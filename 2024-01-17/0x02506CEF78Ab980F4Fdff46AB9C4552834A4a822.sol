// OpenZeppelin Contracts (last updated v5.0.0) (token/ERC20/IERC20.sol)

pragma solidity ^0.8.20;

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
     * @dev Returns the value of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the value of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Moves a `value` amount of tokens from the caller's account to `to`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address to, uint256 value) external returns (bool);

    /**
     * @dev Returns the remaining number of tokens that `spender` will be
     * allowed to spend on behalf of `owner` through {transferFrom}. This is
     * zero by default.
     *
     * This value changes when {approve} or {transferFrom} are called.
     */
    function allowance(address owner, address spender) external view returns (uint256);

    /**
     * @dev Sets a `value` amount of tokens as the allowance of `spender` over the
     * caller's tokens.
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
    function approve(address spender, uint256 value) external returns (bool);

    /**
     * @dev Moves a `value` amount of tokens from `from` to `to` using the
     * allowance mechanism. `value` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(address from, address to, uint256 value) external returns (bool);
}

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

// OpenZeppelin Contracts (last updated v5.0.0) (utils/Context.sol)

pragma solidity ^0.8.20;

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


/**
 * @dev Contract module which provides a basic access control mechanism, where
 * there is an account (an owner) that can be granted exclusive access to
 * specific functions.
 *
 * The initial owner is set to the address provided by the deployer. This can
 * later be changed with {transferOwnership}.
 *
 * This module is used through inheritance. It will make available the modifier
 * `onlyOwner`, which can be applied to your functions to restrict their use to
 * the owner.
 */
abstract contract Ownable is Context {
    address private _owner;

    /**
     * @dev The caller account is not authorized to perform an operation.
     */
    error OwnableUnauthorizedAccount(address account);

    /**
     * @dev The owner is not a valid owner account. (eg. `address(0)`)
     */
    error OwnableInvalidOwner(address owner);

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the address provided by the deployer as the initial owner.
     */
    constructor(address initialOwner) {
        if (initialOwner == address(0)) {
            revert OwnableInvalidOwner(address(0));
        }
        _transferOwnership(initialOwner);
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
        if (owner() != _msgSender()) {
            revert OwnableUnauthorizedAccount(_msgSender());
        }
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
        if (newOwner == address(0)) {
            revert OwnableInvalidOwner(address(0));
        }
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


contract EventPoolSCv1 is ReentrancyGuard, Ownable {
    struct Pool {
        address owner;
        address token;
        uint256 rewardPerMessage;
        uint256 totalRewardPool;
        uint256 startDate;
        string name;
    }

    Pool[] public pools;
    mapping(address => mapping(address => uint256)) public claimable;
    mapping(address => uint256) public totalDeposited;
    mapping(address => uint256) public totalClaimed;

    event PoolCreated(uint256 indexed poolId, address indexed owner, address token, uint256 rewardPerMessage, uint256 totalRewardPool, uint256 startDate, string name);
    event PoolBalanceAdded(address indexed participant, address indexed token, uint256 amount);
    event PoolBalanceClaimed(address indexed token, address indexed claimer, uint256 netReward);
    event PoolCancelled(uint256 indexed poolId, uint256 refundAmount);
    event PoolStartDateModified(uint256 indexed poolId, uint256 newStartDate);
    event PoolNameModified(uint256 indexed poolId, string newName);


    mapping(address => bool) public whitelistedTokens;
    address[] public whitelistedTokenAddresses;

    event TokenWhitelisted(address indexed tokenAddress);
    event TokenRemovedFromWhitelist(address indexed tokenAddress);


    address public taxWallet;
    uint256 public taxPercentage;

    event TaxChanged(uint256 newTaxPercentage);
    event TaxWalletChanged(address newTaxWallet);

    constructor(address authorizedWallet) Ownable(msg.sender) {
        addTokenToWhitelist(0x55d398326f99059fF775485246999027B3197955);
        addTokenToWhitelist(0x0000000000000000000000000000000000000000);
        setAuthorised(authorizedWallet, true);
        taxWallet = msg.sender;
        taxPercentage = 10;
    }

    // pool
    function createPoolAndDeposit(address token, uint256 rewardPerMessage, uint256 totalRewardPool, uint256 startDate, string memory name) external payable returns (uint256 poolId) {
        require(whitelistedTokens[token], "Token not whitelisted");
        require(startDate > block.timestamp + 1 days, "Start date must be at least 24 hours from now");

        Pool memory newPool;
        newPool.owner = msg.sender;
        newPool.token = token;
        newPool.rewardPerMessage = rewardPerMessage;
        newPool.totalRewardPool = totalRewardPool;
        newPool.startDate = startDate;
        newPool.name = name;
        pools.push(newPool);
        poolId = pools.length - 1;

        if (token == address(0)) {
            require(msg.value == totalRewardPool, "Incorrect amount of BNB");
        } else {
            require(IERC20(token).transferFrom(msg.sender, address(this), totalRewardPool), "Transfer failed");
        }

        totalDeposited[token] += totalRewardPool;

        emit PoolCreated(poolId, msg.sender, token, rewardPerMessage, totalRewardPool, startDate, name);
    }

    function modifyPoolName(uint256 poolId, string memory newName) external {
        require(poolId < pools.length, "Invalid pool ID");
        Pool storage poolToModify = pools[poolId];
        
        require(poolToModify.owner == msg.sender, "Not the pool owner");
        require(block.timestamp < poolToModify.startDate - 1 days, "Cannot modify pool name within 24 hours of start");
        
        poolToModify.name = newName;
        emit PoolNameModified(poolId, newName); 
    }

    function modifyStartDate(uint256 poolId, uint256 newStartDate) external {
        require(poolId < pools.length, "Invalid pool ID");
        Pool storage poolToModify = pools[poolId];
        
        require(poolToModify.owner == msg.sender, "Not the pool owner");
        require(newStartDate > block.timestamp + 1 days, "Cannot modify start date within 24 hours of start");
        
        poolToModify.startDate = newStartDate;
        emit PoolStartDateModified(poolId, newStartDate);
    }

    function addBalance(address participant, address token, uint256 amount) external {
        require(authorised[msg.sender], "Agent not authorised");
        
        uint256 potentialTotalClaimed = totalClaimed[token] + claimable[participant][token] + amount;
        require(potentialTotalClaimed <= totalDeposited[token], "Amount exceeds total deposited for the token");

        claimable[participant][token] += amount;

        emit PoolBalanceAdded(participant, token, amount);
    }

    function claim(address token) external nonReentrant {
      uint256 totalReward = claimable[msg.sender][token];
      require(totalReward > 0, "No claimable amount found");

      uint256 taxAmount = (totalReward * taxPercentage) / 100;
      uint256 amountAfterTax = totalReward - taxAmount;

      totalClaimed[token] += totalReward;

      claimable[msg.sender][token] = 0;

      if (token == address(0)) {
          payable(taxWallet).transfer(taxAmount);
          payable(msg.sender).transfer(amountAfterTax);
      } else {
          require(IERC20(token).transfer(taxWallet, taxAmount), "Tax transfer failed");
          require(IERC20(token).transfer(msg.sender, amountAfterTax), "Transfer failed");
      }

      emit PoolBalanceClaimed(token, msg.sender, amountAfterTax);
  }

    function cancelAndRefundPool(uint256 poolId) external onlyOwner {
        require(poolId < pools.length, "Invalid pool ID");
        Pool storage poolToCancel = pools[poolId];
        
        require(poolToCancel.owner != address(0), "Already cancelled");
        
        uint256 refundAmount = poolToCancel.totalRewardPool;

        address owner = poolToCancel.owner;
        poolToCancel.owner = address(0);
        
        if (refundAmount > 0) {
            if (poolToCancel.token == address(0)) {
                payable(owner).transfer(refundAmount);
            } else {
                require(IERC20(poolToCancel.token).transfer(owner, refundAmount), "Transfer failed");
            }
        }
      
        emit PoolCancelled(poolId, refundAmount);
    }

    function getClaimable(address user, address[] memory tokens) public view returns (uint256[] memory) {
        uint256[] memory claimableAmounts = new uint256[](tokens.length);
        for (uint256 i = 0; i < tokens.length; i++) {
            claimableAmounts[i] = claimable[user][tokens[i]];
        }
        return claimableAmounts;
    }

    function setTaxPercentage(uint256 _taxPercentage) external onlyOwner {
        require(_taxPercentage >= 5 && _taxPercentage <= 50, "Tax percentage should be between 5 and 50");
        taxPercentage = _taxPercentage;
        emit TaxChanged(_taxPercentage);
    }

    function setTaxWallet(address _taxWallet) external onlyOwner {
        require(_taxWallet != address(0), "Invalid tax wallet address");
        taxWallet = _taxWallet;
        emit TaxWalletChanged(_taxWallet);
    }

    function getWhitelistedTokens() public view returns (address[] memory) {
        return whitelistedTokenAddresses;
    }

    function addTokenToWhitelist(address tokenAddress) public onlyOwner {
        require(!whitelistedTokens[tokenAddress], "Already whitelisted, can't add");
        whitelistedTokens[tokenAddress] = true;
        whitelistedTokenAddresses.push(tokenAddress);
        emit TokenWhitelisted(tokenAddress);
    }    

    function removeTokenFromWhitelist(address tokenAddress) external onlyOwner {
        require(whitelistedTokens[tokenAddress], "Not whitelisted, can't remove");
        whitelistedTokens[tokenAddress] = false;
        for (uint256 i = 0; i < whitelistedTokenAddresses.length; i++) {
            if (whitelistedTokenAddresses[i] == tokenAddress) {
                whitelistedTokenAddresses[i] = whitelistedTokenAddresses[whitelistedTokenAddresses.length - 1];
                whitelistedTokenAddresses.pop();
                break;
            }
        }
        emit TokenRemovedFromWhitelist(tokenAddress);
    }

    mapping(address => bool) private authorised;

    event Authorised(address indexed user, bool indexed isAuthorised);
    function setAuthorised(address _user, bool _isUserAuthorised) public onlyOwner {
      require(authorised[_user] != _isUserAuthorised, authorised[_user] ? "User is already a manager" : "User doesn't have manager rights");
      authorised[_user] = _isUserAuthorised;
      emit Authorised(_user, _isUserAuthorised);
    }

    function isAuthorised(address _user) public view returns (bool) {
      return authorised[_user];
    }

    

}