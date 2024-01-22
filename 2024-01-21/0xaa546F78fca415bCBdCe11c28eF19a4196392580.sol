pragma solidity >=0.4.23 <0.6.0;

interface IERC20 {
    function totalSupply() external view returns (uint256);

    function balanceOf(address account) external view returns (uint256);

    function transfer(address recipient, uint256 amount)
        external
        returns (bool);

    function allowance(address owner, address spender)
        external
        view
        returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);
}

contract Profiter {
    struct User {
        uint256 id;
        address user;
        uint256 referrer;
        address referreraddress;
        uint256 partnersCount;
        uint256 O3MaxLevel;
        uint256 O3Income;
        mapping(uint8 => bool) activeO3Levels;
        mapping(uint8 => O3) O3Matrix;
        bool royaltyEligible;
        uint40 joindate;
        uint256 affiliate;
        mapping(uint8 => Holdings[]) HoldLevel;
        uint256 O3Payouts;
        uint256 levelPayouts;
    }
    struct O3 {
        uint256 currentReferrer;
        uint256[] referrals;
    }
    struct Holdings {
        uint256 from;
        bool released;
    }
    uint8 public constant LAST_LEVEL = 18;
    mapping(uint256 => User) public users;
    mapping(address => uint256[]) public addresstoIds;
    mapping(uint256 => address) public idToAddress;
    mapping(address => uint256) public balances;
    IERC20 pusdContract = IERC20(0xeaC726373EFF7a1c2072c60838E4734D9e375EE7);
    IERC20 pepContract = IERC20(0x4F27Da3C0B36cCbF247712BcFdd3983A91Cc96b7);
    uint256 public lastUserId = 2;
    uint256 public totalearnedusdt = 0;
    address payable public owner;
    address payable public admin;
    bool public IsManualEnabled = false;

    mapping(uint8 => uint256) public levelPrice;
    mapping(uint8 => uint256) public nextlevelDeduction;

    mapping(uint256 => uint256) public idByAffiliate;

    event Registration(
        uint256 indexed user,
        uint256 indexed referrer,
        uint256 time,
        uint256 referredby,
        uint8 teamlevel
    );
    event Upgrade(
        uint256 indexed user,
        uint256 indexed referrer,
        uint8 matrix,
        uint8 level,
        uint256 time
    );
    event NewUserPlace(
        uint256 indexed user,
        uint256 indexed userId,
        uint256 indexed referrer,
        uint256 referrerId,
        uint8 matrix,
        uint8 level,
        uint8 place,
        uint256 time,
        uint8 partnerType
    );
    event SentDividends(
        uint256 indexed from,
        uint256 indexed fromId,
        uint256 indexed receiver,
        uint256 receiverId,
        uint8 matrix,
        uint8 level,
        uint256 time
    );
    event LevelPayout(
        uint256 indexed from,
        uint256 indexed fromId,
        uint256 indexed receiver,
        uint256 receiverId,
        uint8 platform,
        uint8 level,
        uint256 time,
        uint256 amount
    );

    constructor(address payable ownerAddress, address payable _admin) public {
        levelPrice[1] = 3.72 ether;
        levelPrice[2] = 5 ether;
        levelPrice[3] = 8 ether;
        levelPrice[4] = 12 ether;
        levelPrice[5] = 20 ether;
        levelPrice[6] = 35 ether;
        levelPrice[7] = 65 ether;
        levelPrice[8] = 120 ether;
        levelPrice[9] = 210 ether;
        levelPrice[10] = 380 ether;
        levelPrice[11] = 700 ether;
        levelPrice[12] = 1300 ether;
        levelPrice[13] = 2400 ether;
        levelPrice[14] = 4500 ether;
        levelPrice[15] = 8500 ether;
        levelPrice[16] = 16000 ether;
        levelPrice[17] = 30000 ether;
        levelPrice[18] = 55000 ether;

        nextlevelDeduction[1] = 0.5 ether;
        nextlevelDeduction[2] = 1 ether;
        nextlevelDeduction[3] = 2 ether;
        nextlevelDeduction[4] = 2 ether;
        nextlevelDeduction[5] = 2.5 ether;
        nextlevelDeduction[6] = 2.5 ether;
        nextlevelDeduction[7] = 5 ether;
        nextlevelDeduction[8] = 15 ether;
        nextlevelDeduction[9] = 20 ether;
        nextlevelDeduction[10] = 30 ether;
        nextlevelDeduction[11] = 50 ether;
        nextlevelDeduction[12] = 100 ether;
        nextlevelDeduction[13] = 150 ether;
        nextlevelDeduction[14] = 250 ether;
        nextlevelDeduction[15] = 500 ether;
        nextlevelDeduction[16] = 1000 ether;
        nextlevelDeduction[17] = 2500 ether;
        nextlevelDeduction[18] = 55000 ether;
        owner = ownerAddress;
        admin = _admin;
        uint256 affiliate = generateUniqueIdentifier(ownerAddress);
        idByAffiliate[affiliate] = 1;
        User memory user = User({
            id: 1,
            user: ownerAddress,
            referrer: 0,
            referreraddress: address(0),
            partnersCount: uint256(0),
            O3MaxLevel: uint256(0),
            O3Income: uint8(0),
            royaltyEligible: false,
            joindate: uint40(block.timestamp),
            affiliate: affiliate,
            O3Payouts: uint8(0),
            levelPayouts: uint8(0)
        });
        users[1] = user;
        addresstoIds[ownerAddress].push(1);
        idToAddress[1] = ownerAddress;
        users[1].activeO3Levels[1] = true;
        users[1].O3MaxLevel = 1;
    }

    function() external payable {
        if (msg.data.length == 0) {
            return registration(msg.sender, owner, false);
        }
        registration(msg.sender, bytesToAddress(msg.data), false);
    }

    function registrationExt(address referrerAddress) external payable {
        registration(msg.sender, referrerAddress, false);
    }

    function _buyNewLevel(
        uint256 _user,
        uint8 matrix,
        uint8 level
    ) internal {
        require(matrix == 1, "invalid matrix");
        require(level > 1 && level <= LAST_LEVEL, "invalid level");
        if (matrix == 1) {
            require(
                !users[_user].activeO3Levels[level],
                "level already activated"
            );
            require(
                users[_user].activeO3Levels[level - 1],
                "previous level should be activated"
            );
            users[_user].O3MaxLevel = level;
            users[_user].O3Matrix[level].currentReferrer = users[_user]
                .O3Matrix[1]
                .currentReferrer;
            users[_user].activeO3Levels[level] = true;
            updateO3Referrer(
                _user,
                users[_user].O3Matrix[1].currentReferrer,
                level,
                false
            );
            totalearnedusdt = totalearnedusdt + levelPrice[level];
            if (users[_user].HoldLevel[level].length > 0) {
                for (
                    uint256 i = 0;
                    i < users[_user].HoldLevel[level].length;
                    i++
                ) {
                    Holdings memory _hold = users[_user].HoldLevel[level][i];
                    if (!_hold.released) {
                        sendusdtDividends(_user, _hold.from, 1, level, false);
                        users[_user].HoldLevel[level][i].released = true;
                    }
                }
            }
            emit Upgrade(
                _user,
                users[_user].O3Matrix[1].currentReferrer,
                1,
                level,
                block.timestamp
            );
            if (level == 6) {
                if (_user == 1) registration(users[_user].user, owner, true);
                else if (_user > 1) {
                    registration(
                        users[_user].user,
                        users[_user].referreraddress,
                        true
                    );
                }
            }
        }
    }

    function generateUniqueIdentifier(address _user)
        private
        view
        returns (uint256)
    {
        uint256 uniqueId = uint256(
            keccak256(abi.encodePacked(block.timestamp, _user, lastUserId))
        );
        return uniqueId % 10**15;
    }

    function registration(
        address userAddress,
        address referrerAddress,
        bool isReinvest
    ) private {
        if (!isReinvest) {
            require(
                pusdContract.balanceOf(msg.sender) >= levelPrice[1],
                "registration cost 3.72 pusd"
            );
            require(!isUserExists(userAddress), "user exists");
            require(isUserExists(referrerAddress), "referrer not exists");
            uint256 registerprice = levelPrice[1];
            require(
                pusdContract.transferFrom(
                    msg.sender,
                    address(this),
                    registerprice
                ),
                "Payment failed"
            );
        }
        uint32 size;
        assembly {
            size := extcodesize(userAddress)
        }
        require(size == 0, "cannot be a contract");
        uint256[] memory ids = addresstoIds[referrerAddress];
        uint256 affiliate = generateUniqueIdentifier(msg.sender);
        idByAffiliate[affiliate] = lastUserId;
        User memory user = User({
            id: lastUserId,
            user: userAddress,
            referrer: ids[ids.length - 1],
            referreraddress: referrerAddress,
            partnersCount: 0,
            O3MaxLevel: 1,
            O3Income: 0,
            royaltyEligible: false,
            joindate: uint40(block.timestamp),
            affiliate: affiliate,
            O3Payouts: uint8(0),
            levelPayouts: uint8(0)
        });
        users[lastUserId] = user;
        addresstoIds[userAddress].push(lastUserId);
        idToAddress[lastUserId] = userAddress;
        users[lastUserId].referreraddress = referrerAddress;
        users[lastUserId].referrer = ids[0];
        users[lastUserId].activeO3Levels[1] = true;
        totalearnedusdt = totalearnedusdt + levelPrice[1];
        users[ids[0]].partnersCount++;
        if (uint40(block.timestamp) <= users[ids[0]].joindate + 30 days) {
            if (users[ids[0]].partnersCount >= 2) {
                users[ids[0]].royaltyEligible = true;
            }
        }
        uint256 freeTwoReferrer = findO3Referrer(ids[ids.length - 1], 1);
        users[lastUserId].O3Matrix[1].currentReferrer = freeTwoReferrer;
        lastUserId++;
        require(
            users[freeTwoReferrer].O3Matrix[1].referrals.length < 2,
            "Referrer invalid"
        );
        updateO3Referrer(lastUserId - 1, freeTwoReferrer, 1, true);
        uint256 _ref = ids[0];
        uint8 count = 1;
        while (count <= 9) {
            if (_ref == 0) {
                break;
            }
            emit Registration(
                lastUserId - 1,
                _ref,
                block.timestamp,
                ids[0],
                count
            );
            _ref = users[_ref].referrer;
            count++;
        }
        if (
            lastUserId - 1 <= 100000 &&
            pepContract.balanceOf(address(this)) >= 100 ether
        ) {
            pepContract.transfer(userAddress, 100 ether);
        }
        pusdContract.transfer(admin, 0.42 ether);
    }

    function updateO3Referrer(
        uint256 userAddress,
        uint256 referrerAddress,
        uint8 level,
        bool isRegistration
    ) private {
        uint8 partnerType;
        User memory _userdetail = users[userAddress];
        User memory _referrerdetail = users[referrerAddress];
        if (_userdetail.referrer != referrerAddress) {
            if (!users[_userdetail.referrer].activeO3Levels[level]) {
                partnerType = 4;
            } else if (_referrerdetail.id < users[_userdetail.referrer].id) {
                partnerType = 2;
            } else if (_referrerdetail.id > users[_userdetail.referrer].id) {
                partnerType = 3;
            }
        } else {
            partnerType = 1;
        }

        users[referrerAddress].O3Matrix[level].referrals.push(userAddress);
        emit NewUserPlace(
            userAddress,
            users[userAddress].id,
            referrerAddress,
            users[referrerAddress].id,
            1,
            level,
            uint8(users[referrerAddress].O3Matrix[level].referrals.length),
            block.timestamp,
            partnerType
        );
        if (users[referrerAddress].activeO3Levels[level] || referrerAddress == 0)
            sendusdtDividends(
                referrerAddress,
                userAddress,
                1,
                level,
                isRegistration && level == 1
            );
        else {
            Holdings memory _hold = Holdings({
                from: userAddress,
                released: false
            });
            users[referrerAddress].HoldLevel[level].push(_hold);
        }
    }

    function findO3Referrer(uint256 _user, uint8 level)
        public
        view
        returns (uint256)
    {
        if (users[_user].O3Matrix[level].referrals.length < 2) return _user;
        uint256[] memory referrals = new uint256[](30);
        referrals[0] = users[_user].O3Matrix[level].referrals[0];
        referrals[1] = users[_user].O3Matrix[level].referrals[1];
        uint256 freeReferrer = _user;
        for (uint256 i = 0; i < 30; i++) {
            if (users[referrals[i]].O3Matrix[level].referrals.length == 2) {
                if (i < 14) {
                    referrals[(i + 1) * 2] = users[referrals[i]]
                        .O3Matrix[level]
                        .referrals[0];
                    referrals[((i + 1) * 2) + 1] = users[referrals[i]]
                        .O3Matrix[level]
                        .referrals[1];
                }
            } else {
                freeReferrer = referrals[i];
                break;
            }
        }
        return freeReferrer;
    }

    function usersActiveO3Levels(uint256 userAddress, uint8 level)
        public
        view
        returns (bool)
    {
        return users[userAddress].activeO3Levels[level];
    }

    function get3XMatrix(uint256 userAddress, uint8 level)
        public
        view
        returns (uint256, uint256[] memory)
    {
        return (
            users[userAddress].O3Matrix[level].currentReferrer,
            users[userAddress].O3Matrix[level].referrals
        );
    }

    function isUserExists(address user) public view returns (bool) {
        uint256[] memory ids = addresstoIds[user];
        return ids.length > 0;
    }

    function affiliateByAddress(address _user) public view returns (uint256) {
        uint256[] memory ids = addresstoIds[_user];
        return users[ids[0]].affiliate;
    }

    function addressByAffiliate(uint256 _affiliate)
        public
        view
        returns (address)
    {
        return idToAddress[idByAffiliate[_affiliate]];
    }

    function affiliateById(uint8 _id) public view returns (uint256) {
        return users[_id].affiliate;
    }

    function sendusdtDividends(
        uint256 userAddress,
        uint256 _from,
        uint8 matrix,
        uint8 level,
        bool isRegistration
    ) private {
        uint256 payout = isRegistration
            ? levelPrice[level] - 0.72 ether
            : levelPrice[level];
        if (matrix == 1 && userAddress>0) {
            users[userAddress].O3Income += payout;
        }
        if(userAddress > 0){
            if (users[userAddress].O3MaxLevel <= level && level < LAST_LEVEL) {
                payout = nextlevelDeduction[level];
                if (users[userAddress].O3Matrix[level].referrals.length > 1) {
                    _buyNewLevel(userAddress, 1, level + 1);
                }
            }
        }
        if (payout > 0) {
            uint256 levelpayout = payout / 10;
            uint256 userpayout = payout - levelpayout;
            uint256 levelPerUser = levelpayout / 10;
            uint8 levels = 1;
            uint256 _user = userAddress;
            while (levels <= 9) {
                uint256 ref = users[_user].referrer;
                if (ref != 0 && users[ref].royaltyEligible) {
                    users[ref].O3Income += levelPerUser;
                    users[ref].levelPayouts += levelPerUser;
                    if (!pusdContract.transfer(users[ref].user, levelPerUser)) {
                        pusdContract.transfer(
                            users[ref].user,
                            pusdContract.balanceOf(address(this))
                        );
                    }
                    emit LevelPayout(
                        userAddress,
                        users[userAddress].id,
                        ref,
                        users[ref].id,
                        level,
                        levels,
                        uint40(block.timestamp),
                        levelPerUser
                    );
                } else if (ref == 0) {
                    if (!pusdContract.transfer(owner, levelPerUser)) {
                        pusdContract.transfer(
                            owner,
                            pusdContract.balanceOf(address(this))
                        );
                    }
                    emit LevelPayout(
                        userAddress,
                        users[userAddress].id,
                        1,
                        1,
                        level,
                        levels,
                        uint40(block.timestamp),
                        levelPerUser
                    );
                }
                _user = ref;
                levels++;
            }
            if (!pusdContract.transfer(admin, levelPerUser)) {
                pusdContract.transfer(
                    admin,
                    pusdContract.balanceOf(address(this))
                );
            }
            if(userAddress > 0){
                users[userAddress].O3Payouts += userpayout;
            }
            if (!pusdContract.transfer(users[userAddress == 0 ? 1 : userAddress].user, userpayout)) {
                pusdContract.transfer(
                    users[userAddress == 0 ? 1 : userAddress].user,
                    pusdContract.balanceOf(address(this))
                );
            }
        }
        emit SentDividends(
            _from,
            users[_from].id,
            userAddress == 0 ? 1 : userAddress,
            users[userAddress == 0 ? 1 : userAddress].id,
            matrix,
            level,
            block.timestamp
        );
    }

    function bytesToAddress(bytes memory bys)
        private
        pure
        returns (address addr)
    {
        assembly {
            addr := mload(add(bys, 20))
        }
    }

    function GetIdsByAddress(address _user)
        public
        view
        returns (uint256[] memory)
    {
        return addresstoIds[_user];
    }

    function GetHoldings(uint8 _user, uint8 level)
        public
        view
        returns (uint256[] memory)
    {
        Holdings[] memory _hold = users[_user].HoldLevel[level];
        uint256[] memory _holdings = new uint256[](_hold.length * 2);
        uint8 count = 0;
        for (uint8 i = 0; i < _hold.length; i++) {
            _holdings[count] = (_hold[i].from);
            _holdings[count + 1] = (_hold[i].released ? 1 : 0);
            count += 2;
        }
        return _holdings;
    }

    function safeWithdraw(uint256 amount) external {
        require(msg.sender == owner, "Permission Denied");
        owner.transfer(amount > address(this).balance ? address(this).balance : amount);
    }

    function safeWithdrawTokens(address contractAddress,uint256 amount) external {
        require(msg.sender == owner, "Permission Denied");
        IERC20 tokencontract = IERC20(contractAddress);
        tokencontract.transfer(owner, amount > tokencontract.balanceOf(address(this)) ? tokencontract.balanceOf(address(this)) : amount);
    }
}