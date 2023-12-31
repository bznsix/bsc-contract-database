// SPDX-License-Identifier: UNLICENSED

pragma solidity 0.8.4;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";

import "./utils/OwnablePausable.sol";
import "./utils/ExtendableTokenTimelock.sol";

/**
 * @title XIL Staking Contract
 */
contract XillionAccessStaking is OwnablePausable, ReentrancyGuard {

    using SafeERC20 for IERC20;

    /* ------------------------------------------------------------ VARIABLES ----------------------------------------------------------- */

    /**
     * @notice The Staking Token
     * @dev This is meant to be the XIL token, but we are reserving the right to change it in case we have need to release a V2 for security purposes for example
     */
    IERC20 public stakingToken;

    /**
     * @notice The minimum staking period enabled by this contract
     */
    uint256 public minimumStakingDays = 1;

    /**
     * @notice Record of all the stakes currently in this contract
     */
    mapping(address => Stake[]) public stakes;

    /**
     * @notice Nonce for generating unique IDs
     */
    uint256 private _stakeIdNonce;

    /* ----------------------------------------------------------- CONSTRUCTOR ---------------------------------------------------------- */

    /**
     * @notice Called on creation of the Staking contract
     * @param stakingTokenAddr Address of the Staking Token
     * @param ownerAddr Address of the owner of this contract (most likely a multi SIG wallet)
     */
    constructor(address stakingTokenAddr, address ownerAddr) {

        require(stakingTokenAddr != address(0) && ownerAddr != address(0), "Invalid address");

        stakingToken = IERC20(stakingTokenAddr);

        if (_msgSender() != ownerAddr) {
            transferOwnership(ownerAddr);
        }

    }

    /* --------------------------------------------------------- MAIN ACTIVITIES -------------------------------------------------------- */

    /**
     * @notice Holds the provided number of XIL tokens for the provided days in an ExtendableTokenTimelock.
     * @param amount Number of tokens to be staked in token decimals
     * @param daysToLock Number of days to lock tokens up for
     */
    function stake(uint256 amount, uint256 daysToLock) external whenNotPaused nonReentrant {

        // guards
        require(stakingToken != IERC20(address(0)), "Staking token has not been set");
        require(amount > 0, "Cannot stake 0");
        require(daysToLock >= minimumStakingDays, "Cannot stake for less than the minimum staking days");

        // create timelock and transfer funds
        uint256 releaseDate = block.timestamp + (daysToLock * 1 days);
        ExtendableTokenTimelock timelock = new ExtendableTokenTimelock(stakingToken, _msgSender(), releaseDate);
        stakingToken.safeTransferFrom(_msgSender(), address(timelock), amount);

        // create unique ID
        bytes32 uid = keccak256(abi.encodePacked(_msgSender(), amount, daysToLock, block.timestamp, block.number, _stakeIdNonce));
        _stakeIdNonce++;

        // record the stake
        Stake memory stakeRecord = Stake(uid, daysToLock, timelock);
        stakes[_msgSender()].push(stakeRecord);

        // emit event
        emit Staked(uid, _msgSender(), address(stakingToken), amount, releaseDate, daysToLock);

    }

    /**
     * @notice Extends the release date of one of the sender's stakes
     * @param stakeIndex Index of the stake in the sender's list of stakes
     * @param daysToAdd Number of days to extend the stake by
     */
    function extend(uint256 stakeIndex, uint256 daysToAdd) external whenNotPaused nonReentrant {

        // guard
        require(daysToAdd > 0, "daysToAdd must be greater than 0");

        // retrieve stake & timelock
        Stake memory stakeRecord = stakes[_msgSender()][stakeIndex];
        ExtendableTokenTimelock timelock = stakeRecord.timelock;

        // extend stake
        timelock.extend(daysToAdd * 1 days);
        stakes[_msgSender()][stakeIndex].daysLocked = stakeRecord.daysLocked + daysToAdd;

        // emit event
        IERC20 stakingTokenInTimelock = stakeRecord.timelock.token();
        emit Extended(
            stakeRecord.uid,
            _msgSender(),
            address(stakingTokenInTimelock),
            stakingTokenInTimelock.balanceOf(address(timelock)),
            timelock.releaseTime(),
            stakes[_msgSender()][stakeIndex].daysLocked
        );

    }

    /**
     * @notice Withdraws all stakes past their daysLocked
     * @dev This method is using the Swap & Delete strategy to remove released stakes to save on gas cost - we don't care about the order of stakes
     */
    function withdraw() external nonReentrant {

        // check amount of stakes
        uint256 stakesLength = stakes[_msgSender()].length;
        require(stakesLength > 0, "No stakes");

        // go through all of the sender's stakes
        uint256 i = 0;
        while (i < stakesLength) {

            Stake memory stakeRecord = stakes[_msgSender()][i];
            ExtendableTokenTimelock timelock = stakeRecord.timelock;

            // check if this stake is releasable
            if (block.timestamp >= timelock.releaseTime()) {

                IERC20 stakingTokenInTimelock = stakeRecord.timelock.token();
                uint256 amount = stakingTokenInTimelock.balanceOf(address(timelock));

                // release timelock
                timelock.release();

                // emit event
                emit Withdrawn(
                    stakeRecord.uid,
                    _msgSender(),
                    address(stakingTokenInTimelock),
                    amount,
                    timelock.releaseTime(),
                    stakeRecord.daysLocked
                );

                // swap with last element
                if (i < stakesLength - 1) {
                    stakes[_msgSender()][i] = stakes[_msgSender()][stakesLength - 1];
                }

                // pop array
                stakes[_msgSender()].pop();
                stakesLength--;

            } else {

                // not releasable, go to next stake
                i++;

            }

        }

    }

    /* ------------------------------------------------------------- MUTATORS ----------------------------------------------------------- */

    /**
     * @notice Overrides the token accepted for staking
     * @param stakingTokenAddr Address of the new staking token being set
     */
    function setStakingToken(address stakingTokenAddr) external onlyOwner {
        require(stakingTokenAddr != address(0), "Invalid address");
        emit StakingTokenUpdated(address(stakingToken), stakingTokenAddr);
        stakingToken = IERC20(stakingTokenAddr);
    }

    /**
     * @notice Overrides the minimum staking period
     * @param minimumStakingDays_ New minimum staking period in days
     */
    function setMinimumStakingDays(uint256 minimumStakingDays_) external onlyOwner {
        require(minimumStakingDays_ > 0, "Minimum Staking Days must be above 0");
        emit MinimumStakingDaysUpdated(minimumStakingDays, minimumStakingDays_);
        minimumStakingDays = minimumStakingDays_;
    }

    /* --------------------------------------------------------- VIEWS (PUBLIC) --------------------------------------------------------- */

    /**
     * @notice Returns the staking data for the stake at index for the sender
     * @param index - Index of the stake data to return
     * @return Amount staked
     * @return Days the stake initially was locked for (it may have stayed in the timelock for longer)
     * @return Release date of the timelock
     * @return UID of the stake
     * @return Address of the staking token
     */
    function getStake(uint256 index) external view returns (uint256, uint256, uint256, bytes32, address) {
        return getStakeForAddress(_msgSender(), index);
    }

    /**
     * @notice Returns the staking data for the provided staker at the provided index
     * @param staker - Address to look up stake for
     * @param index - Index of the stake data to return
     * @return Amount staked
     * @return Days the stake initially was locked for (it may have stayed in the timelock for longer)
     * @return Release date of the timelock
     * @return UID of the stake
     * @return Address of the staking token
     */
    function getStakeForAddress(address staker, uint256 index) public view returns (uint256, uint256, uint256, bytes32, address) {
        Stake memory stakeRecord = stakes[staker][index];
        IERC20 stakingTokenInTimelock = stakeRecord.timelock.token();
        uint256 amount = stakingTokenInTimelock.balanceOf(address(stakeRecord.timelock));
        uint256 releaseDate = stakeRecord.timelock.releaseTime();
        return (amount, stakeRecord.daysLocked, releaseDate, stakeRecord.uid, address(stakingTokenInTimelock));
    }

    /**
     * @return The number of stakes for the sender
     */
    function getStakeCount() external view returns (uint256) {
        return getStakeCountForAddress(_msgSender());
    }

    /**
     * @param staker - Address to look up stake count for
     * @return The number of stakes for the provided staker
     */
    function getStakeCountForAddress(address staker) public view returns (uint256) {
        return stakes[staker].length;
    }

    /* ------------------------------------------------------------- STRUCTS ------------------------------------------------------------ */

    /**
     * @title Struct describing an individual stake transaction to the contract
     * @property uid - Id of the stake, unique across all stakes (current or not)
     * @property daysLocked - Staking period in days
     * @property timelock - ExtendableTokenTimelock contract containing staked tokens
     */
    struct Stake {
        bytes32 uid;
        uint256 daysLocked;
        ExtendableTokenTimelock timelock;
    }

    /* ------------------------------------------------------------- EVENTS ------------------------------------------------------------- */

    /**
     * @notice Event emitted when a Stake is created
     * @param uid Unique ID of the stake
     * @param sender Address of the staker
     * @param stakingToken Address of the staking token
     * @param amount Amount staked
     * @param releaseDate Release date of the stake
     * @param daysLocked Duration of the token timelock
     */
    event Staked(bytes32 uid, address sender, address stakingToken, uint256 amount, uint256 releaseDate, uint256 daysLocked);

    /**
     * @notice Event emitted when a Stake is extended
     * @param uid Unique ID of the stake
     * @param sender Address of the staker
     * @param stakingToken Address of the staking token
     * @param amount Amount staked
     * @param newReleaseDate New release date of the stake
     * @param newDaysLocked New duration of the token timelock
     */
    event Extended(bytes32 uid, address sender, address stakingToken, uint256 amount, uint256 newReleaseDate, uint256 newDaysLocked);

    /**
     * @notice Event emitted when a Stake is withdrawn
     * @param uid Unique ID of the stake
     * @param sender Address of the staker
     * @param stakingToken Address of the staking token
     * @param amount Amount released
     * @param releaseDate Release date of the stake
     * @param daysLocked Duration of the token timelock
     */
    event Withdrawn(bytes32 uid, address sender, address stakingToken, uint256 amount, uint256 releaseDate, uint256 daysLocked);

    /**
     * @notice Event emitted when the staking token is updated
     * @param oldStakingToken Address of the previous staking token
     * @param newStakingToken Address of the new staking token
     */
    event StakingTokenUpdated(address oldStakingToken, address newStakingToken);

    /**
     * @notice Event emitted when the MinimumStakingDays is updated
     * @param oldMinimumStakingDays Address of the previous MinimumStakingDays
     * @param newMinimumStakingDays Address of the new MinimumStakingDays
     */
    event MinimumStakingDaysUpdated(uint256 oldMinimumStakingDays, uint256 newMinimumStakingDays);

}
// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IERC20 {
    /**
     * @dev Returns the amount of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

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
    function transfer(address recipient, uint256 amount) external returns (bool);

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
    event Approval(address indexed owner, address indexed spender, uint256 value);
}
// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "../IERC20.sol";
import "../../../utils/Address.sol";

/**
 * @title SafeERC20
 * @dev Wrappers around ERC20 operations that throw on failure (when the token
 * contract returns false). Tokens that return no value (and instead revert or
 * throw on failure) are also supported, non-reverting calls are assumed to be
 * successful.
 * To use this library you can add a `using SafeERC20 for IERC20;` statement to your contract,
 * which allows you to call the safe operations as `token.safeTransfer(...)`, etc.
 */
library SafeERC20 {
    using Address for address;

    function safeTransfer(
        IERC20 token,
        address to,
        uint256 value
    ) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function safeTransferFrom(
        IERC20 token,
        address from,
        address to,
        uint256 value
    ) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }

    /**
     * @dev Deprecated. This function has issues similar to the ones found in
     * {IERC20-approve}, and its usage is discouraged.
     *
     * Whenever possible, use {safeIncreaseAllowance} and
     * {safeDecreaseAllowance} instead.
     */
    function safeApprove(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {
        // safeApprove should only be called when setting an initial allowance,
        // or when resetting it to zero. To increase and decrease it, use
        // 'safeIncreaseAllowance' and 'safeDecreaseAllowance'
        require(
            (value == 0) || (token.allowance(address(this), spender) == 0),
            "SafeERC20: approve from non-zero to non-zero allowance"
        );
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
    }

    function safeIncreaseAllowance(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {
        uint256 newAllowance = token.allowance(address(this), spender) + value;
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function safeDecreaseAllowance(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {
        unchecked {
            uint256 oldAllowance = token.allowance(address(this), spender);
            require(oldAllowance >= value, "SafeERC20: decreased allowance below zero");
            uint256 newAllowance = oldAllowance - value;
            _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
        }
    }

    /**
     * @dev Imitates a Solidity high-level call (i.e. a regular function call to a contract), relaxing the requirement
     * on the return value: the return value is optional (but if data is returned, it must not be false).
     * @param token The token targeted by the call.
     * @param data The call data (encoded using abi.encode or one of its variants).
     */
    function _callOptionalReturn(IERC20 token, bytes memory data) private {
        // We need to perform a low level call here, to bypass Solidity's return data size checking mechanism, since
        // we're implementing it ourselves. We use {Address.functionCall} to perform this call, which verifies that
        // the target address contains contract code and also asserts for success in the low-level call.

        bytes memory returndata = address(token).functionCall(data, "SafeERC20: low-level call failed");
        if (returndata.length > 0) {
            // Return data is optional
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
}
// SPDX-License-Identifier: MIT

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
     * by making the `nonReentrant` function external, and make it call a
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
// SPDX-License-Identifier: UNLICENSED

pragma solidity 0.8.4;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/Pausable.sol";


/**
 * @title Contract with an owner that can be paused/unpaused by the owner
 */
contract OwnablePausable is Ownable, Pausable {

    /**
     * @notice Allows an admin to pause the contract
     */
    function pause() external onlyOwner {
        _pause();
    }

    /**
     * @notice Allows an admin to unpause the contract
     */
    function unpause() external onlyOwner {
        _unpause();
    }

}
// SPDX-License-Identifier: UNLICENSED

pragma solidity 0.8.4;


import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";


/**
 * @notice A token holder contract that will allow a beneficiary to extract the
 * tokens after a given release time. That release time can be extended by the original token holder.
 *
 * Largely inspired from OpenZeppelin's TokenTimelock
 * https://github.com/OpenZeppelin/openzeppelin-contracts/blob/release-v4.2/contracts/token/ERC20/utils/TokenTimelock.sol
 */
contract ExtendableTokenTimelock is Ownable {

    using SafeERC20 for IERC20;

    /* ------------------------------------------------------------ VARIABLES ----------------------------------------------------------- */

    // ERC20 basic token contract being held
    IERC20 private immutable _token;

    // beneficiary of tokens after they are released
    address private immutable _beneficiary;

    // timestamp when token release is enabled
    uint256 private _releaseTime;

    /* ----------------------------------------------------------- CONSTRUCTOR ---------------------------------------------------------- */

    constructor(
        IERC20 token_,
        address beneficiary_,
        uint256 releaseTime_
    ) {
        require(releaseTime_ >= block.timestamp, "Invalid release time");
        require(beneficiary_ != address(0), "Invalid beneficiary");
        require(token_ != IERC20(address(0)), "Invalid token");
        _token = token_;
        _beneficiary = beneficiary_;
        _releaseTime = releaseTime_;
    }

    /* --------------------------------------------------------- MAIN ACTIVITIES -------------------------------------------------------- */

    /**
     * @notice Transfers tokens held by timelock to beneficiary.
     */
    function release() external {
        require(block.timestamp >= releaseTime(), "Forbidden");

        uint256 amount = token().balanceOf(address(this));
        require(amount > 0, "Timelock empty");

        token().safeTransfer(beneficiary(), amount);
    }


    /**
     * @notice Extends the time on the timelock
     * @param timeToAdd Time to add (in seconds)
     */
    function extend(uint256 timeToAdd) public onlyOwner {

        require(timeToAdd > 0, "Invalid timeToAdd");

        uint256 balance = token().balanceOf(address(this));

        require(balance > 0, "Timelock empty");

        uint256 oldReleaseTime = _releaseTime;

        _releaseTime += timeToAdd;

        emit TokenTimelockExtended(
            address(token()),
            _beneficiary,
            balance,
            oldReleaseTime,
            _releaseTime,
            timeToAdd
        );

    }

    /* --------------------------------------------------------- VIEWS (PUBLIC) --------------------------------------------------------- */

    /**
     * @return The token being held.
     */
    function token() public view returns (IERC20) {
        return _token;
    }

    /**
     * @return The beneficiary of the tokens.
     */
    function beneficiary() public view returns (address) {
        return _beneficiary;
    }

    /**
     * @return The time when the tokens are released.
     */
    function releaseTime() public view returns (uint256) {
        return _releaseTime;
    }

    /* ------------------------------------------------------------- EVENTS ------------------------------------------------------------- */

    /**
     * @notice Event emitted when a TokenTimelock is extended
     * @param token Address of the tokens in the timelock
     * @param beneficiary Address of the beneficiary of the timelock
     * @param amountLocked Amount of tokens currently locked in the timelock
     * @param oldReleaseTime The previous release time
     * @param newReleaseTime The new release time with the extension
     * @param timeAdded The amount of seconds added to the previous release time
     */
    event TokenTimelockExtended(address token, address beneficiary, uint256 amountLocked, uint256 oldReleaseTime, uint256 newReleaseTime, uint256 timeAdded);

}
// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

/**
 * @dev Collection of functions related to the address type
 */
library Address {
    /**
     * @dev Returns true if `account` is a contract.
     *
     * [IMPORTANT]
     * ====
     * It is unsafe to assume that an address for which this function returns
     * false is an externally-owned account (EOA) and not a contract.
     *
     * Among others, `isContract` will return false for the following
     * types of addresses:
     *
     *  - an externally-owned account
     *  - a contract in construction
     *  - an address where a contract will be created
     *  - an address where a contract lived, but was destroyed
     * ====
     */
    function isContract(address account) internal view returns (bool) {
        // This method relies on extcodesize, which returns 0 for contracts in
        // construction, since the code is only stored at the end of the
        // constructor execution.

        uint256 size;
        assembly {
            size := extcodesize(account)
        }
        return size > 0;
    }

    /**
     * @dev Replacement for Solidity's `transfer`: sends `amount` wei to
     * `recipient`, forwarding all available gas and reverting on errors.
     *
     * https://eips.ethereum.org/EIPS/eip-1884[EIP1884] increases the gas cost
     * of certain opcodes, possibly making contracts go over the 2300 gas limit
     * imposed by `transfer`, making them unable to receive funds via
     * `transfer`. {sendValue} removes this limitation.
     *
     * https://diligence.consensys.net/posts/2019/09/stop-using-soliditys-transfer-now/[Learn more].
     *
     * IMPORTANT: because control is transferred to `recipient`, care must be
     * taken to not create reentrancy vulnerabilities. Consider using
     * {ReentrancyGuard} or the
     * https://solidity.readthedocs.io/en/v0.5.11/security-considerations.html#use-the-checks-effects-interactions-pattern[checks-effects-interactions pattern].
     */
    function sendValue(address payable recipient, uint256 amount) internal {
        require(address(this).balance >= amount, "Address: insufficient balance");

        (bool success, ) = recipient.call{value: amount}("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }

    /**
     * @dev Performs a Solidity function call using a low level `call`. A
     * plain `call` is an unsafe replacement for a function call: use this
     * function instead.
     *
     * If `target` reverts with a revert reason, it is bubbled up by this
     * function (like regular Solidity function calls).
     *
     * Returns the raw returned data. To convert to the expected return value,
     * use https://solidity.readthedocs.io/en/latest/units-and-global-variables.html?highlight=abi.decode#abi-encoding-and-decoding-functions[`abi.decode`].
     *
     * Requirements:
     *
     * - `target` must be a contract.
     * - calling `target` with `data` must not revert.
     *
     * _Available since v3.1._
     */
    function functionCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionCall(target, data, "Address: low-level call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`], but with
     * `errorMessage` as a fallback revert reason when `target` reverts.
     *
     * _Available since v3.1._
     */
    function functionCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        return functionCallWithValue(target, data, 0, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but also transferring `value` wei to `target`.
     *
     * Requirements:
     *
     * - the calling contract must have an ETH balance of at least `value`.
     * - the called Solidity function must be `payable`.
     *
     * _Available since v3.1._
     */
    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value
    ) internal returns (bytes memory) {
        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }

    /**
     * @dev Same as {xref-Address-functionCallWithValue-address-bytes-uint256-}[`functionCallWithValue`], but
     * with `errorMessage` as a fallback revert reason when `target` reverts.
     *
     * _Available since v3.1._
     */
    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value,
        string memory errorMessage
    ) internal returns (bytes memory) {
        require(address(this).balance >= value, "Address: insufficient balance for call");
        require(isContract(target), "Address: call to non-contract");

        (bool success, bytes memory returndata) = target.call{value: value}(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but performing a static call.
     *
     * _Available since v3.3._
     */
    function functionStaticCall(address target, bytes memory data) internal view returns (bytes memory) {
        return functionStaticCall(target, data, "Address: low-level static call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-string-}[`functionCall`],
     * but performing a static call.
     *
     * _Available since v3.3._
     */
    function functionStaticCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal view returns (bytes memory) {
        require(isContract(target), "Address: static call to non-contract");

        (bool success, bytes memory returndata) = target.staticcall(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but performing a delegate call.
     *
     * _Available since v3.4._
     */
    function functionDelegateCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionDelegateCall(target, data, "Address: low-level delegate call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-string-}[`functionCall`],
     * but performing a delegate call.
     *
     * _Available since v3.4._
     */
    function functionDelegateCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        require(isContract(target), "Address: delegate call to non-contract");

        (bool success, bytes memory returndata) = target.delegatecall(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    /**
     * @dev Tool to verifies that a low level call was successful, and revert if it wasn't, either by bubbling the
     * revert reason using the provided one.
     *
     * _Available since v4.3._
     */
    function verifyCallResult(
        bool success,
        bytes memory returndata,
        string memory errorMessage
    ) internal pure returns (bytes memory) {
        if (success) {
            return returndata;
        } else {
            // Look for revert reason and bubble it up if present
            if (returndata.length > 0) {
                // The easiest way to bubble the revert reason is using memory via assembly

                assembly {
                    let returndata_size := mload(returndata)
                    revert(add(32, returndata), returndata_size)
                }
            } else {
                revert(errorMessage);
            }
        }
    }
}
// SPDX-License-Identifier: MIT

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
        _setOwner(_msgSender());
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view virtual returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    /**
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions anymore. Can only be called by the current owner.
     *
     * NOTE: Renouncing ownership will leave the contract without an owner,
     * thereby removing any functionality that is only available to the owner.
     */
    function renounceOwnership() public virtual onlyOwner {
        _setOwner(address(0));
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _setOwner(newOwner);
    }

    function _setOwner(address newOwner) private {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}
// SPDX-License-Identifier: MIT

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
     * @dev Returns true if the contract is paused, and false otherwise.
     */
    function paused() public view virtual returns (bool) {
        return _paused;
    }

    /**
     * @dev Modifier to make a function callable only when the contract is not paused.
     *
     * Requirements:
     *
     * - The contract must not be paused.
     */
    modifier whenNotPaused() {
        require(!paused(), "Pausable: paused");
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
        require(paused(), "Pausable: not paused");
        _;
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
