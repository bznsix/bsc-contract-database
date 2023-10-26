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
pragma solidity ^0.8.11;

import '@openzeppelin/contracts/access/Ownable.sol';
import '@openzeppelin/contracts/token/ERC20/IERC20.sol';

contract Reward is Ownable {
  address public deployer;
  uint256 public totalDeposited;

  uint256 public constant YEAR_SECOND = 31577600;
  uint256 public rewardRate;

  IERC20 public rewardToken;

  mapping(address => uint256) public stakingBalance;
  mapping(address => uint256) public startTime;
  mapping(address => uint256) public userReward;
  mapping(address => uint256) public userWithdrawn;

  event RewardsWithdrawal(address indexed to, uint256 amount);
  event LogWithdrawToken(address token, address account, uint256 amount);
  event LogUpdateDeployerAddress(address newDeployer);
  event Deposit(address user, uint256 amount);
  event AddStaker(address indexed staker, uint256 amount, uint256 startTime);
  event UpdateStaker(address indexed staker, uint256 amount, uint256 startTime);

  constructor(address _rewardToken, uint256 _rewardRate) {
    require(_rewardToken != address(0), 'RewardsToken Address 0 validation');
    rewardRate = _rewardRate;
    rewardToken = IERC20(_rewardToken);
    deployer = _msgSender();
  }

  modifier onlyDeployer() {
    require(
      deployer == _msgSender() || owner() == _msgSender(),
      'Caller is not the deployer'
    );
    _;
  }

  function _calculateRewards(address _staker) internal view returns (uint256) {
    uint256 timeDiff = block.timestamp - startTime[_staker];
    uint256 reward = stakingBalance[_staker] * rewardRate * timeDiff;
    return reward / (YEAR_SECOND * 100);
  }

  function getTotalRewards(address _staker) public view returns (uint256) {
    uint256 reward = _calculateRewards(_staker);
    uint256 total = userReward[_staker] + reward;
    return total;
  }

  function withdrawRewards() external {
    address _staker = _msgSender();
    uint256 toWithdraw = _calculateRewards(_staker);
    uint256 total = userReward[_staker] + toWithdraw;

    // this is only for first time user withdraw
    // after this, userReward will be 0
    // and user withdrawn will be also 0

    require(total > userWithdrawn[_staker], 'No rewards to withdraw');

    require(
      toWithdraw <= rewardToken.balanceOf(address(this)),
      'Incufficient funds'
    );

    require(toWithdraw > 0, 'Incufficient rewards balance');
    startTime[_staker] = block.timestamp;
    userReward[_staker] = 0;
    userWithdrawn[_staker] = 0;
    rewardToken.transfer(_staker, total);
    emit RewardsWithdrawal(_staker, total);
  }

  function withdrawToken(
    address token,
    address account,
    uint256 amount
  ) external onlyDeployer {
    require(amount <= IERC20(token).balanceOf(account), 'Incufficient funds');
    if (token == address(rewardToken)) {
      require(amount <= totalDeposited, 'Incufficient funds');
      totalDeposited -= amount;
    }
    IERC20(token).transfer(account, amount);
    emit LogWithdrawToken(token, account, amount);
  }

  function updateDeployerAddress(address newDeployer) external onlyDeployer {
    require(deployer != newDeployer, 'Already set to this value');
    require(newDeployer != address(0), 'Address 0 validation');
    deployer = newDeployer;
    emit LogUpdateDeployerAddress(newDeployer);
  }

  function deposit(uint256 amount) external onlyDeployer {
    require(amount > 0, 'Cant be 0');
    require(
      rewardToken.allowance(msg.sender, address(this)) >= amount,
      'Insufficient allowance.'
    );

    totalDeposited += amount;
    rewardToken.transferFrom(msg.sender, address(this), amount);

    emit Deposit(msg.sender, amount);
  }

  function _addStaker(
    address _staker,
    uint256 _amount,
    uint256 _userReward,
    uint256 _userWithdrawn,
    uint256 _startTime
  ) internal {
    require(_startTime > 0 || _startTime <= block.timestamp, 'invalid time');
    stakingBalance[_staker] = _amount;
    startTime[_staker] = _startTime;
    userReward[_staker] = _userReward;
    userWithdrawn[_staker] = _userWithdrawn;
    emit AddStaker(_staker, _amount, _startTime);
  }

  function addStaker(
    address[] memory _stakers,
    uint256[] memory _amounts,
    uint256[] memory _userReward,
    uint256[] memory _userWithdrawn,
    uint256[] memory _startTimes
  ) external onlyDeployer {
    require(
      _stakers.length == _amounts.length &&
        _stakers.length == _userReward.length &&
        _stakers.length == _userWithdrawn.length &&
        _stakers.length == _startTimes.length,
      'Array length mismatch'
    );
    for (uint256 i = 0; i < _stakers.length; i++) {
      _addStaker(
        _stakers[i],
        _amounts[i],
        _userReward[i],
        _userWithdrawn[i],
        _startTimes[i]
      );
    }
  }

  function updateStaker(
    address _staker,
    uint256 _amount,
    uint256 _userReward,
    uint256 _userWithdrawn,
    uint256 _startTime
  ) external onlyDeployer {
    require(_startTime > 0 || _startTime <= block.timestamp, 'invalid time');
    stakingBalance[_staker] = _amount;
    userReward[_staker] = _userReward;
    userWithdrawn[_staker] = _userWithdrawn;
    startTime[_staker] = _startTime;
    emit UpdateStaker(_staker, _amount, _startTime);
  }
}
