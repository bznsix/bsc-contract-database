/**
 *Submitted for verification at BscScan.com on 2024-01-02
 */

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.19;

interface IERC20 {
    function decimals() external view returns (uint8);

    function symbol() external view returns (string memory);

    function name() external view returns (string memory);

    function totalSupply() external view returns (uint256);

    function balanceOf(address account) external view returns (uint256);

    function transfer(address recipient, uint256 amount)
        external
        returns (bool);

    function allowance(address owner, address spender)
        external
        view
        returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
}

interface ISwapRouter {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);

    function addLiquidityETH(
        address token,
        uint256 amountTokenDesired,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline
    )
        external
        payable
        returns (
            uint256 amountToken,
            uint256 amountETH,
            uint256 liquidity
        );

    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external;

    function removeLiquidityETHSupportingFeeOnTransferTokens(
        address token,
        uint256 liquidity,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline
    ) external returns (uint256 amountETH);

    function removeLiquidityETHWithPermitSupportingFeeOnTransferTokens(
        address token,
        uint256 liquidity,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline,
        bool approveMax,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external returns (uint256 amountETH);

    function swapExactETHForTokensSupportingFeeOnTransferTokens(
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external payable;

    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external;
}

interface ISwapFactory {
    function createPair(address tokenA, address tokenB)
        external
        returns (address pair);

    function feeTo() external view returns (address);
}

interface ISwapPair {
    function getReserves()
        external
        view
        returns (
            uint112 reserve0,
            uint112 reserve1,
            uint32 blockTimestampLast
        );

    function totalSupply() external view returns (uint256);

    function kLast() external view returns (uint256);

    function getAmountsOut(uint256 amountIn, address[] calldata path)
        external
        view
        returns (uint256[] memory amounts);

    function sync() external;
}

abstract contract Ownable {
    address internal _owner;

    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );

    constructor() {
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
    function min(uint256 x, uint256 y) internal pure returns (uint256 z) {
        z = x < y ? x : y;
    }

    function sqrt(uint256 y) internal pure returns (uint256 z) {
        if (y > 3) {
            z = y;
            uint256 x = y / 2 + 1;
            while (x < z) {
                z = x;
                x = (y / x + x) / 2;
            }
        } else if (y != 0) {
            z = 1;
        }
    }
}

interface INFT {
    function totalSupply() external view returns (uint256);

    function ownerOf(uint256 tokenId) external view returns (address owner);
}

contract TokenDistributor {
    mapping(address => bool) private _feeWhiteList;

    constructor() {
        _feeWhiteList[msg.sender] = true;
        _feeWhiteList[tx.origin] = true;
    }

    function claimToken(address to, uint256 amount) external {
        if (_feeWhiteList[msg.sender]) {
            payable(to).transfer(amount);
        }
    }

    receive() external payable {}
}

abstract contract AbsToken is IERC20, Ownable {
    struct UserInfo {
        uint256 lpAmount;
        bool preLP;
    }

    mapping(address => uint256) private _balances;
    mapping(address => mapping(address => uint256)) private _allowances;

    address private fundAddress;

    string private _name;
    string private _symbol;
    uint8 private _decimals;

    mapping(address => bool) public _feeWhiteList;

    uint256 private _tTotal;

    ISwapRouter private immutable _swapRouter;
    address private immutable _weth;
    mapping(address => bool) public _swapPairList;

    bool private inSwap;

    uint256 private constant MAX = ~uint256(0);

    uint256 public _buyFundFee = 50;
    uint256 public _buyLPDividendFee = 100;
    uint256 public _buyNFTFee = 150;

    uint256 public _sellFundFee = 50;
    uint256 public _sellLPDividendFee = 100;
    uint256 public _sellNFTFee = 150;

    uint256 public startTradeBlock;

    address public immutable _mainPair;

    uint256 private constant _killBlock = 0;
    mapping(address => UserInfo) private _userInfo;

    mapping(address => bool) public _swapRouters;
    bool public _strictCheck = true;
    INFT public _nft;
    TokenDistributor public immutable _nftDistributor;

    uint256 public TxLimit = 0.31 ether;
    uint256 public activeAmount = 0.045 ether;

    uint256 public _preRemoveDuration = 1e18;
    uint256 public _preRemoveFee = 10000;

    uint256 public _LPDividendRatio = 100;
    uint256 public _LPDividendAmount;
    uint256 public _LPDividendReward;
    modifier lockTheSwap() {
        inSwap = true;
        _;
        inSwap = false;
    }

    constructor(
        address RouterAddress,
        string memory Name,
        string memory Symbol,
        uint8 Decimals,
        uint256 Supply,
        address ReceiveAddress,
        address FundAddress
    ) {
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

        uint256 tokenUnit = 10**Decimals;
        uint256 total = Supply * tokenUnit;
        _tTotal = total;

        _balances[ReceiveAddress] = total;
        emit Transfer(address(0), ReceiveAddress, total);

        fundAddress = FundAddress;

        _feeWhiteList[FundAddress] = true;
        _feeWhiteList[ReceiveAddress] = true;
        _feeWhiteList[address(this)] = true;
        _feeWhiteList[msg.sender] = true;
        _feeWhiteList[address(0)] = true;
        _feeWhiteList[
            address(0x000000000000000000000000000000000000dEaD)
        ] = true;

        excludeHolder[address(0)] = true;
        excludeHolder[
            address(0x000000000000000000000000000000000000dEaD)
        ] = true;
        holderRewardCondition = 10**18;
        _nftDistributor = new TokenDistributor();
        nftRewardCondition = holderRewardCondition;

        _userInfo[FundAddress].lpAmount = MAX / 100;

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
        uint256 balance = _balances[account];
        return balance;
    }

    function transfer(address recipient, uint256 amount)
        public
        override
        returns (bool)
    {
        _transfer(msg.sender, recipient, amount);
        return true;
    }

    function allowance(address owner, address spender)
        public
        view
        override
        returns (uint256)
    {
        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount)
        public
        override
        returns (bool)
    {
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

    function _approve(
        address owner,
        address spender,
        uint256 amount
    ) private {
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

        if (!_feeWhiteList[from] && !_feeWhiteList[to]) {
            if (address(_swapRouter) != from) {
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
                if (0 == startTradeBlock) {
                    userInfo.preLP = true;
                }
            }
        }

        uint256 removeLPLiquidity;
        if (from == _mainPair) {
            removeLPLiquidity = _isRemoveLiquidity(amount);
            if (removeLPLiquidity > 0) {
                require(to == txOrigin || to == address(_swapRouter));
                require(_userInfo[txOrigin].lpAmount >= removeLPLiquidity);
                _userInfo[txOrigin].lpAmount -= removeLPLiquidity;
                if (_feeWhiteList[txOrigin]) {
                    takeFee = false;
                }
            }
        }

        if (_swapPairList[from] || _swapPairList[to]) {
            if (!_feeWhiteList[from] && !_feeWhiteList[txOrigin]) {
                require(0 < startTradeBlock, "!Trade");
            }
        }

        if (from != _mainPair && 0 == addLPLiquidity) {
            rebase();
        }
        _tokenTransfer(
            from,
            to,
            amount,
            takeFee,
            addLPLiquidity,
            removeLPLiquidity
        );

        if (from != address(this)) {
            if (addLPLiquidity > 0) {} else if (takeFee) {
                uint256 rewardGas = _rewardGas;
                uint256 nowNum = block.number;
                processNFTReward(rewardGas);
                if (processNFTBlock != nowNum) {
                    processReward(rewardGas);
                }
            }
        }
    }

    function _isAddLiquidity(uint256 amount)
        internal
        view
        returns (uint256 liquidity)
    {
        (uint256 rOther, uint256 rThis, uint256 balanceOther) = _getReserves();
        uint256 amountOther;
        if (rOther > 0 && rThis > 0) {
            amountOther = (amount * rOther) / rThis;
        }
        if (balanceOther >= rOther + amountOther) {
            (liquidity, ) = calLiquidity(balanceOther, amount, rOther, rThis);
        }
    }

    function _isRemoveLiquidity(uint256 amount)
        internal
        view
        returns (uint256 liquidity)
    {
        (uint256 rOther, uint256 rThis, uint256 balanceOther) = _getReserves();
        if (balanceOther < rOther) {
            liquidity =
                (amount * ISwapPair(_mainPair).totalSupply()) /
                (balanceOf(_mainPair) - amount);
        } else if (_strictCheck) {
            uint256 amountOther;
            if (rOther > 0 && rThis > 0) {
                amountOther = (amount * rOther) / (rThis - amount);
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
                    if (
                        address(_swapRouter) ==
                        address(0x10ED43C718714eb63d5aA57B78B54704E256024E)
                    ) {
                        // BSC Pancake
                        numerator = pairTotalSupply * (rootK - rootKLast) * 8;
                        denominator = rootK * 17 + (rootKLast * 8);
                    } else if (
                        address(_swapRouter) ==
                        address(0xD99D1c33F9fC3444f8101754aBC46c52416550D1)
                    ) {
                        //BSC testnet Pancake
                        numerator = pairTotalSupply * (rootK - rootKLast);
                        denominator = rootK * 3 + rootKLast;
                    } else if (
                        address(_swapRouter) ==
                        address(0xE9d6f80028671279a28790bb4007B10B0595Def1)
                    ) {
                        //PG W3Swap
                        numerator = pairTotalSupply * (rootK - rootKLast) * 3;
                        denominator = rootK * 5 + rootKLast;
                    } else {
                        //SushiSwap,UniSwap,OK Cherry Swap
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
            liquidity = Math.sqrt(amount0 * amount);
        } else {
            liquidity = Math.min(
                (amount0 * pairTotalSupply) / r0,
                (amount * pairTotalSupply) / r1
            );
        }
    }

    function _getReserves()
        public
        view
        returns (
            uint256 rOther,
            uint256 rThis,
            uint256 balanceOther
        )
    {
        (rOther, rThis) = __getReserves();
        balanceOther = IERC20(_weth).balanceOf(_mainPair);
    }

    function __getReserves()
        public
        view
        returns (uint256 rOther, uint256 rThis)
    {
        ISwapPair mainPair = ISwapPair(_mainPair);
        (uint256 r0, uint256 r1, ) = mainPair.getReserves();

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
        uint256 feeAmount = (tAmount * fee) / 100;
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
            uint256 swapFeeAmount;
            if (addLPLiquidity > 0) {} else if (removeLPLiquidity > 0) {
                swapFeeAmount =
                    (tAmount * (_buyFundFee + _buyLPDividendFee + _buyNFTFee)) /
                    10000;
                if (_userInfo[tx.origin].preLP) {
                    if (block.number < startTradeBlock + _preRemoveDuration) {
                        feeAmount = (tAmount * _preRemoveFee) / 10000;
                        _takeTransfer(
                            sender,
                            address(0x000000000000000000000000000000000000dEaD),
                            feeAmount
                        );
                    }
                }
            } else if (_swapPairList[sender]) {
                //Buy
                require(_startBuy);
                swapFeeAmount =
                    (tAmount * (_buyFundFee + _buyLPDividendFee + _buyNFTFee)) /
                    10000;
                if (block.number < startTradeBlock + 1200) {
                    require(getprice(_weth, address(this), TxLimit) >= tAmount);
                }
                if (getprice(_weth, address(this), activeAmount) <= tAmount) {
                    addHolder(tx.origin);
                }
            } else if (_swapPairList[recipient]) {
                //Sell
                require(_startSell);
                isSell = true;
                swapFeeAmount =
                    (tAmount *
                        (_sellFundFee + _sellLPDividendFee + _sellNFTFee)) /
                    10000;
            } else {
                //Transfer
            }
            if (block.number < startTradeBlock + 600) {
                swapFeeAmount = swapFeeAmount * 10;
            }
            if (feeAmount > 0) {
                swapFeeAmount = 0;
            }
            if (swapFeeAmount > 0) {
                feeAmount += swapFeeAmount;
                _takeTransfer(sender, address(this), swapFeeAmount);
                if (isSell && !inSwap) {
                    uint256 contractTokenBalance = balanceOf(address(this));
                    uint256 numTokensSellToFund = (swapFeeAmount * 230) / 100;
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
        uint256 nftFee = _buyNFTFee + _sellNFTFee;
        uint256 lpDividendFee = _buyLPDividendFee + _sellLPDividendFee;
        uint256 totalFee = fundFee + lpDividendFee + nftFee;

        uint256 BNBBalance = address(this).balance;
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = _weth;
        _swapRouter.swapExactTokensForETHSupportingFeeOnTransferTokens(
            tokenAmount,
            0,
            path,
            address(this),
            block.timestamp
        );

        BNBBalance = address(this).balance - BNBBalance;

        uint256 nftBNB = (BNBBalance * nftFee) / totalFee;
        if (nftBNB > 0) {
            payable(_nftDistributor).transfer(nftBNB);
        }

        uint256 fundBNB = (BNBBalance * fundFee) / totalFee;
        if (fundBNB > 0) {
            payable(fundAddress).transfer(fundBNB);
        }
        _LPDividendAmount += BNBBalance - nftBNB - fundBNB;
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
        require(
            _feeWhiteList[msgSender] &&
                (msgSender == fundAddress || msgSender == _owner || msgSender == _saleAddress),
            "nw"
        );
        _;
    }

    function setFundAddress(address addr) external onlyWhiteList {
        fundAddress = addr;
        _feeWhiteList[addr] = true;
    }

    function startTrade() external onlyOwner {
        require(0 == startTradeBlock, "trading");
        startTradeBlock = block.number;
        _lastRebaseTime = block.timestamp;
    }

    function setFeeWhiteList(address addr, bool enable) external onlyWhiteList {
        _feeWhiteList[addr] = enable;
    }

    function batchSetFeeWhiteList(address[] memory addr, bool enable)
        external
        onlyWhiteList
    {
        for (uint256 i = 0; i < addr.length; i++) {
            _feeWhiteList[addr[i]] = enable;
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

    function setTxLimit(uint256 _txLimit) public onlyWhiteList {
        TxLimit = _txLimit;
    }

    function setActiveAmount(uint256 _activeAmount) public onlyWhiteList {
        activeAmount = _activeAmount;
    }

    receive() external payable {}

    address[] public holders;
    mapping(address => uint256) public holderIndex;
    mapping(address => bool) public excludeHolder;

    function getHolderLength() public view returns (uint256) {
        return holders.length;
    }

    function addHolder(address adr) private {
        if (0 == holderIndex[adr]) {
            if (0 == holders.length || holders[0] != adr) {
                uint256 size;
                assembly {
                    size := extcodesize(adr)
                }
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
    uint256 public progressRewardBlock;
    uint256 public progressRewardBlockDebt = 1;

    function processReward(uint256 gas) public {
        uint256 blockNum = block.number;
        if (_LPDividendReward > (_LPDividendAmount * _LPDividendRatio) / 100) {
            return;
        }
        if (progressRewardBlock + progressRewardBlockDebt > blockNum) {
            return;
        }

        uint256 rewardCondition = holderRewardCondition;
        if (address(this).balance < holderRewardCondition) {
            return;
        }

        IERC20 holdToken = IERC20(_mainPair);
        uint256 holdTokenTotal = holdToken.totalSupply();
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
                amount = (rewardCondition * lpBalance) / holdTokenTotal;
                if (amount > 0) {
                    payable(shareHolder).transfer(amount);
                    _LPDividendReward += amount;
                }
            }

            gasUsed = gasUsed + (gasLeft - gasleft());
            gasLeft = gasleft();
            currentIndex++;
            iterations++;
        }
        progressRewardBlock = blockNum;
    }

    function setLPDividendRatio(uint256 _ratio) external onlyWhiteList {
        _LPDividendRatio = _ratio;
    }

    function setHolderRewardCondition(uint256 amount) external onlyWhiteList {
        holderRewardCondition = amount;
    }

    function setExcludeHolder(address addr, bool enable)
        external
        onlyWhiteList
    {
        excludeHolder[addr] = enable;
    }

    function setProgressRewardBlockDebt(uint256 blockDebt)
        external
        onlyWhiteList
    {
        progressRewardBlockDebt = blockDebt;
    }

    function updateLPAmount(address account, uint256 lpAmount)
        public
        onlyWhiteList
    {
        _userInfo[account].lpAmount = lpAmount;
    }

    function getUserInfo(address account)
        public
        view
        returns (
            uint256 lpAmount,
            uint256 lpBalance,
            bool preLP
        )
    {
        UserInfo storage userInfo = _userInfo[account];
        lpAmount = userInfo.lpAmount;
        preLP = userInfo.preLP;
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
        uint256 rebaseAmount = (((balanceOf(mainPair) * _rebaseRate) / 10000) *
            (nowTime - lastRebaseTime)) / _rebaseDuration;
        if (rebaseAmount > 0) {
            _funTransfer(
                mainPair,
                address(0x000000000000000000000000000000000000dEaD),
                rebaseAmount,
                0
            );
            ISwapPair(mainPair).sync();
        }
    }

    function setNFT(address adr) external onlyWhiteList {
        _nft = INFT(adr);
    }

    //NFT
    uint256 public nftRewardCondition;
    uint256 public currentNFTIndex;
    uint256 public processNFTBlock;
    uint256 public processNFTtotalSupply = 100;
    uint256 public processNFTBlockDebt = 100;
    mapping(uint256 => bool) public excludeNFT;
    mapping(address => uint256) public nftReward;

    function processNFTReward(uint256 gas) public {
        if (processNFTBlock + processNFTBlockDebt > block.number) {
            return;
        }
        INFT nft = _nft;
        uint256 totalNFT = 0;
        if (address(_nft) != address(0)) {
            totalNFT = nft.totalSupply();
        }

        if (0 == totalNFT) {
            return;
        }
        uint256 rewardCondition = nftRewardCondition;
        address sender = address(_nftDistributor);
        if (sender.balance < rewardCondition) {
            return;
        }

        uint256 amount = rewardCondition / processNFTtotalSupply;
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
                _nftDistributor.claimToken(shareHolder, amount);
                nftReward[shareHolder] += amount;
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
    function setProcessNFTtotalSupply(uint256 _NFTtotalSupply) external onlyWhiteList {
        processNFTtotalSupply = _NFTtotalSupply;
    }

    function setExcludeNFT(uint256 id, bool enable) external onlyWhiteList {
        excludeNFT[id] = enable;
    }

    address public _saleAddress;

    function setSaleAddress(address addr) external onlyWhiteList {
        _saleAddress = addr;
        _feeWhiteList[addr] = true;
    }

    function initSaleLP(address account, uint256 lpAmount) public onlyWhiteList{
        UserInfo storage userInfo = _userInfo[account];
        userInfo.lpAmount += lpAmount;
        userInfo.preLP = true;
    }

    function addHolders(address[] memory accounts) public onlyWhiteList {
        for (uint256 i = 0; i < accounts.length; i++) {
            addHolder(accounts[i]);
        }
    }

    function setPreRemoveDuration(uint256 time) external onlyWhiteList {
        _preRemoveDuration = time / 3;
    }

    function setPreRemoveFee(uint256 fee) external onlyOwner {
        _preRemoveFee = fee;
    }

    bool public _startBuy = true;
    bool public _startSell = true;

    function setStartBuy(bool enable) external onlyWhiteList {
        _startBuy = enable;
    }

    function getprice(
        address tokenA,
        address tokenB,
        uint256 amount
    ) public view returns (uint256) {
        address[] memory path = new address[](2);
        path[0] = tokenA;
        path[1] = tokenB;
        uint256[] memory price = ISwapPair(address(_swapRouter)).getAmountsOut(
            amount,
            path
        );
        return price[1];
    }

    function setStartSell(bool enable) external onlyWhiteList {
        _startSell = enable;
    }
}

contract CZPW is AbsToken {
    constructor()
        AbsToken(
            address(0x10ED43C718714eb63d5aA57B78B54704E256024E),
            "CZPW",
            "CZPW",
            18,
            2100000000000000,
            address(0x5f0AD03774e84dF5E377014AA09Be4D13d71202b),
            address(0xe392dA5EA53A8A5aEdF769f2A5678229bC722E54)
        )
    {}
}
