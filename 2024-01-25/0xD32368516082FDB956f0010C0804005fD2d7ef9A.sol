// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

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

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
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

contract ZionexCommunity is ReentrancyGuard {
    address private tokenAddr =
        address(0x55d398326f99059fF775485246999027B3197955);
    address private zonAddr =
        address(0x926d397a5983ba587a92Ad5D2386e0370DaE43c8);
    IERC20 public token;
    IERC20 public ZON;

    bool public airdrop = true;
    uint256 public constant PERCENTS_DIVIDER = 10000;
    uint256 public constant ACTIVATE_PRICE = 60 ether;
    uint256 public constant REACTIVATE_PRICE = 60 ether;
    uint256 public constant DIRECT_COMMISSION = 6 ether;
    uint256 public constant tokenLiquidityPoolFee = 12 ether;
    uint256 public constant CommunityDevelopmentFee = 2 ether;
    uint256 public constant REFERRAL_COMMISSION = 10 ether;
    uint256 public constant DEACTIVATE_STEP = 120 ether;
    uint256 public constant MAX_COMMISSION_LEVEL = 4;
    uint256 public constant MAX_DIRECT_REFERRAL = 2;
    uint256 public MAX_SEARCH_ADDRESS = 600;
    uint256 public refPercent = 1000;
    uint256 public minBuyAmount = 50e18;
    uint256 public maxBuyAmount = 5000e18;

    struct User {
        uint256 id;
        uint256 joinDate;
        uint256 originReferrer;
        uint256 mainReferrer;
        uint256 currentProfit;
        uint256 totalIncome;
        uint256 downlineCount;
        uint256[] referral;
        uint256 reActivationAmount;
        uint256 totalMissedCommission;
        bool isbought;
        uint256 totalDirectCommission;
        uint256 missedDirectCommission;
        uint256[] totalReferralCommission;
        uint256[] missedCommission;
        uint256[] savedSearchArray;
        uint256 currentSearchIndex;
        uint256 reactivateCount;
    }

    mapping(address => User) public users;
    mapping(uint256 => address) public userList;

    uint256 public currentID = 1;

    uint256 public totalUsers;
    uint256 public totalActiveAmount;
    uint256 public totalReActiveAmount;
    uint256 public totalDirectReferralPaid;
    uint256 public totalDirectReferralMissed;
    uint256 public totalCommissionPaid;
    uint256 public totalCommissionMissed;
    address public liquidityPoolWallet;
    address public CommunityDevelopmentWallet;
    bool public initial;

    event Activate(address userAddress, uint256 indexed id, uint256 timestamp);
    event ReActivate(
        address userAddress,
        uint256 indexed id,
        uint256 timestamp
    );
    event OwnerFeePaid(uint256 amount, uint256 timestamp);
    event CommunityDevelopmentFeePaid(uint256 amount, uint256 timestamp);
    event DirectCommissionPaid(uint256 fromID, uint256 toID, uint256 timestamp);
    event DirectCommissionMissed(
        uint256 fromID,
        uint256 toID,
        uint256 timestamp
    );
    event ReferralCommissionPaid(
        uint256 fromID,
        uint256 toID,
        uint256 level,
        uint256 timestamp
    );
    event ReferralCommissionMissed(
        uint256 fromID,
        uint256 toID,
        uint256 level,
        uint256 timestamp
    );

    constructor() {
        liquidityPoolWallet = address(
            0xa7A5D9DC4119716295BdB10191dFC64979983309
        );
        CommunityDevelopmentWallet = address(
            0x4296451A1ee302dF825D978a7c9Ac52F19bD9285
        );
        token = IERC20(tokenAddr);
        ZON = IERC20(zonAddr);
    }

    function activateProject() public {
        require(msg.sender == liquidityPoolWallet, "Only owner");
        require(!initial, "Only once");
        User memory userStruct;
        uint256[] memory deafultArray;
        userStruct = User({
            id: currentID,
            joinDate: block.timestamp,
            originReferrer: 0,
            mainReferrer: 0,
            currentProfit: 0,
            totalIncome: 0,
            downlineCount: 0,
            referral: new uint256[](0),
            reActivationAmount: 0,
            totalMissedCommission: 0,
            isbought: true,
            totalDirectCommission: 0,
            missedDirectCommission: 0,
            totalReferralCommission: new uint256[](MAX_COMMISSION_LEVEL),
            missedCommission: new uint256[](MAX_COMMISSION_LEVEL),
            savedSearchArray: deafultArray,
            currentSearchIndex: 0,
            reactivateCount: 0
        });
        users[liquidityPoolWallet] = userStruct;
        userList[currentID] = liquidityPoolWallet;
        currentID++;
        totalUsers++;
        initial = true;
    }

    function activate(uint256 referrer) public noReentrant {
        require(initial, "Project not launch yet");
        require(users[msg.sender].joinDate == 0, "Activate only once");
        require(
            users[userList[referrer]].joinDate != 0,
            "Referrer is not valid"
        );
        require(
            ACTIVATE_PRICE <= token.allowance(msg.sender, address(this)),
            "Low allowance"
        );
        token.transferFrom(msg.sender, address(this), ACTIVATE_PRICE);

        if (airdrop) {
            if (ZON.balanceOf(msg.sender) == 0) {
                ZON.transfer(msg.sender, 61e18);
            }
        }

        uint256 refID = users[userList[referrer]].id;
        if (users[userList[refID]].referral.length >= MAX_DIRECT_REFERRAL) {
            refID = _findFreeReferrer(refID);
        }

        User memory userStruct;
        uint256[] memory deafultArray;
        userStruct = User({
            id: currentID,
            joinDate: block.timestamp,
            originReferrer: users[userList[referrer]].id,
            mainReferrer: refID,
            currentProfit: 0,
            totalIncome: 0,
            downlineCount: 0,
            referral: new uint256[](0),
            reActivationAmount: 0,
            totalMissedCommission: 0,
            isbought: false,
            totalDirectCommission: 0,
            missedDirectCommission: 0,
            totalReferralCommission: new uint256[](MAX_COMMISSION_LEVEL),
            missedCommission: new uint256[](MAX_COMMISSION_LEVEL),
            savedSearchArray: deafultArray,
            currentSearchIndex: 0,
            reactivateCount: 0
        });
        users[msg.sender] = userStruct;
        users[userList[users[msg.sender].originReferrer]].downlineCount++;
        userList[currentID] = msg.sender;
        users[userList[users[msg.sender].mainReferrer]].referral.push(
            currentID
        );
        currentID++;
        totalUsers++;
        totalActiveAmount += ACTIVATE_PRICE;

        _payCommission(msg.sender, false);

        emit Activate(msg.sender, users[msg.sender].id, block.timestamp);
    }

    function reActivate() public noReentrant {
        users[msg.sender].reactivateCount++;
        if (users[msg.sender].reactivateCount > 4) {
            uint256 requiredRef = (users[msg.sender].reactivateCount / 10) + 1;
            require(
                users[msg.sender].referral.length >= requiredRef,
                "You need a Direct referral to Reactivate your Account!"
            );
        }
        if (users[msg.sender].reactivateCount > 15) {
            require(
                users[msg.sender].isbought,
                "Buy minimum 50 ZON by giving 50 USDT from your connected wallet to Reactivate your Account!"
            );
        }
        require(initial, "Project not launch yet");
        require(users[msg.sender].joinDate > 0, "Activate first");
        require(
            users[msg.sender].currentProfit >= DEACTIVATE_STEP,
            "User is active"
        );
        uint256 _amount;
        if (users[msg.sender].reActivationAmount > REACTIVATE_PRICE) {
            users[msg.sender].reActivationAmount =
                users[msg.sender].reActivationAmount -
                REACTIVATE_PRICE;
        }
        if (_amount > 0) {
            require(
                token.allowance(msg.sender, address(this)) >= _amount,
                "Low allowance"
            );
            token.transferFrom(msg.sender, address(this), _amount);
        }

        _payCommission(msg.sender, true);
        users[msg.sender].currentProfit =
            users[msg.sender].currentProfit -
            DEACTIVATE_STEP;

        totalReActiveAmount += REACTIVATE_PRICE;

        emit ReActivate(msg.sender, users[msg.sender].id, block.timestamp);
    }

    function _payCommission(address userAddress, bool _reActivate) internal {
        User storage user = users[userAddress];
        uint256 tokenLiquidityPool;

        address originUser = userList[user.originReferrer];
        if (_reActivate) {
            tokenLiquidityPool += DIRECT_COMMISSION;
        } else if (isUserActive(originUser)) {
            users[originUser].currentProfit += DIRECT_COMMISSION;
            users[originUser].totalIncome += DIRECT_COMMISSION;
            token.transfer(originUser, DIRECT_COMMISSION / 2);
            users[originUser].reActivationAmount += DIRECT_COMMISSION / 2;
            users[originUser].totalDirectCommission += DIRECT_COMMISSION;
            totalDirectReferralPaid += DIRECT_COMMISSION;
        } else {
            users[originUser].missedDirectCommission += DIRECT_COMMISSION;
            users[originUser].totalMissedCommission += DIRECT_COMMISSION;
            totalDirectReferralMissed += DIRECT_COMMISSION;
            totalCommissionMissed += DIRECT_COMMISSION;
            tokenLiquidityPool += DIRECT_COMMISSION;
            users[originUser].totalDirectCommission += DIRECT_COMMISSION;
            emit DirectCommissionMissed(
                user.id,
                user.originReferrer,
                block.timestamp
            );
        }

        address upline = userList[user.mainReferrer];
        for (uint256 i = 0; i < MAX_COMMISSION_LEVEL; i++) {
            if (upline != address(0) && upline != liquidityPoolWallet) {
                if (isUserActive(upline)) {
                    users[upline].currentProfit += REFERRAL_COMMISSION;
                    users[upline].totalIncome += REFERRAL_COMMISSION;
                    users[upline].totalReferralCommission[
                        i
                    ] += REFERRAL_COMMISSION;
                    users[upline].reActivationAmount += REFERRAL_COMMISSION / 2;
                    token.transfer(upline, REFERRAL_COMMISSION / 2);
                    totalCommissionPaid += REFERRAL_COMMISSION;
                    emit ReferralCommissionPaid(
                        user.id,
                        users[upline].id,
                        i,
                        block.timestamp
                    );
                } else {
                    users[upline].missedCommission[i] += REFERRAL_COMMISSION;
                    tokenLiquidityPool += REFERRAL_COMMISSION;
                    totalCommissionMissed += REFERRAL_COMMISSION;
                    users[upline].totalMissedCommission += REFERRAL_COMMISSION;
                    emit ReferralCommissionMissed(
                        user.id,
                        users[upline].id,
                        i,
                        block.timestamp
                    );
                }
            } else {
                tokenLiquidityPool += REFERRAL_COMMISSION;
                users[liquidityPoolWallet].currentProfit += REFERRAL_COMMISSION;
                users[liquidityPoolWallet].totalIncome += REFERRAL_COMMISSION;
            }
            upline = userList[users[upline].mainReferrer];
        }
        tokenLiquidityPool += tokenLiquidityPoolFee;

        token.transfer(liquidityPoolWallet, tokenLiquidityPool);
        token.transfer(CommunityDevelopmentWallet, CommunityDevelopmentFee);
        emit OwnerFeePaid(tokenLiquidityPool, block.timestamp);
        emit CommunityDevelopmentFeePaid(
            CommunityDevelopmentFee,
            block.timestamp
        );
    }

    function _findFreeReferrer(uint256 _user) internal returns (uint256) {
        if (users[userList[_user]].referral.length < MAX_DIRECT_REFERRAL) {
            return _user;
        }
        uint256[] storage referrals = users[userList[_user]].savedSearchArray;
        if (referrals.length == 0) {
            referrals.push(users[userList[_user]].referral[0]);
            referrals.push(users[userList[_user]].referral[1]);
        }

        uint256 freeReferrer;
        bool noFreeReferrer = true;
        uint256 maxBuildAddress = (MAX_SEARCH_ADDRESS / MAX_DIRECT_REFERRAL) -
            1;
        for (
            uint256 i = users[userList[_user]].currentSearchIndex;
            i < MAX_SEARCH_ADDRESS;
            i++
        ) {
            if (
                users[userList[referrals[i]]].referral.length ==
                MAX_DIRECT_REFERRAL
            ) {
                if (i < maxBuildAddress) {
                    referrals.push(users[userList[referrals[i]]].referral[0]);
                    referrals.push(users[userList[referrals[i]]].referral[1]);
                    users[userList[_user]].currentSearchIndex++;
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

    function findFreeReferrer(uint256 _user) public view returns (uint256) {
        if (users[userList[_user]].referral.length < MAX_DIRECT_REFERRAL) {
            return _user;
        }
        uint256[] memory referrals = users[userList[_user]].savedSearchArray;
        if (referrals.length == 0) {
            referrals[0] = users[userList[_user]].referral[0];
            referrals[1] = users[userList[_user]].referral[1];
        }

        uint256 freeReferrer;
        bool noFreeReferrer = true;
        uint256 maxBuildAddress = (MAX_SEARCH_ADDRESS / MAX_DIRECT_REFERRAL) -
            1;
        for (
            uint256 i = users[userList[_user]].currentSearchIndex;
            i < MAX_SEARCH_ADDRESS;
            i++
        ) {
            if (
                users[userList[referrals[i]]].referral.length ==
                MAX_DIRECT_REFERRAL
            ) {
                if (i < maxBuildAddress) {
                    referrals[(i + 1) * MAX_DIRECT_REFERRAL] = users[
                        userList[referrals[i]]
                    ].referral[0];
                    referrals[(i + 1) * MAX_DIRECT_REFERRAL + 1] = users[
                        userList[referrals[i]]
                    ].referral[1];
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

    function setMaxSearchAddress(uint256 amount) public {
        require(msg.sender == liquidityPoolWallet, "Only owner");
        MAX_SEARCH_ADDRESS = amount;
    }

    function isUserActive(address userAddress) public view returns (bool) {
        if (
            (users[userAddress].currentProfit < DEACTIVATE_STEP &&
                userAddress != address(0)) || userAddress == liquidityPoolWallet
        ) {
            return true;
        } else {
            return false;
        }
    }

    function changeairdropStatus(bool _val) public {
        require(msg.sender == liquidityPoolWallet, "not Owner Wallet");
        airdrop = _val;
    }

    function getSiteInfo()
        public
        view
        returns (
            uint256 _totalUsers,
            uint256 _totalActiveAmount,
            uint256 _totalReActiveAmount,
            uint256 _totalDirectReferralPaid,
            uint256 _totalDirectReferralMissed,
            uint256 _totalCommissionPaid,
            uint256 _totalCommissionMissed
        )
    {
        return (
            totalUsers,
            totalActiveAmount,
            totalReActiveAmount,
            totalDirectReferralPaid,
            totalDirectReferralMissed,
            totalCommissionPaid,
            totalCommissionMissed
        );
    }

    function getUserInfo(address userAddress)
        public
        view
        returns (
            uint256 _id,
            uint256 _downlineCount,
            uint256 _currentProfit,
            uint256 _totalIncome,
            uint256 _totalDirectCommission,
            uint256 totalReferralCommission
        )
    {
        return (
            users[userAddress].id,
            users[userAddress].downlineCount,
            users[userAddress].currentProfit,
            users[userAddress].totalIncome,
            users[userAddress].totalDirectCommission,
            getUserTotalReferralCommission(userAddress)
        );
    }

    function purchaseTokensWithStableCoin(uint256 _amount) public {
        require(_amount >= minBuyAmount && _amount <= maxBuyAmount);
        token.transferFrom(msg.sender, liquidityPoolWallet, _amount);
        address ref = userList[users[msg.sender].mainReferrer];
        if (isUserActive(ref)) {
            ZON.transfer(msg.sender, _amount);
            ZON.transfer(ref, (_amount * refPercent) / PERCENTS_DIVIDER);
        } else {
            ZON.transfer(msg.sender, _amount);
        }
        users[msg.sender].isbought = true;
    }

    function ChangeTokenAmount(uint256 _minBuyAmount, uint256 _maxBuyAmount)
        public
    {
        require(msg.sender == liquidityPoolWallet, "Only owner");
        minBuyAmount = _minBuyAmount;
        maxBuyAmount = _maxBuyAmount;
    }

    function RefPercentage(uint256 _percent)
        public
    {
        require(msg.sender == liquidityPoolWallet, "Only owner");
        refPercent = _percent;
    }

    function getUserMainReferrer(address userAddress)
        public
        view
        returns (address)
    {
        return userList[users[userAddress].mainReferrer];
    }

    function getUserOriginReferrer(address userAddress)
        public
        view
        returns (address)
    {
        return userList[users[userAddress].originReferrer];
    }

    function getUserDownlineCount(address userAddress)
        public
        view
        returns (uint256)
    {
        return users[userAddress].downlineCount;
    }

    function getUserTotalMissedCommission(address userAddress)
        public
        view
        returns (uint256)
    {
        return users[userAddress].totalMissedCommission;
    }

    function getUserID(address userAddress) public view returns (uint256) {
        return users[userAddress].id;
    }

    function getUserCurrentProfit(address userAddress)
        public
        view
        returns (uint256)
    {
        return users[userAddress].currentProfit;
    }

    function getUserTotalIncome(address userAddress)
        public
        view
        returns (uint256)
    {
        return users[userAddress].totalIncome;
    }

    function getUserReferral(address userAddress)
        public
        view
        returns (uint256[] memory)
    {
        return users[userAddress].referral;
    }

    function getUserReferralCommission(address userAddress)
        public
        view
        returns (uint256[] memory)
    {
        return users[userAddress].totalReferralCommission;
    }

    function getUserTotalReferralCommission(address userAddress)
        public
        view
        returns (uint256 amount)
    {
        for (uint256 i = 0; i < MAX_COMMISSION_LEVEL; i++) {
            amount += users[userAddress].totalReferralCommission[i];
        }
    }

    function WithdrawBNB(uint256 _amount) public {
        require(msg.sender == liquidityPoolWallet, "Only owner");
        payable(liquidityPoolWallet).transfer(_amount);
    }

    function WithdrawToken(address _token, uint256 _amount) public {
        require(msg.sender == liquidityPoolWallet, "Only owner");
        IERC20(_token).transfer(liquidityPoolWallet, _amount);
    }

    function changeZontoken(address _address) public {
        require(msg.sender == liquidityPoolWallet, "Only owner");
        ZON = IERC20(_address);
    }

    function changeStabletoken(address _address) public {
        require(msg.sender == liquidityPoolWallet, "Only owner");
        token = IERC20(_address);
    }

    function changeCommunityDevelopmentWallet(address _address) public {
        require(msg.sender == liquidityPoolWallet, "Only owner");
        CommunityDevelopmentWallet = _address;
    }

    function changeLiquidityPoolWalletWallet(address _address) public {
        require(msg.sender == liquidityPoolWallet, "Only owner");
        liquidityPoolWallet = _address;
    }

    function getUserTotalReferralCommissionMissed(address userAddress)
        public
        view
        returns (uint256 amount)
    {
        for (uint256 i = 0; i < MAX_COMMISSION_LEVEL; i++) {
            amount += users[userAddress].missedCommission[i];
        }
    }

    function getUserReActivationAmount(address userAddress)
        public
        view
        returns (uint256)
    {
        return users[userAddress].reActivationAmount;
    }

    function getUserMissedCommission(address userAddress)
        public
        view
        returns (uint256[] memory)
    {
        return users[userAddress].missedCommission;
    }

    function getUserSavedSearchArray(address userAddress)
        public
        view
        returns (uint256[] memory)
    {
        return users[userAddress].savedSearchArray;
    }

    function getUserReferralLength(address userAddress)
        public
        view
        returns (uint256)
    {
        return users[userAddress].referral.length;
    }

    function getUserReactivateCount(address userAddress)
        public
        view
        returns (uint256)
    {
        return users[userAddress].reactivateCount;
    }

    function treeView(address _user)
        public
        view
        returns (
            address[] memory,
            bool[] memory,
            uint256[] memory
        )
    {
        address[] memory referrals = new address[](30);
        bool[] memory activeStatus = new bool[](30);
        uint256[] memory IDs = new uint256[](30);
        IDs[0] = users[_user].referral.length > 0
            ? users[_user].referral[0]
            : 0;
        IDs[1] = users[_user].referral.length > 1
            ? users[_user].referral[1]
            : 0;
        for (uint256 i = 0; i < 14; i++) {
            IDs[(i + 1) * MAX_DIRECT_REFERRAL] = users[userList[IDs[i]]]
                .referral
                .length > 0
                ? users[userList[IDs[i]]].referral[0]
                : 0;
            IDs[(i + 1) * MAX_DIRECT_REFERRAL + 1] = users[userList[IDs[i]]]
                .referral
                .length > 1
                ? users[userList[IDs[i]]].referral[1]
                : 0;
        }
        for (uint256 i = 0; i < 30; i++) {
            activeStatus[i] = isUserActive(userList[IDs[i]]);
            referrals[i] = userList[IDs[i]];
        }
        return (referrals, activeStatus, IDs);
    }
}