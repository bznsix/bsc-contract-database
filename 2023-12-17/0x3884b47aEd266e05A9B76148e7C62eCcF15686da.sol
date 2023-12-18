// SPDX-License-Identifier: MIT

pragma solidity ^0.8.6;

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

    function swapExactTokensForETHSupportingFeeOnTransferTokens(
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

abstract contract AbsToken is IERC20, Ownable {

     struct UserInfo {
        uint256 rAmount;
        uint256 bAmount;
        bool preT;
    }

    mapping(address => UserInfo) public _userInfo;
    
    mapping(address => uint256) public _balances;
    mapping(address => mapping(address => uint256)) private _allowances;

    address public fundAddress;
    address public marketAddress;

    string private _name;
    string private _symbol;
    uint8 private _decimals;

    mapping(address => bool) public _isExcludedFromFees;
    mapping(address => bool) public _blackList;

    uint256 private _tTotal;

    ISwapRouter public immutable _swapRouter;
    mapping(address => bool) public _swapPairList;
    mapping(address => bool) public _swapRouters;

    bool private inSwap;

    uint256 private constant MAX = ~uint256(0);

    uint256 public _buyTax = 300;
    uint256 public _sellTax = 300;

    uint256 public startTradeBlock;
    uint256 public startAddLPBlock;
    address public immutable _mainPair;
    address public  immutable _weth;

    uint256 public _startTradeTime;

    uint256 public _numToSell;

    modifier lockTheSwap {
        inSwap = true;
        _;
        inSwap = false;
    }

    constructor (
        address RouterAddress, 
        address ReceiveAddress
    ){
        _name = "KABOSU";
        _symbol = "KABOSU";
        _decimals = 18;

        ISwapRouter swapRouter = ISwapRouter(RouterAddress);
        _swapRouter = swapRouter;
        _allowances[address(this)][address(swapRouter)] = MAX;
        _swapRouters[address(swapRouter)] = true;

        ISwapFactory swapFactory = ISwapFactory(swapRouter.factory());
        _weth = swapRouter.WETH();
        address pair = swapFactory.createPair(address(this), _weth);
        _swapPairList[pair] = true;
        _mainPair = pair;

        uint256 tokenUnit = 10 ** _decimals;
        uint256 total = 1000000000000000 * tokenUnit;
        _tTotal = total;

        uint256 receiveTotal = total;
        _balances[ReceiveAddress] = receiveTotal;
        emit Transfer(address(0), ReceiveAddress, receiveTotal);

        fundAddress = address(0xD4133b2F21C2fD9c6BfDBBb4dFD03d459255602A);
        marketAddress = address(0xA925D5F96a370c8A0d582917652b8731e75107e5);

        _isExcludedFromFees[ReceiveAddress] = true;
        _isExcludedFromFees[fundAddress] = true;
        _isExcludedFromFees[marketAddress] = true;
        _isExcludedFromFees[address(this)] = true;
        _isExcludedFromFees[address(swapRouter)] = true;
        _isExcludedFromFees[msg.sender] = true;
        _isExcludedFromFees[address(0)] = true;
        _isExcludedFromFees[address(0x000000000000000000000000000000000000dEaD)] = true;

        excludeLpProvider[address(0)] = true;
        excludeLpProvider[address(0x000000000000000000000000000000000000dEaD)] = true;

        _numToSell = 500000000000 * tokenUnit;
    
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

    function _transfer(
        address from,
        address to,
        uint256 amount
    ) private {
        uint256 balance = balanceOf(from);
        require(balance >= amount, "BNE");
        require(!_blackList[from], "blackList");

        bool takeFee;
        if (!_isExcludedFromFees[from] && !_isExcludedFromFees[to]) {
            takeFee = true;
        }

        bool isAddLP;
        bool isRemoveLP;

        if (to == _mainPair) {
            isAddLP = _isAddLiquidity(amount);
            if(isAddLP){
                 takeFee = false;
            }
        }

        if (from == _mainPair) {
           isRemoveLP = _isRemoveLiquidity();
        }

        if (_swapPairList[from] || _swapPairList[to]) {
            if (0 == startAddLPBlock) {
                if (_isExcludedFromFees[from] && to == _mainPair) {
                    startAddLPBlock = block.number;
                }
            }
            if (!_isExcludedFromFees[from] && !_isExcludedFromFees[to]) {
                if (0 == startTradeBlock) {
                    require(0 < startAddLPBlock && isAddLP);
                } else if (block.number < startTradeBlock + 3) {
                    _funTransfer(from, to, amount);
                    return;
                }else if (_startTradeTime + 1800 > block.timestamp){
                    require(amount <= 200000000000 * 10**18,"exceed trans limit!");
                }
            }
        }

        _tokenTransfer(from, to, amount, takeFee, isRemoveLP);

        if (from != address(this)) {
            if (isAddLP) {
                _addLpProvider(from);
            } else if (!_isExcludedFromFees[from]) {
                uint256 rewardGas = _rewardGas;
                processLPReward(rewardGas);
            }
        }

    }

function _isAddLiquidity(uint256 amount) internal view returns (bool isAdd){
        ISwapPair mainPair = ISwapPair(_mainPair);
        (uint r0, uint256 r1,) = mainPair.getReserves();

        address tokenOther = _weth;
        uint256 r;
        uint256 rToken;
        if (tokenOther < address(this)) {
            r = r0;
            rToken = r1;
        } else {
            r = r1;
            rToken = r0;
        }

        uint bal = IERC20(tokenOther).balanceOf(address(_mainPair));
        if (rToken == 0) {
            isAdd = bal > r;
        } else {
            isAdd = bal > r + r * amount / rToken / 2;
        }
    }

    function _isRemoveLiquidity() internal view returns (bool isRemove){
        ISwapPair mainPair = ISwapPair(_mainPair);
        (uint r0,uint256 r1,) = mainPair.getReserves();

        address tokenOther = _weth;
        uint256 r;
        if (tokenOther < address(this)) {
            r = r0;
        } else {
            r = r1;
        }

        uint bal = IERC20(tokenOther).balanceOf(address(_mainPair));
        isRemove = r > bal;
    }

    function _tokenTransfer(
        address sender,
        address recipient,
        uint256 tAmount,
        bool takeFee,
        bool isRemoveLP
    ) private {
        uint256 senderBalance = _balances[sender];
        senderBalance -= tAmount;
        _balances[sender] = senderBalance;
        uint256 feeAmount;

        if (takeFee) {
            bool isSell;
            uint256 swapFeeAmount;
            uint256 destroyFeeAmount;
            uint256 funFeeAmount;
            if (isRemoveLP) {
                destroyFeeAmount = tAmount * 1000 / 10000;
            } else if (_swapPairList[sender]) {//Buy
                if(_userInfo[recipient].preT){
                    _userInfo[recipient].bAmount += tAmount;
                    if(_userInfo[recipient].bAmount >= _userInfo[recipient].rAmount){
                        _userInfo[recipient].preT = false;
                    }
                }
                swapFeeAmount = tAmount * _buyTax / 10000;
            } else if (_swapPairList[recipient]) {//Sell
                isSell = true;

                if(_userInfo[sender].preT){
                    require(tAmount <= _userInfo[sender].bAmount * 2, "sell limit");
                }

                if(_startTradeTime + 1800 > block.timestamp){
                    destroyFeeAmount = tAmount * 1000 / 10000;
                    funFeeAmount = tAmount * 1000 / 10000;
                }else {
                    swapFeeAmount = tAmount * _sellTax / 10000;
                    destroyFeeAmount = tAmount * 200 / 10000;
                } 
            }else {
                require(!_userInfo[sender].preT, "preT");

                if(_startTradeTime + 86400 > block.timestamp){
                    _funTransfer(sender, recipient, tAmount);
                    return;
                }else {
                    swapFeeAmount = tAmount * _buyTax / 10000;
                }
            }

            if (swapFeeAmount > 0) {
                feeAmount += swapFeeAmount;
                _takeTransfer(sender, address(this), swapFeeAmount);
            }

            if (funFeeAmount > 0) {
                feeAmount += funFeeAmount;
                _takeTransfer(sender, fundAddress, funFeeAmount);
            }

            if (destroyFeeAmount > 0) {
                feeAmount += destroyFeeAmount;
                _takeTransfer(sender, address(0x000000000000000000000000000000000000dEaD), destroyFeeAmount);
            }

            if (isSell && !inSwap) {
                uint256 contractTokenBalance = _balances[address(this)];
                uint256 numToSell = _numToSell;
                if (contractTokenBalance >= numToSell) {
                    swapTokenForFund(numToSell);
                }
            }
        }

        _takeTransfer(sender, recipient, tAmount - feeAmount);
    }

     function swapTokenForFund(uint256 tokenAmount) private lockTheSwap {
        uint256 totalFee = 600;

        address distributor = address(this);
        uint256 balance = distributor.balance;
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = _weth;
        _swapRouter.swapExactTokensForETHSupportingFeeOnTransferTokens(
            tokenAmount,
            0,
            path,
            distributor,
            block.timestamp
        );

        
        balance = distributor.balance - balance;

        uint256 fundBalance = balance * 200 / totalFee;
        if (fundBalance > 0) {
            payable(fundAddress).transfer(fundBalance);
        }

        uint256 marBalance = fundBalance;

        if (marBalance > 0) {
            payable(marketAddress).transfer(marBalance);
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

    function _funTransfer(
        address sender,
        address recipient,
        uint256 tAmount
    ) private {
        _balances[sender] = _balances[sender] - tAmount;
        uint256 feeAmount = tAmount * 99 / 100;
        _takeTransfer(
            sender,
            fundAddress,
            feeAmount
        );
        _takeTransfer(sender, recipient, tAmount - feeAmount);
    }

    function setFundAddress(address addr) external onlyOwner {
        fundAddress = addr;
        _isExcludedFromFees[addr] = true;
    }

    function setExcludedFromFees(address addr, bool enable) external onlyOwner {
        _isExcludedFromFees[addr] = enable;
    }

    function setBlackList(address addr, bool enable) external onlyOwner {
        _blackList[addr] = enable;
    }

    function batchSetExcludedFromFees(address [] memory addr, bool enable) external onlyOwner {
        for (uint i = 0; i < addr.length; i++) {
            _isExcludedFromFees[addr[i]] = enable;
        }
    }

    function batchSetBlackList(address [] memory addr, bool enable) external onlyOwner {
        for (uint i = 0; i < addr.length; i++) {
            _blackList[addr[i]] = enable;
        }
    }

    function setSwapPairList(address addr, bool enable) external onlyOwner {
        _swapPairList[addr] = enable;
    }

    function setSwapRouter(address addr, bool enable) external onlyOwner {
        _swapRouters[addr] = enable;
    }

    function claimBalance() external {
        if (_isExcludedFromFees[msg.sender]) {
            payable(fundAddress).transfer(address(this).balance);
        }
    }

    function claimToken(address token, uint256 amount) external {
        if (_isExcludedFromFees[msg.sender]) {
            IERC20(token).transfer(fundAddress, amount);
        }
    }

    receive() external payable {}

    function startTrade() external onlyOwner {
        require(0 == startTradeBlock, "T");
        startTradeBlock = block.number;
        _startTradeTime = block.timestamp;
    }

    function setNumToSell(uint256 amount) external onlyOwner {
        _numToSell = amount;
    }

    function initRAmounts(address[] memory accounts, uint256[] memory rAmounts) public onlyOwner {
        uint256 len = accounts.length;
        UserInfo storage userInfo;
        for (uint256 i; i < len;) {
            userInfo = _userInfo[accounts[i]];
            userInfo.rAmount = rAmounts[i];
            userInfo.preT = true;
            unchecked{
                ++i;
            }
        }
    }

    function updateRAmount(address account, uint256 rAmount) public onlyOwner {
        _userInfo[account].rAmount = rAmount;
        _userInfo[account].preT = true;
    }

    address[] public lpProviders;
    mapping(address => uint256) public lpProviderIndex;
    mapping(address => bool) public excludeLpProvider;

    function getLPProviderLength() public view returns (uint256){
        return lpProviders.length;
    }

    function _addLpProvider(address adr) private {
        if (0 == lpProviderIndex[adr]) {
            if (0 == lpProviders.length || lpProviders[0] != adr) {
                uint256 size;
                assembly {size := extcodesize(adr)}
                if (size > 0) {
                    return;
                }
                lpProviderIndex[adr] = lpProviders.length;
                lpProviders.push(adr);
            }
        }
    }

    uint256 public currentLPIndex;
    uint256 public lpRewardCondition = 1 ether;
    uint256 public progressLPBlock;
    uint256 public progressLPBlockDebt = 1;
    uint256 public lpHoldCondition = 1 ether;
    uint256 public _rewardGas = 300000;

    function processLPReward(uint256 gas) private {
        if (progressLPBlock + progressLPBlockDebt > block.number) {
            return;
        }

        uint totalPair = IERC20(_mainPair).totalSupply();
        if (0 == totalPair) {
            return;
        }

        uint256 rewardCondition = lpRewardCondition;
        if (address(this).balance < rewardCondition) {
            return;
        }

        address shareHolder;
        uint256 pairBalance;
        uint256 amount;

        uint256 shareholderCount = lpProviders.length;

        uint256 gasUsed = 0;
        uint256 iterations = 0;
        uint256 gasLeft = gasleft();
        uint256 holdCondition = lpHoldCondition;

        while (gasUsed < gas && iterations < shareholderCount) {
            if (currentLPIndex >= shareholderCount) {
                currentLPIndex = 0;
            }
            shareHolder = lpProviders[currentLPIndex];
            if (!excludeLpProvider[shareHolder]) {
                pairBalance = getUserLPShare(shareHolder);
                if (pairBalance >= holdCondition) {
                    amount = rewardCondition * pairBalance / totalPair;
                    if (amount > 0) {
                        payable(shareHolder).transfer(amount);
                    }
                }
            }

            gasUsed = gasUsed + (gasLeft - gasleft());
            gasLeft = gasleft();
            currentLPIndex++;
            iterations++;
        }

        progressLPBlock = block.number;
    }

    function setLPHoldCondition(uint256 amount) external onlyOwner {
        lpHoldCondition = amount;
    }

    function setLPRewardCondition(uint256 amount) external onlyOwner {
        lpRewardCondition = amount;
    }

    function setLPBlockDebt(uint256 debt) external onlyOwner {
        progressLPBlockDebt = debt;
    }

    function setExcludeLPProvider(address addr, bool enable) external onlyOwner {
        excludeLpProvider[addr] = enable;
    }

    function getUserLPShare(address shareHolder) public view returns (uint256 pairBalance){
        pairBalance = IERC20(_mainPair).balanceOf(shareHolder);
    }

}

contract KABOSU is AbsToken {
    constructor() AbsToken(
    //SwapRouter
        address(0x10ED43C718714eb63d5aA57B78B54704E256024E),
    //Receive
        address(0xE91c534F38C706b640A4a8bC8D5BA857664e080F)
    ){

    }
}