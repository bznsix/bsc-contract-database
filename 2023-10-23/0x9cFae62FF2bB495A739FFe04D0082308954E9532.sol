// SPDX-License-Identifier: MIT
pragma solidity 0.8.0; 

contract owned
{
    address internal owner;
    address internal newOwner;
    address public signer;

    event OwnershipTransferred(address indexed _from, address indexed _to);

    constructor() {
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


 interface force1Interface
 {
    function coreAddressByID(uint id) external view returns(address);
 }

 interface tokenInterface
 {
    function transfer(address _to, uint256 _amount) external returns (bool);
    function transferFrom(address _from, address _to, uint256 _amount) external returns (bool);
    function balanceOf(address _user) external view returns(uint);
    function increaseLiquidity(uint _liquidity, address _caller) external returns(bool);
 }


contract F1_Orbit is owned {

    // Replace below address with main token token
    address public tokenAddress;
    address public coreAddress;
    address public liquidityTokenAddress;

    uint public totalGlobalCount;
    mapping(address => uint) public userGlobalCount;

    uint maxDownLimit = 2;
    uint public startTime = block.timestamp;

    uint public lastIDCount = 0;
    uint public defaultRefID = 1;   //this ref ID will be used if user joins without any ref ID
    bool public ignoreForce1;

    struct userInfo {
        bool joined;
        uint id;
        uint parentID;
        uint referrerID;
        uint levelBought;
        address[] parent;
        address[] referral;
    }


    
    mapping(uint => uint) public priceOfLevel;
    mapping(uint => uint) public directRefIncome;
    mapping(uint => uint) public distForCore;
    mapping(uint => uint) public liquidity;


    mapping(uint => uint) public _4XGlobalCount; // for distribution

    struct autoPool
    {
        uint userID;
        uint autoPoolParent;
        bool right;
    }


    mapping(uint => autoPool[]) public _4XPoolLevel;  // users lavel records under auto pool scheme
    mapping(address => mapping(uint => uint[])) public _4XPoolIndex; //to find index of user inside auto pool
    uint[10] public _4XFillIndex;  // which auto pool index is in top of queue to fill in 
    uint[10] public _4XFillBox;   // 3 downline to each, so which downline need to fill in

    mapping (address => userInfo) public userInfos;
    mapping (uint => address payable) public userAddressByID;


    event regLevelEv(address indexed _userWallet, uint indexed _userID, uint indexed _parentID, uint _time, address _refererWallet, uint _referrerID);
    event levelBuyEv(address indexed _user, uint _level, uint _amount, uint _time);
    event paidForLevelEv(address indexed _user, address indexed _referral, uint _level, uint _amount, uint _time);

    event _4XPoolPayEv(uint timeNow,address paidTo,uint paidForLevel, uint paidAmount, address paidAgainst);
    event update_4XPoolEv(uint timeNow,uint userIndexInAutoPool, address user);
    event directPayEv(address from, address to, uint level, uint amount);

    function initialize(address payable ownerAddress, address payable ID1address) public onlyOwner {
        owner = ownerAddress;

        emit OwnershipTransferred(address(0), owner);
        address payable ownerWallet = ID1address;

        uint pow = 10 ** 18;

        priceOfLevel[1] = 12 * pow;
        priceOfLevel[2] = 18 * pow;
        priceOfLevel[3] = 30 * pow;
        priceOfLevel[4] = 40 * pow;
        priceOfLevel[5] = 70 * pow;
        priceOfLevel[6] = 130 * pow;
        priceOfLevel[7] = 200 * pow;
        priceOfLevel[8] = 300 * pow;
        priceOfLevel[9] = 500 * pow;
        priceOfLevel[10]= 700 * pow;

        directRefIncome[1] = 3 * pow;
        directRefIncome[2] = 4 * pow;
        directRefIncome[3] = 6 * pow;
        directRefIncome[4] = 8 * pow;
        directRefIncome[5] = 15 * pow;
        directRefIncome[6] = 30 * pow;
        directRefIncome[7] = 50 * pow;
        directRefIncome[8] = 70 * pow;
        directRefIncome[9] = 114 * pow;
        directRefIncome[10]= 200 * pow;

        _4XGlobalCount[1] = 1;
        _4XGlobalCount[2] = 1;
        _4XGlobalCount[3] = 1;
        _4XGlobalCount[4] = 1;
        _4XGlobalCount[5] = 3;
        _4XGlobalCount[6] = 3;
        _4XGlobalCount[7] = 4;
        _4XGlobalCount[8] = 4;
        _4XGlobalCount[9] = 5;
        _4XGlobalCount[10]= 6;

        distForCore[1] = 0 * pow;
        distForCore[2] = 3 * pow;
        distForCore[3] = 6 * pow;
        distForCore[4] = 8 * pow;
        distForCore[5] = 15 * pow;
        distForCore[6] = 30 * pow;
        distForCore[7] = 50 * pow;
        distForCore[8] = 80 * pow;
        distForCore[9] = 142 * pow;
        distForCore[10]= 166 * pow;


        liquidity[1] = 4 * pow;
        liquidity[2] = 6 * pow;
        liquidity[3] = 13 * pow;
        liquidity[4] = 19 * pow;
        liquidity[5] = 25 * pow;
        liquidity[6] = 55 * pow;
        liquidity[7] = 80 * pow;
        liquidity[8] = 125 * pow;
        liquidity[9] = 219 * pow;
        liquidity[10]= 304 * pow;

        userInfo memory UserInfo;
        lastIDCount++;

        UserInfo = userInfo({
            joined: true,
            id: lastIDCount,
            parentID: 1,
            referrerID: 1,
            levelBought: 10,  
            referral: new address[](0),
            parent: new address[](0)
        });
        userInfos[ownerWallet] = UserInfo;
        userAddressByID[lastIDCount] = ownerWallet;

        autoPool memory temp2;
        for (uint a = 0 ; a < 10; a++)
        {
           temp2.userID = lastIDCount;  
           _4XPoolLevel[a].push(temp2);
         
           _4XPoolIndex[ownerWallet][a].push(0);
        }

        emit regLevelEv(ownerWallet, 1, 0, block.timestamp, address(this), 0);

    }

    function toggleIgnoreForce1() public onlyOwner returns(bool)
    {
        ignoreForce1 = !ignoreForce1;
        return true;
    }

    function subOrbitOwn(uint _oldID, address _referrer, address _user) public onlyOwner returns(bool) 
    {
        _subOrbit(_oldID,_referrer, _user);
        return true;
    }


    function subOrbit(uint _oldID, address _referrer) public returns(bool) 
    {
        _subOrbit(_oldID,_referrer, msg.sender);
        return true;
    }


    function _subOrbit(uint _oldID, address _referrer, address msgSender) internal returns(bool) 
    {
        if (!ignoreForce1) require(force1Interface(coreAddress).coreAddressByID(_oldID) == msgSender, "Invalid oldID");
        uint _referrerID = userInfos[_referrer].id;
        if (_referrerID == 0) _referrerID = 1;

        uint pID;

        address origRef = userAddressByID[_referrerID];


        //checking all conditions
        require(!userInfos[msgSender].joined, 'User exist');

        uint _lastIDCount = lastIDCount; // from here _lastIDCount is lastIDCount

        if(userInfos[_referrer].parent.length >= maxDownLimit ) pID = userInfos[findFreeReferrer(_referrer)].id;


        uint prc = priceOfLevel[1];
        //transferring tokens from smart user to smart contract for level 1
        tokenInterface(tokenAddress).transferFrom(msg.sender, address(this), prc);

        uint di = directRefIncome[1] ;
        //direct payment
        if( userInfos[origRef].levelBought >= 1) 
        {
            tokenInterface(tokenAddress).transfer(origRef, di);
            emit directPayEv(msgSender,origRef,1,di);
        }
        else
        {
            tokenInterface(tokenAddress).transfer(owner, directRefIncome[1] );
            emit directPayEv(msgSender,owner,1,di);
        }
        //update variables
        userInfo memory UserInfo;
        _lastIDCount++;

        UserInfo = userInfo({
            joined: true,
            id: _lastIDCount,
            parentID: pID,
            referrerID: _referrerID,
            levelBought: 1,             
            referral: new address[](0),
            parent: new address[](0)
        });

        userInfos[msgSender] = UserInfo;
        userAddressByID[_lastIDCount] = payable(msgSender);



        userInfos[userAddressByID[pID]].parent.push(msgSender);
        
        userInfos[origRef].referral.push(msgSender);


        lastIDCount = _lastIDCount;
        require(spkitPart(msgSender,_lastIDCount,pID,_referrerID,prc),"split part failed");
        return true;
    }

    function spkitPart(address msgSender, uint lID, uint pID, uint _referrerID, uint prc) internal returns(bool)
    {
        //require(payForLevel(1, msgSender),"pay for level fail");
        emit regLevelEv(msgSender, lID, pID, block.timestamp,userAddressByID[pID], _referrerID );
        emit levelBuyEv(msgSender, 1, prc, block.timestamp);

        require(updateNPay_4XPool(msgSender),"_4X pool update fail"); 
        uint liq = liquidity[1];
        tokenInterface(tokenAddress).transfer(liquidityTokenAddress, liq);
        tokenInterface(liquidityTokenAddress).increaseLiquidity(liq,msgSender);
        flushRemaining();      
        return true;
    }

    function buyOrbitOwn(uint _level, address _user) public onlyOwner returns(bool)
    {
        _buyOrbit(_level, _user);
        return true;
    }


    function buyOrbit(uint _level) public returns(bool)
    {
        _buyOrbit(_level, msg.sender);
        return true;
    }


    function _buyOrbit(uint _level, address msgSender) internal returns(bool)
    {
        
        require(_level > 1 && _level <= 10, 'Incorrect level');
        require(userInfos[msgSender].levelBought + 1 == _level, "buy previous level first");  
        userInfos[msgSender].levelBought = _level;
        
      
        //transfer tokens
        uint prc = priceOfLevel[_level];
        tokenInterface(tokenAddress).transferFrom(msg.sender, address(this), prc);


        address origRef = userAddressByID[userInfos[msgSender].referrerID];
        //direct payment
        
       // if( userInfos[origRef].levelBought >= _level) 
       // {
       //     tokenInterface(tokenAddress).transfer(origRef, directRefIncome[_level] );
       // }
       // else
       // {
       //     tokenInterface(tokenAddress).transfer(owner, directRefIncome[_level] );
       // }


       // referer = userAddressByID[userInfos[_user].referrerID];
        for(uint j=0; j < 5; j++)
        {
            if( userInfos[origRef].levelBought >= _level )
            {
                tokenInterface(tokenAddress).transfer(origRef, directRefIncome[_level]);
                emit directPayEv(msgSender,origRef,_level,directRefIncome[_level]);
                j=11;
            }
            else
            {
                origRef = userAddressByID[userInfos[origRef].referrerID];
                if(j==4)
                {
                    tokenInterface(tokenAddress).transfer(owner, directRefIncome[_level]);
                    emit directPayEv(msgSender,owner,_level,directRefIncome[_level]);
                    j=11;
                }                
            }            
        }


        require(payForLevel(_level, msgSender),"pay for level fail");
        emit levelBuyEv(msgSender, _level, prc , block.timestamp);

            uint i=_4XGlobalCount[_level];
            
            for (uint j=0;j<i;j++)
            {
                updateNPay_4XPool(msgSender);
            }

        uint liq = liquidity[_level];
        tokenInterface(tokenAddress).transfer(liquidityTokenAddress, liq);
        tokenInterface(liquidityTokenAddress).increaseLiquidity(liq,msgSender);

        flushRemaining();
        return true;
    }
    


    function payForLevel(uint _level, address _user) internal returns (bool){
        address referer;
        uint amt = distForCore[_level]/10;

        referer = userAddressByID[userInfos[_user].referrerID];
        for(uint i=0; i < 10; i++)
        {
            if( userInfos[referer].levelBought >= _level )
            {
                tokenInterface(tokenAddress).transfer(referer, amt);
            }
            else
            {
                tokenInterface(tokenAddress).transfer(owner, amt);
            }
            referer = userAddressByID[userInfos[referer].referrerID];
        }
        return true;

    }

    function flushRemaining() internal returns(bool)
    {
        uint bal = tokenInterface(tokenAddress).balanceOf(address(this));
        if (bal > 0) tokenInterface(tokenAddress).transfer(owner, bal);
        return true;
    }

    function findFreeReferrer(address _user) public view returns(address) {
        uint _limit = maxDownLimit;
        if(userInfos[_user].parent.length < _limit ) return _user;

        address[] memory referrals = new address[](126);

        uint j;
        for(j=0;j<_limit;j++)
        {
            referrals[j] = userInfos[_user].parent[j];
        }

        address freeReferrer;
        bool noFreeReferrer = true;

        for(uint i = 0; i < 126; i++) {


            if(userInfos[referrals[i]].parent.length == _limit) {

                if(j < 62) {
                    
                    for(uint k=0;k< _limit;k++)
                    {
                        referrals[j] = userInfos[referrals[i]].parent[k];
                        j++;
                    }

                }
            }
            else {
                noFreeReferrer = false;
                freeReferrer = referrals[i];
                break;
            }
        }

        require(!noFreeReferrer, 'No Free Referrer');

        return freeReferrer;
    }


    function updateNPay_4XPool(address _user) internal returns (bool)
    {
        address recycleUser;
        uint a;
        uint len = _4XPoolLevel[a].length;
        autoPool memory temp;
        temp.userID = userInfos[_user].id;
        uint idx = _4XFillIndex[a];
        temp.autoPoolParent = idx;       
        _4XPoolLevel[a].push(temp);  
        userGlobalCount[_user]++;
        totalGlobalCount++;      

        uint ix = _4XPoolLevel[a][idx].autoPoolParent;
        recycleUser = userAddressByID[_4XPoolLevel[a][ix].userID];       

        bool recycle = false;
        if(_4XFillBox[a] == 0)
        {
            _4XFillBox[a] = 1;
        }   
        else
        {
            _4XPoolLevel[a][len].right = true;
            _4XFillIndex[a]++;
            _4XFillBox[a] = 0;

            if (_4XPoolLevel[a][idx].right == true) 
            {
                recycle = true;
            } 
            
        }


        if(recycle == false)
        {
            if(recycleUser == address(0)) recycleUser = userAddressByID[defaultRefID];
            uint amt = 5 * (10**18);

            tokenInterface(tokenAddress).transfer(recycleUser, amt);
            emit _4XPoolPayEv(block.timestamp, recycleUser,a+1, amt, _user);
        }

        _4XPoolIndex[_user][a].push(len);
        emit update_4XPoolEv(block.timestamp,len, _user);
        if(recycle == true) updateNPay_4XPool(recycleUser);
        return true;
    }

    function viewUserReferral(address _user) public view returns(address[] memory) {
        return userInfos[_user].referral;
    }



    function viewUsersOfParent(address _user) public view returns(address[] memory) {
        return userInfos[_user].parent;
    }


    
    function indexLength(uint _level) public view returns(uint)
    {
        if(!(_level > 0  || _level < 11)) return 0;
        return _4XPoolLevel[_level - 1].length;
    }  

    
    function changeLiquidityTokenaddress(address newLiquidityTokenaddress) onlyOwner public returns(string memory){
        liquidityTokenAddress = newLiquidityTokenaddress;
        return("token address updated successfully");
    }

    function Assign_Reward_Address(address newtokenaddress) onlyOwner public returns(string memory){
        tokenAddress = newtokenaddress;
        return("token address updated successfully");
    }

    function force1CoreContract(address _fContract) onlyOwner public returns(bool)
    {
        coreAddress = _fContract;
        return true;
    }

    function changeMyAddress(address _newAddress, address _oldAddress) public onlyOwner returns(bool)
    {
        require(!userInfos[_newAddress].joined && userInfos[_oldAddress].joined, "wrong caller or new address");
        userInfos[_newAddress] = userInfos[_oldAddress];
        userInfos[_oldAddress] = userInfos[address(0)];
        uint id = userInfos[_oldAddress].id;

        userAddressByID[id] = payable(_newAddress);

        return true;
    }

    function levelBought_(address _user) public view returns(uint)
    {
        return userInfos[_user].levelBought;
    }

}