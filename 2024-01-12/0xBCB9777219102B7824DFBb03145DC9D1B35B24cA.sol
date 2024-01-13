// SPDX-License-Identifier: MIT
pragma solidity 0.8.0;

contract owned {
    address  public owner;
    address  public newOwner;

    event OwnershipTransferred(address indexed _from, address indexed _to);

    constructor() {
        owner = msg.sender;
    }

    modifier onlyOwner {
        require(msg.sender == owner);
        _;
    }

    function transferOwnership(address  _newOwner) public onlyOwner {
        newOwner = _newOwner;
    }

    function acceptOwnership() public {
        require(msg.sender == newOwner);
        emit OwnershipTransferred(owner, newOwner);
        owner = newOwner;
        newOwner = address(0);
    }
}

interface goldInterface {
    function regUser(uint _referrerID, address _user) external returns(bool);

}
interface AIinterface {

    function regUser(uint uinRefID, address _user) external returns(bool);
}

interface tokenInterface
 {
    function transfer(address _to, uint256 _amount) external returns (bool);
    function transferFrom(address _from, address _to, uint256 _amount) external returns (bool);
    function balanceOf(address _user) external view returns(uint);
 }


contract mainContract is owned {

    uint public maxDownLimit_ = 3;


    uint public lastIDCount = 0;


    struct userInfo {
        bool joined;
        uint id;
        uint referrerID;
        uint directCount;
        uint levelBought;
    }
    address public goldAddress;
    address public usdtAddress;
    address public AIAddress;
    uint public regPrice;
    //uint public directGainOne; //= 0.02 ether;
    uint public directGainTwo; //= 0.04 ether;

    mapping(uint => uint) public levelPrice;
    //mapping(uint => uint) public distForLevel;

    mapping (address => userInfo) public userInfos;
    mapping (uint => address payable) public userAddressByID;
    mapping (address => uint[12]) public nextGlobalJoinPending;
    mapping (address => uint[12]) public lastJoinTime;

    struct gPoolInfo {
        uint id;
        uint parentID;
        uint childCount;
        bool dormant;
    }

    //user => gPool level => gPool Data.  
    mapping(address => mapping(uint => gPoolInfo)) public gPoolInfos;
    uint[12] public nextGPoolToFill;
    mapping(address => uint[12]) public dormantJoin;
    mapping(address => uint[12]) public lastPendingProcessTime;


    event regLevelEv(address indexed _userWallet, uint indexed _userID,uint _time,uint _referrerID, uint _amount);
    event clubBLevelBuyEv(address indexed _user, uint _level, uint _amount, uint _time);
    event paidForLevelEv(address indexed _user, address indexed _childAddress, uint _level, uint _amount, uint _time);
    // type 
    // 0 = direct one, 
    // 1 = direct two,  
    // 2 = gold contract, 
    // 3 = base
    // 4 = Club B
    // 5 = AI Contract
    event paidForEv(uint Type,address paidTo, address paidDueTo, uint amount);
    function initialize() public onlyOwner returns(bool)  {
        require(regPrice == 0 , "can't call twice");
        emit OwnershipTransferred(address(0), owner);
        uint power = 10 ** 18; // after test make it '10 ** 18'


        regPrice = 15 * power;

        
        levelPrice[1] = 10 * power ;
        levelPrice[2] = 20 * power;
        levelPrice[3] = 40 * power;
        levelPrice[4]= 80 * power;
        levelPrice[5]= 160 * power;
        levelPrice[6]= 320 * power;
        levelPrice[7]= 640 * power;
        levelPrice[8]= 1280 * power;
        levelPrice[9]= 2560 * power;
        levelPrice[10]= 5120 * power;
        levelPrice[11]= 10240 * power;

/*
        //distForLevel[1] = 0 * power / 1000;
        distForLevel[2] = 6 * power / 10000;
        distForLevel[3] = 3 * power / 10000;
        distForLevel[4] = 3 * power / 10000;
        distForLevel[5] = 3 * power / 10000;
        distForLevel[6] = 3 * power / 10000;
        distForLevel[7] = 3 * power / 10000;
        distForLevel[8] = 3 * power / 10000;
        distForLevel[9] = 3 * power / 10000;
        distForLevel[10]= 3 * power / 10000; 
*/
        //directGainOne = 2 * power / 100;
        directGainTwo = 5 ;        

        userInfo memory UserInfo;
        lastIDCount++;

        UserInfo = userInfo({
            joined: true,
            id: lastIDCount,
            referrerID: 1,
            directCount: 0,
            levelBought:10
        });
        userInfos[owner] = UserInfo;
        userAddressByID[lastIDCount] = payable(owner);


        gPoolInfo memory GPoolInfo = gPoolInfo({
            id: 1,
            parentID: 1,
            childCount: 0,
            dormant:false
        });

        for (uint i=1;i<12;i++)
        {
            gPoolInfos[owner][i] = GPoolInfo;
            nextGPoolToFill[i]++;
        }
        

        emit regLevelEv(owner, 1, block.timestamp, 1, 0);
        return true;
    }

/*
    receive ()  external payable {
        payable(owner).transfer(msg.value);
    }
*/

    function setTokenAddress(address _goldAddress, address _usdtAddress, address _AIAddress) public onlyOwner returns(bool)
    {
        goldAddress = _goldAddress;
        usdtAddress = _usdtAddress;
        AIAddress = _AIAddress;
        return true;
    }

    function regForUser(address _user, uint _referrerID) public returns(bool) 
    {
        require(_user != address(0), "Invalid user");
        uint prc = regPrice;
        tokenInterface(usdtAddress).transferFrom(msg.sender,address(this), prc);
        _regUser(_user,_referrerID,prc);
        return true;
    }


    function regUser(uint _referrerID) public returns(bool) 
    {
        uint prc = regPrice;
        tokenInterface(usdtAddress).transferFrom(msg.sender,address(this), prc);
        _regUser(msg.sender,_referrerID, prc);
        return true;
    }

    function _regUser(address msgSender, uint _referrerID, uint prc) internal returns(bool) 
    {
        //address msgSender = msg.sender; 
        require(!userInfos[msgSender].joined, 'User exist');
        address origRef = userAddressByID[_referrerID];
        require(userInfos[origRef].joined, 'referrer not exist');

        

        //require(msg.value == prc, "Invalid amount sent");     

        uint lID = lastIDCount; 

        userInfo memory UserInfo;
        lID++;

        UserInfo = userInfo({
            joined: true,
            id: lID,
            referrerID: _referrerID,
            directCount: 0,             
            levelBought:0
        });

        userInfos[msgSender] = UserInfo;
        userAddressByID[lID] = payable(msgSender);
        
        userInfos[origRef].directCount++;

        lastIDCount = lID;
        skiptPart(msgSender,lID,_referrerID,prc);
        return true;
    }

    function skiptPart(address msgSender, uint lID, uint _referrerID, uint prc) internal returns(bool)
    {
        address _ref = userAddressByID[_referrerID];
        uint _directNos = userInfos[_ref].directCount;

        //level
        //payForLevel(msgSender);

        //club B
        //payable(goldAddress) .transfer(prc/3);
        tokenInterface(usdtAddress).transfer(goldAddress, prc/3);
        tokenInterface(usdtAddress).transfer(AIAddress, prc/3);
        emit paidForEv(2,goldAddress,msgSender,prc/3);
        emit paidForEv(5,AIAddress,msgSender,prc/3);

        goldInterface(goldAddress).regUser(_referrerID, msgSender);
        AIinterface(AIAddress).regUser(_referrerID, msgSender);

        //direct and club A
        if (_directNos == 3)
        {

            //payable(_ref) .transfer(prc/3);
            tokenInterface(usdtAddress).transfer(_ref, prc/3);
            emit paidForEv(3,_ref,msgSender, prc/3);
            _buyGlobalPool(1,_ref,levelPrice[1],false);
        }
        
        if (_directNos > 3)
        {
            //payable(_ref).transfer(directGainTwo);
            tokenInterface(usdtAddress).transfer(_ref, directGainTwo);
            emit paidForEv(1,_ref,msgSender, directGainTwo);
        }
    /*    
        else
        {
            payable(_ref).transfer(directGainOne);
            emit paidForEv(0,_ref,msgSender,directGainOne);
        }
    */    

        emit regLevelEv(msgSender, lID, block.timestamp, _referrerID, prc );
        emit clubBLevelBuyEv(msgSender, 1, prc, block.timestamp);      
        return true;
    }

    // to buy pool 1 multiple times as desired
    function buyGlobalPool() public payable returns(bool){ 
        uint _level = 1;      
        address msgSender = msg.sender;
        require(lastJoinTime[msg.sender][_level] + 1 days < block.timestamp, "please wait");
        require(userInfos[msgSender].joined, 'pls register first');
        uint prc = levelPrice[_level];
        require(_level < 12, "invalid price paid");
        tokenInterface(usdtAddress).transferFrom(msg.sender,address(this), prc);
        lastJoinTime[msg.sender][_level] = block.timestamp;
        _buyGlobalPool(_level,msgSender,prc, false);
        return true;
    }

    function processDormantEntry(uint _level) public returns(bool){        
        address msgSender = msg.sender;
        require(dormantJoin[msgSender][_level] > 0, 'no peding');
        require(lastPendingProcessTime[msgSender][_level] + 1 days < block.timestamp, "wait please");
        uint prc = levelPrice[_level];
        dormantJoin[msgSender][_level]--;
        lastPendingProcessTime[msgSender][_level]= block.timestamp;
        _buyGlobalPool(_level,msgSender,prc, true);
        return true;
    }



    function _buyGlobalPool(uint _level, address msgSender, uint prc,bool _dormant) internal returns(bool){

        require(userInfos[msgSender].levelBought + 1 >= _level, "Buy previous level first");

        userInfos[msgSender].levelBought = _level;

        uint pID = nextGPoolToFill[_level];

        gPoolInfo memory GPoolInfo = gPoolInfo({
            id: userInfos[msgSender].id,
            parentID: pID,
            childCount: 0,
            dormant:_dormant
        });

        gPoolInfos[msgSender][_level] = GPoolInfo;

        address parent = userAddressByID[pID];

        gPoolInfos[parent][_level].childCount++;
        
        uint cc = gPoolInfos[parent][_level].childCount;

        bool dorm = gPoolInfos[parent][_level].dormant;

            if (cc== 3 ) 
            {

                nextGPoolToFill[_level]++;

                if(_level < 11)
                {

                    if (_level > 1) {
                        dormantJoin[parent][_level - 1] += (2 ** (_level -2) );
                    }

                    nextGlobalJoinPending[parent][_level+1]++;
                    if(!dorm)
                    {
                        //payable(parent).transfer(prc);
                        tokenInterface(usdtAddress).transfer(parent, prc);
                        emit paidForEv(4,parent,msgSender,prc);
                    }

                } 
                
            }
            else if ( _level == 11)
            {
                dormantJoin[parent][_level - 1] += (2 ** (_level -2) );
                if(!dorm)
                {
                    //payable(parent).transfer(prc);
                    tokenInterface(usdtAddress).transfer(parent, prc);
                    emit paidForEv(4,parent,msgSender,prc);
                }                
            }


        emit clubBLevelBuyEv(msgSender, _level, levelPrice[_level] , block.timestamp);

        return true;
    }
    
    function joinNextPendingGlobal(uint _level) public returns(bool){
        require(nextGlobalJoinPending[msg.sender][_level] > 0, "no pending join");
        nextGlobalJoinPending[msg.sender][_level]--;
        uint prc = levelPrice[_level];
        _buyGlobalPool(_level,msg.sender,prc, false);
        return true;
    }

/*
    function payForLevel(address _user) internal returns (bool){

        address payable usr = userAddressByID[userInfos[_user].referrerID];
        usr = userAddressByID[userInfos[usr].referrerID];
        for (uint i=2;i<11;i++)
         {
            uint dist = distForLevel[i];
            usr.transfer(dist);

            emit paidForLevelEv(usr, _user, 1,dist, block.timestamp);

            usr = userAddressByID[userInfos[usr].referrerID];
         }

        return true;

    }
*/
    function getUserInfo(address _user) public view returns(bool,uint,uint,uint,uint)
    {
        userInfo memory temp = userInfos[_user];
        return (temp.joined,temp.id,temp.referrerID,temp.directCount,temp.levelBought);
    }

    function getgPoolInfo(address _user, uint _level) public view returns(uint,uint,uint,bool)
    {
        gPoolInfo memory temp = gPoolInfos[_user][_level];
        return (temp.id,temp.parentID,temp.childCount,temp.dormant);
    }

    function upgradeContract() public onlyOwner returns(bool)
    {
        //payable(owner).transfer(address(this).balance);
        uint bal = tokenInterface(usdtAddress).balanceOf(address(this));
        tokenInterface(usdtAddress).transfer(owner, bal);
        return true;
    }


}