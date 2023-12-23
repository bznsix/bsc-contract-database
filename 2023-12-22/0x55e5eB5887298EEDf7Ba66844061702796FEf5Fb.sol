// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

interface IERC20 {
    function balanceOf(address account) external view returns (uint256);

    function transfer(address to, uint256 amount) external returns (bool);

    function allowance(
        address owner,
        address spender
    ) external view returns (uint256);

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

    constructor(address newOwner) {
        _setOwner(newOwner);
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

contract RexxStaking is Ownable, Pausable {
    IERC20 public token;
    IERC20 public usdt;

    address public paymentWallet;
    uint256 public tokenPrice;

    uint256[] public referralPercentage = [3, 2, 1];

    event NewDeposit(address indexed user, uint256 amount, uint256 timestamp);
    event WithdrawReferralRewards(
        address indexed user,
        uint256 amount,
        uint256 timestamp
    );

    event WithdrawCapitals(
        address indexed user,
        uint256 amount,
        uint256 timestamp
    );

    constructor() Ownable(_msgSender()) {
        initialize();
    }

    struct activity {
        address user;
        string _event;
        uint256 amount;
        uint256 time;
    }

    struct Users {
        address referrer;
        uint256 refferReward;
        uint256 directBonus;
        uint256 indirectBonus;
        address[] referrals;
        uint256[] timestamp;
    }

    struct plans {
        string name;
        uint256 amount;
        uint256 apy;
        uint256 addPlanTimestamp;
        bool paused;
    }

    struct user {
        uint256 step;
        uint256 price;
        uint256 depositTime;
        uint256 timestamp;
    }
    mapping(address => user[]) public investment;
    mapping(address => Users) public userRewards;
    plans[] public plansData;
    activity[] public activities;

    mapping(address => bool) public isExits;
    mapping(address => bool) public is1stBonusClaim;
    mapping(address => bool) public is2ndBonusClaim;

    function removeId(uint256 indexnum) internal {
        for (
            uint256 i = indexnum;
            i < investment[_msgSender()].length - 1;
            i++
        ) {
            investment[_msgSender()][i] = investment[_msgSender()][i + 1];
        }
        investment[_msgSender()].pop();
    }

    function initialize() private {
        token = IERC20(0x1C07B56d1765D15Aa9d28C5e6cfe2cC2A765b27b);
        usdt = IERC20(0x55d398326f99059fF775485246999027B3197955);
        paymentWallet = owner();
        tokenPrice = 1;
        plansData.push(
            plans({
                name: "Starter",
                amount: 100 ether,
                apy: 800,
                paused: false,
                addPlanTimestamp: block.timestamp
            })
        );
        plansData.push(
            plans({
                name: "Standard",
                amount: 500 ether,
                apy: 800,
                paused: false,
                addPlanTimestamp: block.timestamp
            })
        );
        plansData.push(
            plans({
                name: "Premium",
                amount: 1000 ether,
                apy: 1000,
                paused: false,
                addPlanTimestamp: block.timestamp
            })
        );
        plansData.push(
            plans({
                name: "Master",
                amount: 2000 ether,
                apy: 1000,
                paused: false,
                addPlanTimestamp: block.timestamp
            })
        );
        plansData.push(
            plans({
                name: "Master Pro",
                amount: 3000 ether,
                apy: 1100,
                paused: false,
                addPlanTimestamp: block.timestamp
            })
        );
        plansData.push(
            plans({
                name: "Executive",
                amount: 5000 ether,
                apy: 1200,
                paused: false,
                addPlanTimestamp: block.timestamp
            })
        );
    }

    function changePaymentWallet(address _newPaymentWallet) external onlyOwner {
        require(_newPaymentWallet != address(0), "address cannot be zero");
        require(
            _newPaymentWallet != paymentWallet,
            "This address is already fixed"
        );
        paymentWallet = _newPaymentWallet;
    }

    function addNewPlan(
        string calldata name,
        uint256 amount,
        uint256 apy
    ) external onlyOwner returns (bool) {
        require(amount > 0 && apy > 0, "Invalid arguments");
        plansData.push(
            plans({
                name: name,
                amount: amount,
                apy: apy,
                paused: false,
                addPlanTimestamp: block.timestamp
            })
        );
        return true;
    }

    function changeTokenPrice(uint256 _newPrice) external onlyOwner {
        require(_newPrice > 0, "invalid price");
        tokenPrice = _newPrice;
    }

    function pausedPlan(uint256 _step) external onlyOwner {
        require(!plansData[_step].paused, "Plan is already inactive");
        plansData[_step].paused = true;
    }

    function unpausedPlan(uint256 _step) external onlyOwner {
        require(plansData[_step].paused, "Plan is already active");
        plansData[_step].paused = false;
    }

    function pause() external onlyOwner returns (bool success) {
        _pause();
        return true;
    }

    function unpause() external onlyOwner returns (bool success) {
        _unpause();
        return true;
    }

    function getTokenBalance(address _token) public view returns (uint256) {
        IERC20 newToken = IERC20(_token);
        return newToken.balanceOf(address(this));
    }

    function getContractBalanceUsdt() public view returns (uint256) {
        return usdt.balanceOf(address(this));
    }

    function withdrawTokens(
        address _token,
        uint256 _amount
    ) external onlyOwner {
        require(_token != address(0), "token address is null");
        IERC20 newToken = IERC20(_token);
        require(
            _amount > 0 && newToken.balanceOf(address(this)) >= _amount,
            "Amount should not be zero or more than contract"
        );
        newToken.transfer(_msgSender(), _amount);
    }

    modifier checkPlans(uint256 step) {
        require(step < plansData.length, "Invalid step");
        require(!plansData[step].paused, "This plan is currently inactive");
        _;
    }

    modifier withdrawCheck(uint256 id) {
        user memory users = investment[_msgSender()][id];
        require(id < investment[_msgSender()].length, "Invalid enter Id");
        _;
    }

    function invest(
        uint8 step,
        address _referral
    ) external checkPlans(step) whenNotPaused {
        uint256 amount = plansData[step].amount;
        uint256 ourAllowance = usdt.allowance(_msgSender(), address(this));
        require(
            amount <= ourAllowance,
            "Make sure to add enough allowance of usdt"
        );
        usdt.transferFrom(_msgSender(), address(this), amount);

        investment[_msgSender()].push(
            user({
                step: step,
                price: tokenPrice,
                depositTime: block.timestamp,
                timestamp: block.timestamp
            })
        );
        if (
            !isExits[_msgSender()] &&
            _referral != address(0) &&
            _referral != _msgSender() &&
            isExits[_referral]
        ) {
            userRewards[_msgSender()].referrer = _referral;
            userRewards[_referral].referrals.push(_msgSender());
            userRewards[_referral].timestamp.push(block.timestamp);
        }
        saveActivity("Invest", amount);
        distributeReferralsReward(_msgSender(), amount);
        isExits[_msgSender()] = true;
        emit NewDeposit(_msgSender(), amount, block.timestamp);
    }

    function distributeReferralsReward(address _user, uint256 amount) private {
        address directAddress = userRewards[_user].referrer;
        if (directAddress != address(0)) {
            referralsDistribute(directAddress, amount / 10);
            userRewards[directAddress].refferReward += amount / 10;
            address referral = userRewards[directAddress].referrer;
            for (uint256 i = 0; i < 5; i++) {
                if (referral != address(0)) {
                    if (i < 2) {
                        uint256 amount1 = (amount * referralPercentage[i]) /
                            100;
                        userRewards[referral].refferReward +=
                            (amount * referralPercentage[i]) /
                            100;
                        referralsDistribute(referral, amount1);
                    } else {
                        userRewards[referral].refferReward +=
                            (amount * referralPercentage[2]) /
                            100;
                        referralsDistribute(
                            referral,
                            (amount * referralPercentage[2]) / 100
                        );
                    }
                    referral = userRewards[referral].referrer;
                } else break;
            }
        }
    }

    function referralsDistribute(address referrer, uint256 amount) private {
        if (referrer != address(0)) {
            uint256 usdtRewards = (amount * 7) / 10;
            uint256 rexRewards = usdTToTokens(amount * 3, tokenPrice) / 10;
            usdt.transfer(referrer, usdtRewards);
            token.transfer(referrer, rexRewards);
            userRewards[referrer].directBonus += usdtRewards;
            userRewards[referrer].indirectBonus += rexRewards;
        }
    }

    function withdrawTeamBonus() external returns (bool) {
        require(isExits[_msgSender()], "You are not registered on this site.");
        uint256 teamVolume = totalBusinessUsdt(_msgSender());
        uint256 amount;
        if (
            !is1stBonusClaim[_msgSender()] &&
            teamVolume > 5000 ether &&
            teamVolume <= 10000 ether
        ) {
            amount = 100 ether;
            is1stBonusClaim[_msgSender()] = true;
        } else if (!is2ndBonusClaim[_msgSender()] && teamVolume > 10000 ether) {
            amount = 200 ether;
            is2ndBonusClaim[_msgSender()] = true;
        } else revert("You con't withdraw");
        bool success = usdt.transfer(_msgSender(), amount);
        saveActivity("Withdraw Team Bonus", amount);
        return success;
    }

    function withdrawRewards(uint256 id) external returns (bool) {
        user storage users = investment[_msgSender()][id];
        uint256 rewards = usdTToTokens(
            calculateReward(_msgSender(), id),
            users.price
        );
        require(rewards > 0, "No rewards found|");
        bool success = token.transfer(_msgSender(), rewards);
        users.timestamp = block.timestamp;
        saveActivity("Withdraw rewards", rewards);
        return success;
    }

    function withdrawCapital(
        uint256 id
    ) external whenNotPaused withdrawCheck(id) returns (bool success) {
        user memory users = investment[_msgSender()][id];
        uint256 withdrawalAmount = usdTToTokens(
            (plansData[users.step].amount + calculateReward(_msgSender(), id)),
            users.price
        );
        token.transfer(_msgSender(), withdrawalAmount);
        saveActivity("UnStake", withdrawalAmount);
        emit WithdrawCapitals(_msgSender(), withdrawalAmount, block.timestamp);
        removeId(id);
        return true;
    }

    function calculateRewards(address _user) public view returns (uint256) {
        uint256 rewards;
        uint256 DIVIDER = 10000;
        for (uint256 i = 0; i < investment[_user].length; i++) {
            user memory users = investment[_user][i];
            uint256 time = block.timestamp - users.timestamp;
            rewards +=
                (plansData[users.step].amount *
                    plansData[users.step].apy *
                    time) /
                DIVIDER /
                30.44 days;
        }
        return rewards;
    }

    function calculateReward(
        address _user,
        uint256 id
    ) public view returns (uint256 usdtRewards) {
        require(id < investment[_user].length, "Invalid Id");
        user memory users = investment[_user][id];
        uint256 time = block.timestamp - users.timestamp;
        uint256 DIVIDER = 10000;
        usdtRewards =
            (plansData[users.step].amount * plansData[users.step].apy * time) /
            DIVIDER /
            30.44 days;

        return (usdtRewards);
    }

    function usdTToTokens(
        uint256 _usdtAmount,
        uint256 _price
    ) public pure returns (uint256) {
        uint256 numOfTokens = _usdtAmount * 100;
        return (numOfTokens / _price);
    }

    function totalBusinessUsdt(address _user) public view returns (uint256) {
        uint256 amount;
        for (uint256 i = 0; i < getTeamLength(_user); i++) {
            address referralAddress = userRewards[_user].referrals[i];
            amount += depositAddAmount(referralAddress);
            for (uint256 i1 = 0; i1 < getTeamLength(referralAddress); i1++) {
                address firstUser = userRewards[referralAddress].referrals[i1];
                amount += depositAddAmount(firstUser);
                for (uint8 j = 0; j < getTeamLength(firstUser); j++) {
                    address secondUser = userRewards[firstUser].referrals[j];
                    amount += depositAddAmount(secondUser);
                    for (uint8 k = 0; k < getTeamLength(secondUser); k++) {
                        address thirdUser = userRewards[secondUser].referrals[
                            k
                        ];
                        amount += depositAddAmount(thirdUser);
                        for (uint8 n = 0; n < getTeamLength(thirdUser); n++) {
                            address fourthUser = userRewards[thirdUser]
                                .referrals[n];
                            amount += depositAddAmount(fourthUser);
                            for (
                                uint8 p = 0;
                                p < getTeamLength(fourthUser);
                                p++
                            ) {
                                address fifthUser = userRewards[fourthUser]
                                    .referrals[p];
                                amount += depositAddAmount(fifthUser);
                            }
                        }
                    }
                }
            }
        }
        return (amount);
    }

    function saveActivity(string memory _event, uint256 _amount) private {
        activities.push(
            activity(_msgSender(), _event, _amount, block.timestamp)
        );
        if (activities.length > 20) {
            for (uint256 i = 0; i < activities.length - 1; i++) {
                activities[i] = activities[i + 1];
            }
            activities.pop();
        }
    }

    function getTeamLength(address _user) private view returns (uint256) {
        return userRewards[_user].referrals.length;
    }

    function getmyDirectReferrals(
        address _user
    )
        public
        view
        returns (address[] memory addresses, uint256[] memory timestamp)
    {
        addresses = userRewards[_user].referrals;
        timestamp = userRewards[_user].timestamp;
        return (addresses, timestamp);
    }

    function getReferralsReward(address _user) public view returns (uint256) {
        return userRewards[_user].refferReward;
    }

    function userIndex(address _user) public view returns (uint256) {
        return investment[_user].length;
    }

    function depositAddAmount(
        address _user
    ) public view returns (uint256 amount) {
        uint256 index = investment[_user].length;
        for (uint256 i = 0; i < index; i++) {
            user memory users = investment[_user][i];
            amount += plansData[users.step].amount;
        }
        return amount;
    }

    function numberOfPlans() public view returns (uint256) {
        return plansData.length;
    }

    function latestActivitiesLength() public view returns (uint256) {
        return activities.length;
    }
}
