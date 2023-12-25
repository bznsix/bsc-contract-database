// SPDX-License-Identifier: MIT

/*
█▄▄  █▀  █▀▀    █▀  █░█  █▄░█  █▀█  █  █▀  █▀▀
█▄█  ▄█  █▄▄    ▄█  █▄█  █░▀█  █▀▄  █  ▄█  ██▄
*/

pragma solidity ^0.8.7;

interface IERC20 {
    function transfer(address recipient, uint256 amount)
        external
        returns (bool);

    function approve(address spender, uint256 amount) external returns (bool);
    function balanceOf(address account) external view returns (uint256);

    function allowance(address owner, address spender)
        external
        view
        returns (uint256);

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);
} 


/**
 * @dev Contract module which provides a basic access control mechanism, where
 * there is an account (an owner) that can be granted exclusive access to
 * specific functions.
 *
 * By default, the owner account will be the one that deploys the contract. This
 * can later be changed with {transferOwnership}.
 *
 * This module is used through inheritance. It will make available the modifier
 * `onlyOwner`, which can be applied to your functions to restrict their use to
 * the owner.
 */
abstract contract Ownable {
    address private _owner;
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor() {
        _setOwner(msg.sender);
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view virtual returns (address) {
        return _owner;
    }
    
    /**
    * @dev Throws if called by any account other than the owner.
    */
    modifier onlyOwner() {
        require(_owner == msg.sender, "Ownable: caller is not the owner");
        _;
    }
    
    /**
    * @dev Leaves the contract without owner. It will not be possible to call
    * `onlyOwner` functions anymore. Can only be called by the current owner.
    *
    * NOTE: Renouncing ownership will leave the contract without an owner,
    * thereby removing any functionality that is only available to the owner.
    */
    function renounceOwnership() public onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    function _setOwner(address newOwner) private {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}
 
contract BSCSunRise is Ownable {  
    event NodeRegister(address node , address upline , uint8 level);
    event NodeLevelUp(address node , uint8 oldLevel , uint8 newLevel);
    event UserFlashedOut(address node ,uint8 atLevel, uint256 profit);
    event PoolCharged(uint16 forDays, uint256 amount);

    uint24 internal constant calcPeriod = 86400;
    uint16 internal constant basePrice = 20;
    uint16 internal lastCalcIndex = 10;
    uint16 internal lastWithdrawIndex = 9;
    uint256 lastCalc = block.timestamp;
    bool internal canWithdraw;

    struct Level{
        uint256 price;
        uint8  parityAmount;
        uint16 perDay;
        uint256 perDayUSDT;
    }
    mapping (uint8 => Level)  internal Levels;
    struct Node {
        address ad;
        uint24 LCap;
        uint24 RCap;
        uint8 ln;
        uint32 allTimeParity;
        uint256 registerTime;
        uint16 rwi;
        bool needLevelUp;
    }
    
    mapping (uint32 => Node) internal Nodes;
    uint32 internal totalUsers = 0;
 
    IERC20 PaymentToken = IERC20(0x55d398326f99059fF775485246999027B3197955);

    uint256 internal withdrawPool;
    uint256 internal lotteryPool;

    struct PoolStruct {
        uint256 sumDeposit;
        uint24  sumParity;    
        mapping(address => uint24) userParity;
        mapping(uint16 => uint32) users;
        mapping(uint32 => bool) selfWithdrawalUsers;
        uint16  countUserParity;
        mapping(uint32 => uint256) userProfit;
    }

    mapping (address => uint256)  internal userProfits;
    mapping (uint16  => PoolStruct) internal pool;
    mapping (address => address) internal parent;
    mapping (address => mapping (uint8 => address)) internal children;
    mapping (address => uint32) internal uids;
    mapping (address => uint256) internal lotteryPerUser;
    mapping (address => uint256) internal lotteryPerUserTime;
    
    constructor() { 
        setLevels(); 
        totalUsers++;
        Nodes[totalUsers].registerTime = block.timestamp;
        Nodes[totalUsers].ad = msg.sender; 
        Nodes[totalUsers].ln = 5;
        Nodes[totalUsers].rwi = lastCalcIndex;
        uids[msg.sender] = totalUsers;
    }

    function chargeBinaryPool(uint16 addDay , uint256 amount) external{
        require(PaymentToken.allowance(msg.sender , address(this)) >= amount , "Approve to transfer BUSD first.");
        require(PaymentToken.transferFrom(msg.sender , address(this) , amount),"Token transfer failure.");
        pool[lastCalcIndex + addDay].sumDeposit += amount;
        emit PoolCharged(addDay , amount);
    }

    function setLevels() internal{
        // level $20
        Levels[1].price = (uint256)(basePrice) * (10 ** 18);
        Levels[1].parityAmount = 1;
        Levels[1].perDay = 9;
        Levels[1].perDayUSDT = 4  * (10 ** 19);

        // level $60
        Levels[2].price = (uint256)(basePrice * 3) * (10 ** 18);
        Levels[2].parityAmount = 3;
        Levels[2].perDay = 40;
        Levels[2].perDayUSDT = 18  * (10 ** 19);

        // level $100
        Levels[3].price = (uint256)(basePrice * 5) * (10 ** 18);
        Levels[3].parityAmount = 5;
        Levels[3].perDay = 90;
        Levels[3].perDayUSDT = 4  * (10 ** 20);

        // level $200
        Levels[4].price = (uint256)(basePrice) * (10 ** 19);
        Levels[4].parityAmount = 10;
        Levels[4].perDay = 205;
        Levels[4].perDayUSDT = 10 ** 21;

        // level $400
        Levels[5].price = (uint256)(basePrice * 25) * (10 ** 18);
        Levels[5].parityAmount = 25;
        Levels[5].perDay = 310;
        Levels[5].perDayUSDT = 15 *  (10 ** 20);
    }    

    function checkLastCalc() private {
        if(block.timestamp - lastCalc > calcPeriod){ 
            if(pool[lastCalcIndex].sumParity ==0){
                pool[lastCalcIndex+1].sumDeposit += pool[lastCalcIndex].sumDeposit;
                pool[lastCalcIndex].sumDeposit=0;
            } else {
                canWithdraw = true;
            }
            
            lastCalcIndex++;
            lastCalc = block.timestamp;
        }
    }

    function CalcParity(address user) internal{
        uint24 currentUserParity = 0;
        uint32 userId = uids[user];
        bool isNew = pool[lastCalcIndex].userParity[user] == 0;
        uint16 pd = Levels[Nodes[userId].ln].perDay;

        if(Nodes[userId].LCap >= Nodes[userId].RCap ){
            if(Nodes[userId].RCap + pool[lastCalcIndex].userParity[user] > pd){
                currentUserParity = pd - pool[lastCalcIndex].userParity[user];
                if(currentUserParity > 0){
                    pool[lastCalcIndex].userParity[user] = pd;
                }
                if(Nodes[userId].ln < 4){
                    Nodes[userId].needLevelUp = true;
                }
            } else {
                pool[lastCalcIndex].userParity[user] += Nodes[userId].RCap;
                currentUserParity = Nodes[userId].RCap;
            }

            Nodes[userId].LCap = Nodes[userId].LCap - Nodes[userId].RCap; 
            Nodes[userId].RCap = 0;
        } else{
            if(Nodes[userId].LCap + pool[lastCalcIndex].userParity[user] > pd){
                currentUserParity = pd - pool[lastCalcIndex].userParity[user];
                if(currentUserParity > 0){
                    pool[lastCalcIndex].userParity[user] = pd;
                }

                if(Nodes[userId].ln < 4){
                    Nodes[userId].needLevelUp = true;
                }
            } else {
                pool[lastCalcIndex].userParity[user] += Nodes[userId].LCap;
                currentUserParity = Nodes[userId].LCap;
            }
            Nodes[userId].RCap = Nodes[userId].RCap - Nodes[userId].LCap; 
            Nodes[userId].LCap = 0;
        }

        if(currentUserParity > 0){
            Nodes[userId].allTimeParity += currentUserParity;
            pool[lastCalcIndex].sumParity += currentUserParity;

            if(isNew){
                pool[lastCalcIndex].users[pool[lastCalcIndex].countUserParity++] = userId;
            }
        }
    }

    function setRefferalsSalesCap(address currentUser , uint8 levelId) internal{
        pool[lastCalcIndex].sumDeposit += Levels[levelId].price * 9 / 10;      // 90% for public pool
        uint256 remain = Levels[levelId].price / 10;
        withdrawPool += 10 ** 18; // $1 for withdraw pool
        lotteryPool  += remain - (10 ** 18);   
        
        address child = currentUser;
        address userParent = parent[child];
        uint32 userId = uids[userParent];
   
        do{
            if(children[userParent][0] == child){
                Nodes[userId].LCap += Levels[levelId].parityAmount;
            } else {
                Nodes[userId].RCap += Levels[levelId].parityAmount ;
            }
            
            if(Nodes[userId].LCap > 0 && Nodes[userId].RCap > 0){
                CalcParity(userParent);    
            } 

            child = userParent;
            userParent = parent[child];
            userId = uids[userParent];
   
        } while(userParent !=  address(0));
    }

    function getChildCount(address a) internal view returns (uint8){
        uint8 c = 0;
        if(children[a][0] != address(0))
            c++;
        
        if(children[a][1] != address(0))
            c++;

        return c;
    }
    

    function Register(address upline,uint8 levelId) external {
        bool v = levelId >= 1 && levelId <=4;
        require(v , "Wrong level Id");

        uint256 needAmount = Levels[levelId].price ;
        uint32 upId = uids[upline];

        require(PaymentToken.allowance(msg.sender , address(this)) >= needAmount , "Approve to transfer BUSD first.");
        require(upId > 0 , "Your selected upline is not exists.");
        require(parent[msg.sender]  == address(0) , "You are already registered.");

        uint8 directCount = getChildCount(upline);
        require(directCount < 2 , "Upline already has 2 directs.");             
        require(PaymentToken.transferFrom(msg.sender , address(this) , needAmount),"Token transfer failure.");

        checkLastCalc();
        _register(upline , msg.sender , levelId);
        setRefferalsSalesCap(msg.sender, levelId);
    }

    function _register(address upline , address user , uint8 levelId) internal{
        totalUsers++;
        parent[user] = upline; 
        Nodes[totalUsers].registerTime = block.timestamp;
        Nodes[totalUsers].ln = levelId;
        Nodes[totalUsers].ad = user;
        Nodes[totalUsers].rwi = lastCalcIndex;
        uids[user] = totalUsers;

        if(children[upline][0] == address(0)) {
            children[upline][0] = user;
        } else {
            children[upline][1] = user;
        }

        emit NodeRegister(user, upline, levelId);
    }

    function getUserId() external view returns(uint32){
        return uids[msg.sender];
    }

    function getUserRegisterDate(address user) external view returns(uint256){
        return Nodes[uids[user]].registerTime;
    }

    function getUserLevel(address user) external view returns(uint8){
        return Nodes[uids[user]].ln;
    }

    function getNodesHasBalanceToday() external view returns(address[] memory){
        address [] memory users = new address[](pool[lastCalcIndex].countUserParity);
        for(uint16 i =0 ; i< pool[lastCalcIndex].countUserParity ; i++){
            users[i] = Nodes[pool[lastCalcIndex].users[i]].ad;
        }
        return users;
    }

    function canTopUpTo5() external view returns(bool){
        return _canTopUpTo5(msg.sender);
    }

    function _canTopUpTo5(address sender) internal view returns(bool){
         uint32 userId = uids[sender];
         
         if(userId == 0){
            return false;
        }

        bool canTopUp = Nodes[userId].ln == 4;
        
        if(canTopUp){ 
            uint8 count = 0;
            for(uint16 i = Nodes[userId].rwi; i < lastCalcIndex; i++){
                if(pool[i].userParity[sender] == Levels[4].perDay){
                    if(++count == 2){
                        break;
                    }
                } else {
                    count=0;
                }
            }
            if(count < 2){
                canTopUp = false;
            }
        }

        return canTopUp;
    }

    function LevelUp(uint8 levelId) external {
        bool v = levelId >= 2 && levelId <=5; 
        require(v , "Wrong level Id");
        uint32 userId = uids[msg.sender];
        require(levelId > Nodes[userId].ln , "Level Id should be greater than the current.");

        if(levelId == 5){           
            require(_canTopUpTo5(msg.sender) , "Based on your account status, top up to level 5 is currently unavailbe for you.");
        }


        uint256 needPrice = Levels[levelId].price;
        require(PaymentToken.allowance(msg.sender , address(this)) == needPrice , "Payment token allowance error");

        checkLastCalc();
        require(PaymentToken.transferFrom(msg.sender , address(this) , needPrice) , "Token transfer failure.");
      
        emit NodeLevelUp(msg.sender , Nodes[userId].ln, levelId);
    
        Nodes[userId].ln = levelId;         
        Nodes[userId].needLevelUp = false;
        setRefferalsSalesCap(msg.sender, levelId);
    } 

    function SmartLottery() external returns(bool){
        uint32 userId = uids[msg.sender];
        require(userId > 0 , "You are not Registered.");
        uint8 levelId  = Nodes[userId].ln;
        uint256 am = Levels[levelId].price / 10;

        require(lotteryPool >= am, "Lottery pool is empty. wait for next cycle.");
        require(lotteryPerUser[msg.sender] < Levels[levelId].price , "You can't participate in the lottery anymore");
        require(Nodes[userId].allTimeParity <= 1 , "you have already more than 1 parity points.");
        require(block.timestamp -  Nodes[userId].registerTime > 2678400 ,
         "Only users who have been registered for at least one month can participate in the lottery");
        require(lotteryPerUserTime[msg.sender] < block.timestamp , "You already participated in lottey in this cycle.");
        bool win = false;
        uint8 randomNumber = uint8(uint256(keccak256(abi.encodePacked(block.timestamp ,block.number, msg.sender))) % 6);
        uint256 tm = block.timestamp + 86400;
        randomNumber++;
        if(randomNumber == 6){
            lotteryPool -= am;
            lotteryPerUser[msg.sender] += am;
            tm = block.timestamp + 172800;
            require(PaymentToken.transfer(msg.sender, am), "Token transfer failure.");
            win=true;
        }  
        lotteryPerUserTime[msg.sender] = tm;
        return win;
    }

    function WithdrawForAll() external {
        checkLastCalc();
        require(uids[msg.sender] > 0 , "Permission Denied!");
        require(canWithdraw , "It has not been 24 hours past yet.");  
        bool hasBonus = false;
        
        for(uint16 i = lastWithdrawIndex ; i < lastCalcIndex ; i++){
            uint24 poolSumParity = pool[i].sumParity;
            if(poolSumParity == 0){
                continue;
            }

            uint256 poolAmount = pool[i].sumDeposit;
            for(uint16 j = 0; j < pool[i].countUserParity; j++){
                uint32 theUser = pool[i].users[j]; 
                if(pool[i].selfWithdrawalUsers[theUser]){
                    continue;
                }

                address ad = Nodes[theUser].ad;
                uint256 maxPD = Levels[Nodes[theUser].ln].perDayUSDT;
                uint256 profit =(poolAmount * pool[i].userParity[ad]) / poolSumParity;
                
                if(profit > maxPD){
                    pool[i+1].sumDeposit += profit - maxPD;
                    profit = maxPD;
                    emit UserFlashedOut(ad, Nodes[theUser].ln , profit);
                }
                pool[i].userProfit[theUser] = profit;
                require(PaymentToken.transfer(ad, profit), "Token transfer failure.");
            }
            hasBonus = true;
        }

        require(hasBonus , "Total users' balances is currently zero.");
        
        canWithdraw = false; 
        uint256 bonus = withdrawPool; 
        withdrawPool = 0;
        lastWithdrawIndex = lastCalcIndex;
        require(PaymentToken.transfer(msg.sender, bonus), "Bonus transfer failure.");
    }
 
    function Withdraw() external {
        checkLastCalc();
        uint32 userId = uids[msg.sender];
        require(userId > 0 , "Permission Denied!");

        address ad = Nodes[userId].ad;
        uint256 cup = 0;
        uint256 maxPD = Levels[Nodes[userId].ln].perDayUSDT;

        for(uint16 i = lastWithdrawIndex ; i < lastCalcIndex; i++){
            if(pool[i].userParity[ad] > 0 && !pool[i].selfWithdrawalUsers[userId]){ 
                uint256 profit =(pool[i].sumDeposit * pool[i].userParity[ad]) / pool[i].sumParity ;
                if(profit > maxPD){
                    pool[i+1].sumDeposit += profit - maxPD;
                    profit = maxPD;
                    emit UserFlashedOut(ad, Nodes[userId].ln , profit);
                }
                cup +=profit;
                pool[i].selfWithdrawalUsers[userId] = true;
                pool[i].userProfit[userId] = profit;
            }
        }

        require(cup > 0 , "User has no balance yet.");
        require(PaymentToken.transfer(ad, cup) , "Token transfer failure.");  
    }

    function addPreviousNodes(address[] memory nAddresses , address[] memory nUplines , uint8[] memory nLevels , uint24[] memory nSaveLeft , uint24[] memory nSaveRight , uint8 count) external {
        require(totalUsers < 77 , "Users are already added.");
        for( uint8 i = 0 ; i < count ; i++){
            if(uids[nAddresses[i]] == 0 ){
                _register(nUplines[i] , nAddresses[i] , nLevels[i]);
            }
            Nodes[uids[nAddresses[i]]].LCap = nSaveLeft[i];
            Nodes[uids[nAddresses[i]]].RCap = nSaveRight[i];
        }
    }
 
    function getDynamicAtLow(address starter) external view returns(address){
        address current = starter;
        while(getChildCount(current) == 2){
            uint32 currentId = uids[current];
            current = children[current][Nodes[currentId].LCap < Nodes[currentId].RCap ? 0 : 1];
        }

        return current;
    }
    
    function getDynamicAtHigh(address starter) external view returns(address){
        address current = starter;
        while(getChildCount(current) > 0){
            uint32 currentId = uids[current];
            if(getChildCount(current) == 1){
                current = children[current][0];
                continue;
            }
            current = children[current][Nodes[currentId].LCap < Nodes[currentId].RCap ? 1 : 0];
        }
        return current;
    }
    
    function MyWithdrawableProfit() external view returns (uint256){
        return _myWithdrawableProfit(msg.sender);
    }
    
    function _myWithdrawableProfit(address ad) internal view returns (uint256){
        uint32 userId = uids[ad];
        require(userId > 0 , "Permission Denied!");
        uint256 maxPD = Levels[Nodes[userId].ln].perDayUSDT;

        uint256 cup = 0;
        for(uint16 i = lastWithdrawIndex ; i< lastCalcIndex; i++){
            if(pool[i].sumParity > 0){ 
                if(pool[i].selfWithdrawalUsers[userId]){
                    continue;
                }
                uint256 profit =(pool[i].sumDeposit * pool[i].userParity[ad]) / pool[i].sumParity ;
                if(profit > maxPD){
                    profit = maxPD;
                }
                cup +=profit;

            }
        } 
        return cup;
    }
      
    function MyParityCountToday() external view returns(uint24){
        uint32 userId = uids[msg.sender];
        require(userId > 0 , "You are not registered."); 
        return pool[lastCalcIndex].userParity[msg.sender];
    }
    
    function MyProfitToday() external view returns(uint256){
        return userProfitToday(msg.sender);
    }

    function userProfitToday(address ad) internal view returns(uint256){
        require(uids[ad] > 0 , "You are not registered."); 
        uint32 userId = uids[ad];
        uint256 maxPD = Levels[Nodes[userId].ln].perDayUSDT;

        if(pool[lastCalcIndex].sumParity == 0){
            return 0;
        }

        uint256 profit =  (pool[lastCalcIndex].sumDeposit * pool[lastCalcIndex].userParity[ad]) / pool[lastCalcIndex].sumParity;
        if(profit > maxPD){
            profit = maxPD;
        }
        return profit;
    } 

    function TodayPoolAmount() external view returns(uint256){
        return pool[lastCalcIndex].sumDeposit;
    }

    function TodayTotalParity() external view returns(uint24){
        return pool[lastCalcIndex].sumParity;
    }
      
    function LotteryPoolAmount() external view returns(uint256){
        return lotteryPool;
    }
    
    function MyDirects() external view returns(address , address){
        return (
            children[msg.sender][0],
            children[msg.sender][1]
        );
    }

    function getSystemData() external view returns(uint256,uint24,uint256,uint256,uint32,bool,uint256){
        bool withdrawable = canWithdraw;
        if(pool[lastCalcIndex].sumParity > 0 && block.timestamp - lastCalc > calcPeriod){ 
            withdrawable = true;
        } 
        return (                                    
            lotteryPool,
            pool[lastCalcIndex].sumParity,
            pool[lastCalcIndex].sumDeposit,
            withdrawPool,
            totalUsers,
            withdrawable,
            pool[lastCalcIndex+1].sumDeposit
       );
    }

    function getUserProfitByPoolId(uint32 userId , uint16 poolId) internal view returns(uint256){
        return pool[poolId].userProfit[userId];
    }

    function getUserAllTimeProfit(uint32 userId) internal view returns(uint256){
        uint256 sumProfit = 0;
        for(uint16 i = Nodes[userId].rwi ; i< lastWithdrawIndex ; i++){
            sumProfit += getUserProfitByPoolId(userId , i);
        }
        return sumProfit;
    }

    function getLastWeekUserProfit() external view returns(uint256,uint256,uint256,uint256,uint256,uint256,uint256){
        uint32 userId = uids[msg.sender];
        require(userId > 0, "Access Denied.");

        uint16 index = lastWithdrawIndex;

        return(
            getUserProfitByPoolId(userId , index  ),
            getUserProfitByPoolId(userId , index-1),
            getUserProfitByPoolId(userId , index-2),
            getUserProfitByPoolId(userId , index-3),
            getUserProfitByPoolId(userId , index-4),
            getUserProfitByPoolId(userId , index-5),
            getUserProfitByPoolId(userId , index-6)
        );
    }

    function _getUserBalanceByPoolId(address userAddress , uint16 poolId) internal view returns(uint24){
        return pool[poolId].userParity[userAddress];
    }

    function getUserBalanceByPoolId(uint16 poolId) external view returns(uint24){
        uint32 userId = uids[msg.sender];
        require(userId > 0, "Access Denied.");

        return _getUserBalanceByPoolId(msg.sender , poolId);
    }

    function getLastWeekUserBalance() external view returns(uint24,uint24,uint24,uint24,uint24,uint24,uint24){
        uint32 userId = uids[msg.sender];
        require(userId > 0, "Access Denied.");
        address s = msg.sender;
        uint16 index = lastWithdrawIndex;

        return(
            _getUserBalanceByPoolId(s , index  ),
            _getUserBalanceByPoolId(s , index-1),
            _getUserBalanceByPoolId(s , index-2),
            _getUserBalanceByPoolId(s , index-3),
            _getUserBalanceByPoolId(s , index-4),
            _getUserBalanceByPoolId(s , index-5),
            _getUserBalanceByPoolId(s , index-6)
        );
    }

    function getUserLotteryData() external view returns(bool, bool, uint256,uint256, uint256){
        uint32 userId = uids[msg.sender];
        bool canJoinNow = true;
        bool canJoinEver = true;

        if(Nodes[userId].allTimeParity > 1){
            canJoinNow = false;
            canJoinEver = false;
        }
        
        uint256 elapsed = block.timestamp - Nodes[userId].registerTime;
        if(elapsed < 30 * 86400){
            canJoinNow = false;
        }
        if(lotteryPerUser[msg.sender] >= Levels[Nodes[userId].ln].price){
            canJoinNow = false;
            canJoinEver = false;
        }
        uint256 wait = 0;
        if(canJoinEver){
            if(block.timestamp < lotteryPerUserTime[msg.sender]){
                wait = lotteryPerUserTime[msg.sender] - block.timestamp;
                canJoinNow = false;
            }
        }

        return (
            canJoinEver,
            canJoinNow,
            elapsed,
            wait,
            lotteryPerUser[msg.sender]
        );
    }
    
    function getUserData() external view returns(uint256,uint256,uint256,address,address,address,uint8,uint32,uint24,uint256,bool,uint24,uint24){
        uint32 userId = uids[msg.sender];
        return (                                    
            userProfitToday(msg.sender),
            _myWithdrawableProfit(msg.sender),
            getUserAllTimeProfit(userId),
            parent[msg.sender],
            children[msg.sender][0],
            children[msg.sender][1],
            Nodes[userId].ln,
            Nodes[userId].allTimeParity,
            pool[lastCalcIndex].userParity[msg.sender],
            Nodes[userId].registerTime,
            Nodes[userId].needLevelUp,
            Nodes[userId].LCap,
            Nodes[userId].RCap
       );
    }

    function getUserPublicData(address user) external view returns(uint256,uint8,uint24,uint256){
        uint32 userId = uids[user];
        return (                                    
            userProfitToday(user),
            Nodes[userId].ln,
            pool[lastCalcIndex].userParity[user],
            Nodes[userId].registerTime
       );
    }
}