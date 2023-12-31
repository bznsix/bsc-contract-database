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
// SPDX-License-Identifier: MIT

pragma solidity 0.8.23;

import "@openzeppelin/contracts/utils/Context.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract STO is Context, Ownable {
    using SafeMath for uint256;

    uint256 public rate; // token rate against of stable coin
    IERC20 private token; // token address
    address private wallet; // company wallet address to withdraw after STO is finished

    uint256 public softCap; // softCap for STO
    uint256 public hardCap; // hardCap for STO

    uint256 private weiRaised; // total raised funds in Stable Coins
    uint256 public endSTODate; // end date for STO
    uint256 public startSTODate; // start date for STO

    uint256 public minPurchase; // minimum investment amount in Stable Coin
    uint256 public maxPurchase; // maximum investment amount in Stable Coin

    string[] acceptedCoins; // array of Stable Coin names accepted to invest
    mapping(string => address) acceptedCoin; // address of accepted Stable Coin

    mapping(address => bool) isClaimed; // status to represent if a specfic user claimed
    mapping(address => uint256) totalInvestedOf; // total investment for a specific user
    mapping(address => uint256) purchasedTokensOf; // total bought token amount for a specific user
    mapping(address => mapping(string => uint256)) investedCoinsOf; // investment by Stable Coins for a specfic user

    /**
     * @param purchaser user who invests to buy tokens
     * @param beneficiary user who get tokens in practice
     * @param coins Stable Coin amount invested
     * @param coinName Stable Coin Name invested
     * @param tokens Token amount bought
     * @dev event which occurs when token was purchased successfully.
     */
    event TokensPurchased(
        address indexed purchaser,
        address indexed beneficiary,
        uint256 coins,
        string coinName,
        uint256 tokens
    );

    /**
     * @dev event which occurs when STO was started.
     */
    event STOStarted(
        uint256 startSTO,
        uint256 endSTO,
        uint256 minPurchase,
        uint256 maxPurchase,
        uint256 softCap,
        uint256 hardCap
    );

    /**
     * @dev event which occurs when raised fund for a specific user was refunded.
     */
    event Refunded(address indexed beneficiary);

    /**
     * @dev event which occurs when whole raised funds were withdrawn into company's account.
     */
    event Withdrawn(address indexed wallet);

    event StableCoinAdded(address indexed coin, string coinName);
    event StableCoinRemoved(string coinName);

    /**
     * @dev constructor
     */
    constructor(
        uint256 _rate,
        address _wallet,
        address _token,
        uint256 _startSTO,
        uint256 _endSTO,
        uint256 _minPurchase,
        uint256 _maxPurchase,
        uint256 _softCap,
        uint256 _hardCap,
        uint256 _weiRaised
    ) {
        require(
            _endSTO > _startSTO,
            "STO: The ending date must be after the starting date"
        );
        require(
            _softCap > 0 && _hardCap > _softCap,
            "STO: softCap and hardCap must be larger than 0"
        );
        require(_rate > 0, "STO: rate must be larger than 0");
        require(_wallet != address(0), "STO: wallet is the zero address");
        require(_token != address(0), "STO: token is the zero address");
        rate = _rate;
        wallet = _wallet;
        token = IERC20(_token);
        startSTODate = _startSTO;
        endSTODate = _endSTO;
        minPurchase = _minPurchase;
        maxPurchase = _maxPurchase;
        softCap = _softCap;
        hardCap = _hardCap;
        weiRaised = _weiRaised;
        acceptedCoins = ["USDT", "USDC", "BUSD", "BKTUSD"];
        acceptedCoin["USDT"] = 0x55d398326f99059fF775485246999027B3197955;
        acceptedCoin["USDC"] = 0x8AC76a51cc950d9822D68b83fE1Ad97B32Cd580d;
        acceptedCoin["BUSD"] = 0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56;
        acceptedCoin["BKTUSD"] = 0x8f12f949A5e82364602D6bA27DAfFD41FBD7d9ae;
    }

    /**
     * @dev stoActive modifier possible all actions when STO is processed.
     */
    modifier stoActive() {
        require(
            block.timestamp < endSTODate &&
                block.timestamp > startSTODate &&
                hardCap > weiRaised,
            "STO: STO must be active"
        );
        _;
    }

    /**
     * @dev stoFailed modifier possible all actions when STO isn't active.
     */
    modifier stoFailed() {
        require(
            endSTODate < block.timestamp && softCap > weiRaised,
            "STO: STO must not be active"
        );
        _;
    }

    /**
     * @notice STO must be active to call this function.
     * @param _beneficiary the address whose get token.
     * @param _weiAmount the wei amount of Stable Coin to send
     * @param _coinName the stable coin name like (USDT, USDC or nay other Token that you accepting)
     * @dev Purchase Tokens
     */
    function buyTokens(
        address _beneficiary,
        uint256 _weiAmount,
        string memory _coinName
    ) public stoActive {
        require(acceptedCoin[_coinName] != address(0), "Invalid Coin Name");
        require(
            IERC20(acceptedCoin[_coinName]).balanceOf(_msgSender()) >=
                _weiAmount,
            "Not Enough Coin Amount"
        );

        require(
            IERC20(acceptedCoin[_coinName]).allowance(
                _msgSender(),
                address(this)
            ) >= _weiAmount,
            "NOT Enough Coin Amount Approved"
        );
        _preValidatePurchase(_beneficiary, _weiAmount);
        uint256 tokens = _getTokenAmount(_weiAmount);
        IERC20(acceptedCoin[_coinName]).transferFrom(
            _msgSender(),
            address(this),
            _weiAmount
        );
        weiRaised = weiRaised.add(_weiAmount);
        isClaimed[_beneficiary] = false;
        totalInvestedOf[_beneficiary] = totalInvestedOf[_beneficiary].add(
            _weiAmount
        );
        purchasedTokensOf[_beneficiary] = purchasedTokensOf[_beneficiary].add(
            tokens
        );
        investedCoinsOf[_beneficiary][_coinName] = investedCoinsOf[
            _beneficiary
        ][_coinName].add(_weiAmount);
        _deliverTokens(_beneficiary, tokens);
        emit TokensPurchased(
            _msgSender(),
            _beneficiary,
            _weiAmount,
            _coinName,
            tokens
        );
    }

    /**
     * @param _beneficiary the User address to refund
     * @dev If STO goal is not reached softCap, then Investors Claim their funds that they spend for Purchse token.
     */
    function claimRefund(address _beneficiary) public stoFailed {
        require(
            isClaimed[_beneficiary] == false,
            "STO: Only STO member can refund coins!"
        );
        isClaimed[_beneficiary] = true;
        for (uint256 i = 0; i < acceptedCoins.length; i++) {
            if (investedCoinsOf[_beneficiary][acceptedCoins[i]] > 0) {
                IERC20(acceptedCoin[acceptedCoins[i]]).transfer(
                    _beneficiary,
                    investedCoinsOf[_beneficiary][acceptedCoins[i]]
                );
                totalInvestedOf[_beneficiary].sub(
                    investedCoinsOf[_beneficiary][acceptedCoins[i]]
                );
            }
        }
        emit Refunded(_beneficiary);
    }

    /**
     * @dev Withdraw Whole Raised Funds into Company's account when STO is finished successfully.
     */
    function withdraw() external onlyOwner {
        for (uint256 i = 0; i < acceptedCoins.length; i++) {
            IERC20(acceptedCoin[acceptedCoins[i]]).transfer(
                wallet,
                IERC20(acceptedCoin[acceptedCoins[i]]).balanceOf(address(this))
            );
        }
        emit Withdrawn(wallet);
    }

    /**
     * @dev Internal function checking all rules and regulation before purchase token This is internal function no one could call from outside
     * @param _beneficiary Its beneficary address
     * @param _weiAmount wei amount
     * @notice Until and unless owner also couldn't call
     */
    function _preValidatePurchase(
        address _beneficiary,
        uint256 _weiAmount
    ) internal view {
        require(
            _beneficiary != address(0),
            "STO: beneficiary is the zero address"
        );
        require(_weiAmount != 0, "STO: weiAmount is 0");
        require(_weiAmount >= minPurchase, "have to send at least minPurchase");
        require(_weiAmount <= maxPurchase, "have to send at most maxPurchase");
        this;
    }

    /**
     * @dev internal function which deliver Token to User
     */
    function _deliverTokens(
        address _beneficiary,
        uint256 _tokenAmount
    ) internal {
        token.transfer(_beneficiary, _tokenAmount);
    }

    /**
     * @param _weiAmount amount in wei of USD from investor
     * @dev Internally Get Token Amount
     */
    function _getTokenAmount(
        uint256 _weiAmount
    ) internal view returns (uint256) {
        return _weiAmount.mul(10 ** 18).div(rate);
    }

    /**
     * @notice Only Owner can set Token that accepting for purchase Token that on sell.
     * @param _coin Stable Coin Address to add
     * @param _coinName Stable Coin Name to add
     */
    function acceptCoin(
        address _coin,
        string memory _coinName
    ) external onlyOwner {
        require(acceptedCoin[_coinName] == address(0), "Already Exist");
        acceptedCoin[_coinName] = _coin;
        acceptedCoins.push(_coinName);
        emit StableCoinAdded(_coin, _coinName);
    }

    /**
     * @notice Owner Remove Token Accept Token to purchase token.
     * @param _coinName Stable Coin Name to remove
     */
    function removeAcceptedCoin(string memory _coinName) external onlyOwner {
        require(acceptedCoin[_coinName] != address(0), "Token Not Exist");
        acceptedCoin[_coinName] = address(0);
        for (uint256 i = 0; i < acceptedCoins.length; i++) {
            if (
                keccak256(abi.encodePacked(acceptedCoins[i])) ==
                keccak256(abi.encodePacked(_coinName))
            ) {
                acceptedCoins[i] = acceptedCoins[acceptedCoins.length - 1];
                acceptedCoins.pop();
            }
        }
        emit StableCoinRemoved(_coinName);
    }

    /**
     * @notice Only owner can set rate
     * @dev Set Rate
     * @param _rate New Rate
     */
    function setRate(uint256 _rate) external onlyOwner {
        require(_rate > 0, "STO: rate must be larger than 0");
        rate = _rate;
    }

    /**
     * @notice Only owner can set wallet address
     * @dev Set wallet address
     * @param _wallet new wallet address
     */
    function setWallet(address _wallet) external onlyOwner {
        require(_wallet != address(0), "STO: wallet is the zero address");
        wallet = _wallet;
    }

    /**
     * @notice Only owner can set softCap
     * @dev Set softCap
     * @param _softCap new softCap in wei
     */
    function setSoftCap(uint256 _softCap) external onlyOwner {
        require(_softCap > 0, "STO: softCap must be larger than 0");
        softCap = _softCap;
    }

    /**
     * @notice Only owner can set hardCap
     * @dev Set hardCap
     * @param _hardCap new hardCap in wei
     */
    function setHardCap(uint256 _hardCap) external onlyOwner {
        require(_hardCap > 0, "STO: hardCap must be larger than 0");
        hardCap = _hardCap;
    }

    /**
     * @notice Only owner can set startSTODate
     * @dev Set startSTODate
     * @param _startSTODate new start STO date
     */
    function setStartSTODate(uint256 _startSTODate) external onlyOwner {
        require(_startSTODate > 0, "STO: start STO Date must be larger than 0");
        startSTODate = _startSTODate;
    }

    /**
     * @notice Only owner can set endSTODate
     * @dev Set endSTODate
     * @param _endSTODate new end STO date
     */
    function setEndSTODate(uint256 _endSTODate) external onlyOwner {
        require(_endSTODate > 0, "STO: end STO Date must be larger than 0");
        endSTODate = _endSTODate;
    }

    /**
     * @notice Only owner can set minPurchase
     * @dev Set minPurchase
     * @param _minPurchase new minPurchase
     */
    function setMinPurchase(uint256 _minPurchase) external onlyOwner {
        require(_minPurchase > 0, "STO: minPurchase must be larger than 0");
        minPurchase = _minPurchase;
    }

    /**
     * @notice Only owner can set maxPurchase
     * @dev Set maxPurchase
     * @param _maxPurchase new maxPurchase
     */
    function setMaxPurchase(uint256 _maxPurchase) external onlyOwner {
        require(_maxPurchase > 0, "STO: maxPurchase must be larger than 0");
        maxPurchase = _maxPurchase;
    }

    /**
     * @dev Get rate
     */
    function getRate() external view returns (uint256) {
        return rate;
    }

    /**
     * @dev Its function just getting current block time from blockchain.
     */
    function getCurrentTimestamp() external view returns (uint256) {
        return block.timestamp;
    }

    /**
     * @dev Get STO End Time.
     */
    function getEndSTOTimestamp() external view returns (uint256) {
        return endSTODate;
    }

    /**
     * @dev Get STO Start Time.
     */
    function getStartSTOTimestamp() external view returns (uint256) {
        return startSTODate;
    }

    /**
     * @dev Get total raised Stable Coin in wei.
     */
    function getWeiRaised() external view returns (uint256) {
        return weiRaised;
    }

    /**
     * @dev Get hardcap in wei.
     */
    function getHardCap() external view returns (uint256) {
        return hardCap;
    }

    /**
     * @dev Get softCap in wei.
     */
    function getSoftCap() external view returns (uint256) {
        return softCap;
    }

    /**
     * @dev Get minPurchase in wei
     */
    function getMinPurchase() external view returns (uint256) {
        return minPurchase;
    }

    /**
     * @dev Get maxPurchase in wei
     */
    function getMaxPurchase() external view returns (uint256) {
        return maxPurchase;
    }

    /**
     * @dev Get total invested Stable Coin for a specific user.
     */
    function getTotalInvestedOf() external view returns (uint256) {
        return totalInvestedOf[_msgSender()];
    }

    /**
     * @dev Get total purchased tokens amount for a specific user.
     */
    function getPurchasedTokensOf() external view returns (uint256) {
        return purchasedTokensOf[_msgSender()];
    }
}
