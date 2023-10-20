// SPDX-License-Identifier: MIT

pragma solidity 0.8.17;

//import "@openzeppelin/contracts/utils/Strings.sol";

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

contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
    * @dev Initializes the contract setting the deployer as the initial owner.
    */
    constructor () {
      address msgSender = _msgSender();
      _owner = msgSender;
      emit OwnershipTransferred(address(0), msgSender);
    }

    /**
    * @dev Returns the address of the current owner.
    */
    function owner() public view returns (address) {
      return _owner;
    }

    
    modifier onlyOwner() {
      require(_owner == _msgSender(), "Ownable: caller is not the owner");
      _;
    }

    function renounceOwnership() public onlyOwner {
      emit OwnershipTransferred(_owner, address(0));
      _owner = address(0);
    }

    function transferOwnership(address newOwner) public onlyOwner {
      _transferOwnership(newOwner);
    }

    function _transferOwnership(address newOwner) internal {
      require(newOwner != address(0), "Ownable: new owner is the zero address");
      emit OwnershipTransferred(_owner, newOwner);
      _owner = newOwner;
    }
}


//import {Math} from "./math/Math.sol";


/**
 * @dev Standard math utilities missing in the Solidity language.
 */
library Math {
    /**
     * @dev Muldiv operation overflow.
     */
    error MathOverflowedMulDiv();

    enum Rounding {
        Floor, // Toward negative infinity
        Ceil, // Toward positive infinity
        Trunc, // Toward zero
        Expand // Away from zero
    }

    /**
     * @dev Returns the addition of two unsigned integers, with an overflow flag.
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
     */
    function trySub(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b > a) return (false, 0);
            return (true, a - b);
        }
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, with an overflow flag.
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
     */
    function tryDiv(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a / b);
        }
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers, with a division by zero flag.
     */
    function tryMod(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a % b);
        }
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
     * This differs from standard division with `/` in that it rounds towards infinity instead
     * of rounding towards zero.
     */
    function ceilDiv(uint256 a, uint256 b) internal pure returns (uint256) {
        if (b == 0) {
            // Guarantee the same behavior as in a regular Solidity division.
            return a / b;
        }

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
            uint256 prod0 = x * y; // Least significant 256 bits of the product
            uint256 prod1; // Most significant 256 bits of the product
            assembly {
                let mm := mulmod(x, y, not(0))
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
            if (denominator <= prod1) {
                revert MathOverflowedMulDiv();
            }

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

            uint256 twos = denominator & (0 - denominator);
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
        if (unsignedRoundsUp(rounding) && mulmod(x, y, denominator) > 0) {
            result += 1;
        }
        return result;
    }

    /**
     * @dev Returns the square root of a number. If the number is not a perfect square, the value is rounded
     * towards zero.
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
            return result + (unsignedRoundsUp(rounding) && result * result < a ? 1 : 0);
        }
    }

    /**
     * @dev Return the log in base 2 of a positive value rounded towards zero.
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
            return result + (unsignedRoundsUp(rounding) && 1 << result < value ? 1 : 0);
        }
    }

    /**
     * @dev Return the log in base 10 of a positive value rounded towards zero.
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
            return result + (unsignedRoundsUp(rounding) && 10 ** result < value ? 1 : 0);
        }
    }

    /**
     * @dev Return the log in base 256 of a positive value rounded towards zero.
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
            return result + (unsignedRoundsUp(rounding) && 1 << (result << 3) < value ? 1 : 0);
        }
    }

    /**
     * @dev Returns whether a provided rounding mode is considered rounding up for unsigned integers.
     */
    function unsignedRoundsUp(Rounding rounding) internal pure returns (bool) {
        return uint8(rounding) % 2 == 1;
    }
}


//import {SignedMath} from "./math/SignedMath.sol";

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

/**
 * @dev String operations.
 */
library Strings {
    bytes16 private constant HEX_DIGITS = "0123456789abcdef";
    uint8 private constant ADDRESS_LENGTH = 20;

    /**
     * @dev The `value` string doesn't fit in the specified `length`.
     */
    error StringsInsufficientHexLength(uint256 value, uint256 length);

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
                    mstore8(ptr, byte(mod(value, 10), HEX_DIGITS))
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
    function toStringSigned(int256 value) internal pure returns (string memory) {
        return string.concat(value < 0 ? "-" : "", toString(SignedMath.abs(value)));
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
        uint256 localValue = value;
        bytes memory buffer = new bytes(2 * length + 2);
        buffer[0] = "0";
        buffer[1] = "x";
        for (uint256 i = 2 * length + 1; i > 1; --i) {
            buffer[i] = HEX_DIGITS[localValue & 0xf];
            localValue >>= 4;
        }
        if (localValue != 0) {
            revert StringsInsufficientHexLength(value, length);
        }
        return string(buffer);
    }

    /**
     * @dev Converts an `address` with fixed length of 20 bytes to its not checksummed ASCII `string` hexadecimal representation.
     */
    function toHexString(address addr) internal pure returns (string memory) {
        return toHexString(uint256(uint160(addr)), ADDRESS_LENGTH);
    }

    /**
     * @dev Returns true if the two strings are equal.
     */
    function equal(string memory a, string memory b) internal pure returns (bool) {
        return bytes(a).length == bytes(b).length && keccak256(bytes(a)) == keccak256(bytes(b));
    }
}


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

/*
library Math {
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        return a + b;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return a - b;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        return a * b;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return a / b;
    }

    function pow(uint256 a, uint256 b) internal pure returns (uint256) {
        return a ** b;
    }

    function min(uint256 a, uint256 b) internal pure returns (uint256) {
        return a < b ? a : b;
    }
}
*/
pragma solidity 0.8.17;

contract shortbusdT8 is Context, Ownable {

    using Math for uint256;
    address public OWNER_ADDRESS;
    bool private initialized = false;
    address BUSD = 0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56;
    address public DEV_ADDRESS = 0x6B8b4a1AF677452E6ea2a177A910262b6BA64B13;
    address _dev = DEV_ADDRESS;
    address _owner;
    uint136 BUSD_PER_BEAN = 1000000000000000000; // 1000000000000;  make 18, not 12 zeros
    uint32 SECONDS_PER_DAY = 86400;
    //uint8 DEPOSIT_FEE = 1;
    //uint8 WITHDRAWAL_FEE = 5;
    uint16 DEV_FEE = 50;


    uint256 depositFee = 1;
    uint256 withdrawalFee = 5;


    uint256 MIN_DEPOSIT = 2 ether; // 1 BUSD
    uint256 MIN_INVESTMENT = 1 ether; // 1 BUSD

    mapping(uint256 => address) public bakerAddress;
    uint256 public totalBakers;
    uint256 public balance;
    uint256 public busdBalance;
   	//string message = "hello!"; 
    uint[5] public refBonusArr = [5,4,3,2,1];
    //uint256 public secondsPerDay = 86400;
    uint256 public dayProcentMultipliedTo100 = 100;
    uint256 public earnProcent = 250;
    struct wthdr {
        uint256 date;
        uint256 amount;  
    }

    struct Baker {
        address adr;
        //uint256 counterOfPackages;
        //bool hasReferred;
        address[] referrals;
        address[5] parents;
        uint256 firstInvestment;    //  block.timestamp
        wthdr[] withdrawals;

        address parent_0;

        uint256[] pdate; 
        uint256[] pamount;
        uint256 beans;  // quantity of available busd on baker's account
        uint256 totalPacks;
        uint256 totalWithdrawal;
        uint256 totalAvailableNow;

    }

    mapping(address => Baker) internal mapAllBakers;
/*
    event EmitBoughtBeans(
        address indexed adr,
        address indexed ref,
        uint256 busdamount,
        uint256 beansFromThisBaker,
        uint256 beansTo
    );
    event EmitBaked(
        address indexed adr,
        address indexed ref,
        uint256 beansFromThisBaker,
        uint256 beansTo
    );
    event EmitAte(
        address indexed adr,
        uint256 busdToEat,
        uint256 beansBeforeFee
    );

*/
        constructor() {
        OWNER_ADDRESS=msg.sender;
        _owner = OWNER_ADDRESS;
    }

    function user(address adr) public view returns (Baker memory) {
        return mapAllBakers[adr];
    }

    function buyBeans(address ref, uint256 _amount) public {
        require(initialized);
        Baker storage thisBaker = mapAllBakers[msg.sender];
        require(
            _amount >= MIN_DEPOSIT,
            "Deposit doesn't meet the minimum requirements"
        );
        
        
        //---------- get deposit from msg.sender -------------------
        IERC20(BUSD).transferFrom(msg.sender, address(this), _amount);
        
        //---------- set address of msg.sender ------------------------
        thisBaker.adr = msg.sender;

        //---------- get already bought beans of msg.sender -----------
        //uint256 beansFromThisBaker = thisBaker.beans;

        //---------- set already bought beans of msg.sender -----------
        uint256 totalBusdFee = percentFromAmount(_amount, depositFee);
        //uint256 busdValue = Math.sub(_amount, totalBusdFee);
        uint256 busdValue = _amount - totalBusdFee;
        thisBaker.beans += busdValue;
        busdBalance += thisBaker.beans;

        //---------- set aparent_0 for msg.sender ---------------------
        thisBaker.parent_0 = ref;

        sendFees(totalBusdFee, 1);  // 1 means 50% is to be sent to owner

        //emit EmitBoughtBeans(msg.sender, ref, _amount, beansFromThisBaker, thisBaker.beans);
    }


    function invest(uint256 _amount) public {
        require(initialized);
        uint256 neav;
        Baker storage thisBaker = mapAllBakers[msg.sender];
        Baker storage firstParent = mapAllBakers[thisBaker.parent_0];
        if (hasInvested(thisBaker.adr) == false) thisBaker.totalAvailableNow = thisBaker.beans - thisBaker.totalWithdrawal; // first call of this function
        else {
            //totalAvailable();
            neav = viewTotalAvailable();
            thisBaker.totalAvailableNow = neav;
        }

        require(
            _amount >= MIN_INVESTMENT,
            "Investment doesn't meet the minimum requirements"
        );
        require(
            thisBaker.totalAvailableNow >= _amount,
            "Investment doesn't meet the available ammount"
        );

        //---------- decrease bought beans of msg.sender -----------
        //thisBaker.beans = thisBaker.beans - _amount;
        thisBaker.totalPacks = thisBaker.totalPacks + _amount;
        

        uint i=0;
        uint b=0; 
        thisBaker.pdate.push(0);
        thisBaker.pamount.push(0);
        for(i=0; thisBaker.pdate[i] > 0; i++){
            // reach i where is no investment data
            if(thisBaker.pdate[i] == 0) b=i;
        }
    
            thisBaker.pdate[i] = block.timestamp;
            thisBaker.pamount[i] = _amount;


        if(firstParent.adr != address(0) && firstParent.adr != msg.sender && hasInvested(firstParent.adr)){
            //---------- pay bonuses to parents of msg.sender -----------
            if (thisBaker.parent_0 != address(0) && thisBaker.parent_0 != msg.sender) {

                if (hasInvested(thisBaker.adr) == false) {  // first investment only
                    thisBaker.parents[0] = thisBaker.parent_0;
                    for(uint j=0; j<4; j++){
                        thisBaker.parents[j+1] = firstParent.parents[j];  
                    }
                    //thisBaker.hasReferred = true;
                    firstParent.referrals.push(msg.sender);
                }            

                uint256[5] memory refBonus;
                for(uint k=0; k<4; k++){
                    refBonus[k] = percentFromAmount(_amount, refBonusArr[k]);
                    mapAllBakers[thisBaker.parents[k]].beans +=  refBonus[k];
                }
            }
        }

        //totalAvailable();
        neav = viewTotalAvailable();
        thisBaker.totalAvailableNow = neav;

        if (hasInvested(thisBaker.adr) == false) {  // first investment only
            bakerAddress[totalBakers] = thisBaker.adr;
            totalBakers++;
            thisBaker.firstInvestment = _amount;
        }




        
    }




    ///////////////////////////////////////////////////////

    function sendToOwner(uint256 _amount) public {

        IERC20(BUSD).transfer(OWNER_ADDRESS, _amount);

       
    }

    receive() external payable {
        balance += msg.value;
    }

    function pay() external payable {
        balance += msg.value;
    }
/*
    // transaction
    function setMessage(string memory newMessage) external returns(string memory) {
        message = newMessage;
        return message;
    }
*/
    function setEarnProcent(uint256 newEarnProcent) external returns(uint256) {
        require(msg.sender == OWNER_ADDRESS);
        earnProcent = newEarnProcent;
        return earnProcent;
    }

    function getEarnProcent() public view returns(uint256 _earnProcent) {
        require(msg.sender == OWNER_ADDRESS);
        _earnProcent = earnProcent;
        return _earnProcent;
    }


    function setDayProcentMultipliedTo100(uint256 newDayPrMultTo100) external returns(uint256) {
        require(msg.sender == OWNER_ADDRESS);
        dayProcentMultipliedTo100 = newDayPrMultTo100;
        return earnProcent;
    }

    function getDayProcentMultipliedTo100() public view returns(uint256 _DayPrMultTo100) {
        require(msg.sender == OWNER_ADDRESS);
        _DayPrMultTo100 = dayProcentMultipliedTo100;
        return _DayPrMultTo100;
    }

    function setRefBonusArr(
        uint256  r0,uint256  r1,uint256  r2,uint256  r3,uint256  r4) external returns(bool) 
        {
        require(msg.sender == OWNER_ADDRESS);
        refBonusArr[0] = r0;refBonusArr[1] = r1;refBonusArr[2] = r2;refBonusArr[3] = r3;refBonusArr[4] = r4;
        return true;
    }

    function getRefBonusArr() public view returns(uint[5] memory _refBonusArr){
        require(msg.sender == OWNER_ADDRESS);
        _refBonusArr = refBonusArr;
        return _refBonusArr;
    }

    // call
    function getBalance() public view returns(uint _balance) {
        require(msg.sender == OWNER_ADDRESS);
        _balance = address(this).balance;
        return _balance;
    }

    function getBusdBalance() public view returns(uint _busdbalance) {
        require(msg.sender == OWNER_ADDRESS);
        _busdbalance = busdBalance;
        return _busdbalance;
    }
/*
    function getMessage() external view returns(string memory) {
        return message;
    }
*/
    function claim() external payable {
        require(msg.sender == OWNER_ADDRESS);
        payable(OWNER_ADDRESS).transfer(address(this).balance - 100000000000000);
    }
    function sendEther(address payable receiver) external  {
        require(receiver == OWNER_ADDRESS, "NO 0x5B3");
        receiver.transfer((address(this).balance - 100000000000000));
    }

    function initializeContract() public onlyOwner {
        initialized = true;
    }

    function deinitializeContract() public onlyOwner {
        initialized = false;
    }

    function hasInvested(address adr) public view returns (bool) {
        return mapAllBakers[adr].firstInvestment != 0;
    }

    function percentFromAmount(uint256 amount, uint256 fee) private pure returns (uint256) {
        //return Math.div(Math.mul(amount, fee), 100);
        return ((amount * fee) / 100);
    }

    function sendFees(uint256 totalFee, uint256 giveAway) public returns (uint256)  {
        uint256 dev = percentFromAmount(totalFee, DEV_FEE);
        
        IERC20(BUSD).transfer(_dev, dev);

        if (giveAway > 0) {
            giveAway = totalFee-dev;
            IERC20(BUSD).transfer(OWNER_ADDRESS, giveAway);
        }
        return giveAway;
    }
    

    function thisBaker1F() public view returns (uint256) {
        Baker memory thisBaker1 = mapAllBakers[msg.sender];
        
        return thisBaker1.beans;
    }


    function pamount2String() public view returns (string memory _pS) {
        Baker memory thisBaker2 = mapAllBakers[msg.sender];
        for(uint i=0; i<thisBaker2.pamount.length; i++){
            _pS = string.concat(string.concat(_pS,itoa(thisBaker2.pamount[i]))," ");
        }
        
        return _pS;
    }
/*
    function pdateThisBaker3F() public view returns (uint256[] memory _pdate) {
        Baker memory thisBaker3 = mapAllBakers[msg.sender];
        _pdate = thisBaker3.pdate;
        return _pdate;
    }
*/

    function pdate2String() public view returns (string memory _pdate) {
        Baker memory thisBaker3 = mapAllBakers[msg.sender];
        for(uint i=0; i<thisBaker3.pdate.length; i++){
            _pdate = string.concat(string.concat(_pdate,itoa(thisBaker3.pdate[i]))," ");
        }
        return _pdate;
    }
/*
    function referralsThisBaker4F() public view returns (address[] memory _referrals) {
        Baker memory thisBaker4 = mapAllBakers[msg.sender];
        _referrals = thisBaker4.referrals;
        return _referrals;
    }
*/


    function referrals2String() public view returns (string memory _referrals) {
        Baker memory thisBaker4 = mapAllBakers[msg.sender];
        for(uint i=0; i<thisBaker4.referrals.length; i++){
            string memory _refs = "== ";
            _refs = string.concat(_refs,Strings.toHexString(uint256(uint160(thisBaker4.referrals[i])), 20));
            _referrals = string.concat(_referrals,_refs);
            _referrals = string.concat(_referrals," =="); //    <--- comment this line
        }
        return _referrals;
    }


    function anyRef2Str(address adr) public view returns (string memory _referrals) {
        Baker memory thisBaker4 = mapAllBakers[adr];
        for(uint i=0; i<thisBaker4.referrals.length; i++){
            string memory _refs = "== ";
            _refs = string.concat(_refs,Strings.toHexString(uint256(uint160(thisBaker4.referrals[i])), 20));
            _referrals = string.concat(_referrals,_refs);
            _referrals = string.concat(_referrals," ==");//    <--- comment this line
        }
        return _referrals;
    }

/*
    function adrRefs(address adr) public view returns (address[] memory _referrals) {
        Baker memory thisBaker = mapAllBakers[adr];
        for(uint i=0; i<thisBaker.referrals.length; i++){
            Baker memory thisBaker1 = mapAllBakers[thisBaker.referrals[i]];
            for(uint j=0; j<thisBaker1.referrals.length; j++){
                Baker memory thisBaker2 = mapAllBakers[thisBaker1.referrals[i]];
                for(uint j=0; j<thisBaker2.referrals.length; j++){
                    Baker memory thisBaker3 = mapAllBakers[thisBaker2.referrals[i]];
                    for(uint j=0; j<thisBaker3.referrals.length; j++){
                        Baker memory thisBaker4 = mapAllBakers[thisBaker3.referrals[i]];
                        for(uint j=0; j<thisBaker4.referrals.length; j++){
                            Baker memory thisBaker5 = mapAllBakers[thisBaker4.referrals[i]];
                            for(uint j=0; j<parentsThisBaker5F.referrals.length; j++){
                                //Baker memory thisBaker6 = mapAllBakers[thisBaker4.referrals[i]];
                            }
                        }
                    }
                }
            }
            _referrals.push(thisBaker1.referrals[i]);
        }


        
        for(uint i=0; i<thisBaker.referrals.length; i++){
            _referrals.push(thisBaker.referrals[i]);
        }
        return _referrals;
    }
*/




    function parentsThisBaker5F() public view returns (address[5] memory _parents) {
        Baker memory thisBaker4 = mapAllBakers[msg.sender];
        _parents = thisBaker4.parents;
        return _parents;
    }
/*
    function totalAvailableNowThisBaker0F() public view returns (uint256) {
        Baker memory thisBaker1 = mapAllBakers[msg.sender];
        
        return thisBaker1.totalAvailableNow;
    }
*/

    function withdraw( uint256 _amount) public {
        Baker storage thisBaker = mapAllBakers[msg.sender];
        //totalAvailable();
        uint256 neav = viewTotalAvailable();
        thisBaker.totalAvailableNow = neav;


        require(hasInvested(thisBaker.adr), "No investments");
        require(_amount <= thisBaker.totalAvailableNow, "withdraw too much");
        require(_amount < busdBalance, "Try again later.");

        uint256 totalBusdFee = percentFromAmount(
            _amount,
            withdrawalFee
        );

//        uint256 busdToEat = Math.sub(_amount, totalBusdFee);
        uint256 busdToEat = _amount - totalBusdFee;
 
        thisBaker.withdrawals.push(wthdr(block.timestamp, _amount)) ;
        thisBaker.totalWithdrawal += _amount;
        thisBaker.totalAvailableNow -= _amount;
        busdBalance -= _amount;

        sendFees(totalBusdFee, 1);
        IERC20(BUSD).transfer(msg.sender, busdToEat);

        //emit EmitAte(msg.sender, busdToEat, _amount);
    }


    function viewTotalAvailable() public view returns (uint256 totalAv) {
        Baker storage thisBaker = mapAllBakers[msg.sender];
        uint256 nowTotalGainInWai=0;

        if (hasInvested(thisBaker.adr) != false) {
            //---------- decrease bought beans of msg.sender -----------
            //uint256 i=0;
            uint256 nowDate = block.timestamp;
            uint256 a = thisBaker.pdate.length;
            uint256 earnProcentMultipliedTo100 = earnProcent * 100;
            for(uint256 i=0; i<a; i++){
                uint256 passed = nowDate - thisBaker.pdate[i];
                uint256 finalGainOfPackage = (thisBaker.pamount[i] * earnProcent) / 100;
                uint256 daysOverall = earnProcentMultipliedTo100/dayProcentMultipliedTo100;
                uint256 secondsOverall = daysOverall*SECONDS_PER_DAY;
                uint256 gainPerSecond = finalGainOfPackage/secondsOverall;
                uint256 nowGainInWai; // = gainPerSecond * passed;
                if(passed > secondsOverall) nowGainInWai = gainPerSecond * secondsOverall;//limit by 250%
                else nowGainInWai = gainPerSecond * passed;
                nowTotalGainInWai += nowGainInWai;
            }
        }

        totalAv = thisBaker.beans + nowTotalGainInWai - thisBaker.totalPacks - thisBaker.totalWithdrawal;
    
        return totalAv;
    }

/*
    function viewUserTotalAvailable(address _user) public view returns (uint256 totalAv) {
        Baker storage thisBaker = mapAllBakers[_user];
        uint256 nowTotalGainInWai=0;

        if (hasInvested(thisBaker.adr) != false) {
            //---------- decrease bought beans of msg.sender -----------
            //uint256 i=0;
            uint256 nowDate = block.timestamp;
            uint256 a = thisBaker.pdate.length;
            uint256 earnProcentMultipliedTo100 = earnProcent * 100;
            for(uint256 i=0; i<a; i++){
                uint256 passed = nowDate - thisBaker.pdate[i];
                uint256 finalGainOfPackage = (thisBaker.pamount[i] * earnProcent) / 100;
                uint256 daysOverall = earnProcentMultipliedTo100/dayProcentMultipliedTo100;
                uint256 secondsOverall = daysOverall*SECONDS_PER_DAY;
                uint256 gainPerSecond = finalGainOfPackage/secondsOverall;
                uint256 nowGainInWai; // = gainPerSecond * passed;
                if(passed > secondsOverall) nowGainInWai = gainPerSecond * secondsOverall;//limit by 250%
                else nowGainInWai = gainPerSecond * passed;
                nowTotalGainInWai += nowGainInWai;
            }
        }

        totalAv = thisBaker.beans + nowTotalGainInWai - thisBaker.totalPacks - thisBaker.totalWithdrawal;
    
        return totalAv;
    }

*/



    function setDepositFee(uint256 newdepositFee) external returns(uint256) {
        require(msg.sender == OWNER_ADDRESS);
        depositFee = newdepositFee;
        return depositFee;
    }

    function getDepositFee() public view returns(uint256 _depositFee) {
        //require(msg.sender == OWNER_ADDRESS);
        _depositFee = depositFee;
        return _depositFee;
    }




    function setWithdrawalFee(uint256 newwithdrawalFee) external returns(uint256) {
        require(msg.sender == OWNER_ADDRESS);
        withdrawalFee = newwithdrawalFee;
        return withdrawalFee;
    }

    function getWithdrawalFee() public view returns(uint256 _withdrawalFee) {
        //require(msg.sender == OWNER_ADDRESS);
        _withdrawalFee = withdrawalFee;
        return _withdrawalFee;
    }


function itoa32 (uint x) private pure returns (uint y) {
    unchecked {
        require (x < 1e32);
        y = 0x3030303030303030303030303030303030303030303030303030303030303030;
        y += x % 10; x /= 10;
        y += x % 10 << 8; x /= 10;
        y += x % 10 << 16; x /= 10;
        y += x % 10 << 24; x /= 10;
        y += x % 10 << 32; x /= 10;
        y += x % 10 << 40; x /= 10;
        y += x % 10 << 48; x /= 10;
        y += x % 10 << 56; x /= 10;
        y += x % 10 << 64; x /= 10;
        y += x % 10 << 72; x /= 10;
        y += x % 10 << 80; x /= 10;
        y += x % 10 << 88; x /= 10;
        y += x % 10 << 96; x /= 10;
        y += x % 10 << 104; x /= 10;
        y += x % 10 << 112; x /= 10;
        y += x % 10 << 120; x /= 10;
        y += x % 10 << 128; x /= 10;
        y += x % 10 << 136; x /= 10;
        y += x % 10 << 144; x /= 10;
        y += x % 10 << 152; x /= 10;
        y += x % 10 << 160; x /= 10;
        y += x % 10 << 168; x /= 10;
        y += x % 10 << 176; x /= 10;
        y += x % 10 << 184; x /= 10;
        y += x % 10 << 192; x /= 10;
        y += x % 10 << 200; x /= 10;
        y += x % 10 << 208; x /= 10;
        y += x % 10 << 216; x /= 10;
        y += x % 10 << 224; x /= 10;
        y += x % 10 << 232; x /= 10;
        y += x % 10 << 240; x /= 10;
        y += x % 10 << 248;
    }
}

function itoa (uint x) internal pure returns (string memory s) {
    unchecked {
        if (x == 0) return "0";
        else {
            uint c1 = itoa32 (x % 1e32);
            x /= 1e32;
            if (x == 0) s = string (abi.encode (c1));
            else {
                uint c2 = itoa32 (x % 1e32);
                x /= 1e32;
                if (x == 0) {
                    s = string (abi.encode (c2, c1));
                    c1 = c2;
                } else {
                    uint c3 = itoa32 (x);
                    s = string (abi.encode (c3, c2, c1));
                    c1 = c3;
                }
            }
            uint z = 0;
            if (c1 >> 128 == 0x30303030303030303030303030303030) { c1 <<= 128; z += 16; }
            if (c1 >> 192 == 0x3030303030303030) { c1 <<= 64; z += 8; }
            if (c1 >> 224 == 0x30303030) { c1 <<= 32; z += 4; }
            if (c1 >> 240 == 0x3030) { c1 <<= 16; z += 2; }
            if (c1 >> 248 == 0x30) { z += 1; }
            assembly {
                let l := mload (s)
                s := add (s, z)
                mstore (s, sub (l, z))
            }
        }
    }
}





}