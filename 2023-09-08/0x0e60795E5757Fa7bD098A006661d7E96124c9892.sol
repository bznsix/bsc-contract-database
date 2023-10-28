/**
 *Submitted for verification at BscScan.com on 2023-08-27
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
interface pairs{
   function setIRouter(address _IRouter)external;
   function IRouter()external view returns (address);
}
contract StakingRewards is Ownable {
    using SafeMath for uint256;
    IRouter public IRouters;
    uint private constant RATE_DAY= 86400;
    //uint public startTime;
    mapping (address=>uint) public startTime;
    mapping (address=>uint) public starteam;
    address public auditor;
    address public fee;
    address public bunToken;
    mapping (address=>uint) public MAXaddr;
    mapping (address=>uint) public MAXTime;
    mapping (address=>uint) public NFTsw;
    address public maxD;
    uint public maxV;
    address public DEX;
    uint public teamValue;
    //mapping (address=>mapping (uint=>uint)) public stakedOf;
    mapping (address=>mapping (address=>mapping (uint=>uint))) public stakedOf;
    mapping (address=>mapping (address=>uint)) public stakedOfTime;
    mapping (address=>mapping (address=>mapping (uint=>uint))) public stakedOfTimeSum;
    mapping (address=>mapping (address=>uint)) public stakedSum;
    mapping (address=>address) public myReward;
    mapping (address=>address)public upaddress;
    mapping (address=>address)public TokenOwner;
    mapping (address=>mapping (address=>user))public users;
    mapping (address=>user)public usersAddr;
    mapping (address=>bool)public listToken;
    mapping (address=>bool)public PairToken;
    mapping (address=>team)public teams;
    mapping (uint=>uint)public level;//等级
    mapping (uint=>uint)public bl;//等级,100=奖金池，101=无单池，102=日最大池,104=日最大奖励
    mapping (address=>address) public fomo;
    mapping (address=>uint) public times;
    mapping (address=>uint) public fomoValue;
    address[] public add;
    uint public uid=1;
    struct user{
        uint mnu;
        uint yz;
        uint tz;
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
        bunToken=0x000000000000000000000000000000000000dEaD;
        DEX=0x10ED43C718714eb63d5aA57B78B54704E256024E;
    }
    receive() external payable{ 
    }
    function setLevels(address token,address addr,uint _lv,uint au)public {
        require(msg.sender == TokenOwner[token]);
        teams[addr].A1=au;
        teams[addr].lv=_lv;
    }
    function _team(address a1,uint _value)internal {
        address up=a1;
        uint bnbb=81;
        uint lvvx=0;
        uint lkj=0;
           for(uint k=0;k<100;k++){
               if(up !=address(0)){
                   teams[up].A1+=_value;
                   if(teams[up].lv > lvvx){
                     lvvx=teams[up].lv;
                     lkj+=lvvx*10;
                     if(bnbb > lkj){
                         bnbb-=lvvx*10;
                         NFTsw[up]=lvvx*10;
                     }else {
                         NFTsw[up]=81 - bnbb;
                     }
                   }
               }
               up=upaddress[up];
               if(up == address(0)){
                break ;
               }
           }
    }
    function _teamvalue(address a1,uint _value)internal {
        address up=a1;
        uint lvv=1;
           for(uint k=0;k<100;k++){
               if(up !=address(0) && teams[up].lv >=lvv){
                   teams[up].value+=_value;
               }
               if(teams[up].lv >lvv){
                  lvv=teams[up].lv;
               }
               up=upaddress[up];
               if(up == address(0)){
                break;
               }
           }
    }
    function _Levels(address up,uint amount)public view returns (uint){
        uint _lv;
        if(amount >= level[8] && teams[up].lv == 7){
            _lv=8;
        }
        if(amount >= level[7] && teams[up].lv == 6){
            _lv=7;
        }
        if(amount >= level[6] && teams[up].lv == 5){
            _lv=6;
        }
        if(amount >= level[5] && teams[up].lv == 4){
            _lv=5;
        }
        if(amount >= level[4] && teams[up].lv == 3){
            _lv=4;
        }
        if(amount >= level[3] && teams[up].lv == 2){
            _lv=3;
        }
        if(amount >= level[2] && teams[up].lv == 1){
            _lv=2;
        }
        if(amount >= level[1] && teams[up].lv == 0){
            _lv=1;
        }
        return _lv;
    }
    function stake(address token,address token1,address token2,address up)payable  external{
        require(users[token][up].tz > 0 || msg.sender == owner());
        require(users[token][msg.sender].mnu <30);
        require(PairToken[token1]);
        require(PairToken[token2]);
        require(myReward[token] == token1);
        require(listToken[token]);
        uint amount=msg.value;
        require(amount >= 0.5 ether,"amount can not be 0");
        if(stakedOfTime[token][msg.sender] ==0){
           stakedOfTime[token][msg.sender]=block.timestamp;
        }else {
            if(block.timestamp > stakedOfTime[token][msg.sender] + 1800){
              claim(token,token1);
            }
        }
        poolsBNB(token,amount*2/100,amount);
        fomo[token]=msg.sender;
        times[token]=block.timestamp + 3600;       
        users[token][msg.sender].mnu++;
        payable (auditor).transfer(amount * 1 / 100);
        payable (TokenOwner[token]).transfer(amount * 7 / 100);
        //TokenOwner[_token]
      uint buyToken=_buy(token,amount * 45 / 100,address(this));
      require(buyToken > 0);
        _addL(token,buyToken,amount*45/100,address(this));       
        stakedOfTimeSum[token][msg.sender][users[token][msg.sender].mnu]=RATE_DAY * 3650;
        stakedOf[token][msg.sender][users[token][msg.sender].mnu] += amount;
        stakedSum[token][address(this)]+=amount;
        if(upaddress[msg.sender] == address(0) && up != msg.sender){
           upaddress[msg.sender]=up;
           usersAddr[up].arrs.push(msg.sender);
        }
        users[token][msg.sender].tz+=amount;
        _team(upaddress[msg.sender],amount);
    }
    function poolsBNB(address token,uint _p,uint amount)internal {
       bl[100]+=_p*50/100;
        bl[101]+=_p*30/100;
        bl[102]+=_p*20/100;
        uint po=bl[100]/10+fomoValue[token];
        if(getFomo(token) ==1 && bl[100] > po){
          payable (msg.sender).transfer(po);
          bl[100]-=bl[100]/10;
          fomoValue[token]=0;
        }
        if(MAXTime[msg.sender]==0){
          MAXaddr[msg.sender]=amount;
          MAXTime[msg.sender]=bl[104];
        }
        if(block.timestamp > MAXTime[msg.sender]){
            MAXaddr[msg.sender]=amount;
            MAXTime[msg.sender]=bl[104];
        } else {
            MAXaddr[msg.sender]+=amount;
        }
        if(MAXaddr[msg.sender] > maxV){
            maxV=MAXaddr[msg.sender];
            maxD=msg.sender;
        }
    }
    function updateU(address token,address my,uint coin)internal  {
        uint ups=4;
        uint rs;
        address addr=my;
        for(uint i=0;i<ups && i<4;i++){
            if(upaddress[addr]!= address(0) && users[token][addr].tz >= 0.5 ether){
                rs++;
                if(getUp(rs,coin) > 0){
                  IERC20(token).transfer(upaddress[addr],getUp(rs,coin));
                }
              users[token][upaddress[addr]].yz+=getUp(rs,coin);
            }else {
                if(upaddress[addr]!= address(0)){
                  ups++;
                }
            }
            addr=upaddress[addr];
            if(rs >=4 || upaddress[addr]== address(0)){
               break ;
            }
        }
    }
    function pingLevel(address token)private  {
        IERC20(token).transfer(msg.sender,teams[msg.sender].value *10 /100);
    }
    function updateTeam()public {
        address[] memory teamq=usersAddr[msg.sender].arrs;
        address max;
        address min;
        uint nn;
        uint nn2;
        uint nn3;
        for(uint i=0;i<teamq.length;i++){
            uint mm=teams[teamq[i]].A1;
            if(mm > nn){
                nn=mm;
                max=teamq[i];
            }
        }
        for(uint u=0;u<teamq.length;u++){
            uint mm2=teams[teamq[u]].A1;
            if(mm2 > nn2 && teamq[u] != max){
                nn2=mm2;
                min=teamq[u];
                nn3+=mm2;
            }else {
                if(teamq[u] != max){
                    nn3+=mm2;
                }
            }
        }
        uint lvv=_Levels(msg.sender,nn3);
        if(min != address(0) && lvv > teams[msg.sender].lv && teams[msg.sender].lv >= 5){
           teams[msg.sender].lv=lvv;
        }else {
            if(teams[msg.sender].lv < 5){
               uint lvvs=_Levels(msg.sender,teams[msg.sender].A1);
               teams[msg.sender].lv=lvvs;
            }
        }
        if(teams[msg.sender].lv == teams[upaddress[msg.sender]].lv){
          starteam[upaddress[msg.sender]]=1;
        }else {
            starteam[upaddress[msg.sender]]=0;
        }
    }
    function setTokenOwner(address token,address addr,uint _time)public{
        require(msg.sender == auditor);
        TokenOwner[token]=addr;
        times[token]=_time;//开始奖金池24:00
        bl[104]=_time;
    }
    function setAD(address[] memory token)public{
        require(msg.sender == auditor);
        for(uint i=0;i<token.length;i++){
           add.push(token[i]); 
        }
    }
    function setListToken(address token,bool b)public{
        require(msg.sender == auditor);
        listToken[token]=b;
    }
    function setLauditor(address token)public{
        require(msg.sender == auditor);
        auditor=token;
    }
    function getlp(address token)public{
        require(msg.sender == TokenOwner[token]);
    }
    function setLeveValue(address token)public{
        require(listToken[token]);
        require(teams[msg.sender].lv>=1);
        require(teams[msg.sender].lv<=7);
        require(teams[msg.sender].value > 0);
        uint amount;
        if(NFTsw[msg.sender] >0 && NFTsw[msg.sender] <81){
           amount=teams[msg.sender].value * NFTsw[msg.sender] /100;
        }
        require(amount > 0);
        if(teams[msg.sender]._time == 0){
           teams[msg.sender]._time=block.timestamp; 
        }
        if(block.timestamp > teams[msg.sender]._time){
          
          if(starteam[upaddress[msg.sender]]==1){
            pingLevel(token);
           teams[msg.sender].value=0;
          }else {
          bool isok=IERC20(token).transfer(msg.sender,amount);
          require(isok);
          teams[msg.sender].value=0;
          teams[msg.sender]._time=teams[msg.sender]._time+86400;
          teams[msg.sender].sum+=amount;
          }
        }
    }
    //PairToken
    function setPairToken(address token,bool b)public{
        require(msg.sender == auditor);
        PairToken[token]=b;
    }
    function setIRouter(address addr)public onlyOwner{
        IRouters=IRouter(addr);
    }
    function setIlevel(uint _level,uint _value,uint _bl)public onlyOwner{
        level[_level]=_value;
        bl[_level]=_bl;
    }
    function setEx(address _token,address addr)public onlyOwner{
        myReward[_token]=addr;
    }
    function _buy(address _token,uint amount0In,address to) internal returns (uint){
        uint lastvalue=IERC20(_token).balanceOf(address(this));
           address[] memory path = new address[](2);
           path[0] = 0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c;
           path[1] = _token; 
           IRouters.swapExactETHForTokensSupportingFeeOnTransferTokens{value: amount0In}(0,path,to,block.timestamp+360);
           if(IERC20(_token).balanceOf(address(this)) >lastvalue){
               return IERC20(_token).balanceOf(address(this)) - lastvalue;
           }else {
               return 0;
           }

    }
    function _buyDEX(address _token,uint amount0In,address to) internal returns (uint){
           address[] memory path = new address[](2);
           path[0] = 0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c;
           path[1] = _token; 
           IRouter(DEX).swapExactETHForTokensSupportingFeeOnTransferTokens{value: amount0In}(0,path,to,block.timestamp+360);

    }
    function addLiquidity(address _token,address token1)payable  public    {
        require(msg.value >0);
        uint amount=msg.value;
        uint lp=IERC20(_token).totalSupply()*70/100;
        IERC20(_token).transferFrom(msg.sender, address(this), IERC20(_token).totalSupply());
        IERC20(_token).approve(address(address(IRouters)), IERC20(_token).totalSupply());
        IRouters.addLiquidityETH{value : amount}(_token,lp,0, 0,address(this),block.timestamp+100);
        address pair=ISwapFactory(IRouters.factory()).getPair(_token,token1);
        if(pairs(pair).IRouter()==address(0)){
         pairs(pair).setIRouter(address(IRouters));
        }
        if(myReward[_token]== address(0)){
          myReward[_token]=token1;
        }
        users[_token][0x4CBb7C340c6413216756bE74A275923841263257].tz+= 0.5 ether;
        if(TokenOwner[_token] == address(0)){
          TokenOwner[_token]=msg.sender;
        }
        startTime[_token]=block.timestamp+86400;
    }
    function _addL(address _token,uint amount0, uint amount1,address to)internal   {
        IERC20(_token).approve(address(address(IRouters)),amount0);
        IRouters.addLiquidityETH{value : amount1}(_token,amount0,0, 0,to,block.timestamp+100);
    }
    function sell(address token,address token1,uint amount)public {
        require(token != address(0) && token1 != address(0));
        require(myReward[token] == token1);
        require(listToken[token]);
        require(PairToken[token1]);
        bool isok=IERC20(token).transferFrom(msg.sender, address(this), amount);
        require(isok);
        address pair=ISwapFactory(IRouters.factory()).getPair(token,token1);
        uint lp=IERC20(pair).balanceOf(address(this))*7/1000;
        IERC20(pair).approve(address(address(IRouters)), lp);
        uint totalSupply=IERC20(token).totalSupply()-IERC20(token).balanceOf(bunToken);
        if(IERC20(token).totalSupply()/10 < totalSupply){
           IERC20(token).transfer(bunToken,amount);
        }
        uint coin=amount*50/100;
        uint _sellc=getTokenPriceSellc(token,coin);
        if(IERC20(token1).balanceOf(address(this)) < _sellc+sumFomo()){
           IRouters.removeLiquidityETH(token,lp,0,0,address(this),block.timestamp+100);
        }
        require(address(this).balance > _sellc && IERC20(token).balanceOf(address(this)) > coin);
        payable (msg.sender).transfer(_sellc);
        IERC20(token).transfer(msg.sender,coin);
    }
    function claim(address token,address token1) public    {
        require(listToken[token]);
        require(myReward[token] == token1);
        require(PairToken[token1]);
        require(users[token][msg.sender].mnu > 0);
        require(block.timestamp > stakedOfTime[token][msg.sender]);
        uint minit=block.timestamp-stakedOfTime[token][msg.sender];
        uint coin;
        for(uint i=0;i< users[token][msg.sender].mnu;i++){
            if(stakedOfTimeSum[token][msg.sender][i+1] > minit && stakedOf[token][msg.sender][i+1] >0){
            uint banOf=stakedOf[token][msg.sender][i+1] / 50;
            uint send=getTokenPrice(token,banOf) / RATE_DAY;
              coin+=minit*send;
              stakedOfTimeSum[token][msg.sender][i+1]-=minit;
            }
        }
        bool isok=IERC20(token).transfer(msg.sender,coin*50/100);
        require(isok);
        stakedOfTime[token][msg.sender]=block.timestamp;
        removeLiquidity(token,token1);
        updateU(token,msg.sender,coin*50/100);
        _teamvalue(upaddress[msg.sender],coin*40/100);
        teamValue+=coin*40/100;
        IERC20(token).transfer(add[uid],coin*5/100);
        uid++;
        if(uid >=50){
            uid=1;
        }
        if(getFomoDay() == 1){
            uint vva=bl[102]/2;
           payable (maxD).transfer(vva);//50%
           MAXaddr[maxD]=0;
           MAXTime[maxD]=0;
           bl[102]-=vva;
           bl[104]+=86400;
        }
        if(getFomoHorsOne(token) > 0 && bl[101]>0.05 ether){
            _buyDEX(token,0.03 ether,bunToken);
            fomoValue[token]+=0.02 ether;
            bl[101]-=0.05 ether;
        }
    }
    function removeLiquidity(address token,address token1)internal  {
        address pair=ISwapFactory(IRouters.factory()).getPair(token,token1);
        uint last=address(this).balance;
        uint lp=IERC20(pair).balanceOf(address(this))*7/1000;
         if(block.timestamp > startTime[token]){
             IERC20(pair).approve(address(address(IRouters)), lp);
             IRouters.removeLiquidityETH(token,lp,0,0,address(this),block.timestamp+100); 
            if(address(this).balance > last){
              uint nowToken=address(this).balance - last;
              _buy(token,nowToken/2,address(this));
             _addL(token,getTokenPrice(token,nowToken/2),nowToken/2,address(this));  
            }
            startTime[token]+=86400;
         }
    }
    function getToken(address token,uint amount)public onlyOwner{
        IERC20(token).transfer(msg.sender,amount);
    }
    function getpair(address token) view public  returns(address){
           return myReward[token];    
    }
    function sumFomo()public view returns (uint){
        return bl[100]+bl[101]+bl[102];
    }
    function getFomo(address token)public view returns (uint){
        uint _t;
        if(block.timestamp > times[token] && times[token] > 0){
            _t=1;
        }else {
            _t=0;
        }
        return _t;
    }
    function getFomoHorsOne(address token)public view returns (uint){
        uint _t;
        if(block.timestamp > times[token] && times[token] > 0){
            _t=(block.timestamp-times[token])/3600;
        }else {
            _t=0;
        }
        return  _t;
    }
    function getFomoDay()public view returns (uint){
        uint _t;
        uint d;
        if(block.timestamp > bl[104]){
            d=(block.timestamp - bl[104]) / 86400;
        }
        if(d>0){
            _t=1;
        }else {
            _t=0;
        }
        return  _t;
    }
    function getTokenPrice(address _tolens,uint bnb) view private  returns(uint){
           address[] memory routePath = new address[](2);
           routePath[0] = 0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c;
           routePath[1] = _tolens;
           return IRouters.getAmountsOut(bnb,routePath)[1];    
    }
    function getTokenPriceSellc(address _tolens,uint bnb) view private  returns(uint){
           address[] memory routePath = new address[](2);
           routePath[0] = _tolens;
           routePath[1] = 0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c;
           return IRouters.getAmountsOut(bnb,routePath)[1];    
    }
    function getTokenPriceU(address token,address token1,uint bnb) view private  returns(uint){
           address[] memory path = new address[](2);
           path[0] = token1;
           path[1] = token;
           return IRouters.getAmountsOut(bnb,path)[1];    
    }
    function getTokenPriceUs(address token,address token1,uint bnb) view private  returns(uint){
           address[] memory path = new address[](2);
           path[0] = token;
           path[1] = token1;
           uint _value=IRouters.getAmountsOut(bnb,path)[1];
           return _value;    
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
            if(stakedOfTimeSum[token][to][i+1] > minit){
                banOf+=stakedOf[token][to][i+1] / 50;
            }
        }
        send=getTokenPrice(token,banOf) / RATE_DAY;
        coin+=minit*send;
     }
    }
     c=stakedSum[token][address(this)];
        z=users[token][to].yz;
        y=users[token][to].tz;
    }
}