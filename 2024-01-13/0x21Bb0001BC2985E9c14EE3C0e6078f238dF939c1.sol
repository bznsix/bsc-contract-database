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
// OpenZeppelin Contracts (last updated v4.9.0) (token/ERC721/IERC721.sol)

pragma solidity ^0.8.0;

import "../../utils/introspection/IERC165.sol";

/**
 * @dev Required interface of an ERC721 compliant contract.
 */
interface IERC721 is IERC165 {
    /**
     * @dev Emitted when `tokenId` token is transferred from `from` to `to`.
     */
    event Transfer(address indexed from, address indexed to, uint256 indexed tokenId);

    /**
     * @dev Emitted when `owner` enables `approved` to manage the `tokenId` token.
     */
    event Approval(address indexed owner, address indexed approved, uint256 indexed tokenId);

    /**
     * @dev Emitted when `owner` enables or disables (`approved`) `operator` to manage all of its assets.
     */
    event ApprovalForAll(address indexed owner, address indexed operator, bool approved);

    /**
     * @dev Returns the number of tokens in ``owner``'s account.
     */
    function balanceOf(address owner) external view returns (uint256 balance);

    /**
     * @dev Returns the owner of the `tokenId` token.
     *
     * Requirements:
     *
     * - `tokenId` must exist.
     */
    function ownerOf(uint256 tokenId) external view returns (address owner);

    /**
     * @dev Safely transfers `tokenId` token from `from` to `to`.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `tokenId` token must exist and be owned by `from`.
     * - If the caller is not `from`, it must be approved to move this token by either {approve} or {setApprovalForAll}.
     * - If `to` refers to a smart contract, it must implement {IERC721Receiver-onERC721Received}, which is called upon a safe transfer.
     *
     * Emits a {Transfer} event.
     */
    function safeTransferFrom(address from, address to, uint256 tokenId, bytes calldata data) external;

    /**
     * @dev Safely transfers `tokenId` token from `from` to `to`, checking first that contract recipients
     * are aware of the ERC721 protocol to prevent tokens from being forever locked.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `tokenId` token must exist and be owned by `from`.
     * - If the caller is not `from`, it must have been allowed to move this token by either {approve} or {setApprovalForAll}.
     * - If `to` refers to a smart contract, it must implement {IERC721Receiver-onERC721Received}, which is called upon a safe transfer.
     *
     * Emits a {Transfer} event.
     */
    function safeTransferFrom(address from, address to, uint256 tokenId) external;

    /**
     * @dev Transfers `tokenId` token from `from` to `to`.
     *
     * WARNING: Note that the caller is responsible to confirm that the recipient is capable of receiving ERC721
     * or else they may be permanently lost. Usage of {safeTransferFrom} prevents loss, though the caller must
     * understand this adds an external call which potentially creates a reentrancy vulnerability.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `tokenId` token must be owned by `from`.
     * - If the caller is not `from`, it must be approved to move this token by either {approve} or {setApprovalForAll}.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(address from, address to, uint256 tokenId) external;

    /**
     * @dev Gives permission to `to` to transfer `tokenId` token to another account.
     * The approval is cleared when the token is transferred.
     *
     * Only a single account can be approved at a time, so approving the zero address clears previous approvals.
     *
     * Requirements:
     *
     * - The caller must own the token or be an approved operator.
     * - `tokenId` must exist.
     *
     * Emits an {Approval} event.
     */
    function approve(address to, uint256 tokenId) external;

    /**
     * @dev Approve or remove `operator` as an operator for the caller.
     * Operators can call {transferFrom} or {safeTransferFrom} for any token owned by the caller.
     *
     * Requirements:
     *
     * - The `operator` cannot be the caller.
     *
     * Emits an {ApprovalForAll} event.
     */
    function setApprovalForAll(address operator, bool approved) external;

    /**
     * @dev Returns the account approved for `tokenId` token.
     *
     * Requirements:
     *
     * - `tokenId` must exist.
     */
    function getApproved(uint256 tokenId) external view returns (address operator);

    /**
     * @dev Returns if the `operator` is allowed to manage all of the assets of `owner`.
     *
     * See {setApprovalForAll}
     */
    function isApprovedForAll(address owner, address operator) external view returns (bool);
}
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.9.4) (utils/Context.sol)

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

    function _contextSuffixLength() internal view virtual returns (uint256) {
        return 0;
    }
}
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/Counters.sol)

pragma solidity ^0.8.0;

/**
 * @title Counters
 * @author Matt Condon (@shrugs)
 * @dev Provides counters that can only be incremented, decremented or reset. This can be used e.g. to track the number
 * of elements in a mapping, issuing ERC721 ids, or counting request ids.
 *
 * Include with `using Counters for Counters.Counter;`
 */
library Counters {
    struct Counter {
        // This variable should never be directly accessed by users of the library: interactions must be restricted to
        // the library's function. As of Solidity v0.5.2, this cannot be enforced, though there is a proposal to add
        // this feature: see https://github.com/ethereum/solidity/issues/4637
        uint256 _value; // default: 0
    }

    function current(Counter storage counter) internal view returns (uint256) {
        return counter._value;
    }

    function increment(Counter storage counter) internal {
        unchecked {
            counter._value += 1;
        }
    }

    function decrement(Counter storage counter) internal {
        uint256 value = counter._value;
        require(value > 0, "Counter: decrement overflow");
        unchecked {
            counter._value = value - 1;
        }
    }

    function reset(Counter storage counter) internal {
        counter._value = 0;
    }
}
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/introspection/IERC165.sol)

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC165 standard, as defined in the
 * https://eips.ethereum.org/EIPS/eip-165[EIP].
 *
 * Implementers can declare support of contract interfaces, which can then be
 * queried by others ({ERC165Checker}).
 *
 * For an implementation, see {ERC165}.
 */
interface IERC165 {
    /**
     * @dev Returns true if this contract implements the interface defined by
     * `interfaceId`. See the corresponding
     * https://eips.ethereum.org/EIPS/eip-165#how-interfaces-are-identified[EIP section]
     * to learn more about how these ids are created.
     *
     * This function call must use less than 30 000 gas.
     */
    function supportsInterface(bytes4 interfaceId) external view returns (bool);
}
// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/security/Pausable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";

interface INonfungiblePositionManager {
    /// @notice Returns the position information associated with a given token ID.
    /// @dev Throws if the token ID is not valid.
    /// @param tokenId The ID of the token that represents the position
    /// @return nonce The nonce for permits
    /// @return operator The address that is approved for spending
    /// @return token0 The address of the token0 for a specific pool
    /// @return token1 The address of the token1 for a specific pool
    /// @return fee The fee associated with the pool
    /// @return tickLower The lower end of the tick range for the position
    /// @return tickUpper The higher end of the tick range for the position
    /// @return liquidity The liquidity of the position
    /// @return feeGrowthInside0LastX128 The fee growth of token0 as of the last action on the individual position
    /// @return feeGrowthInside1LastX128 The fee growth of token1 as of the last action on the individual position
    /// @return tokensOwed0 The uncollected amount of token0 owed to the position as of the last computation
    /// @return tokensOwed1 The uncollected amount of token1 owed to the position as of the last computation
    function positions(
        uint256 tokenId
    )
        external
        view
        returns (
            uint96 nonce,
            address operator,
            address token0,
            address token1,
            uint24 fee,
            int24 tickLower,
            int24 tickUpper,
            uint128 liquidity,
            uint256 feeGrowthInside0LastX128,
            uint256 feeGrowthInside1LastX128,
            uint128 tokensOwed0,
            uint128 tokensOwed1
        );
}

contract Mar3Staking is Ownable, Pausable {
    using Counters for Counters.Counter;
    Counters.Counter public poolIdCount;

    uint256 public constant DENOMINATOR = 10000;
    uint256 public constant ONE_YEAR_IN_DAYS = 360;
    uint256 public constant ONE_DAY_IN_SECONDS = 86400;
    uint256 public constant MINIMUM_DEPOSIT_AMOUNT = 1000 ether;

    address public signer;

    mapping(address => bool) public adminList;
    mapping(uint256 => Pool) public pools;
    mapping(uint256 => mapping(address => UserInfo)) public userInfos;

    enum PoolStatus {
        NOT_STARTED,
        STARTED,
        FINISHED,
        PAUSED
    }

    struct Pool {
        uint256 poolId;
        uint256 startTime;
        uint256 endTime;
        uint256 apy;
        uint256 duration;
        uint256 capacity;
        address depositTokenAddress;
        address earnTokenAddress;
        uint256 totalTokenDeposited;
        uint256 totalValueLocked;
        uint256 totalExpectedTokenEarned;
        uint256 totalTokenEarned;
        bool isPaused;
        bool isLpPool;
    }

    struct UserInfo {
        uint256 totalTokenDeposited;
        uint256 totalExpectedTokenEarned;
        uint256 totalTokenEarned;
        Deposit[] deposits;
    }

    struct Deposit {
        uint256 depositAmount;
        uint256 expectedEarnAmount;
        uint256 unstakeTime;
        uint256 tokenId;
        uint256 createdAt;
        uint256 unstakedAt;
    }

    event Staked(
        address indexed user,
        uint256 poolId,
        uint256 depositAmount,
        uint256 expectedEarnAmount,
        uint256 duration,
        uint256 unstakeTime
    );
    event LpStaked(
        address indexed user,
        uint256 poolId,
        uint256 depositAmount,
        uint256 expectedEarnAmount,
        uint256 duration,
        uint256 unstakeTime,
        uint256 tokenId
    );
    event Unstaked(
        address indexed user,
        uint256 poolId,
        uint256 depositIndex,
        uint256 depositAmount,
        uint256 earnAmount
    );
    event LpUnstaked(
        address indexed user,
        uint256 poolId,
        uint256 depositIndex,
        uint256 depositAmount,
        uint256 earnAmount,
        uint256 tokenId
    );
    event PoolCreated(
        uint256 poolId,
        uint256 startTime,
        uint256 endTime,
        uint256 apy,
        uint256 duration,
        uint256 capacity,
        address indexed depositTokenAddress,
        address indexed earnTokenAddress,
        bool isLpPool
    );
    event PoolUpdated(
        uint256 poolId,
        uint256 startTime,
        uint256 endTime,
        uint256 apy,
        uint256 duration,
        uint256 capacity,
        address indexed depositTokenAddress,
        address indexed earnTokenAddress,
        bool isLpPool
    );
    event PoolPaused(uint256 poolId);
    event PoolUnpaused(uint256 poolId);

    constructor() {
        poolIdCount.increment();
    }

    function stake(
        uint256 poolId,
        uint256 depositAmount
    ) external whenNotPaused {
        Pool storage pool = pools[poolId];
        PoolStatus poolStatus = getPoolStatus(poolId);

        require(!pool.isLpPool, "Wrong pool");
        require(poolStatus == PoolStatus.STARTED, "Cannot stake");
        require(
            depositAmount >= MINIMUM_DEPOSIT_AMOUNT &&
                depositAmount % 1 ether == 0,
            "Invalid deposit amount"
        );
        require(
            pool.totalTokenDeposited + depositAmount <= pool.capacity,
            "Capacity reached"
        );

        UserInfo storage userInfo = userInfos[poolId][_msgSender()];

        IERC20(pool.depositTokenAddress).transferFrom(
            _msgSender(),
            address(this),
            depositAmount
        );

        uint256 expectedEarnAmount = calculateEarnAmount(poolId, depositAmount);
        uint256 unstakeTime = calculateUnstakeTime(poolId);

        pool.totalValueLocked += depositAmount;
        pool.totalTokenDeposited += depositAmount;
        pool.totalExpectedTokenEarned += expectedEarnAmount;
        userInfo.totalTokenDeposited += depositAmount;
        userInfo.totalExpectedTokenEarned += expectedEarnAmount;
        userInfo.deposits.push(
            Deposit(
                depositAmount,
                expectedEarnAmount,
                unstakeTime,
                0,
                block.timestamp,
                0
            )
        );

        emit Staked(
            _msgSender(),
            poolId,
            depositAmount,
            expectedEarnAmount,
            pool.duration,
            unstakeTime
        );
    }

    function stakeLp(
        uint256 poolId,
        uint256 depositAmount,
        uint256 tokenId,
        uint256 expiredAt,
        bytes memory signature
    ) external whenNotPaused {
        Pool storage pool = pools[poolId];
        PoolStatus poolStatus = getPoolStatus(poolId);

        require(pool.isLpPool, "Wrong pool");
        require(poolStatus == PoolStatus.STARTED, "Cannot stake");
        require(
            depositAmount >= MINIMUM_DEPOSIT_AMOUNT &&
                depositAmount % 1 ether == 0,
            "Invalid deposit amount"
        );
        require(
            pool.totalTokenDeposited + depositAmount <= pool.capacity,
            "Capacity reached"
        );
        require(expiredAt > block.timestamp, "Request expired");
        require(
            _checkOwner(pool.depositTokenAddress, _msgSender(), tokenId),
            "Not owner"
        );
        require(
            _checkApproved(pool.depositTokenAddress, _msgSender(), tokenId),
            "Not approved"
        );

        (, , , , , , , uint128 liquidity, , , , ) = INonfungiblePositionManager(
            pool.depositTokenAddress
        ).positions(tokenId);

        require(
            recoverSigner(
                getEthSignedMessageHash(
                    getMessageHash(
                        poolId,
                        depositAmount,
                        tokenId,
                        liquidity,
                        expiredAt
                    )
                ),
                signature
            ) == signer,
            "Signature is wrong"
        );

        UserInfo storage userInfo = userInfos[poolId][_msgSender()];

        IERC721(pool.depositTokenAddress).transferFrom(
            _msgSender(),
            address(this),
            tokenId
        );

        uint256 expectedEarnAmount = calculateEarnAmount(poolId, depositAmount);
        uint256 unstakeTime = calculateUnstakeTime(poolId);

        pool.totalTokenDeposited += depositAmount;
        pool.totalValueLocked += depositAmount;
        pool.totalExpectedTokenEarned += expectedEarnAmount;
        userInfo.totalTokenDeposited += depositAmount;
        userInfo.totalExpectedTokenEarned += expectedEarnAmount;
        userInfo.deposits.push(
            Deposit(
                depositAmount,
                expectedEarnAmount,
                unstakeTime,
                tokenId,
                block.timestamp,
                0
            )
        );

        emit LpStaked(
            _msgSender(),
            poolId,
            depositAmount,
            expectedEarnAmount,
            pool.duration,
            unstakeTime,
            tokenId
        );
    }

    function unstake(uint256 poolId, uint256 depositIndex) external {
        Pool storage pool = pools[poolId];
        UserInfo storage userInfo = userInfos[poolId][_msgSender()];

        require(!pool.isLpPool, "Wrong pool");
        require(pool.depositTokenAddress != address(0), "Invalid pool");
        require(
            userInfo.deposits.length > depositIndex,
            "Invalid deposit index"
        );

        Deposit storage deposit = userInfo.deposits[depositIndex];

        require(deposit.unstakedAt == 0, "Unstaked");
        require(deposit.unstakeTime <= block.timestamp, "Locked");

        deposit.unstakedAt = block.timestamp;

        pool.totalValueLocked -= deposit.depositAmount;
        pool.totalExpectedTokenEarned -= deposit.expectedEarnAmount;
        pool.totalTokenEarned += deposit.expectedEarnAmount;
        userInfo.totalExpectedTokenEarned -= deposit.expectedEarnAmount;
        userInfo.totalTokenEarned += deposit.expectedEarnAmount;

        require(
            IERC20(pool.depositTokenAddress).balanceOf(address(this)) >=
                deposit.depositAmount &&
                IERC20(pool.earnTokenAddress).balanceOf(address(this)) >=
                deposit.expectedEarnAmount,
            "Low balance"
        );

        IERC20(pool.depositTokenAddress).transfer(
            _msgSender(),
            deposit.depositAmount
        );
        IERC20(pool.earnTokenAddress).transfer(
            _msgSender(),
            deposit.expectedEarnAmount
        );

        emit Unstaked(
            _msgSender(),
            poolId,
            depositIndex,
            deposit.depositAmount,
            deposit.expectedEarnAmount
        );
    }

    function unstakeLp(uint256 poolId, uint256 depositIndex) external {
        Pool storage pool = pools[poolId];
        UserInfo storage userInfo = userInfos[poolId][_msgSender()];

        require(pool.isLpPool, "Wrong pool");
        require(pool.depositTokenAddress != address(0), "Invalid pool");
        require(
            userInfo.deposits.length > depositIndex,
            "Invalid deposit index"
        );

        Deposit storage deposit = userInfo.deposits[depositIndex];

        require(deposit.unstakedAt == 0, "Unstaked");
        require(deposit.unstakeTime <= block.timestamp, "Locked");

        deposit.unstakedAt = block.timestamp;

        pool.totalValueLocked -= deposit.depositAmount;
        pool.totalExpectedTokenEarned -= deposit.expectedEarnAmount;
        pool.totalTokenEarned += deposit.expectedEarnAmount;
        userInfo.totalExpectedTokenEarned -= deposit.expectedEarnAmount;
        userInfo.totalTokenEarned += deposit.expectedEarnAmount;

        require(
            IERC20(pool.earnTokenAddress).balanceOf(address(this)) >=
                deposit.expectedEarnAmount,
            "Low balance"
        );

        IERC721(pool.depositTokenAddress).transferFrom(
            address(this),
            _msgSender(),
            deposit.tokenId
        );
        IERC20(pool.earnTokenAddress).transfer(
            _msgSender(),
            deposit.expectedEarnAmount
        );

        emit LpUnstaked(
            _msgSender(),
            poolId,
            depositIndex,
            deposit.depositAmount,
            deposit.expectedEarnAmount,
            deposit.tokenId
        );
    }

    function calculateEarnAmount(
        uint256 poolId,
        uint256 depositAmount
    ) public view returns (uint256 expectedEarnAmount) {
        Pool memory pool = pools[poolId];

        require(pool.depositTokenAddress != address(0), "Invalid pool");

        expectedEarnAmount =
            (depositAmount * pool.apy * pool.duration) /
            (ONE_YEAR_IN_DAYS * DENOMINATOR);
    }

    function calculateUnstakeTime(
        uint256 poolId
    ) public view returns (uint256 unstakeTime) {
        Pool memory pool = pools[poolId];

        require(pool.depositTokenAddress != address(0), "Invalid pool");

        unstakeTime = block.timestamp + pool.duration * ONE_DAY_IN_SECONDS;
    }

    function getPoolInfo(
        uint256 poolId
    ) public view returns (Pool memory pool) {
        pool = pools[poolId];

        require(pool.depositTokenAddress != address(0), "Invalid pool");
    }

    function getPoolStatus(
        uint256 poolId
    ) public view returns (PoolStatus poolStatus) {
        Pool memory pool = pools[poolId];

        require(pool.depositTokenAddress != address(0), "Invalid pool");

        if (pool.isPaused) return PoolStatus.PAUSED;
        if (
            pool.endTime <= block.timestamp ||
            pool.totalTokenDeposited >= pool.capacity
        ) return PoolStatus.FINISHED;
        if (pool.startTime <= block.timestamp && pool.endTime > block.timestamp)
            return PoolStatus.STARTED;

        return PoolStatus.NOT_STARTED;
    }

    function getUserInfo(
        address userAddress,
        uint256 poolId
    ) public view returns (UserInfo memory userInfo) {
        userInfo = userInfos[poolId][userAddress];
    }

    function getTotalTokenEarned()
        public
        view
        returns (uint256 totalTokenEarned, uint256 totalExpectedTokenEarned)
    {
        for (uint256 i = 1; i < poolIdCount.current(); i++) {
            totalExpectedTokenEarned += pools[i].totalExpectedTokenEarned;
            totalTokenEarned += pools[i].totalTokenEarned;
        }
    }

    function getTotalValueLocked()
        public
        view
        returns (uint256 totalValueLocked)
    {
        for (uint256 i = 1; i < poolIdCount.current(); i++) {
            totalValueLocked += pools[i].totalValueLocked;
        }
    }

    function getUserTotalTokenEarned(
        address userAddress
    )
        public
        view
        returns (uint256 totalTokenEarned, uint256 totalExpectedTokenEarned)
    {
        for (uint256 i = 1; i < poolIdCount.current(); i++) {
            totalExpectedTokenEarned += userInfos[i][userAddress]
                .totalExpectedTokenEarned;
            totalTokenEarned += userInfos[i][userAddress].totalTokenEarned;
        }
    }

    function _checkOwner(
        address tokenAddress,
        address sender,
        uint256 tokenId
    ) internal view virtual returns (bool) {
        return IERC721(tokenAddress).ownerOf(tokenId) == sender;
    }

    function _checkApproved(
        address tokenAddress,
        address sender,
        uint256 tokenId
    ) internal view virtual returns (bool) {
        return
            IERC721(tokenAddress).isApprovedForAll(sender, address(this)) ||
            IERC721(tokenAddress).getApproved(tokenId) == address(this);
    }

    modifier onlyAdmin() {
        require(adminList[_msgSender()], "Not admin");
        _;
    }

    function createPool(
        uint256 startTime,
        uint256 endTime,
        uint256 apy,
        uint256 duration,
        uint256 capacity,
        address depositTokenAddress,
        address earnTokenAddress,
        bool isLpPool
    ) external onlyAdmin whenNotPaused {
        uint256 poolId = poolIdCount.current();
        Pool storage pool = pools[poolId];

        require(startTime < endTime, "Invalid end time");
        require(startTime > block.timestamp, "Invalid start time");
        require(duration > 0, "Invalid duration");
        require(capacity > 0, "Invalid capacity");
        require(
            depositTokenAddress != address(0),
            "Invalid deposit token address"
        );
        require(earnTokenAddress != address(0), "Invalid earn token address");

        pool.poolId = poolId;
        pool.startTime = startTime;
        pool.endTime = endTime;
        pool.apy = apy;
        pool.duration = duration;
        pool.capacity = capacity;
        pool.depositTokenAddress = depositTokenAddress;
        pool.earnTokenAddress = earnTokenAddress;
        pool.totalTokenDeposited = 0;
        pool.totalValueLocked = 0;
        pool.totalExpectedTokenEarned = 0;
        pool.totalTokenEarned = 0;
        pool.isPaused = false;
        pool.isLpPool = isLpPool;

        poolIdCount.increment();

        emit PoolCreated(
            poolId,
            startTime,
            endTime,
            apy,
            duration,
            capacity,
            depositTokenAddress,
            earnTokenAddress,
            isLpPool
        );
    }

    function updatePool(
        uint256 poolId,
        uint256 startTime,
        uint256 endTime,
        uint256 apy,
        uint256 duration,
        uint256 capacity,
        address depositTokenAddress,
        address earnTokenAddress,
        bool isLpPool
    ) external onlyAdmin {
        Pool storage pool = pools[poolId];
        PoolStatus poolStatus = getPoolStatus(poolId);

        require(
            poolStatus != PoolStatus.PAUSED &&
                poolStatus != PoolStatus.FINISHED,
            "Invalid pool status"
        );
        require(startTime < endTime, "Invalid end time");
        require(startTime > block.timestamp, "Invalid start time");
        require(duration > 0, "Invalid duration");
        require(capacity > 0, "Invalid capacity");
        require(
            depositTokenAddress != address(0),
            "Invalid deposit token address"
        );
        require(earnTokenAddress != address(0), "Invalid earn token address");

        pool.startTime = startTime;
        pool.endTime = endTime;
        pool.apy = apy;
        pool.duration = duration;
        pool.capacity = capacity;
        pool.depositTokenAddress = depositTokenAddress;
        pool.earnTokenAddress = earnTokenAddress;
        pool.isLpPool = isLpPool;

        emit PoolUpdated(
            poolId,
            startTime,
            endTime,
            apy,
            duration,
            capacity,
            depositTokenAddress,
            earnTokenAddress,
            isLpPool
        );
    }

    function pausePool(uint256 poolId) external onlyAdmin whenNotPaused {
        Pool storage pool = pools[poolId];

        require(pool.depositTokenAddress != address(0), "Invalid pool");
        require(!pool.isPaused, "Cannot pause");

        pool.isPaused = true;

        emit PoolPaused(poolId);
    }

    function unpausePool(uint256 poolId) external onlyAdmin whenNotPaused {
        Pool storage pool = pools[poolId];

        require(pool.depositTokenAddress != address(0), "Invalid pool");
        require(pool.isPaused, "Cannot unpause");

        pool.isPaused = false;

        emit PoolUnpaused(poolId);
    }

    function setAdmins(
        address[] calldata users,
        bool remove
    ) external onlyOwner {
        for (uint256 i = 0; i < users.length; i++) {
            adminList[users[i]] = !remove;
        }
    }

    function setSigner(address _signer) external onlyOwner {
        require(_signer != address(0), "Invalid signer");

        signer = _signer;
    }

    function pause() external onlyOwner {
        _pause();
    }

    function unpause() external onlyOwner {
        _unpause();
    }

    function emergencyTokenWithdraw(
        address token,
        address recipient,
        uint256 amount
    ) external onlyOwner {
        IERC20(token).transfer(recipient, amount);
    }

    function recoverSigner(
        bytes32 _ethSignedMessageHash,
        bytes memory _signature
    ) internal pure returns (address) {
        (bytes32 r, bytes32 s, uint8 v) = splitSignature(_signature);

        return ecrecover(_ethSignedMessageHash, v, r, s);
    }

    function getMessageHash(
        uint256 poolId,
        uint256 depositAmount,
        uint256 tokenId,
        uint128 liquidity,
        uint256 expiredAt
    ) internal pure returns (bytes32) {
        return
            keccak256(
                abi.encodePacked(
                    poolId,
                    depositAmount,
                    tokenId,
                    liquidity,
                    expiredAt
                )
            );
    }

    function getEthSignedMessageHash(
        bytes32 _messageHash
    ) internal pure returns (bytes32) {
        return
            keccak256(
                abi.encodePacked(
                    "\x19Ethereum Signed Message:\n32",
                    _messageHash
                )
            );
    }

    function splitSignature(
        bytes memory sig
    ) internal pure returns (bytes32 r, bytes32 s, uint8 v) {
        require(sig.length == 65, "invalid signature length");

        assembly {
            /*
            First 32 bytes stores the length of the signature

            add(sig, 32) = pointer of sig + 32
            effectively, skips first 32 bytes of signature

            mload(p) loads next 32 bytes starting at the memory address p into memory
            */

            // first 32 bytes, after the length prefix
            r := mload(add(sig, 32))
            // second 32 bytes
            s := mload(add(sig, 64))
            // final byte (first byte of the next 32 bytes)
            v := byte(0, mload(add(sig, 96)))
        }

        // implicitly return (r, s, v)
    }
}
