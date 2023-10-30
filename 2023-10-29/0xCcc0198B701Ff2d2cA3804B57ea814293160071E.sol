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
    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);
}

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

// File: contracts/1_Storage.sol


pragma solidity ^0.8.19;



interface ITokenPool {
    struct Stake {
        address user;
        uint256 amount;
        uint256 startTime;
        uint256 endTime;
        uint256 finalReward;
        bool claimed;
    }

    struct User {
        uint256[] stakedIds;
    }

    /*//////////////////////////////////////////////////////////////
                        EVENTS
    //////////////////////////////////////////////////////////////*/

    /// @dev is emitted when a stake is successful
    event Staked(
        address indexed user,
        uint256 amount,
        uint256 tenure,
        uint256 id,
        uint256 startTime
    );

    /// @dev is emitted when an unstake is successful
    event Unstaked(
        address indexed user,
        uint256 amount,
        uint256 rewardClaimed,
        uint256 id,
        uint256 claimTime
    );

    /*//////////////////////////////////////////////////////////////
                        EXTERNAL FUNCTIONS
    //////////////////////////////////////////////////////////////*/

    /// @dev allows users to stake their tokens for any of the three periods
    /// 3 months, 6 months & 12 months
    /// @param amount_ is the amount of tokens to stake
    /// @param tenure_ is the stake tenure in months
    /// @return id is the stake identifier
    /// @notice tenure_ should be 3,6,12
    function stake(
        uint256 amount_,
        uint256 tenure_
    ) external returns (uint256 id);

    /// @dev allows user to claim their rewards + stake at the end of staking period
    /// @param id_ is the unique id of the stake
    function unstake(uint256 id_) external;
}

contract TokenPool is ITokenPool, Ownable {
    /*//////////////////////////////////////////////////////////////
                        STATE VARIABLES
    //////////////////////////////////////////////////////////////*/
    IERC20 public immutable POOL_TOKEN;

    uint256 public rewardPool = 100 * 10e18;
    uint256 public nextStakeId;

    mapping(uint256 => Stake) public stakeInfo;
    mapping(uint256 => uint256) public rewardPercent; // 2 decimal; eg: 8% = 800
    mapping(address => uint256) public userStaked;
    mapping(address => uint256) public pendingYield;
    mapping(address => uint256) public totalEarnings;

    constructor(address mct_, address owner_) {
        POOL_TOKEN = IERC20(mct_);
        
        /// Preset APY
        rewardPercent[3] = 1420;
        rewardPercent[6] = 2850;
        rewardPercent[12] = 5710;

        /// @dev transfer ownership
        _transferOwnership(owner_);
    }

    /*//////////////////////////////////////////////////////////////
                        EXTERNAL FUNCTIONS
    //////////////////////////////////////////////////////////////*/

    /// @dev see IStaking-{stake}
    function stake(
        uint256 amount_,
        uint256 tenure_
    ) external override returns (uint256 id) {
        require(
            tenure_ == 3 || tenure_ == 6 || tenure_ == 12,
            "TokenPool: Invalid Tenure"
        );

        /// @dev transfers staking token into contract custody
        require(
            POOL_TOKEN.transferFrom(msg.sender, address(this), amount_),
            "TokenPool: Transfer From Failed"
        );

        uint256 reward = (rewardPercent[tenure_] * amount_) / 10e4;
        require(rewardPool >= reward, "TokenPool: Reward Pool Exhausted");
        rewardPool -= reward;

        /// @dev initiates staking info
        nextStakeId++;

        id = nextStakeId;
        stakeInfo[nextStakeId] = Stake(
            msg.sender,
            amount_,
            block.timestamp,
            block.timestamp + (tenure_ * 30 days), /// @FIXME: change to days on mainnet
            reward,
            false
        );

        userStaked[msg.sender] += amount_;
        pendingYield[msg.sender] += reward;

        emit Staked(msg.sender, amount_, tenure_, id, block.timestamp);
    }

    /// @dev see IStaking-{unstake}
    function unstake(uint256 id_) external override {
        require(id_ <= nextStakeId, "TokenPool: Invalid ID");

        Stake storage s = stakeInfo[id_];
        require(s.user == msg.sender, "TokenPool: Invalid Claimer");
        require(!s.claimed, "TokenPool: Already Claimed");
        require(block.timestamp >= s.endTime, "TokenPool: Immature Claim");

        s.claimed = true;

        uint256 finalSettlement = s.amount + s.finalReward;
        userStaked[msg.sender] -= s.amount;
        pendingYield[msg.sender] -= s.finalReward;

        totalEarnings[msg.sender] += s.finalReward;

        POOL_TOKEN.transfer(msg.sender, finalSettlement);

        emit Unstaked(
            msg.sender,
            s.amount,
            s.finalReward,
            id_,
            block.timestamp
        );
    }

    /// @dev allows admin to set the apy for different tenures
    /// @param apys_ represent the apy for 3,6 and 12 months respectively
    function setAPY(uint256[] memory apys_) external onlyOwner {
        uint256 len = apys_.length;
        require(len == 3, "TokenPool: Invalid Length");

        rewardPercent[3] = apys_[0];
        rewardPercent[6] = apys_[1];
        rewardPercent[12] = apys_[2];
    }

    /// @dev allows admin to withdraw the reward pool tokens added
    /// @notice cannot withdraw staked user funds and their allocated rewards
    /// @param amount_ is the token amount to be withdrawn
    function emergencyWithdraw(uint256 amount_) external onlyOwner {
        require(amount_ <= rewardPool, "TokenPool: Invalid Withdraw Amount");

        rewardPool -= amount_;
        POOL_TOKEN.transfer(owner(), amount_);
    }
}