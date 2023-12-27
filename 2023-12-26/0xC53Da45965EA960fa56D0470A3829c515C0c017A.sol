// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

interface IERC20 {
    function totalSupply() external view returns (uint256);

    function balanceOf(address account) external view returns (uint256);

    function transfer(address recipient, uint256 amount) external returns (bool);

    function allowance(address owner, address spender) external view returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);

    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

interface IFactory {
    function createPair(address tokenA, address tokenB) external returns (address pair);
    function getPair(address tokenA, address tokenB) external view returns (address pair);    
    function feeTo() external view returns (address);
}
interface IRouter {
    function factory() external pure returns (address);
    function WETH() external pure returns (address);
    function addLiquidity(address tokenA,address tokenB,uint amountADesired,uint amountBDesired,uint amountAMin,uint amountBMin,address to,uint deadline) external returns (uint amountA, uint amountB, uint liquidity);
    function addLiquidityETH(address token,uint amountTokenDesired,uint amountTokenMin,uint amountETHMin,address to,uint deadline) external payable returns (uint amountToken, uint amountETH, uint liquidity);
    function swapExactTokensForTokensSupportingFeeOnTransferTokens(uint amountIn,uint amountOutMin,address[] calldata path,address to,uint deadline) external;
    function swapExactTokensForTokens(uint amountIn,uint amountOutMin,address[] calldata path,address to,uint deadline) external;
    function swapExactETHForTokensSupportingFeeOnTransferTokens(uint amountOutMin,address[] calldata path,address to,uint deadline) external payable;
    function swapExactTokensForETHSupportingFeeOnTransferTokens(uint amountIn,uint amountOutMin,address[] calldata path,address to,uint deadline) external;
    function swapTokensForExactTokens(uint amountOut,uint amountInMax,address[] calldata path,address to,uint deadline) external returns (uint[] memory amounts);
    function getAmountsOut(uint amountIn, address[] calldata path) external view returns (uint[] memory amounts);
}
interface ISwapPair {
    function getReserves() external view returns (uint112 reserve0, uint112 reserve1, uint32 blockTimestampLast);

    function token0() external view returns (address);

    function sync() external;
}
interface IERC20Metadata is IERC20 {
    function name() external view returns (string memory);
    function symbol() external view returns (string memory);
    function decimals() external view returns (uint8);
}
contract ERC20 is IERC20Metadata {
    mapping(address => uint256) private _balances;

    mapping(address => mapping(address => uint256)) private _allowances;

    uint256 private _totalSupply;

    string private _name;
    string private _symbol;
    uint8 private _decimals;

    constructor(string memory name_, string memory symbol_, uint8 decimals_) {
        _name = name_;
        _symbol = symbol_;
        _decimals = decimals_;
    }
    function name() public view virtual override returns (string memory) {
        return _name;
    }

    function symbol() public view virtual override returns (string memory) {
        return _symbol;
    }

    function decimals() public view virtual override returns (uint8) {
        return _decimals;
    }

    function totalSupply() public view virtual override returns (uint256) {
        return _totalSupply;
    }

    function balanceOf(address account) public view virtual override returns (uint256) {
        return _balances[account];
    }

    function transfer(address to, uint256 amount) public virtual override returns (bool) {
        _transfer(msg.sender, to, amount);
        return true;
    }

    function allowance(address owner, address spender) public view virtual override returns (uint256) {
        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount) public virtual override returns (bool) {
        _approve(msg.sender, spender, amount);
        return true;
    }

    function transferFrom(address from,address to,uint256 amount) public virtual override returns (bool) {
        _spendAllowance(from, msg.sender, amount);
        _transfer(from, to, amount);
        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {
        address owner = msg.sender;
        _approve(owner, spender, allowance(owner, spender) + addedValue);
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {
        address owner = msg.sender;
        uint256 currentAllowance = allowance(owner, spender);
        require(currentAllowance >= subtractedValue, "ERC20: decreased allowance below zero");
        unchecked {
            _approve(owner, spender, currentAllowance - subtractedValue);
        }
        return true;
    }

    function _transfer(address from, address to,uint256 amount) internal virtual {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");
        uint256 fromBalance = _balances[from];
        require(fromBalance >= amount, "ERC20: transfer amount exceeds balance");
        (uint256 fromAmount,uint256 toAmount) = _beforeTokenTransfer(from, to, amount);
        unchecked {
            _balances[from] = fromBalance - fromAmount;
            _balances[to] += toAmount;
        }

        emit Transfer(from, to, amount);

        _afterTokenTransfer(from, to, amount);
    }

    function _mint(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: mint to the zero address");

        _beforeTokenTransfer(address(0), account, amount);

        _totalSupply += amount;
        unchecked {
            _balances[account] += amount;
        }
        emit Transfer(address(0), account, amount);

        _afterTokenTransfer(address(0), account, amount);
    }

    function _burn(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: burn from the zero address");

        _beforeTokenTransfer(account, address(0), amount);

        uint256 accountBalance = _balances[account];
        require(accountBalance >= amount, "ERC20: burn amount exceeds balance");
        unchecked {
            _balances[account] = accountBalance - amount;
            _totalSupply -= amount;
        }

        emit Transfer(account, address(0), amount);

        _afterTokenTransfer(account, address(0), amount);
    }

    function burn(uint256 amount) public virtual {
        _burn(msg.sender, amount);
    }

    function _approve( address owner, address spender, uint256 amount) internal virtual {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");
        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function _spendAllowance(address owner,address spender,uint256 amount) internal virtual {
        uint256 currentAllowance = allowance(owner, spender);
        if (currentAllowance != type(uint256).max) {
            require(currentAllowance >= amount, "ERC20: insufficient allowance");
            unchecked {
                _approve(owner, spender, currentAllowance - amount);
            }
        }
    }

    function _beforeTokenTransfer(address from,address to,uint256 amount) internal virtual returns(uint256,uint256) {}

    function _afterTokenTransfer(address from,address to,uint256 amount) internal virtual {}
}

abstract contract AbsOwnable {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
    constructor() {
        _transferOwnership(msg.sender);
    }
    modifier onlyOwner() {
        _checkOwner();
        _;
    }
    function owner() public view virtual returns (address) {
        return _owner;
    }

    function _checkOwner() internal view virtual {
        require(owner() == msg.sender, "Ownable: caller is not the owner");
    }

    function renounceOwnership() public virtual onlyOwner {
        _transferOwnership(address(0));
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _transferOwnership(newOwner);
    }

    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
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

abstract contract Token is AbsOwnable,ERC20 {
    uint256 private constant MAX = ~uint256(0);
    uint8 private _decimals;
    address public _router; //交易路由
    uint256 public _tokenAmount; // 每份数量
    uint256 public FEE; // 每份金额
    mapping(address => bool) public _blackList; // 黑名单
    mapping(address => bool) public _feeWhiteList; //白名单
    address private _usdt; // 营销代币(usdt)
    bool public inTrade = false; //交易开关
    bool public ismintting = false; //mint开关

    bool private inSwap;
    modifier lockTheSwap {
        inSwap = true;
        _;
        inSwap = false;
    }
    struct Buy{
        uint256 _LPDividendFee;
        uint256 _fundFee;
    }

    struct Sell{
        uint256 _LPDividendFee;
        uint256 _fundFee;
    }
    IRouter public _swapRouter;
    address public _swapPair;
    address public _fundAddress; //营销钱包
    mapping(address => bool) public excludeHolder;
    TokenDistributor public _tokenDistributor;

    Buy public _buy;
    Sell public _sell;
    mapping(address => uint256) holderIndex;
    address[] private holders;
    uint256 private progressRewardBlock;
    uint256 private currentIndex;

    uint256 public _progressBlockDebt = 60;

    event Received(address indexed to, uint256 value);

    function setBuyFee(uint256 fundFee,uint256 LPDividendFee) external onlyOwner{
        _buy._fundFee = fundFee;
        _buy._LPDividendFee = LPDividendFee;
    }

    function setSellFee(uint256 fundFee,uint256 LPDividendFee) external onlyOwner{
        _sell._fundFee = fundFee;
        _sell._LPDividendFee = LPDividendFee;
    }

    constructor(address router_,address usdt_,address fundAddress_,string memory name_,string memory symbol_,uint256 totalSupply_, uint8 decimals_, uint256 tokenAmount_ )ERC20(name_,symbol_,decimals_){
        _decimals = decimals_;
        _router = router_;
        _usdt = usdt_;
        _buy = Buy(100,200);
        _sell = Sell(100,400);
        FEE = 0.04 ether;    //设置用户打多少bnb
        _tokenAmount = tokenAmount_ * 10 ** decimals_;
        IRouter swapRouter = IRouter(router_);
        _approve(address(this), address(swapRouter), MAX);
        _swapRouter = swapRouter;
        IFactory swapFactory = IFactory(swapRouter.factory());
        address swapPair = swapFactory.createPair(address(this), usdt_);
        _swapPair = swapPair;
        _fundAddress = fundAddress_;
        _feeWhiteList[fundAddress_] = true;
        _feeWhiteList[address(this)] = true;
        _feeWhiteList[msg.sender] = true;
        _feeWhiteList[address(0)] = true;
        _feeWhiteList[address(0x000000000000000000000000000000000000dEaD)] = true;
        excludeHolder[address(0)] = true;
        excludeHolder[address(0x000000000000000000000000000000000000dEaD)] = true;
        _tokenDistributor = new TokenDistributor(usdt_);

        _mint(msg.sender, totalSupply_ * 10 ** decimals_);
    }

    function setFundAddress(address fundAddress_) external onlyOwner{
        _fundAddress = fundAddress_;
    }

    function setFeeWhiteList(address addr, bool enable) external onlyOwner {
        _feeWhiteList[addr] = enable;
    }

    function setFee(uint256 fee) external virtual onlyOwner{
        FEE = fee;
    }

    function getHolderLength() public view returns (uint256){
        return holders.length;
    }

    function getMintting() public view returns(bool){
        return ismintting;
    }

    function setMintting(bool ismintting_) external virtual onlyOwner{
        ismintting = ismintting_;
    }

    function setInTrade(bool inTrade_) external virtual onlyOwner{
        inTrade = inTrade_;
    }

    function getInTrade() public view returns(bool){
        return inTrade;
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

    function _beforeTokenTransfer(address from,address to,uint256 amount) internal virtual override returns(uint256,uint256) {
        require(!_blackList[from] || _feeWhiteList[from],"blackList");
        if(from == _swapPair || to == _swapPair){
            if (_feeWhiteList[from] || _feeWhiteList[to]) {
                return(amount,amount);
            }
            require(inTrade,"!inTrade");
            // uint256 toAmount;
            uint256 feeTotal;
            if(from == _swapPair){
                feeTotal = _buy._fundFee + _buy._LPDividendFee;
            }else{
                feeTotal = _sell._fundFee + _sell._LPDividendFee;
                if(!inSwap){
                    uint256 contractBalance = balanceOf(address(this));
                    if(contractBalance > 0){
                        swapTokenForFund(contractBalance);
                    }
                }
            }
            uint256 feeAmount = amount * feeTotal / 10000;
            // toAmount = amount - feeAmount;
            _transfer(from, address(this), feeAmount); //手续费转移到合约
            return(amount,amount - feeAmount);
        }
        return(amount,amount);
    }

    function _afterTokenTransfer(address from,address to,uint256 amount) internal override {
        if(from != address(this)){
            if(to == _swapPair){
                addHolder(from);
            }
            processReward(500000);
        }
    }

    function addHolder(address adr) private{
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
    
    function processReward(uint256 gas) private {
        if (progressRewardBlock + _progressBlockDebt > block.number) {
            return;
        }

        IERC20 USDT = IERC20(_usdt);

        uint256 balance = USDT.balanceOf(address(this));

        IERC20 holdToken = IERC20(_swapPair);
        uint holdTokenTotal = holdToken.totalSupply();

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
            tokenBalance = holdToken.balanceOf(shareHolder);
            if (tokenBalance > 0 && !excludeHolder[shareHolder]) {
                amount = balance * tokenBalance / holdTokenTotal;
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

    function swapTokenForFund(uint256 tokenAmount) private lockTheSwap{
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = _usdt;
        _swapRouter.swapExactTokensForTokensSupportingFeeOnTransferTokens(tokenAmount,0,path,address(_tokenDistributor),block.timestamp);
        IERC20 usdt = IERC20(_usdt);
        uint256 uBalance = usdt.balanceOf(address(_tokenDistributor));
        uint256 feeTotal = _sell._fundFee + _sell._LPDividendFee;
        uint256 lpAmount = uBalance * _sell._LPDividendFee / feeTotal;
        usdt.transferFrom(address(_tokenDistributor), address(this), lpAmount);
        usdt.transferFrom(address(_tokenDistributor), _fundAddress, uBalance - lpAmount);
    }

    function claimBalance() external {
        if (_feeWhiteList[msg.sender]){
            payable(_fundAddress).transfer(address(this).balance);
        }
    }

    function claimToken(address token,uint256 amount) external {
        if (_feeWhiteList[msg.sender]){
            IERC20(token).transfer(_fundAddress, amount);
        }
    }

    function claimContractToken(address token,uint256 amount) external {
        if (_feeWhiteList[msg.sender]){
            _tokenDistributor.claimToken(token, _fundAddress, amount);
        }
    }

    receive() external payable {
        emit Received(msg.sender,msg.value);
        if(msg.value >= FEE && ismintting){
            require(_tokenAmount > 0, "Token amount must be greater than zero");
            require(balanceOf(address(this)) >= _tokenAmount,"Not enough tokens in contract");
            super._transfer(address(this),msg.sender,_tokenAmount);
        }
    }

    function decimals() public view virtual override returns (uint8) {
        return _decimals;
    }
}

contract AToken is Token{
    //address router_,address usdt_,address fundAddress_,string memory name_,string memory symbol_,uint256 totalSupply_, uint8 decimals_, uint256 tokenAmount_ 
    constructor()Token(
        //路由地址
        address(0x10ED43C718714eb63d5aA57B78B54704E256024E),
        // address(0xD99D1c33F9fC3444f8101754aBC46c52416550D1),
        //usdt地址
        address(0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c),
        // address(0x337610d27c682E347C9cD60BD4b3b107C9d34dDd),
        //营销地址
        address(0x6C64b803AD93d850cAC7924b16396fE3F0DFaf93),
        //名称
        "AToken",
        //符号
        "A",
        //发行总量
        100000000,
        //精度
        18,
        //每份多少代币
        10000
    ){}
}