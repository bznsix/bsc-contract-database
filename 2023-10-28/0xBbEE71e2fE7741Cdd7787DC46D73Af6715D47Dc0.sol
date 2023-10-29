// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import { IAxelarGateway } from '../interfaces/IAxelarGateway.sol';
import { IAxelarExecutable } from '../interfaces/IAxelarExecutable.sol';

contract AxelarExecutable is IAxelarExecutable {
    IAxelarGateway public immutable gateway;

    constructor(address gateway_) {
        if (gateway_ == address(0)) revert InvalidAddress();

        gateway = IAxelarGateway(gateway_);
    }

    function execute(
        bytes32 commandId,
        string calldata sourceChain,
        string calldata sourceAddress,
        bytes calldata payload
    ) external {
        bytes32 payloadHash = keccak256(payload);

        if (!gateway.validateContractCall(commandId, sourceChain, sourceAddress, payloadHash))
            revert NotApprovedByGateway();

        _execute(sourceChain, sourceAddress, payload);
    }

    function executeWithToken(
        bytes32 commandId,
        string calldata sourceChain,
        string calldata sourceAddress,
        bytes calldata payload,
        string calldata tokenSymbol,
        uint256 amount
    ) external {
        bytes32 payloadHash = keccak256(payload);

        if (
            !gateway.validateContractCallAndMint(
                commandId,
                sourceChain,
                sourceAddress,
                payloadHash,
                tokenSymbol,
                amount
            )
        ) revert NotApprovedByGateway();

        _executeWithToken(sourceChain, sourceAddress, payload, tokenSymbol, amount);
    }

    function _execute(
        string calldata sourceChain,
        string calldata sourceAddress,
        bytes calldata payload
    ) internal virtual {}

    function _executeWithToken(
        string calldata sourceChain,
        string calldata sourceAddress,
        bytes calldata payload,
        string calldata tokenSymbol,
        uint256 amount
    ) internal virtual {}
}
// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import { AxelarExecutable } from '../executable/AxelarExecutable.sol';
import { TimeLock } from '../utils/TimeLock.sol';
import { SafeNativeTransfer } from '../libs/SafeNativeTransfer.sol';
import { IInterchainGovernance } from '../interfaces/IInterchainGovernance.sol';
import { Caller } from '../utils/Caller.sol';

/**
 * @title Interchain Governance contract
 * @notice This contract handles cross-chain governance actions. It includes functionality
 * to create, cancel, and execute governance proposals.
 */
contract InterchainGovernance is AxelarExecutable, TimeLock, Caller, IInterchainGovernance {
    using SafeNativeTransfer for address;

    enum GovernanceCommand {
        ScheduleTimeLockProposal,
        CancelTimeLockProposal
    }

    string public governanceChain;
    string public governanceAddress;
    bytes32 public immutable governanceChainHash;
    bytes32 public immutable governanceAddressHash;

    /**
     * @notice Initializes the contract
     * @param gateway_ The address of the Axelar gateway contract
     * @param governanceChain_ The name of the governance chain
     * @param governanceAddress_ The address of the governance contract
     * @param minimumTimeDelay The minimum time delay for timelock operations
     */
    constructor(
        address gateway_,
        string memory governanceChain_,
        string memory governanceAddress_,
        uint256 minimumTimeDelay
    ) AxelarExecutable(gateway_) TimeLock(minimumTimeDelay) {
        if (bytes(governanceChain_).length == 0 || bytes(governanceAddress_).length == 0) {
            revert InvalidAddress();
        }

        governanceChain = governanceChain_;
        governanceAddress = governanceAddress_;
        governanceChainHash = keccak256(bytes(governanceChain_));
        governanceAddressHash = keccak256(bytes(governanceAddress_));
    }

    /**
     * @notice Modifier to check if the caller is the governance contract
     * @param sourceChain The source chain of the proposal, must equal the governance chain
     * @param sourceAddress The source address of the proposal, must equal the governance address
     */
    modifier onlyGovernance(string calldata sourceChain, string calldata sourceAddress) {
        if (
            keccak256(bytes(sourceChain)) != governanceChainHash ||
            keccak256(bytes(sourceAddress)) != governanceAddressHash
        ) revert NotGovernance();

        _;
    }

    /**
     * @notice Modifier to check if the caller is the contract itself
     */
    modifier onlySelf() {
        if (msg.sender != address(this)) revert NotSelf();

        _;
    }

    /**
     * @notice Returns the ETA of a proposal
     * @param target The address of the contract targeted by the proposal
     * @param callData The call data to be sent to the target contract
     * @param nativeValue The amount of native tokens to be sent to the target contract
     * @return uint256 The ETA of the proposal
     */
    function getProposalEta(
        address target,
        bytes calldata callData,
        uint256 nativeValue
    ) external view returns (uint256) {
        return _getTimeLockEta(_getProposalHash(target, callData, nativeValue));
    }

    /**
     * @notice Executes a proposal
     * @dev The proposal is executed by calling the target contract with calldata. Native value is
     * transferred with the call to the target contract.
     * @param target The target address of the contract to call
     * @param callData The data containing the function and arguments for the contract to call
     * @param nativeValue The amount of native token to send to the target contract
     */
    function executeProposal(
        address target,
        bytes calldata callData,
        uint256 nativeValue
    ) external payable {
        bytes32 proposalHash = _getProposalHash(target, callData, nativeValue);

        _finalizeTimeLock(proposalHash);

        emit ProposalExecuted(proposalHash, target, callData, nativeValue, block.timestamp);

        _call(target, callData, nativeValue);
    }

    /**
     * @notice Withdraws native token from the contract
     * @param recipient The address to send the native token to
     * @param amount The amount of native token to send
     * @dev This function is only callable by the contract itself after passing according proposal
     */
    function withdraw(address recipient, uint256 amount) external onlySelf {
        recipient.safeNativeTransfer(amount);
    }

    /**
     * @notice Internal function to execute a proposal action
     * @param sourceChain The source chain of the proposal, must equal the governance chain
     * @param sourceAddress The source address of the proposal, must equal the governance address
     * @param payload The payload of the proposal
     */
    function _execute(
        string calldata sourceChain,
        string calldata sourceAddress,
        bytes calldata payload
    ) internal override onlyGovernance(sourceChain, sourceAddress) {
        (uint256 command, address target, bytes memory callData, uint256 nativeValue, uint256 eta) = abi.decode(
            payload,
            (uint256, address, bytes, uint256, uint256)
        );

        if (target == address(0)) revert InvalidTarget();

        _processCommand(command, target, callData, nativeValue, eta);
    }

    /**
     * @notice Internal function to process a governance command
     * @param commandType The type of the command, 0 for proposal creation and 1 for proposal cancellation
     * @param target The target address the proposal will call
     * @param callData The data the encodes the function and arguments to call on the target contract
     * @param nativeValue The nativeValue of native token to be sent to the target contract
     * @param eta The time after which the proposal can be executed
     */
    function _processCommand(
        uint256 commandType,
        address target,
        bytes memory callData,
        uint256 nativeValue,
        uint256 eta
    ) internal virtual {
        bytes32 proposalHash = _getProposalHash(target, callData, nativeValue);

        if (commandType == uint256(GovernanceCommand.ScheduleTimeLockProposal)) {
            eta = _scheduleTimeLock(proposalHash, eta);

            emit ProposalScheduled(proposalHash, target, callData, nativeValue, eta);
            return;
        } else if (commandType == uint256(GovernanceCommand.CancelTimeLockProposal)) {
            _cancelTimeLock(proposalHash);

            emit ProposalCancelled(proposalHash, target, callData, nativeValue, eta);
            return;
        } else {
            revert InvalidCommand();
        }
    }

    /**
     * @dev Get proposal hash using the target, callData, and nativeValue
     */
    function _getProposalHash(
        address target,
        bytes memory callData,
        uint256 nativeValue
    ) internal pure returns (bytes32) {
        return keccak256(abi.encode(target, callData, nativeValue));
    }

    /**
     * @notice Overrides internal function of AxelarExecutable, will always revert
     * as this governance module does not support execute with token.
     */
    function _executeWithToken(
        string calldata, /* sourceChain */
        string calldata, /* sourceAddress */
        bytes calldata, /* payload */
        string calldata, /* tokenSymbol */
        uint256 /* amount */
    ) internal pure override {
        revert TokenNotSupported();
    }

    /**
     * @notice Allow contract to receive native gas token
     */
    receive() external payable {}
}
// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import { IAxelarGateway } from './IAxelarGateway.sol';

interface IAxelarExecutable {
    error InvalidAddress();
    error NotApprovedByGateway();

    function gateway() external view returns (IAxelarGateway);

    function execute(
        bytes32 commandId,
        string calldata sourceChain,
        string calldata sourceAddress,
        bytes calldata payload
    ) external;

    function executeWithToken(
        bytes32 commandId,
        string calldata sourceChain,
        string calldata sourceAddress,
        bytes calldata payload,
        string calldata tokenSymbol,
        uint256 amount
    ) external;
}
// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import { IGovernable } from './IGovernable.sol';
import { IImplementation } from './IImplementation.sol';

interface IAxelarGateway is IImplementation, IGovernable {
    /**********\
    |* Errors *|
    \**********/

    error NotSelf();
    error InvalidCodeHash();
    error SetupFailed();
    error InvalidAuthModule();
    error InvalidTokenDeployer();
    error InvalidAmount();
    error InvalidChainId();
    error InvalidCommands();
    error TokenDoesNotExist(string symbol);
    error TokenAlreadyExists(string symbol);
    error TokenDeployFailed(string symbol);
    error TokenContractDoesNotExist(address token);
    error BurnFailed(string symbol);
    error MintFailed(string symbol);
    error InvalidSetMintLimitsParams();
    error ExceedMintLimit(string symbol);

    /**********\
    |* Events *|
    \**********/

    event TokenSent(
        address indexed sender,
        string destinationChain,
        string destinationAddress,
        string symbol,
        uint256 amount
    );

    event ContractCall(
        address indexed sender,
        string destinationChain,
        string destinationContractAddress,
        bytes32 indexed payloadHash,
        bytes payload
    );

    event ContractCallWithToken(
        address indexed sender,
        string destinationChain,
        string destinationContractAddress,
        bytes32 indexed payloadHash,
        bytes payload,
        string symbol,
        uint256 amount
    );

    event Executed(bytes32 indexed commandId);

    event TokenDeployed(string symbol, address tokenAddresses);

    event ContractCallApproved(
        bytes32 indexed commandId,
        string sourceChain,
        string sourceAddress,
        address indexed contractAddress,
        bytes32 indexed payloadHash,
        bytes32 sourceTxHash,
        uint256 sourceEventIndex
    );

    event ContractCallApprovedWithMint(
        bytes32 indexed commandId,
        string sourceChain,
        string sourceAddress,
        address indexed contractAddress,
        bytes32 indexed payloadHash,
        string symbol,
        uint256 amount,
        bytes32 sourceTxHash,
        uint256 sourceEventIndex
    );

    event ContractCallExecuted(bytes32 indexed commandId);

    event TokenMintLimitUpdated(string symbol, uint256 limit);

    event OperatorshipTransferred(bytes newOperatorsData);

    event Upgraded(address indexed implementation);

    /********************\
    |* Public Functions *|
    \********************/

    function sendToken(
        string calldata destinationChain,
        string calldata destinationAddress,
        string calldata symbol,
        uint256 amount
    ) external;

    function callContract(
        string calldata destinationChain,
        string calldata contractAddress,
        bytes calldata payload
    ) external;

    function callContractWithToken(
        string calldata destinationChain,
        string calldata contractAddress,
        bytes calldata payload,
        string calldata symbol,
        uint256 amount
    ) external;

    function isContractCallApproved(
        bytes32 commandId,
        string calldata sourceChain,
        string calldata sourceAddress,
        address contractAddress,
        bytes32 payloadHash
    ) external view returns (bool);

    function isContractCallAndMintApproved(
        bytes32 commandId,
        string calldata sourceChain,
        string calldata sourceAddress,
        address contractAddress,
        bytes32 payloadHash,
        string calldata symbol,
        uint256 amount
    ) external view returns (bool);

    function validateContractCall(
        bytes32 commandId,
        string calldata sourceChain,
        string calldata sourceAddress,
        bytes32 payloadHash
    ) external returns (bool);

    function validateContractCallAndMint(
        bytes32 commandId,
        string calldata sourceChain,
        string calldata sourceAddress,
        bytes32 payloadHash,
        string calldata symbol,
        uint256 amount
    ) external returns (bool);

    /***********\
    |* Getters *|
    \***********/

    function authModule() external view returns (address);

    function tokenDeployer() external view returns (address);

    function tokenMintLimit(string memory symbol) external view returns (uint256);

    function tokenMintAmount(string memory symbol) external view returns (uint256);

    function allTokensFrozen() external view returns (bool);

    function implementation() external view returns (address);

    function tokenAddresses(string memory symbol) external view returns (address);

    function tokenFrozen(string memory symbol) external view returns (bool);

    function isCommandExecuted(bytes32 commandId) external view returns (bool);

    /************************\
    |* Governance Functions *|
    \************************/

    function setTokenMintLimits(string[] calldata symbols, uint256[] calldata limits) external;

    function upgrade(
        address newImplementation,
        bytes32 newImplementationCodeHash,
        bytes calldata setupParams
    ) external;

    /**********************\
    |* External Functions *|
    \**********************/

    function execute(bytes calldata input) external;
}
// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

interface ICaller {
    error InvalidContract(address target);
    error InsufficientBalance();
    error ExecutionFailed();
}
// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

// General interface for upgradable contracts
interface IContractIdentifier {
    /**
     * @notice Returns the contract ID. It can be used as a check during upgrades.
     * @dev Meant to be overridden in derived contracts.
     * @return bytes32 The contract ID
     */
    function contractId() external pure returns (bytes32);
}
// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

/**
 * @title IGovernable Interface
 * @notice This is an interface used by the AxelarGateway contract to manage governance and mint limiter roles.
 */
interface IGovernable {
    error NotGovernance();
    error NotMintLimiter();
    error InvalidGovernance();
    error InvalidMintLimiter();

    event GovernanceTransferred(address indexed previousGovernance, address indexed newGovernance);
    event MintLimiterTransferred(address indexed previousGovernance, address indexed newGovernance);

    /**
     * @notice Returns the governance address.
     * @return address of the governance
     */
    function governance() external view returns (address);

    /**
     * @notice Returns the mint limiter address.
     * @return address of the mint limiter
     */
    function mintLimiter() external view returns (address);

    /**
     * @notice Transfer the governance role to another address.
     * @param newGovernance The new governance address
     */
    function transferGovernance(address newGovernance) external;

    /**
     * @notice Transfer the mint limiter role to another address.
     * @param newGovernance The new mint limiter address
     */
    function transferMintLimiter(address newGovernance) external;
}
// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import { IContractIdentifier } from './IContractIdentifier.sol';

interface IImplementation is IContractIdentifier {
    error NotProxy();

    function setup(bytes calldata data) external;
}
// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import { IAxelarExecutable } from './IAxelarExecutable.sol';
import { ICaller } from './ICaller.sol';
import { ITimeLock } from './ITimeLock.sol';

/**
 * @title IInterchainGovernance Interface
 * @notice This interface extends IAxelarExecutable for interchain governance mechanisms.
 */
interface IInterchainGovernance is IAxelarExecutable, ICaller, ITimeLock {
    error NotGovernance();
    error NotSelf();
    error InvalidCommand();
    error InvalidTarget();
    error TokenNotSupported();

    event ProposalScheduled(
        bytes32 indexed proposalHash,
        address indexed target,
        bytes callData,
        uint256 value,
        uint256 indexed eta
    );
    event ProposalCancelled(
        bytes32 indexed proposalHash,
        address indexed target,
        bytes callData,
        uint256 value,
        uint256 indexed eta
    );
    event ProposalExecuted(
        bytes32 indexed proposalHash,
        address indexed target,
        bytes callData,
        uint256 value,
        uint256 indexed timestamp
    );

    /**
     * @notice Returns the name of the governance chain.
     * @return string The name of the governance chain
     */
    function governanceChain() external view returns (string memory);

    /**
     * @notice Returns the address of the governance address.
     * @return string The address of the governance address
     */
    function governanceAddress() external view returns (string memory);

    /**
     * @notice Returns the hash of the governance chain.
     * @return bytes32 The hash of the governance chain
     */
    function governanceChainHash() external view returns (bytes32);

    /**
     * @notice Returns the hash of the governance address.
     * @return bytes32 The hash of the governance address
     */
    function governanceAddressHash() external view returns (bytes32);

    /**
     * @notice Returns the ETA of a proposal.
     * @param target The address of the contract targeted by the proposal
     * @param callData The call data to be sent to the target contract
     * @param nativeValue The amount of native tokens to be sent to the target contract
     * @return uint256 The ETA of the proposal
     */
    function getProposalEta(
        address target,
        bytes calldata callData,
        uint256 nativeValue
    ) external view returns (uint256);

    /**
     * @notice Executes a governance proposal.
     * @param targetContract The address of the contract targeted by the proposal
     * @param callData The call data to be sent to the target contract
     * @param value The amount of ETH to be sent to the target contract
     */
    function executeProposal(
        address targetContract,
        bytes calldata callData,
        uint256 value
    ) external payable;

    /**
     * @notice Withdraws native token from the contract
     * @param recipient The address to send the native token to
     * @param amount The amount of native token to send
     * @dev This function is only callable by the contract itself after passing according proposal
     */
    function withdraw(address recipient, uint256 amount) external;
}
// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

/**
 * @title ITimeLock
 * @dev Interface for a TimeLock that enables function execution after a certain time has passed.
 */
interface ITimeLock {
    error InvalidTimeLockHash();
    error TimeLockAlreadyScheduled();
    error TimeLockNotReady();

    /**
     * @notice Returns a minimum time delay at which the TimeLock may be scheduled.
     * @return uint Minimum scheduling delay time (in secs) from the current block timestamp
     */
    function minimumTimeLockDelay() external view returns (uint256);

    /**
     * @notice Returns the timestamp after which the TimeLock may be executed.
     * @param hash The hash of the timelock
     * @return uint The timestamp after which the timelock with the given hash can be executed
     */
    function getTimeLock(bytes32 hash) external view returns (uint256);
}
// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

library ContractAddress {
    function isContract(address contractAddress) internal view returns (bool) {
        bytes32 existingCodeHash = contractAddress.codehash;

        // https://eips.ethereum.org/EIPS/eip-1052
        // keccak256('') == 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470
        return
            existingCodeHash != bytes32(0) &&
            existingCodeHash != 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470;
    }
}
// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

error NativeTransferFailed();

/*
 * @title SafeNativeTransfer
 * @dev This library is used for performing safe native value transfers in Solidity by utilizing inline assembly.
 */
library SafeNativeTransfer {
    /*
     * @notice Perform a native transfer to a given address.
     * @param receiver The recipient address to which the amount will be sent.
     * @param amount The amount of native value to send.
     * @throws NativeTransferFailed error if transfer is not successful.
     */
    function safeNativeTransfer(address receiver, uint256 amount) internal {
        bool success;

        assembly {
            success := call(gas(), receiver, amount, 0, 0, 0, 0)
        }

        if (!success) revert NativeTransferFailed();
    }
}
// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import { ContractAddress } from '../libs/ContractAddress.sol';
import { ICaller } from '../interfaces/ICaller.sol';

contract Caller is ICaller {
    using ContractAddress for address;

    /**
     * @dev Calls a target address with specified calldata and optionally sends value.
     */
    function _call(
        address target,
        bytes calldata callData,
        uint256 nativeValue
    ) internal returns (bytes memory) {
        if (!target.isContract()) revert InvalidContract(target);

        if (nativeValue > address(this).balance) revert InsufficientBalance();

        (bool success, bytes memory data) = target.call{ value: nativeValue }(callData);
        if (!success) {
            revert ExecutionFailed();
        }

        return data;
    }
}
// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import { ITimeLock } from '../interfaces/ITimeLock.sol';

/**
 * @title TimeLock
 * @dev A contract that enables function execution after a certain time has passed.
 * Implements the {ITimeLock} interface.
 */
contract TimeLock is ITimeLock {
    bytes32 internal constant PREFIX_TIME_LOCK = keccak256('time-lock');

    uint256 public immutable minimumTimeLockDelay;

    /**
     * @notice The constructor for the TimeLock.
     * @param minimumTimeDelay The minimum time delay (in secs) that must pass for the TimeLock to be executed
     */
    constructor(uint256 minimumTimeDelay) {
        minimumTimeLockDelay = minimumTimeDelay;
    }

    /**
     * @notice Returns the timestamp after which the TimeLock may be executed.
     * @param hash The hash of the timelock
     * @return uint The timestamp after which the timelock with the given hash can be executed
     */
    function getTimeLock(bytes32 hash) external view override returns (uint256) {
        return _getTimeLockEta(hash);
    }

    /**
     * @notice Schedules a new timelock.
     * @dev The timestamp will be set to the current block timestamp + minimum time delay,
     * if the provided timestamp is less than that.
     * @param hash The hash of the new timelock
     * @param eta The proposed Unix timestamp (in secs) after which the new timelock can be executed
     * @return uint The Unix timestamp (in secs) after which the new timelock can be executed
     */
    function _scheduleTimeLock(bytes32 hash, uint256 eta) internal returns (uint256) {
        if (hash == 0) revert InvalidTimeLockHash();
        if (_getTimeLockEta(hash) != 0) revert TimeLockAlreadyScheduled();

        uint256 minimumEta = block.timestamp + minimumTimeLockDelay;

        if (eta < minimumEta) eta = minimumEta;

        _setTimeLockEta(hash, eta);

        return eta;
    }

    /**
     * @notice Cancels an existing timelock by setting its eta to zero.
     * @param hash The hash of the timelock to cancel
     */
    function _cancelTimeLock(bytes32 hash) internal {
        if (hash == 0) revert InvalidTimeLockHash();

        _setTimeLockEta(hash, 0);
    }

    /**
     * @notice Finalizes an existing timelock and sets its eta back to zero.
     * @dev To finalize, the timelock must currently exist and the required time delay
     * must have passed.
     * @param hash The hash of the timelock to finalize
     */
    function _finalizeTimeLock(bytes32 hash) internal {
        uint256 eta = _getTimeLockEta(hash);

        if (hash == 0 || eta == 0) revert InvalidTimeLockHash();

        if (block.timestamp < eta) revert TimeLockNotReady();

        _setTimeLockEta(hash, 0);
    }

    /**
     * @dev Returns the timestamp after which the timelock with the given hash can be executed.
     */
    function _getTimeLockEta(bytes32 hash) internal view returns (uint256 eta) {
        bytes32 key = keccak256(abi.encodePacked(PREFIX_TIME_LOCK, hash));

        assembly {
            eta := sload(key)
        }
    }

    /**
     * @dev Sets a new timestamp for the timelock with the given hash.
     */
    function _setTimeLockEta(bytes32 hash, uint256 eta) private {
        bytes32 key = keccak256(abi.encodePacked(PREFIX_TIME_LOCK, hash));

        assembly {
            sstore(key, eta)
        }
    }
}
