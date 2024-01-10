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
pragma solidity ^0.8.0;

interface IAdapter {
    function name() external view returns (string memory);

    function swapGasEstimate() external view returns (uint256);

    function tokensTo(
        address _tokenIn,
        address _tokenOut
    ) external view returns (address);

    function swap(uint256, uint256, address, address, address) external;

    function swapUnsafe(uint256, uint256, address, address, address) external;

    function query(uint256, address, address) external view returns (uint256);
}
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IERC20 {
    event Approval(address, address, uint256);
    event Transfer(address, address, uint256);

    function name() external view returns (string memory);

    function decimals() external view returns (uint8);

    function transferFrom(
        address,
        address,
        uint256
    ) external returns (bool);

    function allowance(address, address) external view returns (uint256);

    function approve(address, uint256) external returns (bool);

    function transfer(address, uint256) external returns (bool);

    function balanceOf(address) external view returns (uint256);

    function nonces(address) external view returns (uint256); // Only tokens that support permit

    function permit(
        address,
        address,
        uint256,
        uint256,
        uint8,
        bytes32,
        bytes32
    ) external; // Only tokens that support permit

    function swap(address, uint256) external; // Only Avalanche bridge tokens

    function swapSupply(address) external view returns (uint256); // Only Avalanche bridge tokens

    function totalSupply() external view returns (uint256);
}
//       ╟╗                                                                      ╔╬
//       ╞╬╬                                                                    ╬╠╬
//      ╔╣╬╬╬                                                                  ╠╠╠╠╦
//     ╬╬╬╬╬╩                                                                  ╘╠╠╠╠╬
//    ║╬╬╬╬╬                                                                    ╘╠╠╠╠╬
//    ╣╬╬╬╬╬╬╬╬╬╬╬╬╬╬╬      ╒╬╬╬╬╬╬╬╜   ╠╠╬╬╬╬╬╬╬         ╠╬╬╬╬╬╬╬    ╬╬╬╬╬╬╬╬╠╠╠╠╠╠╠╠
//    ╙╬╬╬╬╬╬╬╬╬╬╬╬╬╬╬╬╕    ╬╬╬╬╬╬╬╜   ╣╠╠╬╬╬╬╬╬╬╬        ╠╬╬╬╬╬╬╬   ╬╬╬╬╬╬╬╬╬╠╠╠╠╠╠╠╩
//     ╙╣╬╬╬╬╬╬╬╬╬╬╬╬╬╬╬  ╔╬╬╬╬╬╬╬    ╔╠╠╠╬╬╬╬╬╬╬╬        ╠╬╬╬╬╬╬╬ ╣╬╬╬╬╬╬╬╬╬╬╬╠╠╠╠╝╙
//               ╘╣╬╬╬╬╬╬╬╬╬╬╬╬╬╬    ╒╠╠╠╬╠╬╩╬╬╬╬╬╬       ╠╬╬╬╬╬╬╬╣╬╬╬╬╬╬╬╙
//                 ╣╬╬╬╬╬╬╬╬╬╬╠╣     ╣╬╠╠╠╬╩ ╚╬╬╬╬╬╬      ╠╬╬╬╬╬╬╬╬╬╬╬╬╬╬
//                  ╣╬╬╬╬╬╬╬╬╬╣     ╣╬╠╠╠╬╬   ╣╬╬╬╬╬╬     ╠╬╬╬╬╬╬╬╬╬╬╬╬╬╬
//                   ╟╬╬╬╬╬╬╬╩      ╬╬╠╠╠╠╬╬╬╬╬╬╬╬╬╬╬     ╠╬╬╬╬╬╬╬╠╬╬╬╬╬╬╬
//                    ╬╬╬╬╬╬╬     ╒╬╬╠╠╬╠╠╬╬╬╬╬╬╬╬╬╬╬╬    ╠╬╬╬╬╬╬╬ ╣╬╬╬╬╬╬╬
//                    ╬╬╬╬╬╬╬     ╬╬╬╠╠╠╠╝╝╝╝╝╝╝╠╬╬╬╬╬╬   ╠╬╬╬╬╬╬╬  ╚╬╬╬╬╬╬╬╬
//                    ╬╬╬╬╬╬╬    ╣╬╬╬╬╠╠╩       ╘╬╬╬╬╬╬╬  ╠╬╬╬╬╬╬╬   ╙╬╬╬╬╬╬╬╬
//

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;


struct Query {
    address adapter;
    address tokenIn;
    address tokenOut;
    uint256 amountOut;
}
struct Offer {
    bytes amounts;
    bytes adapters;
    bytes path;
    uint256 gasEstimate;
}
struct FormattedOffer {
    uint256[] amounts;
    address[] adapters;
    address[] path;
    uint256 gasEstimate;
}
struct Trade {
    uint256 amountIn;
    uint256 amountOut;
    address[] path;
    address[] adapters;
}

interface IViralataRouter {

    event UpdatedTrustedTokens(address[] _newTrustedTokens);
    event UpdatedAdapters(address[] _newAdapters);
    event UpdatedMinFee(uint256 _oldMinFee, uint256 _newMinFee);
    event UpdatedFeeClaimer(address _oldFeeClaimer, address _newFeeClaimer);
    event ViralataSwap(address indexed _tokenIn, address indexed _tokenOut, uint256 _amountIn, uint256 _amountOut);

    // admin
    function setTrustedTokens(address[] memory _trustedTokens) external;
    function setAdapters(address[] memory _adapters) external;
    function setFeeClaimer(address _claimer) external;
    function setMinFee(uint256 _fee) external;

    // misc
    function trustedTokensCount() external view returns (uint256);
    function adaptersCount() external view returns (uint256);

    // query

    function queryAdapter(
        uint256 _amountIn,
        address _tokenIn,
        address _tokenOut,
        uint8 _index
    ) external returns (uint256);

    function queryNoSplit(
        uint256 _amountIn,
        address _tokenIn,
        address _tokenOut,
        uint8[] calldata _options
    ) external view returns (Query memory);

    function queryNoSplit(
        uint256 _amountIn,
        address _tokenIn,
        address _tokenOut
    ) external view returns (Query memory);

    function findBestPathWithGas(
        uint256 _amountIn,
        address _tokenIn,
        address _tokenOut,
        uint256 _maxSteps,
        uint256 _gasPrice
    ) external view returns (FormattedOffer memory);

    function findBestPath(
        uint256 _amountIn,
        address _tokenIn,
        address _tokenOut,
        uint256 _maxSteps
    ) external view returns (FormattedOffer memory);

    // swap

    function swapNoSplit(
        Trade calldata _trade,
        address _to,
        uint256 _fee
    ) external;

    function swapNoSplitFromNative(
        Trade calldata _trade,
        address _to,
        uint256 _fee
    ) external payable;

    function swapNoSplitToNative(
        Trade calldata _trade,
        address _to,
        uint256 _fee
    ) external; 

    function swapNoSplitWithPermit(
        Trade calldata _trade,
        address _to,
        uint256 _fee,
        uint256 _deadline,
        uint8 _v,
        bytes32 _r,
        bytes32 _s
    ) external;

    function swapNoSplitToNativeWithPermit(
        Trade calldata _trade,
        address _to,
        uint256 _fee,
        uint256 _deadline,
        uint8 _v,
        bytes32 _r,
        bytes32 _s
    ) external;

}// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./IERC20.sol";

interface IWETH is IERC20 {
    function withdraw(uint256 amount) external;

    function deposit() external payable;
}
// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/AccessControl.sol";

/**
 * @dev Contract module which extends the basic access control mechanism of Ownable
 * to include many maintainers, whom only the owner (DEFAULT_ADMIN_ROLE) may add and
 * remove.
 *
 * By default, the owner account will be the one that deploys the contract. This can
 * later be changed with {transferOwnership}.
 *
 * This module is used through inheritance. It will make available this modifier:
 * `onlyMaintainer`, which can be applied to your functions to restrict their use to
 * the accounts with the role of maintainer.
 */

abstract contract Maintainable is Context, AccessControl {
    bytes32 public constant MAINTAINER_ROLE = keccak256("MAINTAINER_ROLE");

    constructor() {
        address msgSender = _msgSender();
        // members of the DEFAULT_ADMIN_ROLE alone may revoke and grant role membership
        _setupRole(DEFAULT_ADMIN_ROLE, msgSender);
        _setupRole(MAINTAINER_ROLE, msgSender);
    }

    function addMaintainer(address addedMaintainer) public virtual {
        grantRole(MAINTAINER_ROLE, addedMaintainer);
    }

    function removeMaintainer(address removedMaintainer) public virtual {
        revokeRole(MAINTAINER_ROLE, removedMaintainer);
    }

    function renounceRole(bytes32 role) public virtual {
        address msgSender = _msgSender();
        renounceRole(role, msgSender);
    }

    function transferOwnership(address newOwner) public virtual {
        address msgSender = _msgSender();
        grantRole(DEFAULT_ADMIN_ROLE, newOwner);
        renounceRole(DEFAULT_ADMIN_ROLE, msgSender);
    }

    modifier onlyMaintainer() {
        address msgSender = _msgSender();
        require(hasRole(MAINTAINER_ROLE, msgSender), "Maintainable: Caller is not a maintainer");
        _;
    }
}
// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import "./SafeERC20.sol";
import "./Maintainable.sol";


abstract contract Recoverable is Maintainable {
    using SafeERC20 for IERC20;

    event Recovered(
        address indexed _asset, 
        uint amount
    );

    /**
     * @notice Recover ERC20 from contract
     * @param _tokenAddress token address
     * @param _tokenAmount amount to recover
     */
    function recoverERC20(address _tokenAddress, uint _tokenAmount) external onlyMaintainer {
        require(_tokenAmount > 0, "Nothing to recover");
        IERC20(_tokenAddress).safeTransfer(msg.sender, _tokenAmount);
        emit Recovered(_tokenAddress, _tokenAmount);
    }

    /**
     * @notice Recover native asset from contract
     * @param _amount amount
     */
    function recoverNative(uint _amount) external onlyMaintainer {
        require(_amount > 0, "Nothing to recover");
        payable(msg.sender).transfer(_amount);
        emit Recovered(address(0), _amount);
    }

}// This is a simplified version of OpenZepplin's SafeERC20 library
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
pragma experimental ABIEncoderV2;

import "../interface/IERC20.sol";

/**
 * @title SafeERC20
 * @dev Wrappers around ERC20 operations that throw on failure (when the token
 * contract returns false). Tokens that return no value (and instead revert or
 * throw on failure) are also supported, non-reverting calls are assumed to be
 * successful.
 * To use this library you can add a `using SafeERC20 for ERC20;` statement to your contract,
 * which allows you to call the safe operations as `token.safeTransfer(...)`, etc.
 */
library SafeERC20 {
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

    function safeApprove(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {
        // safeApprove should only be called when setting an initial allowance,
        // or when resetting it to zero. To increase and decrease it, use
        // 'safeIncreaseAllowance' and 'safeDecreaseAllowance'
        // solhint-disable-next-line max-line-length
        require(
            (value == 0) || (token.allowance(address(this), spender) == 0),
            "SafeERC20: approve from non-zero to non-zero allowance"
        );
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
    }

    /**
     * @dev Imitates a Solidity high-level call (i.e. a regular function call to a contract), relaxing the requirement
     * on the return value: the return value is optional (but if data is returned, it must not be false).
     * @param token The token targeted by the call.
     * @param data The call data (encoded using abi.encode or one of its variants).
     */
    function _callOptionalReturn(IERC20 token, bytes memory data) private {
        // We need to perform a low level call here, to bypass Solidity's return data size checking mechanism, since
        // we're implementing it ourselves.

        // A Solidity high level call has three parts:
        //  1. The target address is checked to verify it contains contract code
        //  2. The call itself is made, and success asserted
        //  3. The return value is decoded, which in turn checks the size of the returned data.
        // solhint-disable-next-line max-line-length

        // solhint-disable-next-line avoid-low-level-calls
        (bool success, bytes memory returndata) = address(token).call(data);
        require(success, "SafeERC20: low-level call failed");

        if (returndata.length > 0) {
            // Return data is optional
            // solhint-disable-next-line max-line-length
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
}
// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;


library TypeConversion {

    function toBytes12(address x) internal pure returns (bytes12 y) {
        assembly { y := x }
    }

    function toBytes32(address x) internal pure returns (bytes32 y) {
        assembly { y := x }
    }

    function toAddress(bytes32 x) internal pure returns (address y) {
        assembly { y := x }
    }

    function toBytes(address x) internal pure returns (bytes memory y) {
        y = new bytes(32);
        assembly { mstore(add(y, 32), x) }
    }

    function toBytes(bytes32 x) internal pure returns (bytes memory y) {
        y = new bytes(32);
        assembly { mstore(add(y, 32), x) }
    }

    function toBytes(uint x) internal pure returns (bytes memory y) {
        y = new bytes(32);
        assembly { mstore(add(y, 32), x) }
    }

    function toAddress(
        bytes memory x,
        uint offset
    ) internal pure returns (address y) {
        assembly { y := mload(add(x, offset)) }
    }

    function toUint(
        bytes memory x,
        uint offset
    ) internal pure returns (uint y) {
        assembly { y := mload(add(x, offset)) }
    }

    function toBytes12(
        bytes memory x,
        uint offset
    ) internal pure returns (bytes12 y) {
        assembly { y := mload(add(x, offset)) }
    }

    function toBytes32(
        bytes memory x,
        uint offset
    ) internal pure returns (bytes32 y) {
        assembly { y := mload(add(x, offset)) }
    }

    function toAddresses(
        bytes memory xs
    ) internal pure returns (address[] memory ys) {
        ys = new address[](xs.length/32);
        for (uint i=0; i < xs.length/32; i++) {
            ys[i] = toAddress(xs, i*32 + 32);
        }
    }

    function toUints(
        bytes memory xs
    ) internal pure returns (uint[] memory ys) {
        ys = new uint[](xs.length/32);
        for (uint i=0; i < xs.length/32; i++) {
            ys[i] = toUint(xs, i*32 + 32);
        }
    }

    function toBytes32s(
        bytes memory xs
    ) internal pure returns (bytes32[] memory ys) {
        ys = new bytes32[](xs.length/32);
        for (uint i=0; i < xs.length/32; i++) {
            ys[i] = toBytes32(xs, i*32 + 32);
        }
    }

}
// SPDX-License-Identifier: GPL-3.0-only
pragma solidity >=0.8.4;

import { Offer, FormattedOffer } from "../interface/IViralataRouter.sol";
import "./TypeConversion.sol";


library OfferUtils {
    using TypeConversion for address;
    using TypeConversion for uint256;
    using TypeConversion for bytes;

    function newOffer(
        uint _amountIn,
        address _tokenIn
    ) internal pure returns (Offer memory offer) {
        offer.amounts = _amountIn.toBytes();
        offer.path = _tokenIn.toBytes();
    }

    /**
     * Makes a deep copy of Offer struct
     */
    function clone(Offer memory _queries) internal pure returns (Offer memory) {
        return Offer(_queries.amounts, _queries.adapters, _queries.path, _queries.gasEstimate);
    }

    /**
     * Appends new elements to the end of Offer struct
     */
    function addToTail(
        Offer memory _queries,
        uint256 _amount,
        address _adapter,
        address _tokenOut,
        uint256 _gasEstimate
    ) internal pure {
        _queries.path = bytes.concat(_queries.path, _tokenOut.toBytes());
        _queries.adapters = bytes.concat(_queries.adapters, _adapter.toBytes());
        _queries.amounts = bytes.concat(_queries.amounts, _amount.toBytes());
        _queries.gasEstimate += _gasEstimate;
    }

    /**
     * Formats elements in the Offer object from byte-arrays to integers and addresses
     */
    function format(Offer memory _queries) internal pure returns (FormattedOffer memory) {
        return
            FormattedOffer(
                _queries.amounts.toUints(),
                _queries.adapters.toAddresses(),
                _queries.path.toAddresses(),
                _queries.gasEstimate
            );
    }

    function getTokenOut(
        Offer memory _offer
    ) internal pure returns (address tokenOut) {
        tokenOut = _offer.path.toAddress(_offer.path.length);  // Last 32 bytes
    }

    function getAmountOut(
        Offer memory _offer
    ) internal pure returns (uint amountOut) {
        amountOut = _offer.amounts.toUint(_offer.path.length);  // Last 32 bytes
    }

}

library FormattedOfferUtils {
    using TypeConversion for address;
    using TypeConversion for uint256;
    using TypeConversion for bytes;

    /**
     * Appends new elements to the end of FormattedOffer
     */
    function addToTail(
        FormattedOffer memory offer, 
        uint256 amountOut, 
        address wrapper,
        address tokenOut,
        uint256 gasEstimate
    ) internal pure {
        offer.amounts = bytes.concat(abi.encodePacked(offer.amounts), amountOut.toBytes()).toUints();
        offer.adapters = bytes.concat(abi.encodePacked(offer.adapters), wrapper.toBytes()).toAddresses();
        offer.path = bytes.concat(abi.encodePacked(offer.path), tokenOut.toBytes()).toAddresses();
        offer.gasEstimate += gasEstimate;
    }

    /**
     * Appends new elements to the beginning of FormattedOffer
     */
    function addToHead(
        FormattedOffer memory offer, 
        uint256 amountOut, 
        address wrapper,
        address tokenOut,
        uint256 gasEstimate
    ) internal pure {
        offer.amounts = bytes.concat(amountOut.toBytes(), abi.encodePacked(offer.amounts)).toUints();
        offer.adapters = bytes.concat(wrapper.toBytes(), abi.encodePacked(offer.adapters)).toAddresses();
        offer.path = bytes.concat(tokenOut.toBytes(), abi.encodePacked(offer.path)).toAddresses();
        offer.gasEstimate += gasEstimate;
    }

    function getAmountOut(FormattedOffer memory offer) internal pure returns (uint256) {
        return offer.amounts[offer.amounts.length - 1];
    }

}// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
pragma experimental ABIEncoderV2;

import "./interface/IViralataRouter.sol";
import "./interface/IAdapter.sol";
import "./interface/IERC20.sol";
import "./interface/IWETH.sol";
import "./lib/SafeERC20.sol";
import "./lib/Maintainable.sol";
import "./lib/ViralataViewUtils.sol";
import "./lib/Recoverable.sol";
import "./lib/SafeERC20.sol";

contract ViralataRouter is Maintainable, Recoverable, IViralataRouter {
    using SafeERC20 for IERC20;
    using OfferUtils for Offer;

    address public immutable WNATIVE;
    address public constant NATIVE = address(0);
    string public constant NAME = "Viralata Finance - DEX Aggregator";
    uint256 public constant FEE_DENOMINATOR = 1e4;
    uint256 public MIN_FEE = 0;
    address public FEE_CLAIMER;
    address[] public TRUSTED_TOKENS;
    address[] public ADAPTERS;

    constructor(
        address[] memory _adapters,
        address[] memory _trustedTokens,
        address _feeClaimer,
        address _wrapped_native
    ) {
        setAllowanceForWrapping(_wrapped_native);
        setTrustedTokens(_trustedTokens);
        setFeeClaimer(_feeClaimer);
        setAdapters(_adapters);
        WNATIVE = _wrapped_native;
    }

    // -- SETTERS --

    function setAllowanceForWrapping(address _wnative) public onlyMaintainer {
        IERC20(_wnative).safeApprove(_wnative, type(uint256).max);
    }

    function setTrustedTokens(
        address[] memory _trustedTokens
    ) public override onlyMaintainer {
        emit UpdatedTrustedTokens(_trustedTokens);
        TRUSTED_TOKENS = _trustedTokens;
    }

    function setAdapters(
        address[] memory _adapters
    ) public override onlyMaintainer {
        emit UpdatedAdapters(_adapters);
        ADAPTERS = _adapters;
    }

    function setMinFee(uint256 _fee) external override onlyMaintainer {
        emit UpdatedMinFee(MIN_FEE, _fee);
        MIN_FEE = _fee;
    }

    function setFeeClaimer(address _claimer) public override onlyMaintainer {
        emit UpdatedFeeClaimer(FEE_CLAIMER, _claimer);
        FEE_CLAIMER = _claimer;
    }

    //  -- GENERAL --

    function trustedTokensCount() external view override returns (uint256) {
        return TRUSTED_TOKENS.length;
    }

    function adaptersCount() external view override returns (uint256) {
        return ADAPTERS.length;
    }

    // Fallback
    receive() external payable {}

    // -- HELPERS --

    function _applyFee(
        uint256 _amountIn,
        uint256 _fee
    ) internal view returns (uint256) {
        require(_fee >= MIN_FEE, "ViralataRouter: Insufficient fee");
        return (_amountIn * (FEE_DENOMINATOR - _fee)) / FEE_DENOMINATOR;
    }

    function _wrap(uint256 _amount) internal {
        IWETH(WNATIVE).deposit{value: _amount}();
    }

    function _unwrap(uint256 _amount) internal {
        IWETH(WNATIVE).withdraw(_amount);
    }

    /**
     * @notice Return tokens to user
     * @dev Pass address(0) for Native
     * @param _token address
     * @param _amount tokens to return
     * @param _to address where funds should be sent to
     */
    function _returnTokensTo(
        address _token,
        uint256 _amount,
        address _to
    ) internal {
        if (address(this) != _to) {
            if (_token == NATIVE) {
                payable(_to).transfer(_amount);
            } else {
                IERC20(_token).safeTransfer(_to, _amount);
            }
        }
    }

    function _transferFrom(
        address token,
        address _from,
        address _to,
        uint _amount
    ) internal {
        if (_from != address(this))
            IERC20(token).safeTransferFrom(_from, _to, _amount);
        else IERC20(token).safeTransfer(_to, _amount);
    }

    // -- QUERIES --

    /**
     * Query single adapter
     */
    function queryAdapter(
        uint256 _amountIn,
        address _tokenIn,
        address _tokenOut,
        uint8 _index
    ) external view override returns (uint256) {
        IAdapter _adapter = IAdapter(ADAPTERS[_index]);
        uint256 amountOut = _adapter.query(_amountIn, _tokenIn, _tokenOut);
        return amountOut;
    }

    /**
     * Query specified adapters
     */
    function queryNoSplit(
        uint256 _amountIn,
        address _tokenIn,
        address _tokenOut,
        uint8[] calldata _options
    ) public view override returns (Query memory) {
        Query memory bestQuery;
        for (uint8 i; i < _options.length; i++) {
            address _adapter = ADAPTERS[_options[i]];
            uint256 amountOut = IAdapter(_adapter).query(
                _amountIn,
                _tokenIn,
                _tokenOut
            );
            if (i == 0 || amountOut > bestQuery.amountOut) {
                bestQuery = Query(_adapter, _tokenIn, _tokenOut, amountOut);
            }
        }
        return bestQuery;
    }

    /**
     * Query all adapters
     */
    function queryNoSplit(
        uint256 _amountIn,
        address _tokenIn,
        address _tokenOut
    ) public view override returns (Query memory) {
        Query memory bestQuery;
        for (uint8 i; i < ADAPTERS.length; i++) {
            address _adapter = ADAPTERS[i];
            uint256 amountOut = IAdapter(_adapter).query(
                _amountIn,
                _tokenIn,
                _tokenOut
            );
            if (i == 0 || amountOut > bestQuery.amountOut) {
                bestQuery = Query(_adapter, _tokenIn, _tokenOut, amountOut);
            }
        }
        return bestQuery;
    }

    /**
     * Return path with best returns between two tokens
     * Takes gas-cost into account
     */
    function findBestPathWithGas(
        uint256 _amountIn,
        address _tokenIn,
        address _tokenOut,
        uint256 _maxSteps,
        uint256 _gasPrice
    ) external view override returns (FormattedOffer memory) {
        require(
            _maxSteps > 0 && _maxSteps < 5,
            "ViralataRouter: Invalid max-steps"
        );
        Offer memory queries = OfferUtils.newOffer(_amountIn, _tokenIn);
        uint256 gasPriceInExitTkn = _gasPrice > 0
            ? getGasPriceInExitTkn(_gasPrice, _tokenOut)
            : 0;
        queries = _findBestPath(
            _amountIn,
            _tokenIn,
            _tokenOut,
            _maxSteps,
            queries,
            gasPriceInExitTkn
        );
        if (queries.adapters.length == 0) {
            queries.amounts = "";
            queries.path = "";
        }
        return queries.format();
    }

    // Find the market price between gas-asset(native) and token-out and express gas price in token-out
    function getGasPriceInExitTkn(
        uint256 _gasPrice,
        address _tokenOut
    ) internal view returns (uint256 price) {
        // Avoid low-liquidity price appreciation (https://github.com/yieldyak/yak-aggregator/issues/20)
        FormattedOffer memory gasQuery = findBestPath(
            1e18,
            WNATIVE,
            _tokenOut,
            2
        );
        if (gasQuery.path.length != 0) {
            // Leave result in nWei to preserve precision for assets with low decimal places
            price =
                (gasQuery.amounts[gasQuery.amounts.length - 1] * _gasPrice) /
                1e9;
        }
    }

    /**
     * Return path with best returns between two tokens
     */
    function findBestPath(
        uint256 _amountIn,
        address _tokenIn,
        address _tokenOut,
        uint256 _maxSteps
    ) public view override returns (FormattedOffer memory) {
        require(
            _maxSteps > 0 && _maxSteps < 5,
            "ViralataRouter: Invalid max-steps"
        );
        Offer memory queries = OfferUtils.newOffer(_amountIn, _tokenIn);
        queries = _findBestPath(
            _amountIn,
            _tokenIn,
            _tokenOut,
            _maxSteps,
            queries,
            0
        );
        // If no paths are found return empty struct
        if (queries.adapters.length == 0) {
            queries.amounts = "";
            queries.path = "";
        }
        return queries.format();
    }

    function _findBestPath(
        uint256 _amountIn,
        address _tokenIn,
        address _tokenOut,
        uint256 _maxSteps,
        Offer memory _queries,
        uint256 _tknOutPriceNwei
    ) internal view returns (Offer memory) {
        Offer memory bestOption = _queries.clone();
        uint256 bestAmountOut;
        uint256 gasEstimate;
        bool withGas = _tknOutPriceNwei != 0;

        // First check if there is a path directly from tokenIn to tokenOut
        Query memory queryDirect = queryNoSplit(_amountIn, _tokenIn, _tokenOut);

        if (queryDirect.amountOut != 0) {
            if (withGas) {
                gasEstimate = IAdapter(queryDirect.adapter).swapGasEstimate();
            }
            bestOption.addToTail(
                queryDirect.amountOut,
                queryDirect.adapter,
                queryDirect.tokenOut,
                gasEstimate
            );
            bestAmountOut = queryDirect.amountOut;
        }
        // Only check the rest if they would go beyond step limit (Need at least 2 more steps)
        if (_maxSteps > 1 && _queries.adapters.length / 32 <= _maxSteps - 2) {
            // Check for paths that pass through trusted tokens
            for (uint256 i = 0; i < TRUSTED_TOKENS.length; i++) {
                if (_tokenIn == TRUSTED_TOKENS[i]) {
                    continue;
                }
                // Loop through all adapters to find the best one for swapping tokenIn for one of the trusted tokens
                Query memory bestSwap = queryNoSplit(
                    _amountIn,
                    _tokenIn,
                    TRUSTED_TOKENS[i]
                );
                if (bestSwap.amountOut == 0) {
                    continue;
                }
                // Explore options that connect the current path to the tokenOut
                Offer memory newOffer = _queries.clone();
                if (withGas) {
                    gasEstimate = IAdapter(bestSwap.adapter).swapGasEstimate();
                }
                newOffer.addToTail(
                    bestSwap.amountOut,
                    bestSwap.adapter,
                    bestSwap.tokenOut,
                    gasEstimate
                );
                newOffer = _findBestPath(
                    bestSwap.amountOut,
                    TRUSTED_TOKENS[i],
                    _tokenOut,
                    _maxSteps,
                    newOffer,
                    _tknOutPriceNwei
                ); // Recursive step
                address tokenOut = newOffer.getTokenOut();
                uint256 amountOut = newOffer.getAmountOut();
                // Check that the last token in the path is the tokenOut and update the new best option if neccesary
                if (_tokenOut == tokenOut && amountOut > bestAmountOut) {
                    if (newOffer.gasEstimate > bestOption.gasEstimate) {
                        uint256 gasCostDiff = (_tknOutPriceNwei *
                            (newOffer.gasEstimate - bestOption.gasEstimate)) /
                            1e9;
                        uint256 priceDiff = amountOut - bestAmountOut;
                        if (gasCostDiff > priceDiff) {
                            continue;
                        }
                    }
                    bestAmountOut = amountOut;
                    bestOption = newOffer;
                }
            }
        }
        return bestOption;
    }

    // -- SWAPPERS --

    function _swapNoSplit(
        Trade calldata _trade,
        address _from,
        address _to,
        uint256 _fee
    ) internal returns (uint256) {
        uint amountIn = _trade.amountIn;
        if (_fee > 0 || MIN_FEE > 0) {
            // Transfer fees to the claimer account and decrease initial amount
            amountIn = _applyFee(_trade.amountIn, _fee);
            _transferFrom(
                _trade.path[0],
                _from,
                FEE_CLAIMER,
                _trade.amountIn - amountIn
            );
        }

        //tokens should either go to the adapter or to the pair contract
        //first amountIn is the amount the adapter/pair received after transfer (for tokens with tax)
        address tokensTo = IAdapter(_trade.adapters[0]).tokensTo(
            _trade.path[0],
            _trade.path[1]
        );
        uint amountBefore = IERC20(_trade.path[0]).balanceOf(tokensTo);
        _transferFrom(_trade.path[0], _from, tokensTo, amountIn);
        amountIn = IERC20(_trade.path[0]).balanceOf(tokensTo) - amountBefore;

        //amount out is calculated every adapter
        uint amountOut;
        for (uint256 i = 0; i < _trade.adapters.length; i++) {

            //tokens are sent after swaping either to the next adapter or to receiver (if last iteration)
            address targetAddress = i < _trade.adapters.length - 1
                ? IAdapter(_trade.adapters[i + 1]).tokensTo(
                    _trade.path[i + 1],
                    _trade.path[i + 2]
                )
                : _to;

            amountOut = IAdapter(_trade.adapters[i]).query(
                amountIn,
                _trade.path[i],
                _trade.path[i + 1]
            );

            //calculate the amount of token 1 in the target address before swap
            amountBefore = IERC20(_trade.path[i + 1]).balanceOf(
                (targetAddress)
            );

            IAdapter(_trade.adapters[i]).swap(
                amountIn,
                amountOut,
                _trade.path[i],
                _trade.path[i + 1],
                targetAddress
            );

            //the next amountIn is the amount of token 1 received in the targetAddress - amountBefore
            amountIn =
                IERC20(_trade.path[i + 1]).balanceOf((targetAddress)) -
                amountBefore;
        }

        // Get amounts that will be swapped
        require(
            amountOut >= _trade.amountOut,
            "ViralataRouter: Insufficient output amount"
        );

        emit ViralataSwap(
            _trade.path[0],
            _trade.path[_trade.path.length - 1],
            _trade.amountIn,
            amountOut
        );
        return amountOut;
    }

    function swapNoSplit(
        Trade calldata _trade,
        address _to,
        uint256 _fee
    ) public override {
        _swapNoSplit(_trade, msg.sender, _to, _fee);
    }

    function swapNoSplitFromNative(
        Trade calldata _trade,
        address _to,
        uint256 _fee
    ) external payable override {
        require(
            _trade.path[0] == WNATIVE,
            "ViralataRouter: Path needs to begin with WNative"
        );
        _wrap(_trade.amountIn);
        _swapNoSplit(_trade, address(this), _to, _fee);
    }

    function swapNoSplitToNative(
        Trade calldata _trade,
        address _to,
        uint256 _fee
    ) public override {
        require(
            _trade.path[_trade.path.length - 1] == WNATIVE,
            "ViralataRouter: Path needs to end with WNative"
        );
        uint256 returnAmount = _swapNoSplit(
            _trade,
            msg.sender,
            address(this),
            _fee
        );
        _unwrap(returnAmount);
        _returnTokensTo(NATIVE, returnAmount, _to);
    }

    /**
     * Swap token to token without the need to approve the first token
     */
    function swapNoSplitWithPermit(
        Trade calldata _trade,
        address _to,
        uint256 _fee,
        uint256 _deadline,
        uint8 _v,
        bytes32 _r,
        bytes32 _s
    ) external override {
        IERC20(_trade.path[0]).permit(
            msg.sender,
            address(this),
            _trade.amountIn,
            _deadline,
            _v,
            _r,
            _s
        );
        swapNoSplit(_trade, _to, _fee);
    }

    /**
     * Swap token to Native without the need to approve the first token
     */
    function swapNoSplitToNativeWithPermit(
        Trade calldata _trade,
        address _to,
        uint256 _fee,
        uint256 _deadline,
        uint8 _v,
        bytes32 _r,
        bytes32 _s
    ) external override {
        IERC20(_trade.path[0]).permit(
            msg.sender,
            address(this),
            _trade.amountIn,
            _deadline,
            _v,
            _r,
            _s
        );
        swapNoSplitToNative(_trade, _to, _fee);
    }
}
