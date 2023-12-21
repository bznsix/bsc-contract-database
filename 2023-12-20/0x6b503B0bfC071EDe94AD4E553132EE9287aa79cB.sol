// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

interface IERC20 {
    function balanceOf(address account) external view returns (uint256);

    function transfer(address to, uint256 amount) external returns (bool);

    function allowance(address owner, address spender)
        external
        view
        returns (uint256);

    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);
}

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }
}

abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );

    constructor() {
        _setOwner(_msgSender());
    }

    function owner() public view virtual returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(
            newOwner != address(0),
            "Ownable: new owner is the zero address"
        );
        _setOwner(newOwner);
    }

    function _setOwner(address newOwner) internal {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}

abstract contract Pausable is Context {
    event Paused(address account);

    event Unpaused(address account);

    bool private _paused;

    constructor() {
        _paused = false;
    }

    modifier whenNotPaused() {
        _requireNotPaused();
        _;
    }

    modifier whenPaused() {
        _requirePaused();
        _;
    }

    function paused() public view virtual returns (bool) {
        return _paused;
    }

    function _requireNotPaused() internal view virtual {
        require(!paused(), "Pausable: paused");
    }

    function _requirePaused() internal view virtual {
        require(paused(), "Pausable: not paused");
    }

    function _pause() internal virtual whenNotPaused {
        _paused = true;
        emit Paused(_msgSender());
    }

    function _unpause() internal virtual whenPaused {
        _paused = false;
        emit Unpaused(_msgSender());
    }
}

interface TokenPriceInterface {
    function getTokenPrice() external view returns (uint256);
}

contract Staking is Ownable, Pausable {
    IERC20 public token;
    uint256 public DailyEarning = 40;
    uint256 public minimumDeposit = 30 ether;

    TokenPriceInterface public tokenPriceContract;
    event Withdrawal(address indexed user, uint256 amount);

    constructor() {
        token = IERC20(0xbf035D8f65b804963a8131B4779863e2541Bd91E);
        tokenPriceContract = TokenPriceInterface(
            0x285DA06f3eeBA9eE2708Cac46ecD5Aab0A932D45
        );
    }

    struct depoite {
        uint256 amount;
        uint256 depositeTime;
        uint256 checkTime;
        uint256 withdrawTime;
    }

    struct User {
        depoite[] deposites;
        address refferAddress;
        uint256 refferReward;
        uint256 withdrawReward;
        uint256 timestamp;
    }

    mapping(address => User) public investment;
    mapping(address => bool) public isExits;
    mapping(address => address[]) myDirectReferrals;

    uint256[] level = [15, 10, 5, 3, 2, 1];

    function pause() external onlyOwner returns (bool success) {
        _pause();
        return true;
    }

    function unpause() external onlyOwner returns (bool success) {
        _unpause();
        return true;
    }

    function withdrawTokens(address _token, uint256 amount) external onlyOwner {
        require(isContract(_token), "Invalid contract address");
        require(
            IERC20(_token).balanceOf(address(this)) >= amount,
            "Insufficient tokens"
        );
        IERC20(_token).transfer(_msgSender(), amount);
    }

    function isContract(address _addr) private view returns (bool iscontract) {
        uint32 size;
        assembly {
            size := extcodesize(_addr)
        }
        return (size > 0);
    }

    function changeEarning(uint256 _apy) external onlyOwner {
        require(_apy > 0, " Invalid earning");
        DailyEarning = _apy;
    }

    modifier checkParameter(uint256 amount) {
        require(
            tokenToUsdPrice(amount) >= minimumDeposit,
            "Min deposit amount"
        );
        _;
    }

    function importData(
        address[] memory _users,
        uint256[] memory amount,
        uint256[] memory time,
        uint256[] memory _updatedTime,
        address[] memory _referrer,
        uint256[] memory _referralAmount,
        uint256[] memory _withdrawAmount,
        address[][] memory _myDirectReferrals
    ) external onlyOwner {
        uint256 index = _users.length;
        for (uint256 i = 0; i < index; i++) {
            User storage users = investment[_users[i]];
            users.deposites.push(
                depoite(amount[i], time[i], _updatedTime[i], 500 days)
            );
            users.refferAddress = _referrer[i];
            users.refferReward = _referralAmount[i];
            users.withdrawReward = _withdrawAmount[i];
            users.timestamp = time[i];
            isExits[_users[i]] = true;
            for (uint256 j = 0; j < _myDirectReferrals[i].length; j++) {
                myDirectReferrals[_users[i]].push(_myDirectReferrals[i][j]);
            }
        }
    }

    function invest(uint256 amount, address referrer)
        public
        checkParameter(amount)
        whenNotPaused
        returns (bool)
    {
        User storage users = investment[msg.sender];
        require(
            amount <= token.allowance(msg.sender, address(this)),
            "Insufficient Allowence to the contract"
        );
        token.transferFrom(msg.sender, address(this), amount);
        if (
            referrer != address(0) &&
            referrer != _msgSender() &&
            isExits[referrer] &&
            !isExits[_msgSender()]
        ) {
            users.refferAddress = referrer;
            myDirectReferrals[referrer].push(_msgSender());
        }
        users.timestamp = block.timestamp;
        users.deposites.push(
            depoite(amount, block.timestamp, block.timestamp, 500 days)
        );
        isExits[_msgSender()] = true;
        distributeReferralsReward(_msgSender(), amount);
        return true;
    }

    function removeId(uint256 indexnum) internal {
        for (
            uint256 i = indexnum;
            i < investment[_msgSender()].deposites.length - 1;
            i++
        ) {
            investment[_msgSender()].deposites[i] = investment[_msgSender()]
                .deposites[i + 1];
        }
        investment[_msgSender()].deposites.pop();
    }

    function unStake() external returns (bool) {
        User memory users = investment[_msgSender()];
        require(users.deposites.length > 0, "No deposit amount");
        uint256 amount;
        for (uint256 i = 0; i < users.deposites.length; i++) {
            uint256 withdrawTime = users.deposites[i].depositeTime +
                users.deposites[i].withdrawTime;
            if (withdrawTime < block.timestamp) {
                uint256 rewards = calculateRewardSpecificId(_msgSender(), i);
                amount += users.deposites[i].amount + rewards;
                removeId(i);
            }
        }
        if (amount > 0) {
            transactions(amount);
        } else revert("Unstake time is not reached");
        return true;
    }

    function withdrawReferralsReward() external returns (bool) {
        User storage users = investment[_msgSender()];
        require(users.refferReward > 0, "Referrals reward not found!");
        transactions(users.refferReward);
        users.refferReward = 0;
        return true;
    }

    function withdrawRewards() external returns (bool) {
        User storage users = investment[_msgSender()];
        uint256 totalRewards = calculateRewards(msg.sender);
        require(totalRewards > 0, "No Rewards Found");
        require(
            totalRewards <= token.balanceOf(address(this)),
            "Not Enough Token for withdrwal from contract please try after some time"
        );
        for (uint256 i = 0; i < users.deposites.length; i++) {
            users.deposites[i].checkTime = block.timestamp;
        }
        transactions(totalRewards);
        return true;
    }

    function calculateRewards(address _user) public view returns (uint256) {
        User memory users = investment[_user];
        uint256 rewards;
        for (uint256 i = 0; i < users.deposites.length; i++) {
            uint256 time = block.timestamp - users.deposites[i].checkTime;
            rewards +=
                (users.deposites[i].amount * (DailyEarning) * time) /
                1 days /
                10000;
        }
        uint256 totalAmountWithdraw = users.withdrawReward +
            rewards +
            users.refferReward;
        uint256 depositAmount = getUserTotalDeposits(_user);
        if (totalAmountWithdraw >= 4 * depositAmount) {
            rewards =
                4 *
                depositAmount -
                users.withdrawReward -
                users.refferReward;
        }
        return rewards;
    }

    function calculateRewardSpecificId(address _user, uint256 id)
        private
        view
        returns (uint256)
    {
        User memory users = investment[_user];
        uint256 time = block.timestamp - users.deposites[id].checkTime;
        uint256 rewards = (users.deposites[id].amount * (DailyEarning) * time) /
            1 days /
            10000;

        uint256 totalAmountWithdraw = users.withdrawReward +
            rewards +
            users.refferReward;
        uint256 depositAmount = getUserTotalDeposits(_user);
        if (totalAmountWithdraw >= 4 * depositAmount) {
            rewards =
                4 *
                depositAmount -
                users.withdrawReward -
                users.refferReward;
        }
        return rewards;
    }

    function getUserDepositeHistory(address _user)
        public
        view
        returns (uint256[] memory, uint256[] memory)
    {
        uint256[] memory amount = new uint256[](
            investment[_user].deposites.length
        );
        uint256[] memory time = new uint256[](
            investment[_user].deposites.length
        );
        for (uint256 i = 0; i < investment[_user].deposites.length; i++) {
            amount[i] = investment[_user].deposites[i].amount;
            time[i] = investment[_user].deposites[i].depositeTime;
        }
        return (amount, time);
    }

    function transactions(uint256 amount) private {
        User storage users = investment[_msgSender()];
        uint256 totalAmountWithdraw = users.withdrawReward + amount;
        uint256 depositAmount = getUserTotalDeposits(_msgSender());
        if (totalAmountWithdraw >= 4 * depositAmount) {
            amount = 4 * depositAmount - users.withdrawReward;
            token.transfer(_msgSender(), amount);
            delete users.deposites;
            delete investment[_msgSender()];
            delete myDirectReferrals[_msgSender()];
            isExits[_msgSender()] = false;
        } else {
            token.transfer(_msgSender(), amount);
            users.withdrawReward += amount;
        }
        emit Withdrawal(msg.sender, amount);
    }

    function getUserTotalDeposits(address _user)
        public
        view
        returns (uint256 _totalInvestment)
    {
        for (uint256 i = 0; i < investment[_user].deposites.length; i++) {
            _totalInvestment =
                _totalInvestment +
                investment[_user].deposites[i].amount;
        }
    }

    function getmyDirectReferrals(address _user)
        public
        view
        returns (address[] memory)
    {
        return myDirectReferrals[_user];
    }

    function distributeReferralsReward(address _user, uint256 amount) private {
        address referral = investment[_user].refferAddress;
        for (uint256 i = 0; i < 15; i++) {
            if (referral != address(0) && isExits[referral]) {
                User storage users = investment[referral];
                uint256 roiRewards = calculateRewards(referral);
                if (i < 5) {
                    uint256 refferReward = (amount * level[i]) / 100;
                    uint256 totalAmountWithdraw = users.withdrawReward +
                        users.refferReward +
                        refferReward +
                        roiRewards;
                    uint256 depositAmount = getUserTotalDeposits(referral);
                    if (totalAmountWithdraw >= 4 * depositAmount) {
                        refferReward =
                            4 *
                            depositAmount -
                            users.withdrawReward -
                            users.refferReward -
                            roiRewards;
                        users.refferReward += refferReward;
                    } else users.refferReward += refferReward;
                } else {
                    uint256 refferReward = (amount * level[5]) / 100;
                    uint256 totalAmountWithdraw = users.withdrawReward +
                        users.refferReward +
                        refferReward +
                        roiRewards;
                    uint256 depositAmount = getUserTotalDeposits(referral);
                    if (totalAmountWithdraw >= 4 * depositAmount) {
                        refferReward =
                            4 *
                            depositAmount -
                            users.withdrawReward -
                            users.refferReward -
                            roiRewards;
                        users.refferReward += refferReward;
                    } else users.refferReward += refferReward;
                }
                referral = users.refferAddress;
            } else break;
        }
    }

    function getTokenPrice() public view returns (uint256) {
        return tokenPriceContract.getTokenPrice(); // 2 decimals
    }

    function tokenToUsdPrice(uint256 amount) public view returns (uint256) {
        uint256 tokens = (amount * 100) / getTokenPrice();
        return tokens;
    }

    function usdToTokens(uint256 amount) public view returns (uint256) {
        uint256 tokens = (amount * getTokenPrice()) / 100;
        return tokens;
    }

    function teamBusinessAmounts(address _user) public view returns (uint256) {
        uint256 amount;
        for (uint24 i = 0; i < getTeamLength(_user); i++) {
            address referralAddress = myDirectReferrals[_user][i];
            amount += getUserTotalDeposits(referralAddress);
            amount += teamBusinessAmount(referralAddress);
        }
        return tokenToUsdPrice(amount);
    }

    function teamBusinessAmount(address _user) private view returns (uint256) {
        uint256 amount;
        for (uint24 i = 0; i < getTeamLength(_user); i++) {
            amount += getUserTotalDeposits(myDirectReferrals[_user][i]);
            address firstUser = myDirectReferrals[_user][i];
            for (uint24 i1 = 0; i1 < getTeamLength(firstUser); i1++) {
                amount += getUserTotalDeposits(
                    myDirectReferrals[firstUser][i1]
                );
                address secondUser = myDirectReferrals[firstUser][i1];
                for (uint24 i2 = 0; i2 < getTeamLength(secondUser); i2++) {
                    amount += getUserTotalDeposits(
                        myDirectReferrals[secondUser][i2]
                    );
                    address thirdUser = myDirectReferrals[secondUser][i2];
                    for (uint24 i3 = 0; i3 < getTeamLength(thirdUser); i3++) {
                        amount += getUserTotalDeposits(
                            myDirectReferrals[thirdUser][i3]
                        );
                        address fourthUser = myDirectReferrals[thirdUser][i3];
                        for (
                            uint24 i4 = 0;
                            i4 < getTeamLength(fourthUser);
                            i4++
                        ) {
                            amount += getUserTotalDeposits(
                                myDirectReferrals[fourthUser][i4]
                            );
                            address fifthUser = myDirectReferrals[fourthUser][
                                i4
                            ];
                            for (
                                uint24 i5 = 0;
                                i5 < getTeamLength(fifthUser);
                                i5++
                            ) {
                                amount += getUserTotalDeposits(
                                    myDirectReferrals[fifthUser][i5]
                                );
                                address sixthUser = myDirectReferrals[
                                    fifthUser
                                ][i5];
                                for (
                                    uint24 i6 = 0;
                                    i6 < getTeamLength(sixthUser);
                                    i6++
                                ) {
                                    amount += getUserTotalDeposits(
                                        myDirectReferrals[sixthUser][i6]
                                    );
                                    address seventhUser = myDirectReferrals[
                                        sixthUser
                                    ][i6];
                                    amount += teamBusinessAmount2(seventhUser);
                                }
                            }
                        }
                    }
                }
            }
        }
        return (amount);
    }

    function teamBusinessAmount2(address _user) private view returns (uint256) {
        uint256 amount;
        for (uint24 i = 0; i < getTeamLength(_user); i++) {
            amount += getUserTotalDeposits(myDirectReferrals[_user][i]);
            address firstUser = myDirectReferrals[_user][i];
            for (uint24 i1 = 0; i1 < getTeamLength(firstUser); i1++) {
                amount += getUserTotalDeposits(
                    myDirectReferrals[firstUser][i1]
                );
                address secondUser = myDirectReferrals[firstUser][i1];
                for (uint24 i2 = 0; i2 < getTeamLength(secondUser); i2++) {
                    amount += getUserTotalDeposits(
                        myDirectReferrals[secondUser][i2]
                    );
                    address thirdUser = myDirectReferrals[secondUser][i2];
                    for (uint24 i3 = 0; i3 < getTeamLength(thirdUser); i3++) {
                        amount += getUserTotalDeposits(
                            myDirectReferrals[thirdUser][i3]
                        );
                        address fourthUser = myDirectReferrals[thirdUser][i3];
                        for (
                            uint24 i4 = 0;
                            i4 < getTeamLength(fourthUser);
                            i4++
                        ) {
                            amount += getUserTotalDeposits(
                                myDirectReferrals[fourthUser][i4]
                            );
                            address fifthUser = myDirectReferrals[fourthUser][
                                i4
                            ];
                            for (
                                uint24 i5 = 0;
                                i5 < getTeamLength(fifthUser);
                                i5++
                            ) {
                                amount += getUserTotalDeposits(
                                    myDirectReferrals[fifthUser][i5]
                                );
                                address sixthUser = myDirectReferrals[
                                    fifthUser
                                ][i5];
                                for (
                                    uint24 i6 = 0;
                                    i6 < getTeamLength(sixthUser);
                                    i6++
                                ) {
                                    amount += getUserTotalDeposits(
                                        myDirectReferrals[fifthUser][i6]
                                    );
                                }
                            }
                        }
                    }
                }
            }
        }
        return (amount);
    }

    function getTeamLength(address _user) public view returns (uint256) {
        return myDirectReferrals[_user].length;
    }

    function totalWithdrawRewards(address _user)
        public
        view
        returns (uint256 amount)
    {
        User memory users = investment[_user];
        amount = users.withdrawReward;
    }

    function getReferralsReward(address _user) public view returns (uint256) {
        User memory users = investment[_user];
        return users.refferReward;
    }

    struct group {
        bool step1;
        bool step2;
        bool step3;
        bool step4;
        bool step5;
        bool step6;
        bool step7;
        bool step8;
    }

    mapping(address => group) incomeGroup;

    function claimRewardsIncome() external {
        address user = msg.sender;
        User memory users = investment[user];
        uint256 amount = teamBusinessAmounts(user);
        bool claimStatus;
        uint256 businessAmount;
        require(
            amount >= 1000 ether,
            "Minimum total business requirement not met"
        );
        if (amount >= 1500000 ether && !incomeGroup[user].step1) {
            incomeGroup[user].step1 = true;
            businessAmount += usdToTokens(20000 ether);
            claimStatus = true;
        }
        if (
            amount >= 700000 ether &&
            amount < 1500000 ether &&
            !incomeGroup[user].step2
        ) {
            incomeGroup[user].step2 = true;
            businessAmount += usdToTokens(10000 ether);
            claimStatus = true;
        }
        if (
            amount >= 300000 ether &&
            amount < 700000 ether &&
            !incomeGroup[user].step3
        ) {
            incomeGroup[user].step3 = true;
            businessAmount += usdToTokens(5000 ether);
            claimStatus = true;
        }
        if (
            amount >= 150000 ether &&
            amount < 300000 ether &&
            !incomeGroup[user].step4
        ) {
            incomeGroup[user].step4 = true;
            businessAmount += usdToTokens(2000 ether);
            claimStatus = true;
        }
        if (
            amount >= 50000 ether &&
            amount < 150000 ether &&
            !incomeGroup[user].step5
        ) {
            incomeGroup[user].step5 = true;
            businessAmount += usdToTokens(1000 ether);
            claimStatus = true;
        }
        if (
            amount >= 25000 ether &&
            amount < 50000 ether &&
            !incomeGroup[user].step6
        ) {
            incomeGroup[user].step6 = true;
            businessAmount += usdToTokens(500 ether);
            claimStatus = true;
        }
        if (
            amount >= 5000 ether &&
            amount < 25000 ether &&
            !incomeGroup[user].step7
        ) {
            incomeGroup[user].step7 = true;
            businessAmount += usdToTokens(200 ether);
            claimStatus = true;
        }
        if (
            amount >= 1000 ether &&
            amount < 5000 ether &&
            !incomeGroup[user].step8
        ) {
            incomeGroup[user].step8 = true;
            businessAmount += usdToTokens(50 ether);
            claimStatus = true;
        }
        uint256 roiRewards = calculateRewards(user);
        uint256 totalAmountWithdraw = users.withdrawReward +
            users.refferReward +
            businessAmount +
            roiRewards;
        uint256 depositAmount = getUserTotalDeposits(user);
        if (totalAmountWithdraw >= 4 * depositAmount) {
            businessAmount =
                4 *
                depositAmount -
                users.withdrawReward -
                users.refferReward -
                roiRewards;
        }

        if (businessAmount > 0) {
            transactions(businessAmount);
        } else revert("No bonus prizes received!");

        require(claimStatus, "Minimum total business requirement not met");
    }

    function bonusStatus(address user) external view returns (bool) {
        uint256 amount = teamBusinessAmounts(user);
        User memory users = investment[user];
        bool claimStatus;
        if (amount >= 1500000 ether && !incomeGroup[user].step1) {
            claimStatus = true;
        }
        if (
            amount >= 700000 ether &&
            amount < 1500000 ether &&
            !incomeGroup[user].step2
        ) {
            claimStatus = true;
        }
        if (
            amount >= 300000 ether &&
            amount < 700000 ether &&
            !incomeGroup[user].step3
        ) {
            claimStatus = true;
        }
        if (
            amount >= 150000 ether &&
            amount < 300000 ether &&
            !incomeGroup[user].step4
        ) {
            claimStatus = true;
        }
        if (
            amount >= 50000 ether &&
            amount < 150000 ether &&
            !incomeGroup[user].step5
        ) {
            claimStatus = true;
        }
        if (
            amount >= 25000 ether &&
            amount < 50000 ether &&
            !incomeGroup[user].step6
        ) {
            claimStatus = true;
        }
        if (
            amount >= 5000 ether &&
            amount < 25000 ether &&
            !incomeGroup[user].step7
        ) {
            claimStatus = true;
        }
        if (
            amount >= 1000 ether &&
            amount < 5000 ether &&
            !incomeGroup[user].step8
        ) {
            claimStatus = true;
        }
        uint256 totalAmountWithdraw = users.withdrawReward +
            users.refferReward +
            calculateRewards(user);
        uint256 depositAmount = getUserTotalDeposits(user);
        if (totalAmountWithdraw >= 4 * depositAmount) {
            claimStatus = false;
        }
        return claimStatus;
    }
}