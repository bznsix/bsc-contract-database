// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.6.0) (token/ERC20/IERC20.sol)

pragma solidity ^0.8.0;

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
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.6.0) (utils/math/SafeMath.sol)

pragma solidity ^0.8.0;

// CAUTION
// This version of SafeMath should only be used with Solidity 0.8 or later,
// because it relies on the compiler's built in overflow checks.

/**
 * @dev Wrappers over Solidity's arithmetic operations.
 *
 * NOTE: `SafeMath` is generally not needed starting with Solidity 0.8, since the compiler
 * now has built in overflow checking.
 */
library SafeMath {
    /**
     * @dev Returns the addition of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function tryAdd(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            uint256 c = a + b;
            if (c < a) return (false, 0);
            return (true, c);
        }
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function trySub(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b > a) return (false, 0);
            return (true, a - b);
        }
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function tryMul(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
            // benefit is lost if 'b' is also tested.
            // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
            if (a == 0) return (true, 0);
            uint256 c = a * b;
            if (c / a != b) return (false, 0);
            return (true, c);
        }
    }

    /**
     * @dev Returns the division of two unsigned integers, with a division by zero flag.
     *
     * _Available since v3.4._
     */
    function tryDiv(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a / b);
        }
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers, with a division by zero flag.
     *
     * _Available since v3.4._
     */
    function tryMod(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a % b);
        }
    }

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
        return a + b;
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
        return a - b;
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
        return a * b;
    }

    /**
     * @dev Returns the integer division of two unsigned integers, reverting on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator.
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return a / b;
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * reverting when dividing by zero.
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
        return a % b;
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting with custom message on
     * overflow (when the result is negative).
     *
     * CAUTION: This function is deprecated because it requires allocating memory for the error
     * message unnecessarily. For custom revert reasons use {trySub}.
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     *
     * - Subtraction cannot overflow.
     */
    function sub(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b <= a, errorMessage);
            return a - b;
        }
    }

    /**
     * @dev Returns the integer division of two unsigned integers, reverting with custom message on
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
    function div(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b > 0, errorMessage);
            return a / b;
        }
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * reverting with custom message when dividing by zero.
     *
     * CAUTION: This function is deprecated because it requires allocating memory for the error
     * message unnecessarily. For custom revert reasons use {tryMod}.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function mod(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b > 0, errorMessage);
            return a % b;
        }
    }
}
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
contract BTW {
    using SafeMath for uint256; 
    IERC20 public USDT;
    uint256 private constant baseDivider = 10000;
    uint256 private constant feePercents = 300;
    uint256 private constant minDeposit = 50e18;
    uint256 private constant maxDeposit = 2000e18;
    uint256 private constant timeStep = 1 days;
    uint256 private constant dayPerRound = 10 days; 
    uint256 private constant maxAddFreeze = 20 days;
    uint256[5] private refReward = [200, 50, 50, 50, 50];
    uint256 private refRewardSum = 400;
    uint256 private constant referDepth = 20;
    uint256 private constant directDepth = 1;
    uint256 private constant directPercents = 100;
    uint256[4] private senManPercents = [50, 50, 50, 50];
    uint256[5] private asvpPercents = [20, 20, 20, 20, 20];
    uint256[10] private vpPercents = [10, 10, 10, 10, 10, 10, 10, 10, 10, 10];
    uint256 private constant MPoolPercents = 10;
    uint256 private constant SMPoolPercents = 10;
    uint256 private constant AVPoolPercents = 10;
    uint256 private constant VPPoolPercents = 10;
    uint256 private rewardingMultiple = 20000;
     
    uint256[10] private balDown = [10e22, 20e22, 30e22, 50e22, 100e22, 300e22, 500e22, 800e22, 1000e22, 1500e22];
    uint256[10] private balDownRate = [5000, 5000, 5000, 5000, 5000, 5000, 5000, 5000, 5000, 5000];
    uint256[10] private balRecover = [10e22, 20e22, 30e22, 50e22, 100e22, 300e22, 500e22, 800e22, 1000e22, 1500e22];
    mapping(uint256=>bool) public balStatus;

    address public feeReceiver;
    address public ContractAddress;
    address public defaultRefer;
    uint256 public startTime;
    uint256 public lastDistribute;
    uint256 public totalUser; 
    uint256 public lastfreezetime;
    uint256 public MPool;
    uint256 public SMPool;
    uint256 public AVPool;
    uint256 public VPPool;
     
    mapping(uint256=>address[]) public dayUsers;
    
     address[] public MUsers;
     address[] public SMUsers;
     address[] public AVUsers;
     address[] public VPUsers;


     struct OrderInfo {
        uint256 amount; 
        uint256 start;
        uint256 unfreeze; 
        bool isUnfreezed;
    }

    mapping(address => OrderInfo[]) public orderInfos;

    address[] public depositors;

    struct UserInfo {
        address referrer;
        uint256 start;
        uint256 level;
        uint256 maxDeposit;
        uint256 totalDeposit;
        uint256 totalDepositbeforeHarvested;
        uint256 teamNum;
        uint256 directnum;
        uint256 maxDirectDeposit;
        uint256 teamTotalDeposit;
        uint256 totalRevenue;
        uint256 totalRevenueFinal;
        bool isactive;   
    }

    struct TwoXInfo {
        bool isTwoX;
    }
        struct LastMaxTeamC {
        uint256 LastLegC;
    }

    struct UserInfoHarvest {  
        uint256 acheived;
        uint256 currentdays;
        uint256 harvestCount;
        
    }

    struct UserInfoPercents {
        uint256 dayRewardPercents;
    }
    mapping(address => UserInfoPercents) public userInfoPercents;
    mapping(address => TwoXInfo) public twoXInfo;
    mapping(address => LastMaxTeamC) public lastMaxTeamC;
 
      struct UserInfoTeamBuss {  
        uint256 totalTeam;
        uint256 maxTeamA;
        uint256 maxTeamB;
        uint256 maxTeamC;
        uint256 maxusernumberA; 
    }

       
     mapping(address=>UserInfo) public userInfo;
     mapping(address=>UserInfoHarvest) public userInfoHarvest;
     mapping(address=>UserInfoTeamBuss) public userInfoTeamBuss;
   
    mapping(address => mapping(uint256 => address[])) public teamUsers;
    struct RewardInfo{
       
        uint256 statics;
        uint256 refRewards;
        uint256 directs;
        uint256 sm;
        uint256 av;
        uint256 vp;
    }

     struct RewardInfoPool{
        uint256 MN;
        uint256 SM;
        uint256 AV;
        uint256 VP;
        
    }

    mapping(address=>RewardInfo) public rewardInfo;
    mapping(address=>RewardInfoPool) public rewardInfoPool;
    bool public isFreezeReward;
    event Register(address user, address referral);
    event Deposit(address user, uint256 amount);
    event DepositByActivationFund(address user, uint256 amount);
    event TransferByActivation(address user, address receiver, uint256 amount);
    event Withdraw(address user, uint256 withdrawable);
    event Harvests(address user, uint256 reward , uint256 amount );
    constructor(address _usdtAddr, address _defaultRefer, address _feeReceiver, uint256 _startTime) {
        USDT = IERC20(_usdtAddr);
        feeReceiver = _feeReceiver;
        defaultRefer = _defaultRefer;
        startTime = _startTime;
        lastDistribute = _startTime;
    }

    function register(address _referral) external {
        require(userInfo[_referral].totalDeposit > 0 || _referral == defaultRefer, "invalid refer");
        UserInfo storage user = userInfo[msg.sender];
        require(user.referrer == address(0), "referrer bonded");
        user.referrer = _referral;
        user.start = block.timestamp;
        totalUser = totalUser.add(1);
        emit Register(msg.sender, _referral);
    }

    function _updatedirectNum(address _user) private {
        UserInfo storage user = userInfo[_user];
        address upline = user.referrer;
        for(uint256 i = 0; i < directDepth; i++){
            if(upline != address(0)){
                userInfo[upline].directnum = userInfo[upline].directnum.add(1);                         
            }else{
                break;
            }
        }

        for(uint256 i = 0; i < referDepth; i++){
            if(upline != address(0)){
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

    function _updateReferInfo(address _user, uint256 _amount) private {
        UserInfo storage user = userInfo[_user];
        address upline = user.referrer;
        for(uint256 i = 0; i < referDepth; i++){
            if(upline != address(0)){
                userInfo[upline].teamTotalDeposit = userInfo[upline].teamTotalDeposit.add(_amount);
                _updateLevel(upline);
                if(upline == defaultRefer) break;
                upline = userInfo[upline].referrer;
            }else{
                break;
            }
        }
    }

     function _updateLevel(address _user) private {
        UserInfo storage user = userInfo[_user];
         updateUserTeamBusscurrent(_user);
        uint256 levelNow = _calLevelNow(_user);
        if(levelNow > user.level){
            user.level = levelNow;
              if(levelNow == 2){        
                MUsers.push(_user);
            }
              if(levelNow == 3){        
                SMUsers.push(_user);
            }
             if(levelNow == 4){        
                AVUsers.push(_user);
            }
            if(levelNow == 5){         
                VPUsers.push(_user);
            }
        }
    }
  
    function _calLevelNow(address _user) private view returns (uint256) {
        UserInfo storage user = userInfo[_user];
        uint256 total = user.maxDeposit;
        uint256 totaldirectnum = user.directnum;
        uint256 totaldirectdepositnum = user.maxDirectDeposit;
        uint256 levelNow;

        if(total >= 500e18){
            (uint256 maxTeam, uint256 otherTeam,uint256 othermaxTeam) = checkteamconditions(_user);  // a //c ///b
            if(total >= 2000e18 && totaldirectnum>=10 && totaldirectdepositnum>=5000e18   && user.teamNum >= 250 &&   otherTeam  + othermaxTeam + maxTeam >=210000e18){
                levelNow = 5;
            }else if(total >= 2000e18 && totaldirectnum>=8 && totaldirectdepositnum>=2000e18 && user.teamNum >= 100 &&  otherTeam  + othermaxTeam + maxTeam >=60000e18){
                levelNow = 4;
            }else if(total >= 1000e18  && totaldirectnum>=5 && totaldirectdepositnum>=1000e18 && user.teamNum >= 50 &&  otherTeam  + othermaxTeam + maxTeam >=15000e18){
                levelNow = 3;
            }
            else if(total >= 500e18  && totaldirectnum>=5 && totaldirectdepositnum>=500e18 && user.teamNum >= 5 &&  otherTeam  + othermaxTeam + maxTeam >=600e18)
            {
               levelNow = 2;
            }
            else if(totaldirectnum >= 1){
              levelNow = 1;
            }
        }
        return levelNow;
    }
    function updateUserTeamBusscurrent(address _user) private {
        UserInfoTeamBuss storage userteaminfo = userInfoTeamBuss[_user];
        uint256 totalTeam;
        uint256 maxTeam; //a
        uint256 othermaxTeam; //b
        uint256 otherTeam; //c
        uint256 maxusernumber;
        uint256 teamUsersLength = teamUsers[_user][0].length;
        for (uint256 i = 0; i < teamUsersLength; i++) {
            address currentUser = teamUsers[_user][0][i];
            uint256 userTotalTeam = userInfo[currentUser].teamTotalDeposit.add(userInfo[currentUser].totalDeposit);
            totalTeam = totalTeam.add(userTotalTeam);
            if (userTotalTeam > maxTeam) { maxTeam = userTotalTeam;
                maxusernumber = i;
            }
        }
        for (uint256 i = 0; i < teamUsersLength; i++) {
            if (i != maxusernumber) {
                address currentUser = teamUsers[_user][0][i];
                uint256 userTotalTeam = userInfo[currentUser].teamTotalDeposit.add(userInfo[currentUser].totalDeposit);
                if (userTotalTeam > othermaxTeam) { othermaxTeam = userTotalTeam;
                }
            }
        }
        otherTeam = totalTeam.sub(maxTeam).sub(othermaxTeam);
        userteaminfo.totalTeam = totalTeam;
        userteaminfo.maxTeamA = maxTeam;
        userteaminfo.maxTeamB = othermaxTeam;
        userteaminfo.maxTeamC = otherTeam;
        userteaminfo.maxusernumberA = maxusernumber;
    }

    function getTeamDeposit(address _user) public view returns(uint256, uint256, uint256 ){
       
        uint256 maxTeam;
        uint256 othermaxTeam;
        uint256 otherTeam;
        
         maxTeam =  userInfoTeamBuss[_user].maxTeamA;
         othermaxTeam =  userInfoTeamBuss[_user].maxTeamB;
         otherTeam =  userInfoTeamBuss[_user].maxTeamC;
        
          return(maxTeam, otherTeam, othermaxTeam);
    }
    function checkteamconditions(address _user) private view returns(uint256, uint256, uint256 ) {      
        uint256 maxTeam;
        uint256 othermaxTeam;
        uint256 otherTeam;
        uint256 usercurrentlevel;
        usercurrentlevel = userInfo[_user].level;
        maxTeam =  userInfoTeamBuss[_user].maxTeamA;
        othermaxTeam =  userInfoTeamBuss[_user].maxTeamB;
        otherTeam =  userInfoTeamBuss[_user].maxTeamC;
            if(usercurrentlevel==2) {
                if(maxTeam>=5000e18) { 
                    maxTeam = 5000e18;
                }
                if(othermaxTeam>=5000e18) {
                    othermaxTeam = 5000e18;
                }
            }
                if(usercurrentlevel==3) {
                    if(maxTeam>=20000e18) {
                        maxTeam = 20000e18;
                    }
                    if(othermaxTeam>=20000e18) {
                        othermaxTeam = 20000e18;
                    }            

                    }
                        if(usercurrentlevel==4) {
                                if(maxTeam>=70000e18) {
                                    maxTeam = 70000e18;
                            }
                            if(othermaxTeam>=70000e18) {
                                othermaxTeam = 70000e18;
                            }              
                        }

          return(maxTeam, otherTeam, othermaxTeam);    
   }
  
    function deposit(uint256 _amount) external {
        USDT.transferFrom(msg.sender, address(this), _amount);
        _deposit(msg.sender, _amount);
        emit Deposit(msg.sender, _amount);
    }
    function _deposit(address _user, uint256 _amount) private {
        UserInfo storage user = userInfo[_user];
        UserInfoHarvest storage userHarvest = userInfoHarvest[_user];
        
        require(user.referrer != address(0), "register first");
        require(_amount >= minDeposit, "less than min");
        require(_amount.mod(minDeposit) == 0 && _amount >= minDeposit, "mod err");
        require(user.maxDeposit == 0 || _amount >= user.maxDeposit, "less before");
        
        depositors.push(_user); 
        
        user.totalDepositbeforeHarvested = user.totalDepositbeforeHarvested.add(_amount);
        user.isactive = true;
                 
        uint256 currorder=  orderInfos[_user].length;

        if(userHarvest.acheived == 0  && currorder ==0)
        {  
            if(user.maxDeposit == 0){
               user.maxDeposit = _amount; 
              _updatedirectNum(_user);
            }else if(user.maxDeposit < _amount){
            user.maxDeposit = _amount;
            }  

           userHarvest.acheived = block.timestamp;
           user.totalDeposit = user.totalDeposit.add(user.totalDepositbeforeHarvested);
           user.totalDepositbeforeHarvested = 0;
          
           uint256 addFreeze = (orderInfos[_user].length.div(1)).mul(timeStep);
           if(addFreeze > maxAddFreeze){
            addFreeze = maxAddFreeze;
           }
           uint256 unfreezeTime = block.timestamp.add(dayPerRound).add(addFreeze);
           userHarvest.currentdays = unfreezeTime;
           orderInfos[_user].push(OrderInfo(
            _amount, 
            block.timestamp, 
            unfreezeTime,
            false
          ));
            _distributeDeposit(_amount);     
           _updateReferInfo(msg.sender, _amount);
           _updatemaxdirectdepositInfo(msg.sender, _amount);
           _updateLevel(msg.sender);
           _resetTwoXUser(msg.sender);
           updateUserTeamBusscurrent(user.referrer);
          _distributedepositreward(msg.sender, _amount);
        }
         
        if(userHarvest.acheived == 0  && currorder>0)
        {  
             if(user.maxDeposit < _amount){
                user.maxDeposit = _amount;
              }  

           userHarvest.acheived = block.timestamp;
           user.totalDeposit = user.totalDeposit.add(user.totalDepositbeforeHarvested);
           user.totalDepositbeforeHarvested = 0;
           _updateReferInfo(msg.sender, _amount);
           _updatemaxdirectdepositInfo(msg.sender, _amount);
           _updateLevel(msg.sender);
           _resetTwoXUser(msg.sender);
           updateUserTeamBusscurrent(user.referrer);
           _distributedepositreward(msg.sender, _amount);

        }

         distributePoolRewards();
       
        uint256 bal = USDT.balanceOf(address(this));
        _balActived(bal);
        if(isFreezeReward){
            _setFreezeReward(bal);
        }
    }
    function checkusermultiplerewardingstage(address _user) private {
            UserInfo storage user = userInfo[_user];  
            UserInfoHarvest storage userHarvest = userInfoHarvest[_user];
            TwoXInfo storage twoX = twoXInfo[_user];
            UserInfoTeamBuss storage userTeam = userInfoTeamBuss[_user];
            LastMaxTeamC storage lastMaxC = lastMaxTeamC[_user];
            uint256 _rewarding = rewardingMultiple;
            if(user.totalRevenue >= user.totalDeposit.mul(_rewarding).div(baseDivider)){
                user.totalRevenueFinal = user.totalRevenueFinal.add(user.totalRevenue);
                user.isactive = false;
                user.totalDeposit=0;
                user.totalRevenue =  0;
                userHarvest.acheived = 0;
                twoX.isTwoX = true;
                lastMaxC.LastLegC = userTeam.maxTeamC;
            }
    }

    function _resetTwoXUser(address _user) private {
        UserInfo storage user = userInfo[_user];  
        TwoXInfo storage twoX = twoXInfo[_user];
        UserInfoTeamBuss storage userTeam = userInfoTeamBuss[_user];
        LastMaxTeamC storage lastMaxC = lastMaxTeamC[_user];
        uint256 reqPlusTeamC = user.totalDeposit * 3;
        if(twoX.isTwoX == true && user.totalDeposit > 0) {
            if (userTeam.maxTeamC - lastMaxC.LastLegC >= reqPlusTeamC) {
                twoX.isTwoX = false;
                lastMaxC.LastLegC = 0;
            }
        }
    }

    function _checkCurDayPercent(address _user) private {
        UserInfoHarvest storage userHarvest = userInfoHarvest[_user];
        UserInfoPercents storage userPercents = userInfoPercents[_user];
        
        if (userHarvest.harvestCount >= 13) {
            userPercents.dayRewardPercents = 50;
        } else {
            userPercents.dayRewardPercents = 75;
        }
    }
    function HarvestReward() public {
        TwoXInfo storage twoX = twoXInfo[msg.sender];
        _checkCurDayPercent(msg.sender);
        checkusermultiplerewardingstage(msg.sender);
        _resetTwoXUser(msg.sender);
        UserInfo storage user = userInfo[msg.sender];
        UserInfoHarvest storage userHarvest = userInfoHarvest[msg.sender];
        UserInfoPercents storage userPercents = userInfoPercents[msg.sender];
        require(user.isactive == true, "Inactive Account");
        uint256 _rewarding = rewardingMultiple;
        uint256 initialAmt;
        if (user.totalDeposit > 0) {
            require(user.totalRevenue < user.totalDeposit.mul(_rewarding).div(baseDivider), "Cannot harvest more than 2x, update level");
            if (block.timestamp > userHarvest.currentdays) {
                bool hasHarvest = false;
                for (uint256 i = 0; i < orderInfos[msg.sender].length; i++) {
                    OrderInfo storage order = orderInfos[msg.sender][i];
                    if (block.timestamp > order.unfreeze && order.isUnfreezed == false) {
                        order.isUnfreezed = true;
                        uint256 interest = order.amount.mul(userPercents.dayRewardPercents).mul(dayPerRound).div(timeStep).div(baseDivider);
                        if (interest > 0 && user.isactive) {
                            if (user.totalRevenue.add(interest) > user.totalDeposit.mul(_rewarding).div(baseDivider)) {
                                interest = (user.totalDeposit.mul(_rewarding).div(baseDivider)).sub(user.totalRevenue);
                            }
                            initialAmt = order.amount;
                            if (isFreezeReward) {
                                if (user.totalDeposit > user.totalRevenue) {
                                    uint256 leftCapital = user.totalDeposit.sub(user.totalRevenue);
                                    if (interest > leftCapital) {
                                        interest = leftCapital;
                                    }
                                } else {
                                    interest = 0;
                                }
                            }
                            uint256 temp = interest;
                            if (!twoX.isTwoX) {
                                rewardInfo[msg.sender].statics = rewardInfo[msg.sender].statics.add(temp);
                                user.totalRevenue = user.totalRevenue.add(temp);
                            }
                            uint256 addFreeze = (orderInfos[msg.sender].length.div(1)).mul(timeStep);
                            if (addFreeze > maxAddFreeze) {
                                addFreeze = maxAddFreeze;
                            }
                            uint256 unfreezeTime = block.timestamp.add(dayPerRound).add(addFreeze);
                            userHarvest.currentdays = unfreezeTime;
                            userHarvest.harvestCount++;
                            hasHarvest = true;
                            uint256 nextamt = user.totalDeposit;
                            if (user.totalDepositbeforeHarvested > 0) {
                                if (user.totalDeposit < maxDeposit) {
                                    uint256 availbal = maxDeposit.sub(user.totalDeposit);
                                    if (user.totalDepositbeforeHarvested >= availbal) {
                                        nextamt = nextamt.add(availbal);
                                        user.totalDepositbeforeHarvested = user.totalDepositbeforeHarvested.sub(availbal);
                                        _updateReferInfo(msg.sender, availbal);
                                        _updatemaxdirectdepositInfo(msg.sender, availbal);
                                        _distributedepositreward(msg.sender, availbal);
                                    } else {
                                        nextamt = nextamt.add(user.totalDepositbeforeHarvested);
                                        _updateReferInfo(msg.sender, user.totalDepositbeforeHarvested);
                                        _updatemaxdirectdepositInfo(msg.sender, user.totalDepositbeforeHarvested);
                                        _distributedepositreward(msg.sender, user.totalDepositbeforeHarvested);
                                        user.totalDepositbeforeHarvested = 0;
                                    }
                                }
                            }
                            
                            user.totalDeposit = nextamt;
                            _distributeDeposit(nextamt);
                            user.maxDeposit = nextamt;
                            
                            if (user.totalDeposit >= maxDeposit) {
                                user.maxDeposit = maxDeposit;
                            }
                            
                            orderInfos[msg.sender].push(OrderInfo(
                                nextamt,
                                block.timestamp,
                                unfreezeTime,
                                false
                            ));
                            _updateLevel(msg.sender);
                            updateUserTeamBusscurrent(user.referrer);
                            
                            if (!isFreezeReward) {
                                _releaseReward(msg.sender, initialAmt);
                                emit Harvests(msg.sender, temp, initialAmt);
                            }
                        }
                        break;
                    }
                }
                if (!hasHarvest) {
                    userHarvest.harvestCount--;
                }
            }
        } else {
            user.isactive = false;
        }
    }
 
    function _releaseReward(address _user, uint256 _initialAmt) private { 
        UserInfo storage user = userInfo[_user]; 
        address upline = user.referrer;
        bool isTwoX = twoXInfo[_user].isTwoX;
        for (uint256 i = 0; i < referDepth && !isTwoX; i++) { 
            if(upline != address(0)){ 
                bool idstatus = false; 
                checkusermultiplerewardingstage(upline);
                distributePoolRewards();
                _resetTwoXUser(upline); 
                idstatus = getActiveUpline(upline);
                uint256 newAmount = _initialAmt;
                if(upline != defaultRefer){
                    uint256 maxFreezing = getMaxFreezingUpline(upline); 
                    if(maxFreezing < newAmount){ 
                        newAmount = maxFreezing;   
                    } 
                } 
                RewardInfo storage upRewards = rewardInfo[upline]; 
                uint256 reward; 
                uint256 _rewarding = rewardingMultiple; 
                if(userInfo[upline].totalRevenue < userInfo[upline].totalDeposit.mul(_rewarding).div(baseDivider) && idstatus==true){ 
                    if (!twoXInfo[upline].isTwoX) {
                        if(i==0 && idstatus==true){
                            reward = newAmount.mul(directPercents).div(baseDivider); 
                            if(userInfo[upline].totalRevenue.add(reward) > userInfo[upline].totalDeposit.mul(_rewarding).div(baseDivider)) { 
                                reward = (userInfo[upline].totalDeposit.mul(_rewarding).div(baseDivider)).sub(userInfo[upline].totalRevenue); 
                            }
                            upRewards.directs = upRewards.directs.add(reward);                        
                            userInfo[upline].totalRevenue = userInfo[upline].totalRevenue.add(reward);
                        } else if(i>0 && i<5 && idstatus==true && userInfo[upline].level > 2){ 
                            reward = newAmount.mul(senManPercents[i - 1]).div(baseDivider);
                            if(userInfo[upline].totalRevenue.add(reward) > userInfo[upline].totalDeposit.mul(_rewarding).div(baseDivider)) { 
                                reward = (userInfo[upline].totalDeposit.mul(_rewarding).div(baseDivider)).sub(userInfo[upline].totalRevenue); 
                            }
                            upRewards.sm = upRewards.sm.add(reward); 
                            userInfo[upline].totalRevenue = userInfo[upline].totalRevenue.add(reward);
                        } else if(userInfo[upline].level > 3 && i>4 && i <10 && idstatus==true){ 
                            reward = newAmount.mul(asvpPercents[i - 5]).div(baseDivider); 
                            if(userInfo[upline].totalRevenue.add(reward) > userInfo[upline].totalDeposit.mul(_rewarding).div(baseDivider)) { 
                                reward = (userInfo[upline].totalDeposit.mul(_rewarding).div(baseDivider)).sub(userInfo[upline].totalRevenue); 
                            }
                            upRewards.av = upRewards.av.add(reward); 
                            userInfo[upline].totalRevenue = userInfo[upline].totalRevenue.add(reward);
                        } else if(userInfo[upline].level > 4 && i >=10 && idstatus==true){ 
                            reward = newAmount.mul(vpPercents[i - 10]).div(baseDivider); 
                            if(userInfo[upline].totalRevenue.add(reward) > userInfo[upline].totalDeposit.mul(_rewarding).div(baseDivider)) { 
                                reward = (userInfo[upline].totalDeposit.mul(_rewarding).div(baseDivider)).sub(userInfo[upline].totalRevenue); 
                            }
                            upRewards.vp = upRewards.vp.add(reward); 
                            userInfo[upline].totalRevenue = userInfo[upline].totalRevenue.add(reward);
                        } 
                    }
                } 
                if(upline == defaultRefer) break; 
                upline = userInfo[upline].referrer; 
            }else{ 
                break; 
            } 
        } 
    }

    function withdraw() external {
        distributePoolRewards();
        _updateLevel(msg.sender);
        uint256 staticReward = _calCurStaticRewards(msg.sender);
        uint256 withdrawable = staticReward;
        uint256 dynamicReward = _calCurDynamicRewards(msg.sender);
        withdrawable = withdrawable.add(dynamicReward);   
        RewardInfo storage userRewards = rewardInfo[msg.sender];
        RewardInfoPool storage userRewardsf = rewardInfoPool[msg.sender];
        UserInfo storage user = userInfo[msg.sender];
        _resetTwoXUser(msg.sender);
        userRewards.statics = 0;
        userRewards.refRewards = 0;
        userRewards.directs = 0;
        userRewards.sm = 0;
        userRewards.av = 0;
        userRewards.vp = 0;
        userRewardsf.VP = 0;  
        userRewardsf.SM = 0;
        userRewardsf.AV = 0; 
        userRewardsf.MN = 0; 
        withdrawable = withdrawable.add(user.totalDepositbeforeHarvested);
        user.totalDepositbeforeHarvested = 0;
        uint256 bal = USDT.balanceOf(address(this));
        _setFreezeReward(bal);
         
         USDT.transfer(msg.sender, withdrawable);
        emit Withdraw(msg.sender, withdrawable);

    }


    function getMaxFreezingUpline(address _user) public view returns(uint256) {
        uint256 maxFreezing;
        UserInfo storage user = userInfo[_user];
        maxFreezing =   user.maxDeposit;
        return maxFreezing;
    }

     function getActiveUpline(address _user) public view returns(bool) {
        bool currentstatus = false;  
        UserInfo storage user = userInfo[_user];
        if(user.isactive==true){
           UserInfoHarvest storage userHarvest = userInfoHarvest[_user];
          if(block.timestamp < userHarvest.currentdays){
             currentstatus =  true;
           }
        }
        
        return currentstatus;
    }
       
    function _calCurStaticRewards(address _user) private view returns(uint256) {
        RewardInfo storage userRewards = rewardInfo[_user];
        uint256 totalRewards = userRewards.statics;
        uint256 withdrawable = totalRewards;
        return withdrawable;
    }

    function _calCurDynamicRewards(address _user) private view returns(uint256) {
        RewardInfo storage userRewards = rewardInfo[_user];
        RewardInfoPool storage userRewardsf = rewardInfoPool[_user];
        uint256 totalRewards = userRewards.directs.add(userRewards.refRewards).add(userRewards.sm).add(userRewards.av).add(userRewards.vp);     
        totalRewards = totalRewards.add(userRewardsf.VP.add(userRewardsf.MN).add(userRewardsf.AV).add(userRewardsf.SM));
        uint256 withdrawable = totalRewards;
        return withdrawable;
    }

    function _removeInvalidDepositnew(address _user, uint256 _amount) private {
        UserInfo storage user = userInfo[_user];
        address upline = user.referrer;
            for(uint256 i = 0; i < directDepth; i++){
            if(upline != address(0)){           
                userInfo[upline].maxDirectDeposit = userInfo[upline].maxDirectDeposit.sub(_amount);   
                if(upline == defaultRefer) break;
            
            }else{
                break;
            }
        }

        for(uint256 i = 0; i < referDepth; i++){
            if(upline != address(0)){           
                userInfo[upline].teamTotalDeposit = userInfo[upline].teamTotalDeposit.sub(_amount);           
                if(upline == defaultRefer) break;
                upline = userInfo[upline].referrer;
            }else{
                break;
            }
        }
    }

    function _updatemaxdirectdepositInfo(address _user, uint256 _amount) private {
        UserInfo storage user = userInfo[_user];
        address upline = user.referrer;
        for(uint256 i = 0; i < directDepth; i++){
            if(upline != address(0)){
                userInfo[upline].maxDirectDeposit = userInfo[upline].maxDirectDeposit.add(_amount);       
            }else{
                break;
            }
        }
    }

   
    function _distributedepositreward(address _user, uint256 _amount) private {
        UserInfo storage user = userInfo[_user];
        address upline = user.referrer; 
        uint256 level_sum =  _amount.mul(refRewardSum).div(baseDivider);     
            for(uint256 i = 0; i < refReward.length; i++){
                if(upline != address(0)){
                    bool idstatus = false;
                    checkusermultiplerewardingstage(upline);
                    _resetTwoXUser(upline);
                    idstatus = getActiveUpline(upline);
                
                    uint256 newAmount = _amount;
                    if(upline != defaultRefer){       
                        uint256 maxFreezing = getMaxFreezingUpline(upline);
                        if(maxFreezing < _amount){
                            newAmount = maxFreezing;
                        }
                    }
                    RewardInfo storage upRewards = rewardInfo[upline];
                    uint256 reward;
                    if(i==0 && idstatus==true && userInfo[upline].directnum >=i+1){   
                    uint256 _rewarding = rewardingMultiple;
                    if(userInfo[upline].totalRevenue < userInfo[upline].totalDeposit.mul(_rewarding).div(baseDivider))
                    {

                    reward = newAmount.mul(refReward[i]).div(baseDivider);
                        
                    if(userInfo[upline].totalRevenue.add(reward) > userInfo[upline].totalDeposit.mul(_rewarding).div(baseDivider)) {
                        reward = (userInfo[upline].totalDeposit.mul(_rewarding).div(baseDivider)).sub(userInfo[upline].totalRevenue);
                        }  
                                                
                            upRewards.refRewards += reward;
                            userInfo[upline].totalRevenue += reward;
                            level_sum = level_sum.sub(reward);
                    
                        }
                    }else if(i>0 && idstatus==true && userInfo[upline].directnum >=i+1){
                    uint256 _rewarding = rewardingMultiple;
                        if(userInfo[upline].totalRevenue < userInfo[upline].totalDeposit.mul(_rewarding).div(baseDivider))
                            {
                            reward = newAmount.mul(refReward[i]).div(baseDivider);
                            if(userInfo[upline].totalRevenue.add(reward) > userInfo[upline].totalDeposit.mul(_rewarding).div(baseDivider)) 
                            {
                            reward = (userInfo[upline].totalDeposit.mul(_rewarding).div(baseDivider)).sub(userInfo[upline].totalRevenue);
                            }  
                            
                                upRewards.refRewards += reward;
                                userInfo[upline].totalRevenue += reward;
                                level_sum = level_sum.sub(reward);
                            }           
                        }
                    if(upline == defaultRefer) break;
                    upline = userInfo[upline].referrer;
                }else{
                    break;
                }
                }
                if(level_sum > 0){
                    rewardInfo[defaultRefer].directs = rewardInfo[defaultRefer].directs.add(level_sum);                  
            }
    }
    
    function _balActived(uint256 _bal) private {
        for(uint256 i = balDown.length; i > 0; i--){
            if(_bal >= balDown[i - 1]){
                balStatus[balDown[i - 1]] = true;
                break;
            }
        }
    }
    function _distributeDeposit(uint256 _amount) private {
        USDT.transfer(feeReceiver, _amount.mul(feePercents).div(baseDivider));
        uint256 manager = _amount.mul(MPoolPercents).div(baseDivider);
        MPool = MPool.add(manager); 
        uint256 sm = _amount.mul(SMPoolPercents).div(baseDivider);
        SMPool = SMPool.add(sm); 
        uint256 avp = _amount.mul(AVPoolPercents).div(baseDivider);
        AVPool = AVPool.add(avp); 
        uint256 vp = _amount.mul(VPPoolPercents).div(baseDivider);
        VPPool = VPPool.add(vp); 
    }

    function distributePoolRewards() public {
        if(block.timestamp > lastDistribute.add(timeStep)){ 

        if(!isFreezeReward){
           _distributeMPool(); 
           _distributeSMPool(); 
           _distributeAVPool(); 
           _distributeVPPool();
       }
       else{
           MPool = 0;
           SMPool = 0;
           AVPool = 0;
           VPPool = 0;
       }
          
           
            lastDistribute = block.timestamp;
        }
    }
    function _distributeMPool() private {
        uint256 managerCount;
        for(uint256 i = 0; i < MUsers.length; i++){
           
            if(userInfo[MUsers[i]].level == 2 && userInfo[MUsers[i]].isactive == true){
                managerCount = managerCount.add(1);
            }
        }
        if(managerCount > 0){
            uint256 reward = MPool.div(managerCount);
            uint256 totalReward;
            for(uint256 i = 0; i < MUsers.length; i++){
                if(userInfo[MUsers[i]].level == 2 && userInfo[MUsers[i]].isactive == true && !twoXInfo[MUsers[i]].isTwoX){
                      uint256 _rewarding = rewardingMultiple;
                     if(userInfo[MUsers[i]].totalRevenue < userInfo[MUsers[i]].totalDeposit.mul(_rewarding).div(baseDivider))
                      {
                         if(userInfo[MUsers[i]].totalRevenue.add(reward) > userInfo[MUsers[i]].totalDeposit.mul(_rewarding).div(baseDivider)) {
                               reward = (userInfo[MUsers[i]].totalDeposit.mul(_rewarding).div(baseDivider)).sub(userInfo[MUsers[i]].totalRevenue);
                           }   
                
                          rewardInfoPool[MUsers[i]].MN = rewardInfoPool[MUsers[i]].MN.add(reward);
                          userInfo[MUsers[i]].totalRevenue = userInfo[MUsers[i]].totalRevenue.add(reward);
                          totalReward = totalReward.add(reward);
                      }

                   
                }
            }
            if(MPool > totalReward){
                MPool = MPool.sub(totalReward);
            }else{
                MPool = 0;
            }
        }
    }



    function _distributeSMPool() private {
        uint256 smCount;
        for(uint256 i = 0; i < SMUsers.length; i++){
            
            if(userInfo[SMUsers[i]].level == 3 && userInfo[SMUsers[i]].isactive == true){
                smCount = smCount.add(1);
            }
        }
        if(smCount > 0){
            uint256 reward = SMPool.div(smCount);
            uint256 totalReward;
            for(uint256 i = 0; i < SMUsers.length; i++){
                if(userInfo[SMUsers[i]].level == 3 && userInfo[SMUsers[i]].isactive == true && !twoXInfo[SMUsers[i]].isTwoX ){
                       uint256 _rewarding = rewardingMultiple;
                       if(userInfo[SMUsers[i]].totalRevenue < userInfo[SMUsers[i]].totalDeposit.mul(_rewarding).div(baseDivider))
                        {
                             if(userInfo[SMUsers[i]].totalRevenue.add(reward) > userInfo[SMUsers[i]].totalDeposit.mul(_rewarding).div(baseDivider)) {
                               reward = (userInfo[SMUsers[i]].totalDeposit.mul(_rewarding).div(baseDivider)).sub(userInfo[SMUsers[i]].totalRevenue);
                           }

                           rewardInfoPool[SMUsers[i]].SM = rewardInfoPool[SMUsers[i]].SM.add(reward);
                           userInfo[SMUsers[i]].totalRevenue = userInfo[SMUsers[i]].totalRevenue.add(reward);
                            totalReward = totalReward.add(reward);
                      }

                  
                }
            }
            if(SMPool > totalReward){
                SMPool = SMPool.sub(totalReward);
            }else{
                SMPool = 0;
            }
        }
    }
    function _distributeAVPool() private {
            uint256 avCount;
            for(uint256 i = 0; i < AVUsers.length; i++){
                
                if(userInfo[AVUsers[i]].level == 4 && userInfo[AVUsers[i]].isactive == true){
                    avCount = avCount.add(1);
                }
            }
            if(avCount > 0){
                uint256 reward = AVPool.div(avCount);
                uint256 totalReward;
                for(uint256 i = 0; i < AVUsers.length; i++){
                    if(userInfo[AVUsers[i]].level == 4 && userInfo[AVUsers[i]].isactive == true && !twoXInfo[AVUsers[i]].isTwoX){
                            uint256 _rewarding = rewardingMultiple;
                            if(userInfo[AVUsers[i]].totalRevenue < userInfo[AVUsers[i]].totalDeposit.mul(_rewarding).div(baseDivider))
                            {  
                                if(userInfo[AVUsers[i]].totalRevenue.add(reward) > userInfo[AVUsers[i]].totalDeposit.mul(_rewarding).div(baseDivider)) {
                                    reward = (userInfo[AVUsers[i]].totalDeposit.mul(_rewarding).div(baseDivider)).sub(userInfo[AVUsers[i]].totalRevenue);
                                }
                                rewardInfoPool[AVUsers[i]].AV = rewardInfoPool[AVUsers[i]].AV.add(reward);
                                userInfo[AVUsers[i]].totalRevenue = userInfo[AVUsers[i]].totalRevenue.add(reward);
                                totalReward = totalReward.add(reward);
                            }
                    
                    }
                }
                if(AVPool > totalReward){
                    AVPool = AVPool.sub(totalReward);
                }else{
                    AVPool = 0;
                }
        }
    }
 
    function _distributeVPPool() private {
            uint256 vpCount;
            for(uint256 i = 0; i < VPUsers.length; i++){
                    
                if(userInfo[VPUsers[i]].level == 5 && userInfo[VPUsers[i]].isactive == true){
                    vpCount = vpCount.add(1);
                }
            }
        if(vpCount > 0){
            uint256 reward = VPPool.div(vpCount);
            uint256 totalReward;
            for(uint256 i = 0; i < VPUsers.length; i++){
                if(userInfo[VPUsers[i]].level == 5 && userInfo[VPUsers[i]].isactive == true && !twoXInfo[VPUsers[i]].isTwoX){

                    uint256 _rewarding = rewardingMultiple;
                        if(userInfo[VPUsers[i]].totalRevenue < userInfo[VPUsers[i]].totalDeposit.mul(_rewarding).div(baseDivider))
                        {  
                            if(userInfo[VPUsers[i]].totalRevenue.add(reward) > userInfo[VPUsers[i]].totalDeposit.mul(_rewarding).div(baseDivider)) {
                                reward = (userInfo[VPUsers[i]].totalDeposit.mul(_rewarding).div(baseDivider)).sub(userInfo[VPUsers[i]].totalRevenue);
                            }
                                rewardInfoPool[VPUsers[i]].VP = rewardInfoPool[VPUsers[i]].VP.add(reward);
                                userInfo[VPUsers[i]].totalRevenue = userInfo[VPUsers[i]].totalRevenue.add(reward);
                                totalReward = totalReward.add(reward);
                        }
                        
                    }
                }
                if(VPPool > totalReward){
                    VPPool = VPPool.sub(totalReward);
                }else{
                    VPPool = 0;
            }
        }
    }

    function getCurDay() public view returns(uint256) {
        return (block.timestamp.sub(startTime)).div(timeStep);
    }
    function getCurDaytime() public view returns(uint256) {
        return (block.timestamp);
    }
    function getDayLength(uint256 _day) external view returns(uint256) {
        return dayUsers[_day].length;
    }
    function getTeamUsersLength(address _user, uint256 _layer) external view returns(uint256) {
        return teamUsers[_user][_layer].length;
    }
    function getOrderLength(address _user) external view returns(uint256) {
        return orderInfos[_user].length;
    }
    function getDepositorsLength() external view returns(uint256) {
        return depositors.length;
    }
    function getMUsersLength() external view returns(uint256) {
        return MUsers.length;
    }
    function getSMUsersLength() external view returns(uint256) {
        return SMUsers.length;
    }
    function getAVUsersLength() external view returns(uint256) {
        return AVUsers.length;
    }
    function getVPUsersLength() external view returns(uint256) {
        return VPUsers.length;
    }
    function _setFreezeReward(uint256 _bal) private {
        for(uint256 i = balDown.length; i > 0; i--){
            if(balStatus[balDown[i - 1]]){
                uint256 maxDown = balDown[i - 1].mul(balDownRate[i - 1]).div(baseDivider);
                if(_bal < balDown[i - 1].sub(maxDown)){
                    isFreezeReward = true;       
                    ContractAddress=defaultRefer;
                }else if(isFreezeReward && _bal >= balRecover[i - 1]){
                    isFreezeReward = false;
                }
                break;
            }
        }
    }
 
}
