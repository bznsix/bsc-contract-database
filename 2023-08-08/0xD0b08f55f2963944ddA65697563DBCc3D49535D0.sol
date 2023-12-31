// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.17;
import "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/interfaces/IERC20.sol";

contract LotteryPayment is Ownable {

    event LotteryPriceUpdated(uint256 amount);
    event ChainLinkContractAddressUpdated(address indexed contractAddress);
    event ReferralPercentageUpdated(uint256 percentage);
    event TokenAddressUpdated(address indexed tokenAddress);

    uint256 public lotteryPrice;
    address public chainLinkContractAddress;
    uint256 public referralPercentage;
    address public tokenAddress;

    struct Payment{
        address tokenAddress;
        uint256 amount;
        bool referralFlag;
        address referralAddress;
    }
    
    constructor() {
        lotteryPrice = 10 * 1e8;
        chainLinkContractAddress = 0xB97Ad0E74fa7d920791E90258A6E2085088b4320;
        referralPercentage = 3;
        tokenAddress = 0x55d398326f99059fF775485246999027B3197955;
    }

    function setLotteryPrice(uint256 _amount) external onlyOwner {
        lotteryPrice = _amount;
        emit LotteryPriceUpdated(lotteryPrice);
    }

    function setChainLinkContractAddress(address _contractAddress) external onlyOwner {
        chainLinkContractAddress = _contractAddress;
        emit ChainLinkContractAddressUpdated(chainLinkContractAddress);
    }

    function setReferralPercentage(uint256 _percentage) external onlyOwner {
        referralPercentage = _percentage;
        emit ReferralPercentageUpdated(referralPercentage);
    }

    function setTokenAddress(address _tokenAddress) external onlyOwner{
        tokenAddress = _tokenAddress;
        emit TokenAddressUpdated(tokenAddress);
    }

    function buyLottery(Payment calldata payment) external returns(bool) {
        uint256 amount;
        amount = payment.amount;
        require(amount > 0 , "Invalid amount");
        require(amount >= getPaymentAmount(), "Invaid Payment Amount");
        require(tokenAddress == payment.tokenAddress, "Invalid Token Address");

        if(payment.referralFlag == true){
        uint256 referralAmount;
        referralAmount = amount *  referralPercentage / 100;
        amount =  amount - referralAmount;
        bool referralTransaction = IERC20(tokenAddress).transferFrom(msg.sender,payment.referralAddress,referralAmount);
        require(referralTransaction, "Referral Amount Transaction Failed");
        }
        bool paymentTransaction = IERC20(tokenAddress).transferFrom(msg.sender,owner(),amount);
        require(paymentTransaction, "Payment Transaction Failed");
        return true;
    }

    function getPaymentAmount() public view returns(uint256) {
        uint256 price = uint256(getCurrentPrice());
        uint256 paymentAmount =  lotteryPrice * 1e18;
        paymentAmount = paymentAmount / price;
        return paymentAmount;
    }

    function getCurrentPrice() public view returns(int256) {
        (, int256 price, , , ) = AggregatorV3Interface(chainLinkContractAddress).latestRoundData();
        return price;
    }

    function recoverToken(address walletAddress, uint256 amount) external onlyOwner {
        require(walletAddress != address(0), "Null address");
        require(amount <= IERC20(tokenAddress).balanceOf(address(this)), "Insufficient amount");
        bool recoverTransaction = IERC20(tokenAddress).transfer(
            walletAddress,
            amount
        );
        require(recoverTransaction, "Payment Transaction Failed");
    }

}// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (interfaces/IERC20.sol)

pragma solidity ^0.8.0;

import "../token/ERC20/IERC20.sol";
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
