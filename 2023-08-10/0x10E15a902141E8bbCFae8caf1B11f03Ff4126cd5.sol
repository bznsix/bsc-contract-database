// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";

abstract contract Ownable {

    address public owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor() {
        owner = msg.sender;
        emit OwnershipTransferred(address(0), msg.sender);
    }

    modifier onlyOwner() {
        require(owner == msg.sender, "Ownable: caller is not the owner");
        _;
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(
            newOwner != address(0),
            "Ownable: new owner is the zero address"
        );
        emit OwnershipTransferred(owner, newOwner);
        owner = newOwner;
    }
}

 contract Presale is Ownable{
    using SafeMath for uint256;

    bool public isPresaleOpen = false;

    struct preBuy {
        string recipient;
        uint256 btcAmount;
        uint256 tokenAmount;
        uint256 feeInSats;
        address referrer;
    }

    mapping (address => preBuy) public preBuys;

    mapping (address => uint256) public paidTotal;
    // address where funds are collected
    address public wallet;
    // BTC-ETH feed address
    address public btcEthFeed;
    // buy rate: satoshi amount
    uint public rate;
    // referral fee
    uint public referralFeeRateBP = 100; // 1%
    // amount of wei raised
    uint public raisedAmount;

    uint256 public minBuyLimit = 7 * 10 ** 15; // min buyAmount is 0.1ETH

    event TokenPurchase(
        address indexed purchaser,
        uint256 amount,
        uint256 tokenAmount
    );

    receive() external payable {}

    constructor(uint256 _rate, address _wallet, address _btcEthFeed) {
        require(_rate > 0);
        require(_wallet != address(0));

        rate = _rate;
        wallet = _wallet;
        btcEthFeed = _btcEthFeed;
    }

    function setWallet(address _wallet) external onlyOwner {
        wallet = _wallet;
    }

    function startPresale() external onlyOwner {
        require(!isPresaleOpen, "Presale is open");
        
        isPresaleOpen = true;
    }

    function closePrsale() external onlyOwner {
        require(isPresaleOpen, "Presale is not open yet.");
        
        isPresaleOpen = false;
    }

    function setMinBuyLimit(uint256 _amount) external onlyOwner {
        minBuyLimit = _amount;    
    }

    function setRate(uint256 _rate) external onlyOwner {
        rate = _rate;    
    }

    function setReferralFeeRate(uint256 _rate) external onlyOwner {
        require(_rate <= 1000, "Max referral fee is 10%");
        rate = _rate;    
    }

    function getBTCPriceInETH() public view returns (uint256) {
        AggregatorV3Interface feed = AggregatorV3Interface(
            btcEthFeed
        );
        (
            ,
            /*uint80 roundID*/
            int256 price, /*uint startedAt*/ /*uint timeStamp*/ /*uint80 answeredInRound*/
            ,
            ,

        ) = feed.latestRoundData();
        // decimal is 18
        return uint256(price);
    }

    // allows buyers to put their busd to get some token once the presale will closes
    function buy(string memory _recipient, uint256 _feeInSats, address _referrer) public payable {
        require(isPresaleOpen, "Presale is not open yet");
        require(msg.value >= minBuyLimit, "You need to sell at least some min amount");
        uint256 referralFee = 0;
        if (_referrer != address(0) && msg.sender != _referrer && preBuys[msg.sender].referrer == address(0)) {
            preBuys[msg.sender].referrer = _referrer;
        }
        if (preBuys[msg.sender].referrer != address(0)) {
            referralFee = msg.value.mul(referralFeeRateBP).div(10000);
            payable(preBuys[msg.sender].referrer).transfer(referralFee);
        }
        uint256 btcPrice = getBTCPriceInETH();

        // fee in ETH
        uint256 feeInETH = _feeInSats.mul(btcPrice).div(10 ** 8);
        // calculate token amount to be bought
        uint256 sellAmount = msg.value.sub(feeInETH).sub(referralFee);
        preBuys[msg.sender].tokenAmount = sellAmount.mul(10 ** 8).div(btcPrice).div(rate);
        preBuys[msg.sender].btcAmount = sellAmount.mul(10 ** 8).div(btcPrice);
        // update state
        raisedAmount = raisedAmount.add(msg.value);

        preBuys[msg.sender].recipient = _recipient;
        preBuys[msg.sender].feeInSats = _feeInSats;

        paidTotal[msg.sender] = paidTotal[msg.sender].add(sellAmount);
        emit TokenPurchase(
            msg.sender,
            sellAmount,
            preBuys[msg.sender].tokenAmount
        );
    }

    // allows operator wallet to get the fund deposited in the contract
    function retreiveFund() public {
        require(msg.sender == wallet);
        require(!isPresaleOpen, "Presale is not over yet");
        address payable recipient = payable(msg.sender);
        recipient.transfer(address(this).balance);
    }
}// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.6.0) (utils/math/SafeMath.sol)

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
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface AggregatorV3Interface {
  function decimals() external view returns (uint8);

  function description() external view returns (string memory);

  function version() external view returns (uint256);

  function getRoundData(uint80 _roundId)
    external
    view
    returns (
      uint80 roundId,
      int256 answer,
      uint256 startedAt,
      uint256 updatedAt,
      uint80 answeredInRound
    );

  function latestRoundData()
    external
    view
    returns (
      uint80 roundId,
      int256 answer,
      uint256 startedAt,
      uint256 updatedAt,
      uint80 answeredInRound
    );
}
