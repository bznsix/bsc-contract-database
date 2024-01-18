// SPDX-License-Identifier: MIT
pragma solidity =0.8.16;

interface IERC20 {
	event Approval(address indexed owner, address indexed spender, uint value);
	event Transfer(address indexed from, address indexed to, uint value);

	function name() external view returns (string memory);

	function symbol() external view returns (string memory);

	function decimals() external view returns (uint8);

	function totalSupply() external view returns (uint);

	function balanceOf(address owner) external view returns (uint);

	function allowance(address owner, address spender) external view returns (uint);

	function approve(address spender, uint value) external returns (bool);

	function transfer(address to, uint value) external returns (bool);

	function transferFrom(address from, address to, uint value) external returns (bool);
}

interface IUniswapV2Pair {
	event Approval(address indexed owner, address indexed spender, uint value);
	event Transfer(address indexed from, address indexed to, uint value);

	function name() external pure returns (string memory);

	function symbol() external pure returns (string memory);

	function decimals() external pure returns (uint8);

	function totalSupply() external view returns (uint);

	function balanceOf(address owner) external view returns (uint);

	function allowance(address owner, address spender) external view returns (uint);

	function approve(address spender, uint value) external returns (bool);

	function transfer(address to, uint value) external returns (bool);

	function transferFrom(address from, address to, uint value) external returns (bool);

	function DOMAIN_SEPARATOR() external view returns (bytes32);

	function PERMIT_TYPEHASH() external pure returns (bytes32);

	function nonces(address owner) external view returns (uint);

	function permit(address owner, address spender, uint value, uint deadline, uint8 v, bytes32 r, bytes32 s) external;

	event Mint(address indexed sender, uint amount0, uint amount1);
	event Burn(address indexed sender, uint amount0, uint amount1, address indexed to);
	event Swap(
		address indexed sender,
		uint amount0In,
		uint amount1In,
		uint amount0Out,
		uint amount1Out,
		address indexed to
	);
	event Sync(uint112 reserve0, uint112 reserve1);

	function MINIMUM_LIQUIDITY() external pure returns (uint);

	function factory() external view returns (address);

	function token0() external view returns (address);

	function token1() external view returns (address);

	function getReserves() external view returns (uint112 reserve0, uint112 reserve1, uint32 blockTimestampLast);

	function price0CumulativeLast() external view returns (uint);

	function price1CumulativeLast() external view returns (uint);

	function kLast() external view returns (uint);

	function mint(address to) external returns (uint liquidity);

	function burn(address to) external returns (uint amount0, uint amount1);

	function swap(uint amount0Out, uint amount1Out, address to, bytes calldata data) external;

	function skim(address to) external;

	function sync() external;

	function initialize(address, address) external;
}

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

// OpenZeppelin Contracts v4.4.1 (utils/Context.sol)

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

library Math {
	enum Rounding {
		Down, // Toward negative infinity
		Up, // Toward infinity
		Zero // Toward zero
	}

	/**
	 * @dev Returns the largest of two numbers.
	 */
	// function max(uint256 a, uint256 b) internal pure returns (uint256) {
	//     return a > b ? a : b;
	// }

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
	// function average(uint256 a, uint256 b) internal pure returns (uint256) {
	//     // (a + b) / 2 can overflow.
	//     return (a & b) + (a ^ b) / 2;
	// }

	/**
	 * @dev Returns the ceiling of the division of two numbers.
	 *
	 * This differs from standard division with `/` in that it rounds up instead
	 * of rounding down.
	 */
	// function ceilDiv(uint256 a, uint256 b) internal pure returns (uint256) {
	//     // (a + b - 1) / b can overflow on addition, so we distribute.
	//     return a == 0 ? 0 : (a - 1) / b + 1;
	// }

	/**
	 * @dev Returns the square root of a number. If the number is not a perfect square, the value is rounded down.
	 *
	 * Inspired by Henry S. Warren, Jr.'s "Hacker's Delight" (Chapter 11).
	 */
	// function sqrt(uint256 a) internal pure returns (uint256) {
	//     if (a == 0) {
	//         return 0;
	//     }

	//     // For our first guess, we get the biggest power of 2 which is smaller than the square root of the target.
	//     //
	//     // We know that the "msb" (most significant bit) of our target number `a` is a power of 2 such that we have
	//     // `msb(a) <= a < 2*msb(a)`. This value can be written `msb(a)=2**k` with `k=log2(a)`.
	//     //
	//     // This can be rewritten `2**log2(a) <= a < 2**(log2(a) + 1)`
	//     // → `sqrt(2**k) <= sqrt(a) < sqrt(2**(k+1))`
	//     // → `2**(k/2) <= sqrt(a) < 2**((k+1)/2) <= 2**(k/2 + 1)`
	//     //
	//     // Consequently, `2**(log2(a) / 2)` is a good first approximation of `sqrt(a)` with at least 1 correct bit.
	//     uint256 result = 1 << (log2(a) >> 1);

	//     // At this point `result` is an estimation with one bit of precision. We know the true value is a uint128,
	//     // since it is the square root of a uint256. Newton's method converges quadratically (precision doubles at
	//     // every iteration). We thus need at most 7 iteration to turn our partial result with one bit of precision
	//     // into the expected uint128 result.
	//     unchecked {
	//         result = (result + a / result) >> 1;
	//         result = (result + a / result) >> 1;
	//         result = (result + a / result) >> 1;
	//         result = (result + a / result) >> 1;
	//         result = (result + a / result) >> 1;
	//         result = (result + a / result) >> 1;
	//         result = (result + a / result) >> 1;
	//         return min(result, a / result);
	//     }
	// }

	/**
	 * @notice Calculates sqrt(a), following the selected rounding direction.
	 */
	// function sqrt(uint256 a, Rounding rounding) internal pure returns (uint256) {
	//     unchecked {
	//         uint256 result = sqrt(a);
	//         return result + (rounding == Rounding.Up && result * result < a ? 1 : 0);
	//     }
	// }

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
	// function log2(uint256 value, Rounding rounding) internal pure returns (uint256) {
	//     unchecked {
	//         uint256 result = log2(value);
	//         return result + (rounding == Rounding.Up && 1 << result < value ? 1 : 0);
	//     }
	// }

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
	// function log10(uint256 value, Rounding rounding) internal pure returns (uint256) {
	//     unchecked {
	//         uint256 result = log10(value);
	//         return result + (rounding == Rounding.Up && 10 ** result < value ? 1 : 0);
	//     }
	// }

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
	// function log256(uint256 value, Rounding rounding) internal pure returns (uint256) {
	//     unchecked {
	//         uint256 result = log256(value);
	//         return result + (rounding == Rounding.Up && 1 << (result << 3) < value ? 1 : 0);
	//     }
	// }
}

// OpenZeppelin Contracts (last updated v4.8.0) (utils/math/SignedMath.sol)

/**
 * @dev Standard signed math utilities missing in the Solidity language.
 */
library SignedMath {
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
	// function toString(int256 value) internal pure returns (string memory) {
	//     return string(abi.encodePacked(value < 0 ? "-" : "", toString(SignedMath.abs(value))));
	// }

	/**
	 * @dev Converts a `uint256` to its ASCII `string` hexadecimal representation.
	 */
	// function toHexString(uint256 value) internal pure returns (string memory) {
	//     unchecked {
	//         return toHexString(value, Math.log256(value) + 1);
	//     }
	// }

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
	// function equal(string memory a, string memory b) internal pure returns (bool) {
	//     return keccak256(bytes(a)) == keccak256(bytes(b));
	// }
}

// OpenZeppelin Contracts v4.4.1 (utils/introspection/ERC165.sol)

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

library TransferHelper {
	function safeApprove(address token, address to, uint value) internal {
		// bytes4(keccak256(bytes('approve(address,uint256)')));
		(bool success, bytes memory data) = token.call(abi.encodeWithSelector(0x095ea7b3, to, value));
		require(success && (data.length == 0 || abi.decode(data, (bool))), "TransferHelper: APPROVE_FAILED");
	}

	function safeTransfer(address token, address to, uint value) internal {
		// bytes4(keccak256(bytes('transfer(address,uint256)')));
		(bool success, bytes memory data) = token.call(abi.encodeWithSelector(0xa9059cbb, to, value));
		require(success && (data.length == 0 || abi.decode(data, (bool))), "TransferHelper: TRANSFER_FAILED");
	}

	function safeTransferFrom(address token, address from, address to, uint value) internal {
		// bytes4(keccak256(bytes('transferFrom(address,address,uint256)')));
		(bool success, bytes memory data) = token.call(abi.encodeWithSelector(0x23b872dd, from, to, value));
		require(success && (data.length == 0 || abi.decode(data, (bool))), "TransferHelper: TRANSFER_FROM_FAILED");
	}

	function safeTransferETH(address to, uint value) internal {
		(bool success, ) = to.call{ value: value }(new bytes(0));
		require(success, "TransferHelper: ETH_TRANSFER_FAILED");
	}
}

library UniSwapV2Library {
	// returns sorted token addresses, used to handle return values from pairs sorted in this order
	function sortTokens(address tokenA, address tokenB) internal pure returns (address token0, address token1) {
		require(tokenA != tokenB, "UniSwapV2Library: IDENTICAL_ADDRESSES");
		(token0, token1) = tokenA < tokenB ? (tokenA, tokenB) : (tokenB, tokenA);
		require(token0 != address(0), "UniSwapV2Library: ZERO_ADDRESS");
	}

	// calculates the CREATE2 address for a pair without making any external calls
	function pairFor(
		address factory,
		address tokenA,
		address tokenB,
		bytes32 creationCode
	) internal pure returns (address pair) {
		(address token0, address token1) = sortTokens(tokenA, tokenB);
		pair = address(
			uint160(
				uint(
					keccak256(
						abi.encodePacked(
							hex"ff",
							factory,
							keccak256(abi.encodePacked(token0, token1)),
							creationCode // init code hash (creationCode of factory)
						)
					)
				)
			)
		);
	}

	// fetches and sorts the reserves for a pair
	function getReserves(
		address factory,
		address tokenA,
		address tokenB,
		bytes32 creationCode
	) internal view returns (uint reserveA, uint reserveB) {
		(address token0, ) = sortTokens(tokenA, tokenB);
		pairFor(factory, tokenA, tokenB, creationCode);
		(uint reserve0, uint reserve1, ) = IUniswapV2Pair(pairFor(factory, tokenA, tokenB, creationCode)).getReserves();
		(reserveA, reserveB) = tokenA == token0 ? (reserve0, reserve1) : (reserve1, reserve0);
	}

	// given some amount of an asset and pair reserves, returns an equivalent amount of the other asset
	function quote(uint amountA, uint reserveA, uint reserveB) internal pure returns (uint amountB) {
		require(amountA > 0, "UniSwapV2Library: INSUFFICIENT_AMOUNT");
		require(reserveA > 0 && reserveB > 0, "UniSwapV2Library: INSUFFICIENT_LIQUIDITY");
		amountB = amountA * reserveB / reserveA;
	}

	// given an input amount of an asset and pair reserves, returns the maximum output amount of the other asset
	function getAmountOut(uint amountIn, uint reserveIn, uint reserveOut) internal pure returns (uint amountOut) {
		require(amountIn > 0, "UniSwapV2Library: INSUFFICIENT_INPUT_AMOUNT");
		require(reserveIn > 0 && reserveOut > 0, "UniSwapV2Library: INSUFFICIENT_LIQUIDITY");
		uint amountInWithFee = amountIn * 9975;
		uint numerator = amountInWithFee * reserveOut;
		uint denominator = reserveIn * 10000 + amountInWithFee;
		amountOut = numerator / denominator;
	}

	// given an output amount of an asset and pair reserves, returns a required input amount of the other asset
	function getAmountIn(uint amountOut, uint reserveIn, uint reserveOut) internal pure returns (uint amountIn) {
		require(amountOut > 0, "UniSwapV2Library: INSUFFICIENT_OUTPUT_AMOUNT");
		require(reserveIn > 0 && reserveOut > 0, "UniSwapV2Library: INSUFFICIENT_LIQUIDITY");
		uint numerator = reserveIn * amountOut * 10000;
		uint denominator = (reserveOut - amountOut) * 9975;
		amountIn = (numerator / denominator) + 1;
	}

	// performs chained getAmountOut calculations on any number of pairs
	function getAmountsOut(
		address factory,
		uint amountIn,
		address[] memory path,
		bytes32 creationCode
	) internal view returns (uint[] memory amounts) {
		require(path.length >= 2, "UniSwapV2Library: INVALID_PATH");
		amounts = new uint[](path.length);
		amounts[0] = amountIn;
		for (uint i; i < path.length - 1; i++) {
			(uint reserveIn, uint reserveOut) = getReserves(factory, path[i], path[i + 1], creationCode);
			amounts[i + 1] = getAmountOut(amounts[i], reserveIn, reserveOut);
		}
	}

	// performs chained getAmountIn calculations on any number of pairs
	function getAmountsIn(
		address factory,
		uint amountOut,
		address[] memory path,
		bytes32 creationCode
	) internal view returns (uint[] memory amounts) {
		require(path.length >= 2, "UniSwapV2Library: INVALID_PATH");
		amounts = new uint[](path.length);
		amounts[amounts.length - 1] = amountOut;
		for (uint i = path.length - 1; i > 0; i--) {
			(uint reserveIn, uint reserveOut) = getReserves(factory, path[i - 1], path[i], creationCode);
			amounts[i - 1] = getAmountIn(amounts[i], reserveIn, reserveOut);
		}
	}
}

abstract contract SwapUtils is ReentrancyGuard, AccessControl {
	enum SWAPTYPE {
		U2BNB,
		U2ETH,
		U2BTC,
		BNB2U,
		ETH2U,
		BTC2U
	}

	address public immutable usdtToken;
	address public immutable bnbToken;
	address public immutable ethToken;
	address public immutable btcToken;
	address public factory;
	bytes32 public creationCode;
	uint256 public immutable slippage;
	uint256 public immutable u2TokenMax;
	uint256 public immutable bnb2UMax;
	uint256 public immutable eth2UMax;
	uint256 public immutable btc2UMax;

	constructor() {
		factory = 0x858E3312ed3A876947EA49d572A7C42DE08af7EE;
		creationCode = 0xfea293c909d87cd4153593f077b76bb7e94340200f4ee84211ae8e4f9bd7ffdf;
		usdtToken = 0x55d398326f99059fF775485246999027B3197955;
		bnbToken = 0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c;
		ethToken = 0x2170Ed0880ac9A755fd29B2688956BD959F933F8;
		btcToken = 0x7130d2A12B9BCbFAe4f2634d864A1Ee1Ce3Ead9c;
		slippage = 10; // 10/1000
		u2TokenMax = 5000 * 1e18;
		bnb2UMax = 20 * 1e18;
		eth2UMax = 2 * 1e18;
		btc2UMax = (2 * 1e18) / 10;
	}

	function _swapData(
		SWAPTYPE _type
	) internal view returns (uint256 amountIn, address inputToken, address outputToken) {
		if (_type == SWAPTYPE.U2BNB) {
			amountIn = Math.min(IERC20(usdtToken).balanceOf(address(this)), u2TokenMax);
			inputToken = usdtToken;
			outputToken = bnbToken;
		} else if (_type == SWAPTYPE.U2ETH) {
			amountIn = Math.min(IERC20(usdtToken).balanceOf(address(this)), u2TokenMax);
			inputToken = usdtToken;
			outputToken = ethToken;
		} else if (_type == SWAPTYPE.U2BTC) {
			amountIn = Math.min(IERC20(usdtToken).balanceOf(address(this)), u2TokenMax);
			inputToken = usdtToken;
			outputToken = btcToken;
		} else if (_type == SWAPTYPE.BNB2U) {
			amountIn = Math.min(IERC20(bnbToken).balanceOf(address(this)), bnb2UMax);
			inputToken = bnbToken;
			outputToken = usdtToken;
		} else if (_type == SWAPTYPE.ETH2U) {
			amountIn = Math.min(IERC20(ethToken).balanceOf(address(this)), eth2UMax);
			inputToken = ethToken;
			outputToken = usdtToken;
		} else if (_type == SWAPTYPE.BTC2U) {
			amountIn = Math.min(IERC20(btcToken).balanceOf(address(this)), btc2UMax);
			inputToken = btcToken;
			outputToken = usdtToken;
		}
	}

	function _swapExactTokensForTokens(
		uint256 amountIn,
		address[] memory path,
		address to
	) internal virtual returns (uint256[] memory amounts) {
		amounts = UniSwapV2Library.getAmountsOut(factory, amountIn, path, creationCode);
		address pair = UniSwapV2Library.pairFor(factory, path[0], path[1], creationCode);
		if (pair == address(0)) revert("zero address");
		TransferHelper.safeTransfer(
			path[0],
			pair,
			amountIn
		);

		_swap(amounts, path, to);
	}

	function _swap(uint256[] memory amounts, address[] memory path, address _to) private {
		for (uint256 i; i < path.length - 1; i++) {
			(address input, address output) = (path[i], path[i + 1]);
			(address token0, ) = UniSwapV2Library.sortTokens(input, output);
			uint256 amountOut = amounts[i + 1];
			(uint256 amount0Out, uint256 amount1Out) = input == token0
				? (uint256(0), amountOut)
				: (amountOut, uint256(0));
			address to = i < path.length - 2
				? UniSwapV2Library.pairFor(factory, output, path[i + 2], creationCode)
				: _to;
			IUniswapV2Pair(UniSwapV2Library.pairFor(factory, input, output, creationCode)).swap(
				amount0Out,
				amount1Out,
				to,
				new bytes(0)
			);
		}
	}

	function _swapTo(address[] memory path, address to, uint256 amountIn) internal virtual returns (uint256) {
		uint256[] memory amounts = _swapExactTokensForTokens(amountIn, path, to);
		address[] memory path_1 = new address[](2);
		path_1[0] = path[1];
		path_1[1] = path[0];
		uint256[] memory amounts1 = UniSwapV2Library.getAmountsOut(factory, amounts[1], path_1, creationCode);
		require(amounts1[1] >= (amountIn - ((amountIn * slippage) / 1000)), "swap amount error");
		return amounts[1];
	}

	function _setFactory(address _factory, bytes32 _creationCode) internal virtual {
		factory = _factory;
		creationCode = _creationCode;
	}
}

contract FeeFund is SwapUtils {
	bytes32 public constant CALL_AUTH_ROLE = keccak256("CALL_AUTH_ROLE");
	bytes32 public constant SWAP_AUTH_ROLE = keccak256("SWAP_AUTH_ROLE");
	bytes32 public constant SET_RATE_ROLE = keccak256("SET_RATE_ROLE");

	address public immutable fundTo;
	uint256 public rate;

	constructor(address _fundTo, address _rateAuth, address _swapAuth, address _callAuth) {
		if (_fundTo == address(0)) revert("zero address");
		_grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
		_grantRole(CALL_AUTH_ROLE, _callAuth);
		_grantRole(SET_RATE_ROLE, _rateAuth);
		_grantRole(SWAP_AUTH_ROLE, _swapAuth);

		fundTo = _fundTo;

		rate = 50000; // 5 * 10000
	}

	function release() external onlyRole(CALL_AUTH_ROLE) {
		uint _balance = IERC20(usdtToken).balanceOf(address(this));
		uint _amount = (_balance * rate) / (100 * 10000);
		if (_amount > 0) TransferHelper.safeTransfer(usdtToken, fundTo, _amount);
	}

	function setRate(uint256 _rate) external onlyRole(SET_RATE_ROLE) {
		rate = _rate;
	}

	function dexSwapWithType(SWAPTYPE _type) external nonReentrant onlyRole(SWAP_AUTH_ROLE) {
		address[] memory path = new address[](2);
		(uint256 amountIn, address inputToken, address outputToken) = _swapData(_type);
		path[0] = inputToken;
		path[1] = outputToken;
		_swapTo(path, address(this), amountIn);
	}

	function customDexSwap(
		address _factory,
		uint256 _amountIn,
		address[] calldata _path
	) external nonReentrant onlyRole(SWAP_AUTH_ROLE) {
		if (_factory == 0xcA143Ce32Fe78f1f7019d7d551a6402fC5350c73) {
			// pancake
			address factory_ = factory;
			bytes32 creationCode_ = creationCode;
			_setFactory(_factory, hex'00fb7f630766e6a796048ea87d01acd3068e8ff67d078148a3fa3f4a84f69bd5');
			_swapTo(_path, address(this), Math.min(_amountIn, IERC20(_path[0]).balanceOf(address(this))));
			_setFactory(factory_, creationCode_);
		} else if (_factory == factory) {
			// Biswap
			_swapTo(_path, address(this), Math.min(_amountIn, IERC20(_path[0]).balanceOf(address(this))));
		} else {
			revert("not swap");
		}
	}
}