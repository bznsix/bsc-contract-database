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
// OpenZeppelin Contracts (last updated v4.7.0) (utils/math/SafeCast.sol)

pragma solidity ^0.8.0;

/**
 * @dev Wrappers over Solidity's uintXX/intXX casting operators with added overflow
 * checks.
 *
 * Downcasting from uint256/int256 in Solidity does not revert on overflow. This can
 * easily result in undesired exploitation or bugs, since developers usually
 * assume that overflows raise errors. `SafeCast` restores this intuition by
 * reverting the transaction when such an operation overflows.
 *
 * Using this library instead of the unchecked operations eliminates an entire
 * class of bugs, so it's recommended to use it always.
 *
 * Can be combined with {SafeMath} and {SignedSafeMath} to extend it to smaller types, by performing
 * all math on `uint256` and `int256` and then downcasting.
 */
library SafeCast {
    /**
     * @dev Returns the downcasted uint248 from uint256, reverting on
     * overflow (when the input is greater than largest uint248).
     *
     * Counterpart to Solidity's `uint248` operator.
     *
     * Requirements:
     *
     * - input must fit into 248 bits
     *
     * _Available since v4.7._
     */
    function toUint248(uint256 value) internal pure returns (uint248) {
        require(value <= type(uint248).max, "SafeCast: value doesn't fit in 248 bits");
        return uint248(value);
    }

    /**
     * @dev Returns the downcasted uint240 from uint256, reverting on
     * overflow (when the input is greater than largest uint240).
     *
     * Counterpart to Solidity's `uint240` operator.
     *
     * Requirements:
     *
     * - input must fit into 240 bits
     *
     * _Available since v4.7._
     */
    function toUint240(uint256 value) internal pure returns (uint240) {
        require(value <= type(uint240).max, "SafeCast: value doesn't fit in 240 bits");
        return uint240(value);
    }

    /**
     * @dev Returns the downcasted uint232 from uint256, reverting on
     * overflow (when the input is greater than largest uint232).
     *
     * Counterpart to Solidity's `uint232` operator.
     *
     * Requirements:
     *
     * - input must fit into 232 bits
     *
     * _Available since v4.7._
     */
    function toUint232(uint256 value) internal pure returns (uint232) {
        require(value <= type(uint232).max, "SafeCast: value doesn't fit in 232 bits");
        return uint232(value);
    }

    /**
     * @dev Returns the downcasted uint224 from uint256, reverting on
     * overflow (when the input is greater than largest uint224).
     *
     * Counterpart to Solidity's `uint224` operator.
     *
     * Requirements:
     *
     * - input must fit into 224 bits
     *
     * _Available since v4.2._
     */
    function toUint224(uint256 value) internal pure returns (uint224) {
        require(value <= type(uint224).max, "SafeCast: value doesn't fit in 224 bits");
        return uint224(value);
    }

    /**
     * @dev Returns the downcasted uint216 from uint256, reverting on
     * overflow (when the input is greater than largest uint216).
     *
     * Counterpart to Solidity's `uint216` operator.
     *
     * Requirements:
     *
     * - input must fit into 216 bits
     *
     * _Available since v4.7._
     */
    function toUint216(uint256 value) internal pure returns (uint216) {
        require(value <= type(uint216).max, "SafeCast: value doesn't fit in 216 bits");
        return uint216(value);
    }

    /**
     * @dev Returns the downcasted uint208 from uint256, reverting on
     * overflow (when the input is greater than largest uint208).
     *
     * Counterpart to Solidity's `uint208` operator.
     *
     * Requirements:
     *
     * - input must fit into 208 bits
     *
     * _Available since v4.7._
     */
    function toUint208(uint256 value) internal pure returns (uint208) {
        require(value <= type(uint208).max, "SafeCast: value doesn't fit in 208 bits");
        return uint208(value);
    }

    /**
     * @dev Returns the downcasted uint200 from uint256, reverting on
     * overflow (when the input is greater than largest uint200).
     *
     * Counterpart to Solidity's `uint200` operator.
     *
     * Requirements:
     *
     * - input must fit into 200 bits
     *
     * _Available since v4.7._
     */
    function toUint200(uint256 value) internal pure returns (uint200) {
        require(value <= type(uint200).max, "SafeCast: value doesn't fit in 200 bits");
        return uint200(value);
    }

    /**
     * @dev Returns the downcasted uint192 from uint256, reverting on
     * overflow (when the input is greater than largest uint192).
     *
     * Counterpart to Solidity's `uint192` operator.
     *
     * Requirements:
     *
     * - input must fit into 192 bits
     *
     * _Available since v4.7._
     */
    function toUint192(uint256 value) internal pure returns (uint192) {
        require(value <= type(uint192).max, "SafeCast: value doesn't fit in 192 bits");
        return uint192(value);
    }

    /**
     * @dev Returns the downcasted uint184 from uint256, reverting on
     * overflow (when the input is greater than largest uint184).
     *
     * Counterpart to Solidity's `uint184` operator.
     *
     * Requirements:
     *
     * - input must fit into 184 bits
     *
     * _Available since v4.7._
     */
    function toUint184(uint256 value) internal pure returns (uint184) {
        require(value <= type(uint184).max, "SafeCast: value doesn't fit in 184 bits");
        return uint184(value);
    }

    /**
     * @dev Returns the downcasted uint176 from uint256, reverting on
     * overflow (when the input is greater than largest uint176).
     *
     * Counterpart to Solidity's `uint176` operator.
     *
     * Requirements:
     *
     * - input must fit into 176 bits
     *
     * _Available since v4.7._
     */
    function toUint176(uint256 value) internal pure returns (uint176) {
        require(value <= type(uint176).max, "SafeCast: value doesn't fit in 176 bits");
        return uint176(value);
    }

    /**
     * @dev Returns the downcasted uint168 from uint256, reverting on
     * overflow (when the input is greater than largest uint168).
     *
     * Counterpart to Solidity's `uint168` operator.
     *
     * Requirements:
     *
     * - input must fit into 168 bits
     *
     * _Available since v4.7._
     */
    function toUint168(uint256 value) internal pure returns (uint168) {
        require(value <= type(uint168).max, "SafeCast: value doesn't fit in 168 bits");
        return uint168(value);
    }

    /**
     * @dev Returns the downcasted uint160 from uint256, reverting on
     * overflow (when the input is greater than largest uint160).
     *
     * Counterpart to Solidity's `uint160` operator.
     *
     * Requirements:
     *
     * - input must fit into 160 bits
     *
     * _Available since v4.7._
     */
    function toUint160(uint256 value) internal pure returns (uint160) {
        require(value <= type(uint160).max, "SafeCast: value doesn't fit in 160 bits");
        return uint160(value);
    }

    /**
     * @dev Returns the downcasted uint152 from uint256, reverting on
     * overflow (when the input is greater than largest uint152).
     *
     * Counterpart to Solidity's `uint152` operator.
     *
     * Requirements:
     *
     * - input must fit into 152 bits
     *
     * _Available since v4.7._
     */
    function toUint152(uint256 value) internal pure returns (uint152) {
        require(value <= type(uint152).max, "SafeCast: value doesn't fit in 152 bits");
        return uint152(value);
    }

    /**
     * @dev Returns the downcasted uint144 from uint256, reverting on
     * overflow (when the input is greater than largest uint144).
     *
     * Counterpart to Solidity's `uint144` operator.
     *
     * Requirements:
     *
     * - input must fit into 144 bits
     *
     * _Available since v4.7._
     */
    function toUint144(uint256 value) internal pure returns (uint144) {
        require(value <= type(uint144).max, "SafeCast: value doesn't fit in 144 bits");
        return uint144(value);
    }

    /**
     * @dev Returns the downcasted uint136 from uint256, reverting on
     * overflow (when the input is greater than largest uint136).
     *
     * Counterpart to Solidity's `uint136` operator.
     *
     * Requirements:
     *
     * - input must fit into 136 bits
     *
     * _Available since v4.7._
     */
    function toUint136(uint256 value) internal pure returns (uint136) {
        require(value <= type(uint136).max, "SafeCast: value doesn't fit in 136 bits");
        return uint136(value);
    }

    /**
     * @dev Returns the downcasted uint128 from uint256, reverting on
     * overflow (when the input is greater than largest uint128).
     *
     * Counterpart to Solidity's `uint128` operator.
     *
     * Requirements:
     *
     * - input must fit into 128 bits
     *
     * _Available since v2.5._
     */
    function toUint128(uint256 value) internal pure returns (uint128) {
        require(value <= type(uint128).max, "SafeCast: value doesn't fit in 128 bits");
        return uint128(value);
    }

    /**
     * @dev Returns the downcasted uint120 from uint256, reverting on
     * overflow (when the input is greater than largest uint120).
     *
     * Counterpart to Solidity's `uint120` operator.
     *
     * Requirements:
     *
     * - input must fit into 120 bits
     *
     * _Available since v4.7._
     */
    function toUint120(uint256 value) internal pure returns (uint120) {
        require(value <= type(uint120).max, "SafeCast: value doesn't fit in 120 bits");
        return uint120(value);
    }

    /**
     * @dev Returns the downcasted uint112 from uint256, reverting on
     * overflow (when the input is greater than largest uint112).
     *
     * Counterpart to Solidity's `uint112` operator.
     *
     * Requirements:
     *
     * - input must fit into 112 bits
     *
     * _Available since v4.7._
     */
    function toUint112(uint256 value) internal pure returns (uint112) {
        require(value <= type(uint112).max, "SafeCast: value doesn't fit in 112 bits");
        return uint112(value);
    }

    /**
     * @dev Returns the downcasted uint104 from uint256, reverting on
     * overflow (when the input is greater than largest uint104).
     *
     * Counterpart to Solidity's `uint104` operator.
     *
     * Requirements:
     *
     * - input must fit into 104 bits
     *
     * _Available since v4.7._
     */
    function toUint104(uint256 value) internal pure returns (uint104) {
        require(value <= type(uint104).max, "SafeCast: value doesn't fit in 104 bits");
        return uint104(value);
    }

    /**
     * @dev Returns the downcasted uint96 from uint256, reverting on
     * overflow (when the input is greater than largest uint96).
     *
     * Counterpart to Solidity's `uint96` operator.
     *
     * Requirements:
     *
     * - input must fit into 96 bits
     *
     * _Available since v4.2._
     */
    function toUint96(uint256 value) internal pure returns (uint96) {
        require(value <= type(uint96).max, "SafeCast: value doesn't fit in 96 bits");
        return uint96(value);
    }

    /**
     * @dev Returns the downcasted uint88 from uint256, reverting on
     * overflow (when the input is greater than largest uint88).
     *
     * Counterpart to Solidity's `uint88` operator.
     *
     * Requirements:
     *
     * - input must fit into 88 bits
     *
     * _Available since v4.7._
     */
    function toUint88(uint256 value) internal pure returns (uint88) {
        require(value <= type(uint88).max, "SafeCast: value doesn't fit in 88 bits");
        return uint88(value);
    }

    /**
     * @dev Returns the downcasted uint80 from uint256, reverting on
     * overflow (when the input is greater than largest uint80).
     *
     * Counterpart to Solidity's `uint80` operator.
     *
     * Requirements:
     *
     * - input must fit into 80 bits
     *
     * _Available since v4.7._
     */
    function toUint80(uint256 value) internal pure returns (uint80) {
        require(value <= type(uint80).max, "SafeCast: value doesn't fit in 80 bits");
        return uint80(value);
    }

    /**
     * @dev Returns the downcasted uint72 from uint256, reverting on
     * overflow (when the input is greater than largest uint72).
     *
     * Counterpart to Solidity's `uint72` operator.
     *
     * Requirements:
     *
     * - input must fit into 72 bits
     *
     * _Available since v4.7._
     */
    function toUint72(uint256 value) internal pure returns (uint72) {
        require(value <= type(uint72).max, "SafeCast: value doesn't fit in 72 bits");
        return uint72(value);
    }

    /**
     * @dev Returns the downcasted uint64 from uint256, reverting on
     * overflow (when the input is greater than largest uint64).
     *
     * Counterpart to Solidity's `uint64` operator.
     *
     * Requirements:
     *
     * - input must fit into 64 bits
     *
     * _Available since v2.5._
     */
    function toUint64(uint256 value) internal pure returns (uint64) {
        require(value <= type(uint64).max, "SafeCast: value doesn't fit in 64 bits");
        return uint64(value);
    }

    /**
     * @dev Returns the downcasted uint56 from uint256, reverting on
     * overflow (when the input is greater than largest uint56).
     *
     * Counterpart to Solidity's `uint56` operator.
     *
     * Requirements:
     *
     * - input must fit into 56 bits
     *
     * _Available since v4.7._
     */
    function toUint56(uint256 value) internal pure returns (uint56) {
        require(value <= type(uint56).max, "SafeCast: value doesn't fit in 56 bits");
        return uint56(value);
    }

    /**
     * @dev Returns the downcasted uint48 from uint256, reverting on
     * overflow (when the input is greater than largest uint48).
     *
     * Counterpart to Solidity's `uint48` operator.
     *
     * Requirements:
     *
     * - input must fit into 48 bits
     *
     * _Available since v4.7._
     */
    function toUint48(uint256 value) internal pure returns (uint48) {
        require(value <= type(uint48).max, "SafeCast: value doesn't fit in 48 bits");
        return uint48(value);
    }

    /**
     * @dev Returns the downcasted uint40 from uint256, reverting on
     * overflow (when the input is greater than largest uint40).
     *
     * Counterpart to Solidity's `uint40` operator.
     *
     * Requirements:
     *
     * - input must fit into 40 bits
     *
     * _Available since v4.7._
     */
    function toUint40(uint256 value) internal pure returns (uint40) {
        require(value <= type(uint40).max, "SafeCast: value doesn't fit in 40 bits");
        return uint40(value);
    }

    /**
     * @dev Returns the downcasted uint32 from uint256, reverting on
     * overflow (when the input is greater than largest uint32).
     *
     * Counterpart to Solidity's `uint32` operator.
     *
     * Requirements:
     *
     * - input must fit into 32 bits
     *
     * _Available since v2.5._
     */
    function toUint32(uint256 value) internal pure returns (uint32) {
        require(value <= type(uint32).max, "SafeCast: value doesn't fit in 32 bits");
        return uint32(value);
    }

    /**
     * @dev Returns the downcasted uint24 from uint256, reverting on
     * overflow (when the input is greater than largest uint24).
     *
     * Counterpart to Solidity's `uint24` operator.
     *
     * Requirements:
     *
     * - input must fit into 24 bits
     *
     * _Available since v4.7._
     */
    function toUint24(uint256 value) internal pure returns (uint24) {
        require(value <= type(uint24).max, "SafeCast: value doesn't fit in 24 bits");
        return uint24(value);
    }

    /**
     * @dev Returns the downcasted uint16 from uint256, reverting on
     * overflow (when the input is greater than largest uint16).
     *
     * Counterpart to Solidity's `uint16` operator.
     *
     * Requirements:
     *
     * - input must fit into 16 bits
     *
     * _Available since v2.5._
     */
    function toUint16(uint256 value) internal pure returns (uint16) {
        require(value <= type(uint16).max, "SafeCast: value doesn't fit in 16 bits");
        return uint16(value);
    }

    /**
     * @dev Returns the downcasted uint8 from uint256, reverting on
     * overflow (when the input is greater than largest uint8).
     *
     * Counterpart to Solidity's `uint8` operator.
     *
     * Requirements:
     *
     * - input must fit into 8 bits
     *
     * _Available since v2.5._
     */
    function toUint8(uint256 value) internal pure returns (uint8) {
        require(value <= type(uint8).max, "SafeCast: value doesn't fit in 8 bits");
        return uint8(value);
    }

    /**
     * @dev Converts a signed int256 into an unsigned uint256.
     *
     * Requirements:
     *
     * - input must be greater than or equal to 0.
     *
     * _Available since v3.0._
     */
    function toUint256(int256 value) internal pure returns (uint256) {
        require(value >= 0, "SafeCast: value must be positive");
        return uint256(value);
    }

    /**
     * @dev Returns the downcasted int248 from int256, reverting on
     * overflow (when the input is less than smallest int248 or
     * greater than largest int248).
     *
     * Counterpart to Solidity's `int248` operator.
     *
     * Requirements:
     *
     * - input must fit into 248 bits
     *
     * _Available since v4.7._
     */
    function toInt248(int256 value) internal pure returns (int248) {
        require(value >= type(int248).min && value <= type(int248).max, "SafeCast: value doesn't fit in 248 bits");
        return int248(value);
    }

    /**
     * @dev Returns the downcasted int240 from int256, reverting on
     * overflow (when the input is less than smallest int240 or
     * greater than largest int240).
     *
     * Counterpart to Solidity's `int240` operator.
     *
     * Requirements:
     *
     * - input must fit into 240 bits
     *
     * _Available since v4.7._
     */
    function toInt240(int256 value) internal pure returns (int240) {
        require(value >= type(int240).min && value <= type(int240).max, "SafeCast: value doesn't fit in 240 bits");
        return int240(value);
    }

    /**
     * @dev Returns the downcasted int232 from int256, reverting on
     * overflow (when the input is less than smallest int232 or
     * greater than largest int232).
     *
     * Counterpart to Solidity's `int232` operator.
     *
     * Requirements:
     *
     * - input must fit into 232 bits
     *
     * _Available since v4.7._
     */
    function toInt232(int256 value) internal pure returns (int232) {
        require(value >= type(int232).min && value <= type(int232).max, "SafeCast: value doesn't fit in 232 bits");
        return int232(value);
    }

    /**
     * @dev Returns the downcasted int224 from int256, reverting on
     * overflow (when the input is less than smallest int224 or
     * greater than largest int224).
     *
     * Counterpart to Solidity's `int224` operator.
     *
     * Requirements:
     *
     * - input must fit into 224 bits
     *
     * _Available since v4.7._
     */
    function toInt224(int256 value) internal pure returns (int224) {
        require(value >= type(int224).min && value <= type(int224).max, "SafeCast: value doesn't fit in 224 bits");
        return int224(value);
    }

    /**
     * @dev Returns the downcasted int216 from int256, reverting on
     * overflow (when the input is less than smallest int216 or
     * greater than largest int216).
     *
     * Counterpart to Solidity's `int216` operator.
     *
     * Requirements:
     *
     * - input must fit into 216 bits
     *
     * _Available since v4.7._
     */
    function toInt216(int256 value) internal pure returns (int216) {
        require(value >= type(int216).min && value <= type(int216).max, "SafeCast: value doesn't fit in 216 bits");
        return int216(value);
    }

    /**
     * @dev Returns the downcasted int208 from int256, reverting on
     * overflow (when the input is less than smallest int208 or
     * greater than largest int208).
     *
     * Counterpart to Solidity's `int208` operator.
     *
     * Requirements:
     *
     * - input must fit into 208 bits
     *
     * _Available since v4.7._
     */
    function toInt208(int256 value) internal pure returns (int208) {
        require(value >= type(int208).min && value <= type(int208).max, "SafeCast: value doesn't fit in 208 bits");
        return int208(value);
    }

    /**
     * @dev Returns the downcasted int200 from int256, reverting on
     * overflow (when the input is less than smallest int200 or
     * greater than largest int200).
     *
     * Counterpart to Solidity's `int200` operator.
     *
     * Requirements:
     *
     * - input must fit into 200 bits
     *
     * _Available since v4.7._
     */
    function toInt200(int256 value) internal pure returns (int200) {
        require(value >= type(int200).min && value <= type(int200).max, "SafeCast: value doesn't fit in 200 bits");
        return int200(value);
    }

    /**
     * @dev Returns the downcasted int192 from int256, reverting on
     * overflow (when the input is less than smallest int192 or
     * greater than largest int192).
     *
     * Counterpart to Solidity's `int192` operator.
     *
     * Requirements:
     *
     * - input must fit into 192 bits
     *
     * _Available since v4.7._
     */
    function toInt192(int256 value) internal pure returns (int192) {
        require(value >= type(int192).min && value <= type(int192).max, "SafeCast: value doesn't fit in 192 bits");
        return int192(value);
    }

    /**
     * @dev Returns the downcasted int184 from int256, reverting on
     * overflow (when the input is less than smallest int184 or
     * greater than largest int184).
     *
     * Counterpart to Solidity's `int184` operator.
     *
     * Requirements:
     *
     * - input must fit into 184 bits
     *
     * _Available since v4.7._
     */
    function toInt184(int256 value) internal pure returns (int184) {
        require(value >= type(int184).min && value <= type(int184).max, "SafeCast: value doesn't fit in 184 bits");
        return int184(value);
    }

    /**
     * @dev Returns the downcasted int176 from int256, reverting on
     * overflow (when the input is less than smallest int176 or
     * greater than largest int176).
     *
     * Counterpart to Solidity's `int176` operator.
     *
     * Requirements:
     *
     * - input must fit into 176 bits
     *
     * _Available since v4.7._
     */
    function toInt176(int256 value) internal pure returns (int176) {
        require(value >= type(int176).min && value <= type(int176).max, "SafeCast: value doesn't fit in 176 bits");
        return int176(value);
    }

    /**
     * @dev Returns the downcasted int168 from int256, reverting on
     * overflow (when the input is less than smallest int168 or
     * greater than largest int168).
     *
     * Counterpart to Solidity's `int168` operator.
     *
     * Requirements:
     *
     * - input must fit into 168 bits
     *
     * _Available since v4.7._
     */
    function toInt168(int256 value) internal pure returns (int168) {
        require(value >= type(int168).min && value <= type(int168).max, "SafeCast: value doesn't fit in 168 bits");
        return int168(value);
    }

    /**
     * @dev Returns the downcasted int160 from int256, reverting on
     * overflow (when the input is less than smallest int160 or
     * greater than largest int160).
     *
     * Counterpart to Solidity's `int160` operator.
     *
     * Requirements:
     *
     * - input must fit into 160 bits
     *
     * _Available since v4.7._
     */
    function toInt160(int256 value) internal pure returns (int160) {
        require(value >= type(int160).min && value <= type(int160).max, "SafeCast: value doesn't fit in 160 bits");
        return int160(value);
    }

    /**
     * @dev Returns the downcasted int152 from int256, reverting on
     * overflow (when the input is less than smallest int152 or
     * greater than largest int152).
     *
     * Counterpart to Solidity's `int152` operator.
     *
     * Requirements:
     *
     * - input must fit into 152 bits
     *
     * _Available since v4.7._
     */
    function toInt152(int256 value) internal pure returns (int152) {
        require(value >= type(int152).min && value <= type(int152).max, "SafeCast: value doesn't fit in 152 bits");
        return int152(value);
    }

    /**
     * @dev Returns the downcasted int144 from int256, reverting on
     * overflow (when the input is less than smallest int144 or
     * greater than largest int144).
     *
     * Counterpart to Solidity's `int144` operator.
     *
     * Requirements:
     *
     * - input must fit into 144 bits
     *
     * _Available since v4.7._
     */
    function toInt144(int256 value) internal pure returns (int144) {
        require(value >= type(int144).min && value <= type(int144).max, "SafeCast: value doesn't fit in 144 bits");
        return int144(value);
    }

    /**
     * @dev Returns the downcasted int136 from int256, reverting on
     * overflow (when the input is less than smallest int136 or
     * greater than largest int136).
     *
     * Counterpart to Solidity's `int136` operator.
     *
     * Requirements:
     *
     * - input must fit into 136 bits
     *
     * _Available since v4.7._
     */
    function toInt136(int256 value) internal pure returns (int136) {
        require(value >= type(int136).min && value <= type(int136).max, "SafeCast: value doesn't fit in 136 bits");
        return int136(value);
    }

    /**
     * @dev Returns the downcasted int128 from int256, reverting on
     * overflow (when the input is less than smallest int128 or
     * greater than largest int128).
     *
     * Counterpart to Solidity's `int128` operator.
     *
     * Requirements:
     *
     * - input must fit into 128 bits
     *
     * _Available since v3.1._
     */
    function toInt128(int256 value) internal pure returns (int128) {
        require(value >= type(int128).min && value <= type(int128).max, "SafeCast: value doesn't fit in 128 bits");
        return int128(value);
    }

    /**
     * @dev Returns the downcasted int120 from int256, reverting on
     * overflow (when the input is less than smallest int120 or
     * greater than largest int120).
     *
     * Counterpart to Solidity's `int120` operator.
     *
     * Requirements:
     *
     * - input must fit into 120 bits
     *
     * _Available since v4.7._
     */
    function toInt120(int256 value) internal pure returns (int120) {
        require(value >= type(int120).min && value <= type(int120).max, "SafeCast: value doesn't fit in 120 bits");
        return int120(value);
    }

    /**
     * @dev Returns the downcasted int112 from int256, reverting on
     * overflow (when the input is less than smallest int112 or
     * greater than largest int112).
     *
     * Counterpart to Solidity's `int112` operator.
     *
     * Requirements:
     *
     * - input must fit into 112 bits
     *
     * _Available since v4.7._
     */
    function toInt112(int256 value) internal pure returns (int112) {
        require(value >= type(int112).min && value <= type(int112).max, "SafeCast: value doesn't fit in 112 bits");
        return int112(value);
    }

    /**
     * @dev Returns the downcasted int104 from int256, reverting on
     * overflow (when the input is less than smallest int104 or
     * greater than largest int104).
     *
     * Counterpart to Solidity's `int104` operator.
     *
     * Requirements:
     *
     * - input must fit into 104 bits
     *
     * _Available since v4.7._
     */
    function toInt104(int256 value) internal pure returns (int104) {
        require(value >= type(int104).min && value <= type(int104).max, "SafeCast: value doesn't fit in 104 bits");
        return int104(value);
    }

    /**
     * @dev Returns the downcasted int96 from int256, reverting on
     * overflow (when the input is less than smallest int96 or
     * greater than largest int96).
     *
     * Counterpart to Solidity's `int96` operator.
     *
     * Requirements:
     *
     * - input must fit into 96 bits
     *
     * _Available since v4.7._
     */
    function toInt96(int256 value) internal pure returns (int96) {
        require(value >= type(int96).min && value <= type(int96).max, "SafeCast: value doesn't fit in 96 bits");
        return int96(value);
    }

    /**
     * @dev Returns the downcasted int88 from int256, reverting on
     * overflow (when the input is less than smallest int88 or
     * greater than largest int88).
     *
     * Counterpart to Solidity's `int88` operator.
     *
     * Requirements:
     *
     * - input must fit into 88 bits
     *
     * _Available since v4.7._
     */
    function toInt88(int256 value) internal pure returns (int88) {
        require(value >= type(int88).min && value <= type(int88).max, "SafeCast: value doesn't fit in 88 bits");
        return int88(value);
    }

    /**
     * @dev Returns the downcasted int80 from int256, reverting on
     * overflow (when the input is less than smallest int80 or
     * greater than largest int80).
     *
     * Counterpart to Solidity's `int80` operator.
     *
     * Requirements:
     *
     * - input must fit into 80 bits
     *
     * _Available since v4.7._
     */
    function toInt80(int256 value) internal pure returns (int80) {
        require(value >= type(int80).min && value <= type(int80).max, "SafeCast: value doesn't fit in 80 bits");
        return int80(value);
    }

    /**
     * @dev Returns the downcasted int72 from int256, reverting on
     * overflow (when the input is less than smallest int72 or
     * greater than largest int72).
     *
     * Counterpart to Solidity's `int72` operator.
     *
     * Requirements:
     *
     * - input must fit into 72 bits
     *
     * _Available since v4.7._
     */
    function toInt72(int256 value) internal pure returns (int72) {
        require(value >= type(int72).min && value <= type(int72).max, "SafeCast: value doesn't fit in 72 bits");
        return int72(value);
    }

    /**
     * @dev Returns the downcasted int64 from int256, reverting on
     * overflow (when the input is less than smallest int64 or
     * greater than largest int64).
     *
     * Counterpart to Solidity's `int64` operator.
     *
     * Requirements:
     *
     * - input must fit into 64 bits
     *
     * _Available since v3.1._
     */
    function toInt64(int256 value) internal pure returns (int64) {
        require(value >= type(int64).min && value <= type(int64).max, "SafeCast: value doesn't fit in 64 bits");
        return int64(value);
    }

    /**
     * @dev Returns the downcasted int56 from int256, reverting on
     * overflow (when the input is less than smallest int56 or
     * greater than largest int56).
     *
     * Counterpart to Solidity's `int56` operator.
     *
     * Requirements:
     *
     * - input must fit into 56 bits
     *
     * _Available since v4.7._
     */
    function toInt56(int256 value) internal pure returns (int56) {
        require(value >= type(int56).min && value <= type(int56).max, "SafeCast: value doesn't fit in 56 bits");
        return int56(value);
    }

    /**
     * @dev Returns the downcasted int48 from int256, reverting on
     * overflow (when the input is less than smallest int48 or
     * greater than largest int48).
     *
     * Counterpart to Solidity's `int48` operator.
     *
     * Requirements:
     *
     * - input must fit into 48 bits
     *
     * _Available since v4.7._
     */
    function toInt48(int256 value) internal pure returns (int48) {
        require(value >= type(int48).min && value <= type(int48).max, "SafeCast: value doesn't fit in 48 bits");
        return int48(value);
    }

    /**
     * @dev Returns the downcasted int40 from int256, reverting on
     * overflow (when the input is less than smallest int40 or
     * greater than largest int40).
     *
     * Counterpart to Solidity's `int40` operator.
     *
     * Requirements:
     *
     * - input must fit into 40 bits
     *
     * _Available since v4.7._
     */
    function toInt40(int256 value) internal pure returns (int40) {
        require(value >= type(int40).min && value <= type(int40).max, "SafeCast: value doesn't fit in 40 bits");
        return int40(value);
    }

    /**
     * @dev Returns the downcasted int32 from int256, reverting on
     * overflow (when the input is less than smallest int32 or
     * greater than largest int32).
     *
     * Counterpart to Solidity's `int32` operator.
     *
     * Requirements:
     *
     * - input must fit into 32 bits
     *
     * _Available since v3.1._
     */
    function toInt32(int256 value) internal pure returns (int32) {
        require(value >= type(int32).min && value <= type(int32).max, "SafeCast: value doesn't fit in 32 bits");
        return int32(value);
    }

    /**
     * @dev Returns the downcasted int24 from int256, reverting on
     * overflow (when the input is less than smallest int24 or
     * greater than largest int24).
     *
     * Counterpart to Solidity's `int24` operator.
     *
     * Requirements:
     *
     * - input must fit into 24 bits
     *
     * _Available since v4.7._
     */
    function toInt24(int256 value) internal pure returns (int24) {
        require(value >= type(int24).min && value <= type(int24).max, "SafeCast: value doesn't fit in 24 bits");
        return int24(value);
    }

    /**
     * @dev Returns the downcasted int16 from int256, reverting on
     * overflow (when the input is less than smallest int16 or
     * greater than largest int16).
     *
     * Counterpart to Solidity's `int16` operator.
     *
     * Requirements:
     *
     * - input must fit into 16 bits
     *
     * _Available since v3.1._
     */
    function toInt16(int256 value) internal pure returns (int16) {
        require(value >= type(int16).min && value <= type(int16).max, "SafeCast: value doesn't fit in 16 bits");
        return int16(value);
    }

    /**
     * @dev Returns the downcasted int8 from int256, reverting on
     * overflow (when the input is less than smallest int8 or
     * greater than largest int8).
     *
     * Counterpart to Solidity's `int8` operator.
     *
     * Requirements:
     *
     * - input must fit into 8 bits
     *
     * _Available since v3.1._
     */
    function toInt8(int256 value) internal pure returns (int8) {
        require(value >= type(int8).min && value <= type(int8).max, "SafeCast: value doesn't fit in 8 bits");
        return int8(value);
    }

    /**
     * @dev Converts an unsigned uint256 into a signed int256.
     *
     * Requirements:
     *
     * - input must be less than or equal to maxInt256.
     *
     * _Available since v3.0._
     */
    function toInt256(uint256 value) internal pure returns (int256) {
        // Note: Unsafe cast below is okay because `type(int256).max` is guaranteed to be positive
        require(value <= uint256(type(int256).max), "SafeCast: value doesn't fit in an int256");
        return int256(value);
    }
}
// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.17;

/**
 * @title Mosaic Alpha Governance contract
 * @author dlabs.hu
 * @dev This contract is for handling governance and configuration changes
 */

import "../Interfaces/IVault.sol";
import "../Interfaces/IAffiliate.sol";
import "../Interfaces/IGoverned.sol";

contract Governance {

mapping(address => uint256) public curator_proportions;                             // Proportions of the curators
address[] public governedContracts;                                                 // The governed addresses

/* ConfManager system mappings and vars */
mapping(string => config_struct) public Configuration;
mapping(string => config_struct) public invoteConfiguration;
mapping(uint256 => string) public ID_to_name;

mapping(address => uint256) public conf_curator_timer;                           // Last action time by curator for locking
mapping(uint256 => uint256) public conf_votes;                                   // ID to see if threshold is passed
mapping(uint256 => uint256) public conf_time_limit;                              // Actions needs to be triggered in time
uint256 public conf_counter = 6;                                                 // Starting from 6+1, 0-6 are reserved for global config

struct config_struct {
  string name;
  bool Running;
  address govaddr;
  address[] managers;
  bool[] boolslot;
  address[] address_slot;
  uint256[] uint256_slot;
  bytes32[] bytes32_slot;
}

mapping(uint256 => bool) public triggered;                                          // If true, it was triggered before and will be blocked
string constant Core = "Main";                                                               // Core string for consistency

/* Action manager system mappings */
mapping(address => uint256) public action_curator_timer;                            // Last action time by curator for locking
mapping(uint256 => uint256) public action_id_to_vote;                               // ID to see if threshold is passed
mapping(uint256 => uint256) public action_time_limit;                               // Actions needs to be triggered in time
mapping(uint256 => address) public action_can_be_triggered_by;                      // Address which can trigger the action after threshold is passed

/* This is used to store calldata and make it takeable from external contracts.
@dev be careful with this, low level calls can be tricky. */
mapping(uint256 => bytes) public action_id_to_calldata;                             // Mapping actions to relevant calldata.

// Action threshold and time limit, so the community can react to changes
uint256 public action_threshold;                                                    // This threshold needs to be passed for action to happen
uint256 public vote_time_threshold;                                                 // You can only vote once per timer - this is for security and gas optimization
uint256 public vote_conf_time_threshold;                                            // Config

event Transfer_Proportion(uint256 beneficiary_proportion);
event Action_Proposed(uint256 id);
event Action_Support(uint256 id);
event Action_Trigger(uint256 id);
event Config_Proposed(string name);
event Config_Supported(string name);

modifier onlyCurators(){
  require(curator_proportions[msg.sender] > 0, "Not a curator");
  _;
}

// The Governance contract needs to be deployed first, before all
// Max proportions are 100, shared among curators
 constructor(
    address[] memory _curators,
    uint256[] memory _curator_proportions,
    address[] memory _managers
) {
    action_threshold = 30;                                        // Threshold -> from this, configs and actions can be triggered
    vote_time_threshold = 600;                                    // Onc conf change per 10 mins, in v2 we can make it longer
    vote_conf_time_threshold = 0;

    require(_curators.length == _curator_proportions.length, "Curators and proportions length mismatch");

    uint totalProp;
    for (uint256 i = 0; i < _curators.length; i++) {
        curator_proportions[_curators[i]] = _curator_proportions[i];
        totalProp += _curator_proportions[i];
    }

    require(totalProp == 100, "Total proportions must be 100");

    ID_to_name[0] = Core;                                         // Core config init
    core_govAddr_conf(address(this));                             // Global governance address
    core_emergency_conf();                                        // Emergency stop value is enforced to be Running==true from start.
    core_managers_conf(_managers);
}

// Core functions, only used during init
function core_govAddr_conf(address _address) private {
    Configuration[Core].name = Core;
    Configuration[Core].govaddr = _address;}

function core_emergency_conf() private {
    Configuration[Core].Running = true;}

function core_managers_conf(address[] memory _addresses) private {
    Configuration[Core].managers = _addresses;
    address[] storage addGovAddr = Configuration[Core].managers; // Constructor memory -> Storage
    addGovAddr.push(address(this));
    Configuration[Core].managers = addGovAddr;
    }

// Only the addresses on the manager list are allowed to execute
function onlyManagers() internal view {
      bool ok;
          address [] memory tempman =  read_core_managers();
          for (uint i=0; i < tempman.length; i++) {
              if (tempman[i] == msg.sender) {ok = true;}
          }
          if (ok == true){} else {revert("0");} //Not manager*/
}

bool public deployed = false;
function setToDeployed() public returns (bool) {
  onlyManagers();
  deployed = true;
  return deployed;
}

function ActivateDeployedMosaic(
    address _userProfile,
    address _affiliate,
    address _fees,
    address _register,
    address _poolFactory,
    address _feeTo,
    address _swapsContract,
    address _oracle,
    address _deposit,
    address _burner,
    address _booster
) public {
    onlyManagers();
    require(deployed == false, "It is done.");

        Configuration[Core].address_slot.push(msg.sender); //0 owner
        Configuration[Core].address_slot.push(_userProfile); //1
        Configuration[Core].address_slot.push(_affiliate); //2
        Configuration[Core].address_slot.push(_fees); //3
        Configuration[Core].address_slot.push(_register); //4
        Configuration[Core].address_slot.push(_poolFactory); //5
        Configuration[Core].address_slot.push(_feeTo); //6 - duplicate? fees and feeToo are same?
        Configuration[Core].address_slot.push(_swapsContract); //7
        Configuration[Core].address_slot.push(_oracle); //8
        Configuration[Core].address_slot.push(_deposit); //9
        Configuration[Core].address_slot.push(_burner); //10
        Configuration[Core].address_slot.push(_booster); //11

        IAffiliate(_affiliate).selfManageMe();
}

/* Transfer proportion */
function transfer_proportion(address _address, uint256 _amount) external returns (uint256) {
    require(curator_proportions[msg.sender] >= _amount, "Not enough proportions");
    require(block.timestamp >= action_curator_timer[msg.sender] + vote_time_threshold, "Not yet, your votes need to conclude");
    action_curator_timer[msg.sender] = block.timestamp;
    curator_proportions[msg.sender] = curator_proportions[msg.sender] - _amount;
    curator_proportions[_address] = curator_proportions[_address] + _amount;
    emit Transfer_Proportion(curator_proportions[_address]);
    return curator_proportions[_address];
  }

/* Configuration manager */

// Add or update config.
function update_config(string memory _name,
  bool _Running,
  address _govaddr,
  address[] memory _managers,
  bool[] memory _boolslot,
  address[] memory _address_slot,
  uint256[] memory _uint256_slot,
  bytes32[] memory _bytes32_slot
  ) internal returns (string memory){
  Configuration[_name].name = _name;
  Configuration[_name].Running = _Running;
  Configuration[_name].govaddr = _govaddr;
  Configuration[_name].managers = _managers;
  Configuration[_name].boolslot = _boolslot;
  Configuration[_name].address_slot = _address_slot;
  Configuration[_name].uint256_slot = _uint256_slot;
  Configuration[_name].bytes32_slot = _bytes32_slot;
  return _name;
}

// Create temp configuration
function votein_config(string memory _name,
  bool _Running,
  address _govaddr,
  address[] memory _managers,
  bool[] memory _boolslot,
  address[] memory _address_slot,
  uint256[] memory _uint256_slot,
  bytes32[] memory _bytes32_slot
) internal returns (string memory){
  invoteConfiguration[_name].name = _name;
  invoteConfiguration[_name].Running = _Running;
  invoteConfiguration[_name].govaddr = _govaddr;
  invoteConfiguration[_name].managers = _managers;
  invoteConfiguration[_name].boolslot = _boolslot;
  invoteConfiguration[_name].address_slot = _address_slot;
  invoteConfiguration[_name].uint256_slot = _uint256_slot;
  invoteConfiguration[_name].bytes32_slot = _bytes32_slot;
  return _name;
}

// Propose config
function propose_config(
  string memory _name,
  bool _Running,
  address _govaddr,
  address[] memory _managers,
  bool[] memory _boolslot,
  address[] memory _address_slot,
  uint256[] memory _uint256_slot,
  bytes32[] memory _bytes32_slot
) external returns (uint256) {
    require(curator_proportions[msg.sender] > 0, "You are not a curator");
    require(block.timestamp >= conf_curator_timer[msg.sender] + vote_conf_time_threshold, "Curator timer not yet expired");
    conf_counter = conf_counter + 1;
    require(conf_time_limit[conf_counter] == 0, "In progress");
    conf_curator_timer[msg.sender] = block.timestamp;
    conf_time_limit[conf_counter] = block.timestamp + vote_time_threshold;
    conf_votes[conf_counter] = curator_proportions[msg.sender];
    ID_to_name[conf_counter] = _name;
    triggered[conf_counter] = false; // It keep rising, so can't be overwritten from true in past value
    votein_config(
        _name,
        _Running,
        _govaddr,
        _managers,
        _boolslot,
        _address_slot,
        _uint256_slot,
        _bytes32_slot
    );
    emit Config_Proposed(_name);
    return conf_counter;
  }

// Use this with caution!
function propose_core_change(address _govaddr, bool _Running, address[] memory _managers, address[] memory _owners) external returns (uint256) {
    require(curator_proportions[msg.sender] > 0, "You are not a curator");
    require(block.timestamp >= conf_curator_timer[msg.sender] + vote_conf_time_threshold, "Curator timer not yet expired");
    require(conf_time_limit[conf_counter] == 0, "In progress");
    conf_curator_timer[msg.sender] = block.timestamp;
    conf_time_limit[conf_counter] = block.timestamp + vote_time_threshold;
    conf_votes[conf_counter] = curator_proportions[msg.sender];
    ID_to_name[conf_counter] = Core;
    triggered[conf_counter] = false; // It keep rising, so can't be overwritten from true in past value

    invoteConfiguration[Core].name = Core;
    invoteConfiguration[Core].govaddr = _govaddr;
    invoteConfiguration[Core].Running = _Running;
    invoteConfiguration[Core].managers = _managers;
    invoteConfiguration[Core].address_slot = _owners;
    return conf_counter;
}

// ID and name are requested together for supporting a config because of awareness.
function support_config_proposal(uint256 _confCount, string memory _name) external returns (string memory) {
  require(curator_proportions[msg.sender] > 0, "You are not a curator");
  require(block.timestamp >= conf_curator_timer[msg.sender] + vote_conf_time_threshold, "Curator timer not yet expired");
  require(conf_time_limit[_confCount] > block.timestamp, "Timed out");
  require(conf_time_limit[_confCount] != 0, "Not started");
  require(keccak256(abi.encodePacked(ID_to_name[_confCount])) == keccak256(abi.encodePacked(_name)), "You are not aware, Neo.");
  conf_curator_timer[msg.sender] = block.timestamp;
  conf_votes[_confCount] = conf_votes[_confCount] + curator_proportions[msg.sender];
  if (conf_votes[_confCount] >= action_threshold && triggered[_confCount] == false) {
    triggered[_confCount] = true;
    string memory name = ID_to_name[_confCount];
    update_config(
    invoteConfiguration[name].name,
    invoteConfiguration[name].Running,
    invoteConfiguration[name].govaddr,
    invoteConfiguration[name].managers,
    invoteConfiguration[name].boolslot,
    invoteConfiguration[name].address_slot,
    invoteConfiguration[name].uint256_slot,
    invoteConfiguration[name].bytes32_slot
    );

    delete invoteConfiguration[name].name;
    delete invoteConfiguration[name].Running;
    delete invoteConfiguration[name].govaddr;
    delete invoteConfiguration[name].managers;
    delete invoteConfiguration[name].boolslot;
    delete invoteConfiguration[name].address_slot;
    delete invoteConfiguration[name].uint256_slot;
    delete invoteConfiguration[name].bytes32_slot;

    conf_votes[_confCount] = 0;
  }
  emit Config_Supported(_name);
  return Configuration[_name].name = _name;
}

/* Read configurations */

function read_core_Running() public view returns (bool) {return Configuration[Core].Running;}
function read_core_govAddr() public view returns (address) {return Configuration[Core].govaddr;}
function read_core_managers() public view returns (address[] memory) {return Configuration[Core].managers;}
function read_core_owners() public view returns (address[] memory) {return Configuration[Core].address_slot;}

function read_config_Main_addressN(uint256 _n) public view returns (address) {
  return Configuration["Main"].address_slot[_n];
}

// Can't read full because of stack too deep limit
function read_config_core(string memory _name) public view returns (
  string memory,
  bool,
  address,
  address[] memory){
  return (
  Configuration[_name].name,
  Configuration[_name].Running,
  Configuration[_name].govaddr,
  Configuration[_name].managers);}
function read_config_name(string memory _name) public view returns (string memory) {return Configuration[_name].name;}
function read_config_emergencyStatus(string memory _name) public view returns (bool) {return Configuration[_name].Running;}
function read_config_governAddress(string memory _name) public view returns (address) {return Configuration[_name].govaddr;}
function read_config_Managers(string memory _name) public view returns (address[] memory) {return Configuration[_name].managers;}

function read_config_bool_slot(string memory _name) public view returns (bool[] memory) {return Configuration[_name].boolslot;}
function read_config_address_slot(string memory _name) public view returns (address[] memory) {return Configuration[_name].address_slot;}
function read_config_uint256_slot(string memory _name) public view returns (uint256[] memory) {return Configuration[_name].uint256_slot;}
function read_config_bytes32_slot(string memory _name) public view returns (bytes32[] memory) {return Configuration[_name].bytes32_slot;}

function read_config_Managers_batched(string memory _name, uint256[] memory _ids) public view returns (address[] memory) {
    address[] memory result = new address[](_ids.length);
    for (uint256 i = 0; i < _ids.length; i++) {
        result[i] = Configuration[_name].managers[_ids[i]];
    }
    return result;
}

function read_config_bool_slot_batched(string memory _name, uint256[] memory _ids) public view returns (bool[] memory) {
    bool[] memory result = new bool[](_ids.length);
    for (uint256 i = 0; i < _ids.length; i++) {
        result[i] = Configuration[_name].boolslot[_ids[i]];
    }
    return result;
}

function read_config_address_slot_batched(string memory _name, uint256[] memory _ids) public view returns (address[] memory) {
    address[] memory result = new address[](_ids.length);
    for (uint256 i = 0; i < _ids.length; i++) {
        result[i] = Configuration[_name].address_slot[_ids[i]];
    }
    return result;
}

function read_config_uint256_slot_batched(string memory _name, uint256[] memory _ids) public view returns (uint256[] memory) {
    uint256[] memory result = new uint256[](_ids.length);
    for (uint256 i = 0; i < _ids.length; i++) {
        result[i] = Configuration[_name].uint256_slot[_ids[i]];
    }
    return result;
}

function read_config_bytes32_slot_batched(string memory _name, uint256[] memory _ids) public view returns (bytes32[] memory) {
    bytes32[] memory result = new bytes32[](_ids.length);
    for (uint256 i = 0; i < _ids.length; i++) {
        result[i] = Configuration[_name].bytes32_slot[_ids[i]];
    }
    return result;
}


// Read invote configuration
// Can't read full because of stack too deep limit
function read_invoteConfig_core(string calldata _name) public view returns (
  string memory,
  bool,
  address,
  address[] memory){
  return (
  invoteConfiguration[_name].name,
  invoteConfiguration[_name].Running,
  invoteConfiguration[_name].govaddr,
  invoteConfiguration[_name].managers);}
function read_invoteConfig_name(string memory _name) public view returns (string memory) {return invoteConfiguration[_name].name;}
function read_invoteConfig_emergencyStatus(string memory _name) public view returns (bool) {return invoteConfiguration[_name].Running;}
function read_invoteConfig_governAddress(string memory _name) public view returns (address) {return invoteConfiguration[_name].govaddr;}
function read_invoteConfig_Managers(string memory _name) public view returns (address[] memory) {return invoteConfiguration[_name].managers;}
function read_invoteConfig_boolslot(string memory _name) public view returns (bool[] memory) {return invoteConfiguration[_name].boolslot;}
function read_invoteConfig_address_slot(string memory _name) public view returns (address[] memory) {return invoteConfiguration[_name].address_slot;}
function read_invoteConfig_uint256_slot(string memory _name) public view returns (uint256[] memory) {return invoteConfiguration[_name].uint256_slot;}
function read_invoteConfig_bytes32_slot(string memory _name) public view returns (bytes32[] memory) {return invoteConfiguration[_name].bytes32_slot;}


/* Action manager system */

// Propose an action, regardless of which contract/address it resides in
function propose_action(uint256 _id, address _trigger_address, bytes memory _calldata) external returns (uint256) {
    require(curator_proportions[msg.sender] > 0, "You are not a curator");
    require(action_id_to_calldata[_id].length == 0, "Calldata already set");
    require(action_time_limit[_id] == 0, "Create a new one");
    require(block.timestamp >= action_curator_timer[msg.sender] + vote_time_threshold, "Not yet");
    action_curator_timer[msg.sender] = block.timestamp;
    action_time_limit[_id] = block.timestamp + vote_time_threshold;
    action_can_be_triggered_by[_id] = _trigger_address;
    action_id_to_vote[_id] = curator_proportions[msg.sender];
    action_id_to_calldata[_id] = _calldata;
    triggered[_id] = false;
    emit Action_Proposed(_id);
    return _id;
  }

// Support an already submitted action
function support_actions(uint256 _id) external returns (uint256) {
    require(curator_proportions[msg.sender] > 0, "You are not a curator");
    require(block.timestamp >= action_curator_timer[msg.sender] + vote_time_threshold, "Not yet");
    require(action_time_limit[_id] > block.timestamp, "Action timed out");
    action_curator_timer[msg.sender] = block.timestamp;
    action_id_to_vote[_id] = action_id_to_vote[_id] + curator_proportions[msg.sender];
    emit Action_Support(_id);
    return _id;
  }

// Trigger action by allowed smart contract address
// Only returns calldata, does not guarantee execution success! Triggerer is responsible, choose wisely.
function trigger_action(uint256 _id) external returns (bytes memory) {
    require(action_id_to_vote[_id] >= action_threshold, "Threshold not passed");
    require(action_time_limit[_id] > block.timestamp, "Action timed out");
    require(action_can_be_triggered_by[_id] == msg.sender, "You are not the triggerer");
    require(triggered[_id] == false, "Already triggered");
    triggered[_id] = true;
    action_id_to_vote[_id] = 0;
    emit Action_Trigger(_id);
    return action_id_to_calldata[_id];
}

/* Pure function for generating signatures */
function generator(string memory _func) public pure returns (bytes memory) {
        return abi.encodeWithSignature(_func);
    }

/* Execution and mass config updates */

/* Update contracts address list */
function update_All(address [] memory _addresses) external onlyCurators returns (address [] memory) {
  governedContracts = _addresses;
  return governedContracts;
}

/* Update all contracts from address list */
function selfManageMe_All() external onlyCurators {
  for (uint256 i = 0; i < governedContracts.length; i++) {
    _execute_Manage(governedContracts[i]);
  }
}

/* Execute external contract call: selfManageMe() */
function execute_Manage(address _contractA) external onlyCurators {
    _execute_Manage(_contractA);
}

function _execute_Manage(address _contractA) internal {
    require(_contractA != address(this),"You can't call Governance on itself");
    IGoverned(_contractA).selfManageMe();
}

/* Execute external contract call: selfManageMe() */
function execute_batch_Manage(address[] calldata _contracts) external onlyCurators {
  for (uint i; i < _contracts.length; i++) {
    _execute_Manage(_contracts[i]);
  }
}

/* Execute external contract calls with any string */
function execute_ManageBytes(address _contractA, string calldata _call, bytes calldata _data) external onlyCurators {
  _execute_ManageBytes(_contractA, _call, _data);
}

function execute_batch_ManageBytes(address[] calldata _contracts, string[] calldata _calls, bytes[] calldata _datas) external onlyCurators {
  require(_contracts.length == _calls.length, "Governance: _conracts and _calls length does not match");
  require(_calls.length == _datas.length, "Governance: _calls and _datas length does not match");
  for (uint i; i < _contracts.length; i++) {
    _execute_ManageBytes(_contracts[i], _calls[i], _datas[i]);
  }
}

function _execute_ManageBytes(address _contractA, string calldata _call, bytes calldata _data) internal {
  require(_contractA != address(this),"You can't call Governance on itself");
  require(bytes(_call).length == 0 || bytes(_call).length >=3, "provide a valid function specification");

  for (uint256 i = 0; i < bytes(_call).length; i++) {
    require(bytes(_call)[i] != 0x20, "No spaces in fun please");
  }

  bytes4 signature;
  if (bytes(_call).length != 0) {
      signature = (bytes4(keccak256(bytes(_call))));
  } else {
      signature = "";
  }

  (bool success, bytes memory retData) = _contractA.call(abi.encodePacked(signature, _data));
  _evaluateCallReturn(success, retData);
}

/* Execute external contract calls with address array */
function execute_ManageList(address _contractA, string calldata _funcName, address[] calldata address_array) external onlyCurators {
  require(_contractA != address(this),"You can't call Governance on itself");
  (bool success, bytes memory retData) = _contractA.call(abi.encodeWithSignature(_funcName, address_array));
  _evaluateCallReturn(success, retData);
}

/* Update Vault values */
function execute_Vault_update(address _vaultAddress) external onlyCurators {
  IVault(_vaultAddress).selfManageMe();
}

function _evaluateCallReturn(bool success, bytes memory retData) internal pure {
    if (!success) {
      if (retData.length >= 68) {
          bytes memory reason = new bytes(retData.length - 68);
          for (uint i = 0; i < reason.length; i++) {
              reason[i] = retData[i + 68];
          }
          revert(string(reason));
      } else revert("Governance: FAILX");
  }
}
}
// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.17;

/**
 * @title Mosaic Alpha Governed base contract
 * @author dlabs.hu
 * @dev This contract is base for contracts governed by Governance
 */

import "./Governance.sol";
import "../Interfaces/IGovernance.sol";
import "../Interfaces/IGoverned.sol";

abstract contract Governed is IGoverned {
    GovernanceState internal governanceState;

    constructor() {
      governanceState.running = true;
      governanceState.governanceAddress = address(this);
    }

    function getGovernanceState() public view returns (GovernanceState memory govState) {
      return governanceState;
    }

    // Modifier responsible for checking if emergency stop was triggered, default is Running == true
    modifier Live {
        LiveFun();
        _;
    }

    modifier notLive {
        notLiveFun();
        _;
    }


    error Governed__EmergencyStopped();
    function LiveFun() internal virtual view {
        if (!governanceState.running) revert Governed__EmergencyStopped();
    }

    error Governed__NotStopped();
    function notLiveFun() internal virtual view {
        if (governanceState.running) revert Governed__NotStopped();
    }

    modifier onlyManagers() {
        onlyManagersFun();
        _;
    }

    error Governed__NotManager(address caller);
    function onlyManagersFun() internal virtual view {
        if (!isManagerFun(msg.sender)) revert Governed__NotManager(msg.sender);
    }


    function isManagerFun(address a) internal virtual view returns (bool) {
        if (a == governanceState.governanceAddress) {
            return true;
        }
        for (uint i=0; i < governanceState.managers.length; i++) {
            if (governanceState.managers[i] == a) {
                return true;
            }
        }
        return false;
    }

    function selfManageMe() external virtual {
        onlyManagersFun();
        LiveFun();
        _selfManageMeBefore();
        address governAddress = governanceState.governanceAddress;
        bool nextRunning = IGovernance(governAddress).read_core_Running();
        if (governanceState.running != nextRunning) _onBeforeEmergencyChange(nextRunning);
        governanceState.running = nextRunning;
        governanceState.managers = IGovernance(governAddress).read_core_managers();               // List of managers
        governanceState.governanceAddress = IGovernance(governAddress).read_core_govAddr();
        _selfManageMeAfter();
    }

    function _selfManageMeBefore() internal virtual;
    function _selfManageMeAfter() internal virtual;
    function _onBeforeEmergencyChange(bool nextRunning) internal virtual;
}
// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity ^0.8.17;

interface ISimpleEntropy {
    // function random(uint256 seed) external view returns (uint256);
    function simpleRandom() external view returns (uint256);
    function simpleRandom(uint256 seed) external view returns (uint256);
}// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity ^0.8.17;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

interface IERC20Burnable is IERC20 {
    function burn(uint256 _amount) external;
}// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.7.0) (access/Ownable.sol)

pragma solidity ^0.8.0;

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
abstract contract Ownable {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor() {
        _transferOwnership(msg.sender);
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
        require(owner() == msg.sender, "Ownable: caller is not the owner");
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
// SPDX-License-Identifier: GPL-3.0-or-later

pragma solidity ^0.8.17;

import "./IEntropy.sol";

contract SimpleEntropy is ISimpleEntropy {

    function simpleRandom() external view returns (uint256) {
        return _simpleRandom(0);
    }

    function simpleRandom(uint256 seed) external view returns (uint256) {
        return _simpleRandom(seed);
    }

    function _simpleRandom(uint256 seed) internal view returns (uint256) {
        uint256 blockNumber = block.number;
        if (blockNumber < 4) blockNumber = 4;
        return uint256(keccak256(abi.encodePacked(
            block.timestamp,
            block.coinbase,
            blockhash(block.number - 1),
            msg.sender,
            seed,
            tx.origin
        )));
    }
}
// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity ^0.8.17;

import "../Interfaces/IUserProfile.sol";
import "../Interfaces/IGoverned.sol";

interface IAffiliate is IGoverned {
    struct AffiliateLevel {
        uint8 rank;
        uint8 commissionLevels; // eligibility for how many levels affiliate comission
        uint16 referralBuyFeeDiscount; // buy fee disccount for the referrals refistering for the user - 10000 = 100%
        uint16 referralCountThreshold; // minimum amount of direct referrals needed for level
        uint16 stakingBonus;
        uint16 conversionRatio;
        uint32 claimLimit; // max comission per month claimable - in usd value, not xe18!
        uint256 kdxStakeThreshold; // minimum amount of kdx stake needed
        uint256 purchaseThreshold; // minimum amount of self basket purchase needed
        uint256 referralPurchaseThreshold; // minimum amount of referral basket purchase needed
        uint256 traderPurchaseThreshold; // minimum amount of user basket purchase (for traders) needed

        string rankName;
    }

    struct AffiliateUserData {
        uint32 affiliateRevision;
        uint32 activeReferralCount;
        uint256 userPurchase;
        uint256 referralPurchase;
        uint256 traderPurchase;
        uint256 kdxStake;
    }

    struct AffiliateConfig {
        uint16 level1RewardShare; // 0..10000. 6000 -> 60% of affiliate rewards go to level 1, 40% to level2
        uint240 activeReferralPurchaseThreshold; // the min amount of (usdt) purchase in wei to consider a referral active
    }

    function getCommissionLevelsForRanks(uint8 rank, uint8 rank2) external view returns (uint8 commissionLevels, uint8 commissionLevels2);

    function getLevelsAndConversionAndClaimLimitForRank(uint8 rank) external view returns (uint8 commissionLevels, uint16 conversionRatio, uint32 claimLimit);

    function getConfig() external view returns (AffiliateConfig memory config);

    // get the number of affiliate levels
    function getLevelCount() external view returns (uint256 count);

    function getLevelDetails(uint256 _idx) external view returns (AffiliateLevel memory level);

    function getAllLevelDetails() external view returns (AffiliateLevel[] memory levels);

    function getAffiliateUserData(address user) external view returns (AffiliateUserData memory data);

    function getUserPurchaseAmount(address user) external view returns (uint256 amount);

    function getReferralPurchaseAmount(address user) external view returns (uint256 amount);

    function userStakeChanged(address user, address referredBy, uint256 kdxAmount) external;

    function registerUserPurchase(address user, address referredBy, address trader, uint256 usdAmount) external;
    function registerUserPurchaseAsTokens(address user, address referredBy, address trader, address[] memory tokens, uint256[] memory tokenAmounts) external;

    event AffiliateConfigUpdated(AffiliateConfig _newConfig, AffiliateConfig config);

}// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity ^0.8.17;

interface IAffiliateBooster {
    // Structs
    struct AffiliateBoosterState {
        uint64 currentEpoch;         // current epoch number
        uint64 currentEpochStart;    // timestamp of the start of the current epoch
        uint16 epochSize;            // number of referrals allocated per epoch
        uint32 epochTime;            // length of epoch (in seconds)
        uint64 totalTicketsSpent;    // total number of tickets used via booster
        uint64 totalTicketCount;     // total number of tickets bought via booster
        bool feeTokenBurnable;      // whether the fee token is burnable
        uint8[] epochWeights;        // an array of % weights of tickets in past N epochs
        address feeToken;            // address of the fee token
        uint256 totalPlayerWeight;   // total weight of all players in the booster
        uint256 ticketPrice;         // price of a ticket in the booster
        address feeTo;
    }


    struct AffiliateBoosterEpoch {
        uint64 ticketsBought;   // Total number of tickets bought during this epoch
        uint64 ticketsSpent;    // Total number of tickets spent during this epoch
        uint64 ticketsActive;   // Still active tickets in epoch
        uint64 epochStart;      // Timestamp of when this epoch started (in seconds since Unix epoch)
    }

    // Events
    event TicketBought(uint256 epoch, address user, uint256 count, uint256 price);
    event TicketSpent(uint256 epoch, address user);
    event ReferralPicked(address pickedAddress);
    event EpochClosed(uint256 epochId);
    event CallerAllowed(address caller, bool);
    event EpochWeightsChanged(uint8[] weights);

    // Getter functions
    function getState() external view returns (AffiliateBoosterState memory stateStruct);
    function getEpochStates(uint256[] memory epochIds) external view returns (AffiliateBoosterEpoch[] memory epochStates);
    function getEpochTickets(uint256 epochId) external view returns (address[] memory tickets);
    function getEpochTicket(uint256 epochId, uint256 idx) external view returns (address user);
    function getEpochTicketsCount(uint256 epochId) external view returns (uint256 count);
    function getUserTickets(address user, uint256[] memory epochIds) external view returns (uint64[] memory userTickets);
    function getCurrentEpoch() external view returns (uint64 epochSize);
    function getCurrentEpochState() external view returns (AffiliateBoosterEpoch memory epochState);
    function getCurrentEpochStart() external view returns (uint64 epochStart);
    function getEpochSize() external view returns (uint16 epochSize);
    function getEpochTime() external view returns (uint32 epochTime);
    function getTotalTicketCount() external view returns (uint64 totalTicketCount);
    function getTotalTicketsSpent() external view returns (uint64 totalTicketsSpent);
    function getEpochWeights() external view returns (uint8[] memory epochWeights);
    function getFeeToken() external view returns (address feeToken);
    function getFeeTokenBurnable() external view returns (bool burnable);
    function getTotalPlayerWeight() external view returns (uint256 totalPlayerWeight);
    function getTicketPrice() external view returns (uint256 ticketPrice);


    // Setter functions
    function setEpochWeights(uint8[] memory weights) external;
    function setCallerAllowed(address _a, bool _allowed) external;

    // core functionality
    function purchaseTicket(uint256 _c) external;
    function purchaseTicket(address _referredBy, uint256 _c) external;
    function allocateTicket(address _a, address _referredBy, uint256 _c, uint256 _price) external;
    function pickNextReferral() external returns (address pickedAddress);
}
// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity ^0.8.17;

interface IAffiliateBoosterController {
    // hook to get the current price of one ticket
    function getTicketPrice(address user, uint256 count) external returns (uint256 ticketPrice);

    // callback to notify the pricer of epoch closure
    function epochClosed(uint256 newEpochId) external;

    // callback to notify the pricer of ticket purchase
    function ticketAllocated(address user, uint256 count) external;

    function purchaseTicket(uint256 _c) external;

    function purchaseTicket(address _referredBy, uint256 _c) external;

    // callback to notify the pricer of referral picked
    function referralPicked(address user, bool isDefault) external;
}
// SPDX-License-Identifier: MIT LICENSE
pragma solidity ^0.8.17;

interface IGovernance {
    function propose_action(uint256 _id, address _trigger_address, bytes memory _calldata) external returns (uint256) ;
    function support_actions(uint256 _id) external returns (uint256) ;
    function trigger_action(uint256 _id) external returns (bytes memory) ;
    function transfer_proportion(address _address, uint256 _amount) external returns (uint256) ;

    function read_core_Running() external view returns (bool);
    function read_core_govAddr() external view returns (address);
    function read_core_managers() external view returns (address[] memory);
    function read_core_owners() external view returns (address[] memory);

    function read_config_core(string memory _name) external view returns (string memory);
    function read_config_emergencyStatus(string memory _name) external view returns (bool);
    function read_config_governAddress(string memory _name) external view returns (address);
    function read_config_Managers(string memory _name) external view returns (address [] memory);

    function read_config_bool_slot(string memory _name) external view returns (bool[] memory);
    function read_config_address_slot(string memory _name) external view returns (address[] memory);
    function read_config_uint256_slot(string memory _name) external view returns (uint256[] memory);
    function read_config_bytes32_slot(string memory _name) external view returns (bytes32[] memory);

    function read_invoteConfig_core(string memory _name) external view returns (string memory);
    function read_invoteConfig_name(string memory _name) external view returns (string memory);
    function read_invoteConfig_emergencyStatus(string memory _name) external view returns (bool);
    function read_invoteConfig_governAddress(string memory _name) external view returns (address);
    function read_invoteConfig_Managers(string memory _name) external view returns (address[] memory);
    function read_invoteConfig_boolslot(string memory _name) external view returns (bool[] memory);
    function read_invoteConfig_address_slot(string memory _name) external view returns (address[] memory);
    function read_invoteConfig_uint256_slot(string memory _name) external view returns (uint256[] memory);
    function read_invoteConfig_bytes32_slot(string memory _name) external view returns (bytes32[] memory);

    function propose_config(string memory _name, bool _bool_val, address _address_val, address[] memory _address_list, uint256 _uint256_val, bytes32 _bytes32_val) external returns (uint256);
    function support_config_proposal(uint256 _confCount, string memory _name) external returns (string memory);
    function generator() external pure returns (bytes memory);
}
// SPDX-License-Identifier: MIT LICENSE
pragma solidity ^0.8.17;

interface IGoverned {
    struct GovernanceState {
      bool running;
      address governanceAddress;
      address[] managers;
    }

    function selfManageMe() external;
}
// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity ^0.8.17;

interface IUserProfile {

    struct UserProfile {                           /// Storage - We map the affiliated person to the affiliated_by person
        bool exists;
        uint8 rank;
        uint8 referredByRank;                       /// Rank of referrer at transaction time
        uint16 buyFeeDiscount;                            /// buy discount - 10000 = 100%
        uint32 referralCount;                          /// Number of referred by referee
        uint32 activeReferralCount;                    /// Number of active users referred by referee
        address referredBy;                            /// Address is referred by this user
        address referredByBefore;                     /// We store the 2nd step here to save gas (no interation needed)
    }

    struct Parent {
        uint8 rank;
        address user;
    }

    // returns the parent of the address
    function getParent(address _user) external view returns (address parent);
    // returns the parent and the parent of the parent of the address
    function getParents(address _user) external view returns (address parent, address parentOfParent);


    // returns user's parents and ranks of parents in 1 call
    function getParentsAndParentRanks(address _user) external view returns (Parent memory parent, Parent memory parent2);
    // returns user's parents and ranks of parents and use rbuy fee discount in 1 call
    function getParentsAndBuyFeeDiscount(address _user) external view returns (Parent memory parent, Parent memory parent2, uint16 discount);
    // returns number of referrals of address
    function getReferralCount(address _user) external view returns (uint32 count);
    // returns number of active referrals of address
    function getActiveReferralCount(address _user) external view returns (uint32 count);

    // returns up to _count referrals of _user
    function getAllReferrals(address _user) external view returns (address[] memory referrals);

    // returns up to _count referrals of _user starting from _index
    function getReferrals(address _user, uint256 _index, uint256 _count) external view returns (address[] memory referrals);

    function getDefaultReferral() external view returns (address defaultReferral);

    // get user information of _user
    function getUser(address _user) external view returns (UserProfile memory user);

    function getUserRank(address _user) external view returns (uint8 rank);

    // returns the total number of registered users
    function getUserCount() external view returns (uint256 count);

    // return true if user exists
    function userExists(address _user) external view returns (bool exists);

    function registerUser(address _user) external;

    function increaseActiveReferralCount(address _user) external;

    function registerUser(address _user, address _referredBy) external;

    function registerUserWoBooster(address _user) external;

    function setUserRank(address _user, uint8 _rank) external;

    // function setDefaultReferral(address _referral) external;

    // events
    event UserRegistered(address user, address referredBy, uint8 referredByRank, uint16 buyFeeDiscount);
}// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity ^0.8.17;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "../Interfaces/IGoverned.sol";

interface IVault is IGoverned {

    struct VaultState {
        bool userPoolTrackingDisabled;
        // bool paused;
        bool emergencyMode;
        bool whitelistingEnabled;
        bool flashEnabled;
        uint8 maxPoolTokenCount;
        uint8 feeToProtocol;
        uint8 bidMultiplier;
        uint16 flashFee;
        uint16 swapFee;
        uint16 bidMinDuration;
        uint16 rebalancingMinDuration;
        uint32 emergencyModeTimestamp;
        address feeTo;
    }

    struct PoolState {
        bool poolInitialized;
        bool poolEmergencyMode;
        bool feeless;
        bool boosted;
        uint8 poolTokenCount;
        uint32 emergencyModeTime;
        uint48 lastTrailingTimestamp;
        uint48 lastPerformanceTimestamp;
        uint216 emergencyModeLPs;
        TotalSupplyBase totalSupplyBase;
    }

    function getVaultState() external view returns (VaultState memory _vaultState);


    /************************************************************************************/
    /* Admin functions                                                                  */
    /************************************************************************************/
    // Check if given address is admin or not
    function isAdmin(address _address) external view returns (bool _isAdmin);

    // Add or remove vault admin. Only admin can call this function
    function AddRemoveAdmin(address _address, bool _ShouldBeAdmin) external;// returns (address, bool);

    // Boost or unboost pool. Boosted pools get 100% of their swap fees.
    // For non boosted pools, a part of the swap fees go to the platform.
    // Only admin can call this function
    function AddRemoveBoostedPool(address _address, bool _ShouldBeBoosted) external;// returns (address, bool);


    /************************************************************************************/
    /* Token whitelist                                                                  */
    /************************************************************************************/

    // Only admin can call this function. Only the whitelisted tokens can be added to a Pool
    // If empty: No whitelist, all tokens are allowed
    function setWhitelistedTokens(address[] calldata _tokens, bool[] calldata _whitelisted) external;

    function isTokenWhitelisted(address token) external view returns (bool whitelisted);
    event TokenWhitelistChanged(address indexed token, bool isWhitelisted);

    /************************************************************************************/
    /* Internal Balances                                                                */
    /************************************************************************************/

    // Users can deposit tokens into the Vault to have an internal balance in the Mosaic platform.
    // This internal balance can be used to deposit tokens into a Pool (Mint), withdraw tokens from
    // a Pool (Burn), or perform a swap. The internal balance can also be transferred or withdrawn.

    // Get a specific user's internal balance for one given token
    function getInternalBalance(address user, address token) external view returns (uint balance);

    // Get a specific user's internal balances for the given token array
    function getInternalBalances(address user, address[] memory tokens) external view returns (uint[] memory balances);

    // Deposit tokens to the msg.sender's  internal balance
    function depositToInternalBalance(address token, uint amount) external;

    // Deposit tokens to the recipient internal balance
    function depositToInternalBalanceToAddress(address token, address to, uint amount) external;

    // ERC20 token transfer from the message sender's internal balance to their address
    function withdrawFromInternalBalance(address token, uint amount) external;

    // ERC20 token transfer from the message sender's internal balance to the given address
    function withdrawFromInternalBalanceToAddress(address token, address to, uint amount) external;

    // Transfer tokens from the message sender's internal balance to another user's internal balance
    function transferInternalBalance(address token, address to, uint amount) external;

    // Event emitted when user's internal balance changes by delta amount. Positive delta means internal balance increase
    event InternalBalanceChanged(address indexed user, address indexed token, int256 delta);

    /************************************************************************************/
    /* Pool ERC20 helper                                                                */
    /************************************************************************************/

    function transferFromAsTokenContract(address from, address to, uint amount) external returns (bool success);
    function mintAsTokenContract(address to, uint amount) external returns (bool success);
    function burnAsTokenContract(address from, uint amount) external returns (bool success);

    /************************************************************************************/
    /* Pool                                                                             */
    /************************************************************************************/

    struct TotalSupplyBase {
        uint32 timestamp;
        uint224 amount;
    }

    event TotalSupplyBaseChanged(address indexed poolAddr, TotalSupplyBase supplyBase);
    // Each pool should be one of the following based on poolType:
    // 0: REBALANCING: (30% ETH, 30% BTC, 40% MKR). Weight changes gradually in time.
    // 1: NON_REBALANCING: (100 ETH, 5 BTC, 200 MKR). Weight changes gradually in time.
    // 2: DAYTRADE: Non rebalancing pool. Weight changes immediately.

    function tokenInPool(address pool, address token) external view returns (bool inPool);

    function poolIdToAddress(uint32 poolId) external view returns (address poolAddr);

    function poolAddressToId(address poolAddr) external view returns (uint32 poolId);

    // pool calls this to move the pool to zerofee status
    function disableFees() external;

    // Returns the total pool count
    function poolCount() external view returns (uint32 count);

    // Returns a list of pool IDs where the user has assets
    function userJoinedPools(address user) external view returns (uint32[] memory poolIDs);

    // Returns a list of pool the user owns
    function userOwnedPools(address user) external view returns (uint32[] memory poolIDs);

    //Get pool tokens and their balances
    function getPoolTokens(uint32 poolId) external view returns (address[] memory tokens, uint[] memory balances);

    function getPoolTokensByAddr(address poolAddr) external view returns (address[] memory tokens, uint[] memory balances);

    function getPoolTotalSupplyBase(uint32 poolId) external view returns (TotalSupplyBase memory totalSupplyBase);

    function getPoolTotalSupplyBaseByAddr(address poolAddr) external view returns (TotalSupplyBase memory totalSupplyBase);

    // Register a new pool. Pool type can not be changed after the creation. Emits a PoolRegistered event.
    function registerPool(address _poolAddr, address _user, address _referredBy) external returns (uint32 poolId);
    event PoolRegistered(uint32 indexed poolId, address indexed poolAddress);

    // Registers tokens for the Pool. Must be called by the Pool's contract. Emits a TokensRegistered event.
    function registerTokens(address[] memory _tokenList, bool onlyWhitelisted) external;
    event TokensRegistered(uint32 indexed poolId, address[] newTokens);

    // Adds initial liquidity to the pool
    function addInitialLiquidity(uint32 _poolId, address[] memory _tokens, uint[] memory _liquidity, address tokensTo, bool fromInternalBalance) external;
    event InitialLiquidityAdded(uint32 indexed poolId, address user, uint lpTokens, address[] tokens, uint[] amounts);

    // Deegisters tokens for the poolId Pool. Must be called by the Pool's contract.
    // Tokens to be deregistered should have 0 balance. Emits a TokensDeregistered event.
    function deregisterToken(address _tokenAddress, uint _remainingAmount) external;
    event TokensDeregistered(uint32 indexed poolId, address tokenAddress);

    // This function is called when a liquidity provider adds liquidity to the pool.
    // It mints additional liquidity tokens as a reward.
    // If fromInternalBalance is true, the amounts will be deducted from user's internal balance
    function Mint(uint32 poolId, uint LPTokensRequested, uint[] memory amountsMax, address to, address referredBy, bool fromInternalBalance, uint deadline, uint usdValue) external returns (uint[] memory amountsSpent);
    event Minted(uint32 indexed poolId, address txFrom, address user, uint lpTokens, address[] tokens, uint[] amounts, bool fromInternalBalance);

    // This function is called when a liquidity provider removes liquidity from the pool.
    // It burns the liquidity tokens and sends back the tokens as ERC20 transfer.
    // If toInternalBalance is true, the tokens will be deposited to user's internal balance
    function Burn(uint32 poolId, uint LPTokensToBurn, uint[] memory amountsMin, bool toInternalBalance, uint deadline, address from) external returns (uint[] memory amountsReceived);
    event Burned(uint32 indexed poolId, address txFrom, address user, uint lpTokens, address[] tokens, uint[] amounts, bool fromInternalBalance);

    /************************************************************************************/
    /* Swap                                                                             */
    /************************************************************************************/

    // Executes a swap operation on a single Pool. Called by the user
    // If the swap is initiated with givenInOrOut == 1 (i.e., the number of tokens to be sent to the Pool is specified),
    // it returns the amount of tokens taken from the Pool, which should not be less than limit.
    // If the swap is initiated with givenInOrOut == 0 parameter (i.e., the number of tokens to be taken from the Pool is specified),
    // it returns the amount of tokens sent to the Pool, which should not exceed limit.
    // Emits a Swap event
    function swap(address poolAddress, bool givenInOrOut, address tokenIn, address tokenOut, uint amount, bool fromInternalBalance, uint limit, uint64 deadline) external returns (uint calculatedAmount);
    event Swap(uint32 indexed poolId, address indexed tokenIn, address indexed tokenOut, uint amountIn, uint amountOut, address user);

    // Execute a multi-hop token swap between multiple pairs of tokens on their corresponding pools
    // Example: 100 tokenA -> tokenB -> tokenC
    // pools = [pool1, pool2], tokens = [tokenA, tokenB, tokenC], amountIn = 100
    // The returned amount of tokenC should not be less than limit
    function multiSwap(address[] memory pools, address[] memory tokens, uint amountIn, bool fromInternalBalance, uint limit, uint64 deadline) external returns (uint calculatedAmount);

    /************************************************************************************/
    /* Dutch Auction                                                                    */
    /************************************************************************************/
    // Non rebalancing pools (where poolId is not 0) can use Dutch auction to change their
    // balance sheet. A Dutch auction (also called a descending price auction) refers to a
    // type of auction in which an auctioneer starts with a very high price, incrementally
    // lowering the price. User can bid for the entire amount, or just a fraction of that.

    struct AuctionInfo {
        address poolAddress;
        uint32 startsAt;
        uint32 duration;
        uint32 expiration;
        address tokenToSell;
        address tokenToBuy;
        uint startingAmount;
        uint remainingAmount;
        uint startingPrice;
        uint endingPrice;
    }

    // Get total (lifetime) auction count
    function getAuctionCount() external view returns (uint256 auctionCount);

    // Get all information of the given auction
    function getAuctionInfo(uint auctionId) external view returns (AuctionInfo memory);

    // Returns 'true' if the auction is still running and there are tokens available for purchase
    // Returns 'false' if the auction has expired or if all tokens have been sold.
    function isRunning(uint auctionId) external view returns (bool);

    // Called by pool owner. Emits an auctionStarted event
    function startAuction(address tokenToSell, uint amountToSell, address tokenToBuy, uint32 duration, uint32 expiration, uint endingPrice) external returns (uint auctionId);
    event AuctionStarted(uint32 poolId, uint auctionId, AuctionInfo _info);

    // Called by pool owner. Emits an auctionStopped event
    function stopAuction(uint auctionId) external;
    event AuctionStopped(uint auctionId);

    // Get the current price for 'remainingAmount' number of tokens
    function getBidPrice(uint auctionId) external view returns (uint currentPrice, uint remainingAmount);

    // Place a bid for the specified 'auctionId'. Fractional bids are supported, with the 'amount'
    // representing the number of tokens to purchase. The amounts are deducted from and credited to the
    // user's internal balance. If there are insufficient tokens in the user's internal balance, the function reverts.
    // If there are fewer tokens available for the auction than the specified 'amount' and enableLessAmount == 1,
    // the function purchases all remaining tokens (which may be less than the specified amount).
    // If enableLessAmount is set to 0, the function reverts. Emits a 'newBid' event
    function bid(uint auctionId, uint amount, bool enableLessAmount, bool fromInternalBalance, uint deadline) external returns (uint spent);
    event NewBid(uint auctionId, address buyer, uint tokensBought, uint paid, address tokenToBuy, address tokenToSell, uint remainingAmount);

    /************************************************************************************/
    /* Emergency                                                                        */
    /************************************************************************************/
    // Activate emergency mode. Once the contract enters emergency mode, it cannot be reverted or cancelled.
    // Only an admin can call this function.
    function setEmergencyMode() external;

    // Activate emergency mode. Once the contract enters emergency mode, it cannot be reverted or cancelled.
    function setPoolEmergencyMode(address poolAddress) external;
}
// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity ^0.8.17;

/**
 * @title Mosaic Alpha AffiliateBooster contract
 * @author dlabs.hu
 * @dev This contract is for affiliate booster logic
 */

import "../helpers/SimpleEntropy.sol";
import "../helpers/Ownable.sol";
import "../Interfaces/IAffiliateBoosterController.sol";
import "../Interfaces/IAffiliateBooster.sol";
import "../Interfaces/IUserProfile.sol";
import "../helpers/IERC20Burnable.sol";

import "../Interfaces/IGovernance.sol";
import "../Governance/Governed.sol";
import "@openzeppelin/contracts/utils/math/SafeCast.sol";

/**
 * @title AffiliateBooster
 * @dev A contract for picking referrals based on ticket purchases
 */
contract AffiliateBooster is SimpleEntropy, IAffiliateBooster, Ownable, Governed {
    using SafeCast for uint256;
    AffiliateBoosterState private state; // state of the contract
    mapping (address => bool) public allowedCaller; // addresses that can request new referral to be picked
    mapping(uint256 => AffiliateBoosterEpoch) private epochs; // epochs
    mapping(uint256 => address[]) public epochTickets; // active epoch tickets
    mapping(uint256 => mapping(address => uint64)) public epochUserTickets; // active user epoch tickets

    IAffiliateBoosterController public controller; // controller contract
    IUserProfile public userProfile;

    /**
     * @dev Constructor function
     * @param _feeToken The address of the fee token used to purchase tickets
     */
    constructor(address _feeToken, /*bool _feeTokenBurnable, uint256 _ticketPrice,*/ address _governAddress) {
        state.feeToken = _feeToken;
        state.epochWeights = [100, 90, 70, 50, 10]; // default epoch weights
        state.currentEpochStart = uint64(block.timestamp);
        epochs[0].epochStart = uint64(block.timestamp);
        governanceState.governanceAddress = _governAddress;
    }

    // /* Governance */
    function _selfManageMeBefore() internal override {
        // get vault, userprofile, oracle, deposit
        address[] memory slots = IGovernance(governanceState.governanceAddress).read_config_address_slot("Main");
        _setCallerAllowed(address(userProfile), false);
        userProfile = IUserProfile(slots[1]);
        state.feeTo = slots[6];
        _setCallerAllowed(address(userProfile), true);
        _transferOwnership(slots[0]);

        slots = IGovernance(governanceState.governanceAddress).read_config_address_slot("AffiliateBooster");
        bool[] memory boolSlots = IGovernance(governanceState.governanceAddress).read_config_bool_slot("AffiliateBooster");
        uint256[] memory uintSlots = IGovernance(governanceState.governanceAddress).read_config_uint256_slot("AffiliateBooster");

        controller = IAffiliateBoosterController(slots[0]);
        if (slots.length > 1) state.feeTo = slots[1];
        state.feeTokenBurnable = boolSlots[0];
        state.ticketPrice = uintSlots[0];
        state.epochTime = uintSlots[1].toUint32();
        state.epochSize = uintSlots[2].toUint16();
    }
    function _selfManageMeAfter() internal override {}
    function _onBeforeEmergencyChange(bool nexRunning) internal override {}

    /**
     * @dev Modifier to close the current epoch if the epoch time has elapsed
     */
    modifier closeEpochIfTimeUp() {
        if (state.epochTime > 0 && block.timestamp >= state.currentEpochStart + state.epochTime) {
            _incrementEpoch();
        }
        _;
    }

    /**
     * @dev Closes the current epoch if the epoch time has elapsed or the epoch size has been reached
     */
    function closeEpoch() external {
        if (state.epochTime > 0 && block.timestamp >= state.currentEpochStart + state.epochTime) {
            _incrementEpoch();
        return;
        } else if (state.epochSize > 0 && epochs[state.currentEpoch].ticketsSpent >= state.epochSize) {
            _incrementEpoch();
            return;
        }
        revert("No epoch to close");
    }

    /* GETTERS */

    /**
    * @dev Returns the current epoch
    * @return epochSize The current epoch number
    */
    function getCurrentEpoch() external view returns (uint64 epochSize) {
        return state.currentEpoch;
    }

    /**
    * @dev Returns the state of the current epoch
    * @return epochState The epoch state as a struct
    */
    function getCurrentEpochState() external view returns (AffiliateBoosterEpoch memory epochState) {
        epochState = epochs[state.currentEpoch];
        epochState.ticketsActive = uint64(epochTickets[state.currentEpoch].length);
    }

    /**
    * @dev Returns the start time of the current epoch
    * @return epochStart The start time of the current epoch
    */
    function getCurrentEpochStart() external view returns (uint64 epochStart) {
        return state.currentEpochStart;
    }

    /**
    * @dev Returns the maximum number of tickets that can be purchased in an epoch
    * @return epochSize The epoch size
    */
    function getEpochSize() external view returns (uint16 epochSize) {
        return state.epochSize;
    }

    /**
    * @dev Returns the duration of each epoch in seconds
    * @return epochTime The epoch time
    */
    function getEpochTime() external view returns (uint32 epochTime) {
        return state.epochTime;
    }

    /**
    * @dev Returns the total number of tickets purchased
    * @return totalTicketCount The total number of tickets purchased
    */
    function getTotalTicketCount() external view returns (uint64 totalTicketCount) {
        return state.totalTicketCount;
    }

    /**
    * @dev Returns the total number of tickets spent in the current epoch
    * @return totalTicketsSpent The total number of tickets spent in the current epoch
    */
    function getTotalTicketsSpent() external view returns (uint64 totalTicketsSpent) {
        return state.totalTicketsSpent;
    }

    /**
    * @dev Returns the epoch weights
    * @return epochWeights The epoch weights
    */
    function getEpochWeights() external view returns (uint8[] memory epochWeights) {
        return state.epochWeights;
    }

    /**
    * @dev Returns the address of the fee token
    * @return feeToken The address of the fee token
    */
    function getFeeToken() external view returns (address feeToken) {
        return state.feeToken;
    }

    /**
    * @dev Returns whether the fee token can be burned
    * @return burnable Whether the fee token can be burned
    */
    function getFeeTokenBurnable() external view returns (bool burnable) {
        // Return the value of the `feeTokenBurnable` field in the `state` struct
        return state.feeTokenBurnable;
    }


    /**
    * @dev Returns the sum of weights of all players in the current epoch
    * @return totalPlayerWeight The total player weight
    */
    function getTotalPlayerWeight() external view returns (uint256 totalPlayerWeight) {
        return state.totalPlayerWeight;
    }

    /**
    * @dev Returns the price of a ticket in wei
    * @return ticketPrice The ticket price
    */
    function getTicketPrice() external view returns (uint256 ticketPrice) {
        return state.ticketPrice;
    }

    /* GETTERS END */

    /**
    * @dev Sets the controller contract address
    * @param _a The address of the controller contract
    */
    function setController(address _a) external Live onlyOwner {
        controller = IAffiliateBoosterController(_a);
    }

    // /**
    // * @dev Allows or disallows an address to request the next referral
    // * @param _a The address to allow or disallow
    // * @param _allowed Whether the address is allowed or not
    // */
    function setCallerAllowed(address _a, bool _allowed) external Live onlyOwner {
        _setCallerAllowed(_a, _allowed);
    }
    function _setCallerAllowed(address _a, bool _allowed) internal {
        allowedCaller[_a] = _allowed;
        emit CallerAllowed(_a, _allowed);
    }

    /**
    * @dev Sets the weights with which tickets are counted in the epochs. It closes the current epoch
    * @param _weights The new epoch weights
    */
    function setEpochWeights(uint8[] memory _weights) external Live onlyOwner {
        state.epochWeights = _weights;
        _incrementEpoch();
        emit EpochWeightsChanged(_weights);
    }

    /**
    * @dev Sets whether the fee token can be burned
    * @param _b Whether the fee token can be burned
    */
    function _setFeeTokenBurnable(bool _b) internal {
        state.feeTokenBurnable = _b;
    }

    /**
    * @dev Sets the fee receiver address
    * @param _a Address for the fee
    */
    function setFeeTo(address _a) external Live onlyOwner {
        state.feeTo= _a;
    }

    /**
    * @dev Purchases a ticket for a given beneficiary address and cost
    * @param _c The cost of the ticket
    */
    function purchaseTicket(uint256 _c) external Live closeEpochIfTimeUp {
        purchaseTicket(address(0), _c);
    }

    /**
    * @dev Allows a user to purchase tickets directly by transferring the fee token to this contract
    * @param _referredBy The address off the referee
    * @param _c The number of tickets to purchase
    */
    function purchaseTicket(address _referredBy, uint256 _c) public Live closeEpochIfTimeUp {
        if (address(controller) != address(0)) revert("AffiliateBooster: No direct purchase when controller is set");
        require(IERC20Burnable(state.feeToken).transferFrom(msg.sender, address(this), _c * state.ticketPrice), "TransferFrom failed");
        if (state.feeTokenBurnable) {
            IERC20Burnable(state.feeToken).burn(_c * state.ticketPrice);
        } else {
            IERC20Burnable(state.feeToken).transfer(state.feeTo, _c * state.ticketPrice);
        }
        _allocateTicket(msg.sender, _referredBy, _c, state.ticketPrice);
    }

    /**
    * @dev Allocates tickets to a user
    * @param _a The address of the user who is being allocated tickets
    * @param _referredBy _a's referral
    * @param _c The number of tickets to allocate
    * @param _price The price of each ticket in wei
    */
    function allocateTicket(address _a, address _referredBy, uint256 _c, uint256 _price) external Live closeEpochIfTimeUp {
        require(msg.sender == address(controller), "AffiliateBooster: Only controller can call this");
        _allocateTicket(_a, _referredBy, _c, _price);
    }

    /**
    * @dev Internal function to allocate tickets to a user
    * @param _a The address of the user who is being allocated tickets
    * @param _referredBy _a's referral
    * @param _c The number of tickets to allocate
    * @param _price The price of each ticket in wei
    */
    function _allocateTicket(address _a, address _referredBy, uint256 _c, uint256 _price) internal {
        if (address(userProfile) != address(0)) userProfile.registerUser(_a, _referredBy);
        for (uint256 i = 0; i < _c; i++) {
            epochTickets[state.currentEpoch].push(_a);
            state.totalPlayerWeight += state.epochWeights[0];
        }
        epochs[state.currentEpoch].ticketsBought += uint64(_c);
        epochUserTickets[state.currentEpoch][_a] += uint64(_c);
        state.totalTicketCount += uint64(_c);
        if (address(controller) != address(0)) {
            controller.ticketAllocated(_a, _c);
        }
        emit TicketBought(state.currentEpoch, _a, _c, _price);
    }


    /**
    * @dev Picks the next referral based on the number of tickets purchased by users
    * @return pickedAddress The address of the next referral
    */
    function pickNextReferral() external Live closeEpochIfTimeUp returns (address pickedAddress){
        require(allowedCaller[msg.sender], "AffiliateBooster: caller not allowed to pich referral");
        if (state.totalPlayerWeight == 0) {
            if (address(controller) != address(0)) controller.referralPicked(address(0), true);
            emit ReferralPicked(address(0));
            return address(0);
        }

        // get some entropy
        uint256 seed = _simpleRandom(state.totalTicketsSpent);
        // convert entropy to threshold weight
        uint256 threshold = seed % (state.totalPlayerWeight);
        seed >>= 48;
        uint256 sumWeight;
        for (uint64 i; i < state.epochWeights.length && i <= state.currentEpoch; i++) {
            sumWeight += state.epochWeights[i] * epochTickets[state.currentEpoch - i].length;
            if (threshold < sumWeight) {
                pickedAddress = epochTickets[state.currentEpoch - i][seed % epochTickets[state.currentEpoch - i].length];
                epochTickets[state.currentEpoch - i][seed % epochTickets[state.currentEpoch - i].length] = epochTickets[state.currentEpoch - i][epochTickets[state.currentEpoch - i].length - 1];
                epochTickets[state.currentEpoch - i].pop();
                state.totalPlayerWeight -= state.epochWeights[i];
                epochUserTickets[state.currentEpoch -i][pickedAddress] -= 1;
                break;
            }
        }
        unchecked {
            state.totalTicketsSpent += 1;
            epochs[state.currentEpoch].ticketsSpent += 1;
        }
        emit TicketSpent(state.currentEpoch, pickedAddress);

        if (address(controller) != address(0)) {
            controller.referralPicked(pickedAddress, false);
        }
        if (state.epochSize > 0 && epochs[state.currentEpoch].ticketsSpent >= state.epochSize) {
            _incrementEpoch();
        }
        emit ReferralPicked(pickedAddress);
    }

    /**
    * @dev Internal function to increment the current epoch
    */
    function _incrementEpoch() internal {
        state.totalPlayerWeight = 0;
        unchecked {
            state.currentEpoch++;
        }
        state.currentEpochStart = uint64(block.timestamp);
        epochs[state.currentEpoch].epochStart = uint64(block.timestamp);
        for (uint64 i; i < state.epochWeights.length && i <= state.currentEpoch; i++) {
            state.totalPlayerWeight += state.epochWeights[i] * epochTickets[state.currentEpoch - i].length;
        }
        emit EpochClosed(state.currentEpoch - 1);
        if (address(controller) != address(0)) {
            controller.epochClosed(state.currentEpoch - 1);
        }
    }

    /**
    * @dev Returns the current state of the AffiliateBooster contract
    * @return stateStruct The current state of the AffiliateBooster contract
    */
    function getState() external view returns (AffiliateBoosterState memory stateStruct) {
        return state;
    }

    /**
    * @dev Returns an array of epoch states for the given epoch IDs
    * @param epochIds The IDs of the epochs to get the states for
    * @return epochStates An array of epoch states for the given epoch IDs
    */
    function getEpochStates(uint256[] memory epochIds) external view returns (AffiliateBoosterEpoch[] memory epochStates) {
        epochStates = new AffiliateBoosterEpoch[](epochIds.length);
        for (uint256 i = 0; i < epochIds.length; i++) {
            epochStates[i] = epochs[epochIds[i]];
            epochStates[i].ticketsActive = uint64(epochTickets[epochIds[i]].length);
        }
    }

    /**
    * @dev Returns an array of epoch stakes for the given epoch ID
    * @param epochId The ID of the epoch to get the stakes for
    * @return tickets An array of epoch tickets for the given epoch ID
    */
    function getEpochTickets(uint256 epochId) external view returns (address[] memory tickets) {
        tickets = epochTickets[epochId];
    }

    function getEpochTicketsCount(uint256 epochId) external view returns (uint256 cnt) {
        return epochTickets[epochId].length;
    }

    function getEpochTicket(uint256 epochId, uint256 idx) external view returns (address user) {
        return epochTickets[epochId][idx];
    }

    /**
    * @dev Returns an array of the number of tickets held by the given user in the specified epochs
    * @param user The user to get the ticket counts for
    * @param epochIds The IDs of the epochs to get the ticket counts for
    * @return userTickets An array of the number of tickets held by the given user in the specified epochs
    */
    function getUserTickets(address user, uint256[] memory epochIds) external view returns (uint64[] memory userTickets) {
        userTickets = new uint64[](epochIds.length);
        for (uint256 i = 0; i < epochIds.length; i++) {
            if (epochIds[i] + state.epochWeights.length > state.currentEpoch) userTickets[i] = epochUserTickets[epochIds[i]][user];
        }
    }
}