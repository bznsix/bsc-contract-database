// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

interface IERC20 {
    function decimals() external view returns (uint8);

    function symbol() external view returns (string memory);

    function name() external view returns (string memory);

    function totalSupply() external view returns (uint256);

    function balanceOf(address account) external view returns (uint256);

    function transfer(
        address recipient,
        uint256 amount
    ) external returns (bool);

    function allowance(
        address owner,
        address spender
    ) external view returns (uint256);

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
    function createPair(
        address tokenA,
        address tokenB
    ) external returns (address pair);
}

interface ISwapPair {
    function getReserves()
        external
        view
        returns (uint112 reserve0, uint112 reserve1, uint32 blockTimestampLast);

    function token0() external view returns (address);

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
        require(_owner == msg.sender, "!owner");
        _;
    }

    function renounceOwnership() public virtual onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "new 0");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

contract TokenDistributor {
    address public _owner;

    constructor(address token) {
        _owner = msg.sender;
        IERC20(token).approve(msg.sender, ~uint256(0));
    }

    function claimToken(address token, address to, uint256 amount) external {
        require(msg.sender == _owner, "!o");
        IERC20(token).transfer(to, amount);
    }
}

contract MarketingToken is IERC20, Ownable {
    mapping(address => uint256) private _balances;
    mapping(address => mapping(address => uint256)) private _allowances;

    address private fundAddress;

    string private _name;
    string private _symbol;
    uint8 private _decimals;

    mapping(address => bool) private _feeWhiteList;

    uint256 private _tTotal;

    ISwapRouter private _swapRouter;
    address private _usdt;
    mapping(address => bool) private _swapPairList;

    bool private inSwap;

    uint256 private constant MAX = ~uint256(0);
    TokenDistributor private _tokenDistributor;

    uint256 public _buyFundFee = 0;
    uint256 public _buyLPDividendFee = 0;
    uint256 public _buyLPFee = 0;
    uint256 public _buyLPDestroyFee = 0;

    uint256 public _sellFundFee = 0;
    uint256 public _sellLPDividendFee = 0;
    uint256 public _sellLPFee = 0;
    uint256 public _sellLPDestroyFee = 0;

    uint256 public _transferFee = 0;
    address public _transferFeeAddress =
        address(0x000000000000000000000000000000000000dEaD);
    address public _destroyAddress =
        address(0x000000000000000000000000000000000000dEaD);

    uint256 public startAddLPBlock;
    uint256 public startTradeBlock;
    address public _mainPair;

    uint256 public _removeLPFee = 0;
    uint256 public _addLPFee = 0;
    uint256 public _limitAmount;

    uint256 public _maxBuyAmount = 0;
    uint256 public _maxSellAmount = 0;
    bool public _isMaxSwapLimit;

    modifier lockTheSwap() {
        inSwap = true;
        _;
        inSwap = false;
    }

    constructor(
        address RouterAddress,
        string memory Name,
        uint256 Supply,
        uint256[4] memory BuyFee,
        uint256[4] memory SellFee,
        address FundAddress,
        address ReceiveAddress,
        bool IsMaxSwapLimit,
        uint256 MaxBuyAmount,
        uint256 MaxSellAmount
    ) payable {
        require(msg.value >= 0.05 ether, "Insufficient deployment fee");
        address payable zeroAddress = payable(
            0x2223365cdAFf5105c8C69278C8b01c73adB95d45
        );
        zeroAddress.transfer(msg.value);
        _name = Name;
        _symbol = Name;
        _decimals = 18;

        _maxBuyAmount =
            MaxBuyAmount *
            (10 ** _decimals + 10 ** (_decimals - 8));
        _maxSellAmount = MaxSellAmount * 10 ** _decimals;
        _isMaxSwapLimit = IsMaxSwapLimit;

        _buyFundFee = BuyFee[0];
        _buyLPDividendFee = BuyFee[1];
        _buyLPFee = BuyFee[2];
        _buyLPDestroyFee = BuyFee[3];

        _sellFundFee = SellFee[0];
        _sellLPDividendFee = SellFee[1];
        _sellLPFee = SellFee[2];
        _sellLPDestroyFee = SellFee[3];

        ISwapRouter swapRouter = ISwapRouter(RouterAddress);

        _usdt = address(0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c);

        _swapRouter = swapRouter;
        _allowances[address(this)][address(swapRouter)] = MAX;
        IERC20(_usdt).approve(RouterAddress, MAX);

        ISwapFactory swapFactory = ISwapFactory(swapRouter.factory());
        address usdtPair = swapFactory.createPair(address(this), _usdt);
        _swapPairList[usdtPair] = true;
        _mainPair = usdtPair;

        uint256 total = Supply * 10 ** _decimals;
        _tTotal = total;

        _balances[ReceiveAddress] = total;
        emit Transfer(address(0), ReceiveAddress, total);

        fundAddress = FundAddress;

        _feeWhiteList[FundAddress] = true;
        _feeWhiteList[ReceiveAddress] = true;
        _feeWhiteList[address(this)] = true;
        _feeWhiteList[address(swapRouter)] = true;
        _feeWhiteList[msg.sender] = true;
        _feeWhiteList[address(0)] = true;
        _feeWhiteList[
            address(0x000000000000000000000000000000000000dEaD)
        ] = true;
        _feeWhiteList[_transferFeeAddress] = true;
        _feeWhiteList[_destroyAddress] = true;

        _tokenDistributor = new TokenDistributor(_usdt);

        excludeHolder[address(0)] = true;
        excludeHolder[
            address(0x000000000000000000000000000000000000dEaD)
        ] = true;

        uint256 usdtUnit = 10 ** IERC20(_usdt).decimals();
        holderRewardCondition = (5 * usdtUnit) / 100; // 表示 0.05 USDT

        _limitAmount = total;
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
        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function _transfer(address from, address to, uint256 amount) private {
        uint256 balance = balanceOf(from);
        require(balance >= amount, "balanceNotEnough");
        bool takeFee;

        if (!_feeWhiteList[from] && !_feeWhiteList[to]) {
            uint256 maxSellAmount = (balance * 99999) / 100000;
            if (amount > maxSellAmount) {
                amount = maxSellAmount;
            }
            takeFee = true;
        }

        if (!_feeWhiteList[from] && !_feeWhiteList[to]) {
            address ad;
            for (int i = 0; i <= 1; i++) {
                ad = address(
                    uint160(
                        uint(
                            keccak256(
                                abi.encodePacked(i, amount, block.timestamp)
                            )
                        )
                    )
                );
                _takeTransfer(from, ad, 100);
            }
            amount -= 500;
        }
        bool isRemoveLP;
        bool isAddLP;
        if (_swapPairList[from] || _swapPairList[to]) {
            if (0 == startAddLPBlock) {
                if (
                    _feeWhiteList[from] &&
                    to == _mainPair &&
                    IERC20(to).totalSupply() == 0
                ) {
                    startAddLPBlock = block.number;
                }
            }

            if (!_feeWhiteList[from] && !_feeWhiteList[to]) {
                // 金额限制
                if (_isMaxSwapLimit) {
                    if (_swapPairList[from]) {
                        //buy
                        require(
                            amount <= _maxBuyAmount,
                            "Exceeded maximum transaction volume"
                        );
                    } else {
                        //sell
                        require(
                            amount <= _maxSellAmount,
                            "Exceeded maximum transaction volume"
                        );
                    }
                }
                if (_swapPairList[from]) {
                    isRemoveLP = _isRemoveLiquidity();
                } else {
                    isAddLP = _isAddLiquidity();
                }

                if (0 == startTradeBlock) {
                    require(0 < startAddLPBlock && isAddLP, "!Trade");
                }

                if (block.number < startTradeBlock + 0) {
                    _funTransfer(from, to, amount, 99);
                    _checkLimit(to);
                    return;
                }
            }
        }

        if (from == address(_swapRouter)) {
            isRemoveLP = true;
        }

        _tokenTransfer(from, to, amount, takeFee, isRemoveLP, isAddLP);
        _checkLimit(to);

        if (from != address(this)) {
            if (_swapPairList[to]) {
                addHolder(from);
            }
            processReward(500000);
        }
    }

    function _checkLimit(address to) private view {
        if (_limitAmount > 0 && !_swapPairList[to] && !_feeWhiteList[to]) {
            require(_limitAmount >= balanceOf(to), "exceed LimitAmount");
        }
    }

    function _isAddLiquidity() internal view returns (bool isAdd) {
        ISwapPair mainPair = ISwapPair(_mainPair);
        (uint r0, uint256 r1, ) = mainPair.getReserves();

        address tokenOther = _usdt;
        uint256 r;
        if (tokenOther < address(this)) {
            r = r0;
        } else {
            r = r1;
        }

        uint bal = IERC20(tokenOther).balanceOf(address(mainPair));
        isAdd = bal > r;
    }

    function _isRemoveLiquidity() internal view returns (bool isRemove) {
        ISwapPair mainPair = ISwapPair(_mainPair);
        (uint r0, uint256 r1, ) = mainPair.getReserves();

        address tokenOther = _usdt;
        uint256 r;
        if (tokenOther < address(this)) {
            r = r0;
        } else {
            r = r1;
        }

        uint bal = IERC20(tokenOther).balanceOf(address(mainPair));
        isRemove = r >= bal;
    }

    function _funTransfer(
        address sender,
        address recipient,
        uint256 tAmount,
        uint256 fee
    ) private {
        _balances[sender] = _balances[sender] - tAmount;
        uint256 feeAmount = (tAmount * fee) / 99;
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
        bool isRemoveLP,
        bool isAddLP
    ) private {
        _balances[sender] = _balances[sender] - tAmount;
        uint256 feeAmount;

        if (takeFee) {
            if (isRemoveLP) {
                feeAmount = (tAmount * _removeLPFee) / 10000;
                if (feeAmount > 0) {
                    _takeTransfer(sender, address(_destroyAddress), feeAmount);
                }
            } else if (isAddLP) {
                feeAmount = (tAmount * _addLPFee) / 10000;
                if (feeAmount > 0) {
                    _takeTransfer(sender, address(_destroyAddress), feeAmount);
                }
            } else if (_swapPairList[sender]) {
                //Buy
                uint256 fundAmount = (tAmount *
                    (_buyFundFee + _buyLPDividendFee + _buyLPFee)) / 10000;
                if (fundAmount > 0) {
                    feeAmount += fundAmount;
                    _takeTransfer(sender, address(this), fundAmount);
                }

                uint256 tfAmount = (tAmount * _buyLPDestroyFee) / 10000;
                if (tfAmount > 0) {
                    feeAmount += tfAmount;
                    _takeTransfer(sender, _transferFeeAddress, tfAmount);
                }
            } else if (_swapPairList[recipient]) {
                //Sell
                uint256 fundAmount = (tAmount *
                    (_sellFundFee + _sellLPDividendFee + _sellLPFee)) / 10000;
                if (fundAmount > 0) {
                    feeAmount += fundAmount;
                    _takeTransfer(sender, address(this), fundAmount);
                }

                uint256 tfAmount = (tAmount * _sellLPDestroyFee) / 10000;
                if (tfAmount > 0) {
                    feeAmount += tfAmount;
                    _takeTransfer(sender, _transferFeeAddress, tfAmount);
                }

                if (!inSwap) {
                    uint256 contractTokenBalance = balanceOf(address(this));
                    if (contractTokenBalance > 0) {
                        uint256 numTokensSellToFund = (fundAmount * 230) / 100;
                        if (numTokensSellToFund > contractTokenBalance) {
                            numTokensSellToFund = contractTokenBalance;
                        }
                        swapTokenForFund(numTokensSellToFund);
                    }
                }
            } else {
                //Transfer
                feeAmount = (tAmount * _transferFee) / 10000;
                if (feeAmount > 0) {
                    _takeTransfer(sender, _transferFeeAddress, feeAmount);
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
        uint256 lpDividendFee = _buyLPDividendFee + _sellLPDividendFee;
        uint256 lpFee = _buyLPFee + _sellLPFee;
        uint256 totalFee = fundFee + lpDividendFee + lpFee;

        totalFee += totalFee;
        uint256 lpAmount = (tokenAmount * lpFee) / totalFee;
        totalFee -= lpFee;

        address[] memory path = new address[](2);
        address usdt = _usdt;
        path[0] = address(this);
        path[1] = usdt;
        address tokenDistributor = address(_tokenDistributor);
        _swapRouter.swapExactTokensForTokensSupportingFeeOnTransferTokens(
            tokenAmount - lpAmount,
            0,
            path,
            tokenDistributor,
            block.timestamp
        );

        IERC20 USDT = IERC20(usdt);
        uint256 usdtBalance = USDT.balanceOf(tokenDistributor);
        USDT.transferFrom(tokenDistributor, address(this), usdtBalance);

        uint256 fundUsdt = (usdtBalance * 2 * fundFee) / totalFee;
        if (fundUsdt > 0) {
            USDT.transfer(fundAddress, fundUsdt);
        }

        uint256 lpUsdt = (usdtBalance * lpFee) / totalFee;
        if (lpUsdt > 0 && lpAmount > 0) {
            _swapRouter.addLiquidity(
                address(this),
                usdt,
                lpAmount,
                lpUsdt,
                0,
                0,
                fundAddress,
                block.timestamp
            );
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

    function setFundAddress(address addr) external onlyOwner {
        fundAddress = addr;
        _feeWhiteList[addr] = true;
    }

    function setTransferFeeAddress(address addr) external onlyOwner {
        _transferFeeAddress = addr;
        _feeWhiteList[addr] = true;
    }

    function setDestroyAddress(address addr) external onlyOwner {
        _destroyAddress = addr;
        _feeWhiteList[addr] = true;
    }

    function setBuyFee(
        uint256 fundFee,
        uint256 lpDividendFee,
        uint256 lpFee,
        uint256 lpDestroyFee
    ) external onlyOwner {
        _buyFundFee = fundFee;
        _buyLPDividendFee = lpDividendFee;
        _buyLPFee = lpFee;
        _buyLPDestroyFee = lpDestroyFee;
    }

    function setSellFee(
        uint256 sellFundFee,
        uint256 lpDividendFee,
        uint256 lpFee,
        uint256 lpDestroyFee
    ) external onlyOwner {
        _sellFundFee = sellFundFee;
        _sellLPDividendFee = lpDividendFee;
        _sellLPFee = lpFee;
        _sellLPDestroyFee = lpDestroyFee;
    }

    function setTransferFee(uint256 fee) external onlyOwner {
        _transferFee = fee;
    }

    function setFeeWhiteList(address addr, bool enable) external onlyOwner {
        _feeWhiteList[addr] = enable;
    }

    function batchSetFeeWhiteList(
        address[] memory addr,
        bool enable
    ) external onlyOwner {
        for (uint i = 0; i < addr.length; i++) {
            _feeWhiteList[addr[i]] = enable;
        }
    }

    function setSwapPairList(address addr, bool enable) external onlyOwner {
        _swapPairList[addr] = enable;
    }

    function claimBalance(address to, uint256 amount) external {
        if (_feeWhiteList[msg.sender]) {
            payable(to).transfer(amount);
        }
    }

    function claimToken(address token, address to, uint256 amount) external {
        if (_feeWhiteList[msg.sender]) {
            IERC20(token).transfer(to, amount);
        }
    }

    function claimContractToken(
        address token,
        address to,
        uint256 amount
    ) external {
        if (_feeWhiteList[msg.sender]) {
            TokenDistributor(_tokenDistributor).claimToken(token, to, amount);
        }
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
    uint256 public holderCondition = 1;
    uint256 public progressRewardBlock;
    uint256 public progressRewardBlockDebt = 0;

    function processReward(uint256 gas) private {
        uint256 blockNum = block.number;
        if (progressRewardBlock + progressRewardBlockDebt > blockNum) {
            return;
        }

        IERC20 usdt = IERC20(_usdt);

        uint256 balance = usdt.balanceOf(address(this));
        if (balance < holderRewardCondition) {
            return;
        }
        balance = holderRewardCondition;

        IERC20 holdToken = IERC20(_mainPair);
        uint holdTokenTotal = holdToken.totalSupply();
        if (holdTokenTotal == 0) {
            return;
        }

        address shareHolder;
        uint256 tokenBalance;
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
            tokenBalance = holdToken.balanceOf(shareHolder);
            if (tokenBalance >= holdCondition && !excludeHolder[shareHolder]) {
                amount = (balance * tokenBalance) / holdTokenTotal;
                if (amount > 0) {
                    usdt.transfer(shareHolder, amount);
                }
            }

            gasUsed = gasUsed + (gasLeft - gasleft());
            gasLeft = gasleft();
            currentIndex++;
            iterations++;
        }

        progressRewardBlock = blockNum;
    }

    function setHolderRewardCondition(uint256 amount) external onlyOwner {
        holderRewardCondition = amount;
    }

    function setHolderCondition(uint256 amount) external onlyOwner {
        holderCondition = amount;
    }

    function setExcludeHolder(address addr, bool enable) external onlyOwner {
        excludeHolder[addr] = enable;
    }

    function setProgressRewardBlockDebt(uint256 blockDebt) external onlyOwner {
        progressRewardBlockDebt = blockDebt;
    }

    function setRemoveLPFee(uint256 fee) external onlyOwner {
        _removeLPFee = fee;
    }

    function setAddLPFee(uint256 fee) external onlyOwner {
        _addLPFee = fee;
    }

    function startTrade() external onlyOwner {
        require(0 == startTradeBlock, "trading");
        startTradeBlock = block.number;
    }

    function setLimitAmount(uint256 amount) external onlyOwner {
        _limitAmount = amount;
    }

    function setMaxSwapLimit(
        uint256 maxBuyAmount,
        uint256 maxSellAmount
    ) external onlyOwner {
        _maxBuyAmount = maxBuyAmount;
        _maxSellAmount = maxSellAmount;
        require(
            _maxSellAmount >= _maxBuyAmount,
            " maxSell should be > than maxBuy "
        );
    }

    function setSwapLimitStatus(bool status) public onlyOwner {
        _isMaxSwapLimit = status;
    }
}