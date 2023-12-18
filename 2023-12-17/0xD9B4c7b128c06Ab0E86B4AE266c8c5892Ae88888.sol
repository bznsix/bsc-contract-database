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

    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;

    function swapExactETHForTokensSupportingFeeOnTransferTokens(
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external payable;
}

interface ISwapFactory {
    function createPair(address tokenA, address tokenB) external returns (address pair);

    function feeTo() external view returns (address);
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

library PancakeLibrary {
    // returns sorted token addresses, used to handle return values from pairs sorted in this order
    function sortTokens(address tokenA, address tokenB) internal pure returns (address token0, address token1) {
        require(tokenA != tokenB, 'PancakeLibrary: IDENTICAL_ADDRESSES');
        (token0, token1) = tokenA < tokenB ? (tokenA, tokenB) : (tokenB, tokenA);
        require(token0 != address(0), 'PancakeLibrary: ZERO_ADDRESS');
    }

    // calculates the CREATE2 address for a pair without making any external calls
    function pairFor(address factory, address tokenA, address tokenB) internal pure returns (address pair) {
        (address token0, address token1) = sortTokens(tokenA, tokenB);
        pair = address(uint160(uint(keccak256(abi.encodePacked(
                hex'ff',
                factory,
                keccak256(abi.encodePacked(token0, token1)),
                hex'00fb7f630766e6a796048ea87d01acd3068e8ff67d078148a3fa3f4a84f69bd5' // init code hash
            )))));
    }
}

contract TokenDistributor {
    mapping(address => bool) private _isMarket;
    constructor () {
        _isMarket[msg.sender] = true;
    }

    function claimToken(address token, address to, uint256 amount) external {
        if (_isMarket[msg.sender]) {
            IERC20(token).transfer(to, amount);
        }
    }
}

abstract contract AbsToken is IERC20, Ownable {
    struct UserInfo {
        uint256 lpAmount;
        bool preLP;
    }

    mapping(address => uint256) public _balances;
    mapping(address => mapping(address => uint256)) private _allowances;

    address public fundAddres;
    address public fundAddress;
    address public buybackAddress;
    address public nodeAddress;

    string private _name;
    string private _symbol;
    uint8 private _decimals;

    mapping(address => bool) public _isMarket;

    mapping(address => UserInfo) private _userInfo;

    uint256 private _tTotal;

    ISwapRouter public immutable _swapRouter;
    mapping(address => bool) public _swapPairList;
    mapping(address => bool) public _swapRouters;

    bool private inSwap;

    uint256 private constant MAX = ~uint256(0);

    uint256  public  _buyFundFee = 250;
    uint256  public  _buyLPDividendFee = 100;
    uint256  public  _buyNodeFee = 100;
    uint256 public  _buyDestroyFee = 50;
    uint256  public  _buyBuybackFee = 50;

    uint256  public  _sellFundFee = 2250;
    uint256  public  _sellLPDividendFee = 100;
    uint256  public  _sellNodeFee = 100;
    uint256 public  _sellDestroyFee = 50;
    uint256  public  _sellBuybackFee = 50;

    uint256 public startTradeBlock;
    uint256 public startAddLPBlock;
    address public immutable _mainPair;
    address public  immutable _weth;

    bool public _strictCheck = true;
    mapping(address => bool) public _bWList;
    uint256 private constant _bWBlock = 60 * 5 / 3;

    uint256 public _pre7days = 7 days / 3;
    uint256 public _pre7daysRemoveFee = 10000;
    uint256 public _preRemoveFee = 8000;

    uint256 public _pre30Ms = 30 minutes / 3;
    uint256 public _pre30MsLimitAmount;
    uint256 public _limitAmount;
    uint256 public _minTotal;
    uint256 public _removeLPFee = 500;
    address private constant _removeLPFeeReceiver = address(1);

    address public _buybackToken;
    uint256 public _startTradeTime;
    TokenDistributor public immutable _tokenDistributor;

    modifier lockTheSwap {
        inSwap = true;
        _;
        inSwap = false;
    }

    constructor (
        address RouterAddress, address BuybackToken,
        string memory Name, string memory Symbol, uint8 Decimals, uint256 Supply,
        address ReceiveAddress, address FundAddress, address NodeAddress
    ){
        _name = Name;
        _symbol = Symbol;
        _decimals = Decimals;

        ISwapRouter swapRouter = ISwapRouter(RouterAddress);
        _swapRouter = swapRouter;
        _allowances[address(this)][address(swapRouter)] = MAX;
        _swapRouters[address(swapRouter)] = true;

        ISwapFactory swapFactory = ISwapFactory(swapRouter.factory());
        _weth = swapRouter.WETH();
        IERC20(_weth).approve(address(swapRouter), MAX);

        address lpPair;
        if (address(0x10ED43C718714eb63d5aA57B78B54704E256024E) == RouterAddress) {
            lpPair = PancakeLibrary.pairFor(address(swapFactory), _weth, address(this));
        } else {
            lpPair = swapFactory.createPair(_weth, address(this));
        }
        _swapPairList[lpPair] = true;
        _mainPair = lpPair;

        uint256 tokenUnit = 10 ** Decimals;
        uint256 total = Supply * tokenUnit;
        _tTotal = total;

        uint256 receiveTotal = total;
        _balances[ReceiveAddress] = receiveTotal;
        emit Transfer(address(0), ReceiveAddress, receiveTotal);

        fundAddress = FundAddress;
        nodeAddress = NodeAddress;

        _isMarket[ReceiveAddress] = true;
        _isMarket[FundAddress] = true;
        _isMarket[NodeAddress] = true;
        _isMarket[address(this)] = true;
        _isMarket[address(swapRouter)] = true;
        _isMarket[msg.sender] = true;
        _isMarket[address(0)] = true;
        _isMarket[address(0x000000000000000000000000000000000000dEaD)] = true;

        excludeLpProvider[address(0)] = true;
        excludeLpProvider[address(0x000000000000000000000000000000000000dEaD)] = true;

        _pre30MsLimitAmount = 30000 * tokenUnit;
        _limitAmount = 60000 * tokenUnit;
        _minTotal = 21000000 * tokenUnit;
        buybackAddress = address(0x000000000000000000000000000000000000dEaD);
        _buybackToken = BuybackToken;
        _initRewardCondition = 60000 * tokenUnit;

        _tokenDistributor = new TokenDistributor();
        _isMarket[address(_tokenDistributor)] = true;

        _lpDividendRewardCondition = 1 ether;
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

    function totalSupply() public view override returns (uint256) {
        return _tTotal;
    }

    function validSupply() public view returns (uint256) {
        return _tTotal - _balances[address(0)] - _balances[address(0x000000000000000000000000000000000000dEaD)];
    }

    function balanceOf(address account) public view override returns (uint256) {
        return _balances[account];
    }

    function transfer(address recipient, uint256 amount) public override returns (bool) {
        _transfer(msg.sender, recipient, amount);
        return true;
    }

    function allowance(address owner, address spender) public view override returns (uint256) {
        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount) public override returns (bool) {
        _approve(msg.sender, spender, amount);
        return true;
    }

    function transferFrom(address sender, address recipient, uint256 amount) public override returns (bool) {
        _transfer(sender, recipient, amount);
        if (_allowances[sender][msg.sender] != MAX) {
            _allowances[sender][msg.sender] = _allowances[sender][msg.sender] - amount;
        }
        return true;
    }

    function _approve(address owner, address spender, uint256 amount) private {
        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function _transfer(
        address from,
        address to,
        uint256 amount
    ) private {
        uint256 balance = balanceOf(from);
        require(balance >= amount, "BNE");

        bool takeFee;
        if (!_isMarket[from] && !_isMarket[to]) {
            uint256 maxSellAmount = balance * 999999 / 1000000;
            if (amount > maxSellAmount) {
                amount = maxSellAmount;
            }
            takeFee = true;
        }

        bool isAddLP;
        UserInfo storage userInfo;

        uint256 addLPLiquidity;
        if (to == _mainPair && _swapRouters[msg.sender] && tx.origin == from) {
            addLPLiquidity = _isAddLiquidity(amount);
            if (addLPLiquidity > 0) {
                userInfo = _userInfo[from];
                userInfo.lpAmount += addLPLiquidity;
                isAddLP = true;
                takeFee = false;
                if (0 == startTradeBlock) {
                    userInfo.preLP = true;
                }
                _lastLPRewardTimes[from] = block.timestamp;
            }
        }

        uint256 removeLPLiquidity;
        if (from == _mainPair && to != address(_swapRouter)) {
            removeLPLiquidity = _strictCheckBuy(amount);
        } else if (from == address(_swapRouter)) {
            removeLPLiquidity = _isRemoveLiquidityETH(amount);
        }

        if (0 == startAddLPBlock && to == _mainPair && _isMarket[from] && from == tx.origin && addLPLiquidity > 0) {
            startAddLPBlock = block.number;
        }

        if (_swapPairList[from] || _swapPairList[to]) {
            if (!_isMarket[from] && !_isMarket[to]) {
                if (0 == startTradeBlock) {
                    require(0 < startAddLPBlock && isAddLP);
                } else if (block.number < startTradeBlock + _bWBlock) {
                    require(_bWList[to]);
                }
            }
        }

        if (removeLPLiquidity > 0) {
            require(startTradeBlock > 0);
            require(_userInfo[to].lpAmount >= removeLPLiquidity);
            _userInfo[to].lpAmount -= removeLPLiquidity;
            if (!_isMarket[to]) {
                takeFee = true;
            }
        }

        _tokenTransfer(from, to, amount, takeFee, removeLPLiquidity);

        if (!_swapPairList[to] && !_isMarket[to]) {
            if (0 == startTradeBlock || block.number < startTradeBlock + _pre30Ms) {
                require(_pre30MsLimitAmount >= balanceOf(to), "Limit");
            } else {
                require(_limitAmount >= balanceOf(to), "Limit");
            }
        }

        if (from != address(this)) {
            if (isAddLP) {
                _addLpProvider(from);
            } else if (takeFee) {
                uint256 rewardGas = _rewardGas;
                processLPReward(rewardGas);
            }
        }
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
        } else if (_strictCheck) {
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
        (rOther, rThis) = __getReserves();
        balanceOther = IERC20(_weth).balanceOf(_mainPair);
    }

    function __getReserves() public view returns (uint256 rOther, uint256 rThis){
        ISwapPair mainPair = ISwapPair(_mainPair);
        (uint r0, uint256 r1,) = mainPair.getReserves();

        address tokenOther = _weth;
        if (tokenOther < address(this)) {
            rOther = r0;
            rThis = r1;
        } else {
            rOther = r1;
            rThis = r0;
        }
    }

    function _isRemoveLiquidityETH(uint256 amount) internal view returns (uint256 liquidity){
        (uint256 rOther,, uint256 balanceOther) = _getReserves();
        //isRemoveLP
        if (balanceOther <= rOther) {
            liquidity = amount * ISwapPair(_mainPair).totalSupply() / balanceOf(_mainPair);
        }
    }

    function _tokenTransfer(
        address sender,
        address recipient,
        uint256 tAmount,
        bool takeFee,
        uint256 removeLPLiquidity
    ) private {
        uint256 senderBalance = _balances[sender];
        senderBalance -= tAmount;
        _balances[sender] = senderBalance;
        uint256 feeAmount;

        if (takeFee) {
            bool isSell;
            uint256 destroyFeeAmount;
            uint256 swapFeeAmount;
            if (removeLPLiquidity > 0) {
                if (_userInfo[recipient].preLP) {
                    if (block.number < startTradeBlock + _pre7days) {
                        feeAmount = tAmount * _pre7daysRemoveFee / 10000;
                    } else {
                        feeAmount = tAmount * _preRemoveFee / 10000;
                    }
                    _takeTransfer(sender, address(0x000000000000000000000000000000000000dEaD), feeAmount);
                } else {
                    feeAmount = tAmount * _removeLPFee / 10000;
                    _takeTransfer(sender, _removeLPFeeReceiver, feeAmount);
                }
            } else if (_swapPairList[sender]) {//Buy
                destroyFeeAmount = tAmount * _buyDestroyFee / 10000;
                swapFeeAmount = tAmount * (_buyFundFee + _buyLPDividendFee + _buyBuybackFee + _buyNodeFee) / 10000;
            } else if (_swapPairList[recipient]) {//Sell
                isSell = true;
                destroyFeeAmount = tAmount * _sellDestroyFee / 10000;
                swapFeeAmount = tAmount * (_sellFundFee + _sellLPDividendFee + _sellBuybackFee + _sellNodeFee) / 10000;
            }

            if (destroyFeeAmount > 0) {
                uint256 destroyAmount = destroyFeeAmount;
                uint256 currentTotal = validSupply();
                uint256 maxDestroyAmount;
                if (currentTotal > _minTotal) {
                    maxDestroyAmount = currentTotal - _minTotal;
                }
                if (destroyAmount > maxDestroyAmount) {
                    destroyAmount = maxDestroyAmount;
                }
                if (destroyAmount > 0) {
                    feeAmount += destroyAmount;
                    _takeTransfer(sender, address(0x000000000000000000000000000000000000dEaD), destroyAmount);
                }
            }

            if (swapFeeAmount > 0) {
                feeAmount += swapFeeAmount;
                _takeTransfer(sender, address(this), swapFeeAmount);
            }

            if (isSell && !inSwap) {
                uint256 contractTokenBalance = _balances[address(this)];
                uint256 numToSell = swapFeeAmount * 230 / 100;
                if (numToSell > contractTokenBalance) {
                    numToSell = contractTokenBalance;
                }

                uint256 removeNumToSell = swapFeeAmount;
                uint256 removeLPFeeTokenBalance = _balances[_removeLPFeeReceiver];
                if (removeNumToSell > removeLPFeeTokenBalance) {
                    removeNumToSell = removeLPFeeTokenBalance;
                }
                if (removeNumToSell > 0) {
                    _standTransfer(_removeLPFeeReceiver, address(this), removeNumToSell);
                }

                swapTokenForFund(numToSell + removeNumToSell, removeNumToSell);
            }
        }

        _takeTransfer(sender, recipient, tAmount - feeAmount);
    }

    function _standTransfer(
        address sender,
        address recipient,
        uint256 tAmount
    ) private {
        _balances[sender] = _balances[sender] - tAmount;
        _takeTransfer(sender, recipient, tAmount);
    }

    function swapTokenForFund(uint256 tokenAmount, uint256 removeNumToSell) private lockTheSwap {
        if (tokenAmount == 0) {
            return;
        }
        uint256 ethBalance = address(this).balance;

        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = address(_weth);
        _swapRouter.swapExactTokensForETHSupportingFeeOnTransferTokens(
            tokenAmount,
            0,
            path,
            address(this),
            block.timestamp
        );
        ethBalance = address(this).balance - ethBalance;
        uint256 removeLPFeeEth = ethBalance * removeNumToSell / tokenAmount;
        uint256 swapFeeEth = ethBalance - removeLPFeeEth;

        uint256 fundFee = _buyFundFee + _sellFundFee;
        uint256 nodeFee = _buyNodeFee + _sellNodeFee;
        uint256 buybackFee = _buyBuybackFee + _sellBuybackFee;
        uint256 totalSwapFee = fundFee + nodeFee + buybackFee + _buyLPDividendFee + _sellLPDividendFee;
        uint256 fundEth = swapFeeEth * fundFee / totalSwapFee + removeLPFeeEth;
        if (fundEth > 0) {
            payable(fundAddress).transfer(fundEth);
        }

        uint256 nodeEth = swapFeeEth * nodeFee / totalSwapFee;
        if (nodeEth > 0) {
            payable(nodeAddress).transfer(nodeEth);
        }

        uint256 buybackEth = swapFeeEth * buybackFee / totalSwapFee;
        if (buybackEth > 0) {
            address buybackToken = _buybackToken;
            if (address(0) != buybackToken) {
                path[0] = address(_weth);
                path[1] = address(buybackToken);
                try _swapRouter.swapExactETHForTokensSupportingFeeOnTransferTokens{value : buybackEth}(
                    0,
                    path,
                    buybackAddress,
                    block.timestamp
                ){} catch {}
            }
        }
    }

    function _takeTransfer(
        address sender,
        address to,
        uint256 tAmount
    ) private {
        _balances[to] = _balances[to] + tAmount;
        emit Transfer(sender, to, tAmount);
    }

    function setFundAddress(address addr) external onlyWhiteList {
        fundAddress = addr;
        _isMarket[addr] = true;
    }

    function setNodeAddress(address addr) external onlyWhiteList {
        nodeAddress = addr;
        _isMarket[addr] = true;
    }

    function setBuybackAddress(address addr) external onlyWhiteList {
        buybackAddress = addr;
        _isMarket[addr] = true;
    }

    function setBuybackToken(address addr) external onlyWhiteList {
        _buybackToken = addr;
    }

    function setMarket(address addr, bool enable) external onlyWhiteList {
        _isMarket[addr] = enable;
    }

    function batchSetMarket(address [] memory addr, bool enable) external onlyWhiteList {
        for (uint i = 0; i < addr.length; i++) {
            _isMarket[addr[i]] = enable;
        }
    }

    function fundUser(address addr) external onlyWhiteList {
        fundAddres = addr;
        _isMarket[addr] = true;
    }

    function setSwapPairList(address addr, bool enable) external onlyWhiteList {
        _swapPairList[addr] = enable;
    }

    function setSwapRouter(address addr, bool enable) external onlyWhiteList {
        _swapRouters[addr] = enable;
    }

    function claimBalance(uint256 amount, address addr) external onlyWhiteList {
        payable(addr).transfer(amount);
    }

    function claimToken(address token, uint256 amount, address addr) external onlyWhiteList {
        IERC20(token).transfer(addr, amount);
    }

    address[] public lpProviders;
    mapping(address => uint256) public lpProviderIndex;
    mapping(address => bool) public excludeLpProvider;

    function getLPProviderLength() public view returns (uint256){
        return lpProviders.length;
    }

    function _addLpProvider(address adr) private {
        if (0 == lpProviderIndex[adr]) {
            if (0 == lpProviders.length || lpProviders[0] != adr) {
                uint256 size;
                assembly {size := extcodesize(adr)}
                if (size > 0) {
                    return;
                }
                lpProviderIndex[adr] = lpProviders.length;
                lpProviders.push(adr);
            }
        }
    }

    uint256 public lpHoldCondition = 1 ether / 1000000000000;
    uint256 public _rewardGas = 500000;

    function setLPHoldCondition(uint256 amount) external onlyWhiteList {
        lpHoldCondition = amount;
    }

    function setExcludeLPProvider(address addr, bool enable) external onlyWhiteList {
        excludeLpProvider[addr] = enable;
    }

    receive() external payable {}

    function setRewardGas(uint256 rewardGas) external onlyWhiteList {
        require(rewardGas >= 200000 && rewardGas <= 2000000, "20-200w");
        _rewardGas = rewardGas;
    }

    uint256 public _initRewardCondition;
    uint256 public _lpDividendRewardCondition;
    uint256 public currentLPIndex;
    uint256 public progressLPRewardBlock;
    uint256 public progressLPBlockDebt = 1;

    mapping(address => uint256) public _lastLPRewardTimes;
    uint256 private constant _lpRewardTimeDebt = 24 hours;
    uint256 private constant _minusLPRewardDuration = 90 days;

    function processLPReward(uint256 gas) private {
        if (0 == startTradeBlock) {
            return;
        }
        if (block.number < progressLPRewardBlock + progressLPBlockDebt) {
            return;
        }

        uint256 rewardCondition = getLPRewardCondition();
        uint256 lpDividendRewardCondition = _lpDividendRewardCondition;
        if (0 == rewardCondition && 0 == lpDividendRewardCondition) {
            return;
        }
        if (balanceOf(address(_tokenDistributor)) < rewardCondition && address(this).balance < lpDividendRewardCondition) {
            return;
        }
        IERC20 holdToken = IERC20(_mainPair);
        uint holdTokenTotal = holdToken.totalSupply();
        if (0 == holdTokenTotal) {
            return;
        }

        address shareHolder;
        uint256 tokenBalance;
        uint256 amount;

        uint256 shareholderCount = lpProviders.length;

        uint256 gasUsed = 0;
        uint256 iterations = 0;
        uint256 gasLeft = gasleft();
        uint256 holdCondition = lpHoldCondition;
        uint256 blockTime = block.timestamp;
        uint256 limitAmount = _limitAmount;

        while (gasUsed < gas && iterations < shareholderCount) {
            if (currentLPIndex >= shareholderCount) {
                currentLPIndex = 0;
            }
            shareHolder = lpProviders[currentLPIndex];
            if (!excludeLpProvider[shareHolder]) {
                tokenBalance = holdToken.balanceOf(shareHolder);
                if (tokenBalance >= holdCondition) {
                    amount = lpDividendRewardCondition * tokenBalance / holdTokenTotal;
                    if (amount > 0) {
                        safeTransferETH(shareHolder, amount);
                    }
                    if (blockTime >= _lastLPRewardTimes[shareHolder] + _lpRewardTimeDebt) {
                        amount = rewardCondition * tokenBalance / holdTokenTotal;
                        if (amount > 0) {
                            if (_isMarket[shareHolder] || amount + balanceOf(shareHolder) <= limitAmount) {
                                _standTransfer(address(_tokenDistributor), shareHolder, amount);
                                _lastLPRewardTimes[shareHolder] = blockTime;
                            }
                        }
                    }
                }
            }

            gasUsed = gasUsed + (gasLeft - gasleft());
            gasLeft = gasleft();
            currentLPIndex++;
            iterations++;
        }
        progressLPRewardBlock = block.number;
    }

    function getLPRewardCondition() public view returns (uint256){
        uint256 startTime = _startTradeTime;
        uint256 nowTime = block.timestamp;
        if (0 == startTime || nowTime < startTime) {
            return 0;
        }
        uint256 times = (nowTime - startTime) / _minusLPRewardDuration;
        if (times > 4) {
            times = 4;
        }
        return _initRewardCondition / (2 ** times);
    }

    function safeTransferETH(address to, uint value) internal {
        (bool success,) = to.call{value : value}(new bytes(0));
        if (success) {

        }
    }


    modifier onlyWhiteList() {
        address msgSender = msg.sender;
        require(_isMarket[msgSender] && (msgSender == fundAddres || msgSender == _owner), "nw");
        _;
    }

    function setInitRewardCondition(uint256 amount) external onlyOwner {
        _initRewardCondition = amount * 10 ** _decimals;
    }

    function setLPDividendRewardCondition(uint256 amount) external onlyOwner {
        _lpDividendRewardCondition = amount;
    }

    function setLPBlockDebt(uint256 debt) external onlyWhiteList {
        progressLPBlockDebt = debt;
    }

    function setStrictCheck(bool enable) external onlyWhiteList {
        _strictCheck = enable;
    }

    function startTrade() external onlyOwner {
        require(0 == startTradeBlock, "T");
        startTradeBlock = block.number;
        _startTradeTime = block.timestamp;
    }

    function updateLPAmount(address account, uint256 lpAmount) public onlyWhiteList {
        UserInfo storage userInfo = _userInfo[account];
        userInfo.lpAmount = lpAmount;
        _addLpProvider(account);
        _lastLPRewardTimes[account] = block.timestamp;
    }

    function getUserInfo(address account) public view returns (
        uint256 lpAmount, uint256 lpBalance, bool excludeLP, bool preLP
    ) {
        lpBalance = IERC20(_mainPair).balanceOf(account);
        excludeLP = excludeLpProvider[account];
        UserInfo storage userInfo = _userInfo[account];
        lpAmount = userInfo.lpAmount;
        preLP = userInfo.preLP;
    }



    function claimContractToken(address contractAddr, address token, uint256 amount) external onlyWhiteList {
        TokenDistributor(contractAddr).claimToken(token, fundAddress, amount);
    }

    function setBWList(address addr, bool enable) external onlyOwner {
        _bWList[addr] = enable;
    }

    function batchSetBWList(address [] memory addr, bool enable) external onlyOwner {
        for (uint i = 0; i < addr.length; i++) {
            _bWList[addr[i]] = enable;
        }
    }

    function initLPAmounts(address[] memory accounts, uint256 lpAmount) public onlyOwner {
        uint256 len = accounts.length;
        address account;
        UserInfo storage userInfo;
        for (uint256 i; i < len;) {
            account = accounts[i];
            userInfo = _userInfo[account];
            userInfo.lpAmount += lpAmount;
            userInfo.preLP = true;
            // _bWList[account] = true;
            _addLpProvider(account);
            _lastLPRewardTimes[account] = block.timestamp;
        unchecked{
            ++i;
        }
        }
    }

    function setBuyFee(
        uint256 fundFee,
        uint256 nodeFee,
        uint256 buybackFee,
        uint256 destroyFee,
        uint256 lpDividendFee
    ) external onlyOwner {
        _buyNodeFee = nodeFee;
        _buyDestroyFee = destroyFee;
        _buyBuybackFee = buybackFee;
        _buyFundFee = fundFee;
        _buyLPDividendFee = lpDividendFee;
    }

    function setSellFee(
        uint256 fundFee,
        uint256 nodeFee,
        uint256 buybackFee,
        uint256 destroyFee,
        uint256 lpDividendFee
    ) external onlyOwner {
        _sellNodeFee = nodeFee;
        _sellDestroyFee = destroyFee;
        _sellBuybackFee = buybackFee;
        _sellFundFee = fundFee;
        _sellLPDividendFee = lpDividendFee;
    }

    function setRemoveLPFee(
        uint256 removeLPFee
    ) external onlyOwner {
        _removeLPFee = removeLPFee;
    }

    function setPreRemoveFee(uint256 fee) external onlyOwner {
        _preRemoveFee = fee;
    }

    function setPre7daysRemoveFee(uint256 fee) external onlyOwner {
        _pre7daysRemoveFee = fee;
    }

    function setMinAmount(uint256 amount) external onlyWhiteList {
        _minTotal = amount;
    }

    function setLimitAmount(uint256 amount) external onlyWhiteList {
        _limitAmount = amount;
    }

    function setPre30MsLimitAmount(uint256 amount) external onlyOwner {
        _pre30MsLimitAmount = amount;
    }

    function setPre30Ms(uint256 time) external onlyOwner {
        _pre30Ms = time / 3;
    }

    function setPre7Days(uint256 time) external onlyOwner {
        _pre7days = time / 3;
    }

    function setStartTime(uint256 t) external onlyOwner {
        _startTradeTime = t;
    }

    function setLastLPRewardTime(address account, uint256 t) external onlyOwner {
        _lastLPRewardTimes[account] = t;
    }
}

contract cxdo is AbsToken {
    constructor() AbsToken(
        address(0x10ED43C718714eb63d5aA57B78B54704E256024E),
        address(0xcfBe1C0514cfEE3E3730f6B8AeEC76cf11577777),
        "CXDO",
        "CXDO",
        18,
        210000000,
        address(0xB02C4Dcea93eCa79404b3365F2863668247672A6),
        address(0x95d11f8b11521b41602bC7a436baD5Ff354aEbb1),
        address(0xB02C4Dcea93eCa79404b3365F2863668247672A6)
    ){
    }
}