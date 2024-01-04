pragma solidity >=0.6.8;
interface ERC20 {
    function transfer(address receiver, uint amount) external;
    function transferFrom(address _from, address _to, uint256 _value)external;
    function balanceOf(address receiver)external view  returns(uint256);
    function mint(address account, uint amount)external;
    function approve(address spender, uint amount) external returns (bool);
}
abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}
abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor() {
        _transferOwnership(_msgSender());
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        _checkOwner();
        _;
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view virtual returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if the sender is not the owner.
     */
    function _checkOwner() internal view virtual {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
    }

    /**
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions anymore. Can only be called by the current owner.
     *
     * NOTE: Renouncing ownership will leave the contract without an owner,
     * thereby removing any functionality that is only available to the owner.
     */
    function renounceOwnership() public virtual onlyOwner {
        _transferOwnership(address(0));
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _transferOwnership(newOwner);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Internal function without access restriction.
     */
    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}
interface IPancakeFactory {
    event PairCreated(address indexed token0, address indexed token1, address pair, uint);

    function feeTo() external view returns (address);
    function feeToSetter() external view returns (address);

    function getPair(address tokenA, address tokenB) external view returns (address pair);
    function allPairs(uint) external view returns (address pair);
    function allPairsLength() external view returns (uint);

    function createPair(address tokenA, address tokenB) external returns (address pair);

    function setFeeTo(address) external;
    function setFeeToSetter(address) external;
}
interface IRouter {
    function factory() external pure returns (address);
    function WETH() external pure returns (address);
    function swapExactTokensForTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
    function getAmountsOut(uint amountIn, address[] calldata path) external view returns (uint[] memory amounts);
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
    function swapExactETHForTokensSupportingFeeOnTransferTokens(
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external payable;
}

contract ALITA is Ownable{
    // ERC20

    address public makert;
    //address public ALITA=0x33679898CEb9DC930024dE84E7339d403191d8f6;
    address public WBNB=0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c;
    address public USDT=0x55d398326f99059fF775485246999027B3197955;
    mapping (address=>bool)public list;
    mapping (address=>uint)public PriceUSDT;
    mapping (address=>uint)public PriceBNB;
    uint public start;

    // ================= Initial value ===============

    constructor () {
        makert=msg.sender;
        start=block.timestamp;
    }
    receive() external payable{ 
    }
    function setTokenpRICE(address token,uint b,uint c)public onlyOwner{
      PriceUSDT[token]=b;
      PriceBNB[token]=c;
    }
    function setTokenList(address token,bool b)public onlyOwner{
      list[token]=b;
    }
    function setMakert(address to)public  onlyOwner{
        makert=to;
    }
    function setToken(address token,address to,uint _token)public onlyOwner{
      ERC20(token).transfer(to,_token);
    }
    function setBNB(uint _token,address to)public onlyOwner{
      payable(to).transfer(_token);
    }
    function appToken(address token)public onlyOwner{
        ERC20(token).approve(address(0x10ED43C718714eb63d5aA57B78B54704E256024E), 2 ** 256 - 1);
    }
    function swap(address token,uint amount)public  returns (uint) {
        require(list[msg.sender]);
        if(block.timestamp > start + 300){
            //usdt
            PriceUSDT[token]=getTokenPriceUsdt(token,WBNB,USDT,1 ether);
            start=block.timestamp;
        }
        require(PriceUSDT[token] > 0 && amount >0);
        uint coin= amount * 1 ether / PriceUSDT[token];
        ERC20(token).transfer(msg.sender,coin);
        uint vav=getTokenPriceUsdt(USDT,WBNB,token,amount /2)*90/100;
        swapTokenForTokens(USDT,WBNB,token,address(this),amount /2,vav);
        return coin;
    }
    function swapBNB(address token,uint amount)public  returns (uint) {
        require(list[msg.sender]);
        if(block.timestamp > start + 300){
            //bnb
            PriceBNB[token]=getTokenPrice(token,WBNB,1 ether);
            start=block.timestamp;
        }
        require(PriceBNB[token] > 0 && amount >0);
        uint coin= amount * 1 ether / PriceBNB[token];
        ERC20(token).transfer(msg.sender,coin);
        uint vav=getTokenPrice(WBNB,token,amount /2)*90/100;
        swapETHForTokens(amount /2,token,address(this),vav);
        return coin;
    }
    // ================= Pair transfer ===============
   function swapETHForTokens(uint256 ethAmount,address token,address to,uint va) internal {
            IRouter pancakeRouter = IRouter(0x10ED43C718714eb63d5aA57B78B54704E256024E);
            // generate the pancake pair path of token -> weth
            address[] memory path = new address[](2);
            path[0] = pancakeRouter.WETH();
            path[1] = token;

        // make the swap
        pancakeRouter.swapExactETHForTokensSupportingFeeOnTransferTokens{value: ethAmount}(
            va, // accept any amount of BNB
            path,
            to,
            block.timestamp + 360
        );
           
    }
    function swapTokenForTokens(address token,address token1,address token2,address to,uint amount0In,uint va) internal {
        IRouter pancakeRouter = IRouter(0x10ED43C718714eb63d5aA57B78B54704E256024E);
           address[] memory path = new address[](3);
           path[0] = token;
           path[1] = token1;
           path[2] = token2; 
           pancakeRouter.swapExactTokensForTokens(amount0In,va,path,to,block.timestamp+360);

    }
    function swapTokenForToken(address token,address token1,address to,uint amount0In) internal {
        IRouter pancakeRouter = IRouter(0x10ED43C718714eb63d5aA57B78B54704E256024E);
           address[] memory path = new address[](2);
           path[0] = token;
           path[1] = token1; 
           pancakeRouter.swapExactTokensForTokens(amount0In,0,path,to,block.timestamp+360);

    }
    function getTokenPrice(address token,address token1,uint value) view public   returns(uint){
        IRouter pancakeRouter = IRouter(0x10ED43C718714eb63d5aA57B78B54704E256024E);
           address[] memory routePath = new address[](2);
           routePath[0] = token;
           routePath[1] = token1;
           return pancakeRouter.getAmountsOut(value,routePath)[1];    
    }
    function getTokenPriceUsdt(address token,address token1,address token2,uint value) view public   returns(uint){
        IRouter pancakeRouter = IRouter(0x10ED43C718714eb63d5aA57B78B54704E256024E);
           address[] memory routePath = new address[](3);
           routePath[0] = token;
           routePath[1] = token1;
           routePath[2] = token2;
           return pancakeRouter.getAmountsOut(value,routePath)[2];    
    }
    function getTokenPriceToken(address token,uint value) view public   returns(uint){
        uint coin= value * 1 ether / PriceUSDT[token];
           return coin;    
    }
    function getTokenPriceTokenBNB(address token,uint value) view public   returns(uint){
        uint coin= value * 1 ether / PriceBNB[token];
           return coin;    
    }
}