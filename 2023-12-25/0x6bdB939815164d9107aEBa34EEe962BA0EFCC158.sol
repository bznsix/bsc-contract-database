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
// OpenZeppelin Contracts (last updated v4.9.4) (utils/Context.sol)

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

    function _contextSuffixLength() internal view virtual returns (uint256) {
        return 0;
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
pragma solidity >=0.5.0;

interface IUniswapV2Factory {
    event PairCreated(address indexed token0, address indexed token1, address pair, uint);

    function feeTo() external view returns (address);
    function feeToSetter() external view returns (address);

    function getPair(address tokenA, address tokenB) external view returns (address pair);
    function allPairs(uint) external view returns (address pair);
    function allPairsLength() external view returns (uint);

    function createPair(address tokenA, address tokenB) external returns (address pair);

    function setFeeTo(address) external;
    function setFeeToSetter(address) external;
}
pragma solidity >=0.6.2;

interface IUniswapV2Router01 {
    function factory() external pure returns (address);
    function WETH() external pure returns (address);

    function addLiquidity(
        address tokenA,
        address tokenB,
        uint amountADesired,
        uint amountBDesired,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline
    ) external returns (uint amountA, uint amountB, uint liquidity);
    function addLiquidityETH(
        address token,
        uint amountTokenDesired,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external payable returns (uint amountToken, uint amountETH, uint liquidity);
    function removeLiquidity(
        address tokenA,
        address tokenB,
        uint liquidity,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline
    ) external returns (uint amountA, uint amountB);
    function removeLiquidityETH(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external returns (uint amountToken, uint amountETH);
    function removeLiquidityWithPermit(
        address tokenA,
        address tokenB,
        uint liquidity,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountA, uint amountB);
    function removeLiquidityETHWithPermit(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountToken, uint amountETH);
    function swapExactTokensForTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory amounts);
    function swapTokensForExactTokens(
        uint amountOut,
        uint amountInMax,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory amounts);
    function swapExactETHForTokens(uint amountOutMin, address[] calldata path, address to, uint deadline)
        external
        payable
        returns (uint[] memory amounts);
    function swapTokensForExactETH(uint amountOut, uint amountInMax, address[] calldata path, address to, uint deadline)
        external
        returns (uint[] memory amounts);
    function swapExactTokensForETH(uint amountIn, uint amountOutMin, address[] calldata path, address to, uint deadline)
        external
        returns (uint[] memory amounts);
    function swapETHForExactTokens(uint amountOut, address[] calldata path, address to, uint deadline)
        external
        payable
        returns (uint[] memory amounts);

    function quote(uint amountA, uint reserveA, uint reserveB) external pure returns (uint amountB);
    function getAmountOut(uint amountIn, uint reserveIn, uint reserveOut) external pure returns (uint amountOut);
    function getAmountIn(uint amountOut, uint reserveIn, uint reserveOut) external pure returns (uint amountIn);
    function getAmountsOut(uint amountIn, address[] calldata path) external view returns (uint[] memory amounts);
    function getAmountsIn(uint amountOut, address[] calldata path) external view returns (uint[] memory amounts);
}
pragma solidity >=0.6.2;

import './IUniswapV2Router01.sol';

interface IUniswapV2Router02 is IUniswapV2Router01 {
    function removeLiquidityETHSupportingFeeOnTransferTokens(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external returns (uint amountETH);
    function removeLiquidityETHWithPermitSupportingFeeOnTransferTokens(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountETH);

    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
    function swapExactETHForTokensSupportingFeeOnTransferTokens(
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external payable;
    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
}
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.2;

import "@openzeppelin/contracts/token/ERC20/extensions/IERC20Metadata.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";
import "@uniswap/v2-periphery/contracts/interfaces/IUniswapV2Router02.sol";
import "@uniswap/v2-core/contracts/interfaces/IUniswapV2Factory.sol";
import "./GrokNYDistribution.sol";

contract GrokNY is IERC20Metadata, AccessControl {

    mapping(address => uint256) private balances;

    mapping(address => mapping(address => uint256)) private allowances;

    uint256 public override totalSupply;

    string public override name;
    string public override symbol;
    uint8 public constant override decimals = 18;

    address public owner = address(0);

    address public constant deadAddress = 0x000000000000000000000000000000000000dEaD;

    address public token1;
    IUniswapV2Router02 public router;
    address public pair;

    bool public tradingEnabled = false;

    mapping(address => bool) public isLpToken;
    mapping(address => bool) public excludedFromFee;
    mapping(address => bool) public excludedFromSwap;

    GrokNYDistribution public distribution;

    bool private inSwap;

    uint256 public feeCounter = 0;
    uint256 public feeLimit = 8;

    uint256 public burnFeeBuyRate;
    uint256 public burnFeeSellRate;
    uint256 public burnFeeTransferRate;
    address[] public burnFeeReceivers;
    uint256[] public burnFeeReceiversRate;

    uint256 public liquidityFeeBuyRate;
    uint256 public liquidityFeeSellRate;
    uint256 public liquidityFeeTransferRate;
    address[] public liquidityFeeReceivers;
    uint256[] public liquidityFeeReceiversRate;
    uint256 public liquidityFeeAmount;

    uint256 public swapFeeBuyRate;
    uint256 public swapFeeSellRate;
    uint256 public swapFeeTransferRate;
    address[] public swapFeeReceivers;
    uint256[] public swapFeeReceiversRate;
    uint256 public swapFeeAmount;

    address immutable public rewardSwapAddress;
    uint256 public rewardSellAmount;
    uint256 public rewardSellRate;
    uint256 public rewardBuyAmount;
    uint256 public rewardBuyRate;
    address[] public rewardSwapReceivers;
    uint256[] public rewardSwapReceiversRate;

    bool public enabledSwapForSell = true;

    modifier lockTheSwap {
        inSwap = true;
        _;
        inSwap = false;
    }

    event LpTokenUpdated(address _lpToken, bool _lp);
    event ExcludedFromFee(address _address, bool _isExcludedFromFee);
    event ExcludedFromSwap(address _address, bool _isExcludedFromSwap);
    event RewardSwapReceiversUpdated(address[] _rewardSwapReceivers, uint256[] _rewardSwapReceiversRate);
    event RewardSellRateUpdated(uint256 _rewardSellRate);
    event RewardBuyRateUpdated(uint256 _rewardBuyRate);
    event RewardsAmountReseted();
    event BuyFeesUpdated(uint256 _burnFeeBuyRate, uint256 _liquidityFeeBuyRate, uint256 _swapFeeBuyRate);
    event SellFeesUpdated(uint256 _burnFeeSellRate, uint256 _liquidityFeeSellRate, uint256 _swapFeeSellRate);
    event TransferFeesUpdated(uint256 _burnFeeTransferRate, uint256 _liquidityFeeTransferRate, uint256 _swapFeeTransferRate);
    event FeeCounterReseted();
    event FeeLimitUpdated();
    event BurnFeeReceiversUpdated(address[] _burnFeeReceivers, uint256[] _burnFeeReceiversRate);
    event LiquidityFeeReceiversUpdated(address[] _liquidityFeeReceivers, uint256[] _liquidityFeeReceiversRate);
    event LiquidityFeeReseted();
    event SwapFeeReceiversUpdated(address[] _swapFeeReceivers, uint256[] _swapFeeReceiversRate);
    event SwapFeeReseted();
    event EnabledSwapForSellUpdated(bool _enabledSwapForSell);

    constructor(
        string memory _name,
        string memory _symbol,
        uint256 _totalSupply,
        address _rewardSwapAddress,
        IUniswapV2Router02 _router,
        address _token1
    ) {
        name = _name;
        symbol = _symbol;

        _setupRole(DEFAULT_ADMIN_ROLE, msg.sender);

        _mint(msg.sender, _totalSupply * 10 ** 18);

        distribution = new GrokNYDistribution();

        require(_rewardSwapAddress != address(0), "zero reward swap address.");
        rewardSwapAddress = _rewardSwapAddress;

        _setRouterAndPair(_router, _token1);

        setExcludedFromFee(msg.sender, true);
        setExcludedFromSwap(msg.sender, true);

        setExcludedFromFee(address(this), true);
        setExcludedFromSwap(address(this), true);
    }

    function balanceOf(address _account) public view override returns (uint256) {
        return balances[_account];
    }

    function transfer(address _recipient, uint256 _amount) external override returns (bool) {
        _transfer(msg.sender, _recipient, _amount);
        return true;
    }

    function allowance(address _owner, address _spender) public view override returns (uint256) {
        return allowances[_owner][_spender];
    }

    function approve(address _spender, uint256 _amount) external override returns (bool) {
        _approve(msg.sender, _spender, _amount);
        return true;
    }

    function transferFrom(address _sender, address _recipient, uint256 _amount) external override returns (bool) {
        _transfer(_sender, _recipient, _amount);

        uint256 _currentAllowance = allowances[_sender][msg.sender];
        require(_currentAllowance >= _amount, "ERC20: transfer amount exceeds allowance");
        _approve(_sender, msg.sender, _currentAllowance - _amount);

        return true;
    }

    function increaseAllowance(address _spender, uint256 _addedValue) external returns (bool) {
        _approve(msg.sender, _spender, allowances[msg.sender][_spender] + _addedValue);
        return true;
    }

    function decreaseAllowance(address _spender, uint256 _subtractedValue) external returns (bool) {
        uint256 _currentAllowance = allowances[msg.sender][_spender];
        require(_currentAllowance >= _subtractedValue, "ERC20: decreased allowance below zero");

        _approve(msg.sender, _spender, _currentAllowance - _subtractedValue);

        return true;
    }

    function enableTrading() external onlyRole(DEFAULT_ADMIN_ROLE) {
        require(!tradingEnabled, "ERC20: Trading already enabled");
        tradingEnabled = true;
    }

    function setLpToken(address _lpToken, bool _lp) external onlyRole(DEFAULT_ADMIN_ROLE) {
        require(_lpToken != address(0), "ERC20: invalid LP address");
        require(_lpToken != pair, "ERC20: exclude default pair");

        isLpToken[_lpToken] = _lp;

        emit LpTokenUpdated(_lpToken, _lp);
    }

    function setExcludedFromFee(address _address, bool _isExcludedFromFee) public onlyRole(DEFAULT_ADMIN_ROLE) {
        excludedFromFee[_address] = _isExcludedFromFee;

        emit ExcludedFromFee(_address, _isExcludedFromFee);
    }

    function setExcludedFromSwap(address _address, bool _isExcludedFromSwap) public onlyRole(DEFAULT_ADMIN_ROLE) {
        excludedFromSwap[_address] = _isExcludedFromSwap;

        emit ExcludedFromSwap(_address, _isExcludedFromSwap);
    }

    function setRewardSwapReceivers(address[] calldata _rewardSwapReceivers, uint256[] calldata _rewardSwapReceiversRate) external onlyRole(DEFAULT_ADMIN_ROLE) {
        require(_rewardSwapReceivers.length == _rewardSwapReceiversRate.length, "size");

        uint256 _totalRate = 0;
        for (uint256 _i = 0; _i < _rewardSwapReceiversRate.length; _i++) {
            _totalRate += _rewardSwapReceiversRate[_i];
        }
        require(_totalRate == 10000, "rate");

        delete rewardSwapReceivers;
        delete rewardSwapReceiversRate;

        for (uint i = 0; i < _rewardSwapReceivers.length; i++) {
            rewardSwapReceivers.push(_rewardSwapReceivers[i]);
            rewardSwapReceiversRate.push(_rewardSwapReceiversRate[i]);
        }

        emit RewardSwapReceiversUpdated(_rewardSwapReceivers, _rewardSwapReceiversRate);
    }

    function setRewardSellRate(uint256 _rewardSellRate) external onlyRole(DEFAULT_ADMIN_ROLE) {
        require(_rewardSellRate <= 3000, "_rewardSellRate");
        rewardSellRate = _rewardSellRate;

        emit RewardSellRateUpdated(_rewardSellRate);
    }

    function setRewardBuyRate(uint256 _rewardBuyRate) external onlyRole(DEFAULT_ADMIN_ROLE) {
        require(_rewardBuyRate <= 3000, "_rewardBuyRate");
        rewardBuyRate = _rewardBuyRate;

        emit RewardBuyRateUpdated(_rewardBuyRate);
    }

    function resetRewardsAmount() external onlyRole(DEFAULT_ADMIN_ROLE) {
        rewardSellAmount = 0;
        rewardBuyAmount = 0;

        emit RewardsAmountReseted();
    }

    function updateBuyRates(uint256 _burnFeeBuyRate, uint256 _liquidityFeeBuyRate, uint256 _swapFeeBuyRate) external onlyRole(DEFAULT_ADMIN_ROLE) {
        require(_burnFeeBuyRate + _liquidityFeeBuyRate + _swapFeeBuyRate <= 900, "rate");

        burnFeeBuyRate = _burnFeeBuyRate;
        liquidityFeeBuyRate = _liquidityFeeBuyRate;
        swapFeeBuyRate = _swapFeeBuyRate;

        emit BuyFeesUpdated(_burnFeeBuyRate, _liquidityFeeBuyRate, _swapFeeBuyRate);
    }

    function updateSellRates(uint256 _burnFeeSellRate, uint256 _liquidityFeeSellRate, uint256 _swapFeeSellRate) external onlyRole(DEFAULT_ADMIN_ROLE) {
        require(_burnFeeSellRate + _liquidityFeeSellRate + _swapFeeSellRate <= 900, "rate");

        burnFeeSellRate = _burnFeeSellRate;
        liquidityFeeSellRate = _liquidityFeeSellRate;
        swapFeeSellRate = _swapFeeSellRate;

        emit SellFeesUpdated(_burnFeeSellRate, _liquidityFeeSellRate, _swapFeeSellRate);
    }

    function updateTransferRates(uint256 _burnFeeTransferRate, uint256 _liquidityFeeTransferRate, uint256 _swapFeeTransferRate) external onlyRole(DEFAULT_ADMIN_ROLE) {
        require(_burnFeeTransferRate + _liquidityFeeTransferRate + _swapFeeTransferRate <= 900, "rate");

        burnFeeTransferRate = _burnFeeTransferRate;
        liquidityFeeTransferRate = _liquidityFeeTransferRate;
        swapFeeTransferRate = _swapFeeTransferRate;

        emit TransferFeesUpdated(_burnFeeTransferRate, _liquidityFeeTransferRate, _swapFeeTransferRate);
    }

    function resetCounter() external onlyRole(DEFAULT_ADMIN_ROLE) {
        feeCounter = 0;

        emit FeeCounterReseted();
    }

    function setLimit(uint256 _feeLimit) external onlyRole(DEFAULT_ADMIN_ROLE) {
        feeLimit = _feeLimit;

        emit FeeLimitUpdated();
    }

    function updateBurnFeeReceivers(address[] calldata _burnFeeReceivers, uint256[] calldata _burnFeeReceiversRate) external onlyRole(DEFAULT_ADMIN_ROLE) {
        require(_burnFeeReceivers.length == _burnFeeReceiversRate.length, "size");

        uint256 _totalRate = 0;
        for (uint256 _i = 0; _i < _burnFeeReceiversRate.length; _i++) {
            _totalRate += _burnFeeReceiversRate[_i];
        }
        require(_totalRate == 10000, "rate");

        delete burnFeeReceivers;
        delete burnFeeReceiversRate;

        for (uint i = 0; i < _burnFeeReceivers.length; i++) {
            burnFeeReceivers.push(_burnFeeReceivers[i]);
            burnFeeReceiversRate.push(_burnFeeReceiversRate[i]);
        }

        emit BurnFeeReceiversUpdated(_burnFeeReceivers, _burnFeeReceiversRate);
    }

    function updateLiquidityFeeReceivers(address[] calldata _liquidityFeeReceivers, uint256[] calldata _liquidityFeeReceiversRate) external onlyRole(DEFAULT_ADMIN_ROLE) {
        require(_liquidityFeeReceivers.length == _liquidityFeeReceiversRate.length, "size");

        uint256 _totalRate = 0;
        for (uint256 _i = 0; _i < _liquidityFeeReceiversRate.length; _i++) {
            _totalRate += _liquidityFeeReceiversRate[_i];
        }
        require(_totalRate == 10000, "rate");

        delete liquidityFeeReceivers;
        delete liquidityFeeReceiversRate;

        for (uint i = 0; i < _liquidityFeeReceivers.length; i++) {
            liquidityFeeReceivers.push(_liquidityFeeReceivers[i]);
            liquidityFeeReceiversRate.push(_liquidityFeeReceiversRate[i]);
        }

        emit LiquidityFeeReceiversUpdated(_liquidityFeeReceivers, _liquidityFeeReceiversRate);
    }

    function resetLiquidityFee() external onlyRole(DEFAULT_ADMIN_ROLE) {
        liquidityFeeAmount = 0;

        emit LiquidityFeeReseted();
    }

    function updateSwapFeeReceivers(address[] calldata _swapFeeReceivers, uint256[] calldata _swapFeeReceiversRate) external onlyRole(DEFAULT_ADMIN_ROLE) {
        require(_swapFeeReceivers.length == _swapFeeReceiversRate.length, "size");

        uint256 _totalRate = 0;
        for (uint256 _i = 0; _i < _swapFeeReceiversRate.length; _i++) {
            _totalRate += _swapFeeReceiversRate[_i];
        }
        require(_totalRate == 10000, "rate");

        delete swapFeeReceivers;
        delete swapFeeReceiversRate;

        for (uint _i = 0; _i < _swapFeeReceivers.length; _i++) {
            swapFeeReceivers.push(_swapFeeReceivers[_i]);
            swapFeeReceiversRate.push(_swapFeeReceiversRate[_i]);
        }

        emit SwapFeeReceiversUpdated(_swapFeeReceivers, _swapFeeReceiversRate);
    }

    function resetSwapFee() external onlyRole(DEFAULT_ADMIN_ROLE) {
        swapFeeAmount = 0;

        emit SwapFeeReseted();
    }

    function setEnabledSwapForSell(bool _enabledSwapForSell) external onlyRole(DEFAULT_ADMIN_ROLE) {
        enabledSwapForSell = _enabledSwapForSell;

        emit EnabledSwapForSellUpdated(_enabledSwapForSell);
    }

    function _transfer(address _from, address _to, uint256 _amount) internal {
        require(_from != address(0), "ERC20: transfer from the zero address");
        require(_to != address(0), "ERC20: transfer to the zero address");
        require(balances[_from] >= _amount, "ERC20: transfer amount exceeds balance");
        require(tradingEnabled || excludedFromFee[_from] || excludedFromFee[_to], "ERC20: Trading not yet enabled");

        uint256 calculatedAmount = _takeFees(_from, _to, _amount);
        _transferAmount(_from, _to, calculatedAmount);
    }

    function _takeFees(address _from, address _to, uint256 _amount) internal returns (uint256) {
        uint256 _resultAmount = _amount;

        if (!inSwap) {

            if (
                !(excludedFromFee[_from] || excludedFromFee[_to])
            ) {

                feeCounter += 1;

                uint256 _burnFeeRes;
                uint256 _liquidityFeeRes;
                uint256 _swapFeeRes;

                if (_isBuy(_from, _to)) {
                    _burnFeeRes = _calcFee(_resultAmount, burnFeeBuyRate);
                    _liquidityFeeRes = _calcFee(_resultAmount, liquidityFeeBuyRate);
                    _swapFeeRes = _calcFee(_resultAmount, swapFeeBuyRate);

                    rewardBuyAmount += _calcFee(_resultAmount, rewardBuyRate);
                } else if (_isSell(_from, _to)) {
                    _burnFeeRes = _calcFee(_resultAmount, burnFeeSellRate);
                    _liquidityFeeRes = _calcFee(_resultAmount, liquidityFeeSellRate);
                    _swapFeeRes = _calcFee(_resultAmount, swapFeeSellRate);

                    rewardSellAmount += _calcFee(_resultAmount, rewardSellRate);
                } else {
                    _burnFeeRes = _calcFee(_resultAmount, burnFeeTransferRate);
                    _liquidityFeeRes = _calcFee(_resultAmount, liquidityFeeTransferRate);
                    _swapFeeRes = _calcFee(_resultAmount, swapFeeTransferRate);
                }

                if (_burnFeeRes > 0) {
                    if (burnFeeReceivers.length > 0) {
                        for (uint256 _i = 0; _i < burnFeeReceivers.length; _i++) {
                            _transferAmount(_from, burnFeeReceivers[_i], _calcFee(_burnFeeRes, burnFeeReceiversRate[_i]));
                        }
                    } else {
                        _transferAmount(_from, deadAddress, _burnFeeRes);
                    }
                }

                if (_liquidityFeeRes > 0 || _swapFeeRes > 0) {
                    _transferAmount(_from, address(this), _liquidityFeeRes + _swapFeeRes);
                    liquidityFeeAmount += _liquidityFeeRes;
                    swapFeeAmount += _swapFeeRes;
                }

                _resultAmount -= _burnFeeRes + _liquidityFeeRes + _swapFeeRes;
            }

            if (
                !_isBuy(_from, _to) &&
                (!_isSell(_from, _to) || enabledSwapForSell) &&
                !(excludedFromSwap[_from] || excludedFromSwap[_to]) &&
                feeCounter >= feeLimit
            ) {
                uint256 _amountToSwap = 0;

                uint256 _liquidityFeeHalf = liquidityFeeAmount / 2;
                uint256 _liquidityFeeOtherHalf = liquidityFeeAmount - _liquidityFeeHalf;

                if (_liquidityFeeOtherHalf > 0 && _liquidityFeeHalf > 0) {
                    _amountToSwap += _liquidityFeeHalf;
                }

                _amountToSwap += swapFeeAmount;

                uint256 _rewardsToSwap = rewardBuyAmount + rewardSellAmount;
                if (_rewardsToSwap > 0) {
                    if (balanceOf(rewardSwapAddress) >= _rewardsToSwap) {
                        _transferAmount(rewardSwapAddress, address(this), _rewardsToSwap);
                        _amountToSwap += _rewardsToSwap;
                    } else {
                        rewardBuyAmount = 0;
                        rewardSellAmount = 0;
                        _rewardsToSwap = 0;
                    }
                }

                if (_amountToSwap > 0) {
                    IERC20 _token1 = IERC20(token1);
                    uint256 _oldToken1Balance = _token1.balanceOf(address(distribution));
                    _swapTokensForToken1(_amountToSwap, address(distribution));
                    uint256 _newToken1Balance = _token1.balanceOf(address(distribution));
                    uint256 _token1Balance = _newToken1Balance - _oldToken1Balance;

                    if (_liquidityFeeOtherHalf > 0 && _liquidityFeeHalf > 0) {
                        uint256 _liquidityFeeToken1Amount = _calcFee(_token1Balance, _liquidityFeeHalf * 10000 / _amountToSwap);
                        distribution.recoverTokensFor(token1, _liquidityFeeToken1Amount, address(this));

                        IERC20 _lp = IERC20(pair);
                        uint256 _oldLpBalance = _lp.balanceOf(address(distribution));
                        if (liquidityFeeReceivers.length == 1) {
                            _addLiquidity(_liquidityFeeOtherHalf, _liquidityFeeToken1Amount, liquidityFeeReceivers[0]);
                        } else {
                            _addLiquidity(_liquidityFeeOtherHalf, _liquidityFeeToken1Amount, address(distribution));
                        }
                        uint256 _newLpBalance = _lp.balanceOf(address(distribution));
                        uint256 _lpBalance = _newLpBalance - _oldLpBalance;

                        if (liquidityFeeReceivers.length > 1) {
                            for (uint256 i = 0; i < liquidityFeeReceivers.length; i++) {
                                distribution.recoverTokensFor(pair, _calcFee(_lpBalance, liquidityFeeReceiversRate[i]), liquidityFeeReceivers[i]);
                            }
                        }
                    }

                    if (swapFeeAmount > 0) {
                        uint256 _swapFeeToken1Amount = _calcFee(_token1Balance, swapFeeAmount * 10000 / _amountToSwap);

                        for (uint256 i = 0; i < swapFeeReceivers.length; i++) {
                            distribution.recoverTokensFor(token1, _calcFee(_swapFeeToken1Amount, swapFeeReceiversRate[i]), swapFeeReceivers[i]);
                        }
                    }

                    if (_rewardsToSwap > 0) {
                        uint256 _rewardToken1Amount = _calcFee(_token1Balance, _rewardsToSwap * 10000 / _amountToSwap);

                        for (uint256 _i = 0; _i < rewardSwapReceivers.length; _i++) {
                            distribution.recoverTokensFor(token1, _calcFee(_rewardToken1Amount, rewardSwapReceiversRate[_i]), rewardSwapReceivers[_i]);
                        }
                    }

                    feeCounter = 0;
                    liquidityFeeAmount = 0;
                    swapFeeAmount = 0;
                    rewardBuyAmount = 0;
                    rewardSellAmount = 0;
                }
            }
        }

        return _resultAmount;
    }

    function _transferAmount(address _from, address _to, uint256 _amount) internal {
        balances[_from] -= _amount;
        balances[_to] += _amount;

        emit Transfer(_from, _to, _amount);
    }

    function _mint(address _account, uint256 _amount) internal {
        require(_account != address(0), "ERC20: mint to the zero address");

        totalSupply += _amount;
        balances[_account] += _amount;

        emit Transfer(address(0), _account, _amount);
    }

    /*function _burn(address _account, uint256 _amount) internal {
        require(_account != address(0), "ERC20: burn from the zero address");
        require(_account != deadAddress, "ERC20: burn from the dead address");
        require(balances[_account] >= _amount, "ERC20: burn amount exceeds balance");

        _transferAmount(_account, deadAddress, _amount);
    }*/

    function _approve(address _owner, address _spender, uint256 _amount) internal {
        require(_owner != address(0), "ERC20: approve from the zero address");
        require(_spender != address(0), "ERC20: approve to the zero address");

        allowances[_owner][_spender] = _amount;
        emit Approval(_owner, _spender, _amount);
    }

    function _setRouterAndPair(IUniswapV2Router02 _router, address _token1) internal {
        require(_token1 != address(0), "zero token1 address");

        address _pair = IUniswapV2Factory(_router.factory()).getPair(address(this), _token1);

        if (_pair == address(0)) {
            _pair = IUniswapV2Factory(_router.factory()).createPair(address(this), _token1);
        }

        router = _router;
        token1 = _token1;
        pair = _pair;
        isLpToken[pair] = true;
    }

    function _calcFee(uint256 _amount, uint256 _rate) internal pure returns (uint256) {
        return _rate > 0 ? _amount * _rate / 10000 : 0;
    }

    function _isSell(address _from, address _to) internal view returns (bool) {
        return !isLpToken[_from] && isLpToken[_to];
    }

    function _isBuy(address _from, address _to) internal view returns (bool) {
        return isLpToken[_from] && !isLpToken[_to];
    }

    function _swapTokensForToken1(uint256 _tokenAmount, address _recipient) internal lockTheSwap {
        // generate the uniswap pair path of token -> token1
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = token1;

        _approve(address(this), address(router), _tokenAmount);
        // make the swap

        router.swapExactTokensForTokensSupportingFeeOnTransferTokens(
            _tokenAmount,
            0, // accept any amount of token1
            path,
            _recipient,
            block.timestamp
        );
    }

    function _addLiquidity(uint256 _tokenAmount, uint256 _token1Amount, address _recipient) internal lockTheSwap {
        // approve token transfer to cover all possible scenarios
        _approve(address(this), address(router), _tokenAmount);
        IERC20(token1).approve(address(router), _token1Amount);

        // add the liquidity
        router.addLiquidity(
            address(this),
            token1,
            _tokenAmount,
            _token1Amount,
            0,
            0,
            _recipient,
            block.timestamp
        );
    }

}
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.2;

import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "./interfaces/IGrokNYDistribution.sol";

contract GrokNYDistribution is IGrokNYDistribution, AccessControl {

    constructor() {
        _setupRole(DEFAULT_ADMIN_ROLE, msg.sender);
    }

    function recoverTokensFor(address _token, uint256 _amount, address _to) external override onlyRole(DEFAULT_ADMIN_ROLE) {
        IERC20(_token).transfer(_to, _amount);
    }

}
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.2;

interface IGrokNYDistribution {

    function recoverTokensFor(address _token, uint256 _amount, address _to) external;

}
