// SPDX-License-Identifier: MIT
pragma solidity ^0.8.15;

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
        // On the first call to nonReentrant, _notEntered will be true
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");

        // Any calls to nonReentrant after this point will fail
        _status = _ENTERED;

        _;

        // By storing the original value once again, a refund is triggered (see
        // https://eips.ethereum.org/EIPS/eip-2200)
        _status = _NOT_ENTERED;
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
abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );

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
        require(
            newOwner != address(0),
            "Ownable: new owner is the zero address"
        );
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

contract BigBlueWhale is Ownable, ReentrancyGuard {
    bool public started;

    uint8[5] public INIT_PERCENTAGES = [20, 18, 15, 12, 8];
    uint256[5] public INIT_AMOUNTS = [
        80 ether,
        30 ether,
        10 ether,
        1 ether,
        0.05 ether
    ];
    uint256[3] public PERCENTAGES = [250, 100, 20];
    uint256 TIME_STEP = 86400;
    address public developer = 0xFfF1746052f181414eA290542B9FD782f1593CdA;
    address public marketing = 0xD29105cB1486fa883C04042440dc9E81EE2B0Fbc;

    mapping(address => Stake) public stake;
    mapping(address => address[]) public level1;
    mapping(address => address[]) public level2;
    mapping(address => address[]) public level3;

    struct Stake {
        uint256 stake;
        uint256 notWithdrawn;
        uint256 timestamp;
        address partner;
        uint8 percentage;
        uint256 refEarning;
        uint256 earning;
        uint256 fastBonus;
        uint256[3] levelBusiness;
    }

    event StakeChanged(
        address indexed user,
        address indexed partner,
        uint256 amount
    );

    modifier whenStarted() {
        require(started, "Not started yet");
        _;
    }

    constructor(address newOwner) {
        transferOwnership(newOwner);
    }

    receive() external payable onlyOwner {}

    function start() external onlyOwner {
        started = true;
    }

    function getLevel1Data(address account)
        external
        view
        returns (address[] memory)
    {
        return level1[account];
    }

    function getLevel2Data(address account)
        external
        view
        returns (address[] memory)
    {
        return level2[account];
    }

    function getLevel3Data(address account)
        external
        view
        returns (address[] memory)
    {
        return level3[account];
    }

    function deposit(address partner)
        external
        payable
        whenStarted
        nonReentrant
    {
        uint256 msgValue = msg.value;
        address sender = _msgSender();

        require(msgValue >= 0.05 ether, "Too low amount to deposit");

        _updateNotWithdrawn();

        Stake storage userStake = stake[sender];

        userStake.stake += msgValue;

        if (userStake.percentage == 0) {
            require(
                partner != sender &&
                    (stake[partner].stake > 0 || partner == marketing),
                "Invalid partner address"
            );

            userStake.partner = partner;

            if (partner != address(0)) {
                address _partner = partner;
                for (uint256 i = 0; i < 3 && _partner != address(0); i++) {
                    if (i == 0) level1[_partner].push(sender);
                    else if (i == 1) level2[_partner].push(sender);
                    else if (i == 2) level3[_partner].push(sender);

                    _partner = stake[_partner].partner;
                }
            }
        }

        _updatePercentage(sender);

        address account = userStake.partner;

        for (uint8 i; i < 3 && account != address(0); i++) {
            stake[account].levelBusiness[i] += msgValue;
            account = stake[account].partner;
        }

        uint256 bonus = (msgValue * 7) / 100;
        userStake.notWithdrawn += bonus;
        userStake.fastBonus += bonus;

        uint256 fee = (msgValue * 5) / 100;
        payable(marketing).transfer(fee);
        payable(developer).transfer(fee);

        emit StakeChanged(sender, userStake.partner, userStake.stake);
    }

    function reinvest(uint256 amount) external whenStarted nonReentrant {
        require(amount >= 0.0004 ether, "Too low amount to reinvest");

        address sender = _msgSender();
        _updateNotWithdrawn();

        Stake storage userStake = stake[sender];

        require(amount <= userStake.notWithdrawn, "Balance too low");

        userStake.notWithdrawn -= amount;
        userStake.stake += amount;

        _updatePercentage(sender);

        emit StakeChanged(sender, userStake.partner, userStake.stake);
    }

    function withdraw(uint256 amount) external whenStarted nonReentrant {
        require(amount >= 0.001 ether, "Too low amount to withdraw");

        address sender = _msgSender();
        _updateNotWithdrawn();

        Stake storage userStake = stake[sender];

        require(amount <= userStake.notWithdrawn, "Balance too low");

        userStake.notWithdrawn -= amount;
        userStake.earning += amount;

        payable(sender).transfer(amount);
    }

    function pendingReward(address account) public view returns (uint256) {
        Stake storage userStake = stake[account];
        uint256 elapsedTime = block.timestamp - userStake.timestamp;

        uint256 amount = ((userStake.stake *
            (elapsedTime / TIME_STEP) *
            userStake.percentage) / 1000);

        // Calculate the maximum withdrawable amount based on the stake conditions
        uint256 maxWithdrawable = userStake.stake *
            2 -
            userStake.earning -
            userStake.notWithdrawn;

        // Ensure the calculated amount does not exceed the maximum withdrawable amount
        if (amount > maxWithdrawable) {
            amount = maxWithdrawable;
        }

        return amount;
    }

    function _updateNotWithdrawn() private {
        uint256 pending = pendingReward(_msgSender());
        Stake storage userStake = stake[_msgSender()];

        // Update the user's timestamp and notWithdrawn balance
        userStake.timestamp = block.timestamp;
        userStake.notWithdrawn += pending;

        // Traverse the referral tree to update notWithdrawn for each level
        _traverseTree(userStake.partner, pending);
    }

    function _traverseTree(address account, uint256 value) private {
        if (value != 0) {
            for (uint8 i; i < 3; i++) {
                if (stake[account].stake > 0) {
                    uint256 amount = ((value * PERCENTAGES[i]) / 1000);
                    stake[account].refEarning += amount;
                    if (
                        (stake[account].earning +
                            stake[account].notWithdrawn +
                            amount) > stake[account].stake * 2
                    ) {
                        amount =
                            (stake[account].stake * 2) -
                            stake[account].earning -
                            stake[account].notWithdrawn;
                    }
                    stake[account].notWithdrawn += amount;

                    account = stake[account].partner;
                }
            }
        }
    }

    function _updatePercentage(address account) private {
        uint256 stakeAmount = stake[account].stake;

        for (uint256 i = INIT_AMOUNTS.length; i > 0; i--) {
            if (stakeAmount >= INIT_AMOUNTS[i - 1]) {
                stake[account].percentage = INIT_PERCENTAGES[i - 1];
                break;
            }
        }
    }

    function getLevelBusiness(address account)
        external
        view
        returns (uint256[3] memory levelIncome)
    {
        levelIncome = stake[account].levelBusiness;
    }
}