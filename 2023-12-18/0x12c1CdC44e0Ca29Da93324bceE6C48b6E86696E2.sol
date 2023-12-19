pragma solidity 0.6.0; 

//*******************************************************************************//
//------------------ Contract to 100% secure p2p decentrlised mini blast25 -------------------//
//*******************************************************************************//
contract owned
{
    address internal owner;
    address internal newOwner;
    address public signer;

    event OwnershipTransferred(address indexed _from, address indexed _to);

    constructor() public {
        owner = msg.sender;
        signer = msg.sender;
    }

    modifier onlyOwner {
        require(msg.sender == owner);
        _;
    }


    modifier onlySigner {
        require(msg.sender == signer, 'caller must be signer');
        _;
    }


    function changeSigner(address _signer) public onlyOwner {
        signer = _signer;
    }

    function transferOwnership(address _newOwner) public onlyOwner {
        newOwner = _newOwner;
    }

    //the reason for this flow is to protect owners from sending ownership to unintended address due to human error
    function acceptOwnership() public {
        require(msg.sender == newOwner);
        emit OwnershipTransferred(owner, newOwner);
        owner = newOwner;
        newOwner = address(0);
    }
}



//*******************************************************************//
//------------------         token interface        -------------------//
//*******************************************************************//

 interface tokenInterface
 {
    function transfer(address _to, uint256 _amount) external returns (bool);
    function transferFrom(address _from, address _to, uint256 _amount) external returns (bool);
    function isUserExists(address userAddress) external returns (bool);
 }



//*******************************************************************//
//------------------        MAIN contract         -------------------//
//*******************************************************************//

contract MiniBlast25 is owned {

    // Replace below address with main token token
    address public tokenAddress;
    address public blastAddress;
    address public rewadaddress;

    uint public maxDownLimit = 2;
    uint[4] public lastIDCount;
    uint public joiningFee = 5 * (10 ** 18);    
    uint public reJoinFee = 5 * (10 ** 18);
    
  
    uint nextJoinWait = 1 days;
    uint nextReJoinWait = 2 hours;
    //uint nextJoinWait = 3 hours;
    //uint nextReJoinWait = 1 hours;
    

    uint public royaltee;

    mapping(address => uint) public ActiveDirect;
    mapping(address => uint) public ActiveUnit;    
    mapping(address => uint) public nextJoinPending;
    mapping(address => uint) public lastJoinTime;
    mapping(address => uint) public lastReJoinTime;
    mapping(address => uint) public boostPending;
    mapping(address => uint) public boosedCounter;
   

    uint[4] public nextMemberFillIndex;  
    uint[4] public nextMemberFillBox;   


    struct userInfo {
        bool joined;
        uint id;
        uint parent;
        uint referrerID;
        uint directCount;
    }

    mapping(address => address[]) public directAddress;

    

    struct TotalInfo {
        uint32 user;        
        uint32 activeUnits;
        uint32 pendingUnits;        
        uint32 boostUnits;       
    }

    struct UserIncomeInfo {         
        uint32 UnitIncome;
        uint32 DirectIncome;
        uint32 LevelIncome;
    }

    mapping(address => UserIncomeInfo) public UserIncomeInfos;
    bool public doUS; // enable or disable update stat

    TotalInfo public total;

    mapping(address => userInfo[6]) public userInfos;
    mapping(uint => address) public refAddressbyUID;
    mapping(address=> uint) public uidByRefAddress;


    //userID => _level => address
    mapping(uint => mapping(uint => address)) public userAddressByID;
  
    function init() public onlyOwner returns(bool){
        require(lastIDCount[0]==0, "can be called only once");
        userInfo memory temp;
        lastIDCount[0]++;

        temp.joined = true;
        temp.id = 1;
        temp.parent = 1;
        temp.referrerID = 1;
        //temp.directCount = 2 ** 100;
        temp.directCount = 100;


        userInfos[owner][0] = temp;
        userAddressByID[1][0] = owner;

        tokenInterface(tokenAddress).transferFrom(msg.sender, address(this), 173 * (10 ** 18));

        for(uint i=1;i<4;i++)
        {
            lastIDCount[i]++;
            userInfos[owner][i] = temp;
            userAddressByID[1][i] = owner;
        }

    }

    function setTokenNTigerAddress(address _tokenAddress, address _rewadaddress) public onlyOwner returns(bool)
    {
        tokenAddress = _tokenAddress;        
        rewadaddress = _rewadaddress;
        return true;
    }


    function toggleDoUS() public onlyOwner returns(bool)
    {
        doUS = !doUS;
        return true;
    }

    event regUserEv(address _user,uint userid, address _referrer, uint refID,address parent, uint parentid,  uint timeNow, uint uid);
    function regUser() public returns(bool) 
    {
        address _ref = refAddressbyUID[1];

        uint _referrerID = userInfos[_ref][0].id;
        if(_referrerID == 0) _referrerID =1;
        //require(tokenInterface(blastAddress).isUserExists(msg.sender), "user not exists");
        require(msg.sender == tx.origin, "contract can't call");
        require(!userInfos[msg.sender][0].joined, "already joined");
        require(_referrerID <= lastIDCount[0], "Invalid ref id");
        tokenInterface(tokenAddress).transferFrom(msg.sender, address(this), joiningFee);
        userInfo memory temp;
        lastIDCount[0]++;
        temp.joined = true;
        temp.id = lastIDCount[0];
        bool pay;
        (temp.parent,pay) = findFreeReferrer(0);
        temp.referrerID = _referrerID;

        userInfos[msg.sender][0] = temp;
        userAddressByID[temp.id][0] = msg.sender;


        userInfos[_ref][0].directCount = userInfos[_ref][0].directCount + 1;

        lastJoinTime[msg.sender] = now;
        //nextJoinPending[msg.sender] = 2;
        ActiveUnit[msg.sender]++;
        ActiveDirect[_ref]++;
        
        directAddress[_ref].push(msg.sender);

        uint uid = uint(now) % 10000000;

        uidByRefAddress[msg.sender] = uid;
        refAddressbyUID[uid] = msg.sender;

        total.user++;        
        total.activeUnits++;
       // total.pendingUnits=total.pendingUnits+2;        
        
        if(pay) 
        {
            payForLevel(temp.parent, 0);
            buyLevel(userAddressByID[temp.parent][0], 1);
        }

        //Direct+Level -- registration
        payForLevel(_referrerID, 7);
        
        emit regUserEv(msg.sender,temp.id, _ref, _referrerID,userAddressByID[temp.parent][0], temp.parent, now, uid);
        return true;
    }

    function regUser_top_byother( address _useraddress) public returns(bool) 
    {
        address _ref = refAddressbyUID[1];

        uint _referrerID = userInfos[_ref][0].id;
        if(_referrerID == 0) _referrerID = 1;
        //require(tokenInterface(tigerAddress).isUserExists(msg.sender), "user not exists");
        require(msg.sender == tx.origin, "contract can't call");
        //require(_useraddress == tx.origin, "contract can't call");
        require(!userInfos[_useraddress][0].joined, "already joined");
        require(_referrerID <= lastIDCount[0], "Invalid ref id");
        tokenInterface(tokenAddress).transferFrom(msg.sender, address(this), joiningFee);
        userInfo memory temp;
        lastIDCount[0]++;
        temp.joined = true;
        temp.id = lastIDCount[0];
        bool pay;
        (temp.parent,pay) = findFreeReferrer(0);
        temp.referrerID = _referrerID;

        userInfos[_useraddress][0] = temp;
        userAddressByID[temp.id][0] = _useraddress;


        userInfos[_ref][0].directCount = userInfos[_ref][0].directCount + 1;

        lastJoinTime[_useraddress] = now;
        //nextJoinPending[msg.sender] = 2;
        ActiveUnit[_useraddress]++;
        ActiveDirect[_ref]++;
        
        directAddress[_ref].push(_useraddress);

       uint uid = uint(now) % 10000000;

        uidByRefAddress[_useraddress] = uid;
        refAddressbyUID[uid] = _useraddress;

        total.user++;        
        total.activeUnits++;
       // total.pendingUnits=total.pendingUnits+2;        
        
        if(pay) 
        {
            payForLevel(temp.parent, 0);
            buyLevel(userAddressByID[temp.parent][0], 1);
        }

        //Direct+Level -- registration
       // payForLevel(_referrerID, 7);
        
        emit regUserEv(_useraddress,temp.id, _ref, _referrerID,userAddressByID[temp.parent][0], temp.parent, now, uid);
        return true;
    }

    event enterMoreEv(address _user,uint userid, address parent, uint parentid,  uint timeNow);
    function BuyULP() public returns(bool){
        require(lastReJoinTime[msg.sender] + nextReJoinWait <= now, "please wait time little more");
        require(userInfos[msg.sender][0].joined, "register first");
        tokenInterface(tokenAddress).transferFrom(msg.sender, address(this), reJoinFee);

       // require(userInfos[msg.sender][0].joined, "Not Registration");

       // nextJoinPending[msg.sender]++;
        ActiveUnit[msg.sender]++;
        userInfo memory temp;
        lastIDCount[0]++;
        temp.joined = true;
        temp.id = lastIDCount[0];
        temp.directCount = userInfos[msg.sender][0].directCount;
        uint _referrerID = userInfos[msg.sender][0].referrerID;
        bool pay;

        (temp.parent,pay) = findFreeReferrer(0);
        temp.referrerID = _referrerID;

        userInfos[msg.sender][0] = temp;
        userAddressByID[temp.id][0] = msg.sender;

       // userInfos[userAddressByID[_referrerID][0]][0].directCount = userInfos[userAddressByID[_referrerID][0]][0].directCount + 1;

        lastReJoinTime[msg.sender] = now;

       
        total.activeUnits++;
        //total.pendingUnits=total.pendingUnits+1;
            

        if(pay) 
        {
            payForLevel(temp.parent, 0);
            buyLevel(userAddressByID[temp.parent][0], 1);
        }
        emit enterMoreEv(msg.sender,temp.id, userAddressByID[temp.parent][0],temp.parent,now);
        return true;
    }

    

    event joinNextEv(address _user,uint userid, address parent, uint parentid,  uint timeNow);    
    function joinNext() public returns(bool){
        require(userInfos[msg.sender][0].joined, "register first");
       // require(userInfos[msg.sender][0].joined, "address used already");
        require(nextJoinPending[msg.sender] > 0, "no pending next join");
        require(lastJoinTime[msg.sender] + nextJoinWait <= now, "please wait time little more");
        nextJoinPending[msg.sender]--;
        ActiveUnit[msg.sender]++;
        userInfo memory temp;
        lastIDCount[0]++;
        temp.joined = true;
        temp.id = lastIDCount[0];
        temp.directCount = userInfos[msg.sender][0].directCount;
        uint _referrerID = userInfos[msg.sender][0].referrerID;
        bool pay;
        (temp.parent,pay) = findFreeReferrer(0);
        temp.referrerID = _referrerID;

        userInfos[msg.sender][0] = temp;
        userAddressByID[temp.id][0] = msg.sender;


        lastJoinTime[msg.sender] = now;
        
         
        total.activeUnits++;
        total.pendingUnits=total.pendingUnits-1;       
                
        
        if(pay) 
        {
            payForLevel(temp.parent, 0);
            buyLevel(userAddressByID[temp.parent][0], 1);
        }
        emit enterMoreEv(msg.sender,temp.id, userAddressByID[temp.parent][0],temp.parent,now);
        return true;
    }
   
    event buyLevelEv(uint level, address _user,uint userid, address parent, uint parentid,  uint timeNow);
    function buyLevel(address _user, uint _level) internal returns(bool)
    {
        userInfo memory temp = userInfos[_user][0];

        lastIDCount[_level]++;
        temp.id = lastIDCount[_level];
        if(_level == 0) temp.directCount = userInfos[_user][0].directCount;

        bool pay;
        (temp.parent,pay) = findFreeReferrer(_level);
 

        userInfos[_user][_level] = temp;
        userAddressByID[temp.id][_level] = _user;

        address parentAddress = userAddressByID[temp.parent][_level];


        if(pay)
        {
            if(_level < 3 ) payForLevel(temp.parent, _level); // for 0,1, only
            if(_level < 3 ) buyLevel(parentAddress, _level + 1); //upgrade for 0,1, only
            if(_level == 2 ) 
            {
                nextJoinPending[msg.sender] = (nextJoinPending[msg.sender]+2);
                total.pendingUnits = (total.pendingUnits+2);
               
            }           
            if(_level == 3 ) 
            {
                boostPending[parentAddress]++;
               // nextJoinPending[parentAddress] = (nextJoinPending[parentAddress]+2);
            }

        }
        emit buyLevelEv(_level, msg.sender, temp.id, userAddressByID[temp.parent][0], temp.parent, now);
        return true;
    }

    event boostEv(address user, uint boostCount, uint remainingBoost, uint timeNow);
    function boost() public returns(bool)
    {
        require(boostPending[msg.sender] > 0 , "not eligible" );
        boosedCounter[msg.sender]++;
        payForLevel(userInfos[msg.sender][2].id, 3);
       // buyLevel(msg.sender, 0); // 1 id in level 1st level
       // buyLevel(msg.sender, 2); // 1 id in level 3rd level
        //nextJoinPending[msg.sender]++; // 1 id after 48 hr in 1st level 
        nextJoinPending[msg.sender] = (nextJoinPending[msg.sender]+3);
        
        //ActiveUnit[msg.sender]++;
        boostPending[msg.sender]--;

        
        //total.activeUnits++;       
        total.boostUnits++;
        total.pendingUnits = (total.pendingUnits+3);
        emit boostEv(msg.sender,boosedCounter[msg.sender],boostPending[msg.sender] , now);       
        return true;
    }
 

    event payForLevelEv(uint level, uint parentID,address paidTo, uint amount, bool direct, uint timeNow);

    function payForLevel(uint _pID, uint _level) internal returns (bool){
        address _user = userAddressByID[_pID][_level];
        if(_level == 0) 
        {
            // tokenInterface(tokenAddress).transfer(_user,2 * (10 ** 18));
            // US(_user, 0, 2);
            // emit payForLevelEv(_level,_pID,_user, 2 * (10 ** 18), false, now);

            // _user = userAddressByID[userInfos[_user][0].referrerID][0];
            // tokenInterface(tokenAddress).transfer(_user,1 * (10 ** 18));
            // US(_user, 1, 1);
            // emit payForLevelEv(_level,_pID,_user, 1 * (10 ** 18), true, now);

            // _user = userAddressByID[userInfos[_user][0].referrerID][0];
            // tokenInterface(tokenAddress).transfer(_user,1 * (10 ** 18));
            // US(_user, 2, 1);
            // emit payForLevelEv(_level,_pID,_user, 1 * (10 ** 18), true, now);

            // royaltee += 1 * (10 ** 18) ;
        }
        else if(_level == 1)
        {
            tokenInterface(tokenAddress).transfer(_user, 2 * (10 ** 18));
            US(_user, 0, 2);
            emit payForLevelEv(_level,_pID,_user, 2 * (10 ** 18), false, now);

           tokenInterface(tokenAddress).transfer(rewadaddress,1 * (10 ** 18));

           
        }
        else if(_level == 2)
        {
            tokenInterface(tokenAddress).transfer(_user, 3 * (10 ** 18));
            US(_user, 0, 3);
            emit payForLevelEv(_level,_pID,_user, 3 * (10 ** 18), false, now);

             tokenInterface(tokenAddress).transfer(rewadaddress,1 * (10 ** 18));
        }
        else if(_level == 3)
        {
            tokenInterface(tokenAddress).transfer(_user, 25 * (10 ** 18));
            US(_user, 0, 25);
            emit payForLevelEv(_level,_pID,_user, 25 * (10 ** 18), false, now);

           tokenInterface(tokenAddress).transfer(rewadaddress,2 * (10 ** 18));
                
        }  
                
        return true;

    }

    function US(address _user,uint8 _type, uint32 _amount) internal 
    {
        if (doUS)
        {
            if(_type == 0 ) UserIncomeInfos[_user].UnitIncome = UserIncomeInfos[_user].UnitIncome + _amount ;
            else if (_type == 1 ) UserIncomeInfos[_user].DirectIncome =  UserIncomeInfos[_user].DirectIncome + _amount;
            else if (_type == 2 ) UserIncomeInfos[_user].LevelIncome =  UserIncomeInfos[_user].LevelIncome + _amount;
        }
    }

  

    //function findFreeReferrer(uint _level) internal returns(uint,bool) {
    function findFreeReferrer(uint _level) public returns(uint,bool) {

        bool pay;

        uint currentID = nextMemberFillIndex[_level];

        if(nextMemberFillBox[_level] == 0)
        {
            nextMemberFillBox[_level] = 1;
        }   
        else
        {
            nextMemberFillIndex[_level]++;
            nextMemberFillBox[_level] = 0;
            pay = true;
        }
        return (currentID+1,pay);
    }

    
   
    //a = join, b = ulp join
    function timeRemains(address _user) public view returns(uint, uint)
    {
        uint a; // UNIT TIME
        uint b; // ULP TIME
        
        if( nextJoinPending[_user] == 0 || lastJoinTime[_user] + nextJoinWait < now) 
        {
            a = 0;
        }
        else
        {
            a = (lastJoinTime[_user] + nextJoinWait) - now;
        }
               
        if(lastReJoinTime[_user] + nextReJoinWait < now) 
        {
            b = 0;
        }
        else
        {
            b = (lastReJoinTime[_user] + nextReJoinWait) - now ;
        }

         
        return (a,b);
    }

}