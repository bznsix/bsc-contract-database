/**
 *Submitted for verification at BscScan.com on 2023-10-27
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.6;
abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this;
        return msg.data;
    }

}



interface IUniswapV2Pair {

    event Approval(

        address indexed owner,

        address indexed spender,

        uint256 value

    );

    event Transfer(address indexed from, address indexed to, uint256 value);



    function name() external pure returns (string memory);



    function symbol() external pure returns (string memory);



    function decimals() external pure returns (uint8);



    function totalSupply() external view returns (uint256);



    function balanceOf(address owner) external view returns (uint256);



    function allowance(address owner, address spender)

    external

    view

    returns (uint256);



    function approve(address spender, uint256 value) external returns (bool);



    function transfer(address to, uint256 value) external returns (bool);



    function transferFrom(

        address from,

        address to,

        uint256 value

    ) external returns (bool);



    function DOMAIN_SEPARATOR() external view returns (bytes32);



    function PERMIT_TYPEHASH() external pure returns (bytes32);



    function nonces(address owner) external view returns (uint256);



    function permit(

        address owner,

        address spender,

        uint256 value,

        uint256 deadline,

        uint8 v,

        bytes32 r,

        bytes32 s

    ) external;



    event Mint(address indexed sender, uint256 amount0, uint256 amount1);

    event Burn(

        address indexed sender,

        uint256 amount0,

        uint256 amount1,

        address indexed to

    );

    event Swap(

        address indexed sender,

        uint256 amount0In,

        uint256 amount1In,

        uint256 amount0Out,

        uint256 amount1Out,

        address indexed to

    );

    event Sync(uint112 reserve0, uint112 reserve1);



    function MINIMUM_LIQUIDITY() external pure returns (uint256);



    function factory() external view returns (address);



    function token0() external view returns (address);



    function token1() external view returns (address);



    function getReserves()

    external

    view

    returns (

        uint112 reserve0,

        uint112 reserve1,

        uint32 blockTimestampLast

    );



    function price0CumulativeLast() external view returns (uint256);



    function price1CumulativeLast() external view returns (uint256);



    function kLast() external view returns (uint256);



    function mint(address to) external returns (uint256 liquidity);



    function burn(address to)

    external

    returns (uint256 amount0, uint256 amount1);



    function swap(

        uint256 amount0Out,

        uint256 amount1Out,

        address to,

        bytes calldata data

    ) external;



    function skim(address to) external;



    function sync() external;



    function initialize(address, address) external;

}



interface IUniswapV2Factory {

    event PairCreated(

        address indexed token0,

        address indexed token1,

        address pair,

        uint256

    );



    function feeTo() external view returns (address);



    function feeToSetter() external view returns (address);



    function getPair(address tokenA, address tokenB)
    external
    view
    returns (address pair);

    function allPairs(uint256) external view returns (address pair);
    function allPairsLength() external view returns (uint256);
    function createPair(address tokenA, address tokenB)
    external
    returns (address pair);

    function setFeeTo(address) external;

    function setFeeToSetter(address) external;

}





interface IERC20 {

    /**

     * @dev Returns the amount of tokens in existence.

     */

    function totalSupply() external view returns (uint256);



    function decimals() external view returns (uint8);


    function balanceOf(address account) external view returns (uint256);



    /**

     * @dev Moves `amount` tokens from the caller's account to `recipient`.

     *

     * Returns a boolean value indicating whether the operation succeeded.

     *

     * Emits a {Transfer} event.

     */

    function transfer(address recipient, uint256 amount)

    external

    returns (bool);


    function allowance(address owner, address spender)

    external

    view

    returns (uint256);


    function approve(address spender, uint256 amount) external returns (bool);


    function transferFrom(

        address sender,

        address recipient,

        uint256 amount

    ) external returns (bool);



    /**

     * @dev Emitted when `value` tokens are moved from one account (`from`) to

     * another (`to`).

     *

     * Note that `value` may be zero.

     */

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );

}



interface IERC20Metadata is IERC20 {
    function name() external view returns (string memory);
    function symbol() external view returns (string memory);
}



contract Ownable is Context {

    address private _owner;

    address private _dever;



    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );


    constructor() {

        address msgSender = _msgSender();

        _owner = msgSender;

        _dever = msgSender;

        emit OwnershipTransferred(address(0), msgSender);

    }

    function owner() public view returns (address) {
        return _owner;
    }


    modifier onlyOwner() {
        require(_owner == _msgSender(), "Ownable: caller is not the owner");
        _;
    }



    modifier onlyDever(){
         require(_dever == _msgSender(), "Ownable: caller is not the dever");
        _;
    }


    function renounceOwnership() public virtual onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(
            newOwner != address(0),
            "Ownable: new owner is the zero address"
        );
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }

}



library Address {

  

    function isContract(address account) internal view returns (bool) {
        bytes32 codehash;
        bytes32 accountHash = 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470;

        // solhint-disable-next-line no-inline-assembly

        assembly { codehash := extcodehash(account) }

        return (codehash != 0x0 && codehash != accountHash);

    }

}



contract ERC20 is Ownable, IERC20, IERC20Metadata {

    using SafeMath for uint256;



    mapping(address => uint256) private _balances;



    mapping(address => mapping(address => uint256)) private _allowances;



    uint256 private _totalSupply;
    string private _name;
    string private _symbol;
    constructor(string memory name_, string memory symbol_) {
        _name = name_;
        _symbol = symbol_;

    }



    /**

     * @dev Returns the name of the token.

     */

    function name() public view virtual override returns (string memory) {

        return _name;

    }

    function symbol() public view virtual override returns (string memory) {

        return _symbol;

    }

    function decimals() public view virtual override returns (uint8) {

        return 18;

    }



    /**

     * @dev See {IERC20-totalSupply}.

     */

    function totalSupply() public view virtual override returns (uint256) {
        return _totalSupply;
    }

    function balanceOf(address account)
    public
    view
    virtual
    override
    returns (uint256)
    {
        return _balances[account];
    }
    function transfer(address recipient, uint256 amount)
    public
    virtual
    override
    returns (bool)
    {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    function allowance(address owner, address spender)
    public
    view
    virtual
    override
    returns (uint256)
    {
        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount)
    public
    virtual
    override
    returns (bool)
    {
        _approve(_msgSender(), spender, amount);
        return true;
    }

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) public virtual override returns (bool) {
        _transfer(sender, recipient, amount);
        _approve(
            sender,
            _msgSender(),
            _allowances[sender][_msgSender()].sub(
                amount,
                "ERC20: transfer amount exceeds allowance"
            )
        );
        return true;
    }


    function increaseAllowance(address spender, uint256 addedValue)
    public
    virtual
    returns (bool)
    {
        _approve(
         _msgSender(),
            spender,
            _allowances[_msgSender()][spender].add(addedValue)
        );
        return true;
    }


    function decreaseAllowance(address spender, uint256 subtractedValue)
    public
    virtual
    returns (bool)
    {
        _approve(
            _msgSender(),
            spender,
            _allowances[_msgSender()][spender].sub(
                subtractedValue,
                "ERC20: decreased allowance below zero"
            )
        );
        return true;
    }




    function _transfer(

        address sender,

        address recipient,

        uint256 amount

    ) internal virtual {

        require(sender != address(0), "ERC20: transfer from the zero address");

        require(recipient != address(0), "ERC20: transfer to the zero address");



        _beforeTokenTransfer(sender, recipient, amount);



         _transferToken(sender,recipient,amount);

    }

    

    function _transferToken(

        address sender,

        address recipient,

        uint256 amount

    ) internal virtual {

        _balances[sender] = _balances[sender].sub(

            amount,

            "ERC20: transfer amount exceeds balance"

        );

        _balances[recipient] = _balances[recipient].add(amount);

        emit Transfer(sender, recipient, amount);

    }


    function _mint(address account, uint256 amount) internal virtual {

        require(account != address(0), "ERC20: mint to the zero address");



        _beforeTokenTransfer(address(0), account, amount);



        _totalSupply = _totalSupply.add(amount);

        _balances[account] = _balances[account].add(amount);

        emit Transfer(address(0), account, amount);

    }


    function _burn(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: burn from the zero address");
        _beforeTokenTransfer(account, address(0), amount);
        _balances[account] = _balances[account].sub(
            amount,
            "ERC20: burn amount exceeds balance"
        );
        _totalSupply = _totalSupply.sub(amount);
        emit Transfer(account, address(0), amount);
    }

    function _approve(
        address owner,
        address spender,
        uint256 amount
    ) internal virtual {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");
        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }


    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {}

}





library SafeMath {

    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");
        return c;
    }



    function sub(uint256 a, uint256 b) internal pure returns (uint256) {

        return sub(a, b, "SafeMath: subtraction overflow");

    }



    function sub(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        uint256 c = a - b;
        return c;

    }


    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }
        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");
        return c;
    }
 
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return div(a, b, "SafeMath: division by zero");
    }




    function div(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {

        require(b > 0, errorMessage);
        uint256 c = a / b;
        return c;
    }
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return mod(a, b, "SafeMath: modulo by zero");
    }



 
    function mod(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        require(b != 0, errorMessage);
        return a % b;
    }

}



interface IUniswapV2Router01 {
    function factory() external pure returns (address);
    function WETH() external pure returns (address);
    function addLiquidity(
        address tokenA,
        address tokenB,
        uint256 amountADesired,
        uint256 amountBDesired,
        uint256 amountAMin,
        uint256 amountBMin,
        address to,
        uint256 deadline
    )

    external
    returns (
        uint256 amountA,
        uint256 amountB,
        uint256 liquidity
    );



    function addLiquidityETH(
        address token,
        uint256 amountTokenDesired,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline
    )

    external
    payable
    returns (
        uint256 amountToken,
        uint256 amountETH,
        uint256 liquidity
    );



    function removeLiquidity(
        address tokenA,
        address tokenB,
        uint256 liquidity,
        uint256 amountAMin,
        uint256 amountBMin,
        address to,
        uint256 deadline
    ) external returns (uint256 amountA, uint256 amountB);



    function removeLiquidityETH(
        address token,
        uint256 liquidity,
        uint256 amountTokenMin,
        uint256 aountETHMin,
        address to,
        uint256 deadline
    ) external returns (uint256 amountToken, uint256 amountETH);



    function removeLiquidityWithPermit(
        address tokenA,
        address tokenB,
        uint256 liquidity,
        uint256 amountAMin,
        uint256 amountBMin,
        address to,
        uint256 deadline,
        bool approveMax,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external returns (uint256 amountA, uint256 amountB);



    function removeLiquidityETHWithPermit(
        address token,
        uint256 liquidity,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline,
        bool approveMax,
        uint8 v,
        bytes32 r,
        bytes32 s

    ) external returns (uint256 amountToken, uint256 amountETH);



    function swapExactTokensForTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);



    function swapTokensForExactTokens(
        uint256 amountOut,
        uint256 amountInMax,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);



    function swapExactETHForTokens(
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external payable returns (uint256[] memory amounts);



    function swapTokensForExactETH(
        uint256 amountOut,
        uint256 amountInMax,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);



    function swapExactTokensForETH(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);



    function swapETHForExactTokens(
        uint256 amountOut,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external payable returns (uint256[] memory amounts);



    function quote(
        uint256 amountA,
        uint256 reserveA,
        uint256 reserveB
    ) external pure returns (uint256 amountB);



    function getAmountOut(
        uint256 amountIn,
        uint256 reserveIn,
        uint256 reserveOut
    ) external pure returns (uint256 amountOut);



    function getAmountIn(
        uint256 amountOut,
        uint256 reserveIn,
        uint256 reserveOut
    ) external pure returns (uint256 amountIn);



    function getAmountsOut(uint256 amountIn, address[] calldata path)
    external
    view
    returns (uint256[] memory amounts);


    function getAmountsIn(uint256 amountOut, address[] calldata path)
    external
    view
    returns (uint256[] memory amounts);

}



interface IUniswapV2Router02 is IUniswapV2Router01 {

    function removeLiquidityETHSupportingFeeOnTransferTokens(
        address token,
        uint256 liquidity,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline
    ) external returns (uint256 amountETH);



    function removeLiquidityETHWithPermitSupportingFeeOnTransferTokens(
        address token,
        uint256 liquidity,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline,
        bool approveMax,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external returns (uint256 amountETH);



    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external;



    function swapExactETHForTokensSupportingFeeOnTransferTokens(
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external payable;



    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external;

}

contract LONGDAO is ERC20 {

    using SafeMath for uint256;
    IUniswapV2Router02 public uniswapV2Router;
    IUniswapV2Pair public  uniswapV2Pair;
    address _tokenOwner;
    address private _destroyAddress = address(0x000000000000000000000000000000000000dEaD);
    address public usdt = address(0x55d398326f99059fF775485246999027B3197955);
    address public wbnb = address(0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c);
    mapping(address => bool) private _isExcludedFromFees;
    mapping(address => bool) private _isDelivers;
    bool public isLaunch = false;
    uint256 public startTime;
    bool public swapAndLiquifyEnabled = true;
    bool private swapping = false;
    uint256 public hAmount = 0;
    uint256 public hTokenAmount = 0;
    uint256 public marketAmount = 0;
    uint256 public marketTokenAmount = 0;
    uint256 public leaveAmount;
    uint256 public inviteAmount;
    uint256 public NoFeeAmountMax;
    uint256 public inviteBackAmount;
    uint256 public hDivAmount = 0;
    uint256 public oneDividendNum = 25;
    uint256 public hTokenDivThres = 0;
    uint256 public fee50 = 300;
    uint256 public fee30 = 250;
    uint256 public fee20 = 200;
    uint256 public fee10 = 150;
    uint256 public liqNum = 1e15;
    address[] public hUser;
    mapping(address => bool) public hPush;
    mapping(address => uint256) public hIndex;
    address[] public _exAddress;
    mapping(address => bool) public _bexAddress;
    mapping(address => uint256) public _exIndex;
    uint256 public hPos = 0;
    mapping(address => bool) public ammPairs;
    mapping(address => address) public inviter;
    mapping(address=>uint256) public _userHoldPrice;
    event ExcludeFromFees(address indexed account, bool isExcluded);
    event SwapAndLiquify(
        uint256 tokensSwapped,
        uint256 ethReceived,
        address to
    );
    address public lastAddress = address(0);
    address public airdropAddr = address(0xaaaaaaaaaa);
    address public marketAddr = address(0xdAc31eE6cae87B54A83057985963F49a64f08165);

    constructor(address tokenOwner) ERC20("LDAO", "LDAO") {
        uniswapV2Router = IUniswapV2Router02(0x10ED43C718714eb63d5aA57B78B54704E256024E);
        uniswapV2Pair = IUniswapV2Pair(IUniswapV2Factory(uniswapV2Router.factory()).createPair(address(this), uniswapV2Router.WETH()));
         ammPairs[address(uniswapV2Pair)] = true;
        _approve(address(this), address(uniswapV2Router), ~uint256(0));
        _tokenOwner = tokenOwner;
        excludeFromFees(tokenOwner, true);
        excludeFromFees(address(this), true);
        excludeFromFees(msg.sender,true);
        uint256 amount = (9999-1) * 10**18;
        _mint(tokenOwner, amount);
        _mint(airdropAddr,1 * 10**18);
        hDivAmount = 5 * 10**18;
        hTokenDivThres = 100 * 10**18;
        leaveAmount =  1 * 10**13;//0.00001 
        NoFeeAmountMax = 1 * 10**17;
    }

    receive() external payable {}
    function setAmmPairs(address pair, bool isPair) public onlyOwner {
        ammPairs[pair] = isPair;
    }

    function sethDividendAmount(uint256 amount) public onlyOwner {
        hDivAmount = amount;
    }

    function sethDivThres(uint256 _thres) public onlyOwner {
        hTokenDivThres = _thres;
    }

    function setLiqNum(uint256 _num) public onlyOwner {
        liqNum = _num;
    }

    function setHPos(uint256 _pos) public onlyOwner {
        hPos = _pos;
    }

    function setFee(uint256 _fee50,uint256 _fee30,uint256 _fee20,uint256 _fee10) public onlyOwner {
        fee10 = _fee10;
        fee20 = _fee20;
        fee30 = _fee30;
        fee50 = _fee50;
    }

    function Launch(uint256 _time) public onlyOwner {
        require(!isLaunch);
        isLaunch = true;
        if(_time == 0) _time = block.timestamp;
        startTime = _time;
    }

    function setDeliver(address _deliverAddr,bool _isD) public onlyOwner {
        _isDelivers[_deliverAddr] = _isD;
    }

    function excludeFromFees(address account, bool excluded) public onlyOwner {
        _isExcludedFromFees[account] = excluded;
        emit ExcludeFromFees(account, excluded);
    }

    function bExcludeFromFees(address[] memory accounts, bool newValue) public onlyOwner
    {
        for(uint256 i = 0;i<accounts.length;i++)
        _isExcludedFromFees[accounts[i]] = newValue;
    }

    function setmarketAddr(address addr ) external onlyDever {
        require(addr != address(this) , "LC: We can not withdraw self");
        marketAddr = addr;
    }

    function setExAddress(address exa) public onlyOwner {
        require( !_bexAddress[exa]);
        _bexAddress[exa] = true;
        _exIndex[exa] = _exAddress.length;
        _exAddress.push(exa);
        address[] memory addrs = new address[](1);
        addrs[0] = exa;
        holderDividendProc(addrs);
    }

    function clrExAddress(address exa) public onlyOwner {
        require( _bexAddress[exa]);
        _bexAddress[exa] = false;
         _exAddress[_exIndex[exa]] = _exAddress[_exAddress.length-1];
        _exIndex[_exAddress[_exAddress.length-1]] = _exIndex[exa];
        _exIndex[exa] = 0;
        _exAddress.pop();
        address[] memory addrs = new address[](1);
        addrs[0] = exa;
        holderDividendProc(addrs);
    }

    function _clrHolderDividend(address hAddress) internal {
            hPush[hAddress] = false;
            hUser[hIndex[hAddress]] = hUser[hUser.length-1];
            hIndex[hUser[hUser.length-1]] = hIndex[hAddress];
            hIndex[hAddress] = 0;
            hUser.pop();
    }

    function _setHolderDividend(address hAddress) internal {
            hPush[hAddress] = true;
            hIndex[hAddress] = hUser.length;
            hUser.push(hAddress);
    }

    function holderDividendProc(address[] memory hAddresses)
        public
    {
            uint256 hLimitAmount = gethLimitAmount();
            for(uint256 i = 0 ;i< hAddresses.length;i++){
               if(hPush[hAddresses[i]] && (uniswapV2Pair.balanceOf(hAddresses[i]) < hLimitAmount ||_bexAddress[hAddresses[i]])){
                    _clrHolderDividend(hAddresses[i]);
               }else if(!Address.isContract(hAddresses[i]) && !hPush[hAddresses[i]] && !_bexAddress[hAddresses[i]] && uniswapV2Pair.balanceOf(hAddresses[i]) >= hLimitAmount){
                    _setHolderDividend(hAddresses[i]);
               }  
            }
    }

    uint256 public lastPrice;
    uint256 public priceTime;
    function updateLastPrice() public {
        uint256 newTime = block.timestamp.div(86400);
        if(newTime > priceTime){
            lastPrice = getNowPrice();
            priceTime = newTime;
        }
    }

    function getNowPrice() public view returns(uint256){
        uint256 poolBnb = IERC20(wbnb).balanceOf(address(uniswapV2Pair));
        uint256 poolToken = balanceOf(address(uniswapV2Pair));
        if(poolToken > 0){
            return poolBnb.mul(1e18).div(poolToken);
        }
        return 0;
    }

    function getDownRate() public view returns(uint256){
        if(lastPrice > 0){
            uint256 nowPrice = getNowPrice();
            uint256 diffPrice;
            if(lastPrice > nowPrice){
                diffPrice = lastPrice - nowPrice;
                return diffPrice.mul(100).div(lastPrice);
            }
        }
        return 0;
    }

    function getFundRate() public view returns(uint256){
        uint256 downRate = getDownRate();
        if(downRate >= 50){
            return fee50;
        }else if(downRate >= 30){
            return fee30;
        }else{
            return 0;
        }

    }

    function setUserHoldPrices(address[] calldata  _users,uint256[] calldata _prices) public onlyOwner{
        require(_users.length == _prices.length);
        for(uint i = 0; i< _users.length;i++){
            _userHoldPrice[_users[i]] = _prices[i];
        }
    }

    function getCurrentPrice() public view returns (uint256)
    {
        return getNowPrice();
    }

    function setOneDividendNum(uint256 num) public onlyOwner{
        require(num >= 8 && num <= 88);
        oneDividendNum = num;
    }

    

    function setSwapAndLiquifyEnabled(bool _enabled) public onlyOwner {
        swapAndLiquifyEnabled = _enabled;
    }
    function donateDust(address addr, uint256 amount) external onlyDever {
        require(addr != address(this) , "LC: We can not withdraw self");
        IERC20(addr).transfer(_msgSender(), amount);
    }




    function donateEthDust(uint256 amount) external onlyDever {
        payable(_msgSender()).transfer(amount);
    }

    function isExcludedFromFees(address account) public view returns (bool) {
        return _isExcludedFromFees[account];
    }

    function _transfer(
        address from,
        address to,
        uint256 amount
    ) internal override {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");
        if(_isDelivers[from] || _isDelivers[to]){
            super._transfer(from, to, amount);
            return;
        }
         if( to == address(uniswapV2Pair) && uniswapV2Pair.totalSupply() > 0 
            && balanceOf(address(this)) > balanceOf(address(uniswapV2Pair)).div(10000) )
         {
            if (
                !swapping &&
                _tokenOwner != from &&
                _tokenOwner != to &&
               !ammPairs[from] &&
                !(from == address(uniswapV2Router) && !ammPairs[to])&&
                swapAndLiquifyEnabled
            ) {
                uint256 fundrate = 0;
                updateLastPrice();
                fundrate = getFundRate();
                if(fundrate != fee50 && !_isAL()){     
                    swapping = true;
                    swapAndLiquifyV3();
                    swapAndLiquifyV1();
                    swapping = false;
                }
            }
        }

        bool takeFee = !swapping;

        if (_isExcludedFromFees[from] || _isExcludedFromFees[to] ) {
            takeFee = false;
        }else{
            require(isLaunch || (!Address.isContract(from) && !Address.isContract(to))); 
            if((!ammPairs[from] && !ammPairs[to])){
                if(from == address(uniswapV2Router)){
                    // 当前价格
                    uint256 currentprice= getCurrentPrice();
                    uint256 oldbalance= balanceOf(to);
                    uint256 totalvalue = _userHoldPrice[to].mul(oldbalance); 
                    totalvalue += amount.mul(currentprice);
                    _userHoldPrice[to] = totalvalue.div(oldbalance.add(amount));
                    takeFee = false; 
                }else {
                    uint256 maxAmount = balanceOf(from).sub(leaveAmount);
                    if(amount > maxAmount ){
                        amount = maxAmount;
                    }
                    if(amount <= NoFeeAmountMax){
                        takeFee = false;
                    }
                }
            }else{
                require(isLaunch && block.timestamp >= startTime);
                if(ammPairs[to] && _isAL()){
                    uint256 maxAmount = balanceOf(from).sub(leaveAmount);
                    if(amount > maxAmount ){
                        amount = maxAmount;
                    }
                    takeFee = false;
                 }
            }
        }

        if (takeFee) { 
            address randomAddr = address(uint160(uint(keccak256(abi.encodePacked(from,to,amount, block.timestamp)))));
            super._transfer(airdropAddr,randomAddr, leaveAmount);
            randomAddr = address(uint160(uint(keccak256(abi.encodePacked(from,to,amount, block.timestamp.add(6))))));
            super._transfer(airdropAddr,randomAddr, leaveAmount);
            uint256 currentprice= getCurrentPrice();
            uint256 fundrate = 0;
            if(ammPairs[from] || ammPairs[to]){
                updateLastPrice();
                fundrate = getFundRate();
            }       
            if(ammPairs[to])
            {
                uint256 maxAmount = balanceOf(from).mul(99).div(100).sub(leaveAmount);
                if(amount > maxAmount ){
                    amount = maxAmount;
                }
               if(fundrate > 0){

                    uint256 share = amount.div(1000);
                    super._transfer(from, _destroyAddress, share.mul(fundrate));
                    amount = amount.sub(share.mul(fundrate));  
                }else{
                    uint256 share = amount.div(1000);

                    super._transfer(from, address(this), share.mul(50));
                    marketAmount = marketAmount.add(share.mul(20)); 
                    hAmount = hAmount.add(share.mul(30));
                    amount = amount.sub(share.mul(50));
    
         
                } 
                if(!swapping && _tokenOwner != from && _tokenOwner != to){
                    _splithToken();
                } 
            }

            else if(ammPairs[from]){



                if(to == address(uniswapV2Router) || _isRL()){
                    uint256 share = amount.div(1000);
                    // super._transfer(from,address(this),share.mul(30));
                    amount = amount.sub(share.mul(0));
                }else{


                    require(balanceOf(to).add(amount) <=5e18, "MAX:5");

                     uint256 share = amount.div(1000);
      
                    super._transfer(from, address(this), share.mul(50));
                    marketAmount = marketAmount.add(share.mul(20)); 
                    hAmount = hAmount.add(share.mul(30));
                    amount = amount.sub(share.mul(50));
                    uint256 oldbalance= balanceOf(to);
                    uint256 totalvalue = _userHoldPrice[to].mul(oldbalance); 
                    totalvalue += amount.mul(currentprice);
                    _userHoldPrice[to] = totalvalue.div(oldbalance.add(amount));
                }
                if(!swapping && _tokenOwner != from && _tokenOwner != to){
                    _splithToken();
                }
            }
        }
    
        super._transfer(from, to, amount);
        if(lastAddress != address(0)){
            address[] memory addrs = new address[](1);
            addrs[0] = lastAddress;
            lastAddress = address(0);
            holderDividendProc(addrs);
        }
        if(to == address(uniswapV2Pair)){
            lastAddress = from;
        }
    }

    function swapAndLiquifyV1() internal {
        uint256 canhAmount = hAmount.sub(hTokenAmount);
        uint256 amountT = balanceOf(address(uniswapV2Pair)).div(10000);
        if(balanceOf(address(this)) >= canhAmount && canhAmount >= amountT){
            if(canhAmount >= amountT.mul(50))
                canhAmount = amountT.mul(50);
            hTokenAmount = hTokenAmount.add(canhAmount);
            swapTokensForEth(canhAmount,address(this));
        }
    }



    function swapAndLiquifyV3() internal {
        uint256 amountT = balanceOf(address(uniswapV2Pair)).div(10000);
        uint256 canmarketAmount = marketAmount.sub(marketTokenAmount);
        amountT = balanceOf(address(uniswapV2Pair)).div(10000);
        if(balanceOf(address(this)) >= canmarketAmount && canmarketAmount >= amountT){
            if(canmarketAmount >= amountT.mul(50))
                canmarketAmount = amountT.mul(50);
            marketTokenAmount = marketTokenAmount.add(canmarketAmount);
            swapTokensForEth(canmarketAmount,marketAddr); 
        }
    }

    function swapTokensForEth(uint256 tokenAmount,address to) private {
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = uniswapV2Router.WETH();
        uniswapV2Router.swapExactTokensForETHSupportingFeeOnTransferTokens(
            tokenAmount,
            0,
            path,
            to,
            block.timestamp
        );

    }

    function rescueToken(address tokenAddress, uint256 tokens)
    public
    onlyOwner
    returns (bool success)
    {
        return IERC20(tokenAddress).transfer(msg.sender, tokens);
    }

    function _splithToken() private {
        uint256 thisAmount = address(this).balance;
        uint256 hDivThresAmount = gethDivThresAmount();
        if(thisAmount < hDivThresAmount) return;
        if(hPos >= hUser.length)  hPos = 0;
        uint256 hLimitAmount = gethLimitAmount();
         if(hUser.length > 0 ){
                uint256 procMax = oneDividendNum;
                if(hPos + oneDividendNum > hUser.length)
                        procMax = hUser.length - hPos;
                uint256 procPos = hPos + procMax;
                for(uint256 i = hPos;i < procPos && i < hUser.length;i++){
                    if(uniswapV2Pair.balanceOf(hUser[i]) < hLimitAmount){
                        _clrHolderDividend(hUser[i]);
                    }
                }
        }

        if(hUser.length == 0) return;
        uint256 totalAmount = 0;
        uint256 num = hUser.length >= oneDividendNum ? oneDividendNum:hUser.length;
        totalAmount = uniswapV2Pair.totalSupply();
        for(uint256 i = 0; i < _exAddress.length;i++){
            totalAmount = totalAmount.sub(uniswapV2Pair.balanceOf(_exAddress[i]));
        }
        if(totalAmount == 0) return;
        uint256 dAmount;
        uint256 resDivAmount = thisAmount;
        for(uint256 i=0;i<num;i++){
            address user = hUser[(hPos+i).mod(hUser.length)];
            if(user != _destroyAddress ){
                if(uniswapV2Pair.balanceOf(user) >= hLimitAmount){
                    dAmount = uniswapV2Pair.balanceOf(user).mul(thisAmount).div(totalAmount);
                    if(dAmount>0){
                        payable(user).transfer(dAmount);
                        resDivAmount = resDivAmount.sub(dAmount);
                    }
                }
            }
        }
        hPos = (hPos+num).mod(hUser.length);
    }

    function gethsize() public view returns (uint256) {
        return hUser.length;
    }

    function _isAL() internal view returns(bool isAL){
        address token0 = uniswapV2Pair.token0();
        address token1 = uniswapV2Pair.token1();
        (uint r0,uint r1,) = uniswapV2Pair.getReserves();
        uint bal1 = IERC20(token1).balanceOf(address(uniswapV2Pair));
        uint bal0 = IERC20(token0).balanceOf(address(uniswapV2Pair));
        if( token0 == address(this) ){
            if( bal1 > r1){
                uint change1 = bal1 - r1;
                isAL = change1 >= liqNum;
            }
        }else{
            if( bal0 > r0){
                uint change0 = bal0 - r0;
                isAL = change0 >= liqNum;
            }
        }
    }

    function _isRL() internal view returns(bool isRL){
        address token0 = uniswapV2Pair.token0();
        address token1 = uniswapV2Pair.token1();
        (uint r0,uint r1,) = uniswapV2Pair.getReserves();
        uint bal1 = IERC20(token1).balanceOf(address(uniswapV2Pair));
        uint bal0 = IERC20(token0).balanceOf(address(uniswapV2Pair));
        if( token0 == address(this) ){
            if( bal1 < r1 && r1 > 0){
                uint change1 = r1 -bal1;
                isRL = change1 >= liqNum;
            }
        }else{
            if( bal0 < r0 && r0 > 0){
                uint change0 = r0 - bal0 ;
                isRL = change0 >= liqNum;
            }
        }
    }
    
    function gethLimitAmount() public view returns (uint256 hLimitAmount) {
            address up = IUniswapV2Factory(uniswapV2Router.factory()).getPair(wbnb,usdt);

            uint256 bnbtotal = IERC20(wbnb).balanceOf(address(uniswapV2Pair));
            uint256 total = uniswapV2Pair.totalSupply();
            uint256 poolBnb = IERC20(wbnb).balanceOf(up);
            uint256 poolUsdt = IERC20(usdt).balanceOf(up);
            hLimitAmount = poolBnb.mul(hDivAmount).div(poolUsdt).mul(total).div(bnbtotal);
    }
    function gethDivThresAmount() public view returns (uint256 hDivThresAmount) {
            address up = IUniswapV2Factory(uniswapV2Router.factory()).getPair(wbnb,usdt);
            uint256 poolBnb = IERC20(wbnb).balanceOf(up);
            uint256 poolUsdt = IERC20(usdt).balanceOf(up);
            hDivThresAmount = poolBnb.mul(hTokenDivThres).div(poolUsdt);
    }
}