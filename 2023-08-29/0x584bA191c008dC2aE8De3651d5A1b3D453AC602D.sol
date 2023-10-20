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
// OpenZeppelin Contracts (last updated v4.9.0) (utils/structs/EnumerableMap.sol)
// This file was procedurally generated from scripts/generate/templates/EnumerableMap.js.

pragma solidity ^0.8.0;

import "./EnumerableSet.sol";

/**
 * @dev Library for managing an enumerable variant of Solidity's
 * https://solidity.readthedocs.io/en/latest/types.html#mapping-types[`mapping`]
 * type.
 *
 * Maps have the following properties:
 *
 * - Entries are added, removed, and checked for existence in constant time
 * (O(1)).
 * - Entries are enumerated in O(n). No guarantees are made on the ordering.
 *
 * ```solidity
 * contract Example {
 *     // Add the library methods
 *     using EnumerableMap for EnumerableMap.UintToAddressMap;
 *
 *     // Declare a set state variable
 *     EnumerableMap.UintToAddressMap private myMap;
 * }
 * ```
 *
 * The following map types are supported:
 *
 * - `uint256 -> address` (`UintToAddressMap`) since v3.0.0
 * - `address -> uint256` (`AddressToUintMap`) since v4.6.0
 * - `bytes32 -> bytes32` (`Bytes32ToBytes32Map`) since v4.6.0
 * - `uint256 -> uint256` (`UintToUintMap`) since v4.7.0
 * - `bytes32 -> uint256` (`Bytes32ToUintMap`) since v4.7.0
 *
 * [WARNING]
 * ====
 * Trying to delete such a structure from storage will likely result in data corruption, rendering the structure
 * unusable.
 * See https://github.com/ethereum/solidity/pull/11843[ethereum/solidity#11843] for more info.
 *
 * In order to clean an EnumerableMap, you can either remove all elements one by one or create a fresh instance using an
 * array of EnumerableMap.
 * ====
 */
library EnumerableMap {
    using EnumerableSet for EnumerableSet.Bytes32Set;

    // To implement this library for multiple types with as little code
    // repetition as possible, we write it in terms of a generic Map type with
    // bytes32 keys and values.
    // The Map implementation uses private functions, and user-facing
    // implementations (such as Uint256ToAddressMap) are just wrappers around
    // the underlying Map.
    // This means that we can only create new EnumerableMaps for types that fit
    // in bytes32.

    struct Bytes32ToBytes32Map {
        // Storage of keys
        EnumerableSet.Bytes32Set _keys;
        mapping(bytes32 => bytes32) _values;
    }

    /**
     * @dev Adds a key-value pair to a map, or updates the value for an existing
     * key. O(1).
     *
     * Returns true if the key was added to the map, that is if it was not
     * already present.
     */
    function set(Bytes32ToBytes32Map storage map, bytes32 key, bytes32 value) internal returns (bool) {
        map._values[key] = value;
        return map._keys.add(key);
    }

    /**
     * @dev Removes a key-value pair from a map. O(1).
     *
     * Returns true if the key was removed from the map, that is if it was present.
     */
    function remove(Bytes32ToBytes32Map storage map, bytes32 key) internal returns (bool) {
        delete map._values[key];
        return map._keys.remove(key);
    }

    /**
     * @dev Returns true if the key is in the map. O(1).
     */
    function contains(Bytes32ToBytes32Map storage map, bytes32 key) internal view returns (bool) {
        return map._keys.contains(key);
    }

    /**
     * @dev Returns the number of key-value pairs in the map. O(1).
     */
    function length(Bytes32ToBytes32Map storage map) internal view returns (uint256) {
        return map._keys.length();
    }

    /**
     * @dev Returns the key-value pair stored at position `index` in the map. O(1).
     *
     * Note that there are no guarantees on the ordering of entries inside the
     * array, and it may change when more entries are added or removed.
     *
     * Requirements:
     *
     * - `index` must be strictly less than {length}.
     */
    function at(Bytes32ToBytes32Map storage map, uint256 index) internal view returns (bytes32, bytes32) {
        bytes32 key = map._keys.at(index);
        return (key, map._values[key]);
    }

    /**
     * @dev Tries to returns the value associated with `key`. O(1).
     * Does not revert if `key` is not in the map.
     */
    function tryGet(Bytes32ToBytes32Map storage map, bytes32 key) internal view returns (bool, bytes32) {
        bytes32 value = map._values[key];
        if (value == bytes32(0)) {
            return (contains(map, key), bytes32(0));
        } else {
            return (true, value);
        }
    }

    /**
     * @dev Returns the value associated with `key`. O(1).
     *
     * Requirements:
     *
     * - `key` must be in the map.
     */
    function get(Bytes32ToBytes32Map storage map, bytes32 key) internal view returns (bytes32) {
        bytes32 value = map._values[key];
        require(value != 0 || contains(map, key), "EnumerableMap: nonexistent key");
        return value;
    }

    /**
     * @dev Same as {get}, with a custom error message when `key` is not in the map.
     *
     * CAUTION: This function is deprecated because it requires allocating memory for the error
     * message unnecessarily. For custom revert reasons use {tryGet}.
     */
    function get(
        Bytes32ToBytes32Map storage map,
        bytes32 key,
        string memory errorMessage
    ) internal view returns (bytes32) {
        bytes32 value = map._values[key];
        require(value != 0 || contains(map, key), errorMessage);
        return value;
    }

    /**
     * @dev Return the an array containing all the keys
     *
     * WARNING: This operation will copy the entire storage to memory, which can be quite expensive. This is designed
     * to mostly be used by view accessors that are queried without any gas fees. Developers should keep in mind that
     * this function has an unbounded cost, and using it as part of a state-changing function may render the function
     * uncallable if the map grows to a point where copying to memory consumes too much gas to fit in a block.
     */
    function keys(Bytes32ToBytes32Map storage map) internal view returns (bytes32[] memory) {
        return map._keys.values();
    }

    // UintToUintMap

    struct UintToUintMap {
        Bytes32ToBytes32Map _inner;
    }

    /**
     * @dev Adds a key-value pair to a map, or updates the value for an existing
     * key. O(1).
     *
     * Returns true if the key was added to the map, that is if it was not
     * already present.
     */
    function set(UintToUintMap storage map, uint256 key, uint256 value) internal returns (bool) {
        return set(map._inner, bytes32(key), bytes32(value));
    }

    /**
     * @dev Removes a value from a map. O(1).
     *
     * Returns true if the key was removed from the map, that is if it was present.
     */
    function remove(UintToUintMap storage map, uint256 key) internal returns (bool) {
        return remove(map._inner, bytes32(key));
    }

    /**
     * @dev Returns true if the key is in the map. O(1).
     */
    function contains(UintToUintMap storage map, uint256 key) internal view returns (bool) {
        return contains(map._inner, bytes32(key));
    }

    /**
     * @dev Returns the number of elements in the map. O(1).
     */
    function length(UintToUintMap storage map) internal view returns (uint256) {
        return length(map._inner);
    }

    /**
     * @dev Returns the element stored at position `index` in the map. O(1).
     * Note that there are no guarantees on the ordering of values inside the
     * array, and it may change when more values are added or removed.
     *
     * Requirements:
     *
     * - `index` must be strictly less than {length}.
     */
    function at(UintToUintMap storage map, uint256 index) internal view returns (uint256, uint256) {
        (bytes32 key, bytes32 value) = at(map._inner, index);
        return (uint256(key), uint256(value));
    }

    /**
     * @dev Tries to returns the value associated with `key`. O(1).
     * Does not revert if `key` is not in the map.
     */
    function tryGet(UintToUintMap storage map, uint256 key) internal view returns (bool, uint256) {
        (bool success, bytes32 value) = tryGet(map._inner, bytes32(key));
        return (success, uint256(value));
    }

    /**
     * @dev Returns the value associated with `key`. O(1).
     *
     * Requirements:
     *
     * - `key` must be in the map.
     */
    function get(UintToUintMap storage map, uint256 key) internal view returns (uint256) {
        return uint256(get(map._inner, bytes32(key)));
    }

    /**
     * @dev Same as {get}, with a custom error message when `key` is not in the map.
     *
     * CAUTION: This function is deprecated because it requires allocating memory for the error
     * message unnecessarily. For custom revert reasons use {tryGet}.
     */
    function get(UintToUintMap storage map, uint256 key, string memory errorMessage) internal view returns (uint256) {
        return uint256(get(map._inner, bytes32(key), errorMessage));
    }

    /**
     * @dev Return the an array containing all the keys
     *
     * WARNING: This operation will copy the entire storage to memory, which can be quite expensive. This is designed
     * to mostly be used by view accessors that are queried without any gas fees. Developers should keep in mind that
     * this function has an unbounded cost, and using it as part of a state-changing function may render the function
     * uncallable if the map grows to a point where copying to memory consumes too much gas to fit in a block.
     */
    function keys(UintToUintMap storage map) internal view returns (uint256[] memory) {
        bytes32[] memory store = keys(map._inner);
        uint256[] memory result;

        /// @solidity memory-safe-assembly
        assembly {
            result := store
        }

        return result;
    }

    // UintToAddressMap

    struct UintToAddressMap {
        Bytes32ToBytes32Map _inner;
    }

    /**
     * @dev Adds a key-value pair to a map, or updates the value for an existing
     * key. O(1).
     *
     * Returns true if the key was added to the map, that is if it was not
     * already present.
     */
    function set(UintToAddressMap storage map, uint256 key, address value) internal returns (bool) {
        return set(map._inner, bytes32(key), bytes32(uint256(uint160(value))));
    }

    /**
     * @dev Removes a value from a map. O(1).
     *
     * Returns true if the key was removed from the map, that is if it was present.
     */
    function remove(UintToAddressMap storage map, uint256 key) internal returns (bool) {
        return remove(map._inner, bytes32(key));
    }

    /**
     * @dev Returns true if the key is in the map. O(1).
     */
    function contains(UintToAddressMap storage map, uint256 key) internal view returns (bool) {
        return contains(map._inner, bytes32(key));
    }

    /**
     * @dev Returns the number of elements in the map. O(1).
     */
    function length(UintToAddressMap storage map) internal view returns (uint256) {
        return length(map._inner);
    }

    /**
     * @dev Returns the element stored at position `index` in the map. O(1).
     * Note that there are no guarantees on the ordering of values inside the
     * array, and it may change when more values are added or removed.
     *
     * Requirements:
     *
     * - `index` must be strictly less than {length}.
     */
    function at(UintToAddressMap storage map, uint256 index) internal view returns (uint256, address) {
        (bytes32 key, bytes32 value) = at(map._inner, index);
        return (uint256(key), address(uint160(uint256(value))));
    }

    /**
     * @dev Tries to returns the value associated with `key`. O(1).
     * Does not revert if `key` is not in the map.
     */
    function tryGet(UintToAddressMap storage map, uint256 key) internal view returns (bool, address) {
        (bool success, bytes32 value) = tryGet(map._inner, bytes32(key));
        return (success, address(uint160(uint256(value))));
    }

    /**
     * @dev Returns the value associated with `key`. O(1).
     *
     * Requirements:
     *
     * - `key` must be in the map.
     */
    function get(UintToAddressMap storage map, uint256 key) internal view returns (address) {
        return address(uint160(uint256(get(map._inner, bytes32(key)))));
    }

    /**
     * @dev Same as {get}, with a custom error message when `key` is not in the map.
     *
     * CAUTION: This function is deprecated because it requires allocating memory for the error
     * message unnecessarily. For custom revert reasons use {tryGet}.
     */
    function get(
        UintToAddressMap storage map,
        uint256 key,
        string memory errorMessage
    ) internal view returns (address) {
        return address(uint160(uint256(get(map._inner, bytes32(key), errorMessage))));
    }

    /**
     * @dev Return the an array containing all the keys
     *
     * WARNING: This operation will copy the entire storage to memory, which can be quite expensive. This is designed
     * to mostly be used by view accessors that are queried without any gas fees. Developers should keep in mind that
     * this function has an unbounded cost, and using it as part of a state-changing function may render the function
     * uncallable if the map grows to a point where copying to memory consumes too much gas to fit in a block.
     */
    function keys(UintToAddressMap storage map) internal view returns (uint256[] memory) {
        bytes32[] memory store = keys(map._inner);
        uint256[] memory result;

        /// @solidity memory-safe-assembly
        assembly {
            result := store
        }

        return result;
    }

    // AddressToUintMap

    struct AddressToUintMap {
        Bytes32ToBytes32Map _inner;
    }

    /**
     * @dev Adds a key-value pair to a map, or updates the value for an existing
     * key. O(1).
     *
     * Returns true if the key was added to the map, that is if it was not
     * already present.
     */
    function set(AddressToUintMap storage map, address key, uint256 value) internal returns (bool) {
        return set(map._inner, bytes32(uint256(uint160(key))), bytes32(value));
    }

    /**
     * @dev Removes a value from a map. O(1).
     *
     * Returns true if the key was removed from the map, that is if it was present.
     */
    function remove(AddressToUintMap storage map, address key) internal returns (bool) {
        return remove(map._inner, bytes32(uint256(uint160(key))));
    }

    /**
     * @dev Returns true if the key is in the map. O(1).
     */
    function contains(AddressToUintMap storage map, address key) internal view returns (bool) {
        return contains(map._inner, bytes32(uint256(uint160(key))));
    }

    /**
     * @dev Returns the number of elements in the map. O(1).
     */
    function length(AddressToUintMap storage map) internal view returns (uint256) {
        return length(map._inner);
    }

    /**
     * @dev Returns the element stored at position `index` in the map. O(1).
     * Note that there are no guarantees on the ordering of values inside the
     * array, and it may change when more values are added or removed.
     *
     * Requirements:
     *
     * - `index` must be strictly less than {length}.
     */
    function at(AddressToUintMap storage map, uint256 index) internal view returns (address, uint256) {
        (bytes32 key, bytes32 value) = at(map._inner, index);
        return (address(uint160(uint256(key))), uint256(value));
    }

    /**
     * @dev Tries to returns the value associated with `key`. O(1).
     * Does not revert if `key` is not in the map.
     */
    function tryGet(AddressToUintMap storage map, address key) internal view returns (bool, uint256) {
        (bool success, bytes32 value) = tryGet(map._inner, bytes32(uint256(uint160(key))));
        return (success, uint256(value));
    }

    /**
     * @dev Returns the value associated with `key`. O(1).
     *
     * Requirements:
     *
     * - `key` must be in the map.
     */
    function get(AddressToUintMap storage map, address key) internal view returns (uint256) {
        return uint256(get(map._inner, bytes32(uint256(uint160(key)))));
    }

    /**
     * @dev Same as {get}, with a custom error message when `key` is not in the map.
     *
     * CAUTION: This function is deprecated because it requires allocating memory for the error
     * message unnecessarily. For custom revert reasons use {tryGet}.
     */
    function get(
        AddressToUintMap storage map,
        address key,
        string memory errorMessage
    ) internal view returns (uint256) {
        return uint256(get(map._inner, bytes32(uint256(uint160(key))), errorMessage));
    }

    /**
     * @dev Return the an array containing all the keys
     *
     * WARNING: This operation will copy the entire storage to memory, which can be quite expensive. This is designed
     * to mostly be used by view accessors that are queried without any gas fees. Developers should keep in mind that
     * this function has an unbounded cost, and using it as part of a state-changing function may render the function
     * uncallable if the map grows to a point where copying to memory consumes too much gas to fit in a block.
     */
    function keys(AddressToUintMap storage map) internal view returns (address[] memory) {
        bytes32[] memory store = keys(map._inner);
        address[] memory result;

        /// @solidity memory-safe-assembly
        assembly {
            result := store
        }

        return result;
    }

    // Bytes32ToUintMap

    struct Bytes32ToUintMap {
        Bytes32ToBytes32Map _inner;
    }

    /**
     * @dev Adds a key-value pair to a map, or updates the value for an existing
     * key. O(1).
     *
     * Returns true if the key was added to the map, that is if it was not
     * already present.
     */
    function set(Bytes32ToUintMap storage map, bytes32 key, uint256 value) internal returns (bool) {
        return set(map._inner, key, bytes32(value));
    }

    /**
     * @dev Removes a value from a map. O(1).
     *
     * Returns true if the key was removed from the map, that is if it was present.
     */
    function remove(Bytes32ToUintMap storage map, bytes32 key) internal returns (bool) {
        return remove(map._inner, key);
    }

    /**
     * @dev Returns true if the key is in the map. O(1).
     */
    function contains(Bytes32ToUintMap storage map, bytes32 key) internal view returns (bool) {
        return contains(map._inner, key);
    }

    /**
     * @dev Returns the number of elements in the map. O(1).
     */
    function length(Bytes32ToUintMap storage map) internal view returns (uint256) {
        return length(map._inner);
    }

    /**
     * @dev Returns the element stored at position `index` in the map. O(1).
     * Note that there are no guarantees on the ordering of values inside the
     * array, and it may change when more values are added or removed.
     *
     * Requirements:
     *
     * - `index` must be strictly less than {length}.
     */
    function at(Bytes32ToUintMap storage map, uint256 index) internal view returns (bytes32, uint256) {
        (bytes32 key, bytes32 value) = at(map._inner, index);
        return (key, uint256(value));
    }

    /**
     * @dev Tries to returns the value associated with `key`. O(1).
     * Does not revert if `key` is not in the map.
     */
    function tryGet(Bytes32ToUintMap storage map, bytes32 key) internal view returns (bool, uint256) {
        (bool success, bytes32 value) = tryGet(map._inner, key);
        return (success, uint256(value));
    }

    /**
     * @dev Returns the value associated with `key`. O(1).
     *
     * Requirements:
     *
     * - `key` must be in the map.
     */
    function get(Bytes32ToUintMap storage map, bytes32 key) internal view returns (uint256) {
        return uint256(get(map._inner, key));
    }

    /**
     * @dev Same as {get}, with a custom error message when `key` is not in the map.
     *
     * CAUTION: This function is deprecated because it requires allocating memory for the error
     * message unnecessarily. For custom revert reasons use {tryGet}.
     */
    function get(
        Bytes32ToUintMap storage map,
        bytes32 key,
        string memory errorMessage
    ) internal view returns (uint256) {
        return uint256(get(map._inner, key, errorMessage));
    }

    /**
     * @dev Return the an array containing all the keys
     *
     * WARNING: This operation will copy the entire storage to memory, which can be quite expensive. This is designed
     * to mostly be used by view accessors that are queried without any gas fees. Developers should keep in mind that
     * this function has an unbounded cost, and using it as part of a state-changing function may render the function
     * uncallable if the map grows to a point where copying to memory consumes too much gas to fit in a block.
     */
    function keys(Bytes32ToUintMap storage map) internal view returns (bytes32[] memory) {
        bytes32[] memory store = keys(map._inner);
        bytes32[] memory result;

        /// @solidity memory-safe-assembly
        assembly {
            result := store
        }

        return result;
    }
}
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.9.0) (utils/structs/EnumerableSet.sol)
// This file was procedurally generated from scripts/generate/templates/EnumerableSet.js.

pragma solidity ^0.8.0;

/**
 * @dev Library for managing
 * https://en.wikipedia.org/wiki/Set_(abstract_data_type)[sets] of primitive
 * types.
 *
 * Sets have the following properties:
 *
 * - Elements are added, removed, and checked for existence in constant time
 * (O(1)).
 * - Elements are enumerated in O(n). No guarantees are made on the ordering.
 *
 * ```solidity
 * contract Example {
 *     // Add the library methods
 *     using EnumerableSet for EnumerableSet.AddressSet;
 *
 *     // Declare a set state variable
 *     EnumerableSet.AddressSet private mySet;
 * }
 * ```
 *
 * As of v3.3.0, sets of type `bytes32` (`Bytes32Set`), `address` (`AddressSet`)
 * and `uint256` (`UintSet`) are supported.
 *
 * [WARNING]
 * ====
 * Trying to delete such a structure from storage will likely result in data corruption, rendering the structure
 * unusable.
 * See https://github.com/ethereum/solidity/pull/11843[ethereum/solidity#11843] for more info.
 *
 * In order to clean an EnumerableSet, you can either remove all elements one by one or create a fresh instance using an
 * array of EnumerableSet.
 * ====
 */
library EnumerableSet {
    // To implement this library for multiple types with as little code
    // repetition as possible, we write it in terms of a generic Set type with
    // bytes32 values.
    // The Set implementation uses private functions, and user-facing
    // implementations (such as AddressSet) are just wrappers around the
    // underlying Set.
    // This means that we can only create new EnumerableSets for types that fit
    // in bytes32.

    struct Set {
        // Storage of set values
        bytes32[] _values;
        // Position of the value in the `values` array, plus 1 because index 0
        // means a value is not in the set.
        mapping(bytes32 => uint256) _indexes;
    }

    /**
     * @dev Add a value to a set. O(1).
     *
     * Returns true if the value was added to the set, that is if it was not
     * already present.
     */
    function _add(Set storage set, bytes32 value) private returns (bool) {
        if (!_contains(set, value)) {
            set._values.push(value);
            // The value is stored at length-1, but we add 1 to all indexes
            // and use 0 as a sentinel value
            set._indexes[value] = set._values.length;
            return true;
        } else {
            return false;
        }
    }

    /**
     * @dev Removes a value from a set. O(1).
     *
     * Returns true if the value was removed from the set, that is if it was
     * present.
     */
    function _remove(Set storage set, bytes32 value) private returns (bool) {
        // We read and store the value's index to prevent multiple reads from the same storage slot
        uint256 valueIndex = set._indexes[value];

        if (valueIndex != 0) {
            // Equivalent to contains(set, value)
            // To delete an element from the _values array in O(1), we swap the element to delete with the last one in
            // the array, and then remove the last element (sometimes called as 'swap and pop').
            // This modifies the order of the array, as noted in {at}.

            uint256 toDeleteIndex = valueIndex - 1;
            uint256 lastIndex = set._values.length - 1;

            if (lastIndex != toDeleteIndex) {
                bytes32 lastValue = set._values[lastIndex];

                // Move the last value to the index where the value to delete is
                set._values[toDeleteIndex] = lastValue;
                // Update the index for the moved value
                set._indexes[lastValue] = valueIndex; // Replace lastValue's index to valueIndex
            }

            // Delete the slot where the moved value was stored
            set._values.pop();

            // Delete the index for the deleted slot
            delete set._indexes[value];

            return true;
        } else {
            return false;
        }
    }

    /**
     * @dev Returns true if the value is in the set. O(1).
     */
    function _contains(Set storage set, bytes32 value) private view returns (bool) {
        return set._indexes[value] != 0;
    }

    /**
     * @dev Returns the number of values on the set. O(1).
     */
    function _length(Set storage set) private view returns (uint256) {
        return set._values.length;
    }

    /**
     * @dev Returns the value stored at position `index` in the set. O(1).
     *
     * Note that there are no guarantees on the ordering of values inside the
     * array, and it may change when more values are added or removed.
     *
     * Requirements:
     *
     * - `index` must be strictly less than {length}.
     */
    function _at(Set storage set, uint256 index) private view returns (bytes32) {
        return set._values[index];
    }

    /**
     * @dev Return the entire set in an array
     *
     * WARNING: This operation will copy the entire storage to memory, which can be quite expensive. This is designed
     * to mostly be used by view accessors that are queried without any gas fees. Developers should keep in mind that
     * this function has an unbounded cost, and using it as part of a state-changing function may render the function
     * uncallable if the set grows to a point where copying to memory consumes too much gas to fit in a block.
     */
    function _values(Set storage set) private view returns (bytes32[] memory) {
        return set._values;
    }

    // Bytes32Set

    struct Bytes32Set {
        Set _inner;
    }

    /**
     * @dev Add a value to a set. O(1).
     *
     * Returns true if the value was added to the set, that is if it was not
     * already present.
     */
    function add(Bytes32Set storage set, bytes32 value) internal returns (bool) {
        return _add(set._inner, value);
    }

    /**
     * @dev Removes a value from a set. O(1).
     *
     * Returns true if the value was removed from the set, that is if it was
     * present.
     */
    function remove(Bytes32Set storage set, bytes32 value) internal returns (bool) {
        return _remove(set._inner, value);
    }

    /**
     * @dev Returns true if the value is in the set. O(1).
     */
    function contains(Bytes32Set storage set, bytes32 value) internal view returns (bool) {
        return _contains(set._inner, value);
    }

    /**
     * @dev Returns the number of values in the set. O(1).
     */
    function length(Bytes32Set storage set) internal view returns (uint256) {
        return _length(set._inner);
    }

    /**
     * @dev Returns the value stored at position `index` in the set. O(1).
     *
     * Note that there are no guarantees on the ordering of values inside the
     * array, and it may change when more values are added or removed.
     *
     * Requirements:
     *
     * - `index` must be strictly less than {length}.
     */
    function at(Bytes32Set storage set, uint256 index) internal view returns (bytes32) {
        return _at(set._inner, index);
    }

    /**
     * @dev Return the entire set in an array
     *
     * WARNING: This operation will copy the entire storage to memory, which can be quite expensive. This is designed
     * to mostly be used by view accessors that are queried without any gas fees. Developers should keep in mind that
     * this function has an unbounded cost, and using it as part of a state-changing function may render the function
     * uncallable if the set grows to a point where copying to memory consumes too much gas to fit in a block.
     */
    function values(Bytes32Set storage set) internal view returns (bytes32[] memory) {
        bytes32[] memory store = _values(set._inner);
        bytes32[] memory result;

        /// @solidity memory-safe-assembly
        assembly {
            result := store
        }

        return result;
    }

    // AddressSet

    struct AddressSet {
        Set _inner;
    }

    /**
     * @dev Add a value to a set. O(1).
     *
     * Returns true if the value was added to the set, that is if it was not
     * already present.
     */
    function add(AddressSet storage set, address value) internal returns (bool) {
        return _add(set._inner, bytes32(uint256(uint160(value))));
    }

    /**
     * @dev Removes a value from a set. O(1).
     *
     * Returns true if the value was removed from the set, that is if it was
     * present.
     */
    function remove(AddressSet storage set, address value) internal returns (bool) {
        return _remove(set._inner, bytes32(uint256(uint160(value))));
    }

    /**
     * @dev Returns true if the value is in the set. O(1).
     */
    function contains(AddressSet storage set, address value) internal view returns (bool) {
        return _contains(set._inner, bytes32(uint256(uint160(value))));
    }

    /**
     * @dev Returns the number of values in the set. O(1).
     */
    function length(AddressSet storage set) internal view returns (uint256) {
        return _length(set._inner);
    }

    /**
     * @dev Returns the value stored at position `index` in the set. O(1).
     *
     * Note that there are no guarantees on the ordering of values inside the
     * array, and it may change when more values are added or removed.
     *
     * Requirements:
     *
     * - `index` must be strictly less than {length}.
     */
    function at(AddressSet storage set, uint256 index) internal view returns (address) {
        return address(uint160(uint256(_at(set._inner, index))));
    }

    /**
     * @dev Return the entire set in an array
     *
     * WARNING: This operation will copy the entire storage to memory, which can be quite expensive. This is designed
     * to mostly be used by view accessors that are queried without any gas fees. Developers should keep in mind that
     * this function has an unbounded cost, and using it as part of a state-changing function may render the function
     * uncallable if the set grows to a point where copying to memory consumes too much gas to fit in a block.
     */
    function values(AddressSet storage set) internal view returns (address[] memory) {
        bytes32[] memory store = _values(set._inner);
        address[] memory result;

        /// @solidity memory-safe-assembly
        assembly {
            result := store
        }

        return result;
    }

    // UintSet

    struct UintSet {
        Set _inner;
    }

    /**
     * @dev Add a value to a set. O(1).
     *
     * Returns true if the value was added to the set, that is if it was not
     * already present.
     */
    function add(UintSet storage set, uint256 value) internal returns (bool) {
        return _add(set._inner, bytes32(value));
    }

    /**
     * @dev Removes a value from a set. O(1).
     *
     * Returns true if the value was removed from the set, that is if it was
     * present.
     */
    function remove(UintSet storage set, uint256 value) internal returns (bool) {
        return _remove(set._inner, bytes32(value));
    }

    /**
     * @dev Returns true if the value is in the set. O(1).
     */
    function contains(UintSet storage set, uint256 value) internal view returns (bool) {
        return _contains(set._inner, bytes32(value));
    }

    /**
     * @dev Returns the number of values in the set. O(1).
     */
    function length(UintSet storage set) internal view returns (uint256) {
        return _length(set._inner);
    }

    /**
     * @dev Returns the value stored at position `index` in the set. O(1).
     *
     * Note that there are no guarantees on the ordering of values inside the
     * array, and it may change when more values are added or removed.
     *
     * Requirements:
     *
     * - `index` must be strictly less than {length}.
     */
    function at(UintSet storage set, uint256 index) internal view returns (uint256) {
        return uint256(_at(set._inner, index));
    }

    /**
     * @dev Return the entire set in an array
     *
     * WARNING: This operation will copy the entire storage to memory, which can be quite expensive. This is designed
     * to mostly be used by view accessors that are queried without any gas fees. Developers should keep in mind that
     * this function has an unbounded cost, and using it as part of a state-changing function may render the function
     * uncallable if the set grows to a point where copying to memory consumes too much gas to fit in a block.
     */
    function values(UintSet storage set) internal view returns (uint256[] memory) {
        bytes32[] memory store = _values(set._inner);
        uint256[] memory result;

        /// @solidity memory-safe-assembly
        assembly {
            result := store
        }

        return result;
    }
}
//SPDX-License-Identifier: MIT

pragma solidity ^0.8.9;

abstract contract DepositManager {
    struct Deposit {
        uint128 amount;
        uint128 profit;
        uint128 withdrawnAmount;
        uint48 creationTime;
        uint32 period;
        uint16[] roi_times_10_000_per_month; 
    }

    struct DepositRemovalInfo {
        uint256 depositedAmount;
        uint256 profit;
    }

    struct DepositPauseStatus {
        bool isPaused;
    }

    event MinimumDepositChanged(uint256 newMinimum);

    uint256 private nextDepositId;
    mapping(uint256 => Deposit) internal deposits;
    mapping(address => uint256[]) internal userDepositIds;
    uint256 public minDeposit;
    mapping(uint256 => DepositPauseStatus) private pausedDeposits;
    mapping(uint256 => bool) public isCompound;
    mapping(uint256 => bool) public isProgressive;

    function getDeposit(uint256 depositId) public view returns (Deposit memory) {
        return deposits[depositId];
    }

    function userHasActiveDeposits(address user) public view returns (bool) {
        uint256[] storage depositIds = userDepositIds[user];
        for (uint256 i = 0; i < depositIds.length; i++) {
            Deposit storage deposit = deposits[depositIds[i]];
            if (deposit.creationTime + deposit.period > block.timestamp)
                return true;
        }
        return false;
    }

    function getUserDepositIds(address user) public view returns (uint256[] memory) {
        return userDepositIds[user];
    }

    function getUserTotalInvestment(address user) public view returns (uint256 totalInvestedAmount) {
        uint256[] storage userDeposits = userDepositIds[user];
        for (uint256 i = 0; i < userDeposits.length; i++) {
            Deposit storage deposit = deposits[userDeposits[i]];
            totalInvestedAmount += deposit.amount;
        }
    }

    function getWithdrawableProfitForDeposit(uint256 depositId) public view returns (uint256) {
        Deposit storage deposit = deposits[depositId];
        uint256 elapsedTime = block.timestamp - deposit.creationTime;
        uint256 unlockedAmount;

        if (isCompound[depositId]) {
            if (elapsedTime >= deposit.period) {
                unlockedAmount = deposit.profit;
            } else {
                return 0;
            }
        } else if (isProgressive[depositId]) {
            uint256 progressiveProfit;
            if (elapsedTime < 30 days) {
                // Calculate the proportion of the month that has passed
                uint256 monthProportion = elapsedTime * 1e18 / 30 days; // Scaled up for precision
                // Calculate the profit for the month so far using the first ROI
                progressiveProfit = deposit.amount * deposit.roi_times_10_000_per_month[0] * monthProportion / 1e22; // scaled down
            } else {
                if (elapsedTime > deposit.period) {
                    return deposit.profit - deposit.withdrawnAmount;
                }
                uint256 monthsElapsed = elapsedTime / 30 days;
                if(monthsElapsed >= deposit.roi_times_10_000_per_month.length) {
                    monthsElapsed = deposit.roi_times_10_000_per_month.length - 1;
                }
                uint256 progressiveRoi = deposit.roi_times_10_000_per_month[monthsElapsed];
                // Get seconds elapsed in the current month
                uint256 secondsElapsedInMonth = elapsedTime % 30 days;
                // Calculate the proportion of the month that has passed
                uint256 monthProportion = secondsElapsedInMonth * 1e18 / 30 days; // Scaled up for precision
                // Calculate the profit for the month so far
                progressiveProfit = deposit.amount * progressiveRoi * monthProportion / 1e22; // scaled down
                // Add this to the profit for the past months
                for(uint i = 0; i < monthsElapsed; i++) {
                    unlockedAmount += deposit.amount * deposit.roi_times_10_000_per_month[i] / 1e4;
                }
            }
            unlockedAmount += progressiveProfit;
        } else if (elapsedTime > deposit.period) {
            unlockedAmount = deposit.profit;
        } else {
            unlockedAmount = (deposit.profit * elapsedTime) / deposit.period;
        }
        return unlockedAmount > deposit.withdrawnAmount ? unlockedAmount - deposit.withdrawnAmount : 0;
    }





    function getUserWithdrawableProfit(address user) public view returns (uint256 total) {
        uint256[] storage userDeposits = userDepositIds[user];
        for (uint256 i = 0; i < userDeposits.length; i++) {
            total += getWithdrawableProfitForDeposit(userDeposits[i]);
        }
    }

    function _updateMinDeposit(uint256 value) internal {
        if (value == minDeposit) return;
        minDeposit = value;
        emit MinimumDepositChanged(value);
    }

    function _addUserDeposit(Deposit memory deposit, address user) internal returns (uint256) {
        require(deposit.amount >= minDeposit, "edbm");
        return _addUserDepositWithoutMinCheck(deposit, user);
    }

    function _addUserDepositWithoutMinCheck(Deposit memory deposit, address user) internal returns (uint256) {
        uint256 depositId = _generateUniqueDepositId();
        deposits[depositId] = deposit;
        userDepositIds[user].push(depositId);
        return depositId;
    }

    function _removeExpiredDeposit(uint256 depositId, address user) internal returns (DepositRemovalInfo memory) {
        Deposit memory deposit = _removeDeposit(depositId, user);
        require(block.timestamp >= deposit.creationTime + deposit.period, "edne");
        return DepositRemovalInfo({depositedAmount: deposit.amount, profit: deposit.profit - deposit.withdrawnAmount});
    }

    function _withdrawAllAvailableProfits(address user) internal returns (uint256 totalWithdrawableAmount) {
        uint256[] storage userDeposits = userDepositIds[user];
        for (uint256 i = 0; i < userDeposits.length; i++) {
            uint256 depositId = userDeposits[i];
            if (!isCompound[depositId]) {
                uint256 amount = getWithdrawableProfitForDeposit(depositId);
                totalWithdrawableAmount += amount;
                deposits[depositId].withdrawnAmount += uint128(amount);
            }
        }
    }


     function _removeDeposit(uint256 depositId, address owner) private returns (Deposit memory removedDeposit) {
        uint256 userDepositIndex = _getUserDepositIndex(depositId, owner);
        uint256[] storage userDeposits = userDepositIds[owner];
          userDeposits[userDepositIndex] = userDeposits[userDeposits.length - 1];
        userDeposits.pop();
        removedDeposit = deposits[depositId];
        delete deposits[depositId];
    }

     function _getUserDepositIndex(uint256 depositId, address user) private view returns (uint256) {
        uint256[] storage userDeposits = userDepositIds[user];
        for (uint256 i; i < userDeposits.length; i++) {
            if (userDeposits[i] == depositId) {
                return i;
            }
        }
        revert("edna");
    }

    function calculatePenalty(uint48 creationTime, uint32 period) internal view returns (uint256) {
        uint256 currentTime = block.timestamp;
        uint256 timePassed = currentTime - creationTime;
        uint256 penaltyFraction = ((period - timePassed) * 1e18) / period;
        return penaltyFraction;
    }

     function _generateUniqueDepositId() private returns (uint256) {
        return ++nextDepositId;
    }

}//SPDX-License-Identifier: MIT

pragma solidity ^0.8.9;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";
import "@openzeppelin/contracts/utils/structs/EnumerableMap.sol";
import "@openzeppelin/contracts/utils/math/Math.sol";
import "./Deposits.sol";
import "./Referrals.sol";

contract Investment is
    AccessControl,
    DepositManager,
    Referrals
{
    using SafeERC20 for IERC20;
    using EnumerableSet for EnumerableSet.UintSet;
    using EnumerableMap for EnumerableMap.AddressToUintMap;


    struct Plan {
        uint32 period;
        uint16[] roi_times_10_000_per_month;
        uint8 roiNumber;
        uint80 minDeposit;
        uint80 maxDeposit; 
        uint8 flags;
        uint32 timeLimit;
        uint24 investmentLimitShifted56BitsRight;
        bool isCompound;
        bool isProgressive;
        bool approved;  
        mapping(address => bool) approvers;  
        uint approverCount; 
    }

    struct LastWithdrawalInfo {
        uint128 day;
        uint128 total;
    }

    struct DepositFeeInfo {
        address payTo;
        uint256 fractionTimes10k;
    }

    struct WithdrawFeeInfo {
        address payTo;
        uint96 amount;
    }

    struct WithdrawFeePublic {
        address payTo;
        uint256 fixedAmount;
        uint256 fractionTimes10k;
    }

    event PlanRemoved(uint256 indexed id);
    event NewDeposit(
        address indexed account,
        uint256 indexed planId,
        uint256 indexed depositId,
        uint256 amount
    );
  
    event AllProfitWithdrawn(address indexed account, uint256 amount);
    event ReferralsWithdrawn(address indexed account, uint256 amount);
    event OwedAmountWithdrawn(address indexed account, uint256 amount);
    

    bytes32 constant ADMIN_ROLE = keccak256("ADMIN_ROLE");
    uint8 constant PLAN_TIME_LIMIT_FLAG = 1;
    uint8 constant PLAN_UNITS_LIMIT_FLAG = 2;
    uint8 constant PLAN_INVESTMENT_LIMIT_FLAG = 4;

    mapping(address => bool) public registered;
    mapping(address => uint256) public extraOwedAmount;
    mapping(address => LastWithdrawalInfo) public lastWithdrawal;
    mapping(uint256 => Plan) public plans;
    EnumerableSet.UintSet private availablePlans;
    IERC20 public currency;
    uint256 public withdrawLimit;
    EnumerableMap.AddressToUintMap private depositFees;
    WithdrawFeeInfo private withdrawFee;
    uint constant QUORUM = 3; 
    uint16 public planCounter = 1;
    

        constructor(IERC20 _currency) {
            currency = _currency;
            _setupRole(ADMIN_ROLE, msg.sender);
            _setupRole(DEFAULT_ADMIN_ROLE, msg.sender);
        }


        function addPlan(
            uint32 period,
            uint16[] memory roi_times_10_000_per_month,
            uint8 roiNumber,
            uint80 minDeposit,
            uint80 maxDeposit, 
            uint32 timeLimit,
            uint128 investmentLimit,
            bool isCompound,
            bool isProgressive
        ) external onlyRole(ADMIN_ROLE) returns (uint16 planId) {
            uint8 flags = 0;
            if (timeLimit != 0) flags |= PLAN_TIME_LIMIT_FLAG;
            if (investmentLimit != 0) flags |= PLAN_INVESTMENT_LIMIT_FLAG;
            uint24 investmentLimitShifted56BitsRight = uint24(
                investmentLimit >> 56
            );

            planId = planCounter;
            Plan storage plan = plans[planCounter];

            plan.period = period;
            plan.roi_times_10_000_per_month = roi_times_10_000_per_month;
            plan.roiNumber = roiNumber;
            plan.minDeposit = minDeposit;
            plan.maxDeposit = maxDeposit;
            plan.flags = flags;
            plan.timeLimit = timeLimit;
            plan.investmentLimitShifted56BitsRight = investmentLimitShifted56BitsRight;
            plan.isCompound = isCompound;
            plan.isProgressive = isProgressive;
            
            plan.approved = false;

            planCounter++;

            return planId;
        }

        function approvePlan(uint16 planId) external onlyRole(ADMIN_ROLE) {
            Plan storage plan = plans[planId];
            require(!plan.approved, "paa");
            require(!plan.approvers[msg.sender], "uaap");

            plan.approvers[msg.sender] = true;
            plan.approverCount++;

            if (plan.approverCount >= QUORUM) {
                plan.approved = true;
                availablePlans.add(planId);
            }
        }


    function removePlan(uint256 id) external onlyRole(ADMIN_ROLE) {
        if (availablePlans.remove(id)) emit PlanRemoved(id);
    }

    function getPlanROI(uint256 planId) public view returns (uint16[] memory) {
        return plans[planId].roi_times_10_000_per_month;
    }


    function setWithdrawLimit(uint256 limit) external onlyRole(ADMIN_ROLE) {
        if (limit == withdrawLimit) return;
        withdrawLimit = limit;
    }

   function setRewardFractionsTimes10k(uint256[] calldata newFractions) external onlyRole(ADMIN_ROLE) {
       rewardFractionsTimes10k = newFractions;
    } 

    function setDepositFee(
        address payTo,
        uint256 fractionTimes10k,
        address previousPayTo
    ) external onlyRole(ADMIN_ROLE) {
        if (previousPayTo != address(0) && previousPayTo != payTo) {
            depositFees.remove(previousPayTo);
        }
        if (fractionTimes10k > 0) {
            depositFees.set(payTo, fractionTimes10k);
        } else {
            depositFees.remove(payTo);
        }
    }

    function setWithdrawFee(
        address payTo,
        uint96 amount
    ) external onlyRole(ADMIN_ROLE) {
        withdrawFee.payTo = payTo;
        withdrawFee.amount = amount;
    }

    function getDepositFees()
        external
        view
        returns (DepositFeeInfo[] memory fees)
    {
        uint256 depositFeesLength = depositFees.length();
        fees = new DepositFeeInfo[](depositFeesLength);
        for (uint256 i = 0; i < depositFeesLength; i++) {
            (address payTo, uint256 fractionTimes10k) = depositFees.at(i);
            fees[i] = (
                DepositFeeInfo({
                    payTo: payTo,
                    fractionTimes10k: fractionTimes10k
                })
            );
        }
    }

    function getWithdrawFee()
        external
        view
        returns (WithdrawFeePublic memory fee)
    {
        fee.payTo = withdrawFee.payTo;
        fee.fixedAmount = withdrawFee.amount;
    }


    function getAvailablePlans() external view returns (uint256[] memory) {
        uint[] memory list = new uint256[](availablePlans.length());
        for (uint i = 0; i < availablePlans.length(); i++) {
            list[i] = availablePlans.at(i);
        }
        return list;
    }

    function addNewLevelRule(uint256 requiredReferrals, uint256 requiredInvestment, uint256 minInvestmentToClaim) external onlyRole(ADMIN_ROLE) {
        addLevelRule(requiredReferrals, requiredInvestment, minInvestmentToClaim);
    }

    function clearAllRules() external onlyRole(ADMIN_ROLE) {
        clearAllLevelRules();
    }

    function setRewardsActivity(bool _active) external onlyRole(ADMIN_ROLE) {
        _setRewardsActivity(_active);
    }

    function getAvailableProfitAllSources(
        address user
    ) external view returns (uint256) {
        return
            getUserWithdrawableProfit(user) +
            getPendingReferralRewards(user) +
            extraOwedAmount[user];
    }


    function makeDeposit(
        address referrer,
        uint128 amount,
        uint256 planId
    ) external  {
        require(availablePlans.contains(planId), "epnf");
        register(msg.sender, referrer);
        Plan storage plan = plans[planId];
        require(plan.approved, "pda");
        currency.safeTransferFrom(msg.sender, address(this), amount);
        uint256 depositId = _createDeposit(amount, plan, planId);
        _createReferralRewards(msg.sender, amount, plan.period);
        uint256 depositFeesLength = depositFees.length();
        for (uint256 i = 0; i < depositFeesLength; i++) {
            (address payTo, uint256 fractionTimes10k) = depositFees.at(i);
            currency.safeTransfer(payTo, (amount * fractionTimes10k) / 10_000);
        }
        if (plan.isCompound) {
            isCompound[depositId] = true;
        }
        if (plan.isProgressive) {
            isProgressive[depositId] = true;
        }
        emit NewDeposit(msg.sender, planId, depositId, amount);
        totalInvestmentPerUser[msg.sender] += amount;
    }


        function withdraw(uint256 depositId) external {
            DepositRemovalInfo memory deposit = _removeExpiredDeposit(
                depositId,
                msg.sender
            );

            transferWithWithdrawLimit(
                msg.sender,
                deposit.depositedAmount,
                deposit.profit
            );
            
        }
        


        function withdrawDepositProfitAll() external  {
            uint256 amount = _withdrawAllAvailableProfits(msg.sender);
            transferWithWithdrawLimit(msg.sender, 0, amount);
            emit AllProfitWithdrawn(msg.sender, amount);
        }

        function withdrawReferrals() external  {
            address user = msg.sender;
            require(userLevels[user] > 0, "na");
            require(userHasActiveDeposits(msg.sender), "enad");
            uint256 amount = _takeAvailableReferralRewards(msg.sender);
            transferWithWithdrawLimit(msg.sender, 0, amount);
            emit ReferralsWithdrawn(msg.sender, amount);
        }

        function withdrawReinvestAll(
            uint256 withdrawAmount,
            uint256 reinvestAmount,
            uint256 reinvestPlanId
        ) external  {
            uint256 target = withdrawAmount + reinvestAmount;
            uint256 owedAmount = Math.min(
                extraOwedAmount[msg.sender],
                target
            );
            if (owedAmount > 0) {
                extraOwedAmount[msg.sender] -= owedAmount;
                target -= owedAmount;
                emit OwedAmountWithdrawn(msg.sender, owedAmount);
            }
            if (target > 0 && userHasActiveDeposits(msg.sender)) {
                uint256 referrals = _takeAvailableReferralRewards(msg.sender);
                if (referrals != 0) emit ReferralsWithdrawn(msg.sender, referrals);
                if (referrals > target) {
                    extraOwedAmount[msg.sender] += referrals - target;
                    target = 0;
                } else {
                    target -= referrals;
                }
            }
            if (target > 0) {
                uint256 depositProfit = _withdrawAllAvailableProfits(msg.sender);
                if (depositProfit != 0)
                    emit AllProfitWithdrawn(msg.sender, depositProfit);
                if (depositProfit > target) {
                    extraOwedAmount[msg.sender] += depositProfit - target;
                    target = 0;
                } else {
                    target -= depositProfit;
                }
            }
            require(target == 0, "ebtl");
            if (withdrawAmount > 0) {
                transferWithWithdrawLimit(msg.sender, 0, withdrawAmount);
            }
            if (reinvestAmount > 0) {
                require(availablePlans.contains(reinvestPlanId), "epnf");
                Plan storage plan = plans[reinvestPlanId];
                uint256 depositId = _createDeposit(uint128(reinvestAmount), plan, reinvestPlanId);
                _createReferralRewards(msg.sender, reinvestAmount, plan.period);
                emit NewDeposit(
                    msg.sender,
                    reinvestPlanId,
                    depositId,
                    reinvestAmount
                );
            }
        }

    function transferWithWithdrawLimit(
        address user,
        uint256 amountOutsideLimit,
        uint256 amountWithLimit
    ) private {
        uint256 contractBalance = currency.balanceOf(address(this));
        require(contractBalance > 0, "eoof");
        if (amountWithLimit > 0) {
            LastWithdrawalInfo storage info = lastWithdrawal[user];
            uint256 currentDay = block.timestamp / 1 days;
            if (info.day != currentDay) {
                info.day = uint128(currentDay);
                info.total = 0;
            }
            uint256 remaining = Math.max(info.total, withdrawLimit) -
                info.total;
            if (amountWithLimit > remaining) {
                extraOwedAmount[user] += amountWithLimit - remaining;
                amountWithLimit = remaining;
            }
        }
        uint256 total = amountOutsideLimit + amountWithLimit;
        require(total > 0, "entw");
        if (total > contractBalance) {
            extraOwedAmount[user] += total - contractBalance;
            total = contractBalance;
        }
        if (withdrawFee.amount > 0) {
            require(total > withdrawFee.amount, "ewbf");
            currency.safeTransfer(withdrawFee.payTo, withdrawFee.amount);
        }
        currency.safeTransfer(msg.sender, total - withdrawFee.amount);
    }

    function _createDeposit(
        uint128 amount,
        Plan storage plan,
        uint256 planId
    ) private returns (uint256 depositId) {
        require(amount >= plan.minDeposit, "edbm");
        require(amount <= plan.maxDeposit, "edbm");
        if (plan.flags & PLAN_TIME_LIMIT_FLAG != 0)
            require(plan.timeLimit > block.timestamp, "eptl");
        if (plan.flags & PLAN_INVESTMENT_LIMIT_FLAG != 0) {
            uint24 amountShifted56 = uint24(amount >> 56);
            require(
                plan.investmentLimitShifted56BitsRight >= amountShifted56,
                "epil"
            );
            plan.investmentLimitShifted56BitsRight -= amountShifted56;
        }
        Deposit memory deposit;
        deposit.amount = amount;
        deposit.creationTime = uint48(block.timestamp);
        deposit.period = plan.period;

        deposit.roi_times_10_000_per_month = getPlanROI(planId);
        
        uint32 totalRoi = 0;
        for (uint32 i = 0; i < plan.roi_times_10_000_per_month.length; i++) {
            totalRoi += plan.roi_times_10_000_per_month[i];
        }
        
        deposit.profit = uint128((amount * totalRoi) / 10_000);
        return _addUserDeposit(deposit, msg.sender);
    }

    function cancelInvestment(uint256 depositId) external {
        require(isProgressive[depositId], "dinp");
        bool isOwner = false;
        uint256[] memory depositIds = userDepositIds[msg.sender];
        for (uint256 i = 0; i < depositIds.length; i++) {
            if (depositIds[i] == depositId) {
                isOwner = true;
                break;
            }
        }
        require(isOwner, "oocc");

        Deposit storage deposit = deposits[depositId];
        uint256 currentTime = block.timestamp;
        require(currentTime < deposit.creationTime + deposit.period, "cc");

        uint256 penaltyFraction = calculatePenalty(deposit.creationTime, deposit.period);
        uint256 penalty = (deposit.amount * penaltyFraction) / 1e18;
        require(deposit.amount >= penalty, "peda");
        uint256 refundAmount = deposit.amount - penalty;
        currency.safeTransfer(msg.sender, refundAmount);

        // Luego de retirar, se remueve el deposito
        delete deposits[depositId];
    }


    function register(address user, address referrer) private {
        if (registered[user]) return;
        _setReferrer(user, referrer);
        referralsCount[referrer] += 1;
        registered[user] = true;
    }

}//SPDX-License-Identifier: MIT

pragma solidity ^0.8.9;

import "@openzeppelin/contracts/utils/math/Math.sol";

abstract contract Referrals {
    uint32 constant MAX_UINT32 = 2 ** 32 - 1;
    uint256 constant MAX_UINT256 = 2 ** 256 - 1;

    event NewReferral(address indexed newUser, address indexed referrer);

    struct Reward {
        uint128 amount;
        uint48 startTime;
        uint32 duration;
        uint32 next;
        bool isActive;  
    }

    struct LevelRules {
        uint256 requiredReferrals;
        uint256 requiredInvestment;
        uint256 minInvestmentToClaim;
    }


    struct RewardExtraInfo {
        uint256 nextPeriod;
        uint256 endTime;
        uint256 claimableAmount;
        bool finished;
        bool nextIsPartial;
    }

    struct LastClaimInfo {
        uint32 arraySize;
        uint32 lastClaimedIndex;
        uint48 time;
    }

    struct DebugInfo {
        uint256 rewardsLength;
        LastClaimInfo lastClaim;
        Reward[] rewards;
        RewardExtraInfo[] extraInfo;
    }

    uint32 public constant PERIOD_LENGTH = 30 days;
    LevelRules[] public levelsRules;
    uint256[] rewardFractionsTimes10k;
    mapping(address => address) public referrerOf;
    mapping(address => Reward[]) rewardsOf;
    mapping(address => mapping(uint => uint256)) public depositsByLevel;
    mapping(address => LastClaimInfo) lastClaimOf;
    mapping(address => uint) public referralsCount;
    mapping(address => uint) public totalInvestmentPerUser;
    mapping(address => uint8) public userLevels;
    bool public rewardsActive = true;


    function getRewardFractionsTimes10k() public view returns (uint256[] memory) {
    return rewardFractionsTimes10k;
    }

    function getPendingReferralRewards(
        address referrer
    ) public view returns (uint256) {
        return getPendingRewardsAtTime(referrer, block.timestamp);
    }

    function getTotalFutureReferralRewards(
        address referrer
    ) public view returns (uint256) {
        return getPendingRewardsAtTime(referrer, 2 ** 64);
    }

    function getDebugInfo(
        address referrer,
        uint256 from,
        uint256 to,
        uint256 currentTime
    ) public view returns (DebugInfo memory debugInfo) {
        if (currentTime == 0) currentTime = block.timestamp;
        Reward[] storage rewards = rewardsOf[referrer];
        uint256 realTo = Math.min(to, rewards.length);
        debugInfo.rewards = new Reward[](realTo - from);
        debugInfo.extraInfo = new RewardExtraInfo[](realTo - from);
        debugInfo.lastClaim = lastClaimOf[referrer];
        debugInfo.rewardsLength = rewards.length;
        for (uint256 i = 0; i < realTo - from; i++) {
            Reward memory reward = rewards[i + from];
            debugInfo.rewards[i] = reward;
            if (reward.startTime != 0) {
                debugInfo.extraInfo[i] = getRewardExtraInfo(
                    reward,
                    debugInfo.lastClaim.time,
                    currentTime
                );
            }
        }
    }

    function getUserLevel(address user) external view returns (uint8) {
        return userLevels[user];
    }


    function getPendingRewardsAtTime(
        address referrer,
        uint256 time
    ) public view returns (uint256 totalRewards) {
        Reward[] storage rewards = rewardsOf[referrer];
        LastClaimInfo memory lastClaim = lastClaimOf[referrer];
        uint256 next = lastClaim.lastClaimedIndex;
        if (next < lastClaim.arraySize) {
            next = rewards[next].next;
        }
        while (next < rewards.length) {
            Reward memory reward = rewards[next];
            RewardExtraInfo memory rewardInfo = getRewardExtraInfo(
                reward,
                lastClaim.time,
                time
            );
            if (next < lastClaim.arraySize) {
                if (
                    next == lastClaim.lastClaimedIndex ||
                    time < rewardInfo.nextPeriod
                ) next = lastClaim.arraySize;
                else next = rewards[next].next;
            } else {
                if (time < rewardInfo.nextPeriod) break;
                    rewardInfo.claimableAmount -= reward.amount;
                next++;
            }
            totalRewards += rewardInfo.claimableAmount;
        }
    }

    function _setReferrer(
        address newUser,
        address referrer
    ) internal returns (bool) {
        if (!_setReferrerNoCycleCheck(newUser, referrer)) return false;
        address nextInChain = referrer;
        uint activeLevels = levelsRules.length;
        for (uint i = 0; i < activeLevels && nextInChain != address(0); i++) {
            require(nextInChain != newUser, "ercd");
            nextInChain = referrerOf[nextInChain];
        }
        return true;
    }


    function _setReferrerNoCycleCheck(
        address newUser,
        address referrer
    ) internal returns (bool) {
        if (referrer == address(0) || referrerOf[newUser] != address(0)) {
            return false;
        }
        _forceSetReferrer(newUser, referrer);
        return true;
    }

    function _forceSetReferrer(address newUser, address referrer) internal {
        referrerOf[newUser] = referrer;
        emit NewReferral(newUser, referrer);
    }

    function getReferralsFor(address user) public view returns (uint) {
        return referralsCount[user];
    }

    function getTotalInvestmentFor(address user) public view returns (uint) {
        return totalInvestmentPerUser[user];
    }


    function addLevelRule(
        uint256 requiredReferrals,
        uint256 requiredInvestment,
        uint256 minInvestmentToClaim
    ) internal {
        LevelRules memory newLevel = LevelRules({
            requiredReferrals: requiredReferrals,
            requiredInvestment: requiredInvestment,
            minInvestmentToClaim: minInvestmentToClaim
        });
        
        levelsRules.push(newLevel);
    }


    function clearAllLevelRules() internal {
        delete levelsRules;
    }

    function checkLevelCompletion(address user) public view returns(bool) {
        uint8 checkingLevel = userLevels[user] + 1;

        // Asegúrate de que el nivel sea válido
        require(checkingLevel <= levelsRules.length, "il");

        LevelRules memory rules = levelsRules[checkingLevel - 1];
        return (referralsCount[user] >= rules.requiredReferrals && totalInvestmentPerUser[user] >= rules.requiredInvestment);
    }


     function _setRewardsActivity(bool _active) internal {
        rewardsActive = _active;
    }

    function updateRewardsOnLevelUp(address user) internal {
        uint48 currentTime = uint48(block.timestamp);

        for (uint i = 0; i < rewardsOf[user].length; i++) {
            if (!rewardsOf[user][i].isActive) {
                uint32 elapsed = uint32(currentTime - rewardsOf[user][i].startTime);

                rewardsOf[user][i].startTime = currentTime;

                if (elapsed < rewardsOf[user][i].duration) {
                    rewardsOf[user][i].duration -= elapsed;
                } else {
                    rewardsOf[user][i].duration = 0;
                }

                rewardsOf[user][i].isActive = true; 
            }
        }
    }



        function activatePendingRewards(address user) internal {
            if (checkLevelCompletion(user)) {
                updateRewardsOnLevelUp(user); // Actualizamos las recompensas

                if (userLevels[user] < levelsRules.length - 1) {
                    userLevels[user]++;
                } else {
                    for (uint i = 0; i < rewardsOf[user].length; i++) {
                            rewardsOf[user][i].isActive = true;
                        }                
                }
            }
        }


        function _createReferralRewards(address depositor, uint256 depositedAmount, uint32 depositDuration) internal {
            if (!rewardsActive) {
                return; 
            }

            uint48 currentTime = uint48(block.timestamp);
            address nextInChain = referrerOf[depositor];
            address referrer = referrerOf[depositor];
            

            for (uint i = 0; i < rewardFractionsTimes10k.length && nextInChain != address(0); i++) {
                uint256 rewardFraction;

                if (userLevels[nextInChain] == 0 || userLevels[nextInChain] == 1) {
                    rewardFraction = rewardFractionsTimes10k[0];
                } else {
                    rewardFraction = rewardFractionsTimes10k[userLevels[nextInChain] - 1];
                }

                rewardsOf[nextInChain].push(
                    Reward({
                        amount: uint128((depositedAmount * rewardFraction) / 10_000),
                        startTime: currentTime,
                        duration: depositDuration,
                        next: 0,
                        isActive: userLevels[nextInChain] == (i + 1)
                    })
                );

                nextInChain = referrerOf[nextInChain];
            }

             activatePendingRewards(referrer);
             activatePendingRewards(depositor);  
        }


    function _takeAvailableReferralRewards(
        address referrer
    ) internal returns (uint256 totalRewards) {
        Reward[] storage rewards = rewardsOf[referrer];
        LastClaimInfo memory lastClaim = lastClaimOf[referrer];
        uint256 lastClaimedIndex = lastClaim.lastClaimedIndex;
        uint256 nextNewIndex = lastClaim.arraySize;
        Reward memory nextNew = (nextNewIndex < rewards.length)
            ? rewards[nextNewIndex]
            : Reward(0, 0, 0, 0, true);
        uint256 firstClaimedIndex = MAX_UINT256;
        uint32 firstNeedsToBeReinserted = MAX_UINT32;
        uint256 substractFromTotal = 0;
        for (;;) {
            if (lastClaimedIndex == nextNewIndex) {
                if (nextNewIndex == rewards.length) break;
                if (
                    rewards[nextNewIndex].next == 1
                ) substractFromTotal += rewards[nextNewIndex].amount;
                rewards[nextNewIndex].next = uint32(nextNewIndex);
                nextNewIndex++;
                nextNew = (nextNewIndex < rewards.length)
                    ? rewards[nextNewIndex]
                    : Reward(0, 0, 0, 0, true);
            }
            uint256 nextToClaimIndex = rewards[lastClaimedIndex].next;
            Reward memory nextToClaim = rewards[nextToClaimIndex];
            RewardExtraInfo memory nextToClaimInfo = getRewardExtraInfo(
                nextToClaim,
                (nextToClaimIndex == firstClaimedIndex)
                    ? block.timestamp
                    : lastClaim.time,
                block.timestamp
            );
            if (nextNew.startTime != 0) {
                RewardExtraInfo memory nextNewInfo = getRewardExtraInfo(
                    nextNew,
                    lastClaim.time,
                    block.timestamp
                );
                if (nextToClaimInfo.nextPeriod > nextNewInfo.nextPeriod) {
                    if (nextNew.next == 1) 
                    substractFromTotal += nextNew.amount;
                    rewards[lastClaimedIndex].next = uint32(nextNewIndex);
                    nextNew.next = uint32(nextToClaimIndex);
                    rewards[nextNewIndex].next = nextNew.next;
                    nextToClaimIndex = nextNewIndex;
                    nextToClaim = nextNew;
                    nextToClaimInfo = nextNewInfo;
                    nextNewIndex++;
                    nextNew = (nextNewIndex < rewards.length)
                        ? rewards[nextNewIndex]
                        : Reward(0, 0, 0, 0, true);
                }
            }
            if (nextToClaimInfo.nextPeriod > block.timestamp) break;
            totalRewards += nextToClaimInfo.claimableAmount;
            if (nextToClaimInfo.finished) {
                rewards[lastClaimedIndex].next = nextToClaim.next;
                delete rewards[nextToClaimIndex];
                if (lastClaimedIndex == nextToClaimIndex)
                    lastClaimedIndex = nextNewIndex;
            } else if (nextToClaimInfo.nextIsPartial) {
                rewards[lastClaimedIndex].next = nextToClaim.next;
                if (lastClaimedIndex == nextToClaimIndex)
                    lastClaimedIndex = nextNewIndex;
                rewards[nextToClaimIndex].next = firstNeedsToBeReinserted;
                firstNeedsToBeReinserted = uint32(nextToClaimIndex);
            } else {
                lastClaimedIndex = nextToClaimIndex;
                if (firstClaimedIndex == MAX_UINT256)
                    firstClaimedIndex = lastClaimedIndex;
            }
        }
        while (firstNeedsToBeReinserted != MAX_UINT32) {
            uint256 reinsertedIndex = firstNeedsToBeReinserted;
            Reward storage reinserted = rewards[reinsertedIndex];
            firstNeedsToBeReinserted = reinserted.next;
            if (lastClaimedIndex == nextNewIndex) {
                reinserted.next = uint32(reinsertedIndex);
                lastClaimedIndex = reinsertedIndex;
                continue;
            }
            RewardExtraInfo memory reinsertedInfo = getRewardExtraInfo(
                reinserted,
                block.timestamp,
                block.timestamp
            );
            uint256 insertAfterIndex = lastClaimedIndex;
            uint256 insertBeforeIndex = rewards[insertAfterIndex].next;
            Reward memory insertBefore = rewards[insertBeforeIndex];
            RewardExtraInfo memory insertBeforeInfo = getRewardExtraInfo(
                insertBefore,
                block.timestamp,
                block.timestamp
            );
            while (reinsertedInfo.nextPeriod > insertBeforeInfo.nextPeriod) {
                insertAfterIndex = insertBeforeIndex;
                insertBeforeIndex = insertBefore.next;
                insertBefore = rewards[insertBeforeIndex];
                insertBeforeInfo = getRewardExtraInfo(
                    insertBefore,
                    block.timestamp,
                    block.timestamp
                );
                if (insertAfterIndex == lastClaimedIndex) {
                    lastClaimedIndex = reinsertedIndex;
                    break;
                }
            }
            rewards[insertAfterIndex].next = uint32(reinsertedIndex);
            reinserted.next = uint32(insertBeforeIndex);
        }
        lastClaim.lastClaimedIndex = uint32(lastClaimedIndex);
        lastClaim.arraySize = uint32(nextNewIndex);
        lastClaim.time = uint48(block.timestamp);
        lastClaimOf[referrer] = lastClaim;
        totalRewards -= substractFromTotal;
    }

    function _setRewardFractionsTimes10k(uint256[] memory newFractions) internal {
        rewardFractionsTimes10k = newFractions;
    }


    function getRewardExtraInfo(
        Reward memory reward,
        uint256 lastClaimTime,
        uint256 currentTime
    ) public pure returns (RewardExtraInfo memory info) {
        info.endTime = reward.startTime + reward.duration;
        uint256 onePeriodBeforeStart = reward.startTime - PERIOD_LENGTH;
        uint256 periodsClaimed = (Math.max(
            lastClaimTime,
            onePeriodBeforeStart
        ) - onePeriodBeforeStart) / PERIOD_LENGTH;
        uint256 prevPeriod = onePeriodBeforeStart +
            PERIOD_LENGTH *
            periodsClaimed;
        info.nextPeriod = Math.min(
            info.endTime,
            prevPeriod + PERIOD_LENGTH
        );
        if (currentTime >= info.endTime) {
            uint256 timeSinceLastPeriod = info.endTime - prevPeriod;
            info.claimableAmount =
                (reward.amount * (timeSinceLastPeriod / PERIOD_LENGTH)) +
                ((reward.amount * (timeSinceLastPeriod % PERIOD_LENGTH)) /
                    PERIOD_LENGTH);
            info.finished = true;
            info.nextIsPartial = false;
        } else {
            uint256 timeSinceLastPeriod = currentTime - prevPeriod;
            uint256 newPeriodsClaimed = timeSinceLastPeriod / PERIOD_LENGTH;
            info.claimableAmount = reward.amount * newPeriodsClaimed;
            info.finished = false;
            info.nextIsPartial =
                info.endTime -
                    (onePeriodBeforeStart +
                        PERIOD_LENGTH *
                        (periodsClaimed + newPeriodsClaimed)) <
                PERIOD_LENGTH;
        }
    }

}