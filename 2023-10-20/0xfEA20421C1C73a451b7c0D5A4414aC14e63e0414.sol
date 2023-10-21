// SPDX-License-Identifier: MIT

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
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );

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
    function allowance(address owner, address spender)
        external
        view
        returns (uint256);

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

// File: @openzeppelin/contracts/security/ReentrancyGuard.sol

// OpenZeppelin Contracts (last updated v4.9.0) (security/ReentrancyGuard.sol)

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

    /**
     * @dev Returns true if the reentrancy guard is currently set to "entered", which indicates there is a
     * `nonReentrant` function in the call stack.
     */
    function _reentrancyGuardEntered() internal view returns (bool) {
        return _status == _ENTERED;
    }
}

// File: @openzeppelin/contracts/utils/Context.sol

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

// File: @openzeppelin/contracts/access/Ownable.sol

// OpenZeppelin Contracts (last updated v4.9.0) (access/Ownable.sol)

pragma solidity ^0.8.0;

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

pragma solidity ^0.8.17;

contract LamonApp is Ownable, ReentrancyGuard {
    address public usdt = 0x55d398326f99059fF775485246999027B3197955;
    IERC20 public token;

    uint256 private AFFILIATE_PERCENT_USDT = 100; // 10% in units to avoid decimals.
    uint256 public INIT_MIN_DEPOSIT = 5;
    uint256 public INIT_MAX_DEPOSIT = 1000;
    uint256 public INIT_TRADE_FAIR = 0;
    uint256 private INIT_SECOND_PERCENT = 288680;
    uint256 public INIT_MAX_INCOME_MULTIPLIER = 3;

    address public defaultRef = 0x328B887AAD7f5523aE643682f4eD42B35246DEa4;
    uint256 public totalInvested;
    uint256 public totalInvestors;
    uint256 public totalFairs;

    struct User {
        uint256 deposit;
        uint256 reinvested;
        uint256 earned;
        uint256 withdrawn;
        uint256 lamons;
        uint256 timestamp;
        address partner;
        uint256 refsTotal;
        uint256 refs1level;
        uint256 refearnUSDT;
        uint256 percentage;
        uint256 maxEarnings;
        uint256 totalEarnings;
    }

    struct Fairs {
        uint256 wins;
        uint256 loses;
    }

    struct TradeFair {
        address player1;
        address player2;
        uint256 lamons;
        uint256 timestamp;
        address winner;
        uint256 roll;
    }

    mapping(address => User) public user;
    mapping(address => mapping(uint256 => TradeFair)) public tradefair;
    mapping(address => Fairs) public fairs;
    mapping(uint256 => address) public waitingFairs;

    constructor() {
        token = IERC20(usdt);
    }

    event ChangeUser(
        address indexed user,
        address indexed partner,
        uint256 amount
    );

    receive() external payable onlyOwner {}

    function setDefaultRef(address _newDefaultRef) external onlyOwner {
        defaultRef = _newDefaultRef;
    }

    function PlantLamon(uint256 amount, address partner) external nonReentrant {
        require(
            _msgSender() == tx.origin,
            "Function can only be called by a user account"
        );
        require(
            amount >= (INIT_MIN_DEPOSIT * 1e18),
            "Deposit amount lower than minimum"
        );
        require(
            (user[_msgSender()].deposit + amount) <
                (INIT_MAX_DEPOSIT * 1000000000000000000),
            "Max deposit limit has been exceeded"
        );

        _updateprePayment(_msgSender());
        totalInvested += amount;
        totalInvestors += 1;

        user[_msgSender()].deposit += amount;
        user[_msgSender()].maxEarnings = amount * INIT_MAX_INCOME_MULTIPLIER;
        user[_msgSender()].totalEarnings = 0;


        if (user[_msgSender()].percentage == 0) {
            require(
                partner != _msgSender(),
                "Cannot set your own address as partner"
            );
            address ref = user[partner].deposit == 0 ? defaultRef : partner;
            user[ref].refs1level++;
            user[ref].refsTotal++;
            user[user[ref].partner].refsTotal++;
            user[_msgSender()].partner = ref;
            user[_msgSender()].percentage = INIT_SECOND_PERCENT;
        }

        token.transferFrom(_msgSender(), address(this), amount);
        emit ChangeUser(
            _msgSender(),
            user[_msgSender()].partner,
            user[_msgSender()].deposit
        );

        // REF
        _traverseTree(user[_msgSender()].partner, amount);
    }

    function ReinvestLamon(uint256 amount) external nonReentrant {
        require(
            _msgSender() == tx.origin,
            "Function can only be called by a user account"
        );
        uint256 fee = (amount * 30) / 1000;
        _updateprePayment(_msgSender());
        user[_msgSender()].lamons -= amount;
        user[_msgSender()].maxEarnings += amount * INIT_MAX_INCOME_MULTIPLIER; 
        user[_msgSender()].totalEarnings = 0;
        user[_msgSender()].deposit += amount;
        user[_msgSender()].reinvested += amount;
        emit ChangeUser(
            _msgSender(),
            user[_msgSender()].partner,
            user[_msgSender()].deposit
        );
        user[owner()].lamons += fee;
    }

    function Withdraw(uint256 amount) external nonReentrant {
        require(
            _msgSender() == tx.origin,
            "Function can only be called by a user account"
        );
        _updateprePayment(_msgSender());
        uint256 fee = (amount * 50) / 1000;
        amount -= fee;
        require(amount <= user[_msgSender()].lamons, "Insufficient funds");
        if (_msgSender() != defaultRef) {
          require(user[_msgSender()].totalEarnings + amount < user[_msgSender()].maxEarnings, "Max earnings exceed");
        }
        user[_msgSender()].lamons -= amount;
        user[_msgSender()].withdrawn += amount;
        user[_msgSender()].totalEarnings += amount; // Track total earnings
        user[_msgSender()].percentage = INIT_SECOND_PERCENT;
        token.transfer(_msgSender(), amount);
        token.transfer(owner(), fee);
    }

    function checkReward(address account) public view returns (uint256) {
        uint256 RewardTime = block.timestamp - user[account].timestamp;
        RewardTime = (RewardTime >= 86400) ? 86400 : RewardTime;
        uint256 reward = ((((user[account].deposit / 100) * user[account].percentage) /
            10000000000) * RewardTime);
        return reward > user[account].maxEarnings ? user[account].maxEarnings : reward;
    }

    function _updateprePayment(address account) internal {
        uint256 pending = checkReward(_msgSender());
        user[account].timestamp = block.timestamp;
        user[account].lamons += pending;
        user[account].earned += pending;
    }

    function _traverseTree(address account, uint256 value) internal {
        if (value != 0) {
            uint256 feeUSDT = ((value * AFFILIATE_PERCENT_USDT) / 1000);

            user[account].lamons += feeUSDT;

            user[account].refearnUSDT += feeUSDT;

            account = user[account].partner;
        }
    }

    function changeMaxDeposit(uint256 amount) external onlyOwner {
        INIT_MAX_DEPOSIT = amount;
    }

    function changeFairStatus(uint256 status) external onlyOwner {
        INIT_TRADE_FAIR = status;
    }

    // TradeFair
    function createFair(uint256 fairType) public {
        require(INIT_TRADE_FAIR == 1, "Trade fair is not available");
        require(fairType < 3, "Incorrect type");
        _updateprePayment(_msgSender());

        address fairCreator = waitingFairs[fairType];
        require(_msgSender() != fairCreator, "You are already in fair");

        if (fairCreator == address(0)) {
            _createFair(fairType);
        } else {
            _joinFair(fairType, fairCreator);
            _fightFair(fairType, fairCreator);
        }
    }

    function getFairType(uint256 fairType) internal pure returns (uint256) {
        return [5e18, 25e18, 50e18][fairType];
    }

    function _randomNumber() internal view returns (uint256) {
        uint256 randomnumber = uint256(
            keccak256(
                abi.encodePacked(
                    block.timestamp +
                        block.difficulty +
                        ((
                            uint256(keccak256(abi.encodePacked(block.coinbase)))
                        ) / (block.timestamp)) +
                        block.gaslimit +
                        ((uint256(keccak256(abi.encodePacked(_msgSender())))) /
                            (block.timestamp)) +
                        block.number
                )
            )
        );

        return randomnumber % 100;
    }

    function _createFair(uint256 fairType) internal {
        tradefair[_msgSender()][fairType].timestamp = block.timestamp;
        tradefair[_msgSender()][fairType].player1 = _msgSender();
        tradefair[_msgSender()][fairType].player2 = address(0);
        tradefair[_msgSender()][fairType].winner = address(0);
        tradefair[_msgSender()][fairType].lamons = getFairType(fairType);
        tradefair[_msgSender()][fairType].roll = 0;
        require(
            user[_msgSender()].lamons >=
                tradefair[_msgSender()][fairType].lamons,
            "Insuffitient lamon balance"
        );
        user[_msgSender()].lamons -= tradefair[_msgSender()][fairType].lamons;
        waitingFairs[fairType] = _msgSender();
    }

    function _joinFair(uint256 fairType, address fairCreator) internal {
        tradefair[fairCreator][fairType].timestamp = block.timestamp;
        tradefair[fairCreator][fairType].player2 = _msgSender();
        user[_msgSender()].lamons -= tradefair[fairCreator][fairType].lamons;
        waitingFairs[fairType] = address(0);
    }

    function _fightFair(uint256 fairType, address fairCreator) internal {
        uint256 random = _randomNumber();
        uint256 wAmount = tradefair[fairCreator][fairType].lamons * 2;
        uint256 fee = (wAmount * 50) / 1000;

        address winner = random < 50
            ? tradefair[fairCreator][fairType].player1
            : tradefair[fairCreator][fairType].player2;
        address loser = random >= 50
            ? tradefair[fairCreator][fairType].player1
            : tradefair[fairCreator][fairType].player2;

        user[winner].lamons += wAmount;
        tradefair[fairCreator][fairType].winner = winner;
        tradefair[fairCreator][fairType].roll = random;

        fairs[winner].wins++;
        fairs[loser].loses++;
        totalFairs++;

        user[owner()].lamons += fee;
    }
}