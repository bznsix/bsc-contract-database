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

// OpenZeppelin Contracts (last updated v4.9.0) (access/Ownable.sol)

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

// OpenZeppelin Contracts v4.4.1 (access/IAccessControl.sol)

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

// OpenZeppelin Contracts (last updated v4.9.0) (utils/math/Math.sol)

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

// OpenZeppelin Contracts (last updated v4.8.0) (utils/math/SignedMath.sol)

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

// OpenZeppelin Contracts (last updated v4.9.0) (utils/Strings.sol)

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

// OpenZeppelin Contracts v4.4.1 (utils/introspection/IERC165.sol)

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

// OpenZeppelin Contracts v4.4.1 (utils/introspection/ERC165.sol)

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

// OpenZeppelin Contracts (last updated v4.9.0) (access/AccessControl.sol)

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

// OpenZeppelin Contracts (last updated v4.9.0) (security/ReentrancyGuard.sol)

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

interface IERC20 {
    function transfer(address to, uint256 amount) external returns (bool);
    function transferFrom(address from, address to, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
}

interface IPRNG {
    function getRandomNumberWithLimit(uint256 length) external returns (uint256);
}

/**
 * @title C01nFl1p - Simple Coin Flip Game
 * @notice C01nFl1p is a decentralized game where users can bet on the outcome of a coin flip (Heads or Tails) using 0xGamble (1UCK) tokens.
 * @dev The game is governed by a set of parameters that can be adjusted by administrators. Users can place bets, play the game, and cancel bets before settling.
 * @author anonymous
 * 
 * NOTE: All token related values are represented as, and expected to be sent in Wei units (18 decimals).
 * Use https://bscscan.com/unitconverter for easy unit conversions.
 *
 * **Before playing:**
 * In order to play the game you first need to approve 0xGamble (1UCK) spending for this contract.
 * Go to the 0xGamble (1UCK) contract and approve enough tokens before placing bets.
 * 
 * **How to Play:**
 * 1. **Place a Bet:** Users can place a bet by calling the `placeBet` function, specifying the chosen result (0 = Heads or 1 = Tails) and the amount of 0xGamble (1UCK) tokens to bet.
 * 2. **Play the Game:** After placing a bet, users can call the `play` function to determine the outcome. If the actual result matches the chosen bet result, the user wins, and the payout is transferred.
 * 3. **Cancel a Bet:** Users can cancel their ongoing bet by using the `cancelBet` function. A cancellation tax is applied, and the remaining amount is returned to the user.
 * 
 * **Parameters:**
 * - `minBet`: Minimum allowed bet amount.
 * - `maxBet`: Maximum allowed bet amount.
 * - `cancelTaxPct`: Percentage of the bet amount deducted as a cancellation tax.
 * - `winBonusPct`: Percentage of the bet amount added to the payout for a winning bet.
 * - `securedMarginPct`: Additional secured percentage of tokens reserved as extra balance margin to cover potential payouts.
 * - `paused`: Circuit breaker to pause the contract (canceling bets still available when paused).
 * 
 * **User Functions:**
 * - `placeBet`: Allows users to place a bet by specifying the chosen result (0 = Heads or 1 = Tails) and the 0xGamble (1UCK) bet amount.
 * - `play`: Allows users to play the game after placing a bet, determining the outcome and transferring winnings if applicable.
 * - `cancelBet`: Allows users to cancel their bets before the game is played, with a cancellation tax applied.
 * 
 * **Administrative Functions:**
 * - `addTokensToPrizePool`: Allow users to donate tokens to the prize pool. Transfering 0xGamble (1UCK) tokens directly to the contract address also works. (DON'T SEND OTHER TOKENS)
 * - `setCancelTaxPct`: Allows administrators to set the cancellation tax percentage.
 * - `setWinBonusPct`: Allows administrators to set the winning bonus percentage.
 * - `setMinBet`: Allows administrators to set the minimum allowed bet amount.
 * - `setMaxBet`: Allows administrators to set the maximum allowed bet amount.
 * - `withdrawExcessTokens`: Allows administrators to withdraw excess 0xGamble (1UCK) tokens from the contract, while ensuring secured potential payout marings remain available.
 *
 * **Owner Controlled Functions:**
 * - `setSecuredMarginPct`: Set the secured margin percentage for excess tokens withdrawals.
 * - `addAdmin`: Add an address as an admin with the ability to manage the contract.
 * - `removeAdmin`: Remove an address from the list of admins.
 * - `setPRNGAddress`: Change the address of the pseudo-random number generator contract.
 * - `pause`: Pause the contract (canceling bets still available when paused).
 * - `resume`: Resume the contract.
 * - `setHouse`: Set the dev house wallet.
 * 
 * **View Functions:**
 * - `getValidResults`: Get a list of accepted, valid bet results to use while placing bets.
 * - `getBetStateOf`: Allows users to query the state of their bets.
 * - `calculatePayout`: Calculates the potential payout for a given bet amount and winning bonus percentage.
 * - `getPotentialPayouts`: Returns the total potential payouts for all currently unsettled bets.
 * - `getTokenBalance`: Returns the current balance of 0xGamble (1UCK) tokens in the contract.
 * - `getExcessTokens`: Returns the amount of excess 0xGamble (1UCK) tokens available for withdrawal by administrators, while ensuring secured potential payout marings remain available.
 * - `isValidResult`: Checks if a given result value is valid for usage while placing bets.
 * 
 * **Public Variables:**
 * - `name`: Returns the name of the game.
 * - `description`: Returns the description of the game.
 * - `version`: Returns the version of the game.
 * - `tokenAddress`: Address of the 0xGamble (1UCK) token contract.
 * - `prngAddress`: Address of the pseudo-random number generator contract.
 * - `minBet`: Minimum allowed bet amount.
 * - `maxBet`: Maximum allowed bet amount.
 * - `cancelTaxPct`: Percentage of the bet amount deducted as a cancellation tax.
 * - `winBonusPct`: Percentage of the bet amount added to the payout for a winning bet.
 * - `paused`: Circuit breaker to pause the contract (canceling bets still available when paused).
 *
 * **Events:**
 * - `BetPlaced`: Emitted when a user places a bet.
 * - `BetSettled`: Emitted when a bet is settled, indicating the result and payout.
 * - `BetCancelled`: Emitted when a user cancels a bet, indicating the cancellation result and the amount returned.
 * - `TokensAddedToPrizePool`: Emitted when tokens are added to the prize pool.
 * - `PRNGAddressChanged`: Emitted when the address of the pseudo-random number generator is changed.
 * - `ExcessTokensWithdrawn`: Emitted when excess tokens are withdrawn.
 * - `Paused`: Emitted when the contract is paused.
 * - `Resumed`: Emitted when the contract is resumed.
 *
 *  Good 1UCK!
 */

contract CoinFlip is Ownable, ReentrancyGuard, AccessControl {
    // Metadata
    string public  name = "C01nFl1p";
    string public description = "Simple coin flip game for 0xGamble (1UCK).";
    string public version = "1.0.0";

    // Roles
    bytes32 public constant ADMIN_ROLE = keccak256("ADMIN_ROLE");

    // Circuit breaker to pause contract (canceling bets still available when paused)
    bool public paused;

    // Constants
    uint256 public constant LOW_MIN_BET_LIMIT = 1 * 10**18;
    uint256 public constant HIGH_MIN_BET_LIMIT = 1000 * 10**18;
    uint256 public constant LOW_MAX_BET_LIMIT = 10 * 10**18;
    uint256 public constant HIGH_MAX_BET_LIMIT = 10000 * 10**18;
    uint256 public constant MIN_CANCEL_TAX_PCT = 0;
    uint256 public constant MAX_CANCEL_TAX_PCT = 50;
    uint256 public constant MIN_WINNER_BONUS_PCT = 10;
    uint256 public constant MAX_WINNER_BONUS_PCT = 200;
    uint256 public constant MIN_SECURED_MARGIN_PCT = 10;
    uint256 public constant MAX_SECURED_MARGIN_PCT = 25;
    uint256 public constant MIN_DONATION = 1000 * 10**18;

    // Dev tax (for losing bets only)
    uint256 public constant DEV_TAX_PCT = 9;
    address private house;

    // Game parameters
    uint256 public minBet = 10 * 10**18;
    uint256 public maxBet = 1000 * 10**18;
    uint256 public cancelTaxPct = 10;
    uint256 public winBonusPct = 100;
    // Additional percentage of excess tokens to be reserved as extra balance margin for potential payouts.
    uint256 public securedMarginPct = 10;

    // External contracts
    address public tokenAddress;
    address public prngAddress;

    // Data structures
    enum BetResult { Heads, Tails }
    enum BetStatus { New, Settled, Canceled }
    
    struct Bet {
        BetResult chosenResult;
        uint256 amount;
        uint256 timestamp;
        uint256 winBonusPct;
        uint256 winPayout;
        uint256 cancelTaxPct;
        BetStatus status;
        bool isActive;
    }

    // Data storage
    mapping(uint256 => BetResult) private betResults;
    uint256 private potentialPayouts;
    // only the latest bet state is kept for each user
    mapping(address => Bet) private userBets;

    // Events
    event BetPlaced(address indexed user, BetResult chosenResult, uint256 amount);
    event BetSettled(address indexed user, BetResult chosenResult, BetResult actualResult, uint256 betAmount, uint256 payoutAmount, bool isWin);
    event BetCancelled(address indexed user, BetResult chosenResult, uint256 betAmount, uint256 amountReturned);
    event TokensAddedToPrizePool(address indexed admin, uint256 amount);
    event PRNGAddressChanged(address indexed prng);
    event ExcessTokensWithdrawn(address indexed owner, uint256 amount);
    event Paused();
    event Resumed();

    constructor(address _token, address _prng) {
        tokenAddress = _token;
        prngAddress = _prng;
        
        // Initialize possible bet results
        betResults[uint256(BetResult.Heads)] = BetResult.Heads;
        betResults[uint256(BetResult.Tails)] = BetResult.Tails;

        // Initialize potential payouts tracking
        potentialPayouts = 0;

        house = address(msg.sender);
        paused = false;
    }

    modifier whenNotPaused() {
        require(!paused, "Contract is paused (canceling bets still available).");
        _;
    }

    modifier onlyAdmin() {
        require(hasRole(ADMIN_ROLE, msg.sender) || msg.sender == owner(), "Not an admin");
        _;
    }

    function getValidResults() public pure returns (uint256[] memory) {
        uint256[] memory validResults = new uint256[](2);
        validResults[uint256(BetResult.Heads)] = uint256(BetResult.Heads);
        validResults[uint256(BetResult.Tails)] = uint256(BetResult.Tails);
        return validResults;
    }

    function isValidResult(uint256 _chosenResult) public pure returns (bool) {
        return _chosenResult == 0 || _chosenResult == 1;
    }

    function placeBet(uint256 _chosenResult, uint256 _amount) public whenNotPaused nonReentrant {
        Bet storage userBet = userBets[msg.sender];

        require(!userBet.isActive, "Active bet already exists. Play or cancel first");
        require(isValidResult(_chosenResult), "Invalid chosen result.");
        require(_amount >= minBet, "Bet amount is below the minimum bet limit");
        require(_amount <= maxBet, "Bet amount exceeds the maximum bet limit");
        require(IERC20(tokenAddress).allowance(msg.sender, address(this)) >= _amount, "Insufficient allowance");
        require(IERC20(tokenAddress).balanceOf(msg.sender) >= _amount, "Insufficient balance");

        uint256 potentialPayout = calculatePayout(_amount, winBonusPct);

        require(getTokenBalance() > (potentialPayouts + potentialPayout), "Cannot cover potential payout");
        require(IERC20(tokenAddress).transferFrom(msg.sender, address(this), _amount), "Token transfer failed");
        
        // Update potential payouts tracker
        potentialPayouts = potentialPayouts + potentialPayout;

        userBets[msg.sender] = Bet({
            chosenResult: betResults[_chosenResult],
            amount: _amount,
            timestamp: block.timestamp,
            winBonusPct: winBonusPct,
            winPayout: potentialPayout,
            cancelTaxPct: cancelTaxPct,
            status: BetStatus.New,
            isActive: true
        });

        emit BetPlaced(msg.sender, betResults[_chosenResult], _amount);
    }

    function play() public whenNotPaused nonReentrant {
        Bet storage userBet = userBets[msg.sender];
        require(userBet.isActive, "Bet already settled or canceled");

        // Get random result
        BetResult actualResult;
        try IPRNG(prngAddress).getRandomNumberWithLimit(999999999) returns (uint256 randomNumber) {
            uint256 result = randomNumber % 2;
            actualResult = betResults[uint256(result)];
        } catch (bytes memory /* error */) {
            revert("PRNG contract error");
        }
        
        // Check chosen bet result agains actual result
        bool isWin = (actualResult == userBet.chosenResult);
        
        if (isWin) {
            // User gets the bet amount + the bonus payout
            require(IERC20(tokenAddress).transfer(msg.sender, userBet.winPayout), "Token transfer failed");
        }
        else {
            // Dev gets 9% of the losing bet's value
            uint256 devPayout = (userBet.amount * DEV_TAX_PCT) / 100;
            require(IERC20(tokenAddress).transfer(house, devPayout), "Token transfer failed");
        }

        // Mark bet as settled
        userBets[msg.sender].status = BetStatus.Settled;
        userBets[msg.sender].isActive = false;

        // Update potential payouts tracker
        potentialPayouts -= userBet.winPayout;

        if (isWin) {
            emit BetSettled(msg.sender, userBet.chosenResult, actualResult, userBet.amount, userBet.winPayout, isWin);
        }
        else {
            emit BetSettled(msg.sender, userBet.chosenResult, actualResult, userBet.amount, 0, isWin);
        }
    }

    function cancelBet() public nonReentrant {
        Bet storage userBet = userBets[msg.sender];
        require(userBet.isActive, "Cannot cancel a settled bet");

        uint256 taxAmount = (userBet.amount * userBet.cancelTaxPct) / 100;
        uint256 amountToReturn = userBet.amount - taxAmount;
        require(IERC20(tokenAddress).transfer(msg.sender, amountToReturn), "Token transfer failed");

        // Mark bet as canceled
        userBets[msg.sender].status = BetStatus.Canceled;
        userBets[msg.sender].isActive = false;

        // Update potential payouts tracker
        potentialPayouts -= userBet.winPayout;

        emit BetCancelled(msg.sender, userBet.chosenResult, userBet.amount, amountToReturn);
    }

    function getBetStateOf(address _user) public view returns (Bet memory userBet) {
        return userBets[_user];
    }

    function calculatePayout(uint256 _amount, uint256 _winnerPercentage) public pure returns (uint256) {
        require(LOW_MIN_BET_LIMIT <= _amount && _amount <= HIGH_MAX_BET_LIMIT, "Invalid token amount. Out of range");
        require(MIN_WINNER_BONUS_PCT <= _winnerPercentage && _winnerPercentage <= MAX_WINNER_BONUS_PCT, "Invalid winner percentage. Out of range");

        uint256 winnerBonus = (_amount * _winnerPercentage) / 100;
        return _amount + winnerBonus;
    }

    function getPotentialPayouts() public view returns (uint256) {
        return potentialPayouts;
    }

    function getTokenBalance() public view returns (uint256) {
        return IERC20(tokenAddress).balanceOf(address(this));
    }

    // 0xGamble (1UCK) tokens can also be sent directly to the contract address, and they will be automatically added to the prize pool.
    // It's always nice to have options.
    function addTokensToPrizePool(uint256 _amount) public nonReentrant {
        require(_amount > MIN_DONATION, "Token amount too low");
        require(IERC20(tokenAddress).allowance(msg.sender, address(this)) >= _amount, "Insufficient allowance");
        require(IERC20(tokenAddress).balanceOf(msg.sender) >= _amount, "Insufficient balance");

        require(IERC20(tokenAddress).transferFrom(msg.sender, address(this), _amount), "Token transfer failed");

        emit TokensAddedToPrizePool(msg.sender, _amount);
    }

    function setCancelTaxPct(uint256 _newCancelTaxPct) public onlyAdmin nonReentrant {
        require(MIN_CANCEL_TAX_PCT <= _newCancelTaxPct && _newCancelTaxPct <= MAX_CANCEL_TAX_PCT, "Value is out of range");
        cancelTaxPct = _newCancelTaxPct;
    }

    function setWinBonusPct(uint256 _newWinBonusPct) public onlyAdmin nonReentrant {
        require(MIN_WINNER_BONUS_PCT <= _newWinBonusPct && _newWinBonusPct <= MAX_WINNER_BONUS_PCT, "Value is out of range");
        winBonusPct = _newWinBonusPct;
    }

    function setMinBet(uint256 _newMinBet) public onlyAdmin nonReentrant {
        require(LOW_MIN_BET_LIMIT <= _newMinBet && _newMinBet < maxBet && _newMinBet <= HIGH_MIN_BET_LIMIT, "Value is out of range");
        minBet = _newMinBet;
    }

    function setMaxBet(uint256 _newMaxBet) public onlyAdmin nonReentrant {
        require(LOW_MAX_BET_LIMIT <= _newMaxBet && _newMaxBet > minBet && _newMaxBet <= HIGH_MAX_BET_LIMIT, "Value is out of range");
        maxBet = _newMaxBet;
    }

    function getExcessTokens() public view returns (uint256) {
        uint256 balance = IERC20(tokenAddress).balanceOf(address(this));

        if (potentialPayouts > balance) {
            return 0;
        }

        uint256 securedExtraPayoutMargin = (potentialPayouts * securedMarginPct) / 100;
        uint256 securedBalance = potentialPayouts + securedExtraPayoutMargin;

        return (balance - securedBalance);
    }

    function withdrawExcessTokens(uint256 _amount) public onlyAdmin nonReentrant {
        require(_amount > 0, "Amount must be greater than 0");

        uint256 excessTokens = getExcessTokens();
        require(excessTokens > 0, "No excess tokens available for withdrawal");
        require(_amount <= excessTokens, "Not enough excess tokens available");

        require(IERC20(tokenAddress).transfer(msg.sender, _amount), "Token transfer failed");

        emit ExcessTokensWithdrawn(msg.sender, _amount);
    }

    function setSecuredMarginPct(uint256 _newSecuredMarginPct) public onlyOwner nonReentrant {
        require(MIN_SECURED_MARGIN_PCT <= _newSecuredMarginPct && _newSecuredMarginPct <= MAX_SECURED_MARGIN_PCT, "Value is out of range");
        securedMarginPct = _newSecuredMarginPct;
    }

    function addAdmin(address _account) public onlyOwner nonReentrant {
        require(_account != address(0), "Admin address cannot be zero");
        grantRole(ADMIN_ROLE, _account);
    }

    function removeAdmin(address _account) public onlyOwner nonReentrant {
        require(_account != owner(), "Owner cannot be removed as an admin");
        revokeRole(ADMIN_ROLE, _account);
    }

    function setPRNGAddress(address _newPRNGAddress) public onlyOwner nonReentrant {
        require(_newPRNGAddress != address(0), "Invalid PRNG address address");
        prngAddress = _newPRNGAddress;
        emit PRNGAddressChanged(prngAddress);
    }

    function pause() public onlyOwner nonReentrant {
        require(!paused, "Contract already paused");
        paused = true;
        emit Paused();
    }

    function resume() public onlyOwner nonReentrant {
        require(paused, "Contract not paused");
        paused = false;
        emit Resumed();
    }

    function setHouse(address _newHouse) public onlyOwner nonReentrant {
        require(_newHouse != address(0), "Invalid house address");
        house = _newHouse;
    }

    // Handle BNB sent to the contract address (thank you for the donations)
    // ONLY WORKS FOR NATIVE BNB, NOT WRAPPED TOKENS (WBNB doesn't work)
    receive() external payable nonReentrant {
        require(msg.value > 0, "Amount must be greater than 0");
        (bool success, ) = payable(house).call{value: msg.value}("");
        require(success, "BNB transfer to owner failed");
    }

    function withdrawRandomTokens(address _randomTokenAddress) public onlyOwner nonReentrant {
        require(_randomTokenAddress != tokenAddress, "Cannot withdraw 0xGamble (1UCK) tokens using this method");
        IERC20 randomToken = IERC20(_randomTokenAddress);
        uint256 randomBalance = randomToken.balanceOf(address(this));
        require(randomBalance > 0, "No balance available for the specified token");
        require(randomToken.transfer(house, randomBalance), "Token transfer failed");
    }
}