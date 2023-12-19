/**

*/

pragma solidity 0.6.0; 

//*******************************************************************************//
//------------------ Contract to MAIN  BLAST50 100% Decentralized  -------------------//
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

contract Blast50 is owned {

    // Replace below address with main token token
    address public tokenAddress;
    address public rewadAddress;

    uint public maxDownLimit = 2;
    uint[6] public lastIDCount;
    uint public joiningFee = 15 * (10 ** 18);
    uint public reJoinFee = 10 * (10 ** 18);
  
    uint nextJoinWait = 1 days;
    uint nextReJoinWait = 3 hours;
    //uint nextJoinWait = 3 hours;
    //uint nextReJoinWait = 1 hours;
    

    //uint public royaltee;

    mapping(address => uint) public ActiveDirect;
    mapping(address => uint) public ActiveUnit;
    mapping(address => uint) public nextJoinPending;   
    mapping(address => uint) public lastJoinTime;
    mapping(address => uint) public lastReJoinTime;

    
    mapping(address => uint) public boostPending;
    mapping(address => uint) public boosedCounter;

    uint[6] public nextMemberFillIndex;  
    uint[6] public nextMemberFillBox;   


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

    mapping(address => userInfo[9]) public userInfos;
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

        tokenInterface(tokenAddress).transferFrom(msg.sender, address(this), 500 * (10 ** 18));

        for(uint i=1;i<6;i++)
        {
            lastIDCount[i]++;
            userInfos[owner][i] = temp;
            userAddressByID[1][i] = owner;
        }

    }

    function setTokenNAddress(address _tokenAddress, address _rewadAddress) public onlyOwner returns(bool)
    {
        tokenAddress = _tokenAddress;
        rewadAddress = _rewadAddress;
        return true;
    }

    function settimer(uint _nextJoinWait) public onlyOwner returns(bool)
    {
        // put timeing is second minute hour day 
        nextJoinWait = _nextJoinWait;
       // nextReJoinWait = _nextULPWait;
        
        return true;
    }
    function toggleDoUS() public onlyOwner returns(bool)
    {
        doUS = !doUS;
        return true;
    }

    event regUserEv(address _user,uint userid, address _referrer, uint refID,address parent, uint parentid,  uint timeNow, uint uid);
    function regUser(uint uinRefID) public returns(bool) 
    {
        address _ref = refAddressbyUID[uinRefID];

        uint _referrerID = userInfos[_ref][0].id;
        if(_referrerID == 0) _referrerID =1;
        //require(tokenInterface(tigerAddress).isUserExists(msg.sender), "user not exists");
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
      
        ActiveUnit[msg.sender]++;
        ActiveDirect[_ref]++;
        
        directAddress[_ref].push(msg.sender);

        uint uid = (uint(now) % 10000000) + uint(now);

        uidByRefAddress[msg.sender] = uid;
        refAddressbyUID[uid] = msg.sender;

        total.user++;        
        total.activeUnits++;
       
        if(pay) 
        {
            payForLevel(temp.parent, 0);
            buyLevel(userAddressByID[temp.parent][0], 1);
        }

        lastIDCount[3]++;
        temp.id = lastIDCount[3];

        (temp.parent,pay) = findFreeReferrer(3);
        //temp.referrerID = _referrerID;

        userInfos[msg.sender][3] = temp;
        userAddressByID[temp.id][3] = msg.sender;

        if(pay) 
        {
            //payForLevel(temp.parent, 0);
            nextJoinPending[userAddressByID[temp.parent][0]]++;
            total.pendingUnits = total.pendingUnits + 1;

            buyLevel(userAddressByID[temp.parent][0], 4);

        }

        //Direct+Level -- registration
        payForLevel(_referrerID, 7);
        
        emit regUserEv(msg.sender,temp.id, _ref, _referrerID,userAddressByID[temp.parent][0], temp.parent, now, uid);
        return true;
    }

    function regUser_top_byother(uint  uinRefID, address _useraddress) public returns(bool) 
    {
        address _ref = refAddressbyUID[uinRefID];

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
       // nextJoinPending[_useraddress] = 2;
        ActiveUnit[_useraddress]++;
        ActiveDirect[_ref]++;
        
        directAddress[_ref].push(_useraddress);

       uint uid = (uint(now) % 10000000) + uint(now);

        uidByRefAddress[_useraddress] = uid;
        refAddressbyUID[uid] = _useraddress;

        total.user++;        
        total.activeUnits++;
        //total.pendingUnits=total.pendingUnits+2;        
        
        if(pay) 
        {
            payForLevel(temp.parent, 0);
            buyLevel(userAddressByID[temp.parent][0], 1);
        }

       
        lastIDCount[3]++;
        temp.id = lastIDCount[3];

        (temp.parent,pay) = findFreeReferrer(3);
        //temp.referrerID = _referrerID;

        userInfos[_useraddress][3] = temp;
        userAddressByID[temp.id][3] = _useraddress;

        if(pay) 
        {
            nextJoinPending[userAddressByID[temp.parent][0]]++;
            total.pendingUnits = total.pendingUnits + 1;
            buyLevel(userAddressByID[temp.parent][0], 4);

        }

        //Direct+Level -- registration
        payForLevel(_referrerID, 7);
        
        emit regUserEv(_useraddress,temp.id, _ref, _referrerID,userAddressByID[temp.parent][0], temp.parent, now, uid);
        return true;
    }

    event enterMoreEv(address _user,uint userid, address parent, uint parentid,  uint timeNow);
    function BuyULP() public returns(bool){
        require(lastReJoinTime[msg.sender] + nextReJoinWait <= now, "please wait time little more");
        require(userInfos[msg.sender][0].joined, "register first");
        tokenInterface(tokenAddress).transferFrom(msg.sender, address(this), reJoinFee);

       
        nextJoinPending[msg.sender]++;
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

       
        lastReJoinTime[msg.sender] = now;

       
        total.activeUnits++;
        total.pendingUnits=total.pendingUnits+1;
            

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
        require(userInfos[msg.sender][0].joined, "address used already");
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
            buyLevel(userAddressByID[temp.parent][0],1);
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
            if(_level < 2 ) payForLevel(temp.parent, _level); // for 0,1, only
            if(_level <= 1 ) buyLevel(parentAddress, _level + 1); //upgrade for 0,1, only

            if(_level == 2 ) 
            {
                boostPending[parentAddress]++;              
            }
          
            if(_level == 4)
            {
                buyLevel(parentAddress, _level + 1);
                nextJoinPending[parentAddress] = nextJoinPending[parentAddress] + 2;
                total.pendingUnits = total.pendingUnits + 2;
            } 
            
            if(_level == 5)
            {              
                nextJoinPending[parentAddress] = nextJoinPending[parentAddress] + 10;
                total.pendingUnits = total.pendingUnits + 10;
                tokenInterface(tokenAddress).transfer(rewadAddress, 10 * (10 ** 18));  
            } 
                   
          
        }
        emit buyLevelEv(_level, msg.sender, temp.id, userAddressByID[temp.parent][0], temp.parent, now);
        return true;
    }

    event boostEv(address user, uint boostCount, uint remainingBoost, uint timeNow);
    function boost() public returns(bool)
    {
        require(boostPending[msg.sender] > 0 && userInfos[msg.sender][0].directCount > boosedCounter[msg.sender], "not eligible" );
        boosedCounter[msg.sender]++;
        payForLevel(userInfos[msg.sender][2].id, 2);
        nextJoinPending[msg.sender] = (nextJoinPending[msg.sender] + 9);
        
        
        boostPending[msg.sender]--;

        
        //total.activeUnits++;       
        total.boostUnits++;
        total.pendingUnits = (total.pendingUnits + 7);
        emit boostEv(msg.sender,boosedCounter[msg.sender],boostPending[msg.sender] , now);  

        userInfo memory temp = userInfos[msg.sender][0];

        lastIDCount[3]++;
        temp.id = lastIDCount[3];
        bool pay;
        (temp.parent,pay) = findFreeReferrer(0);
        

        userInfos[msg.sender][3] = temp;
        userAddressByID[temp.id][3] = msg.sender;

        if(pay) 
        {
           
            buyLevel(userAddressByID[temp.parent][0], 4);
        }



        return true;
    }

    event payForLevelEv(uint level, uint parentID,address paidTo, uint amount, bool direct, uint timeNow);
    function payForLevel(uint _pID, uint _level) internal returns (bool){
        address _user = userAddressByID[_pID][_level];
        if(_level == 0) 
        {
            tokenInterface(tokenAddress).transfer(_user,1 * (10 ** 18));
            US(_user, 0, 1);
            emit payForLevelEv(_level,_pID,_user, 1 * (10 ** 18), false, now);

            _user = userAddressByID[userInfos[_user][0].referrerID][0];
            tokenInterface(tokenAddress).transfer(_user,1 * (10 ** 18));
            US(_user, 1, 1);
            emit payForLevelEv(_level,_pID,_user, 1 * (10 ** 18), true, now);

           tokenInterface(tokenAddress).transfer(rewadAddress,1 * (10 ** 18));
        }
        else if(_level == 1)
        {
            tokenInterface(tokenAddress).transfer(_user, 2 * (10 ** 18));
            US(_user, 0, 2);
            emit payForLevelEv(_level,_pID,_user, 2 * (10 ** 18), false, now);

              _user = userAddressByID[userInfos[_user][0].referrerID][0];
            tokenInterface(tokenAddress).transfer(_user,2 * (10 ** 18));
            US(_user, 1, 2);
            emit payForLevelEv(_level,_pID,_user, 2 * (10 ** 18), true, now);
           tokenInterface(tokenAddress).transfer(rewadAddress,2 * (10 ** 18));       
        }
        else if(_level == 2)
        {
            tokenInterface(tokenAddress).transfer(_user, 50 * (10 ** 18));
            US(_user, 0, 50);
            emit payForLevelEv(_level,_pID,_user, 50 * (10 ** 18), false, now);

            _user = userAddressByID[userInfos[_user][0].referrerID][0];
            tokenInterface(tokenAddress).transfer(_user, 10 * (10 ** 18)); 
            US(_user, 1, 10);
            emit payForLevelEv(_level,_pID,_user, 10 * (10 ** 18), true, now); 

             _user = userAddressByID[userInfos[_user][0].referrerID][0];
            tokenInterface(tokenAddress).transfer(_user, 5 * (10 ** 18)); 
            US(_user, 2, 5);
            emit payForLevelEv(_level,_pID,_user, 5 * (10 ** 18), true, now);     

           tokenInterface(tokenAddress).transfer(rewadAddress, 3 * (10 ** 18));  
        }

        else if(_level == 7)
        {
             _user = userAddressByID[_pID][0];
            tokenInterface(tokenAddress).transfer(_user,3 * (10 ** 18));
            US(_user, 1, 3);
            emit payForLevelEv(_level,_pID,_user, 3 * (10 ** 18), true, now);

            _user = userAddressByID[userInfos[_user][0].referrerID][0];
            tokenInterface(tokenAddress).transfer(_user, 2 * (10 ** 18)); 
            US(_user, 2, 2);
            emit payForLevelEv(_level,_pID,_user, 2 * (10 ** 18), true, now); 

           
        }
           
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
        else  if(nextMemberFillBox[_level] == 1)
        {
            nextMemberFillBox[_level] = 2;
        }      
        else
        {
            nextMemberFillIndex[_level]++;
            nextMemberFillBox[_level] = 0;
            pay = true;
        }
        return (currentID+2,pay);
    }


    //a = join, b = ulp join
    function timeRemains(address _user) public view returns(uint, uint)
    {
        uint a; // UNIT TIME
        uint b; // ULP TIME
        //uint c;
        //uint d;
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