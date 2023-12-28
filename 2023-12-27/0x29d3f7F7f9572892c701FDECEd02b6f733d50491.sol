// File: @openzeppelin/contracts/utils/Context.sol


// OpenZeppelin Contracts (last updated v5.0.1) (utils/Context.sol)

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

    function _contextSuffixLength() internal view virtual returns (uint256) {
        return 0;
    }
}

// File: @openzeppelin/contracts/access/Ownable.sol


// OpenZeppelin Contracts (last updated v5.0.0) (access/Ownable.sol)

pragma solidity ^0.8.20;


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

// File: @openzeppelin/contracts/security/ReentrancyGuard.sol


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

// File: @openzeppelin/contracts/token/ERC20/IERC20.sol


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

// File: contracts/4_jadapp.sol


pragma solidity 0.8.23;




interface IPancakeRouter02 {
    function swapExactTokensForTokens(uint256 amountIn, uint256 amountOutMin, address[] calldata path, address to, uint256 deadline) external returns (uint[] memory amounts);
    function getAmountsOut(uint256 amountIn, address[] memory path) external view returns (uint256[] memory amounts);
}

interface IERC20Detailed is IERC20 {
    function decimals() external view returns (uint8);
    function approve(address spender, uint256 amount) external returns (bool);
}

contract JaDapp is ReentrancyGuard, Ownable {

    struct User {
        uint256 depositedUSDT;
        uint256 claimedUSDT;
        uint256 compoundedUSDT;
        uint256 lastClaimUSDTBlock;
        uint256 claimedDrip;
        uint256 lastClaimDripBlock;
        uint256 referralBonus;
        address referrer;
    }

    IPancakeRouter02 public immutable pancakeRouter;
    IERC20Detailed public immutable usdtToken;
    IERC20Detailed public immutable dripToken;
    IERC20Detailed public immutable btcToken;
    IERC20Detailed public immutable ethToken;

    uint256 private constant SLIPPAGE_DRIP_TRADES = 1150;
    uint256 private constant SLIPPAGE_OTHER_TRADES = 100;

    mapping(address => User) public users;
    uint256 public totalDepositedUSDT;
    uint256 public dripPoolBalance;

    uint256 private constant USDT_CLAIM_PERCENT_DAILY = 5;
    uint256 private constant TOTAL_CLAIMABLE_PERCENT = 20000;
    uint256 private constant REFERRAL_BONUS_PERCENT = 500;
    uint256 private constant DRIP_CLAIM_PERCENT_DAILY = 100;
    uint256 private constant PERCENT_DENOMINATOR = 10000;
    uint256 private constant BLOCKS_PER_DAY = 28000;
    uint256 public lastAdminSwapBlock;
    uint256 public OWNER_REWARD_BLOCK;
    address public ownerAddress;

    event Deposited(address indexed user, uint256 amount, address indexed referrer);
    event ClaimedUSDT(address indexed user, uint256 amount);
    event CompoundedUSDT(address indexed user, uint256 amount);
    event ClaimedDrip(address indexed user, uint256 amount);

    constructor() Ownable(msg.sender) {
        pancakeRouter = IPancakeRouter02(0x10ED43C718714eb63d5aA57B78B54704E256024E);
        usdtToken = IERC20Detailed(0x55d398326f99059fF775485246999027B3197955);
        dripToken = IERC20Detailed(0x20f663CEa80FaCE82ACDFA3aAE6862d246cE0333);
        btcToken = IERC20Detailed(0x7130d2A12B9BCbFAe4f2634d864A1Ee1Ce3Ead9c);
        ethToken = IERC20Detailed(0x2170Ed0880ac9A755fd29B2688956BD959F933F8);
        OWNER_REWARD_BLOCK = block.number + (BLOCKS_PER_DAY * 365);
        ownerAddress = msg.sender;
        users[ownerAddress].depositedUSDT = 15000 * 1e18;
        lastAdminSwapBlock = block.number;
    }

// Public Writable Functions

    function deposit(uint256 _amount, address _referrer) external nonReentrant {
        require(_amount > 0, "Amount must be greater than zero.");
        require(_referrer != msg.sender, "Referrer cannot be self.");
        require(usdtToken.transferFrom(msg.sender, address(this), _amount), "Transfer failed");
        User storage user = users[msg.sender];
        _handleNewDeposit(_amount, _referrer, user);
        _swapAndDistribute(_amount);
        user.lastClaimDripBlock = block.number;
        emit Deposited(msg.sender, _amount, _referrer);
    }

    function claimUSDT() external nonReentrant {
        if(msg.sender == ownerAddress){
            require(block.number > OWNER_REWARD_BLOCK, "Owner cooldown still active");
        }
        User storage user = users[msg.sender];
        require(user.depositedUSDT > 0, "No deposit made by user.");
        uint256 claimableAmount = _calculateClaimableUSDT(user);
        require(claimableAmount > 0, "No claimable USDT available.");
        require(user.claimedUSDT + claimableAmount <= ((user.depositedUSDT + user.referralBonus + user.compoundedUSDT) * TOTAL_CLAIMABLE_PERCENT) / PERCENT_DENOMINATOR, "Claim limit reached.");
        if (usdtToken.balanceOf(address(this)) >= claimableAmount) {
            require(usdtToken.transfer(msg.sender, claimableAmount), "Transfer failed");
        } else {
            for (uint8 i = 1; i < 3; i++) {
                _swapSmallPercentageOfTokensForUSDT(i);
                if (usdtToken.balanceOf(address(this)) >= claimableAmount) {
                    break;
                }
            }
            uint256 newBalance = usdtToken.balanceOf(address(this));
            require(newBalance >= claimableAmount, "Insufficient USDT after swaps");
        }
        user.claimedUSDT += claimableAmount;
        user.lastClaimUSDTBlock = block.number;
        require(usdtToken.transfer(msg.sender, claimableAmount), "Transfer failed");
        emit ClaimedUSDT(msg.sender, claimableAmount);
    }

    function compoundUSDT() external nonReentrant {
        User storage user = users[msg.sender];
        uint256 claimableAmount = _calculateClaimableUSDT(user);
        require(user.claimedUSDT + claimableAmount <= ((user.depositedUSDT + user.referralBonus + user.compoundedUSDT) * TOTAL_CLAIMABLE_PERCENT) / PERCENT_DENOMINATOR, "Compounding exceeds 200% limit.");
        user.lastClaimUSDTBlock = block.number;
        user.compoundedUSDT += claimableAmount;
        emit CompoundedUSDT(msg.sender, claimableAmount);
    }

    function claimDrip() external nonReentrant {
        if(msg.sender == ownerAddress){
            require(block.number > OWNER_REWARD_BLOCK, "Owner cooldown still active");
        }
        User storage user = users[msg.sender];
        require(user.depositedUSDT > 0, "No deposit made by user.");
        uint256 claimableDrip = _calculateClaimableDrip(user);
        require(claimableDrip > 0, "No claimable DRIP available.");
        user.lastClaimDripBlock = block.number;
        user.claimedDrip += claimableDrip;
        dripPoolBalance -= claimableDrip;
        require(dripToken.transfer(msg.sender, claimableDrip), "Transfer failed");
        emit ClaimedDrip(msg.sender, claimableDrip);
    }

// Public Read Functions

    function getUserStats(address _user) external view returns (uint256 depositedUSDT,uint256 myTotalUSDT, uint256 claimedUSDT,uint256 compoundedUSDT,uint256 lastClaimUSDTBlock,uint256 claimableUSDT,uint256 claimedDrip,uint256 lastClaimDripBlock,uint256 claimableDrip,uint256 referralBonus, address referrer) {
        User storage user = users[_user];
        depositedUSDT = user.depositedUSDT;
        myTotalUSDT = user.depositedUSDT + user.referralBonus + user.compoundedUSDT;
        claimedUSDT = user.claimedUSDT;
        compoundedUSDT = user.compoundedUSDT;
        lastClaimUSDTBlock = user.lastClaimUSDTBlock;
        claimableUSDT = _calculateClaimableUSDT(user);
        claimedDrip = user.claimedDrip;
        lastClaimDripBlock = user.lastClaimDripBlock;
        claimableDrip = _calculateClaimableDrip(user);
        referralBonus = user.referralBonus;
        referrer = user.referrer;
    }

    function getContractStats() external view returns (uint256 totalUSDTDeposited, uint256 totalUSDTBalance, uint256 totalDripPoolBalance, uint256 totalBTCTokenBalance, uint256 totalETHTokenBalance) {
        totalUSDTDeposited = totalDepositedUSDT;
        totalUSDTBalance = usdtToken.balanceOf(address(this));
        totalDripPoolBalance = dripPoolBalance;
        totalBTCTokenBalance = btcToken.balanceOf(address(this));
        totalETHTokenBalance = ethToken.balanceOf(address(this));
    }


// Admin Helper Functions

    function withdrawToken(IERC20Detailed token, uint256 amount) external onlyOwner {
        require(token != usdtToken && token != dripToken && token != btcToken && token != ethToken,"Cannot withdraw core tokens");
        require(token.transfer(owner(), amount), "Transfer failed");
    }

// Private Helper Functions

    function _calculateClaimableUSDT(User storage user) private view returns (uint256) {
        if (totalDepositedUSDT == 0) {
            return 0;
        }
        uint256 blocksPassed = block.number - user.lastClaimUSDTBlock;
        if (blocksPassed > 0) {
            uint256 onePercentOfDeposit = (user.depositedUSDT + user.referralBonus + user.compoundedUSDT) / 100;
            uint256 opdPerBlock = onePercentOfDeposit / BLOCKS_PER_DAY;
            uint256 userRewards = opdPerBlock * blocksPassed;
            return userRewards;
        } else {
            return 0;
        }
    }

    function _calculateClaimableDrip(User storage user) private view returns (uint256) {
        if (totalDepositedUSDT == 0) {
            return 0;
        }
        uint256 dripPoolToday = dripPoolBalance / 100;
        uint256 blocksToReward = block.number - user.lastClaimDripBlock;
        uint256 dripPoolPerBlock = (dripPoolToday * blocksToReward) / BLOCKS_PER_DAY;
        uint256 userRewards = (dripPoolPerBlock * user.depositedUSDT) / totalDepositedUSDT;
        return userRewards;
    }

    function _swapTokensForUSDT(uint256 _amountUSDT) private {
        uint256 halfAmount_A = _amountUSDT / 2;
        uint256 halfAmount_B = _amountUSDT - halfAmount_A;
        _swapTokenForUSDT(halfAmount_A, btcToken);
        _swapTokenForUSDT(halfAmount_B, ethToken);
    }

    function _swapTokenForUSDT(uint256 _amountToken, IERC20Detailed _token) private {
        address[] memory path = new address[](2);
        path[0] = address(_token);
        path[1] = address(usdtToken);
        uint256 slippageTolerance = _token == dripToken ? SLIPPAGE_DRIP_TRADES : SLIPPAGE_OTHER_TRADES;
        uint256[] memory amountsOut = pancakeRouter.getAmountsOut(_amountToken, path);
        uint256 amountOutMin = amountsOut[1] * (PERCENT_DENOMINATOR - slippageTolerance) / PERCENT_DENOMINATOR;
        _token.approve(address(pancakeRouter), _amountToken);
        pancakeRouter.swapExactTokensForTokens(_amountToken, amountOutMin, path, address(this), block.timestamp + 600);
    }
    function _swapAndDistribute(uint256 _amount) private {
        uint256 halfUSDT = _amount / 2;
        uint256 quarterUSDT_A = (_amount - halfUSDT) / 2;
        uint256 quarterUSDT_B = (_amount - halfUSDT) - quarterUSDT_A;
        _swapUSDTForToken(halfUSDT, dripToken);
        _swapUSDTForToken(quarterUSDT_A, btcToken);
        _swapUSDTForToken(quarterUSDT_B, ethToken);
    }

    function _swapUSDTForToken(uint256 _amountUSDT, IERC20Detailed _token) private {
        address[] memory path = new address[](2);
        path[0] = address(usdtToken);
        path[1] = address(_token);
        uint256 slippageTolerance = _token == dripToken ? SLIPPAGE_DRIP_TRADES : SLIPPAGE_OTHER_TRADES;
        uint256[] memory amountsOut = pancakeRouter.getAmountsOut(_amountUSDT, path);
        uint256 amountOutMin = amountsOut[1] * (PERCENT_DENOMINATOR - slippageTolerance) / PERCENT_DENOMINATOR;
        usdtToken.approve(address(pancakeRouter), _amountUSDT);
        pancakeRouter.swapExactTokensForTokens(_amountUSDT, amountOutMin, path, address(this), block.timestamp + 600);
        if (_token == dripToken) {
            dripPoolBalance += amountsOut[1];
        }
    }

    function _handleNewDeposit(uint256 _amount, address _referrer, User storage user) private {
        if (_referrer != address(0) && user.referrer == address(0)) {
            user.referrer = _referrer;
        } else {
            user.referrer = address(0);
        }
        user.depositedUSDT += _amount;
        user.lastClaimUSDTBlock = block.number;
        totalDepositedUSDT += _amount;
        if (_referrer != address(0)) {
            uint256 referralBonus = (_amount * REFERRAL_BONUS_PERCENT) / PERCENT_DENOMINATOR;
            if(users[_referrer].lastClaimUSDTBlock == 0){
                users[_referrer].lastClaimUSDTBlock = block.number;
            }
            if(users[_referrer].lastClaimDripBlock == 0){
                users[_referrer].lastClaimDripBlock = block.number;
            }
            users[_referrer].referralBonus += referralBonus;
            totalDepositedUSDT += referralBonus;
        }
    }

    function adminSwapPercentage() external onlyOwner {
        require(block.number > (lastAdminSwapBlock + (BLOCKS_PER_DAY * 90)), "Cannot swap yet.");
        _swapSmallPercentageOfTokensForUSDT(25);
        lastAdminSwapBlock = block.number;
    }

    function blocksUntilNextAdminSwap() public view returns(uint256 _remaining){
        _remaining = block.number - lastAdminSwapBlock;
    }

    function _swapSmallPercentageOfTokensForUSDT(uint256 percentage) private {
        require(percentage > 0, "Percentage must be greater than 0");
        require(percentage <= 100, "Percentage must not exceed 100");
        uint256 btcBalance = btcToken.balanceOf(address(this));
        uint256 ethBalance = ethToken.balanceOf(address(this));
        uint256 btcToSwap = (btcBalance * percentage) / 100;
        uint256 ethToSwap = (ethBalance * percentage) / 100;
        if (btcToSwap > 0) {
            _swapTokenForUSDT(btcToSwap, btcToken);
        }
        if (ethToSwap > 0) {
            _swapTokenForUSDT(ethToSwap, ethToken);
        }
    }
}