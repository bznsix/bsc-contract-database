// File contracts/LEXEACH_RBCF.sol
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;



interface IBEP20 {
    /**
     * @dev Returns the amount of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the token decimals.
     */
    function decimals() external view returns (uint8);

    /**
     * @dev Returns the token symbol.
     */
    function symbol() external view returns (string memory);

    /**
     * @dev Returns the token name.
     */
    function name() external view returns (string memory);

    /**
     * @dev Returns the bep token owner.
     */
    function getOwner() external view returns (address);

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
    function transfer(
        address recipient,
        uint256 amount
    ) external returns (bool);

    /**
     * @dev Returns the remaining number of tokens that `spender` will be
     * allowed to spend on behalf of `owner` through {transferFrom}. This is
     * zero by default.
     *
     * This value changes when {approve} or {transferFrom} are called.
     */
    function allowance(
        address _owner,
        address spender
    ) external view returns (uint256);

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
    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);

    function freezeToken(
        address recipient,
        uint256 amount
    ) external returns (bool);

    function unfreezeToken(address account) external returns (bool);

    function mint(address _to, uint256 amount) external returns (bool);

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
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
    event Unfreeze(
        address indexed _unfreezer,
        address indexed _to,
        uint256 _amount
    );
}

contract NEW_CBC_ROI {
    address public ownerWallet;
    uint public currUserID = 499;
    uint public level_income = 0;
    // Percentage and Times of Fee Increament
    // Setting the renewal auto increament of

    struct UserStruct {
        bool isExist;
        uint id;
        uint referrerID;
        uint topupAmount;
        uint referredUsers;
        uint capping;
        uint income;
        uint rootBalance;
        uint assuredReward;
        uint levelIncomeReceived;
        uint incomeTaken;
        uint takenROI;
        uint256 stakeTimes;
        mapping(uint => uint) levelExpired;
        uint incomeMissed;
    }
    struct StackeStruct {
        uint stakeTimes;
        uint lastStaked;
        uint totalStaked;
        uint currentStaked;
        uint rootStakeBalance;
        uint rewardPercentage;
        uint takenStkngReward;
        //uint withdrawableStaking;
    }
    // MATRIX CONFIG FOR AUTO-POOL FUND
    // USERS
    mapping(address => UserStruct) public users;
    mapping(address => StackeStruct) public stakeUser;

    mapping(uint => address) public userList;
    mapping(uint => uint) public LEVEL_PRICE;
    mapping(address => uint256) public lastTopup;
    mapping(address => uint256) public rewardWin;
    mapping(address => uint256) public regTime;
    mapping(address => uint256) public stakeMonths;
    mapping(address => uint256) public stkTime;
    mapping(address => uint256) public stkCapping;
    mapping(address => uint256) public totalIncomeTaken;
    mapping(uint256 => bool) public stakeExist;
    IBEP20 token;
    IBEP20 public stableCoin;

    //   mapping(string => address) token; // Token Address Hold with name
    uint public REGESTRATION_FESS;

    bool ownerPaid;
    // Events
    event SponsorIncome(address indexed _user,address indexed _referrer,uint _time);
    event rewardBonus(address indexed _user,address indexed _referrer,uint _amount);
    event WithdrawROI(address indexed user, uint256 reward);
    event WithdrawStakingROI(address indexed user, uint256 reward);
    event WithdrawWorkingIncome(address indexed user, uint256 reward);
    event TopUp(address indexed sender, uint256 amount, uint256 now);
    event Staked(address indexed sender, uint256 amount, uint256 now);
    event WithdrawStable(address sender, address _to,uint256 amount);
    event allIncomeWithdrawn(address indexed sender, uint256 amount, uint256 now);
    event LevelsIncome(address indexed _user,address indexed _referral,uint indexed _level,uint _amount,uint _time);
    event TopupLevelsIncome(address indexed _user,address indexed _referral,uint indexed _level,uint _amount,uint _time);

    UserStruct[] private requests;

    // Owner Set Token Acceptance Format
    // string tokenAcceptType = "NATIVE-COIN";

    constructor(address _token, address stableCoin_) {
        ownerWallet = msg.sender;
        currUserID++;
        REGESTRATION_FESS = 25e18;
        LEVEL_PRICE[1] = REGESTRATION_FESS / 2;
        LEVEL_PRICE[2] = REGESTRATION_FESS * 6 / 100;
        LEVEL_PRICE[3] = REGESTRATION_FESS * 6 / 100;
        LEVEL_PRICE[4] = REGESTRATION_FESS * 6 / 100;
        LEVEL_PRICE[5] = REGESTRATION_FESS * 6 / 100;
        LEVEL_PRICE[6] = REGESTRATION_FESS * 3 / 100;
        LEVEL_PRICE[7] = REGESTRATION_FESS * 3 / 100;
        LEVEL_PRICE[8] = REGESTRATION_FESS * 3 / 100;
        LEVEL_PRICE[9] = REGESTRATION_FESS * 2 / 100;
        LEVEL_PRICE[10] = REGESTRATION_FESS * 2 / 100;
        LEVEL_PRICE[11] = REGESTRATION_FESS * 2 / 100;
        //LEVEL_PRICE[12] = REGESTRATION_FESS / 100;
        //LEVEL_PRICE[13] = REGESTRATION_FESS / 100;
        //LEVEL_PRICE[14] = REGESTRATION_FESS / 100;
        level_income = REGESTRATION_FESS / 100;
        users[ownerWallet].isExist = true;
        users[ownerWallet].id = currUserID;
        stakeExist[24] = true;
        stakeExist[36] = true;
        stakeExist[48] = true;
        //stakeExist[60] = true;
        // user
        userList[currUserID] = ownerWallet;
        token = IBEP20(_token);

        stableCoin = IBEP20(stableCoin_);
    }

    modifier onlyOwner() {
        require(
            msg.sender == ownerWallet,
            "Only Owner can access this function."
        );
        _;
    }

    function Registration(uint _referrerID, uint256 _amount) public payable {
        require(!users[msg.sender].isExist, "User Exists");
        require(
            _referrerID > 499 && _referrerID <= currUserID,
            "Incorrect referral ID"
        );
        require(_amount == REGESTRATION_FESS, "Incorrect Value");
        require(
            stableCoin.allowance(msg.sender, address(this)) >= _amount,
            "NEED_TO_APPROVE_TOKEN"
        );
        stableCoin.transferFrom(msg.sender, address(this), _amount);
        currUserID++;
        users[msg.sender].isExist = true;
        users[msg.sender].id = currUserID;
        users[msg.sender].referrerID = _referrerID;
        userList[currUserID] = msg.sender;
        regTime[msg.sender] = block.timestamp;
        // Calculating ROI
       // uint256 amountTo = withdrawableROI(msg.sender);
        //users[msg.sender].withdrawable += amountTo;
        users[msg.sender].stakeTimes = block.timestamp;

        users[userList[users[msg.sender].referrerID]].referredUsers =
            users[userList[users[msg.sender].referrerID]].referredUsers +
            1;
        users[msg.sender].topupAmount = users[msg.sender].topupAmount + _amount;
        users[msg.sender].capping = users[msg.sender].capping + (_amount * 4);
        users[msg.sender].rootBalance =users[msg.sender].rootBalance +(_amount * 2);
        users[msg.sender].assuredReward =users[msg.sender].assuredReward +(_amount * 2);
        //token.mint(msg.sender, _amount); // Transfer Rewarded Token
        // send reward who refer 10 user in 5 days
        if (users[userList[_referrerID]].referredUsers == 10 &&
            users[msg.sender].stakeTimes - users[userList[_referrerID]].stakeTimes <= 432000){
                rewardWin[userList[_referrerID]] = rewardWin[userList[_referrerID]]+15e18;
                users[userList[_referrerID]].income = users[userList[_referrerID]].income + 15e18;
              //(stableCoin.transfer(userList[_referrerID],15e18));  
              emit rewardBonus(msg.sender, userList[_referrerID],_amount-10e18);
            }
        payReferral(1, msg.sender, msg.value);

        emit SponsorIncome(msg.sender, userList[_referrerID], block.timestamp);
    }

    function topUp(uint256 _amount) public {
        require(users[msg.sender].isExist, "User not Exists");
        if (lastTopup[msg.sender] == 0) {
            require(_amount == 50e18, "Incorrect amount");
        } else if (lastTopup[msg.sender] == 400e18) {
            require(_amount == 400e18, "Incorrect amount");
        } else {
            require(
                _amount == (lastTopup[msg.sender]) * 2,
                "Incorrect amount"
            );
        }
        require(
            stableCoin.allowance(msg.sender, address(this)) >= _amount,
            "NEED_TO_APPROVE_TOKEN"
        );
        stableCoin.transferFrom(msg.sender, address(this), _amount);
        //token.mint(msg.sender, _amount); // Transfer Rewarded Token
        lastTopup[msg.sender] = _amount;
        users[msg.sender].capping = users[msg.sender].capping + (_amount * 4);
        payTopupLevel(1, msg.sender, _amount);
        emit TopUp(msg.sender, _amount, block.timestamp);
    }

    function stakeCBC(uint256 _amount,uint _month) public {
        require(users[msg.sender].isExist, "User not Exists");
        require(stakeUser[msg.sender].currentStaked == 0, "Already staked");
        require(_amount % 100e18 == 0, "Amount must be a multiple of 100");
        require(_amount >= 100e18  && _amount <= 2400e18,"Incorrect amount not in range");
        //require(stakeExist[_amount], "Stacke Not Exist");
        require(stakeExist[_month], "invalid time period");
        require( stableCoin.allowance(msg.sender, address(this)) >= _amount,"NEED_TO_APPROVE_TOKEN");
        
        //uint256 amountTo = withdrawableStakingROI(msg.sender);
        stableCoin.transferFrom(msg.sender, address(this), _amount);
        token.mint(msg.sender,_amount);
        if (_month == 24){
        stakeMonths[msg.sender] = 24;    
        stakeUser[msg.sender].rootStakeBalance = _amount*72/100;
        stkCapping[msg.sender] = stkCapping[msg.sender] + _amount*72/100;
        stakeUser[msg.sender].rewardPercentage = 1000;
        }

        if (_month == 36){
        stakeMonths[msg.sender] = 36;
        stakeUser[msg.sender].rootStakeBalance = _amount*144/100;
        stkCapping[msg.sender] = stkCapping[msg.sender] + _amount*144/100;
        stakeUser[msg.sender].rewardPercentage = 750;
        }
        if (_month == 48){
        stakeMonths[msg.sender] = 48;    
        stakeUser[msg.sender].rootStakeBalance= _amount*240/100;
        stkCapping[msg.sender] = stkCapping[msg.sender] + _amount*240/100;
        stakeUser[msg.sender].rewardPercentage = 600;
        }
        
        //rootStakeBalance[msg.sender] += _amount;
        stakeUser[msg.sender].stakeTimes = block.timestamp;
        stkTime[msg.sender] = block.timestamp;
        //stakeUser[msg.sender].totalStaked += _amount;
        stakeUser[msg.sender].currentStaked = _amount;
        stakeUser[msg.sender].takenStkngReward = 0;
        users[userList[users[msg.sender].referrerID]].income =
            users[userList[users[msg.sender].referrerID]].income +
            (_amount / 10);
        stakeUser[userList[users[msg.sender].referrerID]].totalStaked = 
        stakeUser[userList[users[msg.sender].referrerID]].totalStaked +
        (_amount / 10);
        //stakeUser[msg.sender].lastStaked = _amount;
        emit Staked(msg.sender, _amount, block.timestamp);
    }

        
    

    function withdrawROI() public  {
        uint256 reward = withdrawableROI(msg.sender);
       // require(reward > 0, "No any withdrawableROI Found");
        if (reward >= users[msg.sender].rootBalance) {
            reward = users[msg.sender].rootBalance;
            users[msg.sender].assuredReward = 0;
        }
        users[msg.sender].rootBalance -= reward;
        users[msg.sender].takenROI += reward;
       // stableCoin.transfer(msg.sender, reward);
        //totalFreeze[msg.sender] -= reward;
       // users[msg.sender].withdrawable = 0;
        users[msg.sender].stakeTimes = block.timestamp;
        emit WithdrawROI(msg.sender, reward);
    }

    /**
     * @dev Withrawable ROI amount till now
     */
    function withdrawableROI(
        address _address
    ) public view returns (uint reward) 
    //{
       // if (users[_address].stakeTimes == 0) {
         //   return users[_address].withdrawable;
    //  }

       { uint256 numDays = (block.timestamp - users[_address].stakeTimes) / 86400;
        if (numDays > 0) {
            return
                ((users[_address].assuredReward * numDays) / 500);
        }else {
            return (0);
    }
       }
    function withdrawStakingROI() public  {
        require(realWithdrawableStakingROI(msg.sender)>=10e18,"staking bonus is less then 10 OSDT");
        uint256 reward = withdrawableStakingROI(msg.sender);
        address _user = msg.sender;
        //require(reward > 0,"No any withdrawableStaking ROI Found");
        if (reward >= stakeUser[msg.sender].rootStakeBalance) {
            reward = stakeUser[msg.sender].rootStakeBalance;
            stakeUser[msg.sender].lastStaked = stakeUser[msg.sender].currentStaked = 0;
            stakeUser[msg.sender].currentStaked = 0;
            stakeUser[msg.sender].rewardPercentage = 0;
            stakeMonths[msg.sender] = 0; 
            stkCapping[msg.sender] = 0;      
        }
        stakeUser[msg.sender].rootStakeBalance -= reward;
        stableCoin.transfer(_user,(reward/100)*80);
        
        //totalFreeze[msg.sender] -= reward;
        stakeUser[msg.sender].takenStkngReward += reward;
        stakeUser[msg.sender].stakeTimes = block.timestamp;
        totalIncomeTaken[msg.sender] = totalIncomeTaken[msg.sender] + reward;
        
        emit WithdrawStakingROI(msg.sender, reward);
    }
    
    function realWithdrableROI(address _address) public view returns (uint reward) {
       if (withdrawableROI(_address) > users[_address].rootBalance){
        return (users[_address].rootBalance);
        } else {
            return withdrawableROI(_address);
        }
    }
    /**
     * @dev Withrawable Staking ROI amount till now
     */
    function withdrawableStakingROI(address _address) public view returns (uint reward) {
        //if (stakeUser[_address].stakeTimes == 0) {
            if (stakeUser[_address].currentStaked > 0) {
            uint256 numDays = (block.timestamp - stakeUser[_address].stakeTimes) / 86400;
        if (numDays > 0) {
            return ((stakeUser[_address].currentStaked * numDays) / stakeUser[_address].rewardPercentage);
            
        } else {
            return (0);
        
            //return stakeUser[_address].withdrawableStaking;}
                // +
                //stakeUser[_address].withdrawableStaking;
        //} else {
          //  return stakeUser[_address].withdrawableStaking;
        }

    }
    }
    function realWithdrawableStakingROI(address _address) public view returns (uint reward) {
       if (withdrawableStakingROI(_address) > stakeUser[_address].rootStakeBalance){
        return (stakeUser[_address].rootStakeBalance);
        } else {
            return withdrawableStakingROI(_address);
        }
    }


    function withdrawIncome() public  {
        
        uint256 reward = withdrawableIncome(msg.sender);
        //address _user = msg.sender;
        //require(reward > 0,"No any withdrawableStaking ROI Found");
       // if (reward > 0) {
         //   reward = users[msg.sender].incomeWithdrawable;
                   
        //stableCoin.transfer(_user, reward);
        users[msg.sender].incomeTaken = users[msg.sender].incomeTaken + reward;
        //stableCoin.transfer(msg.sender, reward);

        //totalFreeze[msg.sender] -= reward;
       // users[msg.sender].incomeWithdrawable = 0;
        //users[msg.sender].stakeTimes = block.timestamp;
        emit WithdrawWorkingIncome(msg.sender, reward);
    }
    function withdrawableIncome (
        address _address
    ) public view returns (uint reward) {
        {
            return
                (users[_address].income)-(users[_address].incomeTaken);
                
    }
    }
    
    function totalWithdrawable (
        address _address
    ) public view returns (uint reward) {
        {
            return
                realWithdrawableStakingROI(_address) +
                realWithdrableROI(_address) +
                withdrawableIncome(_address);
                //((users[_address].income)-(users[_address].incomeTaken));
        }
    }

    function withdrawAllIncome() public {
        require(users[msg.sender].isExist, "User not Exists");
        require(users[msg.sender].referredUsers >= 1,"Refer_an_users_first");
        uint256 reward = realWithdrableROI(msg.sender) + withdrawableIncome(msg.sender);

        address _user = msg.sender;
        if ((users[msg.sender].id)!= 500) {
        require((users[msg.sender].takenROI +
        users[msg.sender].incomeTaken + reward) <= (users[msg.sender].capping),"capping limit crossed");
        }
        require(reward >= 10e18, "Less then 10 USDT");
        stableCoin.transfer(_user,(reward/100)*80);
        totalIncomeTaken[msg.sender] = totalIncomeTaken[msg.sender] + reward;

        
        //(users[msg.sender].incomeTaken) += (users[msg.sender].WithrawableIncome);
        
        
       
        if (withdrawableROI(msg.sender) > 0) {
            withdrawROI();
        }
        if (withdrawableIncome(msg.sender) > 0) {
            withdrawIncome();
        }
        
        
        //send total withdrawable income( withdrawableRIO + withdrawableStakingRIO + withdrawableWorkingIncome to user and
        //run three function 1. withdrawROI 2. withdrawStakingROI and reset withdrawableWorkingincome to 0
        emit allIncomeWithdrawn(msg.sender, reward, block.timestamp);
    }

    function payTopupLevel(
        uint _level,
        address _user,
        uint _value
    ) internal {
        address referer;
        referer = userList[users[_user].referrerID];
       // bool sent = false;
        uint level_price_local = 0;
        // Condition of level from 1- 1o and number of reffered user
        if (_level == 1 && users[referer].referredUsers >= 0) {
                level_price_local = (_value * 40) / 100;
            }
        else if (_level == 2 && users[referer].referredUsers >= 1) {
            level_price_local = (_value * 6) / 100;
         }
        else if (_level == 3 && users[referer].referredUsers >= 2) {
            level_price_local = (_value * 6) / 100;
        }
        else if (_level == 4 && users[referer].referredUsers >= 3) {
            level_price_local = (_value * 6) / 100;
        }
        else if (_level == 5 && users[referer].referredUsers >= 4) {
            level_price_local = (_value * 6) / 100;
        }
        else if (_level == 6 && users[referer].referredUsers >= 5) {
            level_price_local = (_value * 3) / 100;
        }
        else if (_level == 7 && users[referer].referredUsers >= 6) {
            level_price_local = (_value * 3) / 100;
        }
        else if (_level == 8 && users[referer].referredUsers >= 6) {
            level_price_local = (_value * 3) / 100;
        }
        else if (_level == 9 && users[referer].referredUsers >= 7) {
            level_price_local = (_value * 2) / 100;
        }
        else if (_level == 10 && users[referer].referredUsers >= 7) {
            level_price_local = (_value * 2) / 100;
        }
        else if (_level == 11 && users[referer].referredUsers >= 8) {
            level_price_local = (_value * 2) / 100;
        }
        else if (_level == 12 && users[referer].referredUsers >= 8) {
            level_price_local = (_value * 1) / 100;
        }
        else if (_level == 13 && users[referer].referredUsers >= 9) {
            level_price_local = (_value * 1) / 100;
        }
        else if (_level == 14 && users[referer].referredUsers >= 9) {
            level_price_local = (_value * 1) / 100;
        }
        else if (_level == 15 && users[referer].referredUsers >= 10) {
            level_price_local = (_value * 1) / 100;
        }
        else if (_level == 16 && users[referer].referredUsers >= 10) {
            level_price_local = (_value * 1) / 100;
        }
         else {
            users[referer].incomeMissed++;
        }
        //sent = stableCoin.transfer(address(uint160(referer)),level_price_local);

        //users[referer].levelIncomeReceived = users[referer].levelIncomeReceived + 1;
        users[userList[users[_user].referrerID]].income =
            users[userList[users[_user].referrerID]].income +
            level_price_local;
        //if (sent) {
            emit TopupLevelsIncome(referer, msg.sender, _level,level_price_local, block.timestamp);
            // level incone distributed counting direct as level one
            //for exampl, 10 maeans 1+9 one is direct plus 9 level after direct
            if (_level < 16 && users[referer].referrerID >= 1) {
                payTopupLevel(_level + 1, referer, _value);
           // } else {}
        }
        //if (!sent) {
        //  payTopupLevel(_level, referer, _value);
        }
    
    function withdrawalStableCoin(address payable _to, uint256 _amount) external onlyOwner{// Owner Withdraw Token From Contract
      
       stableCoin.transfer(_to,_amount);
    emit WithdrawStable(msg.sender, _to, _amount);
    }

    function payReferral(uint _level, address _user, uint _value) internal {
        address referer;
        referer = userList[users[_user].referrerID];
       // bool sent = false;
        uint level_price_local = 0;
            // Condition of level from 1- 1o and number of reffered user 
        if (_level == 1 && users[referer].referredUsers >= 0) {
            level_price_local = LEVEL_PRICE[_level];
         }
        else if (_level == 2 && users[referer].referredUsers >= 1) {
            level_price_local = LEVEL_PRICE[_level];
         }
        else if (_level == 3 && users[referer].referredUsers >= 2) {
            level_price_local = LEVEL_PRICE[_level];
        }
        else if (_level == 4 && users[referer].referredUsers >= 3) {
            level_price_local = LEVEL_PRICE[_level];
        }
        else if (_level == 5 && users[referer].referredUsers >= 4) {
            level_price_local = LEVEL_PRICE[_level];
        }
        else if (_level == 6 && users[referer].referredUsers >= 5) {
            level_price_local = LEVEL_PRICE[_level];
        }
        else if (_level == 7 && users[referer].referredUsers >= 6) {
            level_price_local = LEVEL_PRICE[_level];
        }
        else if (_level == 8 && users[referer].referredUsers >= 6) {
            level_price_local = LEVEL_PRICE[_level];
        }
        else if (_level == 9 && users[referer].referredUsers >= 7) {
            level_price_local = LEVEL_PRICE[_level];
        }
        else if (_level == 10 && users[referer].referredUsers >= 7) {
            level_price_local = LEVEL_PRICE[_level];
        }
        else if (_level == 11 && users[referer].referredUsers >= 8) {
            level_price_local = LEVEL_PRICE[_level];
        }
        else if (_level == 12 && users[referer].referredUsers >= 8) {
            level_price_local = level_income;
        }
        else if (_level == 13 && users[referer].referredUsers >= 9) {
            level_price_local = level_income;
        }
        else if (_level == 14 && users[referer].referredUsers >= 9) {
            level_price_local = level_income;
        }
        else if (_level == 15 && users[referer].referredUsers >= 10) {
            level_price_local = level_income;
        }
        else if (_level == 16 && users[referer].referredUsers >= 10) {
            level_price_local = level_income;
        }
        else{
            users[referer].incomeMissed ++;
        }
                //sent = stableCoin.transfer(address(uint160(referer)),level_price_local); 
        
        users[referer].levelIncomeReceived =
            users[referer].levelIncomeReceived +
            1;
        users[userList[users[_user].referrerID]].income =
            users[userList[users[_user].referrerID]].income +
            level_price_local;
      //  if (sent) {
        
            emit LevelsIncome(
                referer,
                msg.sender,
                _level,
                level_price_local,
                block.timestamp
               );
            // level incone distributed counting direct as level one 
            //for exampl, 10 maeans 1+9 one is direct plus 9 level after direct 
            if (_level < 16 && users[referer].referrerID >= 1) {
                payReferral(_level + 1, referer, _value);
         //   } else {
            }
        }
     //   if (!sent) {
         //   payReferral(_level, referer, _value);
    
}