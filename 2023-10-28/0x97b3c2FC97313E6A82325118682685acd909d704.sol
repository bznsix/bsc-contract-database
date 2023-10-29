// SPDX-License-Identifier: MIT
pragma solidity =0.8.20;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

interface IPool {
    function factory() external view returns (address);
    function fee() external view returns (uint24);
    function token0() external view returns (address);
    function token1() external view returns (address);
}

interface IFactory {
    function getPool(address _token0, address _token1, uint24 _fee) external view returns (address);
}

// Errors
error __errorWrongTimeSetting();
error __errorNotSupportedFactory();
error __errorWrongPool();
error __errorRewardAlreadySet();
error __errorWrongCompetitionId();
error __errorCompetitionHasNotEnded();
error __errorCompetitionHasEnded();
error __errorWrongInput();
error __errorWrongReward();
error __errorNoReward();
error __errorCannotWithdrawCbon();

// Cadinu Trading Competition Contract
contract CadinuTradingCompetition is Ownable {
    // events
    event StartCompetition(uint256 startTime, uint256 endTime, address pool);
    event FactorySetting(address factoryAddress, bool isSupported);
    event NewCompetitionLaunched(uint256 startTime, uint256 endTime, address poolAddress, uint256 rewardAmount);
    event RewardIncreased(uint256 competitionId, uint256 increasedAmount, uint256 newReward);
    event RewardSet(uint256 competitionId, uint256 rewardCharged);
    event WithdrawReward(address user, uint256 withdrawnAmount);

    // Data
    address public constant CBON = 0x6e64fCF15Be3eB71C3d42AcF44D85bB119b2D98b;
    mapping(address => bool) public supportedFactories;
    uint256 public lastId;

    struct Competitions {
        uint256 startTime;
        uint256 endTime;
        address poolAddress;
        uint256 rewardAmount;
        uint256 rewardCharged;
        bool isBoosted;
    }

    struct User {
        uint256 availableReward;
        uint256 withdrawnReward;
    }

    struct Winners {
        address[] winnerUsers;
        uint256[] amounts;
    }

    mapping(uint256 => Competitions) public cadinuCompetitions;
    mapping(address => User) public users;
    mapping(uint256 => Winners) winners;

    // Constructor
    constructor() Ownable(_msgSender()) {
        lastId = 0;
    }

    // Functions
    function factorySetting(address _factoryAddress, bool _isSupported) external onlyOwner {
        supportedFactories[_factoryAddress] = _isSupported;
        emit FactorySetting(_factoryAddress, _isSupported);
    }

    function startCompetition(uint256 _startTime, uint256 _endTime, address _poolAddress, uint256 _rewardAmount)
        external
        onlyOwner
    {
        if (_startTime >= _endTime || _startTime < block.timestamp) revert __errorWrongTimeSetting();
        if (!supportedFactories[IPool(_poolAddress).factory()]) revert __errorNotSupportedFactory();
        if (
            IFactory(IPool(_poolAddress).factory()).getPool(
                IPool(_poolAddress).token0(), IPool(_poolAddress).token1(), IPool(_poolAddress).fee()
            ) != _poolAddress
        ) {
            revert __errorWrongPool();
        }
        cadinuCompetitions[lastId] = Competitions(_startTime, _endTime, _poolAddress, _rewardAmount, 0, false);
        lastId += 1;
        emit NewCompetitionLaunched(_startTime, _endTime, _poolAddress, _rewardAmount);
    }

    function increaseReward(uint256 _competitionId, uint256 _amount) external onlyOwner {
        if (_competitionId > lastId) revert __errorWrongCompetitionId();
        if (cadinuCompetitions[_competitionId].endTime <= block.timestamp) revert __errorCompetitionHasEnded();
        cadinuCompetitions[_competitionId].rewardAmount += _amount;
        cadinuCompetitions[_competitionId].isBoosted = true;
        emit RewardIncreased(_competitionId, _amount, cadinuCompetitions[_competitionId].rewardAmount);
    }

    function setReward(uint256 _competitionId, address[] calldata _users, uint256[] calldata _rewards)
        external
        onlyOwner
    {
        if (_competitionId > lastId) revert __errorWrongCompetitionId();
        if (cadinuCompetitions[_competitionId].endTime >= block.timestamp) revert __errorCompetitionHasNotEnded();
        if (_users.length != _rewards.length) revert __errorWrongInput();
        if (cadinuCompetitions[_competitionId].rewardCharged >= cadinuCompetitions[_competitionId].rewardAmount) {
            revert __errorRewardAlreadySet();
        }
        uint256 totalReward = cadinuCompetitions[_competitionId].rewardCharged;
        for (uint256 ii = 0; ii < _rewards.length; ++ii) {
            totalReward += _rewards[ii];
        }
        if (totalReward > cadinuCompetitions[_competitionId].rewardAmount) revert __errorWrongReward();
        cadinuCompetitions[_competitionId].rewardCharged += totalReward;
        for (uint256 ii = 0; ii < _rewards.length; ++ii) {
            users[_users[ii]].availableReward += _rewards[ii];
            winners[_competitionId].winnerUsers.push(_users[ii]);
            winners[_competitionId].amounts.push(_rewards[ii]);
        }
        IERC20(CBON).transferFrom(_msgSender(), address(this), totalReward);
        emit RewardSet(_competitionId, cadinuCompetitions[_competitionId].rewardCharged);
    }

    function withdrawReward() external {
        if (users[_msgSender()].availableReward == 0) revert __errorNoReward();
        uint256 withdrawAmount = users[_msgSender()].availableReward;
        users[_msgSender()].availableReward = 0;
        users[_msgSender()].withdrawnReward += withdrawAmount;
        IERC20(CBON).transfer(_msgSender(), withdrawAmount);
        emit WithdrawReward(_msgSender(), withdrawAmount);
    }

    function getWinners(uint256 _competitionId) external view returns (address[] memory, uint256[] memory) {
        return (winners[_competitionId].winnerUsers, winners[_competitionId].amounts);
    }

    function withdrawWrongToken(address _tokenAddress) external onlyOwner {
        if (_tokenAddress == CBON) revert __errorCannotWithdrawCbon();
        uint256 amount = IERC20(_tokenAddress).balanceOf(address(this));
        IERC20(_tokenAddress).transfer(owner(), amount);
    }
}
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v5.0.0) (access/Ownable.sol)

pragma solidity ^0.8.20;

import {Context} from "../utils/Context.sol";

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
// SPDX-License-Identifier: MIT
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
// SPDX-License-Identifier: MIT
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
