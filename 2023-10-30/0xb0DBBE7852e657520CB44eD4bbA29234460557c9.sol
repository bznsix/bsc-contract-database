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
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";

interface IWBNB {
    function deposit() external payable;

    function balanceOf(address account) external view returns (uint256);

    function withdraw(uint256 wad) external;
}

contract LPB5 is Ownable, ReentrancyGuard {
    address public lpToken;
    uint256 public threshold = 1 ether;
    mapping(address => uint256) public lpShares;
    address[] public participants;
    mapping(address => uint256) public userIndex;
    address public authorizedContract;
    IWBNB public wbnbToken = IWBNB(0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c);
    uint256 public totalLP;
    uint256 public totalLPDistributionIn;
    uint256 public DistributionInIndex;

    bool public distributionInProgress = false;
    uint256 public currentDistributionIndex = 0;
    uint256 public maxBatchSize = 50;
    uint256 public wbnbConvertThreshold = 1 ether;
    address public previous_user;

    mapping(address => uint256) private _released;


    event RewardsDistributed(uint256 totalAmount);
    event ParticipantAdded(address participant);
    event ParticipantRemoved(address participant);
    event ThresholdUpdated(uint256 newThreshold);
    event AuthorizedContractUpdated(address newAuthorizedContract);
    event LPTokenUpdated(address newLPToken);
    event DistributionStarted();
    event DistributionEnded();

    modifier onlyAuthorizedContract() {
        require(msg.sender == authorizedContract, "Only authorized contract can call this function");
        _;
    }

    receive() external payable nonReentrant {
        if(!distributionInProgress){
            if (address(this).balance >= threshold) {
                totalLPDistributionIn = totalLP;
                DistributionInIndex = participants.length;
                _distributeRewards();

            }
        }else{
            _distributeRewards();
        }

    }

    function _distributeRewards() internal {
        distributionInProgress = true;
        emit DistributionStarted();

//        uint256 toDistribute = address(this).balance;
        uint256 totalDistributed = 0;

        for (uint256 i = currentDistributionIndex; i < DistributionInIndex && i < currentDistributionIndex + maxBatchSize; i++) {
            address payable account = payable(participants[i]);
            uint256 payment = _releasable(account);
            if (payment > 0) {
                _released[account] += payment;
                account.transfer(payment);
                totalDistributed += payment;
            }
        }

        currentDistributionIndex += maxBatchSize;

        if (currentDistributionIndex >= participants.length) {
            distributionInProgress = false;
            currentDistributionIndex = 0;
            emit DistributionEnded();
        }

        if (totalDistributed > 0) {
            emit RewardsDistributed(totalDistributed);
        }

        if (wbnbToken.balanceOf(address(this)) >= wbnbConvertThreshold) {
            wbnbToken.withdraw(wbnbToken.balanceOf(address(this)));
        }
    }

    function storeLPBalance(address user) external onlyAuthorizedContract {
        _storeLPBalance(user);
    }

    function _storeLPBalance(address user) internal {
        uint32 size;
        assembly {
            size := extcodesize(user)
        }
        if (size > 0 || user == address(0)) {
            return;
        }
        if (previous_user == address(0)) {
            previous_user = user;
        }

        uint256 newLPBalance = IERC20(lpToken).balanceOf(previous_user);
        uint256 oldLPBalance = lpShares[previous_user];

        if (newLPBalance > 0 && newLPBalance != oldLPBalance) {
            if (oldLPBalance == 0) {
                participants.push(previous_user);
                userIndex[previous_user] = participants.length - 1;
                emit ParticipantAdded(previous_user);
            }
            lpShares[previous_user] = newLPBalance;
            totalLP = totalLP - oldLPBalance + newLPBalance;
        } else if (newLPBalance == 0) {
            if(!distributionInProgress){
                _removeParticipant(previous_user);
            }

        }
        previous_user = user;
    }

    function _removeParticipant(address user) internal {
        if (participants.length == 0) return;
        uint256 userIndexToRemove = userIndex[user];
        if (userIndexToRemove < participants.length - 1) {
            address lastUser = participants[participants.length - 1];
            participants[userIndexToRemove] = lastUser;
            userIndex[lastUser] = userIndexToRemove;
        }
        participants.pop();
        lpShares[user] = 0;
        emit ParticipantRemoved(user);
    }

    function _releasable(address account) private view returns (uint256) {
        return (threshold * lpShares[account]) / totalLPDistributionIn;
    }

    function setThreshold(uint256 _threshold) external onlyOwner {
        threshold = _threshold;
        emit ThresholdUpdated(_threshold);
    }

    function addlpSharesAndparticipants(address[] memory _participants) external onlyOwner {
        require(_participants.length > 0, "Recipients and amounts length mismatch");
        for (uint256 i = 0; i < _participants.length; i++) {
            _storeLPBalance(_participants[i]);
        }
    }

    function claimBalance() external onlyOwner nonReentrant {
        require(!distributionInProgress, "Distribution is in progress");
        payable(msg.sender).transfer(address(this).balance);
    }

    function claimToken(address token, uint256 amount) external onlyOwner {
        require(token != address(lpToken), "Cannot claim the LP tokens");
        require(!distributionInProgress, "Distribution is in progress");
        IERC20(token).transfer(msg.sender, amount);
    }

    function setAuthorizedContract(address _authorizedContract) external onlyOwner {
        authorizedContract = _authorizedContract;
        emit AuthorizedContractUpdated(_authorizedContract);
    }

    function setLPToken(address _lpToken) external onlyOwner {
        lpToken = _lpToken;
        emit LPTokenUpdated(_lpToken);
    }

    function setWbnbConvertThreshold(uint256 _wbnbConvertThreshold) external onlyOwner {
        wbnbConvertThreshold = _wbnbConvertThreshold;
    }

    function setMaxBatchSize(uint256 _maxBatchSize) external onlyOwner {
        maxBatchSize = _maxBatchSize;
    }
}
