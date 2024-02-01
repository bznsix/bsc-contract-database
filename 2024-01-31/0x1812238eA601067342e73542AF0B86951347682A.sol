// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./Ownable.sol";

/**
 * @title AccessControl
 * @dev This abstract contract implements access control mechanism based on roles.
 * Each role can have one or more addresses associated with it, which are granted
 * permission to execute functions with the onlyRole modifier.
 */
abstract contract AccessControl is Ownable {
    /**
     * @dev A mapping of roles to a mapping of addresses to boolean values indicating whether or not they have the role.
     */
    mapping(bytes32 => mapping(address => bool)) private _permits;

    /**
     * @dev Emitted when a role is granted to an address.
     */
    event RoleGranted(bytes32 indexed role, address indexed grantee);

    /**
     * @dev Emitted when a role is revoked from an address.
     */
    event RoleRevoked(bytes32 indexed role, address indexed revokee);

    /**
     * @dev Error message thrown when an address does not have permission to execute a function with onlyRole modifier.
     */
    error NoPermit(bytes32 role);

    /**
     * @dev Constructor that sets the owner of the contract.
     */
    constructor(address owner_) Ownable(owner_) {}

    /**
     * @dev Modifier that restricts access to addresses having roles
     * Throws an error if the caller do not have permit
     */
    modifier onlyRole(bytes32 role) {
        if (!_permits[role][msg.sender]) revert NoPermit(role);
        _;
    }

    /**
     * @dev Checks and reverts if an address do not have a specific role.
     * @param role_ The role to check.
     * @param address_ The address to check.
     */
    function _checkRole(bytes32 role_, address address_) internal virtual {
        if (!_hasRole(role_, address_)) revert NoPermit(role_);
    }

    /**
     * @dev Grants a role to a given address.
     * @param role_ The role to grant.
     * @param grantee_ The address to grant the role to.
     * Emits a RoleGranted event.
     * Can only be called by the owner of the contract.
     */
    function grantRole(
        bytes32 role_,
        address grantee_
    ) external virtual onlyOwner {
        _grantRole(role_, grantee_);
    }

    /**
     * @dev Revokes a role from a given address.
     * @param role_ The role to revoke.
     * @param revokee_ The address to revoke the role from.
     * Emits a RoleRevoked event.
     * Can only be called by the owner of the contract.
     */
    function revokeRole(
        bytes32 role_,
        address revokee_
    ) external virtual onlyOwner {
        _revokeRole(role_, revokee_);
    }

    /**
     * @dev Internal function to grant a role to a given address.
     * @param role_ The role to grant.
     * @param grantee_ The address to grant the role to.
     * Emits a RoleGranted event.
     */
    function _grantRole(bytes32 role_, address grantee_) internal {
        _permits[role_][grantee_] = true;
        emit RoleGranted(role_, grantee_);
    }

    /**
     * @dev Internal function to revoke a role from a given address.
     * @param role_ The role to revoke.
     * @param revokee_ The address to revoke the role from.
     * Emits a RoleRevoked event.
     */
    function _revokeRole(bytes32 role_, address revokee_) internal {
        _permits[role_][revokee_] = false;
        emit RoleRevoked(role_, revokee_);
    }

    /**
     * @dev Checks whether an address has a specific role.
     * @param role_ The role to check.
     * @param address_ The address to check.
     * @return A boolean value indicating whether or not the address has the role.
     */
    function hasRole(
        bytes32 role_,
        address address_
    ) external view returns (bool) {
        return _hasRole(role_, address_);
    }

    function _hasRole(
        bytes32 role_,
        address address_
    ) internal view returns (bool) {
        return _permits[role_][address_];
    }
}
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

abstract contract Gauge {
    struct LimitParams {
        uint256 lastUpdateTimestamp;
        uint256 ratePerSecond;
        uint256 maxLimit;
        uint256 lastUpdateLimit;
    }

    error AmountOutsideLimit();

    function _getCurrentLimit(
        LimitParams storage _params
    ) internal view returns (uint256 _limit) {
        uint256 timeElapsed = block.timestamp - _params.lastUpdateTimestamp;
        uint256 limitIncrease = timeElapsed * _params.ratePerSecond;

        if (limitIncrease + _params.lastUpdateLimit > _params.maxLimit) {
            _limit = _params.maxLimit;
        } else {
            _limit = limitIncrease + _params.lastUpdateLimit;
        }
    }

    function _consumePartLimit(
        uint256 amount_,
        LimitParams storage _params
    ) internal returns (uint256 consumedAmount, uint256 pendingAmount) {
        uint256 currentLimit = _getCurrentLimit(_params);
        _params.lastUpdateTimestamp = block.timestamp;
        if (currentLimit >= amount_) {
            _params.lastUpdateLimit = currentLimit - amount_;
            consumedAmount = amount_;
            pendingAmount = 0;
        } else {
            _params.lastUpdateLimit = 0;
            consumedAmount = currentLimit;
            pendingAmount = amount_ - currentLimit;
        }
    }

    function _consumeFullLimit(
        uint256 amount_,
        LimitParams storage _params
    ) internal {
        uint256 currentLimit = _getCurrentLimit(_params);
        if (currentLimit >= amount_) {
            _params.lastUpdateTimestamp = block.timestamp;
            _params.lastUpdateLimit = currentLimit - amount_;
        } else {
            revert AmountOutsideLimit();
        }
    }
}
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/**
 * @title Ownable
 * @dev The Ownable contract provides a simple way to manage ownership of a contract
 * and allows for ownership to be transferred to a nominated address.
 */
abstract contract Ownable {
    address private _owner;
    address private _nominee;

    event OwnerNominated(address indexed nominee);
    event OwnerClaimed(address indexed claimer);

    error OnlyOwner();
    error OnlyNominee();

    /**
     * @dev Sets the contract's owner to the address that is passed to the constructor.
     */
    constructor(address owner_) {
        _claimOwner(owner_);
    }

    /**
     * @dev Modifier that restricts access to only the contract's owner.
     * Throws an error if the caller is not the owner.
     */
    modifier onlyOwner() {
        if (msg.sender != _owner) revert OnlyOwner();
        _;
    }

    /**
     * @dev Returns the current owner of the contract.
     */
    function owner() external view returns (address) {
        return _owner;
    }

    /**
     * @dev Returns the current nominee for ownership of the contract.
     */
    function nominee() external view returns (address) {
        return _nominee;
    }

    /**
     * @dev Allows the current owner to nominate a new owner for the contract.
     * Throws an error if the caller is not the owner.
     * Emits an `OwnerNominated` event with the address of the nominee.
     */
    function nominateOwner(address nominee_) external {
        if (msg.sender != _owner) revert OnlyOwner();
        _nominee = nominee_;
        emit OwnerNominated(_nominee);
    }

    /**
     * @dev Allows the nominated owner to claim ownership of the contract.
     * Throws an error if the caller is not the nominee.
     * Sets the nominated owner as the new owner of the contract.
     * Emits an `OwnerClaimed` event with the address of the new owner.
     */
    function claimOwner() external {
        if (msg.sender != _nominee) revert OnlyNominee();
        _claimOwner(msg.sender);
    }

    /**
     * @dev Internal function that sets the owner of the contract to the specified address
     * and sets the nominee to address(0).
     */
    function _claimOwner(address claimer_) internal {
        _owner = claimer_;
        _nominee = address(0);
        emit OwnerClaimed(claimer_);
    }
}
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

library ExcessivelySafeCall {
    uint constant LOW_28_MASK =
        0x00000000ffffffffffffffffffffffffffffffffffffffffffffffffffffffff;

    /// @notice Use when you _really_ really _really_ don't trust the called
    /// contract. This prevents the called contract from causing reversion of
    /// the caller in as many ways as we can.
    /// @dev The main difference between this and a solidity low-level call is
    /// that we limit the number of bytes that the callee can cause to be
    /// copied to caller memory. This prevents stupid things like malicious
    /// contracts returning 10,000,000 bytes causing a local OOG when copying
    /// to memory.
    /// @param _target The address to call
    /// @param _gas The amount of gas to forward to the remote contract
    /// @param _maxCopy The maximum number of bytes of returndata to copy
    /// to memory.
    /// @param _calldata The data to send to the remote contract
    /// @return success and returndata, as `.call()`. Returndata is capped to
    /// `_maxCopy` bytes.
    function excessivelySafeCall(
        address _target,
        uint _gas,
        uint16 _maxCopy,
        bytes memory _calldata
    ) internal returns (bool, bytes memory) {
        // set up for assembly call
        uint _toCopy;
        bool _success;
        bytes memory _returnData = new bytes(_maxCopy);
        // dispatch message to recipient
        // by assembly calling "handle" function
        // we call via assembly to avoid memcopying a very large returndata
        // returned by a malicious contract
        assembly {
            _success := call(
                _gas, // gas
                _target, // recipient
                0, // ether value
                add(_calldata, 0x20), // inloc
                mload(_calldata), // inlen
                0, // outloc
                0 // outlen
            )
            // limit our copy to 256 bytes
            _toCopy := returndatasize()
            if gt(_toCopy, _maxCopy) {
                _toCopy := _maxCopy
            }
            // Store the length of the copied bytes
            mstore(_returnData, _toCopy)
            // copy the bytes from returndata[0:_toCopy]
            returndatacopy(add(_returnData, 0x20), 0, _toCopy)
        }
        return (_success, _returnData);
    }

    /// @notice Use when you _really_ really _really_ don't trust the called
    /// contract. This prevents the called contract from causing reversion of
    /// the caller in as many ways as we can.
    /// @dev The main difference between this and a solidity low-level call is
    /// that we limit the number of bytes that the callee can cause to be
    /// copied to caller memory. This prevents stupid things like malicious
    /// contracts returning 10,000,000 bytes causing a local OOG when copying
    /// to memory.
    /// @param _target The address to call
    /// @param _gas The amount of gas to forward to the remote contract
    /// @param _maxCopy The maximum number of bytes of returndata to copy
    /// to memory.
    /// @param _calldata The data to send to the remote contract
    /// @return success and returndata, as `.call()`. Returndata is capped to
    /// `_maxCopy` bytes.
    function excessivelySafeStaticCall(
        address _target,
        uint _gas,
        uint16 _maxCopy,
        bytes memory _calldata
    ) internal view returns (bool, bytes memory) {
        // set up for assembly call
        uint _toCopy;
        bool _success;
        bytes memory _returnData = new bytes(_maxCopy);
        // dispatch message to recipient
        // by assembly calling "handle" function
        // we call via assembly to avoid memcopying a very large returndata
        // returned by a malicious contract
        assembly {
            _success := staticcall(
                _gas, // gas
                _target, // recipient
                add(_calldata, 0x20), // inloc
                mload(_calldata), // inlen
                0, // outloc
                0 // outlen
            )
            // limit our copy to 256 bytes
            _toCopy := returndatasize()
            if gt(_toCopy, _maxCopy) {
                _toCopy := _maxCopy
            }
            // Store the length of the copied bytes
            mstore(_returnData, _toCopy)
            // copy the bytes from returndata[0:_toCopy]
            returndatacopy(add(_returnData, 0x20), 0, _toCopy)
        }
        return (_success, _returnData);
    }

    /**
     * @notice Swaps function selectors in encoded contract calls
     * @dev Allows reuse of encoded calldata for functions with identical
     * argument types but different names. It simply swaps out the first 4 bytes
     * for the new selector. This function modifies memory in place, and should
     * only be used with caution.
     * @param _newSelector The new 4-byte selector
     * @param _buf The encoded contract args
     */
    function swapSelector(
        bytes4 _newSelector,
        bytes memory _buf
    ) internal pure {
        require(_buf.length >= 4);
        uint _mask = LOW_28_MASK;
        assembly {
            // load the first word of
            let _word := mload(add(_buf, 0x20))
            // mask out the top 4 bytes
            // /x
            _word := and(_word, _mask)
            _word := or(_newSelector, _word)
            mstore(add(_buf, 0x20), _word)
        }
    }
}
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "solmate/src/utils/SafeTransferLib.sol";

error ZeroAddress();

/**
 * @title RescueFundsLib
 * @dev A library that provides a function to rescue funds from a contract.
 */

library RescueFundsLib {
    /**
     * @dev The address used to identify ETH.
     */
    address public constant ETH_ADDRESS =
        address(0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE);

    /**
     * @dev thrown when the given token address don't have any code
     */
    error InvalidTokenAddress();

    /**
     * @dev Rescues funds from a contract.
     * @param token_ The address of the token contract.
     * @param rescueTo_ The address of the user.
     * @param amount_ The amount of tokens to be rescued.
     */
    function rescueFunds(
        address token_,
        address rescueTo_,
        uint256 amount_
    ) internal {
        if (rescueTo_ == address(0)) revert ZeroAddress();

        if (token_ == ETH_ADDRESS) {
            SafeTransferLib.safeTransferETH(rescueTo_, amount_);
        } else {
            if (token_.code.length == 0) revert InvalidTokenAddress();
            SafeTransferLib.safeTransfer(ERC20(token_), rescueTo_, amount_);
        }
    }
}
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "solmate/src/utils/ReentrancyGuard.sol";

import {RescueFundsLib} from "../libraries/RescueFundsLib.sol";
import {Gauge} from "../common/Gauge.sol";
import {AccessControl} from "../common/AccessControl.sol";

import "./ISuperTokenOrVault.sol";
import "./IMessageBridge.sol";
import "./ExecutionHelper.sol";

/**
 * @title Base contract for super token and vault
 * @notice It contains relevant execution payload storages.
 * @dev This contract implements Socket's IPlug to enable message bridging and IMessageBridge
 * to support any type of message bridge.
 */
abstract contract Base is
    ReentrancyGuard,
    Gauge,
    ISuperTokenOrVault,
    AccessControl
{
    /**
     * @notice this struct stores relevant details for a pending payload execution
     * @param receiver address of receiver where payload executes.
     * @param payload payload to be executed
     * @param isAmountPending if amount to be bridged is pending
     */
    struct PendingExecutionDetails {
        bool isAmountPending;
        uint32 siblingChainSlug;
        address receiver;
        bytes payload;
    }

    ExecutionHelper public executionHelper__;

    // messageId => PendingExecutionDetails
    mapping(bytes32 => PendingExecutionDetails) public pendingExecutions;

    ////////////////////////////////////////////////////////
    ////////////////////// ERRORS //////////////////////////
    ////////////////////////////////////////////////////////

    error InvalidExecutionRetry();
    error PendingAmount();
    error CannotExecuteOnBridgeContracts();

    // emitted when a execution helper is updated
    event ExecutionHelperUpdated(address executionHelper);

    /**
     * @notice this function is used to update execution helper contract
     * @dev it can only be updated by owner
     * @param executionHelper_ new execution helper address
     */
    function updateExecutionHelper(
        address executionHelper_
    ) external onlyOwner {
        executionHelper__ = ExecutionHelper(executionHelper_);
        emit ExecutionHelperUpdated(executionHelper_);
    }

    /**
     * @notice this function can be used to retry a payload execution if it was not successful.
     * @param msgId_ The unique identifier of the bridging message.
     */
    function retryPayloadExecution(bytes32 msgId_) external nonReentrant {
        PendingExecutionDetails storage details = pendingExecutions[msgId_];
        if (details.isAmountPending) revert PendingAmount();

        if (details.receiver == address(0)) revert InvalidExecutionRetry();
        bool success = executionHelper__.execute(
            details.receiver,
            details.payload
        );

        if (success) _clearPayload(msgId_);
    }

    /**
     * @notice this function caches the execution payload details if the amount to be bridged
     * is not pending or execution is reverting
     */
    function _cachePayload(
        bytes32 msgId_,
        bool isAmountPending_,
        uint32 siblingChainSlug_,
        address receiver_,
        bytes memory payload_
    ) internal {
        pendingExecutions[msgId_].receiver = receiver_;
        pendingExecutions[msgId_].payload = payload_;
        pendingExecutions[msgId_].siblingChainSlug = siblingChainSlug_;
        pendingExecutions[msgId_].isAmountPending = isAmountPending_;
    }

    /**
     * @notice this function clears the payload details once execution succeeds
     */
    function _clearPayload(bytes32 msgId_) internal {
        pendingExecutions[msgId_].receiver = address(0);
        pendingExecutions[msgId_].payload = bytes("");
        pendingExecutions[msgId_].siblingChainSlug = 0;
        pendingExecutions[msgId_].isAmountPending = false;
    }
}
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "../libraries/ExcessivelySafeCall.sol";

/**
 * @title ExecutionHelper
 * @notice It is an untrusted contract used for payload execution by Super token and Vault.
 */
contract ExecutionHelper {
    using ExcessivelySafeCall for address;
    uint16 private constant MAX_COPY_BYTES = 0;

    /**
     * @notice this function is used to execute a payload at target_
     * @dev receiver address cannot be this contract address.
     * @param target_ address of target.
     * @param payload_ payload to be executed at target.
     */
    function execute(
        address target_,
        bytes memory payload_
    ) external returns (bool success) {
        if (target_ == address(this)) return false;
        (success, ) = target_.excessivelySafeCall(
            gasleft(),
            MAX_COPY_BYTES,
            payload_
        );
    }
}
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/**
 * @title IMessageBridge
 * @notice It should be implemented by message bridge integrated to Super token and Vault.
 */
interface IMessageBridge {
    /**
     * @notice calls socket's outbound function which transmits msg to `siblingChainSlug_`.
     * @dev Only super token or vault can call this contract
     * @param siblingChainSlug_ The unique identifier of the sibling chain.
     * @param msgGasLimit_ min gas limit needed to execute the message on sibling
     * @param payload_ payload which should be executed at the sibling chain.
     * @param options_ extra bytes memory can be used by other protocol plugs for additional options
     */
    function outbound(
        uint32 siblingChainSlug_,
        uint256 msgGasLimit_,
        bytes memory payload_,
        bytes memory options_
    ) external payable returns (bytes32 messageId_);

    /**
     * @notice this function is used to calculate message id before sending outbound().
     * @param siblingChainSlug_ The unique identifier of the sibling chain.
     * @return message id
     */
    function getMessageId(
        uint32 siblingChainSlug_
    ) external view returns (bytes32);
}
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/**
 * @title ISuperTokenOrVault
 * @notice It should be implemented Super token and Vault for plugs to communicate.
 */
interface ISuperTokenOrVault {
    /**
     * @dev this should be only executable by socket.
     * @notice executes the message received from source chain.
     * @notice It is expected to have original sender checks in the destination plugs using payload.
     * @param siblingChainSlug_ chain slug of source.
     * @param payload_ the data which is needed to decode receiver, amount, msgId and payload.
     */
    function inbound(
        uint32 siblingChainSlug_,
        bytes memory payload_
    ) external payable;
}
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

// OSEAN DAO VAULT for BSC ETH Bridge - https://osean.online
// Official telegram: https://t.me/oseadao 

import "solmate/src/utils/SafeTransferLib.sol";
import "./Base.sol";

/**
 * @title OseanVault
 * @notice Vault contract which is used to lock/unlock token and enable bridging to its sibling chains.
 * @dev This contract implements ISuperTokenOrVault to support message bridging through IMessageBridge compliant contracts.
 */
contract OseanVault is Base {
    using SafeTransferLib for ERC20;

    struct UpdateLimitParams {
        bool isLock;
        uint32 siblingChainSlug;
        uint256 maxLimit;
        uint256 ratePerSecond;
    }

    bytes32 constant RESCUE_ROLE = keccak256("RESCUE_ROLE");
    bytes32 constant LIMIT_UPDATER_ROLE = keccak256("LIMIT_UPDATER_ROLE");

    ERC20 public immutable token__;
    IMessageBridge public bridge__;

    // siblingChainSlug => receiver => identifier => pendingUnlock
    mapping(uint32 => mapping(address => mapping(bytes32 => uint256)))
        public pendingUnlocks;

    // siblingChainSlug => amount
    mapping(uint32 => uint256) public siblingPendingUnlocks;

    // siblingChainSlug => lockLimitParams
    mapping(uint32 => LimitParams) _lockLimitParams;

    // siblingChainSlug => unlockLimitParams
    mapping(uint32 => LimitParams) _unlockLimitParams;

    ////////////////////////////////////////////////////////
    ////////////////////// ERRORS //////////////////////////
    ////////////////////////////////////////////////////////

    error SiblingChainSlugUnavailable();
    error ZeroAmount();
    error NotMessageBridge();
    error InvalidReceiver();
    error InvalidSiblingChainSlug();
    error MessageIdMisMatched();
    error InvalidTokenContract();

    ////////////////////////////////////////////////////////
    ////////////////////// EVENTS //////////////////////////
    ////////////////////////////////////////////////////////

    // emitted when a message bridge is updated
    event MessageBridgeUpdated(address bridge);
    // emitted when limit params are updated
    event LimitParamsUpdated(UpdateLimitParams[] updates);
    // emitted at source when tokens are deposited to be bridged to a sibling chain
    event TokensDeposited(
        uint32 siblingChainSlug,
        address depositor,
        address receiver,
        uint256 depositAmount
    );
    // emitted when pending tokens are transferred to the receiver
    event PendingTokensTransferred(
        uint32 siblingChainSlug,
        address receiver,
        uint256 unlockedAmount,
        uint256 pendingAmount
    );
    // emitted when transfer reaches limit and token transfer is added to pending queue
    event TokensPending(
        uint32 siblingChainSlug,
        address receiver,
        uint256 pendingAmount,
        uint256 totalPendingAmount
    );
    // emitted when pending tokens are unlocked as limits are replenished
    event TokensUnlocked(
        uint32 siblingChainSlug,
        address receiver,
        uint256 unlockedAmount
    );

    /**
     * @notice constructor for creating a new SuperTokenVault.
     * @param token_ token contract address which is to be bridged.
     * @param owner_ owner of this contract
     * @param bridge_ message bridge address
     */
    constructor(
        address token_,
        address owner_,
        address bridge_,
        address executionHelper_
    ) AccessControl(owner_) {
        if (token_.code.length == 0) revert InvalidTokenContract();
        token__ = ERC20(token_);
        bridge__ = IMessageBridge(bridge_);
        executionHelper__ = ExecutionHelper(executionHelper_);
    }

    /**
     * @notice this function is used to update message bridge
     * @dev it can only be updated by owner
     * @dev should be carefully migrated as it can risk user funds
     * @param bridge_ new bridge address
     */
    function updateMessageBridge(address bridge_) external onlyOwner {
        bridge__ = IMessageBridge(bridge_);
        emit MessageBridgeUpdated(bridge_);
    }

    /**
     * @notice this function is used to set bridge limits
     * @dev it can only be updated by owner
     * @param updates_ can be used to set mint and burn limits for all siblings in one call.
     */
    function updateLimitParams(
        UpdateLimitParams[] calldata updates_
    ) external onlyRole(LIMIT_UPDATER_ROLE) {
        for (uint256 i; i < updates_.length; i++) {
            if (updates_[i].isLock) {
                _consumePartLimit(
                    0,
                    _lockLimitParams[updates_[i].siblingChainSlug]
                ); // to keep current limit in sync
                _lockLimitParams[updates_[i].siblingChainSlug]
                    .maxLimit = updates_[i].maxLimit;
                _lockLimitParams[updates_[i].siblingChainSlug]
                    .ratePerSecond = updates_[i].ratePerSecond;
            } else {
                _consumePartLimit(
                    0,
                    _unlockLimitParams[updates_[i].siblingChainSlug]
                ); // to keep current limit in sync
                _unlockLimitParams[updates_[i].siblingChainSlug]
                    .maxLimit = updates_[i].maxLimit;
                _unlockLimitParams[updates_[i].siblingChainSlug]
                    .ratePerSecond = updates_[i].ratePerSecond;
            }
        }

        emit LimitParamsUpdated(updates_);
    }

    /**
     * @notice this function is called by users to bridge their funds to a sibling chain
     * @dev it is payable to receive message bridge fees to be paid.
     * @param receiver_ address receiving bridged tokens
     * @param siblingChainSlug_ The unique identifier of the sibling chain.
     * @param amount_ amount bridged
     * @param msgGasLimit_ min gas limit needed for execution at destination
     * @param payload_ payload which is executed at destination with bridged amount at receiver address.
     * @param options_ additional message bridge options can be provided using this param
     */
    function bridge(
        address receiver_,
        uint32 siblingChainSlug_,
        uint256 amount_,
        uint256 msgGasLimit_,
        bytes calldata payload_,
        bytes calldata options_
    ) external payable {
        if (amount_ == 0) revert ZeroAmount();

        if (_lockLimitParams[siblingChainSlug_].maxLimit == 0)
            revert SiblingChainSlugUnavailable();

        _consumeFullLimit(amount_, _lockLimitParams[siblingChainSlug_]); // reverts on limit hit

        token__.safeTransferFrom(msg.sender, address(this), amount_);

        bytes32 messageId = bridge__.getMessageId(siblingChainSlug_);
        bytes32 returnedMessageId = bridge__.outbound{value: msg.value}(
            siblingChainSlug_,
            msgGasLimit_,
            abi.encode(receiver_, amount_, messageId, payload_),
            options_
        );
        if (returnedMessageId != messageId) revert MessageIdMisMatched();
        emit TokensDeposited(siblingChainSlug_, msg.sender, receiver_, amount_);
    }

    /**
     * @notice this function can be used to unlock funds which were in pending state due to limits
     * @param receiver_ address receiving bridged tokens
     * @param siblingChainSlug_ The unique identifier of the sibling chain.
     * @param identifier_ message identifier where message was received to unlock funds
     */
    function unlockPendingFor(
        address receiver_,
        uint32 siblingChainSlug_,
        bytes32 identifier_
    ) external nonReentrant {
        if (_unlockLimitParams[siblingChainSlug_].maxLimit == 0)
            revert SiblingChainSlugUnavailable();

        uint256 pendingUnlock = pendingUnlocks[siblingChainSlug_][receiver_][
            identifier_
        ];
        (uint256 consumedAmount, uint256 pendingAmount) = _consumePartLimit(
            pendingUnlock,
            _unlockLimitParams[siblingChainSlug_]
        );

        pendingUnlocks[siblingChainSlug_][receiver_][
            identifier_
        ] = pendingAmount;
        siblingPendingUnlocks[siblingChainSlug_] -= consumedAmount;

        token__.safeTransfer(receiver_, consumedAmount);

        address receiver = pendingExecutions[identifier_].receiver;
        if (pendingAmount == 0 && receiver != address(0)) {
            if (receiver_ != receiver) revert InvalidReceiver();

            uint32 siblingChainSlug = pendingExecutions[identifier_]
                .siblingChainSlug;
            if (siblingChainSlug != siblingChainSlug_)
                revert InvalidSiblingChainSlug();

            // execute
            pendingExecutions[identifier_].isAmountPending = false;
            bool success = executionHelper__.execute(
                receiver_,
                pendingExecutions[identifier_].payload
            );
            if (success) _clearPayload(identifier_);
        }

        emit PendingTokensTransferred(
            siblingChainSlug_,
            receiver_,
            consumedAmount,
            pendingAmount
        );
    }

    /**
     * @notice this function receives the message from message bridge
     * @dev Only bridge can call this function.
     * @param siblingChainSlug_ The unique identifier of the sibling chain.
     * @param payload_ payload which is decoded to get `receiver`, `amount to mint`, `message id` and `payload` to execute after token transfer.
     */
    function inbound(
        uint32 siblingChainSlug_,
        bytes memory payload_
    ) external payable override nonReentrant {
        if (msg.sender != address(bridge__)) revert NotMessageBridge();

        if (_unlockLimitParams[siblingChainSlug_].maxLimit == 0)
            revert SiblingChainSlugUnavailable();

        (
            address receiver,
            uint256 unlockAmount,
            bytes32 identifier,
            bytes memory execPayload
        ) = abi.decode(payload_, (address, uint256, bytes32, bytes));

        if (
            receiver == address(this) ||
            receiver == address(bridge__) ||
            receiver == address(token__)
        ) revert CannotExecuteOnBridgeContracts();

        (uint256 consumedAmount, uint256 pendingAmount) = _consumePartLimit(
            unlockAmount,
            _unlockLimitParams[siblingChainSlug_]
        );

        token__.safeTransfer(receiver, consumedAmount);

        if (pendingAmount > 0) {
            // add instead of overwrite to handle case where already pending amount is left
            pendingUnlocks[siblingChainSlug_][receiver][
                identifier
            ] += pendingAmount;
            siblingPendingUnlocks[siblingChainSlug_] += pendingAmount;

            // cache payload
            if (execPayload.length > 0)
                _cachePayload(
                    identifier,
                    true,
                    siblingChainSlug_,
                    receiver,
                    execPayload
                );

            emit TokensPending(
                siblingChainSlug_,
                receiver,
                pendingAmount,
                pendingUnlocks[siblingChainSlug_][receiver][identifier]
            );
        } else if (execPayload.length > 0) {
            // execute
            bool success = executionHelper__.execute(receiver, execPayload);

            if (!success)
                _cachePayload(
                    identifier,
                    false,
                    siblingChainSlug_,
                    receiver,
                    execPayload
                );
        }

        emit TokensUnlocked(siblingChainSlug_, receiver, consumedAmount);
    }

    function getCurrentLockLimit(
        uint32 siblingChainSlug_
    ) external view returns (uint256) {
        return _getCurrentLimit(_lockLimitParams[siblingChainSlug_]);
    }

    function getCurrentUnlockLimit(
        uint32 siblingChainSlug_
    ) external view returns (uint256) {
        return _getCurrentLimit(_unlockLimitParams[siblingChainSlug_]);
    }

    function getLockLimitParams(
        uint32 siblingChainSlug_
    ) external view returns (LimitParams memory) {
        return _lockLimitParams[siblingChainSlug_];
    }

    function getUnlockLimitParams(
        uint32 siblingChainSlug_
    ) external view returns (LimitParams memory) {
        return _unlockLimitParams[siblingChainSlug_];
    }

    /**
     * @notice Rescues funds from the contract if they are locked by mistake.
     * @param token_ The address of the token contract.
     * @param rescueTo_ The address where rescued tokens need to be sent.
     * @param amount_ The amount of tokens to be rescued.
     */
    function rescueFunds(
        address token_,
        address rescueTo_,
        uint256 amount_
    ) external onlyRole(RESCUE_ROLE) {
        RescueFundsLib.rescueFunds(token_, rescueTo_, amount_);
    }
}
// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity >=0.8.0;

/// @notice Modern and gas efficient ERC20 + EIP-2612 implementation.
/// @author Solmate (https://github.com/transmissions11/solmate/blob/main/src/tokens/ERC20.sol)
/// @author Modified from Uniswap (https://github.com/Uniswap/uniswap-v2-core/blob/master/contracts/UniswapV2ERC20.sol)
/// @dev Do not manually set balances without updating totalSupply, as the sum of all user balances must not exceed it.
abstract contract ERC20 {
    /*//////////////////////////////////////////////////////////////
                                 EVENTS
    //////////////////////////////////////////////////////////////*/

    event Transfer(address indexed from, address indexed to, uint256 amount);

    event Approval(address indexed owner, address indexed spender, uint256 amount);

    /*//////////////////////////////////////////////////////////////
                            METADATA STORAGE
    //////////////////////////////////////////////////////////////*/

    string public name;

    string public symbol;

    uint8 public immutable decimals;

    /*//////////////////////////////////////////////////////////////
                              ERC20 STORAGE
    //////////////////////////////////////////////////////////////*/

    uint256 public totalSupply;

    mapping(address => uint256) public balanceOf;

    mapping(address => mapping(address => uint256)) public allowance;

    /*//////////////////////////////////////////////////////////////
                            EIP-2612 STORAGE
    //////////////////////////////////////////////////////////////*/

    uint256 internal immutable INITIAL_CHAIN_ID;

    bytes32 internal immutable INITIAL_DOMAIN_SEPARATOR;

    mapping(address => uint256) public nonces;

    /*//////////////////////////////////////////////////////////////
                               CONSTRUCTOR
    //////////////////////////////////////////////////////////////*/

    constructor(
        string memory _name,
        string memory _symbol,
        uint8 _decimals
    ) {
        name = _name;
        symbol = _symbol;
        decimals = _decimals;

        INITIAL_CHAIN_ID = block.chainid;
        INITIAL_DOMAIN_SEPARATOR = computeDomainSeparator();
    }

    /*//////////////////////////////////////////////////////////////
                               ERC20 LOGIC
    //////////////////////////////////////////////////////////////*/

    function approve(address spender, uint256 amount) public virtual returns (bool) {
        allowance[msg.sender][spender] = amount;

        emit Approval(msg.sender, spender, amount);

        return true;
    }

    function transfer(address to, uint256 amount) public virtual returns (bool) {
        balanceOf[msg.sender] -= amount;

        // Cannot overflow because the sum of all user
        // balances can't exceed the max uint256 value.
        unchecked {
            balanceOf[to] += amount;
        }

        emit Transfer(msg.sender, to, amount);

        return true;
    }

    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) public virtual returns (bool) {
        uint256 allowed = allowance[from][msg.sender]; // Saves gas for limited approvals.

        if (allowed != type(uint256).max) allowance[from][msg.sender] = allowed - amount;

        balanceOf[from] -= amount;

        // Cannot overflow because the sum of all user
        // balances can't exceed the max uint256 value.
        unchecked {
            balanceOf[to] += amount;
        }

        emit Transfer(from, to, amount);

        return true;
    }

    /*//////////////////////////////////////////////////////////////
                             EIP-2612 LOGIC
    //////////////////////////////////////////////////////////////*/

    function permit(
        address owner,
        address spender,
        uint256 value,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) public virtual {
        require(deadline >= block.timestamp, "PERMIT_DEADLINE_EXPIRED");

        // Unchecked because the only math done is incrementing
        // the owner's nonce which cannot realistically overflow.
        unchecked {
            address recoveredAddress = ecrecover(
                keccak256(
                    abi.encodePacked(
                        "\x19\x01",
                        DOMAIN_SEPARATOR(),
                        keccak256(
                            abi.encode(
                                keccak256(
                                    "Permit(address owner,address spender,uint256 value,uint256 nonce,uint256 deadline)"
                                ),
                                owner,
                                spender,
                                value,
                                nonces[owner]++,
                                deadline
                            )
                        )
                    )
                ),
                v,
                r,
                s
            );

            require(recoveredAddress != address(0) && recoveredAddress == owner, "INVALID_SIGNER");

            allowance[recoveredAddress][spender] = value;
        }

        emit Approval(owner, spender, value);
    }

    function DOMAIN_SEPARATOR() public view virtual returns (bytes32) {
        return block.chainid == INITIAL_CHAIN_ID ? INITIAL_DOMAIN_SEPARATOR : computeDomainSeparator();
    }

    function computeDomainSeparator() internal view virtual returns (bytes32) {
        return
            keccak256(
                abi.encode(
                    keccak256("EIP712Domain(string name,string version,uint256 chainId,address verifyingContract)"),
                    keccak256(bytes(name)),
                    keccak256("1"),
                    block.chainid,
                    address(this)
                )
            );
    }

    /*//////////////////////////////////////////////////////////////
                        INTERNAL MINT/BURN LOGIC
    //////////////////////////////////////////////////////////////*/

    function _mint(address to, uint256 amount) internal virtual {
        totalSupply += amount;

        // Cannot overflow because the sum of all user
        // balances can't exceed the max uint256 value.
        unchecked {
            balanceOf[to] += amount;
        }

        emit Transfer(address(0), to, amount);
    }

    function _burn(address from, uint256 amount) internal virtual {
        balanceOf[from] -= amount;

        // Cannot underflow because a user's balance
        // will never be larger than the total supply.
        unchecked {
            totalSupply -= amount;
        }

        emit Transfer(from, address(0), amount);
    }
}
// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity >=0.8.0;

/// @notice Gas optimized reentrancy protection for smart contracts.
/// @author Solmate (https://github.com/transmissions11/solmate/blob/main/src/utils/ReentrancyGuard.sol)
/// @author Modified from OpenZeppelin (https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/security/ReentrancyGuard.sol)
abstract contract ReentrancyGuard {
    uint256 private locked = 1;

    modifier nonReentrant() virtual {
        require(locked == 1, "REENTRANCY");

        locked = 2;

        _;

        locked = 1;
    }
}
// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity >=0.8.0;

import {ERC20} from "../tokens/ERC20.sol";

/// @notice Safe ETH and ERC20 transfer library that gracefully handles missing return values.
/// @author Solmate (https://github.com/transmissions11/solmate/blob/main/src/utils/SafeTransferLib.sol)
/// @dev Use with caution! Some functions in this library knowingly create dirty bits at the destination of the free memory pointer.
/// @dev Note that none of the functions in this library check that a token has code at all! That responsibility is delegated to the caller.
library SafeTransferLib {
    /*//////////////////////////////////////////////////////////////
                             ETH OPERATIONS
    //////////////////////////////////////////////////////////////*/

    function safeTransferETH(address to, uint256 amount) internal {
        bool success;

        /// @solidity memory-safe-assembly
        assembly {
            // Transfer the ETH and store if it succeeded or not.
            success := call(gas(), to, amount, 0, 0, 0, 0)
        }

        require(success, "ETH_TRANSFER_FAILED");
    }

    /*//////////////////////////////////////////////////////////////
                            ERC20 OPERATIONS
    //////////////////////////////////////////////////////////////*/

    function safeTransferFrom(
        ERC20 token,
        address from,
        address to,
        uint256 amount
    ) internal {
        bool success;

        /// @solidity memory-safe-assembly
        assembly {
            // Get a pointer to some free memory.
            let freeMemoryPointer := mload(0x40)

            // Write the abi-encoded calldata into memory, beginning with the function selector.
            mstore(freeMemoryPointer, 0x23b872dd00000000000000000000000000000000000000000000000000000000)
            mstore(add(freeMemoryPointer, 4), and(from, 0xffffffffffffffffffffffffffffffffffffffff)) // Append and mask the "from" argument.
            mstore(add(freeMemoryPointer, 36), and(to, 0xffffffffffffffffffffffffffffffffffffffff)) // Append and mask the "to" argument.
            mstore(add(freeMemoryPointer, 68), amount) // Append the "amount" argument. Masking not required as it's a full 32 byte type.

            success := and(
                // Set success to whether the call reverted, if not we check it either
                // returned exactly 1 (can't just be non-zero data), or had no return data.
                or(and(eq(mload(0), 1), gt(returndatasize(), 31)), iszero(returndatasize())),
                // We use 100 because the length of our calldata totals up like so: 4 + 32 * 3.
                // We use 0 and 32 to copy up to 32 bytes of return data into the scratch space.
                // Counterintuitively, this call must be positioned second to the or() call in the
                // surrounding and() call or else returndatasize() will be zero during the computation.
                call(gas(), token, 0, freeMemoryPointer, 100, 0, 32)
            )
        }

        require(success, "TRANSFER_FROM_FAILED");
    }

    function safeTransfer(
        ERC20 token,
        address to,
        uint256 amount
    ) internal {
        bool success;

        /// @solidity memory-safe-assembly
        assembly {
            // Get a pointer to some free memory.
            let freeMemoryPointer := mload(0x40)

            // Write the abi-encoded calldata into memory, beginning with the function selector.
            mstore(freeMemoryPointer, 0xa9059cbb00000000000000000000000000000000000000000000000000000000)
            mstore(add(freeMemoryPointer, 4), and(to, 0xffffffffffffffffffffffffffffffffffffffff)) // Append and mask the "to" argument.
            mstore(add(freeMemoryPointer, 36), amount) // Append the "amount" argument. Masking not required as it's a full 32 byte type.

            success := and(
                // Set success to whether the call reverted, if not we check it either
                // returned exactly 1 (can't just be non-zero data), or had no return data.
                or(and(eq(mload(0), 1), gt(returndatasize(), 31)), iszero(returndatasize())),
                // We use 68 because the length of our calldata totals up like so: 4 + 32 * 2.
                // We use 0 and 32 to copy up to 32 bytes of return data into the scratch space.
                // Counterintuitively, this call must be positioned second to the or() call in the
                // surrounding and() call or else returndatasize() will be zero during the computation.
                call(gas(), token, 0, freeMemoryPointer, 68, 0, 32)
            )
        }

        require(success, "TRANSFER_FAILED");
    }

    function safeApprove(
        ERC20 token,
        address to,
        uint256 amount
    ) internal {
        bool success;

        /// @solidity memory-safe-assembly
        assembly {
            // Get a pointer to some free memory.
            let freeMemoryPointer := mload(0x40)

            // Write the abi-encoded calldata into memory, beginning with the function selector.
            mstore(freeMemoryPointer, 0x095ea7b300000000000000000000000000000000000000000000000000000000)
            mstore(add(freeMemoryPointer, 4), and(to, 0xffffffffffffffffffffffffffffffffffffffff)) // Append and mask the "to" argument.
            mstore(add(freeMemoryPointer, 36), amount) // Append the "amount" argument. Masking not required as it's a full 32 byte type.

            success := and(
                // Set success to whether the call reverted, if not we check it either
                // returned exactly 1 (can't just be non-zero data), or had no return data.
                or(and(eq(mload(0), 1), gt(returndatasize(), 31)), iszero(returndatasize())),
                // We use 68 because the length of our calldata totals up like so: 4 + 32 * 2.
                // We use 0 and 32 to copy up to 32 bytes of return data into the scratch space.
                // Counterintuitively, this call must be positioned second to the or() call in the
                // surrounding and() call or else returndatasize() will be zero during the computation.
                call(gas(), token, 0, freeMemoryPointer, 68, 0, 32)
            )
        }

        require(success, "APPROVE_FAILED");
    }
}
