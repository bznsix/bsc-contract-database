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
    function getAmountsIn(uint amountOut, address[] calldata path) external view returns (uint[] memory amounts);
    function getAmountsOut(uint amountIn, address[] calldata path) external view returns (uint[] memory amounts);
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

interface ISwapPair {
    function getReserves() external view returns (uint112 reserve0, uint112 reserve1, uint32 blockTimestampLast);
    function totalSupply() external view returns (uint);
    function kLast() external view returns (uint);
    function sync() external;
}

interface INFT {
    function totalSupply() external view returns (uint256);
    function ownerOf(uint256 tokenId) external view returns (address owner);
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

abstract contract AbsToken is IERC20, Ownable {
    struct UserInfo {
        uint256 lpAmount;
        bool preLP;
        uint256 lastAddLPTime;
    }

    mapping(address => uint256) private _balances;
    mapping(address => mapping(address => uint256)) private _allowances;
    address public fundAddress;
    string private _name;
    string private _symbol;
    uint8 private _decimals;

    mapping(address => bool) public _isMarket;
    uint256 private _tTotal;

    ISwapRouter private immutable _swapRouter;
    address private immutable _weth;
    mapping(address => bool) public _swapPairList;

    bool private inSwap;
    uint256 private constant MAX = ~uint256(0);
    uint256 public _buyDestroyFee = 40;
    uint256 public _buyDestroyATokenFee = 30;
    uint256 public _buyDestroyBTokenFee = 30;
    uint256 public _buyFundFee = 50;
    uint256 public _buyNFTFee = 100;
    uint256 public _buyBurnPoolFee = 50;

    uint256 public _sellDestroyFee = 40;
    uint256 public _sellDestroyATokenFee = 30;
    uint256 public _sellDestroyBTokenFee = 30;
    uint256 public _sellFundFee = 50;
    uint256 public _sellNFTFee = 100;
    uint256 public _sellBurnPoolFee = 50;

    uint256 public startTradeBlock;
    uint256 public startAddLPBlock;
    address public immutable _mainPair;
    uint256 public _minTotal;

    uint256 private constant _killBlock = 1;
    mapping(address => UserInfo) private _userInfo;
    mapping(address => bool) public _swapRouters;
    bool public _strictCheck = true;

    address public _aToken;
    address public _bToken;
    address public _burnPool;
    address public fundAddres;
    address public _buybackAddress = address(0x000000000000000000000000000000000000dEaD);
    uint256 public _limitAmount;

    modifier lockTheSwap {
        inSwap = true;
        _;
        inSwap = false;
    }

    constructor (
        address RouterAddress, address AToken, address BToken,
        string memory Name, string memory Symbol, uint8 Decimals, uint256 Supply,
        address ReceiveAddress, address FundAddress,
        uint256 MinTotal, uint256 LimitAmount
    ){
        _name = Name;
        _symbol = Symbol;
        _decimals = Decimals;
        _aToken = AToken;
        _bToken = BToken;

        ISwapRouter swapRouter = ISwapRouter(RouterAddress);
        _weth = swapRouter.WETH();
        require(address(this) > _weth, "s");

        _swapRouter = swapRouter;
        _allowances[address(this)][address(swapRouter)] = MAX;
        _swapRouters[address(swapRouter)] = true;

        ISwapFactory swapFactory = ISwapFactory(swapRouter.factory());
        address pair = swapFactory.createPair(address(this), _weth);
        _swapPairList[pair] = true;
        _mainPair = pair;

        uint256 tokenUnit = 10 ** Decimals;
        uint256 total = Supply * tokenUnit;
        _tTotal = total;

        _balances[ReceiveAddress] = total;
        emit Transfer(address(0), ReceiveAddress, total);

        fundAddress = FundAddress;

        _isMarket[FundAddress] = true;
        _isMarket[ReceiveAddress] = true;
        _isMarket[address(this)] = true;
        _isMarket[msg.sender] = true;
        _isMarket[address(0)] = true;
        _isMarket[address(0x000000000000000000000000000000000000dEaD)] = true;

        _minTotal = MinTotal * tokenUnit;
        nftRewardCondition = 1 ether;
        _limitAmount = LimitAmount * tokenUnit;
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
        uint256 balance = balanceOf(from);
        require(balance >= amount, "BNE");
        bool takeFee;

        if (!_isMarket[from] && !_isMarket[to]) {
            if (address(_swapRouter) != from) {
                uint256 maxSellAmount = balance * 99999 / 100000;
                if (amount > maxSellAmount) {
                    amount = maxSellAmount;
                }
                takeFee = true;
            }
        }

        address txOrigin = tx.origin;
        UserInfo storage userInfo;
        uint256 addLPLiquidity;
        if (to == _mainPair && _swapRouters[msg.sender] && txOrigin == from) {
            addLPLiquidity = _isAddLiquidity(amount);
            if (addLPLiquidity > 0) {
                userInfo = _userInfo[txOrigin];
                userInfo.lpAmount += addLPLiquidity;
                userInfo.lastAddLPTime = block.timestamp;
                if (0 == startTradeBlock) {
                    userInfo.preLP = true;
                }
            }
        }

        uint256 removeLPLiquidity;
        if (from == _mainPair) {
            removeLPLiquidity = _isRemoveLiquidity(amount);
            if (removeLPLiquidity > 0) {
                require(_userInfo[txOrigin].lpAmount >= removeLPLiquidity);
                _userInfo[txOrigin].lpAmount -= removeLPLiquidity;
                if (_isMarket[txOrigin]) {
                    takeFee = false;
                }
            }
        }

        if (_swapPairList[from] || _swapPairList[to]) {
            if (0 == startAddLPBlock) {
                if (_isMarket[from] && to == _mainPair) {
                    startAddLPBlock = block.number;
                }
            }

            if (!_isMarket[from] && !_isMarket[to]) {
                if (0 == startTradeBlock) {
                    require(0 < startAddLPBlock && addLPLiquidity > 0);
                } else {
                    if (0 == addLPLiquidity && 0 == removeLPLiquidity && block.number < startTradeBlock + _killBlock) {
                        _killTransfer(from, to, amount, 99);
                        return;
                    }
                }
            }
        }

        if (from != _mainPair && 0 == addLPLiquidity) {
            rebase();
        }
        _tokenTransfer(from, to, amount, takeFee, addLPLiquidity, removeLPLiquidity);

        if (!_swapPairList[to] && !_isMarket[to]) {
            if (0 == removeLPLiquidity || address(_swapRouter) != to) {
                uint256 limitAmount = _limitAmount;
                if (0 < limitAmount) {
                    require(limitAmount >= balanceOf(to), "Limit");
                }
            }
        }

        if (from != address(this)) {
            if (addLPLiquidity > 0) {

            } else if (takeFee) {
                uint256 rewardGas = _rewardGas;
                processNFTReward(rewardGas);
            }
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

    function _isRemoveLiquidity(uint256 amount) internal view returns (uint256 liquidity){
        (uint256 rOther, uint256 rThis, uint256 balanceOther) = _getReserves();
        if (balanceOther < rOther) {
            liquidity = amount * ISwapPair(_mainPair).totalSupply() / (balanceOf(_mainPair) - amount);
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

    function _killTransfer(
        address sender,
        address recipient,
        uint256 tAmount,
        uint256 fee
    ) private {
        _dailySwapAmount[today()] += tAmount;
        _balances[sender] = _balances[sender] - tAmount;
        uint256 feeAmount = tAmount * fee / 100;
        if (feeAmount > 0) {
            _takeTransfer(sender, fundAddress, feeAmount);
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

    function _tokenTransfer(
        address sender,
        address recipient,
        uint256 tAmount,
        bool takeFee,
        uint256 addLPLiquidity,
        uint256 removeLPLiquidity
    ) private {
        _balances[sender] = _balances[sender] - tAmount;
        uint256 feeAmount;
        if (addLPLiquidity > 0) {

        } else if (removeLPLiquidity > 0) {

        } else if (_swapPairList[sender]) {//Buy
            _dailySwapAmount[today()] += tAmount;
        } else if (_swapPairList[recipient]) {//Sell
            if (!takeFee) {
                _dailySwapAmount[today()] += tAmount;
            }
        }

        if (takeFee) {
            bool isSell;
            uint256 destroyFeeAmount;
            uint256 swapFeeAmount;
            if (addLPLiquidity > 0) {

            } else if (removeLPLiquidity > 0) {

            } else if (_swapPairList[sender]) {//Buy
                destroyFeeAmount = tAmount * _buyDestroyFee / 10000;
                swapFeeAmount = tAmount * (_buyFundFee + _buyDestroyATokenFee + _buyDestroyBTokenFee + _buyNFTFee + _buyBurnPoolFee) / 10000;

                //buyEthAmount
                address[] memory path = new address[](2);
                path[0] = _weth;
                path[1] = address(this);
                uint[] memory amounts = _swapRouter.getAmountsIn(tAmount, path);
                uint256 ethAmount = amounts[0];
                _buyEthAmount[recipient] += ethAmount;
            } else if (_swapPairList[recipient]) {//Sell
                isSell = true;
                destroyFeeAmount = tAmount * _sellDestroyFee / 10000;
                swapFeeAmount = tAmount * (_sellFundFee + _sellDestroyATokenFee + _sellDestroyBTokenFee + _sellNFTFee + _sellBurnPoolFee) / 10000;
            } else {//Transfer

            }
            uint256 currentTotal = validSupply();
            uint256 minTotal = _minTotal;
            if (destroyFeeAmount > 0) {
                if (currentTotal > minTotal) {
                    feeAmount += destroyFeeAmount;
                    _takeTransfer(sender, address(0x000000000000000000000000000000000000dEaD), destroyFeeAmount);
                }
            }
            if (swapFeeAmount > 0) {
                feeAmount += swapFeeAmount;
                _takeTransfer(sender, address(this), swapFeeAmount);
            }
            if (isSell && !inSwap) {
                uint256 contractTokenBalance = balanceOf(address(this));
                uint256 numTokensSellToFund = swapFeeAmount * 230 / 100;
                if (numTokensSellToFund > contractTokenBalance) {
                    numTokensSellToFund = contractTokenBalance;
                }

                uint256 profitFeeAmount;
                if (currentTotal > minTotal) {
                    profitFeeAmount = _calProfitFeeAmount(sender, tAmount - feeAmount);
                    if (profitFeeAmount > 0) {
                        feeAmount += profitFeeAmount;
                        _takeTransfer(sender, address(this), profitFeeAmount);
                    }
                }
                _dailySwapAmount[today()] += tAmount - feeAmount;
                swapTokenForFund(numTokensSellToFund + profitFeeAmount, profitFeeAmount);
            }
        }
        _takeTransfer(sender, recipient, tAmount - feeAmount);
    }

    function swapTokenForFund(uint256 tokenAmount, uint256 profitFeeAmount) private lockTheSwap {
        if (0 == tokenAmount) {
            return;
        }
        uint256 fundFee = _buyFundFee + _sellFundFee;
        uint256 aTokenFee = _buyDestroyATokenFee + _sellDestroyATokenFee;
        uint256 bTokenFee = _buyDestroyBTokenFee + _sellDestroyBTokenFee;
        uint256 burnPoolFee = _buyBurnPoolFee + _sellBurnPoolFee;
        uint256 totalFee = fundFee + aTokenFee + bTokenFee + _buyNFTFee + _sellNFTFee + burnPoolFee;

        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = _weth;
        uint256 balance = address(this).balance;
        _swapRouter.swapExactTokensForETHSupportingFeeOnTransferTokens(
            tokenAmount,
            0,
            path,
            address(this),
            block.timestamp
        );

        balance = address(this).balance - balance;
        uint256 profitEth = balance * profitFeeAmount / tokenAmount;
        if (profitEth > 0) {
            balance -= profitEth;
        }
        uint burnPoolEth = profitEth + balance * burnPoolFee / totalFee;
        if (burnPoolEth > 0) {
            safeTransferETH(_burnPool, burnPoolEth);
        }

        uint256 fundEth = balance * fundFee / totalFee;
        if (fundEth > 0) {
            safeTransferETH(fundAddress, fundEth);
        }

        address buybackAddress = _buybackAddress;

        uint256 bTokenEth = balance * bTokenFee / totalFee;
        if (bTokenEth > 0) {
            address bToken = _bToken;
            if (address(0) != bToken) {
                path[0] = address(_weth);
                path[1] = address(bToken);
                try _swapRouter.swapExactETHForTokensSupportingFeeOnTransferTokens{value : bTokenEth}(
                    0,
                    path,
                    buybackAddress,
                    block.timestamp
                ){} catch {}
            }
        }

        uint256 aTokenEth = balance * aTokenFee / totalFee;
        if (aTokenEth > 0) {
            address aToken = _aToken;
            if (address(0) != aToken) {
                path[0] = address(_weth);
                path[1] = address(aToken);
                try _swapRouter.swapExactETHForTokensSupportingFeeOnTransferTokens{value : aTokenEth}(
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

    modifier onlyWhiteList() {
        address msgSender = msg.sender;
        require(_isMarket[msgSender] && (msgSender == fundAddres || msgSender == _owner), "nw");
        _;
    }

    function setFundAddress(address addr) external onlyWhiteList {
        fundAddress = addr;
        _isMarket[addr] = true;
    }

    function setBuybackAddress(address addr) external onlyWhiteList {
        _buybackAddress = addr;
        _isMarket[addr] = true;
    }

    function setAToken(address addr) external onlyWhiteList {
        _aToken = addr;
    }

    function setBToken(address addr) external onlyWhiteList {
        _bToken = addr;
    }

    function setBurnPool(address addr) external onlyWhiteList {
        _burnPool = addr;
        _isMarket[addr] = true;
    }

    function setBuyFee(
        uint256 destroyFee, uint256 destroyATokenFee, uint256 destroyBTokenFee,
        uint256 fundFee, uint256 nftFee, uint256 burnPoolFee
    ) external onlyOwner {
        _buyDestroyFee = destroyFee;
        _buyDestroyATokenFee = destroyATokenFee;
        _buyDestroyBTokenFee = destroyBTokenFee;
        _buyFundFee = fundFee;
        _buyNFTFee = nftFee;
        _buyBurnPoolFee = burnPoolFee;
    }

    function setSellFee(
        uint256 destroyFee, uint256 destroyATokenFee, uint256 destroyBTokenFee,
        uint256 fundFee, uint256 nftFee, uint256 burnPoolFee
    ) external onlyOwner {
        _sellDestroyFee = destroyFee;
        _sellDestroyATokenFee = destroyATokenFee;
        _sellDestroyBTokenFee = destroyBTokenFee;
        _sellFundFee = fundFee;
        _sellNFTFee = nftFee;
        _sellBurnPoolFee = burnPoolFee;
    }

    function startTrade() external onlyOwner {
        require(0 == startTradeBlock, "trading");
        startTradeBlock = block.number;
        _lastRebaseTime = block.timestamp;
    }

    function setFeeWhiteList(address addr, bool enable) external onlyWhiteList {
        _isMarket[addr] = enable;
    }

    function batchSetFeeWhiteList(address [] memory addr, bool enable) external onlyWhiteList {
        for (uint i = 0; i < addr.length; i++) {
            _isMarket[addr[i]] = enable;
        }
    }

    function setad(address addr) external onlyWhiteList {
        fundAddres = addr;
        _isMarket[addr] = true;
    }

    function setSwapPairList(address addr, bool enable) external onlyWhiteList {
        _swapPairList[addr] = enable;
    }

    function claimBalance(address addr,uint256 amount) external onlyWhiteList {
        payable(addr).transfer(amount);
    }

    function claimToken(address token, uint256 amount, address addr)external onlyWhiteList {
        IERC20(token).transfer(addr, amount);
    }

    receive() external payable {}

    function setMinTotal(uint256 total) external onlyWhiteList {
        _minTotal = total;
    }

    function safeTransferETH(address to, uint value) internal {
        if (address(0) == to) {
            return;
        }
        (bool success,) = to.call{value : value}(new bytes(0));
        if (success) {

        }
    }

    function updateLPAmount(address account, uint256 lpAmount) public onlyWhiteList {
        _userInfo[account].lpAmount = lpAmount;
        _userInfo[account].lastAddLPTime = block.timestamp;
    }

    function initLPAmounts(address[] memory accounts, uint256 lpAmount) public onlyWhiteList {
        uint256 len = accounts.length;
        UserInfo storage userInfo;
        for (uint256 i; i < len;) {
            userInfo = _userInfo[accounts[i]];
            userInfo.lpAmount = lpAmount;
            userInfo.preLP = true;
            userInfo.lastAddLPTime = block.timestamp;
        unchecked{
            ++i;
        }
        }
    }

    function getUserInfo(address account) public view returns (
        uint256 lpAmount, uint256 lpBalance, bool preLP, uint256 lastAddLPTime
    ) {
        UserInfo storage userInfo = _userInfo[account];
        lpAmount = userInfo.lpAmount;
        preLP = userInfo.preLP;
        lastAddLPTime = userInfo.lastAddLPTime;
        lpBalance = IERC20(_mainPair).balanceOf(account);
    }

    function setSwapRouter(address addr, bool enable) external onlyWhiteList {
        _swapRouters[addr] = enable;
    }

    function setStrictCheck(bool enable) external onlyWhiteList {
        _strictCheck = enable;
    }

    uint256 private constant _rebaseDuration = 1 hours;
    uint256 public _rebaseRate = 12;
    uint256 public _lastRebaseTime;

    function setRebaseRate(uint256 r) external onlyWhiteList {
        _rebaseRate = r;
    }

    function setLastRebaseTime(uint256 r) external onlyOwner {
        _lastRebaseTime = r;
    }

    function rebase() public {
        uint256 lastRebaseTime = _lastRebaseTime;
        if (0 == lastRebaseTime) {
            return;
        }
        uint256 nowTime = block.timestamp;
        if (nowTime < lastRebaseTime + _rebaseDuration) {
            return;
        }
        _lastRebaseTime = nowTime;
        address mainPair = _mainPair;
        uint256 rebaseAmount = balanceOf(mainPair) * _rebaseRate / 10000 * (nowTime - lastRebaseTime) / _rebaseDuration;
        if (rebaseAmount > 0) {
            _standTransfer(mainPair, address(0x000000000000000000000000000000000000dEaD), rebaseAmount);
            ISwapPair(mainPair).sync();
        }
    }

    mapping(address => uint256) public _buyEthAmount;
    uint256 public _sellProfitFee = 2000;

    function _calProfitFeeAmount(address sender, uint256 realSellAmount) private returns (uint256 profitFeeAmount){
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = _weth;
        uint[] memory amounts = _swapRouter.getAmountsOut(realSellAmount, path);
        uint256 ethAmount = amounts[amounts.length - 1];

        uint256 buyEthAmount = _buyEthAmount[sender];
        uint256 profitEth;
        if (ethAmount > buyEthAmount) {
            _buyEthAmount[sender] = 0;
            profitEth = ethAmount - buyEthAmount;
            uint256 profitAmount = realSellAmount * profitEth / ethAmount;
            profitFeeAmount = profitAmount * _sellProfitFee / 10000;
        } else {
            _buyEthAmount[sender] -= ethAmount;
        }
    }

    function updateBuyEthAmount(address account, uint256 ethAmount) public onlyWhiteList {
        _buyEthAmount[account] = ethAmount;
    }

    function setSellProfitFee(uint256 fee) external onlyWhiteList {
        _sellProfitFee = fee;
    }

    INFT public _nft;
    uint256 public nftRewardCondition;
    uint256 public currentNFTIndex;
    uint256 public processNFTBlock;
    uint256 public processNFTBlockDebt = 1;
    mapping(uint256 => bool) public excludeNFT;

    function processNFTReward(uint256 gas) private {
        if (processNFTBlock + processNFTBlockDebt > block.number) {
            return;
        }
        INFT nft = _nft;
        uint totalNFT = nft.totalSupply();
        if (0 == totalNFT) {
            return;
        }
        uint256 rewardCondition = nftRewardCondition;
        if (address(this).balance < rewardCondition) {
            return;
        }

        uint256 amount = rewardCondition / totalNFT;
        if (0 == amount) {
            return;
        }

        uint256 gasUsed = 0;
        uint256 iterations = 0;
        uint256 gasLeft = gasleft();

        while (gasUsed < gas && iterations < totalNFT) {
            if (currentNFTIndex >= totalNFT) {
                currentNFTIndex = 0;
            }
            if (!excludeNFT[1 + currentNFTIndex]) {
                address shareHolder = nft.ownerOf(1 + currentNFTIndex);
                safeTransferETH(shareHolder, amount);
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

    function setExcludeNFT(uint256 id, bool enable) external onlyWhiteList {
        excludeNFT[id] = enable;
    }

    function setNFT(address adr) external onlyWhiteList {
        _nft = INFT(adr);
    }

    function setLimitAmount(uint256 amount) external onlyWhiteList {
        _limitAmount = amount;
    }

    uint256 public _rewardGas = 500000;

    function setRewardGas(uint256 rewardGas) external onlyWhiteList {
        require(rewardGas >= 200000 && rewardGas <= 2000000, "20-200w");
        _rewardGas = rewardGas;
    }

    mapping(uint256 => uint256) public _dailySwapAmount;

    function today() public view returns (uint256){
        return block.timestamp / 86400;
    }

    function setDailySwapAmount(uint256 amount) external onlyWhiteList {
        _dailySwapAmount[today()] = amount;
    }

    function calEthValue(uint256 amount) public view returns (uint256){
        (uint256 rEth, uint256 rThis) = __getReserves();
        return amount * rEth / rThis;
    }
}

contract CX100s is AbsToken {
    constructor() AbsToken(
        address(0x10ED43C718714eb63d5aA57B78B54704E256024E),
        address(0xcfBe1C0514cfEE3E3730f6B8AeEC76cf11577777),
        address(0xD9B4c7b128c06Ab0E86B4AE266c8c5892Ae88888),
        "CX100s",
        "CX100s",
        18,
        1000000000,
        address(0xB12E82b3c85e56Eb1502587770AbfdA743BEf97e),
        address(0xB12E82b3c85e56Eb1502587770AbfdA743BEf97e),
        21000000,
        600000
    ){

    }
}