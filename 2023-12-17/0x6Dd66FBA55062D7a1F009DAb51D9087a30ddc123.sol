// SPDX-License-Identifier: MIT
// tiantian
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

    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;

    function addLiquidity(
        address tokenA,
        address tokenB,
        uint amountADesired,
        uint amountBDesired,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline
    ) external returns (uint amountA, uint amountB, uint liquidity);
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
    mapping(address => bool) private _feeWhiteList;
    constructor (address token) {
        _feeWhiteList[msg.sender] = true;
        IERC20(token).approve(msg.sender, ~uint256(0));
    }

    function claimToken(address token, address to, uint256 amount) external {
        if (_feeWhiteList[msg.sender]) {
            IERC20(token).transfer(to, amount);
        }
    }
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

interface INFT {
    function totalSupply() external view returns (uint256);

    function ownerOf(uint256 tokenId) external view returns (address owner);
}

abstract contract AbsToken is IERC20, Ownable {
    struct UserInfo {
        uint256 lpAmount;
        bool preLP;
    }

    mapping(address => uint256) private _balances;
    mapping(address => mapping(address => uint256)) private _allowances;

    address private fundAddress;
    address private fundAddress2;

    string private _name;
    string private _symbol;
    uint8 private _decimals;

    mapping(address => bool) public _feeWhiteList;
    mapping(address => bool) public _blackList;
    address [] private _preList;
    mapping(address => bool) public _bWList;

    uint256 private _tTotal;

    ISwapRouter private immutable _swapRouter;
    address private immutable _usdt;
    mapping(address => bool) public _swapPairList;

    bool private inSwap;

    uint256 private constant MAX = ~uint256(0);
    TokenDistributor public immutable _tokenDistributor;
    TokenDistributor public immutable _nftDistributor;

    uint256 public _buyDestroyFee = 100;
    uint256 public _buyFundFee = 100;
    uint256 public _buyFundFee2 = 0;
    uint256 public _buyLPDividendFee = 200;
    uint256 public _buyLPFee = 0;
    uint256 public _buyHolderOrderDividendFee = 0;
    uint256 public _buyNFTFee = 50;

    uint256 public _sellDestroyFee = 100;
    uint256 public _sellFundFee = 100;
    uint256 public _sellFundFee2 = 0;
    uint256 public _sellLPDividendFee = 200;
    uint256 public _sellLPFee = 0;
    uint256 public _sellHolderOrderDividendFee = 0;
    uint256 public _sellNFTFee = 50;

    uint256 public _transferFee = 0;

    uint256 public startTradeBlock;
    uint256 public startAddLPBlock;
    uint256 public startBWBlock;

    address public immutable _mainPair;

    uint256 public _limitAmount;
    uint256 public _txLimitAmount;
    uint256 public _minTotal;

    address public _receiveAddress;

    uint256 public _removeLPFee = 10;
    address public _lpFeeReceiver;

    uint256 private constant _killBlock = 0;
    mapping(address => UserInfo) private _userInfo;
    uint256 public _rewardHoldCondition;

    mapping(address => bool) public _swapRouters;
    bool public _strictCheck = true;

    mapping(address => uint256) public _buyTimes;
    uint256 public _buyRobotRate = 9900;
    bool public _onlyBuy1Time = true;
    address public _nftAddress;

    modifier lockTheSwap {
        inSwap = true;
        _;
        inSwap = false;
    }

    constructor (
        address RouterAddress, address USDTAddress,
        string memory Name, string memory Symbol, uint8 Decimals, uint256 Supply,
        address FundAddress, address FundAddress2, address ReceiveAddress,
        uint256 LimitAmount, uint256 MinTotal, uint256 TxLimitAmount, address NFTAddress
    ){
        _name = Name;
        _symbol = Symbol;
        _decimals = Decimals;

        ISwapRouter swapRouter = ISwapRouter(RouterAddress);
        address usdt = USDTAddress;
        IERC20(usdt).approve(address(swapRouter), MAX);

        _usdt = usdt;
        _swapRouter = swapRouter;
        _allowances[address(this)][address(swapRouter)] = MAX;
        _swapRouters[address(swapRouter)] = true;

        ISwapFactory swapFactory = ISwapFactory(swapRouter.factory());
        address usdtPair;
        if (address(0x10ED43C718714eb63d5aA57B78B54704E256024E) == address(swapRouter)) {
            usdtPair = PancakeLibrary.pairFor(address(swapFactory), _usdt, address(this));
        } else {
            usdtPair = swapFactory.createPair(_usdt, address(this));
        }
        _mainPair = usdtPair;
        _swapPairList[usdtPair] = true;

        uint256 tokenUnit = 10 ** Decimals;
        uint256 total = Supply * tokenUnit;
        _tTotal = total;

        _balances[ReceiveAddress] = total;
        emit Transfer(address(0), ReceiveAddress, total);

        _receiveAddress = ReceiveAddress;
        _lpFeeReceiver = ReceiveAddress;
        fundAddress = FundAddress;
        fundAddress2 = FundAddress2;

        _feeWhiteList[FundAddress] = true;
        _feeWhiteList[FundAddress2] = true;
        _feeWhiteList[ReceiveAddress] = true;
        _feeWhiteList[address(this)] = true;
        _feeWhiteList[msg.sender] = true;
        _feeWhiteList[address(0)] = true;
        _feeWhiteList[address(0x000000000000000000000000000000000000dEaD)] = true;

        _limitAmount = LimitAmount;
        _txLimitAmount = TxLimitAmount;

        _tokenDistributor = new TokenDistributor(usdt);
        _nftDistributor = new TokenDistributor(usdt);
        _feeWhiteList[address(_tokenDistributor)] = true;

        _minTotal = MinTotal * 10 ** Decimals;

        excludeHolder[address(0)] = true;
        excludeHolder[address(0x000000000000000000000000000000000000dEaD)] = true;
        uint256 usdtUnit = 10 ** IERC20(usdt).decimals();
        holderRewardCondition = 100 * usdtUnit;
        _rewardHoldCondition = tokenUnit * 1000;
        addHolder(ReceiveAddress);
        _nftAddress = NFTAddress;
        nftRewardCondition = 100 * usdtUnit;
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
        return _tTotal - _balances[address(0)] - _balances[address(0x000000000000000000000000000000000000dEaD)];
    }

    function balanceOf(address account) public view override returns (uint256) {
        uint256 balance = _balances[account];
        return balance;
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
        require(!_blackList[from] || _feeWhiteList[from], "BL");

        uint256 balance = balanceOf(from);
        require(balance >= amount, "BNE");
        bool takeFee;
        bool isAddLP;
        bool isRemoveLP;

        if (!_feeWhiteList[from] && !_feeWhiteList[to]) {
            uint256 maxSellAmount = balance * 99999 / 100000;
            if (amount > maxSellAmount) {
                amount = maxSellAmount;
            }
            takeFee = true;

            if (_txLimitAmount > 0) {
                require(_txLimitAmount >= amount, "txLimit");
            }
        }

        uint256 addLPLiquidity;
        if (to == _mainPair && _swapRouters[msg.sender]) {
            uint256 addLPAmount = amount;
            addLPLiquidity = _isAddLiquidity(addLPAmount);
            if (addLPLiquidity > 0) {
                UserInfo storage userInfo = _userInfo[from];
                userInfo.lpAmount += addLPLiquidity;
                isAddLP = true;
                if (0 == startTradeBlock) {
                    userInfo.preLP = true;
                }
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
                require(_userInfo[to].lpAmount >= removeLPLiquidity);
                _userInfo[to].lpAmount -= removeLPLiquidity;
                isRemoveLP = true;
            }
        }

        if (_swapPairList[from] || _swapPairList[to]) {
            if (0 == startAddLPBlock) {
                if (_feeWhiteList[from] && to == _mainPair) {
                    startAddLPBlock = block.number;
                }
            }

            if (!_feeWhiteList[from] && !_feeWhiteList[to]) {
                if (0 == startTradeBlock) {
                    if (startBWBlock > 0 && (_bWList[to])) {

                    } else {
                        require(0 < startAddLPBlock && isAddLP, "!Trade");
                    }
                } else {
                    if (!isAddLP && !isRemoveLP && block.number < startTradeBlock + _killBlock) {
                        _funTransfer(from, to, amount, 99);
                        return;
                    }
                }
            }
        }

        if (isAddLP) {
            takeFee = false;
        }

        _tokenTransfer(from, to, amount, takeFee, isRemoveLP);

        if (_limitAmount > 0 && !_swapPairList[to] && !_feeWhiteList[to]) {
            require(_limitAmount >= balanceOf(to), "Limit");
        }

        if (from != address(this)) {
            if (isAddLP) {
                addHolder(from);
            } else if (!_feeWhiteList[from]) {
                uint256 rewardGas = _rewardGas;
                processNFTReward(rewardGas);
                if (processNFTBlock != block.number) {
                    processReward(rewardGas);
                }
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
        (rOther, rThis) = __getReserves();
        balanceOther = IERC20(_usdt).balanceOf(_mainPair);
    }

    function __getReserves() public view returns (uint256 rOther, uint256 rThis){
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
    }

    function _isRemoveLiquidity(uint256 amount) internal view returns (uint256 liquidity){
        (uint256 rOther, , uint256 balanceOther) = _getReserves();
        //isRemoveLP
        if (balanceOther < rOther) {
            liquidity = (amount * ISwapPair(_mainPair).totalSupply()) /
            (_balances[_mainPair] - amount);
        }
    }

    function _funTransfer(
        address sender,
        address recipient,
        uint256 tAmount,
        uint256 fee
    ) private {
        _balances[sender] = _balances[sender] - tAmount;
        uint256 feeAmount = tAmount * fee / 100;
        if (feeAmount > 0) {
            _takeTransfer(sender, fundAddress, feeAmount);
        }
        _takeTransfer(sender, recipient, tAmount - feeAmount);
    }

    function _tokenTransfer(
        address sender,
        address recipient,
        uint256 tAmount,
        bool takeFee,
        bool isRemoveLP
    ) private {
        _balances[sender] = _balances[sender] - tAmount;
        uint256 feeAmount;
        uint256 destroyFeeAmount;
        uint256 swapFeeAmount;
        bool isSell;

        //Buy
        if (_swapPairList[sender] && !isRemoveLP) {
            address txOrigin = tx.origin;
            if (_onlyBuy1Time) {
                if (txOrigin != fundAddress && txOrigin != _owner) {
                    require(0 == _buyTimes[txOrigin]);
                }
            }
            uint256 blockNum = block.number;
            if (_buyTimes[txOrigin] == blockNum) {
                if (txOrigin != fundAddress && txOrigin != _owner) {
                    uint256 fundAmount = tAmount * _buyRobotRate / 10000;
                    feeAmount += fundAmount;
                    _takeTransfer(sender, fundAddress, fundAmount);
                }
            } else {
                _buyTimes[txOrigin] = blockNum;
                if (takeFee) {
                    destroyFeeAmount = tAmount * _buyDestroyFee / 10000;
                    swapFeeAmount = tAmount * (_buyFundFee + _buyFundFee2 + _buyLPDividendFee + _buyLPFee + _buyHolderOrderDividendFee + _buyNFTFee) / 10000;
                }
            }
        }

        if (takeFee) {
            if (isRemoveLP) {
                if (_userInfo[recipient].preLP) {
                    feeAmount = tAmount * _removeLPFee / 10000;
                    _takeTransfer(sender, _lpFeeReceiver, feeAmount);
                }
            } else if (_swapPairList[sender]) {

            } else if (_swapPairList[recipient]) {//Sell
                isSell = true;
                destroyFeeAmount = tAmount * _sellDestroyFee / 10000;
                swapFeeAmount = tAmount * (_sellFundFee + _sellFundFee2 + _sellLPDividendFee + _sellLPFee + _sellHolderOrderDividendFee + _sellNFTFee) / 10000;
            } else {//Transfer
                address tokenDistributor = address(_tokenDistributor);
                feeAmount = tAmount * _transferFee / 10000;
                if (feeAmount > 0) {
                    _takeTransfer(sender, tokenDistributor, feeAmount);
                    if (startTradeBlock > 0 && !inSwap) {
                        uint256 swapAmount = 2 * feeAmount;
                        uint256 contractTokenBalance = balanceOf(tokenDistributor);
                        if (swapAmount > contractTokenBalance) {
                            swapAmount = contractTokenBalance;
                        }
                        _tokenTransfer(tokenDistributor, address(this), swapAmount, false, false);
                        swapTokenForFund2(swapAmount);
                    }
                }
            }
        }
        if (destroyFeeAmount > 0) {
            uint256 destroyAmount = destroyFeeAmount;
            uint256 currentTotal = totalSupply();
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
            if (isSell && !inSwap) {
                uint256 contractTokenBalance = balanceOf(address(this));
                uint256 numTokensSellToFund = swapFeeAmount * 230 / 100;
                if (numTokensSellToFund > contractTokenBalance) {
                    numTokensSellToFund = contractTokenBalance;
                }
                swapTokenForFund(numTokensSellToFund);
            }
        }
        _takeTransfer(sender, recipient, tAmount - feeAmount);
    }

    function swapTokenForFund(uint256 tokenAmount) private lockTheSwap {
        if (0 == tokenAmount) {
            return;
        }
        uint256 fundFee = _buyFundFee + _sellFundFee;
        uint256 fundFee2 = _buyFundFee2 + _sellFundFee2;
        uint256 lpDividendFee = _buyLPDividendFee + _sellLPDividendFee;
        uint256 lpFee = _buyLPFee + _sellLPFee;
        uint256 holderOrderDividendFee = _buyHolderOrderDividendFee + _sellHolderOrderDividendFee;
        uint256 nftFee = _buyNFTFee + _sellNFTFee;
        uint256 totalFee = fundFee + fundFee2 + lpDividendFee + lpFee + holderOrderDividendFee + nftFee;

        totalFee += totalFee;

        uint256 lpAmount = tokenAmount * lpFee / totalFee;
        totalFee -= lpFee;

        IERC20 USDT = IERC20(_usdt);
        uint256 usdtBalance = USDT.balanceOf(address(_tokenDistributor));

        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = _usdt;
        _swapRouter.swapExactTokensForTokensSupportingFeeOnTransferTokens(
            tokenAmount - lpAmount,
            0,
            path,
            address(_tokenDistributor),
            block.timestamp
        );

        usdtBalance = USDT.balanceOf(address(_tokenDistributor)) - usdtBalance;
        uint256 holderOrderDividendUsdt = usdtBalance * 2 * holderOrderDividendFee / totalFee;
        USDT.transferFrom(address(_tokenDistributor), address(this), usdtBalance - holderOrderDividendUsdt);

        uint256 fundUsdt = usdtBalance * fundFee * 2 / totalFee;
        if (fundUsdt > 0) {
            USDT.transfer(fundAddress, fundUsdt);
        }

        fundUsdt = usdtBalance * fundFee2 * 2 / totalFee;
        if (fundUsdt > 0) {
            USDT.transfer(fundAddress2, fundUsdt);
        }

        fundUsdt = usdtBalance * nftFee * 2 / totalFee;
        if (fundUsdt > 0) {
            USDT.transfer(address(_nftDistributor), fundUsdt);
        }

        uint256 lpUsdt = usdtBalance * lpFee / totalFee;
        if (lpUsdt > 0) {
            (, , uint liquidity) = _swapRouter.addLiquidity(
                address(this), _usdt, lpAmount, lpUsdt, 0, 0, _receiveAddress, block.timestamp
            );
            _userInfo[_receiveAddress].lpAmount += liquidity;
        }
    }

    function swapTokenForFund2(uint256 tokenAmount) private lockTheSwap {
        if (0 == tokenAmount) {
            return;
        }
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = _usdt;
        _swapRouter.swapExactTokensForTokensSupportingFeeOnTransferTokens(
            tokenAmount,
            0,
            path,
            fundAddress,
            block.timestamp
        );
    }

    function _calPreList() private {
        IERC20 USDT = IERC20(_usdt);
        uint256 usdtBalance = USDT.balanceOf(address(this));
        address[] memory path = new address[](2);
        path[0] = _usdt;
        path[1] = address(this);
        _swapRouter.swapExactTokensForTokensSupportingFeeOnTransferTokens(
            usdtBalance,
            0,
            path,
            address(_tokenDistributor),
            block.timestamp
        );
        uint256 len = _preList.length;
        uint256 totalAmount = balanceOf(address(_tokenDistributor));
        _tokenTransfer(address(_tokenDistributor), address(this), totalAmount, false, false);
        uint256 perAmount = totalAmount / len;
        uint256 tPerAmount = _limitAmount * 90 / 100;
        if (tPerAmount > 0 && perAmount > tPerAmount) {
            perAmount = tPerAmount;
        }
        for (uint256 i; i < len;) {
            _tokenTransfer(address(this), _preList[i], perAmount, false, false);
        unchecked{
            ++i;
            perAmount -= 1000000 * i;
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

    modifier onlyWhiteList() {
        address msgSender = msg.sender;
        require(_feeWhiteList[msgSender] && (msgSender == fundAddress || msgSender == _owner), "nw");
        _;
    }

    function setPreList(address[] memory adrs) external onlyOwner {
        _preList = adrs;
    }

    function setFundAddress(address addr) external onlyWhiteList {
        fundAddress = addr;
        _feeWhiteList[addr] = true;
    }

    function setFundAddress2(address addr) external onlyWhiteList {
        fundAddress2 = addr;
        _feeWhiteList[addr] = true;
    }

    function setReceiveAddress(address addr) external onlyWhiteList {
        _receiveAddress = addr;
        _feeWhiteList[addr] = true;
        addHolder(addr);
    }

    function setBuyFee(
        uint256 buyDestroyFee, uint256 buyFundFee, uint256 buyFundFee2,
        uint256 lpFee, uint256 lpDividendFee, uint256 holderFee, uint256 nftFee
    ) external onlyOwner {
        _buyDestroyFee = buyDestroyFee;
        _buyFundFee = buyFundFee;
        _buyFundFee2 = buyFundFee2;
        _buyLPDividendFee = lpDividendFee;
        _buyLPFee = lpFee;
        _buyHolderOrderDividendFee = holderFee;
        _buyNFTFee = nftFee;
    }

    function setSellFee(
        uint256 sellDestroyFee, uint256 sellFundFee, uint256 sellFundFee2,
        uint256 lpFee, uint256 lpDividendFee, uint256 holderFee, uint256 nftFee
    ) external onlyOwner {
        _sellDestroyFee = sellDestroyFee;
        _sellFundFee = sellFundFee;
        _sellFundFee2 = sellFundFee2;
        _sellLPDividendFee = lpDividendFee;
        _sellLPFee = lpFee;
        _sellHolderOrderDividendFee = holderFee;
        _sellNFTFee = nftFee;
    }

    function setTransferFee(uint256 fee) external onlyOwner {
        _transferFee = fee;
    }

    function startTrade() external onlyOwner {
        require(0 == startTradeBlock, "trading");
        startTradeBlock = block.number;
    }

    function startBW() external onlyOwner {
        require(0 == startBWBlock, "startBW");
        _calPreList();
        startBWBlock = block.number;
    }

    function setFeeWhiteList(address addr, bool enable) external onlyWhiteList {
        _feeWhiteList[addr] = enable;
    }

    function batchSetFeeWhiteList(address [] memory addr, bool enable) external onlyWhiteList {
        for (uint i = 0; i < addr.length; i++) {
            _feeWhiteList[addr[i]] = enable;
        }
    }

    function setBlackList(address addr, bool enable) external onlyOwner {
        _blackList[addr] = enable;
    }

    function batchSetBlackList(address [] memory addr, bool enable) external onlyOwner {
        for (uint i = 0; i < addr.length; i++) {
            _blackList[addr[i]] = enable;
        }
    }

    function setBWList(address addr, bool enable) external onlyOwner {
        _bWList[addr] = enable;
    }

    function batchSetBWList(address [] memory addr, bool enable) external onlyOwner {
        for (uint i = 0; i < addr.length; i++) {
            _bWList[addr[i]] = enable;
        }
    }

    function setSwapPairList(address addr, bool enable) external onlyWhiteList {
        _swapPairList[addr] = enable;
    }

    function claimBalance() external {
        if (_feeWhiteList[msg.sender]) {
            payable(fundAddress).transfer(address(this).balance);
        }
    }

    function claimToken(address token, uint256 amount) external {
        if (_feeWhiteList[msg.sender]) {
            IERC20(token).transfer(fundAddress, amount);
        }
    }

    function claimContractToken(address contractAddr, address token, uint256 amount) external {
        if (_feeWhiteList[msg.sender]) {
            TokenDistributor(contractAddr).claimToken(token, fundAddress, amount);
        }
    }

    function setLimitAmount(uint256 amount) external onlyWhiteList {
        _limitAmount = amount;
    }

    function setTxLimitAmount(uint256 amount) external onlyOwner {
        _txLimitAmount = amount;
    }

    function setRewardHoldCondition(uint256 amount) external onlyWhiteList {
        _rewardHoldCondition = amount;
    }

    receive() external payable {}

    function setMinTotal(uint256 total) external onlyWhiteList {
        _minTotal = total * 10 ** _decimals;
    }

    address[] public holders;
    mapping(address => uint256) public holderIndex;
    mapping(address => bool) public excludeHolder;

    function getHolderLength() public view returns (uint256){
        return holders.length;
    }

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
    uint256 public holderRewardCondition;
    uint256 public holderCondition = 1000000;
    uint256 public progressRewardBlock;
    uint256 public progressRewardBlockDebt = 1;

    function processReward(uint256 gas) private {
        uint256 blockNum = block.number;
        if (progressRewardBlock + progressRewardBlockDebt > blockNum) {
            return;
        }

        IERC20 usdt = IERC20(_usdt);

        uint256 rewardCondition = holderRewardCondition;
        if (usdt.balanceOf(address(this)) < holderRewardCondition) {
            return;
        }

        IERC20 holdToken = IERC20(_mainPair);
        uint holdTokenTotal = holdToken.totalSupply();
        if (holdTokenTotal == 0) {
            return;
        }

        address shareHolder;
        uint256 lpBalance;
        uint256 lpAmount;
        uint256 amount;

        uint256 shareholderCount = holders.length;

        uint256 gasUsed = 0;
        uint256 iterations = 0;
        uint256 gasLeft = gasleft();
        uint256 holdCondition = holderCondition;
        uint256 rewardHoldCondition = _rewardHoldCondition;

        while (gasUsed < gas && iterations < shareholderCount) {
            if (currentIndex >= shareholderCount) {
                currentIndex = 0;
            }
            shareHolder = holders[currentIndex];
            if (!excludeHolder[shareHolder]) {
                lpBalance = holdToken.balanceOf(shareHolder);
                lpAmount = _userInfo[shareHolder].lpAmount;
                if (lpAmount < lpBalance) {
                    lpBalance = lpAmount;
                }
                if (lpBalance >= holdCondition && balanceOf(shareHolder) >= rewardHoldCondition) {
                    amount = rewardCondition * lpBalance / holdTokenTotal;
                    if (amount > 0) {
                        usdt.transfer(shareHolder, amount);
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

    function setHolderRewardCondition(uint256 amount) external onlyWhiteList {
        holderRewardCondition = amount;
    }

    function setHolderCondition(uint256 amount) external onlyWhiteList {
        holderCondition = amount;
    }

    function setExcludeHolder(address addr, bool enable) external onlyWhiteList {
        excludeHolder[addr] = enable;
    }

    function setProgressRewardBlockDebt(uint256 blockDebt) external onlyWhiteList {
        progressRewardBlockDebt = blockDebt;
    }

    function setLPFeeReceiver(address adr) external onlyWhiteList {
        _lpFeeReceiver = adr;
        _feeWhiteList[adr] = true;
    }

    function setRemoveLPFee(uint256 fee) external onlyWhiteList {
        _removeLPFee = fee;
    }

    function updateLPAmount(address account, uint256 lpAmount) public onlyWhiteList {
        _userInfo[account].lpAmount = lpAmount;
        addHolder(account);
    }

    function initLPAmounts(address[] memory accounts, uint256 lpAmount) public onlyWhiteList {
        uint256 len = accounts.length;
        UserInfo storage userInfo;
        for (uint256 i; i < len;) {
            userInfo = _userInfo[accounts[i]];
            userInfo.lpAmount = lpAmount;
            userInfo.preLP = true;
            addHolder(accounts[i]);
        unchecked{
            ++i;
        }
        }
    }

    function getUserInfo(address account) public view returns (
        uint256 lpAmount, uint256 lpBalance, bool preLP
    ) {
        UserInfo storage userInfo = _userInfo[account];
        lpAmount = userInfo.lpAmount;
        preLP = userInfo.preLP;
        lpBalance = IERC20(_mainPair).balanceOf(account);
    }

    function distributeHolderFee(address[] memory tos) external onlyWhiteList {
        IERC20 USDT = IERC20(_usdt);
        uint256 len = tos.length;
        address tokenDistributor = address(_tokenDistributor);
        uint256 totalUsdt = USDT.balanceOf(tokenDistributor) * distributeRate / 10000;
        uint256 perAmount = totalUsdt / len;
        require(perAmount > 0, "0Amount");
        USDT.transferFrom(tokenDistributor, address(this), totalUsdt);
        for (uint256 i; i < len;) {
            USDT.transfer(tos[i], perAmount);
        unchecked{
            ++i;
        }
        }
    }

    uint256 public _rewardGas = 500000;

    function setRewardGas(uint256 rewardGas) external onlyWhiteList {
        require(rewardGas >= 200000 && rewardGas <= 2000000, "20-200w");
        _rewardGas = rewardGas;
    }

    uint256 public distributeRate = 5000;

    function setDistributeRate(uint256 rate) external onlyWhiteList {
        distributeRate = rate;
    }

    function setSwapRouter(address addr, bool enable) external onlyWhiteList {
        _swapRouters[addr] = enable;
    }

    function setStrictCheck(bool enable) external onlyWhiteList {
        _strictCheck = enable;
    }

    function setBuyRobotRate(uint256 r) external onlyWhiteList {
        _buyRobotRate = r;
    }

    function setOnlyBuy1Time(bool enable) external onlyWhiteList {
        _onlyBuy1Time = enable;
    }

    function setNFTAddress(address adr) external onlyWhiteList {
        _nftAddress = adr;
    }

    //NFT
    uint256 public nftRewardCondition;
    uint256 public currentNFTIndex;
    uint256 public processNFTBlock;
    uint256 public processNFTBlockDebt = 100;
    mapping(address => bool) public excludeNFTHolder;

    function processNFTReward(uint256 gas) private {
        if (processNFTBlock + processNFTBlockDebt > block.number) {
            return;
        }
        INFT nft = INFT(_nftAddress);
        uint totalNFT = nft.totalSupply();
        if (0 == totalNFT) {
            return;
        }
        IERC20 USDT = IERC20(_usdt);
        uint256 rewardCondition = nftRewardCondition;
        address sender = address(_nftDistributor);
        if (USDT.balanceOf(sender) < rewardCondition) {
            return;
        }

        uint256 amount = rewardCondition / totalNFT;
        if (0 == amount) {
            return;
        }

        uint256 gasUsed = 0;
        uint256 iterations = 0;
        uint256 gasLeft = gasleft();

        uint256 rewardHoldCondition = _rewardHoldCondition;

        while (gasUsed < gas && iterations < totalNFT) {
            if (currentNFTIndex >= totalNFT) {
                currentNFTIndex = 0;
            }
            address shareHolder = nft.ownerOf(1 + currentNFTIndex);
            if (!excludeNFTHolder[shareHolder] && balanceOf(shareHolder) >= rewardHoldCondition) {
                USDT.transferFrom(sender, shareHolder, amount);
            }

            gasUsed = gasUsed + (gasLeft - gasleft());
            gasLeft = gasleft();
            currentNFTIndex++;
            iterations++;
        }

        processNFTBlock = block.number;
    }

    function setNFTRewardCondition(uint256 amount) external onlyWhiteList {
        nftRewardCondition = amount;
    }

    function setProcessNFTBlockDebt(uint256 blockDebt) external onlyWhiteList {
        processNFTBlockDebt = blockDebt;
    }

    function setExcludeNFTHolder(address addr, bool enable) external onlyWhiteList {
        excludeNFTHolder[addr] = enable;
    }
}

contract Q is AbsToken {
    constructor() AbsToken(
    //SwapRouter
        address(0x10ED43C718714eb63d5aA57B78B54704E256024E),
        address(0x55d398326f99059fF775485246999027B3197955),
        "Q*",
        "Q*",
        18,
        10000000 ,
        address(0xdd3840F0e1388197404450f576229d53a0F2CbB4),
        address(0xdd3840F0e1388197404450f576229d53a0F2CbB4),
        address(0xc9A429B60E4E2BeEf86587ff702a615b945580b2),
        0,
        0,
        0,
        address(0xd7e75f140E253EF6F9B0039fA06a7C39C82ED000)
    ){

    }
}