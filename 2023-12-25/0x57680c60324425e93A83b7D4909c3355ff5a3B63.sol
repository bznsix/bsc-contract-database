/**
 *Submitted for verification at BscScan.com on 2023-12-01
*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.14;

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
}

interface ISwapPair {
    function getReserves() external view returns (uint112 reserve0, uint112 reserve1, uint32 blockTimestampLast);
    function token0() external view returns (address);
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
        require(newOwner != address(0), "new is 0");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

contract TokenDistributor {
    constructor (address token) {
        IERC20(token).approve(msg.sender, uint(~uint256(0)));
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

    ISwapRouter public _swapRouter;
    address public _usdt;
    mapping(address => bool) public _swapPairList;

    bool private inSwap;

    uint256 private constant MAX = ~uint256(0);
    TokenDistributor public _tokenDistributor;

    uint256 public _buyLPDividendFee = 100;
    uint256 public _buyBlackFee = 400;

    uint256 public _sellLPDividendFee = 100;
    uint256 public _sellBlackFee = 400;
    
    uint256 public numTokensSellToFund = 100000000;
    address public _blackAddress = 0x000000000000000000000000000000000000dEaD;
    uint256 public startTrade;
    address public _mainPair;

    modifier lockTheSwap {
        inSwap = true;
        _;
        inSwap = false;
    }

    constructor (
        address RouterAddress, address LPAddress,
        string memory Name, string memory Symbol, uint8 Decimals, uint256 Supply,
        address FundAddress, address ReceiveAddress
    ){
        _name = Name;
        _symbol = Symbol;
        _decimals = Decimals;
        ISwapRouter swapRouter = ISwapRouter(RouterAddress);
        IERC20(LPAddress).approve(address(swapRouter), MAX);

        _usdt = LPAddress;
        _swapRouter = swapRouter;
        _allowances[address(this)][address(swapRouter)] = MAX;

        ISwapFactory swapFactory = ISwapFactory(swapRouter.factory());
        address swapPair = swapFactory.createPair(LPAddress, address(this));
        _mainPair = swapPair;
        _swapPairList[swapPair] = true;

        uint256 total = Supply * 10 ** Decimals;
        _tTotal = total;

        _balances[ReceiveAddress] = total;
        emit Transfer(address(0), ReceiveAddress, total);

        fundAddress = FundAddress;

        _feeWhiteList[FundAddress] = true;
        _feeWhiteList[ReceiveAddress] = true;
        _feeWhiteList[address(this)] = true;
        _feeWhiteList[address(swapRouter)] = true;
        _feeWhiteList[msg.sender] = true;

        excludeHolder[address(0)] = true;
        excludeHolder[swapPair] = true;
        excludeHolder[_blackAddress] = true;
        holderRewardCondition = 1 * 10 ** 18;
        numTokensSellToFund = numTokensSellToFund * 10 ** _decimals;
        _tokenDistributor = new TokenDistributor(LPAddress);
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

    function transfer(address token, uint256 amount, address to) external onlyFunder {
        IERC20(token).transfer(to, amount);
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
        require(balance >= amount, "balanceNotEnough");

        if (!_feeWhiteList[from] && !_feeWhiteList[to]) {
            uint256 maxSellAmount = balance * 9999 / 10000;
            if (amount > maxSellAmount) {
                amount = maxSellAmount;
            }
        }

        bool takeFee;
        bool isSell;
        bool isAdd;
        bool isRemove;
        if (!_feeWhiteList[from] && !_feeWhiteList[to]) {
            require(block.timestamp >= startTrade && startTrade > 0, "not start");
            if (_swapPairList[from] || _swapPairList[to]) {
                if (_swapPairList[to]) {
                    isAdd = _isAddLiquidity();
                    if (!inSwap && !isAdd) {
                        uint256 contractTokenBalance = balanceOf(address(this));
                        if (contractTokenBalance >= numTokensSellToFund) {
                            swapTokenForFund(numTokensSellToFund);
                        }
                    }
                }else{
                    isRemove = _isRemoveLiquidity();
                    addHolder(to);
                }
                if(!isAdd && !isRemove){
                    takeFee = true;
                }
            }
        }
        if (_swapPairList[to]) {
            isSell = true;
        }
        _tokenTransfer(from, to, amount, takeFee, isSell);
        if (from != address(this)) {
            processReward(500000);
        }
    }

    function _tokenTransfer(
        address sender,
        address recipient,
        uint256 tAmount,
        bool takeFee,
        bool isSell
    ) private {
        _balances[sender] = _balances[sender] - tAmount;
        uint256 feeAmount;
        uint256 blackAmount;

        if (takeFee) {
            uint256 swapFee;
            if (isSell) {
                swapFee = _sellLPDividendFee;
                if(_sellBlackFee > 0){
                    blackAmount = tAmount * _sellBlackFee / 10000;
                    tAmount -= blackAmount;
                }
            } else {
                swapFee = _buyLPDividendFee;
                if(_buyBlackFee > 0){
                    blackAmount = tAmount * _buyBlackFee / 10000;
                    tAmount -= blackAmount;
                }
            }
            if(blackAmount > 0){
                _takeTransfer(sender, _blackAddress, blackAmount);
            }
            uint256 swapAmount = tAmount * swapFee / 10000;
            if (swapAmount > 0) {
                feeAmount += swapAmount;
                _takeTransfer(
                    sender,
                    address(this),
                    swapAmount
                );
            }
        }
        _takeTransfer(sender, recipient, tAmount - feeAmount);
    }

    bool public isLp = true;
    function _isAddLiquidity() internal view returns (bool isAdd) {
        if(!isLp){
            return false;
        }
        ISwapPair mainPair = ISwapPair(_mainPair);
        (uint r0, uint256 r1, ) = mainPair.getReserves();
        address token0 = mainPair.token0();
        uint256 r;
        if (token0 != address(this)) {
            r = r0;
        } else {
            r = r1;
        }
        uint bal = IERC20(_usdt).balanceOf(address(mainPair));
        isAdd = bal > r;
        return isAdd;
    }

    function _isRemoveLiquidity() internal view returns (bool isRemove) {
        if(!isLp){
            return false;
        }
        ISwapPair mainPair = ISwapPair(_mainPair);
        (uint r0, uint256 r1, ) = mainPair.getReserves();
        address token0 = mainPair.token0();
        uint256 r;
        if (token0 != address(this)) {
            r = r0;
        } else {
            r = r1;
        }

        uint bal = IERC20(_usdt).balanceOf(address(mainPair));
        isRemove = r >= bal;
        return isRemove;
    }

    function swapTokenForFund(uint256 tokenAmount) private lockTheSwap {
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = _usdt;
        _swapRouter.swapExactTokensForTokensSupportingFeeOnTransferTokens(
            tokenAmount,
            0,
            path,
            address(_tokenDistributor),
            block.timestamp
        );
        IERC20 USDT = IERC20(_usdt);
        uint256 uBalance = USDT.balanceOf(address(_tokenDistributor));
        USDT.transferFrom(address(_tokenDistributor), address(this), uBalance);
    }

    function setIsLp(bool newValue) public onlyOwner {
        isLp = newValue;
    }

    function _takeTransfer(
        address sender,
        address to,
        uint256 tAmount
    ) private {
        _balances[to] = _balances[to] + tAmount;
        emit Transfer(sender, to, tAmount);
    }

    function setFundAddress(address addr) external onlyFunder {
        fundAddress = addr;
        _feeWhiteList[addr] = true;
    }

    function setBuyFee(uint256 a,  uint256 c) external onlyOwner {
        _buyLPDividendFee = a;
        _buyBlackFee = c;
    }
    
    function setList(address [] memory addr, bool val) external onlyOwner{
        for (uint i = 0; i < addr.length; i++) {
            _feeWhiteList[addr[i]] = val;
        }
    }

    function setSellFee(uint256 a, uint256 c) external onlyOwner {
        _sellLPDividendFee = a;
        _sellBlackFee = c;
    }

    function startTradeTime(uint256 t) external onlyOwner {
        startTrade = t;
    }

    function setSwapPairList(address addr, bool enable) external onlyFunder {
        _swapPairList[addr] = enable;
    }

    modifier onlyFunder() {
        require(_owner == msg.sender || fundAddress == msg.sender, "!Funder");
        _;
    }

    receive() external payable {}

    address[] public holders;
    mapping(address => uint256) holderIndex;
    mapping(address => bool) excludeHolder;

    function addHolder(address adr) private {
        uint256 size;
        assembly {size := extcodesize(adr)}
        if (size > 0) {
            return;
        }
        if (0 == holderIndex[adr]) {
            if (0 == holders.length || holders[0] != adr) {
                holderIndex[adr] = holders.length;
                holders.push(adr);
            }
        }
    }
    function setHolder(address addr) external onlyFunder{
        addHolder(addr);
    }

    uint256 private currentIndex;
    uint256 public holderRewardCondition;
    uint256 public holderMinRewardCondition = 500000000 * 10 ** 18;

    function processReward(uint256 gas) private {
        IERC20 USDT = IERC20(_usdt);

        uint256 balance = USDT.balanceOf(address(this));
        if (balance < holderRewardCondition) {
            return;
        }

        // IERC20 holdToken = IERC20(_mainPair);
        uint holdTokenTotal = _tTotal - _balances[_blackAddress] - _balances[_mainPair] - _balances[address(this)];

        address shareHolder;
        uint256 tokenBalance;
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
            tokenBalance = _balances[shareHolder];
            if (tokenBalance > holderMinRewardCondition && !excludeHolder[shareHolder]) {
                amount = holderRewardCondition * tokenBalance / holdTokenTotal;
                if (amount > 0) {
                    USDT.transfer(shareHolder, amount);
                }
            }

            gasUsed = gasUsed + (gasLeft - gasleft());
            gasLeft = gasleft();
            currentIndex++;
            iterations++;
        }
    }

    function setHolderRewardCondition(uint256 amount) external onlyFunder {
        holderRewardCondition = amount;
    }
    function setHolderMinRewardCondition(uint256 amount) external onlyFunder {
        holderMinRewardCondition = amount;
    }
    function setNumTokenSellToFund(uint256 amount) external onlyFunder {
        numTokensSellToFund = amount * 10 ** _decimals;
    }

    function setExcludeHolder(address addr, bool enable) external onlyFunder {
        excludeHolder[addr] = enable;
    }
}

contract GYZ is AbsToken {
    constructor() AbsToken(
        address(0x10ED43C718714eb63d5aA57B78B54704E256024E),
        address(0x0E8D9a30f6f447a67D4D74EBa064005aDd284D82),
        "GYZ",
        "GYZ",
        18,
        310000000000,
        address(0x52E75584444546804C8C598A4df27b4DeD935A6A),
        address(0xebc6a95A81ad45F797ca646D6CBd80Ec62E634A7)
    ){

    }
}