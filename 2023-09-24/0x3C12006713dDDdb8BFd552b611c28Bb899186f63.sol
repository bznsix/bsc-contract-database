// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.9.0) (token/ERC20/IERC20.sol)

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IERC20Upgradeable {
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
// OpenZeppelin Contracts (last updated v4.9.0) (security/ReentrancyGuard.sol)

pragma solidity ^0.8.0;

/**
 * @dev Contract module that helps prevent reentrant calls to a function.
 *
 * Inheriting from `ReentrancyGuard` will make the {nonReentrant} modifier
 * available, which can be applied to functions to make sure there are no nested
 * (reentrant) calls to them.
 *
 * Note that because there is a single `nonReentrant` guard, functions marked as
 * `nonReentrant` may not call one another. This can be worked around by making
 * those functions `private`, and then adding `external` `nonReentrant` entry
 * points to them.
 *
 * TIP: If you would like to learn more about reentrancy and alternative ways
 * to protect against it, check out our blog post
 * https://blog.openzeppelin.com/reentrancy-after-istanbul/[Reentrancy After Istanbul].
 */
abstract contract ReentrancyGuard {
    // Booleans are more expensive than uint256 or any type that takes up a full
    // word because each write operation emits an extra SLOAD to first read the
    // slot's contents, replace the bits taken up by the boolean, and then write
    // back. This is the compiler's defense against contract upgrades and
    // pointer aliasing, and it cannot be disabled.

    // The values being non-zero value makes deployment a bit more expensive,
    // but in exchange the refund on every call to nonReentrant will be lower in
    // amount. Since refunds are capped to a percentage of the total
    // transaction's gas, it is best to keep them low in cases like this one, to
    // increase the likelihood of the full refund coming into effect.
    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;

    uint256 private _status;

    constructor() {
        _status = _NOT_ENTERED;
    }

    /**
     * @dev Prevents a contract from calling itself, directly or indirectly.
     * Calling a `nonReentrant` function from another `nonReentrant`
     * function is not supported. It is possible to prevent this from happening
     * by making the `nonReentrant` function external, and making it call a
     * `private` function that does the actual work.
     */
    modifier nonReentrant() {
        _nonReentrantBefore();
        _;
        _nonReentrantAfter();
    }

    function _nonReentrantBefore() private {
        // On the first call to nonReentrant, _status will be _NOT_ENTERED
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");

        // Any calls to nonReentrant after this point will fail
        _status = _ENTERED;
    }

    function _nonReentrantAfter() private {
        // By storing the original value once again, a refund is triggered (see
        // https://eips.ethereum.org/EIPS/eip-2200)
        _status = _NOT_ENTERED;
    }

    /**
     * @dev Returns true if the reentrancy guard is currently set to "entered", which indicates there is a
     * `nonReentrant` function in the call stack.
     */
    function _reentrancyGuardEntered() internal view returns (bool) {
        return _status == _ENTERED;
    }
}
// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC20/IERC20Upgradeable.sol";

contract Presale is ReentrancyGuard {
    // Immutable variables
    IERC20Upgradeable public immutable presaleToken; // ERC20 token for presale
    address public constant burnAddress = 0x000000000000000000000000000000000000dEaD; // Burn address
    address public immutable owner; // Contract owner's address

    // Constants
    uint8 private constant vestingPeriods = 4; // Number of vesting periods
    uint256 public pricePerTokenInWei = 6000000000; // 0.000000006 ethers/token (18 decimal places)
    uint256 public softcap = 1000 ether;
    uint256 public hardcap = 3000 ether;
    uint256 public amountOfTokensPurchased;

    // State variables
    // mapping(address => uint256) public referralRewards; // Referral rewards for each address
    mapping(address => uint256) public lockedUntil; // Lock timestamp for each address
    mapping (address => uint256) public vestedTokens; // Vested tokens for each address
    mapping (address => uint256) purchasedByUser;

    uint256 public launchTimestamp; // Timestamp when presale starts
    uint256 public presaleEndTime; // Timestamp when presale ends
    uint256 public vestingTime = 90 days; // Vesting period duration
    // uint256 public TotalReferralAccumulated; // Total referral rewards accumulated

    // Constructor
    constructor(
        address _presaleTokenAddress,
        uint256 _launchTimestamp,
        uint256 _presaleEndTime
    ) {
        presaleToken = IERC20Upgradeable(_presaleTokenAddress);
        launchTimestamp = _launchTimestamp;
        presaleEndTime = _presaleEndTime;
        owner = msg.sender;
    }

    // Modifier to restrict function access to the owner
    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner");
        _;
    }

    // Function to retrieve the contract's balance
    function getBalance() public view returns (uint256) {
        return address(this).balance;
    }

    // Function to set the launch timestamp
    function setLaunchTimestamp(uint256 _timestamp) external onlyOwner {
        launchTimestamp = _timestamp;
    }

    // Function to set the presale end time
    function setPresaleEndTime(uint256 _timestamp) external onlyOwner {
        presaleEndTime = _timestamp;
    }

    // Function to set the vesting time
    function setVestingTime(uint256 _time) external onlyOwner {
        vestingTime = _time;
    }

    // Function to buy tokens in the presale
    function buyTokens() external payable nonReentrant {
        // Check presale timing
        require(block.timestamp >= launchTimestamp, "Presale has not started yet");
        require(block.timestamp <= presaleEndTime, "Presale has ended");
        require(address(this).balance <= hardcap, "Hardcap reached");

        // Calculate Ether amount and perform checks
        uint256 ethAmount = msg.value;
        require(ethAmount >= 0.05 ether, "Minimum purchase: 0.05 BNB");
        require(ethAmount <= 100 ether, "Maximum purchase: 100 BNB");

        // Calculate token amount based on Ether sent
        uint256 tokenAmount = (ethAmount) / pricePerTokenInWei;

        // Ensure token amount is reasonable
        require(tokenAmount > 0, "Token amount is too low");
        require(presaleToken.balanceOf(address(this)) >= tokenAmount, "Insufficient tokens in the contract");

        // Calculate immediate release and remaining tokens
        uint256 immediateRelease = tokenAmount * 20 / 100;
        require(presaleToken.transfer(msg.sender, immediateRelease), "Token transfer failed");

        uint256 remainingTokens = tokenAmount - immediateRelease;

        // Update vested tokens and lock until timestamp
        vestedTokens[msg.sender] += remainingTokens;
        purchasedByUser[msg.sender] += tokenAmount;
        lockedUntil[msg.sender] = block.timestamp + vestingTime;
        amountOfTokensPurchased += tokenAmount;
    }

    // Function to unlock vested tokens
    function unlockTokens() external nonReentrant {
        uint256 tokenAmount = vestedTokens[msg.sender];
        require(lockedUntil[msg.sender] <= block.timestamp, "Tokens are locked");
        require(tokenAmount > 0, "No tokens to unlock");

        uint256 purchasedAmount = purchasedByUser[msg.sender];
        uint256 unlockedAmount = (purchasedAmount * 20) / 100;

        uint256 sentAmount;

        if (tokenAmount <= unlockedAmount)
            sentAmount = tokenAmount;
        else {
            sentAmount = unlockedAmount;
        }
        lockedUntil[msg.sender] = block.timestamp + vestingTime;
        vestedTokens[msg.sender] -= sentAmount;

        require(presaleToken.transfer(msg.sender, sentAmount), "Token transfer failed");
    }

    // Function to withdraw Ether in case of emergency
    function emergencyWithdrawEther(uint256 amount) external onlyOwner {
        require(amount <= address(this).balance, "Insufficient balance");
        payable(msg.sender).transfer(amount);
    }

    // Function to withdraw BEP20 tokens in case of emergency
    function emergencyWithdrawBEP20(address tokenAddress, uint256 amount) external onlyOwner {
        IERC20Upgradeable token = IERC20Upgradeable(tokenAddress);
        require(amount <= token.balanceOf(address(this)), "Insufficient balance");
        require(token.transfer(msg.sender, amount), "Token transfer failed");
    }

    // Fallback function to receive Ether
    receive() external payable {}
}
