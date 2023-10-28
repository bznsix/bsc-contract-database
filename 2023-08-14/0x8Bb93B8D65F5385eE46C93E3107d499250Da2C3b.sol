// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

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

// File: @openzeppelin/contracts/access/Ownable.sol


// OpenZeppelin Contracts (last updated v4.9.0) (access/Ownable.sol)

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

// File: @openzeppelin/contracts/token/ERC20/IERC20.sol


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

// File: RoflcoinAirdrop.sol


pragma solidity ^0.8.9;



contract RoflcoinAirdrop is Ownable {
    // Address of the Roflcoin token contract
    address public roflcoinTokenAddress;

    // Airdrop amount per user (1,000,000,000 ROFL)
    uint256 public airdropAmount = 1_000_000_000 * 10**18;

    // Airdrop fee (0.0025 BNB)
    uint256 public airdropFee = 0.0025 ether;

    // Referral bonus amount (300,000,000 ROFL)
    uint256 public referralBonusAmount = 300_000_000 * 10**18;

    // Mapping to keep track of whether a wallet has received the airdrop
    mapping(address => bool) public hasReceivedAirdrop;

    // Mapping to store referrers and their referred users
    mapping(address => address) public referrers;

    // Event to log successful airdrop distribution
    event AirdropClaimed(address indexed user, uint256 amount, address indexed referrer);

    // Modifier to check if the sender is eligible for the airdrop
    modifier isEligibleForAirdrop() {
        require(!hasReceivedAirdrop[msg.sender], "Already claimed the airdrop");
        _;
    }

    // Constructor to set the address of the Roflcoin token contract
    constructor(address _roflcoinTokenAddress) {
        roflcoinTokenAddress = _roflcoinTokenAddress;
    }

    // Function to allow users to claim the airdrop with a referral address
    function claimAirdropWithReferral(address _referrer) external payable isEligibleForAirdrop {
        require(msg.value >= airdropFee, "Insufficient BNB for the airdrop fee");

        // Transfer the airdrop amount to the user
        IERC20(roflcoinTokenAddress).transfer(msg.sender, airdropAmount);

        // Mark the user as having received the airdrop
        hasReceivedAirdrop[msg.sender] = true;

        // Assign referral bonus to the referrer
        if (_referrer != address(0) && _referrer != msg.sender) {
            IERC20(roflcoinTokenAddress).transfer(_referrer, referralBonusAmount);
            referrers[msg.sender] = _referrer;
        }

        // Emit the event
        emit AirdropClaimed(msg.sender, airdropAmount, _referrer);
    }

    // Function to update the airdrop fee (only callable by the contract owner)
    function updateAirdropFee(uint256 _newFee) external onlyOwner {
        airdropFee = _newFee;
    }

    // Function to update the airdrop amount (only callable by the contract owner)
    function updateAirdropAmount(uint256 _newAmount) external onlyOwner {
        airdropAmount = _newAmount * 10**18;
    }

    // Function to update the referral bonus amount (only callable by the contract owner)
    function updateReferralBonusAmount(uint256 _newBonusAmount) external onlyOwner {
        referralBonusAmount = _newBonusAmount * 10**18;
    }

    // Function to withdraw BNB from the contract (only callable by the contract owner)
    function withdrawBNB() external onlyOwner {
        require(address(this).balance > 0, "Contract has no BNB balance");
        payable(owner()).transfer(address(this).balance);
    }

    // Function to withdraw any remaining ROFL tokens from the contract (only callable by the contract owner)
    function withdrawROFL() external onlyOwner {
        uint256 remainingROFL = IERC20(roflcoinTokenAddress).balanceOf(address(this));
        require(remainingROFL > 0, "Contract has no remaining ROFL balance");
        IERC20(roflcoinTokenAddress).transfer(owner(), remainingROFL);
    }
   
    // Function to send Roflcoin (ROFL) tokens to a specific address (only callable by the contract owner)
    function sendROFL(address _to, uint256 _amount) external onlyOwner {
        require(_to != address(0), "Invalid recipient address");

        IERC20 roflcoinToken = IERC20(roflcoinTokenAddress);
        require(roflcoinToken.balanceOf(address(this)) >= _amount, "Insufficient ROFL token balance in the contract");

        roflcoinToken.transfer(_to, _amount);
    }
}