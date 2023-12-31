// SPDX-License-Identifier: MIT
pragma solidity ^0.8.12;

import "./Tether.sol";

contract DollarFortUpdated {
    IBEP20 public _usdtToken;
    uint256 public immutable CONST_MIN_INVESTMENT = toWei(100);
    uint256 public immutable CONST_MIN_WITHDRAWAL = toWei(12);
    address public immutable CONST_SYSTEM_ADDRESS;
    uint32[] public CONST_REWARDS = [3000, 9000, 27000, 81000, 243000, 729000];
    uint256 public immutable CONST_REWARD_FLUSHED_TIMESTAMP = 4102444800;
    uint8 public immutable CONST_REWARD_PERCENTAGE = 10; // 10% of the achieved business volume
    uint8 public immutable CONST_ROI_PER_DAY = 5; // 0.5% daily
    uint8 public immutable CONST_DIRECT_LEVEL_OPENED_PER_REFERRAL = 1;
    uint8 public immutable CONST_GENERATION_LEVEL_OPENED_PER_REFERRAL = 3;
    uint16 public immutable CONST_WORKING_LIMIT = 3000;
    uint16 public immutable CONST_NONWORKING_LIMIT = 1825;
    uint8[] public CONST_DIRECT_INCOME_PERCENTAGES = [
        15,
        5,
        5,
        5,
        5,
        5,
        5,
        5,
        5,
        5
    ]; // 1.5% for 1st level & 0.5% for 2nd to 10th level

    // Level 1 to 10 = 3%; Level 11 to 20 = 6%; Level 21 to 30 = 9%;
    uint256[] public CONST_GENERATION_INCOME_PERCENTAGES = [
        30,
        30,
        30,
        30,
        30,
        30,
        30,
        30,
        30,
        30,
        60,
        60,
        60,
        60,
        60,
        60,
        60,
        60,
        60,
        60,
        90,
        90,
        90,
        90,
        90,
        90,
        90,
        90,
        90,
        90
    ];

    address public immutable CONST_PROJECT_ADDRESS;
    address public immutable CONST_MARKETING_ADDRESS;
    address public immutable CONST_FEES_ADDRESS;

    enum UserIncome {
        AP,
        RR,
        NN
    }

    event UserRegistered(
        address indexed user,
        address indexed sponsor,
        uint256 investment,
        uint256 timestamp
    );

    event WithdrawalHappened(
        address indexed user,
        uint256 amount,
        uint256 timestamp
    );

    struct UserInvestment {
        uint256 id;
        uint256 amount;
        uint256 timestamp;
        uint256 endedTimestamp;
        UserIncome incomeType;
    }

    // some stat fields for the contract
    uint256 totalInvestments;
    uint256 totalWithdrawal;

    struct User {
        address addr;
        mapping(uint8 => uint256) usersAtEachLevel;
        mapping(uint8 => uint256) achievedRewards; // index to reward timestamp
        mapping(uint8 => uint256) businessAtEachLevel;
        mapping(uint8 => address[]) usersAtEachLevelArray;
        UserDetails details;
    }

    struct UserDetails {
        uint256 directIncome;
        uint256 generationIncome;
        uint256 totalSelfRoiIncome;
        uint256 totalDirectIncome;
        uint256 totalGenerationIncome;
        uint256 lastRetopupTimestamp;
        uint256 lastWithdrawalTimestamp;
        uint256[] withdrawalAmounts; // timestamp to amount
        uint256[] withdrawalTimestamps;
        uint256 totalInvestmentTillDate;
        uint256 activeInvestmentAmount;
        uint256 totalWithdrawal;
        uint256 directBusiness;
        uint256 levelBusiness;
        uint256 pendingFromMaxLimit;
        uint256 rewardCarryForwardAmount;
        uint8 directLevelsOpened;
        uint8 generationLevelsOpened;
        uint256 registrationTimestamp;
        UserInvestment[] investments;
        address[] referrals;
        address sponsor;
        UserIncome userIncome;
    }

    uint256 public _investmentIndex = 1;

    mapping(address => User) public users;

    constructor(
        address usdtAddress,
        address _projectAddress,
        address _marketingAddress,
        address _feesAddress
    ) {
        CONST_SYSTEM_ADDRESS = msg.sender;
        _usdtToken = IBEP20(usdtAddress);
        CONST_PROJECT_ADDRESS = _projectAddress;
        CONST_MARKETING_ADDRESS = _marketingAddress;
        CONST_FEES_ADDRESS = _feesAddress;

        uint256 _systemInvestment = toWei(1000);
        User storage _systemUser = users[CONST_SYSTEM_ADDRESS];
        _systemUser.addr = CONST_SYSTEM_ADDRESS;
        _systemUser.details.pendingFromMaxLimit = _systemInvestment * 30000;
        _systemUser.details.directLevelsOpened = uint8(
            CONST_DIRECT_INCOME_PERCENTAGES.length
        );
        _systemUser.details.generationLevelsOpened = uint8(
            CONST_GENERATION_INCOME_PERCENTAGES.length
        );
        _systemUser.details.registrationTimestamp = block.timestamp;
        _systemUser.details.investments.push(
            UserInvestment({
                id: _investmentIndex++,
                amount: _systemInvestment,
                timestamp: block.timestamp,
                endedTimestamp: 0,
                incomeType: UserIncome.AP
            })
        );
        _systemUser.details.userIncome = UserIncome.AP;
    }

    modifier onlySystem() {
        require(
            msg.sender == CONST_SYSTEM_ADDRESS,
            "Only system can call this function"
        );
        _;
    }

    function toWei(uint256 _n) public pure returns (uint256) {
        return _n * 10 ** 18;
    }

    function getUserDownlineAtLevel(
        address _addr,
        uint8 _level
    ) public view returns (address[] memory) {
        return users[_addr].usersAtEachLevelArray[_level];
    }

    function getSelfRoiPerSecond(address _addr) public view returns (uint256) {
        User storage _user = users[_addr];

        if (_user.details.userIncome != UserIncome.NN) return 0;

        uint256 _selfRoiPerSecond = ((CONST_ROI_PER_DAY) *
            _user.details.activeInvestmentAmount) / 1000;
        _selfRoiPerSecond /= 86400;

        return _selfRoiPerSecond;
    }

    function getGenerationPerSecond(
        address _addr
    ) public view returns (uint256) {
        User storage _user = users[_addr];

        uint256 _generationPerSecond = 0;

        uint256[] memory roiAmountAtLevels = getAllLevelsDownlineRoi(_addr);

        for (uint8 i = 0; i < CONST_GENERATION_INCOME_PERCENTAGES.length; i++) {
            // _generationPerSecond += 5 * 10 ** 18;
            if (_user.details.generationLevelsOpened >= (i == 0 ? 0 : i + 1)) {
                uint256 _roi = roiAmountAtLevels[i];

                _generationPerSecond +=
                    (CONST_GENERATION_INCOME_PERCENTAGES[i] * 10 ** 18) *
                    (_roi);
                // _generationPerSecond +=
                //     (CONST_GENERATION_INCOME_PERCENTAGES[i] / 1000) *
                //     _roi;
                // _generationPerSecond += 10 * 10 ** 18;
            }
        }

        return (_generationPerSecond / 10 ** 21);
    }

    function getAllLevelsDownlineRoi(
        address _addr
    ) public view returns (uint256[] memory) {
        User storage _user = users[_addr];
        uint256[] memory roiAmountAtLevels = new uint256[](
            CONST_GENERATION_INCOME_PERCENTAGES.length
        );

        for (uint8 i = 0; i < CONST_GENERATION_INCOME_PERCENTAGES.length; i++) {
            uint256 _roi = 0;

            for (
                uint256 j = 0;
                j < _user.usersAtEachLevelArray[i].length;
                j++
            ) {
                _roi += getSelfRoiPerSecond(_user.usersAtEachLevelArray[i][j]);
            }

            roiAmountAtLevels[i] += _roi;
        }

        return roiAmountAtLevels;
    }

    function getUserDetails(
        address _addr
    ) external view returns (UserDetails memory) {
        return users[_addr].details;
    }

    function getUserInvestments(
        address _address
    ) external view returns (UserInvestment[] memory) {
        return users[_address].details.investments;
    }

    function getRewards() external view returns (uint32[] memory) {
        return CONST_REWARDS;
    }

    function getUserAchievedRewards(
        address _addr
    ) external view returns (uint256[] memory) {
        uint256[] memory _rewards = new uint256[](CONST_REWARDS.length);

        for (uint8 i = 0; i < CONST_REWARDS.length; i++) {
            _rewards[i] = users[_addr].achievedRewards[i];
        }

        return _rewards;
    }

    function _getUserReferralCount(
        address _address
    ) external view returns (uint256) {
        uint256 _count = 0;
        address[] memory referrals = users[_address].details.referrals;

        for (uint256 i = 0; i < referrals.length; i++) {
            if (users[referrals[i]].details.userIncome == UserIncome.NN) {
                _count++;
            }
        }

        return _count;
    }

    function userExists(address _address) public view returns (bool) {
        return users[_address].addr != address(0);
    }

    function getUserLatestInvestment(
        address _address
    ) private view returns (UserInvestment memory) {
        User storage _user = users[_address];
        return _user.details.investments[_user.details.investments.length - 1];
    }

    function getUserStructure(
        address _addr
    )
        external
        view
        returns (uint16[] memory usersList, uint256[] memory business)
    {
        User storage _user = users[_addr];
        uint16[] memory _usersList = new uint16[](
            CONST_GENERATION_INCOME_PERCENTAGES.length
        );
        uint256[] memory _business = new uint256[](
            CONST_GENERATION_INCOME_PERCENTAGES.length
        );

        for (uint8 i = 0; i < CONST_GENERATION_INCOME_PERCENTAGES.length; i++) {
            _usersList[i] = uint16(_user.usersAtEachLevel[i]);
            _business[i] = _user.businessAtEachLevel[i];
        }

        return (_usersList, _business);
    }

    function getUserBalance(
        address addr,
        uint256 timestamp
    ) external view returns (uint256) {
        User storage _user = users[addr];

        return
            _user.details.directIncome +
            _user.details.generationIncome +
            getUserAvailableSelfRoi(addr, timestamp);
    }

    function getUserAvailableSelfRoi(
        address _addr,
        uint256 timestamp
    ) public view returns (uint256) {
        timestamp /= 10 ** 18;
        User storage _user = users[_addr];
        uint256 _selfRoiIncome = 0;

        if (_user.details.userIncome == UserIncome.NN) {
            // we will calculate this based upon time

            for (uint256 i = 0; i < _user.details.investments.length; i++) {
                UserInvestment storage _investment = _user.details.investments[
                    i
                ];

                if (_investment.endedTimestamp != 0) {
                    continue;
                }

                uint256 checkpoint = _user.details.lastWithdrawalTimestamp == 0
                    ? timestamp
                    : _user.details.lastWithdrawalTimestamp;

                if (_investment.timestamp > checkpoint) {
                    checkpoint = timestamp;
                }

                // adison migration is pending 7:33 PM 22 dec 2023

                uint256 _seconds = (checkpoint - _investment.timestamp);

                // _selfRoiIncome += toWei(block.timestamp);

                // if (_seconds > 0) {
                uint256 _roi = ((_investment.amount *
                    _seconds *
                    CONST_ROI_PER_DAY) / 1000) / 86400;
                _selfRoiIncome += _roi;
            }
        }
        // }

        return _selfRoiIncome;
    }

    function getUserAvailableGenerationIncome(
        address _addr,
        uint256 timestamp
    ) external view returns (uint256) {
        timestamp /= 10 ** 18;
        User storage _user = users[_addr];
        uint256 generationPerSecond = getGenerationPerSecond(_addr);

        uint256 checkpoint = _user.details.lastWithdrawalTimestamp == 0
            ? _user.details.registrationTimestamp
            : _user.details.lastWithdrawalTimestamp;

        uint256 _seconds = (timestamp - checkpoint);

        return (generationPerSecond * _seconds);
    }

    function safeFromLimit(
        address _address,
        uint256 _amount
    ) private returns (uint256) {
        if (users[_address].details.userIncome == UserIncome.AP) return _amount;

        if (users[_address].details.pendingFromMaxLimit > _amount) {
            users[_address].details.pendingFromMaxLimit -= _amount;
            return _amount;
        } else {
            uint256 _amountToReturn = users[_address]
                .details
                .pendingFromMaxLimit;
            users[_address].details.pendingFromMaxLimit = 0;
            UserInvestment storage _investment = users[_address]
                .details
                .investments[users[_address].details.investments.length - 1];

            if (_investment.endedTimestamp == 0) {
                _investment.endedTimestamp = block.timestamp;
            }
            return _amountToReturn;
        }
    }

    function getContractBalance() public view returns (uint256) {
        return _usdtToken.balanceOf(address(this));
    }

    function invest(
        address _sponsor,
        uint256 _investment,
        UserIncome userIncome,
        address _userAddress
    ) external {
        _investment = toWei(_investment);
        address senderInCase = msg.sender == CONST_SYSTEM_ADDRESS ||
            msg.sender == CONST_FEES_ADDRESS
            ? _userAddress
            : msg.sender;
        require(_sponsor != address(0), "Invalid sponsor address");
        require(
            _investment >= CONST_MIN_INVESTMENT,
            "Invalid investment amount"
        );
        require(senderInCase != _sponsor, "Same sponsor and user address");

        if (userIncome != UserIncome.NN && msg.sender != CONST_SYSTEM_ADDRESS) {
            revert("Invalid User Income");
        }

        if (userIncome != UserIncome.NN && userExists(senderInCase)) {
            revert("Invalid Income for existing user");
        }

        if (userIncome == UserIncome.NN && msg.sender != CONST_FEES_ADDRESS) {
            require(
                _usdtToken.transferFrom(
                    senderInCase,
                    address(this),
                    (_investment)
                ),
                "Transfer failed"
            );
        }

        bool isNewUser = !userExists(senderInCase);
        User storage _user = users[senderInCase];

        if (isNewUser) {
            _user.addr = senderInCase;
            _user.details.sponsor = _sponsor;
            _user.details.registrationTimestamp = block.timestamp;
            _user.details.investments.push(
                UserInvestment({
                    id: _investmentIndex++,
                    amount: _investment,
                    timestamp: block.timestamp,
                    incomeType: userIncome,
                    endedTimestamp: 0
                })
            );
            _user.details.userIncome = userIncome;

            if (userIncome == UserIncome.AP) {
                _user.details.pendingFromMaxLimit = _investment * 3000;
                _user.details.generationLevelsOpened = 30;
                _user.details.directLevelsOpened = 10;
            }

            if (userIncome == UserIncome.NN) {
                address currentUpline = _sponsor;

                for (
                    uint8 i = 0;
                    i < CONST_GENERATION_INCOME_PERCENTAGES.length;
                    i++
                ) {
                    User storage _currentUpline = users[currentUpline];
                    bool isCurrentlyInactive = _currentUpline
                        .details
                        .pendingFromMaxLimit == 0;
                    _currentUpline.usersAtEachLevel[i] += 1;
                    if (!isCurrentlyInactive) {
                        _currentUpline.details.levelBusiness += _investment;
                        _currentUpline.businessAtEachLevel[i] += _investment;
                    }
                    _currentUpline.usersAtEachLevelArray[i].push(senderInCase);

                    // if it is under the first 10 levels, then give the direct income
                    uint8 _levelCondition = i == 0 ? 0 : i + 1; // add 1 because we are starting from 0
                    if (
                        userIncome == UserIncome.NN &&
                        i < 10 &&
                        _currentUpline.details.directLevelsOpened >=
                        _levelCondition
                    ) {
                        if (!isCurrentlyInactive) {
                            uint256 _directIncome = safeFromLimit(
                                currentUpline,
                                (_investment *
                                    CONST_DIRECT_INCOME_PERCENTAGES[i]) / 1000
                            );
                            _currentUpline
                                .details
                                .directIncome += _directIncome;
                            _currentUpline
                                .details
                                .totalDirectIncome += _directIncome;
                        }
                    }

                    currentUpline = _currentUpline.details.sponsor;
                    if (currentUpline == address(0)) break;
                }
            }
        } else {
            if (
                _user.details.pendingFromMaxLimit == 0 &&
                _user
                    .details
                    .investments[_user.details.investments.length - 1]
                    .endedTimestamp ==
                0
            ) {
                _user
                    .details
                    .investments[_user.details.investments.length - 1]
                    .endedTimestamp = block.timestamp;

                // _user.details.activeInvestmentAmount -= _user
                //     .details
                //     .investments[_user.details.investments.length - 1]
                //     .amount;

                if (
                    _user.details.activeInvestmentAmount >=
                    _user
                        .details
                        .investments[_user.details.investments.length - 1]
                        .amount
                ) {
                    _user.details.activeInvestmentAmount -= _user
                        .details
                        .investments[_user.details.investments.length - 1]
                        .amount;
                }
            }

            // add a new investment for the user
            _user.details.investments.push(
                UserInvestment({
                    id: _investmentIndex++,
                    amount: _investment,
                    timestamp: block.timestamp,
                    endedTimestamp: 0,
                    incomeType: UserIncome.NN
                })
            );

            _user.details.userIncome = UserIncome.NN;

            // since this is an existing user we will not increment the user count
            address currentUpline = _sponsor;

            for (
                uint8 i = 0;
                i < CONST_GENERATION_INCOME_PERCENTAGES.length;
                i++
            ) {
                User storage _currentUpline = users[currentUpline];
                bool isCurrentlyInactive = _currentUpline
                    .details
                    .pendingFromMaxLimit == 0;
                if (!isCurrentlyInactive) {
                    _currentUpline.details.levelBusiness += _investment;
                    _currentUpline.businessAtEachLevel[i] += _investment;
                }
                uint8 _levelCondition = i == 0 ? 0 : i + 1;

                if (
                    i < 10 &&
                    _currentUpline.details.directLevelsOpened >= _levelCondition
                ) {
                    if (!isCurrentlyInactive) {
                        uint256 _directIncome = safeFromLimit(
                            currentUpline,
                            (_investment * CONST_DIRECT_INCOME_PERCENTAGES[i]) /
                                1000
                        );
                        _currentUpline.details.directIncome += _directIncome;
                        _currentUpline
                            .details
                            .totalDirectIncome += _directIncome;
                    }
                }

                currentUpline = _currentUpline.details.sponsor;
                if (currentUpline == address(0)) break;
            }
        }

        // add the pending limit for the user
        if (userIncome != UserIncome.AP) {
            if (_user.details.userIncome == UserIncome.AP) {
                _user.details.pendingFromMaxLimit = 0;
            }
            if (_user.details.referrals.length > 0) {
                _user.details.pendingFromMaxLimit +=
                    (_investment * CONST_WORKING_LIMIT) /
                    1000;
            } else {
                _user.details.pendingFromMaxLimit +=
                    (_investment * CONST_NONWORKING_LIMIT) /
                    1000;
            }
        }

        // update the global stat
        totalInvestments += _investment;

        // update user investment amounts
        User storage _sponsorUser = users[_sponsor];

        if (userIncome == UserIncome.NN) {
            _user.details.activeInvestmentAmount += _investment;
            _user.details.totalInvestmentTillDate += _investment;
            // increment the direct business of the sponsor & open levels
            if (_sponsorUser.details.pendingFromMaxLimit > 0) {
                _sponsorUser.details.directBusiness += _investment;
            }
        }

        if (isNewUser) {
            _sponsorUser.details.referrals.push(senderInCase);
            if (
                _sponsorUser.details.directLevelsOpened <
                CONST_DIRECT_INCOME_PERCENTAGES.length
            ) {
                _sponsorUser
                    .details
                    .directLevelsOpened += CONST_DIRECT_LEVEL_OPENED_PER_REFERRAL;
            }

            if (
                _sponsorUser.details.generationLevelsOpened <
                CONST_GENERATION_INCOME_PERCENTAGES.length
            ) {
                _sponsorUser
                    .details
                    .generationLevelsOpened += CONST_GENERATION_LEVEL_OPENED_PER_REFERRAL;
            }

            if (_sponsorUser.details.referrals.length == 1) {
                // this is the first referral of the sponsor
                if (
                    _sponsorUser.details.userIncome == UserIncome.NN &&
                    _sponsorUser.details.pendingFromMaxLimit > 0
                ) {
                    UserInvestment memory _sponsorInvestment = _sponsorUser
                        .details
                        .investments[
                            _sponsorUser.details.investments.length - 1
                        ];
                    uint256 maxLimit = (_sponsorInvestment.amount *
                        CONST_NONWORKING_LIMIT) / 1000;
                    uint256 earnedLimit = maxLimit -
                        _sponsorUser.details.pendingFromMaxLimit;
                    uint256 newLimit = (_sponsorInvestment.amount *
                        CONST_WORKING_LIMIT) / 1000;
                    newLimit -= earnedLimit;
                    _sponsorUser.details.pendingFromMaxLimit = newLimit;
                }
            }
        }

        uint256 _fees = (_investment * 10) / 100;
        if (userIncome == UserIncome.NN && getContractBalance() >= _fees) {
            _usdtToken.transfer(CONST_PROJECT_ADDRESS, _fees);
        }

        distributeRewards(_sponsor);

        if (isNewUser) {
            emit UserRegistered(
                senderInCase,
                _sponsor,
                _investment,
                block.timestamp
            );
        }
    }

    function getUserPendingLimit(address _addr) public view returns (uint256) {
        return users[_addr].details.pendingFromMaxLimit;
    }

    function isUserActive(address _addr) public view returns (bool) {
        return getUserPendingLimit(_addr) != 0;
    }

    function distributeRewards(address _user) private {
        User storage _currentUser = users[_user];

        // if (_currentUser.details.pendingFromMaxLimit == 0) {
        //     return;
        // }

        for (uint8 i = 0; i < CONST_REWARDS.length; i++) {
            uint256 rewardAmount = toWei(CONST_REWARDS[i]);
            bool hasAchievedReward = _currentUser.achievedRewards[i] > 0 &&
                _currentUser.achievedRewards[i] !=
                CONST_REWARD_FLUSHED_TIMESTAMP;

            if (
                hasAchievedReward ||
                _currentUser.achievedRewards[i] ==
                CONST_REWARD_FLUSHED_TIMESTAMP
            ) {
                continue;
            }

            uint256 _maxBusinessFromEachLeg = (30 * rewardAmount) / 100;
            uint256 _totalBusiness = 0;
            uint256 _totalPendingBusiness = 0;

            for (uint8 j = 0; j < _currentUser.details.referrals.length; j++) {
                User storage _referral = users[
                    _currentUser.details.referrals[j]
                ];
                uint256 _referralBusiness = _referral.details.levelBusiness +
                    _referral.details.totalInvestmentTillDate;

                if (_referralBusiness > _maxBusinessFromEachLeg) {
                    _totalBusiness += _maxBusinessFromEachLeg;
                    uint256 _pendingBusiness = _referralBusiness -
                        _maxBusinessFromEachLeg;
                    _totalPendingBusiness += _pendingBusiness > 0
                        ? _pendingBusiness
                        : 0;
                } else {
                    _totalBusiness += _referralBusiness;
                }
            }

            uint256 _usedRewardCarryForwardAmount = 0;

            if (_totalBusiness < rewardAmount) {
                _usedRewardCarryForwardAmount = rewardAmount - _totalBusiness;

                if (
                    _currentUser.details.rewardCarryForwardAmount >=
                    _usedRewardCarryForwardAmount
                ) {
                    _currentUser
                        .details
                        .rewardCarryForwardAmount -= _usedRewardCarryForwardAmount;
                    _totalBusiness += _usedRewardCarryForwardAmount;
                }
            }

            if (_totalBusiness >= rewardAmount) {
                if (_currentUser.details.pendingFromMaxLimit > 0) {
                    _currentUser.achievedRewards[i] = block.timestamp;

                    _currentUser
                        .details
                        .rewardCarryForwardAmount += _totalPendingBusiness;
                    _usdtToken.transfer(
                        _currentUser.addr,
                        (rewardAmount * CONST_REWARD_PERCENTAGE) / 100
                    );
                } else {
                    _currentUser.achievedRewards[
                            i
                        ] = CONST_REWARD_FLUSHED_TIMESTAMP;
                    _currentUser
                        .details
                        .rewardCarryForwardAmount += _usedRewardCarryForwardAmount;
                }
            }
        }
    }

    function userHasBeenRegisteredForLessThan24Hours(
        address _addr,
        uint256 _predefined
    ) public view returns (bool) {
        if (_predefined == 0) {
            return
                block.timestamp - getUserLatestInvestment(_addr).timestamp <
                86400;
        } else if (_predefined == 1) {
            return true;
        } else {
            return false;
        }
    }

    function sendGenerationIncome(address _user, uint256 _amount) private {
        address currentUpline = users[_user].details.sponsor;

        for (uint8 i = 0; i < CONST_GENERATION_INCOME_PERCENTAGES.length; i++) {
            uint8 _levelCondition = i == 0 ? 0 : i + 1;
            if (
                !(users[currentUpline].details.generationLevelsOpened >=
                    _levelCondition) ||
                users[currentUpline].details.pendingFromMaxLimit == 0 ||
                userHasBeenRegisteredForLessThan24Hours(currentUpline, 2)
            ) {
                currentUpline = users[currentUpline].details.sponsor;
                continue;
            }

            uint256 _generationIncome = safeFromLimit(
                currentUpline,
                (_amount * CONST_GENERATION_INCOME_PERCENTAGES[i]) / 1000
            );
            users[currentUpline].details.generationIncome += _generationIncome;
            users[currentUpline]
                .details
                .totalGenerationIncome += _generationIncome;

            currentUpline = users[currentUpline].details.sponsor;
            if (currentUpline == address(0)) break;
        }
    }

    function withdraw() external {
        User storage _user = users[msg.sender];

        require(_user.details.pendingFromMaxLimit != 0, "User is inactive");
        // check if the user has already withdrawn in last 24 hours
        require(
            block.timestamp - _user.details.lastWithdrawalTimestamp > 86400,
            "Already withdrawn in last 24 hours"
        );

        uint256 _selfRoiIncome;

        if (_user.details.userIncome == UserIncome.NN) {
            // we will calculate this based upon time

            for (uint256 i = 0; i < _user.details.investments.length; i++) {
                UserInvestment storage _investment = _user.details.investments[
                    i
                ];

                if (_investment.endedTimestamp != 0) {
                    continue;
                }

                uint256 checkpoint = _user.details.lastWithdrawalTimestamp == 0
                    ? block.timestamp
                    : _user.details.lastWithdrawalTimestamp;

                if (_investment.timestamp > checkpoint) {
                    checkpoint = block.timestamp;
                }

                uint256 _seconds = (checkpoint - _investment.timestamp);

                // _selfRoiIncome += toWei(block.timestamp);

                // if (_seconds > 0) {
                uint256 _roi = ((_investment.amount *
                    _seconds *
                    CONST_ROI_PER_DAY) / 1000) / 86400;
                _selfRoiIncome += _roi;

                // if it has been 365 days since the investment, it should be ended

                if (
                    (checkpoint - _investment.timestamp > 365 * 86400 ||
                        _seconds > 365 * 86400 ||
                        _user.details.pendingFromMaxLimit == 0) &&
                    _investment.endedTimestamp == 0
                ) {
                    _investment.endedTimestamp = block.timestamp;
                    if (
                        _user.details.activeInvestmentAmount >=
                        _investment.amount
                    ) {
                        _user.details.activeInvestmentAmount -= _investment
                            .amount;
                    }
                }
            }
        }

        _selfRoiIncome = safeFromLimit(msg.sender, _selfRoiIncome);

        uint256 balance = _selfRoiIncome +
            _user.details.directIncome +
            _user.details.generationIncome;

        require(
            balance >= CONST_MIN_WITHDRAWAL,
            "Minimum withdrawal amount not reached"
        );

        sendGenerationIncome(msg.sender, _selfRoiIncome);

        uint256 _fees = (balance * 6) / 100;

        _usdtToken.transfer(CONST_MARKETING_ADDRESS, _fees);

        _usdtToken.transfer(msg.sender, balance - _fees);

        _user.details.lastWithdrawalTimestamp = block.timestamp;

        _user.details.totalSelfRoiIncome += _selfRoiIncome;

        _user.details.withdrawalAmounts.push(balance);
        _user.details.withdrawalTimestamps.push(block.timestamp);

        _user.details.directIncome = 0;
        _user.details.generationIncome = 0;
        _user.details.totalWithdrawal += balance;

        totalWithdrawal += balance;

        emit WithdrawalHappened(msg.sender, balance, block.timestamp);

        distributeRewards(msg.sender);
    }
}
// SPDX-License-Identifier: MIT

pragma solidity ^0.8.12;

interface IBEP20 {
    /**
     * @dev Returns the amount of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the token decimals.
     */
    function decimals() external view returns (uint8);

    /**
     * @dev Returns the token symbol.
     */
    function symbol() external view returns (string memory);

    /**
     * @dev Returns the token name.
     */
    function name() external view returns (string memory);

    /**
     * @dev Returns the bep token owner.
     */
    function getOwner() external view returns (address);

    /**
     * @dev Returns the amount of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Moves `amount` tokens from the caller's account to `recipient`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(
        address recipient,
        uint256 amount
    ) external returns (bool);

    /**
     * @dev Returns the remaining number of tokens that `spender` will be
     * allowed to spend on behalf of `owner` through {transferFrom}. This is
     * zero by default.
     *
     * This value changes when {approve} or {transferFrom} are called.
     */
    function allowance(
        address _owner,
        address spender
    ) external view returns (uint256);

    /**
     * @dev Sets `amount` as the allowance of `spender` over the caller's tokens.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * IMPORTANT: Beware that changing an allowance with this method brings the risk
     * that someone may use both the old and the new allowance by unfortunate
     * transaction ordering. One possible solution to mitigate this race
     * condition is to first reduce the spender's allowance to 0 and set the
     * desired value afterwards:
     * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
     *
     * Emits an {Approval} event.
     */
    function approve(address spender, uint256 amount) external returns (bool);

    /**
     * @dev Moves `amount` tokens from `sender` to `recipient` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);

    /**
     * @dev Emitted when `value` tokens are moved from one account (`from`) to
     * another (`to`).
     *
     * Note that `value` may be zero.
     */
    event Transfer(address indexed from, address indexed to, uint256 value);

    /**
     * @dev Emitted when the allowance of a `spender` for an `owner` is set by
     * a call to {approve}. `value` is the new allowance.
     */
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
}

/*
 * @dev Provides information about the current execution context, including the
 * sender of the transaction and its data. While these are generally available
 * via msg.sender and msg.data, they should not be accessed in such a direct
 * manner, since when dealing with GSN meta-transactions the account sending and
 * paying for execution may not be the actual sender (as far as an application
 * is concerned).
 *
 * This contract is only required for intermediate, library-like contracts.
 */
contract Context {
    // Empty internal constructor, to prevent people from mistakenly deploying
    // an instance of this contract, which should be used via inheritance.
    constructor() {}

    function _msgSender() internal view returns (address) {
        return msg.sender;
    }

    function _msgData() internal view returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}

/**
 * @dev Wrappers over Solidity's arithmetic operations with added overflow
 * checks.
 *
 * Arithmetic operations in Solidity wrap on overflow. This can easily result
 * in bugs, because programmers usually assume that an overflow raises an
 * error, which is the standard behavior in high level programming languages.
 * `SafeMath` restores this intuition by reverting the transaction when an
 * operation overflows.
 *
 * Using this library instead of the unchecked operations eliminates an entire
 * class of bugs, so it's recommended to use it always.
 */
library SafeMath {
    /**
     * @dev Returns the addition of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `+` operator.
     *
     * Requirements:
     * - Addition cannot overflow.
     */
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting on
     * overflow (when the result is negative).
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     * - Subtraction cannot overflow.
     */
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return sub(a, b, "SafeMath: subtraction overflow");
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting with custom message on
     * overflow (when the result is negative).
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     * - Subtraction cannot overflow.
     */
    function sub(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        uint256 c = a - b;

        return c;
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `*` operator.
     *
     * Requirements:
     * - Multiplication cannot overflow.
     */
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
        // benefit is lost if 'b' is also tested.
        // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");

        return c;
    }

    /**
     * @dev Returns the integer division of two unsigned integers. Reverts on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator. Note: this function uses a
     * `revert` opcode (which leaves remaining gas untouched) while Solidity
     * uses an invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     * - The divisor cannot be zero.
     */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return div(a, b, "SafeMath: division by zero");
    }

    /**
     * @dev Returns the integer division of two unsigned integers. Reverts with custom message on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator. Note: this function uses a
     * `revert` opcode (which leaves remaining gas untouched) while Solidity
     * uses an invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     * - The divisor cannot be zero.
     */
    function div(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        // Solidity only automatically asserts when dividing by 0
        require(b > 0, errorMessage);
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold

        return c;
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * Reverts when dividing by zero.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     * - The divisor cannot be zero.
     */
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return mod(a, b, "SafeMath: modulo by zero");
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * Reverts with custom message when dividing by zero.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     * - The divisor cannot be zero.
     */
    function mod(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        require(b != 0, errorMessage);
        return a % b;
    }
}

/**
 * @dev Contract module which provides a basic access control mechanism, where
 * there is an account (an owner) that can be granted exclusive access to
 * specific functions.
 *
 * By default, the owner account will be the one that deploys the contract. This
 * can later be changed with {transferOwnership}.
 *
 * This module is used through inheritance. It will make available the modifier
 * `onlyOwner`, which can be applied to your functions to restrict their use to
 * the owner.
 */
contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor() {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(_owner == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    /**
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions anymore. Can only be called by the current owner.
     *
     * NOTE: Renouncing ownership will leave the contract without an owner,
     * thereby removing any functionality that is only available to the owner.
     */
    function renounceOwnership() public onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public onlyOwner {
        _transferOwnership(newOwner);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     */
    function _transferOwnership(address newOwner) internal {
        require(
            newOwner != address(0),
            "Ownable: new owner is the zero address"
        );
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

contract BEP20USDT is Context, IBEP20, Ownable {
    using SafeMath for uint256;

    mapping(address => uint256) private _balances;

    mapping(address => mapping(address => uint256)) private _allowances;

    uint256 private _totalSupply;
    uint8 public _decimals;
    string public _symbol;
    string public _name;

    constructor() {
        _name = "Tether USD";
        _symbol = "USDT";
        _decimals = 18;
        _totalSupply = 30000000000000000000000000;
        _balances[msg.sender] = _totalSupply;

        emit Transfer(address(0), msg.sender, _totalSupply);
    }

    /**
     * @dev Returns the bep token owner.
     */
    function getOwner() external view returns (address) {
        return owner();
    }

    /**
     * @dev Returns the token decimals.
     */
    function decimals() external view returns (uint8) {
        return _decimals;
    }

    /**
     * @dev Returns the token symbol.
     */
    function symbol() external view returns (string memory) {
        return _symbol;
    }

    /**
     * @dev Returns the token name.
     */
    function name() external view returns (string memory) {
        return _name;
    }

    /**
     * @dev See {BEP20-totalSupply}.
     */
    function totalSupply() external view returns (uint256) {
        return _totalSupply;
    }

    /**
     * @dev See {BEP20-balanceOf}.
     */
    function balanceOf(address account) external view returns (uint256) {
        return _balances[account];
    }

    /**
     * @dev See {BEP20-transfer}.
     *
     * Requirements:
     *
     * - `recipient` cannot be the zero address.
     * - the caller must have a balance of at least `amount`.
     */
    function transfer(
        address recipient,
        uint256 amount
    ) external returns (bool) {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    /**
     * @dev See {BEP20-allowance}.
     */
    function allowance(
        address owner,
        address spender
    ) external view returns (uint256) {
        return _allowances[owner][spender];
    }

    /**
     * @dev See {BEP20-approve}.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     */
    function approve(address spender, uint256 amount) external returns (bool) {
        _approve(_msgSender(), spender, amount);
        return true;
    }

    /**
     * @dev See {BEP20-transferFrom}.
     *
     * Emits an {Approval} event indicating the updated allowance. This is not
     * required by the EIP. See the note at the beginning of {BEP20};
     *
     * Requirements:
     * - `sender` and `recipient` cannot be the zero address.
     * - `sender` must have a balance of at least `amount`.
     * - the caller must have allowance for `sender`'s tokens of at least
     * `amount`.
     */
    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool) {
        _transfer(sender, recipient, amount);
        _approve(
            sender,
            _msgSender(),
            _allowances[sender][_msgSender()].sub(
                amount,
                "BEP20: transfer amount exceeds allowance"
            )
        );
        return true;
    }

    /**
     * @dev Atomically increases the allowance granted to `spender` by the caller.
     *
     * This is an alternative to {approve} that can be used as a mitigation for
     * problems described in {BEP20-approve}.
     *
     * Emits an {Approval} event indicating the updated allowance.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     */
    function increaseAllowance(
        address spender,
        uint256 addedValue
    ) public returns (bool) {
        _approve(
            _msgSender(),
            spender,
            _allowances[_msgSender()][spender].add(addedValue)
        );
        return true;
    }

    /**
     * @dev Atomically decreases the allowance granted to `spender` by the caller.
     *
     * This is an alternative to {approve} that can be used as a mitigation for
     * problems described in {BEP20-approve}.
     *
     * Emits an {Approval} event indicating the updated allowance.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     * - `spender` must have allowance for the caller of at least
     * `subtractedValue`.
     */
    function decreaseAllowance(
        address spender,
        uint256 subtractedValue
    ) public returns (bool) {
        _approve(
            _msgSender(),
            spender,
            _allowances[_msgSender()][spender].sub(
                subtractedValue,
                "BEP20: decreased allowance below zero"
            )
        );
        return true;
    }

    /**
     * @dev Creates `amount` tokens and assigns them to `msg.sender`, increasing
     * the total supply.
     *
     * Requirements
     *
     * - `msg.sender` must be the token owner
     */
    function mint(uint256 amount) public onlyOwner returns (bool) {
        _mint(_msgSender(), amount);
        return true;
    }

    /**
     * @dev Burn `amount` tokens and decreasing the total supply.
     */
    function burn(uint256 amount) public returns (bool) {
        _burn(_msgSender(), amount);
        return true;
    }

    /**
     * @dev Moves tokens `amount` from `sender` to `recipient`.
     *
     * This is internal function is equivalent to {transfer}, and can be used to
     * e.g. implement automatic token fees, slashing mechanisms, etc.
     *
     * Emits a {Transfer} event.
     *
     * Requirements:
     *
     * - `sender` cannot be the zero address.
     * - `recipient` cannot be the zero address.
     * - `sender` must have a balance of at least `amount`.
     */
    function _transfer(
        address sender,
        address recipient,
        uint256 amount
    ) internal {
        require(sender != address(0), "BEP20: transfer from the zero address");
        require(recipient != address(0), "BEP20: transfer to the zero address");

        _balances[sender] = _balances[sender].sub(
            amount,
            "BEP20: transfer amount exceeds balance"
        );
        _balances[recipient] = _balances[recipient].add(amount);
        emit Transfer(sender, recipient, amount);
    }

    /** @dev Creates `amount` tokens and assigns them to `account`, increasing
     * the total supply.
     *
     * Emits a {Transfer} event with `from` set to the zero address.
     *
     * Requirements
     *
     * - `to` cannot be the zero address.
     */
    function _mint(address account, uint256 amount) internal {
        require(account != address(0), "BEP20: mint to the zero address");

        _totalSupply = _totalSupply.add(amount);
        _balances[account] = _balances[account].add(amount);
        emit Transfer(address(0), account, amount);
    }

    /**
     * @dev Destroys `amount` tokens from `account`, reducing the
     * total supply.
     *
     * Emits a {Transfer} event with `to` set to the zero address.
     *
     * Requirements
     *
     * - `account` cannot be the zero address.
     * - `account` must have at least `amount` tokens.
     */
    function _burn(address account, uint256 amount) internal {
        require(account != address(0), "BEP20: burn from the zero address");

        _balances[account] = _balances[account].sub(
            amount,
            "BEP20: burn amount exceeds balance"
        );
        _totalSupply = _totalSupply.sub(amount);
        emit Transfer(account, address(0), amount);
    }

    /**
     * @dev Sets `amount` as the allowance of `spender` over the `owner`s tokens.
     *
     * This is internal function is equivalent to `approve`, and can be used to
     * e.g. set automatic allowances for certain subsystems, etc.
     *
     * Emits an {Approval} event.
     *
     * Requirements:
     *
     * - `owner` cannot be the zero address.
     * - `spender` cannot be the zero address.
     */
    function _approve(address owner, address spender, uint256 amount) internal {
        require(owner != address(0), "BEP20: approve from the zero address");
        require(spender != address(0), "BEP20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    /**
     * @dev Destroys `amount` tokens from `account`.`amount` is then deducted
     * from the caller's allowance.
     *
     * See {_burn} and {_approve}.
     */
    function _burnFrom(address account, uint256 amount) internal {
        _burn(account, amount);
        _approve(
            account,
            _msgSender(),
            _allowances[account][_msgSender()].sub(
                amount,
                "BEP20: burn amount exceeds allowance"
            )
        );
    }
}
