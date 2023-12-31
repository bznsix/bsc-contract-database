// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/Pausable.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/IERC20Metadata.sol";
import "@chainlink/contracts/src/v0.8/KeeperCompatible.sol";

import "./interfaces/ITradingFee.sol";
import "./interfaces/ITwapGetter.sol";

contract TradingFeeOperator is KeeperCompatibleInterface, Ownable, Pausable {
    using SafeERC20 for IERC20;

    address public register;

    address immutable public twapGetter;

    /// @dev reward token refers to the pancake V3 pool
    mapping(address => address) rewardInV3Pools;

    /// @notice Represents an incentive
    struct TradingFeeContract {
        address contractAddress;
        string latestCampaignId;
    }

    /// @dev id refers to different trading fee reward contract
    mapping(uint8 => TradingFeeContract) public tradingFeeContracts;

    event NewRegister(address indexed register);
    event RewardTokenPriceUpdated(uint256 block, uint8 contractId, uint256 price);
    event RewardInV3PoolUpdated(address indexed rewardToken, address indexed v3Pool);
    event TradingFeeContractUpdated(uint8 contractId, address contractAddress, string latestCampaignId);

    modifier onlyRegister() {
        require(msg.sender == register, "Not register");
        _;
    }

    constructor(address _twapGetter) {
        twapGetter = _twapGetter;
    }

    function setRegister(address _register) external onlyOwner {
        require(_register != address(0), "Can not be zero address");
        register = _register;
        emit NewRegister(_register);
    }

    function pause() external onlyOwner {
        _pause();
    }

    function unpause() external onlyOwner {
        _unpause();
    }

    //The logic is consistent with the following performUpkeep function, in order to make the code logic clearer.
    function checkUpkeep(bytes calldata) external view override returns (bool upkeepNeeded, bytes memory) {
        if (!paused()) {
            bool upkeepNeeded0;
            bool upkeepNeeded1;

            TradingFeeContract memory tradingFeeContract0 = tradingFeeContracts[0];
            ( , , , , , uint256 campaignClaimTime0, , , ) = ITradingFee(tradingFeeContract0.contractAddress).incentives(tradingFeeContract0.latestCampaignId);
            if (block.timestamp < campaignClaimTime0) {
                upkeepNeeded0 = campaignClaimTime0 - block.timestamp < 3600;
            }

            TradingFeeContract memory tradingFeeContract1 = tradingFeeContracts[1];
            ( , , , , , uint256 campaignClaimTime1, , , ) = ITradingFee(tradingFeeContract1.contractAddress).incentives(tradingFeeContract1.latestCampaignId);
            if (block.timestamp < campaignClaimTime1) {
                upkeepNeeded1 = campaignClaimTime1 - block.timestamp < 3600;
            }

            upkeepNeeded = upkeepNeeded0 || upkeepNeeded1;
        }
    }

    function performUpkeep(bytes calldata) external override onlyRegister whenNotPaused {
        TradingFeeContract memory tradingFeeContract0 = tradingFeeContracts[0];
        ( , , , , , uint256 campaignClaimTime0, , , ) = ITradingFee(tradingFeeContract0.contractAddress).incentives(tradingFeeContract0.latestCampaignId);
        if (campaignClaimTime0 > block.timestamp && campaignClaimTime0 - block.timestamp < 3600) {
            (address rewardToken, uint256 rewardPrice, uint256 rewardToLockRatio, uint256 rewardFeeRatio) = ITradingFee(tradingFeeContract0.contractAddress).incentiveRewards(tradingFeeContract0.latestCampaignId);

            if (rewardInV3Pools[rewardToken] != address(0)) {
                // fetch rewardToken's price
                uint8 decimals = IERC20Metadata(rewardToken).decimals();
                rewardPrice = ITwapGetter(twapGetter).getTwapPrice(rewardInV3Pools[rewardToken], 100, decimals);

                ITradingFee(tradingFeeContract0.contractAddress).updateRewardTokenParams(
                    tradingFeeContract0.latestCampaignId,
                    rewardToken,
                    rewardPrice,
                    rewardToLockRatio,
                    rewardFeeRatio
                );

                emit RewardTokenPriceUpdated(block.number, 0, rewardPrice);
            }
        }

        TradingFeeContract memory tradingFeeContract1 = tradingFeeContracts[1];
        ( , , , , , uint256 campaignClaimTime1, , , ) = ITradingFee(tradingFeeContract1.contractAddress).incentives(tradingFeeContract1.latestCampaignId);
        if (campaignClaimTime1 > block.timestamp && campaignClaimTime1 - block.timestamp < 3600) {
            (address rewardToken, uint256 rewardPrice, uint256 rewardToLockRatio, uint256 rewardFeeRatio) = ITradingFee(tradingFeeContract1.contractAddress).incentiveRewards(tradingFeeContract1.latestCampaignId);

            if (rewardInV3Pools[rewardToken] != address(0)) {
                // fetch rewardToken's price
                uint8 decimals = IERC20Metadata(rewardToken).decimals();
                rewardPrice = ITwapGetter(twapGetter).getTwapPrice(rewardInV3Pools[rewardToken], 100, decimals);

                ITradingFee(tradingFeeContract1.contractAddress).updateRewardTokenParams(
                    tradingFeeContract1.latestCampaignId,
                    rewardToken,
                    rewardPrice,
                    rewardToLockRatio,
                    rewardFeeRatio
                );

                emit RewardTokenPriceUpdated(block.number, 1, rewardPrice);
            }
        }
    }

    function updateRewardInV3Pool(address _rewardToken, address _v3Pool) external onlyOwner {
        require(_rewardToken != address(0), "address can not be empty");
        require(_v3Pool != address(0), "address can not be empty");

        rewardInV3Pools[_rewardToken] = _v3Pool;

        emit RewardInV3PoolUpdated(_rewardToken, _v3Pool);
    }

    function updateTradingFeeContract(uint8 _contractId, address _contractAddress, string calldata _latestCampaignId) external onlyOwner {
        require(_contractId < 2, "only id 0 and 1 exists");
        require(_contractAddress != address(0), "contract can not be empty");

        TradingFeeContract storage tradingFeeContract = tradingFeeContracts[_contractId];
        tradingFeeContract.contractAddress = _contractAddress;
        tradingFeeContract.latestCampaignId = _latestCampaignId;

        emit TradingFeeContractUpdated(_contractId, _contractAddress, _latestCampaignId);
    }

    function callCreateIncentive(
        uint8 _contractId,
        string calldata _campaignId,
        address _rewardToken,
        uint256 _rewardPrice,
        uint256 _rewardToLockRatio,
        uint256 _rewardFeeRatio,
        uint256 _campaignStart,
        uint256 _campaignClaimTime,
        uint256 _campaignClaimEndTime
    ) external onlyOwner {
        TradingFeeContract memory tradingFeeContract = tradingFeeContracts[_contractId];
        ITradingFee(tradingFeeContract.contractAddress).createIncentive(
            _campaignId,
            _rewardToken,
            _rewardPrice,
            _rewardToLockRatio,
            _rewardFeeRatio,
            _campaignStart,
            _campaignClaimTime,
            _campaignClaimEndTime
        );
    }

    function callPrepareIncentive(
        uint8 _contractId,
        string calldata _campaignId,
        uint256 _totalTradingFee,
        bytes32 _proofRoot
    ) external onlyOwner {
        TradingFeeContract memory tradingFeeContract = tradingFeeContracts[_contractId];
        ITradingFee(tradingFeeContract.contractAddress).prepareIncentive(
            _campaignId,
            _totalTradingFee,
            _proofRoot
        );
    }

    function callDepositIncentiveReward(uint8 _contractId, string calldata _campaignId, uint256 _amount, bool _isDynamicReward) external onlyOwner {
        TradingFeeContract memory tradingFeeContract = tradingFeeContracts[_contractId];
        ITradingFee(tradingFeeContract.contractAddress).depositIncentiveReward(
            _campaignId,
            _amount,
            _isDynamicReward
        );
    }

    function callActivateIncentive(uint8 _contractId, string calldata _campaignId) external onlyOwner {
        TradingFeeContract memory tradingFeeContract = tradingFeeContracts[_contractId];
        ITradingFee(tradingFeeContract.contractAddress).activateIncentive(
            _campaignId
        );
    }

    function callWithdrawAll(uint8 _contractId, string calldata _campaignId) external onlyOwner {
        TradingFeeContract memory tradingFeeContract = tradingFeeContracts[_contractId];

        (address rewardToken, , , ) = ITradingFee(tradingFeeContract.contractAddress).incentiveRewards(_campaignId);

        uint256 amountBefore = IERC20Metadata(rewardToken).balanceOf(address(this));
        ITradingFee(tradingFeeContract.contractAddress).withdrawAll(
            _campaignId
        );
        uint256 amountAfter = IERC20Metadata(rewardToken).balanceOf(address(this));

        uint256 amount = amountAfter - amountBefore;

        // reward transfer
        IERC20(rewardToken).safeTransfer(msg.sender, amount);
    }

    function callUpdateCampaignPeriodParams(uint8 _contractId, uint256 _maxPeriod, uint256 _minClaimPeriod, uint256 _maxClaimPeriod) external onlyOwner {
        TradingFeeContract memory tradingFeeContract = tradingFeeContracts[_contractId];
        ITradingFee(tradingFeeContract.contractAddress).updateCampaignPeriodParams(
            _maxPeriod,
            _minClaimPeriod,
            _maxClaimPeriod
        );
    }

    function callUpdateUserQualification(
        uint8 _contractId,
        uint256 _thresholdLockTime,
        uint256 _thresholdLockAmount,
        bool _needProfileIsActivated,
        uint256 _minAmountUSD
    ) external onlyOwner {
        TradingFeeContract memory tradingFeeContract = tradingFeeContracts[_contractId];
        ITradingFee(tradingFeeContract.contractAddress).updateUserQualification(
            _thresholdLockTime,
            _thresholdLockAmount,
            _needProfileIsActivated,
            _minAmountUSD
        );
    }

    function callUpdateRewardTokenParams(uint8 _contractId, string memory _campaignId, address _rewardToken, uint256 _rewardPrice, uint256 _rewardToLockRatio, uint256 _rewardFeeRatio) external onlyOwner {
        TradingFeeContract memory tradingFeeContract = tradingFeeContracts[_contractId];
        ITradingFee(tradingFeeContract.contractAddress).updateRewardTokenParams(
            _campaignId,
            _rewardToken,
            _rewardPrice,
            _rewardToLockRatio,
            _rewardFeeRatio
        );
    }

    function callUpdateTradingFeeClaimedRecordContract(uint8 _contractId, address _tradingFeeClaimedRecord) external onlyOwner {
        TradingFeeContract memory tradingFeeContract = tradingFeeContracts[_contractId];
        ITradingFee(tradingFeeContract.contractAddress).updateTradingFeeClaimedRecordContract(
            _tradingFeeClaimedRecord
        );
    }

    function callPause(uint8 _contractId) external onlyOwner {
        TradingFeeContract memory tradingFeeContract = tradingFeeContracts[_contractId];
        ITradingFee(tradingFeeContract.contractAddress).pause();
    }

    function callUnpause(uint8 _contractId) external onlyOwner {
        TradingFeeContract memory tradingFeeContract = tradingFeeContracts[_contractId];
        ITradingFee(tradingFeeContract.contractAddress).unpause();
    }

    function callCleanUpIncentiveCampaignIds(uint8 _contractId) external onlyOwner {
        TradingFeeContract memory tradingFeeContract = tradingFeeContracts[_contractId];
        ITradingFee(tradingFeeContract.contractAddress).cleanUpIncentiveCampaignIds();
    }
}// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

interface ITradingFee {
    function incentives(string calldata _campaignId) external view returns (uint256, uint256, uint256, bytes32, uint256, uint256, uint256, bool, bool);

    function incentiveRewards(string calldata _campaignId) external view returns (address, uint256, uint256, uint256);

    function createIncentive(
        string calldata _campaignId,
        address _rewardToken,
        uint256 _rewardPrice,
        uint256 _rewardToLockRatio,
        uint256 _rewardFeeRatio,
        uint256 _campaignStart,
        uint256 _campaignClaimTime,
        uint256 _campaignClaimEndTime
    ) external;

    function prepareIncentive(
        string calldata _campaignId,
        uint256 _totalTradingFee,
        bytes32 _proofRoot
    ) external;

    function depositIncentiveReward(string calldata _campaignId, uint256 _amount, bool _isDynamicReward) external;

    function activateIncentive(string calldata _campaignId) external;

    function withdrawAll(string calldata _campaignId) external;

    function updateCampaignPeriodParams(uint256 _maxPeriod, uint256 _minClaimPeriod, uint256 _maxClaimPeriod) external;

    function updateUserQualification(
        uint256 _thresholdLockTime,
        uint256 _thresholdLockAmount,
        bool _needProfileIsActivated,
        uint256 _minAmountUSD
    ) external;

    function updateRewardTokenParams(string memory _campaignId, address _rewardToken, uint256 _rewardPrice, uint256 _rewardToLockRatio, uint256 _rewardFeeRatio) external;

    function updateTradingFeeClaimedRecordContract(address _tradingFeeClaimedRecord) external;

    function paused() external view returns (bool);

    function pause() external;

    function unpause() external;

    function cleanUpIncentiveCampaignIds() external;
}// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

interface ITwapGetter {
    function getTwapPrice(address pancakeV3Pool, uint32 twapInterval, uint8 decimals) external view returns (uint256);
}// SPDX-License-Identifier: MIT
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
pragma solidity ^0.8.0;

import "./KeeperBase.sol";
import "./interfaces/KeeperCompatibleInterface.sol";

abstract contract KeeperCompatible is KeeperBase, KeeperCompatibleInterface {}
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
// OpenZeppelin Contracts (last updated v4.9.0) (token/ERC20/utils/SafeERC20.sol)

pragma solidity ^0.8.0;

import "../IERC20.sol";
import "../extensions/IERC20Permit.sol";
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

    /**
     * @dev Transfer `value` amount of `token` from the calling contract to `to`. If `token` returns no value,
     * non-reverting calls are assumed to be successful.
     */
    function safeTransfer(IERC20 token, address to, uint256 value) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    /**
     * @dev Transfer `value` amount of `token` from `from` to `to`, spending the approval given by `from` to the
     * calling contract. If `token` returns no value, non-reverting calls are assumed to be successful.
     */
    function safeTransferFrom(IERC20 token, address from, address to, uint256 value) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }

    /**
     * @dev Deprecated. This function has issues similar to the ones found in
     * {IERC20-approve}, and its usage is discouraged.
     *
     * Whenever possible, use {safeIncreaseAllowance} and
     * {safeDecreaseAllowance} instead.
     */
    function safeApprove(IERC20 token, address spender, uint256 value) internal {
        // safeApprove should only be called when setting an initial allowance,
        // or when resetting it to zero. To increase and decrease it, use
        // 'safeIncreaseAllowance' and 'safeDecreaseAllowance'
        require(
            (value == 0) || (token.allowance(address(this), spender) == 0),
            "SafeERC20: approve from non-zero to non-zero allowance"
        );
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
    }

    /**
     * @dev Increase the calling contract's allowance toward `spender` by `value`. If `token` returns no value,
     * non-reverting calls are assumed to be successful.
     */
    function safeIncreaseAllowance(IERC20 token, address spender, uint256 value) internal {
        uint256 oldAllowance = token.allowance(address(this), spender);
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, oldAllowance + value));
    }

    /**
     * @dev Decrease the calling contract's allowance toward `spender` by `value`. If `token` returns no value,
     * non-reverting calls are assumed to be successful.
     */
    function safeDecreaseAllowance(IERC20 token, address spender, uint256 value) internal {
        unchecked {
            uint256 oldAllowance = token.allowance(address(this), spender);
            require(oldAllowance >= value, "SafeERC20: decreased allowance below zero");
            _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, oldAllowance - value));
        }
    }

    /**
     * @dev Set the calling contract's allowance toward `spender` to `value`. If `token` returns no value,
     * non-reverting calls are assumed to be successful. Compatible with tokens that require the approval to be set to
     * 0 before setting it to a non-zero value.
     */
    function forceApprove(IERC20 token, address spender, uint256 value) internal {
        bytes memory approvalCall = abi.encodeWithSelector(token.approve.selector, spender, value);

        if (!_callOptionalReturnBool(token, approvalCall)) {
            _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, 0));
            _callOptionalReturn(token, approvalCall);
        }
    }

    /**
     * @dev Use a ERC-2612 signature to set the `owner` approval toward `spender` on `token`.
     * Revert on invalid signature.
     */
    function safePermit(
        IERC20Permit token,
        address owner,
        address spender,
        uint256 value,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) internal {
        uint256 nonceBefore = token.nonces(owner);
        token.permit(owner, spender, value, deadline, v, r, s);
        uint256 nonceAfter = token.nonces(owner);
        require(nonceAfter == nonceBefore + 1, "SafeERC20: permit did not succeed");
    }

    /**
     * @dev Imitates a Solidity high-level call (i.e. a regular function call to a contract), relaxing the requirement
     * on the return value: the return value is optional (but if data is returned, it must not be false).
     * @param token The token targeted by the call.
     * @param data The call data (encoded using abi.encode or one of its variants).
     */
    function _callOptionalReturn(IERC20 token, bytes memory data) private {
        // We need to perform a low level call here, to bypass Solidity's return data size checking mechanism, since
        // we're implementing it ourselves. We use {Address-functionCall} to perform this call, which verifies that
        // the target address contains contract code and also asserts for success in the low-level call.

        bytes memory returndata = address(token).functionCall(data, "SafeERC20: low-level call failed");
        require(returndata.length == 0 || abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
    }

    /**
     * @dev Imitates a Solidity high-level call (i.e. a regular function call to a contract), relaxing the requirement
     * on the return value: the return value is optional (but if data is returned, it must not be false).
     * @param token The token targeted by the call.
     * @param data The call data (encoded using abi.encode or one of its variants).
     *
     * This is a variant of {_callOptionalReturn} that silents catches all reverts and returns a bool instead.
     */
    function _callOptionalReturnBool(IERC20 token, bytes memory data) private returns (bool) {
        // We need to perform a low level call here, to bypass Solidity's return data size checking mechanism, since
        // we're implementing it ourselves. We cannot use {Address-functionCall} here since this should return false
        // and not revert is the subcall reverts.

        (bool success, bytes memory returndata) = address(token).call(data);
        return
            success && (returndata.length == 0 || abi.decode(returndata, (bool))) && Address.isContract(address(token));
    }
}
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (token/ERC20/extensions/IERC20Metadata.sol)

pragma solidity ^0.8.0;

import "../IERC20.sol";

/**
 * @dev Interface for the optional metadata functions from the ERC20 standard.
 *
 * _Available since v4.1._
 */
interface IERC20Metadata is IERC20 {
    /**
     * @dev Returns the name of the token.
     */
    function name() external view returns (string memory);

    /**
     * @dev Returns the symbol of the token.
     */
    function symbol() external view returns (string memory);

    /**
     * @dev Returns the decimals places of the token.
     */
    function decimals() external view returns (uint8);
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
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract KeeperBase {
  error OnlySimulatedBackend();

  /**
   * @notice method that allows it to be simulated via eth_call by checking that
   * the sender is the zero address.
   */
  function preventExecution() internal view {
    if (tx.origin != address(0)) {
      revert OnlySimulatedBackend();
    }
  }

  /**
   * @notice modifier that allows it to be simulated via eth_call by checking
   * that the sender is the zero address.
   */
  modifier cannotExecute() {
    preventExecution();
    _;
  }
}
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface KeeperCompatibleInterface {
  /**
   * @notice method that is simulated by the keepers to see if any work actually
   * needs to be performed. This method does does not actually need to be
   * executable, and since it is only ever simulated it can consume lots of gas.
   * @dev To ensure that it is never called, you may want to add the
   * cannotExecute modifier from KeeperBase to your implementation of this
   * method.
   * @param checkData specified in the upkeep registration so it is always the
   * same for a registered upkeep. This can easilly be broken down into specific
   * arguments using `abi.decode`, so multiple upkeeps can be registered on the
   * same contract and easily differentiated by the contract.
   * @return upkeepNeeded boolean to indicate whether the keeper should call
   * performUpkeep or not.
   * @return performData bytes that the keeper should call performUpkeep with, if
   * upkeep is needed. If you would like to encode data to decode later, try
   * `abi.encode`.
   */
  function checkUpkeep(bytes calldata checkData) external returns (bool upkeepNeeded, bytes memory performData);

  /**
   * @notice method that is actually executed by the keepers, via the registry.
   * The data returned by the checkUpkeep simulation will be passed into
   * this method to actually be executed.
   * @dev The input to this method should not be trusted, and the caller of the
   * method should not even be restricted to any single registry. Anyone should
   * be able call it, and the input should be validated, there is no guarantee
   * that the data passed in is the performData returned from checkUpkeep. This
   * could happen due to malicious keepers, racing keepers, or simply a state
   * change while the performUpkeep transaction is waiting for confirmation.
   * Always validate the data passed in.
   * @param performData is the data which was passed back from the checkData
   * simulation. If it is encoded, it can easily be decoded into other types by
   * calling `abi.decode`. This data should not be trusted, and should be
   * validated against the contract's current state.
   */
  function performUpkeep(bytes calldata performData) external;
}
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.9.0) (utils/Address.sol)

pragma solidity ^0.8.1;

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
     *
     * Furthermore, `isContract` will also return true if the target contract within
     * the same transaction is already scheduled for destruction by `SELFDESTRUCT`,
     * which only has an effect at the end of a transaction.
     * ====
     *
     * [IMPORTANT]
     * ====
     * You shouldn't rely on `isContract` to protect against flash loan attacks!
     *
     * Preventing calls from contracts is highly discouraged. It breaks composability, breaks support for smart wallets
     * like Gnosis Safe, and does not provide security since it can be circumvented by calling from a contract
     * constructor.
     * ====
     */
    function isContract(address account) internal view returns (bool) {
        // This method relies on extcodesize/address.code.length, which returns 0
        // for contracts in construction, since the code is only stored at the end
        // of the constructor execution.

        return account.code.length > 0;
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
     * https://consensys.net/diligence/blog/2019/09/stop-using-soliditys-transfer-now/[Learn more].
     *
     * IMPORTANT: because control is transferred to `recipient`, care must be
     * taken to not create reentrancy vulnerabilities. Consider using
     * {ReentrancyGuard} or the
     * https://solidity.readthedocs.io/en/v0.8.0/security-considerations.html#use-the-checks-effects-interactions-pattern[checks-effects-interactions pattern].
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
        return functionCallWithValue(target, data, 0, "Address: low-level call failed");
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
    function functionCallWithValue(address target, bytes memory data, uint256 value) internal returns (bytes memory) {
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
        (bool success, bytes memory returndata) = target.call{value: value}(data);
        return verifyCallResultFromTarget(target, success, returndata, errorMessage);
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
        (bool success, bytes memory returndata) = target.staticcall(data);
        return verifyCallResultFromTarget(target, success, returndata, errorMessage);
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
        (bool success, bytes memory returndata) = target.delegatecall(data);
        return verifyCallResultFromTarget(target, success, returndata, errorMessage);
    }

    /**
     * @dev Tool to verify that a low level call to smart-contract was successful, and revert (either by bubbling
     * the revert reason or using the provided one) in case of unsuccessful call or if target was not a contract.
     *
     * _Available since v4.8._
     */
    function verifyCallResultFromTarget(
        address target,
        bool success,
        bytes memory returndata,
        string memory errorMessage
    ) internal view returns (bytes memory) {
        if (success) {
            if (returndata.length == 0) {
                // only check isContract if the call was successful and the return data is empty
                // otherwise we already know that it was a contract
                require(isContract(target), "Address: call to non-contract");
            }
            return returndata;
        } else {
            _revert(returndata, errorMessage);
        }
    }

    /**
     * @dev Tool to verify that a low level call was successful, and revert if it wasn't, either by bubbling the
     * revert reason or using the provided one.
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
            _revert(returndata, errorMessage);
        }
    }

    function _revert(bytes memory returndata, string memory errorMessage) private pure {
        // Look for revert reason and bubble it up if present
        if (returndata.length > 0) {
            // The easiest way to bubble the revert reason is using memory via assembly
            /// @solidity memory-safe-assembly
            assembly {
                let returndata_size := mload(returndata)
                revert(add(32, returndata), returndata_size)
            }
        } else {
            revert(errorMessage);
        }
    }
}
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.9.0) (token/ERC20/extensions/IERC20Permit.sol)

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC20 Permit extension allowing approvals to be made via signatures, as defined in
 * https://eips.ethereum.org/EIPS/eip-2612[EIP-2612].
 *
 * Adds the {permit} method, which can be used to change an account's ERC20 allowance (see {IERC20-allowance}) by
 * presenting a message signed by the account. By not relying on {IERC20-approve}, the token holder account doesn't
 * need to send a transaction, and thus is not required to hold Ether at all.
 */
interface IERC20Permit {
    /**
     * @dev Sets `value` as the allowance of `spender` over ``owner``'s tokens,
     * given ``owner``'s signed approval.
     *
     * IMPORTANT: The same issues {IERC20-approve} has related to transaction
     * ordering also apply here.
     *
     * Emits an {Approval} event.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     * - `deadline` must be a timestamp in the future.
     * - `v`, `r` and `s` must be a valid `secp256k1` signature from `owner`
     * over the EIP712-formatted function arguments.
     * - the signature must use ``owner``'s current nonce (see {nonces}).
     *
     * For more information on the signature format, see the
     * https://eips.ethereum.org/EIPS/eip-2612#specification[relevant EIP
     * section].
     */
    function permit(
        address owner,
        address spender,
        uint256 value,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external;

    /**
     * @dev Returns the current nonce for `owner`. This value must be
     * included whenever a signature is generated for {permit}.
     *
     * Every successful call to {permit} increases ``owner``'s nonce by one. This
     * prevents a signature from being used multiple times.
     */
    function nonces(address owner) external view returns (uint256);

    /**
     * @dev Returns the domain separator used in the encoding of the signature for {permit}, as defined by {EIP712}.
     */
    // solhint-disable-next-line func-name-mixedcase
    function DOMAIN_SEPARATOR() external view returns (bytes32);
}
