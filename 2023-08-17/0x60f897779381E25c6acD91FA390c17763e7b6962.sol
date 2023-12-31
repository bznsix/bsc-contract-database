// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import '@openzeppelin/contracts/utils/Context.sol';
import '@openzeppelin/contracts/access/Ownable.sol';
import '@openzeppelin/contracts/security/Pausable.sol';
import '@openzeppelin/contracts/interfaces/IERC20.sol';

interface IResidualMatrix {
    function updateBUSDBalanceByPoolMatrix(address _userAddress, uint _BUSDAmount) external;
}
contract NuvizionPoolMatrix is Ownable, Pausable {
    
    //User Storage
    //Define user struct
    struct User {
        uint id;
        address referrer;
        uint totalReferrals;
        uint totalGlobalCycles;
        uint totalPersonalCycles;
    }
    
    mapping(address => User) public  users;
    mapping(uint => address) public idToAddress;
    uint public totalUsers;
    address public topMostUser;

    //Pool Storage
    //Pool Structure
    struct Pool {
        address owner;
        address[] spots;
    }

    //Global Pool vars
    mapping(uint => Pool) public  globalPools;
    uint public totalGlobalPools;
    uint public globalPoolToDistribute;

    //Personal Pool vars
    mapping(uint => Pool) public  personalPools;
    uint public totalPersonalPools;

    //Users personal pools info for tracking and isolating distribution within the referrer
    struct PersonalPoolTracker {
        uint poolToDistribute;
        uint totalPools;
        mapping(uint => uint) pools;
    }
    mapping(address => PersonalPoolTracker) public usersPersonalPoolsTracker;
    
    //Configuration
    uint public TOTAL_COST;
    uint public TO_GLOBAL_POOL;
    uint public TO_PERSONAL_POOL;
    uint public TO_LVL1_BONUS;
    uint public TO_LVL2_BONUS;
    uint public TO_BONUS_POOL;
    uint public TO_ADMIN;

    //Contract Vars
    bool PROJECT_LAUNCHED;
    mapping(address => bool) public whitelistedAddress;

    //Contract
    address payable public ADMIN_WALLET;
    address payable public BONUS_POOL_WALLET;
    IERC20 public BUSD;
    IResidualMatrix public IRESIDUAL;
    
    event RegisterUser(address indexed userAddress, address indexed referrerAddress, uint indexed user_id, uint referrer_id);
    event CreatePool(uint indexed pool_id, uint indexed owner, uint poolType);    
    event CreatePersonalPoolTracker(uint indexed user_id, uint indexed pool_key, uint pool_id);    
    event PlaceNewSpot(uint indexed poolType, uint indexed pool_id, uint indexed from_id, uint spot, uint spotType);
    event RecordSpotPayment(uint indexed poolType, uint indexed receiver_id, uint indexed payer_id, uint pool_id, uint spot, uint paymentType);    
    event RecordExtrasPayment(uint indexed receiver_id, uint indexed payer_id, uint indexed paymentType);    

    constructor(address _topMostUser, address _BUSDAddr, address _adminFeeWallet, address _bonusPoolWallet) {
        
        //Initialize global pool to 1
        globalPoolToDistribute = 1;

        TOTAL_COST = 10000; //100$
        TO_GLOBAL_POOL = 3250; //$32.50
        TO_PERSONAL_POOL = 3250; //$32.50
        TO_LVL1_BONUS = 2000; //$20
        TO_LVL2_BONUS = 500; //$5
        TO_BONUS_POOL = 500; //$5
        TO_ADMIN = 500; //$5

        ADMIN_WALLET = payable(_adminFeeWallet);
        BONUS_POOL_WALLET = payable(_bonusPoolWallet);
        BUSD = IERC20(_BUSDAddr);

        topMostUser = _topMostUser;
        createNewUser(topMostUser, topMostUser);

        emit RegisterUser(topMostUser, topMostUser, 1, 1);
    }

    function activatePoolMatrix(address referrerAddress) public payable whenNotPaused {

        if(!PROJECT_LAUNCHED) {
            require(whitelistedAddress[address(_msgSender())], "Please wait till launch");
        }

        require(BUSD.allowance(address(_msgSender()), address(this)) >= getCompatiblePrice(TOTAL_COST), "Not enough allowance");
        require(!isUserExists(_msgSender()), "Already registered");
        require(isUserExists(referrerAddress), "Referrer doesnt exist");
        
        address userAddress = _msgSender();

        //Creator cannot be a contract
        uint32 size;
        assembly {
            size := extcodesize(userAddress)
        }
        require(size == 0, "cannot be a contract");
        
        createNewUser(userAddress, referrerAddress);
        (address globalPoolReceiver, uint globalSpot) = placeUserInGlobalPool(userAddress);
        (address personalPoolReceiver, uint personalSpot) = placeUserInPersonalPool(userAddress, referrerAddress, false);

        //Check number of referrals and distribute payment accordingly.
        address finalGlobalPayReceiver = decideFinalPayReceiver(globalPoolReceiver, globalSpot, users[globalPoolReceiver].totalGlobalCycles, users[globalPoolReceiver].totalReferrals);
        address finalPersonalPayReceiver = decideFinalPayReceiver(personalPoolReceiver, personalSpot, users[personalPoolReceiver].totalPersonalCycles, users[personalPoolReceiver].totalReferrals);

        if(globalPoolReceiver != finalGlobalPayReceiver && finalGlobalPayReceiver == topMostUser) {
            emit RecordSpotPayment(1, users[globalPoolReceiver].id, users[userAddress].id, globalPoolToDistribute, globalSpot, 4);
            emit RecordSpotPayment(1, users[topMostUser].id, users[userAddress].id, globalPoolToDistribute, globalSpot, 5);
        }

        if(personalPoolReceiver != finalPersonalPayReceiver && finalPersonalPayReceiver == topMostUser) {
            emit RecordSpotPayment(2, users[personalPoolReceiver].id, users[userAddress].id, usersPersonalPoolsTracker[personalPoolReceiver].pools[usersPersonalPoolsTracker[personalPoolReceiver].poolToDistribute], personalSpot, 4);
            emit RecordSpotPayment(2, users[topMostUser].id, users[userAddress].id, usersPersonalPoolsTracker[topMostUser].pools[usersPersonalPoolsTracker[topMostUser].poolToDistribute], personalSpot, 5);
        }

        //Check if spot is 5, send to 2x10 matrix balance for the user.
        //send payment to 2x5 matrix contract and add balance of user to balance. 
        //If another payment is received then extend/buy residual subscription.
        if(finalGlobalPayReceiver == globalPoolReceiver) {
            if(globalSpot == 5) {
                finalGlobalPayReceiver = address(IRESIDUAL);
                //Update balance of the finalGlobalPayReceiver in the residual contract
                IRESIDUAL.updateBUSDBalanceByPoolMatrix(globalPoolReceiver, getCompatiblePrice(TO_GLOBAL_POOL));
                emit RecordSpotPayment(1, users[globalPoolReceiver].id, users[userAddress].id, globalPoolToDistribute, 5, 6);
            } else {
                emit RecordSpotPayment(1, users[finalGlobalPayReceiver].id, users[userAddress].id, globalPoolToDistribute, globalSpot, 1);
            }
        }

        if(finalPersonalPayReceiver == personalPoolReceiver) {
            if(personalSpot == 5) {
                finalPersonalPayReceiver = address(IRESIDUAL);
                //Update balance of the finalGlobalPayReceiver in the residual contract
                IRESIDUAL.updateBUSDBalanceByPoolMatrix(personalPoolReceiver, getCompatiblePrice(TO_PERSONAL_POOL));
                emit RecordSpotPayment(2, users[personalPoolReceiver].id, users[userAddress].id, usersPersonalPoolsTracker[personalPoolReceiver].pools[usersPersonalPoolsTracker[personalPoolReceiver].poolToDistribute], 5, 6);
            } else {
                emit RecordSpotPayment(2, users[finalPersonalPayReceiver].id, users[userAddress].id, usersPersonalPoolsTracker[finalPersonalPayReceiver].pools[usersPersonalPoolsTracker[finalPersonalPayReceiver].poolToDistribute], personalSpot, 1);
            }
        }

        BUSD.transferFrom(address(_msgSender()), finalGlobalPayReceiver, getCompatiblePrice(TO_GLOBAL_POOL));
        BUSD.transferFrom(address(_msgSender()), finalPersonalPayReceiver, getCompatiblePrice(TO_PERSONAL_POOL));

        BUSD.transferFrom(address(_msgSender()), referrerAddress, getCompatiblePrice(TO_LVL1_BONUS));
        emit RecordExtrasPayment(users[referrerAddress].id, users[userAddress].id, 7);

        BUSD.transferFrom(address(_msgSender()), users[referrerAddress].referrer, getCompatiblePrice(TO_LVL2_BONUS));
        emit RecordExtrasPayment(users[users[referrerAddress].referrer].id, users[userAddress].id, 8);

        BUSD.transferFrom(address(_msgSender()), BONUS_POOL_WALLET, getCompatiblePrice(TO_BONUS_POOL));
        emit RecordExtrasPayment(0, users[userAddress].id, 10);

        BUSD.transferFrom(address(_msgSender()), ADMIN_WALLET, getCompatiblePrice(TO_ADMIN));
        emit RecordExtrasPayment(0, users[userAddress].id, 9);

    }

    //HELPER METHODS
    //Create new user
    function createNewUser(address userAddress, address referrerAddress) private {
        //Create new user in struct
        totalUsers++;
        users[userAddress].id = totalUsers;
        users[userAddress].referrer = referrerAddress;
        idToAddress[totalUsers] = userAddress;

        emit RegisterUser(userAddress, referrerAddress, users[userAddress].id, users[referrerAddress].id);

        //Update referrer struct
        users[referrerAddress].totalReferrals++;

        //Create new global pool for the user
        createGlobalPool(userAddress);

        //Create new personal pool for the user
        createPersonalPool(userAddress);
        createUserPersonalTracker(userAddress);
        createUserPersonalTracker(referrerAddress);

    }

    //Create a global pool for this user
    function createGlobalPool(address userAddress) private {
        totalGlobalPools++;
        globalPools[totalGlobalPools].owner = userAddress;
        
        emit CreatePool(totalGlobalPools, users[userAddress].id, 1);
    }
    function createPersonalPool(address userAddress) private {
        totalPersonalPools++;
        personalPools[totalPersonalPools].owner = userAddress;

        emit CreatePool(totalPersonalPools, users[userAddress].id, 2);
    }

    //Create poolInfo for this user's referrer
    function createUserPersonalTracker(address userAddress) private {
        //Initialize the referrer's next pool pointer if its the first pool created under his downline
        if(usersPersonalPoolsTracker[userAddress].poolToDistribute == 0) {
            usersPersonalPoolsTracker[userAddress].poolToDistribute++;
        }

        //Add total pools and insert the new pool created to this referrer
        usersPersonalPoolsTracker[userAddress].totalPools++;
        usersPersonalPoolsTracker[userAddress].pools[usersPersonalPoolsTracker[userAddress].totalPools] = totalPersonalPools;

        emit CreatePersonalPoolTracker(users[userAddress].id, usersPersonalPoolsTracker[userAddress].totalPools, totalPersonalPools);
    }

    //Place user's pool in next available pool
    function placeUserInGlobalPool(address userAddress) private returns (address, uint) {
        
        //Check if globalPoolToDistribute has exceeded maxSpots-1 (Recycle)
        if(globalPools[globalPoolToDistribute].spots.length >= 5) { //If 6th spot
            //then mark the spot as filled
            //create new pool for pool owner
            //increment globalPoolToDistribute
            //mark next pool's first spot's with this payment
            //return receiver to next pool owner and pool's size
            globalPools[globalPoolToDistribute].spots.push(userAddress);
            emit PlaceNewSpot(1, globalPoolToDistribute, users[userAddress].id, 6, 2);

            createGlobalPool(globalPools[globalPoolToDistribute].owner);
            globalPoolToDistribute++;
            globalPools[globalPoolToDistribute].spots.push(userAddress);
            emit PlaceNewSpot(1, globalPoolToDistribute, users[userAddress].id, globalPools[globalPoolToDistribute].spots.length, 3);

            return (globalPools[globalPoolToDistribute].owner, globalPools[globalPoolToDistribute].spots.length);
        }

        //Place the user in the globalPools[poolToDistirbute]
        globalPools[globalPoolToDistribute].spots.push(userAddress);
        emit PlaceNewSpot(1, globalPoolToDistribute, users[userAddress].id, globalPools[globalPoolToDistribute].spots.length, 1);

        //Return the owner of the pool to distribute funds
        return (globalPools[globalPoolToDistribute].owner, globalPools[globalPoolToDistribute].spots.length);

    }

    //Place user's pool in next available personal pool
    function placeUserInPersonalPool(address userAddress, address referrerAddress, bool cycled) private returns (address, uint) {

        uint poolToDistribute = usersPersonalPoolsTracker[referrerAddress].pools[usersPersonalPoolsTracker[referrerAddress].poolToDistribute];
        //Check if poolToDistribute has exceeded maxSpots-1 (Recycle)
        if(personalPools[poolToDistribute].spots.length >= 5) { //If 6th spot
            //then mark the spot as filled
            //create new pool for pool owner
            //increment pooltodistribute
            //mark next pool's first spot's with this payment
            //return receiver to next pool owner and pool's size
            personalPools[poolToDistribute].spots.push(userAddress);
            emit PlaceNewSpot(2, poolToDistribute, users[userAddress].id, 6, 2);

            createPersonalPool(personalPools[poolToDistribute].owner);
            createUserPersonalTracker(personalPools[poolToDistribute].owner);
            createUserPersonalTracker(users[personalPools[poolToDistribute].owner].referrer);

            usersPersonalPoolsTracker[referrerAddress].poolToDistribute++;
            return placeUserInPersonalPool(userAddress, referrerAddress, true);
        }

        //Place the user in the personalPools[poolToDistirbute]
        personalPools[poolToDistribute].spots.push(userAddress);

        if(cycled == true) {
            emit PlaceNewSpot(2, poolToDistribute, users[userAddress].id, personalPools[poolToDistribute].spots.length, 3);
        } else {
            emit PlaceNewSpot(2, poolToDistribute, users[userAddress].id, personalPools[poolToDistribute].spots.length, 1);
        }

        //Return the owner of the pool to distribute funds
        return (personalPools[poolToDistribute].owner, personalPools[poolToDistribute].spots.length);

    }

    //Decide final payment receiver based on the cycles and referrals
    function decideFinalPayReceiver(address receiver, uint spot, uint receiverCycles, uint receiverReferrals) private view returns (address finalReceiver) {    

        //check if receiver's totalcycles >= 1
        if(receiverCycles >= 1) {
            //check if receiver's referrals.length == 0
            if(receiverReferrals == 0) {
                return topMostUser;
            } else if(receiverReferrals == 1) {
                if(spot < 3) {
                    return receiver;
                } else {
                    return topMostUser;
                }
            } else if(receiverReferrals > 1) {
                return receiver;
            }
        }

        return receiver;

    }

    //VIEWER METHODS
    function isUserExists(address user) public view returns (bool) {
        return (users[user].id != 0);
    }

    function getIdByAddress(address _userAddress) public view returns (uint) {
        return users[_userAddress].id;
    }

    //Output Functions
    //Structure Views
    function viewUser(address userAddress) public view returns(uint id, address referrer, uint totalReferrals, uint totalGlobalCycles, uint totalPersonalCycles) {
        return (
            users[userAddress].id,
            users[userAddress].referrer,
            users[userAddress].totalReferrals,
            users[userAddress].totalGlobalCycles,
            users[userAddress].totalPersonalCycles
        );
    }

    function viewGlobalPool(uint _poolId) public view returns(address _owner, address[] memory spots) {
        return (globalPools[_poolId].owner,
                globalPools[_poolId].spots);
    }

    function viewPersonalPool(uint _poolId) public view returns(address _owner, address[] memory spots) {
        return (personalPools[_poolId].owner,
                personalPools[_poolId].spots);
    }

    function viewUsersPersonalPoolsTrackerByKey(address _userAddres, uint _key) external view returns (uint poolId) {
        return usersPersonalPoolsTracker[_userAddres].pools[_key];
    }

    function getCompatiblePrice(uint _amount) private pure returns (uint amount) {
        return _amount*10**18/100;
    } 
    
    function bytesToAddress(bytes memory bys) private pure returns (address addr) {
        assembly {
            addr := mload(add(bys, 20))
        }
    }

    //CONFIGURATION
    //Set Residual Contract 
    function setResidualContract(address _contractAddr) public onlyOwner {
        IRESIDUAL = IResidualMatrix(_contractAddr);
    }
    //Set BUSD Contract
    function setBUSDContract(address _contractAddr) public onlyOwner {
        BUSD = IERC20(_contractAddr);
    }
    //Set Admin wallet and Bonus Pool Wallets
    function setAdminBonusWallets(address _adminWallet, address _bonusPoolWallet) public onlyOwner {
        ADMIN_WALLET = payable(_adminWallet);
        BONUS_POOL_WALLET = payable(_bonusPoolWallet);
    }
    //Pricing Configurations
    function configCosts(uint _totalCost, uint _toGlobalPool, uint _toPersonalPool, uint _toLvl1Bonus, uint _toLvl2Bonus, uint _toBonusPool, uint _toAdmin) public onlyOwner {
        TOTAL_COST = _totalCost;
        TO_GLOBAL_POOL = _toGlobalPool;
        TO_PERSONAL_POOL = _toPersonalPool;
        TO_LVL1_BONUS = _toLvl1Bonus;
        TO_LVL2_BONUS = _toLvl2Bonus;
        TO_BONUS_POOL = _toBonusPool;
        TO_ADMIN = _toAdmin;
    }

    //Launch project
    function setLaunchProject(bool _value) public onlyOwner {
        PROJECT_LAUNCHED = _value;
    }
    //Add/remove users from whitelist
    function setWhitelistAddresses(address[] calldata addresses, bool excluded) public onlyOwner {
        for(uint256 i = 0; i < addresses.length; i++) {
            whitelistedAddress[addresses[i]] = excluded;
        }
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
}
//Different types
// 1: direct
// 2: cycle
// 3: cycleSpill
// 4: missed
// 5: gift
// 6: fundResidual
// 7: level1Bonus
// 8: level2Bonus
// 9: adminBonus
// 10: bonusPool// SPDX-License-Identifier: MIT
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
