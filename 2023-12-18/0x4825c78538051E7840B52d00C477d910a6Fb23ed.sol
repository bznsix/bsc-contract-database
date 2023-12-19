// File: @openzeppelin/contracts/utils/Context.sol


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

// File: @openzeppelin/contracts/access/Ownable.sol


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

// File: @openzeppelin/contracts/token/ERC20/IERC20.sol


// OpenZeppelin Contracts (last updated v4.5.0) (token/ERC20/IERC20.sol)

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IERC20 {
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
}

// File: GPAD/Tier_Staking.sol


pragma solidity 0.8.12;



contract TierStaking is Ownable {

    address public immutable token;
    address public receiver;
    bool public active;
    uint256 public totalStaking;
    mapping(uint256 => address) public staking;

    struct UserInfo {
        uint256 amount;
        uint256 tier;
        uint256 stakedAt;
    }

    mapping (address => UserInfo) public userInfo;

    struct Tier {
        uint256 totalSpots;
        uint256 stakers;
        uint256 penaltyStartRate;
        uint256 penaltyReduceStep;
        uint256 penaltyPeriodStep;
        uint256 penaltyTotalStep;
        uint256 minimum;
    }

    mapping (uint256 => Tier) public tiers;

    event OnStake(address indexed staker, uint256 amount, uint256 tier);
    event OnWithdraw(address indexed receiver, uint256 amount, uint256 burn, uint256 tier);

    modifier onActive {
        require(active == true, "The staking is not active.");
        _;
    }

    constructor(address _token, address _receiver){
        require(_token != address(0), "Zero address");
        token = _token;
        receiver = _receiver;
    }

    function addTier(
        uint256 _id,
        uint256 _totalSpots, 
        uint256 _penaltyStartRate, 
        uint256 _penaltyReduceStep, 
        uint256 _penaltyPeriodStep, 
        uint256 _penaltyTotalStep,
        uint256 _minimum
    ) external onlyOwner {
        require(tiers[_id].totalSpots == 0, "Tier already exists");
        require(_penaltyTotalStep * _penaltyReduceStep == _penaltyStartRate, "Step rate is not valid");
        tiers[_id] = Tier({
            totalSpots: _totalSpots,
            stakers: 0,
            penaltyStartRate: _penaltyStartRate,
            penaltyReduceStep: _penaltyReduceStep,
            penaltyPeriodStep: _penaltyPeriodStep,
            penaltyTotalStep: _penaltyTotalStep,
            minimum: _minimum
        });
    }

    function setTier(
        uint256 _id,
        uint256 _totalSpots, 
        uint256 _penaltyStartRate, 
        uint256 _penaltyReduceStep, 
        uint256 _penaltyPeriodStep, 
        uint256 _penaltyTotalStep,
        uint256 _minimum
    ) external onlyOwner {
        require(_totalSpots >= tiers[_id].stakers, "The spots could not be below current stakers.");
        require(_penaltyTotalStep * _penaltyReduceStep == _penaltyStartRate, "Step rate is not valid");
        tiers[_id].totalSpots = _totalSpots;
        tiers[_id].penaltyStartRate = _penaltyStartRate;
        tiers[_id].penaltyReduceStep = _penaltyReduceStep;
        tiers[_id].penaltyPeriodStep = _penaltyPeriodStep;
        tiers[_id].penaltyTotalStep = _penaltyTotalStep;
        tiers[_id].minimum = _minimum;
    }

    function setActive(bool _active) external onlyOwner {
        active = _active;
    }

    function setReceiver(address _receiver) external onlyOwner {
        require(_receiver != address(0), "Zero address");
        receiver = _receiver;
    }

    function getUserTier(address _user) public view returns (uint256) {
        return userInfo[_user].tier;
    }

    function stake(uint256 _tier) public onActive {
        require(getUserTier(_msgSender()) == 0, "Already have Tier");
        require(tiers[_tier].totalSpots - tiers[_tier].stakers >= 1, "The tier is full");
        require(IERC20(token).transferFrom(_msgSender(), address(this), tiers[_tier].minimum), "Fail transfer");
        userInfo[_msgSender()] = UserInfo({
            amount: tiers[_tier].minimum,
            tier: _tier,
            stakedAt: block.timestamp
        });
        totalStaking ++;
        staking[totalStaking] = _msgSender();
        tiers[_tier].stakers ++;

        emit OnStake(_msgSender(), tiers[_tier].minimum, _tier);
    }

    function getWithdrawble(address _wallet) public view returns (uint256) {
        uint256 withdrawable;
        if (getUserTier(_wallet) != 0) {
            Tier memory tier = tiers[userInfo[_wallet].tier];
            uint256 hasStakedPeriod = block.timestamp - userInfo[_wallet].stakedAt;
            uint256 Step = hasStakedPeriod / tier.penaltyPeriodStep;
            uint256 panalty;
            if (Step >= tier.penaltyTotalStep) {
                panalty = 0;
            } else {
                panalty = tier.penaltyStartRate - (tier.penaltyReduceStep * Step);
            }
            withdrawable = userInfo[_wallet].amount * (10000 - panalty) / 10000;
        } else {
            withdrawable = 0;
        }
        return withdrawable;
    }

    function withdraw() public {
        require(getUserTier(_msgSender()) != 0, "Do not stake yet");
        uint256 withdrawable = getWithdrawble(_msgSender());
        require(IERC20(token).transfer(_msgSender(), withdrawable), "Fail transfer");

        uint256 burn = userInfo[_msgSender()].amount - withdrawable;
        if (burn != 0) {
            require(IERC20(token).transfer(receiver, burn), "Fail transfer");
        }

        tiers[userInfo[_msgSender()].tier].stakers = tiers[userInfo[_msgSender()].tier].stakers - 1;

        emit OnWithdraw(receiver, withdrawable, burn, userInfo[_msgSender()].tier);

        userInfo[_msgSender()] = UserInfo({
            amount: 0,
            tier: 0,
            stakedAt: 0
        });
    }

    function withdrawEmergency (
        address _token
    ) public onlyOwner {
        require(_token != address(0), "Invalid token address");
        require(_token != address(this), "Cannot withdraw contract's token");
        require(IERC20(_token).transfer(_msgSender(), IERC20(_token).balanceOf(address(this))), "Fail transfer");
    }
}