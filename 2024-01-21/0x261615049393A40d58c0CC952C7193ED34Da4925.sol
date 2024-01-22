// SPDX-License-Identifier: MIT
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

contract SmartContMult is Context, ReentrancyGuard, Ownable {
    using SafeMath for uint256;
    using Address for address;

    uint256 public maxInvestValue;
    uint256 public maxInvestors;
    uint256 public TotalInvestments;
    uint256 public TotalInvestors;
    uint256 public maxWitheListValue;
    uint256 public maxInvestorsWl;
    uint256 public TotalInvestorWl;
    uint256 public TotalInvestWhiteList;

    uint private _ManagerId;
    struct Managers_Percents {
        address _PartnerAddress;
        uint256 _PartnerPercent;
        bool exist;
    }
    mapping(uint => Managers_Percents) private ManagersPercentage;
    mapping (address => uint) private pendingBalance;

    bool public paused_wl = true;
    bool public paused = true;
    modifier isPausable() {
        require(!paused, "The Contract is paused.");
        _;
    }

    constructor(
        uint256 MaxValeu,
        uint256 MaxInvestors,
        uint256 MaxWitheListValue,
        uint256 MaxInvestorsWl
    ) Ownable(msg.sender) {
        maxInvestValue = MaxValeu;
        maxInvestors = MaxInvestors;
        maxWitheListValue = MaxWitheListValue;
        maxInvestorsWl = MaxInvestorsWl;
    }

    function totalBalance() external view returns(uint256) {
        return payable(address(this)).balance;
    }

    function balanceOf(address account) public view returns (uint256) {
        return pendingBalance[account];
    }

    /*get getManagers_Percents*/
    function getManagers_Percents()
        public view returns (Managers_Percents[] memory) {
        Managers_Percents[] memory items = new Managers_Percents[](_ManagerId+1);
        for (uint i = 0; i < _ManagerId+1; i++) {
            Managers_Percents storage Partner = ManagersPercentage[i];
            if(Partner._PartnerAddress != address(0)){
                items[i] = Partner;
            }
        }
        return items;
    }

    /**
     * @dev Enables the contract to receive BNB.
     */
    receive() external payable {}
    fallback() external payable {}

    function privateMinerGold() public payable nonReentrant isPausable {
        TotalInvestors+=1;
        require(pendingBalance[msg.sender] == 0, "You are already participating in this private sale");
        require(msg.value >= maxInvestValue, "Insufficient value for this requisition");
        require(TotalInvestors <= maxInvestors, "We have reached the maximum number of investors.");

        for (uint256 i = 0; i < _ManagerId+1; i++) {
            require(msg.sender != ManagersPercentage[i]._PartnerAddress, "Administrator does not participate in the private sale");
            if (
                ManagersPercentage[i]._PartnerAddress != address(0) ||
                ManagersPercentage[i]._PartnerPercent > 0
            ) {
                uint256 ManageAmount = (maxInvestValue).mul(ManagersPercentage[i]._PartnerPercent).div(100);
                pendingBalance[ManagersPercentage[i]._PartnerAddress] += ManageAmount;
            }
        }

        pendingBalance[msg.sender] += maxInvestValue;
        TotalInvestments+=maxInvestValue;
        emit Received(msg.sender, maxInvestValue);
    }
    
    function WhiteListMinerGold() public payable nonReentrant isPausable {
        require(!paused_wl, "The WitheList is paused");
        TotalInvestorWl+=1;
        require(pendingBalance[msg.sender] == 0, "You are already participating in this WitheList");
        require(msg.value >= maxWitheListValue, "Insufficient value for this requisition");
        require(TotalInvestorWl <= maxInvestorsWl, "We have reached the maximum number of investors.");

        for (uint256 i = 0; i < _ManagerId+1; i++) {
            require(msg.sender != ManagersPercentage[i]._PartnerAddress, "Administrator does not participate in the WitheList");
            if (
                ManagersPercentage[i]._PartnerAddress != address(0) ||
                ManagersPercentage[i]._PartnerPercent > 0
            ) {
                uint256 ManageAmount = (maxWitheListValue).mul(ManagersPercentage[i]._PartnerPercent).div(100);
                pendingBalance[ManagersPercentage[i]._PartnerAddress] += ManageAmount;
            }
        }

        pendingBalance[msg.sender] += maxWitheListValue;
        TotalInvestWhiteList += maxWitheListValue;
        emit ReceivedWl(msg.sender, maxWitheListValue);
    }

    function updateMaxInvestValue(uint256 MaxInvestValue)
        public onlyOwner
    {
        maxInvestValue = MaxInvestValue;
    }

    function updateMaxInvestors(uint256 MaxInvestors)
        public onlyOwner
    {
        maxInvestors = MaxInvestors;
    }

    function updateMaxInvestorsWl(uint256 MaxInvestors)
        public onlyOwner
    {
        maxInvestorsWl = MaxInvestors;
    }

    //Function for managers redistribution at Correction time.
    function createManagerList(address PercentAddr, uint256 PartnerPercent) public onlyOwner {
        require(ManagersPercentage[_ManagerId]._PartnerAddress != PercentAddr, "This user already exists, check again");
        uint256 totalPercent = PartnerPercent;
        for (uint i = 0; i < _ManagerId+1; i++) {
            require(ManagersPercentage[i]._PartnerAddress != PercentAddr, "This user already exists, check again");
            if(ManagersPercentage[i]._PartnerAddress != PercentAddr){
                Managers_Percents storage item = ManagersPercentage[i];
                if(item._PartnerPercent >= 1){
                    totalPercent += item._PartnerPercent;
                }
            }
        }
        require(PartnerPercent > 0 && totalPercent <= 100, "Percentage distribution, cannot exceed 100%");

        ManagersPercentage[_ManagerId]._PartnerAddress = PercentAddr;
        ManagersPercentage[_ManagerId]._PartnerPercent = PartnerPercent;
        ManagersPercentage[_ManagerId].exist = true;
        _ManagerId+=1;
    }

    //Function for managers redistribution at Correction time.
    function editManagerList(uint MangerId, address PartnerAddress, uint256 PartnerPercent) public onlyOwner {
        uint256 totalPercent = PartnerPercent;
        for (uint i = 0; i < _ManagerId+1; i++) {
            if(ManagersPercentage[i]._PartnerAddress != PartnerAddress){
                Managers_Percents storage item = ManagersPercentage[i];
                if(item._PartnerPercent >= 1){
                    totalPercent += item._PartnerPercent;
                }
            }
        }        
        require(PartnerPercent > 0 && totalPercent <= 100, "Percentage distribution, cannot exceed 100%");

        ManagersPercentage[MangerId]._PartnerAddress = PartnerAddress;
        ManagersPercentage[MangerId]._PartnerPercent = PartnerPercent;
    }

    /*
     * @dev Activates or pauses the main activities carried out by users.
     * For security reasons or to prevent any harm to the system.
     */
    function pause_witheList() public onlyOwner {
        if (paused_wl) {
            paused_wl = false;
        } else {
            paused_wl = true;
        }
    }

    /*
     * @dev Activates or pauses the main activities carried out by users.
     * For security reasons or to prevent any harm to the system.
     */
    function pause() public onlyOwner {
        if (paused) {
            paused = false;
        } else {
            paused = true;
        }
    }
    
    function withdrawManager(uint MangerId) external {
        address account = msg.sender;
        require(
            account == ManagersPercentage[MangerId]._PartnerAddress,
            "Your address does not correspond to that of an administrator."
        );
        require(
            this.totalBalance() > 0,
            "You do not have enough balance for this withdrawal"
        );
        uint256 balance = balanceOf(account);
        payable(account).transfer(balance);
        pendingBalance[account] = 0;
    }

    /*
     * @dev Function created to recover funds sent in error
     */
    function rescueBalanceBNB() external onlyOwner {
        require(
            this.totalBalance() > 0,
            "You do not have enough balance for this withdrawal"
        );
        payable(_owner).transfer(this.totalBalance());
    }

    event Received(address indexed account, uint256 amount);
    event ReceivedWl(address indexed account, uint256 amount);
}