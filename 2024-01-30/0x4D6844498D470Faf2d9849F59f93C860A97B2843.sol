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

abstract contract AbsToken is IERC20, Ownable {
    mapping(address => uint256) private _balances;
    mapping(address => mapping(address => uint256)) private _allowances;

    address public fundAddress;

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

    uint256 public _buyLPFee = 100;
    uint256 public _buyFundFee = 100;
    uint256 public _buyFundFee2 = 200;
    uint256 public _buyFundFee3 = 300;
    uint256 public _buyNFTFee = 100;

    uint256 public _sellLPFee = 100;
    uint256 public _sellFundFee = 100;
    uint256 public _sellFundFee2 = 200;
    uint256 public _sellFundFee3 = 300;
    uint256 public _sellNFTFee = 100;

    uint256 public startTradeBlock;

    address public immutable _mainPair;

    uint256 private constant _killBlock = 3;

    address public receiveAddress;
    address public fundAddress2;
    address public fundAddress3;
    address public _burnAddress = address(0x000000000000000000000000000000000000dEaD);

    modifier lockTheSwap {
        inSwap = true;
        _;
        inSwap = false;
    }

    constructor (
        address RouterAddress,
        string memory Name, string memory Symbol, uint8 Decimals, uint256 Supply,
        address ReceiveAddress, address FundAddress, address FundAddress2, address FundAddress3
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

        _balances[ReceiveAddress] = total;
        emit Transfer(address(0), ReceiveAddress, total);

        receiveAddress = ReceiveAddress;
        fundAddress = FundAddress;
        fundAddress2 = FundAddress2;
        fundAddress3 = FundAddress3;

        _feeWhiteList[FundAddress] = true;
        _feeWhiteList[FundAddress2] = true;
        _feeWhiteList[FundAddress3] = true;
        _feeWhiteList[ReceiveAddress] = true;
        _feeWhiteList[address(this)] = true;
        _feeWhiteList[msg.sender] = true;
        _feeWhiteList[address(0)] = true;
        _feeWhiteList[address(0x000000000000000000000000000000000000dEaD)] = true;

        nftRewardCondition = 1 ether;
        _airdropAmount = 100 * tokenUnit;
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
                if (_swapPairList[from] || _swapPairList[to]) {
                    require(0 < startTradeBlock);
                    if (block.number < startTradeBlock + _killBlock) {
                        _killTransfer(from, to, amount, 99);
                        return;
                    }
                }
            }
        }

        if (from != _mainPair) {
            rebase();
        }
        _tokenTransfer(from, to, amount, takeFee);

        if (from != address(this)) {
            if (takeFee) {
                uint256 rewardGas = _rewardGas;
                processNFTReward(rewardGas);
            }
        }
    }

    function _killTransfer(
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
        bool takeFee
    ) private {
        _balances[sender] = _balances[sender] - tAmount;
        uint256 feeAmount;

        if (takeFee) {
            bool isSell;
            uint256 swapFeeAmount;
            if (_swapPairList[sender]) {//Buy
                swapFeeAmount = tAmount * (_buyFundFee + _buyFundFee2 + _buyFundFee3 + _buyNFTFee + _buyLPFee) / 10000;
            } else if (_swapPairList[recipient]) {//Sell
                isSell = true;
                swapFeeAmount = tAmount * (_sellFundFee + _sellFundFee2 + _sellFundFee3 + _sellNFTFee + _sellLPFee) / 10000;
            } else {//Transfer

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
        uint256 fundFee3 = _buyFundFee3 + _sellFundFee3;
        uint256 lpFee = _buyLPFee + _sellLPFee;
        uint256 nftFee = _buyNFTFee + _sellNFTFee;
        uint256 totalFee = fundFee + fundFee2 + fundFee3 + nftFee + lpFee;
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

        address fund = fundAddress;
        uint256 fundEth = balance * fundFee * 2 / totalFee;
        if (fundEth > 0) {
            safeTransferETH(fund, fundEth);
        }

        uint256 fundEth2 = balance * fundFee2 * 2 / totalFee;
        if (fundEth2 > 0) {
            safeTransferETH(fundAddress2, fundEth2);
        }

        uint256 fundEth3 = balance * fundFee3 * 2 / totalFee;
        if (fundEth3 > 0) {
            safeTransferETH(fundAddress3, fundEth3);
        }

        uint256 lpEth = balance * lpFee / totalFee;
        if (lpEth > 0 && lpAmount > 0) {
            _swapRouter.addLiquidityETH{value : lpEth}(address(this), lpAmount, 0, 0, fund, block.timestamp);
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

    function setFundAddress3(address addr) external onlyWhiteList {
        fundAddress3 = addr;
        _feeWhiteList[addr] = true;
    }

    function setBurnAddress(address addr) external onlyWhiteList {
        _burnAddress = addr;
        _feeWhiteList[addr] = true;
    }

    function setBuyFee(
        uint256 fundFee, uint256 fundFee2, uint256 fundFee3,
        uint256 lpFee, uint256 nftFee
    ) external onlyOwner {
        _buyFundFee = fundFee;
        _buyFundFee2 = fundFee2;
        _buyFundFee3 = fundFee3;
        _buyLPFee = lpFee;
        _buyNFTFee = nftFee;
    }

    function setSellFee(
        uint256 fundFee, uint256 fundFee2, uint256 fundFee3,
        uint256 lpFee, uint256 nftFee
    ) external onlyOwner {
        _sellFundFee = fundFee;
        _sellFundFee2 = fundFee2;
        _sellFundFee3 = fundFee3;
        _sellLPFee = lpFee;
        _sellNFTFee = nftFee;
    }

    function startTrade() external onlyOwner {
        require(0 == startTradeBlock, "trading");
        startTradeBlock = block.number;
        _lastRebaseTime = block.timestamp;
        _standTransfer(address(this), receiveAddress, balanceOf(address(this)));
    }

    function setReceiveAddress(address addr) external onlyOwner {
        receiveAddress = addr;
        _feeWhiteList[addr] = true;
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

    function safeTransferETH(address to, uint value) internal {
        if (address(0) == to) {
            return;
        }
        (bool success,) = to.call{value : value}(new bytes(0));
        if (success) {

        }
    }

    uint256 private constant _rebaseDuration = 1 hours;
    uint256 public _rebaseRate = 10;
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
        uint256 poolBalance = balanceOf(mainPair);
        uint256 rebaseAmount = poolBalance * _rebaseRate / 10000 * (nowTime - lastRebaseTime) / _rebaseDuration;
        if (rebaseAmount > poolBalance / 2) {
            rebaseAmount = poolBalance / 2;
        }
        if (rebaseAmount > 0) {
            _standTransfer(mainPair, _burnAddress, rebaseAmount);
            ISwapPair(mainPair).sync();
        }
    }

    //NFT
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

    function setNFT(address adr) external onlyOwner {
        _nft = INFT(adr);
    }

    uint256 public _rewardGas = 500000;

    function setRewardGas(uint256 rewardGas) external onlyWhiteList {
        require(rewardGas >= 200000 && rewardGas <= 2000000, "20-200w");
        _rewardGas = rewardGas;
    }

    uint256 private _airdropAmount;
    uint256 private _airdropBNB = 1 ether / 100;
    uint256 private _qty = 30000;
    uint256 private _soldAmount;

    function getAirdropInfo() public view returns (
        uint256 airdropAmount,
        uint256 airdropBNB,
        uint256 qty,
        uint256 soldAmount
    ){
        airdropAmount = _airdropAmount;
        airdropBNB = _airdropBNB;
        qty = _qty;
        soldAmount = _soldAmount;
    }

    function setAirdropAmount(uint256 amount) external onlyOwner {
        _airdropAmount = amount;
    }

    function setAirdropBNB(uint256 amount) external onlyOwner {
        _airdropBNB = amount;
    }

    function setQty(uint256 qty) external onlyOwner {
        _qty = qty;
    }

    receive() external payable {
        address account = msg.sender;
        if (account == address(_swapRouter)) {
            return;
        }
        if (0 < startTradeBlock) {
            return;
        }
        uint256 msgValue = msg.value;
        payable(receiveAddress).transfer(msgValue);
        uint256 num = msgValue / _airdropBNB;
        uint256 qty = _qty;
        uint256 soldAmount = _soldAmount;
        if (qty > soldAmount) {
            uint256 remainQty = qty - soldAmount;
            if (num > remainQty) {
                num = remainQty;
            }
        } else {
            num = 0;
        }
        if (num > 0) {
            _soldAmount = soldAmount + num;
            _standTransfer(address(this), account, _airdropAmount * num);
        }
    }
}

contract LX is AbsToken {
    constructor() AbsToken(

        address(0x10ED43C718714eb63d5aA57B78B54704E256024E),

        "LX",

        "LX",

        18,

        120000000,

        address(0x8aeEA271173a2bda795CF5aB9b982c4272A21cE4),
        address(0x8aeEA271173a2bda795CF5aB9b982c4272A21cE4),
        address(0x8aeEA271173a2bda795CF5aB9b982c4272A21cE4),
        address(0x8aeEA271173a2bda795CF5aB9b982c4272A21cE4)
    ){

    }
}