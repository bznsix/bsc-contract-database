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
// OpenZeppelin Contracts (last updated v4.9.3) (token/ERC20/utils/SafeERC20.sol)

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
     * non-reverting calls are assumed to be successful. Meant to be used with tokens that require the approval
     * to be set to zero before setting it to a non-zero value, such as USDT.
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
// OpenZeppelin Contracts (last updated v4.9.0) (utils/cryptography/ECDSA.sol)

pragma solidity ^0.8.0;

import "../Strings.sol";

/**
 * @dev Elliptic Curve Digital Signature Algorithm (ECDSA) operations.
 *
 * These functions can be used to verify that a message was signed by the holder
 * of the private keys of a given address.
 */
library ECDSA {
    enum RecoverError {
        NoError,
        InvalidSignature,
        InvalidSignatureLength,
        InvalidSignatureS,
        InvalidSignatureV // Deprecated in v4.8
    }

    function _throwError(RecoverError error) private pure {
        if (error == RecoverError.NoError) {
            return; // no error: do nothing
        } else if (error == RecoverError.InvalidSignature) {
            revert("ECDSA: invalid signature");
        } else if (error == RecoverError.InvalidSignatureLength) {
            revert("ECDSA: invalid signature length");
        } else if (error == RecoverError.InvalidSignatureS) {
            revert("ECDSA: invalid signature 's' value");
        }
    }

    /**
     * @dev Returns the address that signed a hashed message (`hash`) with
     * `signature` or error string. This address can then be used for verification purposes.
     *
     * The `ecrecover` EVM opcode allows for malleable (non-unique) signatures:
     * this function rejects them by requiring the `s` value to be in the lower
     * half order, and the `v` value to be either 27 or 28.
     *
     * IMPORTANT: `hash` _must_ be the result of a hash operation for the
     * verification to be secure: it is possible to craft signatures that
     * recover to arbitrary addresses for non-hashed data. A safe way to ensure
     * this is by receiving a hash of the original message (which may otherwise
     * be too long), and then calling {toEthSignedMessageHash} on it.
     *
     * Documentation for signature generation:
     * - with https://web3js.readthedocs.io/en/v1.3.4/web3-eth-accounts.html#sign[Web3.js]
     * - with https://docs.ethers.io/v5/api/signer/#Signer-signMessage[ethers]
     *
     * _Available since v4.3._
     */
    function tryRecover(bytes32 hash, bytes memory signature) internal pure returns (address, RecoverError) {
        if (signature.length == 65) {
            bytes32 r;
            bytes32 s;
            uint8 v;
            // ecrecover takes the signature parameters, and the only way to get them
            // currently is to use assembly.
            /// @solidity memory-safe-assembly
            assembly {
                r := mload(add(signature, 0x20))
                s := mload(add(signature, 0x40))
                v := byte(0, mload(add(signature, 0x60)))
            }
            return tryRecover(hash, v, r, s);
        } else {
            return (address(0), RecoverError.InvalidSignatureLength);
        }
    }

    /**
     * @dev Returns the address that signed a hashed message (`hash`) with
     * `signature`. This address can then be used for verification purposes.
     *
     * The `ecrecover` EVM opcode allows for malleable (non-unique) signatures:
     * this function rejects them by requiring the `s` value to be in the lower
     * half order, and the `v` value to be either 27 or 28.
     *
     * IMPORTANT: `hash` _must_ be the result of a hash operation for the
     * verification to be secure: it is possible to craft signatures that
     * recover to arbitrary addresses for non-hashed data. A safe way to ensure
     * this is by receiving a hash of the original message (which may otherwise
     * be too long), and then calling {toEthSignedMessageHash} on it.
     */
    function recover(bytes32 hash, bytes memory signature) internal pure returns (address) {
        (address recovered, RecoverError error) = tryRecover(hash, signature);
        _throwError(error);
        return recovered;
    }

    /**
     * @dev Overload of {ECDSA-tryRecover} that receives the `r` and `vs` short-signature fields separately.
     *
     * See https://eips.ethereum.org/EIPS/eip-2098[EIP-2098 short signatures]
     *
     * _Available since v4.3._
     */
    function tryRecover(bytes32 hash, bytes32 r, bytes32 vs) internal pure returns (address, RecoverError) {
        bytes32 s = vs & bytes32(0x7fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff);
        uint8 v = uint8((uint256(vs) >> 255) + 27);
        return tryRecover(hash, v, r, s);
    }

    /**
     * @dev Overload of {ECDSA-recover} that receives the `r and `vs` short-signature fields separately.
     *
     * _Available since v4.2._
     */
    function recover(bytes32 hash, bytes32 r, bytes32 vs) internal pure returns (address) {
        (address recovered, RecoverError error) = tryRecover(hash, r, vs);
        _throwError(error);
        return recovered;
    }

    /**
     * @dev Overload of {ECDSA-tryRecover} that receives the `v`,
     * `r` and `s` signature fields separately.
     *
     * _Available since v4.3._
     */
    function tryRecover(bytes32 hash, uint8 v, bytes32 r, bytes32 s) internal pure returns (address, RecoverError) {
        // EIP-2 still allows signature malleability for ecrecover(). Remove this possibility and make the signature
        // unique. Appendix F in the Ethereum Yellow paper (https://ethereum.github.io/yellowpaper/paper.pdf), defines
        // the valid range for s in (301): 0 < s < secp256k1n ÷ 2 + 1, and for v in (302): v ∈ {27, 28}. Most
        // signatures from current libraries generate a unique signature with an s-value in the lower half order.
        //
        // If your library generates malleable signatures, such as s-values in the upper range, calculate a new s-value
        // with 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFEBAAEDCE6AF48A03BBFD25E8CD0364141 - s1 and flip v from 27 to 28 or
        // vice versa. If your library also generates signatures with 0/1 for v instead 27/28, add 27 to v to accept
        // these malleable signatures as well.
        if (uint256(s) > 0x7FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF5D576E7357A4501DDFE92F46681B20A0) {
            return (address(0), RecoverError.InvalidSignatureS);
        }

        // If the signature is valid (and not malleable), return the signer address
        address signer = ecrecover(hash, v, r, s);
        if (signer == address(0)) {
            return (address(0), RecoverError.InvalidSignature);
        }

        return (signer, RecoverError.NoError);
    }

    /**
     * @dev Overload of {ECDSA-recover} that receives the `v`,
     * `r` and `s` signature fields separately.
     */
    function recover(bytes32 hash, uint8 v, bytes32 r, bytes32 s) internal pure returns (address) {
        (address recovered, RecoverError error) = tryRecover(hash, v, r, s);
        _throwError(error);
        return recovered;
    }

    /**
     * @dev Returns an Ethereum Signed Message, created from a `hash`. This
     * produces hash corresponding to the one signed with the
     * https://eth.wiki/json-rpc/API#eth_sign[`eth_sign`]
     * JSON-RPC method as part of EIP-191.
     *
     * See {recover}.
     */
    function toEthSignedMessageHash(bytes32 hash) internal pure returns (bytes32 message) {
        // 32 is the length in bytes of hash,
        // enforced by the type signature above
        /// @solidity memory-safe-assembly
        assembly {
            mstore(0x00, "\x19Ethereum Signed Message:\n32")
            mstore(0x1c, hash)
            message := keccak256(0x00, 0x3c)
        }
    }

    /**
     * @dev Returns an Ethereum Signed Message, created from `s`. This
     * produces hash corresponding to the one signed with the
     * https://eth.wiki/json-rpc/API#eth_sign[`eth_sign`]
     * JSON-RPC method as part of EIP-191.
     *
     * See {recover}.
     */
    function toEthSignedMessageHash(bytes memory s) internal pure returns (bytes32) {
        return keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n", Strings.toString(s.length), s));
    }

    /**
     * @dev Returns an Ethereum Signed Typed Data, created from a
     * `domainSeparator` and a `structHash`. This produces hash corresponding
     * to the one signed with the
     * https://eips.ethereum.org/EIPS/eip-712[`eth_signTypedData`]
     * JSON-RPC method as part of EIP-712.
     *
     * See {recover}.
     */
    function toTypedDataHash(bytes32 domainSeparator, bytes32 structHash) internal pure returns (bytes32 data) {
        /// @solidity memory-safe-assembly
        assembly {
            let ptr := mload(0x40)
            mstore(ptr, "\x19\x01")
            mstore(add(ptr, 0x02), domainSeparator)
            mstore(add(ptr, 0x22), structHash)
            data := keccak256(ptr, 0x42)
        }
    }

    /**
     * @dev Returns an Ethereum Signed Data with intended validator, created from a
     * `validator` and `data` according to the version 0 of EIP-191.
     *
     * See {recover}.
     */
    function toDataWithIntendedValidatorHash(address validator, bytes memory data) internal pure returns (bytes32) {
        return keccak256(abi.encodePacked("\x19\x00", validator, data));
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
// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity 0.8.19;

import "./IBanList.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract BanList is Ownable, IBanList {
    mapping(address => bool) public admins;

    mapping(address => bool) private _list;

    modifier restricted() {
        if (!admins[_msgSender()]) revert Unauthorized();
        _;
    }

    function ban(address user) external restricted {
        if (_list[user]) revert AlreadyBanned();
        _list[user] = true;
        emit UserBanned(user);
    }

    function unban(address user) external restricted {
        if (!_list[user]) revert NotBanned();
        _list[user] = false;
        emit UserUnbanned(user);
    }

    function setAdmin(address admin, bool isAdmin) external onlyOwner {
        if (admin == address(0)) revert ZeroAddress();
        _list[admin] = isAdmin;
        emit AdminSet(admin, isAdmin);
    }

    function isBanned(address user) external view returns (bool) {
        return _list[user];
    }

    function isNotBanned(address user) external view returns (bool) {
        return !_list[user];
    }

    function check(address user) external view {
        if (_list[user]) revert UserIsBanned();
    }
}
// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity 0.8.19;

interface IBanList {
    event UserBanned(address indexed user);
    event UserUnbanned(address indexed user);
    event AdminSet(address indexed admin, bool indexed isAdmin);

    error AlreadyBanned();
    error ZeroAddress();
    error NotBanned();
    error Unauthorized();
    error UserIsBanned();

    function isBanned(address user) external view returns (bool);

    function isNotBanned(address user) external view returns (bool);

    function check(address user) external view;
}
// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity 0.8.19;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

//        __                   __
//       / /   ___  ___  _____/ /_
//      / /   / _ \/ _ \/ ___/ __ \  Leech
//     / /___/  __/  __/ /__/ / / / Protocol
//    /_____/\___/\___/\___/_/ /_/ Router    __
//    / __ \_________  / /_____  _________  / /
//   / /_/ / ___/ __ \/ __/ __ \/ ___/ __ \/ /
//  / ____/ /  / /_/ / /_/ /_/ / /__/ /_/ / /
// /_/   /_/   \____/\__/\____/\___/\____/_/

/**
 * @title Leech Protocol router interface.
 * @notice The Router is the main protocol contract, for user interactions and protocol automatizations.
 * @author Leech Protocol (https://app.leechprotocol.com/).
 * @custom:version 1.0.
 * @custom:security Found vulnerability? Contact us and get reward!
 */
interface ILeechRouter {
    /**
     * @dev For crosschainWithdraw() to prevent "stack too deep" error.
     * @param poolId Selected pool ID.
     * @param token Withdrwalas token address. Filtering on the BE side.
     * @param shares Amount of withdrawal token.
     */
    struct XChain {
        uint16 poolId;
        IERC20 token;
        uint256 amount;
        uint256 maxBlockNumber;
        bytes signature;
    }

    /**
     * @dev Deposit into multi-pool params.
     * @param user User address.
     * @param poolId Selected pool ID.
     * @param depositToken Deposited token address.
     * @param amount Amount of deposited token.
     * @param data Additional pool data.
     */
    struct DepositMultiPool {
        address user;
        uint16 poolId;
        IERC20 depositToken;
        uint256 amount;
        uint256[] minAmounts;
        uint16 slippage;
        bytes data;
    }

    /**
     * @notice Finalize withdrawal params.
     * @param poolId Pool Id.
     * @param shares Amount in "want" token on strategy: LP or single token.
     * @param user User address.
     * @param tokenOut Withdrwalas token address. Filtering on the BE side.
     * @param targetChainId Chain ID of the network where the withdrawal requests was created.
     * @param data Additional parameters.
     */
    struct FinalizeWithdrawal {
        uint16 poolId;
        uint256 shares;
        address user;
        uint96 targetChainId;
        IERC20 tokenOut;
        uint256 minAmount;
        uint16 slippage;
        bytes data;
    }

    /// @dev Emit in cross-chain deposits.
    event BaseBridged(
        address user,
        uint256 amountOfBase,
        uint256 poolId,
        uint256 destinationChainId,
        uint256 fromChainId,
        address depositedToken
    );

    /// @dev Emit after deposit to the single pool.
    event DepositedSinglePool(
        address indexed user,
        uint256 indexed poolId,
        uint256 allocation,
        uint256 chainId,
        uint256 amount,
        address token
    );

    /// @dev Emit after deposit to the multi-pool.
    event DepositedMultiPool(
        address indexed user,
        uint256 indexed poolId,
        uint256 chainId,
        uint256 amount,
        address token
    );

    /// @dev Emit in request withdraw function to notify back-end.
    event WithdrawalRequested(
        address user,
        uint256 poolId,
        uint256 amount,
        uint256 chainId,
        address tokenOut
    );

    /// @dev Emit after completeing withdrawal requests.
    event WithdrawCompleted(
        address user,
        uint256 poolId,
        uint256 targetChainId,
        uint256 shares,
        uint256 wantAmount
    );

    /// @dev Emit after completeing cross-chain withdrawal requests.
    event CrosschainWithdrawCompleted(
        address user,
        uint256 poolId,
        uint256 targetChainId,
        uint256 shares,
        uint256 wantAmount
    );

    /// @dev Emit after cross-chain migration is completed.
    event FinalizedCrosschainMigration(
        uint256 poolId,
        uint256 strategyId,
        uint256 chainId
    );

    /// @dev Start migration. If migration is not cross-chain this event is complete.
    event Migration(uint256 poolId, uint256 strategyId, uint256 chainId);

    /// @dev Signature validator updated event.
    event ValidatorUpdated(address previous, address current);
    /// @dev Finalizer service address changed.
    event FinalizerUpdated(address previous, address current);
    /// @dev Router updated.
    event RouterUpdated(
        uint96 indexed chainId,
        address previous,
        address current
    );
    /// @dev Crosschain requests enebled or disabled.
    event CrosschainStatusChanged(bool isPaused);
    /// @dev When transporter updated.
    event TransporterUpdated(address previous, address current);
    /// @dev Rewarder contract changed.
    event RewarderUpdated(address previous, address current);
    /// @dev Withdraw delay changed.
    event WithdrawDelayChanged(uint16 previous, uint16 current);
    /// @dev Deposit token updated.
    event DepositTokenUpdated(
        address indexed token,
        uint256 previous,
        uint256 current
    );
    /// @dev When treasury updated.
    event TreasuryUpdated(address previous, address current);

    error ZeroAddress();
    error ZeroValue();
    error Banned();
    error NotBanned();
    error StrategyDisabled();
    error AmountTooLow();
    error AmountTooBig();
    error CrosschainError();
    error TransferFailed();
    error BadToken();
    error BadArray();
    error BadSignature();
    error BadAmount();
    error WithdrawDelay();
    error BadSlippage();
    error StoreUndefined();
    error Outdated();
    error WrongBlockchain();
    error WrongBridgeFees();
    error Unauthorized();
    error StoreAlreadyInitialized();
    error CrosschainPaused();
    error CrosschainUnpaused();
    error RewarderUndefined();

    // /**
    //  * @notice User deposit method.
    //  * @param poolId Selected pool ID.
    //  * @param depositToken Deposited token address.
    //  * @param amount Amount of deposited token.
    //  * @param data Additional pool data.
    //  */
    // function deposit(
    //     uint16 poolId,
    //     IERC20 depositToken,
    //     uint256 amount,
    //     bytes memory data
    // ) external;

    // /**
    //  * @notice User crosschain deposit method.
    //  * @param poolId Selected pool ID.
    //  * @param depositToken Deposited token address.
    //  * @param bridgedToken Token for the crosschain bridging.
    //  * @param amount Amount of deposited token.
    //  * @param isMultiPool Is deposit to multi-pool.
    //  */
    // function crosschainDeposit(
    //     uint16 poolId,
    //     IERC20 depositToken,
    //     IERC20 bridgedToken,
    //     uint256 amount,
    //     bool isMultiPool
    // ) external payable;

    // /**
    //  * @notice Withdraw from the pool.
    //  * @notice Due to the cross-chain architecture of the protocol, share prices are stored on the BE side.
    //  * @param poolId Selected pool ID.
    //  * @param tokenOut Withdrwalas token address. Filtering on the BE side.
    //  * @param shares Amount of withdrawal token.
    //  * @param data Additional data.
    //  */
    // function withdraw(
    //     uint16 poolId,
    //     IERC20 tokenOut,
    //     uint256 shares,
    //     bytes memory data
    // ) external;

    // /**
    //  * @notice After bridging completed we need to place tokens to farm.
    //  * @dev Used only to finalize cross-chain deposits.
    //  * @param user User address who performed a cross-chain deposit.
    //  * @param amount Amount of base token.
    //  * @param poolId Pool Id.
    //  * @param data Additional data.
    //  */
    // function finalizeDeposit(
    //     address user,
    //     uint256 amount,
    //     uint16 poolId,
    //     bytes memory data
    // ) external;

    // /**
    //  * @notice User creates crosschain withdrawal request.
    //  * @notice Due to the cross-chain architecture of the protocol, share prices are stored on the BE side.
    //  * @param poolId Selected pool ID.
    //  * @param tokenOut Withdrwalas token address. Filtering on the BE side.
    //  * @param shares Amount of withdrawal token.
    //  */
    // function crosschainWithdraw(
    //     uint16 poolId,
    //     IERC20 tokenOut,
    //     uint256 shares
    // ) external payable;

    // /**
    //  * @notice BE calls after WithdrawalRequested event was catched.
    //  * @notice Should be called on chain with active strategy
    //  * @param poolId Pool Id.
    //  * @param shares Amount in "want" token on strategy: LP or single token.
    //  * @param user User address.
    //  * @param tokenOut Withdrwalas token address. Filtering on the BE side.
    //  * @param targetChainId Chain ID of the network where the withdrawal requests was created.
    //  * @param data Additional parameters.
    //  */
    // function finalizeWithdrawal(
    //     uint16 poolId,
    //     uint256 shares,
    //     address user,
    //     IERC20 tokenOut,
    //     uint96 targetChainId,
    //     bytes memory data
    // ) external payable;

    // /**
    //  * @notice Calc potential withdraw amount from pool.
    //  * @param poolId ID of the pool.
    //  * @param shares Pool shares amount to withdraw.
    //  * @param token0toTokenOut May be used in some strategies.
    //  * @param token1toTokenOut May be used in some strategies.
    //  * @param data Additional params.
    //  * @return amountOut Amount converted from shares value to base token amount.
    //  */
    // function quotePotentialWithdraw(
    //     uint16 poolId,
    //     uint256 shares,
    //     address[] calldata token0toTokenOut,
    //     address[] calldata token1toTokenOut,
    //     bytes calldata data
    // ) external view returns (uint256 amountOut);

    // /**
    //  * @notice Base token of current router.
    //  * @return Address of the base token.
    //  */
    // function base() external view returns (address);
}
// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

interface ILeechTransporter {
    /**
     * @notice This function requires that `leechSwapper` is properly initialized
     * @param _destinationToken Address of the asset to be bridged
     * @param _bridgedAmount The amount of asset to send The ID of the destination chain to send to
     * @param _destinationChainId The ID of the destination chain to send to The address of the router on the destination chain
     * @param _destAddress The address on the destination chain
     */
    function bridgeOut(
        address _tokenIn,
        address _destinationToken,
        uint256 _bridgedAmount,
        uint256 _minAmount,
        uint256 _destinationChainId,
        address _destAddress
    ) external payable;
}
// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity 0.8.19;

interface IMultiPoolsStore {
    /// @dev Struct for the strategy instance.
    struct Strategy {
        address addr;
        uint256 withdrawalFee;
        uint16 poolShare;
        bool enabled;
    }

    /// @dev Struct for the pool instance.
    struct Pool {
        uint256 chainId; // 0 = disabled
        uint256 totalAllocation;
        Strategy[] strategies;
        mapping(address => User) user;
    }

    /// @dev Struct for the pool user.
    struct User {
        uint256 allocation;
        uint96 delayToBlock;
    }

    event RouterChanged(address oldRouter, address newRouter);

    error ZeroAddress();
    error Unauthorized();
    error PoolDisabled();
    error AmountTooBig();
    error HasNoRouter();
    error BadPoolShares(uint16 actualValue);

    function setPool(uint16 poolId, uint256 chainId, Strategy[] calldata strategies) external;

    function checkPoolShares(uint16 poolId) external view returns (bool);

    function isCrosschain(uint16 poolId) external view returns (bool);

    function getStrategies(
        uint16 poolId
    ) external view returns (Strategy[] memory);

    function getStrategyAddress(
        uint16 poolId,
        uint256 index
    ) external view returns (address);

    function getTotalAllocation(uint16 poolId) external view returns (uint256);

    function getBalance(
        uint16 poolId,
        uint256 index
    ) external view returns (uint256);

    function increaseAllocation(
        uint16 poolId,
        uint256 amount,
        address user,
        uint96 withdrawDelay
    ) external;

    function decreaseAllocation(
        uint16 poolId,
        uint256 amount,
        address user
    ) external;

    function getStrategyShare(
        uint16 poolId,
        uint256 index
    ) external view returns (uint16);

    function countStrategies(uint16 poolId) external view returns (uint256);

    function getChainId(uint16 poolId) external view returns (uint256);

    function getUserAllocation(
        uint16 poolId,
        address user
    ) external view returns (uint256);

    function isAbleForWithdraw(
        uint16 poolId,
        address user,
        uint256 shares
    ) external view returns (bool);

    function getWithdrawalFees(
        uint16 poolId,
        uint256 index
    ) external view returns (uint256);
}
// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity 0.8.19;

interface ISinglePoolsStore {
    /// @dev Struct for the pool instance.
    struct Pool {
        uint256 chainId; // 0 - disabled
        uint256 totalAllocation;
        uint256 withdrawalFee;
        address strategy;
        mapping(address => User) user;
    }

    /// @dev Struct for the pool user.
    struct User {
        uint256 allocation;
        uint96 delayToBlock;
    }

    event RouterChanged(address oldRouter, address newRouter);

    error ZeroAddress();
    error Unauthorized();
    error PoolDisabled();
    error AmountTooBig();
    error HasNoRouter();

    function isCrosschain(uint16 poolId) external view returns (bool);

    function getStrategyAddress(uint16 poolId) external view returns (address);

    function getTotalAllocation(uint16 poolId) external view returns (uint256);

    function getBalance(uint16 poolId) external view returns (uint256);

    function increaseAllocation(
        uint16 poolId,
        uint256 amount,
        address user,
        uint96 withdrawDelay
    ) external;

    function decreaseAllocation(
        uint16 poolId,
        uint256 amount,
        address user
    ) external;

    function getChainId(uint16 poolId) external view returns (uint256);

    function isAbleForWithdraw(
        uint16 poolId,
        address user
    ) external view returns (bool);

    function isEnoughtShares(
        uint16 poolId,
        address user,
        uint256 shares
    ) external view returns (bool);

    function getWithdrawalFees(uint16 poolId) external view returns (uint256);

    function getUserAllocation(
        uint16 poolId,
        address user
    ) external view returns (uint256);
}
// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity 0.8.19;

import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/security/Pausable.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";
import "./ILeechTransporter.sol";
import "../strategies/IBaseStrategy.sol";
import "./ILeechRouter.sol";
import "./ISinglePoolsStore.sol";
import "./IMultiPoolsStore.sol";
import "./BanList.sol";
import "./rewarder/IRewarder.sol";

//        __                   __
//       / /   ___  ___  _____/ /_
//      / /   / _ \/ _ \/ ___/ __ \  Leech
//     / /___/  __/  __/ /__/ / / / Protocol
//    /_____/\___/\___/\___/_/ /_/ Router    __
//    / __ \_________  / /_____  _________  / /
//   / /_/ / ___/ __ \/ __/ __ \/ ___/ __ \/ /
//  / ____/ /  / /_/ / /_/ /_/ / /__/ /_/ / /
// /_/   /_/   \____/\__/\____/\___/\____/_/

/**
 * @title Leech Protocol router contract.
 * @notice The Router is the main protocol contract, for user interactions and protocol automatizations.
 * @author Leech Protocol (https://app.leechprotocol.com/).
 * @custom:role DEFAULT_ADMIN_ROLE - Hihgly secured core team multisig for setting roles.
 * @custom:role ADMIN_ROLE - Core multisig for the protocol adjustments.
 * @custom:role PAUSER_ROLE - Security monitoring services.
 * @custom:role FINALIZER_ROLE - Crosschain finalizer service.
 * @custom:version 1.0.
 * @custom:security Found vulnerability? Contact us and get reward!
 */
contract LeechRouter is AccessControl, Pausable, ReentrancyGuard, ILeechRouter {
    /// @dev SafeERC20 library from OpenZeppelin.
    using SafeERC20 for IERC20;

    /// @dev OpenZeppelin's ECDSA library.
    using ECDSA for bytes32;

    /// @notice Admins multi-sig for protocol adjustments.
    bytes32 public constant ADMIN_ROLE = keccak256("ADMIN_ROLE");

    /// @notice Malicious actions observers.
    bytes32 public constant PAUSER_ROLE = keccak256("PAUSER_ROLE");

    /// @notice Crosschain finalizer service.
    bytes32 public constant FINALIZER_ROLE = keccak256("FINALIZER_ROLE");

    /// @notice Single strategy pools storage.
    ISinglePoolsStore public immutable singlePools;

    /// @notice Multi-strategy pools storage.
    IMultiPoolsStore public immutable multiPools;

    /// @notice Banned users storage.
    IBanList public immutable banList;

    /// @notice Rewarder contract
    IRewarder public rewarder;

    /// @notice Protocol fee receiver.
    address public treasury;

    /// @notice Signature validator.
    address public validator;

    /// @notice Crosschain finalizer receives bridge fees.
    address payable public finalizer;

    /// @notice Withdraw delay in blocks for security reasons.
    uint16 public withdrawDelay = 1000;

    /// @notice Pause crosschain requests from user.
    /// @dev For the protocol maintenace and upgrade.
    bool public crosschainPaused;

    /// @notice Bridge interface abstraction.
    ILeechTransporter public transporter;

    /// @notice base protocol stablecoin.
    IERC20 internal _baseToken;

    /// @notice Token minimal deposit amount.
    mapping(address => uint256) public depositMinAmount;

    /// @notice Mapping will return active router struct for the specific chain id.
    /// @dev chainId => LeechRouter.
    mapping(uint96 => address) public routers;

    /// @notice Modifier allows exlude banned addresses from execution, even if the valid signature exists.
    modifier enabled(address user) {
        _requireNotPaused();
        banList.check(user);
        if (address(singlePools) == address(0)) revert StoreUndefined();
        if (address(multiPools) == address(0)) revert StoreUndefined();
        if (address(rewarder) == address(0)) revert RewarderUndefined();
        _;
    }

    modifier allowCrosschain() {
        if (crosschainPaused) revert CrosschainPaused();
        _;
    }

    modifier crosschainIsPaused() {
        if (!crosschainPaused) revert CrosschainUnpaused();
        _;
    }

    /// @notice Grand access for two roles.
    modifier onlyRoles(bytes32 role1, bytes32 role2) {
        if (!hasRole(role1, msg.sender) && !hasRole(role2, msg.sender))
            revert Unauthorized();
        _;
    }

    /// @notice Prohibit zero address.
    /// @param checkAddr Address to check.
    modifier zeroAddr(address checkAddr) {
        if (checkAddr == address(0)) revert ZeroAddress();
        _;
    }

    /// @notice Prohibit zero amount.
    /// @param checkVal Value to check.
    modifier zeroVal(uint256 checkVal) {
        if (checkVal == 0) revert ZeroValue();
        _;
    }

    /// @notice Check deposit token for requirments.
    modifier checkDepositAmount(IERC20 depositToken, uint256 amount) {
        if (depositMinAmount[address(depositToken)] == 0) revert BadToken();
        if (amount < depositMinAmount[address(depositToken)])
            revert AmountTooLow();
        _;
    }

    /**
     * @notice Check msg.value for crosschain bridge fees.
     * @dev We are using TTL mechanism instead of storing bytes32 hashes. It's ok if user will use one signature
     * several times for the similar transactions until maxBlockNumber is reached.
     */
    modifier checkCrosschainMsgValue(XChain calldata data) {
        if (block.number > data.maxBlockNumber) revert Outdated();
        bytes32 msgHash = keccak256(
            abi.encode(
                msg.sender,
                address(data.token),
                data.amount,
                msg.value,
                data.maxBlockNumber,
                data.poolId,
                block.chainid
            )
        );
        if (
            msgHash.toEthSignedMessageHash().recover(data.signature) !=
            validator
        ) revert BadSignature();
        _;
    }

    /**
     * @notice Contract deployment params
     * @param __baseToken Base stablecoin.
     * @param _treasury Fees receiver.
     * @param _finalizer Crosschain finalizer service.
     * @param _validator Bridge fees validator.
     * @param _admin Admins team multisig.
     * @param _singlePools Single pools storage address.
     * @param _multiPools Multi-pools storage address.
     * @param _banList Banned users storage address.
     */
    constructor(
        IERC20 __baseToken,
        address _treasury,
        address _finalizer,
        address _validator,
        address _admin,
        ISinglePoolsStore _singlePools,
        IMultiPoolsStore _multiPools,
        IBanList _banList
    ) {
        // Check addresses
        if (
            _admin == address(0) ||
            _finalizer == address(0) ||
            _treasury == address(0) ||
            _validator == address(0) ||
            address(_singlePools) == address(0) ||
            address(_multiPools) == address(0) ||
            address(_banList) == address(0) ||
            address(__baseToken) == address(0)
        ) revert ZeroAddress();
        // Set roles
        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
        _grantRole(ADMIN_ROLE, _admin);
        _grantRole(FINALIZER_ROLE, _finalizer);
        // Set crosschain bridge service
        finalizer = payable(_finalizer);
        // Set the rest of params
        (_baseToken, treasury, validator, singlePools, multiPools, banList) = (
            __baseToken,
            _treasury,
            _validator,
            _singlePools,
            _multiPools,
            _banList
        );
    }

    ///////////////////////////////////////////////////////////////////////////
    //                              USERS  AREA                              //
    // ===================================================================== //
    //                                                                       //
    // Users can deposit and withdraw with functions below. This functions   //
    // can be unavailable in this cases:                                     //
    //  - Protocol on pause.                                                 //
    //  - Crosschain requests unavailable if crosschain on pause.            //
    //  - User is banned.                                                    //
    //  - This contract is depricated.                                       //
    //                                                                       //
    ///////////////////////////////////////////////////////////////////////////

    /**
     * @notice Deposit into single strategy pool.
     * @param poolId Selected pool ID.
     * @param depositToken Deposited token address.
     * @param amount Amount of deposited token.
     * @param data Additional pool data.
     */
    function deposit(
        uint16 poolId,
        IERC20 depositToken,
        uint256 amount,
        uint256 minAmount,
        uint16 slippage,
        bytes memory data
    ) external nonReentrant enabled(_msgSender()) {
        _deposit(_msgSender(), poolId, depositToken, amount, minAmount, slippage, data);
    }

    /**
     * @notice Deposit to the multi-pool.
     * @param poolId Selected pool ID.
     * @param depositToken Deposited token address.
     * @param amount Amount of deposited token.
     * @param data Additional pool data.
     */
    function depositMultiPool(
        uint16 poolId,
        IERC20 depositToken,
        uint256 amount,
        uint256[] calldata minAmounts,
        uint16 slippage,
        bytes memory data
    ) external nonReentrant enabled(_msgSender()) {
        DepositMultiPool memory depositData = DepositMultiPool(
            _msgSender(),
            poolId,
            depositToken,
            amount, 
            minAmounts,
            slippage,
            data
        );
        _depositMultiPool(depositData);
    }

    /**
     * @notice User crosschain deposit method.
     * @dev Function is payable to pay for the bridge.
     */
    function crosschainDeposit(
        XChain calldata data,
        IERC20 bridgedToken,
        bool isMultiPool,
        uint256 minAmount
    )
        external
        payable
        allowCrosschain
        nonReentrant
        enabled(msg.sender)
        checkDepositAmount(data.token, data.amount)
        checkCrosschainMsgValue(data)
    {
        // Check crosschain
        if (!isMultiPool && !singlePools.isCrosschain(data.poolId))
            revert CrosschainError();
        if (isMultiPool && !multiPools.isCrosschain(data.poolId))
            revert CrosschainError();
        // Get pool blockchain id
        uint256 chainId = isMultiPool
            ? multiPools.getChainId(data.poolId)
            : singlePools.getChainId(data.poolId);
        // Send tokens to the LeechTransporter
        data.token.safeTransferFrom(
            msg.sender,
            address(transporter),
            data.amount
        );
        // Bridge token (msg.value check on the bridge side)
        transporter.bridgeOut{value: msg.value}(
            address(data.token),
            address(bridgedToken),
            data.amount,
            minAmount,
            chainId,
            routers[uint96(chainId)]
        );
        // Notify watchers
        emit BaseBridged(
            msg.sender,
            data.amount,
            data.poolId,
            chainId,
            block.chainid,
            address(data.token)
        );
    }

    /**
     * @notice Withdraw from the single pool.
     * @param poolId Selected pool ID.
     * @param tokenOut Withdrwalas token address. Filtering on the BE side.
     * @param shares Amount of withdrawal token.
     * @param data Additional data.
     */
    function withdraw(
        uint16 poolId,
        IERC20 tokenOut,
        uint256 shares,
        uint256 minAmount,
        uint16 slippage,
        bytes memory data
    ) external nonReentrant {
        // Only in this blockchain
        if (singlePools.isCrosschain(poolId)) revert CrosschainError();
        // Check withdraw delay
        if (!singlePools.isAbleForWithdraw(poolId, msg.sender))
            revert WithdrawDelay();
        // Check shares amount
        if (!singlePools.isEnoughtShares(poolId, msg.sender, shares))
            revert AmountTooBig();
        // Get strategy
        IBaseStrategy strategy = IBaseStrategy(
            singlePools.getStrategyAddress(poolId)
        );
        // Withdraw from strategy
        uint256 amount = strategy.withdraw(
            poolId,
            (shares * strategy.allocationOf(poolId)) /
                singlePools.getTotalAllocation(poolId),
            tokenOut,
            minAmount,
            slippage,
            data
        );
        // Calc withdrawal fee
        amount -= _getFeesAndWithdraw(poolId, amount, msg.sender, shares);
        // Send token amount to the user
        tokenOut.safeTransfer(msg.sender, amount);
        // Notify services
        emit WithdrawCompleted(
            msg.sender,
            poolId,
            block.chainid,
            shares,
            amount
        );
    }

    /**
     * @notice Withdraw from the multi-pool.
     * @param poolId Selected pool ID.
     * @param tokenOut Withdrwalas token address. Filtering on the BE side.
     * @param shares Amount of withdrawal token.
     * @param minAmounts Minimal amounts for withdraw from strategies.
     * @param data Additional data.
     */
    function withdrawMultiPool(
        uint16 poolId,
        IERC20 tokenOut,
        uint256 shares,
        uint256[] calldata minAmounts,
        uint16 slippage,
        bytes memory data
    ) external nonReentrant {
        // Only in this blockchain
        if (multiPools.isCrosschain(poolId)) revert CrosschainError();
        // Check withdraw delay and shares amount
        if (!multiPools.isAbleForWithdraw(poolId, _msgSender(), shares))
            revert WithdrawDelay();
        // Withdraw from strategies
        (uint256 totalAmount, uint256 totalFees) = _withdrawFromMulti(
            poolId,
            tokenOut,
            shares,
            minAmounts,
            slippage,
            data
        );
        // Send fees to the protocol treasure
        tokenOut.safeTransfer(treasury, totalFees);
        // Send token amount to the user
        tokenOut.safeTransfer(_msgSender(), totalAmount);
        // Notify services
        emit WithdrawCompleted(
            _msgSender(),
            poolId,
            block.chainid,
            shares,
            totalAmount
        );
    }

    /**
     * @notice User creates crosschain withdrawal request.
     * @notice Due to the cross-chain architecture of the protocol, share prices are stored on the BE side.
     */
    function crosschainWithdraw(
        XChain calldata data
    )
        external
        payable
        allowCrosschain
        enabled(_msgSender())
        whenNotPaused
        zeroVal(data.amount)
        zeroAddr(address(data.token))
        checkCrosschainMsgValue(data)
    {
        // Transfer bridge fees to finalizer
        finalizer.transfer(msg.value);
        // Notify services
        emit WithdrawalRequested(
            _msgSender(),
            data.poolId,
            data.amount, // in shares
            block.chainid,
            address(data.token) // token out
        );
    }

    ///////////////////////////////////////////////////////////////////////////
    //                           FINALIZER SERVICE                           //
    // ===================================================================== //
    //                                                                       //
    // Only for crosschain finalizer services.                               //
    //                                                                       //
    ///////////////////////////////////////////////////////////////////////////

    /**
     * @notice After bridging completed we need to place tokens to farm.
     * @dev Used only to finalize cross-chain deposits.
     * @param user User address who performed a cross-chain deposit.
     * @param amount Amount of base token.
     * @param poolId Pool Id.
     * @param data Additional data.
     */
    function finalizeDeposit(
        address user,
        uint256 amount,
        uint16 poolId,
        uint256 minAmount,
        uint16 slippage,
        bytes memory data
    ) external nonReentrant onlyRole(FINALIZER_ROLE) zeroAddr(user) {
        _deposit(user, poolId, _baseToken, amount, minAmount, slippage, data);
    }

    /**
     * @notice After bridging completed we need to place tokens to farm.
     * @dev Used only to finalize cross-chain deposits.
     * @param user User address who performed a cross-chain deposit.
     * @param amount Amount of base token.
     * @param poolId Pool Id.
     * @param data Additional data.
     */
    function finalizeMultiPoolDeposit(
        address user,
        uint256 amount,
        uint16 poolId,
        uint256[] calldata minAmounts,
        uint16 slippage,
        bytes memory data
    ) external nonReentrant onlyRole(FINALIZER_ROLE) zeroAddr(user) {
        DepositMultiPool memory depositData = DepositMultiPool(
            user,
            poolId,
            _baseToken,
            amount,
            minAmounts,
            slippage,
            data
        );
        _depositMultiPool(depositData);
    }

    /**
     * @notice BE calls after WithdrawalRequested event was catched.
     * Should be called on chain with active strategy
     */
    function finalizeWithdrawal(
        FinalizeWithdrawal calldata data
    ) external nonReentrant onlyRole(FINALIZER_ROLE) {
        // Only current chain
        if (data.targetChainId != block.chainid) revert WrongBlockchain();
        // Get amount and fees
        uint256 amount = _finalizeWithdrawal(data);
        // Send token amount to the user
        _baseToken.safeTransfer(data.user, amount);
        // Notify services
        emit WithdrawCompleted(
            data.user,
            data.poolId,
            data.targetChainId,
            data.shares,
            amount
        );
    }

    /**
     * @notice Called by finalizer service after WithdrawalRequested event was catched and validated.
     * @dev Should be called on chain with active strategy.
     */
    function finalizeCrosschainWithdrawal(
        FinalizeWithdrawal calldata data
    ) external payable {
        // Only crosschain
        if (data.targetChainId == block.chainid) revert WrongBlockchain();
        // Get amount and fees
        uint256 amount = _finalizeWithdrawal(data);
        // If requested on another chain, use bridge
        _baseToken.safeTransfer(address(transporter), amount);
        // Send to transporter and bridge
        transporter.bridgeOut{value: msg.value}(
            base(),
            base(),
            amount,
            amount,
            data.targetChainId,
            data.user
        );
        // Notify services
        emit CrosschainWithdrawCompleted(
            data.user,
            data.poolId,
            data.targetChainId,
            data.shares,
            amount
        );
    }

    ///////////////////////////////////////////////////////////////////////////
    //                              PAUSE MODE                               //
    // ===================================================================== //
    //                                                                       //
    // This protocol has security observers. In case if malicious actions    //
    // happens, observers and admin team can pause deposits and withdrawals. //
    //                                                                       //
    // Also, admin team can put protocol on pause when doing maintenance or  //
    // contracts upgrade. Or current contract can be outdated and disabled.  //
    //                                                                       //
    ///////////////////////////////////////////////////////////////////////////

    /**
     * @notice Disable pause. Only admin team.
     * @dev Only admins multi-sig.
     */
    function unpause() external onlyRole(ADMIN_ROLE) {
        _unpause();
    }

    /**
     * @notice Pause mode ON.
     * @dev Only security observers and admin team can call this function.
     */
    function pause() external onlyRoles(ADMIN_ROLE, PAUSER_ROLE) {
        _pause();
    }

    /**
     * @notice Enable or disable crosschain requests from users.
     * @dev Services still can finalize existed requests.
     * We need this for router updates.
     * @param isCrosschainPaused True is pauseed, false unpaused.
     */
    function setCrosschainPaused(
        bool isCrosschainPaused
    ) external onlyRole(ADMIN_ROLE) {
        crosschainPaused = isCrosschainPaused;
        emit CrosschainStatusChanged(isCrosschainPaused);
    }

    ///////////////////////////////////////////////////////////////////////////
    //                                SETTERS                                //
    // ===================================================================== //
    //                                                                       //
    // Core team area. ADMIN_ROLE is the admins multi-sig.                   //
    //                                                                       //
    ///////////////////////////////////////////////////////////////////////////

    /**
     * @notice Finalizer setter.
     * @param newFinalizer New finalizer. Can't be zero address.
     */
    function setFinalizer(
        address payable newFinalizer
    ) external onlyRole(ADMIN_ROLE) whenPaused zeroAddr(newFinalizer) {
        emit FinalizerUpdated(finalizer, newFinalizer);
        finalizer = newFinalizer;
    }

    /**
     * @notice Update validator address.
     * @param newValidator New bridge fees amount validator.
     */
    function setValidator(
        address newValidator
    ) external onlyRole(ADMIN_ROLE) whenPaused zeroAddr(newValidator) {
        emit ValidatorUpdated(validator, newValidator);
        validator = newValidator;
    }

    /**
     * @notice Router setter.
     * @dev Crosschain requests should be on pause when updating or disabling routers,
     * because some crosschain transactions may be lost.
     * To disable blockchain set router to zero address.
     * Throws CrosschainPaused() custom error if crosschain requests is NOT on pause.
     * Check is all crosschain transactions are finalised before update routers.
     * @param chainId Chain Id.
     * @param router Address of the router.
     */
    function setRouter(
        uint96 chainId,
        address router
    ) external onlyRole(ADMIN_ROLE) crosschainIsPaused {
        emit RouterUpdated(chainId, routers[chainId], router);
        routers[chainId] = router;
    }

    /**
     * @notice Transporter setter.
     * @dev Should be invoked with special caution to prevent blocking cross-chain operations.
     * Throws CrosschainPaused() custom error if crosschain requests is NOT on pause.
     * Check is all crosschain transactions are finalised before update transporter.
     * @param newTransporter New transporter.
     */
    function setTransporter(
        address newTransporter
    )
        external
        onlyRole(ADMIN_ROLE)
        zeroAddr(newTransporter)
        crosschainIsPaused
    {
        emit TransporterUpdated(address(transporter), newTransporter);
        transporter = ILeechTransporter(newTransporter);
    }

    /**
     * @notice Function for disable and enable specific user.
     * @dev Throws CrosschainPaused() custom error if crosschain requests is NOT on pause.
     * Check is all crosschain transactions are finalised before update deposit token.
     * @param token Token address
     * @param minAmount Min amount of token with decimals. 0 to disable token.
     */
    function setDepositToken(
        address token,
        uint256 minAmount
    ) external onlyRole(ADMIN_ROLE) zeroAddr(token) crosschainIsPaused {
        emit DepositTokenUpdated(token, depositMinAmount[token], minAmount);
        depositMinAmount[token] = minAmount;
    }

    /**
     * @notice Set withdraw delay.
     * @dev Limit delay with 10000 blocks.
     * @param newDelay New delay in blocks.
     */
    function setWithdrawDelay(uint16 newDelay) external onlyRole(ADMIN_ROLE) {
        if (newDelay > 10000) revert BadAmount();
        emit WithdrawDelayChanged(withdrawDelay, newDelay);
        withdrawDelay = newDelay;
    }

    /**
     * @notice Change fees collector.
     * @dev Can't be zero address.
     * @param newTreasury New treasury address.
     */
    function setTreasury(
        address newTreasury
    ) external onlyRole(ADMIN_ROLE) zeroAddr(newTreasury) {
        emit TreasuryUpdated(treasury, newTreasury);
        treasury = newTreasury;
    }

    /**
     * @notice Change rewarder contract.
     * @dev Can't be zero address.
     * @param newRewarder New rewarder address.
     */
    function setRewarder(
        IRewarder newRewarder
    ) external onlyRole(ADMIN_ROLE) zeroAddr(address(newRewarder)) {
        emit RewarderUpdated(address(rewarder), address(newRewarder));
        rewarder = newRewarder;
    }

    ///////////////////////////////////////////////////////////////////////////
    //                                 VIEWS                                 //
    ///////////////////////////////////////////////////////////////////////////

    /**
     * @notice Calc potential withdraw amount from single pool.
     * @param poolId ID of the pool.
     * @param shares Pool shares amount to withdraw.
     * @param data Additional params.
     * @return amountOut Amount converted from shares value to base token amount.
     */
    function shareToAmountSP(
        uint16 poolId,
        uint256 shares,
        bytes calldata data
    ) external view returns (uint256 amountOut) {
        // Get strategy
        IBaseStrategy strategy = IBaseStrategy(
            singlePools.getStrategyAddress(poolId)
        );
        // Convert to the strategy shares
        uint256 withdrawAmount = (shares * strategy.allocationOf(poolId)) /
            singlePools.getTotalAllocation(poolId);
        // Get and return potential withdraw amount
        amountOut = strategy.shareToAmount(withdrawAmount, data);
    }

    /**
     * @notice Calc potential withdraw amount from multi-pool.
     * @param poolId ID of the pool.
     * @param shares Pool shares amount to withdraw.
     * @param data Additional params.
     * @return amountOut Amount converted from shares value to base token amount.
     */
    function shareToAmountMP(
        uint16 poolId,
        uint256 shares,
        bytes calldata data
    ) external view returns (uint256 amountOut) {
        // Get strategy
        for (uint256 i = 0; i < multiPools.countStrategies(poolId); i++) {
            IBaseStrategy strategy = IBaseStrategy(
                multiPools.getStrategyAddress(poolId, i)
            );
            // Get and return potential withdraw amount
            amountOut += strategy.shareToAmount(
                _calcShare(poolId, shares, strategy),
                data
            );
        }
    }

    /**
     * @notice Base token of current router.
     * @return Address of the base token.
     */
    function base() public view returns (address) {
        return address(_baseToken);
    }

    ///////////////////////////////////////////////////////////////////////////
    //                           INTERNAL  KITCHEN                           //
    ///////////////////////////////////////////////////////////////////////////

    /**
     * @notice Deposit into single pool.
     * @dev User should be not banned. Protocol should be unpaused. Single and multiple
     * pools storages must be setted.
     * Acceptable tokens amd min amounts should be setted by the core team.
     * @param user Address of the user.
     * @param poolId Selected pool ID.
     * @param token Deposited token address.
     * @param amount Amount of deposited token.
     * @param data Additional pool data.
     */
    function _deposit(
        address user,
        uint16 poolId,
        IERC20 token,
        uint256 amount,
        uint256 minAmount,
        uint16 slippage,
        bytes memory data
    ) internal checkDepositAmount(token, amount) {
        // Check crosschain
        if (singlePools.isCrosschain(poolId)) revert CrosschainError();
        // If current chain is active, deposit to strategy
        token.safeTransferFrom(
            user,
            singlePools.getStrategyAddress(poolId),
            amount
        );
        // Process deposit
        uint256 deposited = IBaseStrategy(
            singlePools.getStrategyAddress(poolId)
        ).deposit(poolId, token, minAmount, slippage, data);
        // Balance of LP before deposit
        uint256 initialBalance = singlePools.getBalance(poolId) - deposited;
        // Calc allocation points and normalize after migration
        if (
            singlePools.getTotalAllocation(poolId) != 0 && initialBalance != 0
        ) {
            deposited =
                (deposited * singlePools.getTotalAllocation(poolId)) /
                initialBalance;
        }
        // Increase allocation points
        singlePools.increaseAllocation(poolId, amount, user, withdrawDelay);
        // Notify watchers
        emit DepositedSinglePool(
            user,
            poolId,
            deposited,
            block.chainid,
            amount,
            address(token)
        );
        // Notify rewarder
        rewarder.setUserDeposit(user, poolId, amount, token);
    }

    /**
     * @notice Deposit to the multi-pool.
     * @param dmp Deposit params (user, poolId, depositToken, amount, data).
     */
    function _depositMultiPool(
        DepositMultiPool memory dmp
    )
        internal
        enabled(dmp.user)
        checkDepositAmount(dmp.depositToken, dmp.amount)
    {
        // Sholdn't be a crosschain deposit
        if (multiPools.isCrosschain(dmp.poolId)) revert CrosschainError();
        // Is pool ready?
        multiPools.checkPoolShares(dmp.poolId);
        // Initial denominator
        // IMultiPoolsStore.Strategy[] memory strategies = multiPools
        //     .getStrategies(dmp.poolId);
        // Deposit shares
        uint256 strategyShare;
        // To reduce token spending approvals we transfer deposit token here first
        dmp.depositToken.safeTransferFrom(dmp.user, address(this), dmp.amount);
        uint256 totalStrategies = multiPools.countStrategies(dmp.poolId);
        // Deposit into strategies
        for (uint256 i = 0; i < totalStrategies; i++) {
            address addr = multiPools.getStrategyAddress(dmp.poolId, i);
            uint256 poolShare = multiPools.getStrategyShare(dmp.poolId, i);
            // Transfer tokens into the strategy
            dmp.depositToken.safeTransfer(
                addr,
                (dmp.amount * poolShare) / 10000
            );
            // Proceed deposit
            uint256 deposited = IBaseStrategy(addr).deposit(
                dmp.poolId,
                dmp.depositToken,
                dmp.minAmounts[i],
                dmp.slippage,
                dmp.data
            );
            // Balance of LP before deposit
            uint256 initialBalance = multiPools.getBalance(dmp.poolId, i) -
                deposited;
            // Calc shares
            if (initialBalance != 0) {
                strategyShare +=
                    ((((deposited * 1e18) / initialBalance)) *
                        poolShare *
                        1e14) /
                    1e18;
            }
        }
        // Notify watchers here to reduce variables amount and prevent stack too deep error on coverage
        emit DepositedMultiPool(
            dmp.user,
            dmp.poolId,
            block.chainid,
            dmp.amount,
            address(dmp.depositToken)
        );
        // Calc allocation points and normalize after strategy migration
        if (multiPools.getTotalAllocation(dmp.poolId) != 0) {
            dmp.amount =
                (multiPools.getTotalAllocation(dmp.poolId) * strategyShare) /
                1e18;
        }
        // Store allocation points
        multiPools.increaseAllocation(
            dmp.poolId,
            dmp.amount,
            dmp.user,
            withdrawDelay
        );
        // Notify rewarder
        rewarder.setUserDeposit(dmp.user, dmp.poolId, dmp.amount, dmp.depositToken);
    }

    function _withdrawFromMulti(
        uint16 poolId,
        IERC20 tokenOut,
        uint256 shares,
        uint256[] calldata minAmounts,
        uint16 slippage,
        bytes memory data
    ) internal returns (uint256 totalAmount, uint256 totalFees) {
        if (minAmounts.length != multiPools.countStrategies(poolId))
            revert BadArray();
        for (uint256 i = 0; i < multiPools.countStrategies(poolId); i++) {
            // Get strategy
            IBaseStrategy strategy = IBaseStrategy(
                multiPools.getStrategyAddress(poolId, i)
            );
            // Withdraw from strategy
            uint256 amount = strategy.withdraw(
                poolId,
                _calcShare(poolId, shares, strategy),
                tokenOut,
                minAmounts[i],
                slippage,
                data
            );
            uint256 fees = (amount * multiPools.getWithdrawalFees(poolId, i)) /
                10000;
            totalFees += fees;
            totalAmount += amount - fees;
        }
        multiPools.decreaseAllocation(poolId, shares, _msgSender());
    }

    function _calcShare(
        uint16 poolId,
        uint256 shares,
        IBaseStrategy strategy
    ) internal view returns (uint256) {
        return
            (((shares * 1e18) / multiPools.getTotalAllocation(poolId)) *
                strategy.allocationOf(poolId)) / 1e18;
    }

    function _getFeesAndWithdraw(
        uint16 poolId,
        uint256 amount,
        address user,
        uint256 shares
    ) internal returns (uint256 withdrawFee) {
        withdrawFee = (amount * singlePools.getWithdrawalFees(poolId)) / 10000;
        // Reduce allocation points
        singlePools.decreaseAllocation(poolId, shares, user);
        // Transfer fees to the treasure
        if (withdrawFee != 0) _baseToken.safeTransfer(treasury, withdrawFee);
    }

    function _finalizeWithdrawal(
        FinalizeWithdrawal calldata fw
    )
        internal
        onlyRole(FINALIZER_ROLE)
        zeroVal(fw.shares)
        zeroAddr(address(fw.tokenOut))
        enabled(fw.user)
        returns (uint256 amount)
    {
        // Get strategy
        IBaseStrategy strategy = IBaseStrategy(
            singlePools.getStrategyAddress(fw.poolId)
        );
        // Withdraw from strategy
        amount = strategy.withdraw(
            fw.poolId,
            (fw.shares * strategy.allocationOf(fw.poolId)) /
                singlePools.getTotalAllocation(fw.poolId), // Convert to the strategy shares
            fw.tokenOut,
            fw.minAmount,
            fw.slippage,
            fw.data
        );
        // Calc withdrawal fee
        amount -= _getFeesAndWithdraw(
            fw.poolId,
            amount,
            fw.user,
            fw.shares
        );
    }
}
// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity 0.8.19;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

interface IRewarder {
    /// @dev Caller unauthorized.
    error Unauthorized();

    /// @dev Amount is zero.
    error ZeroAmount();

    /// @dev Address is zero.
    error ZeroAddress();

    /// @dev Wrong amount.
    error BadAmount();

    /// @dev Emit when a reward epoch is set for a pool
    event EpochSet(uint16 poolId);

    function setUserDeposit(
        address user,
        uint16 poolId,
        uint256 amount,
        IERC20 depositToken
    ) external;

    function setUserWithdraw(
        address user,
        uint16 poolId,
        uint256 amount,
        IERC20 withdrawToken
    ) external;

    function hasActiveRewards(
        uint16 poolId
    ) external view returns (bool hasRewards);
}
// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity 0.8.19;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

interface IBaseStrategy {
    /// @dev Universal instalation params.
    struct InstallParams {
        address controller;
        address router;
        address treasury;
        uint16 protocolFee;
        uint16 slippage;
    }

    /// @dev Emitted when reards get autocompounded.
    event Compounded(uint256 rewardAmount, uint256 fee);

    /// @dev Caller unauthorized.
    error Unauthorized();

    /// @dev Unexpected token address.
    error BadToken();

    /// @dev Strategy disabled.
    error NotActive();

    /// @dev Amount is zero.
    error ZeroAmount();

    /// @dev Address is zero.
    error ZeroAddress();

    /// @dev Protocol paused.
    error OnPause();

    /// @dev Slippage too big.
    error SlippageProtection();

    /// @dev Slippage percentage too big.
    error SlippageTooHigh();

    /// @dev Wrong amount.
    error BadAmount();

    /// @dev Strategy disabled.
    error StrategyDisabled();

    /// @dev Different size of arrays.
    error ArrayDifferentLength();

    /// @dev No rewards to claim.
    error NoRewardsAvailable();

    /// @dev Reentrancy detected.
    error Reentrancy();

    function balance() external view returns (uint256);

    function claimable()
        external
        view
        returns (address[] memory tokens, uint256[] memory amounts);

    function deposit(
        uint16 poolId,
        IERC20 depositToken,
        uint256 minAmount,
        uint16 slippage,
        bytes memory data
    ) external returns (uint256);

    function withdraw(
        uint16 poolId,
        uint256 shares,
        IERC20 tokenOut,
        uint256 minAmount,
        uint16 slippage,
        bytes memory data
    ) external returns (uint256);

    /**
     * @notice Move liquidity to another strategy.
     * @param pool Pool ID.
     * @param _slippage Slippage tolerance.
     * @param data Additional params.
     * @return amountOut Withdraw token amount.
     */
    function migrate(
        uint16 pool,
        uint16 _slippage,
        uint256 minAmount,
        bytes memory data
    ) external returns (uint256 amountOut);

    function autocompound(uint256, bytes memory) external;

    function shareToAmount(
        uint256 shares,
        bytes calldata data
    ) external view returns (uint256 amountOut);

    function allocationOf(uint16 poolId) external view returns (uint256);

    function totalAllocation() external view returns (uint256);
}