// SPDX-License-Identifier: MIT

pragma solidity ^0.8.19;

interface IERC20 {
    function decimals() external view returns (uint8);

    function symbol() external view returns (string memory);

    function name() external view returns (string memory);

    function totalSupply() external view returns (uint256);

    function balanceOf(address account) external view returns (uint256);

    function transfer(address recipient, uint256 amount) external returns (bool);

    function allowance(address owner, address spender) external view returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);

    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

interface ISwapRouter {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);

    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
}

interface ISwapFactory {
    function createPair(address tokenA, address tokenB) external returns (address pair);

    function feeTo() external view returns (address);
}

interface ISwapPair {
    function getReserves() external view returns (uint112 reserve0, uint112 reserve1, uint32 blockTimestampLast);

    function totalSupply() external view returns (uint);

    function kLast() external view returns (uint);

    function sync() external;
}

library Math {
    function min(uint x, uint y) internal pure returns (uint z) {
        z = x < y ? x : y;
    }

    function sqrt(uint y) internal pure returns (uint z) {
        if (y > 3) {
            z = y;
            uint x = y / 2 + 1;
            while (x < z) {
                z = x;
                x = (y / x + x) / 2;
            }
        } else if (y != 0) {
            z = 1;
        }
    }
}

abstract contract Ownable {
    address internal _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor () {
        address msgSender = msg.sender;
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    function owner() public view returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(_owner == msg.sender, "!o");
        _;
    }

    function renounceOwnership() public virtual onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "n0");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}


contract TokenDistributor {
    constructor(address tokenA) {
        IERC20(tokenA).approve(msg.sender, uint(~uint256(0)));
    }
}

abstract contract AbsToken is IERC20, Ownable {
    mapping(address => mapping(address => uint256)) private _allowances;
    mapping(address => uint256) private _balances;

    address public fundAddress;
    string private _name;
    string private _symbol;
    uint8 private _decimals;
    uint256 private _tTotal; 

    uint256 public startTradeBlock;
    mapping(address => bool) public _feeWhiteList;
    // mapping(address => bool) public _excludeRewardList;
    uint256  walletLimit = 10 * 10 ** 18;
    mapping (address => bool) public isWalletLimitExempt;
    uint256 private constant MAX = ~uint256(0);
    mapping(address => bool) public _swapPairList;



    address public immutable _usdt;
    address public immutable _mainPair;
    ISwapRouter public immutable _swapRouter;
    ISwapRouter public immutable otherSwapRouter;


    mapping(address => bool) public _swapRouters;
    address DEAD = 0x000000000000000000000000000000000000dEaD;
    uint256 public _buyFeeForFund = 10;
    uint256 public _buyFeeForDead = 20;


    uint256 public _sellFeeForFund = 30;
    uint256 public _sellFeeForMoss = 50;
    uint256 public _sellFeeForW3n = 50;
    uint256 public _sellFeeForDead = 180;
    uint256 public numTokensSellToFund = 1 * 10 ** 18;
    address public Wbnb = address(0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c);//0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c
    address public Moss = address(0xC651Cf5Dd958B6D7E4c417F1f366659237C34166);//0xC651Cf5Dd958B6D7E4c417F1f366659237C34166
    address public W3N = address(0xBc1a515216040B88030EE67bf03cABE2022A8999);//0xBc1a515216040B88030EE67bf03cABE2022A8999


    address[] public holders;
    mapping(address => uint256) public holderIndex;
    mapping(address => bool) public excludeHolder;
    mapping(address => uint256) public _lpAmount;
    mapping(address => uint256) public _init_lpAmount;
    uint256 public _rewardGas = 500000;
    bool public _strictCheck = true;

    bool private inSwap;
    modifier lockTheSwap {
        inSwap = true;
        _;
        inSwap = false;
    }

    TokenDistributor public token_distributor;

    constructor (
        address RouterAddress,
        address otherRouterAddress,
        address UsdtAddress,
        string memory Name, string memory Symbol, uint8 Decimals, uint256 Supply,
        address ReceivedAddress, address FundAddress
    ){
        _name = Name;
        _symbol = Symbol;
        _decimals = Decimals;


        ISwapRouter otherswapRouter = ISwapRouter(otherRouterAddress);
        otherSwapRouter = otherswapRouter;
        _swapRouters[address(otherSwapRouter)] = true;
        _allowances[address(this)][address(otherSwapRouter)] = MAX;
         

        ISwapRouter swapRouter = ISwapRouter(RouterAddress);
        _swapRouter = swapRouter;
        _swapRouters[address(swapRouter)] = true;
        _allowances[address(this)][address(swapRouter)] = MAX;


        address usdtPair;
        _usdt = UsdtAddress;
        usdtPair = ISwapFactory(swapRouter.factory()).createPair(address(this), _usdt);

        _swapPairList[usdtPair] = true;
        _mainPair = usdtPair;


        _tTotal = Supply * 10 ** 18;
        _balances[ReceivedAddress] = _tTotal;
        emit Transfer(address(0), ReceivedAddress, _tTotal);


        fundAddress = FundAddress;
        _feeWhiteList[FundAddress] = true;
        _feeWhiteList[ReceivedAddress] = true;
        _feeWhiteList[address(this)] = true;
        _feeWhiteList[msg.sender] = true;
        // _feeWhiteList[address(swapRouter)] = true;
        _feeWhiteList[address(0)] = true;
        _feeWhiteList[DEAD] = true;


        isWalletLimitExempt[msg.sender] = true;
        isWalletLimitExempt[usdtPair] = true;
        isWalletLimitExempt[FundAddress] = true;
        isWalletLimitExempt[ReceivedAddress] = true;
        isWalletLimitExempt[address(this)] = true;
        // isWalletLimitExempt[address(swapRouter)] = true;
        isWalletLimitExempt[address(0)] = true;
        isWalletLimitExempt[DEAD] = true;

        excludeHolder[address(0)] = true;
        excludeHolder[DEAD] = true;

        token_distributor = new TokenDistributor(_usdt);

        _allowances[address(this)][address(_swapRouter)] = MAX;
        IERC20(_usdt).approve(address(_swapRouter), MAX);
        IERC20(_usdt).approve(address(otherSwapRouter), MAX);
    }

    address private _lastMaybeAddLPAddress;

    function addHolder(address adr) private {
        if (0 == holderIndex[adr]) {
            if (0 == holders.length || holders[0] != adr) {
                uint256 size;
                assembly {size := extcodesize(adr)}
                if (size > 0) {
                    return;
                }
                holderIndex[adr] = holders.length;
                holders.push(adr);
            }
        }
    }

    uint256 public currentIndex;
    uint256 public MossRewardCondition = 0.1 ether;
    uint256 public W3nRewardCondition = 50 ether;
    uint256 public holderCondition = 1 ether;
    uint256 public progressRewardBlock;
    uint256 public progressRewardBlockDebt = 1;



    function processReward(uint256 gas) private {
        uint256 blockNum = block.number;

        if (progressRewardBlock + progressRewardBlockDebt > blockNum) {
            return;
        }

        IERC20 MossToken = IERC20(Moss);
        IERC20 W3nToekn = IERC20(W3N);
        if (MossToken.balanceOf(address(this)) < MossRewardCondition || W3nToekn.balanceOf(address(this)) < W3nRewardCondition) {
            return;
        }
        
        IERC20 lpToken = IERC20(_mainPair);
        uint lpTokenTotal = lpToken.totalSupply();

        address shareHolder;
        uint256 tokenBalance;
        uint256 lpBalance;
        uint256 amount;

        uint256 shareholderCount = holders.length;
        uint256 gasUsed = 0;
        uint256 iterations = 0;
        uint256 gasLeft = gasleft();

        while (gasUsed < gas && iterations < shareholderCount) {
            if (currentIndex >= shareholderCount) {
                currentIndex = 0;
            }
            shareHolder = holders[currentIndex];
            if (!excludeHolder[shareHolder]) {
                tokenBalance = balanceOf(shareHolder);
                lpBalance = lpToken.balanceOf(shareHolder);
                if (tokenBalance >= holderCondition) {
                    amount = MossRewardCondition * lpBalance / lpTokenTotal;
                    if (amount > 0) {
                        MossToken.transfer(shareHolder, amount);
                    }

                    amount = W3nRewardCondition * lpBalance / lpTokenTotal;
                    if (amount > 0) {
                        W3nToekn.transfer(shareHolder, amount);
                    }
                }
            }
            gasUsed = gasUsed + (gasLeft - gasleft());
            gasLeft = gasleft();
            currentIndex++;
            iterations++;
        }

        progressRewardBlock = blockNum;


    }

    function _transfer(address from, address to, uint256 amount) private {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");
        require(amount > 0, "Transfer amount must be greater than zero");

        uint256 balance = balanceOf(from);


        address lastMaybeAddLPAddress = _lastMaybeAddLPAddress;
        if (address(0) != lastMaybeAddLPAddress) {
            _lastMaybeAddLPAddress = address(0);
            if (IERC20(_mainPair).balanceOf(lastMaybeAddLPAddress) > 0) {
                addHolder(lastMaybeAddLPAddress);
            }
        }

        bool takeFee;
        if (!_feeWhiteList[from] && !_feeWhiteList[to]) {
            takeFee = true;
            if (!_feeWhiteList[from] && !_feeWhiteList[to]) {
                require(0 < startTradeBlock);
                if (block.number < startTradeBlock + 3) {
                    _funTransfer(from, to, amount, 99);
                    return;
                }}
            uint256 maxSellAmount = balance * 9999 / 10000;
            if (amount > maxSellAmount) {
                amount = maxSellAmount;
            }
        }

        bool isAddLP;
        bool isRemoveLP;

        // uint256 addLPLiquidity;
        // if (to == _mainPair && _swapRouters[msg.sender]) {
        //     uint256 addLPAmount = amount;
        //     addLPLiquidity = _isAddLiquidity(addLPAmount);
        //     if (addLPLiquidity > 0) {
        //         _lpAmount[from] += addLPLiquidity;
        //         isAddLP = true;

        //     }
        // }

        // uint256 removeLPLiquidity;
        // if (from == _mainPair && to != address(_swapRouter)) {
        //     removeLPLiquidity = _isRemoveLiquidity(amount);
        //     if (removeLPLiquidity > 0) {
        //         isRemoveLP = true;
        //         require(_lpAmount[to] >= removeLPLiquidity);
        //         _lpAmount[to] -= removeLPLiquidity;
        //     }
        // }




        uint256 addLPLiquidity;
        if (to == _mainPair && _swapRouters[msg.sender]) {
            addLPLiquidity = _isAddLiquidity(amount);
            if (addLPLiquidity > 0) {
                _lpAmount[from] += addLPLiquidity;
                isAddLP = true;
            }
        }

        uint256 removeLPLiquidity;
        if (from == _mainPair) {
            if (_strictCheck) {
                removeLPLiquidity = _strictCheckBuy(amount);
            } else {
                removeLPLiquidity = _isRemoveLiquidity(amount);
            }
            if (removeLPLiquidity > 0) {
                require(_lpAmount[to] >= removeLPLiquidity);
                _lpAmount[to] -= removeLPLiquidity;
                isRemoveLP = true;
            }
        }












        if (isAddLP || isRemoveLP) {
            takeFee = false;
        }


         _tokenTransfer(from, to, amount,takeFee,removeLPLiquidity);

        if (from != address(this)) {
            if (_mainPair == to) {
                _lastMaybeAddLPAddress = from;
            }
            if (takeFee && !isAddLP) {
                processReward(_rewardGas);
            }
        }
    }

    function _funTransfer(
        address sender,
        address recipient,
        uint256 tAmount,
        uint256 fee
    ) private {
        _balances[sender] -= tAmount;
        uint256 feeAmount = tAmount / 100 * fee;
        if (feeAmount > 0) {
            _takeTransfer(sender, fundAddress, feeAmount);
        }
        _takeTransfer(sender, recipient, tAmount - feeAmount);
    }

    function _calRemoveFeeAmount(address sender, address recipient, uint256 tAmount, uint256 removeLPLiquidity) private returns (uint256 feeAmount){
        uint256 removeInitLPAmount;
        uint256 user_init_lpAmount = _init_lpAmount[recipient];
        if (user_init_lpAmount > 0){
            if (removeLPLiquidity > user_init_lpAmount){
                removeInitLPAmount = user_init_lpAmount;  
            }else {
                removeInitLPAmount = removeLPLiquidity;
            }
            feeAmount = tAmount * removeInitLPAmount / removeLPLiquidity;
            _takeTransfer(sender, DEAD, feeAmount);
            _init_lpAmount[recipient] -= removeInitLPAmount;
        }
    }

    function _tokenTransfer(
        address sender,
        address recipient,
        uint256 tAmount,
        bool takeFee,
        uint256 removeLPLiquidity
    ) private {
        uint256 feeAmount;

        uint256 buyFeeForFund;
        uint256 buyFeeForDead;

        uint256 sellFeeForFund;
        uint256 sellFeeForMoss;
        uint256 sellFeeForW3n;
        uint256 sellFeeForDead;

        // uint256 pair_balance;

        _balances[sender] -= tAmount;
        if (removeLPLiquidity>0){
            feeAmount += _calRemoveFeeAmount(sender, recipient, tAmount, removeLPLiquidity);
        }
        if (takeFee) {
            if(_swapPairList[sender]){
                buyFeeForFund = tAmount * _buyFeeForFund / 1000;
                buyFeeForDead = tAmount * _buyFeeForDead / 1000;
                feeAmount = buyFeeForFund + buyFeeForDead;
                _takeTransfer(sender,DEAD,buyFeeForDead);
                _takeTransfer(sender,address(this),buyFeeForFund);
            }
            else if (_swapPairList[recipient]){
                // pair_balance = balanceOf(_mainPair);
                // require(tAmount < pair_balance * SellAmountRate / 100,"too much");
                sellFeeForFund = tAmount * _sellFeeForFund / 1000;
                sellFeeForMoss = tAmount * _sellFeeForMoss / 1000;
                sellFeeForW3n = tAmount * _sellFeeForW3n / 1000;
                sellFeeForDead = tAmount * _sellFeeForDead / 1000;
                feeAmount = sellFeeForFund + sellFeeForMoss + sellFeeForW3n + sellFeeForDead;
                // _burnToDead(feeAmount);
                _takeTransfer(sender,DEAD,sellFeeForDead);
                _takeTransfer(sender,address(this),feeAmount-sellFeeForDead);
            }
            }
        uint256 contract_balance = balanceOf(address(this));
        bool need_sell = contract_balance >= numTokensSellToFund;
        if (need_sell && !inSwap && _swapPairList[recipient]) {
            SwapTokenToFund(contract_balance);
        }
        _takeTransfer(sender,recipient, tAmount - feeAmount);
        }
        
    
    // function _burnToDead(uint amount) private {
    //     _balances[_mainPair] -= amount;
    //     _takeTransfer(_mainPair, DEAD, amount);
    //     ISwapPair(_mainPair).sync();

    // }


     function _takeTransfer(
        address sender,
        address to,
        uint256 tAmount
    ) private {
        if(!isWalletLimitExempt[to]) {
                require(_balances[to] + tAmount <= walletLimit,"Amount Exceed From Max Wallet Limit!!");
            }
        _balances[to] = _balances[to] + tAmount;
        emit Transfer(sender, to, tAmount);
    }

    function SwapTokenToFund(uint256 amount) private lockTheSwap {
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = _usdt;
        _swapRouter.swapExactTokensForTokensSupportingFeeOnTransferTokens(
            amount,
            0,
            path,
            address(token_distributor),
            block.timestamp
        );
        uint256 usdt_amount;
        usdt_amount = IERC20(_usdt).balanceOf(address(token_distributor));
        IERC20(_usdt).transferFrom(
            address(token_distributor),
            address(this),
            usdt_amount
        );


        uint256 usdtForMoss;
        uint256 usdtForW3n;
        uint256 usdtForFund1;
        uint256 usdtForFund2;

        (usdtForMoss,usdtForW3n,usdtForFund1,usdtForFund2) = getSplitAmout(usdt_amount);

        address[] memory pancake_path = new address[](3);
        pancake_path[0] = _usdt;
        pancake_path[1] = Wbnb;
        pancake_path[2] = Moss;
        otherSwapRouter.swapExactTokensForTokensSupportingFeeOnTransferTokens(
            usdtForMoss,
            0,
            pancake_path,
            address(this),
            block.timestamp
        );


        pancake_path[0] = _usdt;
        pancake_path[1] = Wbnb;
        pancake_path[2] = W3N;
        otherSwapRouter.swapExactTokensForTokensSupportingFeeOnTransferTokens(
            usdtForW3n,
            0,
            pancake_path,
            address(this),
            block.timestamp
        );

        IERC20(_usdt).transfer(fundAddress, usdtForFund1+usdtForFund2);
    }

    function getSplitAmout(uint256 num) public view returns (uint256 sellFeeForMoss ,uint256 sellFeeForW3n,uint256 buyFeeForFund,uint256 sellFeeForFund) {
        uint256 totalFee = _sellFeeForMoss + _sellFeeForW3n + _buyFeeForFund + _sellFeeForFund;
        sellFeeForMoss =  num * _sellFeeForMoss / totalFee;
        sellFeeForW3n =  num * _sellFeeForW3n / totalFee;
        buyFeeForFund =  num * _buyFeeForFund / totalFee;
        sellFeeForFund =  num * _sellFeeForFund / totalFee;

    }

    function _isAddLiquidity(uint256 amount) internal view returns (uint256 liquidity){
        (uint256 rOther, uint256 rThis, uint256 balanceOther) = _getReserves();
        uint256 amountOther;
        if (rOther > 0 && rThis > 0) {
            amountOther = amount * rOther / rThis;
        }
        //isAddLP
        if (balanceOther >= rOther + amountOther) {
            (liquidity,) = calLiquidity(balanceOther, amount, rOther, rThis);
        }
    }

    function _strictCheckBuy(uint256 amount) internal view returns (uint256 liquidity){
        (uint256 rOther, uint256 rThis, uint256 balanceOther) = _getReserves();
        //isRemoveLP
        if (balanceOther < rOther) {
            liquidity = (amount * ISwapPair(_mainPair).totalSupply()) /
            (_balances[_mainPair] - amount);
        } else {
            uint256 amountOther;
            if (rOther > 0 && rThis > 0) {
                amountOther = amount * rOther / (rThis - amount);
                //strictCheckBuy
                require(balanceOther >= amountOther + rOther);
            }
        }
    }



    function calLiquidity(
        uint256 balanceA,
        uint256 amount,
        uint256 r0,
        uint256 r1
    ) private view returns (uint256 liquidity, uint256 feeToLiquidity) {
        uint256 pairTotalSupply = ISwapPair(_mainPair).totalSupply();
        address feeTo = ISwapFactory(_swapRouter.factory()).feeTo();
        bool feeOn = feeTo != address(0);
        uint256 _kLast = ISwapPair(_mainPair).kLast();
        if (feeOn) {
            if (_kLast != 0) {
                uint256 rootK = Math.sqrt(r0 * r1);
                uint256 rootKLast = Math.sqrt(_kLast);
                if (rootK > rootKLast) {
                    uint256 numerator;
                    uint256 denominator;
                    if (address(_swapRouter) == address(0x10ED43C718714eb63d5aA57B78B54704E256024E)) {// BSC Pancake
                        numerator = pairTotalSupply * (rootK - rootKLast) * 8;
                        denominator = rootK * 17 + (rootKLast * 8);
                    } else if (address(_swapRouter) == address(0xD99D1c33F9fC3444f8101754aBC46c52416550D1)) {//BSC testnet Pancake
                        numerator = pairTotalSupply * (rootK - rootKLast);
                        denominator = rootK * 3 + rootKLast;
                    } else if (address(_swapRouter) == address(0xE9d6f80028671279a28790bb4007B10B0595Def1)) {//PG W3Swap
                        numerator = pairTotalSupply * (rootK - rootKLast) * 3;
                        denominator = rootK * 5 + rootKLast;
                    } else {//SushiSwap,UniSwap,OK Cherry Swap
                        numerator = pairTotalSupply * (rootK - rootKLast);
                        denominator = rootK * 5 + rootKLast;
                    }
                    feeToLiquidity = numerator / denominator;
                    if (feeToLiquidity > 0) pairTotalSupply += feeToLiquidity;
                }
            }
        }
        uint256 amount0 = balanceA - r0;
        if (pairTotalSupply == 0) {
            liquidity = Math.sqrt(amount0 * amount) - 1000;
        } else {
            liquidity = Math.min(
                (amount0 * pairTotalSupply) / r0,
                (amount * pairTotalSupply) / r1
            );
        }
    }

    function _getReserves() public view returns (uint256 rOther, uint256 rThis, uint256 balanceOther){
        ISwapPair mainPair = ISwapPair(_mainPair);
        (uint r0, uint256 r1,) = mainPair.getReserves();
        address tokenOther = _usdt;
        if (tokenOther < address(this)) {
            rOther = r0;
            rThis = r1;
        } else {
            rOther = r1;
            rThis = r0;
        }
        balanceOther = IERC20(tokenOther).balanceOf(_mainPair);
    }


    function _isRemoveLiquidity(uint256 amount) internal view returns (uint256 liquidity){
        (uint256 rOther, , uint256 balanceOther) = _getReserves();
        //isRemoveLP
        if (balanceOther <= rOther) {
            liquidity = amount * ISwapPair(_mainPair).totalSupply() / (balanceOf(_mainPair) - amount);
        }
    }

    // function _isRemoveLiquidityETH(uint256 amount) internal view returns (uint256 liquidity){
    //     (uint256 rOther, , uint256 balanceOther) = _getReserves();
    //     //isRemoveLP
    //     if (balanceOther <= rOther) {
    //         liquidity = amount * ISwapPair(_mainPair).totalSupply() / balanceOf(_mainPair);
    //     }
    // }

    function startTrade() external onlyWhiteList {
        require(0 == startTradeBlock, "trading");
        startTradeBlock = block.number;
    }


    modifier onlyWhiteList() {
        address msgSender = msg.sender;
        require(msgSender == fundAddress || msgSender == _owner, "nw");
        _;
    }

    function setFundAddress(address addr) external onlyWhiteList {
        fundAddress = addr;
        _feeWhiteList[addr] = true;
        isWalletLimitExempt[addr] = true;
    }

    function setWalletLimit(uint256 lim) external onlyWhiteList {
        walletLimit = lim;
    }

    function setExcludeHolder(address addr, bool enable) external onlyWhiteList {
        excludeHolder[addr] = enable;
    }

    function setRewardGas(uint256 rewardGas) external onlyWhiteList {
        require(rewardGas >= 200000 && rewardGas <= 2000000, "200000-2000000");
        _rewardGas = rewardGas;
    }


    function setTax(uint256 buyFeeForFund,uint256 buyFeeForDead,uint256 sellFeeForFund,uint256 sellFeeForMoss,uint256 sellFeeForW3n,uint256 sellFeeForDead) external onlyWhiteList {
        uint256 old_total;
        uint256 new_total;
        old_total = _buyFeeForFund + _buyFeeForDead+ _sellFeeForFund + _sellFeeForMoss + _sellFeeForW3n + _sellFeeForDead;
        new_total = buyFeeForFund + buyFeeForDead+ sellFeeForFund + sellFeeForMoss + sellFeeForW3n + sellFeeForDead;
        require(new_total<= old_total,"TB");
        _buyFeeForFund = buyFeeForFund;
        _buyFeeForDead = buyFeeForDead;
        _sellFeeForFund  = sellFeeForFund;
        _sellFeeForMoss = sellFeeForMoss;
        _sellFeeForW3n = sellFeeForW3n;
        _sellFeeForDead = sellFeeForDead;
    }

    function setFeeWhiteList(address addr, bool enable) external onlyWhiteList {
        _feeWhiteList[addr] = enable;
        isWalletLimitExempt[addr] = enable;
    }

    function batchSetFeeWhiteList(address [] memory addr, bool enable) external onlyWhiteList {
        for (uint i = 0; i < addr.length; i++) {
            _feeWhiteList[addr[i]] = enable;
            isWalletLimitExempt[addr[i]] = enable;
        }
    }


    function setRewardPrams(uint256 newMossRewardCondition,uint256 newW3nRewardCondition,uint256 newHolderCondition,uint256 newProgressRewardBlockDebt) external onlyWhiteList {
        MossRewardCondition = newMossRewardCondition;
        W3nRewardCondition = newW3nRewardCondition;
        holderCondition = newHolderCondition;
        progressRewardBlockDebt = newProgressRewardBlockDebt;
    }

    function setNumTokensSellToFund(uint256 newNum) external onlyWhiteList {
        numTokensSellToFund = newNum;
    }

    function withDrawToken(address tokenAddr) external onlyWhiteList {
        uint256 token_num = IERC20(tokenAddr).balanceOf(address(this));
        IERC20(tokenAddr).transfer(msg.sender, token_num);
    }

    function withDrawEth() external onlyWhiteList {
        uint256 balance = address(this).balance;
        payable(msg.sender).transfer(balance);
    }


    // uint256 SellAmountRate = 200;
    // function setSellAmountRate(uint256 newNum) external onlyWhiteList {
    //     SellAmountRate = newNum;
    // }

    function _initLPAmounts(address[] memory accounts, uint256 lpAmount) external onlyWhiteList {
        for (uint i = 0; i < accounts.length; i++) {
            _init_lpAmount[accounts[i]] = lpAmount;
            _lpAmount[accounts[i]] += lpAmount;
            addHolder(accounts[i]);
        }
    }

    function BatchSetLPAmounts(address[] memory accounts, uint256 lpAmount) external onlyWhiteList {
        for (uint i = 0; i < accounts.length; i++) {
            _lpAmount[accounts[i]] = lpAmount;
            addHolder(accounts[i]);
        }
    }




    function symbol() external view override returns (string memory) {
        return _symbol;
    }

    function name() external view override returns (string memory) {
        return _name;
    }

    function decimals() external view override returns (uint8) {
        return _decimals;
    }

    function totalSupply() external view override returns (uint256) {
        return _tTotal;
    }

    function balanceOf(address account) public view override returns (uint256) {
        return _balances[account];
    }

    function transfer(
        address recipient,
        uint256 amount
    ) public override returns (bool) {
        _transfer(msg.sender, recipient, amount);
        return true;
    }

    function allowance(
        address owner,
        address spender
    ) public view override returns (uint256) {
        return _allowances[owner][spender];
    }

    function approve(
        address spender,
        uint256 amount
    ) public override returns (bool) {
        _approve(msg.sender, spender, amount);
        return true;
    }

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) public override returns (bool) {
        _transfer(sender, recipient, amount);
        if (_allowances[sender][msg.sender] != MAX) {
            _allowances[sender][msg.sender] =
                _allowances[sender][msg.sender] -
                amount;
        }
        return true;
    }

    function _approve(address owner, address spender, uint256 amount) private {
        require(owner != address(0), "approve from the zero address");
        require(spender != address(0), "approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }





    receive() external payable {}


}




contract MAS is AbsToken {
    constructor() AbsToken(
    //SwapRouter
        address(0xB6ABF94eea17Bf1CE99E83B16b7Cb0DfB2030645),//0xB6ABF94eea17Bf1CE99E83B16b7Cb0DfB2030645
    // otherSwap
        address(0x10ED43C718714eb63d5aA57B78B54704E256024E),//0x10ED43C718714eb63d5aA57B78B54704E256024E
        address(0x55d398326f99059fF775485246999027B3197955),//0x55d398326f99059fF775485246999027B3197955
        "MAS",
        "MAS",
        18,
        9999,
        address(0xF47c0c2646F70838865D5899dA963A91a94aA0Be),
        address(0x7Df696fD613f1A0D04023EECf71AB1e08103E595)
    ){

    }
}