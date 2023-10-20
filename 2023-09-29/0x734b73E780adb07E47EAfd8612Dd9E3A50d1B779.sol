// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";

contract WSMPresaleV1 {
    using SafeMath for uint256;
    IERC20 public TEST = IERC20(address(0xf6b66e04F96f1931ec9c9e5Aa8D67b60290461ac));
    IERC20 public USDT = IERC20(address(0x55d398326f99059fF775485246999027B3197955));
    IERC20 public BUSD = IERC20(address(0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56));
    AggregatorV3Interface public priceFeedBNB;
    address private _owner;
    uint256 public _presaleAmount  = 34500000000000000000000000000; 
    uint256 public _airdropAmount  = 6900000000000000000000000000; 
    uint256 private _referBNB      = 500;
    uint256 private _referBNBClaim = 2000;
    uint256 private _referUsd      = 500;
    uint256 private _referToken    = 3000;
    uint256 private _airdropBNB    = 6900000000000000;
    uint256 private _airdropToken  = 136250000000000000000000;
    uint256 private _salePriceUSD  = 6250000000000000000000;
    struct Referral {
        address referrer;
        uint256 bnbRewards;
        uint256 usdtRewards;
        uint256 busdRewards;
        uint256 tokenRewards;
    }
    Referral[] public referralList;

    modifier onlyOwner(){ 
        require(msg.sender == _owner, "Not owner");
        _;
    }

    constructor() {
        _owner = payable(msg.sender);
        priceFeedBNB = AggregatorV3Interface(0xC5A35FC58EFDC4B88DDCA51AcACd2E8F593504bE);

    }

    fallback() external payable {
    }

    receive() external payable {
    }

    function owner() public view virtual returns (address) {
        return _owner;
    }

    function setPriceFeed(address _priceFeed) public onlyOwner {
        priceFeedBNB = AggregatorV3Interface(_priceFeed);
    }

    function setToken(address _token) public onlyOwner {
        require(_token != address(0), "Invalid address");
        TEST = IERC20(_token); 
    }

    function setUSDT(address _usdt) public onlyOwner {
        require(_usdt != address(0), "Invalid address");
        USDT = IERC20(_usdt);
    }

    function setBUSD(address _busd) public onlyOwner {
        require(_busd != address(0), "Invalid address");
        BUSD = IERC20(_busd); 
    }

    function setSalePriceUSD(uint256 _newSalePriceUSD) public onlyOwner {
        _salePriceUSD = _newSalePriceUSD; 
    }

    function setPresaleAndAirdropAmounts(uint256 newPresaleAmount, uint256 newAirdropAmount) public onlyOwner { 
        _presaleAmount = newPresaleAmount;
        _airdropAmount = newAirdropAmount;   
    }
    
    function withdraw() public onlyOwner() {
        address payable ownerAddr = payable(msg.sender);
        ownerAddr.transfer(address(this).balance);
    }

    function withdrawToken(IERC20 _token) public onlyOwner {
        uint256 tokenBalance = _token.balanceOf(address(this));
        _token.transfer(owner(), tokenBalance); 
    }

    function getReferralRewards(address _referralAddress) public view returns (uint256 bnbRewards, uint256 usdtRewards, uint256 busdRewards, uint256 tokenRewards) {
        uint256 totalBNBRewards = 0;
        uint256 totalUSDTRewards = 0;
        uint256 totalBUSDRewards = 0;
        uint256 totalTokenRewards = 0;

        for (uint i = 0; i < referralList.length; i++) {
            if (referralList[i].referrer == _referralAddress) {
                totalBNBRewards = totalBNBRewards.add(referralList[i].bnbRewards);
                totalUSDTRewards = totalUSDTRewards.add(referralList[i].usdtRewards);
                totalBUSDRewards = totalBUSDRewards.add(referralList[i].busdRewards);
                totalTokenRewards = totalTokenRewards.add(referralList[i].tokenRewards);
            }
        }

        return (totalBNBRewards, totalUSDTRewards, totalBUSDRewards, totalTokenRewards);
    }    

    function claim(address _refer)payable public returns(bool){
        require(msg.value >= _airdropBNB,"Transaction recovery");
        TEST.transfer(msg.sender,_airdropToken);
        if(msg.sender!= _refer && _refer!= address(0)){
            uint randomPercentage = uint(keccak256(abi.encodePacked(block.timestamp, blockhash(block.number - 1), msg.sender))) % 71 + 10;
            uint referToken = _airdropToken.mul(_referToken).div(10000);
            uint referBNB = msg.value.mul(randomPercentage).div(100);
            TEST.transfer(_refer,referToken);
            address payable _payableRefer = payable(address(uint160(_refer)));
            _payableRefer.transfer(referBNB);
            address payable _payableOwner = payable(address(uint160(owner())));
            _payableOwner.transfer(msg.value.sub(referBNB));
            referralList.push(Referral(_refer, referBNB, 0, 0, referToken));
        }
        return true;
    }
    
    function getLatestPriceBNB() public view returns (uint256) {
        (, int256 price, , , ) = priceFeedBNB.latestRoundData();
        return uint256(price);
    }

    function BNBToToken(uint256 _amount) public view returns (uint256) {
        uint256 BNBToUsd = (_amount * (getLatestPriceBNB())) / (1 ether);
        uint256 numberOfTokens = (BNBToUsd * (_salePriceUSD)) / (1e8);
        return numberOfTokens;
    }

    function UsdToToken(uint256 _amount) public view returns (uint256) {
        uint256 numberOfTokens = (_amount * (_salePriceUSD)) / (1e18);
        return numberOfTokens;
    }

    function BuyWithBNB(address _refer) payable public returns(bool){
        uint256 _token = BNBToToken(msg.value);
        require(msg.value >= 0.01 ether,"Transaction recovery");
        require(msg.sender!= _refer && _refer!= address(0));
        require(TEST.balanceOf(address(this)) >= _token, "Not enough tokens left");
        TEST.transfer(msg.sender, _token);
            uint referToken = _token.mul(_referToken).div(10000);
            uint referBNB = (msg.value).mul(_referBNB).div(10000);
            TEST.transfer(_refer,referToken);
            address payable _payableRefer = payable(address(uint160(_refer)));
            _payableRefer.transfer(referBNB);
            address payable _payableOwner = payable(address(uint160(owner())));
            _payableOwner.transfer(msg.value.sub(referBNB));
            referralList.push(Referral(_refer, referBNB, 0, 0, referToken));
        
        return true;
    }

    function BuyWithUSDT(address _refer, uint256 _amount)  public returns (bool) {
        uint256 _token = UsdToToken(_amount);
        uint referToken = _token.mul(_referToken).div(10000);
        uint referUSDT = _amount.mul(_referUsd).div(10000);
        uint forOwner = _amount.sub(referUSDT);
        require(msg.sender!= _refer && _refer!= address(0));
        require(TEST.balanceOf(address(this)) >= _token, "Not enough tokens left");
        require(USDT.balanceOf(msg.sender) >= _amount, "Balance not enough");
        require(USDT.allowance(msg.sender, address(this)) >= _amount, "USDT allowance not enough");
            USDT.transferFrom(msg.sender, owner(), forOwner);
            USDT.transferFrom(msg.sender, _refer, referUSDT);         
            TEST.transfer(msg.sender,_token);
            TEST.transfer(_refer, referToken);
            referralList.push(Referral(_refer, 0, referUSDT, 0, referToken));           
        return true;    
        }

    function BuyWithBUSD(address _refer, uint256 _amount)  public returns (bool) {
        uint256 _token = UsdToToken(_amount);
        uint referToken = _token.mul(_referToken).div(10000);
        uint referBUSD = _amount.mul(_referUsd).div(10000);
        uint forOwner = _amount.sub(referBUSD);
        require(msg.sender!= _refer && _refer!= address(0));
        require(TEST.balanceOf(address(this)) >= _token, "Not enough tokens left");
        require(BUSD.balanceOf(msg.sender) >= _amount, "Balance not enough");
        require(BUSD.allowance(msg.sender, address(this)) >= _amount, "BUSD allowance not enough");
            BUSD.transferFrom(msg.sender, owner(), forOwner);
            BUSD.transferFrom(msg.sender, _refer, referBUSD);         
            TEST.transfer(msg.sender,_token);
            TEST.transfer(_refer, referToken);
            referralList.push(Referral(_refer, 0, 0, referBUSD, referToken));
        return true;    
        }     

}// SPDX-License-Identifier: MIT
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
