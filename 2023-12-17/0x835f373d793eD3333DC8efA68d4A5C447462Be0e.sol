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
// OpenZeppelin Contracts (last updated v4.9.0) (utils/math/SafeMath.sol)

pragma solidity ^0.8.0;

// CAUTION
// This version of SafeMath should only be used with Solidity 0.8 or later,
// because it relies on the compiler's built in overflow checks.

/**
 * @dev Wrappers over Solidity's arithmetic operations.
 *
 * NOTE: `SafeMath` is generally not needed starting with Solidity 0.8, since the compiler
 * now has built in overflow checking.
 */
library SafeMath {
    /**
     * @dev Returns the addition of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function tryAdd(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            uint256 c = a + b;
            if (c < a) return (false, 0);
            return (true, c);
        }
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function trySub(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b > a) return (false, 0);
            return (true, a - b);
        }
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function tryMul(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
            // benefit is lost if 'b' is also tested.
            // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
            if (a == 0) return (true, 0);
            uint256 c = a * b;
            if (c / a != b) return (false, 0);
            return (true, c);
        }
    }

    /**
     * @dev Returns the division of two unsigned integers, with a division by zero flag.
     *
     * _Available since v3.4._
     */
    function tryDiv(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a / b);
        }
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers, with a division by zero flag.
     *
     * _Available since v3.4._
     */
    function tryMod(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a % b);
        }
    }

    /**
     * @dev Returns the addition of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `+` operator.
     *
     * Requirements:
     *
     * - Addition cannot overflow.
     */
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        return a + b;
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting on
     * overflow (when the result is negative).
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     *
     * - Subtraction cannot overflow.
     */
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return a - b;
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `*` operator.
     *
     * Requirements:
     *
     * - Multiplication cannot overflow.
     */
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        return a * b;
    }

    /**
     * @dev Returns the integer division of two unsigned integers, reverting on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator.
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return a / b;
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * reverting when dividing by zero.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return a % b;
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting with custom message on
     * overflow (when the result is negative).
     *
     * CAUTION: This function is deprecated because it requires allocating memory for the error
     * message unnecessarily. For custom revert reasons use {trySub}.
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     *
     * - Subtraction cannot overflow.
     */
    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        unchecked {
            require(b <= a, errorMessage);
            return a - b;
        }
    }

    /**
     * @dev Returns the integer division of two unsigned integers, reverting with custom message on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator. Note: this function uses a
     * `revert` opcode (which leaves remaining gas untouched) while Solidity
     * uses an invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        unchecked {
            require(b > 0, errorMessage);
            return a / b;
        }
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * reverting with custom message when dividing by zero.
     *
     * CAUTION: This function is deprecated because it requires allocating memory for the error
     * message unnecessarily. For custom revert reasons use {tryMod}.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        unchecked {
            require(b > 0, errorMessage);
            return a % b;
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
pragma solidity >=0.7.0 <0.9.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";

/**
 * @title UltronGPT
 * @dev A Solidity smart contract for managing a robot-based investment platform.
 */
contract UltronGPT is Ownable, AccessControl {
    using SafeMath for uint256;

    struct DepositInfo {
        uint256 depositAmount;
        uint256 timestamp;
        address referrer;
    }

    struct Referral {
        address referredBy;
    }

    struct RobotInfo {
        uint256 activeRobots;
    }

    struct Robot {
        uint256 robotId;
        uint256 value;
        uint256 activationTime;
        uint256 expiredOn;
        uint256 quantifiedOn;
        bool quantifiedActive;
        bool activated;
        bool profitClaimed;
    }
    struct TransactionRecord {
        uint256 timestamp;
        string action;
        uint256 amount;
        address from;
    }

    struct TeamInfo {
        address[] totalTeam;
        uint256 totalInvestment;
    }

    uint256 public platformShare;
    uint256[] public robotsPrice;
    uint256 public profitPercentage;
    uint256 public totalValueLocked;
    uint256 public minQuantTime;

    uint256 BitcoinRobot = 20 * 1e18;
    uint256 EthereumRobot = 80 * 1e18;
    uint256 RippleRobot = 220 * 1e18;
    uint256 CardanoRobot = 500 * 1e18;
    uint256 DogeCoinRobot = 1000 * 1e18;
    uint256 ShibaInuRobot = 1500 * 1e18;
    uint256 SolanaRobot = 2000 * 1e18;
    uint256 LitCoinRobot = 3500 * 1e18;
    uint256 PolygonRobot = 5000 * 1e18;

    address public depositToken;
    address public taxReceiver;
    address public firstSigner;
    address public secondSigner;
    address public thirdSigner;
    bool public isWithdrawActive;
    IERC20 public token;

    bytes32 public constant SIGNER_ROLE = keccak256("SIGNER_ROLE");

    mapping(address => DepositInfo) public deposit;
    mapping(address => Referral) public referrals;
    mapping(address => uint256) public totalReferralCommissions;
    mapping(address => mapping(uint256 => RobotInfo)) public robots;
    mapping(address => uint256) public lastClaim;
    mapping(address => bool) public blackListed;
    mapping(address => uint256) public userRobotsValue;
    mapping(address => uint256) public teamRobotValue;
    mapping(address => uint256) public totalProfit;

    mapping(address => bool) public isSigned;
    mapping(address => bool) public firstDepositReferral;
    mapping(address => mapping(uint256 => Robot)) public activatedRobots;
    mapping(address => uint256) public userActivatedRobots;
    mapping(address => uint256) public individualInvestment;
    mapping(address => TransactionRecord[]) public transactionHistory;
    mapping(address => bool) public firstWithdrawlReferral;
    mapping(address => TeamInfo) public team;

    event WithdrawalAuthorized(address indexed initiator, uint256 amount);
    event WithdrawalSigned(address indexed signer, uint256 timestamp);
    event ProfitTransfered(address to, uint256 time, uint256 amount);

    event FundDeposited(
        address depositer,
        address receiver,
        address referrer,
        uint256 amount
    );

    event UserWithdraw(address from, uint256 amountWithdraw);

    event RobotActivated(address activatedBy, uint256 robotAmount);

    event OwnerWithdraw(address from, uint256 amount);

    event PlatformShareUpdated(address from, uint256 newPlatformShare);

    event ProfitPercentageUpdated(address from, uint256 newProfitPercentage);

    event RewardTransfered(
        address user1,
        address user2,
        address user3,
        uint256 userPercentage1,
        uint256 userPercentage2,
        uint256 userPercentage3
    );
    event DepositPaused(address from, uint256 time, bool status);
    event userBlackListed(address from, address blacklistedUser);

    /**
     * @dev Constructor function to initialize the contract.
     * @param _depositToken Address of the deposit token.
     * @param _taxReceiver Address to receive tax on deposits.
     * @param _platformShare Percentage of platform share.
     * @param _profitPercentage Percentage of profit on robots.
     */
    constructor(
        address _firstSigner,
        address _secondSigner,
        address _thirdSigner,
        address _depositToken,
        address _taxReceiver,
        uint256 _platformShare,
        uint256 _profitPercentage
    ) {
        require(_platformShare > 0, "Platform Share Can't be Zero");
        require(
            _depositToken != address(0),
            "Deposit Token Address Can't be Zero"
        );
        require(
            _profitPercentage > 0,
            "Profit Percentage Should be Greater than zero"
        );
        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
        _grantRole(SIGNER_ROLE, _firstSigner);
        _grantRole(SIGNER_ROLE, _secondSigner);
        _grantRole(SIGNER_ROLE, _thirdSigner);
        token = IERC20(_depositToken);
        platformShare = _platformShare;
        taxReceiver = _taxReceiver;
        profitPercentage = _profitPercentage;

        firstSigner = _firstSigner;
        secondSigner = _secondSigner;
        thirdSigner = _thirdSigner;
    }

    /**
     * @dev Throws if the withdrawal is not authorized by all signers.
     */
    modifier isWithDrawlApproved() {
        require(
            isSigned[firstSigner] && isSigned[secondSigner],
            "Withdrawal is not authorized by all signers"
        );
        _;
    }

    /**
     * @dev Function for a signer to sign the withdrawal.
     */
    function signWithdraw() public onlyRole(SIGNER_ROLE) {
        isSigned[msg.sender] = true;
        emit WithdrawalSigned(msg.sender, block.timestamp);
    }

    /**
     * @dev Deposits funds into the contract.
     * @param _amount The amount of funds to deposit.
     * @param _referrer The address of the referrer.
     * Requirements:
     * - The amount must be greater than zero.
     * - Transfers the user's deposit to the contract.
     * - Transfers the platform share to the tax receiver.
     * - Sets the user's deposit information (amount, timestamp, referrer).
     * - If the referrer is a valid address and different from the user:
     *   - Sets the user as the referrer for the caller.
     * Emits the `FundDeposited` event with the user's address, contract address, referrer, and amount deposited.
     */
    function depositFunds(uint256 _amount, address _referrer) external {
        require(
            _referrer != msg.sender,
            "You cant use your own address as referrer"
        );
        require(_amount > 0, "Deposit Should be Greater Than Zero");
        require(_amount >= 20 * 1e18, "Minimum Deposit is 20 USDT");
        if (
            _referrer != address(0) &&
            !firstDepositReferral[msg.sender] &&
            _referrer != msg.sender
        ) {
            deposit[msg.sender].depositAmount += _amount;
            deposit[msg.sender].timestamp = block.timestamp;
            deposit[msg.sender].referrer = _referrer;
            token.transferFrom(msg.sender, address(this), _amount);
            firstDepositReferral[msg.sender] = true;
            team[_referrer].totalTeam.push(msg.sender);
        } else {
            uint256 ownerShare = _amount.mul(platformShare).div(100);
            uint256 userDeposit = _amount.sub(ownerShare);
            deposit[msg.sender].depositAmount += userDeposit;
            deposit[msg.sender].timestamp = block.timestamp;
            deposit[msg.sender].referrer = _referrer;
            token.transferFrom(msg.sender, address(this), userDeposit);
            token.transferFrom(msg.sender, taxReceiver, ownerShare);
        }

        if (
            _referrer != address(0) &&
            _referrer != msg.sender &&
            referrals[msg.sender].referredBy == address(0)
        ) {
            referrals[msg.sender] = Referral(_referrer);
        }
        TransactionRecord memory record = TransactionRecord({
            timestamp: block.timestamp,
            action: "Deposit Funds",
            amount: _amount,
            from: msg.sender
        });

        transactionHistory[msg.sender].push(record);

        emit FundDeposited(msg.sender, address(this), _referrer, _amount);
    }

    /**
     * @dev Sets the platform share percentage.
     * @param _platformShare The new platform share percentage to be set.
     * Requirements:
     * - The caller must be the contract owner.
     */
    function setPlatformShare(uint256 _platformShare) public onlyOwner {
        platformShare = _platformShare;
        emit PlatformShareUpdated(msg.sender, _platformShare);
    }

    /**
     * @dev Withdraws the remaining balance in the contract to the owner's address.
     * Requirements:
     * - The caller must be the multiSignatureAddress contract.
     * - Transfers the balance of the deposit token to the owner's address.
     * - Emits the `OwnerWithdraw` event with the owner's address and the amount withdrawn.
     */
    function withdrawOwner(
        uint256 _amount
    ) external isWithDrawlApproved onlyOwner {
        uint256 balance = IERC20(token).balanceOf(address(this));
        require(balance >= _amount, "InSufficient Balance");
        IERC20(token).transfer(msg.sender, _amount);
        emit OwnerWithdraw(msg.sender, balance);
    }

    /**
     * @dev Activates a robot for the caller.
     * @param _robotAmount The amount of robot to activate.
     * Requirements:
     * - The caller must have a sufficient deposit amount to purchase the robot.
     * - The robot amount must be one of the predefined values: 20, 80, 220, or greater than 220.
     * - The maximum limit for each robot amount should not be exceeded.
     * - For 20 robot amount, the maximum limit is 10.
     * - For 80 robot amount, the maximum limit is 5.
     * - For 220 robot amount, the maximum limit is 2.
     * - For robot amounts greater than 220, the maximum limit is 1.
     * - Updates the user's deposit amount by subtracting the robot amount.
     * - Sets the last claim time to the current block timestamp.
     * - If the caller has a valid referrer up to the 1st level, adds the robot amount to their total robots value.
     * - If the caller has a valid referrer up to the 2nd level, adds the robot amount to their total robots value.
     * - If the caller has a valid referrer up to the 3rd level, adds the robot amount to their total robots value.
     * - Emits the `RobotActivated` event with the caller's address and the robot amount.
     */
    function activateRobot(uint256 _robotAmount) public {
        require(
            deposit[msg.sender].depositAmount >= _robotAmount,
            "Your Deposit Amount is insufficient to buy this Robot"
        );

        address refer = referrals[msg.sender].referredBy;
        team[refer].totalInvestment += _robotAmount;

        robots[msg.sender][_robotAmount].activeRobots++;

        if (_robotAmount == 20 * 1e18) {
            require(
                robots[msg.sender][_robotAmount].activeRobots <= 10,
                "Maximum Robot Limit Reached"
            );
        } else if (_robotAmount == 80 * 1e18) {
            require(
                robots[msg.sender][_robotAmount].activeRobots <= 5,
                "Maximum Robot Limit Reached"
            );
        } else if (_robotAmount == 220 * 1e18) {
            require(
                robots[msg.sender][_robotAmount].activeRobots <= 2,
                "Maximum Robot Limit Reached"
            );
        } else if (_robotAmount > 220 * 1e18) {
            require(
                robots[msg.sender][_robotAmount].activeRobots <= 1,
                "Maximum Robot Limit Reached"
            );
        }

        deposit[msg.sender].depositAmount -= _robotAmount;
        if (referrals[msg.sender].referredBy != address(0)) {
            address referrer = referrals[msg.sender].referredBy;
            userRobotsValue[msg.sender] += _robotAmount;
            teamRobotValue[referrer] += _robotAmount;
        } else if (referrals[msg.sender].referredBy == address(0)) {
            userRobotsValue[msg.sender] += _robotAmount;
        }
        uint256 currentIndex = userActivatedRobots[msg.sender];
        userActivatedRobots[msg.sender]++;

        activatedRobots[msg.sender][currentIndex] = Robot(
            currentIndex,
            _robotAmount,
            block.timestamp,
            block.timestamp + 365 days,
            0,
            false,
            true,
            false
        );

        TransactionRecord memory robotActivated = TransactionRecord({
            timestamp: block.timestamp,
            action: "Activated Robot",
            amount: _robotAmount,
            from: msg.sender
        });
        transactionHistory[msg.sender].push(robotActivated);
        individualInvestment[msg.sender] += _robotAmount;

        emit RobotActivated(msg.sender, _robotAmount);
    }

    /**
     * @dev Withdraws the specified amount from the user's deposit balance.
     * @param _amount The amount to withdraw from the user's deposit balance.
     * Requirements:
     * - The deposit functionality must be active.
     * - The user must have a sufficient balance to withdraw the specified amount.
     * - The user must not be blacklisted.
     * - Transfers the specified amount to the user's address.
     * Emits the `UserWithdraw` event with the user's address and the amount withdrawn.
     */
    function withdrawUser(uint256 _amount) public {
        require(isWithdrawActive, "Withdraw is not Active");
        require(
            deposit[msg.sender].depositAmount >= _amount,
            "InSufficient User Balance"
        );
        require(!blackListed[msg.sender], "Cant Withdraw You are blacklisted");
        if (
            referrals[msg.sender].referredBy != address(0) &&
            !firstDepositReferral[msg.sender]
        ) {
            IERC20(token).transfer(msg.sender, _amount);
            firstDepositReferral[msg.sender] = true;
        }
        uint256 ownerShare = _amount.mul(platformShare).div(100);

        uint256 userShare = _amount.sub(ownerShare);
        IERC20(token).transfer(msg.sender, userShare);
        IERC20(token).transfer(taxReceiver, ownerShare);
        deposit[msg.sender].depositAmount -= _amount;

        TransactionRecord memory record = TransactionRecord({
            timestamp: block.timestamp,
            action: "User Withdrawl",
            amount: _amount,
            from: msg.sender
        });

        transactionHistory[msg.sender].push(record);
        emit UserWithdraw(msg.sender, _amount);
    }

    /**
     * @dev Claims the profit for a given robot amount.
     * @param robotId The RobotId Address.
     * Requirements:
     * - The robot must be active for the user.
     * - The last claim time must be at least 24 hours ago.
     * - The user must have valid referrals up to the 3rd level.
     * - The profit percentage must be set.
     * - The user must have enough balance to receive the profit.
     * - Emits the `levels` event with the referral addresses and their respective levels.
     * - Transfers the profit to the caller's address.
     */

    function claimProfit(uint256 robotId) public {
        require(
            activatedRobots[msg.sender][robotId].activated,
            "No Robot is Active"
        );
        require(
            !activatedRobots[msg.sender][robotId].profitClaimed,
            "You can only Claim Profit once in 24 hours"
        );
        require(
            activatedRobots[msg.sender][robotId].quantifiedActive,
            "Quantify is not Active Yet"
        );
        uint256 _robotAmount = activatedRobots[msg.sender][robotId].value;
        require(
            activatedRobots[msg.sender][robotId].quantifiedOn + 7 hours <
                block.timestamp,
            "You can only Claim Profit after 7 hours of Qunatifying"
        );
        require(
            activatedRobots[msg.sender][robotId].expiredOn > block.timestamp,
            "Robot is Expired"
        );
        address user1 = referrals[msg.sender].referredBy; //user c referred user d
        address user2 = referrals[user1].referredBy; //user b referred user c
        address user3 = referrals[user2].referredBy; //user a referred user b
        uint256 todayProfit = _robotAmount.mul(profitPercentage).div(100);

        if (user1 != address(0) && user2 != address(0) && user3 != address(0)) {
            (, , uint256 level3) = getUserAffiliatePercentage(user3);
            (, uint256 level2, ) = getUserAffiliatePercentage(user2);
            (uint256 level1, , ) = getUserAffiliatePercentage(user1);

            uint256 user1Commision = todayProfit.mul(level1).div(100);
            uint256 user2Commision = todayProfit.mul(level2).div(100);
            uint256 user3Commision = todayProfit.mul(level3).div(100);

            deposit[user1].depositAmount += user1Commision;
            deposit[user2].depositAmount += user2Commision;
            deposit[user3].depositAmount += user3Commision;

            totalProfit[user1] += user1Commision;
            totalProfit[user2] += user2Commision;
            totalProfit[user3] += user2Commision;

            TransactionRecord memory user1record = TransactionRecord({
                timestamp: block.timestamp,
                action: "Referral Reward",
                amount: user1Commision,
                from: msg.sender
            });
            TransactionRecord memory user2record = TransactionRecord({
                timestamp: block.timestamp,
                action: "Referral Reward",
                amount: user2Commision,
                from: msg.sender
            });
            TransactionRecord memory user3record = TransactionRecord({
                timestamp: block.timestamp,
                action: "Referral Reward",
                amount: user3Commision,
                from: msg.sender
            });

            transactionHistory[user1].push(user1record);
            transactionHistory[user2].push(user2record);
            transactionHistory[user3].push(user3record);

            emit RewardTransfered(user1, user2, user3, level1, level2, level3);
        } else if (
            user1 != address(0) && user2 != address(0) && user3 == address(0)
        ) {
            (, uint256 level2, ) = getUserAffiliatePercentage(user2);
            (uint256 level1, , ) = getUserAffiliatePercentage(user1);

            uint256 user1Commision = todayProfit.mul(level1).div(100);
            uint256 user2Commision = todayProfit.mul(level2).div(100);

            deposit[user1].depositAmount += user1Commision;
            deposit[user2].depositAmount += user2Commision;

            totalProfit[user1] += user1Commision;
            totalProfit[user2] += user2Commision;

            TransactionRecord memory user1record = TransactionRecord({
                timestamp: block.timestamp,
                action: "Referral Reward",
                amount: user1Commision,
                from: msg.sender
            });
            TransactionRecord memory user2record = TransactionRecord({
                timestamp: block.timestamp,
                action: "Referral Reward",
                amount: user2Commision,
                from: msg.sender
            });

            transactionHistory[user1].push(user1record);
            transactionHistory[user2].push(user2record);
            emit RewardTransfered(user1, user2, user3, level1, level2, 0);
        } else if (
            user1 != address(0) && user2 == address(0) && user3 == address(0)
        ) {
            (uint256 level1, , ) = getUserAffiliatePercentage(user1);

            uint256 user1Commision = todayProfit.mul(level1).div(100);
            deposit[user1].depositAmount += user1Commision;
            totalProfit[user1] += user1Commision;

            TransactionRecord memory user1record = TransactionRecord({
                timestamp: block.timestamp,
                action: "Referral Reward",
                amount: user1Commision,
                from: msg.sender
            });
            transactionHistory[user1].push(user1record);
            emit RewardTransfered(user1, user2, user3, level1, 0, 0);
        }
        TransactionRecord memory profitClaim = TransactionRecord({
            timestamp: block.timestamp,
            action: "Claim Profit",
            amount: todayProfit,
            from: msg.sender
        });
        transactionHistory[msg.sender].push(profitClaim);
        deposit[msg.sender].depositAmount += todayProfit;
        totalProfit[msg.sender] += todayProfit;
        activatedRobots[msg.sender][robotId].quantifiedActive = false;
        activatedRobots[msg.sender][robotId].profitClaimed = true;
        emit ProfitTransfered(msg.sender, block.timestamp, todayProfit);
    }

    /**
     * @dev Pauses or resumes the deposit functionality.
     * @param _deposit Boolean value indicating whether deposit should be active or not.
     * Requirements:
     * - The caller must be the contract owner.
     */
    function pauseDeposit(bool _deposit) public onlyOwner {
        isWithdrawActive = _deposit;
        emit DepositPaused(msg.sender, block.timestamp, _deposit);
    }

    /**
     * @dev Sets the profit percentage for each robot.
     * @param _share The new profit percentage to be set.
     * Requirements:
     * - The caller must be the contract owner.
     * - The profit percentage should be greater than zero.
     */
    function setProfitPercentage(uint256 _share) public onlyOwner {
        require(_share > 0, "Share Should be Greater than Zero");
        profitPercentage = _share;
        emit ProfitPercentageUpdated(msg.sender, _share);
    }

    function setminQuantTime(uint256 _time) public onlyOwner {
        minQuantTime = _time;
    }

    /**
     * @dev Blacklists a user.
     * @param _user The address of the user that will be blacklisted.
     */
    function blackListUser(address _user) public onlyOwner {
        blackListed[_user] = true;
        emit userBlackListed(msg.sender, _user);
    }

    function startQuantify(uint256 robotId) public {
        if (activatedRobots[msg.sender][robotId].quantifiedActive) {
            require(
                activatedRobots[msg.sender][robotId].quantifiedOn + 24 hours <
                    block.timestamp,
                "You can only Start Quantify once within 24 hours"
            );
        }

        activatedRobots[msg.sender][robotId].quantifiedOn = block.timestamp;
        activatedRobots[msg.sender][robotId].quantifiedActive = true;
        activatedRobots[msg.sender][robotId].profitClaimed = false;
    }

    /**
     * @dev Returns the rank of a user based on their total robots value.
     * @param _user The address of the user.
     * @return The rank of the user as a string.
     */
    function getRank(address _user) public view returns (string memory) {
        uint256 totaluservalue = userRobotsValue[_user];
        uint256 totalteamvalue = teamRobotValue[_user];
        if (
            totaluservalue <= 500 * 1e18 ||
            (totaluservalue >= 500 * 1e18 && totalteamvalue <= 2000 * 1e18)
        ) {
            return "bronze";
        } else if (
            totaluservalue >= 500 * 1e18 &&
            totaluservalue <= 2000 * 1e18 &&
            totalteamvalue >= 2000 * 1e18
        ) {
            return "silver";
        } else if (
            totaluservalue >= 3500 * 1e18 && totalteamvalue >= 18000 * 1e18
        ) {
            return "gold";
        } else if (totaluservalue >= 9000 * 1e18 && totalteamvalue >= 100000) {
            return "diamond";
        }
    }

    /**
     * @dev Returns the percentage of affiliate commission for each level based on the user's rank.
     * @param _user The address of the user.
     * @return level1Percentage The percentage of affiliate commission for level 1.
     * @return level2Percentage The percentage of affiliate commission for level 2.
     * @return level3Percentage The percentage of affiliate commission for level 3.
     */

    function getUserAffiliatePercentage(
        address _user
    ) public view returns (uint256, uint256, uint256) {
        uint256 level1Percentage;
        uint256 level2Percentage;
        uint256 level3Percentage;

        string memory rank = getRank(_user);
        if (
            keccak256(abi.encodePacked(rank)) ==
            keccak256(abi.encodePacked("bronze"))
        ) {
            level1Percentage = 14;
            level2Percentage = 8;
            level3Percentage = 3;
        } else if (
            keccak256(abi.encodePacked(rank)) ==
            keccak256(abi.encodePacked("silver"))
        ) {
            level1Percentage = 17;
            level2Percentage = 10;
            level3Percentage = 4;
        } else if (
            keccak256(abi.encodePacked(rank)) ==
            keccak256(abi.encodePacked("gold"))
        ) {
            level1Percentage = 20;
            level2Percentage = 12;
            level3Percentage = 5;
        } else if (
            keccak256(abi.encodePacked(rank)) ==
            keccak256(abi.encodePacked("diamond"))
        ) {
            level1Percentage = 24;
            level2Percentage = 16;
            level3Percentage = 6;
        }
        return (level1Percentage, level2Percentage, level3Percentage);
    }

    function userBalance(address _user) public view returns (uint256) {
        uint256 balance = deposit[_user].depositAmount;
        return balance;
    }

    function updateTaxAddress(address _newAddress) public onlyOwner {
        taxReceiver = _newAddress;
    }

    function totalInvestment() public view returns (uint256) {
        return totalValueLocked;
    }

    function getActivatedRobotsForUser(
        address user
    ) external view returns (Robot[] memory) {
        uint256 count = userActivatedRobots[user];

        Robot[] memory userRobots = new Robot[](count);

        uint256 currentIndex = 0; // Start from 0

        for (uint256 i = 0; i < count; i++) {
            if (activatedRobots[user][i].activated) {
                userRobots[currentIndex] = activatedRobots[user][i];
                currentIndex++;
            }
        }

        return userRobots;
    }

    function getExpiredRobot(
        address user
    ) external view returns (Robot[] memory) {
        uint256 count = userActivatedRobots[user];

        Robot[] memory userRobots = new Robot[](count);

        uint256 currentIndex = 0;

        for (uint256 i = 0; i < count; i++) {
            if (activatedRobots[user][i].expiredOn < block.timestamp) {
                userRobots[currentIndex] = activatedRobots[user][i];
                currentIndex++;
            }
        }

        return userRobots;
    }

    function getIndividualRobotAmount(
        address _user
    ) public view returns (uint256) {
        uint256 investment = individualInvestment[_user];
        return investment;
    }

    function timeTillQuantified(
        address user,
        uint256 robotId
    ) public view returns (uint256, uint256, uint256) {
        uint256 timeElapsed = block.timestamp -
            activatedRobots[user][robotId].quantifiedOn;
        uint256 quantifyEndsOn = activatedRobots[user][robotId].quantifiedOn +
            7 hours;
        uint256 totalTime = activatedRobots[user][robotId].quantifiedOn +
            24 hours;
        return (timeElapsed, quantifyEndsOn, totalTime);
    }

    function getUserTransactionHistory(
        address _user
    ) public view returns (TransactionRecord[] memory) {
        return transactionHistory[_user];
    }

    function totalTeamMember(
        address _userAddress
    ) public view returns (uint256) {
        uint256 totalTeam = team[_userAddress].totalTeam.length;
        return totalTeam;
    }

    function totalTeamInvestment(
        address _userAddress
    ) public view returns (uint256) {
        uint256 total = team[_userAddress].totalInvestment;
        return total;
    }

    function removeFromBlacklist(address _user) public onlyOwner {
        blackListed[_user] = false;
    }

    function setTotalValueLocked(uint256 _totalValueLocked) public onlyOwner {
        totalValueLocked = _totalValueLocked;
    }

    function gettotalProfit(address _user) public view returns (uint256) {
        uint256 profit = totalProfit[_user];
        return profit;
    }

    function ownerDeposit(uint256 _amount) external onlyOwner {
        token.transferFrom(msg.sender, address(this), _amount);
    }

    function addToUserDepsoit(
        address _user,
        uint256 amount,
        address _referrer
    ) external onlyOwner {
        deposit[_user].depositAmount += amount;
        deposit[msg.sender].timestamp = block.timestamp;
        deposit[msg.sender].referrer = _referrer;
        referrals[_user] = Referral(_referrer);
        TransactionRecord memory record = TransactionRecord({
            timestamp: block.timestamp,
            action: "Deposit Funds",
            amount: amount,
            from: _user
        });

        transactionHistory[_user].push(record);
    }
}
