// SPDX-License-Identifier: MIT
pragma solidity >=0.8.10;

import "@openzeppelin/contracts/utils/math/Math.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "./IDeFiSystemReferenceV2.sol";
import "./ID2HelperBase.sol";
import "./IUniswapV2Factory.sol";
import "./IUniswapV2Router02.sol";
import "./IUniswapV2Pair.sol";
import "./IWETH.sol";

contract D2HelperWithSalt is Ownable, ID2HelperBase {
    using Math for uint256;

    bool internal immutable hasAlternativeSwap;

    bool internal isInternal;
    bool internal isRunningArbitrage;
    bool internal swapSuccessful;

    enum Operation {
        ETH_TO_D2_INTERNAL_D2_TO_ETH_EXTERNAL,
        ETH_TO_D2_EXTERNAL_D2_TO_ETH_INTERNAL
    }

    Operation internal operation;

    IUniswapV2Router02 internal router;
    IUniswapV2Factory internal factory;
    IDeFiSystemReferenceV2 internal d2;
    IERC20 internal sdr;
    address internal immutable rsdTokenAddress;
    address internal immutable timeTokenAddress;

    address internal _pairD2Eth;
    address internal _pairD2Sdr;

    uint256 internal constant FACTOR = 10 ** 18;
    uint256 internal constant ARBITRAGE_RATE = 500;
    uint256 internal constant SWAP_FEE = 100;

    uint256[11] internal rangesWETH = [
        10_000_000 ether,
        1_000_000 ether,
        100_000 ether,
        10_000 ether,
        1_000 ether,
        100 ether,
        10 ether,
        1 ether,
        0.1 ether,
        0.01 ether,
        0.001 ether
    ];

    modifier fromD2() {
        require(msg.sender == address(d2), "D2 Helper: only D2 token contract can call this function");
        _;
    }

    modifier internalOnly() {
        require(isInternal, "D2 Helper: sorry buddy but you do not have access to this function");
        _;
    }

    modifier adjustInternalCondition() {
        isInternal = true;
        _;
        isInternal = false;
    }

    modifier runningArbitrage() {
        if (!isRunningArbitrage) {
            isRunningArbitrage = true;
            _;
            isRunningArbitrage = false;
        }
    }

    constructor(
        address _addressProvider,
        address _exchangeRouterAddress,
        address _d2TokenAddress,
        address _timeTokenAddress,
        address _rsdTokenAddress,
        address _sdrTokenAddress,
        bool _hasAlternativeSwap,
        address _owner
    ) {
        router = IUniswapV2Router02(_exchangeRouterAddress);
        factory = IUniswapV2Factory(router.factory());
        d2 = IDeFiSystemReferenceV2(payable(_d2TokenAddress));
        sdr = IERC20(_sdrTokenAddress);
        rsdTokenAddress = _rsdTokenAddress;
        timeTokenAddress = _timeTokenAddress;
        hasAlternativeSwap = _hasAlternativeSwap;
        transferOwnership(_owner);
        _createPairs();
    }

    function _calculateFee(uint256 amount) internal virtual returns (uint256) {
        return amount + amount.mulDiv(SWAP_FEE, 10_000);
    }

    function _startTraditionalSwap(address asset, uint256 amount) internal virtual returns (bool) {
        return false;
    }

    function _startAlternativeSwap(uint256 amountIn, uint256 amountOut) internal returns (bool) {
        address weth = router.WETH();
        swapSuccessful = false;
        IUniswapV2Pair pair = IUniswapV2Pair(_pairD2Eth);
        if (operation == Operation.ETH_TO_D2_EXTERNAL_D2_TO_ETH_INTERNAL) {
            uint256 amount0Out = address(d2) == pair.token0() ? amountOut : 0;
            uint256 amount1Out = address(d2) == pair.token1() ? amountOut : 0;
            try pair.swap(amount0Out, amount1Out, address(this), bytes(abi.encode(address(d2), amountOut))) {
                return swapSuccessful;
            } catch {
                return swapSuccessful;
            }
        } else {
            // ETH_TO_D2_INTERNAL_D2_TO_ETH_EXTERNAL
            uint256 amount0Out = weth == pair.token0() ? amountIn : 0;
            uint256 amount1Out = weth == pair.token1() ? amountIn : 0;
            try pair.swap(amount0Out, amount1Out, address(this), bytes(abi.encode(weth, amountIn))) {
                return swapSuccessful;
            } catch {
                return swapSuccessful;
            }
        }
    }

    receive() external payable { }

    fallback() external payable {
        require(msg.data.length == 0);
    }

    function _commonCall(address sender, bytes calldata data) internal {
        if (msg.sender == _pairD2Eth) {
            if (sender == address(this)) {
                // Operation.ETH_TO_D2_EXTERNAL_D2_TO_ETH_INTERNAL
                (address tokenToBorrow, uint256 amountToBorrow) = abi.decode(data, (address, uint256));
                if (tokenToBorrow == address(d2)) {
                    // 1. D2 -> ETH (Internal)
                    try d2.sellD2(amountToBorrow) {
                        address[] memory path = new address[](2);
                        path[0] = router.WETH();
                        path[1] = address(d2);
                        uint256[] memory amountRequired = router.getAmountsIn(amountToBorrow, path);
                        IWETH(path[0]).deposit{ value: amountRequired[0] }();
                        // 2. ETH -> D2 (External)
                        IERC20(path[0]).transfer(msg.sender, amountRequired[0]);
                        payable(address(d2)).call{ value: address(this).balance }("");
                        swapSuccessful = true;
                    } catch {
                        swapSuccessful = false;
                        return;
                    }
                } else {
                    // 1. ETH -> D2 (Internal)
                    address weth = router.WETH();
                    IWETH(weth).withdraw(amountToBorrow);
                    try d2.buyD2{ value: amountToBorrow }() {
                        address[] memory path = new address[](2);
                        path[0] = address(d2);
                        path[1] = weth;
                        uint256[] memory amountRequired = router.getAmountsIn(amountToBorrow, path);
                        // 2. D2 -> ETH (External)
                        IERC20(path[0]).transfer(msg.sender, amountRequired[0]);
                        try d2.sellD2(d2.balanceOf(address(this))) {
                            payable(address(d2)).call{ value: address(this).balance }("");
                            swapSuccessful = true;
                        } catch {
                            swapSuccessful = false;
                            return;
                        }
                    } catch {
                        swapSuccessful = false;
                        return;
                    }
                }
            }
        } else {
            swapSuccessful = false;
            return;
        }
    }

    function _createPairs() internal {
        _createPair(rsdTokenAddress, router.WETH());
        _createPair(rsdTokenAddress, address(sdr));
    }

    function _createPair(address asset01, address asset02) internal returns (address pair) {
        pair = factory.getPair(asset01, asset02);
        if (pair == address(0) && asset01 != address(0) && asset02 != address(0)) {
            try factory.createPair(asset01, asset02) returns (address p) {
                pair = p;
            } catch { }
        }
        return pair;
    }

    function _createPairsD2() internal {
        _pairD2Eth = _createPair(address(d2), router.WETH());
        _pairD2Sdr = _createPair(address(d2), address(sdr));
    }

    function _performOperation(address asset, uint256 amount) internal returns (bool) {
        if (operation == Operation.ETH_TO_D2_INTERNAL_D2_TO_ETH_EXTERNAL) {
            IWETH(asset).withdraw(amount); // assumming asset == weth
            try d2.buyD2{ value: amount }() {
                address[] memory path = new address[](2);
                path[0] = address(d2);
                path[1] = asset;
                uint256 d2Amount = d2.balanceOf(address(this));
                d2.approve(address(router), d2Amount);
                try router.swapExactTokensForTokensSupportingFeeOnTransferTokens(
                    d2Amount,
                    0, // amount,
                    path,
                    address(this),
                    block.timestamp + 300
                ) {
                    return true;
                } catch {
                    return false;
                }
            } catch {
                return false;
            }
        } else {
            address[] memory path = new address[](2);
            path[0] = asset;
            path[1] = address(d2);
            IERC20(asset).approve(address(router), amount);
            try router.swapExactTokensForTokensSupportingFeeOnTransferTokens(
                amount,
                0, //d2.queryD2AmountInternalLP(amount),
                path,
                address(this),
                block.timestamp + 300
            ) {
                uint256 d2Amount = d2.balanceOf(address(this));
                try d2.sellD2(d2Amount) {
                    IWETH(asset).deposit{ value: address(this).balance }();
                    return true;
                } catch {
                    return false;
                }
            } catch {
                return false;
            }
        }
    }

    /**
     * @dev Add liquidity for the D2/ETH pair LP in third party exchange (based on UniswapV2)
     *
     */
    function addLiquidityD2Native(uint256 d2Amount) external payable fromD2 returns (bool) {
        d2.approve(address(router), d2Amount);
        // add liquidity for the D2/ETH pair
        try router.addLiquidityETH{ value: msg.value }(
            address(d2),
            d2Amount,
            0, // slippage is unavoidable
            0, // slippage is unavoidable
            address(0),
            block.timestamp + 300
        ) {
            return true;
        } catch {
            d2.returnNativeWithoutSharing{ value: msg.value }();
            return false;
        }
    }

    /**
     * @dev Add liquidity for the D2/SDR pair LP in third party exchange (based on UniswapV2)
     *
     */
    function addLiquidityD2Sdr() external fromD2 returns (bool) {
        uint256 d2TokenAmount = d2.balanceOf(address(this));
        uint256 sdrTokenAmount = sdr.balanceOf(address(this));
        // approve token transfer to cover all possible scenarios
        d2.approve(address(router), d2TokenAmount);
        sdr.approve(address(router), sdrTokenAmount);
        // add the liquidity for D2/SDR pair
        try router.addLiquidity(
            address(d2),
            address(sdr),
            d2TokenAmount,
            sdrTokenAmount,
            0, // slippage is unavoidable
            0, // slippage is unavoidable
            address(0),
            block.timestamp + 300
        ) {
            return true;
        } catch {
            return false;
        }
    }

    function checkAndPerformArbitrage()
        external
        virtual
        runningArbitrage
        fromD2
        adjustInternalCondition
        returns (bool)
    {
        address weth = router.WETH();

        address pair = factory.getPair(address(d2), weth);
        uint256 balanceInternalNative = d2.poolBalance();
        uint256 balanceExternalNative = IERC20(weth).balanceOf(pair);
        uint256 balanceInternalD2 = d2.balanceOf(address(d2));
        uint256 balanceExternalD2 = d2.balanceOf(pair);

        if (balanceInternalNative == 0 || balanceExternalNative == 0) {
            return false;
        }

        uint256 rateInternal = balanceInternalD2.mulDiv(FACTOR, balanceInternalNative);
        uint256 rateExternal = balanceExternalD2.mulDiv(FACTOR, balanceExternalNative);

        if (rateExternal == 0 || rateInternal == 0) {
            return false;
        }

        bool shouldPerformArbitrage = (rateExternal > rateInternal)
            ? (rateExternal - rateInternal).mulDiv(10_000, rateExternal) >= ARBITRAGE_RATE
            : (rateInternal - rateExternal).mulDiv(10_000, rateInternal) >= ARBITRAGE_RATE;

        return (shouldPerformArbitrage ? _performArbitrage() : false);
    }

    function _performArbitrage() internal returns (bool success) {
        address weth = router.WETH();

        address[] memory assets_01 = new address[](2);
        assets_01[0] = weth;
        assets_01[1] = address(d2);
        address[] memory assets_02 = new address[](2);
        assets_02[0] = address(d2);
        assets_02[1] = weth;

        uint256[] memory amountOutExternal;
        uint256 amountOutInternal;

        address pair = factory.getPair(address(d2), weth);
        uint256 balanceInternalNative = d2.poolBalance();
        uint256 balanceExternalNative = IERC20(weth).balanceOf(pair);
        uint256 balanceInternalD2 = d2.balanceOf(address(d2));
        uint256 balanceExternalD2 = d2.balanceOf(pair);

        // getAmountsIn (amountOut, path) --> Given an amountOut value of path[1] token, it will tell us how many path[0] tokens we send
        // getAmountsOut(amountIn,  path) --> Given an amountIn  value of path[0] token, it will tell us how many path[1] tokens we receive
        for (uint256 i = 0; i < rangesWETH.length; i++) {
            amountOutExternal = router.getAmountsOut(rangesWETH[i], assets_01);
            amountOutInternal = d2.queryNativeAmount(amountOutExternal[1]);
            uint256 totalWithFee = _calculateFee(rangesWETH[i]);
            if (amountOutInternal <= totalWithFee) {
                amountOutInternal = d2.queryD2AmountOptimal(rangesWETH[i]);
                amountOutExternal = router.getAmountsOut(amountOutInternal, assets_02);
                if (amountOutExternal[1] > totalWithFee) {
                    // perform arbitrage here - Option #1 - Buy D2 LP Internal and Sell D2 LP External
                    if (balanceExternalNative >= amountOutExternal[1] && balanceInternalD2 >= amountOutInternal) {
                        operation = Operation.ETH_TO_D2_INTERNAL_D2_TO_ETH_EXTERNAL;
                        if (!hasAlternativeSwap) {
                            success = _startTraditionalSwap(weth, rangesWETH[i]);
                            if (!success) {
                                success = _startAlternativeSwap(rangesWETH[i], amountOutInternal);
                            }
                        } else {
                            success = _startAlternativeSwap(rangesWETH[i], amountOutInternal);
                        }
                        if (success) {
                            break;
                        }
                    }
                }
            } else {
                // perform arbitrage here - Option #2 - Buy D2 LP External and Sell D2 LP Internal
                if (balanceInternalNative >= amountOutInternal && balanceExternalD2 >= amountOutExternal[1]) {
                    operation = Operation.ETH_TO_D2_EXTERNAL_D2_TO_ETH_INTERNAL;
                    if (!hasAlternativeSwap) {
                        success = _startTraditionalSwap(weth, rangesWETH[i]);
                        if (!success) {
                            success = _startAlternativeSwap(rangesWETH[i], amountOutExternal[1]);
                        }
                    } else {
                        success = _startAlternativeSwap(rangesWETH[i], amountOutExternal[1]);
                    }
                    if (success) {
                        break;
                    }
                }
            }
        }
        return success;
    }

    function buyRsd() external payable fromD2 returns (bool) {
        // generate the pair path of ETH -> RSD on exchange router contract
        address[] memory path = new address[](2);
        path[0] = router.WETH();
        path[1] = rsdTokenAddress;

        try router.swapExactETHForTokensSupportingFeeOnTransferTokens{ value: msg.value }(
            0, // accept any amount of RSD
            path,
            address(this),
            block.timestamp + 300
        ) {
            return true;
        } catch {
            d2.returnNativeWithoutSharing{ value: msg.value }();
            return false;
        }
    }

    function buySdr() external fromD2 returns (bool) {
        IERC20 rsd = IERC20(rsdTokenAddress);
        uint256 rsdTokenAmount = rsd.balanceOf(address(this));
        // generate the pair path of RSD -> SDR on exchange router contract
        address[] memory path = new address[](2);
        path[0] = rsdTokenAddress;
        path[1] = address(sdr);

        rsd.approve(address(router), rsdTokenAmount);

        try router.swapExactTokensForTokensSupportingFeeOnTransferTokens(
            rsdTokenAmount,
            0, // accept any amount of SDR
            path,
            address(this),
            block.timestamp + 300
        ) {
            return true;
        } catch {
            return false;
        }
    }

    function kickBack() external payable fromD2 {
        payable(address(d2)).call{ value: msg.value }("");
    }

    function pancakeCall(address _sender, uint256 _amount0, uint256 _amount1, bytes calldata _data) external {
        _commonCall(_sender, _data);
    }

    function pairD2Eth() external view returns (address) {
        return _pairD2Eth;
    }

    function pairD2Sdr() external view returns (address) {
        return _pairD2Sdr;
    }

    function uniswapV2Call(address _sender, uint256 _amount0, uint256 _amount1, bytes calldata _data) external {
        _commonCall(_sender, _data);
    }

    function queryD2AmountFromSdr() external view fromD2 returns (uint256) {
        uint256 pairSdrBalance = sdr.balanceOf(factory.getPair(address(d2), address(sdr)));
        pairSdrBalance = (pairSdrBalance == 0) ? sdr.balanceOf(address(this)) : pairSdrBalance;
        return pairSdrBalance.mulDiv(queryD2SdrRate(), FACTOR);
    }

    function queryD2Rate() external view fromD2 returns (uint256) {
        address weth = router.WETH();
        uint256 ethBalance = IERC20(weth).balanceOf(_pairD2Eth);
        return (ethBalance == 0) ? FACTOR : d2.balanceOf(_pairD2Eth).mulDiv(FACTOR, ethBalance);
    }

    function queryD2SdrRate() public view fromD2 returns (uint256) {
        uint256 rate = d2.balanceOf(_pairD2Sdr).mulDiv(FACTOR, sdr.balanceOf(_pairD2Sdr) + 1);
        return (rate == 0 ? 1 : rate);
    }

    function queryPoolAddress() external view virtual returns (address) {
        return address(0);
    }

    function setD2(address d2Address) external virtual onlyOwner {
        d2 = IDeFiSystemReferenceV2(payable(d2Address));
        _createPairsD2();
    }

    function destroy() external virtual onlyOwner {
        selfdestruct(payable(msg.sender));
    }
}
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.8.0) (utils/math/Math.sol)

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
    function mulDiv(
        uint256 x,
        uint256 y,
        uint256 denominator
    ) internal pure returns (uint256 result) {
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
                return prod0 / denominator;
            }

            // Make sure the result is less than 2^256. Also prevents denominator == 0.
            require(denominator > prod1);

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
    function mulDiv(
        uint256 x,
        uint256 y,
        uint256 denominator,
        Rounding rounding
    ) internal pure returns (uint256) {
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
            if (value >= 10**64) {
                value /= 10**64;
                result += 64;
            }
            if (value >= 10**32) {
                value /= 10**32;
                result += 32;
            }
            if (value >= 10**16) {
                value /= 10**16;
                result += 16;
            }
            if (value >= 10**8) {
                value /= 10**8;
                result += 8;
            }
            if (value >= 10**4) {
                value /= 10**4;
                result += 4;
            }
            if (value >= 10**2) {
                value /= 10**2;
                result += 2;
            }
            if (value >= 10**1) {
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
            return result + (rounding == Rounding.Up && 10**result < value ? 1 : 0);
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
     * @dev Return the log in base 10, following the selected rounding direction, of a positive value.
     * Returns 0 if given 0.
     */
    function log256(uint256 value, Rounding rounding) internal pure returns (uint256) {
        unchecked {
            uint256 result = log256(value);
            return result + (rounding == Rounding.Up && 1 << (result * 8) < value ? 1 : 0);
        }
    }
}
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.6.0) (token/ERC20/IERC20.sol)

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
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.7.0) (access/Ownable.sol)

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
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

interface IDeFiSystemReferenceV2 {
    function name() external view returns (string memory);
    function symbol() external view returns (string memory);
    function decimals() external view returns (uint8);
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address to, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address from, address to, uint256 amount) external returns (bool);
    function increaseAllowance(address spender, uint256 addedValue) external returns (bool);
    function decreaseAllowance(address spender, uint256 subtractedValue) external returns (bool);
    function accountShareBalance(address account) external view returns (uint256);
    function burn(uint256 amount) external;
    function mintD2(uint256 timeAmount) external payable;
    function obtainRandomWalletAddress(uint256 someNumber) external view returns (address);
    function queryD2AmountExternalLP(uint256 amountNative) external view returns (uint256);
    function queryD2AmountInternalLP(uint256 amountNative) external view returns (uint256);
    function queryD2AmountOptimal(uint256 amountNative) external view returns (uint256);
    function queryNativeAmount(uint256 d2Amount) external view returns (uint256);
    function queryNativeFromTimeAmount(uint256 timeAmount) external view returns (uint256);
    function queryPoolAddress() external view returns (address);
    function queryPriceNative(uint256 amountNative) external view returns (uint256);
    function queryPriceInverse(uint256 d2Amount) external view returns (uint256);
    function queryRate() external view returns (uint256);
    function queryPublicReward() external view returns (uint256);
    function returnNativeWithoutSharing() external payable returns (bool);
    function splitSharesDinamicallyWithReward() external;
    function tryPoBet(uint256 someNumber) external;
    function buyD2() external payable returns (bool success);
    function sellD2(uint256 d2Amount) external returns (bool success);
    function flashMint(uint256 d2AmountToBorrow, bytes calldata data) external;
    function payFlashMintFee() external payable;
    function poolBalance() external returns (uint256);
}
// SPDX-License-Identifier: MIT
pragma solidity >=0.8.10;

interface ID2HelperBase {
    function addLiquidityD2Native(uint256 d2Amount) external payable returns (bool);
    function addLiquidityD2Sdr() external returns (bool);
    function buyRsd() external payable returns (bool);
    function buySdr() external returns (bool);
    function checkAndPerformArbitrage() external returns (bool);
    function kickBack() external payable;
    function pairD2Eth() external view returns (address);
    function pairD2Sdr() external view returns (address);
    function queryD2AmountFromSdr() external view returns (uint256);
    function queryD2Rate() external view returns (uint256);
    function queryPoolAddress() external view returns (address);
    function setD2(address d2TokenAddress) external;
}
// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

interface IUniswapV2Factory {
    event PairCreated(address indexed token0, address indexed token1, address pair, uint256);

    function feeTo() external view returns (address);
    function feeToSetter() external view returns (address);

    function getPair(address tokenA, address tokenB) external view returns (address pair);
    function allPairs(uint256) external view returns (address pair);
    function allPairsLength() external view returns (uint256);

    function createPair(address tokenA, address tokenB) external returns (address pair);

    function setFeeTo(address) external;
    function setFeeToSetter(address) external;
}
// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import "./IUniswapV2Router01.sol";

interface IUniswapV2Router02 is IUniswapV2Router01 {
    function removeLiquidityETHSupportingFeeOnTransferTokens(
        address token,
        uint256 liquidity,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline
    ) external returns (uint256 amountETH);
    function removeLiquidityETHWithPermitSupportingFeeOnTransferTokens(
        address token,
        uint256 liquidity,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline,
        bool approveMax,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external returns (uint256 amountETH);

    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external;
    function swapExactTokensForTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to
    ) external;
    function swapExactETHForTokensSupportingFeeOnTransferTokens(
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external payable;
    function swapExactAVAXForTokensSupportingFeeOnTransferTokens(
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external payable;
    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external;
    function swapExactTokensForAVAXSupportingFeeOnTransferTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external;
}
// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

interface IUniswapV2Pair {
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

    function MINIMUM_LIQUIDITY() external pure returns (uint256);
    function factory() external view returns (address);
    function token0() external view returns (address);
    function token1() external view returns (address);
    function getReserves() external view returns (uint112 reserve0, uint112 reserve1, uint32 blockTimestampLast);
    function price0CumulativeLast() external view returns (uint256);
    function price1CumulativeLast() external view returns (uint256);
    function kLast() external view returns (uint256);

    function mint(address to) external returns (uint256 liquidity);
    function burn(address to) external returns (uint256 amount0, uint256 amount1);
    function swap(uint256 amount0Out, uint256 amount1Out, address to, bytes calldata data) external;
    function skim(address to) external;
    function sync() external;

    function initialize(address, address) external;
}
// SPDX-License-Identifier: MIT
pragma solidity >=0.5.0;

interface IWETH {
    function approve(address to, uint256 amount) external returns (bool);
    function deposit() external payable;
    function mint(address to, uint256 value) external returns (bool);
    function transfer(address to, uint256 value) external returns (bool);
    function withdraw(uint256) external;
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
pragma solidity >=0.8.0;

interface IUniswapV2Router01 {
    function factory() external pure returns (address);
    function factoryV2() external pure returns (address);
    function WETH() external pure returns (address);
    function WCELO() external pure returns (address);
    function WETH9() external pure returns (address);
    function WAVAX() external pure returns (address);
    function WHT() external pure returns (address);

    function addLiquidity(
        address tokenA,
        address tokenB,
        uint256 amountADesired,
        uint256 amountBDesired,
        uint256 amountAMin,
        uint256 amountBMin,
        address to,
        uint256 deadline
    ) external returns (uint256 amountA, uint256 amountB, uint256 liquidity);
    function addLiquidityETH(
        address token,
        uint256 amountTokenDesired,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline
    ) external payable returns (uint256 amountToken, uint256 amountETH, uint256 liquidity);
    function removeLiquidity(
        address tokenA,
        address tokenB,
        uint256 liquidity,
        uint256 amountAMin,
        uint256 amountBMin,
        address to,
        uint256 deadline
    ) external returns (uint256 amountA, uint256 amountB);
    function removeLiquidityETH(
        address token,
        uint256 liquidity,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline
    ) external returns (uint256 amountToken, uint256 amountETH);
    function removeLiquidityWithPermit(
        address tokenA,
        address tokenB,
        uint256 liquidity,
        uint256 amountAMin,
        uint256 amountBMin,
        address to,
        uint256 deadline,
        bool approveMax,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external returns (uint256 amountA, uint256 amountB);
    function removeLiquidityETHWithPermit(
        address token,
        uint256 liquidity,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline,
        bool approveMax,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external returns (uint256 amountToken, uint256 amountETH);
    function swapExactTokensForTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);
    function swapTokensForExactTokens(
        uint256 amountOut,
        uint256 amountInMax,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);
    function swapExactETHForTokens(uint256 amountOutMin, address[] calldata path, address to, uint256 deadline)
        external
        payable
        returns (uint256[] memory amounts);
    function swapTokensForExactETH(
        uint256 amountOut,
        uint256 amountInMax,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);
    function swapExactTokensForETH(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);
    function swapETHForExactTokens(uint256 amountOut, address[] calldata path, address to, uint256 deadline)
        external
        payable
        returns (uint256[] memory amounts);

    function quote(uint256 amountA, uint256 reserveA, uint256 reserveB) external pure returns (uint256 amountB);
    function getAmountOut(uint256 amountIn, uint256 reserveIn, uint256 reserveOut)
        external
        pure
        returns (uint256 amountOut);
    function getAmountIn(uint256 amountOut, uint256 reserveIn, uint256 reserveOut)
        external
        pure
        returns (uint256 amountIn);
    function getAmountsOut(uint256 amountIn, address[] calldata path)
        external
        view
        returns (uint256[] memory amounts);
    function getAmountsIn(uint256 amountOut, address[] calldata path)
        external
        view
        returns (uint256[] memory amounts);
}
