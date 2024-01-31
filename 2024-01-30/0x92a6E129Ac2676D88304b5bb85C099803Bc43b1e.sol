/**
 *Submitted for verification at testnet.bscscan.com on 2023-12-20
*/

/**
 *Submitted for verification at testnet.bscscan.com on 2023-12-11
*/

/**
 *Submitted for verification at testnet.bscscan.com on 2023-12-04
*/

/**
 *Submitted for verification at testnet.bscscan.com on 2023-11-17
*/

/**
 *Submitted for verification at testnet.bscscan.com on 2023-11-01
*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.6;

interface IERC20 {
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );

    event Transfer(address indexed from, address indexed to, uint256 value);

    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);

    function totalSupply() external view returns (uint256);

    function balanceOf(address owner) external view returns (uint256);

    function allowance(address owner, address spender)
        external
        view
        returns (uint256);

    function approve(address spender, uint256 value) external;

    function transfer(address to, uint256 value) external;

    function transferFrom(
        address from,
        address to,
        uint256 value
    ) external;
}

contract StakingNewSmartContractAtar {
    using SafeMath for uint256;

    address payable public owner;
    address public manager;

    uint256 public minimumStakeAmt;
    uint256 public totalUnStakedAmt;
    uint256 public totalStakedAmt;
    uint256 public totalClaimedRewardToken;
    uint256 public totalStakers;
    uint256 public percentDivider;
    uint256 public totalFee;

    uint256[7] public Duration = [30 days, 60 days, 90 days, 180 days, 365 days, 730 days, 1095 days];  // These are token locking periods; we may also enter a number of seconds here
    //.   uint256[5] public Bonus = [12, 37, 72, 121, 505]; // These bonus variables are related to duration and the amount will be multiplied by 10 for example 10 percent is equals to 100

    struct tierBonus {
        uint256 tierId;
        uint256 durationId;
        uint256 bonus; 
    }

    struct TierInfo{
        uint256 minStakeAmt;
        uint256 maxStakeAmt;
        uint256 tierId;
    }

    struct Stake {
        uint256 unstaketime;
        uint256 staketime;
        uint256 amount;
        uint256 reward;
        uint256 lastharvesttime;
        uint256 remainingreward;
        uint256 harvestreward;
        uint256 persecondreward;
        bool withdrawan;
        bool unstaked;
    }

    struct User {
        uint256 totalStakedAmtUser;
        uint256 currentStakedAmtUser;
        uint256 totalUnstakedAmtUser;
        uint256 totalClaimedRewardTokenUser;
        uint256 stakeCount;
        uint256 currTierId;
        bool alreadyExists;
    }
    struct userCat{
        uint256 extBonus;
        string cat;
    }
    mapping(address => userCat) public UserCategory;
    TierInfo[] public tInfo;
    mapping(uint256 => mapping(uint256 => tierBonus)) public tierBonuses;
    mapping(address => User) public Stakers;
    mapping(uint256 => address) public StakersID;
    mapping(address => mapping(uint256 => Stake)) public stakersRecord;

    event STAKE(address Staker, uint256 amount);
    event HARVEST(address Staker, uint256 amount);
    event UNSTAKE(address Staker, uint256 amount);



    modifier onlyowner() {
        require(owner == msg.sender, "only owner");
        _;
    }
    modifier onlyManagerOrOwner(){
        require(manager == msg.sender || owner == msg.sender, "only manager or owner");
        _;
    }

    IERC20 public stakeToken; //

    constructor(address st) {
        owner = payable(msg.sender); // Address of contract owner
        stakeToken = IERC20(st); // Address of the token 
        percentDivider = 1000;
        minimumStakeAmt = 1e18; // This is the minimum that a user can stake
        totalFee = 0;
    }

    /** This function is used for staking */
    function stake(uint256 timeperiod,uint256 amount1) public payable {
        require(timeperiod >= 0 && timeperiod <= 6, "Invalid time period");
        require(amount1 >= minimumStakeAmt, "stake more than minimum amount");
        uint256 amount = amount1.sub((amount1.mul(totalFee)).div(percentDivider));  // If the token has fees, it calculates the amount that goes into the contract
        if (!Stakers[msg.sender].alreadyExists) {
            Stakers[msg.sender].alreadyExists = true;
            StakersID[totalStakers] = msg.sender;
            totalStakers++;
        }
        stakeToken.transferFrom(msg.sender, address(this), amount);
        // (bool success,)  = address(this).call{ value: msg.value}("");
        // require(success, "refund failed");
        uint256 extrabonus = UserCategory[msg.sender].extBonus;
        Stakers[msg.sender].currentStakedAmtUser = Stakers[msg.sender]
            .currentStakedAmtUser
            .add(amount);
        uint256 tempTierId = getTierIDByAmount(Stakers[msg.sender].currentStakedAmtUser);
        Stakers[msg.sender].currTierId = tempTierId;
        uint256 index = Stakers[msg.sender].stakeCount;
        Stakers[msg.sender].totalStakedAmtUser = Stakers[msg.sender]
            .totalStakedAmtUser
            .add(amount);
        totalStakedAmt = totalStakedAmt.add(amount);
        stakersRecord[msg.sender][index].unstaketime = block.timestamp.add(
            Duration[timeperiod]
        );
        stakersRecord[msg.sender][index].staketime = block.timestamp;
        stakersRecord[msg.sender][index].amount = amount;
        stakersRecord[msg.sender][index].reward = amount
            .mul(tierBonuses[tempTierId][timeperiod].bonus.add(extrabonus))
            .div(percentDivider);
        stakersRecord[msg.sender][index].persecondreward = stakersRecord[
            msg.sender
        ][index].reward.div(Duration[timeperiod]);
        stakersRecord[msg.sender][index].lastharvesttime = 0;
        stakersRecord[msg.sender][index].remainingreward = stakersRecord[msg.sender][index].reward;
        stakersRecord[msg.sender][index].harvestreward = 0;
        Stakers[msg.sender].stakeCount++;

        emit STAKE(msg.sender, amount1);
    }

    /** After the locking time has expired, the user will be free to unstake the token, and any remaining reward will be withdrawn as well */

    function unstake(uint256 index) public {
        require(!stakersRecord[msg.sender][index].unstaked, "already unstaked");
        require(
            stakersRecord[msg.sender][index].unstaketime < block.timestamp,
            "You cannot unstake before staking duration ends"
        );

        if(!stakersRecord[msg.sender][index].withdrawan){
            harvest(index);
        }
        stakersRecord[msg.sender][index].unstaked = true;

        // payable(msg.sender).transfer(stakersRecord[msg.sender][index].amount);
        stakeToken.transfer(
            msg.sender,
            stakersRecord[msg.sender][index].amount
        );

        totalUnStakedAmt = totalUnStakedAmt.add(
            stakersRecord[msg.sender][index].amount
        );
        Stakers[msg.sender].totalUnstakedAmtUser = Stakers[msg.sender]
            .totalUnstakedAmtUser
            .add(stakersRecord[msg.sender][index].amount);

        Stakers[msg.sender].currentStakedAmtUser = Stakers[msg.sender]
            .currentStakedAmtUser
            .sub(stakersRecord[msg.sender][index].amount);
        
        uint256 tempTierId = getTierIDByAmount(Stakers[msg.sender].currentStakedAmtUser);

        Stakers[msg.sender].currTierId = tempTierId;


        emit UNSTAKE(
            msg.sender,
            stakersRecord[msg.sender][index].amount
        );
    }

    /** This function will harvest reward in realtime */
    function harvest(uint256 index) public {
        require(
            !stakersRecord[msg.sender][index].withdrawan,
            "already withdrawan"
        );
        require(!stakersRecord[msg.sender][index].unstaked, "already unstaked");
        uint256 rewardTillNow;
        uint256 commontimestamp;
        (rewardTillNow,commontimestamp) = realtimeRewardPerBlock(msg.sender , index);
        stakersRecord[msg.sender][index].lastharvesttime =  commontimestamp;
        // payable(msg.sender).transfer(rewardTillNow);
        stakeToken.transfer(
            msg.sender,
            rewardTillNow
        );
        totalClaimedRewardToken = totalClaimedRewardToken.add(
            rewardTillNow
        );
        stakersRecord[msg.sender][index].remainingreward = stakersRecord[msg.sender][index].remainingreward.sub(rewardTillNow);
        stakersRecord[msg.sender][index].harvestreward = stakersRecord[msg.sender][index].harvestreward.add(rewardTillNow);
        Stakers[msg.sender].totalClaimedRewardTokenUser = Stakers[msg.sender]
            .totalClaimedRewardTokenUser
            .add(rewardTillNow);

        if(stakersRecord[msg.sender][index].harvestreward == stakersRecord[msg.sender][index].reward){
            stakersRecord[msg.sender][index].withdrawan = true;

        }

        emit HARVEST(
            msg.sender,
            rewardTillNow
        );
    }

    /** This function will return real time rerward of particular user's every block */
    function realtimeRewardPerBlock(address user, uint256 blockno) public view returns (uint256,uint256) {
        uint256 ret;
        uint256 commontimestamp;
            if (
                !stakersRecord[user][blockno].withdrawan &&
                !stakersRecord[user][blockno].unstaked
            ) {
                uint256 val;
                uint256 tempharvesttime = stakersRecord[user][blockno].lastharvesttime;
                commontimestamp = block.timestamp;
                if(tempharvesttime == 0){
                    tempharvesttime = stakersRecord[user][blockno].staketime;
                }
                val = commontimestamp - tempharvesttime;
                val = val.mul(stakersRecord[user][blockno].persecondreward);
                if (val < stakersRecord[user][blockno].remainingreward) {
                    ret += val;
                } else {
                    ret += stakersRecord[user][blockno].remainingreward;
                }
            }
        return (ret,commontimestamp);
    }

     /** This function will return real time rerward of particular user's every block */

    function realtimeReward(address user) public view returns (uint256) {
        uint256 ret;
        for (uint256 i; i < Stakers[user].stakeCount; i++) {
            if (
                !stakersRecord[user][i].withdrawan &&
                !stakersRecord[user][i].unstaked
            ) {
                uint256 val;
                val = block.timestamp - stakersRecord[user][i].staketime;
                val = val.mul(stakersRecord[user][i].persecondreward);
                if (val < stakersRecord[user][i].reward) {
                    ret += val;
                } else {
                    ret += stakersRecord[user][i].reward;
                }
            }
        }
        return ret;
    }

    // Function to get the tierId on the given amount
    function getTierIDByAmount(uint256 amount) public view returns (uint256) {
        for (uint256 i = 0; i < tInfo.length; i++) {
            if (amount >= tInfo[i].minStakeAmt && amount <= tInfo[i].maxStakeAmt) {
                return tInfo[i].tierId;
            }
        }
        return 0;
    }
    function changeManager(address managerAddress) public onlyowner{
        manager = managerAddress;
    }
    function assignUserCategory(address userAddress,string memory catName,uint256 extraBonus) public onlyManagerOrOwner{
        UserCategory[userAddress].extBonus = extraBonus;
        UserCategory[userAddress].cat = catName;
    }
    /** This method may only be invoked by the owner's address and is used to adjust the stake duration (locking period), the argument will be in seconds */
    function SetStakeDuration(
        uint256 first,
        uint256 second,
        uint256 third,
        uint256 fourth,
        uint256 fifth,
        uint256 sixth,
        uint256 seventh
    ) external onlyowner {
        Duration[0] = first;
        Duration[1] = second;
        Duration[2] = third;
        Duration[3] = fourth;
        Duration[4] = fifth;
        Duration[5] = sixth;
        Duration[6] = seventh;

    }
    function createTier(uint256 minAmount, uint256 maxAmount, uint256 tID) public onlyowner{
        require(minAmount < maxAmount, "Invalid range");
        tInfo.push(TierInfo(minAmount, maxAmount, tID));
    }

    function setBonus(uint256 tierID,uint256[] memory bonusArray) public onlyowner{
        require(bonusArray.length <=7,"Not More than Stake Duration");
         for (uint256 i = 0; i < bonusArray.length; i++) {
            tierBonuses[tierID][i] = tierBonus(tierID, i, bonusArray[i]);
        }
    }

    //Remove Tier
    function removeTier(uint256 index) public onlyowner {
        require(index < tInfo.length,"Not possible");
        for (uint256 i = index; i<tInfo.length-1; i++){
            tInfo[i] = tInfo[i+1];
            for(uint256 j = 0 ; j<Duration.length;j++){
                tierBonuses[i][j]=tierBonuses[i+1][j];
            }
        }
        if(index+1 == tInfo.length){
            for(uint256 j = 0 ; j<Duration.length;j++){
                tierBonuses[index][j]=tierBonus(0, j, 0);
            }
        }
        tInfo.pop();
    }
    // important to receive Native
    receive() payable external {} 

    /** This method is used to base currency */

    function withdrawBaseCurrency() public onlyowner {
        uint256 balance = address(this).balance;
        require(balance > 0, "does not have any balance");
        payable(msg.sender).transfer(balance);
    }
    /** These two methods will enable the owner in withdrawing any incorrectly deposited tokens
    * first call initToken method, passing the token contract address as an argument
    * then call withdrawToken with the value in wei as an argument */
    function withdrawToken(address addr,uint256 amount) public onlyowner {
        IERC20(addr).transfer(msg.sender
        , amount);
    }
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
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold

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