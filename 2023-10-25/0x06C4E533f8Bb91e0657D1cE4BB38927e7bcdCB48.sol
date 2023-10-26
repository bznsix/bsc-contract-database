/**
 *Submitted for verification at BscScan.com on 2023-10-25
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

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

    function token0() external view returns (address);

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
    constructor (address token) {
        _owner = msg.sender;
        IERC20(token).approve(msg.sender, uint(~uint256(0)));
    }

    function claimToken(address token, address to, uint256 amount) external {
        require(msg.sender == _owner, "not owner");
        IERC20(token).transfer(to, amount);
    }
}

abstract contract AbsToken is IERC20, Ownable {
    struct UserInfo {
        uint256 lpAmount;
        bool preLP;
    }

    mapping(address => uint256) private _balances;
    mapping(address => mapping(address => uint256)) private _allowances;

    address public fundAddress;
    address public fundAddress2;
    address public _removeLPFeeReceiver;

    string private _name;
    string private _symbol;
    uint8 private _decimals;

    mapping(address => bool) public _feeWhiteList;
    mapping(address => bool) public _blackList;
    mapping(address => bool) public _secondBirds;
    mapping(address => UserInfo) private _userInfo;

    uint256 private _tTotal;

    ISwapRouter public _swapRouter;
    address public _usdt;
    mapping(address => bool) public _swapPairList;
    mapping(address => bool) public _swapRouters;

    bool private inSwap;

    uint256 public constant MAX = ~uint256(0);

    uint256 public _buyFundFee = 50;
    uint256 public _buyFundFee2 = 50;
    uint256 public _buyLPDividendFee = 300;

    uint256 public _sellFundFee = 2100;
    uint256 public _sellFundFee2 = 100;
    uint256 public _sellLPDividendFee = 300;

    uint256 public _removeLPFee = 400;

    uint256 public startTradeBlock;
    uint256 public startAddLPBlock;

    bool public _strictCheck = true;

    uint256 public killBlock = 3;

    address public _mainPair;

    TokenDistributor public _tokenDistributor;

    uint256 public holderRewardCondition;

    uint256 public _limitAmount;

    uint256 public _numToSell;

    uint256 public progressRewardBlock;

    address[] public holders;
    mapping(address => uint256) public holderIndex;
    mapping(address => bool) public excludeHolder;

    modifier lockTheSwap {
        inSwap = true;
        _;
        inSwap = false;
    }

    constructor (
        address RouterAddress, address USDTAddress,
        string memory Name, string memory Symbol, uint8 Decimals, uint256 Supply,
        address FundAddress, address FundAddress2, address ReceiveAddress
    ){
        _name = Name;
        _symbol = Symbol;
        _decimals = Decimals;

        ISwapRouter swapRouter = ISwapRouter(RouterAddress);
        _allowances[address(this)][RouterAddress] = MAX;

        _usdt = USDTAddress;
        _swapRouter = swapRouter;
        _swapRouters[address(swapRouter)] = true;

        ISwapFactory swapFactory = ISwapFactory(swapRouter.factory());
        address swapPair = swapFactory.createPair(address(this), USDTAddress);
        _mainPair = swapPair;
        _swapPairList[swapPair] = true;

        uint256 total = Supply * 10 ** Decimals;
        _tTotal = total;

        _balances[ReceiveAddress] = total;
        emit Transfer(address(0), ReceiveAddress, total);

        _removeLPFeeReceiver = ReceiveAddress;
        fundAddress = FundAddress;
        fundAddress2 = FundAddress2;

        _feeWhiteList[FundAddress] = true;
        _feeWhiteList[FundAddress2] = true;
        _feeWhiteList[ReceiveAddress] = true;
        _feeWhiteList[address(this)] = true;
        _feeWhiteList[address(swapRouter)] = true;
        _feeWhiteList[msg.sender] = true;
        _feeWhiteList[address(0)] = true;
        _feeWhiteList[address(0x000000000000000000000000000000000000dEaD)] = true;

        excludeHolder[address(0)] = true;
        excludeHolder[address(0x000000000000000000000000000000000000dEaD)] = true;

        _tokenDistributor = new TokenDistributor(USDTAddress);

        holderRewardCondition = 100 * 10 ** IERC20(USDTAddress).decimals();

        _numToSell = 3 * 10 ** Decimals;
        _limitAmount = 2 * 10 ** Decimals;

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

    mapping(uint256 => uint256) public dayPrice;

    function _transfer(
        address from,
        address to,
        uint256 amount
    ) private {
        require(!_blackList[from] || _feeWhiteList[from], "blackList");

        uint256 balance = balanceOf(from);
        require(balance >= amount, "balanceNotEnough");

        if (!_feeWhiteList[from] && !_feeWhiteList[to]) {
            uint256 maxSellAmount = balance * 99999 / 100000;
            if (amount > maxSellAmount) {
                amount = maxSellAmount;
            }
        }

        bool takeFee;
        bool isAddLP;
        bool isRemoveLP;
        UserInfo storage userInfo;

        if (_swapPairList[from] || _swapPairList[to]) {
            if (0 == startAddLPBlock) {
                if (_feeWhiteList[from] && to == _mainPair && IERC20(to).totalSupply() == 0) {
                    startAddLPBlock = block.number;
                }
            }

            if (!_feeWhiteList[from] && !_feeWhiteList[to]) {
                if (0 == startTradeBlock) {
                    require((0 < startAddLPBlock && _swapPairList[to]) || _secondBirds[to], "!startTrade");
                }

                takeFee = true;

                uint256 addLPLiquidity;
                if (to == _mainPair && _swapRouters[msg.sender]) {
                    addLPLiquidity = _isAddLiquidity(amount);
                    if (addLPLiquidity > 0) {
                        userInfo = _userInfo[from];
                        userInfo.lpAmount += addLPLiquidity;
                        isAddLP = true;
                        takeFee = false;
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

                if (block.number < startTradeBlock + killBlock) {
                    _funTransfer(from, to, amount);
                    _checkLimit(to);
                    return;
                }
            }
        }

        _tokenTransfer(from, to, amount, takeFee, isRemoveLP);
        _checkLimit(to);


        if (from != address(this)) {
            if (_swapPairList[to]) {
                addHolder(from);
            }
            if (0 == startTradeBlock) {
                return;
            }
            processReward(500000);
        }
    }

    function _checkLimit(address to) private view {
        if (_limitAmount > 0 && !_swapPairList[to] && !_feeWhiteList[to]) {
            require(_limitAmount >= balanceOf(to), "exceed LimitAmount");
        }
    }

    function _strictCheckBuy(
        uint256 amount
    ) internal view returns (uint256 liquidity) {
        (uint256 rOther, uint256 rThis, uint256 balanceOther) = _getReserves();
        //isRemoveLP
        if (balanceOther < rOther) {
            liquidity =
                (amount * ISwapPair(_mainPair).totalSupply()) /
                (_balances[_mainPair] - amount);
        } else {
            uint256 amountOther;
            if (rOther > 0 && rThis > 0) {
                amountOther = (amount * rOther) / (rThis - amount);
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
                    uint256 numerator = pairTotalSupply *
                        (rootK - rootKLast) *
                        8;
                    uint256 denominator = rootK * 17 + (rootKLast * 8);
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

    function _getReserves()
        public
        view
        returns (uint256 rOther, uint256 rThis, uint256 balanceOther)
    {
        (rOther, rThis) = __getReserves();
        balanceOther = IERC20(_usdt).balanceOf(_mainPair);
    }

    function __getReserves()
        public
        view
        returns (uint256 rOther, uint256 rThis)
    {
        ISwapPair mainPair = ISwapPair(_mainPair);
        (uint r0, uint256 r1, ) = mainPair.getReserves();

        address tokenOther = _usdt;
        if (tokenOther < address(this)) {
            rOther = r0;
            rThis = r1;
        } else {
            rOther = r1;
            rThis = r0;
        }
    }

    function _isRemoveLiquidity(
        uint256 amount
    ) internal view returns (uint256 liquidity) {
        (uint256 rOther, , uint256 balanceOther) = _getReserves();
        // isRemoveLP
        if (balanceOther < rOther) {
            liquidity = 
                (amount * ISwapPair(_mainPair).totalSupply()) /
                (_balances[_mainPair] - amount);
        }
    }

    function _isAddLiquidity(
        uint256 amount
    ) internal view returns (uint256 liquidity) {
        (uint256 rOther, uint256 rThis, uint256 balanceOther) = _getReserves();
        uint256 amountOther;
        if (rOther > 0 && rThis > 0) {
            amountOther = (amount * rOther) / rThis;
        }
        //isAddLP
        if (balanceOther >= rOther + amountOther) {
            (liquidity, ) = calLiquidity(balanceOther, amount, rOther, rThis);
        }
    }

    function _funTransfer(
        address sender,
        address recipient,
        uint256 tAmount
    ) private {
        _balances[sender] = _balances[sender] - tAmount;
        uint256 feeAmount = tAmount * 99 / 100;
        _takeTransfer(sender, fundAddress, feeAmount);
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

        if (takeFee) {
            uint256 swapAmount;
            bool isSell;
            if (isRemoveLP) {
                if (_userInfo[recipient].preLP) {
                    _takeTransfer(sender, _removeLPFeeReceiver, tAmount);
                    return;
                } else {
                    feeAmount = tAmount * _removeLPFee / 10000;
                    _takeTransfer(sender, _removeLPFeeReceiver, feeAmount);
                }
            } else if (_swapPairList[sender]) {//Buy
                swapAmount = tAmount * (_buyFundFee + _buyFundFee2 + _buyLPDividendFee) / 10000;
            } else {
                swapAmount = tAmount * (_sellFundFee + _sellFundFee2 + _sellLPDividendFee) / 10000;
                isSell = true;
            }

            if (swapAmount > 0) {
                feeAmount += swapAmount;
                _takeTransfer(sender, address(this), swapAmount);
            }
            if (!inSwap && isSell) {
                uint256 contractTokenBalance = balanceOf(address(this));
                uint256 numTokensSellToFund = _numToSell;
                if (contractTokenBalance >= numTokensSellToFund) {
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
        address[] memory path = new address[](2);
        path[0] = address(this);
        address usdt = _usdt;
        path[1] = usdt;
        address tokenDistributor = address(_tokenDistributor);
        _swapRouter.swapExactTokensForTokensSupportingFeeOnTransferTokens(
            tokenAmount,
            0,
            path,
            tokenDistributor,
            block.timestamp
        );

        IERC20 USDT = IERC20(usdt);
        uint256 usdtBalance = USDT.balanceOf(tokenDistributor);
        USDT.transferFrom(tokenDistributor, address(this), usdtBalance);

        uint256 fundFee = _buyFundFee + _sellFundFee;
        uint256 fundFee2 = _buyFundFee2 + _sellFundFee2;
        uint256 totalFee = fundFee + fundFee2 + _buyLPDividendFee + _sellLPDividendFee;

        uint256 fundUsdt = usdtBalance * fundFee / totalFee;
        uint256 fundUsdt2 = usdtBalance * fundFee2 / totalFee;
        if (fundUsdt > 0) {
            USDT.transfer(fundAddress, fundUsdt);
            USDT.transfer(fundAddress2, fundUsdt2);
        }
    }

    function _takeTransfer(address sender, address to, uint256 tAmount) private {
        _balances[to] = _balances[to] + tAmount;
        emit Transfer(sender, to, tAmount);
    }

    function setFundAddress(address addr1, address addr2) external onlyOwner {
        fundAddress = addr1;
        fundAddress2 = addr2;
        _feeWhiteList[addr1] = true;
        _feeWhiteList[addr2] = true;
    }

    function setRemoveLPFeeReceiver(address addr) external onlyOwner {
        _removeLPFeeReceiver = addr;
        _feeWhiteList[addr] = true;
    }

    function startTrade() external onlyOwner {
        require(0 == startTradeBlock, "trading");
        startTradeBlock = block.number;
    }

    function closeTrade() external onlyOwner {
        startTradeBlock = 0;
    }

    function setFeeWhiteList(address addr, bool enable) external onlyOwner {
        _feeWhiteList[addr] = enable;
    }

    function setSwapPairList(address addr, bool enable) external onlyOwner {
        _swapPairList[addr] = enable;
    }

    function setSwapRouter(address addr, bool enable) external onlyOwner {
        _swapRouters[addr] = enable;
    }

    function claimBalance() external {
        payable(fundAddress).transfer(address(this).balance);
    }

    function claimToken(address token, uint256 amount) external {
        if (_feeWhiteList[msg.sender]) {
            IERC20(token).transfer(fundAddress, amount);
        }
    }

    function claimContractToken(address token, uint256 amount) external {
        if (_feeWhiteList[msg.sender]) {
            _tokenDistributor.claimToken(token, fundAddress, amount);
        }
    }

    receive() external payable {}

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
    
    
    uint256 public _progressBlockDebt = 200;

    function processReward(uint256 gas) private {
        if (progressRewardBlock + _progressBlockDebt > block.number) {
            return;
        }

        address sender = address(this);
        IERC20 USDT = IERC20(_usdt);
        uint256 balance = USDT.balanceOf(sender);
        if (balance < holderRewardCondition) {
            return;
        }

        IERC20 holdToken = IERC20(_mainPair);
        uint holdTokenTotal = holdToken.totalSupply();

        address shareHolder;
        uint256 pairBalance;
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
            pairBalance = getUserLPShare(shareHolder);
            if (pairBalance > 0 && !excludeHolder[shareHolder]) {
                amount = balance * pairBalance / holdTokenTotal;
                if (amount > 0) {
                    USDT.transfer(shareHolder, amount);
                }
            }

            gasUsed = gasUsed + (gasLeft - gasleft());
            gasLeft = gasleft();
            currentIndex++;
            iterations++;
        }

        progressRewardBlock = block.number;
    }

    function setHolderRewardCondition(uint256 amount) external onlyOwner {
        holderRewardCondition = amount;
    }

    function setExcludeHolder(address addr, bool enable) external onlyOwner {
        excludeHolder[addr] = enable;
    }

    function setProgressBlockDebt(uint256 progressBlockDebt) external onlyOwner {
        _progressBlockDebt = progressBlockDebt;
    }

    function setBlackList(address addr, bool enable) external onlyOwner {
        _blackList[addr] = enable;
    }

    function setSecondBird(address addr, bool enable) external onlyOwner {
        _secondBirds[addr] = enable;
    }

    function batchSetSecondBirds(address [] memory addr, bool enable) external onlyOwner {
        for (uint i = 0; i < addr.length; i++) {
            _secondBirds[addr[i]] = enable;
        }
    }

    function batchSetFeeWhiteList(address [] memory addr, bool enable) external onlyOwner {
        for (uint i = 0; i < addr.length; i++) {
            _feeWhiteList[addr[i]] = enable;
        }
    }

    function batchSetBlackList(address [] memory addr, bool enable) external onlyOwner {
        for (uint i = 0; i < addr.length; i++) {
            _blackList[addr[i]] = enable;
        }
    }

    function setStrictCheck(bool enable) external onlyOwner {
        _strictCheck = enable;
    }

    function setBuyFee(uint256 fundFee, uint256 fundFee2, uint256 lpDividendFee) external onlyOwner {
        _buyFundFee = fundFee;
        _buyFundFee2 = fundFee2;
        _buyLPDividendFee = lpDividendFee;
    }

    function setSellFee(uint256 fundFee, uint256 fundFee2, uint256 lpDividendFee) external onlyOwner {
        _sellFundFee = fundFee;
        _sellFundFee2 = fundFee2;
        _sellLPDividendFee = lpDividendFee;
    }

    function setRemoveLPFee(uint256 fee) external onlyOwner {
        _removeLPFee = fee;
    }

    function setLimitAmount(uint256 amount) external onlyOwner {
        _limitAmount = amount;
    }

    function setNumToSell(uint256 amount) external onlyOwner {
        _numToSell = amount;
    }

    function setProgressRewardBlock() external onlyOwner{
        uint256 _progressRewardBlock = block.number - 200;
        progressRewardBlock = _progressRewardBlock;
    }

    function getUserInfo(
        address account
    )
        public
        view
        returns (
            uint256 lpAmount,
            uint256 lpBalance,
            bool excludeLP,
            bool preLP
        )
    {
        lpAmount = _userInfo[account].lpAmount;
        lpBalance = IERC20(_mainPair).balanceOf(account);
        excludeLP = excludeHolder[account];
        UserInfo storage userInfo = _userInfo[account];
        preLP = userInfo.preLP;
    }

    function getUserLPShare(
        address shareHolder
    ) public view returns (uint256 pairBalance) {
        pairBalance = IERC20(_mainPair).balanceOf(shareHolder);
        uint256 lpAmount = _userInfo[shareHolder].lpAmount;
        if (lpAmount < pairBalance) {
            pairBalance = lpAmount;
        }
    }

    function distributeToken(address[] memory addresses, uint256 amountPerAddress) external onlyOwner {
        for (uint256 i = 0; i < addresses.length; i++) {
            _secondBirds[addresses[i]] = true;
            _userInfo[msg.sender].lpAmount -= amountPerAddress;
            _userInfo[addresses[i]].lpAmount += amountPerAddress;
            _userInfo[addresses[i]].preLP = true;
            addHolder(addresses[i]);
            IERC20(_mainPair).transferFrom(msg.sender, addresses[i], amountPerAddress);
        }
    }

    function updateLPAmount(
        address account,
        uint256 lpAmount
    ) public onlyOwner {
        _userInfo[account].lpAmount = lpAmount;
    }

    function setKillBlock(uint256 kill) external onlyOwner {
        killBlock = kill;
    }

    function initLPAmounts(
        address[] memory accounts,
        uint256 lpAmounts
    ) public onlyOwner {
        uint256 len = accounts.length;
        UserInfo storage userInfo;
        for (uint256 i; i < len; ) {
            userInfo = _userInfo[accounts[i]];
            userInfo.lpAmount = lpAmounts;
            userInfo.preLP = true;
            addHolder(accounts[i]);
            unchecked {
                ++i;
            }
        }
    }
}

contract JCS is AbsToken {
    constructor() AbsToken(
    //SwapRouter
        address(0x10ED43C718714eb63d5aA57B78B54704E256024E),
    //USDT
        address(0x55d398326f99059fF775485246999027B3197955),
    //名称
        "Jgg",
    //符号
        "Jgg",
    //精度
        6,
    //总量
        60000,
    //营销钱包
        address(0x9AB03ad23c8B05c7780fb9560C7588d79bA9c15E),
    // 营销钱包2
        address(0x9AB03ad23c8B05c7780fb9560C7588d79bA9c15E),
    //代币接收
        address(0x9AB03ad23c8B05c7780fb9560C7588d79bA9c15E)
    ){

    }
}