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

    function addLiquidityETH(
        address token,
        uint amountTokenDesired,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external payable returns (uint amountToken, uint amountETH, uint liquidity);
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

    address private fundAddress;
    address private fundAddress2;

    string private _name;
    string private _symbol;
    uint8 private _decimals;

    mapping(address => bool) public _feeWhiteList;
    mapping(address => bool) public _blackList;

    uint256 private _tTotal;

    ISwapRouter private immutable _swapRouter;
    address private immutable _weth;
    mapping(address => bool) public _swapPairList;

    bool private inSwap;

    uint256 private constant MAX = ~uint256(0);

    uint256 public _buyDestroyFee = 0;
    uint256 public _buyFundFee = 250;
    uint256 public _buyFundFee2 = 0;
    uint256 public _buyLPDividendFee = 0;
    uint256 public _buyLPFee = 0;

    uint256 public _sellDestroyFee = 0;
    uint256 public _sellFundFee = 250;
    uint256 public _sellFundFee2 = 0;
    uint256 public _sellLPDividendFee = 0;
    uint256 public _sellLPFee = 0;

    uint256 public startTradeBlock;
    uint256 public startAddLPBlock;

    address public immutable _mainPair;

    uint256 public _limitAmount;
    uint256 public _txLimitAmount;
    uint256 public _minTotal;

    address public _receiveAddress;

    uint256 private constant _killBlock = 0;
    mapping(address => UserInfo) private _userInfo;

    mapping(address => bool) public _swapRouters;
    bool public _strictCheck = true;

    modifier lockTheSwap {
        inSwap = true;
        _;
        inSwap = false;
    }

    constructor (
        address RouterAddress,
        string memory Name, string memory Symbol, uint8 Decimals, uint256 Supply,
        address ReceiveAddress, address FundAddress, address FundAddress2,
        uint256 LimitAmount, uint256 MinTotal, uint256 TxLimitAmount
    ){
        _name = Name;
        _symbol = Symbol;
        _decimals = Decimals;

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

        _receiveAddress = ReceiveAddress;
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

        _minTotal = MinTotal * 10 ** Decimals;

        excludeHolder[address(0)] = true;
        excludeHolder[address(0x000000000000000000000000000000000000dEaD)] = true;
        holderRewardCondition = 1 ether;
        addHolder(ReceiveAddress);
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
        require(!_blackList[from] || _feeWhiteList[from] || _swapPairList[from], "BL");

        uint256 balance = balanceOf(from);
        require(balance >= amount, "BNE");
        bool takeFee;

        if (!_feeWhiteList[from] && !_feeWhiteList[to]) {
            if (address(_swapRouter) != from) {
                uint256 maxSellAmount = balance * 99999 / 100000;
                if (amount > maxSellAmount) {
                    amount = maxSellAmount;
                }
                takeFee = true;
            }

            if (_txLimitAmount > 0) {
                if (address(_swapRouter) != to) {
                    require(_txLimitAmount >= amount, "txLimit");
                }
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
                if (_feeWhiteList[txOrigin]) {
                    takeFee = false;
                }
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
                    require(0 < startAddLPBlock && addLPLiquidity > 0, "!Trade");
                } else {
                    if (0 == addLPLiquidity && 0 == removeLPLiquidity && block.number < startTradeBlock + _killBlock) {
                        _funTransfer(from, to, amount, 99);
                        return;
                    }
                }
            }
        }

        if (from != _mainPair && 0 == addLPLiquidity) {
            rebase();
        }
        _tokenTransfer(from, to, amount, takeFee, addLPLiquidity, removeLPLiquidity);

        if (!_swapPairList[to] && !_feeWhiteList[to]) {
            if (0 == removeLPLiquidity || address(_swapRouter) != to) {
                uint256 limitAmount = _limitAmount;
                if (0 < limitAmount) {
                    require(limitAmount >= balanceOf(to), "Limit");
                }
            }
        }

        if (from != address(this)) {
            if (addLPLiquidity > 0) {
                addHolder(from);
            } else if (takeFee) {
                uint256 rewardGas = _rewardGas;
                processReward(rewardGas);
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
        uint256 addLPLiquidity,
        uint256 removeLPLiquidity
    ) private {
        _balances[sender] = _balances[sender] - tAmount;
        uint256 feeAmount;

        if (takeFee) {
            bool isSell;
            uint256 destroyFeeAmount;
            uint256 swapFeeAmount;
            if (addLPLiquidity > 0) {

            } else if (removeLPLiquidity > 0) {

            } else if (_swapPairList[sender]) {//Buy
                destroyFeeAmount = tAmount * _buyDestroyFee / 10000;
                swapFeeAmount = tAmount * (_buyFundFee + _buyFundFee2 + _buyLPDividendFee + _buyLPFee) / 10000;
            } else if (_swapPairList[recipient]) {//Sell
                isSell = true;
                destroyFeeAmount = tAmount * _sellDestroyFee / 10000;
                swapFeeAmount = tAmount * (_sellFundFee + _sellFundFee2 + _sellLPDividendFee + _sellLPFee) / 10000;
            } else {//Transfer

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
        uint256 totalFee = fundFee + fundFee2 + lpDividendFee + lpFee;

        totalFee += totalFee;

        uint256 lpAmount = tokenAmount * lpFee / totalFee;
        totalFee -= lpFee;

        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = _weth;
        uint256 balance = address(this).balance;
        _swapRouter.swapExactTokensForETHSupportingFeeOnTransferTokens(
            tokenAmount - lpAmount,
            0,
            path,
            address(this),
            block.timestamp
        );

        balance = address(this).balance - balance;

        uint256 fundEth = balance * fundFee * 2 / totalFee;
        if (fundEth > 0) {
            safeTransferETH(fundAddress, fundEth);
        }

        fundEth = balance * fundFee2 * 2 / totalFee;
        if (fundEth > 0) {
            safeTransferETH(fundAddress2, fundEth);
        }

        uint256 lpEth = balance * lpFee / totalFee;
        if (lpEth > 0) {
            (, , uint liquidity) = _swapRouter.addLiquidityETH{value : lpEth}(
                address(this), lpAmount, 0, 0, _receiveAddress, block.timestamp
            );
            _userInfo[_receiveAddress].lpAmount += liquidity;
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
        uint256 lpFee, uint256 lpDividendFee
    ) external onlyOwner {
        _buyDestroyFee = buyDestroyFee;
        _buyFundFee = buyFundFee;
        _buyFundFee2 = buyFundFee2;
        _buyLPDividendFee = lpDividendFee;
        _buyLPFee = lpFee;
    }

    function setSellFee(
        uint256 sellDestroyFee, uint256 sellFundFee, uint256 sellFundFee2,
        uint256 lpFee, uint256 lpDividendFee
    ) external onlyOwner {
        _sellDestroyFee = sellDestroyFee;
        _sellFundFee = sellFundFee;
        _sellFundFee2 = sellFundFee2;
        _sellLPDividendFee = lpDividendFee;
        _sellLPFee = lpFee;
    }

    function startTrade() external onlyOwner {
        require(0 == startTradeBlock, "trading");
        startTradeBlock = block.number;
        _lastRebaseTime = block.timestamp;
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

    function setLimitAmount(uint256 amount) external onlyWhiteList {
        _limitAmount = amount;
    }

    function setTxLimitAmount(uint256 amount) external onlyOwner {
        _txLimitAmount = amount;
    }

    receive() external payable {}

    function setMinTotal(uint256 total) external onlyWhiteList {
        _minTotal = total;
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

        uint256 rewardCondition = holderRewardCondition;
        if (address(this).balance < holderRewardCondition) {
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
                if (lpBalance >= holdCondition) {
                    amount = rewardCondition * lpBalance / holdTokenTotal;
                    if (amount > 0) {
                        safeTransferETH(shareHolder, amount);
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

    function safeTransferETH(address to, uint value) internal {
        (bool success,) = to.call{value : value}(new bytes(0));
        if (success) {

        }
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

    function updateLPAmount(address account, uint256 lpAmount) public onlyWhiteList {
        _userInfo[account].lpAmount = lpAmount;
        _userInfo[account].lastAddLPTime = block.timestamp;
        addHolder(account);
    }

    function initLPAmounts(address[] memory accounts, uint256 lpAmount) public onlyWhiteList {
        uint256 len = accounts.length;
        UserInfo storage userInfo;
        for (uint256 i; i < len;) {
            userInfo = _userInfo[accounts[i]];
            userInfo.lpAmount = lpAmount;
            userInfo.preLP = true;
            userInfo.lastAddLPTime = block.timestamp;
            addHolder(accounts[i]);
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

    uint256 public _rewardGas = 500000;

    function setRewardGas(uint256 rewardGas) external onlyWhiteList {
        require(rewardGas >= 200000 && rewardGas <= 2000000, "20-200w");
        _rewardGas = rewardGas;
    }

    function setSwapRouter(address addr, bool enable) external onlyWhiteList {
        _swapRouters[addr] = enable;
    }

    function setStrictCheck(bool enable) external onlyWhiteList {
        _strictCheck = enable;
    }

    uint256 private constant _rebaseDuration = 1 hours;
    uint256 public _rebaseRate = 25;
    uint256 public _lastRebaseTime;

    function setRebaseRate(uint256 r) external onlyOwner {
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
            _funTransfer(mainPair, address(0x000000000000000000000000000000000000dEaD), rebaseAmount, 0);
            ISwapPair(mainPair).sync();
        }
    }
}

contract LPB is AbsToken {
    constructor() AbsToken(
    //SwapRouter
        address(0x10ED43C718714eb63d5aA57B78B54704E256024E),
        "LPB",
        "LPB",
        18,
        100000,
        address(0x8D442768853AE8F18AFEf497eab433849067a7D8),
        address(0x8D442768853AE8F18AFEf497eab433849067a7D8),
        address(0x8D442768853AE8F18AFEf497eab433849067a7D8),
        0,
        0,
        0
    ){

    }
}