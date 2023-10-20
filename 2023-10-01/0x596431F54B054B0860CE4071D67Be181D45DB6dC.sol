// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

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


contract VestingContract is Ownable {
    IERC20 public token;
    
    uint256 public unlockTime; // Unlock time for locked tokens in Unix timestamp
    
    uint256 public initialSupply; // Set during deployment
    uint256 public tokenPublicsale=0;
    uint256 public totalTokensLocked = 0;
    uint256 public totalTokensMarketing = 0;
    uint256 public tokensLocked=0;
    bool public tokenLocked = false;


    bool public saleTokensReleased = false;
    bool public marketingTokensReleased = false;
    bool public remainingTokensReleased = false;

    constructor(address _token) {
        token = IERC20(_token);
        
        unlockTime = 1759255200; // 30 Sep 2025, Unix timestamp
        initialSupply = token.totalSupply();
        totalTokensMarketing=(initialSupply * 15) / 100; //marketing locked up
        totalTokensLocked=(initialSupply * 25) / 100; //25% sales till 2025
        tokenPublicsale=(initialSupply * 40) / 100; //public sale locked up
        tokensLocked=(initialSupply * 20) / 100;//20%locked up 

    }
    
    // Function to release 40% of tokens for sale
    function releaseSaleTokens() external onlyOwner {
        require(!saleTokensReleased, "Sale tokens have already been released");
        
        uint256 tokensForSale = (initialSupply * 40) / 100;
        token.transfer(msg.sender, tokensForSale);
        tokenPublicsale = tokensForSale;
        tokenPublicsale=0;
        saleTokensReleased = true;
    }
    
    // Function to release 15% of tokens for marketing
    function releaseMarketingTokens() external onlyOwner {
        require(!marketingTokensReleased, "Marketing tokens have already been released");
        
        uint256 tokensForMarketing = (initialSupply * 15) / 100;
        token.transfer(msg.sender, tokensForMarketing);
        totalTokensMarketing = tokensForMarketing;
        marketingTokensReleased = true;
    }
    // Function to lock up 20% of the initial supply
function lockTokens() external onlyOwner {
   
    require(!tokenLocked, "Tokens have already been locked");

    uint256 tokensToLock = (initialSupply * 20) / 100;
    require(tokensToLock > 0, "No tokens left to lock");

    // Transfer tokens to this contract
    token.transferFrom(msg.sender, address(this), tokensToLock);
    tokensLocked = tokensToLock;
    tokenLocked = true;

}

// Function to unlock the previously locked tokens
function unlockTokens() external onlyOwner {
    require(!remainingTokensReleased, "Remaining tokens have already been released");

    uint256 tokensToUnlock = tokensLocked;
    require(tokensToUnlock > 0, "No tokens to unlock");
    require(block.timestamp >= unlockTime, "Tokens are locked until the unlock time");

    // Transfer locked tokens to the owner
    token.transfer(msg.sender, tokensToUnlock);
    tokensLocked = 0;
}
    
    // Function to release remaining 25% of tokens after the locked period
    function releaseRemainingTokens() external onlyOwner {
        require(!remainingTokensReleased, "Remaining tokens have already been released");
    require(block.timestamp >= 1704067200, "Tokens are locked until the unlock time");
    
    uint256 tokensForRelease = (initialSupply * 25) / 100;
    require(tokensForRelease > 0, "No tokens to release");

    // Transfer the remaining locked tokens
    token.transfer(msg.sender, tokensForRelease);
    totalTokensLocked -= tokensForRelease;
    remainingTokensReleased = true;
    }
    function transferVestingContractOwnership(address newOwner) external onlyOwner {
    transferOwnership(newOwner);
}
}