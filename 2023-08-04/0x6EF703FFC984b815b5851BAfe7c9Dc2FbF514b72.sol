// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.8.0) (access/AccessControl.sol)

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
 * ```
 * bytes32 public constant MY_ROLE = keccak256("MY_ROLE");
 * ```
 *
 * Roles can be used to represent a set of permissions. To restrict access to a
 * function call, use {hasRole}:
 *
 * ```
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
 * accounts that have been granted it.
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
// OpenZeppelin Contracts (last updated v4.5.0) (token/ERC1155/IERC1155Receiver.sol)

pragma solidity ^0.8.0;

import "../../utils/introspection/IERC165.sol";

/**
 * @dev _Available since v3.1._
 */
interface IERC1155Receiver is IERC165 {
    /**
     * @dev Handles the receipt of a single ERC1155 token type. This function is
     * called at the end of a `safeTransferFrom` after the balance has been updated.
     *
     * NOTE: To accept the transfer, this must return
     * `bytes4(keccak256("onERC1155Received(address,address,uint256,uint256,bytes)"))`
     * (i.e. 0xf23a6e61, or its own function selector).
     *
     * @param operator The address which initiated the transfer (i.e. msg.sender)
     * @param from The address which previously owned the token
     * @param id The ID of the token being transferred
     * @param value The amount of tokens being transferred
     * @param data Additional data with no specified format
     * @return `bytes4(keccak256("onERC1155Received(address,address,uint256,uint256,bytes)"))` if transfer is allowed
     */
    function onERC1155Received(
        address operator,
        address from,
        uint256 id,
        uint256 value,
        bytes calldata data
    ) external returns (bytes4);

    /**
     * @dev Handles the receipt of a multiple ERC1155 token types. This function
     * is called at the end of a `safeBatchTransferFrom` after the balances have
     * been updated.
     *
     * NOTE: To accept the transfer(s), this must return
     * `bytes4(keccak256("onERC1155BatchReceived(address,address,uint256[],uint256[],bytes)"))`
     * (i.e. 0xbc197c81, or its own function selector).
     *
     * @param operator The address which initiated the batch transfer (i.e. msg.sender)
     * @param from The address which previously owned the token
     * @param ids An array containing ids of each token being transferred (order and length must match values array)
     * @param values An array containing amounts of each token being transferred (order and length must match ids array)
     * @param data Additional data with no specified format
     * @return `bytes4(keccak256("onERC1155BatchReceived(address,address,uint256[],uint256[],bytes)"))` if transfer is allowed
     */
    function onERC1155BatchReceived(
        address operator,
        address from,
        uint256[] calldata ids,
        uint256[] calldata values,
        bytes calldata data
    ) external returns (bytes4);
}
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (token/ERC20/extensions/draft-IERC20Permit.sol)

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
// OpenZeppelin Contracts (last updated v4.6.0) (token/ERC20/IERC20.sol)

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
    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);
}
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.8.0) (token/ERC20/utils/SafeERC20.sol)

pragma solidity ^0.8.0;

import "../IERC20.sol";
import "../extensions/draft-IERC20Permit.sol";
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
        if (returndata.length > 0) {
            // Return data is optional
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
}
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.8.0) (utils/Address.sol)

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
// OpenZeppelin Contracts (last updated v4.8.0) (utils/cryptography/draft-EIP712.sol)

pragma solidity ^0.8.0;

// EIP-712 is Final as of 2022-08-11. This file is deprecated.

import "./EIP712.sol";
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.8.0) (utils/cryptography/ECDSA.sol)

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
    function tryRecover(
        bytes32 hash,
        bytes32 r,
        bytes32 vs
    ) internal pure returns (address, RecoverError) {
        bytes32 s = vs & bytes32(0x7fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff);
        uint8 v = uint8((uint256(vs) >> 255) + 27);
        return tryRecover(hash, v, r, s);
    }

    /**
     * @dev Overload of {ECDSA-recover} that receives the `r and `vs` short-signature fields separately.
     *
     * _Available since v4.2._
     */
    function recover(
        bytes32 hash,
        bytes32 r,
        bytes32 vs
    ) internal pure returns (address) {
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
    function tryRecover(
        bytes32 hash,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) internal pure returns (address, RecoverError) {
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
    function recover(
        bytes32 hash,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) internal pure returns (address) {
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
    function toEthSignedMessageHash(bytes32 hash) internal pure returns (bytes32) {
        // 32 is the length in bytes of hash,
        // enforced by the type signature above
        return keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n32", hash));
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
    function toTypedDataHash(bytes32 domainSeparator, bytes32 structHash) internal pure returns (bytes32) {
        return keccak256(abi.encodePacked("\x19\x01", domainSeparator, structHash));
    }
}
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.8.0) (utils/cryptography/EIP712.sol)

pragma solidity ^0.8.0;

import "./ECDSA.sol";

/**
 * @dev https://eips.ethereum.org/EIPS/eip-712[EIP 712] is a standard for hashing and signing of typed structured data.
 *
 * The encoding specified in the EIP is very generic, and such a generic implementation in Solidity is not feasible,
 * thus this contract does not implement the encoding itself. Protocols need to implement the type-specific encoding
 * they need in their contracts using a combination of `abi.encode` and `keccak256`.
 *
 * This contract implements the EIP 712 domain separator ({_domainSeparatorV4}) that is used as part of the encoding
 * scheme, and the final step of the encoding to obtain the message digest that is then signed via ECDSA
 * ({_hashTypedDataV4}).
 *
 * The implementation of the domain separator was designed to be as efficient as possible while still properly updating
 * the chain id to protect against replay attacks on an eventual fork of the chain.
 *
 * NOTE: This contract implements the version of the encoding known as "v4", as implemented by the JSON RPC method
 * https://docs.metamask.io/guide/signing-data.html[`eth_signTypedDataV4` in MetaMask].
 *
 * _Available since v3.4._
 */
abstract contract EIP712 {
    /* solhint-disable var-name-mixedcase */
    // Cache the domain separator as an immutable value, but also store the chain id that it corresponds to, in order to
    // invalidate the cached domain separator if the chain id changes.
    bytes32 private immutable _CACHED_DOMAIN_SEPARATOR;
    uint256 private immutable _CACHED_CHAIN_ID;
    address private immutable _CACHED_THIS;

    bytes32 private immutable _HASHED_NAME;
    bytes32 private immutable _HASHED_VERSION;
    bytes32 private immutable _TYPE_HASH;

    /* solhint-enable var-name-mixedcase */

    /**
     * @dev Initializes the domain separator and parameter caches.
     *
     * The meaning of `name` and `version` is specified in
     * https://eips.ethereum.org/EIPS/eip-712#definition-of-domainseparator[EIP 712]:
     *
     * - `name`: the user readable name of the signing domain, i.e. the name of the DApp or the protocol.
     * - `version`: the current major version of the signing domain.
     *
     * NOTE: These parameters cannot be changed except through a xref:learn::upgrading-smart-contracts.adoc[smart
     * contract upgrade].
     */
    constructor(string memory name, string memory version) {
        bytes32 hashedName = keccak256(bytes(name));
        bytes32 hashedVersion = keccak256(bytes(version));
        bytes32 typeHash = keccak256(
            "EIP712Domain(string name,string version,uint256 chainId,address verifyingContract)"
        );
        _HASHED_NAME = hashedName;
        _HASHED_VERSION = hashedVersion;
        _CACHED_CHAIN_ID = block.chainid;
        _CACHED_DOMAIN_SEPARATOR = _buildDomainSeparator(typeHash, hashedName, hashedVersion);
        _CACHED_THIS = address(this);
        _TYPE_HASH = typeHash;
    }

    /**
     * @dev Returns the domain separator for the current chain.
     */
    function _domainSeparatorV4() internal view returns (bytes32) {
        if (address(this) == _CACHED_THIS && block.chainid == _CACHED_CHAIN_ID) {
            return _CACHED_DOMAIN_SEPARATOR;
        } else {
            return _buildDomainSeparator(_TYPE_HASH, _HASHED_NAME, _HASHED_VERSION);
        }
    }

    function _buildDomainSeparator(
        bytes32 typeHash,
        bytes32 nameHash,
        bytes32 versionHash
    ) private view returns (bytes32) {
        return keccak256(abi.encode(typeHash, nameHash, versionHash, block.chainid, address(this)));
    }

    /**
     * @dev Given an already https://eips.ethereum.org/EIPS/eip-712#definition-of-hashstruct[hashed struct], this
     * function returns the hash of the fully encoded EIP712 message for this domain.
     *
     * This hash can be used together with {ECDSA-recover} to obtain the signer of a message. For example:
     *
     * ```solidity
     * bytes32 digest = _hashTypedDataV4(keccak256(abi.encode(
     *     keccak256("Mail(address to,string contents)"),
     *     mailTo,
     *     keccak256(bytes(mailContents))
     * )));
     * address signer = ECDSA.recover(digest, signature);
     * ```
     */
    function _hashTypedDataV4(bytes32 structHash) internal view virtual returns (bytes32) {
        return ECDSA.toTypedDataHash(_domainSeparatorV4(), structHash);
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
// OpenZeppelin Contracts (last updated v4.8.0) (utils/math/Math.sol)

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
    function mulDiv(
        uint256 x,
        uint256 y,
        uint256 denominator
    ) internal pure returns (uint256 result) {
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
                return prod0 / denominator;
            }

            // Make sure the result is less than 2^256. Also prevents denominator == 0.
            require(denominator > prod1);

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
    function mulDiv(
        uint256 x,
        uint256 y,
        uint256 denominator,
        Rounding rounding
    ) internal pure returns (uint256) {
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
            if (value >= 10**64) {
                value /= 10**64;
                result += 64;
            }
            if (value >= 10**32) {
                value /= 10**32;
                result += 32;
            }
            if (value >= 10**16) {
                value /= 10**16;
                result += 16;
            }
            if (value >= 10**8) {
                value /= 10**8;
                result += 8;
            }
            if (value >= 10**4) {
                value /= 10**4;
                result += 4;
            }
            if (value >= 10**2) {
                value /= 10**2;
                result += 2;
            }
            if (value >= 10**1) {
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
            return result + (rounding == Rounding.Up && 10**result < value ? 1 : 0);
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
     * @dev Return the log in base 10, following the selected rounding direction, of a positive value.
     * Returns 0 if given 0.
     */
    function log256(uint256 value, Rounding rounding) internal pure returns (uint256) {
        unchecked {
            uint256 result = log256(value);
            return result + (rounding == Rounding.Up && 1 << (result * 8) < value ? 1 : 0);
        }
    }
}
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.8.0) (utils/Strings.sol)

pragma solidity ^0.8.0;

import "./math/Math.sol";

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
}
//SPDX-License-Identifier: MIT
pragma solidity 0.8.15;

interface IMarketInfo  {

    function saveSells1155(address _nftContractAddress, uint256 _tokenId, uint256 marketid, address _erc20Token, uint256 _buyNowPrice, 
     address _seller, bool _lazymint) external;

    function saveAuction1155(address _nftContractAddress, uint256 _tokenId, uint256 marketid, address _erc20Token, uint256 _buyNowPrice, 
    uint256 _minPrice, address _seller, uint32 _bidIncreasePercentage, uint32 _auctionBidPeriod,
    bool _lazymint ) external ;

    function saveRoyalties(address _nftContractAddress, uint256 _tokenId, uint256 marketid, address _feeRecipients, uint32 _feePercentages) external;

    function getBidInfo(address _nftContractAddress, uint256 _tokenId, uint256 marketid) external view returns(address seller,uint256 pay, uint64 auctionEndTimestamp);

    function bidrequiriments(address _nftContractAddress, uint256 _tokenId, uint256 marketid) external view returns(uint256 buyNowPrice, uint32 bidIncreasePercentage,uint256 highBid);

    function getTokenAndPrice(address _nftContractAddress, uint256 _tokenId, uint256 marketid) external view returns(address auctionERC20Token, uint256 _price);

    function bidAndToken(address _nftContractAddress, uint256 _tokenId, uint256 marketid) external view returns(address auctionERC20Token,address prevBidder, uint256 prevBid);

    function setBid(address _nftContractAddress, uint256 _tokenId, uint256 marketid, uint256 _amount, address _buyer) external;

    function getSeller(address _nftContractAddress, uint256 _tokenId, uint256 marketid) external view returns(address _seller);

    function resetAuction(address _nftContractAddress, uint256 _tokenId, uint256 marketid) external;
     
    function resetBids(address _nftContractAddress, uint256 _tokenId, uint256 marketid) external;

    function newBidPeriod(address _nftContractAddress, uint256 _tokenId, uint256 marketid, uint32 _newBidPeriod) external returns(uint64 _auctionEnd);

    function getPayInfo(address _nftContractAddress, uint256 _tokenId, uint256 marketid) external view returns(address _nftSeller, address _highestBidder, uint256 highestBid, bool lazymint, string memory metadata);

    function getRoyalties(address _nftContractAddress, uint256 _tokenId, uint256 marketid) external view returns (address feeRecipients, uint32 feePercentages);

    function getToken(address _nftContractAddress, uint256 _tokenId, uint256 marketid) external view returns (address _token);

    function getEndAuctionInfo(address _nftContractAddress, uint256 _tokenId, uint256 marketid) external view returns (uint64 endAuction);

    function updateMiniumPrice(address _nftContractAddress, uint256 _tokenId, uint256 marketid, uint256 _newMinPrice) external;

    function getMinimumPrice(address _nftContractAddress, uint256 _tokenId, uint256 marketid) external view returns (address _nftSeller, address _highestBidder, bool lazymint, uint256 minprice);

    function updateBuynowPrice(address _nftContractAddress, uint256 _tokenId, uint256 marketid, uint256 _newBuyNowPrice) external;

}//SPDX-License-Identifier: MIT
pragma solidity 0.8.15;

import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/token/ERC1155/IERC1155Receiver.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "./MarketEventsV2.sol";
import "./Verification.sol";
import "./Optionmintcontracts/IERC1155.sol";
import "./verifySignature.sol";
import "./IMarketInfo.sol";
import "./MarketStruct.sol";
//import "hardhat/console.sol";

/// @title An Auction Contract for bidding and selling single and batched NFTs
/// @notice This contract can be used for auctioning any NFTs, and accepts any ERC20 token as payment
/// @author Disruptive Studios
/// @author Modified from Avo Labs GmbH (https://github.com/avolabs-io/nft-auction/blob/master/contracts/NFTAuction.sol)
contract NFTMarket1155 is AccessControl, MarketEventsV2, verification, VerifySignature, MarketStruct {

    using SafeERC20 for IERC20;

    IMarketInfo private marketInfo;
    
    ///@notice If transfer fail save to withdraw later
    mapping(address => uint256) private failedTransferCredits;

    ///@notice Default values market fee
    address payable public addressmarketfee;
    uint256 public feeMarket = 250; //Equal 2.5%
    uint256 private Marketid;

    mapping(address => mapping(uint256 => uint256)) private idData;

    // constructor
     constructor(address payable _addressmarketfee, address _marketInfo) {
        _setupRole(DEFAULT_ADMIN_ROLE, msg.sender);
        addressmarketfee = _addressmarketfee;
        marketInfo = IMarketInfo(_marketInfo);
    }

    modifier isAuctionNotStartedByOwner(address _nftContractAddress,uint256 _tokenId, bool _lazy) {
        if (!_lazy) {
            require(IERC1155(_nftContractAddress).balanceOf(msg.sender, _tokenId) != 0, "Sender doesn't own NFT");
        }
        _;
    }

    modifier admin() {
        require(hasRole(DEFAULT_ADMIN_ROLE, msg.sender), "Caller is not Admin");
        _;
    }


    ///@dev If the buy now price is set by the seller, check that the highest bid meets that price.
    function _isBuyNowPriceMet(address _nftContractAddress, uint256 _tokenId, uint256 _marketid)
        internal
        view
        returns (bool)
    {   
        (uint256 buyNowPrice,,uint256 highestBid) = marketInfo.bidrequiriments(_nftContractAddress,_tokenId, _marketid);
        
        return buyNowPrice > 0 && highestBid >= buyNowPrice;
    }

    ///@dev Check that a bid is applicable for the purchase of the NFT.
    ///@dev In the case of a sale: the bid needs to meet the buyNowPrice.
    ///@dev if buyNowPrice is met, ignore increase percentage
    ///@dev In the case of an auction: the bid needs to be a % higher than the previous bid.
    ///@dev if the NFT is up for auction, the bid needs to be a % higher than the previous bid
 function _bidMeetBidRequirements(
        address _nftContractAddress,
        uint256 _tokenId,
        uint256 _marketid,
        uint256 _tokenAmount,
        uint256 _value,
        bool _sign
    ) internal view returns (bool _state) {
        (uint256 buyNowPrice, uint32 bidIncreasePercentage,uint256 highBid) = marketInfo.bidrequiriments(_nftContractAddress,_tokenId, _marketid);
         
        if (_sign) {
            uint256 newTotal = buyNowPrice >= _value ?  (buyNowPrice - _value) : (_value - buyNowPrice);
            if (buyNowPrice > 0 &&
                (msg.value == newTotal || _tokenAmount == newTotal)) {
                return _state = true;
            }
        } else {
            if (
                buyNowPrice > 0 &&
                (msg.value == buyNowPrice || _tokenAmount == buyNowPrice)
            ) {
                return _state = true;
            }

            uint256 bidIncreaseAmount = highBid * (10000 + bidIncreasePercentage) / 10000;
            return (msg.value >= bidIncreaseAmount ||
                _tokenAmount >= bidIncreaseAmount);
        }
    }

    ///@dev Payment is accepted in the following scenarios:
    ///@dev (1) Auction already created - can accept ETH or Specified Token
    ///@dev  --------> Cannot bid with ETH & an ERC20 Token together in any circumstance<------
    ///@dev (2) Auction not created - only ETH accepted (cannot early bid with an ERC20 Token
    ///@dev (3) Cannot make a zero bid (no ETH or Token amount)
     function _isPaymentAccepted(
        address _nftContractAddress,
        uint256 _tokenId,
        uint256 _marketid,
        address _bidERC20Token,
        uint256 _tokenAmount,
        uint256 _value,
        bool _sign
    ) internal view returns (bool) {
        (address auctionERC20Token, uint256 _buyNowPrice) = marketInfo.getTokenAndPrice(_nftContractAddress,_tokenId, _marketid);
        if (_sign) {
            if(_value > _buyNowPrice ){
                    return true;
            }
            if (auctionERC20Token != address(0)) {
                return
                    msg.value == 0 &&
                    auctionERC20Token == _bidERC20Token &&
                    _tokenAmount != 0;
            } else {
                return
                    msg.value != 0 &&
                    _bidERC20Token == address(0) &&
                    _tokenAmount == 0;
            }
        } else {
            if (auctionERC20Token != address(0)) {
                return
                    msg.value == 0 &&
                    auctionERC20Token == _bidERC20Token &&
                    _tokenAmount != 0;
            } else {
                return
                    msg.value != 0 &&
                    _bidERC20Token == address(0) &&
                    _tokenAmount == 0;
            }
        }
    }

    function _transferNftToAuctionContract(
        address _nftContractAddress,
        uint256 _tokenId,
        uint256 _marketid
    ) internal {
        address _nftSeller = marketInfo.getSeller(_nftContractAddress,_tokenId, _marketid);
        if(IERC1155(_nftContractAddress).balanceOf(_nftSeller, _tokenId) != 0){
            IERC1155(_nftContractAddress).safeTransferFrom(_nftSeller,address(this),_tokenId,1,"");
        } else if (IERC1155(_nftContractAddress).balanceOf(_nftSeller, _tokenId) == 0){
            revert ("Seller doesn't own NFT");
        }
    }


  function createNewNftAuction(localvars memory auction) external
        isAuctionNotStartedByOwner(auction._nftContractAddress, auction._tokenId, auction._lazymint)
        priceGreaterThanZero(auction._minPrice)
    {
        require(auction._bidIncreasePercentage >= 100, "Bid increase percentage too low"); //100 Equal 1%
        
        uint256 id = _saveAuction(auction);

         if (!auction._lazymint) {
            _transferNftToAuctionContract(auction._nftContractAddress, auction._tokenId, id);
        }
    }

    function _saveAuction(localvars memory auction) private returns (uint256 id){
        id = ++Marketid;

        marketInfo.saveAuction1155(auction._nftContractAddress, auction._tokenId, id, auction._erc20Token, auction._buyNowPrice, 
        auction._minPrice, auction._seller, auction._bidIncreasePercentage, auction._auctionBidPeriod, auction._lazymint);

        if(auction._feeRecipients != address(0)){
            marketInfo.saveRoyalties(auction._nftContractAddress, auction._tokenId, id, auction._feeRecipients, auction._feePercentages);
        }

        emit NftAuctionCreated(
            auction._nftContractAddress, 
            auction._tokenId,
            id,
            auction._seller,
            auction._erc20Token,
            auction._minPrice,
            auction._buyNowPrice,
            auction._auctionBidPeriod,
            auction._bidIncreasePercentage,
            auction._feeRecipients,
            auction._feePercentages,
            auction._lazymint
        );
    }
    

    ///@notice Allows for a standard sale mechanism.
    ///@dev For sale the min price must be 0
    ///@dev _isABidMade check if buyNowPrice is meet and conclude sale, otherwise reverse the early bid
 function createSale(localSell memory sell) public
        isAuctionNotStartedByOwner(sell._nftContractAddress, sell._tokenId, sell._lazymint)
        priceGreaterThanZero(sell._buyNowPrice)
    {
        uint256 id = _saveSell(sell);

        if (!sell._lazymint) {
            _transferNftToAuctionContract(sell._nftContractAddress, sell._tokenId, id);
        }     
    }

    function _saveSell(localSell memory sell) private returns (uint256 id){
        id = ++Marketid;
        
        marketInfo.saveSells1155(sell._nftContractAddress, sell._tokenId, id, sell._erc20Token, sell._buyNowPrice, sell._nftSeller, 
        sell._lazymint);

        if(sell._feeRecipients != address(0)){
            marketInfo.saveRoyalties(sell._nftContractAddress, sell._tokenId, id, sell._feeRecipients, sell._feePercentages);
        }
    
        emit SaleCreated(
            sell._nftContractAddress,
            sell._tokenId,
            id,
            sell._nftSeller,
            sell._erc20Token,
            sell._buyNowPrice,
            sell._feeRecipients,
            sell._feePercentages,
            sell._lazymint
        );
    }


    function batchsell(localSell memory sell, uint256 _quantity) public 
    isAuctionNotStartedByOwner(sell._nftContractAddress, sell._tokenId, sell._lazymint)
    priceGreaterThanZero(sell._buyNowPrice) {
        if (_quantity <= 1) {
            revert ("amount must exceed 1");
        }
        for(uint256 i = 0; i < _quantity;){
                createSale(sell);
            unchecked {
                ++i;
            }
        }
    }
    
    function saveIdData(address nftContract, uint256 tokenid, uint256 marketId) private {
        idData[nftContract][tokenid] = marketId;
    }

    function getIdData(address nftContract, uint256 tokenid) external view returns(uint256){
        return idData[nftContract][tokenid];
    }
    

    ///@notice Make bids with ETH or an ERC20 Token specified by the NFT seller.
    ///@notice Additionally, a buyer can pay the asking price to conclude a sale of an NFT.
     function makeBid(Bid memory bid) external payable {
        (address seller, uint256 pay, uint64 auctionEndTimestamp) = marketInfo.getBidInfo(bid._nftContractAddress, bid._tokenId, bid._marketid);
        bool _sign = false;
        if (bid._discount) {
            if(validate(bid._value, bid._coupon, bid._signature, seller, bid._nonce)){
                _sign = true;
            }
        }

        if(_sign){
            if(bid._value == 0){
                revert("Value not be zero");
            }else{
                bid._tokenAmount = pay >= bid._value ?  (pay - bid._value) : (bid._value - pay);
            }
        }
      
        if (auctionEndTimestamp != 0) {
            require((block.timestamp < auctionEndTimestamp),"Auction has ended");
        }

        require(msg.sender != seller, "Don't bid on your own NFT");
        require(_bidMeetBidRequirements(
                bid._nftContractAddress,
                bid._tokenId,
                bid._marketid,
                bid._tokenAmount,
                bid._value,
                _sign
            ),
            "Not enough funds to bid"
        );

        require(
            _isPaymentAccepted(
                bid._nftContractAddress,
                bid._tokenId,
                bid._marketid,
                bid._erc20Token,
                bid._tokenAmount,
                bid._value,
                _sign
            ),
            "Bid to be in specified ERC20/ETH"
        );

        _reversePreviousBidAndUpdateHighestBid(bid._nftContractAddress, bid._tokenId, bid._marketid, bid._tokenAmount);
        
        emit BidMade(
            bid._nftContractAddress,
            bid._tokenId,
            bid._marketid,
            msg.sender,
            msg.value,
            bid._erc20Token,
            bid._tokenAmount,
            bid._coupon
        );
        _updateOngoingAuction(bid._nftContractAddress, bid._tokenId, bid._marketid, _sign, bid._value);
    }

    ///@notice Settle an auction or sale if the buyNowPrice is met or set
    ///@dev min price not set, nft not up for auction yet
    function _updateOngoingAuction(
        address _nftContractAddress,
        uint256 _tokenId,
        uint256 _marketId,
        bool _sign,
        uint256 _value
    ) internal {
        (uint256 buyNowPrice,,) = marketInfo.bidrequiriments(_nftContractAddress,_tokenId, _marketId);
        if (_sign) {
            if (_value >= buyNowPrice) {
                _transferNFT(_nftContractAddress, _tokenId, _marketId);
            } else {
                _transferNftAndPaySeller(_nftContractAddress, _tokenId, _marketId, _value);
                return;
            }
        } else {
            if (_isBuyNowPriceMet(_nftContractAddress, _tokenId, _marketId)) {
                _transferNftAndPaySeller(_nftContractAddress, _tokenId, _marketId, 0);
                return;
            }
        }
    }

    ///@dev the auction end is always set to now + the bid period
    function _updateAuctionEnd(address _nftContractAddress, uint256 _tokenId, uint256 _marketId, uint32 _newBidPeriod) external{
        uint64 _auctionEnd = marketInfo.newBidPeriod(_nftContractAddress, _tokenId, _marketId, _newBidPeriod);
        emit AuctionPeriodUpdated(
            _nftContractAddress,
            _tokenId,
            _marketId,
            _auctionEnd
        );
    }


   function _reversePreviousBidAndUpdateHighestBid(
        address _nftContractAddress,
        uint256 _tokenId,
        uint256 _marketId,
        uint256 _tokenAmount
    ) internal {
        (address auctionERC20Token, address prevBidder,uint256 prevBid) = marketInfo.bidAndToken(_nftContractAddress, _tokenId, _marketId);

            if (auctionERC20Token != address(0)) {
                IERC20(auctionERC20Token).safeTransferFrom(msg.sender, address(this), _tokenAmount);
                marketInfo.setBid(_nftContractAddress,_tokenId, _marketId,_tokenAmount, msg.sender);
            } else {
                marketInfo.setBid(_nftContractAddress,_tokenId, _marketId,msg.value, msg.sender);
            }

            if (prevBidder != address(0)) {
                _payout(_nftContractAddress,_tokenId,_marketId,prevBidder,prevBid);
            }
    }

    function _transferNftAndPaySeller(
        address _nftContractAddress,
        uint256 _tokenId,
        uint256 _marketId,
        uint256 _value
    ) internal {
        (address _nftSeller, address _highestBidder, uint256 _highestBid, bool lazymint,)
        = marketInfo.getPayInfo(_nftContractAddress, _tokenId, _marketId);

        _payFeesAndSeller( _nftContractAddress,_tokenId, _marketId,_nftSeller,_highestBid, _value);

        if (!lazymint) {
            IERC1155(_nftContractAddress).safeTransferFrom(address(this),_highestBidder,_tokenId,1,"");
        } else {
            //This is the lazyminting function
            IERC1155(_nftContractAddress).create(_tokenId,_highestBidder,1);
        }

        marketInfo.resetAuction(_nftContractAddress,_tokenId, _marketId);
        marketInfo.resetBids(_nftContractAddress, _tokenId, _marketId);

        emit NFTTransferredAndSellerPaid(
            _nftContractAddress,
            _tokenId,
            _marketId,
            _nftSeller,
            _highestBid,
            _highestBidder
        );
    }

    function _transferNFT(address _nftContractAddress, uint256 _tokenId, uint256 _marketId)
        internal
    {
        (, address _highestBidder, , bool lazymint,)
        = marketInfo.getPayInfo(_nftContractAddress, _tokenId, _marketId);
        if (!lazymint) {
            IERC1155(_nftContractAddress).safeTransferFrom(address(this),_highestBidder,_tokenId,1,"");
        } else {
            //This is the lazyminting function
            IERC1155(_nftContractAddress).create(_tokenId,_highestBidder,1);
        }
        marketInfo.resetAuction(_nftContractAddress,_tokenId, _marketId);
        marketInfo.resetBids(_nftContractAddress, _tokenId, _marketId);
        emit NFTTransferred(_nftContractAddress, _tokenId, _highestBidder);
    }

    function _payFeesAndSeller(
        address _nftContractAddress,
        uint256 _tokenId,
        uint256 _marketId,
        address _nftSeller,
        uint256 _highestBid,
        uint256 _value
    ) internal {
        uint256 pay;
        if(_value != 0){
            pay = _highestBid >= _value ?  (_highestBid - _value) : (_value - _highestBid);
        }else{
            pay = _highestBid;
        }
        uint256 feesPaid = 0;
        uint256 minusfee = _getPortionOfBid(pay, feeMarket);
        
        uint256 subtotal = pay - minusfee;

        feesPaid = _payoutroyalties(_nftContractAddress, _tokenId, _marketId, subtotal);

        _payout( _nftContractAddress, _tokenId, _marketId, _nftSeller,(subtotal - feesPaid));

        sendpayment(_nftContractAddress, _tokenId, _marketId, minusfee);
    }

    function sendpayment(
        address _nftContractAddress,
        uint256 _tokenId,
        uint256 _marketId,
        uint256 minusfee
    ) internal {
        uint256 amount = minusfee;
        minusfee = 0;
        address auctionERC20Token = marketInfo.getToken(_nftContractAddress, _tokenId, _marketId);

        if (auctionERC20Token != address(0)) {
            IERC20(auctionERC20Token).safeTransfer(addressmarketfee, amount);
        } else {
            (bool success, ) = payable(addressmarketfee).call{value: amount}(
                ""
            );
            if (!success) {
                failedTransferCredits[addressmarketfee] = failedTransferCredits[addressmarketfee] + amount;
            }
        }
    }

    function _payoutroyalties(
        address _nftContractAddress,
        uint256 _tokenId,
        uint256 _marketId,
        uint256 subtotal
    ) internal returns (uint256) {
        (address _feeRecipients, uint32 _feePercentages) = marketInfo.getRoyalties(_nftContractAddress, _tokenId, _marketId);
        uint256 fee;
        if(_feeRecipients != address(0)){
        fee = _getPortionOfBid(subtotal,_feePercentages);

        _payout(_nftContractAddress, _tokenId, _marketId,_feeRecipients,fee);
        }
        return fee; 
    }

    ///@dev if the call failed, update their credit balance so they the seller can pull it later
    function _payout(
        address _nftContractAddress,
        uint256 _tokenId,
        uint256 _marketId,
        address _recipient,
        uint256 _amount
    ) internal {
        address auctionERC20Token = marketInfo.getToken(_nftContractAddress, _tokenId, _marketId);

        if (auctionERC20Token != address(0)) {
            IERC20(auctionERC20Token).safeTransfer(_recipient, _amount);
        } else {
            (bool success, ) = payable(_recipient).call{value: _amount}("");
            if (!success) {
                failedTransferCredits[_recipient] = failedTransferCredits[_recipient] + _amount;
            }
        }
    }

    function settleAuction(address _nftContractAddress, uint256 _tokenId, uint256 _marketId)
        external
    {
        uint64 auctionEndTimestamp = marketInfo.getEndAuctionInfo(_nftContractAddress, _tokenId, _marketId);
        require(
            (block.timestamp > auctionEndTimestamp), "Auction has not ended");
        _transferNftAndPaySeller(_nftContractAddress, _tokenId, _marketId,0);
        emit AuctionSettled(_nftContractAddress, _tokenId, msg.sender);
    }

    ///@dev Only the owner of the NFT can prematurely close the sale or auction.
    function withdrawAuction(address _nftContractAddress, uint256 _tokenId, uint256 _marketId)
        external
    {   
        (address _nftSeller, address _highestBidder,, bool lazymint, )
        = marketInfo.getPayInfo(_nftContractAddress, _tokenId,_marketId);
        require(_highestBidder == address(0) && _nftSeller == msg.sender, "cannot cancel an auction");

        if (lazymint) {
            marketInfo.resetAuction(_nftContractAddress,_tokenId, _marketId);
            marketInfo.resetBids(_nftContractAddress, _tokenId, _marketId);
        } else {
            uint256 balance = IERC1155(_nftContractAddress).balanceOf(address(this), _tokenId);
            if (balance != 0 ) {
                IERC1155(_nftContractAddress).safeTransferFrom(address(this),_nftSeller,_tokenId,1,"");
            }
            marketInfo.resetAuction(_nftContractAddress,_tokenId, _marketId);
            marketInfo.resetBids(_nftContractAddress, _tokenId, _marketId);
        }
        emit AuctionWithdrawn(_nftContractAddress, _tokenId, msg.sender);
    }

    function updateMinimumPrice(
        address _nftContractAddress,
        uint256 _tokenId,
        uint256 _marketid,
        uint256 _newMinPrice
    ) public priceGreaterThanZero(_newMinPrice) {
        (address _nftSeller, address _highestBidder,, uint256 minprice)
        = marketInfo.getMinimumPrice(_nftContractAddress, _tokenId, _marketid);

        require(msg.sender == _nftSeller,"Only nft seller");

        require(minprice != 0, "Not applicable a sale");

        require(_highestBidder == address(0), "auction with bidder");

        marketInfo.updateMiniumPrice(_nftContractAddress, _tokenId, _marketid, _newMinPrice);

        emit MinimumPriceUpdated(_nftContractAddress, _tokenId, _newMinPrice);
    }

    function updateBuyNowPrice(
        address _nftContractAddress,
        uint256 _tokenId,
        uint256 _marketid,
        uint256 _newBuyNowPrice
    ) external priceGreaterThanZero(_newBuyNowPrice) {

        (address _nftSeller, , bool lazymint,) = marketInfo.getMinimumPrice(_nftContractAddress, _tokenId, _marketid);

        require(msg.sender == _nftSeller,"Only nft seller");

        marketInfo.updateBuynowPrice(_nftContractAddress, _tokenId, _marketid, _newBuyNowPrice);

        emit BuyNowPriceUpdated(_nftContractAddress, _tokenId, _newBuyNowPrice);

        if (_isBuyNowPriceMet(_nftContractAddress, _tokenId, _marketid)) {
            if (!lazymint) {
                _transferNftToAuctionContract(_nftContractAddress, _tokenId, _marketid);
            }
                _transferNftAndPaySeller(_nftContractAddress, _tokenId, _marketid, 0);
        }
    }

    ///@notice The NFT seller can opt to end an auction by taking the current highest bid.
    function takeHighestBid(address _nftContractAddress, uint256 _tokenId, uint256 _marketid) external {

        (address _nftSeller,, uint256 _highestBid, bool lazymint,) = marketInfo.getPayInfo(_nftContractAddress, _tokenId, _marketid);

        require(msg.sender == _nftSeller, "Only nft seller");

        require(_highestBid > 0, "cannot payout 0 bid");
      
        if (!lazymint) {
            _transferNftToAuctionContract(_nftContractAddress, _tokenId, _marketid);
        }
        _transferNftAndPaySeller(_nftContractAddress, _tokenId, _marketid, 0);

        emit HighestBidTaken(_nftContractAddress, _tokenId);
    }

    ///@notice If the transfer of a bid has failed, allow the recipient to reclaim their amount later.
    function withdrawAllFailedCredits() external {
        uint256 amount = failedTransferCredits[msg.sender];

        require(amount != 0, "no credits to withdraw");

        failedTransferCredits[msg.sender] = 0;

        (bool successfulWithdraw, ) = msg.sender.call{value: amount}("");
        require(successfulWithdraw, "withdraw failed");
    }

    function getFailedCredits() external view returns(uint256 _amount){  
        return failedTransferCredits[msg.sender];
    }
    
    function getMarketId() external view returns(uint256) {
        return Marketid;
    }


    function updateMarketAddress(address _marketfee) external admin {
        addressmarketfee = payable(_marketfee);
    }

    function onERC1155Received(
        address,
        address,
        uint256,
        uint256,
        bytes calldata
    ) external virtual returns (bytes4) {
        return this.onERC1155Received.selector;
    }
}
//SPDX-License-Identifier: MIT
pragma solidity 0.8.15;

abstract contract MarketEventsV2 {
    /*///////////////////////////////////////////////////////////////
                              EVENTS            
    //////////////////////////////////////////////////////////////*/

    event NftAuctionCreated(
        address nftContractAddress,
        uint256 tokenId,
        uint256 marketId,
        address nftSeller,
        address erc20Token,
        uint256 minPrice,
        uint256 buyNowPrice,
        uint32 auctionBidPeriod,
        uint32 bidIncreasePercentage,
        address feeRecipients,
        uint32 feePercentages,
        bool lazymint
    );

    event SaleCreated(
        address nftContractAddress,
        uint256 tokenId,
        uint256 marketId,
        address nftSeller,
        address erc20Token,
        uint256 buyNowPrice,
        address feeRecipients,
        uint32 feePercentages,
        bool lazymint
    );

    event BidMade(
        address nftContractAddress,
        uint256 tokenId,
        uint256 marketId,
        address bidder,
        uint256 ethAmount,
        address erc20Token,
        uint256 tokenAmount,
        uint256 coupon
    );

    event AuctionPeriodUpdated(
        address nftContractAddress,
        uint256 tokenId,
        uint256 marketId,
        uint64 auctionEndPeriod
    );

    event NFTTransferredAndSellerPaid(
        address nftContractAddress,
        uint256 tokenId,
        uint256 marketId,
        address nftSeller,
        uint256 nftHighestBid,
        address nftHighestBidder
    );

    event AuctionWithdrawn(
        address nftContractAddress,
        uint256 tokenId,
        address nftOwner
    );

    event MinimumPriceUpdated(
        address nftContractAddress,
        uint256 tokenId,
        uint256 newMinPrice
    );

    event BuyNowPriceUpdated(
        address nftContractAddress,
        uint256 tokenId,
        uint256 newBuyNowPrice
    );
    event HighestBidTaken(address nftContractAddress, uint256 tokenId);

    event AuctionSettled(
        address nftContractAddress,
        uint256 tokenId,
        address auctionSettler
    );

    event NFTTransferred(
        address nftContractAddress,
        uint256 tokenId,
        address nftHighestBidder
    );

    /*///////////////////////////////////////////////////////////////
                              END EVENTS            
    //////////////////////////////////////////////////////////////*/
}

//SPDX-License-Identifier: MIT
pragma solidity 0.8.15;

abstract contract MarketStruct {

 struct Auction {
        uint32 bidIncreasePercentage;
        uint32 auctionBidPeriod;
        uint64 auctionEnd;
        uint256 minPrice;
        uint256 buyNowPrice;
        uint256 nftHighestBid;
        address nftHighestBidder;
        address nftSeller;
        address ERC20Token;
        address feeRecipients;
        uint32 feePercentages;
        bool lazymint;
        string metadata;
    }

    struct localvars{
        address _nftContractAddress;
        address _seller;
        uint256 _tokenId;
        address _erc20Token;
        uint256 _minPrice;
        uint256 _buyNowPrice;
        uint32 _auctionBidPeriod;
        uint32 _bidIncreasePercentage;
        address _feeRecipients;
        uint32 _feePercentages;
        bool _lazymint;
    }

    struct localSell{
        address _nftContractAddress;
        uint256 _tokenId;
        address _erc20Token;
        uint256 _buyNowPrice;
        address _nftSeller;
        address _feeRecipients;
        uint32 _feePercentages;
        bool _lazymint;
    }

    struct Bid {
        address _nftContractAddress;
        uint256 _tokenId;
        uint256 _marketid;
        address _erc20Token;
        uint256 _tokenAmount;
        uint256 _value;
        uint256 _coupon;
        bytes _signature;
        uint256 _nonce;
        bool _discount;
    }
}// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/utils/introspection/IERC165.sol";

interface IERC1155 is IERC165 {
 
    function balanceOf(address account, uint256 id) external view returns (uint256);

    function balanceOfBatch(address[] calldata accounts, uint256[] calldata ids)
        external
        view
        returns (uint256[] memory);

    function getMaxSupply(uint256 _id) external view returns(uint256);

    function getAdmin() external view returns(address);

    function setApprovalForAll(address operator, bool approved) external;

    function isApprovedForAll(address account, address operator) external view returns (bool);

    function create(uint256 id,address _user,uint256 amount) external;

    function createBatch(uint256[] calldata ids,address _user, uint256[] calldata amounts) external;

    function burnMyNFT(address _burner, uint256 _tokenid, uint256 amount) external returns(uint256);
   
    function safeTransferFrom(
        address from,
        address to,
        uint256 id,
        uint256 amount,
        bytes calldata data
    ) external;

    function safeBatchTransferFrom(
        address from,
        address to,
        uint256[] calldata ids,
        uint256[] calldata amounts,
        bytes calldata data
    ) external;

    function uri(uint256 tokenId) external view returns (string memory);
}
//SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import "./Optionmintcontracts/IERC1155.sol";

abstract contract verification {
    ///@dev Returns the percentage of the total bid (used to calculate fee payments)
    function _getPortionOfBid(uint256 _totalBid, uint256 _percentage)
        internal
        pure
        returns (uint256)
    {
        return (_totalBid * (_percentage)) / 10000;
    }

    modifier priceGreaterThanZero(uint256 _price) {
        require(_price > 0, "Price cannot be 0");
        _;
    }

    modifier isFeePercentagesLessThanMaximum(uint32[] memory _feePercentages) {
        uint32 totalPercent;
        for (uint256 i = 0; i < _feePercentages.length; i++) {
            totalPercent = totalPercent + _feePercentages[i];
        }
        require(totalPercent <= 10000, "Fee percentages exceed maximum");
        _;
    }

    function metadata(address _nftcontract, uint256 _nftid)
        internal
        view
        returns ( string memory)
    {
        return IERC1155(_nftcontract).uri(_nftid);
    }
}
// SPDX-License-Identifier: MIT

pragma solidity ^0.8.5;

import "@openzeppelin/contracts/utils/cryptography/draft-EIP712.sol";
import "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";

abstract contract VerifySignature is EIP712 {
    error invalidsignature();
    error invalidcoupon();
    error addressZero();
    error redeemedcoupon();

    string private SIGNING_DOMAIN = "Market Coupons";
    string private SIGNATURE_VERSION = "1";

    mapping(bytes => bool) public couponsregistry;

    constructor() EIP712(SIGNING_DOMAIN, SIGNATURE_VERSION) {}

    function validate(
        uint256 _value,
        uint256 _coupon,
        bytes memory _signature,
        address _owner,
        uint256 _nonce
    ) internal returns (bool) {
        if (couponsregistry[_signature] == true) {
            revert redeemedcoupon();
        }
        //_domainSeparator();
        if (!check(_value, _coupon, _signature, _owner, _nonce)) {
            revert invalidcoupon();
        }
        couponsregistry[_signature] = true;

        return true;
    }

    function check(
        uint256 _value,
        uint256 _coupon,
        bytes memory _signature,
        address _owner,
        uint256 _nonce
    ) internal view returns (bool) {
        return _verify(_value, _coupon, _signature, _owner, _nonce);
    }

    function _verify(
        uint256 _value,
        uint256 _coupon,
        bytes memory _signature,
        address _owner,
        uint256 _nonce
    ) internal view returns (bool) {
        bytes32 _digest = _hash(_value, _coupon, _nonce);
        address signer = ECDSA.recover(_digest, _signature);
        if (signer != _owner) {
            return false;
        }
        if (signer == address(0)) {
            revert addressZero();
        }
        return true;
    }

    function _hash(
        uint256 _value,
        uint256 _coupon,
        uint256 _nonce
    ) internal view returns (bytes32) {
        return
            _hashTypedDataV4(
                keccak256(
                    abi.encode(
                        keccak256(
                            "MarketCoupons(uint256 value,uint256 coupon,uint256 nonce)"
                        ),
                        _value,
                        _coupon,
                        _nonce
                    )
                )
            );
    }
}
