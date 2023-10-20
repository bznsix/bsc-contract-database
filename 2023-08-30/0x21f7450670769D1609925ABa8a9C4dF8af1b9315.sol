/**
 *Submitted for verification at BscScan.com on 2023-03-29
*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.6.12;

/**
 * @dev Wrappers over Solidity's arithmetic operations with added overflow
 * checks.
 *
 * Arithmetic operations in Solidity wrap on overflow. This can easily result
 * in bugs, because programmers usually assume that an overflow raises an
 * error, which is the standard behavior in high level programming languages.
 * `SafeMath` restores this intuition by reverting the transaction when an
 * operation overflows.
 *
 * Using this library instead of the unchecked operations eliminates an entire
 * class of bugs, so it's recommended to use it always.
 */
library SafeMath {
    /**
     * @dev Returns the addition of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `+` operator.
     *
     * Requirements:
     *
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
     *
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
     *
     * - Subtraction cannot overflow.
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
     *
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
     *
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
     *
     * - The divisor cannot be zero.
     */
    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
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
     *
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
     *
     * - The divisor cannot be zero.
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
     * @dev Returns the amount of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the amount of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Moves `amount` tokens from the caller's account to `recipient`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address recipient, uint256 amount) external returns (bool);

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
     * @dev Moves `amount` tokens from `sender` to `recipient` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

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
}




contract TikSwap {
    using SafeMath for uint256; 
    IERC20 public usdtERC20;//0x55d398326f99059fF775485246999027B3197955
    IERC20 public tikERC20 ;

    address public _owner;

    uint256 baseRate = 10000;
    
    uint256[5] public machineAmount = [100e18, 500e18, 1000e18, 3000e18,5000e18]; //单位 usdt  
    uint256[5] public machineCycle = [30 days, 60 days, 90 days, 180 days, 360 days]; 
    uint256[5] public maxOutput = [200e18,2000e18,6000e18,24000e18,50000e18]; //单位 tik
    uint256[5] public nftPower = [100e18,1000e18,3000e18,10000e18,20000e18];
    
    address[3] public feeAddress = [address(0),0x2A3c52D71C915C4A8a0d3EEDc4c54C1248237Eac,0xB56D14c05Aee0829A4CfAF533AEffB9074f4fcEd];
    uint256[3] public feeRate =[2000,500,500];

    uint256[6] public teamQuota =[10000e18,50000e18,200000e18,600000e18,2000000e18,4000000e18];
    uint256[6] public teamQuotaRate =[0,500,700,900,1200,1500];

    uint256[2] public shareRate =[2500,500];

    uint256 public startTime ;

    uint256 public allPower ;

    uint256 public startOutput = 225e15;

    uint256 public cutNum = 5e15;

    uint256 public minOutput = 1e17; 
    
    uint256[5] public shareSelfRate =[1500,800,400,300,500];

    uint256[6] public shareTeamRate =[0,200,400,600,800,1000];

    uint256[5] public resumptionTik =[0,200e18,600e18,1800e18,4800e18];

    address public defaultRefer = 0x0878139E009FefF828aE872e853Fde26Cd4Da932;

     address public boss = 0xE9258c7b4598e27C08773fA0810840Ca9b78Cf7E;

    uint256 private constant referDepth = 20;

    uint256 public allVip;

    uint256 public allSVip;  

    modifier onlyOwner() {
        require(msg.sender == _owner, "Permission denied"); _;
    }

    struct OrderInfo {
        address user;
        uint256 nft;
        uint256 amount;
        uint256 maxOutput; 
        uint256 power; 
        uint256 startTime;
        uint256 freshTime;
        uint256 endTime; 
        uint256 released;
        uint256 surplus;
        bool isFreeze;
    }


    struct UserInfo {

        uint256 count;

        address referrer;

        uint256 start;
   
        uint256 level;

        bool vip;

        bool  superVip; 

        uint256  directNum;   
   
        uint256 teamNum;

        uint256 totalRevenue;

        uint256 lastTime;

        uint256 totalDeposit;

        uint256 teamTotalDeposit;

        uint256 teamPower;

        uint256 userPower;
    }

    mapping(address=>UserInfo) public userInfo;

    address[] public vips;

    address[] public svips;

    mapping(address => mapping(uint256 => address[])) public teamUsers;

    struct RewardInfo{
  
        uint256 directs; 

        uint256 indirect; 

        uint256 statics;

        uint256 team; 

        uint256 share;

    }

    mapping(address=>RewardInfo) public rewardInfo;

    mapping(address => OrderInfo[]) public orderInfos;

    mapping(address => address[]) public children;
    
    event Register(address user, address referral);
    event Deposit(address user, uint256 amount);
    event DepositBySplit(address user, uint256 amount);
    event TransferBySplit(address user, address receiver, uint256 amount);
    event Withdraw(address user, uint256 withdrawable);
    event BuyNft(address _buyer, uint256 _amount);
    event BuyVip(address _buyer, uint256 _amount);
    //tTik 0x791d9D0a1D06B873991DECA3Ebd4ea4FBf71A768
    //tusdt 0x0d43B61aBE6c5aE1F41371a08da5ec26f8d74682
    constructor(address _tikToken,address _usdtToken) public { 
       tikERC20 =IERC20(_tikToken);
       usdtERC20 = IERC20(_usdtToken);
       startTime = block.timestamp;
       _owner = msg.sender;
    }

    function transferOwnership(address newOwner) public onlyOwner {
        require(newOwner != address(0));
        _owner = newOwner;
    }

    function updateFeeAddress(address _burn,address _skill,address _market)  external onlyOwner{
        feeAddress = [_burn,_skill,_market];
    }
    function updateFeeRate(uint256 _fee1,uint256 _fee2,uint256 _fee3)  external onlyOwner{
        feeRate = [_fee1,_fee2,_fee3];
    }
    function updateTeamQuota(uint256 _quota1,uint256 _quota2,uint256 _quota3,uint256 _quota4,uint256 _quota5)  external onlyOwner{
        teamQuota = [_quota1,_quota2,_quota3,_quota4,_quota5];
    }
    function updateTeamQuotaRate(uint256 _fee1,uint256 _fee2,uint256 _fee3,uint256 _fee4,uint256 _fee5)  external onlyOwner{
        teamQuotaRate = [_fee1,_fee2,_fee3,_fee4,_fee5];
    }
    function updateShareRate(uint256 _fee1,uint256 _fee2)  external onlyOwner{
        shareRate = [_fee1,_fee2];
    }
    function updateShareSelfRate(uint256 _fee1,uint256 _fee2,uint256 _fee3,uint256 _fee4,uint256 _fee5)  external onlyOwner{
        shareSelfRate = [_fee1,_fee2,_fee3,_fee4,_fee5];
    }
    function updateShareTeamRate(uint256 _fee1,uint256 _fee2,uint256 _fee3,uint256 _fee4,uint256 _fee5)  external onlyOwner{
        shareTeamRate = [_fee1,_fee2,_fee3,_fee4,_fee5];
    }    

    function register(address _referral) external {  

        require(orderInfos[_referral].length > 0 || _referral == defaultRefer, "invalid refer");
        
        UserInfo storage user = userInfo[msg.sender];

        require(user.referrer == address(0), "referrer bonded");

        user.referrer = _referral; 

        user.start = block.timestamp; 

        children[_referral].push(msg.sender);       
        
        emit Register(msg.sender, _referral);
    }



    function buyNFT(uint256 _index,uint256 _usdt) external {
        UserInfo storage user = userInfo[msg.sender];      
        require(user.referrer != address(0), "Register First"); 
        require(machineAmount[_index]==_usdt,"Wrong Quantity");    
        usdtERC20.transferFrom(msg.sender, address(this), _usdt);  
        emit BuyNft(msg.sender, _usdt);
        if(user.count==0){
          user.count=1;
        }
        orderInfos[msg.sender].push(OrderInfo(
            msg.sender,
            _index, 
            _usdt,
            maxOutput[_index],
            nftPower[_index],
            block.timestamp,
            block.timestamp,
            block.timestamp+machineCycle[_index],
            0,
            maxOutput[_index],
            false
        ));
        allPower += nftPower[_index];
        user.totalDeposit += _usdt;
       uint256 spent = _updateReferInfo(msg.sender,_usdt,nftPower[_index]);
       _updateTeamNum(msg.sender);
       usdtERC20.transfer(boss,_usdt-spent);
    }

    function buyVip(uint256 _usdt) external {
        UserInfo storage user = userInfo[msg.sender];      
        require(user.referrer != address(0), "Register First");
        require(_usdt == 1000e18, "Incorrect amount");  
        usdtERC20.transferFrom(msg.sender,address(this),_usdt);
        user.vip = true;
        vips.push(msg.sender);
        emit  BuyVip(msg.sender,_usdt);
    }

    function resumption(uint256 _index,uint256 _tik,uint256 _usdt) external {
      UserInfo memory user = userInfo[msg.sender];
      require(user.referrer != address(0), "Register First"); 
      OrderInfo storage  order =orderInfos[msg.sender][_index];
      require(order.user!=address(0), "nft does not exist");
      require(order.isFreeze, "Nft has taken effect");
      if(order.nft==0){
        require(_usdt==100e18,"Incorrect amount");  
        usdtERC20.transferFrom(msg.sender,address(this),_usdt); 
      }else   {
        require(resumptionTik[_index]==_tik, "Incorrect amount");
        tikERC20.transferFrom(msg.sender,address(this),_usdt); 
      }
      order.startTime =  block.timestamp;
      order.endTime =   block.timestamp+machineCycle[_index];
      order.released = 0 ;
      order.surplus = maxOutput[_index];
      order.isFreeze = false;
    }

    function cash() external  { 
     UserInfo memory user = userInfo[msg.sender];
     require(user.referrer != address(0), "Register First"); 
     require(getOrderLength(msg.sender)>0, "nft must > 0"); 
     uint256 staticProfit ;
        OrderInfo[] storage orders= orderInfos[msg.sender];
        for (uint i = 0; i < orders.length; i++) {
            OrderInfo storage  order = orders[i];
            if(order.isFreeze){
               continue; 
            }
            uint256 nowTime ;
            if(block.timestamp>order.endTime){
                nowTime = order.endTime;
                order.isFreeze = true;
                order.freshTime = order.endTime;
            }else { nowTime = block.timestamp; }
           uint256 differTime =(nowTime-order.freshTime);
             uint256 orderStatic = differTime*getCurNum()*55*order.power/allPower/100;
             if(orderStatic>=order.surplus){
                orderStatic = order.surplus;
                order.isFreeze = true;
             }   
             staticProfit += orderStatic;
             order.released += orderStatic;
             order.freshTime = nowTime;
             order.surplus -= orderStatic;
        }   
        uint256 total = staticProfit/55*100;
        _updateCause(msg.sender,total-staticProfit);
        RewardInfo storage reward= rewardInfo[msg.sender];
        uint256 totalPorift = staticProfit+reward.share+reward.team;
        tikERC20.transfer(msg.sender,totalPorift*70/100);
        reward.share = 0;
        reward.team = 0;
        tikERC20.transfer(feeAddress[0],totalPorift*feeRate[0]/baseRate);
        tikERC20.transfer(feeAddress[1],totalPorift*feeRate[1]/baseRate);
        tikERC20.transfer(feeAddress[2],totalPorift*feeRate[2]/baseRate);
    }

    function getTeamUsersLength(address _user, uint256 _layer) external view returns(uint256) {
        return teamUsers[_user][_layer].length;
    }

    function _updateCause(address _user, uint256 _amount) private  {
        UserInfo storage user = userInfo[_user];
        address upline = user.referrer;
        uint256 nowLevl = 0 ;
        for(uint256 i = 0; i < referDepth; i++){
            if(upline != address(0)){
                 RewardInfo  storage reward = rewardInfo[upline];
                if(userInfo[upline].directNum>i&&i<5){ 
                    reward.share +=  _amount*shareSelfRate[i]/baseRate;
                }
                if(userInfo[upline].level>nowLevl){
                    uint256 reamRate = shareTeamRate[userInfo[upline].level]-shareTeamRate[nowLevl];
                   reward.team += _amount*reamRate/baseRate;
                }

                if(upline == defaultRefer) break;
                upline = userInfo[upline].referrer;
            }else{
                break;
            }
        }
    }



    function getOrderLength(address _user) public view returns(uint256) {
        return  orderInfos[_user].length;
    }

    function getChildrenLength(address _user) public view returns(uint256) {
        return  children[_user].length;
    }

    function getTeamDeposit(address _user) public view returns(uint256){
        uint256 maxTeam;
        for(uint256 i = 0; i < teamUsers[_user][0].length; i++){
            uint256 userTotalTeam = userInfo[teamUsers[_user][0][i]].teamTotalDeposit.add(userInfo[teamUsers[_user][0][i]].totalDeposit);
            maxTeam = maxTeam.add(userTotalTeam);
        }
        return(maxTeam);
    }



    function _updateTeamNum(address _user) private {
        UserInfo storage user = userInfo[_user];
        address upline = user.referrer;
        for(uint256 i = 0; i < referDepth; i++){
            if(upline != address(0)){
             if(teamUsers[upline][i].length>0){
                    for(uint256 j=0;j<teamUsers[upline][i].length;j++){
                        if(teamUsers[upline][i][j]==_user){
                          return;
                        }
                    }

                }
                userInfo[upline].teamNum = userInfo[upline].teamNum.add(1);
                teamUsers[upline][i].push(_user);
                _updateLevel(upline);
                if(upline == defaultRefer) break;
                upline = userInfo[upline].referrer;
            }else{
                break;
            }
        }
    }

    function _updateReferInfo(address _user, uint256 _amount,uint256 _power) private  returns(uint256 spent) {
        UserInfo storage user = userInfo[_user];
        address upline = user.referrer;
        uint256 nowLevl = 0 ;
        for(uint256 i = 0; i < referDepth; i++){
            if(upline != address(0)){
                userInfo[upline].teamTotalDeposit = userInfo[upline].teamTotalDeposit.add(_amount);
                userInfo[upline].teamPower = userInfo[upline].teamPower.add(_power);
                if(i==0&&user.count==1){
                   userInfo[upline].directNum +=1;
                }
                if(i<2){ 
                    uint256  direct = _amount * shareRate[i] / baseRate;
                    usdtERC20.transfer(upline,direct);
                    spent += direct;
                }
                if(userInfo[upline].level>nowLevl){ 
                  uint256 rate =  teamQuotaRate[userInfo[upline].level]- teamQuotaRate[nowLevl];
                  uint256 extend = rate*_amount/baseRate;
                  usdtERC20.transfer(upline,extend);
                  spent += extend;
                }            
               _updateLevel(upline);
                if(upline == defaultRefer) break;
                upline = userInfo[upline].referrer;
            }else{
                break;
            }
        }
        if(vips.length>0){
          uint256 vipProfit = _amount*2/100;
          for(uint256 i=0;i<vips.length;i++){
             address vip = vips[i];
             usdtERC20.transfer(vip,vipProfit/vips.length);
          }
          spent += vipProfit;
        }
        if(svips.length>0){
          uint256 svipProfit = _amount*3/100;
          for(uint256 i=0;i<svips.length;i++){
             address svip = svips[i];
             usdtERC20.transfer(svip,svipProfit/svips.length);
          }
          spent += svipProfit;
        }
    }





    function _updateLevel(address _user) private {
        UserInfo storage user = userInfo[_user];
        uint256 levelNow = _calLevelNow(_user);
        if(levelNow > user.level){ 
            user.level = levelNow;
        }
    }

    function freshProfit(address _user) public view returns(uint256 profit) {
        uint256 length = orderInfos[_user].length;
        if(length==0){
          return 0;
        }
        OrderInfo[] memory orders= orderInfos[_user];
        for (uint i = 0; i < orders.length; i++) {
            OrderInfo memory  order = orders[i];
             uint256 nowTime ;
            if(block.timestamp>order.endTime){
                nowTime = order.endTime;
                order.isFreeze = true;
                order.freshTime = order.endTime;
            }else { nowTime = block.timestamp; }
           uint256 differTime =(nowTime-order.freshTime);
            profit += differTime*getCurNum()*55*order.power/allPower/100;    
        }
       return profit;
    }


    function _calLevelNow(address _user) private  returns(uint256 levelNow) { 
        uint256 total = getTeamDeposit(_user);
        if(total >= teamQuota[0]){
            if(total >= teamQuota[4]){
            levelNow = 5;
            if(total>=teamQuota[5]){
               UserInfo storage user = userInfo[_user];
               user.superVip = true;
               svips.push(_user); 
            } 
            }
           else  if(total >= teamQuota[3] && total<teamQuota[4]){
                levelNow = 4;
            }else if(total >= teamQuota[2] && total<teamQuota[3]){
                levelNow = 3;
            }else if(total >= teamQuota[1] && total<teamQuota[2]){
                levelNow = 2;
        }else if(total >= teamQuota[0] && total<teamQuota[1]){
            levelNow = 1;
        }
        return levelNow;
    }
    }

    function getCurDay() public view returns(uint256) {
        return (block.timestamp.sub(startTime)).div(1 days);
    }

    function getCurNum() public view  returns(uint256) { 
       uint256 cutTik = (block.timestamp.sub(startTime)).div(1 days)* cutNum;
       uint256 curNum = startOutput - cutTik;
       if(curNum<minOutput){
         return minOutput/3 ;
       }
        return  curNum/3;
    }
   

    


 
}