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
// OpenZeppelin Contracts v4.4.1 (utils/Counters.sol)

pragma solidity ^0.8.0;

/**
 * @title Counters
 * @author Matt Condon (@shrugs)
 * @dev Provides counters that can only be incremented, decremented or reset. This can be used e.g. to track the number
 * of elements in a mapping, issuing ERC721 ids, or counting request ids.
 *
 * Include with `using Counters for Counters.Counter;`
 */
library Counters {
    struct Counter {
        // This variable should never be directly accessed by users of the library: interactions must be restricted to
        // the library's function. As of Solidity v0.5.2, this cannot be enforced, though there is a proposal to add
        // this feature: see https://github.com/ethereum/solidity/issues/4637
        uint256 _value; // default: 0
    }

    function current(Counter storage counter) internal view returns (uint256) {
        return counter._value;
    }

    function increment(Counter storage counter) internal {
        unchecked {
            counter._value += 1;
        }
    }

    function decrement(Counter storage counter) internal {
        uint256 value = counter._value;
        require(value > 0, "Counter: decrement overflow");
        unchecked {
            counter._value = value - 1;
        }
    }

    function reset(Counter storage counter) internal {
        counter._value = 0;
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

/** ****************************************************************************
 * @notice Interface for contracts using VRF randomness
 * *****************************************************************************
 * @dev PURPOSE
 *
 * @dev Reggie the Random Oracle (not his real job) wants to provide randomness
 * @dev to Vera the verifier in such a way that Vera can be sure he's not
 * @dev making his output up to suit himself. Reggie provides Vera a public key
 * @dev to which he knows the secret key. Each time Vera provides a seed to
 * @dev Reggie, he gives back a value which is computed completely
 * @dev deterministically from the seed and the secret key.
 *
 * @dev Reggie provides a proof by which Vera can verify that the output was
 * @dev correctly computed once Reggie tells it to her, but without that proof,
 * @dev the output is indistinguishable to her from a uniform random sample
 * @dev from the output space.
 *
 * @dev The purpose of this contract is to make it easy for unrelated contracts
 * @dev to talk to Vera the verifier about the work Reggie is doing, to provide
 * @dev simple access to a verifiable source of randomness. It ensures 2 things:
 * @dev 1. The fulfillment came from the VRFCoordinator
 * @dev 2. The consumer contract implements fulfillRandomWords.
 * *****************************************************************************
 * @dev USAGE
 *
 * @dev Calling contracts must inherit from VRFConsumerBase, and can
 * @dev initialize VRFConsumerBase's attributes in their constructor as
 * @dev shown:
 *
 * @dev   contract VRFConsumer {
 * @dev     constructor(<other arguments>, address _vrfCoordinator, address _link)
 * @dev       VRFConsumerBase(_vrfCoordinator) public {
 * @dev         <initialization with other arguments goes here>
 * @dev       }
 * @dev   }
 *
 * @dev The oracle will have given you an ID for the VRF keypair they have
 * @dev committed to (let's call it keyHash). Create subscription, fund it
 * @dev and your consumer contract as a consumer of it (see VRFCoordinatorInterface
 * @dev subscription management functions).
 * @dev Call requestRandomWords(keyHash, subId, minimumRequestConfirmations,
 * @dev callbackGasLimit, numWords),
 * @dev see (VRFCoordinatorInterface for a description of the arguments).
 *
 * @dev Once the VRFCoordinator has received and validated the oracle's response
 * @dev to your request, it will call your contract's fulfillRandomWords method.
 *
 * @dev The randomness argument to fulfillRandomWords is a set of random words
 * @dev generated from your requestId and the blockHash of the request.
 *
 * @dev If your contract could have concurrent requests open, you can use the
 * @dev requestId returned from requestRandomWords to track which response is associated
 * @dev with which randomness request.
 * @dev See "SECURITY CONSIDERATIONS" for principles to keep in mind,
 * @dev if your contract could have multiple requests in flight simultaneously.
 *
 * @dev Colliding `requestId`s are cryptographically impossible as long as seeds
 * @dev differ.
 *
 * *****************************************************************************
 * @dev SECURITY CONSIDERATIONS
 *
 * @dev A method with the ability to call your fulfillRandomness method directly
 * @dev could spoof a VRF response with any random value, so it's critical that
 * @dev it cannot be directly called by anything other than this base contract
 * @dev (specifically, by the VRFConsumerBase.rawFulfillRandomness method).
 *
 * @dev For your users to trust that your contract's random behavior is free
 * @dev from malicious interference, it's best if you can write it so that all
 * @dev behaviors implied by a VRF response are executed *during* your
 * @dev fulfillRandomness method. If your contract must store the response (or
 * @dev anything derived from it) and use it later, you must ensure that any
 * @dev user-significant behavior which depends on that stored value cannot be
 * @dev manipulated by a subsequent VRF request.
 *
 * @dev Similarly, both miners and the VRF oracle itself have some influence
 * @dev over the order in which VRF responses appear on the blockchain, so if
 * @dev your contract could have multiple VRF requests in flight simultaneously,
 * @dev you must ensure that the order in which the VRF responses arrive cannot
 * @dev be used to manipulate your contract's user-significant behavior.
 *
 * @dev Since the block hash of the block which contains the requestRandomness
 * @dev call is mixed into the input to the VRF *last*, a sufficiently powerful
 * @dev miner could, in principle, fork the blockchain to evict the block
 * @dev containing the request, forcing the request to be included in a
 * @dev different block with a different hash, and therefore a different input
 * @dev to the VRF. However, such an attack would incur a substantial economic
 * @dev cost. This cost scales with the number of blocks the VRF oracle waits
 * @dev until it calls responds to a request. It is for this reason that
 * @dev that you can signal to an oracle you'd like them to wait longer before
 * @dev responding to the request (however this is not enforced in the contract
 * @dev and so remains effective only in the case of unmodified oracle software).
 */
abstract contract VRFConsumerBase {
    address private immutable vrfCoordinator;

    /**
     * @param _vrfCoordinator address of VRFCoordinator contract
     */
    constructor(address _vrfCoordinator) {
        vrfCoordinator = _vrfCoordinator;
    }

    /**
     * @notice fulfillRandomness handles the VRF response. Your contract must
     * @notice implement it. See "SECURITY CONSIDERATIONS" above for important
     * @notice principles to keep in mind when implementing your fulfillRandomness
     * @notice method.
     *
     * @dev VRFConsumerBase expects its subcontracts to have a method with this
     * @dev signature, and will call it once it has verified the proof
     * @dev associated with the randomness. (It is triggered via a call to
     * @dev rawFulfillRandomness, below.)
     *
     * @param requestId The Id initially returned by requestRandomness
     * @param randomWords the VRF output expanded to the requested number of words
     */
    function fulfillRandomWords(
        uint256 requestId,
        uint256[] memory randomWords
    ) internal virtual;

    // rawFulfillRandomness is called by VRFCoordinator when it receives a valid VRF
    // proof. rawFulfillRandomness then calls fulfillRandomness, after validating
    // the origin of the call
    function rawFulfillRandomWords(
        uint256 requestId,
        uint256[] memory randomWords
    ) external {
        if (msg.sender != vrfCoordinator) {
            revert("OnlyCoordinatorCanFulfill");
        }
        fulfillRandomWords(requestId, randomWords);
    }
}
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface VRFCoordinatorInterface {
    /**
     * @notice Get configuration relevant for making requests
     * @return minimumRequestConfirmations global min for request confirmations
     * @return maxGasLimit global max for request gas limit
     * @return s_provingKeyHashes list of registered key hashes
     */
    function getRequestConfig()
        external
        view
        returns (uint16, uint32, bytes32[] memory);

    /**
     * @notice Request a set of random words.
     * @param keyHash - Corresponds to a particular oracle job which uses
     * that key for generating the VRF proof. Different keyHash's have different gas price
     * ceilings, so you can select a specific one to bound your maximum per request cost.
     * @param subId  - The ID of the VRF subscription. Must be funded
     * with the minimum subscription balance required for the selected keyHash.
     * @param minimumRequestConfirmations - How many blocks you'd like the
     * oracle to wait before responding to the request. See SECURITY CONSIDERATIONS
     * for why you may want to request more. The acceptable range is
     * [minimumRequestBlockConfirmations, 200].
     * @param callbackGasLimit - How much gas you'd like to receive in your
     * fulfillRandomWords callback. Note that gasleft() inside fulfillRandomWords
     * may be slightly less than this amount because of gas used calling the function
     * (argument decoding etc.), so you may need to request slightly more than you expect
     * to have inside fulfillRandomWords. The acceptable range is
     * [0, maxGasLimit]
     * @param numWords - The number of uint256 random values you'd like to receive
     * in your fulfillRandomWords callback. Note these numbers are expanded in a
     * secure way by the VRFCoordinator from a single random value supplied by the oracle.
     * @return requestId - A unique identifier of the request. Can be used to match
     * a request to a response in fulfillRandomWords.
     */
    function requestRandomWords(
        bytes32 keyHash,
        uint64 subId,
        uint16 minimumRequestConfirmations,
        uint32 callbackGasLimit,
        uint32 numWords
    ) external returns (uint256 requestId);

    /**
     * @notice Create a VRF subscription.
     * @return subId - A unique subscription id.
     * @dev You can manage the consumer set dynamically with addConsumer/removeConsumer.
     * @dev Note to fund the subscription, use transferAndCall. For example
     */
    function createSubscription() external returns (uint64 subId);

    /**
     * @notice Get a VRF subscription.
     * @param subId - ID of the subscription
     * @return balance - BNB balance of the subscription in juels.
     * @return reqCount - number of requests for this subscription, determines fee tier.
     * @return owner - owner of the subscription.
     * @return consumers - list of consumer address which are able to use this subscription.
     */
    function getSubscription(
        uint64 subId
    )
        external
        view
        returns (
            uint96 balance,
            uint64 reqCount,
            address owner,
            address[] memory consumers
        );

    /**
     * @notice Request subscription owner transfer.
     * @param subId - ID of the subscription
     * @param newOwner - proposed new owner of the subscription
     */
    function requestSubscriptionOwnerTransfer(
        uint64 subId,
        address newOwner
    ) external;

    /**
     * @notice Request subscription owner transfer.
     * @param subId - ID of the subscription
     * @dev will revert if original owner of subId has
     * not requested that msg.sender become the new owner.
     */
    function acceptSubscriptionOwnerTransfer(uint64 subId) external;

    /**
     * @notice Add a consumer to a VRF subscription.
     * @param subId - ID of the subscription
     * @param consumer - New consumer which can use the subscription
     */
    function addConsumer(uint64 subId, address consumer) external;

    /**
     * @notice Remove a consumer from a VRF subscription.
     * @param subId - ID of the subscription
     * @param consumer - Consumer to remove from the subscription
     */
    function removeConsumer(uint64 subId, address consumer) external;

    /**
     * @notice Cancel a subscription
     * @param subId - ID of the subscription
     * @param to - Where to send the remaining BNB to
     */
    function cancelSubscription(uint64 subId, address to) external;

    /*
     * @notice Check to see if there exists a request commitment consumers
     * for all consumers and keyhashes for a given sub.
     * @param subId - ID of the subscription
     * @return true if there exists at least one unfulfilled request for the subscription, false
     * otherwise.
     */
    function pendingRequestExists(uint64 subId) external view returns (bool);
}
// SPDX-License-Identifier: MIT
pragma solidity 0.8.9;

interface IRouter {
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

    function getAmountsOut(
        uint amountIn,
        address[] calldata path
    ) external view returns (uint[] memory amounts);

    function WETH() external pure returns (address);

    function factory() external pure returns (address);
}

interface IFactory {
    function getPair(
        address tokenA,
        address tokenB
    ) external view returns (address pair);
}

interface IWKDRaffleTopCadre {
    function totals()
        external
        view
        returns (
            uint256 kimoyo,
            uint256 doramilaje,
            uint256 taifaNagao,
            uint negus
        );

    function getPendingFor(
        address account,
        uint256 tokenId
    ) external view returns (uint256);

    function onTransferHook(address account, uint256[] calldata ids) external;

    // function setDeprecated(bool deprecatedStatus) external;

    function version() external view returns (string memory);

    function claim(uint256 id) external returns (uint256);
}

interface IWKDNFT {
    function totalSupply(uint256) external view returns (uint256);

    function balanceOf(address, uint256) external view returns (uint256);

    function KIMOYO() external view returns (uint256);

    function DORA_MILAJ_E() external view returns (uint256);

    function TAIFA_NAGA_O() external view returns (uint256);

    function NEGUS() external view returns (uint256);

    function safeTransferFrom(
        address from,
        address to,
        uint256 id,
        uint256 amount,
        bytes memory data
    ) external;
}

interface ITopCadre {
    function onTransferHook(
        address account,
        uint256[] calldata tokenIds
    ) external;
}
// SPDX-License-Identifier: MIT
pragma solidity 0.8.9;

import {Counters} from "@openzeppelin/contracts/utils/Counters.sol";
import {AccessControl} from "@openzeppelin/contracts/access/AccessControl.sol";
import {WKDVRFManager} from "./WKDVRFManager.sol";
import {IRouter, IFactory} from "./interfaces/utils.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";

error Incomplete();
error Cycle_Full();
error Too_Many_Prizes();
error Transfer_Failed();
error Invalid_Address_Detected();
error Unequal_Size_And_Prize();
error Nothing_To_Claim();
error Too_Early();
error Price_Too_Low();
error Same_As_Before();
error Inaccurate_Lot_State(uint256 expected, uint256 actual);
error Used_RequestId();
error Joined_Previously();

contract WLOT is AccessControl {
    using Counters for Counters.Counter;
    Counters.Counter public cycleCounter;
    WKDVRFManager public wkdVRFManager;
    uint256 public constant CYCLE_SIZE = 7;

    event ClaimWinPrize(address account, uint256 amount);
    event StartCycle(uint256 cycleId, uint256 price);
    event JoinedCycle(uint256 cycleId, address account);
    event DevChanged(address from, address to);
    event MarketingChanged(address from, address to);
    event CycleFilled(uint256 cycleId);
    event Processed(uint256 cycleId);
    event Drawn(uint256 cycleId, uint256 requestId);

    event Winners(uint256 cycleId, address[] entries, address[] winners);
    event VRFManagerUpdated(address wkdVrfManager, uint64 subscriptionId);
    event OperationFailedWithString(string reasonString);
    event OperationFailedWithData(bytes reasonData);
    event Burned(uint256 total);

    address private _dev;
    address private _marketing;
    uint256 public burnedWKD;

    IERC20 public immutable WKD;
    address public constant BURN_ADDRESS =
        0x000000000000000000000000000000000000dEaD;

    bytes32 public constant MANAGER = keccak256("MANAGER");
    bytes32 public constant ADMIN = keccak256("ADMIN");

    uint256 public constant MARKETING_PCT = 15;
    uint256 public constant BURN_AND_DEV_PCT = 5;

    uint256 private _devFund;
    uint256 private _burn;
    uint256 private _marketingFund;
    uint256 public lastRequestId;
    uint256 public lastRequestMadeAt;
    uint64 public subscriptionId;

    mapping(address => uint256) private _winnersRake;
    mapping(uint256 => Cycle) private _cycles;
    mapping(uint256 => mapping(address => bool)) public hasJoined;
    mapping(uint256 => bool) public usedReqIds;
    mapping(address => uint256) public cummulativeSpent;

    enum Status {
        CLOSED,
        OPEN,
        AWAITING_DRAWS,
        DRAWING_WINNERS
    }

    struct CycleAttributes {
        uint256[3] prizesPct;
        uint256[3] prizes;
        address[] entries;
        address[] winners;
    }

    struct Cycle {
        uint256 price;
        uint256 openedAt;
        CycleAttributes cycleAttributes;
    }

    Status private _status;

    constructor(
        address payable wkdVrfManager,
        address devAccount,
        address marketingAccount,
        address managerAccount,
        IERC20 wkdAddress,
        uint64 subId
    ) {
        _grantRole(DEFAULT_ADMIN_ROLE, devAccount);
        _grantRole(ADMIN, devAccount);
        _grantRole(MANAGER, managerAccount);
        _setRoleAdmin(ADMIN, DEFAULT_ADMIN_ROLE);
        _setRoleAdmin(MANAGER, DEFAULT_ADMIN_ROLE);
        wkdVRFManager = WKDVRFManager(wkdVrfManager);
        _dev = devAccount;
        _marketing = marketingAccount;
        WKD = wkdAddress;
        subscriptionId = subId;
    }

    /// @notice show the current state of the contract circuit
    function status() external view returns (uint256) {
        return uint256(_status);
    }

    /// @notice to create a new
    /// @dev contract must be in a CLOSED state
    function startCycle(
        uint256 price,
        uint256[3] memory prizesPct
    ) external onlyRole(MANAGER) {
        if (price == 0) revert Price_Too_Low();
        cycleCounter.increment();
        uint256 cycleId = cycleCounter.current();
        _cycles[cycleId].price = price;
        _cycles[cycleId].openedAt = block.timestamp;
        _cycles[cycleId].cycleAttributes.prizesPct = prizesPct;
        _status = Status.OPEN;
        emit StartCycle(cycleId, price);
    }

    /// @notice gets the information about a cycle given its id
    function showCycle(uint256 cycleId) external view returns (Cycle memory) {
        return _cycles[cycleId];
    }

    /// @notice lets an account join the current cycle
    /// @dev the account must have approved spend of WKD by this contract of an amount
    /// equal or greater than the cost of the current cycle
    function join() external {
        address account = _msgSender();
        if (_status != Status.OPEN)
            revert Inaccurate_Lot_State({
                expected: uint256(Status.OPEN),
                actual: uint256(_status)
            });
        uint256 cycleId = cycleCounter.current();
        Cycle memory cycle = _cycles[cycleId];
        if (hasJoined[cycleId][account]) revert Joined_Previously();
        if (cycle.cycleAttributes.entries.length == CYCLE_SIZE)
            revert Cycle_Full();
        bool sent = WKD.transferFrom(account, address(this), cycle.price);
        if (!sent) revert Transfer_Failed();
        _cycles[cycleId].cycleAttributes.entries.push(account);
        cummulativeSpent[account] += cycle.price;
        hasJoined[cycleId][account] = true;
        emit JoinedCycle(cycleId, account);
        if (_cycles[cycleId].cycleAttributes.entries.length == CYCLE_SIZE) {
            _status = Status.AWAITING_DRAWS;
            emit CycleFilled(cycleId);
        }
    }

    /// @notice used by the {MANAGER} to end a cycle in preparation for starting the draws
    /// @dev the function emite {RequiredRandomRequest} that should be used to know how many
    /// requests to the VRFManager will be required to draw all winners
    function processCycle() external onlyRole(MANAGER) {
        uint256 cycleId = cycleCounter.current();
        _preDrawCheck(_cycles[cycleId]);
        (
            uint256[3] memory prizes,
            uint256 dev,
            uint256 marketing,
            uint256 burn
        ) = winningPrizes(cycleId);
        _cycles[cycleId].cycleAttributes.prizes = prizes;
        _marketingFund += marketing;
        _devFund += dev;
        _burn += burn;
        _status = Status.DRAWING_WINNERS;
        emit Processed(cycleId);
    }

    /// @dev util function to check some parameters are available beofore proceeding to draw winners
    function _preDrawCheck(Cycle memory cycle) internal view {
        if (_status != Status.AWAITING_DRAWS)
            revert Inaccurate_Lot_State({
                expected: uint256(Status.AWAITING_DRAWS),
                actual: uint256(_status)
            });
        if (cycle.cycleAttributes.entries.length != CYCLE_SIZE)
            revert Incomplete();
    }

    function requestRandomWords() external onlyRole(MANAGER) {
        if (_status != Status.DRAWING_WINNERS)
            revert Inaccurate_Lot_State({
                expected: uint256(Status.DRAWING_WINNERS),
                actual: uint256(_status)
            });
        if (block.timestamp < (lastRequestMadeAt + 2 minutes))
            revert Too_Early();
        try
            wkdVRFManager.requestRandomWords(
                subscriptionId,
                200000 /* callback gas */,
                1 /* number of words */,
                3 /* number of confirmations */
            )
        returns (uint256 requestId) {
            lastRequestId = requestId;
            lastRequestMadeAt = block.timestamp;
        } catch Error(string memory revertReason) {
            emit OperationFailedWithString(revertReason);
        } catch (bytes memory returnData) {
            emit OperationFailedWithData(returnData);
        }
    }

    // Function to shuffle an array with a random number
    function _shuffleArray(
        address[] memory _array,
        uint256 _randomNumber
    ) internal pure returns (address[] memory) {
        for (uint256 i = 0; i < CYCLE_SIZE; i++) {
            uint256 n = i + (_randomNumber % (CYCLE_SIZE - i));
            if (i != n) {
                address temp = _array[n];
                _array[n] = _array[i];
                _array[i] = temp;
            }
        }
        return _array;
    }

    /// @notice computes the winning prize of a given cycle
    /// @param cycleId id of the cycle of interest
    function winningPrizes(
        uint256 cycleId
    )
        public
        view
        returns (
            uint256[3] memory prizes,
            uint256 dev,
            uint256 marketing,
            uint256 burn
        )
    {
        Cycle memory cycle = _cycles[cycleId];
        uint256 totalPay = CYCLE_SIZE * cycle.price;
        marketing = (MARKETING_PCT * totalPay) / 100;
        prizes[0] = (totalPay * cycle.cycleAttributes.prizesPct[0]) / 100;
        prizes[1] = (totalPay * cycle.cycleAttributes.prizesPct[1]) / 100;
        prizes[2] = (totalPay * cycle.cycleAttributes.prizesPct[2]) / 100;
        uint256 burnAndDevPct = (BURN_AND_DEV_PCT * totalPay) / 100;
        dev = burnAndDevPct;
        burn = burnAndDevPct;
    }

    /// @notice used by the {MANAGER} to draw winners from the on-going cycle
    function drawWinners() external onlyRole(MANAGER) {
        if (_status != Status.DRAWING_WINNERS)
            revert Inaccurate_Lot_State({
                expected: uint256(Status.DRAWING_WINNERS),
                actual: uint256(_status)
            });
        uint256 cycleId = cycleCounter.current();

        if (usedReqIds[lastRequestId]) revert Used_RequestId();
        (bool fulfilled, uint256[] memory randomWords) = wkdVRFManager
            .getRequestStatus(lastRequestId);
        if (fulfilled) {
            _creditWinners(cycleId, randomWords[0]);
            emit Drawn(cycleId, lastRequestId);
            usedReqIds[lastRequestId] = true;
            _status = Status.CLOSED;
        }
    }

    function pendingPrize(address account) external view returns (uint256) {
        return _winnersRake[account];
    }

    /// @dev uses random words generated from the vrf manager to credit players
    /// it will never choose a winning number more than once
    /// winner is selected based on the index from the entries array
    /// Can emit {RequiredRandomRequest} in case all winners aren't selected
    /// due to duplicated numbers from VRF call
    function _creditWinners(uint256 cycleId, uint256 randoWord) internal {
        Cycle memory cycle = _cycles[cycleId];
        address[] memory winners = _shuffleArray(
            cycle.cycleAttributes.entries,
            randoWord
        );
        _winnersRake[winners[0]] += cycle.cycleAttributes.prizes[0];
        _winnersRake[winners[1]] += cycle.cycleAttributes.prizes[1];
        _winnersRake[winners[2]] += cycle.cycleAttributes.prizes[2];
        _cycles[cycleId].cycleAttributes.winners = winners;
        emit Winners(
            cycleId,
            _cycles[cycleId].cycleAttributes.entries,
            winners
        );
    }

    function _performSwap(
        address[] memory paths,
        uint256[] memory outs,
        address to,
        IRouter router
    ) internal {
        try
            router.swapExactTokensForETHSupportingFeeOnTransferTokens(
                outs[0],
                outs[1],
                paths,
                to,
                block.timestamp + 5 minutes
            )
        {} catch Error(string memory revertReason) {
            emit OperationFailedWithString(revertReason);
        } catch (bytes memory returnData) {
            emit OperationFailedWithData(returnData);
        }
    }

    /// @notice for {MANAGER} to  perform buy post draw operations
    function deepProcessPlatformCut(IRouter router) external onlyRole(MANAGER) {
        if (_devFund == 0) revert Nothing_To_Claim();
        uint256 toDev = _devFund;
        uint256 toMarketing = _marketingFund;
        uint256 toBurn = _burn;
        _devFund = 0;
        _marketingFund = 0;
        _burn = 0;
        bool sent;
        burnedWKD += toBurn;
        sent = WKD.transfer(BURN_ADDRESS, toBurn);
        if (!sent) revert Transfer_Failed();
        emit Burned(burnedWKD);
        address[] memory path = new address[](2);
        path[0] = address(WKD);
        path[1] = router.WETH();
        uint256[] memory devOuts = router.getAmountsOut(toDev, path);
        uint256[] memory marketingOuts = router.getAmountsOut(
            toMarketing,
            path
        );
        if(WKD.allowance(address(this), address(router)) == 0) {
            WKD.approve(address(router), type(uint).max);
        }
        _performSwap(path, devOuts, _dev, router);
        _performSwap(path, marketingOuts, _marketing, router);
    }

    function easyProcessPlatformCut() external onlyRole(MANAGER) {
        if (_devFund == 0) revert Nothing_To_Claim();
        uint256 toDev = _devFund;
        uint256 toMarketing = _marketingFund;
        uint256 toBurn = _burn;
        _devFund = 0;
        _marketingFund = 0;
        _burn = 0;
        bool sent;
        burnedWKD += toBurn;
        sent = WKD.transfer(BURN_ADDRESS, toBurn);
        if (!sent) revert Transfer_Failed();
        sent = WKD.transfer(_dev, toDev);
        if (!sent) revert Transfer_Failed();
        sent = WKD.transfer(_marketing, toMarketing);
        if (!sent) revert Transfer_Failed();
        emit Burned(burnedWKD);
    }

    /// @notice to claim the price.
    /// @dev cycleId must be provided because the price for each token is differnt in all cycles.
    /// a winning token is burnt during claim
    function claimPrize(address account) external {
        uint256 amount = _winnersRake[account];
        if (amount == 0) revert Transfer_Failed();
        _winnersRake[account] = 0;
        bool sent = WKD.transfer(account, amount);
        if (!sent) revert Transfer_Failed();
        emit ClaimWinPrize(account, amount);
    }

    /// @notice used to set the Platform address as specified by the {ADMIN}
    function updateDev(address dev) external onlyRole(ADMIN) {
        if (dev == address(0)) revert Invalid_Address_Detected();
        emit DevChanged(_dev, dev);
        _dev = dev;
    }

    /// @notice used to set the Platform address as specified by the {ADMIN}
    function updateMarketing(address marketing) external onlyRole(ADMIN) {
        if (marketing == address(0)) revert Invalid_Address_Detected();
        emit MarketingChanged(_marketing, marketing);
        _marketing = marketing;
    }

    /// @notice used to set the vrf manager as specified by the {ADMIN}
    function updateVRFManager(
        address payable vrfManager,
        uint64 subId
    ) public onlyRole(ADMIN) {
        if (address(wkdVRFManager) == vrfManager && subscriptionId == subId)
            revert Same_As_Before();
        if (vrfManager == address(0)) revert Invalid_Address_Detected();
        emit VRFManagerUpdated(vrfManager, subId);
        wkdVRFManager = WKDVRFManager(vrfManager);
        subscriptionId = subId;
    }

    /// @notice shows the version number of this contract
    function version() external pure returns (string memory) {
        return "v1";
    }
}
// SPDX-License-Identifier: MIT
pragma solidity 0.8.9;

import {VRFConsumerBase} from "./interfaces/IVRFConsumerBase.sol";
import {VRFCoordinatorInterface} from "./interfaces/IVRFCoordinator.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

error Same_As_Before();
error Not_Authorized();
error Funding_Failed();
error Invalid_Request();

contract WKDVRFManager is VRFConsumerBase, Ownable {
    VRFCoordinatorInterface private immutable COORDINATOR;
    mapping(address => bool) public authorized;
    struct RequestStatus {
        bool fulfilled; // whether the request has been successfully fulfilled
        bool exists; // whether a requestId exists
        uint256[] randomWords;
    }
    uint256[] public requestIds;
    uint256 private _lastRequestId;
    uint64 private _subscriptionId;

    mapping(uint256 => RequestStatus) private requests;

    event AuthorizationUpdated(address previousController, bool status);
    event RequestSent(uint256 requestId, uint64 subId, uint32 numWords);
    event RequestFulfilled(uint256 requestId, uint256[] randomWords);
    event SubscriptionIdChanged(uint64 previous, uint64 current);

    bytes32 public immutable keyHash;

    constructor(
        address coordinator,
        bytes32 _keyHash,
        uint64 _subId
    ) VRFConsumerBase(coordinator) {
        COORDINATOR = VRFCoordinatorInterface(coordinator);
        _subscriptionId = _subId;
        keyHash = _keyHash;
    }

    receive() external payable {
        _fund(msg.value);
    }

    function updateAuthAccount(
        address account,
        bool status
    ) external onlyOwner {
        if (authorized[account] == status) revert Same_As_Before();
        authorized[account] = status;
        emit AuthorizationUpdated(account, status);
    }

    function requestRandomWords(
        uint64 subId,
        uint32 callbackGasLimit,
        uint32 numWords,
        uint16 confirmations
    ) external returns (uint256 requestId) {
        if (!authorized[_msgSender()]) revert Not_Authorized();
        requestId = COORDINATOR.requestRandomWords(
            keyHash,
            subId,
            confirmations,
            callbackGasLimit,
            numWords
        );
        requests[requestId] = RequestStatus({
            randomWords: new uint256[](0),
            exists: true,
            fulfilled: false
        });
        requestIds.push(requestId);
        _lastRequestId = requestId;
        emit RequestSent(requestId, subId, numWords);
    }

    function fulfillRandomWords(
        uint256 requestId,
        uint256[] memory randomWords
    ) internal override {
        if (!requests[requestId].exists) revert Invalid_Request();
        requests[requestId].fulfilled = true;
        requests[requestId].randomWords = randomWords;
        emit RequestFulfilled(requestId, randomWords);
    }

    function getRequestStatus(
        uint256 _requestId
    ) external view returns (bool fulfilled, uint256[] memory randomWords) {
        if (!requests[_requestId].exists) revert Invalid_Request();
        RequestStatus memory request = requests[_requestId];
        return (request.fulfilled, request.randomWords);
    }

    function _fund(uint256 amount) internal {
        (bool ok, ) = address(COORDINATOR).call{value: amount}(
            abi.encodeWithSignature("deposit(uint64)", _subscriptionId)
        );
        if (!ok) revert Funding_Failed();
    }

    function updateSubId(uint64 newSubId) external onlyOwner {
        if (_subscriptionId == newSubId) revert Same_As_Before();
        emit SubscriptionIdChanged(_subscriptionId, newSubId);
        _subscriptionId = newSubId;
    }

    function subscriptionId() external view returns (uint64) {
        return _subscriptionId;
    }

    function lastRequestId() external view returns (uint256) {
        return _lastRequestId;
    }
}

// 0x0b43eFa3478b02ADA6783d523b0A89F5a2F81fCb - working condition
// 0xd11a9d04642bE7b1BA6E25A5311b1fE312Cf04c1 - improved conditon
