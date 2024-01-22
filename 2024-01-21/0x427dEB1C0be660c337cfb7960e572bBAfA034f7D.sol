/**
 *Submitted for verification at BscScan.com on 2024-01-15
*/

/**
 *Submitted for verification at BscScan.com on 2024-01-12
*/

/**
 *https://AlitaToken.com
*/

pragma solidity 0.8.4;

/**
 * @dev Collection of functions related to the address type
 */

library SafeMath {
    /**
     * @dev Returns the addition of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `+` operator.
     *
     * Requirements:
     * - Addition cannot overflow.
     */
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting on
     * overflow (when the result is negative).
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     * - Subtraction cannot overflow.
     */
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return sub(a, b, "SafeMath: subtraction overflow");
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting with custom message on
     * overflow (when the result is negative).
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     * - Subtraction cannot overflow.
     *
     * _Available since v2.4.0._
     */
    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        uint256 c = a - b;

        return c;
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `*` operator.
     *
     * Requirements:
     * - Multiplication cannot overflow.
     */
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
        // benefit is lost if 'b' is also tested.
        // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");

        return c;
    }

    /**
     * @dev Returns the integer division of two unsigned integers. Reverts on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator. Note: this function uses a
     * `revert` opcode (which leaves remaining gas untouched) while Solidity
     * uses an invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     * - The divisor cannot be zero.
     */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return div(a, b, "SafeMath: division by zero");
    }

    /**
     * @dev Returns the integer division of two unsigned integers. Reverts with custom message on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator. Note: this function uses a
     * `revert` opcode (which leaves remaining gas untouched) while Solidity
     * uses an invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     * - The divisor cannot be zero.
     *
     * _Available since v2.4.0._
     */
    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        // Solidity only automatically asserts when dividing by 0
        require(b > 0, errorMessage);
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold

        return c;
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * Reverts when dividing by zero.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     * - The divisor cannot be zero.
     */
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return mod(a, b, "SafeMath: modulo by zero");
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * Reverts with custom message when dividing by zero.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     * - The divisor cannot be zero.
     *
     * _Available since v2.4.0._
     */
    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b != 0, errorMessage);
        return a % b;
    }
}
/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IERC20 {
    /**
     * @dev Emitted when `value` tokens are moved from one account (`from`) to
     * another (`to`).
     *
     * Note that `value` may be zero.
     */
    event Transfer(address indexed from, address indexed to, uint256 value);

    /**
     * @dev Emitted when the allowance of a `spender` for an `owner` is set by
     * a call to {approve}. `value` is the new allowance.
     */
    event Approval(address indexed owner, address indexed spender, uint256 value);

    /**
     * @dev Returns the amount of tokens in existence.
     */
    function totalSupply() external view returns (uint256);
    function symbol() external view returns (string memory);
    /**
     * @dev Returns the amount of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Moves `amount` tokens from the caller's account to `to`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address to, uint256 amount) external returns (bool);

    /**
     * @dev Returns the remaining number of tokens that `spender` will be
     * allowed to spend on behalf of `owner` through {transferFrom}. This is
     * zero by default.
     *
     * This value changes when {approve} or {transferFrom} are called.
     */
    function allowance(address owner, address spender) external view returns (uint256);

    /**
     * @dev Sets `amount` as the allowance of `spender` over the caller's tokens.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * IMPORTANT: Beware that changing an allowance with this method brings the risk
     * that someone may use both the old and the new allowance by unfortunate
     * transaction ordering. One possible solution to mitigate this race
     * condition is to first reduce the spender's allowance to 0 and set the
     * desired value afterwards:
     * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
     *
     * Emits an {Approval} event.
     */
    function approve(address spender, uint256 amount) external returns (bool);

    /**
     * @dev Moves `amount` tokens from `from` to `to` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);
}
interface ISwapFactory {
    function getPair(address tokenA, address tokenB) external view returns (address pair);
}
interface IRouter {
    function factory() external pure returns (address);
    function WETH() external pure returns (address);

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

    function addLiquidityETH(
        address token,
        uint amountTokenDesired,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external payable returns (uint amountToken, uint amountETH, uint liquidity);
    function removeLiquidityETH(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external returns (uint amountToken, uint amountETH);
    function removeLiquidity(
        address tokenA,
        address tokenB,
        uint liquidity,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline
    ) external returns (uint amountA, uint amountB);
    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
    function swapExactTokensForTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;

    function swapExactETHForTokensSupportingFeeOnTransferTokens(
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external payable;

    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
    function swapTokensForExactTokens(
        uint amountOut,
        uint amountInMax,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory amounts);
    function swapExactTokensForETH(uint amountIn, uint amountOutMin, address[] calldata path, address to, uint deadline)
        external
        returns (uint[] memory amounts);
    function swapExactETHForTokens(uint amountOutMin, address[] calldata path, address to, uint deadline)
        external
        payable
        returns (uint[] memory amounts);
    function getAmountsOut(uint amountIn, address[] calldata path) external view returns (uint[] memory amounts);
}
pragma solidity ^0.8.0;

/**
 * @dev Provides information about the current execution context, including the
 * sender of the transaction and its data. While these are generally available
 * via _msgSender() and msg.data, they should not be accessed in such a direct
 * manner, since when dealing with meta-transactions the account sending and
 * paying for execution may not be the actual sender (as far as an application
 * is concerned).
 *
 * This contract is only required for intermediate, library-like contracts.
 */
abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}
pragma solidity ^0.8.0;
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
interface ANGE {
    function users(address,address)external view returns (uint,uint,uint,uint);
    function upaddress(address)external view returns (address,address);
    function stakedOfTime(address,address)external view returns (uint);
    function teams(address)external view returns (uint,uint,uint);
}
interface pairs{
   function setIRouter(address _IRouter)external;
   function swap(address token,uint amount)external  returns (uint);
   function swapBNB(address token,uint amount)external  returns (uint);
   function getTokenPriceTokenALITA(address token,uint value) view external   returns(uint);
   function getTokenPriceToken(address token,uint value) view external   returns(uint);
   function getTokenPriceTokenBNB(address token,uint value) view external   returns(uint);
}
contract  MktCap{
    address public  auditor;
    address public ceo;
    address public WBNB=0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c;
    address public USDT=0x55d398326f99059fF775485246999027B3197955;
    mapping (uint=>uint)public bl;
    mapping (address=>user)public users;
    mapping (address=>bool)public list;
    struct user{
        uint bnb;
        uint usdt;
        uint tz;
        uint out;
    }
    constructor(address _ceo,address _auditor){
        ceo=_ceo;
        auditor=_auditor;
        bl[50]=50;
        bl[100]=40;
        bl[101]=48000 ether;
        bl[102]=10000000 ether;
    }
    receive() external payable{ 
    }
    function getToken(address token,uint amount)public{
        require(msg.sender == auditor);
        IERC20(token).transfer(msg.sender,amount);
    }
    function getBNB(address to,uint amount)public{
        require(msg.sender == auditor);
        payable (to).transfer(amount);
    }
    function getList(address to,bool b)public{
        require(msg.sender == auditor);
        list[to]=b;
    }
    function setBL(uint lab,uint amount)public{
        require(msg.sender == auditor);
         bl[lab]=amount;
    }
    function senBon(address token,address to,uint amount,uint level)public{
        require(msg.sender == ceo);
        if(users[to].out < bl[101] && level==3){
          if(token==WBNB && !list[to]){
             users[to].bnb+=amount*bl[100]/100;
             users[to].out+=getPrice(amount*bl[100]/100);
             bl[102]-=getPrice(amount*bl[100]/100);
             payable (to).transfer(amount*bl[100]/100);
            }
            if(token==USDT && !list[to]){
              users[to].usdt+=amount*bl[100]/100;
              users[to].out+=amount*bl[100]/100;
              bl[102]-=amount*bl[100]/100;
              IERC20(token).transfer(to,amount*bl[100]/100);
            }
        }
        if(level ==4 && !list[to]){
           setMier(token,to,4,amount);
        }
        if(level ==5 && !list[to]){
           setMier(token,to,3,amount);
        }
        if(level ==6 && !list[to]){
           setMier(token,to,2,amount);
        }
        if(level ==7 && !list[to]){
           setMier(token,to,1,amount);
        }
    }
    function setMier(address token,address to,uint _bl,uint value)internal {
        if(token==WBNB){
             users[to].bnb+=value*_bl/100;
             users[to].out+=getPrice(value*_bl/100);
             bl[102]-=getPrice(value*_bl/100);
             payable (to).transfer(value*_bl/100);
            }
            if(token==USDT){
              users[to].usdt+=value*_bl/100;
              users[to].out+=value*_bl/100;
              bl[102]-=value*bl[100]/100;
              IERC20(token).transfer(to,value*_bl/100);
            }
    }
    function getPrice(uint bnb) view private  returns(uint){
           address[] memory routePath = new address[](2);
           routePath[0] = WBNB;
           routePath[1] = USDT;
           return IRouter(0x10ED43C718714eb63d5aA57B78B54704E256024E).getAmountsOut(bnb,routePath)[1];    
    }
}

contract AlitaMiner is Ownable {
    using SafeMath for uint256;
    IRouter public IRouters;
    uint private constant RATE_DAY= 86400;
    address public auditor;
    address public bunToken;
    mapping (address=>mapping (address=>uint)) public NFTsw;
    address public DEX;
    address public mydex=0xF3969a676aD8bDF315FB119E6Aa5f9e36e90e9E8;
    address public ANGEL=0x1aE85b0f0DC27F9b22db3408c7B795A222026B02;
    address public WBNB;
    address public USDT;
    address public ALITA;
    uint public startTime;
    address public chAlita=0xBE6C68e7a93292b060548b183FB0951c4c1b791d;
    mapping (address=>mapping (address=>mapping (uint=>uint))) public stakedOf;
    mapping (address=>mapping (address=>uint)) public stakedOfTime;
    mapping (address=>UP)public upaddress;
    mapping (address=>mapping (address=>user))public users;
    mapping (address=>user)public usersAddr;
    mapping (address=>bool)public listToken;
    mapping (address=>bool)public PairToken;
    mapping (address=>mapping(address=>team))public teamsw;
    mapping (address=>team)public teams;
    mapping (uint=>uint)public level;
    mapping (uint=>uint)public bl;
    mapping (address=>bool)public miners;
    MktCap public mkt;
    struct UP{
        address dev;
        address ups;
    }
    struct user{
        uint mnu;
        uint yz;
        uint tz;
        uint out;
        address[] arrs;
    }
    struct team{
        uint A1;
        uint lv;
        uint value;
        uint _time;
        uint sum;
    }
    constructor() {   
        auditor=msg.sender;
        ALITA=0x33679898CEb9DC930024dE84E7339d403191d8f6;
        bunToken=0x000000000000000000000000000000000000dEaD;
        DEX=0x10ED43C718714eb63d5aA57B78B54704E256024E;
        WBNB=0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c;
        USDT=0x55d398326f99059fF775485246999027B3197955;
        startTime=1705593540;
        mkt=new MktCap(address(this),auditor);
        IRouters=IRouter(0xEF4BCF52eD00807B4d960fC509Da47347c4411eE);
    }
    receive() external payable{ 
    }
    function update(address add)public {
        (,,uint c,uint d)=ANGE(mydex).users(ANGEL,add);
        (uint a1,,)=ANGE(mydex).teams(add);
        (address dev,address ups)=ANGE(mydex).upaddress(add);
        users[ANGEL][add].mnu=1;
        users[ANGEL][add].tz=c;
        users[ANGEL][add].out=d;
        stakedOfTime[ANGEL][add]=ANGE(mydex).stakedOfTime(ANGEL,add);
        stakedOf[ANGEL][add][1] = c;
        if(upaddress[add].ups == address(0) && ups != add){
           upaddress[add].ups=ups;
           upaddress[add].dev=dev;
           usersAddr[ups].arrs.push(add);
        }
        teams[add].A1=a1;
    }
    function skyTema(address[] memory addr)public {
        require(msg.sender == auditor);
        for(uint i=0;i<addr.length;i++){
            update(addr[i]);
        }
    }
    function setMiners(address[] memory addr,bool bos)public {
        require(msg.sender == auditor);
        for(uint i=0;i<addr.length;i++){
            miners[addr[i]]=bos;
            stakedOfTime[ANGEL][addr[i]]=block.timestamp;
        }
    }
    function setLevels(address addr,uint _lv,uint au)public {
        require(msg.sender == auditor);
        teams[addr].A1=teams[addr].A1+au;
        teams[addr].lv=_lv;
        setBl(addr);
    }
    function setLevAddr(address token,address addr,address to,address _dev)public {
        require(msg.sender == auditor);
        upaddress[addr].ups=to;
        upaddress[addr].dev=_dev;
        users[token][to].tz=1;
    }
    function setBl(address to)internal {
        address[] memory addr=usersAddr[to].arrs;
        for(uint i=0;i<addr.length;i++){
          _team(upaddress[addr[i]].ups,addr[i],0);
       }
    }
    function _team(address a1,address my,uint _value)internal {
        address up=a1;
        address up1=my;
        if(up !=address(0) && teams[up].lv > 0 && teams[up].lv >= teams[my].lv){
            NFTsw[up][my]=(teams[up].lv-teams[my].lv)*10;
        }
        for(uint k=0;k<200;k++){
               if(up !=address(0)){
                   teams[up].A1+=_value;
               }             
               up1=up;
               up=upaddress[up].ups;
               if(up == address(0)){
                break ;
            }
        }
    }
    function _teamvalue(address a1,address my,uint _value)internal {
        address up=a1;
        address up1=my;
        uint lvv=1;
        uint mmb=0;
           for(uint k=0;k<200;k++){
               if(up !=address(0) && teams[up].lv >=lvv){                  
                   if(teams[up].lv == teams[up1].lv && mmb==0){
                   }else {
                      teamsw[up][up1].value+=_value;
                   } 
               }
               up1=up;
               up=upaddress[up].ups;
               if(up == address(0)){
                break;
               }
           }
    }
    function getLsPJ(address addr,address to)public view returns (uint){
      return NFTsw[addr][to];
    }
    function getLs(address addrs)public view returns (uint){
        uint amount;
        address[] memory addr=usersAddr[addrs].arrs;
            for(uint i=0;i<addr.length;i++){
                if(NFTsw[addrs][addr[i]] >0 && NFTsw[addrs][addr[i]] <81){
                   amount+=teamsw[addrs][addr[i]].value;
                }
            }
        return  amount;

    }
    function _Levels(address up,uint amount)public view returns (uint){
        uint _lv;
        if(amount >= pairs(chAlita).getTokenPriceToken(ALITA,level[8]) && teams[up].lv == 7){
            _lv=8;
        }
        if(amount >= pairs(chAlita).getTokenPriceToken(ALITA,level[7]) && teams[up].lv == 6){
            _lv=7;
        }
        if(amount >= pairs(chAlita).getTokenPriceToken(ALITA,level[6]) && teams[up].lv == 5){
            _lv=6;
        }
        if(amount >= pairs(chAlita).getTokenPriceToken(ALITA,level[5]) && teams[up].lv == 4){
            _lv=5;
        }
        if(amount >= pairs(chAlita).getTokenPriceToken(ALITA,level[4]) && teams[up].lv == 3){
            _lv=4;
        }
        if(amount >= pairs(chAlita).getTokenPriceToken(ALITA,level[3]) && teams[up].lv == 2){
            _lv=3;
        }
        if(amount >= pairs(chAlita).getTokenPriceToken(ALITA,level[2]) && teams[up].lv == 1){
            _lv=2;
        }
        if(amount >= pairs(chAlita).getTokenPriceToken(ALITA,level[1]) && teams[up].lv == 0){
            _lv=1;
        }
        return _lv;
    }
    function stake(address token,address token1,address token2,uint _amount,address up,address to)external{
        require(users[token][up].tz > 0 || to == owner());
        require(users[token][to].mnu <30);
        require(PairToken[token1]);
        require(PairToken[token2]);
        require(listToken[token]);
        require(listToken[msg.sender]);
        uint amount;
        uint inValue;
        uint fiv;
        uint tame1;
        if(upaddress[to].ups == address(0) && up != to){
           upaddress[to].ups=up;
           upaddress[to].dev=upaddress[up].dev;
           usersAddr[up].arrs.push(to);
        }
        if(token1==WBNB){
            if(token2==WBNB){
                fiv=_amount/2;
                address up1=upaddress[to].dev;
                uint levels=2;
                for(uint k=0;k<100;k++){  
                   if(up1 !=address(0) && teams[up1].lv > levels){
                    mkt.senBon(WBNB, up1, _amount,teams[up1].lv);
                    levels=teams[up1].lv;
                   }
                    up1=upaddress[up1].dev;
                   if(up1 == address(0)){
                    break ;
                    }
                }
              }else {
                fiv=_amount;
              }
            (uint _b1,,)=getPrice(ALITA,_amount);
            amount=_b1;
            tame1=_b1;
            inValue=pairs(chAlita).swapBNB(ALITA,fiv);
            if(PairToken[token2] && token2!=WBNB && token2!=USDT){
               amount=amount*2;
            }       
        }
        if(token1==USDT){
            if(token2==USDT){
                fiv=_amount/2;
                address up2=upaddress[to].dev;
                uint _level=2;
                for(uint w=0;w<100;w++){  
                   if(up2 !=address(0) && teams[up2].lv > _level){
                       mkt.senBon(USDT, up2, _amount,teams[up2].lv);
                       _level=teams[up2].lv;
                   }
                   up2=upaddress[up2].dev;
                   if(up2 == address(0)){
                       break ;
                    }
                }
            }else {
               fiv= _amount;
            }
            (,uint _u1,)=getPrice(ALITA,_amount);
            amount=_u1;
            tame1=_u1;
            inValue=pairs(chAlita).swap(ALITA,fiv);
           if(PairToken[token2] && token2!=WBNB && token2!=USDT){
               amount=amount*2;
            }
        }
        if(token1==ALITA){
            amount=_amount;
            inValue=_amount;
            tame1=_amount;
            if(PairToken[token2] && token2!=WBNB && token2!=USDT && token2!=ALITA){
               amount=amount*2;
            }
        }
        if(stakedOfTime[token][to] ==0){
            if(block.timestamp < startTime){
                 stakedOfTime[token][to]=startTime;
            }else {
               stakedOfTime[token][to]=block.timestamp;
            }
           
        }else {
            if(block.timestamp > stakedOfTime[token][to] + 3600){
              claim(token,ALITA,to);
            }
        }
        users[token][to].mnu++;
        uint buyToken=_buy(token,inValue * bl[222] / 100);
        require(buyToken > 0);
        _addL(token,buyToken,inValue*bl[333]/100,address(this));     
        stakedOf[token][to][users[token][to].mnu] += amount;
        users[token][to].tz+=amount;
        users[token][to].out+=amount*3;
        _team(upaddress[to].ups,to,tame1);
        
    }   
    function updateU(address token,address my,uint coin)internal  {
        uint ups=4;
        uint rs;
        address addr=my;
        for(uint i=0;i<ups && i<4;i++){
            if(upaddress[addr].ups!= address(0)){
                rs++;
                uint bsb;
                uint mnb=getUp(rs,coin);
                if(mnb>0){
                   bsb=getTokenPriceSell(token,getUp(rs,coin)); 
                }
                if(mnb > 0 && users[token][upaddress[addr].ups].out > bsb){
                  IERC20(token).transfer(upaddress[addr].ups,mnb);
                  users[token][upaddress[addr].ups].out-=bsb;
                }
                users[token][upaddress[addr].ups].yz+=mnb;
            }else {
                if(upaddress[addr].ups!= address(0)){
                  ups++;
                }
            }
            addr=upaddress[addr].ups;
            if(rs >=4 || upaddress[addr].ups== address(0)){
               break ;
            }
        }
    }
    function updateTeam()public {
        uint lvvs=_Levels(msg.sender,teams[msg.sender].A1);
        if(lvvs < 3){
          teams[msg.sender].lv=lvvs;
        }else {
            address[] memory addr=usersAddr[msg.sender].arrs;
            uint ys;
            uint sum;
            uint max;
            for(uint i=0;i<addr.length;i++){
               if(teams[addr[i]].A1 > max){
                 max=teams[addr[i]].A1;
               }
               sum+=teams[addr[i]].A1;
            }
            sum-=max;
            ys=_Levels(msg.sender,sum);
            if(ys >= teams[msg.sender].lv){
              teams[msg.sender].lv++;  
            }
        }
        if(teams[msg.sender].lv>2){
           upaddress[msg.sender].dev=msg.sender;
        }
        setBl(msg.sender);
        setBl(upaddress[msg.sender].ups);
        
    }
    function setListToken(address token,bool b,bool v)public{
        require(msg.sender == auditor);
        listToken[token]=b;
        PairToken[token]=v;
    }
    function setLeveValue(address token)public{
        require(listToken[token]);
        require(teams[msg.sender].lv>=1);
        require(teams[msg.sender].lv<=8);
        uint amount;
        if(teams[msg.sender]._time == 0){
           teams[msg.sender]._time=block.timestamp; 
        }
        if(block.timestamp > teams[msg.sender]._time){
              address[] memory addr=usersAddr[msg.sender].arrs;
              for(uint i=0;i<addr.length;i++){
                  if(teams[msg.sender].lv == teams[addr[i]].lv){
                  }else {
                     if(NFTsw[msg.sender][addr[i]] >0 && NFTsw[msg.sender][addr[i]] <81){
                        amount=teamsw[msg.sender][addr[i]].value * NFTsw[msg.sender][addr[i]] /100;
                        teamsw[msg.sender][addr[i]].value=0;
                        if(amount >0){
                          bool isok=IERC20(token).transfer(msg.sender,amount);
                          require(isok);
                          uint mmnn=getTokenPriceSell(token,amount);
                          require(users[token][msg.sender].out > mmnn);                        
                          users[token][msg.sender].out-=mmnn;
                          teams[msg.sender].value=0;
                          teams[msg.sender].sum+=amount;
                        }
                    }
                }
            }
            if(block.timestamp > teams[msg.sender]._time+60000){
               teams[msg.sender]._time=block.timestamp+86400;
            }
        }
          
    }
    function sell(address token,address token1,uint amount)public {
        require(token != address(0) && token1 != address(0));
        require(listToken[token]);
        require(PairToken[token1]);
        bool isok=IERC20(token).transferFrom(msg.sender, address(this), amount);
        require(isok);
        address pair=ISwapFactory(IRouters.factory()).getPair(token,token1);
        uint lp=IERC20(pair).balanceOf(address(this))*8/1000;
        IERC20(pair).approve(address(address(IRouters)), lp);
        uint totalSupply=IERC20(token).totalSupply()-IERC20(token).balanceOf(bunToken);
        if(IERC20(token).totalSupply()/10 < totalSupply){
           IERC20(token).transfer(bunToken,amount*10/100);
        }
        uint coin=amount*50/100;
        uint angel=getTokenPriceSell(token,coin);
        if(IERC20(ALITA).balanceOf(address(this)) < angel){
           IRouters.removeLiquidity(token,token1,lp,0,0,address(this),block.timestamp+100);
        }
        IERC20(ALITA).transfer(msg.sender,angel);
        IERC20(token).transfer(msg.sender,coin);
    }
    function claim(address token,address token1,address to) public    {
        require(!miners[msg.sender]);
        require(listToken[token]);
        require(PairToken[token1]);
        require(stakedOfTime[token][to]> 0);
        require(users[token][to].mnu > 0);
        require(block.timestamp > stakedOfTime[token][to]);
        uint minit=block.timestamp-stakedOfTime[token][to];
        uint coin;
        for(uint i=0;i< users[token][to].mnu;i++){
            uint banOf=stakedOf[token][to][i+1] / bl[50];
            uint send=getTokenPrice(token,banOf) / RATE_DAY;
            coin+=minit*send;
        }
        uint outAlita=getTokenPriceSell(token,coin/2);
        if(users[token][to].out <= outAlita){
            for(uint m=0;m<users[token][to].mnu;m++){
               stakedOf[token][to][m] = 0;
            }
            users[token][to].mnu=0;
            users[token][to].tz=1;
            users[token][to].out=0;
            stakedOfTime[token][to]=0;
            return ;
        }else {
        require(users[token][to].out > outAlita);
        }
        users[token][to].out-=outAlita;
        bool isok=IERC20(token).transfer(to,coin*50/100);
        require(isok);
        stakedOfTime[token][to]=block.timestamp;
        updateU(token,to,coin*50/100);
        _teamvalue(upaddress[to].ups,to,coin*40/100);
    }
    function setIlevel(uint _level,uint _value,uint _bl)public{
        require(msg.sender == auditor);
        level[_level]=_value;
        bl[_level]=_bl;
    }
    function _buy(address _token,uint amount0In) internal   returns (uint){
        IERC20(ALITA).approve(address(address(IRouters)),amount0In * 2);
        uint lastvalue=IERC20(_token).balanceOf(address(this));
           address[] memory path = new address[](2);
           path[0] = ALITA;
           path[1] = _token; 
           IRouters.swapExactTokensForTokensSupportingFeeOnTransferTokens(amount0In,0,path,address(this),block.timestamp+360);
           if(IERC20(_token).balanceOf(address(this)) >lastvalue){
               return IERC20(_token).balanceOf(address(this)) - lastvalue;
           }else {
               return 0;
           }

    }
     function _addL(address _token,uint amount0, uint amount1,address to)internal     {
        IERC20(_token).approve(address(address(IRouters)),amount0);
        IERC20(ALITA).approve(address(address(IRouters)),amount1);
        IRouters.addLiquidity(_token,ALITA,amount0,amount1,0, 0,to,block.timestamp+100);
    }
    function getToken(address token,uint amount)public onlyOwner{
        IERC20(token).transfer(msg.sender,amount);
    }
    function getPrice(address token2,uint _value) view public  returns(uint b,uint u,uint a){
           b=pairs(chAlita).getTokenPriceTokenBNB(token2,_value);
           u=pairs(chAlita).getTokenPriceToken(token2,_value);
           a=pairs(chAlita).getTokenPriceTokenALITA(token2,_value);
        return (b,u,a);   
    } 
    function getTokenPrice(address _tolens,uint bnb) view private  returns(uint){
           address[] memory routePath = new address[](2);
           routePath[0] = ALITA;
           routePath[1] = _tolens;
           return IRouters.getAmountsOut(bnb,routePath)[1];    
    }
    function getTokenPriceSell(address _tolens,uint bnb) view private  returns(uint){
           address[] memory routePath = new address[](2);
           routePath[0] = _tolens;
           routePath[1] = ALITA;
           return IRouters.getAmountsOut(bnb,routePath)[1];    
    }
    function getUp(uint _rs,uint bnb)public  view returns(uint){
           if(_rs == 1){
               return bnb*10/100;
           }
            if(_rs == 2){
               return bnb*6/100;
           }
           if(_rs == 3){
               return bnb*4/100;
           }
    }
    function getAddrsa(address to)external view returns(address[] memory,uint[] memory){
        address[] memory addr=usersAddr[to].arrs;
        uint[] memory routePath1 = new uint[](addr.length);
        for(uint i=0;i<addr.length;i++){
            routePath1[i]=teams[addr[i]].A1;
        }
        return (addr,routePath1);
    }
    function getAddr(address token,address to)external view returns(address[] memory,uint[] memory,uint[] memory){
        address[] memory addr=usersAddr[to].arrs;
        uint[] memory routePath1 = new uint[](addr.length);
        uint[] memory routePath2 = new uint[](addr.length);
        for(uint i=0;i<addr.length;i++){
            routePath1[i]=users[token][addr[i]].yz;
            routePath2[i]=users[token][addr[i]].tz;
        }
        return (addr,routePath1,routePath2);
    }
    function infos(address token,address token1,address to) external view returns(uint coin,uint a,uint banOf,uint send,uint z,uint y,uint c){
        a=stakedOfTime[token][to];
        if(users[token][to].mnu > 0){
           if(block.timestamp > a){
               uint minit=block.timestamp-a;
               for(uint i=0;i< users[token][to].mnu;i++){
                  banOf+=stakedOf[token][to][i+1] / bl[50];
               }
            send=getTokenPrice(token,banOf) / RATE_DAY;
            coin+=minit*send;
           }
       }
        c=users[token][to].out;
        z=users[token][to].yz;
        y=users[token][to].tz;
    }
    function getLevel()external view returns(uint[] memory){
        uint[] memory routePath1 = new uint[](8);
        for(uint i=0;i<8;i++){
            uint _u=pairs(chAlita).getTokenPriceToken(ALITA,level[i+1]);
            routePath1[i]=_u;
        }
       return routePath1;
    }
    function getLevelUSDT()external view returns(uint[] memory){
        uint[] memory routePath1 = new uint[](8);
        for(uint i=0;i<8;i++){
            uint _u=level[i+1];
            routePath1[i]=_u;
        }
       return routePath1;
    }
}