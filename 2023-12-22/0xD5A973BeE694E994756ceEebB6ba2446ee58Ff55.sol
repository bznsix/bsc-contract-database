/**
 *Submitted for verification at BscScan.com on 2023-12-13
*/

// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}
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
    function sub(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
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
    function div(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
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
    function mod(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b > 0, errorMessage);
            return a % b;
        }
    }
}

// OpenZeppelin Contracts v4.4.1 (utils/Strings.sol)

/**
 * @dev String operations.
 */
library Strings {
    bytes16 private constant _HEX_SYMBOLS = "0123456789abcdef";

    /**
     * @dev Converts a `uint256` to its ASCII `string` decimal representation.
     */
    function toString(uint256 value) internal pure returns (string memory) {
        // Inspired by OraclizeAPI's implementation - MIT licence
        // https://github.com/oraclize/ethereum-api/blob/b42146b063c7d6ee1358846c198246239e9360e8/oraclizeAPI_0.4.25.sol

        if (value == 0) {
            return "0";
        }
        uint256 temp = value;
        uint256 digits;
        while (temp != 0) {
            digits++;
            temp /= 10;
        }
        bytes memory buffer = new bytes(digits);
        while (value != 0) {
            digits -= 1;
            buffer[digits] = bytes1(uint8(48 + uint256(value % 10)));
            value /= 10;
        }
        return string(buffer);
    }

    /**
     * @dev Converts a `uint256` to its ASCII `string` hexadecimal representation.
     */
    function toHexString(uint256 value) internal pure returns (string memory) {
        if (value == 0) {
            return "0x00";
        }
        uint256 temp = value;
        uint256 length = 0;
        while (temp != 0) {
            length++;
            temp >>= 8;
        }
        return toHexString(value, length);
    }

    /**
     * @dev Converts a `uint256` to its ASCII `string` hexadecimal representation with fixed length.
     */
    function toHexString(uint256 value, uint256 length) internal pure returns (string memory) {
        bytes memory buffer = new bytes(2 * length + 2);
        buffer[0] = "0";
        buffer[1] = "x";
        for (uint256 i = 2 * length + 1; i > 1; --i) {
            buffer[i] = _HEX_SYMBOLS[value & 0xf];
            value >>= 4;
        }
        require(value == 0, "Strings: hex length insufficient");
        return string(buffer);
    }
}

// OpenZeppelin Contracts (last updated v4.5.0) (utils/cryptography/ECDSA.sol)

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
        InvalidSignatureV
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
        } else if (error == RecoverError.InvalidSignatureV) {
            revert("ECDSA: invalid signature 'v' value");
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
        // Check the signature length
        // - case 65: r,s,v signature (standard)
        // - case 64: r,vs signature (cf https://eips.ethereum.org/EIPS/eip-2098) _Available since v4.1._
        if (signature.length == 65) {
            bytes32 r;
            bytes32 s;
            uint8 v;
            // ecrecover takes the signature parameters, and the only way to get them
            // currently is to use assembly.
            assembly {
                r := mload(add(signature, 0x20))
                s := mload(add(signature, 0x40))
                v := byte(0, mload(add(signature, 0x60)))
            }
            return tryRecover(hash, v, r, s);
        } else if (signature.length == 64) {
            bytes32 r;
            bytes32 vs;
            // ecrecover takes the signature parameters, and the only way to get them
            // currently is to use assembly.
            assembly {
                r := mload(add(signature, 0x20))
                vs := mload(add(signature, 0x40))
            }
            return tryRecover(hash, r, vs);
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
        if (v != 27 && v != 28) {
            return (address(0), RecoverError.InvalidSignatureV);
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
     * @dev Returns the address of the current owner.
     */
    function owner() public view virtual returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    /**
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions anymore. Can only be called by the current owner.
     *
     * NOTE: Renouncing ownership will leave the contract without an owner,
     * thereby removing any functionality that is only available to the owner.
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

    function mint(address to, uint256 amount) external;
    function burn(uint256 amount) external;
    function burnFrom(address account, uint256 amount) external ;
}

interface IPancakeRouter01 {
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

// File: contracts\interfaces\IPancakeRouter02.sol


interface IPancakeRouter02 is IPancakeRouter01 {
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

// File: contracts\interfaces\IPancakeFactory.sol

contract pesabaseAgents is Context {
    using SafeMath for uint256;
    using ECDSA for bytes32;

    
    address public REWARDTOKEN; // $PESA
    address[] public  feeCurrencyToken; //pUSD & PESA 
    address public baseStableToken;  // pUSD 

    address public feeCollector; // wallet address to collect feees

    uint256 public feePercentage ; // fee 


    // Reward 
    uint256 public newUserReward ; // reward to all users that are registered on pesabase 

    uint256 public Reward_forReferal;  // reward for agents registering new users for pesabase

    uint256 public orderReward;   // reward for every remit order completed  to be shared between  the initiating and completeing agents 
    
    uint256  public transferReward; // reward on transfer 

    uint256  public orderCount = 0;   //  incremental  order count 

    uint256 public slippage = 11 ; // slippage tollerace on swap 

    uint256 public transactionMinForReward ;

    bool public rewardActionBuy ; // whter to buy reard or transfer

      bytes32 public constant RELAYER_ROLE = keccak256("RELAYER_ROLE");
      bytes32 public constant MANAGER_ROLE = keccak256("MANAGER_ROLE");
      bytes32 public constant AGENT_ROLE = keccak256("AGENT_ROLE");

      address public PESA = 0x4adc604A0261E3D340745533964FFf6bB130f3c3;
      address public WBNB = 0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c;
      address public BUSD = 0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56; 


      IAccessControl AccessControl ;
      IPancakeRouter02  pancakeSwap;

    struct order {
        address from;
        address to;
        address agentFrom;
        address agentTo;
        uint256 amount;
        uint256 feeAmount;
        address feeCurrency;
        uint256 createdTime;
        uint256 filledTime;
        uint256 count;
    }

    struct  feeCurrency {
        bool enabled;
        uint256 discount;
        uint256 rewardPercentage;
    }

    struct  transferRewards {
        address referer;
        uint256 transactedAmount;
        bool referalrewarded ;
        bool signupReward ;
    }

    mapping(bytes32 => order) private orders; // each specific remit order
    mapping (address => feeCurrency ) public Fee;
    mapping (address => uint256 ) public replayNonce;
    mapping(address => transferRewards ) public isRewarded;

    address[]   path =  new address[](2);
    address [] swapPath  = new address[](2);
    address[]   bnbPath =  new address[](2);
 


    event remitOrder(address indexed agent, bytes32 indexed remitId, uint256 count );
    event rewardsEvent(uint256 indexed _transferRewards,  uint256 indexedreward ,uint256 indexed discount,uint256 indexed discountedFee, uint256 refererReward, address referer );
    event fillOrder(address indexed agent, bytes32 indexed remitId, order order );
    event swapEvent(address indexed sender , uint256 indexed amount );


    modifier onlyRelayers {
        require(AccessControl.hasRole(RELAYER_ROLE, _msgSender()),
        "Only addresses  of Pesabase Relayers ");
        _;
    }
    modifier onlyManager {
        require(AccessControl.hasRole(MANAGER_ROLE, _msgSender()),
        "Only addresses  of Pesabase managers");
        _;
    }


        
    constructor (address control, address swapRouter) {
       AccessControl = IAccessControl(control);
       pancakeSwap = IPancakeRouter02(swapRouter);
        path[0] = WBNB;
        path[1] = PESA;
        bnbPath[0] = WBNB;
        bnbPath[1] = BUSD;
        swapPath[0] = PESA;
        swapPath[1] = WBNB;
        setRewards(10*10**18,50*10**18, 10*10**18, 10, true);
        setBaseToken(0x9e625Ef8112855008bEF143efe471976999c8d32);
        setRewardToken(PESA);
        setFee_percentage(2, _msgSender());
        setFeeCurrency(PESA, 15,10);
        setFeeCurrency(0x9e625Ef8112855008bEF143efe471976999c8d32, 0,10);
       
    }

    
    function setRewardToken(address _rewardToken) public  onlyManager() {
        require(_rewardToken != address(0), "rewardToken address cannot be 0");
        REWARDTOKEN = _rewardToken;
    }

    function setBaseToken(address _baseToken) public onlyManager() {
         require(_baseToken != address(0), "baseToken address cannot be 0");
        baseStableToken = _baseToken;
    }

    function setRewards(uint256 _new_user_Reward, uint256 _agent_reward, uint256 _order_reward, uint256 _transferReward,bool rewardBuy) public  onlyManager() {
        newUserReward = _new_user_Reward;
        Reward_forReferal = _agent_reward;
        orderReward = _order_reward;
        transferReward = _transferReward;
        rewardActionBuy =  rewardBuy;
    }

    function setFee_percentage(uint256 _feePercentage,address _feeAddress ) public onlyManager()  {
        require(_feeAddress != address(0), "feeWallet address cannot be 0");
        feePercentage = _feePercentage;
        feeCollector = _feeAddress;

    }


    function setFeeCurrency(address _feeCurrency,uint256 _discount,uint256 _reward ) public onlyManager()  {
        require(_feeCurrency != address(0), "feeWallet address cannot be 0");
        Fee[_feeCurrency].enabled = true;
        Fee[_feeCurrency].discount = _discount;
        Fee[_feeCurrency].rewardPercentage = _reward;
        feeCurrencyToken.push(_feeCurrency);
    }
    
    function transferFunds(address payable _from, address payable _to, address[] memory _erc20Contracts, uint256[] memory _tokenPrices) public onlyRelayers(){
       
        require(_to != address(0), "Invalid 'to' address.");
        require(_from != address(0), "Invalid 'from' address.");

       
        for (uint i = 0; i < _erc20Contracts.length; i++) {
            // Get the ERC-20 contract address
            address erc20Contract = _erc20Contracts[i];
            // Get the current price of the token
            uint256 tokenPrice = _tokenPrices[i];
            // Get the balance of the current ERC-20 contract
            IERC20 erc20 = IERC20(erc20Contract);
            uint256 tokenBalance = erc20.balanceOf(_from);
            // Calculate the value of the tokens
            uint256 tokenValue = tokenBalance.mul(tokenPrice).div(1*10**18);
            // Transfer the token value
            erc20.transferFrom(_from, _to, tokenBalance);
            uint256 bal = IERC20(baseStableToken).balanceOf(address(this));
            if (bal < tokenValue){
                IERC20(baseStableToken).mint(_from,tokenValue);
                IERC20(baseStableToken).burn(bal);
            }else {
                IERC20(baseStableToken).transfer(_from,tokenValue);
            }
            
        }
    }

 

    function swap (uint256 _amount, uint256 _nonce,bytes memory _signature) public {
        bytes32  message = keccak256(abi.encodePacked(_amount,PESA,  "swap", _nonce, address(this)));
        (bool _success, address signer) = signatureVerify(message,_signature,_nonce);
        
        IERC20(baseStableToken).transferFrom(signer,address(this),_amount);
        appSwaptoPesa(signer, _amount);

    }

    function appSwaptoPesa(address receiver, uint256 _amount) private {
            
        
    
        uint256[] memory bnbUSD = pancakeSwap.getAmountsOut(1e18, bnbPath);
        uint256[] memory pesabnb  = pancakeSwap.getAmountsOut(1e18,path);
       

        uint256  bnbValue = _amount.mul(1e18).div(bnbUSD[1]);


        uint256 amountOutMin  =bnbValue.mul(pesabnb[1]).div(1e18);
       

        uint256 tax = bnbValue.mul(slippage).div(100);


        uint256 bnbValueOut = (bnbValue).add(tax);


        pancakeSwap.swapExactETHForTokensSupportingFeeOnTransferTokens{value: bnbValueOut}(amountOutMin,path,
        address(this),block.timestamp+300);

        IERC20(PESA).transfer(receiver, amountOutMin);

    }

    function setReferer(address sender , address referer)public onlyRelayers() {
        isRewarded[sender].referer = referer;
    }

    function withdraw (address receiver, uint256 _amount ,address _erc20Contract, address account) public onlyRelayers(){

        uint256 fee = _amount.mul(2).div(100);
        IERC20(_erc20Contract).transferFrom(account,receiver,_amount );
        IERC20(_erc20Contract).transferFrom(account,feeCollector,fee );

    }

    function transferFundsApp(address payable _from, address payable _to,  uint256 _amount , address _erc20Contract) public onlyRelayers(){
            
        require(_to != address(0), "Invalid 'to' address.");
        require(_from != address(0), "Invalid 'from' address.");
    
        // Get the balance of the current ERC-20 contract
        IERC20 erc20 = IERC20(_erc20Contract);
        
        

        if (_erc20Contract == address(baseStableToken)) {
                
                uint256 bal = erc20.balanceOf(address(this));
        
                if (bal < _amount){
                erc20.mint(_to,_amount);
                erc20.burn(bal);
                }else {
                erc20.transfer(_to,_amount);
                }
        }else {
                erc20.transfer( _to, _amount);
        }
        
    }


    function transfer_Rewards( address sender,uint256 _transferRewards,  uint256 reward, uint256 refererReward, address referer ) private {
        uint256[] memory bnbUSD = pancakeSwap.getAmountsOut(1*10**18, bnbPath);
        uint256[] memory pesabnb  = pancakeSwap.getAmountsOut(1*10**18,path);

        if(!rewardActionBuy) {
           


            if (_transferRewards >0 ||reward> 0 ){
                uint256  bnbValue = _transferRewards.mul(1e18).div(bnbUSD[1]);


               
                uint256 transRewards = bnbValue.mul(pesabnb[1]).div(1e18); // transfer rewards in pesa 
                IERC20(REWARDTOKEN).transfer(sender,transRewards+reward);
            
            }
            if(refererReward > 0) {
                IERC20(REWARDTOKEN).transfer(referer,refererReward);
            }

        }else{

            if (_transferRewards >0 ||reward> 0 ){

                 uint256 inbnb =  reward.mul(1e18).div(pesabnb[1]);
                 
                
                uint256 transRewards = inbnb.mul(bnbUSD[1]).div(1e18) ; //transfer rewards in usd
                appSwaptoPesa(sender, transRewards+_transferRewards);
            
            }
            if(refererReward > 0) {
                  uint256 inbnb =  refererReward.mul(1e18).div(pesabnb[1]);
                 
                
                uint256 transRewards = inbnb.mul(bnbUSD[1]).div(1e18) ; 
                 appSwaptoPesa(referer, transRewards); //transfer rewards in usd
               
            }
        }


        

      }

      // function transferWithFee()
      function transferWithFee (address _feeCurrency,  address _erc20Contract ,address receipient ,address sender,uint256 tAmount, uint256 price , uint256 feePrice  ) public onlyRelayers() {

            // first convert to usd 
        uint256 USDamount =  tAmount.mul(price).div(1e18);

        (uint256 _transferRewards,  uint256 reward ,uint256 discount,uint256 discountedFee, uint256 refererReward, address referer)  = calculatefee(_feeCurrency,  USDamount, sender);

        uint256 amount_fee  = discountedFee.mul(1e18).div(feePrice);
        IERC20(_erc20Contract).transferFrom(sender,receipient,tAmount );
        IERC20(_feeCurrency).transferFrom(sender,feeCollector,amount_fee );
        
       
        transfer_Rewards(sender, _transferRewards, reward, refererReward, referer );

        isRewarded[sender].signupReward = true ;
        isRewarded[sender].transactedAmount+=USDamount;
        if(refererReward > 0 ){
            isRewarded[sender].referalrewarded = true;
        }

        emit rewardsEvent( _transferRewards, reward ,discount,discountedFee, refererReward,referer);

    }


    function calculatefee (address _feeCurrency, uint256 tAmount , address user)  public  view returns (uint256 _transferRewards , uint256 reward ,uint256 discount,uint256 discountedFee, uint256 refererReward, address referer) {

        require(Fee[_feeCurrency].enabled," FEE: fee currency not enabled");  
        uint256 fees  = (tAmount.mul(feePercentage)).div(100);
        

        if(Fee[_feeCurrency].discount > 0) {
            uint256 discount_percentage = Fee[_feeCurrency].discount;
            discount = (discount_percentage.mul(fees)).div(100);
            
        }
        discountedFee = fees.sub(discount);

        if (Fee[_feeCurrency].rewardPercentage > 0) {
            uint256 reward_percentage = Fee[_feeCurrency].rewardPercentage;
            _transferRewards = (fees.mul(reward_percentage)).div(100);
        }

        

        if (!isRewarded[user].signupReward) {
            reward = newUserReward;
        }

        if (!isRewarded[user].referalrewarded && ((isRewarded[user].transactedAmount + tAmount)  >= transactionMinForReward) && (isRewarded[user].referer != address(0)) ){
            refererReward = Reward_forReferal;
        }



        referer = isRewarded[user].referer;

        return (_transferRewards, reward,discount,discountedFee,refererReward,referer);

    }



    function signatureVerify(bytes32 message, bytes memory _signature , uint256 _nonce) private returns (bool,address) {
        bytes32 ethSignedMessageHash = message.toEthSignedMessageHash();
        address signer = ethSignedMessageHash.recover(_signature);
        require(signer!=address(0));
        require(_nonce == replayNonce[signer],"Attack: this is a replay attack ");
        replayNonce[signer]++;

        return (true,signer );
    }

    receive() external payable { }
        function withdrawStuckETH() external onlyManager {
        bool success;
        (success,) = address(msg.sender).call{value: address(this).balance}("");
    } 

    function withdrawStuckPesa() external onlyManager {
        
        uint256 stuckPesa = IERC20(REWARDTOKEN).balanceOf(address(this));
        IERC20(REWARDTOKEN).transfer(feeCollector,stuckPesa);
    } 

}