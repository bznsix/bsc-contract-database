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
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "@openzeppelin/contracts/security/Pausable.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
// import "@openzeppelin/contracts/interfaces/IERC165.sol";
// import "hardhat/console.sol";

contract Onlybrains is Pausable, AccessControl {
    bytes32 public constant PAUSER_ROLE = keccak256("PAUSER_ROLE");
    bytes32 public constant SESSION_CLOSER_ROLE = keccak256("SESSION_CLOSER_ROLE");
    bytes32 public constant SESSION_OPENER_ROLE = keccak256("SESSION_OPENER_ROLE");
    bytes32 public constant BLACKLISTED_USER_ROLE = keccak256("BLACKLISTED_USER_ROLE");
    bytes32 public constant COMMISSION_WITHDRAWER_ROLE = keccak256("COMMISSION_WITHDRAWER_ROLE");
    bytes32 public constant SESSION_MODIFIER_ROLE = keccak256("SESSION_MODIFIER_ROLE");

    constructor() {
        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
        _grantRole(PAUSER_ROLE, msg.sender);
    }


    struct Player {
        address account;
        uint reportTS;
        uint score;
        bytes32 sha256hash;
        bool resultUploaded;
        uint256 reward;
        bool checked;
    }

    struct GameSession { 
        uint gameID;
        uint startTimestamp; //think about explicit allowance to start session funding/gaming via dedicated actions. To avoid using timestamps
        uint endTimestamp;
        bytes32 secret;
        bool finished;
        bool commissionWithdrawn;

        uint256 requiredStake;
        address tokenContract;
        uint8 taxPercent;
        uint256 stake;

        Player[] players;
    }
    struct SessionPermissions {
        uint32 playersCountLimit;
        mapping(address=>bool) allowlist;
        bool hasAllowlist;
        mapping(address=>bool) blocklist;
    }
    mapping(uint16 => SessionPermissions) public sessionPermissionsStorage;
    mapping(uint => uint16) public sessionPermissionsMapping;
    mapping(uint => mapping(address => uint)) private sessionsPlayersMap;
    mapping(address => uint[]) private playerSessionsMap;
    mapping(uint => uint[]) private gameSessionsMap; 

    GameSession[] private sessions;


    function pause() public onlyRole(PAUSER_ROLE) {
        _pause();
    }

    function unpause() public onlyRole(PAUSER_ROLE) {
        _unpause();
    }
    error NotParticipating(address player, uint sessionID);
    error AlreadyParticipating(address player, uint sessionID);
    error SessionNotFound(uint sessionID);
    error SessionAlreadyExists(uint sessionID);
    error ResultAlreadyReported(address player, uint sessionID);
    error SessionNotActive(uint sessionID);
    error BadSessionTimeInterval(uint current, uint start, uint end);
    error SessionNotFinished(uint sessionID);
    error AlreadyWithdrawn(uint sessionID);
    error StakeFailed(address player, uint sessionID, uint stake, address token);
    error Blacklisted(address player);
    error PlayersCountLimitReached(uint sessionID);
    error NotAllowedForSession(uint sessionID, address player);
    error WithdrawalFailed(uint sessionID);

    function findSession(uint sessionID) private view returns (GameSession storage) {
        if(sessionID >= sessions.length) revert SessionNotFound(sessionID);
        return sessions[sessionID];
    }

    function checkParticipationAllowed(uint sessionID, address user) private view returns (bool) {
        if(sessionPermissionsMapping[sessionID] == 0) return true;
        GameSession storage session = findSession(sessionID);
        SessionPermissions storage perm = sessionPermissionsStorage[sessionPermissionsMapping[sessionID]];

        if(perm.playersCountLimit > 0 && session.players.length >= perm.playersCountLimit) revert PlayersCountLimitReached(sessionID);
        else if(perm.hasAllowlist && perm.allowlist[user] != true || perm.blocklist[user] == true) revert NotAllowedForSession(sessionID, user);
        return true;
    }

    function updateSessionPermissionsEntry(uint16 id, address[] calldata allowlist, address[] calldata blocklist, uint32 playersCountLimit) public whenNotPaused() onlyRole(SESSION_MODIFIER_ROLE) {
        SessionPermissions storage session = sessionPermissionsStorage[id];
        if(allowlist.length > 0) {
            session.hasAllowlist = true;
            for(uint i = 0; i < allowlist.length; i ++) {
                session.allowlist[allowlist[i]] = true;
            }
        } else {
            session.hasAllowlist = false;
        }
        for(uint i = 0; i < blocklist.length; i ++) {
            session.blocklist[blocklist[i]] = true;
        }
        session.playersCountLimit = playersCountLimit;
    }

    function setSessionPermissions(uint sessionID, uint16 permissionsID) public whenNotPaused() onlyRole(SESSION_MODIFIER_ROLE) {
        sessionPermissionsMapping[sessionID] = permissionsID;
    }
    
    event ScoreSent(
        uint id,
        address player,
        uint score,
        bytes32 hash
    );

    function putScore(uint sessionID, uint score,  bytes32 hash) public whenNotPaused() {
        if(hasRole(BLACKLISTED_USER_ROLE, msg.sender)) {
            revert Blacklisted(msg.sender);
        }

        GameSession storage session = findSession(sessionID);
        if(session.startTimestamp > block.timestamp || block.timestamp > session.endTimestamp || session.finished) revert SessionNotActive(sessionID);

        uint existingParticipantIndex = sessionsPlayersMap[sessionID][msg.sender];
        if(existingParticipantIndex == 0) revert NotParticipating(msg.sender, sessionID);

        Player storage player = session.players[existingParticipantIndex - 1];
        // if(player.resultUploaded) revert ResultAlreadyReported(msg.sender, sessionID);
        player.resultUploaded = true;
        player.score = score;
        player.sha256hash = hash;
        player.reportTS = block.timestamp;

        emit ScoreSent(sessionID, msg.sender, score, hash);
    }

    event NewSession(
        uint id
    );

    function createSession(uint gameID, uint startTS, uint endTS, uint256 requiredStake, address tokenContract, uint8 taxPercent) public whenNotPaused() onlyRole(SESSION_OPENER_ROLE) {
        if(startTS >= endTS || endTS <= block.timestamp || startTS == 0 || endTS == 0) revert BadSessionTimeInterval(block.timestamp, startTS, endTS);
        uint newId = sessions.length;

        GameSession storage session = sessions.push();

        session.endTimestamp = endTS;
        session.finished = false;
        session.commissionWithdrawn = false;
        session.gameID = gameID;
        session.requiredStake = requiredStake;
        session.startTimestamp = startTS;
        session.taxPercent = taxPercent > 100 ? 100: taxPercent;
        session.tokenContract = tokenContract;
        session.stake = 0;
        gameSessionsMap[gameID].push(newId);

        emit NewSession(newId);
    }

    event NewParticipation(
        uint id,
        address player
    );
    event SessionStakeChanged(uint sessionID, address from, uint delta, uint total);

    function participate(uint sessionID) public whenNotPaused() {
        if(hasRole(BLACKLISTED_USER_ROLE, msg.sender)) {
            revert Blacklisted(msg.sender);
        }
        GameSession storage session = findSession(sessionID);
        if(block.timestamp >= session.endTimestamp || session.finished) revert SessionNotActive(sessionID);
        checkParticipationAllowed(sessionID, msg.sender);

        uint existingParticipantIndex = sessionsPlayersMap[sessionID][msg.sender];
        if(existingParticipantIndex > 0) revert AlreadyParticipating(msg.sender, sessionID);

        Player storage newPlayer = session.players.push();

        newPlayer.account = msg.sender;
        newPlayer.checked = false;
        newPlayer.reportTS = 0;
        newPlayer.resultUploaded = false;
        newPlayer.reward = 0;
        newPlayer.score = 0;
        newPlayer.sha256hash = "";

        sessionsPlayersMap[sessionID][msg.sender] = session.players.length;

        playerSessionsMap[msg.sender].push(sessionID);

        bool transferOk = false;
        try IERC20(session.tokenContract).transferFrom(msg.sender, address(this), session.requiredStake) returns (bool success) {
            transferOk = success;
        } catch {
            transferOk = false;
        }
        if(!transferOk) {
            revert StakeFailed(msg.sender, sessionID, session.requiredStake, session.tokenContract);
        } 
        session.stake += session.requiredStake;
        emit NewParticipation(sessionID, msg.sender);
        emit SessionStakeChanged(sessionID, msg.sender, session.requiredStake, session.stake);
    }

    function comparePlayers(Player[] memory players,  uint l, uint r) private pure returns (bool) {
        if(players[l].score != players[r].score) {
            return players[l].score > players[r].score;
        } else {
            return players[l].reportTS < players[r].reportTS;
        }
    }

    function quickSort(Player[] memory players, uint[] memory arr, int left, int right) private pure {
        int i = left;
        int j = right;
        if (i == j) return;
        uint pivot = arr[uint(left + (right - left) / 2)];
        while (i <= j) {
            while (comparePlayers(players, arr[uint(i)], pivot)) i++;
            while (comparePlayers(players, pivot, arr[uint(j)])) j--;
            if (i <= j) {
                (arr[uint(i)], arr[uint(j)]) = (arr[uint(j)], arr[uint(i)]);
                i++;
                j--;
            }
        }
        if (left < j)
            quickSort(players, arr, left, j);
        if (i < right)
            quickSort(players, arr, i, right);
    }

    event RevealedSession(
        uint id
    );

    event PaymentFailed(uint sessionID, address player, uint256 reward);
    event PlayerResult(uint sessionID, address player, uint stake, bool score_uploaded, bool checked, uint rank, uint reward);
    //TODO: https://fravoll.github.io/solidity-patterns/pull_over_push.html
    // dangerous to do it this way, if participant fails to receive for any reason, session will not be ever able to be revealed!
    function revealSession(uint sessionID, bytes32 secret) public whenNotPaused() onlyRole(SESSION_CLOSER_ROLE) {
        GameSession storage session = findSession(sessionID);

        if(session.finished) revert SessionNotActive(sessionID);
        if(session.endTimestamp >= block.timestamp)  {
            revert SessionNotFinished(sessionID);
            
        }

        session.finished = true;
        session.secret = secret;
        uint256 totalStake = session.stake;

        uint checkedCount = 0;
        for(uint i = 0; i < session.players.length; i ++) {
            Player storage player = session.players[i];
            if(player.resultUploaded && ! hasRole(BLACKLISTED_USER_ROLE, player.account)) {
                bytes memory toHash = bytes.concat(abi.encodePacked(player.account), abi.encodePacked(sessionID), abi.encodePacked(player.score), abi.encodePacked(secret));
                // console.logBytes(toHash);

                if(player.sha256hash == sha256(toHash)) {
                    player.checked = true;
                    checkedCount ++;
                } else {
                    emit PlayerResult(sessionID, player.account, session.requiredStake, true, false, 0, 0);
                }
            } else {
                emit PlayerResult(sessionID, player.account, session.requiredStake, false, false, 0, 0);
            }
        }
        if(checkedCount > 0) {           
            uint[] memory checkedPlayersIndexes = new uint[](checkedCount);
            uint j = 0;
            for(uint i = 0; i < session.players.length; i ++) {
                if(session.players[i].checked) {
                    checkedPlayersIndexes[j] = i;
                    j++;
                }
            }
            quickSort(session.players, checkedPlayersIndexes, 0, int256(checkedCount - 1));

            totalStake = (totalStake * (100 - session.taxPercent) ) / 100;
            uint256 totalStakeRemains = totalStake;

            totalStake = totalStake * (300*(1 + checkedCount)*(2 + checkedCount)*(3 + checkedCount)*(4 + checkedCount)*(5 + checkedCount)) / 
                (checkedCount*(10538 + 15525*checkedCount + 8045*checkedCount*checkedCount + 1755*checkedCount*checkedCount*checkedCount + 137*checkedCount*checkedCount*checkedCount*checkedCount));

           
            for(uint i = 0; i < checkedPlayersIndexes.length; i ++) {
                uint rank = i + 1;
                uint256 reward = totalStake / rank / (rank + 5);

                if(reward > totalStakeRemains) {
                    reward = totalStakeRemains;
                }
                
                if(reward > 0) {
                    
                    totalStakeRemains -= reward;
                    address acc  = session.players[checkedPlayersIndexes[i]].account;
                    
                    try IERC20(session.tokenContract).transfer(acc, reward) returns (bool success) {
                        if(!success) {
                            emit PaymentFailed(sessionID, acc, reward);
                        } else {
                            session.players[checkedPlayersIndexes[i]].reward = reward;
                            emit PlayerResult(sessionID, acc, session.requiredStake, true, true, rank, reward);
                        }
                    } catch {
                        emit PaymentFailed(sessionID, acc, reward);
                    }
                }           
            }
        }
        emit RevealedSession(sessionID);
    }
    function sessionsCount() public view returns (uint) {
        return sessions.length;
    }

    struct GameSessionInfo { 
        GameSession session;
        uint playersCount;
        uint id;
    }
    function extendedSessionInfo(GameSession storage session, uint id) private view returns (GameSessionInfo memory) {
        GameSessionInfo memory ret;
        ret.session = session;
        ret.playersCount = session.players.length;
        ret.id = id;
        return ret;
    }
    function sessionInfo(uint sessionID) public view returns (GameSessionInfo memory) {
        return extendedSessionInfo(findSession(sessionID), sessionID);
    }

    function sessionsInfo(uint from, uint to) public view returns (GameSessionInfo[] memory) {
        uint l = sessions.length;
        if(l == 0) return new GameSessionInfo[](0);
        if(from >= l) from = l - 1;
        if(to > l) to = l;
        if(to < from) to = from;
        GameSessionInfo[] memory ret = new GameSessionInfo[](to-from);
        for(uint i = 0; i < to-from ; i ++) {
            ret[i] = sessionInfo(i+from);
        }
        return ret;
    }

    function sessionPlayersCount(uint sessionID) public view returns (uint) {
        GameSession storage session = findSession(sessionID);
        return session.players.length;
    }

    function sessionPlayers(uint sessionID, uint from, uint to) public view returns (Player[] memory) {
        GameSession storage session = findSession(sessionID);
        uint l = session.players.length;
        if(l == 0) return new Player[](0);
        if(from >= l) from = l - 1;
        if(to > l) to = l;
        if(to < from) to = from;
        Player[] memory ret = new Player[](to-from);
        
        for(uint i = 0; i < to-from ; i ++) {
            ret[i] = session.players[i+from];
        }
        return ret;
    }

    function sessionPlayer(uint sessionID, address player) public view returns (Player memory) {
        GameSession storage session = findSession(sessionID);
        uint existingParticipantIndex = sessionsPlayersMap[sessionID][player];
        if(existingParticipantIndex == 0) revert NotParticipating(player, sessionID);
        return session.players[existingParticipantIndex - 1];
    }

    function playerSessionsCount(address player) public view returns (uint) {
        return playerSessionsMap[player].length;
    }

    function playerSessions(address player, uint from, uint to) public view returns (GameSessionInfo[] memory) {
        uint l = playerSessionsMap[player].length;
        if(l == 0) return new GameSessionInfo[](0);
        if(from >= l) from = l - 1;
        if(to > l) to = l;
        if(to < from) to = from;
        GameSessionInfo[] memory ret = new GameSessionInfo[](to-from);
     
        for(uint i = 0; i < to-from ; i ++) {
            ret[i] = extendedSessionInfo(findSession(playerSessionsMap[player][i+from]), playerSessionsMap[player][i+from]);
        }
        return ret;
    }

    function gameSessionsCount(uint gameID) public view returns (uint) {
        return gameSessionsMap[gameID].length; //NEED TO RETURN exception here
    }

    function gameSessions(uint gameID, uint from, uint to) public view returns (GameSessionInfo[] memory) {
        uint l = gameSessionsMap[gameID].length; //todo
        if(l == 0) return new GameSessionInfo[](0);
        if(from >= l) from = l - 1;
        if(to > l) to = l;
        if(to < from) to = from;
        GameSessionInfo[] memory ret = new GameSessionInfo[](to-from);
        for(uint i = 0; i < to-from ; i ++) {
            ret[i] = extendedSessionInfo(findSession(gameSessionsMap[gameID][i+from]), gameSessionsMap[gameID][i+from]);              
        }
        return ret;
    }

    function withdrawCommission(uint sessionID, address target) public whenNotPaused() onlyRole(COMMISSION_WITHDRAWER_ROLE) {
        GameSession storage session = findSession(sessionID);
        if(!session.finished) revert SessionNotFinished(sessionID);
        if(session.commissionWithdrawn) revert AlreadyWithdrawn(sessionID);
        session.commissionWithdrawn = true;
        uint256 totalStake = session.stake;
        uint256 totalReward = 0;
        for(uint i = 0; i < session.players.length; i ++) {
            Player storage player = session.players[i];
            if(player.resultUploaded && player.checked) {
                totalReward += player.reward;
            }
        }
        if(totalStake < totalReward) {
            revert("CRITICAL ERROR");
        }
        try IERC20(session.tokenContract).transfer(target, totalStake - totalReward) returns (bool success) {
            if(!success) {
                revert WithdrawalFailed(sessionID);
            } 
        } catch {
            revert WithdrawalFailed(sessionID);
        }
    }

    function addToSessionStake(uint sessionID, uint256 amount) public whenNotPaused() onlyRole(SESSION_MODIFIER_ROLE) {
        GameSession storage session = findSession(sessionID);
        if(block.timestamp >= session.endTimestamp || session.finished) revert SessionNotActive(sessionID);

        bool transferOk = false;
        try IERC20(session.tokenContract).transferFrom(msg.sender, address(this), amount) returns (bool success) {
            transferOk = success;
        } catch {
            transferOk = false;
        }
        if(!transferOk) {
            revert StakeFailed(msg.sender, sessionID, amount, session.tokenContract);
        } 
        session.stake += amount;
        emit SessionStakeChanged(sessionID, msg.sender, amount, session.stake);

    }
}
