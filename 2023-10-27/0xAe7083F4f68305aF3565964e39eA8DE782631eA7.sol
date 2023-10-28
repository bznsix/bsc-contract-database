pragma solidity >=0.4.23 <0.7.0;

contract OlympiaWorld{
    
    struct Ref {
      address[] referrals;  
    }

    struct M4User {  
        uint8 level; 
        mapping(uint => M4Matrix) M4;
    }    

    struct M4Matrix {
        uint id;
        address useraddress;
        uint upline;
        uint8 partnercount;
        uint partnerdata;
        uint8 reentry;
    }
    struct E3 {
        address currentReferrer;
        address[] referrals;
        bool blocked;
        uint reinvestCount;
    }
   
    struct User {
        uint id;
        address referrer;
        uint8 partnercount;
        uint8 maxlevel;
        uint autopoolbonus;
        uint directbonus;
        uint levelbonus1;
        uint levelbonus2to6;
        uint fourthbonus;
        uint fifthbonus;
        mapping(uint8 => address[]) partners;
        mapping(uint8 => uint[]) E5Matrix;
        mapping(uint8 => bool) activeE3Levels;
        mapping(uint8 => Ref) referrals;
        mapping(uint8 => E3) E3Matrix;
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

    struct M4info{
        uint8 matrix;
        uint8 mxlvl;
        uint8 mxrety;
        uint topid;
        uint newid;
        uint benid;
        uint botid;
    }
    mapping(address => User) public users;
    mapping(uint8 => M4User) public M4users;
    mapping(uint => address) public userIds;
    mapping(address => uint) public balances; 
    mapping(uint8 => uint[]) public L5Matrix;
    mapping(address => LevelIncomeReport[]) public LevelIncomeTransactions;
    
    uint public lastUserId = 2;
    uint8 public constant LAST_LEVEL = 13;
    address public owner;
    uint8[14] private rentmatrx = [0,1,1,1,1,2,4,2,2,2,2,2,3,3];
    uint8[14] private rentids = [0,1,1,2,0,1,1,2,2,4,4,4,1,2];
    uint[5] public matrixbenefit = [0,0.005 ether,0.1 ether,5 ether,0.2 ether];
    uint[14] public matrixprice = [0,0.005 ether,0.01 ether,0.02 ether,0.04 ether,0.10 ether,0.20 ether,0.40 ether,0.80 ether,1.60 ether,3.20 ether,6.40 ether,12.80 ether,25.60 ether];
    
   
    event Registration(address indexed user, address indexed referrer, uint indexed userId, uint referrerId);
    event BuyNew(address indexed user, uint8 indexed level);
    event Payout(address indexed sender,address indexed receiver,uint indexed dividend,uint userid,uint refid,uint8 matrix,uint8 level,uint recid,uint renty);

    constructor(address ownerAddress) public {
        
        owner = ownerAddress;
        User memory user = User({
            id: 1,
            referrer: address(0),
            partnercount : 0,
            autopoolbonus : 0,
            directbonus : 0,
            levelbonus1 : 0,
            levelbonus2to6 : 0,
            fourthbonus : 0,
            fifthbonus : 0,
            maxlevel : 13
        });
                
        users[ownerAddress] = user;
        userIds[1] = ownerAddress;
        
        for (uint8 i = 1; i <= LAST_LEVEL; i++) {
            users[ownerAddress].activeE3Levels[i] = true;
        }
        
        M4Matrix memory m4matrix = M4Matrix({
            id: 1,
            useraddress:owner,
            upline:0,
            partnercount:0,
            partnerdata:0,
            reentry:0
        });
        
        M4User memory m4user = M4User({
            level: 1
        });
        
        for (uint8 i = 1; i <= 5; i++) {
            users[ownerAddress].E5Matrix[i].push(1);
            L5Matrix[i].push(1);
            M4users[i] = m4user;
            M4users[i].M4[1]=m4matrix;
        }

    }
    
    function() external payable {
        if(msg.data.length == 0) {
            return registration(msg.sender, owner);
        }
        
        registration(msg.sender, bytesToAddress(msg.data));
    }

    function registrationExt(address referrerAddress) external payable {
        registration(msg.sender, referrerAddress);
    }
    
    function registration(address userAddress, address referrerAddress) private {
        require(msg.value == (matrixprice[1] * 2), "registration cost 0.005 ether");
        require(!isUserExists(userAddress), "user exists");
        require(isUserExists(referrerAddress), "referrer not exists");
        
        uint32 size;
        assembly {
            size := extcodesize(userAddress)
        }
        require(size == 0, "cannot be a contract");
        
        User memory user = User({
            id: lastUserId,
            referrer: referrerAddress,
            partnercount :0,
            maxlevel:1,
            autopoolbonus : 0,
            directbonus : 0,
            levelbonus1 : 0,
            levelbonus2to6 : 0,
            fourthbonus : 0,
            fifthbonus : 0 
        });
        
        users[userAddress] = user;
        users[userAddress].referrer = referrerAddress;
        users[userAddress].activeE3Levels[1] = true; 
        
        userIds[lastUserId] = userAddress;
        
        users[referrerAddress].partners[0].push(userAddress);
        users[referrerAddress].referrals[0].referrals.push(userAddress);
        users[referrerAddress].partnercount++;
        lastUserId++;
        emit Registration(userAddress, referrerAddress, users[userAddress].id, users[referrerAddress].id);
        updateM4Matrix(userAddress,1);
        distributebonus(userAddress,referrerAddress,1);        
    }
 
    function buyNewLevel(uint8 level) external payable {
        require(isUserExists(msg.sender), "user is not exists. Register first.");
        require(msg.value == (matrixprice[level]), "invalid price");
        require(level > 1 && level <= LAST_LEVEL, "invalid level");
        require(!users[msg.sender].activeE3Levels[level], "level already activated");

        BuyM4Matrix(msg.sender,level);
    }
    
    function BuyM4Matrix(address userAddress, uint8 level) private {
        if (users[userAddress].E3Matrix[level-1].blocked) {
            users[userAddress].E3Matrix[level-1].blocked = false;
        }
        address freeD3Referrer = findFreeD3Referrer(msg.sender, level);
        users[userAddress].E3Matrix[level].currentReferrer = freeD3Referrer;
        users[userAddress].activeE3Levels[level] = true;
        users[userAddress].maxlevel = level;

        distributebonus(userAddress,freeD3Referrer,level);
    }

     function distributebonus(address userAddress,address referrerAddress,uint8 level) private{        

        users[referrerAddress].E3Matrix[level].referrals.push(userAddress);
        uint reentry = users[referrerAddress].E3Matrix[level].reinvestCount;
        uint referral = users[referrerAddress].E3Matrix[level].referrals.length;
        uint reward = matrixprice[level];
        address upline;

       if(referral == 1){
          for(uint8 i=0;i<rentids[level];i++){
            reward -= matrixbenefit[rentmatrx[level]];
            updateM4Matrix(referrerAddress, rentmatrx[level]);
          }         
        
          if(users[referrerAddress].activeE3Levels[level]){
            emit Payout(userAddress,referrerAddress,reward,users[userAddress].id,users[referrerAddress].id,1,level,referral,reentry);
            transferAmount(referrerAddress,reward,5);
          }
          else{
            emit Payout(userAddress,referrerAddress,0,users[userAddress].id,users[referrerAddress].id,1,level,referral,reentry);
            address ref1 = findFreeD3Referrer(referrerAddress,level);
            emit Payout(referrerAddress,ref1,reward,users[referrerAddress].id,users[ref1].id,3,level,referral,0);
            transferAmount(ref1,reward,5);
          }
       }
       else if(referral==2){

         //Second Payout Sposor Get Full Amount  
         if(users[referrerAddress].activeE3Levels[level]){
            emit Payout(userAddress,referrerAddress,reward,users[userAddress].id,users[referrerAddress].id,1,level,referral,reentry);
            transferAmount(referrerAddress,reward,2);
         }
         else{
            emit Payout(userAddress,referrerAddress,0,users[userAddress].id,users[referrerAddress].id,1,level,referral,reentry);
            address ref1 = findFreeD3Referrer(referrerAddress,level);           
            emit Payout(ref1,referrerAddress,reward,users[ref1].id,users[referrerAddress].id,3,level,referral,0);            
            transferAmount(ref1,reward,2);
         }        

       }
       else if(referral == 3){
         reward = (reward*50)/100; //sponsorComm
         uint256 uplinesComm = (matrixprice[level]*10)/100;
         
         //level 1 || direct referral        
            if(users[referrerAddress].activeE3Levels[level]){
                emit Payout(userAddress,referrerAddress,reward,users[userAddress].id,users[referrerAddress].id,1,level,referral,reentry);
                transferAmount(referrerAddress,reward,3);
                upline = referrerAddress;
            }
            else{
                emit Payout(userAddress,referrerAddress,0,users[userAddress].id,users[referrerAddress].id,1,level,referral,reentry);
                address ref1 = findFreeD3Referrer(referrerAddress,level);           
                emit Payout(userAddress,ref1,reward,users[userAddress].id,users[ref1].id,3,level,referral,0);
                transferAmount(ref1,reward,3);
                upline = ref1;
            }  
          
         address recipient = upline;

         for (uint8 i = 2; i <= 6; i++) {
          if(users[recipient].referrer != address(0) && users[recipient].referrer != address(0x0)){
            if (users[users[recipient].referrer].activeE3Levels[level]) {

                LevelIncomeReport memory newLevelReport = LevelIncomeReport({ 
                   fromid: users[userAddress].id,
                   fromaddress:userAddress,   
                   slot:level,
                   level:i,    
                   amount:uplinesComm,  
                   timestamp: block.timestamp,
                   types:1
                });
                LevelIncomeTransactions[users[recipient].referrer].push(newLevelReport);

                transferAmount(users[recipient].referrer,uplinesComm,6);
            }
            else{
                LevelIncomeReport memory newLevelReport = LevelIncomeReport({ 
                   fromid: users[userAddress].id,
                   fromaddress:userAddress,   
                   slot:level,
                   level:i,    
                   amount:uplinesComm,  
                   timestamp: block.timestamp,
                   types:2 // lapsed level income
                });
                LevelIncomeTransactions[owner].push(newLevelReport);

                transferAmount(owner,uplinesComm,6);     
            }
          }
          else{
            LevelIncomeReport memory newLevelReport = LevelIncomeReport({ 
                fromid: users[userAddress].id,
                fromaddress:userAddress,   
                slot:level,
                level:i,    
                amount:uplinesComm,  
                timestamp: block.timestamp,
                types:2 // lapsed level income
            });
            LevelIncomeTransactions[owner].push(newLevelReport);

            transferAmount(owner,uplinesComm,6);   
          }

          recipient = users[recipient].referrer;
         }  


       }
       else if(referral == 4){

            emit Payout(userAddress,referrerAddress,0,users[userAddress].id,users[referrerAddress].id,1,level,referral,reentry);       	
            
            users[referrerAddress].E3Matrix[level].referrals = new address[](0);
            
            if (!users[referrerAddress].activeE3Levels[level+1] && level != LAST_LEVEL) {
                users[referrerAddress].E3Matrix[level].blocked = true;
            }
            
            address freeReferrerAddress;
            if (referrerAddress != owner) {
                freeReferrerAddress = findFreeD3Referrer(referrerAddress, level);
            }else{
                freeReferrerAddress = owner;
            }
            if (users[referrerAddress].E3Matrix[level].currentReferrer != freeReferrerAddress) {
                users[referrerAddress].E3Matrix[level].currentReferrer = freeReferrerAddress;
            }
            users[referrerAddress].E3Matrix[level].reinvestCount++;

            distributebonus(referrerAddress,freeReferrerAddress,level);

       }              
    } 
    

    function updateM4Matrix(address userAddress, uint8 matrixlvl) private {
    
        
        M4info memory m4info;        
        
        m4info.matrix = 3;
        m4info.mxlvl  = 8; 
        m4info.mxrety = 4;
        
        m4info.newid = uint(L5Matrix[matrixlvl].length);
        m4info.newid = m4info.newid + 1;
        m4info.topid = setUpperLine5(m4info.newid,1,m4info.matrix);
        M4Matrix memory m4matrix = M4Matrix({
            id: m4info.newid,
            useraddress:userAddress,
            upline:m4info.topid,
            partnercount:0,
            partnerdata:0,
            reentry:0
        });
        
        L5Matrix[matrixlvl].push(users[userAddress].id);
        users[userAddress].E5Matrix[matrixlvl].push(m4info.newid);
        M4users[matrixlvl].M4[m4info.newid]=m4matrix;
        M4users[matrixlvl].M4[m4info.topid].partnercount++;
        
        uint8 pos = M4users[matrixlvl].M4[m4info.topid].partnercount;
        uint8 lvl = 0;
        address benaddress;
        bool flag;
        uint numcount =1;
    
        
        flag = true;
        
        while(flag){
            lvl++;
            m4info.topid = setUpperLine5(m4info.newid,lvl,m4info.matrix);
            pos = 0;
        
			if(m4info.topid > 0){
			    
				if(lvl == m4info.mxlvl){
					m4info.benid = m4info.topid;
					flag = false;
				}else{
				    m4info.botid = setDownlineLimit(m4info.topid,lvl,m4info.matrix);
			    
				    //emit D5NewId(newid,topid,botid,position,numcount);
					if(m4info.newid == m4info.botid){
						pos = 1;
					}else{
					   
			    
						for (uint8 i = 1; i <= m4info.matrix; i++) {
				
							if(m4info.newid < (m4info.botid + (numcount * i))){
								pos = i;
								i = m4info.matrix;
							}
						}
						
					}
		            
					if(pos == 2){
						m4info.benid = m4info.topid;
						flag = false;
					}
                    
				}
				

			//	lvl++;
			numcount = numcount * m4info.matrix;
			}else{
				m4info.benid =0;
				flag = false;
			}
		}
        
		if(m4info.benid > 0){
		    if((lvl >= 3) && (lvl < m4info.mxlvl)){
		        numcount = numcount / m4info.matrix;
		        if(((m4info.botid + numcount) + m4info.mxrety) >= m4info.newid){
		            flag = true;
		 		}
				    
		    }
				
            if((lvl == m4info.mxlvl) && ((m4info.botid + m4info.mxrety) >= m4info.newid)){
                flag = true;
		    }
		}
		
		if(m4info.benid == 0){
		    m4info.benid =1; 
		    lvl = 0;
		}
    
        benaddress = M4users[matrixlvl].M4[m4info.benid].useraddress;

        if(flag){           
            updateM4Matrix(M4users[matrixlvl].M4[m4info.benid].useraddress,matrixlvl);
        }else{
            uint8 matrixlvl1 = matrixlvl +3;
            emit Payout(benaddress,benaddress,matrixbenefit[matrixlvl],users[benaddress].id,users[benaddress].id,matrixlvl1,lvl,m4info.benid,0);
           
            transferAmount(benaddress,matrixbenefit[matrixlvl],1);
          }
    }

    function findUnblockReferrer(address userAddress, uint8 level) private view returns(address) {
        while (!true) {
            if (users[users[userAddress].referrer].E3Matrix[level].blocked) {
                return users[userAddress].referrer;
            }
            userAddress = users[userAddress].referrer;
        }
    }
 
    function setUpperLine5(uint TrefId,uint8 level,uint8 matrix) internal pure returns(uint){
        
    	for (uint8 i = 1; i <= level; i++) {
    		if(TrefId == 1){
        		TrefId = 0;
    		}else if(TrefId == 0){
        		TrefId = 0;
    		}else if((1 < TrefId) && (TrefId < (matrix + 2))){
        		TrefId = 1;
			}else{
				TrefId -= 1;
				if((TrefId % matrix) > 0){
				TrefId = uint(TrefId / matrix);
				TrefId += 1;
				}else{
				TrefId = uint(TrefId / matrix);  
				}
				
			}	
    	}
    	return TrefId;
    }
    
    function setDownlineLimit(uint TrefId,uint8 level,uint8 matrix) internal pure returns(uint){
    	uint8 ded = 1;
		uint8 add = 2;
    	for (uint8 i = 1; i < level; i++) {
    		ded *= matrix;
			add += ded;
		}
		ded *= matrix;
		TrefId = ((ded * TrefId) - ded) + add;
    	return TrefId;
    }

    function isUserExists(address user) public view returns (bool) {
        return (users[user].id != 0);
    }

    function usersE3Matrix(address userAddress, uint8 level) public view returns(address, address[] memory, bool,uint) {
        return (users[userAddress].E3Matrix[level].currentReferrer,
                users[userAddress].E3Matrix[level].referrals,
                users[userAddress].E3Matrix[level].blocked,
                users[userAddress].E3Matrix[level].reinvestCount);
    }
    
    function usersD5Matrix(address userAddress,uint8 level) public view returns(uint, uint[] memory) {
        return (L5Matrix[level].length,users[userAddress].E5Matrix[level]);
    }
    
    function usersActiveE3Levels(address userAddress, uint8 level) public view returns(bool) {
        return users[userAddress].activeE3Levels[level];
    }
    
    function userspartner(address userAddress) public view returns(address[] memory) {
        return (users[userAddress].partners[0]);
    }

    function findFreeD3Referrer(address userAddress, uint8 level) private view returns(address) {
        while (true) {
            if (users[users[userAddress].referrer].activeE3Levels[level]) {
                return users[userAddress].referrer;
            }
            userAddress = users[userAddress].referrer;
        }
    }
    
    function transferAmount(address receiver,uint dividend,uint types) private {
        if(types==1){
           users[receiver].autopoolbonus+=dividend;
        }
        else if(types==2){
            users[receiver].directbonus+=dividend;
        }            
        else if(types==3){
            users[receiver].levelbonus1+=dividend;
        }
        else if(types==4){
            users[receiver].fourthbonus+=dividend;
        }
        else if(types==5){
            users[receiver].fifthbonus+=dividend;
        }
        else if(types==6){
            users[receiver].levelbonus2to6+=dividend;
        }

        if (!address(uint160(receiver)).send(dividend)) {
            return address(uint160(receiver)).transfer(address(this).balance);
        }        
    }
    
    function bytesToAddress(bytes memory bys) private pure returns (address addr) {
        assembly {
            addr := mload(add(bys, 20))
        }
    }
}