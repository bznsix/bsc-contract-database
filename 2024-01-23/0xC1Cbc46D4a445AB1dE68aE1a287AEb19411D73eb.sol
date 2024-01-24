// SPDX-License-Identifier: MIT
pragma solidity ^0.8.23;

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
 * @dev Wrappers over Solidity's arithmetic operations with added overflow
 * checks.
 *
 * Arithmetic operations in Solidity wrap on overflow. This can easily result
 * in bugs, because programmers usually assume that an overflow raises an
 * error, which is the standard behavior in high level programming languages.
 * `SafeMath` restores this intuition by reverting the transaction when an
 * operation overflows.
 *
 * Using this library instead of the unchecked operations eliminates an entire
 * class of bugs, so it's recommended to use it always.
 */
library SafeMath {
    /**
     * @dev Returns the addition of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `+` operator.
     *
     * Requirements:
     *
     * - Addition cannot overflow.
     */
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting on
     * overflow (when the result is negative).
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     *
     * - Subtraction cannot overflow.
     */
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return sub(a, b, "SafeMath: subtraction overflow");
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting with custom message on
     * overflow (when the result is negative).
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     *
     * - Subtraction cannot overflow.
     */
    function sub(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        uint256 c = a - b;

        return c;
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `*` operator.
     *
     * Requirements:
     *
     * - Multiplication cannot overflow.
     */
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
        // benefit is lost if 'b' is also tested.
        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");

        return c;
    }

    /**
     * @dev Returns the integer division of two unsigned integers. Reverts on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator. Note: this function uses a
     * `revert` opcode (which leaves remaining gas untouched) while Solidity
     * uses an invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return div(a, b, "SafeMath: division by zero");
    }

    /**
     * @dev Returns the integer division of two unsigned integers. Reverts with custom message on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator. Note: this function uses a
     * `revert` opcode (which leaves remaining gas untouched) while Solidity
     * uses an invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function div(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold

        return c;
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * Reverts when dividing by zero.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return mod(a, b, "SafeMath: modulo by zero");
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * Reverts with custom message when dividing by zero.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function mod(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        require(b != 0, errorMessage);
        return a % b;
    }
}

/**
 * @dev Collection of functions related to the address type
 */
library Address {
    /**
     * @dev The ETH balance of the account is not enough to perform the operation.
     */
    error AddressInsufficientBalance(address account);

    /**
     * @dev There's no code at `target` (it is not a contract).
     */
    error AddressEmptyCode(address target);

    /**
     * @dev A call to an address target failed. The target may have reverted.
     */
    error FailedInnerCall();

    /**
     * @dev Replacement for Solidity's `transfer`: sends `amount` wei to
     * `recipient`, forwarding all available gas and reverting on errors.
     *
     * https://eips.ethereum.org/EIPS/eip-1884[EIP1884] increases the gas cost
     * of certain opcodes, possibly making contracts go over the 2300 gas limit
     * imposed by `transfer`, making them unable to receive funds via
     * `transfer`. {sendValue} removes this limitation.
     *
     * https://consensys.net/diligence/blog/2019/09/stop-using-soliditys-transfer-now/[Learn more].
     *
     * IMPORTANT: because control is transferred to `recipient`, care must be
     * taken to not create reentrancy vulnerabilities. Consider using
     * {ReentrancyGuard} or the
     * https://solidity.readthedocs.io/en/v0.8.20/security-considerations.html#use-the-checks-effects-interactions-pattern[checks-effects-interactions pattern].
     */
    function sendValue(address payable recipient, uint256 amount) internal {
        if (address(this).balance < amount) {
            revert AddressInsufficientBalance(address(this));
        }

        (bool success, ) = recipient.call{value: amount}("");
        if (!success) {
            revert FailedInnerCall();
        }
    }

    /**
     * @dev Performs a Solidity function call using a low level `call`. A
     * plain `call` is an unsafe replacement for a function call: use this
     * function instead.
     *
     * If `target` reverts with a revert reason or custom error, it is bubbled
     * up by this function (like regular Solidity function calls). However, if
     * the call reverted with no returned reason, this function reverts with a
     * {FailedInnerCall} error.
     *
     * Returns the raw returned data. To convert to the expected return value,
     * use https://solidity.readthedocs.io/en/latest/units-and-global-variables.html?highlight=abi.decode#abi-encoding-and-decoding-functions[`abi.decode`].
     *
     * Requirements:
     *
     * - `target` must be a contract.
     * - calling `target` with `data` must not revert.
     */
    function functionCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionCallWithValue(target, data, 0);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but also transferring `value` wei to `target`.
     *
     * Requirements:
     *
     * - the calling contract must have an ETH balance of at least `value`.
     * - the called Solidity function must be `payable`.
     */
    function functionCallWithValue(address target, bytes memory data, uint256 value) internal returns (bytes memory) {
        if (address(this).balance < value) {
            revert AddressInsufficientBalance(address(this));
        }
        (bool success, bytes memory returndata) = target.call{value: value}(data);
        return verifyCallResultFromTarget(target, success, returndata);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but performing a static call.
     */
    function functionStaticCall(address target, bytes memory data) internal view returns (bytes memory) {
        (bool success, bytes memory returndata) = target.staticcall(data);
        return verifyCallResultFromTarget(target, success, returndata);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but performing a delegate call.
     */
    function functionDelegateCall(address target, bytes memory data) internal returns (bytes memory) {
        (bool success, bytes memory returndata) = target.delegatecall(data);
        return verifyCallResultFromTarget(target, success, returndata);
    }

    /**
     * @dev Tool to verify that a low level call to smart-contract was successful, and reverts if the target
     * was not a contract or bubbling up the revert reason (falling back to {FailedInnerCall}) in case of an
     * unsuccessful call.
     */
    function verifyCallResultFromTarget(
        address target,
        bool success,
        bytes memory returndata
    ) internal view returns (bytes memory) {
        if (!success) {
            _revert(returndata);
        } else {
            // only check if target is a contract if the call was successful and the return data is empty
            // otherwise we already know that it was a contract
            if (returndata.length == 0 && target.code.length == 0) {
                revert AddressEmptyCode(target);
            }
            return returndata;
        }
    }

    /**
     * @dev Tool to verify that a low level call was successful, and reverts if it wasn't, either by bubbling the
     * revert reason or with a default {FailedInnerCall} error.
     */
    function verifyCallResult(bool success, bytes memory returndata) internal pure returns (bytes memory) {
        if (!success) {
            _revert(returndata);
        } else {
            return returndata;
        }
    }

    /**
     * @dev Reverts with returndata if present. Otherwise reverts with {FailedInnerCall}.
     */
    function _revert(bytes memory returndata) private pure {
        // Look for revert reason and bubble it up if present
        if (returndata.length > 0) {
            // The easiest way to bubble the revert reason is using memory via assembly
            /// @solidity memory-safe-assembly
            assembly {
                let returndata_size := mload(returndata)
                revert(add(32, returndata), returndata_size)
            }
        } else {
            revert FailedInnerCall();
        }
    }
}

/**
 * @dev Contract module that helps prevent reentrant calls to a function.
 *
 * Inheriting sender `ReentrancyGuard` will make the {nonReentrant} modifier
 * available, which can be applied to functions to make sure there are no nested
 * (reentrant) calls to them.
 *
 * Note that because there is a single `nonReentrant` guard, functions marked as
 * `nonReentrant` may not call one another. This can be worked around by making
 * those functions `private`, and then adding `external` `nonReentrant` entry
 * points to them.
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
    uint256 private constant NOT_ENTERED = 1;
    uint256 private constant ENTERED = 2;

    uint256 private _status;

    /**
     * @dev Unauthorized reentrant call.
     */
    error ReentrancyGuardReentrantCall();

    constructor() {
        _status = NOT_ENTERED;
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
        // On the first call to nonReentrant, _status will be NOT_ENTERED
        if (_status == ENTERED) {
            revert ReentrancyGuardReentrantCall();
        }

        // Any calls to nonReentrant after this point will fail
        _status = ENTERED;
    }

    function _nonReentrantAfter() private {
        // By storing the original value once again, a refund is triggered (see
        // https://eips.ethereum.org/EIPS/eip-2200)
        _status = NOT_ENTERED;
    }

    /**
     * @dev Returns true if the reentrancy guard is currently set to "entered", which indicates there is a
     * `nonReentrant` function in the call stack.
     */
    function _reentrancyGuardEntered() internal view returns (bool) {
        return _status == ENTERED;
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
    address public _owner;

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

contract MySheeps is Context, ReentrancyGuard, Ownable {
    // SafeMath library And Address
    using SafeMath for uint256;
    using Address for address;

    uint256 private _ManagerPercent = 20;
    uint256 private _transaction_fee = 5;
    uint256 private _yield_tier = 3;
    uint256 private _truckPrice1 = 2500;
    uint256 private _truckPrice2 = 5000;
    uint256 private _cashValue = 2e13;

    uint256 public totalSheeps;
    uint256 public totalFarms;
    uint256 public totalInvested;
    uint256 public referSheepPercent = 8;
    uint256 public referCashPercent = 2;

    address private _manager;
    uint private _ManagerId = 0; 
    struct Managers_Tokenomics {
        address _PartnerAddress;
        uint256 _PartnerPercent;
        bool exist;
    }
    mapping(uint => Managers_Tokenomics) private ManagersTokenomics;

    struct Farm {
        uint256 SheepCoins;
        uint256 cash;
        uint256 yield;
        uint256 totalYield;
        uint256 timestamp;
        address ref;
        uint256 refs;
        uint256 refSheepC;
        uint256 refCash;
        uint256 refTotal;
        uint8[8] sheeps;
        uint256 truck;
        bool exist;
    }
    mapping(address => Farm) public farmsLand;

    constructor() Ownable(msg.sender)  {
        _owner = msg.sender;
        // Address manager
        _manager = msg.sender;
    }

    function totalBalance() external view returns (uint256) {
        return payable(address(this)).balance;
    }

    function getSheeps(address addr) public view returns (uint8[8] memory) {
        return farmsLand[addr].sheeps;
    }

    function balanceUserFarm(address account)
        public
        view
        returns (uint256 SheepCoins, uint256 cash, uint256 estimateBNB)
    {
        return (farmsLand[account].SheepCoins, farmsLand[account].cash, (farmsLand[account].SheepCoins+farmsLand[account].cash.div(100)).mul(_cashValue));
    }

    function getTruckPrice() public view returns (uint256, uint256) {
        return (_truckPrice1, _truckPrice2);
    }

    function getCashValue() public view returns (uint256) {
        return _cashValue;
    }
    
    function getTransactionFee() public view returns (uint256) {
        return _transaction_fee;
    }
    
    function getYieldTier() public view returns (uint256) {
        return _yield_tier;
    }

    /*get getManagers_Tokenomics*/
    function getManagers_Tokenomics()
        public view returns (Managers_Tokenomics[] memory) {
        Managers_Tokenomics[] memory items = new Managers_Tokenomics[](_ManagerId+1);
        for (uint i = 0; i < _ManagerId+1; i++) {
            Managers_Tokenomics storage Partner = ManagersTokenomics[i];
            items[i] = Partner;
        }
        return items;
    }

    /**
     * @dev Enables the contract to receive BNB.
     */
    receive() external payable {}
    fallback() external payable {}

    function addCoins(address ref) public payable {
        uint256 SheepCoins = msg.value / _cashValue;
        require(SheepCoins > 0 && msg.value > _cashValue, "Zero SheepCoins");
        address user = msg.sender;
        totalInvested += msg.value;
        if (!farmsLand[user].exist) {
            totalFarms+=1;
            ref = farmsLand[ref].exist ? ref : _manager;
            farmsLand[ref].refs+=1;
            farmsLand[user].ref = ref;
            farmsLand[user].timestamp = block.timestamp;
            farmsLand[user].truck = 1;
            farmsLand[user].exist = true;
        }
        ref = farmsLand[user].ref;
        farmsLand[ref].SheepCoins += (SheepCoins.mul(referSheepPercent)).div(100);
        farmsLand[ref].cash += ((SheepCoins.mul(100)).mul(referCashPercent)).div(100);
        farmsLand[ref].refSheepC += (SheepCoins.mul(referSheepPercent)).div(100);
        farmsLand[ref].refCash += ((SheepCoins.mul(100)).mul(referCashPercent)).div(100);
        farmsLand[ref].refTotal += SheepCoins;
        farmsLand[user].SheepCoins += SheepCoins;

        uint256 PartnerValue = ((SheepCoins.mul(100)).mul(_ManagerPercent)).div(100);
        for (uint i = 0; i < _ManagerId; i++) {
            if(ManagersTokenomics[i]._PartnerAddress != address(0) || ManagersTokenomics[i]._PartnerPercent > 0 ){
                farmsLand[ManagersTokenomics[i]._PartnerAddress].cash += ((PartnerValue).mul(ManagersTokenomics[i]._PartnerPercent)).div(100);
            }
        }

        emit addCoin(msg.sender, msg.value, SheepCoins);
    }

    function upgradeTruck() public {
        address user = msg.sender;
        require(farmsLand[user].truck <= 2, "You reached the maximum number of trucks");

        if(farmsLand[user].truck == 1){
            farmsLand[user].SheepCoins -= _truckPrice1;
            farmsLand[user].truck+=1;
            farmsLand[_manager].cash += _truckPrice1.mul(100);
        }else if(farmsLand[user].truck == 2){
            farmsLand[user].SheepCoins -= _truckPrice2;
            farmsLand[user].truck+=1;
            farmsLand[_manager].cash += _truckPrice2.mul(100);
        }

    }

    function upgradeFarm(uint256 famrId) public {
        address user = msg.sender;
        uint256 sheeps = farmsLand[user].sheeps[famrId] + 1;
        uint256 upgradePrice = _getUpgradePrice(famrId, sheeps);

        require(famrId <= 8, "Max 8 famrs");
        require(sheeps <= 5, "Invalid sheepsId"); //Make sure SheepId is valid
        require(
            upgradePrice <= farmsLand[user].SheepCoins, 
            "You don't have enough Coin for this transaction"
        );

        farmsLand[user].SheepCoins -= upgradePrice;
        farmsLand[user].yield += _getYield(famrId, sheeps);
        farmsLand[user].sheeps[famrId]+=1;
        totalSheeps+=1;
    }

    function withdrawCash() public {
        address user = msg.sender;
        uint256 cash = farmsLand[user].cash;
        uint256 amount = (cash.div(100)).mul(_cashValue);
        require(
            amount > 0  &&
            amount <= address(this).balance,
            "You do not have enough balance for this withdrawal"
        );

        uint256 fee = amount.mul(_transaction_fee).div(100);
        payable(user).transfer(amount.sub(fee));
        farmsLand[user].cash = 0;

        emit WithdrawMoney(msg.sender, amount);

    }

    function collectCash() public {
        address user = msg.sender;
        require(
            farmsLand[user].exist,
            "A User does not exist, check the contract or create it first"
        );

        if(farmsLand[user].timestamp <= 0){
            farmsLand[user].timestamp = block.timestamp;
        }

        if (farmsLand[user].yield > 0) {
            uint256 hrs = block.timestamp / 3600 - farmsLand[user].timestamp / 3600;
            uint256 time = 0;
            if(farmsLand[user].truck == 3){
                time = 24;
            }else if(farmsLand[user].truck == 2){
                time = 12;
            }else{
                time = 6;
            }

            if (hrs > time) {
                hrs = time;
            }
            uint256 yield = hrs * farmsLand[user].yield;

            if((farmsLand[user].totalYield.add(yield)) >= ((farmsLand[user].yield).mul(_yield_tier))){
                _resetFarm(user);
            }

            farmsLand[user].cash += yield;
            farmsLand[user].totalYield += yield;
        }
        farmsLand[user].timestamp = block.timestamp;
    }

    function _resetFarm(address user) private {
        uint8[8] memory sheeps = farmsLand[user].sheeps;
        totalSheeps -= sheeps[0] + sheeps[1] + sheeps[2] + sheeps[3] + sheeps[4] + sheeps[5] + sheeps[6] + sheeps[7];
        farmsLand[user].sheeps = [0, 0, 0, 0, 0, 0, 0, 0];
        farmsLand[user].yield = 0;
        farmsLand[user].truck = 1;
        farmsLand[user].totalYield = 0;
    }

    function _getUpgradePrice(uint256 famrId, uint256 sheepId)
        private 
        pure
        returns (uint256)
    {
        if (sheepId == 1)
            return [500, 1500, 4500, 13500, 40500, 120000, 365000, 1000000][famrId];
        if (sheepId == 2)
            return [625, 1800, 5600, 16800, 50600, 150000, 456000, 1200000][famrId];
        if (sheepId == 3)
            return [780, 2300, 7000, 21000, 63000, 187000, 570000, 1560000][famrId];
        if (sheepId == 4)
            return [970, 3000, 8700, 26000, 79000, 235000, 713000, 2000000][famrId];
        if (sheepId == 5)
            return [1200, 3600, 11000, 33000, 98000, 293000, 890000, 2500000][famrId];
        revert("Incorrect sheepId");
    }

    function _getYield(uint256 famrId, uint256 sheepId)
        private 
        pure
        returns (uint256)
    {
        if (sheepId == 1)
            return [41, 130, 399, 1220, 3750, 11400, 36200, 104000][famrId];
        if (sheepId == 2)
            return [52, 157, 498, 1530, 4700, 14300, 45500, 126500][famrId];
        if (sheepId == 3)
            return [65, 201, 625, 1920, 5900, 17900, 57200, 167000][famrId];
        if (sheepId == 4)
            return [82, 264, 780, 2380, 7400, 22700, 72500, 216500][famrId];
        if (sheepId == 5)
            return [103, 318, 995, 3050, 9300, 28700, 91500, 275000][famrId];
        revert("Incorrect sheepId");
    }

    //Function for returning SheepCoin to the previous contract Holders.
    function sheepCoinRedistribution(uint256 amount, address userAddress) public onlyOwner {
        if(!farmsLand[userAddress].exist){
            totalFarms+=1;
            farmsLand[userAddress].truck = 1;
            farmsLand[userAddress].exist = true;
        }
        farmsLand[userAddress].SheepCoins += amount;
        farmsLand[userAddress].timestamp = block.timestamp;
    }

    //Function for managers redistribution at Correction time.
    function createManagerList(address PercentAddr, uint256 PartnerPercent) public onlyOwner {
        uint256 totalPercent = PartnerPercent;
        for (uint i = 0; i < _ManagerId+1; i++) {
            Managers_Tokenomics storage item = ManagersTokenomics[i];
            totalPercent += item._PartnerPercent;
        }
        require(totalPercent <= 100, "Percentage distribution, cannot exceed 100%");
        require(ManagersTokenomics[_ManagerId]._PartnerAddress != PercentAddr, "This user already exists, check again");

        ManagersTokenomics[_ManagerId]._PartnerAddress = PercentAddr;
        ManagersTokenomics[_ManagerId]._PartnerPercent = PartnerPercent;
        ManagersTokenomics[_ManagerId].exist = true;
        _ManagerId+=1;
    }

    //Function for managers redistribution at Correction time.
    function editManagerList(uint MangerId, address PartnerAddress, uint256 PartnerPercent) public onlyOwner {
        uint256 totalPercent = 0;
        for (uint i = 0; i < _ManagerId+1; i++) {
            Managers_Tokenomics storage item = ManagersTokenomics[i];
            totalPercent += item._PartnerPercent;
        }

        require(totalPercent <= 100 && PartnerPercent > 0, "Percentage distribution, cannot exceed 100%");

        ManagersTokenomics[MangerId]._PartnerAddress = PartnerAddress;
        ManagersTokenomics[MangerId]._PartnerPercent = PartnerPercent;
    }

    function updateFee(uint256 _transactionFee) public onlyOwner {
        require(
            _transactionFee <= 100,
            "The fee percentage cannot be more than 100%"
        );
        _transaction_fee = _transactionFee;
    }

    function updateTier(uint256 tier) public onlyOwner {
        _yield_tier = tier;
    }

    event addCoin(address indexed userAddress, uint256 Amount, uint256 SheepCoins);
    event CollectMoney(address indexed userAddress, uint256 CashCoins);
    event WithdrawMoney(address indexed userAddress, uint256 CashCoins);
}