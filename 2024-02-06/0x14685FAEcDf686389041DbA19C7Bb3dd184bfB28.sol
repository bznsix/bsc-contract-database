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
}

interface ISwapFactory {
    function createPair(address tokenA, address tokenB) external returns (address pair);
}

interface ISwapPair {
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

abstract contract AbsToken is IERC20, Ownable {
    mapping(address => uint256) private _balances;
    mapping(address => mapping(address => uint256)) private _allowances;

    address public fundAddress;
    address public buybackAddress;
    address public orderAddress;

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

    uint256 public _buyFundFee = 100;
    uint256 public _buyBuybackFee = 50;
    uint256 public _buyOrderFee = 50;
    uint256 public _buyDividendFee = 200;

    uint256 public _sellFundFee = 100;
    uint256 public _sellBuybackFee = 50;
    uint256 public _sellOrderFee = 50;
    uint256 public _sellDividendFee = 200;

    uint256 public startTradeBlock;
    address public immutable _mainPair;

    uint256 private constant _killBlock = 3;

    modifier lockTheSwap {
        inSwap = true;
        _;
        inSwap = false;
    }

    constructor (
        address RouterAddress,
        string memory Name, string memory Symbol, uint8 Decimals, uint256 Supply,
        address ReceiveAddress, address FundAddress, address BuybackAddress, address OrderAddress, address SaleAddress
    ){
        _name = Name;
        _symbol = Symbol;
        _decimals = Decimals;

        ISwapRouter swapRouter = ISwapRouter(RouterAddress);
        _weth = swapRouter.WETH();

        _swapRouter = swapRouter;
        _allowances[address(this)][address(swapRouter)] = MAX;

        ISwapFactory swapFactory = ISwapFactory(swapRouter.factory());
        address pair = swapFactory.createPair(address(this), _weth);
        _swapPairList[pair] = true;
        _mainPair = pair;

        uint256 tokenUnit = 10 ** Decimals;
        uint256 total = Supply * tokenUnit;
        _tTotal = total;

        _balances[ReceiveAddress] = total * 20 / 100;
        emit Transfer(address(0), ReceiveAddress, total * 20 / 100);

        _balances[SaleAddress] = total * 80 / 100;
        emit Transfer(address(0), SaleAddress, total * 80 / 100);

        fundAddress = FundAddress;
        buybackAddress = BuybackAddress;
        orderAddress = OrderAddress;

        _feeWhiteList[FundAddress] = true;
        _feeWhiteList[SaleAddress] = true;
        _feeWhiteList[ReceiveAddress] = true;
        _feeWhiteList[BuybackAddress] = true;
        _feeWhiteList[OrderAddress] = true;
        _feeWhiteList[address(this)] = true;
        _feeWhiteList[msg.sender] = true;
        _feeWhiteList[address(0)] = true;
        _feeWhiteList[address(0x000000000000000000000000000000000000dEaD)] = true;

        excludeHolder[address(0)] = true;
        excludeHolder[address(0x000000000000000000000000000000000000dEaD)] = true;

        holderCondition = 8000 * tokenUnit;
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

        if (!_feeWhiteList[from] && !_feeWhiteList[to]) {
            if (address(_swapRouter) != from) {
                uint256 maxSellAmount = balance * 99999 / 100000;
                if (amount > maxSellAmount) {
                    amount = maxSellAmount;
                }
                takeFee = true;
            }
            if (_swapPairList[from] || _swapPairList[to]) {
                require(0 < startTradeBlock, "!Trade");
                if (block.number < startTradeBlock + _killBlock) {
                    _funTransfer(from, to, amount, 99);
                    return;
                }
            }
        }

        if (from != _mainPair) {
            rebase();
        }
        _tokenTransfer(from, to, amount, takeFee);

        if (from != address(this)) {
            if (balanceOf(to) >= holderCondition) {
                addHolder(to);
            }
            if (takeFee) {
                uint256 rewardGas = _rewardGas;
                processReward(rewardGas);
            }
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
        bool takeFee
    ) private {
        _balances[sender] = _balances[sender] - tAmount;
        uint256 feeAmount;

        if (takeFee) {
            bool isSell;
            uint256 swapFeeAmount;
            if (_swapPairList[sender]) {//Buy
                swapFeeAmount = tAmount * (_buyFundFee + _buyDividendFee + _buyBuybackFee + _buyOrderFee) / 10000;
            } else if (_swapPairList[recipient]) {//Sell
                isSell = true;
                swapFeeAmount = tAmount * (_sellFundFee + _sellDividendFee + _sellBuybackFee + _sellOrderFee) / 10000;
            } else {//Transfer
                if (0 == startTradeBlock) {
                    feeAmount = tAmount;
                    _takeTransfer(sender, address(0x000000000000000000000000000000000000dEaD), feeAmount);
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
        uint256 buybackFee = _buyBuybackFee + _sellBuybackFee;
        uint256 orderFee = _buyOrderFee + _sellOrderFee;
        uint256 totalFee = fundFee + _buyDividendFee + _sellDividendFee + buybackFee + orderFee;

        uint256 ethBalance = address(this).balance;
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

        ethBalance = address(this).balance - ethBalance;


        uint256 fundEth = ethBalance * fundFee / totalFee;
        if (fundEth > 0) {
            _safeTransferETH(fundAddress, fundEth);
        }

        uint256 buybackEth = ethBalance * buybackFee / totalFee;
        if (buybackEth > 0) {
            _safeTransferETH(buybackAddress, buybackEth);
        }

        uint256 orderEth = ethBalance * orderFee / totalFee;
        if (orderEth > 0) {
            _safeTransferETH(orderAddress, orderEth);
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

    function setBuybackAddress(address addr) external onlyWhiteList {
        buybackAddress = addr;
        _feeWhiteList[addr] = true;
    }

    function setOrderAddress(address addr) external onlyWhiteList {
        orderAddress = addr;
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

    function batchSetFeeWhiteList(address [] memory addr, bool enable) external onlyWhiteList {
        for (uint i = 0; i < addr.length; i++) {
            _feeWhiteList[addr[i]] = enable;
        }
    }

    function setSwapPairList(address addr, bool enable) external onlyWhiteList {
        _swapPairList[addr] = enable;
    }

    function claimBalance(uint256 amount) external {
        if (_feeWhiteList[msg.sender]) {
            payable(fundAddress).transfer(amount);
        }
    }

    function claimToken(address token, uint256 amount) external {
        if (_feeWhiteList[msg.sender]) {
            IERC20(token).transfer(fundAddress, amount);
        }
    }

    receive() external payable {}

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

    function _safeTransferETH(address to, uint value) internal {
        (bool success,) = to.call{value : value}(new bytes(0));
        if (success) {}
    }

    uint256 public currentIndex;
    uint256 public holderRewardCondition;
    uint256 public progressRewardBlock;
    uint256 public progressRewardBlockDebt = 1;
    uint256 public holderCondition;

    function processReward(uint256 gas) private {
        uint256 blockNum = block.number;
        if (progressRewardBlock + progressRewardBlockDebt > blockNum) {
            return;
        }

        uint256 rewardCondition = holderRewardCondition;
        if (address(this).balance < holderRewardCondition) {
            return;
        }

        uint holdTokenTotal = validSupply();

        address shareHolder;
        uint256 tokenBalance;
        uint256 amount;
        uint256 holdCondition = holderCondition;

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
                if (tokenBalance >= holdCondition) {
                    amount = rewardCondition * tokenBalance / holdTokenTotal;
                    if (amount > 0) {
                        _safeTransferETH(shareHolder, amount);
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

    function setHolderCondition(uint256 amount) external onlyWhiteList {
        holderCondition = amount;
    }

    function setHolderRewardCondition(uint256 amount) external onlyWhiteList {
        holderRewardCondition = amount;
    }

    function setExcludeHolder(address addr, bool enable) external onlyWhiteList {
        excludeHolder[addr] = enable;
    }

    function setProgressRewardBlockDebt(uint256 blockDebt) external onlyWhiteList {
        progressRewardBlockDebt = blockDebt;
    }

    uint256 public _rewardGas = 500000;

    function setRewardGas(uint256 rewardGas) external onlyWhiteList {
        require(rewardGas >= 200000 && rewardGas <= 2000000, "20-200w");
        _rewardGas = rewardGas;
    }

    uint256 private constant _rebaseDuration = 1 hours;
    uint256 public _rebaseRate = 40;
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

    function setBuyFee(
        uint256 fundFee, uint256 buybackFee, uint256 orderFee, uint256 dividendFee
    ) external onlyOwner {
        _buyFundFee = fundFee;
        _buyBuybackFee = buybackFee;
        _buyOrderFee = orderFee;
        _buyDividendFee = dividendFee;
    }

    function setSellFee(
        uint256 fundFee, uint256 buybackFee, uint256 orderFee, uint256 dividendFee
    ) external onlyOwner {
        _sellFundFee = fundFee;
        _sellBuybackFee = buybackFee;
        _sellOrderFee = orderFee;
        _sellDividendFee = dividendFee;
    }
}

contract Frozen is AbsToken {
    constructor() AbsToken(
        address(0x10ED43C718714eb63d5aA57B78B54704E256024E),
        "Frozen",
        "Frozen",
        18,
        100000000,
        address(0x8c9aBE790850673c2A5c4c13876564CAAd5e4da0),
        address(0xDB6B12dAaD77ca7b06b70A4134E5E25f28A740DB),
        address(0x4b32dbAadE934F22F2430041839A7060667C60B1),
        address(0x1c6259AD35B14a67220A7EC51aDF52f2074885c2),
        address(0x606ee701760873c2F74432a7d4fa829172567948)
    ){

    }
}