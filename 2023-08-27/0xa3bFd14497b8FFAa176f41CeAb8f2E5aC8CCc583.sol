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
// OpenZeppelin Contracts (last updated v4.9.0) (token/ERC721/IERC721.sol)

pragma solidity ^0.8.0;

import "../../utils/introspection/IERC165.sol";

/**
 * @dev Required interface of an ERC721 compliant contract.
 */
interface IERC721 is IERC165 {
    /**
     * @dev Emitted when `tokenId` token is transferred from `from` to `to`.
     */
    event Transfer(address indexed from, address indexed to, uint256 indexed tokenId);

    /**
     * @dev Emitted when `owner` enables `approved` to manage the `tokenId` token.
     */
    event Approval(address indexed owner, address indexed approved, uint256 indexed tokenId);

    /**
     * @dev Emitted when `owner` enables or disables (`approved`) `operator` to manage all of its assets.
     */
    event ApprovalForAll(address indexed owner, address indexed operator, bool approved);

    /**
     * @dev Returns the number of tokens in ``owner``'s account.
     */
    function balanceOf(address owner) external view returns (uint256 balance);

    /**
     * @dev Returns the owner of the `tokenId` token.
     *
     * Requirements:
     *
     * - `tokenId` must exist.
     */
    function ownerOf(uint256 tokenId) external view returns (address owner);

    /**
     * @dev Safely transfers `tokenId` token from `from` to `to`.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `tokenId` token must exist and be owned by `from`.
     * - If the caller is not `from`, it must be approved to move this token by either {approve} or {setApprovalForAll}.
     * - If `to` refers to a smart contract, it must implement {IERC721Receiver-onERC721Received}, which is called upon a safe transfer.
     *
     * Emits a {Transfer} event.
     */
    function safeTransferFrom(address from, address to, uint256 tokenId, bytes calldata data) external;

    /**
     * @dev Safely transfers `tokenId` token from `from` to `to`, checking first that contract recipients
     * are aware of the ERC721 protocol to prevent tokens from being forever locked.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `tokenId` token must exist and be owned by `from`.
     * - If the caller is not `from`, it must have been allowed to move this token by either {approve} or {setApprovalForAll}.
     * - If `to` refers to a smart contract, it must implement {IERC721Receiver-onERC721Received}, which is called upon a safe transfer.
     *
     * Emits a {Transfer} event.
     */
    function safeTransferFrom(address from, address to, uint256 tokenId) external;

    /**
     * @dev Transfers `tokenId` token from `from` to `to`.
     *
     * WARNING: Note that the caller is responsible to confirm that the recipient is capable of receiving ERC721
     * or else they may be permanently lost. Usage of {safeTransferFrom} prevents loss, though the caller must
     * understand this adds an external call which potentially creates a reentrancy vulnerability.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `tokenId` token must be owned by `from`.
     * - If the caller is not `from`, it must be approved to move this token by either {approve} or {setApprovalForAll}.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(address from, address to, uint256 tokenId) external;

    /**
     * @dev Gives permission to `to` to transfer `tokenId` token to another account.
     * The approval is cleared when the token is transferred.
     *
     * Only a single account can be approved at a time, so approving the zero address clears previous approvals.
     *
     * Requirements:
     *
     * - The caller must own the token or be an approved operator.
     * - `tokenId` must exist.
     *
     * Emits an {Approval} event.
     */
    function approve(address to, uint256 tokenId) external;

    /**
     * @dev Approve or remove `operator` as an operator for the caller.
     * Operators can call {transferFrom} or {safeTransferFrom} for any token owned by the caller.
     *
     * Requirements:
     *
     * - The `operator` cannot be the caller.
     *
     * Emits an {ApprovalForAll} event.
     */
    function setApprovalForAll(address operator, bool approved) external;

    /**
     * @dev Returns the account approved for `tokenId` token.
     *
     * Requirements:
     *
     * - `tokenId` must exist.
     */
    function getApproved(uint256 tokenId) external view returns (address operator);

    /**
     * @dev Returns if the `operator` is allowed to manage all of the assets of `owner`.
     *
     * See {setApprovalForAll}
     */
    function isApprovedForAll(address owner, address operator) external view returns (bool);
}
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.6.0) (token/ERC721/IERC721Receiver.sol)

pragma solidity ^0.8.0;

/**
 * @title ERC721 token receiver interface
 * @dev Interface for any contract that wants to support safeTransfers
 * from ERC721 asset contracts.
 */
interface IERC721Receiver {
    /**
     * @dev Whenever an {IERC721} `tokenId` token is transferred to this contract via {IERC721-safeTransferFrom}
     * by `operator` from `from`, this function is called.
     *
     * It must return its Solidity selector to confirm the token transfer.
     * If any other value is returned or the interface is not implemented by the recipient, the transfer will be reverted.
     *
     * The selector can be obtained in Solidity with `IERC721Receiver.onERC721Received.selector`.
     */
    function onERC721Received(
        address operator,
        address from,
        uint256 tokenId,
        bytes calldata data
    ) external returns (bytes4);
}
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.9.0) (token/ERC721/utils/ERC721Holder.sol)

pragma solidity ^0.8.0;

import "../IERC721Receiver.sol";

/**
 * @dev Implementation of the {IERC721Receiver} interface.
 *
 * Accepts all token transfers.
 * Make sure the contract is able to use its token with {IERC721-safeTransferFrom}, {IERC721-approve} or {IERC721-setApprovalForAll}.
 */
contract ERC721Holder is IERC721Receiver {
    /**
     * @dev See {IERC721Receiver-onERC721Received}.
     *
     * Always returns `IERC721Receiver.onERC721Received.selector`.
     */
    function onERC721Received(address, address, uint256, bytes memory) public virtual override returns (bytes4) {
        return this.onERC721Received.selector;
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
pragma solidity ^0.8.8;

library StructData {
    // struct to store staked NFT information
    struct StakedNFT {
        address stakerAddress;
        uint256 startTime;
        uint256 unlockTime;
        uint256[] nftIds;
        uint256 totalValueStakeUsd;
        uint8 apy;
        uint256 totalClaimedAmountUsdWithDecimal;
        uint256 totalRewardAmountUsdWithDecimal;
        bool isUnstaked;
    }

    struct ChildListData {
        address[] childList;
        uint256 memberCounter;
    }
}
// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity >=0.7.0;

/// @title Optimized overflow and underflow safe math operations
/// @notice Contains methods for doing math operations that revert on overflow or underflow for minimal gas cost
library LowGasSafeMath {
    /// @notice Returns x + y, reverts if sum overflows uint256
    /// @param x The augend
    /// @param y The addend
    /// @return z The sum of x and y
    function add(uint256 x, uint256 y) internal pure returns (uint256 z) {
        require((z = x + y) >= x);
    }

    /// @notice Returns x - y, reverts if underflows
    /// @param x The minuend
    /// @param y The subtrahend
    /// @return z The difference of x and y
    function sub(uint256 x, uint256 y) internal pure returns (uint256 z) {
        require((z = x - y) <= x);
    }

    /// @notice Returns x * y, reverts if overflows
    /// @param x The multiplicand
    /// @param y The multiplier
    /// @return z The product of x and y
    function mul(uint256 x, uint256 y) internal pure returns (uint256 z) {
        require(x == 0 || (z = x * y) / x == y);
    }

    /// @notice Returns x + y, reverts if overflows or underflows
    /// @param x The augend
    /// @param y The addend
    /// @return z The sum of x and y
    function add(int256 x, int256 y) internal pure returns (int256 z) {
        require((z = x + y) >= x == (y >= 0));
    }

    /// @notice Returns x - y, reverts if overflows or underflows
    /// @param x The minuend
    /// @param y The subtrahend
    /// @return z The difference of x and y
    function sub(int256 x, int256 y) internal pure returns (int256 z) {
        require((z = x - y) <= x == (y >= 0));
    }
}
// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity >=0.5.0;

/// @title Safe casting methods
/// @notice Contains methods for safely casting between types
library SafeCast {
    /// @notice Cast a uint256 to a uint160, revert on overflow
    /// @param y The uint256 to be downcasted
    /// @return z The downcasted integer, now type uint160
    function toUint160(uint256 y) internal pure returns (uint160 z) {
        require((z = uint160(y)) == y);
    }

    /// @notice Cast a int256 to a int128, revert on overflow or underflow
    /// @param y The int256 to be downcasted
    /// @return z The downcasted integer, now type int128
    function toInt128(int256 y) internal pure returns (int128 z) {
        require((z = int128(y)) == y);
    }

    /// @notice Cast a uint256 to a int256, revert on overflow
    /// @param y The uint256 to be casted
    /// @return z The casted integer, now type int256
    function toInt256(uint256 y) internal pure returns (int256 z) {
        require(y < 2 ** 255);
        z = int256(y);
    }
}
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.8;

interface IMarketplace {
    event Buy(address seller, address buyer, uint256 nftId);
    event Sell(address seller, address buyer, uint256 nftId);
    event ErrorLog(bytes message);

    function buyByCurrency(uint256 _nftId, uint256 _refCode) external;

    function buyByToken(uint256 _nftId, uint256 _refCode) external;

    function getActiveMemberForAccount(address _wallet) external view returns (uint256);

    function getReferredNftValueForAccount(address _wallet) external view returns (uint256);

    function getNftCommissionEarnedForAccount(address _wallet) external view returns (uint256);

    function getNftSaleValueForAccountInUsdDecimal(address _wallet) external view returns (uint256);

    function getF1ListForAccount(address _wallet) external view returns (address[] memory);

    function getTeamNftSaleValueForAccountInUsdDecimal(address _wallet) external view returns (uint256);

    function updateReferralData(address _user, uint256 _refCode) external;

    function possibleChangeReferralData(address _wallet) external returns (bool);

    function checkValidRefCodeAdvance(address _user, uint256 _refCode) external view returns (bool);

    function genReferralCodeForAccount() external returns (uint256);

    function getReferralCodeForAccount(address _wallet) external view returns (uint256);

    function getReferralAccountForAccount(address _user) external view returns (address);

    function getReferralAccountForAccountExternal(address _user) external view returns (address);

    function getAccountForReferralCode(uint256 _refCode) external view returns (address);

    function getMaxEarnableCommission(address _user) external view returns (uint256);

    function getTotalCommissionEarned(address _user) external view returns (uint256);

    function getCommissionLimit(address _user) external view returns (uint256);

    function getNftPaymentType(uint256 _nftId) external view returns (bool);

    function allowBuyNftByCurrency(bool _activePayByCurrency) external;

    function allowBuyNftByToken(bool _activePayByToken) external;

    function setOracleAddress(address _oracleAddress) external;

    function setStakingAddress(address _stakingAddress) external;

    function setSystemWallet(address _newSystemWallet) external;

    function setSaleWalletAddress(address _saleAddress) external;

    function setCurrencyAddress(address _currency) external;

    function setTokenAddress(address _token) external;

    function setTypePayCommission(bool _typePayCommission) external;

    function setCommissionPercent(uint256 _percent) external;

    function setMaxCommissionDefault(uint256 _maxCommissionDefault) external;

    function setCommissionMultipleTime(uint256 _commissionMultipleTime) external;

    function setSaleStart(uint256 _newSaleStart) external;

    function setSaleEnd(uint256 _newSaleEnd) external;

    function setSalePercent(uint256 _newSalePercent, uint8 _nftTier) external;

    function updateReferralDataOnlyOwner(address _user, uint256 _refCode) external;

    function updateNftCommissionEarnedOnlyOwner(address _user, uint256 _commissionEarned) external;

    function updateNftSaleValueOnlyOwner(address _user, uint256 _nftSaleValue) external;

    function updateUserF1ListOnlyOwner(address _user, address[] memory _f1Users) external;

    function updateNftPaymentTypeOnlyOwner(uint256 _nftId, bool _paymentType) external;

    function updateUserRefParentOnlyOwner(address _user, address _parent) external;

    function recoverLostBNB() external;

    function withdrawTokenEmergency(address _token, uint256 _amount) external;

    function withdrawTokenEmergencyFrom(address _from, address _to, address _currency, uint256 _amount) external;

    function transferNftEmergency(address _receiver, uint256 _nftId) external;

    function transferMultiNftsEmergency(address[] memory _receivers, uint256[] memory _nftIds) external;
}
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.8;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC721/utils/ERC721Holder.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "../libraries/LowGasSafeMath.sol";
import "../libraries/SafeCast.sol";
import "./IMarketplace.sol";
import "../nft/IAICrewNFT.sol";
import "../oracle/IOracle.sol";
import "../stake/IStaking.sol";

contract Marketplace is IMarketplace, Ownable, ERC721Holder {
    using LowGasSafeMath for uint256;
    using SafeCast for uint256;

    uint256 public constant TOKEN_DECIMAL = 1e18;
    bool public constant PAYMENT_TYPE_TOKEN = false;
    bool public constant PAYMENT_TYPE_USDT = true;

    address public nft;
    address public token;
    address public currency;
    address public oracleContract;
    address public stakingContract;
    address public systemWallet;
    address public saleWallet = 0x62605feEF3Da8A3D0D2803bA4208ccc51030ba33;
    address private contractOwner;

    // for network stats
    mapping(address => uint256) private nftCommissionEarned;
    mapping(address => uint256) private nftSaleValue;
    mapping(address => address[]) private userF1List;

    mapping(uint256 => address) private referralCodeUser;
    mapping(address => uint256) private userReferralCode;
    mapping(address => address) private userRefParent; // user => parent

    mapping(uint256 => bool) private nftPaymentType;

    uint256 private saleStart = 1691625600; // 2023-08-10 00:00:00
    uint256 private saleEnd = 1692143999; // 2023-08-15 23:59:59
    mapping(uint8 => uint256) private salePercent;

    uint256 private commissionBuyPercent = 0; // 0%
    uint256 private maxCommissionDefault = 500000000000000000000; // 500$
    uint256 private commissionMultipleTime = 5; // 5 x totalStakedAmount

    bool private allowBuyByCurrency = true; // default allow
    bool private allowBuyByToken = false; // default disable
    bool private typePayCom = true; // false is pay com by token, true is pay com by usdt
    bool private unlocked = true;

    constructor(address _nft, address _token, address _oracle, address _systemWallet, address _currency) {
        token = _token;
        currency = _currency;
        nft = _nft;
        oracleContract = _oracle;
        systemWallet = _systemWallet;
        contractOwner = _msgSender();
        initDefaultReferral();
        initSalePercent();
    }

    modifier checkOwner() {
        require(owner() == _msgSender() || contractOwner == _msgSender(), "MARKETPLACE: caller is not the owner");
        _;
    }

    modifier lock() {
        require(unlocked == true, "MARKETPLACE: Locked");
        unlocked = false;
        _;
        unlocked = true;
    }

    modifier isAcceptBuyByCurrency() {
        require(allowBuyByCurrency, "MARKETPLACE: Only accept payment in token");
        _;
    }

    modifier isAcceptBuyByToken() {
        require(allowBuyByToken, "MARKETPLACE: Only accept payment in currency");
        _;
    }

    /**
     * @dev init default referral as system wallet
     */
    function initDefaultReferral() internal {
        uint256 systemRefCode = 1000;
        userReferralCode[systemWallet] = systemRefCode;
        referralCodeUser[systemRefCode] = systemWallet;
    }

    function initSalePercent() internal {
        salePercent[1] = 50;
        salePercent[2] = 50;
        salePercent[3] = 50;
        salePercent[4] = 30;
        salePercent[5] = 30;
        salePercent[6] = 30;
        salePercent[7] = 30;
    }

    function getCurrentSalePercent(uint8 nftTier) internal view returns (uint256) {
        if (block.timestamp >= saleStart && block.timestamp < saleEnd) {
            return salePercent[nftTier];
        }

        return 0;
    }

    function updateNetworkData(address _buyer, uint256 _totalValueUsdWithDecimal) internal {
        uint256 currentNftSaleValue = nftSaleValue[_buyer];
        nftSaleValue[_buyer] = currentNftSaleValue + _totalValueUsdWithDecimal;
    }

    /**
     * @dev buyByCurrency function
     * @param _nftId NFT ID want to buy
     * @param _refCode referral code of ref account
     */
    function buyByCurrency(uint256 _nftId, uint256 _refCode) external override isAcceptBuyByCurrency lock {
        updateReferralData(msg.sender, _refCode);
        uint256 totalValueUsdWithDecimal = IAICrewNFT(nft).getNftPriceUsd(_nftId) * TOKEN_DECIMAL;
        uint8 nftTier = IAICrewNFT(nft).getNftTier(_nftId);
        uint256 saleValueUsdWithDecimal = 0;
        {
            uint256 currentSale = getCurrentSalePercent(nftTier);
            if (currentSale > 0) {
                saleValueUsdWithDecimal = (currentSale * totalValueUsdWithDecimal) / 1000;
            }
        }

        uint256 payValueUsdWithDecimal = totalValueUsdWithDecimal - saleValueUsdWithDecimal;
        pay(currency, payValueUsdWithDecimal);

        // Transfer nft from marketplace to buyer
        IAICrewNFT(nft).safeTransferFrom(address(this), msg.sender, _nftId, "");
        nftPaymentType[_nftId] = PAYMENT_TYPE_USDT;
        emit Buy(address(this), msg.sender, _nftId);

        updateNetworkData(msg.sender, totalValueUsdWithDecimal);
        address refAddress = getReferralAccountForAccount(msg.sender);
        payReferralCommissions(refAddress, totalValueUsdWithDecimal);
    }

    /**
     * @dev buyByToken function
     * @param _nftId NFT ID want to buy
     * @param _refCode referral code of ref account
     */
    function buyByToken(uint256 _nftId, uint256 _refCode) external override isAcceptBuyByToken lock {
        updateReferralData(msg.sender, _refCode);

        uint256 totalValueUsdWithDecimal = IAICrewNFT(nft).getNftPriceUsd(_nftId) * TOKEN_DECIMAL;
        uint8 nftTier = IAICrewNFT(nft).getNftTier(_nftId);
        uint256 totalValueInTokenWithDecimal = IOracle(oracleContract).convertUsdBalanceDecimalToTokenDecimal(
            totalValueUsdWithDecimal
        );

        uint256 saleValueInTokenWithDecimal = 0;
        {
            uint256 currentSale = getCurrentSalePercent(nftTier);
            if (currentSale > 0) {
                saleValueInTokenWithDecimal = (currentSale * totalValueInTokenWithDecimal) / 1000;
            }
        }

        uint256 payValueTokenWithDecimal = totalValueInTokenWithDecimal - saleValueInTokenWithDecimal;
        pay(token, payValueTokenWithDecimal);

        // Transfer nft from marketplace to buyer
        IAICrewNFT(nft).safeTransferFrom(address(this), msg.sender, _nftId);
        nftPaymentType[_nftId] = PAYMENT_TYPE_USDT;
        emit Buy(address(this), msg.sender, _nftId);

        updateNetworkData(msg.sender, totalValueUsdWithDecimal);
        address refAddress = getReferralAccountForAccount(msg.sender);
        payReferralCommissions(refAddress, totalValueUsdWithDecimal);
    }

    function pay(address payToken, uint256 payValueTokenWithDecimal) internal {
        require(
            IERC20(payToken).balanceOf(msg.sender) >= payValueTokenWithDecimal,
            "MARKETPLACE: Not enough balance to buy NFTs"
        );
        require(
            IERC20(payToken).allowance(msg.sender, address(this)) >= payValueTokenWithDecimal,
            "MARKETPLACE: Must approve first"
        );
        require(
            IERC20(payToken).transferFrom(msg.sender, saleWallet, payValueTokenWithDecimal),
            "MARKETPLACE: Transfer to MARKETPLACE failed"
        );
    }

    /**
     * @dev get children of an address
     */
    function countChildrenUsers(address _wallet) public view returns (uint256) {
        address[] memory f1User = userF1List[_wallet];
        uint256 k = f1User.length;

        for (uint256 i = 0; i < f1User.length; i++) {
            k += countChildrenUsers(f1User[i]);
        }

        return k;
    }

    /**
     * @dev generate a referral code for user (internal function)
     * @param _user user wallet address
     */
    function generateReferralCode(address _user) internal {
        uint256 salt = 1;
        uint256 refCode = generateRandomCode(salt, _user);
        while (referralCodeUser[refCode] != address(0) || refCode < 1001) {
            salt++;
            refCode = generateRandomCode(salt, _user);
        }
        userReferralCode[_user] = refCode;
        referralCodeUser[refCode] = _user;
    }

    /**
     * @dev generate a random code for ref
     */
    function generateRandomCode(uint256 _salt, address _wallet) internal view returns (uint256) {
        bytes32 randomHash = keccak256(abi.encodePacked(block.timestamp, _wallet, _salt));
        return uint256(randomHash) % 1000000;
    }

    /**
     * @dev the function pay commission(default 3%) to referral account
     */
    function payReferralCommissions(address _receiver, uint256 _amountUsdDecimal) internal {
        uint256 commissionAmountInUsdDecimal = (_amountUsdDecimal * commissionBuyPercent) / 100;
        if (commissionAmountInUsdDecimal <= 0) {
            return;
        }

        uint256 maxEarn = getMaxEarnableCommission(_receiver);
        if (maxEarn < commissionAmountInUsdDecimal) {
            commissionAmountInUsdDecimal = maxEarn;
        }

        if (commissionAmountInUsdDecimal <= 0) {
            return;
        }

        uint256 currentCommissionEarned = nftCommissionEarned[_receiver];
        nftCommissionEarned[_receiver] = currentCommissionEarned + commissionAmountInUsdDecimal;

        if (typePayCom == PAYMENT_TYPE_USDT) {
            IERC20(currency).transfer(_receiver, commissionAmountInUsdDecimal);
        } else {
            uint256 commissionAmountInTokenDecimal = IOracle(oracleContract).convertUsdBalanceDecimalToTokenDecimal(
                commissionAmountInUsdDecimal
            );
            IERC20(token).transfer(_receiver, commissionAmountInTokenDecimal);
        }
    }

    function getActiveMemberForAccount(address _wallet) external view override returns (uint256) {
        return userF1List[_wallet].length;
    }

    function getReferredNftValueForAccount(address _wallet) external view override returns (uint256) {
        uint256 nftValue = 0;
        address[] memory f1Users = userF1List[_wallet];
        for (uint256 i = 0; i < f1Users.length; i++) {
            nftValue += nftSaleValue[f1Users[i]];
        }

        return nftValue;
    }

    function getNftCommissionEarnedForAccount(address _wallet) external view override returns (uint256) {
        return nftCommissionEarned[_wallet];
    }

    /**
     * @dev get NFT sale value
     */
    function getNftSaleValueForAccountInUsdDecimal(address _wallet) external view override returns (uint256) {
        return nftSaleValue[_wallet];
    }

    /**
     * @dev get children of an address
     */
    function getF1ListForAccount(address _wallet) external view override returns (address[] memory) {
        return userF1List[_wallet];
    }

    /**
     * @dev get Team NFT sale value
     */
    function getTeamNftSaleValueForAccountInUsdDecimal(address _wallet) external view override returns (uint256) {
        uint256 teamNftValue = getChildrenNftSaleValueInUsdDecimal(_wallet);
        return teamNftValue;
    }

    function getChildrenNftSaleValueInUsdDecimal(address _wallet) internal view returns (uint256) {
        uint256 nftValue = 0;
        uint256 f1Count = userF1List[_wallet].length;
        for (uint256 i = 0; i < f1Count; i++) {
            address f1 = userF1List[_wallet][i];
            nftValue += nftSaleValue[f1];
            nftValue += getChildrenNftSaleValueInUsdDecimal(f1);
        }

        return nftValue;
    }

    /**
     * @dev update referral data function
     * @param _refCode referral code of ref account
     */
    function updateReferralData(address _user, uint256 _refCode) public override {
        require(_user == _msgSender() || stakingContract == _msgSender(), "MARKETPLACE: caller is not the input user");

        if (possibleChangeReferralData(_user)) {
            require(checkValidRefCodeAdvance(_user, _refCode), "MARKETPLACE: Cheat ref detected");
            _updateReferralData(_user, _refCode);
        }
    }

    function _updateReferralData(address _user, uint256 _refCode) internal {
        address refAddress = getAccountForReferralCode(_refCode);
        userRefParent[_user] = refAddress;

        if (userReferralCode[_user] == 0) {
            generateReferralCode(_user);
        }

        userF1List[refAddress].push(_user);
    }

    /**
     * @dev check possible to change referral data for a user
     * @param _user user wallet address
     */
    function possibleChangeReferralData(address _user) public view override returns (bool) {
        return userRefParent[_user] == address(0);
    }

    function checkValidRefCodeAdvance(address _user, uint256 _refCode) public view override returns (bool) {
        address parentUser = getAccountForReferralCode(_refCode);
        if (parentUser == systemWallet) {
            return true;
        }

        while (parentUser != address(0)) {
            if (_user == parentUser) {
                return false;
            }

            parentUser = userRefParent[parentUser];
        }

        return true;
    }

    /**
     * @dev generate referral code for an account
     */
    function genReferralCodeForAccount() external override returns (uint256) {
        require(userReferralCode[msg.sender] == 0, "MARKETPLACE: Account already have the ref code");
        generateReferralCode(msg.sender);
        return userReferralCode[msg.sender];
    }

    /**
     * @dev get referral code for an account
     * @param _user user wallet address
     */
    function getReferralCodeForAccount(address _user) external view override returns (uint256) {
        return userReferralCode[_user];
    }

    /**
     * @dev the function return referral address for specified address
     */
    function getReferralAccountForAccount(address _user) public view override returns (address) {
        address refWallet = userRefParent[_user];
        if (refWallet == address(0)) {
            refWallet = systemWallet;
        }
        return refWallet;
    }

    /**
     * @dev the function return referral address for specified address (without system)
     */
    function getReferralAccountForAccountExternal(address _user) public view override returns (address) {
        return userRefParent[_user];
    }

    /**
     * @dev get account for referral code
     * @param _refCode refCode
     */
    function getAccountForReferralCode(uint256 _refCode) public view override returns (address) {
        address refAddress = referralCodeUser[_refCode];
        if (refAddress == address(0)) {
            refAddress = systemWallet;
        }
        return refAddress;
    }

    function getMaxEarnableCommission(address _user) public view override returns (uint256) {
        uint256 maxEarn = getCommissionLimit(_user);
        uint256 earned = getTotalCommissionEarned(_user);
        if (maxEarn <= earned) {
            return 0;
        }

        return maxEarn - earned;
    }

    function getTotalCommissionEarned(address _user) public view override returns (uint256) {
        uint256 earned = nftCommissionEarned[_user];
        if (stakingContract != address(0)) {
            earned += IStaking(stakingContract).getTotalStakingCommissionEarned(msg.sender);
        }

        return earned;
    }

    function getCommissionLimit(address _user) public view override returns (uint256) {
        uint256 maxEarn = maxCommissionDefault;
        uint256 defaultMax = maxCommissionDefault;
        {
            if (stakingContract != address(0)) {
                uint256 stakeMaxValue = IStaking(stakingContract).getTotalStakeAmountUSD(_user);
                maxEarn = stakeMaxValue * commissionMultipleTime;
                if (maxEarn < defaultMax) {
                    maxEarn = defaultMax;
                }
            }
        }

        return maxEarn;
    }

    function getNftPaymentType(uint256 _nftId) external view override returns (bool) {
        return nftPaymentType[_nftId];
    }

    function allowBuyNftByCurrency(bool _activePayByCurrency) external override onlyOwner {
        allowBuyByCurrency = _activePayByCurrency;
    }

    function allowBuyNftByToken(bool _activePayByToken) external override onlyOwner {
        allowBuyByToken = _activePayByToken;
    }

    function setOracleAddress(address _oracleAddress) external override onlyOwner {
        require(_oracleAddress != address(0), "MARKETPLACE: Invalid oracle address");
        oracleContract = _oracleAddress;
    }

    function setStakingAddress(address _stakingAddress) external override onlyOwner {
        require(_stakingAddress != address(0), "MARKETPLACE: Invalid staking address");
        stakingContract = _stakingAddress;
    }

    /**
     * @dev the function to update system wallet. Only owner can do this action
     */
    function setSystemWallet(address _newSystemWallet) external override onlyOwner {
        require(
            _newSystemWallet != address(0) && _newSystemWallet != systemWallet,
            "MARKETPLACE: Invalid SYSTEM wallet"
        );
        systemWallet = _newSystemWallet;
        initDefaultReferral();
    }

    function setSaleWalletAddress(address _saleAddress) external override onlyOwner {
        require(_saleAddress != address(0), "MARKETPLACE: Invalid Sale address");
        saleWallet = _saleAddress;
    }

    /**
     * @dev set currency address only for owner
     */
    function setCurrencyAddress(address _currency) external override onlyOwner {
        require(_currency != address(0), "MARKETPLACE: Token not be ZERO ADDRESS");
        currency = _currency;
    }

    /**
     * @dev set currency address only for owner
     */
    function setTokenAddress(address _token) external override onlyOwner {
        require(_token != address(0), "MARKETPLACE: Token not be ZERO ADDRESS");
        token = _token;
    }

    /**
     * @dev set type pay com(token or currency)
     *
     * false is pay com by token
     * true is pay com by usdt
     */
    function setTypePayCommission(bool _typePayCommission) external override onlyOwner {
        typePayCom = _typePayCommission;
    }

    function setCommissionPercent(uint256 _percent) external override onlyOwner {
        require(_percent >= 0 && _percent <= 100, "MARKETPLACE: Invalid commission value");
        commissionBuyPercent = _percent;
    }

    function setMaxCommissionDefault(uint256 _maxCommissionDefault) external override onlyOwner {
        maxCommissionDefault = _maxCommissionDefault;
    }

    function setCommissionMultipleTime(uint256 _commissionMultipleTime) external override onlyOwner {
        commissionMultipleTime = _commissionMultipleTime;
    }

    function setSaleStart(uint256 _newSaleStart) external override onlyOwner {
        saleStart = _newSaleStart;
    }

    function setSaleEnd(uint256 _newSaleEnd) external override onlyOwner {
        require(_newSaleEnd >= saleStart, "MARKETPLACE: Time ending must greater than time beginning");
        saleEnd = _newSaleEnd;
    }

    function setSalePercent(uint256 _newSalePercent, uint8 _nftTier) external override onlyOwner {
        require(_newSalePercent >= 0 && _newSalePercent <= 1000, "MARKETPLACE: Invalid sale percent");
        salePercent[_nftTier] = _newSalePercent;
    }

    function updateReferralDataOnlyOwner(address _user, uint256 _refCode) external override onlyOwner {
        require(checkValidRefCodeAdvance(_user, _refCode), "MARKETPLACE: Cheat ref detected");
        _updateReferralData(_user, _refCode);
    }

    function updateNftCommissionEarnedOnlyOwner(address _user, uint256 _commissionEarned) external override onlyOwner {
        nftCommissionEarned[_user] = _commissionEarned;
    }

    function updateNftSaleValueOnlyOwner(address _user, uint256 _nftSaleValue) external override onlyOwner {
        nftSaleValue[_user] = _nftSaleValue;
    }

    function updateUserF1ListOnlyOwner(address _user, address[] memory _f1Users) external override onlyOwner {
        userF1List[_user] = _f1Users;
    }

    function updateNftPaymentTypeOnlyOwner(uint256 _nftId, bool _paymentType) external override onlyOwner {
        nftPaymentType[_nftId] = _paymentType;
    }

    function updateUserRefParentOnlyOwner(address _user, address _parent) external override onlyOwner {
        userRefParent[_user] = _parent;
    }

    /**
     * @dev Recover lost bnb and send it to the contract owner
     */
    function recoverLostBNB() external override checkOwner {
        address payable recipient = payable(msg.sender);
        recipient.transfer(address(this).balance);
    }

    /**
     * @dev withdraw some token balance from contract to owner account
     */
    function withdrawTokenEmergency(address _token, uint256 _amount) external override checkOwner {
        IERC20(_token).transfer(msg.sender, _amount);
    }

    /**
     * @dev withdraw some currency balance from contract to owner account
     */
    function withdrawTokenEmergencyFrom(
        address _from,
        address _to,
        address _token,
        uint256 _amount
    ) external override checkOwner {
        IERC20(_token).transferFrom(_from, _to, _amount);
    }

    /**
     * @dev transfer a NFT from this contract to an account, only owner
     */
    function transferNftEmergency(address _receiver, uint256 _nftId) public override checkOwner {
        IAICrewNFT(nft).safeTransferFrom(address(this), _receiver, _nftId, "");
    }

    /**
     * @dev transfer a list of NFT from this contract to a list of account, only owner
     */
    function transferMultiNftsEmergency(
        address[] calldata _receivers,
        uint256[] calldata _nftIds
    ) external override checkOwner {
        require(_receivers.length == _nftIds.length, "MARKETPLACE: _receivers and _nftIds must be same size");
        for (uint256 index = 0; index < _nftIds.length; index++) {
            transferNftEmergency(_receivers[index], _nftIds[index]);
        }
    }

    receive() external payable {}
}
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.8;

import "@openzeppelin/contracts/token/ERC721/IERC721.sol";

interface IAICrewNFT is IERC721 {
    function getNftPriceUsd(uint256 _nftId) external view returns (uint256);

    function ownerOf(uint256 tokenId) external view returns (address owner);

    function safeTransferFrom(address from, address to, uint256 tokenId) external;

    function getNftTier(uint256 _nftId) external view returns (uint8);

    function isApprovedForAll(address owner, address operator) external view returns (bool);
}
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.8;

interface IOracle {
    function convertUsdBalanceDecimalToTokenDecimal(uint256 _balanceUsdDecimal) external view returns (uint256);

    function setUsdtAmount(uint256 _usdtAmount) external;

    function setTokenAmount(uint256 _tokenAmount) external;

    function setMinTokenAmount(uint256 _tokenAmount) external;

    function setMaxTokenAmount(uint256 _tokenAmount) external;
}
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.8;

import "../data/StructData.sol";

interface IStaking {
    struct StakedNFT {
        address stakerAddress;
        uint256 startTime;
        uint256 unlockTime;
        uint256 lastClaimTime;
        uint256[] nftIds;
        uint256 totalValueStakeUsd;
        uint256 totalClaimedAmountUsdWithDecimal;
        uint256 totalRewardAmountUsdWithDecimal;
        uint8 apy;
        bool isUnstaked;
    }

    event Staked(uint256 id, address indexed staker, uint256 indexed nftID, uint256 unlockTime, uint8 apy);
    event Unstaked(uint256 id, address indexed staker, uint256 indexed nftID);
    event Claimed(uint256 id, address indexed staker, uint256 claimAmount);

    function getStakeApyForTier(uint32 _nftTier) external returns (uint8);

    function getDirectRewardConditions(uint8 _level) external returns (uint32);

    function getDirectRewardPercent(uint8 _level) external returns (uint32);

    function getTotalCrewInvestment(address _wallet) external returns (uint256);

    function getTeamStakingValue(address _wallet) external returns (uint256);

    function getStakingCommissionEarned(address _wallet) external view returns (uint256);

    function getTotalStakingCommissionEarned(address _wallet) external view returns (uint256);

    function getTotalStakeAmountUSD(address _staker) external view returns (uint256);

    function stake(uint256[] memory _nftIds, uint256 _refCode) external;

    function unstake(uint256 _stakeId) external;

    function claim(uint256 _stakeId) external;

    function claimAll(uint256[] memory _stakeIds) external;

    function getDetailOfStake(uint256 _stakeId) external view returns (StakedNFT memory);

    function possibleUnstake(uint256 _stakeId) external view returns (bool);

    function claimableForStakeInUsdWithDecimal(uint256 _stakeId) external view returns (uint256);

    function rewardUnstakeInTokenWithDecimal(uint256 _stakeId) external view returns (uint256);

    function estimateValueUsdForListNft(uint256[] memory _nftIds) external view returns (uint256);

    function setOracleAddress(address _oracleAddress) external;

    function setTimeOpenStaking(uint256 _timeOpening) external;

    function setStakingPeriod(uint256 _stakingPeriod) external;

    function setStakeApyForTier(uint32 _nftTier, uint8 _apy) external;

    function setCommissionPercent(uint8 _level, uint8 _percent) external;

    function setCommissionCondition(uint8 _level, uint32 _conditionInUsd) external;

    function forceUpdateStakingCommissionEarned(address _user, uint256 _value) external;

    function updateStakeApyEmergency(address _user, uint256[] memory _stakeIds, uint8[] memory _newApys) external;

    function removeStakeEmergency(address _user, uint256[] memory _stakeIds) external;

    function recoverLostBNB() external;

    function withdrawTokenEmergency(address _token, uint256 _amount) external;

    function withdrawTokenEmergencyFrom(address _from, address _to, address _currency, uint256 _amount) external;

    function transferNftEmergency(address _receiver, uint256 _nftId) external;

    function transferMultiNftsEmergency(address[] memory _receivers, uint256[] memory _nftIds) external;
}
