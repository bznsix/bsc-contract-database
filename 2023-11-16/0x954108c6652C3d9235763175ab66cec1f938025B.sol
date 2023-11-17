// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.9.0) (access/AccessControl.sol)

pragma solidity ^0.8.0;

import "./IAccessControl.sol";
import "../utils/Context.sol";
import "../utils/Strings.sol";
import "../utils/introspection/ERC165.sol";

/**
 * @dev Contract module that allows children to implement role-based access
 * control mechanisms. This is a lightweight version that doesn't allow enumerating role
 * members except through off-chain means by accessing the contract event logs. Some
 * applications may benefit from on-chain enumerability, for those cases see
 * {AccessControlEnumerable}.
 *
 * Roles are referred to by their `bytes32` identifier. These should be exposed
 * in the external API and be unique. The best way to achieve this is by
 * using `public constant` hash digests:
 *
 * ```solidity
 * bytes32 public constant MY_ROLE = keccak256("MY_ROLE");
 * ```
 *
 * Roles can be used to represent a set of permissions. To restrict access to a
 * function call, use {hasRole}:
 *
 * ```solidity
 * function foo() public {
 *     require(hasRole(MY_ROLE, msg.sender));
 *     ...
 * }
 * ```
 *
 * Roles can be granted and revoked dynamically via the {grantRole} and
 * {revokeRole} functions. Each role has an associated admin role, and only
 * accounts that have a role's admin role can call {grantRole} and {revokeRole}.
 *
 * By default, the admin role for all roles is `DEFAULT_ADMIN_ROLE`, which means
 * that only accounts with this role will be able to grant or revoke other
 * roles. More complex role relationships can be created by using
 * {_setRoleAdmin}.
 *
 * WARNING: The `DEFAULT_ADMIN_ROLE` is also its own admin: it has permission to
 * grant and revoke this role. Extra precautions should be taken to secure
 * accounts that have been granted it. We recommend using {AccessControlDefaultAdminRules}
 * to enforce additional security measures for this role.
 */
abstract contract AccessControl is Context, IAccessControl, ERC165 {
    struct RoleData {
        mapping(address => bool) members;
        bytes32 adminRole;
    }

    mapping(bytes32 => RoleData) private _roles;

    bytes32 public constant DEFAULT_ADMIN_ROLE = 0x00;

    /**
     * @dev Modifier that checks that an account has a specific role. Reverts
     * with a standardized message including the required role.
     *
     * The format of the revert reason is given by the following regular expression:
     *
     *  /^AccessControl: account (0x[0-9a-f]{40}) is missing role (0x[0-9a-f]{64})$/
     *
     * _Available since v4.1._
     */
    modifier onlyRole(bytes32 role) {
        _checkRole(role);
        _;
    }

    /**
     * @dev See {IERC165-supportsInterface}.
     */
    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return interfaceId == type(IAccessControl).interfaceId || super.supportsInterface(interfaceId);
    }

    /**
     * @dev Returns `true` if `account` has been granted `role`.
     */
    function hasRole(bytes32 role, address account) public view virtual override returns (bool) {
        return _roles[role].members[account];
    }

    /**
     * @dev Revert with a standard message if `_msgSender()` is missing `role`.
     * Overriding this function changes the behavior of the {onlyRole} modifier.
     *
     * Format of the revert message is described in {_checkRole}.
     *
     * _Available since v4.6._
     */
    function _checkRole(bytes32 role) internal view virtual {
        _checkRole(role, _msgSender());
    }

    /**
     * @dev Revert with a standard message if `account` is missing `role`.
     *
     * The format of the revert reason is given by the following regular expression:
     *
     *  /^AccessControl: account (0x[0-9a-f]{40}) is missing role (0x[0-9a-f]{64})$/
     */
    function _checkRole(bytes32 role, address account) internal view virtual {
        if (!hasRole(role, account)) {
            revert(
                string(
                    abi.encodePacked(
                        "AccessControl: account ",
                        Strings.toHexString(account),
                        " is missing role ",
                        Strings.toHexString(uint256(role), 32)
                    )
                )
            );
        }
    }

    /**
     * @dev Returns the admin role that controls `role`. See {grantRole} and
     * {revokeRole}.
     *
     * To change a role's admin, use {_setRoleAdmin}.
     */
    function getRoleAdmin(bytes32 role) public view virtual override returns (bytes32) {
        return _roles[role].adminRole;
    }

    /**
     * @dev Grants `role` to `account`.
     *
     * If `account` had not been already granted `role`, emits a {RoleGranted}
     * event.
     *
     * Requirements:
     *
     * - the caller must have ``role``'s admin role.
     *
     * May emit a {RoleGranted} event.
     */
    function grantRole(bytes32 role, address account) public virtual override onlyRole(getRoleAdmin(role)) {
        _grantRole(role, account);
    }

    /**
     * @dev Revokes `role` from `account`.
     *
     * If `account` had been granted `role`, emits a {RoleRevoked} event.
     *
     * Requirements:
     *
     * - the caller must have ``role``'s admin role.
     *
     * May emit a {RoleRevoked} event.
     */
    function revokeRole(bytes32 role, address account) public virtual override onlyRole(getRoleAdmin(role)) {
        _revokeRole(role, account);
    }

    /**
     * @dev Revokes `role` from the calling account.
     *
     * Roles are often managed via {grantRole} and {revokeRole}: this function's
     * purpose is to provide a mechanism for accounts to lose their privileges
     * if they are compromised (such as when a trusted device is misplaced).
     *
     * If the calling account had been revoked `role`, emits a {RoleRevoked}
     * event.
     *
     * Requirements:
     *
     * - the caller must be `account`.
     *
     * May emit a {RoleRevoked} event.
     */
    function renounceRole(bytes32 role, address account) public virtual override {
        require(account == _msgSender(), "AccessControl: can only renounce roles for self");

        _revokeRole(role, account);
    }

    /**
     * @dev Grants `role` to `account`.
     *
     * If `account` had not been already granted `role`, emits a {RoleGranted}
     * event. Note that unlike {grantRole}, this function doesn't perform any
     * checks on the calling account.
     *
     * May emit a {RoleGranted} event.
     *
     * [WARNING]
     * ====
     * This function should only be called from the constructor when setting
     * up the initial roles for the system.
     *
     * Using this function in any other way is effectively circumventing the admin
     * system imposed by {AccessControl}.
     * ====
     *
     * NOTE: This function is deprecated in favor of {_grantRole}.
     */
    function _setupRole(bytes32 role, address account) internal virtual {
        _grantRole(role, account);
    }

    /**
     * @dev Sets `adminRole` as ``role``'s admin role.
     *
     * Emits a {RoleAdminChanged} event.
     */
    function _setRoleAdmin(bytes32 role, bytes32 adminRole) internal virtual {
        bytes32 previousAdminRole = getRoleAdmin(role);
        _roles[role].adminRole = adminRole;
        emit RoleAdminChanged(role, previousAdminRole, adminRole);
    }

    /**
     * @dev Grants `role` to `account`.
     *
     * Internal function without access restriction.
     *
     * May emit a {RoleGranted} event.
     */
    function _grantRole(bytes32 role, address account) internal virtual {
        if (!hasRole(role, account)) {
            _roles[role].members[account] = true;
            emit RoleGranted(role, account, _msgSender());
        }
    }

    /**
     * @dev Revokes `role` from `account`.
     *
     * Internal function without access restriction.
     *
     * May emit a {RoleRevoked} event.
     */
    function _revokeRole(bytes32 role, address account) internal virtual {
        if (hasRole(role, account)) {
            _roles[role].members[account] = false;
            emit RoleRevoked(role, account, _msgSender());
        }
    }
}
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (access/IAccessControl.sol)

pragma solidity ^0.8.0;

/**
 * @dev External interface of AccessControl declared to support ERC165 detection.
 */
interface IAccessControl {
    /**
     * @dev Emitted when `newAdminRole` is set as ``role``'s admin role, replacing `previousAdminRole`
     *
     * `DEFAULT_ADMIN_ROLE` is the starting admin for all roles, despite
     * {RoleAdminChanged} not being emitted signaling this.
     *
     * _Available since v3.1._
     */
    event RoleAdminChanged(bytes32 indexed role, bytes32 indexed previousAdminRole, bytes32 indexed newAdminRole);

    /**
     * @dev Emitted when `account` is granted `role`.
     *
     * `sender` is the account that originated the contract call, an admin role
     * bearer except when using {AccessControl-_setupRole}.
     */
    event RoleGranted(bytes32 indexed role, address indexed account, address indexed sender);

    /**
     * @dev Emitted when `account` is revoked `role`.
     *
     * `sender` is the account that originated the contract call:
     *   - if using `revokeRole`, it is the admin role bearer
     *   - if using `renounceRole`, it is the role bearer (i.e. `account`)
     */
    event RoleRevoked(bytes32 indexed role, address indexed account, address indexed sender);

    /**
     * @dev Returns `true` if `account` has been granted `role`.
     */
    function hasRole(bytes32 role, address account) external view returns (bool);

    /**
     * @dev Returns the admin role that controls `role`. See {grantRole} and
     * {revokeRole}.
     *
     * To change a role's admin, use {AccessControl-_setRoleAdmin}.
     */
    function getRoleAdmin(bytes32 role) external view returns (bytes32);

    /**
     * @dev Grants `role` to `account`.
     *
     * If `account` had not been already granted `role`, emits a {RoleGranted}
     * event.
     *
     * Requirements:
     *
     * - the caller must have ``role``'s admin role.
     */
    function grantRole(bytes32 role, address account) external;

    /**
     * @dev Revokes `role` from `account`.
     *
     * If `account` had been granted `role`, emits a {RoleRevoked} event.
     *
     * Requirements:
     *
     * - the caller must have ``role``'s admin role.
     */
    function revokeRole(bytes32 role, address account) external;

    /**
     * @dev Revokes `role` from the calling account.
     *
     * Roles are often managed via {grantRole} and {revokeRole}: this function's
     * purpose is to provide a mechanism for accounts to lose their privileges
     * if they are compromised (such as when a trusted device is misplaced).
     *
     * If the calling account had been granted `role`, emits a {RoleRevoked}
     * event.
     *
     * Requirements:
     *
     * - the caller must be `account`.
     */
    function renounceRole(bytes32 role, address account) external;
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
// OpenZeppelin Contracts v4.4.1 (utils/introspection/ERC165.sol)

pragma solidity ^0.8.0;

import "./IERC165.sol";

/**
 * @dev Implementation of the {IERC165} interface.
 *
 * Contracts that want to implement ERC165 should inherit from this contract and override {supportsInterface} to check
 * for the additional interface id that will be supported. For example:
 *
 * ```solidity
 * function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
 *     return interfaceId == type(MyInterface).interfaceId || super.supportsInterface(interfaceId);
 * }
 * ```
 *
 * Alternatively, {ERC165Storage} provides an easier to use but more expensive implementation.
 */
abstract contract ERC165 is IERC165 {
    /**
     * @dev See {IERC165-supportsInterface}.
     */
    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return interfaceId == type(IERC165).interfaceId;
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
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.9.0) (utils/math/Math.sol)

pragma solidity ^0.8.0;

/**
 * @dev Standard math utilities missing in the Solidity language.
 */
library Math {
    enum Rounding {
        Down, // Toward negative infinity
        Up, // Toward infinity
        Zero // Toward zero
    }

    /**
     * @dev Returns the largest of two numbers.
     */
    function max(uint256 a, uint256 b) internal pure returns (uint256) {
        return a > b ? a : b;
    }

    /**
     * @dev Returns the smallest of two numbers.
     */
    function min(uint256 a, uint256 b) internal pure returns (uint256) {
        return a < b ? a : b;
    }

    /**
     * @dev Returns the average of two numbers. The result is rounded towards
     * zero.
     */
    function average(uint256 a, uint256 b) internal pure returns (uint256) {
        // (a + b) / 2 can overflow.
        return (a & b) + (a ^ b) / 2;
    }

    /**
     * @dev Returns the ceiling of the division of two numbers.
     *
     * This differs from standard division with `/` in that it rounds up instead
     * of rounding down.
     */
    function ceilDiv(uint256 a, uint256 b) internal pure returns (uint256) {
        // (a + b - 1) / b can overflow on addition, so we distribute.
        return a == 0 ? 0 : (a - 1) / b + 1;
    }

    /**
     * @notice Calculates floor(x * y / denominator) with full precision. Throws if result overflows a uint256 or denominator == 0
     * @dev Original credit to Remco Bloemen under MIT license (https://xn--2-umb.com/21/muldiv)
     * with further edits by Uniswap Labs also under MIT license.
     */
    function mulDiv(uint256 x, uint256 y, uint256 denominator) internal pure returns (uint256 result) {
        unchecked {
            // 512-bit multiply [prod1 prod0] = x * y. Compute the product mod 2^256 and mod 2^256 - 1, then use
            // use the Chinese Remainder Theorem to reconstruct the 512 bit result. The result is stored in two 256
            // variables such that product = prod1 * 2^256 + prod0.
            uint256 prod0; // Least significant 256 bits of the product
            uint256 prod1; // Most significant 256 bits of the product
            assembly {
                let mm := mulmod(x, y, not(0))
                prod0 := mul(x, y)
                prod1 := sub(sub(mm, prod0), lt(mm, prod0))
            }

            // Handle non-overflow cases, 256 by 256 division.
            if (prod1 == 0) {
                // Solidity will revert if denominator == 0, unlike the div opcode on its own.
                // The surrounding unchecked block does not change this fact.
                // See https://docs.soliditylang.org/en/latest/control-structures.html#checked-or-unchecked-arithmetic.
                return prod0 / denominator;
            }

            // Make sure the result is less than 2^256. Also prevents denominator == 0.
            require(denominator > prod1, "Math: mulDiv overflow");

            ///////////////////////////////////////////////
            // 512 by 256 division.
            ///////////////////////////////////////////////

            // Make division exact by subtracting the remainder from [prod1 prod0].
            uint256 remainder;
            assembly {
                // Compute remainder using mulmod.
                remainder := mulmod(x, y, denominator)

                // Subtract 256 bit number from 512 bit number.
                prod1 := sub(prod1, gt(remainder, prod0))
                prod0 := sub(prod0, remainder)
            }

            // Factor powers of two out of denominator and compute largest power of two divisor of denominator. Always >= 1.
            // See https://cs.stackexchange.com/q/138556/92363.

            // Does not overflow because the denominator cannot be zero at this stage in the function.
            uint256 twos = denominator & (~denominator + 1);
            assembly {
                // Divide denominator by twos.
                denominator := div(denominator, twos)

                // Divide [prod1 prod0] by twos.
                prod0 := div(prod0, twos)

                // Flip twos such that it is 2^256 / twos. If twos is zero, then it becomes one.
                twos := add(div(sub(0, twos), twos), 1)
            }

            // Shift in bits from prod1 into prod0.
            prod0 |= prod1 * twos;

            // Invert denominator mod 2^256. Now that denominator is an odd number, it has an inverse modulo 2^256 such
            // that denominator * inv = 1 mod 2^256. Compute the inverse by starting with a seed that is correct for
            // four bits. That is, denominator * inv = 1 mod 2^4.
            uint256 inverse = (3 * denominator) ^ 2;

            // Use the Newton-Raphson iteration to improve the precision. Thanks to Hensel's lifting lemma, this also works
            // in modular arithmetic, doubling the correct bits in each step.
            inverse *= 2 - denominator * inverse; // inverse mod 2^8
            inverse *= 2 - denominator * inverse; // inverse mod 2^16
            inverse *= 2 - denominator * inverse; // inverse mod 2^32
            inverse *= 2 - denominator * inverse; // inverse mod 2^64
            inverse *= 2 - denominator * inverse; // inverse mod 2^128
            inverse *= 2 - denominator * inverse; // inverse mod 2^256

            // Because the division is now exact we can divide by multiplying with the modular inverse of denominator.
            // This will give us the correct result modulo 2^256. Since the preconditions guarantee that the outcome is
            // less than 2^256, this is the final result. We don't need to compute the high bits of the result and prod1
            // is no longer required.
            result = prod0 * inverse;
            return result;
        }
    }

    /**
     * @notice Calculates x * y / denominator with full precision, following the selected rounding direction.
     */
    function mulDiv(uint256 x, uint256 y, uint256 denominator, Rounding rounding) internal pure returns (uint256) {
        uint256 result = mulDiv(x, y, denominator);
        if (rounding == Rounding.Up && mulmod(x, y, denominator) > 0) {
            result += 1;
        }
        return result;
    }

    /**
     * @dev Returns the square root of a number. If the number is not a perfect square, the value is rounded down.
     *
     * Inspired by Henry S. Warren, Jr.'s "Hacker's Delight" (Chapter 11).
     */
    function sqrt(uint256 a) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }

        // For our first guess, we get the biggest power of 2 which is smaller than the square root of the target.
        //
        // We know that the "msb" (most significant bit) of our target number `a` is a power of 2 such that we have
        // `msb(a) <= a < 2*msb(a)`. This value can be written `msb(a)=2**k` with `k=log2(a)`.
        //
        // This can be rewritten `2**log2(a) <= a < 2**(log2(a) + 1)`
        // → `sqrt(2**k) <= sqrt(a) < sqrt(2**(k+1))`
        // → `2**(k/2) <= sqrt(a) < 2**((k+1)/2) <= 2**(k/2 + 1)`
        //
        // Consequently, `2**(log2(a) / 2)` is a good first approximation of `sqrt(a)` with at least 1 correct bit.
        uint256 result = 1 << (log2(a) >> 1);

        // At this point `result` is an estimation with one bit of precision. We know the true value is a uint128,
        // since it is the square root of a uint256. Newton's method converges quadratically (precision doubles at
        // every iteration). We thus need at most 7 iteration to turn our partial result with one bit of precision
        // into the expected uint128 result.
        unchecked {
            result = (result + a / result) >> 1;
            result = (result + a / result) >> 1;
            result = (result + a / result) >> 1;
            result = (result + a / result) >> 1;
            result = (result + a / result) >> 1;
            result = (result + a / result) >> 1;
            result = (result + a / result) >> 1;
            return min(result, a / result);
        }
    }

    /**
     * @notice Calculates sqrt(a), following the selected rounding direction.
     */
    function sqrt(uint256 a, Rounding rounding) internal pure returns (uint256) {
        unchecked {
            uint256 result = sqrt(a);
            return result + (rounding == Rounding.Up && result * result < a ? 1 : 0);
        }
    }

    /**
     * @dev Return the log in base 2, rounded down, of a positive value.
     * Returns 0 if given 0.
     */
    function log2(uint256 value) internal pure returns (uint256) {
        uint256 result = 0;
        unchecked {
            if (value >> 128 > 0) {
                value >>= 128;
                result += 128;
            }
            if (value >> 64 > 0) {
                value >>= 64;
                result += 64;
            }
            if (value >> 32 > 0) {
                value >>= 32;
                result += 32;
            }
            if (value >> 16 > 0) {
                value >>= 16;
                result += 16;
            }
            if (value >> 8 > 0) {
                value >>= 8;
                result += 8;
            }
            if (value >> 4 > 0) {
                value >>= 4;
                result += 4;
            }
            if (value >> 2 > 0) {
                value >>= 2;
                result += 2;
            }
            if (value >> 1 > 0) {
                result += 1;
            }
        }
        return result;
    }

    /**
     * @dev Return the log in base 2, following the selected rounding direction, of a positive value.
     * Returns 0 if given 0.
     */
    function log2(uint256 value, Rounding rounding) internal pure returns (uint256) {
        unchecked {
            uint256 result = log2(value);
            return result + (rounding == Rounding.Up && 1 << result < value ? 1 : 0);
        }
    }

    /**
     * @dev Return the log in base 10, rounded down, of a positive value.
     * Returns 0 if given 0.
     */
    function log10(uint256 value) internal pure returns (uint256) {
        uint256 result = 0;
        unchecked {
            if (value >= 10 ** 64) {
                value /= 10 ** 64;
                result += 64;
            }
            if (value >= 10 ** 32) {
                value /= 10 ** 32;
                result += 32;
            }
            if (value >= 10 ** 16) {
                value /= 10 ** 16;
                result += 16;
            }
            if (value >= 10 ** 8) {
                value /= 10 ** 8;
                result += 8;
            }
            if (value >= 10 ** 4) {
                value /= 10 ** 4;
                result += 4;
            }
            if (value >= 10 ** 2) {
                value /= 10 ** 2;
                result += 2;
            }
            if (value >= 10 ** 1) {
                result += 1;
            }
        }
        return result;
    }

    /**
     * @dev Return the log in base 10, following the selected rounding direction, of a positive value.
     * Returns 0 if given 0.
     */
    function log10(uint256 value, Rounding rounding) internal pure returns (uint256) {
        unchecked {
            uint256 result = log10(value);
            return result + (rounding == Rounding.Up && 10 ** result < value ? 1 : 0);
        }
    }

    /**
     * @dev Return the log in base 256, rounded down, of a positive value.
     * Returns 0 if given 0.
     *
     * Adding one to the result gives the number of pairs of hex symbols needed to represent `value` as a hex string.
     */
    function log256(uint256 value) internal pure returns (uint256) {
        uint256 result = 0;
        unchecked {
            if (value >> 128 > 0) {
                value >>= 128;
                result += 16;
            }
            if (value >> 64 > 0) {
                value >>= 64;
                result += 8;
            }
            if (value >> 32 > 0) {
                value >>= 32;
                result += 4;
            }
            if (value >> 16 > 0) {
                value >>= 16;
                result += 2;
            }
            if (value >> 8 > 0) {
                result += 1;
            }
        }
        return result;
    }

    /**
     * @dev Return the log in base 256, following the selected rounding direction, of a positive value.
     * Returns 0 if given 0.
     */
    function log256(uint256 value, Rounding rounding) internal pure returns (uint256) {
        unchecked {
            uint256 result = log256(value);
            return result + (rounding == Rounding.Up && 1 << (result << 3) < value ? 1 : 0);
        }
    }
}
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.8.0) (utils/math/SignedMath.sol)

pragma solidity ^0.8.0;

/**
 * @dev Standard signed math utilities missing in the Solidity language.
 */
library SignedMath {
    /**
     * @dev Returns the largest of two signed numbers.
     */
    function max(int256 a, int256 b) internal pure returns (int256) {
        return a > b ? a : b;
    }

    /**
     * @dev Returns the smallest of two signed numbers.
     */
    function min(int256 a, int256 b) internal pure returns (int256) {
        return a < b ? a : b;
    }

    /**
     * @dev Returns the average of two signed numbers without overflow.
     * The result is rounded towards zero.
     */
    function average(int256 a, int256 b) internal pure returns (int256) {
        // Formula from the book "Hacker's Delight"
        int256 x = (a & b) + ((a ^ b) >> 1);
        return x + (int256(uint256(x) >> 255) & (a ^ b));
    }

    /**
     * @dev Returns the absolute unsigned value of a signed value.
     */
    function abs(int256 n) internal pure returns (uint256) {
        unchecked {
            // must be unchecked in order to support `n = type(int256).min`
            return uint256(n >= 0 ? n : -n);
        }
    }
}
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.9.0) (utils/Strings.sol)

pragma solidity ^0.8.0;

import "./math/Math.sol";
import "./math/SignedMath.sol";

/**
 * @dev String operations.
 */
library Strings {
    bytes16 private constant _SYMBOLS = "0123456789abcdef";
    uint8 private constant _ADDRESS_LENGTH = 20;

    /**
     * @dev Converts a `uint256` to its ASCII `string` decimal representation.
     */
    function toString(uint256 value) internal pure returns (string memory) {
        unchecked {
            uint256 length = Math.log10(value) + 1;
            string memory buffer = new string(length);
            uint256 ptr;
            /// @solidity memory-safe-assembly
            assembly {
                ptr := add(buffer, add(32, length))
            }
            while (true) {
                ptr--;
                /// @solidity memory-safe-assembly
                assembly {
                    mstore8(ptr, byte(mod(value, 10), _SYMBOLS))
                }
                value /= 10;
                if (value == 0) break;
            }
            return buffer;
        }
    }

    /**
     * @dev Converts a `int256` to its ASCII `string` decimal representation.
     */
    function toString(int256 value) internal pure returns (string memory) {
        return string(abi.encodePacked(value < 0 ? "-" : "", toString(SignedMath.abs(value))));
    }

    /**
     * @dev Converts a `uint256` to its ASCII `string` hexadecimal representation.
     */
    function toHexString(uint256 value) internal pure returns (string memory) {
        unchecked {
            return toHexString(value, Math.log256(value) + 1);
        }
    }

    /**
     * @dev Converts a `uint256` to its ASCII `string` hexadecimal representation with fixed length.
     */
    function toHexString(uint256 value, uint256 length) internal pure returns (string memory) {
        bytes memory buffer = new bytes(2 * length + 2);
        buffer[0] = "0";
        buffer[1] = "x";
        for (uint256 i = 2 * length + 1; i > 1; --i) {
            buffer[i] = _SYMBOLS[value & 0xf];
            value >>= 4;
        }
        require(value == 0, "Strings: hex length insufficient");
        return string(buffer);
    }

    /**
     * @dev Converts an `address` with fixed length of 20 bytes to its not checksummed ASCII `string` hexadecimal representation.
     */
    function toHexString(address addr) internal pure returns (string memory) {
        return toHexString(uint256(uint160(addr)), _ADDRESS_LENGTH);
    }

    /**
     * @dev Returns true if the two strings are equal.
     */
    function equal(string memory a, string memory b) internal pure returns (bool) {
        return keccak256(bytes(a)) == keccak256(bytes(b));
    }
}
// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import './IIdoStorageState.sol';


interface IIdoStorageActions {
  /**
   * @dev Opens the ido.
   */
  function openIdo() external;

  /**
   * @dev Closes the ido.
   */
  function closeIdo() external;

  /**
   * @dev Adds new round.
   * @param priceVestingShort_  price per token unit for short vesting.
   * @param priceVestingLong_  price per token unit for long vesting.
   * @param totalSupply_  max amount of tokens available in the round.
   */
  function setupRound(uint256 priceVestingShort_, uint256 priceVestingLong_, uint256 totalSupply_) external;

  /**
   * @dev Setups default referrals.
   * @param mainReferralReward_  main reward percent.
   * @param secondaryReferralReward_  secondary reward percent.
   */
  function setupDefaultReferral(uint256 mainReferralReward_, uint256 secondaryReferralReward_) external;

  /**
   * @dev Adds referrals.
   * @param referrals_  referrals addresses.
   * @param mainRewards_  collection of main rewards.
   * @param secondaryRewards_  collection of secondary rewards.
   */
  function setupReferrals(
    address[] calldata referrals_,
    uint256[] calldata mainRewards_,
    uint256[] calldata secondaryRewards_
  ) external;

  /**
   * @dev Updates round price parameters.
   * @param index_  round index.
   * @param priceVestingShort_  price per token unit for short vesting.
   * @param priceVestingLong_  price per token unit for long vesting.
   */
  function updateRoundPrice(uint256 index_, uint256 priceVestingShort_, uint256 priceVestingLong_) external;

  /**
   * @dev Updates round supply parameters.
   * @param index_  round index.
   * @param totalSupply_  max amount of tokens available in the round.
   */
  function updateRoundSupply(uint256 index_, uint256 totalSupply_) external;

  /**
   * @dev Opens round for investment.
   * @param index_  round index.
   */
  function openRound(uint256 index_) external;

  /**
   * @dev Closes round for investment.
   * @param index_  round index.
   */
  function closeRound(uint256 index_) external;

  /**
   * @dev Sets beneficiary KYC pass.
   * @param beneficiary_  address performing the token purchase.
   * @param value_  KYC pass state.
   */
  function setKycPass(address beneficiary_, bool value_) external;

  /**
   * @dev Sets KYC pass to the beneficiaries in batches.
   * @param beneficiaries_  beneficiaries array to set the kyc for.
   * @param values_  KYC pass states.
   */
  function setKycPassBatches(address[] calldata beneficiaries_, bool[] calldata values_) external;

  /**
   * @dev Sets max investment amount.
   * @param investment_  max investment amount.
   */
  function setMaxInvestment(uint256 investment_) external;

  /**
   * @dev Sets min investment amount.
   * @param investment_  min investment amount.
   */
  function setMinInvestment(uint256 investment_) external;

  /**
   * @dev Sets KYC cap.
   * @param cap_  new cap value.
   */
  function setKycCap(uint256 cap_) external;

  /**
   * @dev Sets purchase state.
   * @param beneficiary_  address performing the token purchase.
   * @param collateral_  collateral asset.
   * @param investment_  normalized investment amount.
   * @param tokensSold_  amount of tokens purchased.
   * @param referral_  referral owner.
   * @param mainReward_  referral reward in purchase token.
   * @param tokenReward_  referral reward in ido token.
   */
  function setPurchaseState(
    address beneficiary_,
    address collateral_,
    uint256 investment_,
    uint256 tokensSold_,
    address referral_,
    uint256 mainReward_,
    uint256 tokenReward_
  ) external;

  /**
   * @dev Sets wallet address.
   * @param wallet_  new wallet value.
   */
  function setWallet(address wallet_) external;

  /**
   * @dev Enables referral code.
   * @param referral_  referral owner.
   */
  function enableReferral(address referral_) external;

  /**
   * @dev Disables referral code.
   * @param referral_  referral owner.
   */
  function disableReferral(address referral_) external;

  /**
   * @dev Claims referral rewards.
   * @param collaterals_  array of collaterals tokens.
   */
  function claimRewards(address[] calldata collaterals_) external;

  /**
   * @dev Allows to recover native coin from contract.
   */
  function recoverNative() external;

  /**
   * @dev Allows to recover erc20 tokens.
   * @param token_  token address.
   * @param amount_  amount to be recovered.
   */
  function recoverERC20(address token_, uint256 amount_) external;

  /**
   * @return True if the ido is opened.
   */
  function isOpened() external view returns (bool);

  /**
   * @return True if the ido is closed.
   */
  function isClosed() external view returns (bool);

  /**
   * @return Number of rounds
   */
  function getRoundsCount() external view returns (uint256);

  /**
   * @return Active round index.
   */
  function getActiveRound() external view returns (uint256);

  /**
   * @return Round parameters by index.
   * @param index_  round index.
   */
  function getRound(uint256 index_) external view returns (IIdoStorageState.Round memory);

  /**
   * @return Total tokens sold.
   */
  function getTotalTokenSold() external view returns (uint256);

  /**
   * @return Price of the token in the active round.
   * @param vesting_  vesting of the investment.
   */
  function getPrice(IIdoStorageState.Vesting vesting_) external view returns (uint256);

  /**
   * @return Balance of purchased tokens by beneficiary.
   * @param round_  round of ido.
   * @param beneficiary_  address performing the token purchase.
   */
  function balanceOf(uint256 round_, address beneficiary_) external view returns (uint256);

  /**
   * @return Balance of reward tokens by referral.
   * @param collateral_  collateral token.
   * @param beneficiary_  address of referral.
   */
  function rewardBalanceOf(address collateral_, address beneficiary_) external view returns (uint256);

  /**
   * @return Beneficiary KYC.
   * @param beneficiary_  address performing the token purchase.
   */
  function hasKycPass(address beneficiary_) external view returns (bool);

  /**
   * @return Max investment amount.
   */
  function getMaxInvestment() external view returns (uint256);

  /**
   * @return Min investment amount.
   */
  function getMinInvestment() external view returns (uint256);

  /**
   * @return Cap according to KYC.
   * @param beneficiary_  address performing the token purchase.
   */
  function capOf(address beneficiary_) external view returns (uint256);

  /**
   * @return Cap according to max investment.
   * @param beneficiary_  address performing the token purchase.
   */
  function maxCapOf(address beneficiary_) external view returns (uint256);

  /**
   * @return KYC cap.
   */
  function getKycCap() external view returns (uint256);

  /**
   * @dev Get default referral.
   */
  function getDefaultReferral() external view returns (uint256, uint256);

  /**
   * @dev Get referral.
   * @param beneficiary_  address performing the token purchase.
   * @param referral_ referral owner.
   */
  function getReferral(address beneficiary_, address referral_) external view returns (address referral);

  /**
   * @return Get referral reward.
   * @param referral_  referral owner.
   */
  function getReferralReward(address referral_) external view returns (uint256, uint256);

  /**
   * @return Address where funds are collected.
   */
  function getWallet() external view returns (address);
}// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;


interface IIdoStorageErrors {
  error ArrayParamsInvalidLengthErr();

  error IdoStartedErr();
  error IdoClosedErr();

  error WalletNullAddressErr(); 
  error RoundUndefinedErr(uint256 index_);
  error RoundStartedErr(uint256 index_);
  error RoundClosedErr(uint256 index_);
  error RoundInvalidSupplyErr(uint256 index_);

  error MinInvestmentErr(uint256 investment_, uint256 min_);
  error MaxInvestmentErr(uint256 investment_, uint256 max_);
  error KycCaptRangeErr(uint256 cap_, uint256 min_, uint256 max_);

  error MainReferralRewardErr(uint256 reward_);
  error SecondaryReferralRewardErr(uint256 reward_);

  error ReferralUndefinedErr(address referral_);
  error ReferralEnabledErr(address referral_);
  error ReferralDisabledErr(address referral_);

  error CollateralsUndefinedErr();

  error NativeTransferErr();
}// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import './IIdoStorageState.sol';


interface IIdoStorageEvents {
  event IdoStateUpdated(IIdoStorageState.State state);

  event RoundOpened(uint256 indexed index);
  event RoundClosed(uint256 indexed index);
  event RoundAdded(uint256 priceVestingShort, uint256 priceVestingLong, uint256 totalSupply);
  event RoundPriceUpdated(uint256 indexed index, uint256 priceVestingShort, uint256 priceVestingLong);
  event RoundSupplyUpdated(uint256 indexed index, uint256 totalSupply);

  event KycCapUpdated(uint256 cap);
  event KycPassUpdated(address indexed beneficiary, bool value);
  event MaxInvestmentUpdated(uint256 investment);
  event MinInvestmentUpdated(uint256 investment);
  event WalletUpdated(address indexed wallet);

  event DefaultReferralSetup(uint256 mainReferralReward, uint256 secondaryReferralReward);
  event ReferralSetup(address indexed referral, uint256 mainReward, uint256 secondaryReward);
  event ReferralEnabled(address indexed referral);
  event ReferralDisabled(address indexed referral);
  event ClaimedRewards(address indexed referral, address indexed collateral, uint256 amount);

  event ERC20Recovered(address token, uint256 amount);
  event NativeRecovered(uint256 amount);
}// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;


interface IIdoStorageState {
  enum State { None, Opened, Closed }
  enum Vesting { Short, Long }

  struct Round {
    bool defined;
    State state;
    uint256 priceVestingShort;
    uint256 priceVestingLong;
    uint256 tokensSold;
    uint256 totalSupply;
  }

  struct Referral {
    bool defined;
    bool enabled;
    uint256 mainReward;
    uint256 secondaryReward;
  }
}// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;


import './IdoStorage/IIdoStorageActions.sol';
import './IdoStorage/IIdoStorageErrors.sol';
import './IdoStorage/IIdoStorageEvents.sol';
import './IdoStorage/IIdoStorageState.sol';


interface IIdoStorage is IIdoStorageState, IIdoStorageActions, IIdoStorageEvents, IIdoStorageErrors  {
}// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import './LaunchpadErc20Ido/ILaunchpadErc20IdoActions.sol';
import './LaunchpadErc20Ido/ILaunchpadErc20IdoErrors.sol';
import './LaunchpadErc20Ido/ILaunchpadErc20IdoEvents.sol';
import './LaunchpadErc20Ido/ILaunchpadErc20IdoState.sol';
import './IIdoStorage.sol';


interface ILaunchpadErc20Ido is ILaunchpadErc20IdoActions, ILaunchpadErc20IdoErrors, ILaunchpadErc20IdoEvents, ILaunchpadErc20IdoState {
}// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import '../IdoStorage/IIdoStorageState.sol';


interface ILaunchpadErc20IdoActions {
  /**
   * @dev Method allows to purchase the tokens.
   * @param collateral_  collateral token.
   * @param investment_  collateral token investment.
   * @param vesting_  vesting of the investment.
   * @param referral_  referral owner.
   */
  function buyTokens(address collateral_, uint256 investment_, IIdoStorageState.Vesting vesting_, address referral_) external;

  /**
   * @dev Method allows to purchase the tokens.
   * @param collateral_  collateral token.
   * @param investment_  collateral token investment.
   * @param vesting_  vesting of the investment.
   * @param beneficiary_  address performing the token purchase.
   * @param referral_  referral owner.
   */
  function buyTokensFor(
    address collateral_,
    uint256 investment_,
    IIdoStorageState.Vesting vesting_,
    address beneficiary_,
    address referral_
  ) external;

  /**
   * @dev Allows to recover ERC20 from contract.
   * @param token_  ERC20 token address.
   * @param amount_  ERC20 token amount.
   */
  function recoverERC20(address token_, uint256 amount_) external;

  /**
   * @return True if token is collateral.
   * @param collateral_  addresses of the collateral token.
   */
  function isCollateral(address collateral_) external view returns (bool);

  /**
   * @return Address of the ido storage.
   */
  function getIdoStorage() external view returns (address);

  /**
   * @return Amount of collateral tokens raised.
   * @param collateral_  addresses of the collateral token.
   */
  function getRaised(address collateral_) external view returns (uint256);
}// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;


interface ILaunchpadErc20IdoErrors {
  error IdoClosedErr();
  error RoundClosedErr();

  error ExceededRoundAllocationErr();

  error BeneficiaryNullAddressErr();
  error InvestmentNullErr();
  error IvalidReferralErr();
  error MinInvestmentErr(uint256 investment_, uint256 min_);
  error MaxInvestmentErr(uint256 investment_, uint256 max_);

  error IdoStorageNullAddressErr();
  error CollateralNullAddressErr();
  error CollateralUndefinedErr();

  error NativeTransferErr();
}// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import '../IdoStorage/IIdoStorageState.sol';


interface ILaunchpadErc20IdoEvents {
  /**
   * Event for token purchase logging.
   * @param purchaser  who paid for the tokens.
   * @param collateral  collateral token used in the purchase.
   * @param referral  referral used in the purchase.
   * @param investment  collateral tokens paid for the purchase.
   * @param vesting  vesting of the investment.
   * @param tokensSold  amount of tokens purchased.
   * @param round  round of the purchase
   */
  event TokensPurchased(
    address indexed purchaser,
    address indexed collateral,
    address indexed referral,
    uint256 investment,
    IIdoStorageState.Vesting vesting,
    uint256 tokensSold,
    uint256 round
  );

  /**
   * Event for pause state update.
   * @param paused  new paused value.
   */
  event PausedUpdated(bool paused);

  event ERC20Recovered(address token, uint256 amount);
  event NativeRecovered(uint256 amount);
}// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;


interface ILaunchpadErc20IdoState {
  struct Collateral {
    bool defined;
    uint256 raised;
  }
}// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import '@openzeppelin/contracts/utils/Context.sol';
import '@openzeppelin/contracts/token/ERC20/IERC20.sol';
import '@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol';
import '@openzeppelin/contracts/token/ERC20/extensions/IERC20Metadata.sol';
import '@openzeppelin/contracts/access/AccessControl.sol';
import '@openzeppelin/contracts/security/ReentrancyGuard.sol';
import '@openzeppelin/contracts/utils/Address.sol';
import '@openzeppelin/contracts/security/Pausable.sol';
import './interfaces/IIdoStorage.sol';
import './interfaces/IdoStorage/IIdoStorageState.sol';
import './interfaces/ILaunchpadErc20Ido.sol';


/**
 * @title LaunchpadErc20Ido
 * @dev LaunchpadErc20Ido is a contract for managing token ido,
 * allowing investors to purchase the tokens with ERC20 collateral.
 */
contract LaunchpadErc20Ido is ILaunchpadErc20Ido, AccessControl, ReentrancyGuard, Pausable {
  using SafeERC20 for IERC20;
  using Address for address;
  bytes32 public constant WERT_ROLE = keccak256('WERT_ROLE');

  uint256 public constant TOKEN_DECIMALS = 18;
  uint256 public constant PRECISION = 10 ** 18;

  /// @notice Ido storage
  IIdoStorage private _idoStorage;

  /// @notice Collateral tokens used as a payment
  mapping(address => Collateral) private _collaterals;

  /**
   * @param idoStorage_  address where ido state is being store.
   * @param collaterals_  addresses of the collateral tokens.
   */
  constructor(address payable idoStorage_, address[] memory collaterals_) {
    if (idoStorage_ == address(0)) revert IdoStorageNullAddressErr();

    for(uint256 index = 0; index < collaterals_.length; index++) {
      if (collaterals_[index] == address(0)) revert CollateralNullAddressErr();
      _collaterals[collaterals_[index]] = Collateral({
        defined: true,
        raised: 0
      });
    }
    _idoStorage = IIdoStorage(idoStorage_);

    _setupRole(DEFAULT_ADMIN_ROLE, _msgSender());
  }

  /**
   * @dev Method allows to purchase the tokens
   * @param collateral_  addresses of the collateral token.
   * @param investment_  amount of collateral token investment.
   * @param vesting_  vesting of the investment.
   * @param referral_  referral owner.
   */
  function buyTokens(address collateral_, uint256 investment_, IIdoStorage.Vesting vesting_, address referral_)
    external
    nonReentrant()
  {
    address beneficiary = _msgSender();
    _preValidatePurchase(beneficiary, collateral_, investment_, vesting_, referral_, false);
    (address referral, uint256 mainReward, uint256 tokenReward) = _preProcessReferral(beneficiary, collateral_, referral_, vesting_, investment_);
    _processPurchase(beneficiary, collateral_, investment_, mainReward);
    // calculates token amount to be sold
    uint256 tokensSold = _getTokenAmount(collateral_, investment_, vesting_);
    _updatePurchasingState(beneficiary, collateral_, investment_, tokensSold, referral, mainReward, tokenReward);
    _postPurchase(beneficiary, collateral_, referral, investment_, vesting_, tokensSold);
  }

  function buyTokensFor(
    address collateral_,
    uint256 investment_,
    IIdoStorage.Vesting vesting_,
    address beneficiary_,
    address referral_
  )
    external
    nonReentrant()
    onlyRole(WERT_ROLE)
  {
    _preValidatePurchase(beneficiary_, collateral_, investment_, vesting_, referral_, true);
    (address referral, uint256 mainReward, uint256 tokenReward) = _preProcessReferral(beneficiary_, collateral_, referral_, vesting_, investment_);
    _processPurchase(_msgSender(), collateral_, investment_, mainReward);
    // calculates token amount to be sold
    uint256 tokensSold = _getTokenAmount(collateral_, investment_, vesting_);
    _updatePurchasingState(beneficiary_, collateral_, investment_, tokensSold, referral, mainReward, tokenReward);
    _postPurchase(beneficiary_, collateral_, referral, investment_, vesting_, tokensSold);
  }

  function pause() 
    external
    onlyRole(DEFAULT_ADMIN_ROLE)
  {
    _pause();
  }

  function unpause() 
    external
    onlyRole(DEFAULT_ADMIN_ROLE)
  {
    _unpause();
  }

  function recoverERC20(address token_, uint256 amount_)
    external
    onlyRole(DEFAULT_ADMIN_ROLE)
  {
    IERC20(token_).safeTransfer(_msgSender(), amount_);

    emit ERC20Recovered(token_, amount_);
  }

  function isCollateral(address collateral_)
    external
    view
    returns (bool)
  {
    return _collaterals[collateral_].defined;
  }

  function getIdoStorage()
    external
    view
    returns (address)
  {
    return address(_idoStorage);
  }

  function getRaised(address collateral_)
    external
    view
    returns (uint256)
  {
    return _collaterals[collateral_].raised;
  }

  /**
   * @dev Executed when a purchase has been validated and is ready to be executed. Doesn't necessarily emit/send
   * tokens.
   * @param beneficiary_  address performing the token purchase.
   * @param collateral_  addresses of the collateral token.
   * @param investment_  amount of collateral token investment.
   * @param reward_  referral bonus.
   */
  function _processPurchase(
    address beneficiary_,
    address collateral_,
    uint256 investment_,
    uint256 reward_
  )
    internal
  {
    // transfer collateral tokens to wallet
    uint256 investment = investment_ - reward_;
    address wallet = _idoStorage.getWallet();
    IERC20(collateral_).safeTransferFrom(beneficiary_, wallet, investment);

    // transfer collateral tokens to a storage
    if (reward_ > 0) {
      IERC20(collateral_).safeTransferFrom(beneficiary_, address(_idoStorage), reward_);
    }
  }

  /**
   * @dev Executed in order to update state of the purchase within ido.
   * @param beneficiary_  address performing the token purchase.
   * @param collateral_  addresses of the collateral token.
   * @param investment_  amount of collateral token investment.
   * @param tokensSold_  amount of purchased tokens.
   * @param referral_  referral owner.
   * @param mainReward_  referral main reward.
   * @param tokenReward_  referral token reward.
   */
  function _updatePurchasingState(
    address beneficiary_,
    address collateral_,
    uint256 investment_,
    uint256 tokensSold_,
    address referral_,
    uint256 mainReward_,
    uint256 tokenReward_
  )
    internal
  {
    _collaterals[collateral_].raised = _collaterals[collateral_].raised + investment_;
    uint256 decimals = IERC20Metadata(collateral_).decimals();
    uint256 normalizedAmount = (investment_ * PRECISION) / (10 ** decimals);
    _idoStorage.setPurchaseState(beneficiary_, collateral_, normalizedAmount, tokensSold_, referral_, mainReward_, tokenReward_);
  }

  /**
   * @dev Executed for the post purchase processing
   * @param beneficiary_  address performing the token purchase.
   * @param collateral_  addresses of the collateral token.
   * @param referral_  referral used in the purchase.
   * @param investment_  amount of collateral token investment.
   * @param vesting_  vesting option.
   * @param tokensSold_  amount of purchased tokens.
   */
  function _postPurchase(address beneficiary_, address collateral_, address referral_, uint256 investment_, IIdoStorage.Vesting vesting_, uint256 tokensSold_)
    internal
  {
    emit TokensPurchased(beneficiary_, collateral_, referral_, investment_, vesting_, tokensSold_, _idoStorage.getActiveRound());
  }

  /**
   * @dev Validation of the incoming purchase.
   * @param beneficiary_  address performing the token purchase.
   * @param collateral_  addresses of the collateral token.
   * @param investment_  amount of collateral token investment.
   * @param vesting_  vesting of the investment.
   * @param referral_  referral owner.
   * @param maxCap_  if beneficiary has max cap.
   */
  function _preValidatePurchase(address beneficiary_, address collateral_, uint256 investment_, IIdoStorage.Vesting vesting_, address referral_, bool maxCap_)
    internal
    whenNotPaused
    view
  {
    if (beneficiary_ == address(0)) revert BeneficiaryNullAddressErr();
    if (beneficiary_ == referral_) revert IvalidReferralErr();
    if (investment_ == 0) revert InvestmentNullErr();

    // validates if collateral supported
    if (!_collaterals[collateral_].defined) revert CollateralUndefinedErr();
    
    // validates if sale and round is open
    if (!_idoStorage.isOpened()) revert IdoClosedErr();
    uint256 activeRound = _idoStorage.getActiveRound();
    IIdoStorage.Round memory round = _idoStorage.getRound(activeRound);

    if (round.state != IIdoStorageState.State.Opened) revert RoundClosedErr();
    if (round.totalSupply < round.tokensSold + _getTokenAmount(collateral_, investment_, vesting_))
      revert ExceededRoundAllocationErr();

    // validates investment amount
    uint256 decimals = IERC20Metadata(collateral_).decimals();
    uint256 normalizedAmount = (investment_ * PRECISION) / (10 ** decimals);

    if (_idoStorage.getMinInvestment() > normalizedAmount) revert MinInvestmentErr(normalizedAmount, _idoStorage.getMinInvestment());
    uint256 cap = maxCap_ ? _idoStorage.maxCapOf(beneficiary_) : _idoStorage.capOf(beneficiary_);
    if (cap < normalizedAmount) revert MaxInvestmentErr(normalizedAmount, cap);
    
    this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
  }

  /**
   * @dev Returns referral data.
   * @param beneficiary_  address performing the token purchase.
   * @param collateral_  addresses of the collateral token.
   * @param referral_  referral owner.
   * @param vesting_  vesting of the investment.
   * @param investment_  amount of collateral token investment.
   */
  function _preProcessReferral(address beneficiary_, address collateral_, address referral_, IIdoStorage.Vesting vesting_, uint256 investment_)
    internal
    view
    returns (address, uint256, uint256)
  {
    address referral = _idoStorage.getReferral(beneficiary_, referral_);
    if (referral == address(0)) {
      return (referral, 0, 0);
    }
    (uint256 mainReward_, uint256 secondaryReward_) = _idoStorage.getReferralReward(referral);
    uint256 mainReward = investment_ * mainReward_ / 1000;
    uint256 secondaryReward = investment_ * secondaryReward_ / 1000;
    uint256 tokenReward = _getTokenAmount(collateral_, secondaryReward, vesting_);

    return (referral, mainReward, tokenReward);
  }

  /**
   * @return Amount of tokens that can be purchased with specified collateral investment.
   * @param collateral_  addresses of the collateral token.
   * @param investment_  amount of collateral token investment.
   * @param vesting_  vesting of the investment.
   */
  function _getTokenAmount(address collateral_, uint256 investment_, IIdoStorage.Vesting vesting_)
    internal
    view
    returns (uint256)
  {
    uint8 decimals = IERC20Metadata(collateral_).decimals();
    return (investment_ * 10 ** TOKEN_DECIMALS * PRECISION / 10 ** decimals) / _idoStorage.getPrice(vesting_);
  }
}