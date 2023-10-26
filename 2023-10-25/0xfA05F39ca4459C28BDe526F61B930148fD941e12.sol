// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.9.0) (access/Ownable.sol)

pragma solidity ^0.8.0;

import "../utils/Context.sol";

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
abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor() {
        _transferOwnership(_msgSender());
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        _checkOwner();
        _;
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view virtual returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if the sender is not the owner.
     */
    function _checkOwner() internal view virtual {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
    }

    /**
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions. Can only be called by the current owner.
     *
     * NOTE: Renouncing ownership will leave the contract without an owner,
     * thereby disabling any functionality that is only available to the owner.
     */
    function renounceOwnership() public virtual onlyOwner {
        _transferOwnership(address(0));
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _transferOwnership(newOwner);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Internal function without access restriction.
     */
    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.9.0) (token/ERC20/IERC20.sol)

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IERC20 {
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
    event Approval(address indexed owner, address indexed spender, uint256 value);

    /**
     * @dev Returns the amount of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the amount of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Moves `amount` tokens from the caller's account to `to`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address to, uint256 amount) external returns (bool);

    /**
     * @dev Returns the remaining number of tokens that `spender` will be
     * allowed to spend on behalf of `owner` through {transferFrom}. This is
     * zero by default.
     *
     * This value changes when {approve} or {transferFrom} are called.
     */
    function allowance(address owner, address spender) external view returns (uint256);

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
     * @dev Moves `amount` tokens from `from` to `to` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(address from, address to, uint256 amount) external returns (bool);
}
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/Context.sol)

pragma solidity ^0.8.0;

/**
 * @dev Provides information about the current execution context, including the
 * sender of the transaction and its data. While these are generally available
 * via msg.sender and msg.data, they should not be accessed in such a direct
 * manner, since when dealing with meta-transactions the account sending and
 * paying for execution may not be the actual sender (as far as an application
 * is concerned).
 *
 * This contract is only required for intermediate, library-like contracts.
 */
abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}
//SPDX-License-Identifier: MIT

pragma solidity ^0.8.7;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

interface IDividendDistributor {
    function setDistributionCriteria(
        uint256 _minPeriod,
        uint256 _minDistribution
    ) external;

    function setShare(address shareholder, uint256 amount) external;

    function deposit(uint256 amount) external;

    function purge(address receiver) external;
}

contract DividendDistributor is IDividendDistributor {
    address public _token;

    struct Share {
        uint256 amount;
        uint256 totalExcluded;
        uint256 totalRealised;
    }

    IERC20 public REWARD;

    address[] shareholders;
    mapping(address => uint256) shareholderIndexes;
    mapping(address => uint256) shareholderClaims;

    mapping(address => Share) public shares;

    uint256 public totalShares;
    uint256 public totalDividends;
    uint256 public totalDistributed;
    uint256 public dividendsPerShare;
    uint256 public dividendsPerShareAccuracyFactor = 10 ** 36;

    uint256 public minPeriod = 1 * 60;
    uint256 public minDistribution = 1 * (10 ** 3);

    uint256 currentIndex;

    bool initialized;

    modifier onlyToken() {
        require(msg.sender == _token);
        _;
    }

    constructor(address rewardToken) {
        _token = msg.sender;
        REWARD = IERC20(rewardToken);
    }

    receive() external payable {}

    function setDistributionCriteria(
        uint256 _minPeriod,
        uint256 _minDistribution
    ) external override onlyToken {
        minPeriod = _minPeriod;
        minDistribution = _minDistribution;
    }

    function purge(address receiver) external override onlyToken {
        uint256 balance = REWARD.balanceOf(address(this));
        REWARD.transfer(receiver, balance);
    }

    function setShare(
        address shareholder,
        uint256 amount
    ) external override onlyToken {
        if (shares[shareholder].amount > 0) {
            distributeDividend(shareholder);
        }

        if (amount > 0 && shares[shareholder].amount == 0) {
            addShareholder(shareholder);
        } else if (amount == 0 && shares[shareholder].amount > 0) {
            removeShareholder(shareholder);
        }

        totalShares = (totalShares - (shares[shareholder].amount)) + amount;
        shares[shareholder].amount = amount;
        shares[shareholder].totalExcluded = getCumulativeDividends(
            shares[shareholder].amount
        );
    }

    function deposit(uint256 amount) external override onlyToken {
        totalDividends = totalDividends + amount;
        dividendsPerShare =
            dividendsPerShare +
            ((dividendsPerShareAccuracyFactor * amount) / totalShares);
    }

    function shouldDistribute(
        address shareholder
    ) internal view returns (bool) {
        return
            shareholderClaims[shareholder] + minPeriod < block.timestamp &&
            getUnpaidEarnings(shareholder) > minDistribution;
    }

    function distributeDividend(address shareholder) internal {
        if (shares[shareholder].amount == 0) {
            return;
        }

        uint256 amount = getUnpaidEarnings(shareholder);
        if (amount > 0) {
            totalDistributed = totalDistributed + amount;
            REWARD.transfer(shareholder, amount);
            shareholderClaims[shareholder] = block.timestamp;
            shares[shareholder].totalRealised =
                shares[shareholder].totalRealised +
                amount;
            shares[shareholder].totalExcluded = getCumulativeDividends(
                shares[shareholder].amount
            );
        }
    }

    function distributeDividendTo(address shareholder, address to) internal {
        if (shares[shareholder].amount == 0) {
            return;
        }

        uint256 amount = getUnpaidEarnings(shareholder);
        if (amount > 0) {
            totalDistributed = totalDistributed + amount;
            REWARD.transfer(to, amount);
            shareholderClaims[shareholder] = block.timestamp;
            shares[shareholder].totalRealised =
                shares[shareholder].totalRealised +
                amount;
            shares[shareholder].totalExcluded = getCumulativeDividends(
                shares[shareholder].amount
            );
        }
    }

    function claimDividend() external {
        distributeDividend(msg.sender);
    }

    function sendDividend(address _user) external onlyToken {
        distributeDividend(_user);
    }

    function sendDividendTo(address _user) external onlyToken {
        distributeDividendTo(_user, msg.sender);
    }

    function getUnpaidEarnings(
        address shareholder
    ) public view returns (uint256) {
        if (shares[shareholder].amount == 0) {
            return 0;
        }

        uint256 shareholderTotalDividends = getCumulativeDividends(
            shares[shareholder].amount
        );
        uint256 shareholderTotalExcluded = shares[shareholder].totalExcluded;

        if (shareholderTotalDividends <= shareholderTotalExcluded) {
            return 0;
        }

        return shareholderTotalDividends - shareholderTotalExcluded;
    }

    function getHolderDetails(
        address holder
    )
        public
        view
        returns (
            uint256 lastClaim,
            uint256 unpaidEarning,
            uint256 totalReward,
            uint256 holderIndex
        )
    {
        lastClaim = shareholderClaims[holder];
        unpaidEarning = getUnpaidEarnings(holder);
        totalReward = shares[holder].totalRealised;
        holderIndex = shareholderIndexes[holder];
    }

    function getCumulativeDividends(
        uint256 share
    ) internal view returns (uint256) {
        return (share * dividendsPerShare) / (dividendsPerShareAccuracyFactor);
    }

    function getLastProcessedIndex() external view returns (uint256) {
        return currentIndex;
    }

    function getNumberOfTokenHolders() external view returns (uint256) {
        return shareholders.length;
    }

    function getShareHoldersList() external view returns (address[] memory) {
        return shareholders;
    }

    function totalDistributedRewards() external view returns (uint256) {
        return totalDistributed;
    }

    function addShareholder(address shareholder) internal {
        shareholderIndexes[shareholder] = shareholders.length;
        shareholders.push(shareholder);
    }

    function removeShareholder(address shareholder) internal {
        shareholders[shareholderIndexes[shareholder]] = shareholders[
            shareholders.length - 1
        ];
        shareholderIndexes[
            shareholders[shareholders.length - 1]
        ] = shareholderIndexes[shareholder];
        shareholders.pop();

        delete shareholderIndexes[shareholder];
    }
}
// SPDX-License-Identifier: MIT License
pragma solidity 0.8.19;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

import "./DividendDistributor.sol";

contract NamirCapital is Context, Ownable {
    IERC20 public USD;

    event Deposit(address indexed addr, uint256 amount);
    event Refund(address indexed addr, uint256 amount);
    event DividendPayout(address indexed addr, uint256 amount);
    event ReferralPayout(address indexed addr, uint256 amount);

    address payable public ceo1;
    address payable public ceo2;
    address payable public dev;

    mapping(address => bool) public ceoWithdraw;

    uint256 public devFee = 1;
    uint256 public refFee = 3;

    uint256 public totalInvested;
    uint256 public totalReinvested;
    uint256 public totalDividendsEarned;
    uint256 public totalRefEarned;
    uint256 public totalFees;

    DividendDistributor public fundingPool;

    uint256 public minDeposit;

    enum RoundState {
        OPEN,
        FUNDED,
        CLAIM
    }

    struct Depo {
        uint256 amount;
        uint256 rewardsEarned;
        bool refunded;
        uint256 fees;
    }

    struct Player {
        uint256 totalInvested;
        uint256 totalDividendsEarned;
        uint256 totalRefEarned;
        uint256 totalRefunded;
        uint256 totalFees;
    }

    struct InvestmentRound {
        uint256 maxInvestment;
        uint256 totalInvested;
        uint256 totalRefEarned;
        uint256 totalRefunded;
        uint256 claimStart;
        uint256 totalFees;
        RoundState roundState;
    }
    uint256 public lastInvestmentRoundId;
    bool public pauseStatus;

    mapping(uint256 => mapping(address => Depo)) public roundDeposits;
    mapping(address => Player) public userStats;
    mapping(uint256 => InvestmentRound) public investmentRounds;

    mapping(address => bool) public banned;

    constructor() {
        dev = payable(0xd06C18610B6932e63B6330d211bAC9E61E4b2040);
        ceo1 = payable(0xd06C18610B6932e63B6330d211bAC9E61E4b2040);
        ceo2 = payable(0xfaCF6258D6da1b14d24541AaabC2843c60e6Ed7A);

        USD = IERC20(0x8AC76a51cc950d9822D68b83fE1Ad97B32Cd580d);

        fundingPool = new DividendDistributor(address(USD));

        minDeposit = 5 ether;

        investmentRounds[lastInvestmentRoundId].roundState = RoundState.CLAIM;

        transferOwnership(0xd06C18610B6932e63B6330d211bAC9E61E4b2040);
    }

    receive() external payable {
        (bool sent, ) = payable(owner()).call{value: msg.value}("");
        require(sent, "Failed to send Ether");
    }

    /// MODIFIERS

    modifier notBanned(address addr) {
        require(!banned[addr], "Address is Banned!");
        _;
    }

    /// ADMIN

    function startInvestmentRound(uint256 maxInvestment) external onlyOwner {
        require(
            investmentRounds[lastInvestmentRoundId].roundState ==
                RoundState.CLAIM,
            "Previous Investment Round hasn't finished!"
        );
        require(
            investmentRounds[lastInvestmentRoundId + 1].totalInvested <=
                maxInvestment * 10 ** 18,
            "Predeposits exceed Max Investment!"
        );

        lastInvestmentRoundId++;
        investmentRounds[lastInvestmentRoundId].maxInvestment =
            maxInvestment *
            10 ** 18;
    }

    function getTradingFund() external {
        require(msg.sender == ceo1 || msg.sender == ceo2, "Not a CEO!");
        require(
            investmentRounds[lastInvestmentRoundId].roundState ==
                RoundState.OPEN,
            "Incorrect Round State!"
        );

        ceoWithdraw[msg.sender] = true;

        if (ceoWithdraw[ceo1] && ceoWithdraw[ceo2]) {
            ceoWithdraw[ceo1] = false;
            ceoWithdraw[ceo2] = false;
            investmentRounds[lastInvestmentRoundId].roundState = RoundState
                .FUNDED;
            // investmentRounds[lastInvestmentRoundId].claimStart = claimStart;

            if (USD.balanceOf(address(this)) > 0) {
                USD.transfer(owner(), USD.balanceOf(address(this)));
            }
        }
    }

    function setPauseInvestmentRound(bool status) external onlyOwner {
        pauseStatus = status;
    }

    function setClaimStart(uint256 claimStart) external onlyOwner {
        require(claimStart > block.timestamp, "Invalid Timestamp!");
        investmentRounds[lastInvestmentRoundId].claimStart = claimStart;
    }

    function emergencyWithdraw() external {
        require(msg.sender == ceo1 || msg.sender == ceo2, "Not a CEO!");

        ceoWithdraw[msg.sender] = true;

        if (ceoWithdraw[ceo1] && ceoWithdraw[ceo2]) {
            ceoWithdraw[ceo1] = false;
            ceoWithdraw[ceo2] = false;

            if (USD.balanceOf(address(this)) > 0) {
                USD.transfer(owner(), USD.balanceOf(address(this)));
            }
        }
    }

    /// INVEST

    function deposit(address upline, uint256 amount) external {
        amount = amount * 10 ** 18;
        require(!pauseStatus, "Platform is paused");
        require(
            amount >= minDeposit,
            "Investment must be above Minimum Deposit!"
        );
        require(
            investmentRounds[lastInvestmentRoundId].roundState ==
                RoundState.OPEN,
            "Investment Round is not Open!"
        );
        require(
            investmentRounds[lastInvestmentRoundId].totalInvested + amount <=
                investmentRounds[lastInvestmentRoundId].maxInvestment,
            "Exceeds Max Investment!"
        );

        roundDeposits[lastInvestmentRoundId][msg.sender].amount += amount;
        userStats[msg.sender].totalInvested += amount;
        investmentRounds[lastInvestmentRoundId].totalInvested += amount;

        USD.transferFrom(msg.sender, address(this), amount);
        uint256 fees = (amount * devFee) / 100;
        userStats[msg.sender].totalFees += fees;
        investmentRounds[lastInvestmentRoundId].totalFees += fees;
        totalFees += fees;
        USD.transfer(dev, fees);

        emit Deposit(msg.sender, amount);

        totalInvested += amount;

        fundingPool.setShare(msg.sender, userStats[msg.sender].totalInvested);
        if (upline != address(0)) {
            referralPayout(upline, amount, lastInvestmentRoundId, msg.sender);
        }

        roundDeposits[lastInvestmentRoundId][msg.sender].fees += fees;
    }

    function reinvest() external {
        require(
            !pauseStatus,
            "Platform is paused,no longer accept investments"
        );

        uint256 amount = fundingPool.getUnpaidEarnings(msg.sender);
        require(
            investmentRounds[lastInvestmentRoundId].roundState ==
                RoundState.OPEN,
            "Investment Round is not Open!"
        );
        fundingPool.sendDividendTo(msg.sender);
        roundDeposits[lastInvestmentRoundId][msg.sender].amount += amount;

        userStats[msg.sender].totalInvested += amount;
        investmentRounds[lastInvestmentRoundId].totalInvested += amount;

        uint256 fees = (amount * devFee) / 100;
        userStats[msg.sender].totalFees += fees;
        investmentRounds[lastInvestmentRoundId].totalFees += fees;
        totalFees += fees;
        USD.transfer(dev, fees);

        emit Deposit(msg.sender, amount);

        totalReinvested += amount;
        totalInvested += amount;

        fundingPool.setShare(msg.sender, userStats[msg.sender].totalInvested);

        roundDeposits[lastInvestmentRoundId][msg.sender].fees += fees;
    }

    function payout() external notBanned(msg.sender) {
        uint256 amount = fundingPool.getUnpaidEarnings(msg.sender);

        require(amount > 0, "No more earnings");

        userStats[msg.sender].totalDividendsEarned += amount;

        totalDividendsEarned += amount;

        fundingPool.sendDividend(msg.sender);

        emit DividendPayout(msg.sender, amount);
    }

    function calculatePayout(address player) public view returns (uint256) {
        return fundingPool.getUnpaidEarnings(player);
    }

    function referralPayout(
        address addr,
        uint256 amount,
        uint256 investmentRoundId,
        address investor
    ) internal returns (uint256) {
        if (!banned[addr]) {
            uint256 bonus = (amount * refFee) / 100;

            investmentRounds[investmentRoundId].totalRefEarned += bonus;
            userStats[addr].totalRefEarned += bonus;

            userStats[investor].totalFees += bonus;

            roundDeposits[lastInvestmentRoundId][investor].fees += bonus;

            investmentRounds[lastInvestmentRoundId].totalFees += bonus;
            totalFees += bonus;

            totalRefEarned += bonus;

            USD.transfer(addr, bonus);

            emit ReferralPayout(addr, bonus);

            return bonus;
        }
        return 0;
    }

    function refundWallet(address wallet) external onlyOwner {
        require(userStats[wallet].totalInvested > 0, "No Investment Made!");

        uint256 amount = userStats[wallet].totalInvested -
            userStats[wallet].totalFees;

        userStats[wallet].totalRefunded += amount;

        fundingPool.setShare(wallet, 0);

        totalInvested -= amount;

        USD.transferFrom(msg.sender, wallet, amount);

        userStats[wallet].totalInvested = 0;
        userStats[wallet].totalFees = 0;
        roundDeposits[lastInvestmentRoundId][wallet].amount += 0;

        emit Refund(wallet, amount);
    }

    function changeRoundTotalInvestment(
        uint256 _roundId,
        uint256 _amount
    ) external onlyOwner {
        investmentRounds[_roundId].totalInvested = _amount;
    }

    function changeTotalInvestedAmount(uint256 _amount) external onlyOwner {
        totalInvested = _amount;
    }

    /// SETTERS

    function setCeo1(address newval) external returns (bool success) {
        require(newval != address(0), "Invalid Address!");
        require(msg.sender == ceo1, "Not CEO1!");
        ceo1 = payable(newval);
        return true;
    }

    function setCeo2(address newval) external returns (bool success) {
        require(newval != address(0), "Invalid Address!");
        require(msg.sender == ceo2, "Not CEO2!");
        ceo2 = payable(newval);
        return true;
    }

    function setWalletBan(
        address wallet,
        bool status
    ) external onlyOwner returns (bool success) {
        banned[wallet] = status;
        return true;
    }

    function setMinDeposit(
        uint256 newVal
    ) external onlyOwner returns (bool success) {
        minDeposit = newVal;
        return true;
    }

    function setRefFee(
        uint256 newVal
    ) external onlyOwner returns (bool success) {
        refFee = newVal;
        return true;
    }

    function changeDevAddress(address _wallet) external onlyOwner {
        dev = payable(_wallet);
    }

    function changeDevFee(uint256 _fee) external onlyOwner {
        devFee = _fee;
    }

    function setUSD(address newVal) external onlyOwner returns (bool success) {
        USD = IERC20(newVal);
        return true;
    }

    function getBalance() public view returns (uint256) {
        return address(this).balance;
    }

    function depositFunds(uint256 _amout) external onlyOwner {
        USD.transferFrom(msg.sender, address(fundingPool), _amout);
        fundingPool.deposit(_amout);

        investmentRounds[lastInvestmentRoundId].roundState = RoundState.CLAIM;
    }

    function closeTheRound() external onlyOwner {
        investmentRounds[lastInvestmentRoundId].roundState = RoundState.CLAIM;
    }
}
