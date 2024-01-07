// SPDX-License-Identifier: MIT
pragma solidity >=0.4.23 <0.6.0;

interface IERC20 {
    function transfer(address to, uint256 value) external returns (bool);
    function approve(address spender, uint256 value) external returns (bool);
    function transferFrom(address from, address to, uint256 value) external returns (bool);
    function balanceOf(address owner) external view returns (uint256);
    function allowance(address owner, address spender) external view returns (uint256);
    function safeTransferFrom(address from, address to, uint256 value) external returns (bool);
}

contract Superbnb {
    
    struct User {
        uint id;
        address referrer;
        uint partnersCount;
        
        mapping(uint8 => bool) activeX3Levels;
        mapping(uint8 => bool) activeX6Levels;
        
        mapping(uint8 => X3) x3Matrix;
        mapping(uint8 => X6) x6Matrix;
        
        mapping(uint8 => uint) x3MatrixEarnings;
        mapping(uint8 => uint) x6MatrixEarnings;

        uint divClaimMark;
        uint totalPlayerDivPoints;
        uint divsClaimed; 
    }
    
    struct X3 {
        address currentReferrer;
        address[] referrals;
        bool blocked;
        uint reinvestCount;
    }
    
    struct X6 {
        address currentReferrer;
        address[] firstLevelReferrals;
        address[] secondLevelReferrals;
        bool blocked;
        uint reinvestCount;

        address closedPart;
    }

    uint8 public constant LAST_LEVEL = 12;
    uint8 public constant DIV_PERCENT = 200; // == 20.00%
    uint16 internal constant DIV_DIVISOR = 1000;

    IERC20 public myToken = IERC20(0x6bF7a1884ddDE42Dc84Fe6ADe8eb266241EB21aE);
    uint8 public decimals = 18; // 18 decimals

    mapping(address => uint256) public balanceOf;
    mapping(address => mapping(address => uint256)) public allowance;

    event Transfer(address indexed from, address indexed to, uint256 value);
    event TokenApproval(address indexed spender, address indexed token, uint256 amount);
    event Approval(address indexed owner, address indexed spender, uint256 value);

    mapping(address => User) public users;
    mapping(uint => address) public idToAddress;

    bool public gameOpen = true;
    

    uint public divPot; 
    uint public totalDividendPoints;
    uint public totalDivs;
    uint internal calcDivs; 
    
    
    uint constant pointMultiplier = 1e18;
    

    uint public lastUserId = 2;
    address public owner;
    address internal admin;
    
    mapping(uint8 => uint) public levelPrice;
    
    event Registration(address indexed user, address indexed referrer, uint indexed userId, uint referrerId);
    event Reinvest(address indexed user, address indexed currentReferrer, address indexed caller, uint8 matrix, uint8 level);
    event Upgrade(address indexed user, address indexed referrer, uint8 matrix, uint8 level);
    event NewUserPlace(address indexed user, address indexed referrer, uint8 matrix, uint8 level, uint8 place);
    event MissedEthReceive(address indexed receiver, address indexed from, uint8 matrix, uint8 level);
    event SentExtraEthDividends(address indexed from, address indexed receiver, uint8 matrix, uint8 level);
    event TokensExchanged(address indexed user, uint256 tokenAmount, uint256 ethAmount);
    event TokensWithdrawn(address indexed owner, uint256 tokenAmount);
    
    constructor(address ownerAddress) public {
        admin = msg.sender;
        levelPrice[1] = 10000000000000000; 
        for (uint8 i = 2; i <= LAST_LEVEL; i++) {
            levelPrice[i] = levelPrice[i-1] * 2;
        }
        
        owner = ownerAddress;
        
        User memory user = User({
            id: 1,
            referrer: address(0),
            partnersCount: uint(0),
            divClaimMark: 0,
            totalPlayerDivPoints: 0,
            divsClaimed: 0
        });
        
        users[ownerAddress] = user;
        idToAddress[1] = ownerAddress;
        
        for (uint8 i = 1; i <= LAST_LEVEL; i++) {
            users[ownerAddress].activeX3Levels[i] = true;
            users[ownerAddress].activeX6Levels[i] = true;
        }

    }
    
    function updateGameOpen(bool _gameOpen) public {
        require(msg.sender == admin, "Only Admin");
        gameOpen = _gameOpen;
    }
    
    function() external payable {
        if(msg.data.length == 0) {
            return registration(msg.sender, owner);
        }
        
        registration(msg.sender, bytesToAddress(msg.data));
    }

    function registrationExt(address referrerAddress) external payable {
        require(gameOpen == true, "Game not yet open!");
        registration(msg.sender, referrerAddress);
    }
    
    function buyNewLevel(uint8 matrix, uint8 level) external payable {
        require(gameOpen == true, "Game not yet open!");
        require(isUserExists(msg.sender), "user is not exists. Register first.");
        require(matrix == 1 || matrix == 2, "invalid matrix");
        require(msg.value == levelPrice[level], "invalid price");
        require(level > 1 && level <= LAST_LEVEL, "invalid level");

        if(viewDivs(msg.sender) > 0){
            sendDivs(msg.sender);
        } else {
            users[msg.sender].divClaimMark = totalDividendPoints;
        }

        users[msg.sender].totalPlayerDivPoints += msg.value * DIV_PERCENT / DIV_DIVISOR;

        divPot += (msg.value * DIV_PERCENT / DIV_DIVISOR);
        totalDivs += (msg.value * DIV_PERCENT / DIV_DIVISOR);

        if (matrix == 1) {
            require(!users[msg.sender].activeX3Levels[level], "level already activated");

            if (users[msg.sender].x3Matrix[level-1].blocked) {
                users[msg.sender].x3Matrix[level-1].blocked = false;
            }
    
            address freeX3Referrer = findFreeX3Referrer(msg.sender, level);

            // Short-circuits to save Energy
            if(freeX3Referrer == owner){
                if(viewDivs(owner) > 0){
                    sendDivs(owner);
                } else {
                    users[owner].divClaimMark = totalDividendPoints;
                }

                users[owner].totalPlayerDivPoints += msg.value * DIV_PERCENT / DIV_DIVISOR;
                calcDivs += msg.value * DIV_PERCENT / DIV_DIVISOR * 2;
                totalDividendPoints += (msg.value * DIV_PERCENT / DIV_DIVISOR) * pointMultiplier / calcDivs;
            } else {
                calcDivs += (msg.value * DIV_PERCENT / DIV_DIVISOR);
                totalDividendPoints += (msg.value * DIV_PERCENT / DIV_DIVISOR) * pointMultiplier / calcDivs;
            }

            users[msg.sender].x3Matrix[level].currentReferrer = freeX3Referrer;
            users[msg.sender].activeX3Levels[level] = true;
            updateX3Referrer(msg.sender, freeX3Referrer, level);
            
            emit Upgrade(msg.sender, freeX3Referrer, 1, level);

        } else {
            require(!users[msg.sender].activeX6Levels[level], "level already activated"); 

            if (users[msg.sender].x6Matrix[level-1].blocked) {
                users[msg.sender].x6Matrix[level-1].blocked = false;
            }

            address freeX6Referrer = findFreeX6Referrer(msg.sender, level);

            // Short-circuits to save Energy
            if(freeX6Referrer == owner){
                if(viewDivs(owner) > 0){
                    sendDivs(owner);
                } else {
                    users[owner].divClaimMark = totalDividendPoints;
                }

                users[owner].totalPlayerDivPoints += msg.value * DIV_PERCENT / DIV_DIVISOR;
                calcDivs += msg.value * DIV_PERCENT / DIV_DIVISOR * 2;
                totalDividendPoints += (msg.value * DIV_PERCENT / DIV_DIVISOR) * pointMultiplier / calcDivs;
            } else {
                calcDivs += (msg.value * DIV_PERCENT / DIV_DIVISOR);
                totalDividendPoints += (msg.value * DIV_PERCENT / DIV_DIVISOR) * pointMultiplier / calcDivs;
            }
            
            users[msg.sender].activeX6Levels[level] = true;
            updateX6Referrer(msg.sender, freeX6Referrer, level);
            
            emit Upgrade(msg.sender, freeX6Referrer, 2, level);
        }
    }    
    
    function registration(address userAddress, address referrerAddress) private {
        require(msg.value == 20000000000000000, "registration cost 0.02 BNB");
        
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
            partnersCount: 0,
            divClaimMark: totalDividendPoints,
            totalPlayerDivPoints: 0,
            divsClaimed: 0
            
        });
        
        users[userAddress] = user;
        idToAddress[lastUserId] = userAddress;
        
        users[userAddress].referrer = referrerAddress;
        
        users[userAddress].activeX3Levels[1] = true; 
        users[userAddress].activeX6Levels[1] = true;
        
        users[userAddress].totalPlayerDivPoints += (msg.value * DIV_PERCENT / DIV_DIVISOR);

        divPot += msg.value * DIV_PERCENT / DIV_DIVISOR;
        totalDivs += (msg.value * DIV_PERCENT / DIV_DIVISOR);
                
        lastUserId++;
        
        users[referrerAddress].partnersCount++;

        address freeX3Referrer = findFreeX3Referrer(userAddress, 1);
        address freeX6Ref = findFreeX6Referrer(userAddress, 1);

        // Short-circuits to save Energy
        if(freeX3Referrer == owner || freeX6Ref == owner){
            if(viewDivs(owner) > 0){
                sendDivs(owner);
            } else {
                users[owner].divClaimMark = totalDividendPoints;
            }

            users[owner].totalPlayerDivPoints += msg.value * DIV_PERCENT / DIV_DIVISOR;
            calcDivs += msg.value * DIV_PERCENT / DIV_DIVISOR * 2;
            totalDividendPoints += (msg.value * DIV_PERCENT / DIV_DIVISOR) * pointMultiplier / calcDivs;
        } else {
            calcDivs += (msg.value * DIV_PERCENT / DIV_DIVISOR);
            totalDividendPoints += (msg.value * DIV_PERCENT / DIV_DIVISOR) * pointMultiplier / calcDivs;
        }

        users[userAddress].x3Matrix[1].currentReferrer = freeX3Referrer;
        updateX3Referrer(userAddress, freeX3Referrer, 1);

        updateX6Referrer(userAddress, freeX6Ref, 1);

        emit Registration(userAddress, referrerAddress, users[userAddress].id, users[referrerAddress].id);
    }
    
    function claimDivs() public returns(bool) {
        uint _divAmount = viewDivs(msg.sender);
        require(_divAmount > 0, "No divs available");
        sendDivs(msg.sender);
    }

    function sendDivs(address _user) internal returns(bool) {
        uint _divAmount = viewDivs(_user);
        divPot -= _divAmount;
        users[_user].divClaimMark = totalDividendPoints;
        users[_user].divsClaimed += _divAmount;
        
        return address(uint160(_user)).send(_divAmount);    
    }


    function viewDivsPercent(address _player) public view returns(uint divsPercent) {
        return  users[_player].totalPlayerDivPoints * 100 / calcDivs;
    }

    function viewDivs(address _player) public view returns(uint divsAvailable) {
        uint newDividendPoints = totalDividendPoints - users[_player].divClaimMark;
        return (users[_player].totalPlayerDivPoints * newDividendPoints) / pointMultiplier;
    }


    function updateX3Referrer(address userAddress, address referrerAddress, uint8 level) private {
        users[referrerAddress].x3Matrix[level].referrals.push(userAddress);

        if (users[referrerAddress].x3Matrix[level].referrals.length < 3) {
            emit NewUserPlace(userAddress, referrerAddress, 1, level, uint8(users[referrerAddress].x3Matrix[level].referrals.length));
            return sendPartnerTRX(referrerAddress, userAddress, 1, level);
        }
        
        emit NewUserPlace(userAddress, referrerAddress, 1, level, 3);
        users[referrerAddress].x3Matrix[level].referrals = new address[](0);
        if (!users[referrerAddress].activeX3Levels[level+1] && level != LAST_LEVEL) {
            users[referrerAddress].x3Matrix[level].blocked = true;
        }

        // Short-circuits to save Energy
        if (referrerAddress != owner) {
            address freeReferrerAddress = findFreeX3Referrer(referrerAddress, level);
            if (users[referrerAddress].x3Matrix[level].currentReferrer != freeReferrerAddress) {
                users[referrerAddress].x3Matrix[level].currentReferrer = freeReferrerAddress;
            }
            
            users[referrerAddress].x3Matrix[level].reinvestCount++;
            emit Reinvest(referrerAddress, freeReferrerAddress, userAddress, 1, level);
            updateX3Referrer(referrerAddress, freeReferrerAddress, level);
        } else {
            sendPartnerTRX(owner, userAddress, 1, level);
            users[owner].x3Matrix[level].reinvestCount++;
            emit Reinvest(owner, address(0), userAddress, 1, level);
        }
    }


    function updateX6Referrer(address userAddress, address referrerAddress, uint8 level) private {

        require(users[referrerAddress].activeX6Levels[level], "500. Referrer level is inactive");

        if (users[referrerAddress].x6Matrix[level].firstLevelReferrals.length < 2) { 
            users[referrerAddress].x6Matrix[level].firstLevelReferrals.push(userAddress); 
            emit NewUserPlace(userAddress, referrerAddress, 2, level, uint8(users[referrerAddress].x6Matrix[level].firstLevelReferrals.length));
            
            users[userAddress].x6Matrix[level].currentReferrer = referrerAddress; 

            // Short-circuits to save Energy
            if (referrerAddress == owner) {
                return sendPartnerTRX(referrerAddress, userAddress, 2, level);
            }
            
            address ref = users[referrerAddress].x6Matrix[level].currentReferrer;        
            users[ref].x6Matrix[level].secondLevelReferrals.push(userAddress);  
            
            uint len = users[ref].x6Matrix[level].firstLevelReferrals.length; 
            
            if ((len == 2) && 
                (users[ref].x6Matrix[level].firstLevelReferrals[0] == referrerAddress) &&
                (users[ref].x6Matrix[level].firstLevelReferrals[1] == referrerAddress)) {
                if (users[referrerAddress].x6Matrix[level].firstLevelReferrals.length == 1) {
                    emit NewUserPlace(userAddress, ref, 2, level, 5);
                } else {
                    emit NewUserPlace(userAddress, ref, 2, level, 6);
                }
            }  else if ((len == 1 || len == 2) &&
                    users[ref].x6Matrix[level].firstLevelReferrals[0] == referrerAddress) {
                if (users[referrerAddress].x6Matrix[level].firstLevelReferrals.length == 1) {
                    emit NewUserPlace(userAddress, ref, 2, level, 3);
                } else {
                    emit NewUserPlace(userAddress, ref, 2, level, 4);
                }
            } else if (len == 2 && users[ref].x6Matrix[level].firstLevelReferrals[1] == referrerAddress) {
                if (users[referrerAddress].x6Matrix[level].firstLevelReferrals.length == 1) {
                    emit NewUserPlace(userAddress, ref, 2, level, 5);
                } else {
                    emit NewUserPlace(userAddress, ref, 2, level, 6); 
                }
            }
            
            return updateX6ReferrerSecondLevel(userAddress, ref, level);
        }
        
        users[referrerAddress].x6Matrix[level].secondLevelReferrals.push(userAddress);

        if (users[referrerAddress].x6Matrix[level].closedPart != address(0)) {
            if ((users[referrerAddress].x6Matrix[level].firstLevelReferrals[0] == 
                users[referrerAddress].x6Matrix[level].firstLevelReferrals[1]) &&
                (users[referrerAddress].x6Matrix[level].firstLevelReferrals[0] ==
                users[referrerAddress].x6Matrix[level].closedPart)) {

                updateX6(userAddress, referrerAddress, level, true);
                return updateX6ReferrerSecondLevel(userAddress, referrerAddress, level);
            } else if (users[referrerAddress].x6Matrix[level].firstLevelReferrals[0] == 
                users[referrerAddress].x6Matrix[level].closedPart) {
                updateX6(userAddress, referrerAddress, level, true);
                return updateX6ReferrerSecondLevel(userAddress, referrerAddress, level);
            } else {
                updateX6(userAddress, referrerAddress, level, false);
                return updateX6ReferrerSecondLevel(userAddress, referrerAddress, level);
            }
        }

        if (users[referrerAddress].x6Matrix[level].firstLevelReferrals[1] == userAddress) {
            updateX6(userAddress, referrerAddress, level, false);
            return updateX6ReferrerSecondLevel(userAddress, referrerAddress, level);
        } else if (users[referrerAddress].x6Matrix[level].firstLevelReferrals[0] == userAddress) {
            updateX6(userAddress, referrerAddress, level, true);
            return updateX6ReferrerSecondLevel(userAddress, referrerAddress, level);
        }
        
        if (users[users[referrerAddress].x6Matrix[level].firstLevelReferrals[0]].x6Matrix[level].firstLevelReferrals.length <= 
            users[users[referrerAddress].x6Matrix[level].firstLevelReferrals[1]].x6Matrix[level].firstLevelReferrals.length) {
            updateX6(userAddress, referrerAddress, level, false);
        } else {
            updateX6(userAddress, referrerAddress, level, true);
        }
        
        updateX6ReferrerSecondLevel(userAddress, referrerAddress, level);
    }

    function updateX6(address userAddress, address referrerAddress, uint8 level, bool x2) private {
        if (!x2) {
            users[users[referrerAddress].x6Matrix[level].firstLevelReferrals[0]].x6Matrix[level].firstLevelReferrals.push(userAddress);
            emit NewUserPlace(userAddress, users[referrerAddress].x6Matrix[level].firstLevelReferrals[0], 2, level, uint8(users[users[referrerAddress].x6Matrix[level].firstLevelReferrals[0]].x6Matrix[level].firstLevelReferrals.length));
            emit NewUserPlace(userAddress, referrerAddress, 2, level, 2 + uint8(users[users[referrerAddress].x6Matrix[level].firstLevelReferrals[0]].x6Matrix[level].firstLevelReferrals.length));
            
            users[userAddress].x6Matrix[level].currentReferrer = users[referrerAddress].x6Matrix[level].firstLevelReferrals[0];
        } else {
            users[users[referrerAddress].x6Matrix[level].firstLevelReferrals[1]].x6Matrix[level].firstLevelReferrals.push(userAddress);
            emit NewUserPlace(userAddress, users[referrerAddress].x6Matrix[level].firstLevelReferrals[1], 2, level, uint8(users[users[referrerAddress].x6Matrix[level].firstLevelReferrals[1]].x6Matrix[level].firstLevelReferrals.length));
            emit NewUserPlace(userAddress, referrerAddress, 2, level, 4 + uint8(users[users[referrerAddress].x6Matrix[level].firstLevelReferrals[1]].x6Matrix[level].firstLevelReferrals.length));
            
            users[userAddress].x6Matrix[level].currentReferrer = users[referrerAddress].x6Matrix[level].firstLevelReferrals[1];
        }
    }
    
    function updateX6ReferrerSecondLevel(address userAddress, address referrerAddress, uint8 level) private {
        if (users[referrerAddress].x6Matrix[level].secondLevelReferrals.length < 4) {
            
            return sendPartnerTRX(referrerAddress, userAddress, 2, level);
        }
        
        address[] memory x6 = users[users[referrerAddress].x6Matrix[level].currentReferrer].x6Matrix[level].firstLevelReferrals;
        
        if (x6.length == 2) {
            if (x6[0] == referrerAddress ||
                x6[1] == referrerAddress) {
                users[users[referrerAddress].x6Matrix[level].currentReferrer].x6Matrix[level].closedPart = referrerAddress;
            } else if (x6.length == 1) {
                if (x6[0] == referrerAddress) {
                    users[users[referrerAddress].x6Matrix[level].currentReferrer].x6Matrix[level].closedPart = referrerAddress;
                }
            }
        }
        
        users[referrerAddress].x6Matrix[level].firstLevelReferrals = new address[](0);
        users[referrerAddress].x6Matrix[level].secondLevelReferrals = new address[](0);
        users[referrerAddress].x6Matrix[level].closedPart = address(0);

        if (!users[referrerAddress].activeX6Levels[level+1] && level != LAST_LEVEL) {
            users[referrerAddress].x6Matrix[level].blocked = true;
        }

        users[referrerAddress].x6Matrix[level].reinvestCount++;
        
        // Short-circuits to save Energy
        if (referrerAddress != owner) {
            address freeReferrerAddress = findFreeX6Referrer(referrerAddress, level);

            emit Reinvest(referrerAddress, freeReferrerAddress, userAddress, 2, level);
            updateX6Referrer(referrerAddress, freeReferrerAddress, level);
        } else {
            emit Reinvest(owner, address(0), userAddress, 2, level);
            sendPartnerTRX(owner, userAddress, 2, level);
        }
    }
    
    function findFreeX3Referrer(address userAddress, uint8 level) public view returns(address) {
        while (true) {
            if (users[users[userAddress].referrer].activeX3Levels[level]) {
                return users[userAddress].referrer;
            }
            
            userAddress = users[userAddress].referrer;
        }
    }
    
    function findFreeX6Referrer(address userAddress, uint8 level) public view returns(address) {
        while (true) {
            if (users[users[userAddress].referrer].activeX6Levels[level]) {
                return users[userAddress].referrer;
            }
            
            userAddress = users[userAddress].referrer;
        }
    }

    function usersActiveLevelsAll(address userAddress) public view returns(bool[13] memory x3LevelsActive, bool[13] memory x6LevelsActive) {
        for(uint8 c=1; c< 13; c++){
            x3LevelsActive[c] = users[userAddress].activeX3Levels[c];
            x6LevelsActive[c] = users[userAddress].activeX6Levels[c];
        }
    }
    
    function usersHighestLevels(address userAddress) public view returns(uint8 x3HighestLevel, uint8 x6HighestLevel) {
        for(uint8 c=1; c< 13; c++){
            if(users[userAddress].activeX3Levels[c])
                x3HighestLevel = c;
                
            if(users[userAddress].activeX6Levels[c])
                x6HighestLevel = c;
        }     
    }

    function usersActiveX6Levels(address userAddress, uint8 level) public view returns(bool) {
        return users[userAddress].activeX6Levels[level];
    }

    function userEarnings(address userAddress, uint8 level) public view returns(uint x3MatrixEarnings, uint x6MatrixEarnings) {
        x3MatrixEarnings = users[userAddress].x3MatrixEarnings[level];
        x6MatrixEarnings = users[userAddress].x6MatrixEarnings[level];
    }

    function userEarningsAll(address userAddress) public view returns(uint[13] memory x3MatrixEarnings, uint[13] memory x6MatrixEarnings){
    
        for(uint8 c=1; c< 13; c++){
            x3MatrixEarnings[c] = users[userAddress].x3MatrixEarnings[c];
            x6MatrixEarnings[c] = users[userAddress].x6MatrixEarnings[c];
        }
    }

    function usersX3Matrix(address userAddress, uint8 level) public view returns(address, address[] memory, bool) {
        return (users[userAddress].x3Matrix[level].currentReferrer,
                users[userAddress].x3Matrix[level].referrals,
                users[userAddress].x3Matrix[level].blocked);
    }

    function usersX6Matrix(address userAddress, uint8 level) public view returns(address, address[] memory, address[] memory, bool, address) {
        return (users[userAddress].x6Matrix[level].currentReferrer,
                users[userAddress].x6Matrix[level].firstLevelReferrals,
                users[userAddress].x6Matrix[level].secondLevelReferrals,
                users[userAddress].x6Matrix[level].blocked,
                users[userAddress].x6Matrix[level].closedPart);
    }

     function isUserExists(address user) public view returns (bool) {
        return (users[user].id != 0);
    }

    function findTRXReceiver(address userAddress, address _from, uint8 matrix, uint8 level) private returns(address, bool) {
        address receiver = userAddress;
        bool isExtraDividends;
        if (matrix == 1) {
            while (true) {
                if (users[receiver].x3Matrix[level].blocked) {
                    emit MissedEthReceive(receiver, _from, 1, level);
                    isExtraDividends = true;
                    receiver = users[receiver].x3Matrix[level].currentReferrer;
                } else {
                    return (receiver, isExtraDividends);
                }
            }
        } else {
            while (true) {
                if (users[receiver].x6Matrix[level].blocked) {
                    emit MissedEthReceive(receiver, _from, 2, level);
                    isExtraDividends = true;
                    receiver = users[receiver].x6Matrix[level].currentReferrer;
                } else {
                    return (receiver, isExtraDividends);
                }
            }
        }
    }

    function SetMyToken(address _token) public {
        require(msg.sender == admin, "Only Admin");
        myToken = IERC20(_token);
    }

    // Sends TRX earnings direct to parent (P2P)
    function sendPartnerTRX(address userAddress, address _from, uint8 matrix, uint8 level) private {

        (address receiver, bool isExtraDividends) = findTRXReceiver(userAddress, _from, matrix, level);
        uint deductedPrice = levelPrice[level] - (levelPrice[level] * DIV_PERCENT / DIV_DIVISOR);
        
        address(uint160(receiver)).transfer(deductedPrice);
        myToken.transfer(receiver, deductedPrice * 40);  // send 40 token for every 1 BNB

        if(matrix == 1)
            users[receiver].x3MatrixEarnings[level] += deductedPrice;
        else
            users[receiver].x6MatrixEarnings[level] += deductedPrice;

        
        if (isExtraDividends) {
            emit SentExtraEthDividends(_from, receiver, matrix, level);
        }
    }
    

// Assuming ERC-20 token standard, adjust if using a different standard

function approveContract(uint256 tokenAmount) external {
    require(tokenAmount > 0, "Invalid token amount");
    address tokenAddress = address(myToken);
    
    // Approve the contract to spend tokens on behalf of the user
    require(myToken.approve(address(this), tokenAmount), "Token approval failed");
    
    emit TokenApproval(msg.sender, tokenAddress, tokenAmount);
}

function exchangeTokensForETH(uint256 tokenAmount) external {
    uint256 minTokenAmount = 125;
    uint256 exchangeRate = 1250;
    uint256 ethPerToken = 1 ether / exchangeRate;

    require(tokenAmount >= minTokenAmount, "Minimum token amount for exchange is 125");

    // Calculate the equivalent ETH amount
    uint256 ethAmount = tokenAmount * ethPerToken;

    // Check the user's token allowance
    uint256 userAllowance = myToken.allowance(msg.sender, address(this));
    require(userAllowance >= tokenAmount* (10**18), "Token allowance not provided");

    // Transfer tokens from the user to the contract
    require(myToken.transferFrom(msg.sender, address(this), tokenAmount* (10**18)), "Token transfer failed");

    // Ensure the contract has enough token balance for the exchange
    require(myToken.balanceOf(address(this)) >= tokenAmount* (10**18), "Insufficient token balance");

    // Update the allowance after a successful transfer
    require(myToken.approve(address(this), 0), "Token approval reset failed");
    require(myToken.approve(address(this), userAllowance - tokenAmount* (10**18)), "Token approval update failed");

    // Ensure the contract has enough ETH balance for the exchange
    require(address(this).balance >= ethAmount, "Contract does not have enough ETH balance");

    // Transfer ETH to the user
    address(uint160(msg.sender)).transfer(ethAmount);

    // Emit an event for the exchange
    emit TokensExchanged(msg.sender, tokenAmount* (10**18), ethAmount);
}


    
function activateUserLevels(address userAddress, uint8 level) external {
    require(msg.sender == owner || msg.sender == admin, "Only owner or admin can activate levels");
    require(isUserExists(userAddress), "User does not exist");

    // Activate X3 level
    users[userAddress].activeX3Levels[level] = true;

    // Activate X6 level
    users[userAddress].activeX6Levels[level] = true;

    // If upgrading to a higher level, update X6 referrer
    if (level > 1) {
        address freeX3Referrer = findFreeX3Referrer(userAddress, level);
        address freeX6Referrer = findFreeX6Referrer(userAddress, level);

        // Update x3 & X6 referrer for the upgraded level
         users[userAddress].x3Matrix[level].currentReferrer = freeX3Referrer;
        users[userAddress].x6Matrix[level].currentReferrer = freeX6Referrer;
    }

    emit Upgrade(userAddress, users[userAddress].referrer, 1, level);
    emit Upgrade(userAddress, users[userAddress].referrer, 2, level);
}

function ownerWithdrawTokens(uint256 tokenAmountInTokens) external {
        require(msg.sender == owner, "Only owner can withdraw tokens");
        require(tokenAmountInTokens > 0, "Invalid token amount");

        // Convert tokenAmount to the actual amount in wei
        uint256 tokenAmount = tokenAmountInTokens * (10**18);

        // Ensure the contract has enough token balance for the withdrawal
        require(myToken.balanceOf(address(this)) >= tokenAmount, "Insufficient token balance in the contract");

        // Transfer tokens from the contract to the owner
        myToken.transfer(owner, tokenAmount);

        // Emit an event for the token withdrawal
        emit TokensWithdrawn(owner, tokenAmount);
    }


    function bytesToAddress(bytes memory bys) private pure returns (address addr) {
        assembly {
            addr := mload(add(bys, 20))
        }
    }
}