// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

/**
 * @dev Interface of the BEP20 standard as defined in the EIP.
 */
interface IBEP20 {
   /**
     * @dev Returns the amount of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the amount of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Moves `amount` tokens from the caller's account to `recipient`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address recipient, uint256 amount) external returns (bool);

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
     * @dev Moves `amount` tokens from `sender` to `recipient` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(
        address sender,
        address recipient,
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

interface IAIADZMatrix {
    function isUserExists(address user) external view returns (bool);
}

pragma solidity 0.8.19;

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
    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
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
        // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
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
    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
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
    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b != 0, errorMessage);
        return a % b;
    }
}

pragma solidity 0.8.19;

/**
 * @dev Collection of functions related to the address type
 */
library Address {
    /**
     * @dev Returns true if `account` is a contract.
     *
     * [IMPORTANT]
     * ====
     * It is unsafe to assume that an address for which this function returns
     * false is an externally-owned account (EOA) and not a contract.
     *
     * Among others, `isContract` will return false for the following
     * types of addresses:
     *
     *  - an externally-owned account
     *  - a contract in construction
     *  - an address where a contract will be created
     *  - an address where a contract lived, but was destroyed
     * ====
     */
    function isContract(address account) internal view returns (bool) {
        // This method relies on extcodesize, which returns 0 for contracts in
        // construction, since the code is only stored at the end of the
        // constructor execution.

        uint256 size;
        assembly {
            size := extcodesize(account)
        }
        return size > 0;
    }

    /**
     * @dev Replacement for Solidity's `transfer`: sends `amount` wei to
     * `recipient`, forwarding all available gas and reverting on errors.
     *
     * https://eips.ethereum.org/EIPS/eip-1884[EIP1884] increases the gas cost
     * of certain opcodes, possibly making contracts go over the 2300 gas limit
     * imposed by `transfer`, making them unable to receive funds via
     * `transfer`. {sendValue} removes this limitation.
     *
     * https://diligence.consensys.net/posts/2019/09/stop-using-soliditys-transfer-now/[Learn more].
     *
     * IMPORTANT: because control is transferred to `recipient`, care must be
     * taken to not create reentrancy vulnerabilities. Consider using
     * {ReentrancyGuard} or the
     * https://solidity.readthedocs.io/en/v0.5.11/security-considerations.html#use-the-checks-effects-interactions-pattern[checks-effects-interactions pattern].
     */
    function sendValue(address payable recipient, uint256 amount) internal {
        require(address(this).balance >= amount, "Address: insufficient balance");

        (bool success, ) = recipient.call{value: amount}("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }

    /**
     * @dev Performs a Solidity function call using a low level `call`. A
     * plain `call` is an unsafe replacement for a function call: use this
     * function instead.
     *
     * If `target` reverts with a revert reason, it is bubbled up by this
     * function (like regular Solidity function calls).
     *
     * Returns the raw returned data. To convert to the expected return value,
     * use https://solidity.readthedocs.io/en/latest/units-and-global-variables.html?highlight=abi.decode#abi-encoding-and-decoding-functions[`abi.decode`].
     *
     * Requirements:
     *
     * - `target` must be a contract.
     * - calling `target` with `data` must not revert.
     *
     * _Available since v3.1._
     */
    function functionCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionCall(target, data, "Address: low-level call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`], but with
     * `errorMessage` as a fallback revert reason when `target` reverts.
     *
     * _Available since v3.1._
     */
    function functionCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        return functionCallWithValue(target, data, 0, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but also transferring `value` wei to `target`.
     *
     * Requirements:
     *
     * - the calling contract must have an ETH balance of at least `value`.
     * - the called Solidity function must be `payable`.
     *
     * _Available since v3.1._
     */
    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value
    ) internal returns (bytes memory) {
        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }

    /**
     * @dev Same as {xref-Address-functionCallWithValue-address-bytes-uint256-}[`functionCallWithValue`], but
     * with `errorMessage` as a fallback revert reason when `target` reverts.
     *
     * _Available since v3.1._
     */
    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value,
        string memory errorMessage
    ) internal returns (bytes memory) {
        require(address(this).balance >= value, "Address: insufficient balance for call");
        require(isContract(target), "Address: call to non-contract");

        (bool success, bytes memory returndata) = target.call{value: value}(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but performing a static call.
     *
     * _Available since v3.3._
     */
    function functionStaticCall(address target, bytes memory data) internal view returns (bytes memory) {
        return functionStaticCall(target, data, "Address: low-level static call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-string-}[`functionCall`],
     * but performing a static call.
     *
     * _Available since v3.3._
     */
    function functionStaticCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal view returns (bytes memory) {
        require(isContract(target), "Address: static call to non-contract");

        (bool success, bytes memory returndata) = target.staticcall(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but performing a delegate call.
     *
     * _Available since v3.4._
     */
    function functionDelegateCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionDelegateCall(target, data, "Address: low-level delegate call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-string-}[`functionCall`],
     * but performing a delegate call.
     *
     * _Available since v3.4._
     */
    function functionDelegateCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        require(isContract(target), "Address: delegate call to non-contract");

        (bool success, bytes memory returndata) = target.delegatecall(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    /**
     * @dev Tool to verifies that a low level call was successful, and revert if it wasn't, either by bubbling the
     * revert reason using the provided one.
     *
     * _Available since v4.3._
     */
    function verifyCallResult(
        bool success,
        bytes memory returndata,
        string memory errorMessage
    ) internal pure returns (bytes memory) {
        if (success) {
            return returndata;
        } else {
            // Look for revert reason and bubble it up if present
            if (returndata.length > 0) {
                // The easiest way to bubble the revert reason is using memory via assembly

                assembly {
                    let returndata_size := mload(returndata)
                    revert(add(32, returndata), returndata_size)
                }
            } else {
                revert(errorMessage);
            }
        }
    }
}

pragma solidity 0.8.19;

/**
 * @title SafeBEP20
 * @dev Wrappers around BEP20 operations that throw on failure (when the token
 * contract returns false). Tokens that return no value (and instead revert or
 * throw on failure) are also supported, non-reverting calls are assumed to be
 * successful.
 * To use this library you can add a `using SafeBEP20 for IBEP20;` statement to your contract,
 * which allows you to call the safe operations as `token.safeTransfer(...)`, etc.
 */
library SafeBEP20 {
    using Address for address;

    function safeTransfer(
        IBEP20 token,
        address to,
        uint256 value
    ) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function safeTransferFrom(
        IBEP20 token,
        address from,
        address to,
        uint256 value
    ) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }

    /**
     * @dev Deprecated. This function has issues similar to the ones found in
     * {IBEP20-approve}, and its usage is discouraged.
     *
     * Whenever possible, use {safeIncreaseAllowance} and
     * {safeDecreaseAllowance} instead.
     */
    function safeApprove(
        IBEP20 token,
        address spender,
        uint256 value
    ) internal {
        // safeApprove should only be called when setting an initial allowance,
        // or when resetting it to zero. To increase and decrease it, use
        // 'safeIncreaseAllowance' and 'safeDecreaseAllowance'
        require(
            (value == 0) || (token.allowance(address(this), spender) == 0),
            "SafeBEP20: approve from non-zero to non-zero allowance"
        );
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
    }

    function safeIncreaseAllowance(
        IBEP20 token,
        address spender,
        uint256 value
    ) internal {
        uint256 newAllowance = token.allowance(address(this), spender) + value;
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function safeDecreaseAllowance(
        IBEP20 token,
        address spender,
        uint256 value
    ) internal {
        unchecked {
            uint256 oldAllowance = token.allowance(address(this), spender);
            require(oldAllowance >= value, "SafeBEP20: decreased allowance below zero");
            uint256 newAllowance = oldAllowance - value;
            _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
        }
    }

    /**
     * @dev Imitates a Solidity high-level call (i.e. a regular function call to a contract), relaxing the requirement
     * on the return value: the return value is optional (but if data is returned, it must not be false).
     * @param token The token targeted by the call.
     * @param data The call data (encoded using abi.encode or one of its variants).
     */
    function _callOptionalReturn(IBEP20 token, bytes memory data) private {
        // We need to perform a low level call here, to bypass Solidity's return data size checking mechanism, since
        // we're implementing it ourselves. We use {Address.functionCall} to perform this call, which verifies that
        // the target address contains contract code and also asserts for success in the low-level call.

        bytes memory returndata = address(token).functionCall(data, "SafeBEP20: low-level call failed");
        if (returndata.length > 0) {
            // Return data is optional
            require(abi.decode(returndata, (bool)), "SafeBEP20: BEP20 operation did not succeed");
        }
    }
}

pragma solidity 0.8.19;

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

pragma solidity 0.8.19;

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

contract AIADZXXX is Ownable {    
    using SafeBEP20 for IBEP20;  
    using Address for address payable;

    struct User {
        uint id;
        address referrer;
        uint partnersCount;
        mapping(uint8 => bool) activeX6Levels;
        mapping(uint8 => X6) x6Matrix;
    }

    struct X6 {
        address firstUpline;
        address secondUpline;
        address[] firstLevelReferrals;
        address[] secondLevelReferrals;
        address[] thirdLevelReferrals;
        bool blocked;
        uint reinvestCount;
    }

    uint public BASIC_PRICE;
    uint8 public LAST_LEVEL;

    mapping(address => User) public users;
    mapping(uint => address) public idToAddress;
    mapping(uint => address) public userIds;

    uint public lastUserId;
    address public id1;

    mapping(uint8 => uint) public levelPrice;

    IBEP20 public depositToken;
    IAIADZMatrix public matrix;
    address public marketWallet;

    uint256 public commission = 45;
    uint256 public splitCommission = 55;
    uint256 public firstCommission = 30;
    uint256 public secondCommission = 70;

    event Registration(address indexed user, address indexed referrer, uint indexed userId, uint referrerId);
    event Reinvest(address indexed user, address indexed firstUpline, address indexed caller, uint8 matrix, uint8 level);
    event Upgrade(address indexed user, address indexed referrer, uint8 matrix, uint8 level);
    event MissedEthReceive(address indexed receiver, address indexed from, uint8 matrix, uint8 level);    
    event SentExtraEthDividends(address indexed from, address indexed receiver,uint8 level,uint256 commision);
    event SentMarketEthDividends(address indexed from, address indexed receiver,uint8 level,uint256 commision);
    event NewUserPlace(
        address indexed user,
        address indexed referrer,
        uint8 level,
        uint8 line,
        uint256 place
    );

    constructor(IBEP20 _depositTokenAddress, address newMarketWallet, address newMatrix) {        
        require(newMarketWallet != address(0), "zero address");
        require(Address.isContract(address(newMatrix)), "not a matrix contract");
        require(Address.isContract(address(_depositTokenAddress)), "not a contract");
        BASIC_PRICE = 8e18;
        LAST_LEVEL = 15;

        address _ownerAddress = msg.sender;

        levelPrice[1] = BASIC_PRICE;
        for (uint8 i = 2; i <= LAST_LEVEL; i++) {
            levelPrice[i] = levelPrice[i-1] * 2;
        }

        id1 = _ownerAddress;        
        users[_ownerAddress].id = 1;

        idToAddress[1] = _ownerAddress;
        marketWallet = newMarketWallet;
        matrix = IAIADZMatrix(newMatrix);

        for (uint8 i = 1; i <= LAST_LEVEL; i++) {
            users[_ownerAddress].activeX6Levels[i] = true;
            users[_ownerAddress].x6Matrix[i].firstUpline = _ownerAddress;
        }

        userIds[1] = _ownerAddress;
        lastUserId = 2;

        depositToken = _depositTokenAddress;
    }

    receive() external payable{}

    function updateDepositToken(address _depositTokenAddress) external onlyOwner {
        require(Address.isContract(_depositTokenAddress), "not a deposit token contract");
        depositToken = IBEP20(_depositTokenAddress);
    }

    function updateMatrix(address newMatrix) external onlyOwner {
        require(Address.isContract(newMatrix), "not a matrix contract");
        matrix = IAIADZMatrix(newMatrix);
    }

    function updateMarketWallet(address newMarketWallet) external onlyOwner {
        require(newMarketWallet != address(0), "zero address");
        marketWallet = newMarketWallet;
    }

    function registrationExt(address referrerAddress) external  {
        registration(msg.sender, referrerAddress);
    }
    
    function buyNewLevel(uint8 level) external  {
        _buyNewLevel(msg.sender, level);
    }

    function buyNewLevelFor(address userAddress, uint8 level) external  {
        _buyNewLevel(userAddress, level);
    }

    function _buyNewLevel(address _userAddress,uint8 level) internal {
        require(isUserExists(_userAddress), "user is not exists. Register first.");
        require(level > 1 && level <= LAST_LEVEL, "invalid level");
        require(users[_userAddress].activeX6Levels[level-1], "buy previous level first");
        require(!users[_userAddress].activeX6Levels[level], "level already activated"); 

        depositToken.safeTransferFrom(msg.sender, address(this), levelPrice[level]);

        if (users[_userAddress].x6Matrix[level-1].blocked) {
            users[_userAddress].x6Matrix[level-1].blocked = false;
        }

        address freeX6Referrer = findFreeX6Referrer(_userAddress, level);
            
        users[_userAddress].activeX6Levels[level] = true;
        sendMarketETHDividends(marketWallet,_userAddress, level);
        updateX6Referrer(_userAddress, freeX6Referrer, level);

        emit Upgrade(_userAddress, freeX6Referrer, 2, level);
    }

    function registration(address userAddress,address referrerAddress) private {
        require(matrix.isUserExists(userAddress), "user not exist in matrix");
        require(!isUserExists(userAddress), "user exists");
        require(isUserExists(referrerAddress), "referrer not exists");
        
        depositToken.safeTransferFrom(msg.sender, address(this), levelPrice[1]);
        
        users[userAddress].id = lastUserId;
        users[userAddress].referrer = referrerAddress;
        
        idToAddress[lastUserId] = userAddress;
        
        users[userAddress].referrer = referrerAddress;
        
        users[userAddress].activeX6Levels[1] = true;        
        
        userIds[lastUserId] = userAddress;
        lastUserId++;
        
        users[referrerAddress].partnersCount++;
        sendMarketETHDividends( marketWallet, userAddress, 1);
        updateX6Referrer(userAddress, findFreeX6Referrer(userAddress, 1), 1);
        
        emit Registration(userAddress, referrerAddress, users[userAddress].id, users[referrerAddress].id);
    }
    
    function updateX6Referrer(address userAddress, address referrerAddress, uint8 level) private {
        require(users[referrerAddress].activeX6Levels[level], "500. Referrer level is inactive");      

        (address upline1,address upline2) = findFree(referrerAddress,level);

        users[upline1].x6Matrix[level].firstLevelReferrals.push(userAddress);
        if (userAddress != upline1) {
            users[userAddress].x6Matrix[level].firstUpline = upline1;
            emit NewUserPlace(
                userAddress,
                upline1,
                level,
                1,
                users[upline1].x6Matrix[level].firstLevelReferrals.length
            );
        }
     
        if (upline1 == id1) {
            return sendETHDividends(upline1,upline1,userAddress,level);
        }

        if (upline1 != upline2) {
            users[upline2].x6Matrix[level].secondLevelReferrals.push(userAddress);
            emit NewUserPlace(
                userAddress,
                upline2,
                level,
                2,
                users[upline2].x6Matrix[level].secondLevelReferrals.length
            ); 
        } 

        if (users[upline2].x6Matrix[level].firstUpline != upline2) {
            users[users[upline2].x6Matrix[level].firstUpline].x6Matrix[level].thirdLevelReferrals.push(userAddress);
            emit NewUserPlace(
                userAddress,
                users[upline2].x6Matrix[level].firstUpline,
                level,
                3,
                users[users[upline2].x6Matrix[level].firstUpline].x6Matrix[level].thirdLevelReferrals.length
            ); 
        }               
        
        updateX6ReferrerThirdLevel(userAddress,upline2, users[upline2].x6Matrix[level].firstUpline, level);
    }
    
    function updateX6ReferrerThirdLevel(address userAddress, address secondUpline, address thirdUpline, uint8 level) private {
        if (users[thirdUpline].x6Matrix[level].thirdLevelReferrals.length < 8) {
            if (users[secondUpline].x6Matrix[level].secondLevelReferrals.length < 4) {
                return sendETHDividends(secondUpline,thirdUpline, userAddress,level);
            }else {
                return sendETHDividends(address(0),thirdUpline,userAddress,level);
            }
        }

        users[thirdUpline].x6Matrix[level].firstLevelReferrals = new address[](0);
        users[thirdUpline].x6Matrix[level].secondLevelReferrals = new address[](0);
        users[thirdUpline].x6Matrix[level].thirdLevelReferrals = new address[](0);

        if (!users[thirdUpline].activeX6Levels[level+1] && level != LAST_LEVEL) {
            users[thirdUpline].x6Matrix[level].blocked = true;
        }

        users[thirdUpline].x6Matrix[level].reinvestCount++;

        if (thirdUpline != id1) {
            address freeReferrerAddress = findFreeX6Referrer(thirdUpline, level);

            emit Reinvest(thirdUpline, freeReferrerAddress, userAddress, 2, level);
            updateX6Referrer(thirdUpline, freeReferrerAddress, level);
        } else {
            emit Reinvest(id1, address(0), userAddress, 2, level);
            sendETHDividends(id1,id1, userAddress,level);
        }
    }

    function findFree(address user,uint8 level) public view returns(address,address) {
        if(users[user].x6Matrix[level].firstLevelReferrals.length < 2) return (user,users[user].x6Matrix[level].firstUpline);

        address[] memory downlines = new address[](126);
        downlines[0] = users[user].x6Matrix[level].firstLevelReferrals[0];
        downlines[1] = users[user].x6Matrix[level].firstLevelReferrals[1];

        address freeReferrer;
        bool noFreeReferrer = true;

        for(uint i = 0; i < 126; i++) {
            if(users[downlines[i]].x6Matrix[level].firstLevelReferrals.length == 2) {
                if(i < 62) {
                    downlines[(i+1)*2] = users[downlines[i]].x6Matrix[level].firstLevelReferrals[0];
                    downlines[(i+1)*2+1] = users[downlines[i]].x6Matrix[level].firstLevelReferrals[1];
                }
            }else{
                noFreeReferrer = false;
                freeReferrer = downlines[i];
                break;
            }
        }
        require(!noFreeReferrer, 'No Free Referrer');
        return (freeReferrer,users[freeReferrer].x6Matrix[level].firstUpline);
    }
    
    function findFreeX6Referrer(address userAddress, uint8 level) public view returns(address referrer) {
        while (true) {
            if (users[users[userAddress].referrer].activeX6Levels[level]) {
                return users[userAddress].referrer;
            }
            
            userAddress = users[userAddress].referrer;
        }
    }

    function usersActiveX6Levels(address userAddress, uint8 level) public view returns(bool) {
        return users[userAddress].activeX6Levels[level];
    }

    function usersX6Matrix(address userAddress, uint8 level) public view returns(
        address, 
        address[] memory, 
        address[] memory, 
        address[] memory, 
        bool,
        uint
        ) {
        return (users[userAddress].x6Matrix[level].firstUpline,
                users[userAddress].x6Matrix[level].firstLevelReferrals,
                users[userAddress].x6Matrix[level].secondLevelReferrals,
                users[userAddress].x6Matrix[level].thirdLevelReferrals,
                users[userAddress].x6Matrix[level].blocked,
                users[userAddress].x6Matrix[level].reinvestCount
                );
    }
    
    function isUserExists(address user) public view returns (bool) {
        return (users[user].id != 0);
    }

    function findEthReceiver(address receiver, address _from,uint8 level) private returns(address receiverAddress,bool isExtraDividends) {  
        if(receiver == address(0)){
            return (address(0),isExtraDividends);
        }
        while (true) {
            if (users[receiver].x6Matrix[level].blocked) {
                emit MissedEthReceive(receiver, _from, 2, level);
                isExtraDividends = true;
                receiver = users[receiver].x6Matrix[level].firstUpline;
            } else {
                return (receiver, isExtraDividends);
            }
        }
    }

    function sendETHDividends(address userAddress1,address userAddress2, address _from, uint8 level) private {
        (address receiver1,) = findEthReceiver(userAddress1, _from, level);
        (address receiver2,) = findEthReceiver(userAddress2, _from, level);
        
        uint256 _splitCommission = (levelPrice[level] * splitCommission) / 100;
        
        if(receiver1 != address(0)) {
            depositToken.safeTransfer(receiver1, _splitCommission * (firstCommission) / (100));

            emit SentExtraEthDividends(_from, receiver1,level,_splitCommission * (firstCommission) / (100));
        }

        if(receiver2 != address(0)) {
            depositToken.safeTransfer(receiver2, _splitCommission * (secondCommission) / (100));

            emit SentExtraEthDividends(_from, receiver2,level,_splitCommission * (secondCommission) / (100));
        }
    }

    function sendMarketETHDividends(address userAddress,address _from, uint8 level) private {
        uint256 _commission = (levelPrice[level] * commission) / 100;
        if(userAddress != address(0) && _commission != 0) {
            depositToken.safeTransfer(userAddress, _commission);
            emit SentMarketEthDividends(_from, userAddress, level, _commission);
        }
    }

    function withdrawLostTokens(address tokenAddress, address to) public onlyOwner {
        require(to != address(0), "to address zero address");
        if (tokenAddress == address(0)) {
            payable(to).sendValue(address(this).balance);
        } else {
            uint256 amount = IBEP20(tokenAddress).balanceOf(address(this));
            require(amount > 0, "Insufficient Balance");
            IBEP20(tokenAddress).safeTransfer(to, amount);
        }
    }
}