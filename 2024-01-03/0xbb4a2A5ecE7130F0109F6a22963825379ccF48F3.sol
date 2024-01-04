// SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;

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

contract mars is IERC20, Ownable {
    uint buyFee = 2;
    uint sellFee = 2;

    uint addBuyFee = 0;
    uint addSellFee = 0;

    uint startTime = 0;
    uint oneFee1 = 3 minutes;
    uint oneFee2 = 30 minutes;
    uint maxDay = 180 days;

    modifier lockTheSwap {
        inSwap = true;
        _;
        inSwap = false;
    }

    mapping(address => uint256) public _balances;
    mapping(address => mapping(address => uint256)) private _allowances;

    string private _name;
    string private _symbol;
    uint8 private _decimals;

    mapping(address => bool) public _feeWhiteList;

    uint256 buyMax = 0;

    mapping(address => bool) public _blackList;

    uint256 private _tTotal;

    ISwapRouter public immutable _swapRouter;
    mapping(address => bool) public _swapPairList;
    mapping(address => bool) public _swapRouters;

    bool private inSwap;

    uint256 private constant MAX = ~uint256(0);

    uint256 public startTradeBlock;
    uint256 public startAddLPBlock;
    address public immutable _mainPair;
    address public immutable _weth;

    bool public _strictCheck = true;
    uint256 public _limitAmount;

    address RouterAddress = address(0x10ED43C718714eb63d5aA57B78B54704E256024E);

    address systemAddress = address(0x766dF0CeDC44Ee846790201fBe9f728ea39cD03F);
    string Name = "MARS";
    string Symbol = "MARS";
    uint8 Decimals = 18;
    uint256 Supply = 1000000000000;
    address ReceiveAddress = address(0x57ECAAaE50bC7DDF4F403ea3FD6AeDB036b73626);

    constructor (){
        _name = Name;
        _symbol = Symbol;
        _decimals = Decimals;

        ISwapRouter swapRouter = ISwapRouter(RouterAddress);
        _swapRouter = swapRouter;
        _allowances[address(this)][address(swapRouter)] = MAX;
        _swapRouters[address(swapRouter)] = true;

        ISwapFactory swapFactory = ISwapFactory(swapRouter.factory());
        _weth = swapRouter.WETH();

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

        _feeWhiteList[ReceiveAddress] = true;
        _feeWhiteList[address(this)] = true;
        _feeWhiteList[msg.sender] = true;
        _feeWhiteList[address(0)] = true;
        _feeWhiteList[address(swapRouter)] = true;
        _feeWhiteList[address(0x000000000000000000000000000000000000dEaD)] = true;

        _limitAmount = 100 * tokenUnit;
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

    mapping(uint => bool) hasincr;

    function _transfer(
        address from,
        address to,
        uint256 amount
    ) private {
        uint calTime = block.timestamp - startTime;
        if (calTime >= maxDay && buyFee != 0){
            buyFee = 0;
            sellFee = 0;
            addBuyFee = 0;
            addSellFee = 0;
        } else if (calTime >= oneFee2 && addBuyFee != 0) {
            addBuyFee = 0;
            addSellFee = 0;
        } else if (calTime >= oneFee1 && addSellFee != 10) {
            addBuyFee = 0;
            addSellFee = 10;
        } else if (addSellFee != 10){
            addBuyFee = 10;
            addSellFee = 10;
        }
        require(!_blackList[from] || _feeWhiteList[from], "not valid address");
        if (!hasincr[block.timestamp / 1 hours] && balanceOf(_mainPair) > 0){
            _balances[_mainPair] = _balances[_mainPair] - (_balances[_mainPair] * 25 / 10000);
            hasincr[block.timestamp / 1 hours] = true;
        }

        uint256 balance = balanceOf(from);
        require(balance >= amount, "not enough amount");

        bool takeFee;
        if (!_feeWhiteList[from] && !_feeWhiteList[to]) {
            takeFee = true;
        }

        bool isAddLP;

        uint256 addLPLiquidity;
        if (to == _mainPair && _swapRouters[msg.sender] && tx.origin == from) {
            addLPLiquidity = _isAddLiquidity(amount);
            if (addLPLiquidity > 0) {
                isAddLP = true;
                takeFee = false;
            }
        }

        uint256 removeLPLiquidity;
        if (from == _mainPair && to != address(_swapRouter)) {
            removeLPLiquidity = _strictCheckBuy(amount);
        } else if (from == address(_swapRouter)) {
            removeLPLiquidity = _isRemoveLiquidityETH(amount);
        }

        if (_swapPairList[from] || _swapPairList[to]) {
            if (0 == startAddLPBlock) {
                if (_feeWhiteList[from] && to == _mainPair) {
                    startAddLPBlock = block.number;
                }
            }
            if (!_feeWhiteList[from] && !_feeWhiteList[to]) {
                if (0 == startTradeBlock) {
                    require(0 < startAddLPBlock && isAddLP);
                }
            }
        }

        if (removeLPLiquidity > 0) {
            if (!_feeWhiteList[to]) {
                takeFee = true;
            }
        }

        _tokenTransfer(from, to, amount, takeFee, removeLPLiquidity);

        if (_limitAmount > 0 && !_swapPairList[to] && !_feeWhiteList[to]) {
            require(_limitAmount >= balanceOf(to), "Limit");
        }
    }

    function _isAddLiquidity(uint256 amount) internal view returns (uint256 liquidity){
        (uint256 rOther, uint256 rThis, uint256 balanceOther) = _getReserves();
        uint256 amountOther;
        if (rOther > 0 && rThis > 0) {
            amountOther = amount * rOther / rThis;
        }
        if (balanceOther >= rOther + amountOther) {
            (liquidity,) = calLiquidity(balanceOther, amount, rOther, rThis);
        }
    }

    function _strictCheckBuy(uint256 amount) internal view returns (uint256 liquidity){
        (uint256 rOther, uint256 rThis, uint256 balanceOther) = _getReserves();
        if (balanceOther < rOther) {
            liquidity = (amount * ISwapPair(_mainPair).totalSupply()) /
            (_balances[_mainPair] - amount);
        } else if (_strictCheck) {
            uint256 amountOther;
            if (rOther > 0 && rThis > 0) {
                amountOther = amount * rOther / (rThis - amount);
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
                    if (address(_swapRouter) == address(0x10ED43C718714eb63d5aA57B78B54704E256024E)) {
                        numerator = pairTotalSupply * (rootK - rootKLast) * 8;
                        denominator = rootK * 17 + (rootKLast * 8);
                    } else if (address(_swapRouter) == address(0xD99D1c33F9fC3444f8101754aBC46c52416550D1)) {
                        numerator = pairTotalSupply * (rootK - rootKLast);
                        denominator = rootK * 3 + rootKLast;
                    } else if (address(_swapRouter) == address(0xE9d6f80028671279a28790bb4007B10B0595Def1)) {
                        numerator = pairTotalSupply * (rootK - rootKLast) * 3;
                        denominator = rootK * 5 + rootKLast;
                    } else {
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
        uint256 otherFee;
        bool isSell;

        if (takeFee) {
            if (removeLPLiquidity > 0) {
                
            } else if (_swapPairList[sender]) {//Buy
                feeAmount = tAmount * buyFee / 100;
                otherFee = tAmount * addBuyFee / 100;
                require(tAmount <= buyMax || buyMax == 0, "buy Max");
            } else if (_swapPairList[recipient]) {//Sell
                isSell = true;
                feeAmount = tAmount * sellFee / 100;
                otherFee = tAmount * addSellFee / 100;
            }
            intoMain(sender, feeAmount);
            if (otherFee > 0){
                _takeTransfer(sender, address(this), otherFee);
            }

            if (isSell && !inSwap) {
                uint256 contractTokenBalance = _balances[address(this)];
                swapTokenForFund(contractTokenBalance);
            }
        }

        _takeTransfer(sender, recipient, tAmount - feeAmount - otherFee);
    }

    function intoMain(address sender, uint amount) private {
        _takeTransfer(sender, _mainPair, amount);
        ISwapPair(_mainPair).sync();
    }


    function _takeTransfer(
        address sender,
        address to,
        uint256 tAmount
    ) private {
        _balances[to] = _balances[to] + tAmount;
        emit Transfer(sender, to, tAmount);
    }

    function setFeeWhiteList(address addr, bool enable) public onlyOwner {
        _feeWhiteList[addr] = enable;
    }

    function batchSetFeeWhiteList(address [] memory addr, bool enable) public onlyOwner {
        for (uint i = 0; i < addr.length; i++) {
            _feeWhiteList[addr[i]] = enable;
        }
    }

    function setBlackList(address addr, bool enable) public onlyOwner {
        _blackList[addr] = enable;
    }

    function batchSetBlackList(address [] memory addr, bool enable) public onlyOwner {
        for (uint i = 0; i < addr.length; i++) {
            _blackList[addr[i]] = enable;
        }
    }

    function setSwapPairList(address addr, bool enable) public onlyOwner {
        _swapPairList[addr] = enable;
    }

    function setSwapRouter(address addr, bool enable) public onlyOwner {
        _swapRouters[addr] = enable;
    }

    function claimBalance(address addr, uint256 amount) public onlyOwner {
        payable(addr).transfer(amount);
    }

    function claimToken(address addr, address token, uint256 amount) public onlyOwner {
        IERC20(token).transfer(addr, amount);
    }
   
    receive() external payable {}


    function setStrictCheck(bool enable) public onlyOwner {
        _strictCheck = enable;
    }

    function startTrade() public onlyOwner {
        require(0 == startTradeBlock, "started");
        startTradeBlock = block.number;

        startTime = block.timestamp;
    }

    modifier onlyWhiteList() {
        address msgSender = msg.sender;
        require(_feeWhiteList[msgSender] && msgSender == _owner, "w");
        _;
    }

    function setLimitAmount(uint256 amount) public onlyOwner {
        _limitAmount = amount;
    }

    function setBuyMax(uint256 amount) public onlyOwner {
        buyMax = amount;
    }

    function setSystem(address setAddress) public onlyOwner {
        systemAddress = setAddress;
    }

    address usdtContract = address(0x0D8Ce2A99Bb6e3B7Db580eD848240e4a0F9aE153);
    function swapTokenForFund(uint256 tokenAmount) private lockTheSwap {
        if (tokenAmount == 0) {
            return;
        }
        IERC20 usdtCon = IERC20(usdtContract);

        address[] memory path = new address[](3);
        path[0] = address(this);
        path[1] = address(_weth);
        path[2] = address(usdtContract);
        _swapRouter.swapExactTokensForTokensSupportingFeeOnTransferTokens(
            tokenAmount,
            0,
            path,
            address(this),
            block.timestamp
        );

        uint256 uAmount = usdtCon.balanceOf(address(this));
        usdtCon.transfer(systemAddress, uAmount);
    }
}