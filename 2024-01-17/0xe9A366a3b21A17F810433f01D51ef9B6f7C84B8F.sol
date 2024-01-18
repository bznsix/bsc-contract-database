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
// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity ^0.8.14;

import {IBrewlabsERC20} from "./interfaces/IBrewlabsERC20.sol";

contract BrewlabsERC20 is IBrewlabsERC20 {
    string public constant name = "Brewswap LP";
    string public constant symbol = "BREWSWAP-LP";
    uint8 public constant decimals = 18;
    uint256 public totalSupply;
    mapping(address => uint256) public balanceOf;
    mapping(address => mapping(address => uint256)) public allowance;

    bytes32 public DOMAIN_SEPARATOR;
    // keccak256("Permit(address owner,address spender,uint256 value,uint256 nonce,uint256 deadline)");
    bytes32 public constant PERMIT_TYPEHASH = 0x6e71edae12b1b97f4d1f60370fef10105fa2faae0126114a169c64845d6126c9;
    mapping(address => uint256) public nonces;

    constructor() {
        uint256 chainId;
        assembly {
            chainId := chainid()
        }
        DOMAIN_SEPARATOR = keccak256(
            abi.encode(
                keccak256("EIP712Domain(string name,string version,uint256 chainId,address verifyingContract)"),
                keccak256(bytes(name)),
                keccak256(bytes("1")),
                chainId,
                address(this)
            )
        );
    }

    function _mint(address to, uint256 value) internal {
        totalSupply = totalSupply + value;
        balanceOf[to] = balanceOf[to] + value;
        emit Transfer(address(0), to, value);
    }

    function _burn(address from, uint256 value) internal {
        balanceOf[from] = balanceOf[from] - value;
        totalSupply = totalSupply - value;
        emit Transfer(from, address(0), value);
    }

    function _approve(address owner, address spender, uint256 value) private {
        require(owner != address(0) && spender != address(0), "Invalid owner or spender address");
        allowance[owner][spender] = value;
        emit Approval(owner, spender, value);
    }

    function _transfer(address from, address to, uint256 value) internal virtual {
        require(from != address(0) && to != address(0), "Invalid from or to address");
        balanceOf[from] = balanceOf[from] - value;
        balanceOf[to] = balanceOf[to] + value;
        emit Transfer(from, to, value);
    }

    function approve(address spender, uint256 value) external returns (bool) {
        _approve(msg.sender, spender, value);
        return true;
    }

    function transfer(address to, uint256 value) external returns (bool) {
        _transfer(msg.sender, to, value);
        return true;
    }

    function transferFrom(address from, address to, uint256 value) external returns (bool) {
        if (allowance[from][msg.sender] != type(uint256).max) {
            allowance[from][msg.sender] = allowance[from][msg.sender] - value;
            emit Approval(from, msg.sender, allowance[from][msg.sender]);
        }
        _transfer(from, to, value);
        return true;
    }

    function permit(address owner, address spender, uint256 value, uint256 deadline, uint8 v, bytes32 r, bytes32 s)
        external
    {
        require(deadline >= block.timestamp, "Brewlabs: EXPIRED");
        bytes32 digest = keccak256(
            abi.encodePacked(
                "\x19\x01",
                DOMAIN_SEPARATOR,
                keccak256(abi.encode(PERMIT_TYPEHASH, owner, spender, value, nonces[owner]++, deadline))
            )
        );
        address recoveredAddress = ecrecover(digest, v, r, s);
        require(recoveredAddress != address(0) && recoveredAddress == owner, "Brewlabs: INVALID_SIGNATURE");
        _approve(owner, spender, value);
    }
}
// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity ^0.8.14;

import {Math} from "@openzeppelin/contracts/utils/math/Math.sol";

import {IERC20} from "./interfaces/IERC20.sol";
import {IBrewlabsFactory} from "./interfaces/IBrewlabsFactory.sol";
import {IBrewlabsCallee} from "./interfaces/IBrewlabsCallee.sol";
import {IBrewlabsNFTDiscountManager} from "./interfaces/IBrewlabsNFTDiscountManager.sol";
import {IBrewlabsSwapFeeManager} from "./interfaces/IBrewlabsSwapFeeManager.sol";

import {UQ112x112} from "./libraries/UQ112x112.sol";
import {BrewlabsERC20} from "./BrewlabsERC20.sol";

contract BrewlabsPair is BrewlabsERC20 {
    using UQ112x112 for uint224;

    uint256 public constant MINIMUM_LIQUIDITY = 10 ** 3;
    bytes4 private constant SELECTOR = bytes4(keccak256(bytes("transfer(address,uint256)")));

    address public factory;
    address public token0;
    address public token1;
    address public stakingPool;

    bool public initialized;

    uint256 public constant FEE_DENOMINATOR = 1_000_000;
    uint256 public constant DISCOUNT_MAX = 10_000;
    uint256 public constant MAX_FEE_PERCENT = 320_000; // = 32%

    uint32 public feePercent = 3_000; // default = 0.3%  // uses single storage slot, accessible via getReserves

    uint256 public precisionMultiplier0;
    uint256 public precisionMultiplier1;

    uint112 private reserve0; // uses single storage slot, accessible via getReserves
    uint112 private reserve1; // uses single storage slot, accessible via getReserves
    uint32 private blockTimestampLast; // uses single storage slot, accessible via getReserves

    uint256 public price0CumulativeLast;
    uint256 public price1CumulativeLast;
    uint256 public kLast; // reserve0 * reserve1, as of immediately after the most recent liquidity event

    bool public stableSwap; // if set to true, defines pair type as stable
    bool public pairTypeImmutable; // if set to true, stableSwap states cannot be updated anymore

    uint256 private unlocked = 1;

    struct SwapFeeConstraint {
        uint256 realFee;
        uint256 operationFee;
        uint256 remainingFee;
    }

    event Mint(address indexed sender, uint256 amount0, uint256 amount1);
    event Burn(address indexed sender, uint256 amount0, uint256 amount1, address indexed to);
    event Swap(
        address indexed sender,
        uint256 amount0In,
        uint256 amount1In,
        uint256 amount0Out,
        uint256 amount1Out,
        address indexed to
    );
    event Sync(uint112 reserve0, uint112 reserve1);
    event Skim();

    event SetFeePercent(uint32 feePercent);
    event SetPairTypeImmutable();
    event SetStableSwap(bool prevStableSwap, bool stableSwap);
    event RecoverWrongToken(address indexed token, address to);

    modifier lock() {
        require(unlocked == 1, "Brewlabs: LOCKED");
        unlocked = 0;
        _;
        unlocked = 1;
    }

    constructor() {
        factory = msg.sender;
    }

    // called once by the factory at time of deployment
    function initialize(address _token0, address _token1) external {
        require(msg.sender == factory && !initialized, "Brewlabs: FORBIDDEN");
        // sufficient check
        token0 = _token0;
        token1 = _token1;

        precisionMultiplier0 = 10 ** uint256(IERC20(_token0).decimals());
        precisionMultiplier1 = 10 ** uint256(IERC20(_token1).decimals());

        initialized = true;
    }

    function getReserves()
        public
        view
        returns (uint112 _reserve0, uint112 _reserve1, uint32 _feePercent, uint32 _blockTimestampLast)
    {
        _reserve0 = reserve0;
        _reserve1 = reserve1;
        _feePercent = feePercent;
        _blockTimestampLast = blockTimestampLast;
    }

    function _safeTransfer(address token, address to, uint256 value) private {
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(SELECTOR, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), "Brewlabs: TRANSFER_FAILED");
    }

    // update reserves
    function _update(uint256 balance0, uint256 balance1, uint112 _reserve0, uint112 _reserve1) private {
        require(balance0 <= type(uint112).max && balance1 <= type(uint112).max, "Brewlabs: OVERFLOW");
        uint32 blockTimestamp = uint32(block.timestamp % 2 ** 32);
        uint32 timeElapsed = blockTimestamp - blockTimestampLast; // overflow is desired
        if (timeElapsed > 0 && _reserve0 != 0 && _reserve1 != 0) {
            unchecked {
                // * never overflows, and + overflow is desired
                price0CumulativeLast += uint256(UQ112x112.encode(_reserve1).uqdiv(_reserve0)) * timeElapsed;
                price1CumulativeLast += uint256(UQ112x112.encode(_reserve0).uqdiv(_reserve1)) * timeElapsed;
            }
        }
        reserve0 = uint112(balance0);
        reserve1 = uint112(balance1);
        blockTimestampLast = blockTimestamp;
        emit Sync(uint112(balance0), uint112(balance1));
    }

    // if fee is on, mint liquidity equivalent to "factory.ownerFee()" of the growth in sqrt(k)
    // only for uni configuration
    function _mintFee(uint112 _reserve0, uint112 _reserve1) private returns (bool feeOn) {
        if (stableSwap) return false;

        (uint256 ownerFee, address feeTo) = IBrewlabsFactory(factory).feeInfo();
        feeOn = feeTo != address(0);
        uint256 _kLast = kLast;
        // gas savings
        if (feeOn) {
            if (_kLast != 0) {
                uint256 rootK = Math.sqrt(_k(uint256(_reserve0), uint256(_reserve1)));
                uint256 rootKLast = Math.sqrt(_kLast);
                if (rootK > rootKLast) {
                    uint256 d = (FEE_DENOMINATOR * 100 / ownerFee) - 100;
                    uint256 numerator = totalSupply * (rootK - rootKLast) * 100;
                    uint256 denominator = rootK * d + (rootKLast * 100);
                    uint256 liquidity = numerator / denominator;
                    if (liquidity > 0) _mint(feeTo, liquidity);
                }
            }
        } else if (_kLast != 0) {
            kLast = 0;
        }
    }

    function _transfer(address from, address to, uint256 value) internal override {
        super._transfer(from, to, value);

        address feeMgr = IBrewlabsFactory(factory).feeManager();
        if (feeMgr != address(0x0)) {
            IBrewlabsSwapFeeManager(feeMgr).lpTransferred(from, to, value, address(this), token0, token1);
        }
    }

    // this low-level function should be called from a contract which performs important safety checks
    function mint(address to) external lock returns (uint256 liquidity) {
        (uint112 _reserve0, uint112 _reserve1,,) = getReserves(); // gas savings
        uint256 balance0 = IERC20(token0).balanceOf(address(this));
        uint256 balance1 = IERC20(token1).balanceOf(address(this));
        uint256 amount0 = balance0 - _reserve0;
        uint256 amount1 = balance1 - _reserve1;

        bool feeOn = _mintFee(_reserve0, _reserve1);
        uint256 _totalSupply = totalSupply; // gas savings
        if (_totalSupply == 0) {
            liquidity = Math.sqrt(amount0 * amount1) - MINIMUM_LIQUIDITY;
            _mint(address(0), MINIMUM_LIQUIDITY);
            // permanently lock the first MINIMUM_LIQUIDITY tokens
        } else {
            liquidity = Math.min(amount0 * _totalSupply / _reserve0, amount1 * _totalSupply / _reserve1);
        }
        require(liquidity > 0, "Brewlabs: INSUFFICIENT_LIQUIDITY_MINTED");
        _mint(to, liquidity);

        _update(balance0, balance1, _reserve0, _reserve1);
        if (feeOn) kLast = _k(uint256(reserve0), uint256(reserve1));
        // reserve0 and reserve1 are up-to-date
        emit Mint(msg.sender, amount0, amount1);

        address feeMgr = IBrewlabsFactory(factory).feeManager();
        if (feeMgr != address(0x0)) {
            IBrewlabsSwapFeeManager(feeMgr).lpMinted(to, liquidity, address(this), token0, token1);
        }
    }

    // this low-level function should be called from a contract which performs important safety checks
    function burn(address to) external lock returns (uint256 amount0, uint256 amount1) {
        (uint112 _reserve0, uint112 _reserve1,,) = getReserves(); // gas savings
        address _token0 = token0; // gas savings
        address _token1 = token1; // gas savings
        uint256 balance0 = IERC20(_token0).balanceOf(address(this));
        uint256 balance1 = IERC20(_token1).balanceOf(address(this));
        uint256 liquidity = balanceOf[address(this)];

        bool feeOn = _mintFee(_reserve0, _reserve1);
        uint256 _totalSupply = totalSupply; // gas savings
        amount0 = liquidity * balance0 / _totalSupply; // using balances ensures pro-rata distribution
        amount1 = liquidity * balance1 / _totalSupply; // using balances ensures pro-rata distribution
        require(amount0 > 0 && amount1 > 0, "Brewlabs: INSUFFICIENT_LIQUIDITY_BURNED");

        _burn(address(this), liquidity);
        _safeTransfer(_token0, to, amount0);
        _safeTransfer(_token1, to, amount1);

        balance0 = IERC20(_token0).balanceOf(address(this));
        balance1 = IERC20(_token1).balanceOf(address(this));

        _update(balance0, balance1, _reserve0, _reserve1);
        if (feeOn) kLast = _k(uint256(reserve0), uint256(reserve1)); // reserve0 and reserve1 are up-to-date
        emit Burn(msg.sender, amount0, amount1, to);

        address feeMgr = IBrewlabsFactory(factory).feeManager();
        if (feeMgr != address(0x0)) {
            IBrewlabsSwapFeeManager(feeMgr).lpBurned(to, liquidity, address(this), token0, token1);
        }
    }

    // this low-level function should be called from a contract which performs important safety checks
    function swap(uint256 amount0Out, uint256 amount1Out, address to, bytes calldata data) external lock {
        require(IBrewlabsFactory(factory).isAllowedToSwap(msg.sender), "BrewlabsRouter: NOT_ALLOWED_TO_SWAP");
        require(amount0Out > 0 || amount1Out > 0, "Brewlabs: INSUFFICIENT_OUTPUT_AMOUNT");
        require(to != token0 && to != token1, "Brewlabs: INVALID_TO");

        (uint112 _reserve0, uint112 _reserve1, uint32 _feePercent,) = getReserves();
        require(amount0Out < _reserve0 && amount1Out < _reserve1, "Brewlabs: INSUFFICIENT_LIQUIDITY");

        // optimistically transfer tokens
        if (amount0Out > 0) _safeTransfer(token0, to, amount0Out);
        if (amount1Out > 0) _safeTransfer(token1, to, amount1Out);
        if (data.length > 0) {
            IBrewlabsCallee(to).brewlabsCall(msg.sender, amount0Out, amount1Out, data);
        }
        uint256 balance0 = IERC20(token0).balanceOf(address(this));
        uint256 balance1 = IERC20(token1).balanceOf(address(this));

        uint256 amount0In = balance0 > _reserve0 - amount0Out ? balance0 - (_reserve0 - amount0Out) : 0;
        uint256 amount1In = balance1 > _reserve1 - amount1Out ? balance1 - (_reserve1 - amount1Out) : 0;
        require(amount0In > 0 || amount1In > 0, "Brewlabs: INSUFFICIENT_INPUT_AMOUNT");

        SwapFeeConstraint memory constraint;
        {
            uint256 discount = getDiscount(to);

            // scope for fee management
            if (!IBrewlabsFactory(factory).isWhitelisted(to)) {
                constraint.realFee = uint256(_feePercent) * (DISCOUNT_MAX - discount) / DISCOUNT_MAX;
                (constraint.remainingFee, constraint.operationFee) =
                    _distributeFees(amount0In, amount1In, constraint.realFee);
            } else {
                constraint.operationFee = 1;
            }
        }
        // readjust tokens balance
        if (amount0In > 0) balance0 = IERC20(token0).balanceOf(address(this));
        if (amount1In > 0) balance1 = IERC20(token1).balanceOf(address(this));
        {
            uint256 remainingFee0 =
                amount0In * constraint.realFee * constraint.remainingFee / (FEE_DENOMINATOR * constraint.operationFee);
            uint256 remainingFee1 =
                amount1In * constraint.realFee * constraint.remainingFee / (FEE_DENOMINATOR * constraint.operationFee);
            uint256 balance0Adjusted = balance0 - remainingFee0;
            uint256 balance1Adjusted = balance1 - remainingFee1;
            require(_k(balance0Adjusted, balance1Adjusted) >= _k(uint256(_reserve0), uint256(_reserve1)), "Brewlabs: K");
        }

        _update(balance0, balance1, _reserve0, _reserve1);
        {
            // scope for _amountOut{0,1}, avoids stack too deep errors
            uint256 _amount0Out = amount0Out;
            uint256 _amount1Out = amount1Out;
            emit Swap(msg.sender, amount0In, amount1In, _amount0Out, _amount1Out, to);
        }
    }

    function _distributeFees(uint256 amount0In, uint256 amount1In, uint256 realFee)
        internal
        returns (uint256, uint256)
    {
        address feeMgr = IBrewlabsFactory(factory).feeManager();
        if (feeMgr == address(0)) return (1, 1);

        (uint256 operationFee,, uint256 brewlabsFee,, uint256 stakingFee,) =
            IBrewlabsSwapFeeManager(feeMgr).getFeeDistribution(address(this));
        uint256 remainingFee = brewlabsFee + stakingFee;
        uint256 fee = 0;
        {
            uint256 _amount0In = amount0In;
            if (_amount0In > 0) {
                uint256 _realFee = _amount0In * realFee / FEE_DENOMINATOR;
                fee = _realFee * (operationFee - remainingFee) / operationFee;
                IERC20(token0).approve(feeMgr, fee);
                IBrewlabsSwapFeeManager(feeMgr).notifyRewardAmount(address(this), token0, token1, fee, 0);
                // staking fee distribution
                if (stakingFee > 0 && stakingPool != address(0)) {
                    fee = _realFee * stakingFee / operationFee;
                    _safeTransfer(token0, stakingPool, fee);
                    remainingFee = remainingFee - stakingFee;
                }
            }
        }
        {
            uint256 _amount1In = amount1In;
            if (_amount1In > 0) {
                uint256 _realFee = _amount1In * realFee / FEE_DENOMINATOR;
                fee = _realFee * (operationFee - remainingFee) / operationFee;
                IERC20(token1).approve(feeMgr, fee);
                IBrewlabsSwapFeeManager(feeMgr).notifyRewardAmount(address(this), token0, token1, 0, fee);
                // staking fee distribution
                if (stakingFee > 0 && stakingPool != address(0)) {
                    fee = _realFee * stakingFee / operationFee;
                    _safeTransfer(token1, stakingPool, fee);
                    remainingFee = remainingFee - stakingFee;
                }
            }
        }
        return (remainingFee, operationFee);
    }

    function _k(uint256 balance0, uint256 balance1) internal view returns (uint256) {
        if (stableSwap) {
            uint256 _x = balance0 * 1e18 / precisionMultiplier0;
            uint256 _y = balance1 * 1e18 / precisionMultiplier1;
            uint256 _a = _x * _y / 1e18;
            uint256 _b = _x * _x / 1e18 + _y * _y / 1e18;
            return _a * _b / 1e18; // x3y+y3x >= k
        }
        return balance0 * balance1;
    }

    function _get_x(uint256 x, uint256 xy, uint256 y0) internal pure returns (uint256) {
        for (uint256 i = 0; i < 255; i++) {
            uint256 x_prev = x;
            uint256 k = _f(x, y0);
            if (k < xy) {
                uint256 dx = ((xy - k) * 1e18) / _d(y0, x);
                x = x + dx;
            } else {
                uint256 dx = ((k - xy) * 1e18) / _d(y0, x);
                x = x - dx;
            }
            if (x > x_prev) {
                if (x - x_prev <= 1) {
                    return x;
                }
            } else {
                if (x_prev - x <= 1) {
                    return x;
                }
            }
        }
        return x;
    }

    function _get_y(uint256 x0, uint256 xy, uint256 y) internal pure returns (uint256) {
        for (uint256 i = 0; i < 255; i++) {
            uint256 y_prev = y;
            uint256 k = _f(x0, y);
            if (k < xy) {
                uint256 dy = ((xy - k) * 1e18) / _d(x0, y);
                y = y + dy;
            } else {
                uint256 dy = ((k - xy) * 1e18) / _d(x0, y);
                y = y - dy;
            }
            if (y > y_prev) {
                if (y - y_prev <= 1) {
                    return y;
                }
            } else {
                if (y_prev - y <= 1) {
                    return y;
                }
            }
        }
        return y;
    }

    function _f(uint256 x0, uint256 y) internal pure returns (uint256) {
        return (x0 * ((((y * y) / 1e18) * y) / 1e18)) / 1e18 + (((((x0 * x0) / 1e18) * x0) / 1e18) * y) / 1e18;
    }

    function _d(uint256 x0, uint256 y) internal pure returns (uint256) {
        return (3 * x0 * ((y * y) / 1e18)) / 1e18 + ((((x0 * x0) / 1e18) * x0) / 1e18);
    }

    function getDiscount(address addr) internal view returns (uint256 discount) {
        address discountMgr = IBrewlabsFactory(factory).discountMgr();
        if (discountMgr != address(0)) {
            discount = IBrewlabsNFTDiscountManager(discountMgr).discountOf(addr);
        } else {
            discount = 0;
        }
    }

    function getAmountOut(uint256 amountIn, address tokenIn, uint256 discount) external view returns (uint256) {
        require(amountIn > 0, "Brewlabs: INSUFFICIENT_INPUT_AMOUNT");
        require(reserve0 > 0 && reserve1 > 0, "Brewlabs: INSUFFICIENT_LIQUIDITY");
        return _getAmountOut(
            amountIn,
            tokenIn,
            uint256(reserve0),
            uint256(reserve1),
            uint256(feePercent) * (DISCOUNT_MAX - discount) / DISCOUNT_MAX
        );
    }

    function getAmountIn(uint256 amountOut, address tokenIn, uint256 discount) external view returns (uint256) {
        require(amountOut > 0, "Brewlabs: INSUFFICIENT_INPUT_AMOUNT");
        require(reserve0 > 0 && reserve1 > 0, "Brewlabs: INSUFFICIENT_LIQUIDITY");
        return _getAmountIn(
            amountOut,
            tokenIn,
            uint256(reserve0),
            uint256(reserve1),
            uint256(feePercent) * (DISCOUNT_MAX - discount) / DISCOUNT_MAX
        );
    }

    function _getAmountOut(uint256 amountIn, address tokenIn, uint256 _reserve0, uint256 _reserve1, uint256 _feePercent)
        internal
        view
        returns (uint256)
    {
        if (stableSwap) {
            amountIn = amountIn - (amountIn * _feePercent / FEE_DENOMINATOR); // remove fee from amount received
            uint256 xy = _k(_reserve0, _reserve1);
            _reserve0 = _reserve0 * 1e18 / precisionMultiplier0;
            _reserve1 = _reserve1 * 1e18 / precisionMultiplier1;

            (uint256 reserveIn, uint256 reserveOut) =
                tokenIn == token0 ? (_reserve0, _reserve1) : (_reserve1, _reserve0);
            amountIn =
                tokenIn == token0 ? amountIn * 1e18 / precisionMultiplier0 : amountIn * 1e18 / precisionMultiplier1;
            uint256 y = reserveOut - _get_y(amountIn + reserveIn, xy, reserveOut);
            return y * (tokenIn == token0 ? precisionMultiplier1 : precisionMultiplier0) / 1e18;
        } else {
            (uint256 reserveIn, uint256 reserveOut) =
                tokenIn == token0 ? (_reserve0, _reserve1) : (_reserve1, _reserve0);
            amountIn = amountIn * (FEE_DENOMINATOR - _feePercent);
            return (amountIn * reserveOut) / (reserveIn * FEE_DENOMINATOR + amountIn);
        }
    }

    function _getAmountIn(uint256 amountOut, address tokenIn, uint256 _reserve0, uint256 _reserve1, uint256 _feePercent)
        internal
        view
        returns (uint256)
    {
        if (stableSwap) {
            uint256 xy = _k(_reserve0, _reserve1);
            _reserve0 = (_reserve0 * 1e18) / precisionMultiplier0;
            _reserve1 = (_reserve1 * 1e18) / precisionMultiplier1;

            (uint256 reserveIn, uint256 reserveOut) =
                tokenIn == token0 ? (_reserve0, _reserve1) : (_reserve1, _reserve0);
            amountOut = tokenIn == token0
                ? (amountOut * 1e18) / precisionMultiplier0
                : (amountOut * 1e18) / precisionMultiplier1;
            uint256 x = _get_x(reserveIn, xy, reserveOut - amountOut) - reserveIn;
            return ((x * (tokenIn == token0 ? precisionMultiplier0 : precisionMultiplier1)) / 1e18) * FEE_DENOMINATOR
                / (FEE_DENOMINATOR - _feePercent);
        } else {
            (uint256 reserveIn, uint256 reserveOut) =
                tokenIn == token0 ? (_reserve0, _reserve1) : (_reserve1, _reserve0);
            uint256 numerator = reserveIn * amountOut * FEE_DENOMINATOR;
            uint256 denominator = (reserveOut - (amountOut)) * (FEE_DENOMINATOR - _feePercent);
            return (numerator / denominator) + 1;
        }
    }

    // force balances to match reserves
    function skim(address to) external lock {
        address _token0 = token0; // gas savings
        address _token1 = token1; // gas savings
        _safeTransfer(_token0, to, IERC20(_token0).balanceOf(address(this)) - (reserve0));
        _safeTransfer(_token1, to, IERC20(_token1).balanceOf(address(this)) - (reserve1));
        emit Skim();
    }

    // force reserves to match balances
    function sync() external lock {
        _update(IERC20(token0).balanceOf(address(this)), IERC20(token1).balanceOf(address(this)), reserve0, reserve1);
    }

    /**
     * @dev Updates the swap fees percent
     * Can only be called by the factory's feeManager or feePercentOwner
     */
    function setFeePercent(uint32 newfeePercent) external lock {
        address feeMgr = IBrewlabsFactory(factory).feeManager();

        if (feeMgr == address(0)) {
            require(
                msg.sender == IBrewlabsFactory(factory).feePercentOwner(), "Brewlabs: only factory's feePercentOwner"
            );
        } else {
            require(msg.sender == feeMgr, "Brewlabs: only factory's feeManager");
        }

        require(newfeePercent <= MAX_FEE_PERCENT, "Brewlabs: feePercent mustn't exceed the maximum");
        require(newfeePercent > 0, "Brewlabs: feePercent mustn't exceed the minimum");
        feePercent = newfeePercent;
        emit SetFeePercent(newfeePercent);
    }

    function setStableSwap(bool stable, uint112 expectedReserve0, uint112 expectedReserve1) external lock {
        address feeMgr = IBrewlabsFactory(factory).feeManager();
        if (feeMgr == address(0)) {
            require(msg.sender == IBrewlabsFactory(factory).setStableOwner(), "Brewlabs: only factory's setStableOwner");
        } else {
            require(msg.sender == feeMgr, "Brewlabs: only factory's feeManager");
        }
        require(!pairTypeImmutable, "Brewlabs: immutable");

        require(stable != stableSwap, "Brewlabs: no update");
        require(expectedReserve0 == reserve0 && expectedReserve1 == reserve1, "Brewlabs: failed");

        emit SetStableSwap(stableSwap, stable);
        stableSwap = stable;
        kLast = _k(uint256(reserve0), uint256(reserve1));
    }

    function setStakingPool(address _stakingPool) external lock {
        address feeMgr = IBrewlabsFactory(factory).feeManager();
        if (feeMgr == address(0)) {
            require(msg.sender == IBrewlabsFactory(factory).owner(), "Brewlabs: only factory's owner");
        } else {
            require(msg.sender == feeMgr, "Brewlabs: only factory's feeManager");
        }
        require(_stakingPool != address(0), "Brewlabs: invalid staking pool address");
        stakingPool = _stakingPool;
    }

    function setPairTypeImmutable() external lock {
        require(msg.sender == IBrewlabsFactory(factory).owner(), "Brewlabs: only factory's owner");
        require(!pairTypeImmutable, "Brewlabs: already immutable");

        pairTypeImmutable = true;
        emit SetPairTypeImmutable();
    }

    /**
     * @dev Allow to recover token sent here by mistake
     * Can only be called by factory's owner
     */
    function rescueWrongToken(address token, address to) external lock {
        require(msg.sender == IBrewlabsFactory(factory).owner(), "Brewlabs: only factory's owner");
        require(token != token0 && token != token1, "Brewlabs: invalid token");

        if (token == address(0)) {
            (bool sent,) = payable(msg.sender).call{value: address(this).balance}("");
            require(sent, "Failed to recover native token");
        } else {
            _safeTransfer(token, to, IERC20(token).balanceOf(address(this)));
        }
        emit RecoverWrongToken(token, to);
    }
}
// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity ^0.8.14;

interface IBrewlabsCallee {
    function brewlabsCall(address sender, uint256 amount0, uint256 amount1, bytes calldata data) external;
}
// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity ^0.8.14;

interface IBrewlabsERC20 {
    event Approval(address indexed owner, address indexed spender, uint256 value);
    event Transfer(address indexed from, address indexed to, uint256 value);

    function name() external pure returns (string memory);
    function symbol() external pure returns (string memory);
    function decimals() external pure returns (uint8);
    function totalSupply() external view returns (uint256);
    function balanceOf(address owner) external view returns (uint256);
    function allowance(address owner, address spender) external view returns (uint256);

    function approve(address spender, uint256 value) external returns (bool);
    function transfer(address to, uint256 value) external returns (bool);
    function transferFrom(address from, address to, uint256 value) external returns (bool);

    function DOMAIN_SEPARATOR() external view returns (bytes32);
    function PERMIT_TYPEHASH() external pure returns (bytes32);
    function nonces(address owner) external view returns (uint256);

    function permit(address owner, address spender, uint256 value, uint256 deadline, uint8 v, bytes32 r, bytes32 s)
        external;
}
// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity ^0.8.14;

interface IBrewlabsFactory {
    event PairCreated(address indexed token0, address indexed token1, address pair, uint256);

    function owner() external view returns (address);
    function feePercentOwner() external view returns (address);
    function setStableOwner() external view returns (address);
    function feeTo() external view returns (address);

    function discountMgr() external view returns (address);
    function feeManager() external view returns (address);

    function ownerFee() external view returns (uint256);

    function getPair(address tokenA, address tokenB) external view returns (address pair);
    function allPairs(uint256) external view returns (address pair);
    function allPairsLength() external view returns (uint256);

    function createPair(address tokenA, address tokenB) external returns (address pair);

    function setFeeTo(address) external;
    function feeInfo() external view returns (uint256 _ownerFee, address _feeTo);

    function isAllowedToSwap(address) external view returns (bool);
    function isWhitelisted(address) external view returns (bool);
}
// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity ^0.8.14;

interface IBrewlabsNFTDiscountManager {
    function discountOf(address _to) external view returns (uint256);
}
// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity ^0.8.14;

interface IBrewlabsSwapFeeManager {
    event Claimed(address indexed to, address indexed pair, uint256 amount0, uint256 amount1);

    function getFeeDistribution(address pair)
        external
        view
        returns (uint256, uint256, uint256, uint256, uint256, uint256);
    function pendingLPRewards(address pair, address staker) external view returns (uint256, uint256);
    function createPool(address token0, address token1) external;
    function claim(address pair) external;
    function claimAll(address[] calldata pairs) external;
    function lpMinted(address to, uint256 amount, address pair, address token0, address token1) external;
    function lpBurned(address from, uint256 amount, address pair, address token0, address token1) external;
    function lpTransferred(address from, address to, uint256 amount, address pair, address token0, address token1)
        external;
    function notifyRewardAmount(address pair, address token0, address token1, uint256 amount0, uint256 amount1)
        external;
}
// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity ^0.8.14;

interface IERC20 {
    event Approval(address indexed owner, address indexed spender, uint256 value);
    event Transfer(address indexed from, address indexed to, uint256 value);

    function name() external view returns (string memory);
    function symbol() external view returns (string memory);
    function decimals() external view returns (uint8);
    function totalSupply() external view returns (uint256);
    function balanceOf(address owner) external view returns (uint256);
    function allowance(address owner, address spender) external view returns (uint256);

    function approve(address spender, uint256 value) external returns (bool);
    function transfer(address to, uint256 value) external returns (bool);
    function transferFrom(address from, address to, uint256 value) external returns (bool);
}
// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity ^0.8.14;

// a library for handling binary fixed point numbers (https://en.wikipedia.org/wiki/Q_(number_format))

// range: [0, 2**112 - 1]
// resolution: 1 / 2**112

library UQ112x112 {
    uint224 constant Q112 = 2 ** 112;

    // encode a uint112 as a UQ112x112
    function encode(uint112 y) internal pure returns (uint224 z) {
        z = uint224(y) * Q112; // never overflows
    }

    // divide a UQ112x112 by a uint112, returning a UQ112x112
    function uqdiv(uint224 x, uint112 y) internal pure returns (uint224 z) {
        z = x / uint224(y);
    }
}
