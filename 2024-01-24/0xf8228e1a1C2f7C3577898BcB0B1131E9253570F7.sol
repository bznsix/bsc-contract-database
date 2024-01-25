// SPDX-License-Identifier: MIT

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
    function transfer(address recipient, uint256 amount)
        external
        returns (bool);

    /**
     * @dev Returns the remaining number of tokens that `spender` will be
     * allowed to spend on behalf of `owner` through {transferFrom}. This is
     * zero by default.
     *
     * This value changes when {approve} or {transferFrom} are called.
     */
    function allowance(address owner, address spender)
        external
        view
        returns (uint256);

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
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
}

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
        // This method relies in extcodesize, which returns 0 for contracts in
        // construction, since the code is only stored at the end of the
        // constructor execution.

        uint256 size;
        // solhint-disable-next-line no-inline-assembly
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
        require(
            address(this).balance >= amount,
            "Address: insufficient balance"
        );

        // solhint-disable-next-line avoid-low-level-calls, avoid-call-value
        (bool success, ) = recipient.call{value: amount}("");
        require(
            success,
            "Address: unable to send value, recipient may have reverted"
        );
    }

    /**
     * @dev Performs a Solidity function call using a low level `call`. A
     * plain`call` is an unsafe replacement for a function call: use this
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
    function functionCall(address target, bytes memory data)
        internal
        returns (bytes memory)
    {
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
        return _functionCallWithValue(target, data, 0, errorMessage);
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
        return
            functionCallWithValue(
                target,
                data,
                value,
                "Address: low-level call with value failed"
            );
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
        require(
            address(this).balance >= value,
            "Address: insufficient balance for call"
        );
        return _functionCallWithValue(target, data, value, errorMessage);
    }

    function _functionCallWithValue(
        address target,
        bytes memory data,
        uint256 weiValue,
        string memory errorMessage
    ) private returns (bytes memory) {
        require(isContract(target), "Address: call to non-contract");

        // solhint-disable-next-line avoid-low-level-calls
        (bool success, bytes memory returndata) = target.call{value: weiValue}(
            data
        );
        if (success) {
            return returndata;
        } else {
            // Look for revert reason and bubble it up if present
            if (returndata.length > 0) {
                // The easiest way to bubble the revert reason is using memory via assembly

                // solhint-disable-next-line no-inline-assembly
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
    using SafeMath for uint256;
    using Address for address;

    function safeTransfer(
        IBEP20 token,
        address to,
        uint256 value
    ) internal {
        _callOptionalReturn(
            token,
            abi.encodeWithSelector(token.transfer.selector, to, value)
        );
    }

    function safeTransferFrom(
        IBEP20 token,
        address from,
        address to,
        uint256 value
    ) internal {
        _callOptionalReturn(
            token,
            abi.encodeWithSelector(token.transferFrom.selector, from, to, value)
        );
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
        // solhint-disable-next-line max-line-length
        require(
            (value == 0) || (token.allowance(address(this), spender) == 0),
            "SafeBEP20: approve from non-zero to non-zero allowance"
        );
        _callOptionalReturn(
            token,
            abi.encodeWithSelector(token.approve.selector, spender, value)
        );
    }

    function safeIncreaseAllowance(
        IBEP20 token,
        address spender,
        uint256 value
    ) internal {
        uint256 newAllowance = token.allowance(address(this), spender).add(
            value
        );
        _callOptionalReturn(
            token,
            abi.encodeWithSelector(
                token.approve.selector,
                spender,
                newAllowance
            )
        );
    }

    function safeDecreaseAllowance(
        IBEP20 token,
        address spender,
        uint256 value
    ) internal {
        uint256 newAllowance = token.allowance(address(this), spender).sub(
            value,
            "SafeBEP20: decreased allowance below zero"
        );
        _callOptionalReturn(
            token,
            abi.encodeWithSelector(
                token.approve.selector,
                spender,
                newAllowance
            )
        );
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

        bytes memory returndata = address(token).functionCall(
            data,
            "SafeBEP20: low-level call failed"
        );
        if (returndata.length > 0) {
            // Return data is optional
            // solhint-disable-next-line max-line-length
            require(
                abi.decode(returndata, (bool)),
                "SafeBEP20: BEP20 operation did not succeed"
            );
        }
    }
}


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
     * by making the `nonReentrant` function external, and make it call a
     * `private` function that does the actual work.
     */
    modifier nonReentrant() {
        // On the first call to nonReentrant, _notEntered will be true
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");

        // Any calls to nonReentrant after this point will fail
        _status = _ENTERED;

        _;

        // By storing the original value once again, a refund is triggered (see
        // https://eips.ethereum.org/EIPS/eip-2200)
        _status = _NOT_ENTERED;
    }
}

contract SmartMatrixForsageBasic  is ReentrancyGuard {
    address public contractOwner;

    struct User {
        uint256 id;
        address referrer;
        uint256 partnersCount;
        mapping(uint8 => bool) activeX3Levels;
        mapping(uint8 => bool) activeX6Levels;
        mapping(uint8 => X3) x3Matrix;
        mapping(uint8 => X6) x6Matrix;
    }

    struct X3 {
        address currentReferrer;
        address[] referrals;
        bool blocked;
        uint256 reinvestCount;
    }

    struct X6 {
        address currentReferrer;
        address[] firstLevelReferrals;
        address[] secondLevelReferrals;
        bool blocked;
        uint256 reinvestCount;
        address closedPart;
    }

    uint8 public LAST_LEVEL;

    mapping(address => User) public users;
    mapping(uint256 => address) public idToAddress;
    mapping(uint256 => address) public userIds;
    mapping(address => uint256) public balances;

    uint256 public lastUserId;
    address public id1;

    mapping(uint8 => uint256) public levelPrice;

    IBEP20 public depositToken;

    uint256 public BASIC_PRICE;

    bool public locked;

    event Registration(
        address indexed user,
        address indexed referrer,
        uint256 indexed userId,
        uint256 referrerId,
        uint256 ownerShare
    );
    event Reinvest(
        address indexed user,
        address indexed currentReferrer,
        address indexed caller,
        uint8 matrix,
        uint8 level
    );
    event Upgrade(
        address indexed user,
        address indexed referrer,
        uint8 matrix,
        uint8 level,
        uint256 ownerShare
    );
    event NewUserPlace(
        address indexed user,
        address indexed referrer,
        uint8 matrix,
        uint8 level,
        uint8 place
    );
    event MissedEthReceive(
        address indexed receiver,
        address indexed from,
        uint8 matrix,
        uint8 level
    );
    event SentExtraEthDividends(
        address indexed from,
        address indexed receiver,
        uint8 matrix,
        uint8 level
    );
    event Retrieve(
        address indexed _token,
        address indexed user,
        uint256 indexed amount,
        uint256 time
    );

    event UpdateShares(uint256 _ownerShare, uint256 _rewardShare, uint256 time);
    event UpdateDepositToken(address _oldToken, address _newToken, uint256 time);
    event UpdateContractOwner(address _oldOwner, address _newOwner, uint256 time);
    event UpdateAdminWallet(address _oldWallet, address _newWallet, uint256 time);
    event UplineShares(
        address indexed from,
        address indexed receiver,
        uint8 matrix,
        uint8 level,
        uint256 uplineShare
    );
}

contract AIADZMatrix is SmartMatrixForsageBasic {
    using SafeBEP20 for IBEP20;
    using Address for address;

    uint256 public uplineShare = 55e18;
    uint256 public ownerShare = 45e18;
    address public adminWallet;
    bool public isInitialized;

    constructor(address _wallet) {
        contractOwner = msg.sender;
        setWallet(_wallet);
    }

    modifier NotContract(address _account) {
        require(!_account.isContract(), "Addr not be ContractAddress");
        _;
    }

    modifier IsContract(address _account) {
        require(_account.isContract(), "Addr not be userAddress");
        _;
    }

    modifier isZeroAddress(address _addr) {
        require(_addr != address(0), "0!");
        _;
    }

    modifier onlyContractOwner() {
        require(msg.sender == contractOwner, "onlyOwner");
        _;
    }

    modifier onlyUnlocked() {
        require(!locked || msg.sender == contractOwner);
        _;
    }

    function setWallet(address _newWallet)
        public
        onlyContractOwner
        isZeroAddress(_newWallet)
        NotContract(_newWallet)
    {
      emit UpdateAdminWallet(adminWallet, _newWallet, block.timestamp);

        adminWallet = _newWallet;
    }

    function updateAdminWallet(address _newWallet) public {
        setWallet(_newWallet);
    }

    function updateContractOwner(address _contractOwner)
        external
        onlyContractOwner
        isZeroAddress(_contractOwner)
    {
                emit UpdateContractOwner(contractOwner,_contractOwner, block.timestamp);

        contractOwner = _contractOwner;
    }


    function updateShares(uint256 _ownerShare, uint256 _uplineShare)
        external
        onlyContractOwner
    {
        require(_ownerShare + _uplineShare == 100e18, "Invalid share");
        ownerShare = _ownerShare;
        uplineShare = _uplineShare;
        emit UpdateShares(_ownerShare, _uplineShare, block.timestamp);
    }

    function updateDepositToken(address _token)
        external
        onlyContractOwner
        isZeroAddress(_token)
        IsContract(_token)
    {
        emit UpdateDepositToken(address(depositToken), _token, block.timestamp);
        depositToken = IBEP20(_token);
    }

    function init(
        address _ownerAddress,
        IBEP20 _depositTokenAddress
    ) public onlyContractOwner {
        require(!isInitialized, "Already Init");
        BASIC_PRICE = 5e18;
        LAST_LEVEL = 15;

        levelPrice[1] = BASIC_PRICE;
        for (uint8 i = 2; i <= 15; i++) {
            levelPrice[i] = levelPrice[i - 1] * 2;
        }
        id1 = _ownerAddress;

        User storage user = users[_ownerAddress];

        user.id = 1;
        user.referrer = address(0);
        user.partnersCount = uint256(0);

        idToAddress[1] = _ownerAddress;

        for (uint8 i = 1; i <= LAST_LEVEL; i++) {
            users[_ownerAddress].activeX3Levels[i] = true;
            users[_ownerAddress].activeX6Levels[i] = true;
        }

        userIds[1] = _ownerAddress;
        lastUserId = 2;

        depositToken = _depositTokenAddress;
        isInitialized = true;

        locked = true;
    }

    function changeLock() external onlyContractOwner {
        locked = !locked;
    }

    fallback() external {
        if (msg.data.length == 0) {
            return registration(msg.sender, id1);
        }

        registration(msg.sender, bytesToAddress(msg.data));
    }

    function registrationExt(address referrerAddress)
        external
        onlyUnlocked
        isZeroAddress(referrerAddress)
        NotContract(referrerAddress)
    {
        registration(msg.sender, referrerAddress);
    }

    function registrationFor(address userAddress, address referrerAddress)
        external
        onlyUnlocked
        isZeroAddress(userAddress)
        NotContract(userAddress)
        isZeroAddress(referrerAddress)
        NotContract(referrerAddress)
    {
        registration(userAddress, referrerAddress);
    }

    function buyNewLevel(uint8 matrix, uint8 level) external onlyUnlocked {
        _buyNewLevel(msg.sender, matrix, level);
    }

    function buyNewLevelFor(
        address userAddress,
        uint8 matrix,
        uint8 level
    ) external onlyUnlocked {
        _buyNewLevel(userAddress, matrix, level);
    }

    function _buyNewLevel(
        address _userAddress,
        uint8 matrix,
        uint8 level
    ) internal {
        require(
            isUserExists(_userAddress),
            "user is not exists. Register first."
        );
        require(matrix == 1 || matrix == 2, "invalid matrix");

        require(level > 1 && level <= LAST_LEVEL, "invalid level");
        depositToken.safeTransferFrom(
            msg.sender,
            address(this),
            levelPrice[level]
        );

        depositToken.safeTransfer(
            adminWallet,
            (levelPrice[level] * ownerShare) / 100e18
        );

        if (matrix == 1) {
            require(
                users[_userAddress].activeX3Levels[level - 1],
                "buy previous level first"
            );
            require(
                !users[_userAddress].activeX3Levels[level],
                "level already activated"
            );

            if (users[_userAddress].x3Matrix[level - 1].blocked) {
                users[_userAddress].x3Matrix[level - 1].blocked = false;
            }

            address freeX3Referrer = findFreeX3Referrer(_userAddress, level);
            users[_userAddress]
                .x3Matrix[level]
                .currentReferrer = freeX3Referrer;
            users[_userAddress].activeX3Levels[level] = true;
            updateX3Referrer(_userAddress, freeX3Referrer, level);

            emit Upgrade(
                _userAddress,
                freeX3Referrer,
                1,
                level,
                (levelPrice[level] * ownerShare) / 100e18
            );
        } else {
            require(
                users[_userAddress].activeX6Levels[level - 1],
                "buy previous level first"
            );
            require(
                !users[_userAddress].activeX6Levels[level],
                "level already activated"
            );

            if (users[_userAddress].x6Matrix[level - 1].blocked) {
                users[_userAddress].x6Matrix[level - 1].blocked = false;
            }

            address freeX6Referrer = findFreeX6Referrer(_userAddress, level);

            users[_userAddress].activeX6Levels[level] = true;
            updateX6Referrer(_userAddress, freeX6Referrer, level);

            emit Upgrade(
                _userAddress,
                freeX6Referrer,
                2,
                level,
                (levelPrice[level] * ownerShare) / 100e18
            );
        }
    }

    function registration(address userAddress, address referrerAddress)
        private
    {
        require(!isUserExists(userAddress), "user exists");
        require(isUserExists(referrerAddress), "referrer not exists");

        depositToken.safeTransferFrom(
            msg.sender,
            address(this),
            BASIC_PRICE * 2
        );

        User storage user = users[userAddress];

        user.id = lastUserId;
        user.referrer = referrerAddress;
        user.partnersCount = 0;

        idToAddress[lastUserId] = userAddress;

        // -----------Already initialized-----------
        users[userAddress].referrer = referrerAddress;

        users[userAddress].activeX3Levels[1] = true;
        users[userAddress].activeX6Levels[1] = true;

        userIds[lastUserId] = userAddress;
        lastUserId++;

        users[referrerAddress].partnersCount++;

        address freeX3Referrer = findFreeX3Referrer(userAddress, 1);
        users[userAddress].x3Matrix[1].currentReferrer = freeX3Referrer;

        depositToken.safeTransfer(
            adminWallet,
            (BASIC_PRICE * 2 * ownerShare) / 100e18
        );

        updateX3Referrer(userAddress, freeX3Referrer, 1);

        updateX6Referrer(userAddress, findFreeX6Referrer(userAddress, 1), 1);

        emit Registration(
            userAddress,
            referrerAddress,
            users[userAddress].id,
            users[referrerAddress].id,
            (BASIC_PRICE * 2 * ownerShare) / 100e18
        );
    }

    function updateX3Referrer(
        address userAddress,
        address referrerAddress,
        uint8 level
    ) private {
        users[referrerAddress].x3Matrix[level].referrals.push(userAddress);

        if (users[referrerAddress].x3Matrix[level].referrals.length < 3) {
            emit NewUserPlace(
                userAddress,
                referrerAddress,
                1,
                level,
                uint8(users[referrerAddress].x3Matrix[level].referrals.length)
            );
            return sendTokenDividends(referrerAddress, userAddress, 1, level);
        }
        emit NewUserPlace(userAddress, referrerAddress, 1, level, 3);
        //close matrix
        users[referrerAddress].x3Matrix[level].referrals = new address[](0);
        if (
            !users[referrerAddress].activeX3Levels[level + 1] &&
            level != LAST_LEVEL
        ) {
            users[referrerAddress].x3Matrix[level].blocked = true;
        }

        //create new one by recursion
        if (referrerAddress != id1) {
            //check referrer active level
            address freeReferrerAddress = findFreeX3Referrer(
                referrerAddress,
                level
            );
            if (
                users[referrerAddress].x3Matrix[level].currentReferrer !=
                freeReferrerAddress
            ) {
                users[referrerAddress]
                    .x3Matrix[level]
                    .currentReferrer = freeReferrerAddress;
            }

            users[referrerAddress].x3Matrix[level].reinvestCount++;
            emit Reinvest(
                referrerAddress,
                freeReferrerAddress,
                userAddress,
                1,
                level
            );
            updateX3Referrer(referrerAddress, freeReferrerAddress, level);
        } else {
            sendTokenDividends(id1, userAddress, 1, level);
            users[id1].x3Matrix[level].reinvestCount++;
            emit Reinvest(id1, address(0), userAddress, 1, level);
        }
    }

    function updateX6Referrer(
        address userAddress,
        address referrerAddress,
        uint8 level
    ) private {
        require(
            users[referrerAddress].activeX6Levels[level],
            "500. Referrer level is inactive"
        );

        if (
            // ONLY FIRST LEVEL LESSER THEN 2
            users[referrerAddress].x6Matrix[level].firstLevelReferrals.length <
            2
        ) {
            users[referrerAddress].x6Matrix[level].firstLevelReferrals.push(
                userAddress
            );
            emit NewUserPlace(
                userAddress,
                referrerAddress,
                2,
                level,
                uint8(
                    users[referrerAddress]
                        .x6Matrix[level]
                        .firstLevelReferrals
                        .length
                )
            );

            //set current level
            users[userAddress]
                .x6Matrix[level]
                .currentReferrer = referrerAddress;

            if (referrerAddress == id1) {
                return
                    sendTokenDividends(referrerAddress, userAddress, 2, level);
            }

            address ref = users[referrerAddress]
                .x6Matrix[level]
                .currentReferrer;
            users[ref].x6Matrix[level].secondLevelReferrals.push(userAddress);

            uint256 len = users[ref].x6Matrix[level].firstLevelReferrals.length;

            if (
                (len == 2) &&
                (users[ref].x6Matrix[level].firstLevelReferrals[0] ==
                    referrerAddress) &&
                (users[ref].x6Matrix[level].firstLevelReferrals[1] ==
                    referrerAddress)
            ) {
                if (
                    users[referrerAddress]
                        .x6Matrix[level]
                        .firstLevelReferrals
                        .length == 1
                ) {
                    emit NewUserPlace(userAddress, ref, 2, level, 5);
                } else {
                    emit NewUserPlace(userAddress, ref, 2, level, 6);
                }
            } else if (
                (len == 1 || len == 2) &&
                users[ref].x6Matrix[level].firstLevelReferrals[0] ==
                referrerAddress
            ) {
                if (
                    users[referrerAddress]
                        .x6Matrix[level]
                        .firstLevelReferrals
                        .length == 1
                ) {
                    emit NewUserPlace(userAddress, ref, 2, level, 3);
                } else {
                    emit NewUserPlace(userAddress, ref, 2, level, 4);
                }
            } else if (
                len == 2 &&
                users[ref].x6Matrix[level].firstLevelReferrals[1] ==
                referrerAddress
            ) {
                if (
                    users[referrerAddress]
                        .x6Matrix[level]
                        .firstLevelReferrals
                        .length == 1
                ) {
                    emit NewUserPlace(userAddress, ref, 2, level, 5);
                } else {
                    emit NewUserPlace(userAddress, ref, 2, level, 6);
                }
            }
            return updateX6ReferrerSecondLevel(userAddress, ref, level);
        }

        users[referrerAddress].x6Matrix[level].secondLevelReferrals.push(
            userAddress
        );

        if (users[referrerAddress].x6Matrix[level].closedPart != address(0)) {
            if (
                (users[referrerAddress].x6Matrix[level].firstLevelReferrals[
                    0
                ] ==
                    users[referrerAddress].x6Matrix[level].firstLevelReferrals[
                        1
                    ]) &&
                (users[referrerAddress].x6Matrix[level].firstLevelReferrals[
                    0
                ] == users[referrerAddress].x6Matrix[level].closedPart)
            ) {
                updateX6(userAddress, referrerAddress, level, true);
                return
                    updateX6ReferrerSecondLevel(
                        userAddress,
                        referrerAddress,
                        level
                    );
            } else if (
                users[referrerAddress].x6Matrix[level].firstLevelReferrals[0] ==
                users[referrerAddress].x6Matrix[level].closedPart
            ) {
                updateX6(userAddress, referrerAddress, level, true);
                return
                    updateX6ReferrerSecondLevel(
                        userAddress,
                        referrerAddress,
                        level
                    );
            } else {
                updateX6(userAddress, referrerAddress, level, false);
                return
                    updateX6ReferrerSecondLevel(
                        userAddress,
                        referrerAddress,
                        level
                    );
            }
        } //

        if (
            users[referrerAddress].x6Matrix[level].firstLevelReferrals[1] ==
            userAddress
        ) {
            updateX6(userAddress, referrerAddress, level, false);
            return
                updateX6ReferrerSecondLevel(
                    userAddress,
                    referrerAddress,
                    level
                );
        } else if (
            users[referrerAddress].x6Matrix[level].firstLevelReferrals[0] ==
            userAddress
        ) {
            updateX6(userAddress, referrerAddress, level, true);
            return
                updateX6ReferrerSecondLevel(
                    userAddress,
                    referrerAddress,
                    level
                );
        }

        if (
            //
            users[users[referrerAddress].x6Matrix[level].firstLevelReferrals[0]]
                .x6Matrix[level]
                .firstLevelReferrals
                .length <=
            users[users[referrerAddress].x6Matrix[level].firstLevelReferrals[1]]
                .x6Matrix[level]
                .firstLevelReferrals
                .length
        ) {
            updateX6(userAddress, referrerAddress, level, false);
        } else {
            updateX6(userAddress, referrerAddress, level, true);
        }

        updateX6ReferrerSecondLevel(userAddress, referrerAddress, level);
    }

    function updateX6(
        address userAddress,
        address referrerAddress,
        uint8 level,
        bool x2
    ) private {
        if (!x2) {
            users[users[referrerAddress].x6Matrix[level].firstLevelReferrals[0]]
                .x6Matrix[level]
                .firstLevelReferrals
                .push(userAddress);
            emit NewUserPlace(
                userAddress,
                users[referrerAddress].x6Matrix[level].firstLevelReferrals[0],
                2,
                level,
                uint8(
                    users[
                        users[referrerAddress]
                            .x6Matrix[level]
                            .firstLevelReferrals[0]
                    ].x6Matrix[level].firstLevelReferrals.length
                )
            );
            emit NewUserPlace(
                userAddress,
                referrerAddress,
                2,
                level,
                2 +
                    uint8(
                        users[
                            users[referrerAddress]
                                .x6Matrix[level]
                                .firstLevelReferrals[0]
                        ].x6Matrix[level].firstLevelReferrals.length
                    )
            );
            //set current level
            users[userAddress].x6Matrix[level].currentReferrer = users[
                referrerAddress
            ].x6Matrix[level].firstLevelReferrals[0];
        } else {
            users[users[referrerAddress].x6Matrix[level].firstLevelReferrals[1]]
                .x6Matrix[level]
                .firstLevelReferrals
                .push(userAddress);
            emit NewUserPlace(
                userAddress,
                users[referrerAddress].x6Matrix[level].firstLevelReferrals[1],
                2,
                level,
                uint8(
                    users[
                        users[referrerAddress]
                            .x6Matrix[level]
                            .firstLevelReferrals[1]
                    ].x6Matrix[level].firstLevelReferrals.length
                )
            );
            emit NewUserPlace(
                userAddress,
                referrerAddress,
                2,
                level,
                4 +
                    uint8(
                        users[
                            users[referrerAddress]
                                .x6Matrix[level]
                                .firstLevelReferrals[1]
                        ].x6Matrix[level].firstLevelReferrals.length
                    )
            );
            //set current level
            users[userAddress].x6Matrix[level].currentReferrer = users[
                referrerAddress
            ].x6Matrix[level].firstLevelReferrals[1];
        }
    }

    function updateX6ReferrerSecondLevel(
        address userAddress,
        address referrerAddress,
        uint8 level
    ) private {
        if (
            users[referrerAddress].x6Matrix[level].secondLevelReferrals.length <
            4
        ) {
            return sendTokenDividends(referrerAddress, userAddress, 2, level);
        }

        address[] memory x6 = users[
            users[referrerAddress].x6Matrix[level].currentReferrer
        ].x6Matrix[level].firstLevelReferrals;
        // ------- if else -------
        if (x6.length == 2) {
            if (x6[0] == referrerAddress || x6[1] == referrerAddress) {
                users[users[referrerAddress].x6Matrix[level].currentReferrer]
                    .x6Matrix[level]
                    .closedPart = referrerAddress;
            } else if (x6.length == 1) {
                if (x6[0] == referrerAddress) {
                    users[
                        users[referrerAddress].x6Matrix[level].currentReferrer
                    ].x6Matrix[level].closedPart = referrerAddress;
                }
            }
        }

        users[referrerAddress]
            .x6Matrix[level]
            .firstLevelReferrals = new address[](0);
        users[referrerAddress]
            .x6Matrix[level]
            .secondLevelReferrals = new address[](0);
        users[referrerAddress].x6Matrix[level].closedPart = address(0);

        if (
            !users[referrerAddress].activeX6Levels[level + 1] &&
            level != LAST_LEVEL
        ) {
            users[referrerAddress].x6Matrix[level].blocked = true;
        }

        users[referrerAddress].x6Matrix[level].reinvestCount++;

        if (referrerAddress != id1) {
            address freeReferrerAddress = findFreeX6Referrer(
                referrerAddress,
                level
            );

            emit Reinvest(
                referrerAddress,
                freeReferrerAddress,
                userAddress,
                2,
                level
            );
            updateX6Referrer(referrerAddress, freeReferrerAddress, level);
        } else {
            emit Reinvest(id1, address(0), userAddress, 2, level);
            sendTokenDividends(id1, userAddress, 2, level);
        }
    }

    function findFreeX3Referrer(address userAddress, uint8 level)
        public
        view
        returns (address)
    {
        while (true) {
            if (users[users[userAddress].referrer].activeX3Levels[level]) {
                return users[userAddress].referrer;
            }
            userAddress = users[userAddress].referrer;
        }
        return address(0);
    }

    function findFreeX6Referrer(address userAddress, uint8 level)
        public
        view
        returns (address)
    {
        while (true) {
            if (users[users[userAddress].referrer].activeX6Levels[level]) {
                return users[userAddress].referrer;
            }

            userAddress = users[userAddress].referrer;
        }
        return address(0);
    }

    function usersActiveX3Levels(address userAddress, uint8 level)
        public
        view
        returns (bool)
    {
        return users[userAddress].activeX3Levels[level];
    }

    function usersActiveX6Levels(address userAddress, uint8 level)
        public
        view
        returns (bool)
    {
        return users[userAddress].activeX6Levels[level];
    }

    function usersX3Matrix(address userAddress, uint8 level)
        public
        view
        returns (
            address currentReferrer,
            address[] memory referrals,
            bool blocked
        )
    {
        currentReferrer = users[userAddress].x3Matrix[level].currentReferrer;
        referrals = users[userAddress].x3Matrix[level].referrals;
        blocked = users[userAddress].x3Matrix[level].blocked;
    }

    function usersX6Matrix(address userAddress, uint8 level)
        public
        view
        returns (
            address currentReferrer,
            address[] memory firstLevelReferrals,
            address[] memory secondLevelReferrals,
            bool blocked,
            address closedPart
        )
    {
        return (
            currentReferrer = users[userAddress]
                .x6Matrix[level]
                .currentReferrer,
            firstLevelReferrals = users[userAddress]
                .x6Matrix[level]
                .firstLevelReferrals,
            secondLevelReferrals = users[userAddress]
                .x6Matrix[level]
                .secondLevelReferrals,
            blocked = users[userAddress].x6Matrix[level].blocked,
            closedPart = users[userAddress].x6Matrix[level].closedPart
        );
    }

    function isUserExists(address user) public view returns (bool) {
        return (users[user].id != 0);
    }

    function findTokenReceiver(
        address userAddress,
        address _from,
        uint8 matrix,
        uint8 level
    ) private returns (address, bool) {
        address receiver = userAddress;
        bool isExtraDividends;
        if (matrix == 1) {
            while (true) {
                if (users[receiver].x3Matrix[level].blocked) {
                    emit MissedEthReceive(receiver, _from, 1, level);
                    isExtraDividends = true;
                    receiver = users[receiver].x3Matrix[level].currentReferrer;
                } else {
                    return (receiver, isExtraDividends);
                }
            }
        } else {
            while (true) {
                if (users[receiver].x6Matrix[level].blocked) {
                    emit MissedEthReceive(receiver, _from, 2, level);
                    isExtraDividends = true;
                    receiver = users[receiver].x6Matrix[level].currentReferrer;
                } else {
                    return (receiver, isExtraDividends);
                }
            }
        }
        return (address(0), false);
    }

    function sendTokenDividends(
        address userAddress,
        address _from,
        uint8 matrix,
        uint8 level
    ) private {
        (address receiver, bool isExtraDividends) = findTokenReceiver(
            userAddress,
            _from,
            matrix,
            level
        );
        depositToken.safeTransfer(
            receiver,
            (levelPrice[level] * uplineShare) / 100e18
        );

        if (isExtraDividends) {
            emit SentExtraEthDividends(_from, receiver, matrix, level);
        }
        emit UplineShares(
            _from,
            receiver,
            matrix,
            level,
            (levelPrice[level] * uplineShare) / 100e18
        );
    }

    function bytesToAddress(bytes memory bys)
        private
        pure
        returns (address addr)
    {
        assembly {
            addr := mload(add(bys, 20))
        }
    }

    function retrieve(
        address _token,
        address to,
        uint256 amount
    ) external onlyContractOwner {
        require(amount > 0, "!value");
        if (_token == address(0)) {
            require(address(this).balance >= amount, "!Bal");
            require(payable(to).send(amount), "TxnFail!");
        } else {
            require(amount >= IBEP20(_token).balanceOf(address(this)), "!bal");
            IBEP20(_token).safeTransfer(to, amount);
        }
        emit Retrieve(_token, to, amount, block.timestamp);
    }
}