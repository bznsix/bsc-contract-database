// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.7.0) (access/Ownable.sol)

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
     * `onlyOwner` functions anymore. Can only be called by the current owner.
     *
     * NOTE: Renouncing ownership will leave the contract without an owner,
     * thereby removing any functionality that is only available to the owner.
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
// OpenZeppelin Contracts (last updated v4.7.0) (security/Pausable.sol)

pragma solidity ^0.8.0;

import "../utils/Context.sol";

/**
 * @dev Contract module which allows children to implement an emergency stop
 * mechanism that can be triggered by an authorized account.
 *
 * This module is used through inheritance. It will make available the
 * modifiers `whenNotPaused` and `whenPaused`, which can be applied to
 * the functions of your contract. Note that they will not be pausable by
 * simply including this module, only once the modifiers are put in place.
 */
abstract contract Pausable is Context {
    /**
     * @dev Emitted when the pause is triggered by `account`.
     */
    event Paused(address account);

    /**
     * @dev Emitted when the pause is lifted by `account`.
     */
    event Unpaused(address account);

    bool private _paused;

    /**
     * @dev Initializes the contract in unpaused state.
     */
    constructor() {
        _paused = false;
    }

    /**
     * @dev Modifier to make a function callable only when the contract is not paused.
     *
     * Requirements:
     *
     * - The contract must not be paused.
     */
    modifier whenNotPaused() {
        _requireNotPaused();
        _;
    }

    /**
     * @dev Modifier to make a function callable only when the contract is paused.
     *
     * Requirements:
     *
     * - The contract must be paused.
     */
    modifier whenPaused() {
        _requirePaused();
        _;
    }

    /**
     * @dev Returns true if the contract is paused, and false otherwise.
     */
    function paused() public view virtual returns (bool) {
        return _paused;
    }

    /**
     * @dev Throws if the contract is paused.
     */
    function _requireNotPaused() internal view virtual {
        require(!paused(), "Pausable: paused");
    }

    /**
     * @dev Throws if the contract is not paused.
     */
    function _requirePaused() internal view virtual {
        require(paused(), "Pausable: not paused");
    }

    /**
     * @dev Triggers stopped state.
     *
     * Requirements:
     *
     * - The contract must not be paused.
     */
    function _pause() internal virtual whenNotPaused {
        _paused = true;
        emit Paused(_msgSender());
    }

    /**
     * @dev Returns to normal state.
     *
     * Requirements:
     *
     * - The contract must be paused.
     */
    function _unpause() internal virtual whenPaused {
        _paused = false;
        emit Unpaused(_msgSender());
    }
}
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.8.0) (security/ReentrancyGuard.sol)

pragma solidity ^0.8.0;

/**
 * @dev Contract module that helps prevent reentrant calls to a function.
 *
 * Inheriting from `ReentrancyGuard` will make the {nonReentrant} modifier
 * available, which can be applied to functions to make sure there are no nested
 * (reentrant) calls to them.
 *
 * Note that because there is a single `nonReentrant` guard, functions marked as
 * `nonReentrant` may not call one another. This can be worked around by making
 * those functions `private`, and then adding `external` `nonReentrant` entry
 * points to them.
 *
 * TIP: If you would like to learn more about reentrancy and alternative ways
 * to protect against it, check out our blog post
 * https://blog.openzeppelin.com/reentrancy-after-istanbul/[Reentrancy After Istanbul].
 */
abstract contract ReentrancyGuard {
    // Booleans are more expensive than uint256 or any type that takes up a full
    // word because each write operation emits an extra SLOAD to first read the
    // slot's contents, replace the bits taken up by the boolean, and then write
    // back. This is the compiler's defense against contract upgrades and
    // pointer aliasing, and it cannot be disabled.

    // The values being non-zero value makes deployment a bit more expensive,
    // but in exchange the refund on every call to nonReentrant will be lower in
    // amount. Since refunds are capped to a percentage of the total
    // transaction's gas, it is best to keep them low in cases like this one, to
    // increase the likelihood of the full refund coming into effect.
    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;

    uint256 private _status;

    constructor() {
        _status = _NOT_ENTERED;
    }

    /**
     * @dev Prevents a contract from calling itself, directly or indirectly.
     * Calling a `nonReentrant` function from another `nonReentrant`
     * function is not supported. It is possible to prevent this from happening
     * by making the `nonReentrant` function external, and making it call a
     * `private` function that does the actual work.
     */
    modifier nonReentrant() {
        _nonReentrantBefore();
        _;
        _nonReentrantAfter();
    }

    function _nonReentrantBefore() private {
        // On the first call to nonReentrant, _status will be _NOT_ENTERED
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");

        // Any calls to nonReentrant after this point will fail
        _status = _ENTERED;
    }

    function _nonReentrantAfter() private {
        // By storing the original value once again, a refund is triggered (see
        // https://eips.ethereum.org/EIPS/eip-2200)
        _status = _NOT_ENTERED;
    }
}
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.6.0) (token/ERC20/IERC20.sol)

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
    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);
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
//SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

interface IIDOPool {

    function usdcUserBought(address _user, uint256 _amountNika) external;

}// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/security/Pausable.sol";
import "./interfaces/IIDOPool.sol";
// import "hardhat/console.sol";

contract NikaStaking is Ownable, Pausable, ReentrancyGuard {

    struct StakingInfo {
        uint256 totalStakes;
        uint256 totalWithdrawClaimed;
        uint256 totalClaimed;
        uint256 claimStakedPerDay;
        uint256 maxClaim;
        uint64 vestingDuration;
        uint64 interestDuration;
        uint64 lastClaimStaked;
        uint64 lastUpdatedTime;
        uint64 lastTimeDeposited;
        uint64 lastTimeClaimed;
        uint16 interestRates;
        bool joinByReferral;
    }

    struct StakingPackage {
        uint64 interestDuration;
        uint64 vestingDuration;
        uint32 minAmount;
        uint32 maxAmount;
        uint16 interest;
    }

    uint256 public totalStaked;

    uint256 public constant DECIMAL = (10**18);

    uint32 private constant ONE_YEAR_IN_SECONDS = 365 days;
    uint32 private constant ONE_DAY_IN_SECONDS = 1 hours; // Main variable
    uint32 private constant THIRTY_DAYS_IN_SECONDS = 30 days;
    uint16 private constant PRECISION_POINT = 10_000;

    uint16 public maxInterest = 40000; // 400% max interest

    IERC20 public rewardToken;
    address public treasury;
    address public ido;
    address public admin;
    bool public poolStatus;

    // sender => matching bonus
    mapping(address => uint256) public matchingBonus;
    // sender => direct bonus
    mapping(address => uint256) public directBonus;
    // referrer -> number of F1s
    mapping(address => uint256) public totalReferralInvitations;
    // sender -> referrer 
    mapping(address => address) public referralLevels;
    // referrer -> commission level(1,2,3,4,5,6,7,8,9) -> referral invitations 
    mapping(address => mapping(uint256 => uint256)) public referralInvitationsByCommissionLevel;
    // sender -> current staking amount
    mapping(address => StakingInfo) userStakingAmounts;

    // Store all 5 staking checkpoints 
    uint208[5] public stakingCheckpoints;

    uint256[9] public MonthlyInterestLevels;
    uint256[9] public MonthlyInterestConditions;
    uint256[9] public claimPackageRange; // can oly claim in this range

    uint256[9] public commissionInterestLevels;
    uint256[9] public commissionInviteConditions;

    event Deposit(address indexed user, address indexed referrer, uint256 amount);
    event ReferralLevelAdded(address indexed user, address indexed referral, uint256 level);
    event Withdraw(address indexed user, uint256 amount);
    event LinearRewardClaimed(address indexed claimer, uint256 amount);
    event CantClaimReward(address indexed claimer, uint256 amount, uint256 maxClaimAmount);
    event LinearRewardReferrerByLevel(address indexed origin, address indexed receiver, uint256 level, uint256 amount);
    event CommissionRewardReferrerByLevel(address indexed origin, address indexed receiver, uint256 level, uint256 amount, uint256 invitationByLevel);

    constructor(address _treasury, IERC20 _rewardToken) {
        /// @dev: ZA - Zero address
        require(_treasury != address(0), "ZA");
        require(address(_rewardToken) != address(0), "ZA");

        treasury = _treasury;
        rewardToken = _rewardToken;
        admin = msg.sender;
        poolStatus = true;

        /// Commission for the invitation and only get once
        commissionInterestLevels = [
            800, // 8%
            500, // 5%
            300, // 3%
            100, // 1%
            100, // 1%
            100, // 1%
            100, // 1%
            100, // 1%
            100  // 1%
        ];

        /// Commission for the invitation and only get once
        commissionInviteConditions = [
            1, // F1 - 1 F1
            3, // F2 - 3 F1
            3, // F3 - 3 F1
            5, // F4 - 5 F1 
            5, // F5 - 5 F1
            6, // F6 - 4 F1
            6, // F7 - 4 F1
            6, // F8 - 6 F1
            6  // F9 - 6 F1
        ];


        stakingCheckpoints = [ // interest - vesting - min - max - interest
            0x000000000001518000000000000151800000006400001FA40190, // 547 days - 30 days - 100 - 8100 - 4%
            0x0000000000015180000000000001518000001FA400004E8401F4, // 547 days - 30 days - 8100 - 20100 - 5%
            0x0000000000015180000000000001518000004E840000C3B40258, // 547 days - 30 days - 20100 - 50100 - 6%
            0x000000000001518000000000000151800000C3B40001D4C00320, // 547 days - 30 days - 50100 - 120000 - 8%
            0x000000000001518000000000000151800001D4C0FFFFFFFF03E8  // 547 days - 30 days - 120000 - xxxx - 10%
        ]; 

        
        /// Commission interest rate for the referrer and receive when refferee claim 
        MonthlyInterestLevels = [
            1500, // 15%
            1000, // 10%
            500, // 5%
            300, // 3%
            100, // 1%
            200, // 2%
            300, // 3%
            400, // 4%
            500  // 5%
        ];

        /// Commission conditions for the referrer to claim interest
        MonthlyInterestConditions = [
            2, // F1 - 2 F1
            3, // F2 - 3 F1
            3, // F3 - 3 F1
            4, // F4 - 4 F1
            4, // F5 - 4 F1
            5, // F6 - 5 F1
            5, // F7 - 5 F1
            6, // F8 - 6 F1
            6  // F9 - 6 F1
        ];

        /// Package Invest conditions of referee for the referrer to claim interest  hex: maxx - minn
        claimPackageRange = [
            0x00000000000000000000000000003EE400000000000000000000000000000064, // 100, 16100 - 1 F1
            0x0000000000000000000000000000EAC400000000000000000000000000003EE4, // 16100, 60100 - 2 F1
            0x0000000000000000000000000000EAC400000000000000000000000000003EE4, // 16100, 60100 - 3 F1
            0x000000000000000000000000000271000000000000000000000000000000EAC4, // 60100, 160000 - 4 F1
            0x000000000000000000000000000271000000000000000000000000000000EAC4, // 60100, 160000 - 5 F1
            0x0000000000000000000000000004BAF000000000000000000000000000027100, // 160000, 310000 - 6 F1
            0x0000000000000000000000000004BAF000000000000000000000000000027100, // 160000, 310000 - 7 F1
            0x000000000000000000000000FFFFFFFF0000000000000000000000000004BAF0, // 310000, 4294967295 - 8 F1
            0x000000000000000000000000FFFFFFFF0000000000000000000000000004BAF0  // 310000, 4294967295 - 9 F1
        ];
    }

    /// -----------------------------------
    /// ---------- View Function ----------
    /// -----------------------------------

    function isReferral(address _user) external view returns(bool) {
        StakingInfo storage stakingData = userStakingAmounts[_user];
        
        return stakingData.joinByReferral;
    }

    function getUserInformation(address _user) public view returns(StakingInfo memory) {
        StakingInfo storage stakingData = userStakingAmounts[_user];
        
        return stakingData;
    }

    function getF1Invited(address _user) public view returns(uint256) {
    
        return totalReferralInvitations[_user];
    }

    function getDirectBonus(address _user) public view returns(uint256) {
    
        return directBonus[_user];
    }

    function getMatchingBonus(address _user) public view returns(uint256) {
    
        return matchingBonus[_user];
    }

    function getUserReferrer(address _user) public view returns(address) {
        
        return referralLevels[_user];
    }

    function getStakingCheckpoints() public view returns(uint208[5] memory) {

        return stakingCheckpoints;
    }

    function getClaimPackageRange() public view returns(uint256[9] memory) {

        return claimPackageRange;
    }

    function getTotalStaked() public view returns(uint256) {
    
        return totalStaked;
    }

    function getPoolStatus() public view returns(bool) {
    
        return poolStatus;
    }

    /// -----------------------------------
    /// --------- Update Function ---------
    /// -----------------------------------

    function updateAdmin(address _admin) external onlyOwner {

        admin = _admin;
    }

    function updateIDOaddress(address _ido) external onlyAdmin {

        ido = _ido;
    }

    function updateTreasury(address _treasury) external onlyAdmin {

        treasury = _treasury;
    }

    function updateMaxInterest(uint16 _maxInterest) external onlyAdmin {

        maxInterest = _maxInterest;
    }

    function updateStakingCheckPoints(uint208[5] memory _stakingCheckPoints) external onlyAdmin {

        stakingCheckpoints = _stakingCheckPoints;
    }

    function updateClaimPackageRange(uint256[9] memory _claimPackageRange) external onlyAdmin {

        claimPackageRange = _claimPackageRange;
    }

    function getClaimPackagesRange(uint256 index) public view returns (uint128, uint128) {
        uint256 packedStakingPackage = claimPackageRange[index];

        uint128 minimumAmount = uint128(((1 << 128) - 1) & packedStakingPackage);

        uint128 maximumAmount = uint128(
            ((1 << 128) - 1) & (packedStakingPackage >> 128)
        );

        return (maximumAmount, minimumAmount);
    }

    function getStakingPackages(uint256 index) public view returns (StakingPackage memory) {
        uint208 packedStakingPackage = stakingCheckpoints[index];
        uint16 interest = uint16(((1 << 16) - 1) & packedStakingPackage);
        uint32 maximumAmount = uint32(
            ((1 << 32) - 1) & (packedStakingPackage >> 16)
        );
        uint32 minimumAmount = uint32(
            ((1 << 32) - 1) & (packedStakingPackage >> 48)
        );

        uint64 vestingDuration = uint64(
            ((1 << 64) - 1) & (packedStakingPackage >> 80)
        );

        uint64 interestDuration = uint64(
            ((1 << 64) - 1) & (packedStakingPackage >> 144)
        );

        return
            StakingPackage({
                interest: interest,
                maxAmount: maximumAmount,
                minAmount: minimumAmount,
                interestDuration: interestDuration,
                vestingDuration: vestingDuration
            });
    }

    /// -----------------------------------
    /// ---------- Core Function ----------
    /// -----------------------------------

    function deposit(uint256 amount, address referrer) external whenNotPaused {

        require(amount > 0, "pool: amount cannot be zero");
        require(ido != address(0), "pool: ido address can not be zero address");
        require(msg.sender != address(0), "pool: stake address can not be zero address");

        StakingInfo storage stakingInfo = userStakingAmounts[msg.sender];

        uint256 userTotalStakeAmounts = stakingInfo.totalStakes + amount;

        // Locking principal deposit amount
        rewardToken.transferFrom(msg.sender, address(this), amount);

        if (referrer != address(0)) {
            require(!stakingInfo.joinByReferral,"Is already joined by referral");
            
            stakingInfo.joinByReferral = true;
            referralLevels[msg.sender] = referrer;
            totalReferralInvitations[referrer] += 1;

        }

        _rewardToAllReferralLevels(amount, msg.sender);

        StakingPackage memory foundPackage;

        for (uint256 i = 0; i < stakingCheckpoints.length; i++) {
            StakingPackage memory package = getStakingPackages(i);

            if (
                userTotalStakeAmounts >= (uint256(package.minAmount) * DECIMAL) &&
                userTotalStakeAmounts < (uint256(package.maxAmount) * DECIMAL)
            ) {
                foundPackage = package;
                break;
            }
        }

        /// @dev: Not found package
        require(foundPackage.interestDuration > 0, "pool: not found package");

        stakingInfo.claimStakedPerDay = 0;
        stakingInfo.totalWithdrawClaimed = 0;
        stakingInfo.lastUpdatedTime = uint64(block.timestamp);
        stakingInfo.lastTimeDeposited = uint64(block.timestamp);
        stakingInfo.lastTimeClaimed = uint64(block.timestamp);
        stakingInfo.interestDuration = foundPackage.interestDuration;
        stakingInfo.interestRates = foundPackage.interest;
        stakingInfo.totalStakes = userTotalStakeAmounts;
        stakingInfo.maxClaim = (userTotalStakeAmounts * maxInterest) / PRECISION_POINT;
        stakingInfo.vestingDuration = foundPackage.vestingDuration;
        stakingInfo.lastClaimStaked = stakingInfo.lastTimeDeposited + stakingInfo.interestDuration;

        totalStaked += amount;

        IIDOPool(ido).usdcUserBought(msg.sender, amount);

        emit Deposit(msg.sender, referrer, amount);
    }

    function depositIDO(uint256 amount, address stakeUser, address referrer) external whenNotPaused {

        require(amount > 0, "pool: amount cannot be zero");
        require(stakeUser != address(0), "pool: stake address cant not be zero address");
        require(ido != address(0), "pool: ido address can not be zero address");
        require(msg.sender == ido, "pool: not ido address");

        StakingInfo storage stakingInfo = userStakingAmounts[stakeUser];

        uint256 userTotalStakeAmounts = stakingInfo.totalStakes + amount;

        // Locking principal deposit amount
        rewardToken.transferFrom(ido, address(this), amount);

        if (referrer != address(0)) {
            require(!stakingInfo.joinByReferral,"Is already joined by referral");
            
            stakingInfo.joinByReferral = true;
            referralLevels[stakeUser] = referrer;
            totalReferralInvitations[referrer] += 1;
        }

        _rewardToAllReferralLevels(amount, stakeUser);

        StakingPackage memory foundPackage;

        for (uint256 i = 0; i < stakingCheckpoints.length; i++) {
            StakingPackage memory package = getStakingPackages(i);

            if (
                userTotalStakeAmounts >= (uint256(package.minAmount) * DECIMAL) &&
                userTotalStakeAmounts < (uint256(package.maxAmount) * DECIMAL)
            ) {
                foundPackage = package;
                break;
            }
        }

        /// @dev: Not found package
        require(foundPackage.interestDuration > 0, "pool: not found package");

        stakingInfo.claimStakedPerDay = 0;
        stakingInfo.totalWithdrawClaimed = 0;
        stakingInfo.lastUpdatedTime = uint64(block.timestamp);
        stakingInfo.lastTimeDeposited = uint64(block.timestamp);
        stakingInfo.lastTimeClaimed = uint64(block.timestamp);
        stakingInfo.interestDuration = foundPackage.interestDuration;
        stakingInfo.interestRates = foundPackage.interest;
        stakingInfo.totalStakes = userTotalStakeAmounts;
        stakingInfo.maxClaim = (userTotalStakeAmounts * maxInterest) / PRECISION_POINT;
        stakingInfo.vestingDuration = foundPackage.vestingDuration;
        stakingInfo.lastClaimStaked = stakingInfo.lastTimeDeposited + stakingInfo.interestDuration;

        totalStaked += amount;

        emit Deposit(stakeUser, referrer, amount);
    }

    function withdrawAble(address _user) public view returns(uint256) {
        StakingInfo storage stakingData = userStakingAmounts[_user];

        if (stakingData.totalStakes == 0) {
            return 0;
        }

        if (block.timestamp < stakingData.lastClaimStaked) {
            return 0;
        }
    
        uint256 totalStakedClaimable;
        uint64 claimTimes = ((uint64(block.timestamp) - stakingData.lastClaimStaked) / uint64(ONE_DAY_IN_SECONDS)) + 1;

        if (block.timestamp >= stakingData.lastTimeDeposited + stakingData.interestDuration + stakingData.vestingDuration) {
            totalStakedClaimable = stakingData.totalStakes;
           
            return totalStakedClaimable;
        }
        
        totalStakedClaimable = stakingData.claimStakedPerDay * claimTimes;

        if (stakingData.claimStakedPerDay == 0) {
            uint256 claimStakedPerDay = stakingData.totalStakes / (stakingData.vestingDuration / ONE_DAY_IN_SECONDS);
            totalStakedClaimable = claimStakedPerDay * claimTimes;
        }

        if (stakingData.totalWithdrawClaimed + totalStakedClaimable >= stakingData.totalStakes) {
            return stakingData.totalStakes;
        }
            
        return totalStakedClaimable;
    }

    function withdraw() external nonReentrant whenNotPaused {
        address account = msg.sender;
        StakingInfo storage stakingData = userStakingAmounts[account];

        require(block.timestamp >= stakingData.lastTimeDeposited + stakingData.interestDuration, "pool: still Locked");

        // ---- check pending rewards left ---
        uint256 totalPendingRewards;
        uint64 claimTimesReward;

        (totalPendingRewards, claimTimesReward) = poolPendingRewardPerday(account);

        if (totalPendingRewards > 0) {
            _harvest(account);
        }
        // ---- check pending rewards left ---

        require(block.timestamp >= stakingData.lastClaimStaked, "not time to claim"); 
        require(stakingData.totalStakes > 0, "pool: greater than zero");

        uint256 totalStakedClaimable;

        uint64 claimTimes = ((uint64(block.timestamp) - stakingData.lastClaimStaked) / uint64(ONE_DAY_IN_SECONDS)) + 1;

        if (stakingData.claimStakedPerDay == 0) {
            stakingData.claimStakedPerDay = stakingData.totalStakes / (stakingData.vestingDuration / ONE_DAY_IN_SECONDS);
        }

        require(stakingData.claimStakedPerDay > 0, "pool: claim staked per day must greater than zero");

        if (block.timestamp >= stakingData.lastTimeDeposited + stakingData.interestDuration + stakingData.vestingDuration) {
            totalStakedClaimable = stakingData.totalStakes;
            rewardToken.transferFrom(treasury, msg.sender, totalStakedClaimable);
            
            stakingData.maxClaim = 0;
            stakingData.totalStakes = 0;
            stakingData.totalClaimed = 0;
            stakingData.totalWithdrawClaimed = stakingData.totalStakes;
        }
        else {
            totalStakedClaimable = stakingData.claimStakedPerDay * claimTimes;
            require(stakingData.totalWithdrawClaimed + totalStakedClaimable <= stakingData.totalStakes, "pool: your staked less than your withdraw");
            rewardToken.transferFrom(treasury, msg.sender, totalStakedClaimable);
            stakingData.totalStakes = stakingData.totalStakes - totalStakedClaimable;
            stakingData.totalWithdrawClaimed = stakingData.totalWithdrawClaimed + totalStakedClaimable;
        }

        // stakingData.maxClaim = (stakingData.totalStakes * maxInterest) / PRECISION_POINT;
        stakingData.lastClaimStaked = stakingData.lastClaimStaked + (claimTimes * ONE_DAY_IN_SECONDS);

        totalStaked -= totalStakedClaimable;

        emit Withdraw(msg.sender, totalStakedClaimable);   
    }

    function claimReward() external nonReentrant whenNotPaused {
        _harvest(msg.sender);
    }

    function _harvest(address _account) internal {
        StakingInfo storage stakingData = userStakingAmounts[_account];

        uint256 totalPendingRewards;
        uint64 claimTimes;
        (totalPendingRewards, claimTimes) = poolPendingRewardPerday(_account);

        require(stakingData.totalClaimed + totalPendingRewards <= stakingData.maxClaim, "pool: you reach the max interest");

        _rewardCommissionToAllReferralLevels(
            totalPendingRewards,
            _account
        );

        // Transfer the remaining interest to owner
        rewardToken.transferFrom(treasury, _account, totalPendingRewards);
        

        stakingData.lastUpdatedTime = uint64(block.timestamp);
        stakingData.lastTimeClaimed = stakingData.lastTimeClaimed +  ONE_DAY_IN_SECONDS * claimTimes;


        if (stakingData.lastTimeDeposited + stakingData.interestDuration <= uint64(block.timestamp)) {
            stakingData.lastTimeClaimed = stakingData.lastTimeDeposited + stakingData.interestDuration;
        }

        stakingData.totalClaimed = stakingData.totalClaimed + totalPendingRewards;
        
        emit LinearRewardClaimed(_account, totalPendingRewards);
    }

    function poolPendingRewardPerday(address _account) public view returns (uint256, uint64) {
        StakingInfo storage stakingData = userStakingAmounts[_account];

        if (uint64(block.timestamp) < stakingData.lastTimeClaimed) {
            return(0, 0);
        }

        uint64 claimTimes = ((uint64(block.timestamp) - stakingData.lastTimeClaimed) / uint64(ONE_DAY_IN_SECONDS)) + 1;
        uint256 rewardPerDay = ((stakingData.totalStakes * stakingData.interestRates) / PRECISION_POINT) / (THIRTY_DAYS_IN_SECONDS / ONE_DAY_IN_SECONDS);

        if (stakingData.interestDuration > 0 && (stakingData.lastTimeDeposited + stakingData.interestDuration < uint64(block.timestamp))) {
            claimTimes = (((stakingData.lastTimeDeposited + stakingData.interestDuration) - stakingData.lastTimeClaimed) / uint64(ONE_DAY_IN_SECONDS));    
        }


        uint256 totalPendingReward = rewardPerDay * claimTimes;
        return (totalPendingReward, claimTimes);
    }

    function _rewardCommissionToAllReferralLevels(uint256 amount, address _account) internal {
        uint256 level = 1;
        address sentinel = _account;

        while (level <= 9) {
            address referrerByLevel = referralLevels[sentinel];

            StakingInfo storage stakingData = userStakingAmounts[referrerByLevel];

            uint128 maximumAmount;
            uint128 minimumAmount;

            (maximumAmount, minimumAmount)  = getClaimPackagesRange(level - 1);
            
            if (
                (totalReferralInvitations[referrerByLevel] >= MonthlyInterestConditions[level - 1]) && 
                (stakingData.totalStakes >= (uint256(minimumAmount) * DECIMAL))
            ) {
                uint256 commissionAmount = ((amount * MonthlyInterestLevels[level - 1])) / PRECISION_POINT;

                if (stakingData.totalClaimed >= stakingData.maxClaim) {
                    emit CantClaimReward(referrerByLevel, commissionAmount, stakingData.maxClaim);
                    sentinel = referrerByLevel; // need double check
                    level++;
                    continue;
                }

                if (stakingData.totalClaimed + commissionAmount > stakingData.maxClaim) {
                    commissionAmount = stakingData.maxClaim - stakingData.totalClaimed;
                }

                stakingData.totalClaimed = stakingData.totalClaimed + commissionAmount;
                matchingBonus[referrerByLevel] += commissionAmount;

                rewardToken.transferFrom(
                    treasury,
                    referrerByLevel,
                    commissionAmount
                );

                emit LinearRewardReferrerByLevel(
                    _account,
                    referrerByLevel,
                    level,
                    commissionAmount
                );    
            } 
            
            sentinel = referrerByLevel;
            level++;
            // break; old code
        }
    }

    function _rewardToAllReferralLevels(uint256 amount, address _account) internal {
        uint256 level = 1;
        address sentinel = _account;

        while (level <= 7) {
            address referrerByLevel = referralLevels[sentinel];
            StakingInfo storage stakingData = userStakingAmounts[referrerByLevel];

            if (referrerByLevel == address(0)) {
                break;
            }

            referralInvitationsByCommissionLevel[referrerByLevel][level] += 1;
            emit ReferralLevelAdded(
                _account,
                referrerByLevel,
                level
            );

            if (
                totalReferralInvitations[referrerByLevel] >=
                commissionInviteConditions[level - 1]
            ) {
                uint256 commissionAmount = (amount * commissionInterestLevels[level - 1]) / PRECISION_POINT;

                // if (stakingData.totalClaimed + commissionAmount > stakingData.maxClaim) {
                //     emit CantClaimReward(referrerByLevel, commissionAmount, stakingData.maxClaim);
                //     level++;
                //     continue;
                // }

                if (stakingData.totalClaimed >= stakingData.maxClaim) {
                    emit CantClaimReward(referrerByLevel, commissionAmount, stakingData.maxClaim);
                    sentinel = referrerByLevel; // need double check
                    level++;
                    continue;
                }

                if (stakingData.totalClaimed + commissionAmount > stakingData.maxClaim) {
                    commissionAmount = stakingData.maxClaim - stakingData.totalClaimed;
                }
                
                stakingData.totalClaimed = stakingData.totalClaimed + commissionAmount;
                directBonus[referrerByLevel] += commissionAmount;

                rewardToken.transferFrom(
                    treasury,
                    referrerByLevel,
                    commissionAmount
                );

                IIDOPool(ido).usdcUserBought(referrerByLevel, commissionAmount);
                
                emit CommissionRewardReferrerByLevel(
                    _account,
                    referrerByLevel,
                    level,
                    commissionAmount,
                    referralInvitationsByCommissionLevel[referrerByLevel][level]
                );
            }
            
            sentinel = referrerByLevel;
            level++;
            // break; old code
        }
    }

    /// -----------------------------------
    /// --------- Pause Function ----------
    /// -----------------------------------

    function Pause() external onlyAdmin {
        poolStatus = false;
        _pause();
    }

    function UnPause() external onlyAdmin {
        poolStatus = true;
        _unpause();
    }


    /// --------------------------------
    /// ------- Modifier Function ------
    /// --------------------------------

    modifier onlyAdmin() {
        require(msg.sender == admin, "Permission: User is not admin");
        _;
    }
}