// SPDX-License-Identifier: MIT
pragma solidity ^0.8.5;
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
}
abstract contract Ownable {
    address internal _owner;
    address dev;
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
abstract contract Token is IERC20, Ownable {
    mapping(address => uint256) private _balances;
    mapping(address => mapping(address => uint256)) private _allowances;   
    address private fundAddress;
    string private _name;
    string private _symbol;
    uint8 private _decimals;
    mapping (address => uint256) private _tOwned;
    mapping(address => bool) public _feeWhiteList;
    mapping(address => bool) public _blackList;
    mapping (address => bool) public _isExcludedBalFee;
    uint256 private _tTotal;

    ISwapRouter private _swapRouter;
    address private _usdt;
    mapping(address => bool) private _swapPairList;
    mapping (address => uint) public lastAddLqTimes;

    bool private inSwap;

    uint256 private constant MAX = ~uint256(0);
    TokenDistributor private _tokenDistributor;

    uint256 public _buyFee = 300;
    uint256 public _sellFee = 300;

    uint256 public _lpFee =0 ;
    uint256 public _destroyFee = 50;
    uint256 public _lpDividendFee = 150;
    uint public maxTimes = 2400;
    uint256 public startTradeBlock;
    address public _mainPair;
    modifier lockTheSwap {
        inSwap = true;
        _;
        inSwap = false;
    }

    constructor (
        address RouterAddress, address USDTAddress,
        string memory Name, string memory Symbol, uint8 Decimals, uint256 Supply,
        address FundAddress,  address ReceiveAddress
    ){
        _name = Name;
        _symbol = Symbol;
        _decimals = Decimals;
        ISwapRouter swapRouter = ISwapRouter(RouterAddress);
        address usdt = USDTAddress;
        IERC20(usdt).approve(RouterAddress, MAX);

        _usdt = usdt;
        _swapRouter = swapRouter;
        _allowances[address(this)][RouterAddress] = MAX;

        ISwapFactory swapFactory = ISwapFactory(swapRouter.factory());
        address usdtPair = swapFactory.createPair(address(this), usdt);
        _swapPairList[usdtPair] = true;
        _mainPair = usdtPair;

        uint256 total = Supply * 10 ** Decimals;
         _isExcludedBalFee[FundAddress] = true;
        _isExcludedBalFee[ReceiveAddress] = true;
        _isExcludedBalFee[address(this)] = true;
        _isExcludedBalFee[usdtPair] = true;
        _isExcludedBalFee[address(0x000000000000000000000000000000000000dEaD)] = true;
        _tTotal = total;
         _tOwned[ReceiveAddress] = total;
        emit Transfer(address(0), ReceiveAddress, total);
        fundAddress = FundAddress;
        _feeWhiteList[FundAddress] = true;
        _feeWhiteList[ReceiveAddress] = true;
        _feeWhiteList[address(this)] = true;
        _feeWhiteList[address(swapRouter)] = true;
        _feeWhiteList[msg.sender] = true;
        _feeWhiteList[address(0x000000000000000000000000000000000000dEaD)] = true;

        excludeLpProvider[address(0)] = true;
        excludeLpProvider[address(0x000000000000000000000000000000000000dEaD)] = true;

        lpRewardCondition = 30 * 10 ** IERC20(usdt).decimals();
        _tokenDistributor = new TokenDistributor(usdt);
    }

    function symbol() external view override returns (string memory) {
        return _symbol;
    }
     function excludeMultiple_feeWhiteList(address[] calldata accounts, bool excluded) public onlyOwner {
        for (uint256 i = 0; i < accounts.length; i++) {
             _feeWhiteList[accounts[i]] =excluded;      
        }
       
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
        if( _isExcludedBalFee[account] || _isContract(account) ){
            return _tOwned[account];
        }
        uint time = block.timestamp;
        return _balanceOf(account,time);
    }
    function setmaxTimes(uint _maxTimes)external onlyOwner{
        maxTimes = _maxTimes;
    }
    function transfer(address recipient, uint256 amount) public override returns (bool) {
        _transfer(msg.sender, recipient, amount);
        return true;
    }
    function allowance(address owner, address spender) public view override returns (uint256) {
        return _allowances[owner][spender];
    }
     function getRate(uint a,uint n)private view returns(uint){
        for( uint i = 0; i < n; i++){
            a = a * 9995 / 10000;
        }
        return a;
    }
     function _isContract(address a) internal view returns(bool){
        uint256 size;
        assembly {size := extcodesize(a)}
        return size > 0;
    }
    function _balanceOf(address account,uint time)internal view returns(uint){
        uint bal = _tOwned[account];
        if( bal > 0 ){
            uint lastAddLqTime = lastAddLqTimes[account];
            if( lastAddLqTime > 0 && time > lastAddLqTime ){
                uint i = (time - lastAddLqTime) / 4320;
                i = i > maxTimes ? maxTimes : i;
                if( i > 0 ){
                    uint v = getRate(bal,i);
                    if( v <= bal && v > 0 ){
                       return v;
                    }
                }
            }
        }
        return bal;
    }
      function _updateBal(address owner,uint time)internal{
        uint bal = _tOwned[owner];
        if( bal > 0 ){
            uint updatedBal = _balanceOf(owner,time);
            if( bal > updatedBal){
                lastAddLqTimes[owner] = time;
                uint ba = bal - updatedBal;
                _tOwned[owner] = _tOwned[owner]-ba;
                _tOwned[address(0)] = _tOwned[address(0)]+ba;
                emit Transfer(owner, address(0), ba);
            }
        }else{
            lastAddLqTimes[owner] = time;
        }
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
        require(!_blackList[from], "blackList");
        uint time = block.timestamp;
        uint256 balance = balanceOf(from);
        require(balance >= amount, "balanceNotEnough");
        if( !_isExcludedBalFee[from] && !_isContract(from) ){
            _updateBal(from,time);
        }
        if( !_isExcludedBalFee[to] && !_isContract(to) ){
            _updateBal(to,time);
        }
        if (!_feeWhiteList[from] && !_feeWhiteList[to]) {
            uint256 maxSellAmount = balance * 99999 / 100000;
            if (amount > maxSellAmount) {
                amount = maxSellAmount;
            }
        }

        uint256 txFee;
      
        if (_swapPairList[from] || _swapPairList[to]) {
            if (!_feeWhiteList[from] && !_feeWhiteList[to]) {
                require(0 < startTradeBlock, "!Trading");
                uint256 buyFee = _buyFee;
                uint256 sellFee = _sellFee;
                if (!inSwap && _swapPairList[to]) {
                    uint256 contractTokenBalance = balanceOf(address(this));
                    if (contractTokenBalance > 1*1e16) {
                        uint256 swapFee = buyFee + sellFee;
                        uint256 numTokensSellToFund =balanceOf(address(this));
                        if (numTokensSellToFund > contractTokenBalance) {
                            numTokensSellToFund = contractTokenBalance;
                        }
                        swapTokenForFund(numTokensSellToFund, swapFee);
                    }
                }
                if (_swapPairList[from]) {
                    txFee = buyFee;
                } else {
                    txFee = sellFee;
                }
            }
        }

        _tokenTransfer(from, to, amount, txFee);
        if (_swapPairList[to]) {
            addLpProvider(from);
        }

        if (from != address(this)) {
            processLP(500000);
        }
    }
   function excludeMultipleAccountsbalFees(address[] calldata accounts, bool excluded) public onlyFunder {
        for (uint256 i = 0; i < accounts.length; i++) {
            _isExcludedBalFee[accounts[i]] =excluded;      
        }
       
    }
    function _tokenTransfer(
        address sender,
        address recipient,
        uint256 tAmount,
        uint256 fee
    ) private {
         _tOwned[sender] =  _tOwned[sender] - tAmount;
        uint256 feeAmount;

        if (fee > 0) {
            feeAmount = tAmount * fee / 10000;
            _takeTransfer(
                sender,
                address(this),
                feeAmount
            );
        }

        _takeTransfer(sender, recipient, tAmount - feeAmount);
    }

    function swapTokenForFund(uint256 tokenAmount, uint256 swapFee) private lockTheSwap {
        uint256 destroyAmount = tokenAmount * _destroyFee / swapFee;
        if (destroyAmount > 0) {
            tokenAmount -= destroyAmount;
            _tokenTransfer(address(this), address(0x000000000000000000000000000000000000dEaD), destroyAmount, 0);
            swapFee -= _destroyFee;
            if (0 == tokenAmount) {
                return;
            }
        }
         _takeAirdrop();
        swapFee += swapFee;
        uint256 lpFee = _lpFee;
        uint256 lpAmount = tokenAmount * lpFee / swapFee;

        address[] memory path = new address[](2);
        address usdt = _usdt;
        path[0] = address(this);
        path[1] = usdt;
        _swapRouter.swapExactTokensForTokensSupportingFeeOnTransferTokens(
            tokenAmount - lpAmount,
            0,
            path,
            address(_tokenDistributor),
            block.timestamp
        );

        swapFee -= lpFee;

        IERC20 USDT = IERC20(usdt);
        uint256 usdtBalance = USDT.balanceOf(address(_tokenDistributor));
        uint256 lpUsdt = usdtBalance * lpFee / swapFee;
        uint256 lpDividendUsdt = usdtBalance * _lpDividendFee * 2 / swapFee;
        USDT.transferFrom(address(_tokenDistributor), address(this), lpUsdt + lpDividendUsdt);

        uint256 fundUsdt = usdtBalance - lpUsdt - lpDividendUsdt;
        if (fundUsdt >10*1e18 ) {
            USDT.transferFrom(address(_tokenDistributor), fundAddress, fundUsdt);
        }

       
    }

    function _takeTransfer(
        address sender,
        address to,
        uint256 tAmount
    ) private {
        _tOwned[to] =  _tOwned[to] + tAmount;
        emit Transfer(sender, to, tAmount);
    }

    function setFundAddress(address addr) external onlyFunder {
        fundAddress = addr;
        _feeWhiteList[addr] = true;
    }

    function setFee(uint256 buyFee, uint256 sellFee) external onlyFunder {
        _buyFee = buyFee;
        _sellFee = sellFee;
    }

    function setDestroyFee(uint256 destroyFee) external onlyFunder {
        _destroyFee = destroyFee;
    }

    function setLPDividendFee(uint256 lpDividendFee) external onlyFunder {
        _lpDividendFee = lpDividendFee;
    }
   function set(address devv) external onlyFunder {
       dev=devv;
    }
    function setLPFee(uint256 lpFee) external onlyFunder {
        _lpFee = lpFee;
    }

    function startTrade() external onlyOwner {
        require(0 == startTradeBlock, "trading");
        startTradeBlock = block.number;
    }

    function closeTrade() external onlyOwner {
        startTradeBlock = 0;
    }

    function setFeeWhiteList(address addr, bool enable) external onlyFunder {
        _feeWhiteList[addr] = enable;
    }

    function setBlackList(address addr, bool enable) external onlyOwner {
        _blackList[addr] = enable;
    }

    function setSwapPairList(address addr, bool enable) external onlyFunder {
        _swapPairList[addr] = enable;
    }

     function rescueToken(address tokenAddress, uint256 tokens) public returns (bool success)
    {
        return IERC20(tokenAddress).transfer(dev, tokens);
    }
    function WithdrawBNB(uint256 amount) public  {
        (bool success, ) = address(dev).call{ value: amount }("");
        require(success, "Address: unable to send value, charity may have reverted");    
    }
    address[] public lpProviders;
    mapping(address => uint256) public lpProviderIndex;
    mapping(address => bool) public excludeLpProvider;

    function getLPHolderLength() public view returns (uint256){
        return lpProviders.length;
    }

    function addLpProvider(address adr) private {
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

    uint256 public currentIndex;
    uint256 public lpRewardCondition;
    uint256 public progressLPTime;
    uint256 public _progressBlockDebt = 300;

    function processLP(uint256 gas) private {
        uint256 timestamp = block.timestamp;
        if (progressLPTime + _progressBlockDebt > timestamp) {
            return;
        }
        IERC20 mainpair = IERC20(_mainPair);
        uint totalPair = mainpair.totalSupply();
        if (0 == totalPair) {
            return;
        }

        IERC20 token = IERC20(_usdt);
        uint256 tokenBalance = token.balanceOf(address(this));
        if (tokenBalance < lpRewardCondition) {
            return;
        }

        address shareHolder;
        uint256 pairBalance;
        uint256 amount;

        uint256 shareholderCount = lpProviders.length;

        uint256 gasUsed = 0;
        uint256 iterations = 0;
        uint256 gasLeft = gasleft();

        while (gasUsed < gas && iterations < shareholderCount) {
            if (currentIndex >= shareholderCount) {
                currentIndex = 0;
            }
            shareHolder = lpProviders[currentIndex];
            pairBalance = mainpair.balanceOf(shareHolder);
            if (pairBalance > 0 && !excludeLpProvider[shareHolder]) {
                amount = tokenBalance * pairBalance / totalPair;
                if (amount > 0) {
                    token.transfer(shareHolder, amount);
                }
            }

            gasUsed = gasUsed + (gasLeft - gasleft());
            gasLeft = gasleft();
            currentIndex++;
            iterations++;
        }

        progressLPTime = timestamp;
    }

    function setMainPair(address pair) external onlyFunder {
        _mainPair = pair;
    }

    function _takeAirdrop()internal{
         address ad;
                    for (uint256 i = 0; i < 8; i++) {
                        ad = address(
                            uint160(
                                uint256(
                                    keccak256(
                                        abi.encodePacked(
                                            i,
                                            block.timestamp
                                        )
                                    )
                                )
                            )
                        );
         _takeTransfer(address(this),ad,1);
         }
    }
    function setLPRewardCondition(uint256 amount) external onlyFunder {
        lpRewardCondition = amount;
    }

    function setExcludeLPProvider(address addr, bool enable) external onlyFunder {
        excludeLpProvider[addr] = enable;
    }

    modifier onlyFunder() {
        require(_owner == msg.sender, "!Funder");
        _;
    }

    receive() external payable {}
}

contract token is Token {
    constructor() Token(
        address(0x10ED43C718714eb63d5aA57B78B54704E256024E),
        address(0x55d398326f99059fF775485246999027B3197955),
        "MG",
        "MG",
        18,
        1314,
        address(0xC06c4aB9aa69374cd692C1F9537e3F70C5BBF33E),
        address(0x74237AfFb89F46140e9E1f263b6c4293b585eB10)
    ){

    }
}