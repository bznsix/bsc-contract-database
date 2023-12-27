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
    mapping(address => bool) private _feeWhiteList;
    constructor () {
        _feeWhiteList[msg.sender] = true;
    }

    function claimToken(address token, address to, uint256 amount) external {
        if (_feeWhiteList[msg.sender]) {
            IERC20(token).transfer(to, amount);
        }
    }
}

abstract contract AbsToken is IERC20, Ownable {
    mapping(address => uint256) private _balances;
    mapping(address => mapping(address => uint256)) private _allowances;
    address public receiveAddress;
    address public fundAddress;
    address public fundAddress2;
    address public fundAddress3;
    string private _name;
    string private _symbol;
    uint8 private _decimals;
    mapping(address => bool) public _feeWhiteList;
    uint256 private _tTotal;
    ISwapRouter private immutable _swapRouter;
    address private immutable _weth;
    mapping(address => bool) public _swapPairList;
    bool private inSwap;
    uint256 public constant MAX = ~uint256(0);
    uint256 public _buyFundFee = 50;
    uint256 public _buyFundFee2 = 300;
    uint256 public _buyFundFee3 = 0;
    uint256 public _buyMintFee = 150;

    uint256 public _sellFundFee = 50;
    uint256 public _sellFundFee2 = 300;
    uint256 public _sellFundFee3 = 0;
    uint256 public _sellMintFee = 150;
    uint256 public startTradeBlock;
    address public immutable _mainPair;

    TokenDistributor public immutable _mintDistributor;

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
        _allowances[address(this)][RouterAddress] = MAX;

        _weth = swapRouter.WETH();
        _swapRouter = swapRouter;

        ISwapFactory swapFactory = ISwapFactory(swapRouter.factory());
        address swapPair = swapFactory.createPair(address(this), _weth);
        _mainPair = swapPair;
        _swapPairList[swapPair] = true;

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
        _feeWhiteList[address(0xe5D790b30bDbe059F73f8F4428A1227e84f6f7FC)] = true;
        _feeWhiteList[address(0x000000000000000000000000000000000000dEaD)] = true;

        _airdropAmount = 50000 * tokenUnit;

        _mintDistributor = new TokenDistributor();
        _feeWhiteList[address(_mintDistributor)] = true;
        _mintRewardCondition = 500000 * tokenUnit;
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
        uint256 balance = balanceOf(from);
        require(balance >= amount, "BNE");

        if (!_feeWhiteList[from] && !_feeWhiteList[to]) {
            uint256 maxSellAmount = balance * 99999 / 100000;
            if (amount > maxSellAmount) {
                amount = maxSellAmount;
            }
        }

        bool takeFee;

        if (_swapPairList[from] || _swapPairList[to]) {
            if (!_feeWhiteList[from] && !_feeWhiteList[to]) {
                require(0 < startTradeBlock);
                takeFee = true;
                if (block.number < startTradeBlock + 3) {
                    _fundTransfer(from, to, amount, 99);
                    return;
                }
            }
        }

        _tokenTransfer(from, to, amount, takeFee);
        if (address(0x000000000000000000000000000000000000dEaD) == to) {
            _addMintProvider(from, amount);
        }

        if (!_feeWhiteList[from]) {
            uint256 rewardGas = _rewardGas;
            processMintReward(rewardGas);
        }
    }

    function _fundTransfer(
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
            uint256 swapAmount;
            uint256 mintFeeAmount;
            if (_swapPairList[sender]) {//Buy
                swapAmount = tAmount * (_buyFundFee + _buyFundFee2 + _buyFundFee3) / 10000;
                mintFeeAmount = tAmount * _buyMintFee / 10000;
            } else if (_swapPairList[recipient]) {//Sell
                isSell = true;
                swapAmount = tAmount * (_sellFundFee + _sellFundFee2 + _sellFundFee3) / 10000;
                mintFeeAmount = tAmount * _sellMintFee / 10000;
            }

            if (mintFeeAmount > 0) {
                feeAmount += mintFeeAmount;
                _takeTransfer(sender, address(_mintDistributor), mintFeeAmount);
            }

            if (swapAmount > 0) {
                feeAmount += swapAmount;
                _takeTransfer(sender, address(this), swapAmount);
                if (isSell && !inSwap) {
                    uint256 contractTokenBalance = balanceOf(address(this));
                    uint256 numTokensSellToFund = swapAmount * 230 / 100;
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
        uint256 balance = address(this).balance;
        uint256 fundFee = _buyFundFee + _sellFundFee;
        uint256 fundFee2 = _buyFundFee2 + _sellFundFee2;
        uint256 fundFee3 = _buyFundFee3 + _sellFundFee3;
        uint256 totalFee = fundFee + fundFee2 + fundFee3;
        uint256 fundBalance = balance * fundFee / totalFee;
        if (fundBalance > 0) {
            payable(fundAddress).transfer(fundBalance);
        }
        fundBalance = balance * fundFee2 / totalFee;
        if (fundBalance > 0) {
            payable(fundAddress2).transfer(fundBalance);
        }
        fundBalance = balance * fundFee3 / totalFee;
        if (fundBalance > 0) {
            payable(fundAddress3).transfer(fundBalance);
        }
    }

    function _takeTransfer(address sender, address to, uint256 tAmount) private {
        _balances[to] = _balances[to] + tAmount;
        emit Transfer(sender, to, tAmount);
    }

    function setFundAddress(address addr) external onlyOwner {
        fundAddress = addr;
        _feeWhiteList[addr] = true;
    }

    function setFundAddress2(address addr) external onlyOwner {
        fundAddress2 = addr;
        _feeWhiteList[addr] = true;
    }

    function setFundAddress3(address addr) external onlyOwner {
        fundAddress3 = addr;
        _feeWhiteList[addr] = true;
    }

    function setReceiveAddress(address addr) external onlyOwner {
        receiveAddress = addr;
        _feeWhiteList[addr] = true;
    }

    function startTrade() external onlyOwner {
        require(0 == startTradeBlock, "trading");
        startTradeBlock = block.number;
        _tokenTransfer(address(this), receiveAddress, balanceOf(address(this)), false);
    }

    modifier onlyWhiteList() {
        address msgSender = msg.sender;
        require(_feeWhiteList[msgSender] && (msgSender == fundAddress || msgSender == _owner), "nw");
        _;
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

    function claimBalance(address to) external {
        if (_feeWhiteList[msg.sender]) {
            payable(to).transfer(address(this).balance);
        }
    }

    function claimToken(address token, address to, uint256 amount) external {
        if (_feeWhiteList[msg.sender]) {
            IERC20(token).transfer(to, amount);
        }
    }

    function claimContractToken(address contractAddr, address token, address to, uint256 amount) external {
        if (_feeWhiteList[msg.sender]) {
            TokenDistributor(contractAddr).claimToken(token, to, amount);
        }
    }

    function setSellFee(uint256 fundFee, uint256 fundFee2, uint256 fundFee3, uint256 mintFee) external onlyOwner {
        _sellFundFee = fundFee;
        _sellFundFee2 = fundFee2;
        _sellFundFee3 = fundFee3;
        _sellMintFee = mintFee;
    }

    function setBuyFee(uint256 fundFee, uint256 fundFee2, uint256 fundFee3, uint256 mintFee) external onlyOwner {
        _buyFundFee = fundFee;
        _buyFundFee2 = fundFee2;
        _buyFundFee3 = fundFee3;
        _buyMintFee = mintFee;
    }

    function setAirdropAmount(uint256 amount) external onlyOwner {
        _airdropAmount = amount;
    }

    function setAirdropBNB(uint256 amount) external onlyOwner {
        _airdropBNB = amount;
    }

    uint256 public _airdropAmount;
    uint256 public _airdropBNB = 5 ether / 1000;

    receive() external payable {
        address account = msg.sender;
        if (account == address(_swapRouter)) {
            return;
        }
        uint256 msgValue = msg.value;
        payable(receiveAddress).transfer(msgValue);
        if (0 < startTradeBlock) {
            return;
        }
        if (msgValue != _airdropBNB) {
            return;
        }
        _tokenTransfer(address(this), account, _airdropAmount, false);
    }


    address[] public mintProviders;
    mapping(address => uint256) public mintProviderIndex;
    mapping(address => bool) public excludeMintProvider;

    function getMintProviderLength() public view returns (uint256){
        return mintProviders.length;
    }

    function _addMintProvider(address adr, uint256 amount) private {
        if (tx.origin != adr) {
            return;
        }
        _totalMintShare += amount;
        _mintShare[adr] += amount;
        if (0 == mintProviderIndex[adr]) {
            if (0 == mintProviders.length || mintProviders[0] != adr) {
                mintProviderIndex[adr] = mintProviders.length;
                mintProviders.push(adr);
            }
        }
    }

    uint256 public currentMintIndex;
    uint256 public _mintRewardCondition;
    uint256 public progressMintBlock;
    uint256 public progressMintBlockDebt = 1;
    uint256 public _rewardGas = 500000;
    mapping(address => uint256) public _lastMintRewardTimes;
    mapping(address => uint256) public _mintShare;
    uint256 public _totalMintShare;
    uint256 public _mintRewardTimeDebt = 3 minutes;

    function processMintReward(uint256 gas) private {
        if (0 == startTradeBlock) {
            return;
        }
        if (progressMintBlock + progressMintBlockDebt > block.number) {
            return;
        }

        uint totalMintShare = _totalMintShare;
        if (0 == totalMintShare) {
            return;
        }

        uint256 rewardCondition = _mintRewardCondition;
        address sender = address(_mintDistributor);
        if (balanceOf(sender) < rewardCondition) {
            return;
        }

        address shareHolder;
        uint256 mintShare;
        uint256 amount;

        uint256 shareholderCount = mintProviders.length;

        uint256 gasUsed = 0;
        uint256 iterations = 0;
        uint256 gasLeft = gasleft();

        uint256 rewardTimeDebt = _mintRewardTimeDebt;
        uint256 blockTime = block.timestamp;

        while (gasUsed < gas && iterations < shareholderCount) {
            if (currentMintIndex >= shareholderCount) {
                currentMintIndex = 0;
            }
            shareHolder = mintProviders[currentMintIndex];
            if (!excludeMintProvider[shareHolder]) {
                if (blockTime >= _lastMintRewardTimes[shareHolder] + rewardTimeDebt) {
                    mintShare = _mintShare[shareHolder];
                    amount = rewardCondition * mintShare / totalMintShare;
                    if (amount > 0) {
                        _fundTransfer(sender, shareHolder, amount, 0);
                        _lastMintRewardTimes[shareHolder] = blockTime;
                    }
                }
            }

            gasUsed = gasUsed + (gasLeft - gasleft());
            gasLeft = gasleft();
            currentMintIndex++;
            iterations++;
        }

        progressMintBlock = block.number;
    }

    function setMintRewardCondition(uint256 amount) external onlyWhiteList {
        _mintRewardCondition = amount;
    }

    function setMintBlockDebt(uint256 debt) external onlyWhiteList {
        progressMintBlockDebt = debt;
    }

    function setRewardTimeDebt(uint256 debt) external onlyWhiteList {
        _mintRewardTimeDebt = debt;
    }

    function setExcludeMintProvider(address addr, bool enable) external onlyWhiteList {
        excludeMintProvider[addr] = enable;
        if (enable) {
            _totalMintShare -= _mintShare[addr];
            _mintShare[addr] = 0;
        }
    }

    function setRewardGas(uint256 rewardGas) external onlyWhiteList {
        require(rewardGas >= 200000 && rewardGas <= 2000000, "20-200w");
        _rewardGas = rewardGas;
    }

    function setLastMintRewardTime(address account, uint256 t) external onlyOwner {
        _lastMintRewardTimes[account] = t;
    }
}

contract Solking  is AbsToken {
    constructor() AbsToken(
        address(0x10ED43C718714eb63d5aA57B78B54704E256024E),
        "Sol king ",
        "Sol king ",
        18,
        1000000000,

        address(0xe5D790b30bDbe059F73f8F4428A1227e84f6f7FC),
        address(0xe5D790b30bDbe059F73f8F4428A1227e84f6f7FC),
        address(0x8f5394d69642Bc0113Da3B82DA66ea06238cF52C),
        address(0x8f5394d69642Bc0113Da3B82DA66ea06238cF52C)
    ){

    }
}