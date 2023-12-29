// SPDX-License-Identifier: MIT
pragma solidity >=0.4.23 <0.9.0;

interface IERC20 {
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function balanceOf(address account) external view returns (uint256);
    function allowance(address owner, address spender) external view returns (uint256);
}


contract UNIVERSAL_META_GLOBAL {
    IERC20 public usdt;
    struct Ref {
        address[] referrals;
    }
    struct User {
        uint id;
        address referrer;
        uint8 partnercount;
        uint8 maxlevel;
        uint directbonus;
        uint levelbonus;
        uint worldpoolincome;
        uint autopoolincome;
        uint boostpoolincome;
        uint boostUplineincome;
        uint[] levelWiseUsers;
        uint totalEarn;
        uint8 teamCount;
        mapping(uint8 => address[]) partners;
        mapping(uint8 => bool) activeLevels;
        mapping(uint8 => bool) activeBoosting;
        mapping(uint8 => Ref) referrals;
        mapping(uint256 => uint[]) worldpool;
        mapping(uint256 => uint[]) autopool;
        mapping(uint256 => uint[]) boostpool;
    }
    struct LevelIncomeReport {
        uint fromid;
        address fromaddress;
        uint slot;
        uint level;
        uint amount;
        uint timestamp;
        uint types;
    }

    struct wpools {
      uint id; // userID
      uint wid; // autopoolID
      address myAddress; // user address
      uint level;
      uint currectID; // refe ID
      address currectRefAddress; // refe address
      uint id1; // user 1 
      uint id2; // user 2
      uint id3; // user 3
    }

    struct apools {
      uint id; // userID
      uint wid; // autopoolID
      address myAddress; // user address
      uint level;
      uint currectID; // refe ID
      address currectRefAddress; // refe address
      uint id1; // user 1 
      uint id2; // user 2
      uint id3; // user 3
    }

    struct bpools {
      uint id; // userID
      uint wid; // autopoolID
      address myAddress; // user address
      uint level;
      uint currectID; // refe ID
      address currectRefAddress; // refe address
      uint id1; // user 1 
      uint id2; // user 2
      uint id3; // user 3
    }

    mapping(address => User) public users;
    mapping(uint => address) public userIds;

    mapping(uint => wpools) public Wpools;
    mapping(uint => address) public worldIds;

    mapping(uint => apools) public Apools;
    mapping(uint => address) public autoIds;

    mapping(uint => bpools) public Bpools;
    mapping(uint => address) public boostIds;

    mapping(address => uint) public balances;
    mapping(address => LevelIncomeReport[]) public LevelIncomeTransactions;

    mapping(uint8 => mapping(uint256 => uint)) public x3vId_number;
    mapping(uint8 => uint256) public x3CurrentvId;
    mapping(uint8 => uint256) public x3Index;

    mapping(uint8 => mapping(uint256 => uint)) public x3vId_number_auto;
    mapping(uint8 => uint256) public x3CurrentvId_auto;
    mapping(uint8 => uint256) public x3Index_auto;

    mapping(uint8 => mapping(uint256 => uint)) public x3vId_number_boost;
    mapping(uint8 => uint256) public x3CurrentvId_boost;
    mapping(uint8 => uint256) public x3Index_boost;
    
    uint public lapsedIncome = 0 ether;
    uint public lastUserId = 2;
    uint public worldId = 1;
    uint public autoId = 1;
    uint public boostId = 1;
    uint8 public constant LAST_LEVEL = 6;
    address public owner;
    uint8[5] private distribution = [0, 20, 36, 20, 24]; // [1]=direct income,[2]=level income,[3]=magical income,[4]=Autopool income
    uint[7] public packageprice = [0, 25 ether, 50 ether, 100 ether, 200 ether, 400 ether, 800 ether];
    uint8[11] private levelPercentage = [0,10,10,10,10,10,10,10,10,10,10];

    uint public boostingPackagePrice = 15 ether;
    uint public boostLevelIncomePerLevel = 1 ether;


    modifier onlyOwner() {
        require(msg.sender == owner, "Not the contract owner");
        _;
    }

    constructor(address ownerAddress, IERC20 _usdtAddress) public {
        usdt = _usdtAddress;
        owner = ownerAddress;
        User memory user = User({
            id: 1,
            referrer: address(0),
            partnercount: 0,
            maxlevel: 6,
            directbonus: 0,
            levelbonus: 0,
            worldpoolincome: 0,
            autopoolincome: 0,
            boostpoolincome: 0,
            boostUplineincome: 0,
            levelWiseUsers: new uint[](16),
            totalEarn: 0,
            teamCount: 0
        }); 
        users[ownerAddress] = user;
        userIds[1] = ownerAddress;

        for (uint8 i = 1; i <= LAST_LEVEL; i++) {
            x3vId_number[i][1]=worldId;
            x3Index[i]=1;
            x3CurrentvId[i]=1;  
            
            users[ownerAddress].activeLevels[i] = true;
            users[ownerAddress].worldpool[i].push(worldId);
            wpools memory wpool = wpools({
             id: 1, // userID
             wid: worldId, // autopoolID
             myAddress: ownerAddress, // user address
             level: i,
             currectID: 0, // refe ID
             currectRefAddress: address(0), // refe address
             id1: 0, // user 1 
             id2: 0, // user 2
             id3: 0 // user 3
            });
            worldIds[worldId] = ownerAddress;
            Wpools[worldId] = wpool;
            worldId++;

            x3vId_number_auto[i][1]=autoId;
            x3Index_auto[i]=1;
            x3CurrentvId_auto[i]=1;  
            users[ownerAddress].autopool[i].push(autoId);
            apools memory apool = apools({
             id: 1, // userID
             wid: autoId, // autopoolID
             myAddress: ownerAddress, // user address
             level: i,
             currectID: 0, // refe ID
             currectRefAddress: address(0), // refe address
             id1: 0, // user 1 
             id2: 0, // user 2
             id3: 0 // user 3
            });
            autoIds[autoId] = ownerAddress;
            Apools[autoId] = apool;
            autoId++;

        }

        users[ownerAddress].activeBoosting[1] = true;
        x3vId_number_boost[1][1]=boostId;
        x3Index_boost[1]=1;
        x3CurrentvId_boost[1]=1;  
        users[ownerAddress].boostpool[1].push(boostId);
        bpools memory bpool = bpools({
            id: 1, // userID
            wid: boostId, // autopoolID
            myAddress: ownerAddress, // user address
            level: 1,
            currectID: 0, // refe ID
            currectRefAddress: address(0), // refe address
            id1: 0, // user 1 
            id2: 0, // user 2
            id3: 0 // user 3
        });
        boostIds[boostId] = ownerAddress;
        Bpools[boostId] = bpool;
        boostId++;
    }
    
    function registrationExt(address referrerAddress, uint256 amount) external {
        require(!isUserExists(msg.sender), "User already exists");
        require(isUserExists(referrerAddress), "Referrer does not exist");
        require(amount == packageprice[1], "Registration cost must be 1 ether");
        require(usdt.allowance(msg.sender, address(this)) >= amount, "Insufficient allowance");
        require(usdt.transferFrom(msg.sender, address(this), amount), "Transfer failed");
        registration(msg.sender, referrerAddress);
    }

    function registration(address userAddress, address referrerAddress) private {

        User memory user = User({
            id: lastUserId,
            referrer: referrerAddress,
            partnercount: 0,
            maxlevel: 1,
            directbonus: 0,
            levelbonus: 0,
            worldpoolincome: 0,
            autopoolincome: 0,
            boostpoolincome: 0,
            boostUplineincome: 0,
            levelWiseUsers: new uint[](16),
            totalEarn: 0,
            teamCount: 0
        });
        users[userAddress] = user;
        users[userAddress].referrer = referrerAddress;
        users[userAddress].activeLevels[1] = true;
        userIds[lastUserId] = userAddress;
        users[referrerAddress].partners[0].push(userAddress);
        users[referrerAddress].referrals[0].referrals.push(userAddress);
        users[referrerAddress].partnercount++;
        lastUserId++;
        updateUplinesCount(msg.sender);
        //emit Registration(userAddress, referrerAddress, users[userAddress].id, users[referrerAddress].id);
        distributebonus(userAddress,referrerAddress, 1);
        uint freex3AutoPoolReferrer = findFreex3AutoPoolReferrer(1);
        updateX3AutoPoolReferrer(userAddress, freex3AutoPoolReferrer, 1);
        uint freex3AutoPoolReferrer_auto = findFreex3AutoPoolReferrer_auto(1);
        updateX3AutoPoolReferrer_auto(userAddress, freex3AutoPoolReferrer_auto, 1);
    }

    function BuyPackage(uint8 level,uint256 amount) external {
      require(isUserExists(msg.sender), "User does not exist. Register first.");
      require(usdt.allowance(msg.sender, address(this)) >= amount, "Insufficient allowance");
      require(usdt.transferFrom(msg.sender, address(this), amount), "Transfer failed");
      require(amount == packageprice[level], "Package cost not valid");        
      require(level > 1 && level <= LAST_LEVEL, "Invalid level");
      require(!users[msg.sender].activeLevels[level], "Level already activated");
        
      BuyM4Matrix(msg.sender, level);
    }

    function BuyM4Matrix(address userAddress, uint8 level) private { 
        users[userAddress].activeLevels[level] = true;
        users[userAddress].maxlevel = level;
        distributebonus(userAddress,users[userAddress].referrer, level);
        uint freex3AutoPoolReferrer = findFreex3AutoPoolReferrer(level);
        updateX3AutoPoolReferrer(userAddress, freex3AutoPoolReferrer, level);
        uint freex3AutoPoolReferrer_auto = findFreex3AutoPoolReferrer_auto(level);
        updateX3AutoPoolReferrer_auto(userAddress, freex3AutoPoolReferrer_auto, level);
    }

    function BuyBoostingPackage(uint256 amount) external {
      require(isUserExists(msg.sender), "User does not exist. Register first.");
      require(usdt.allowance(msg.sender, address(this)) >= amount, "Insufficient allowance");
      require(usdt.transferFrom(msg.sender, address(this), amount), "Transfer failed");
      require(amount == boostingPackagePrice, "Package cost not valid");  
      require(!users[msg.sender].activeBoosting[1], "Boosting already activated");
      users[msg.sender].activeBoosting[1] = true;  
      uint freex3AutoPoolReferrer_boost = findFreex3AutoPoolReferrer_boost(1);
      updateX3AutoPoolReferrer_boost(msg.sender, freex3AutoPoolReferrer_boost, 1);  
    }

    // Boostpool payout code start //
    function updateX3AutoPoolReferrer_boost(address userAddress, uint referrerId, uint8 level) private{
        uint256 newIndex=x3Index_boost[level]+1;
        x3vId_number_boost[level][newIndex]=boostId;
        x3Index_boost[level]=newIndex;
        uint256 boostpoolincome=boostingPackagePrice;
        users[userAddress].boostpool[level].push(boostId);
        bpools memory bpool = bpools({
            id: users[userAddress].id, // userID
            wid: boostId, // autopoolID
            myAddress: userAddress, // user address
            level: level,
            currectID: Bpools[referrerId].wid, // refe ID
            currectRefAddress: Bpools[referrerId].myAddress, // // refe address
            id1: 0, // user 1 
            id2: 0, // user 2
            id3: 0 // user 3
        });
        boostIds[boostId] = userAddress;
        Bpools[boostId] = bpool;        

        if(Bpools[referrerId].id1==0){
          Bpools[referrerId].id1 = boostId;
          uint256 sponsorUplineIncome = (boostpoolincome*20)/100;  
          if (users[Bpools[referrerId].myAddress].referrer != address(0) && users[Bpools[referrerId].myAddress].referrer != address(0x0)) {
            transferAmount(users[Bpools[referrerId].myAddress].referrer, sponsorUplineIncome, 5); 
          }
          else{
            transferAmount(owner, sponsorUplineIncome, 0);
          }

          uint256 sponsorIncome = (boostpoolincome*80)/100;   
          transferAmount(Bpools[referrerId].myAddress, sponsorIncome, 6);
          boostId++;   
        }
        else if(Bpools[referrerId].id2==0){
          Bpools[referrerId].id2 = boostId;
          uint upline = Bpools[Bpools[referrerId].currectID].wid;
          levelIncomeDistribute(userAddress,upline,boostpoolincome,level,4);
          boostId++;   
        }
        else if(Bpools[referrerId].id3==0){
          Bpools[referrerId].id3 = boostId;  
          boostId++;
          x3CurrentvId_boost[level]=x3CurrentvId_boost[level]+1;     
          uint freeAutoPoolReferrer = findFreex3AutoPoolReferrer_boost(level);
          updateX3AutoPoolReferrer_boost(Bpools[referrerId].myAddress, freeAutoPoolReferrer,level);
        }        
    }  

    function findFreex3AutoPoolReferrer_boost(uint8 level) public view returns(uint){
            uint id=x3CurrentvId_boost[level];
            return x3vId_number_boost[level][id];
    } 
     
    function usersBoostAutoPool(address userAddress, uint8 level) public view returns (uint, uint[] memory) {
        return (users[userAddress].boostpool[level].length,users[userAddress].boostpool[level]);
    }
    // Boostpool payout code end //

    function distributebonus(address userAddress,address referrerAddress, uint8 level) private {
        uint price = packageprice[level];
        uint amount = (price*distribution[1])/100;
        transferAmount(referrerAddress, amount, 1);
        uint LevelDistributeAmount = (price*distribution[2])/100;
        levelIncomeDistribute(userAddress,users[userAddress].id,LevelDistributeAmount,level,1);        
    }    

    function levelIncomeDistribute(address userAddress, uint referrerId, uint amount, uint8 level, uint8 types) internal {
        uint256 income = amount;
        address user;
        uint currentRecipient;
        uint myID;
        address currentRecipient_1;
        uint recipient = referrerId;
        uint256 uplinesComm;
        uint cnd;
        if(types == 3){
            cnd = 6;
        }
        else if(types == 4){
            cnd = 15;
        }
        else{
            cnd = 10;
        }

        for (uint8 i = 1; i <= cnd; i++) {
            if(types == 3){
              uplinesComm = income;
            }
            else if(types == 4){
              uplinesComm = boostLevelIncomePerLevel;
            }
            else{
              uplinesComm = (income * levelPercentage[i]) / 100;
            }

            if (types == 1) {
                //currentRecipient = users[userIds[referrerId]].referrer;
                currentRecipient = recipient;
                user = userAddress;
                currentRecipient_1 = users[userIds[currentRecipient]].referrer;
                myID = 0;
            } else if (types == 2) {
                currentRecipient = recipient;
                user = userAddress;
                currentRecipient_1 = Wpools[currentRecipient].myAddress;
                myID = currentRecipient;
            }
            else if (types == 3) {
                currentRecipient = recipient;
                user = userAddress;
                currentRecipient_1 = Apools[currentRecipient].myAddress;
                myID = currentRecipient;
            }
            else if (types == 4) {
                currentRecipient = recipient;
                user = userAddress;
                currentRecipient_1 = Bpools[currentRecipient].myAddress;
                myID = currentRecipient;    
            }
            if (currentRecipient_1 != address(0) && currentRecipient_1 != address(0x0)) {
                if (users[currentRecipient_1].activeLevels[level]) {
                    LevelIncomeReport memory newLevelReport = LevelIncomeReport({
                        fromid: users[user].id,
                        fromaddress: user,
                        slot: level,
                        level: i,
                        amount: uplinesComm,
                        timestamp: block.timestamp,
                        types: types
                    });

                    LevelIncomeTransactions[currentRecipient_1].push(newLevelReport);
                    if (types == 3) {
                     transferAmount(currentRecipient_1, uplinesComm, 4);
                    }
                    else{
                     transferAmount(currentRecipient_1, uplinesComm, 2);   
                    }
                } else {
                    transferAmount(owner, uplinesComm, 0);
                }
            } else {
                transferAmount(owner, uplinesComm, 0);
            }

            if (types == 1) {
                recipient = users[currentRecipient_1].id;
            } else if(types == 2) {
                recipient = Wpools[myID].currectID;
            } else if(types == 3) {
                recipient = Apools[myID].currectID;
            } else if(types == 4) {
                recipient = Bpools[myID].currectID;
            } 

        }
    }


    function updateUplinesCount(address userAddress) internal {
        User storage user = users[userAddress];
        address upline = user.referrer;        
        for (uint i = 1; i <= 16 && upline != address(0); i++) {
            User storage uplineUser = users[upline];
            uplineUser.teamCount += 1;
            uplineUser.levelWiseUsers[i - 1] += 1;
            upline = uplineUser.referrer;
        }
    }


    // Worldpool payout code start //
    function updateX3AutoPoolReferrer(address userAddress, uint referrerId, uint8 level) private{
        uint256 newIndex=x3Index[level]+1;
        x3vId_number[level][newIndex]=worldId;
        x3Index[level]=newIndex;
        uint price = packageprice[level];
        uint256 worldpoolincome=(price*distribution[3])/100;
        users[userAddress].worldpool[level].push(worldId);
        wpools memory wpool = wpools({
            id: users[userAddress].id, // userID
            wid: worldId, // autopoolID
            myAddress: userAddress, // user address
            level: level,
            currectID: Wpools[referrerId].wid, // refe ID
            currectRefAddress: Wpools[referrerId].myAddress, // // refe address
            id1: 0, // user 1 
            id2: 0, // user 2
            id3: 0 // user 3
        });
        worldIds[worldId] = userAddress;
        Wpools[worldId] = wpool;        

        if(Wpools[referrerId].id1==0){
          Wpools[referrerId].id1 = worldId;
          transferAmount(Wpools[referrerId].myAddress, worldpoolincome, 3);
          worldId++;  
        }
        else if(Wpools[referrerId].id2==0){
          Wpools[referrerId].id2 = worldId;
          uint upline = Wpools[Wpools[referrerId].currectID].wid;
          levelIncomeDistribute(userAddress,upline,worldpoolincome,level,2);
          worldId++;   
        }
        else if(Wpools[referrerId].id3==0){
          Wpools[referrerId].id3 = worldId;  
          worldId++;
          x3CurrentvId[level]=x3CurrentvId[level]+1;     
          uint freeAutoPoolReferrer = findFreex3AutoPoolReferrer(level);
          updateX3AutoPoolReferrer(Wpools[referrerId].myAddress, freeAutoPoolReferrer,level);
        }        
    }  

    function findFreex3AutoPoolReferrer(uint8 level) public view returns(uint){
            uint id=x3CurrentvId[level];
            return x3vId_number[level][id];
    } 
     
    function usersWorldAutoPool(address userAddress, uint8 level) public view returns (uint, uint[] memory) {
        return (users[userAddress].worldpool[level].length,users[userAddress].worldpool[level]);
    }
    // Worldpool payout code end //

    // Autopool payout code start //
    function updateX3AutoPoolReferrer_auto(address userAddress, uint referrerId, uint8 level) private{
        uint256 newIndex=x3Index_auto[level]+1;
        x3vId_number_auto[level][newIndex]=autoId;
        x3Index_auto[level]=newIndex;
        uint price = packageprice[level];
        uint256 autopoolincome=(price*distribution[4])/100;
        uint256 income=autopoolincome/6;
        users[userAddress].autopool[level].push(autoId);
        apools memory apool = apools({
            id: users[userAddress].id, // userID
            wid: autoId, // autopoolID
            myAddress: userAddress, // user address
            level: level,
            currectID: Apools[referrerId].wid, // refe ID
            currectRefAddress: Apools[referrerId].myAddress, // // refe address
            id1: 0, // user 1 
            id2: 0, // user 2
            id3: 0 // user 3
        });
        autoIds[autoId] = userAddress;
        Apools[autoId] = apool;        

        if(Apools[referrerId].id1==0){
          Apools[referrerId].id1 = autoId;
          uint upline = Apools[referrerId].wid;
          levelIncomeDistribute(userAddress,upline,income,level,3);
          autoId++;  
        }
        else if(Apools[referrerId].id2==0){
          Apools[referrerId].id2 = autoId;
          uint upline = Apools[referrerId].wid;
          levelIncomeDistribute(userAddress,upline,income,level,3);
          autoId++;   
        }
        else if(Apools[referrerId].id3==0){
          Apools[referrerId].id3 = autoId;  
          uint upline = Apools[referrerId].wid;
          levelIncomeDistribute(userAddress,upline,income,level,3);          
          autoId++;
          x3CurrentvId_auto[level]=x3CurrentvId_auto[level]+1;
        }        
    }  

    function findFreex3AutoPoolReferrer_auto(uint8 level) public view returns(uint){
            uint id=x3CurrentvId_auto[level];
            return x3vId_number_auto[level][id];
    } 
     
    function usersAutoPool(address userAddress, uint8 level) public view returns (uint, uint[] memory) {
        return (users[userAddress].autopool[level].length,users[userAddress].autopool[level]);
    }
    // Autopool payout code end //
    

    function isUserExists(address user) public view returns (bool) {
        return (users[user].id != 0);
    }

    function levelWiseUsers(address userAddress) public view returns(uint[] memory) {
        return (users[userAddress].levelWiseUsers);
    }

    function usersActiveLevels(address userAddress, uint8 level) public view returns(bool) {
        return users[userAddress].activeLevels[level];
    }

    function usersActiveBoosting(address userAddress, uint8 level) public view returns(bool) {
        return users[userAddress].activeBoosting[level];
    }

    function userspartner(address userAddress) public view returns(address[] memory) {
        return (users[userAddress].partners[0]);
    }

    function transferAmount(address receiver, uint dividend, uint types) private {
        if (types == 1) {
            users[receiver].directbonus += dividend;
        }
        else if (types == 2) {
            users[receiver].levelbonus += dividend;
        } 
        else if (types == 3) {
            users[receiver].worldpoolincome += dividend;
        } 
        else if (types == 4) {
            users[receiver].autopoolincome += dividend;
        } 
        else if (types == 5) {
            users[receiver].boostpoolincome += dividend;
        }
        else if (types == 6) {
            users[receiver].boostUplineincome += dividend;
        }
        else {
           lapsedIncome += dividend;
        }

        users[receiver].totalEarn += dividend;
        require(usdt.transfer(receiver, dividend), "USDT transfer failed");
    }
}