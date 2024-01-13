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
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IERC20 {
    error InvalidAccount();

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

import { IContractIdentifier } from './IContractIdentifier.sol';

interface IImplementation is IContractIdentifier {
    error NotProxy();

    function setup(bytes calldata data) external;
}
// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

/**
 * @title IRolesBase Interface
 * @notice IRolesBase is an interface that abstracts the implementation of a
 * contract with role control internal functions.
 */
interface IRolesBase {
    error MissingRole(address account, uint8 role);
    error MissingAllRoles(address account, uint256 accountRoles);
    error MissingAnyOfRoles(address account, uint256 accountRoles);

    error InvalidProposedRoles(address fromAccount, address toAccount, uint256 accountRoles);

    event RolesProposed(address indexed fromAccount, address indexed toAccount, uint256 accountRoles);
    event RolesAdded(address indexed account, uint256 accountRoles);
    event RolesRemoved(address indexed account, uint256 accountRoles);

    /**
     * @notice Checks if an account has a role.
     * @param account The address to check
     * @param role The role to check
     * @return True if the account has the role, false otherwise
     */
    function hasRole(address account, uint8 role) external view returns (bool);
}
// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

/**
 * @title AddressBytesUtils
 * @dev This library provides utility functions to convert between `address` and `bytes`.
 */
library AddressBytes {
    error InvalidBytesLength(bytes bytesAddress);

    /**
     * @dev Converts a bytes address to an address type.
     * @param bytesAddress The bytes representation of an address
     * @return addr The converted address
     */
    function toAddress(bytes memory bytesAddress) internal pure returns (address addr) {
        if (bytesAddress.length != 20) revert InvalidBytesLength(bytesAddress);

        assembly {
            addr := mload(add(bytesAddress, 20))
        }
    }

    /**
     * @dev Converts an address to bytes.
     * @param addr The address to be converted
     * @return bytesAddress The bytes representation of the address
     */
    function toBytes(address addr) internal pure returns (bytes memory bytesAddress) {
        bytesAddress = new bytes(20);
        // we can test if using a single 32 byte variable that is the address with the length together and using one mstore would be slightly cheaper.
        assembly {
            mstore(add(bytesAddress, 20), addr)
            mstore(bytesAddress, 20)
        }
    }
}
// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import { IERC20 } from '../interfaces/IERC20.sol';

error TokenTransferFailed();

/*
 * @title SafeTokenCall
 * @dev This library is used for performing safe token transfers.
 */
library SafeTokenCall {
    /*
     * @notice Make a safe call to a token contract.
     * @param token The token contract to interact with.
     * @param callData The function call data.
     * @throws TokenTransferFailed error if transfer of token is not successful.
     */
    function safeCall(IERC20 token, bytes memory callData) internal {
        (bool success, bytes memory returnData) = address(token).call(callData);
        bool transferred = success && (returnData.length == uint256(0) || abi.decode(returnData, (bool)));

        if (!transferred || address(token).code.length == 0) revert TokenTransferFailed();
    }
}

/*
 * @title SafeTokenTransfer
 * @dev This library safely transfers tokens from the contract to a recipient.
 */
library SafeTokenTransfer {
    /*
     * @notice Transfer tokens to a recipient.
     * @param token The token contract.
     * @param receiver The recipient of the tokens.
     * @param amount The amount of tokens to transfer.
     */
    function safeTransfer(
        IERC20 token,
        address receiver,
        uint256 amount
    ) internal {
        SafeTokenCall.safeCall(token, abi.encodeWithSelector(IERC20.transfer.selector, receiver, amount));
    }
}

/*
 * @title SafeTokenTransferFrom
 * @dev This library helps to safely transfer tokens on behalf of a token holder.
 */
library SafeTokenTransferFrom {
    /*
     * @notice Transfer tokens on behalf of a token holder.
     * @param token The token contract.
     * @param from The address of the token holder.
     * @param to The address the tokens are to be sent to.
     * @param amount The amount of tokens to be transferred.
     */
    function safeTransferFrom(
        IERC20 token,
        address from,
        address to,
        uint256 amount
    ) internal {
        SafeTokenCall.safeCall(token, abi.encodeWithSelector(IERC20.transferFrom.selector, from, to, amount));
    }
}
// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import { IImplementation } from '../interfaces/IImplementation.sol';

/**
 * @title Implementation
 * @notice This contract serves as a base for other contracts and enforces a proxy-first access restriction.
 * @dev Derived contracts must implement the setup function.
 */
abstract contract Implementation is IImplementation {
    address private immutable implementationAddress;

    /**
     * @dev Contract constructor that sets the implementation address to the address of this contract.
     */
    constructor() {
        implementationAddress = address(this);
    }

    /**
     * @dev Modifier to require the caller to be the proxy contract.
     * Reverts if the caller is the current contract (i.e., the implementation contract itself).
     */
    modifier onlyProxy() {
        if (implementationAddress == address(this)) revert NotProxy();
        _;
    }

    /**
     * @notice Initializes contract parameters.
     * This function is intended to be overridden by derived contracts.
     * The overriding function must have the onlyProxy modifier.
     * @param params The parameters to be used for initialization
     */
    function setup(bytes calldata params) external virtual;
}
// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import { IRolesBase } from '../interfaces/IRolesBase.sol';

/**
 * @title RolesBase
 * @notice A contract module which provides a set if internal functions
 * for implementing role control features.
 */
contract RolesBase is IRolesBase {
    bytes32 internal constant ROLES_PREFIX = keccak256('roles');
    bytes32 internal constant PROPOSE_ROLES_PREFIX = keccak256('propose-roles');

    /**
     * @notice Modifier that throws an error if called by any account missing the role.
     */
    modifier onlyRole(uint8 role) {
        if (!_hasRole(_getRoles(msg.sender), role)) revert MissingRole(msg.sender, role);

        _;
    }

    /**
     * @notice Modifier that throws an error if called by an account without all the roles.
     */
    modifier withEveryRole(uint8[] memory roles) {
        uint256 accountRoles = _toAccountRoles(roles);
        if (!_hasAllTheRoles(_getRoles(msg.sender), accountRoles)) revert MissingAllRoles(msg.sender, accountRoles);

        _;
    }

    /**
     * @notice Modifier that throws an error if called by an account without any of the roles.
     */
    modifier withAnyRole(uint8[] memory roles) {
        uint256 accountRoles = _toAccountRoles(roles);
        if (!_hasAnyOfRoles(_getRoles(msg.sender), accountRoles)) revert MissingAnyOfRoles(msg.sender, accountRoles);

        _;
    }

    /**
     * @notice Checks if an account has a role.
     * @param account The address to check
     * @param role The role to check
     * @return True if the account has the role, false otherwise
     */
    function hasRole(address account, uint8 role) public view returns (bool) {
        return _hasRole(_getRoles(account), role);
    }

    /**
     * @notice Internal function to convert an array of roles to a uint256.
     * @param roles The roles to convert
     * @return accountRoles The roles in uint256 format
     */
    function _toAccountRoles(uint8[] memory roles) internal pure returns (uint256) {
        uint256 length = roles.length;
        uint256 accountRoles;

        for (uint256 i = 0; i < length; ++i) {
            accountRoles |= (1 << roles[i]);
        }

        return accountRoles;
    }

    /**
     * @notice Internal function to get the key of the roles mapping.
     * @param account The address to get the key for
     * @return key The key of the roles mapping
     */
    function _rolesKey(address account) internal view virtual returns (bytes32 key) {
        return keccak256(abi.encodePacked(ROLES_PREFIX, account));
    }

    /**
     * @notice Internal function to get the roles of an account.
     * @param account The address to get the roles for
     * @return accountRoles The roles of the account in uint256 format
     */
    function _getRoles(address account) internal view returns (uint256 accountRoles) {
        bytes32 key = _rolesKey(account);
        assembly {
            accountRoles := sload(key)
        }
    }

    /**
     * @notice Internal function to set the roles of an account.
     * @param account The address to set the roles for
     * @param accountRoles The roles to set
     */
    function _setRoles(address account, uint256 accountRoles) private {
        bytes32 key = _rolesKey(account);
        assembly {
            sstore(key, accountRoles)
        }
    }

    /**
     * @notice Internal function to get the key of the proposed roles mapping.
     * @param fromAccount The address of the current role
     * @param toAccount The address of the pending role
     * @return key The key of the proposed roles mapping
     */
    function _proposalKey(address fromAccount, address toAccount) internal view virtual returns (bytes32 key) {
        return keccak256(abi.encodePacked(PROPOSE_ROLES_PREFIX, fromAccount, toAccount));
    }

    /**
     * @notice Internal function to get the proposed roles of an account.
     * @param fromAccount The address of the current role
     * @param toAccount The address of the pending role
     * @return proposedRoles_ The proposed roles of the account in uint256 format
     */
    function _getProposedRoles(address fromAccount, address toAccount) internal view returns (uint256 proposedRoles_) {
        bytes32 key = _proposalKey(fromAccount, toAccount);
        assembly {
            proposedRoles_ := sload(key)
        }
    }

    /**
     * @notice Internal function to set the proposed roles of an account.
     * @param fromAccount The address of the current role
     * @param toAccount The address of the pending role
     * @param proposedRoles_ The proposed roles to set in uint256 format
     */
    function _setProposedRoles(
        address fromAccount,
        address toAccount,
        uint256 proposedRoles_
    ) private {
        bytes32 key = _proposalKey(fromAccount, toAccount);
        assembly {
            sstore(key, proposedRoles_)
        }
    }

    /**
     * @notice Internal function to add a role to an account.
     * @dev emits a RolesAdded event.
     * @param account The address to add the role to
     * @param role The role to add
     */
    function _addRole(address account, uint8 role) internal {
        _addAccountRoles(account, 1 << role);
    }

    /**
     * @notice Internal function to add roles to an account.
     * @dev emits a RolesAdded event.
     * @dev Called in the constructor to set the initial roles.
     * @param account The address to add roles to
     * @param roles The roles to add
     */
    function _addRoles(address account, uint8[] memory roles) internal {
        _addAccountRoles(account, _toAccountRoles(roles));
    }

    /**
     * @notice Internal function to add roles to an account.
     * @dev emits a RolesAdded event.
     * @dev Called in the constructor to set the initial roles.
     * @param account The address to add roles to
     * @param accountRoles The roles to add
     */
    function _addAccountRoles(address account, uint256 accountRoles) internal {
        uint256 newAccountRoles = _getRoles(account) | accountRoles;

        _setRoles(account, newAccountRoles);

        emit RolesAdded(account, accountRoles);
    }

    /**
     * @notice Internal function to remove a role from an account.
     * @dev emits a RolesRemoved event.
     * @param account The address to remove the role from
     * @param role The role to remove
     */
    function _removeRole(address account, uint8 role) internal {
        _removeAccountRoles(account, 1 << role);
    }

    /**
     * @notice Internal function to remove roles from an account.
     * @dev emits a RolesRemoved event.
     * @param account The address to remove roles from
     * @param roles The roles to remove
     */
    function _removeRoles(address account, uint8[] memory roles) internal {
        _removeAccountRoles(account, _toAccountRoles(roles));
    }

    /**
     * @notice Internal function to remove roles from an account.
     * @dev emits a RolesRemoved event.
     * @param account The address to remove roles from
     * @param accountRoles The roles to remove
     */
    function _removeAccountRoles(address account, uint256 accountRoles) internal {
        uint256 newAccountRoles = _getRoles(account) & ~accountRoles;

        _setRoles(account, newAccountRoles);

        emit RolesRemoved(account, accountRoles);
    }

    /**
     * @notice Internal function to check if an account has a role.
     * @param accountRoles The roles of the account in uint256 format
     * @param role The role to check
     * @return True if the account has the role, false otherwise
     */
    function _hasRole(uint256 accountRoles, uint8 role) internal pure returns (bool) {
        return accountRoles & (1 << role) != 0;
    }

    /**
     * @notice Internal function to check if an account has all the roles.
     * @param hasAccountRoles The roles of the account in uint256 format
     * @param mustHaveAccountRoles The roles the account must have
     * @return True if the account has all the roles, false otherwise
     */
    function _hasAllTheRoles(uint256 hasAccountRoles, uint256 mustHaveAccountRoles) internal pure returns (bool) {
        return (hasAccountRoles & mustHaveAccountRoles) == mustHaveAccountRoles;
    }

    /**
     * @notice Internal function to check if an account has any of the roles.
     * @param hasAccountRoles The roles of the account in uint256 format
     * @param mustHaveAnyAccountRoles The roles to check in uint256 format
     * @return True if the account has any of the roles, false otherwise
     */
    function _hasAnyOfRoles(uint256 hasAccountRoles, uint256 mustHaveAnyAccountRoles) internal pure returns (bool) {
        return (hasAccountRoles & mustHaveAnyAccountRoles) != 0;
    }

    /**
     * @notice Internal function to propose to transfer roles of message sender to a new account.
     * @dev Original account must have all the proposed roles.
     * @dev Emits a RolesProposed event.
     * @dev Roles are not transferred until the new role accepts the role transfer.
     * @param fromAccount The address of the current roles
     * @param toAccount The address to transfer roles to
     * @param role The role to transfer
     */
    function _proposeRole(
        address fromAccount,
        address toAccount,
        uint8 role
    ) internal {
        _proposeAccountRoles(fromAccount, toAccount, 1 << role);
    }

    /**
     * @notice Internal function to propose to transfer roles of message sender to a new account.
     * @dev Original account must have all the proposed roles.
     * @dev Emits a RolesProposed event.
     * @dev Roles are not transferred until the new role accepts the role transfer.
     * @param fromAccount The address of the current roles
     * @param toAccount The address to transfer roles to
     * @param roles The roles to transfer
     */
    function _proposeRoles(
        address fromAccount,
        address toAccount,
        uint8[] memory roles
    ) internal {
        _proposeAccountRoles(fromAccount, toAccount, _toAccountRoles(roles));
    }

    /**
     * @notice Internal function to propose to transfer roles of message sender to a new account.
     * @dev Original account must have all the proposed roles.
     * @dev Emits a RolesProposed event.
     * @dev Roles are not transferred until the new role accepts the role transfer.
     * @param fromAccount The address of the current roles
     * @param toAccount The address to transfer roles to
     * @param accountRoles The account roles to transfer
     */
    function _proposeAccountRoles(
        address fromAccount,
        address toAccount,
        uint256 accountRoles
    ) internal {
        if (!_hasAllTheRoles(_getRoles(fromAccount), accountRoles)) revert MissingAllRoles(fromAccount, accountRoles);

        _setProposedRoles(fromAccount, toAccount, accountRoles);

        emit RolesProposed(fromAccount, toAccount, accountRoles);
    }

    /**
     * @notice Internal function to accept roles transferred from another account.
     * @dev Pending account needs to pass all the proposed roles.
     * @dev Emits RolesRemoved and RolesAdded events.
     * @param fromAccount The address of the current role
     * @param role The role to accept
     */
    function _acceptRole(
        address fromAccount,
        address toAccount,
        uint8 role
    ) internal virtual {
        _acceptAccountRoles(fromAccount, toAccount, 1 << role);
    }

    /**
     * @notice Internal function to accept roles transferred from another account.
     * @dev Pending account needs to pass all the proposed roles.
     * @dev Emits RolesRemoved and RolesAdded events.
     * @param fromAccount The address of the current role
     * @param roles The roles to accept
     */
    function _acceptRoles(
        address fromAccount,
        address toAccount,
        uint8[] memory roles
    ) internal virtual {
        _acceptAccountRoles(fromAccount, toAccount, _toAccountRoles(roles));
    }

    /**
     * @notice Internal function to accept roles transferred from another account.
     * @dev Pending account needs to pass all the proposed roles.
     * @dev Emits RolesRemoved and RolesAdded events.
     * @param fromAccount The address of the current role
     * @param accountRoles The account roles to accept
     */
    function _acceptAccountRoles(
        address fromAccount,
        address toAccount,
        uint256 accountRoles
    ) internal virtual {
        if (_getProposedRoles(fromAccount, toAccount) != accountRoles) {
            revert InvalidProposedRoles(fromAccount, toAccount, accountRoles);
        }

        _setProposedRoles(fromAccount, toAccount, 0);
        _transferAccountRoles(fromAccount, toAccount, accountRoles);
    }

    /**
     * @notice Internal function to transfer roles from one account to another.
     * @dev Original account must have all the proposed roles.
     * @param fromAccount The address of the current role
     * @param toAccount The address to transfer role to
     * @param role The role to transfer
     */
    function _transferRole(
        address fromAccount,
        address toAccount,
        uint8 role
    ) internal {
        _transferAccountRoles(fromAccount, toAccount, 1 << role);
    }

    /**
     * @notice Internal function to transfer roles from one account to another.
     * @dev Original account must have all the proposed roles.
     * @param fromAccount The address of the current role
     * @param toAccount The address to transfer role to
     * @param roles The roles to transfer
     */
    function _transferRoles(
        address fromAccount,
        address toAccount,
        uint8[] memory roles
    ) internal {
        _transferAccountRoles(fromAccount, toAccount, _toAccountRoles(roles));
    }

    /**
     * @notice Internal function to transfer roles from one account to another.
     * @dev Original account must have all the proposed roles.
     * @param fromAccount The address of the current role
     * @param toAccount The address to transfer role to
     * @param accountRoles The account roles to transfer
     */
    function _transferAccountRoles(
        address fromAccount,
        address toAccount,
        uint256 accountRoles
    ) internal {
        if (!_hasAllTheRoles(_getRoles(fromAccount), accountRoles)) revert MissingAllRoles(fromAccount, accountRoles);

        _removeAccountRoles(fromAccount, accountRoles);
        _addAccountRoles(toAccount, accountRoles);
    }
}
// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

/**
 * @title IBaseTokenManager
 * @notice This contract is defines the base token manager interface implemented by all token managers.
 */
interface IBaseTokenManager {
    /**
     * @notice A function that returns the token id.
     */
    function interchainTokenId() external view returns (bytes32);

    /**
     * @notice A function that should return the address of the token.
     * Must be overridden in the inheriting contract.
     * @return address address of the token.
     */
    function tokenAddress() external view returns (address);

    /**
     * @notice A function that should return the token address from the init params.
     */
    function getTokenAddressFromParams(bytes calldata params) external pure returns (address);
}
// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

/**
 * @title FlowLimit Interface
 * @notice Interface for flow limit logic for interchain token transfers.
 */
interface IFlowLimit {
    error FlowLimitExceeded(uint256 limit, uint256 flowAmount, address tokenManager);

    event FlowLimitSet(bytes32 indexed tokenId, address operator, uint256 flowLimit_);

    /**
     * @notice Returns the current flow limit.
     * @return flowLimit_ The current flow limit value.
     */
    function flowLimit() external view returns (uint256 flowLimit_);

    /**
     * @notice Returns the current flow out amount.
     * @return flowOutAmount_ The current flow out amount.
     */
    function flowOutAmount() external view returns (uint256 flowOutAmount_);

    /**
     * @notice Returns the current flow in amount.
     * @return flowInAmount_ The current flow in amount.
     */
    function flowInAmount() external view returns (uint256 flowInAmount_);
}
// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import { IRolesBase } from '@axelar-network/axelar-gmp-sdk-solidity/contracts/interfaces/IRolesBase.sol';

/**
 * @title IOperator Interface
 * @notice An interface for a contract module which provides a basic access control mechanism, where
 * there is an account (a operator) that can be granted exclusive access to specific functions.
 */
interface IOperator is IRolesBase {
    /**
     * @notice Change the operator of the contract.
     * @dev Can only be called by the current operator.
     * @param operator_ The address of the new operator.
     */
    function transferOperatorship(address operator_) external;

    /**
     * @notice Proposed a change of the operator of the contract.
     * @dev Can only be called by the current operator.
     * @param operator_ The address of the new operator.
     */
    function proposeOperatorship(address operator_) external;

    /**
     * @notice Accept a proposed change of operatorship.
     * @dev Can only be called by the proposed operator.
     * @param fromOperator The previous operator of the contract.
     */
    function acceptOperatorship(address fromOperator) external;

    /**
     * @notice Query if an address is a operator.
     * @param addr The address to query for.
     * @return bool Boolean value representing whether or not the address is an operator.
     */
    function isOperator(address addr) external view returns (bool);
}
// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import { IImplementation } from '@axelar-network/axelar-gmp-sdk-solidity/contracts/interfaces/IImplementation.sol';

import { IBaseTokenManager } from './IBaseTokenManager.sol';
import { IOperator } from './IOperator.sol';
import { IFlowLimit } from './IFlowLimit.sol';

/**
 * @title ITokenManager Interface
 * @notice This contract is responsible for managing tokens, such as setting locking token balances, or setting flow limits, for interchain transfers.
 */
interface ITokenManager is IBaseTokenManager, IOperator, IFlowLimit, IImplementation {
    error TokenLinkerZeroAddress();
    error NotService(address caller);
    error TakeTokenFailed();
    error GiveTokenFailed();
    error NotToken(address caller);
    error ZeroAddress();
    error AlreadyFlowLimiter(address flowLimiter);
    error NotFlowLimiter(address flowLimiter);
    error NotSupported();

    /**
     * @notice Returns implementation type of this token manager.
     * @return uint256 The implementation type of this token manager.
     */
    function implementationType() external view returns (uint256);

    function addFlowIn(uint256 amount) external;

    function addFlowOut(uint256 amount) external;

    /**
     * @notice This function adds a flow limiter for this TokenManager.
     * @dev Can only be called by the operator.
     * @param flowLimiter the address of the new flow limiter.
     */
    function addFlowLimiter(address flowLimiter) external;

    /**
     * @notice This function removes a flow limiter for this TokenManager.
     * @dev Can only be called by the operator.
     * @param flowLimiter the address of an existing flow limiter.
     */
    function removeFlowLimiter(address flowLimiter) external;

    /**
     * @notice Query if an address is a flow limiter.
     * @param addr The address to query for.
     * @return bool Boolean value representing whether or not the address is a flow limiter.
     */
    function isFlowLimiter(address addr) external view returns (bool);

    /**
     * @notice This function sets the flow limit for this TokenManager.
     * @dev Can only be called by the flow limiters.
     * @param flowLimit_ The maximum difference between the tokens flowing in and/or out at any given interval of time (6h).
     */
    function setFlowLimit(uint256 flowLimit_) external;

    /**
     * @notice A function to renew approval to the service if we need to.
     */
    function approveService() external;

    /**
     * @notice Getter function for the parameters of a lock/unlock TokenManager.
     * @dev This function will be mainly used by frontends.
     * @param operator_ The operator of the TokenManager.
     * @param tokenAddress_ The token to be managed.
     * @return params_ The resulting params to be passed to custom TokenManager deployments.
     */
    function params(bytes calldata operator_, address tokenAddress_) external pure returns (bytes memory params_);
}
// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import { IERC20 } from '@axelar-network/axelar-gmp-sdk-solidity/contracts/interfaces/IERC20.sol';
import { AddressBytes } from '@axelar-network/axelar-gmp-sdk-solidity/contracts/libs/AddressBytes.sol';
import { IImplementation } from '@axelar-network/axelar-gmp-sdk-solidity/contracts/interfaces/IImplementation.sol';
import { Implementation } from '@axelar-network/axelar-gmp-sdk-solidity/contracts/upgradable/Implementation.sol';
import { SafeTokenCall } from '@axelar-network/axelar-gmp-sdk-solidity/contracts/libs/SafeTransfer.sol';

import { ITokenManager } from '../interfaces/ITokenManager.sol';

import { Operator } from '../utils/Operator.sol';
import { FlowLimit } from '../utils/FlowLimit.sol';

/**
 * @title TokenManager
 * @notice This contract is responsible for managing tokens, such as setting locking token balances, or setting flow limits, for interchain transfers.
 */
contract TokenManager is ITokenManager, Operator, FlowLimit, Implementation {
    using AddressBytes for bytes;
    using SafeTokenCall for IERC20;

    uint256 internal constant UINT256_MAX = type(uint256).max;

    address public immutable interchainTokenService;

    bytes32 private constant CONTRACT_ID = keccak256('token-manager');

    /**
     * @notice Constructs the TokenManager contract.
     * @param interchainTokenService_ The address of the interchain token service.
     */
    constructor(address interchainTokenService_) {
        if (interchainTokenService_ == address(0)) revert TokenLinkerZeroAddress();

        interchainTokenService = interchainTokenService_;
    }

    /**
     * @notice A modifier that allows only the interchain token service to execute the function.
     */
    modifier onlyService() {
        if (msg.sender != interchainTokenService) revert NotService(msg.sender);
        _;
    }

    /**
     * @notice Getter for the contract id.
     * @return bytes32 The contract id.
     */
    function contractId() external pure override returns (bytes32) {
        return CONTRACT_ID;
    }

    /**
     * @notice Reads the token address from the proxy.
     * @dev This function is not supported when directly called on the implementation. It
     * must be called by the proxy.
     * @return tokenAddress_ The address of the token.
     */
    function tokenAddress() external view virtual returns (address) {
        revert NotSupported();
    }

    /**
     * @notice A function that returns the token id.
     * @dev This will only work when implementation is called by a proxy, which stores the tokenId as an immutable.
     * @return bytes32 The interchain token ID.
     */
    function interchainTokenId() public pure returns (bytes32) {
        revert NotSupported();
    }

    /**
     * @notice Returns implementation type of this token manager.
     * @return uint256 The implementation type of this token manager.
     */
    function implementationType() external pure returns (uint256) {
        revert NotSupported();
    }

    /**
     * @notice A function that should return the token address from the setup params.
     * @param params_ The setup parameters.
     * @return tokenAddress_ The token address.
     */
    function getTokenAddressFromParams(bytes calldata params_) external pure returns (address tokenAddress_) {
        (, tokenAddress_) = abi.decode(params_, (bytes, address));
    }

    /**
     * @notice Setup function for the TokenManager.
     * @dev This function should only be called by the proxy, and only once from the proxy constructor.
     * The exact format of params depends on the type of TokenManager used but the first 32 bytes are reserved
     * for the address of the operator, stored as bytes (to be compatible with non-EVM chains)
     * @param params_ The parameters to be used to initialize the TokenManager.
     */
    function setup(bytes calldata params_) external override(Implementation, IImplementation) onlyProxy {
        bytes memory operatorBytes = abi.decode(params_, (bytes));

        address operator = address(0);

        if (operatorBytes.length != 0) {
            operator = operatorBytes.toAddress();
        }

        // If an operator is not provided, set `address(0)` as the operator.
        // This allows anyone to easily check if a custom operator was set on the token manager.
        _addAccountRoles(operator, (1 << uint8(Roles.FLOW_LIMITER)) | (1 << uint8(Roles.OPERATOR)));
        // Add operator and flow limiter role to the service. The operator can remove the flow limiter role if they so chose and the service has no way to use the operator role for now.
        _addAccountRoles(interchainTokenService, (1 << uint8(Roles.FLOW_LIMITER)) | (1 << uint8(Roles.OPERATOR)));
    }

    function addFlowIn(uint256 amount) external onlyService {
        _addFlowIn(amount);
    }

    function addFlowOut(uint256 amount) external onlyService {
        _addFlowOut(amount);
    }

    /**
     * @notice This function adds a flow limiter for this TokenManager.
     * @dev Can only be called by the operator.
     * @param flowLimiter the address of the new flow limiter.
     */
    function addFlowLimiter(address flowLimiter) external onlyRole(uint8(Roles.OPERATOR)) {
        _addRole(flowLimiter, uint8(Roles.FLOW_LIMITER));
    }

    /**
     * @notice This function removes a flow limiter for this TokenManager.
     * @dev Can only be called by the operator.
     * @param flowLimiter the address of an existing flow limiter.
     */
    function removeFlowLimiter(address flowLimiter) external onlyRole(uint8(Roles.OPERATOR)) {
        _removeRole(flowLimiter, uint8(Roles.FLOW_LIMITER));
    }

    /**
     * @notice Query if an address is a flow limiter.
     * @param addr The address to query for.
     * @return bool Boolean value representing whether or not the address is a flow limiter.
     */
    function isFlowLimiter(address addr) external view returns (bool) {
        return hasRole(addr, uint8(Roles.FLOW_LIMITER));
    }

    /**
     * @notice This function sets the flow limit for this TokenManager.
     * @dev Can only be called by the flow limiters.
     * @param flowLimit_ The maximum difference between the tokens flowing in and/or out at any given interval of time (6h).
     */
    function setFlowLimit(uint256 flowLimit_) external onlyRole(uint8(Roles.FLOW_LIMITER)) {
        // slither-disable-next-line var-read-using-this
        _setFlowLimit(flowLimit_, this.interchainTokenId());
    }

    /**
     * @notice A function to renew approval to the service if we need to.
     */
    function approveService() external onlyService {
        /**
         * @dev Some tokens may not obey the infinite approval.
         * Even so, it is unexpected to run out of allowance in practice.
         * If needed, we can upgrade to allow replenishing the allowance in the future.
         */
        IERC20(this.tokenAddress()).safeCall(abi.encodeWithSelector(IERC20.approve.selector, interchainTokenService, UINT256_MAX));
    }

    /**
     * @notice Getter function for the parameters of a lock/unlock TokenManager.
     * @dev This function will be mainly used by frontends.
     * @param operator_ The operator of the TokenManager.
     * @param tokenAddress_ The token to be managed.
     * @return params_ The resulting params to be passed to custom TokenManager deployments.
     */
    function params(bytes calldata operator_, address tokenAddress_) external pure returns (bytes memory params_) {
        params_ = abi.encode(operator_, tokenAddress_);
    }
}
// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import { IFlowLimit } from '../interfaces/IFlowLimit.sol';

/**
 * @title FlowLimit
 * @notice Implements flow limit logic for interchain token transfers.
 * @dev This contract implements low-level assembly for optimization purposes.
 */
contract FlowLimit is IFlowLimit {
    // uint256(keccak256('flow-limit')) - 1
    uint256 internal constant FLOW_LIMIT_SLOT = 0x201b7a0b7c19aaddc4ce9579b7df8d2db123805861bc7763627f13e04d8af42f;
    uint256 internal constant PREFIX_FLOW_OUT_AMOUNT = uint256(keccak256('flow-out-amount'));
    uint256 internal constant PREFIX_FLOW_IN_AMOUNT = uint256(keccak256('flow-in-amount'));

    uint256 internal constant EPOCH_TIME = 6 hours;

    /**
     * @notice Returns the current flow limit.
     * @return flowLimit_ The current flow limit value.
     */
    function flowLimit() public view returns (uint256 flowLimit_) {
        assembly {
            flowLimit_ := sload(FLOW_LIMIT_SLOT)
        }
    }

    /**
     * @notice Internal function to set the flow limit.
     * @param flowLimit_ The value to set the flow limit to.
     * @param tokenId The id of the token to set the flow limit for.
     */
    function _setFlowLimit(uint256 flowLimit_, bytes32 tokenId) internal {
        assembly {
            sstore(FLOW_LIMIT_SLOT, flowLimit_)
        }

        emit FlowLimitSet(tokenId, msg.sender, flowLimit_);
    }

    /**
     * @notice Returns the slot which is used to get the flow out amount for a specific epoch.
     * @param epoch The epoch to get the flow out amount for.
     * @return slot The slot to get the flow out amount from.
     */
    function _getFlowOutSlot(uint256 epoch) internal pure returns (uint256 slot) {
        slot = uint256(keccak256(abi.encode(PREFIX_FLOW_OUT_AMOUNT, epoch)));
    }

    /**
     * @dev Returns the slot which is used to get the flow in amount for a specific epoch.
     * @param epoch The epoch to get the flow in amount for.
     * @return slot The slot to get the flow in amount from.
     */
    function _getFlowInSlot(uint256 epoch) internal pure returns (uint256 slot) {
        slot = uint256(keccak256(abi.encode(PREFIX_FLOW_IN_AMOUNT, epoch)));
    }

    /**
     * @notice Returns the current flow out amount.
     * @return flowOutAmount_ The current flow out amount.
     */
    function flowOutAmount() external view returns (uint256 flowOutAmount_) {
        uint256 epoch = block.timestamp / EPOCH_TIME;
        uint256 slot = _getFlowOutSlot(epoch);

        assembly {
            flowOutAmount_ := sload(slot)
        }
    }

    /**
     * @notice Returns the current flow in amount.
     * @return flowInAmount_ The current flow in amount.
     */
    function flowInAmount() external view returns (uint256 flowInAmount_) {
        uint256 epoch = block.timestamp / EPOCH_TIME;
        uint256 slot = _getFlowInSlot(epoch);

        assembly {
            flowInAmount_ := sload(slot)
        }
    }

    /**
     * @notice Adds a flow amount while ensuring it does not exceed the flow limit.
     * @param flowLimit_ The current flow limit value.
     * @param slotToAdd The slot to add the flow to.
     * @param slotToCompare The slot to compare the flow against.
     * @param flowAmount The flow amount to add.
     */
    function _addFlow(uint256 flowLimit_, uint256 slotToAdd, uint256 slotToCompare, uint256 flowAmount) internal {
        uint256 flowToAdd;
        uint256 flowToCompare;

        assembly {
            flowToAdd := sload(slotToAdd)
            flowToCompare := sload(slotToCompare)
        }

        if (flowToAdd + flowAmount > flowToCompare + flowLimit_)
            revert FlowLimitExceeded((flowToCompare + flowLimit_), flowToAdd + flowAmount, address(this));
        if (flowAmount > flowLimit_) revert FlowLimitExceeded(flowLimit_, flowAmount, address(this));

        assembly {
            sstore(slotToAdd, add(flowToAdd, flowAmount))
        }
    }

    /**
     * @notice Adds a flow out amount.
     * @param flowOutAmount_ The flow out amount to add.
     */
    function _addFlowOut(uint256 flowOutAmount_) internal {
        uint256 flowLimit_ = flowLimit();
        if (flowLimit_ == 0) return;

        uint256 epoch = block.timestamp / EPOCH_TIME;
        uint256 slotToAdd = _getFlowOutSlot(epoch);
        uint256 slotToCompare = _getFlowInSlot(epoch);

        _addFlow(flowLimit_, slotToAdd, slotToCompare, flowOutAmount_);
    }

    /**
     * @notice Adds a flow in amount.
     * @param flowInAmount_ The flow in amount to add.
     */
    function _addFlowIn(uint256 flowInAmount_) internal {
        uint256 flowLimit_ = flowLimit();
        if (flowLimit_ == 0) return;

        uint256 epoch = block.timestamp / EPOCH_TIME;
        uint256 slotToAdd = _getFlowInSlot(epoch);
        uint256 slotToCompare = _getFlowOutSlot(epoch);

        _addFlow(flowLimit_, slotToAdd, slotToCompare, flowInAmount_);
    }
}
// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import { RolesBase } from '@axelar-network/axelar-gmp-sdk-solidity/contracts/utils/RolesBase.sol';

import { IOperator } from '../interfaces/IOperator.sol';

import { RolesConstants } from './RolesConstants.sol';

/**
 * @title Operator Contract
 * @notice A contract module which provides a basic access control mechanism, where
 * there is an account (a operator) that can be granted exclusive access to
 * specific functions.
 * @dev This module is used through inheritance.
 */
contract Operator is IOperator, RolesBase, RolesConstants {
    /**
     * @notice Internal function that stores the new operator address in the correct storage slot
     * @param operator The address of the new operator
     */
    function _addOperator(address operator) internal {
        _addRole(operator, uint8(Roles.OPERATOR));
    }

    /**
     * @notice Change the operator of the contract.
     * @dev Can only be called by the current operator.
     * @param operator The address of the new operator.
     */
    function transferOperatorship(address operator) external onlyRole(uint8(Roles.OPERATOR)) {
        _transferRole(msg.sender, operator, uint8(Roles.OPERATOR));
    }

    /**
     * @notice Propose a change of the operator of the contract.
     * @dev Can only be called by the current operator.
     * @param operator The address of the new operator.
     */
    function proposeOperatorship(address operator) external onlyRole(uint8(Roles.OPERATOR)) {
        _proposeRole(msg.sender, operator, uint8(Roles.OPERATOR));
    }

    /**
     * @notice Accept a proposed change of operatorship.
     * @dev Can only be called by the proposed operator.
     * @param fromOperator The previous operator of the contract.
     */
    function acceptOperatorship(address fromOperator) external {
        _acceptRole(fromOperator, msg.sender, uint8(Roles.OPERATOR));
    }

    /**
     * @notice Query if an address is a operator.
     * @param addr The address to query for.
     * @return bool Boolean value representing whether or not the address is an operator.
     */
    function isOperator(address addr) external view returns (bool) {
        return hasRole(addr, uint8(Roles.OPERATOR));
    }
}
// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

/**
 * @title RolesConstants
 * @notice This contract contains enum values representing different contract roles.
 */
contract RolesConstants {
    enum Roles {
        MINTER,
        OPERATOR,
        FLOW_LIMITER
    }
}
