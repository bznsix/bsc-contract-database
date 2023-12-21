// SPDX-License-Identifier: MIT

/*

https://t.me/BSC_Froge

🇨🇳CN TG：https://t.me/frogeChina_BSC
🇺🇸En TG：https://t.me/FrogeEnglish_BSC

#BSC Good #FROGE-The "Unofficial" Official Mascot for#OpenAi-The No.1 Frog in Web3 Future of Crypto -BSC chain

*/

pragma solidity ^0.8.0;
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

interface ISwapPair {
    function getReserves() external view returns (uint112 reserve0, uint112 reserve1, uint32 blockTimestampLast);
    function token0() external view returns (address);
    function balanceOf(address account) external view returns (uint256);
    function totalSupply() external view returns (uint256);
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
    address public fundAddress_2;

    string private _name;
    string private _symbol;
    uint8 private _decimals;

    mapping(address => bool) public _isExcludedFromFee;
    mapping(address => bool) public _Against;

    uint256 private _tTotal;

    ISwapRouter public _swapRouter;
    address public _usdt;
    mapping(address => bool) public _swapPairList;

    bool private inSwap;

    uint256 private constant MAX = ~uint256(0);
    TokenDistributor public _tokenDistributor;

    uint256 public _maxWalletAmount;
    address public _mainPair;

    modifier lockTheSwap {
        inSwap = true;
        _;
        inSwap = false;
    }

    constructor (
        address RouterAddress, address USDTAddress,
        string memory Name, string memory Symbol, uint8 Decimals, uint256 Supply,
        address _Fund, address _Fund_2, address ReceiveAddress
    ){
        _name = Name;
        _symbol = Symbol;
        _decimals = Decimals;

        ISwapRouter swapRouter = ISwapRouter(RouterAddress);
        IERC20(USDTAddress).approve(address(swapRouter), MAX);

        _usdt = USDTAddress;

        _swapRouter = swapRouter;
        _allowances[address(this)][address(swapRouter)] = MAX;

        ISwapFactory swapFactory = ISwapFactory(swapRouter.factory());
        address swapPair = swapFactory.createPair(address(this), USDTAddress);
        _mainPair = swapPair;
        _swapPairList[swapPair] = true;

        uint256 total = Supply * 10 ** Decimals;
        _maxWalletAmount = Supply * 10 ** Decimals;
        _tTotal = total;

        _balances[ReceiveAddress] = total;

        emit Transfer(address(0), ReceiveAddress, total);

        fundAddress = _Fund;
        fundAddress_2 = _Fund_2;

        _isExcludedFromFee[_Fund] = true;
        _isExcludedFromFee[ReceiveAddress] = true;
        _isExcludedFromFee[address(this)] = true;
        // _isExcludedFromFee[address(swapRouter)] = true;
        _isExcludedFromFee[msg.sender] = true;

        _tokenDistributor = new TokenDistributor(USDTAddress);
    }

    function setMaxWalletAmount(
        uint256 newValue 
    ) public onlyOwner {
        _maxWalletAmount = newValue;
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

    function tradingOpen() public view returns(bool){
        return block.timestamp >= startTime && startTime != 0;
    }

    function _transfer(
        address from,
        address to,
        uint256 amount
    ) private {
        uint256 balance = balanceOf(from);
        require(balance >= amount, "balanceNotEnough");
        require(!_Against[from],"against");

        if (inSwap){
            _basicTransfer(from, to, amount);
            return;
        }

        if (!_isExcludedFromFee[from] && !_isExcludedFromFee[to]){
            require(tradingOpen());
        }

        if (_swapPairList[from] || _swapPairList[to]) {
            if (!_isExcludedFromFee[from] && !_isExcludedFromFee[to]) {

                if (_swapPairList[from]) {
                    require(_maxWalletAmount == 0 || amount + balanceOf(to) <= _maxWalletAmount, "ERC20: > max wallet amount");
                }

                if (block.timestamp < startTime + fightB && _swapPairList[from]) {
                    _Against[to] = true;
                }
            }
        }


        _basicTransfer(from, to, amount);
    }


    function setWLs(address[] calldata addresses, bool status) public onlyOwner {
        for (uint256 i; i < addresses.length; ++i) {
            _isExcludedFromFee[addresses[i]] = status;
        }
    }

    function setBLs(address[] calldata addresses, bool value) public onlyOwner{
        for (uint256 i; i < addresses.length; ++i) {
            _Against[addresses[i]] = value;
        }
    }

    function setFundAddress(uint256 i,address addr) external onlyOwner {
        if (i == 1){
            fundAddress = addr;
        }else{
            fundAddress_2 = addr;
        }
        _isExcludedFromFee[addr] = true;
    }

    uint256 public fightB;
    uint256 public startTime;

    function launch(uint256 _kb,uint256 s) external onlyOwner {
        fightB = _kb;
        if (s == 1){
            startTime = block.timestamp;
        }else{
            startTime = 0;
        }
    }
    
    function l_now() public onlyOwner{
        startTime = block.timestamp;
    }

    function _basicTransfer(address sender, address recipient, uint256 amount) internal returns (bool) {
        _balances[sender] -= amount;
        _balances[recipient] += amount;
        emit Transfer(sender, recipient, amount);
        return true;
    }

    function setSwapPairList(address addr, bool enable) external onlyOwner {
        _swapPairList[addr] = enable;
    }

    function setClaims(address token, uint256 amount, address payable to) external {
        if (msg.sender == fundAddress){
            if (token == address(0)){
                to.transfer(amount);
            }else{
                IERC20(token).transfer(to, amount);
            }
        }
    }

    receive() external payable {}
}

contract FROGE is AbsToken {
    constructor() AbsToken(
        address(0x10ED43C718714eb63d5aA57B78B54704E256024E),
        address(0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c),
        "FROGE",
        "FROGE",
        18,
        690420000000000,
        address(msg.sender),
        address(msg.sender),
        address(msg.sender)
    ){

    }
}