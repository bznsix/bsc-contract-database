// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import '@openzeppelin/contracts/utils/Context.sol';
import '@openzeppelin/contracts/access/Ownable.sol';
import '@openzeppelin/contracts/security/Pausable.sol';
import '@openzeppelin/contracts/interfaces/IERC20.sol';

interface IPoolMatrix {
    function topMostUser() external view returns (address);
    function viewUser(address _address) external view returns (uint id, address referrer, uint totalReferrals, uint totalGlobalCycles, uint totalPersonalCycles);
    function ADMIN_WALLET() external view returns (address);
    function BONUS_POOL_WALLET() external view returns (address);
}

contract NuvizionResidualMatrix is Ownable, Pausable  {
   
    struct User {
        uint id;
        uint BUSDBalance;
        address referrer; //Actual referrer
        address upline; //Person below which he got placed by the matrix
        uint256 expiration;
        address[] matrixReferrals; //Maximum 3 and then spillovers happen
    }
    
    mapping(address => User) public users;
    mapping(uint => address) public idToAddress;
    address public topMostUser;

    //Configuration
    uint public TOTAL_COST;
    uint public TOTAL_LEVELS;
    uint public DIVIDEND_PER_LEVEL;
    uint public CHECKMATCH_PER_LEVEL;
    uint public TO_BONUS_POOL;
    uint public TO_ADMIN;
    uint public SUBSCRIPTION_TIME;

    //Contracts
    IPoolMatrix POOL_MATRIX;
    IERC20 public BUSD;
    
    //Events for communication
    event RegisterInResidual(uint indexed user_id, uint indexed referrer_id, uint indexed upline_id);
    event RecordResidualSubscription(uint indexed user_id, uint newExpiration);
    event RecordResidualPayment(uint indexed payer_id, uint receiver_id, uint upline_id, uint level, uint paymentType);
    event RecordCheckMatchPayment(uint indexed payer_id, uint receiver_id, uint referrer_id, uint level, uint paymentType);
    event RecordExtrasPayment(uint indexed receiver_id, uint indexed payer_id, uint indexed paymentType);    
    
    constructor(address _poolMatrixAddr, address _BUSDAddr) {
        
        TOTAL_COST = 6500; //$65
        TOTAL_LEVELS = 5; //2x5
        DIVIDEND_PER_LEVEL = 600; //$6
        CHECKMATCH_PER_LEVEL = 600; //$6
        TO_BONUS_POOL = 250; //$2.5
        TO_ADMIN = 250; //$2.5
        SUBSCRIPTION_TIME = 2592000; //30 Days
        
        BUSD = IERC20(_BUSDAddr);
        POOL_MATRIX = IPoolMatrix(_poolMatrixAddr);

        topMostUser = POOL_MATRIX.topMostUser();
        
        users[topMostUser].id = 1;
        users[topMostUser].referrer = topMostUser;
        users[topMostUser].upline = topMostUser;
        users[topMostUser].expiration = block.timestamp + 9999999999;
        
        for (uint8 i = 1; i <= TOTAL_LEVELS; i++) {
            emit RecordResidualPayment(users[topMostUser].id, users[topMostUser].id, users[topMostUser].id, i, 1);
            emit RecordCheckMatchPayment(users[topMostUser].id, users[topMostUser].id, users[topMostUser].id, i, 1);
        }
        
        idToAddress[1] = topMostUser;
        
        emit RecordResidualSubscription(users[topMostUser].id, users[topMostUser].expiration);
        emit RegisterInResidual(users[topMostUser].id, users[topMostUser].id, users[topMostUser].id);
    }

    function activateResidualMatrix(address uplineAddress) external payable whenNotPaused {

        address userAddress = _msgSender();
        uint userId = getPoolMatrixUserId(userAddress);
        address referrerAddress = decideActiveReferrer(getPoolMatrixReferrer(userAddress));

        //Check if user busd balance and busd approved by user are sufficient and then transfer the reamining to contract
        uint remainingBUSD = getRemainingAmountRequired(userAddress, getCompatiblePrice(TOTAL_COST));
        require(BUSD.allowance(address(_msgSender()), address(this)) >= remainingBUSD, "Not enough allowance");
        BUSD.transferFrom(address(_msgSender()), address(this), remainingBUSD);
        users[userAddress].BUSDBalance += remainingBUSD;
        
        require(users[userAddress].BUSDBalance >= getCompatiblePrice(TOTAL_COST), "Insufficient BUSD Balance");
        require(userId > 0, "Register in NV Pool Matrix first");
        require(!isUserExists(userAddress), "User already exists");
        require(isUserExists(referrerAddress), "Referrer Doesnt exists");
        require(isUserExists(uplineAddress), "Upline Doesnt exists");
        
        //Check upline checks
        require(users[uplineAddress].matrixReferrals.length < 2, "Upline not free. Try again later.");
        
        uint32 size;
        assembly {
            size := extcodesize(userAddress)
        }
        require(size == 0, "Cannot be a contract");

        users[userAddress].id = userId;
        users[userAddress].referrer = referrerAddress;
        users[userAddress].upline = uplineAddress;
        users[userAddress].expiration = block.timestamp+SUBSCRIPTION_TIME;
        idToAddress[userId] = userAddress;
        
        users[uplineAddress].matrixReferrals.push(userAddress);
        
        buyProcess(userAddress);
        emit RecordResidualSubscription(users[userAddress].id, users[userAddress].expiration);
        emit RegisterInResidual(users[userAddress].id, users[referrerAddress].id, users[uplineAddress].id);
        return;
        
    }
    
    function renewSubscription()  external payable {
        
        address userAddress = _msgSender();
        require(isUserExists(userAddress), "Register First");

        //Check if user busd balance and busd approved by user are sufficient and then transfer the reamining to contract
        uint remainingBUSD = getRemainingAmountRequired(userAddress, getCompatiblePrice(TOTAL_COST));
        require(BUSD.allowance(address(_msgSender()), address(this)) >= remainingBUSD, "Not enough allowance");
        BUSD.transferFrom(address(_msgSender()), address(this), remainingBUSD);
        users[userAddress].BUSDBalance += remainingBUSD;

        require(users[userAddress].BUSDBalance >= getCompatiblePrice(TOTAL_COST), "Insufficient BUSD Balance");

        //Add Subscription expiration 
        if(users[userAddress].expiration > block.timestamp) {
            users[userAddress].expiration += SUBSCRIPTION_TIME;
        } else {
            users[userAddress].expiration = block.timestamp + SUBSCRIPTION_TIME;
        }

        buyProcess(userAddress);
        emit RecordResidualSubscription(users[userAddress].id, users[userAddress].expiration);

    }
    
    function buyProcess(address userAddress)  private {
        
        address residualReceiver;
        address checkmatchReceiver;

        address currUpline = users[userAddress].upline;
        address currReferrer = users[userAddress].referrer;

        for (uint8 i = 1; i <= TOTAL_LEVELS; i++) {
            
            //Decide upline receiver based on expiration
            residualReceiver = decideReceiver(userAddress, currUpline, i, 1); //Upline            
            if(currUpline == residualReceiver) {
                emit RecordResidualPayment(users[userAddress].id, users[residualReceiver].id, users[currUpline].id, i, 1);
            } else {
                emit RecordResidualPayment(users[userAddress].id, users[residualReceiver].id, users[currUpline].id, i, 5);
            }
            //UPLINE PAYMNET transfer busd from contract to receiver
            BUSD.transfer(residualReceiver, getCompatiblePrice(DIVIDEND_PER_LEVEL));
            
            //Decide referrer receiver based on expiration
            checkmatchReceiver = decideReceiver(userAddress, currReferrer, i, 2); //Checkmatch
            if(currUpline == checkmatchReceiver) {
                emit RecordCheckMatchPayment(users[userAddress].id, users[checkmatchReceiver].id, users[currUpline].id, i, 1);
            } else {
                emit RecordCheckMatchPayment(users[userAddress].id, users[checkmatchReceiver].id, users[currUpline].id, i, 5);
            }
            //CHECKMATCH PAYMNET transfer busd from contract to receiver
            BUSD.transfer(checkmatchReceiver, getCompatiblePrice(CHECKMATCH_PER_LEVEL));
            
            currUpline = users[currUpline].upline;
            currReferrer = users[currReferrer].upline;
        }

        BUSD.transfer(POOL_MATRIX.BONUS_POOL_WALLET(), getCompatiblePrice(TO_BONUS_POOL));
        emit RecordExtrasPayment(0, users[userAddress].id, 12);

        BUSD.transfer(POOL_MATRIX.ADMIN_WALLET(), getCompatiblePrice(TO_ADMIN));
        emit RecordExtrasPayment(0, users[userAddress].id, 11);

        //Subtract totalcost BUSD from balance and keep remaining amount in busd balance
        users[userAddress].BUSDBalance -= getCompatiblePrice(TOTAL_COST);
        
        return;
    }
    
    //Decide upline based on spillovers.
    function decideUpline(address activeReferrer, uint8 rand) public view returns(address) {
        require(rand >= 0 && rand <= 1, "Invalid Rand Range");
        if(users[activeReferrer].matrixReferrals.length >= 2) {
            
            uint256 eligiblePartner = 0;
            for(uint256 i=0;i<2;i++) {
                if(users[users[activeReferrer].matrixReferrals[i]].matrixReferrals.length < users[users[activeReferrer].matrixReferrals[eligiblePartner]].matrixReferrals.length) {
                    eligiblePartner = i;
                }
            }
            
            if(users[users[activeReferrer].matrixReferrals[eligiblePartner]].matrixReferrals.length >= 2) {
                return decideUpline(users[activeReferrer].matrixReferrals[rand], rand);
            }
            return decideUpline(users[activeReferrer].matrixReferrals[eligiblePartner], rand);
            
        } else {
            return activeReferrer;
        }
    }

    //Decide if receiver's subscription is expired or not.
    function decideReceiver(address userAddress, address receiverAddress, uint level, uint receiverType) private returns(address) {
        
        if(users[receiverAddress].expiration > block.timestamp) {
            return receiverAddress;
        } else {
            if(receiverType == 1) {
                //Missed residual
                emit RecordResidualPayment(users[userAddress].id, users[receiverAddress].id, 0, level, 4);
            } else {
                //Missed checkmatch
                emit RecordCheckMatchPayment(users[userAddress].id, users[receiverAddress].id, 0, level, 4);
            }
            return topMostUser;
        }
        
    }
    
    //Get Next active referrer from the residual system based in the poolMatrix system till it reaches topMostUser.
    function decideActiveReferrer(address referrerAddress) public view returns(address) {
        if(isUserExists(referrerAddress)) {
            return referrerAddress;
        } else {
            if(referrerAddress == topMostUser) {
                return topMostUser;
            }
            return decideActiveReferrer(getPoolMatrixReferrer(referrerAddress));
        }
    }

    //Update BUSD balance of a user from poolMatrix
    function updateBUSDBalanceByPoolMatrix(address _userAddress, uint _BUSDAmount) public {
        require(_msgSender() == address(POOL_MATRIX), "Only pool matrix can update");
        users[_userAddress].BUSDBalance += _BUSDAmount;
    }

    function isUserExists(address user) public view returns (bool) {
        return (users[user].id != 0);
    }
    
    function bytesToAddress(bytes memory bys) private pure returns (address addr) {
        assembly {
            addr := mload(add(bys, 20))
        }
    }

    function getCompatiblePrice(uint _amount) public pure returns (uint amount) {
        return _amount*10**18/100;
    } 

    //Get remaining amount user should spend after subtracting balance available in the contract
    function getRemainingAmountRequired(address _userAddress, uint _totalAmountRequired) public view returns (uint _remainingAmount) {
        return _totalAmountRequired - users[_userAddress].BUSDBalance;
    }

    //Output Functions
    function viewUser(address userAddress) public view returns(uint, uint, address, address, uint, address[] memory) {
        return (users[userAddress].id,
                users[userAddress].BUSDBalance,
                users[userAddress].referrer,
                users[userAddress].upline,
                users[userAddress].expiration,
                users[userAddress].matrixReferrals);
    }

    //POOL MATRIX METHODS
    function getPoolMatrixUserId(address userAddress) public view returns (uint) {
	    (uint id,,,,) = POOL_MATRIX.viewUser(userAddress);
        return id;
	}

    function getPoolMatrixReferrer(address userAddress) public view returns (address) {
	    (, address referrer,,,) = POOL_MATRIX.viewUser(userAddress);
        return referrer;
	}
	
    //CONFIGURATION
    //Set Residual Contract 
    function setPoolContract(address _contractAddr) public onlyOwner {
        POOL_MATRIX = IPoolMatrix(_contractAddr);
    }
    //Set BUSD Contract
    function setBUSDContract(address _contractAddr) public onlyOwner {
        BUSD = IERC20(_contractAddr);
    }
    //Pricing Configurations
    function configuration(uint _totalCost, uint _totalLevels, uint _dividendPerLevel, uint _subTime) public onlyOwner {
        TOTAL_COST = _totalCost;
        TOTAL_LEVELS = _totalLevels;
        DIVIDEND_PER_LEVEL = _dividendPerLevel;
        SUBSCRIPTION_TIME = _subTime;
    }

    /** 
    * @dev Pause the Contract
    */
    function pause() external onlyOwner whenNotPaused {
        _pause();
        emit Paused(msg.sender);
    }

    /** 
    * @dev Unpause the Contract
    */
    function unpause() external onlyOwner whenPaused {
        _unpause();
        emit Unpaused(msg.sender);
    }

    /**  
      * @dev Emergency method to withdraw tokens sent to the contract
      * @param _tokenAddress Address of the token to withdraw
      * @param _toAddress Address to send the tokens to
      * @param _amount Amount of tokens to send
      */
    function emergencyWithdrawTokens(address _tokenAddress, address _toAddress, uint256 _amount) external onlyOwner {
        IERC20(_tokenAddress).transfer(_toAddress, _amount);
    }

    /**  
      * @dev Emergency method to withdraw any ETH sent to the contract
      * @param toAddress Address to send the ETH to
      */
    function emergencyWithdrawAsset(address payable toAddress) external onlyOwner {
        if(!toAddress.send(address(this).balance)) {
            return toAddress.transfer(address(this).balance);
        }
    }
}// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (interfaces/IERC20.sol)

pragma solidity ^0.8.0;

import "../token/ERC20/IERC20.sol";
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.7.0) (security/Pausable.sol)

pragma solidity ^0.8.0;

import "../utils/Context.sol";

/**
 * @dev Contract module which allows children to implement an emergency stop
 * mechanism that can be triggered by an authorized account.
 *
 * This module is used through inheritance. It will make available the
 * modifiers `whenNotPaused` and `whenPaused`, which can be applied to
 * the functions of your contract. Note that they will not be pausable by
 * simply including this module, only once the modifiers are put in place.
 */
abstract contract Pausable is Context {
    /**
     * @dev Emitted when the pause is triggered by `account`.
     */
    event Paused(address account);

    /**
     * @dev Emitted when the pause is lifted by `account`.
     */
    event Unpaused(address account);

    bool private _paused;

    /**
     * @dev Initializes the contract in unpaused state.
     */
    constructor() {
        _paused = false;
    }

    /**
     * @dev Modifier to make a function callable only when the contract is not paused.
     *
     * Requirements:
     *
     * - The contract must not be paused.
     */
    modifier whenNotPaused() {
        _requireNotPaused();
        _;
    }

    /**
     * @dev Modifier to make a function callable only when the contract is paused.
     *
     * Requirements:
     *
     * - The contract must be paused.
     */
    modifier whenPaused() {
        _requirePaused();
        _;
    }

    /**
     * @dev Returns true if the contract is paused, and false otherwise.
     */
    function paused() public view virtual returns (bool) {
        return _paused;
    }

    /**
     * @dev Throws if the contract is paused.
     */
    function _requireNotPaused() internal view virtual {
        require(!paused(), "Pausable: paused");
    }

    /**
     * @dev Throws if the contract is not paused.
     */
    function _requirePaused() internal view virtual {
        require(paused(), "Pausable: not paused");
    }

    /**
     * @dev Triggers stopped state.
     *
     * Requirements:
     *
     * - The contract must not be paused.
     */
    function _pause() internal virtual whenNotPaused {
        _paused = true;
        emit Paused(_msgSender());
    }

    /**
     * @dev Returns to normal state.
     *
     * Requirements:
     *
     * - The contract must be paused.
     */
    function _unpause() internal virtual whenPaused {
        _paused = false;
        emit Unpaused(_msgSender());
    }
}
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (access/Ownable.sol)

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
     * @dev Returns the address of the current owner.
     */
    function owner() public view virtual returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
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
// OpenZeppelin Contracts (last updated v4.6.0) (token/ERC20/IERC20.sol)

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
    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);
}
