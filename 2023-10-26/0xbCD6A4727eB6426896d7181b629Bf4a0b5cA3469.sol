/*
$$$$$$$$\                  $$\             $$\     $$\                             $$$$$$$\  $$\                                $$\
$$  _____|                 $$ |            $$ |    \__|                            $$  __$$\ $$ |                               $$ |
$$ |  $$\    $$\  $$$$$$\  $$ |$$\   $$\ $$$$$$\   $$\  $$$$$$\  $$$$$$$\          $$ |  $$ |$$ | $$$$$$\  $$$$$$$\   $$$$$$\ $$$$$$\    $$$$$$$\
$$$$$\\$$\  $$  |$$  __$$\ $$ |$$ |  $$ |\_$$  _|  $$ |$$  __$$\ $$  __$$\ $$$$$$\ $$$$$$$  |$$ | \____$$\ $$  __$$\ $$  __$$\\_$$  _|  $$  _____|
$$  __|\$$\$$  / $$ /  $$ |$$ |$$ |  $$ |  $$ |    $$ |$$ /  $$ |$$ |  $$ |\______|$$  ____/ $$ | $$$$$$$ |$$ |  $$ |$$$$$$$$ | $$ |    \$$$$$$\
$$ |    \$$$  /  $$ |  $$ |$$ |$$ |  $$ |  $$ |$$\ $$ |$$ |  $$ |$$ |  $$ |        $$ |      $$ |$$  __$$ |$$ |  $$ |$$   ____| $$ |$$\  \____$$\
$$$$$$$$\\$  /   \$$$$$$  |$$ |\$$$$$$  |  \$$$$  |$$ |\$$$$$$  |$$ |  $$ |        $$ |      $$ |\$$$$$$$ |$$ |  $$ |\$$$$$$$\  \$$$$  |$$$$$$$  |
\________|\_/     \______/ \__| \______/    \____/ \__| \______/ \__|  \__|        \__|      \__| \_______|\__|  \__| \_______|  \____/ \_______/
*/

// SPDX-License-Identifier: MIT

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
     *
     * [IMPORTANT]
     * ====
     * You shouldn't rely on `isContract` to protect against flash loan attacks!
     *
     * Preventing calls from contracts is highly discouraged. It breaks composability, breaks support for smart wallets
     * like Gnosis Safe, and does not provide security since it can be circumvented by calling from a contract
     * constructor.
     * ====
     */
    function isContract(address account) internal view returns (bool) {
        // This method relies on extcodesize/address.code.length, which returns 0
        // for contracts in construction, since the code is only stored at the end
        // of the constructor execution.

        return account.code.length > 0;
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
    constructor(address initialOwner) {
        require(initialOwner != address(0), "Zero address initial owner not allowed");
        _transferOwnership(initialOwner);
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

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IERC20 {
   /**
     * @dev Returns the name of the token.
     */
    function name() external view returns (string memory);

    /**
     * @dev Returns the symbol of the token.
     */
    function symbol() external view returns (string memory);

    /**
     * @dev Returns the decimals places of the token.
     */
    function decimals() external view returns (uint8);

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

/**
 * @title SafeERC20
 * @dev Wrappers around ERC20 operations that throw on failure (when the token
 * contract returns false). Tokens that return no value (and instead revert or
 * throw on failure) are also supported, non-reverting calls are assumed to be
 * successful.
 * To use this library you can add a `using SafeERC20 for IERC20;` statement to your contract,
 * which allows you to call the safe operations as `token.safeTransfer(...)`, etc.
 */
library SafeERC20 {
    using Address for address;

    function safeTransfer(
        IERC20 token,
        address to,
        uint256 value
    ) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function safeTransferFrom(
        IERC20 token,
        address from,
        address to,
        uint256 value
    ) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }

    /**
     * @dev Deprecated. This function has issues similar to the ones found in
     * {IERC20-approve}, and its usage is discouraged.
     *
     * Whenever possible, use {safeIncreaseAllowance} and
     * {safeDecreaseAllowance} instead.
     */
    function safeApprove(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {
        // safeApprove should only be called when setting an initial allowance,
        // or when resetting it to zero. To increase and decrease it, use
        // 'safeIncreaseAllowance' and 'safeDecreaseAllowance'
        require(
            (value == 0) || (token.allowance(address(this), spender) == 0),
            "SafeERC20: approve from non-zero to non-zero allowance"
        );
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
    }

    function safeIncreaseAllowance(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {
        uint256 newAllowance = token.allowance(address(this), spender) + value;
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function safeDecreaseAllowance(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {
        unchecked {
            uint256 oldAllowance = token.allowance(address(this), spender);
            require(oldAllowance >= value, "SafeERC20: decreased allowance below zero");
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
    function _callOptionalReturn(IERC20 token, bytes memory data) private {
        // We need to perform a low level call here, to bypass Solidity's return data size checking mechanism, since
        // we're implementing it ourselves. We use {Address.functionCall} to perform this call, which verifies that
        // the target address contains contract code and also asserts for success in the low-level call.

        bytes memory returndata = address(token).functionCall(data, "SafeERC20: low-level call failed");
        if (returndata.length > 0) {
            // Return data is optional
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
}

interface AggregatorV3Interface {
  function decimals() external view returns (uint8);

  function description() external view returns (string memory);

  function version() external view returns (uint256);

  // getRoundData and latestRoundData should both raise "No data present"
  // if they do not have data to report, instead of returning unset values
  // which could be misinterpreted as actual reported values.
  function getRoundData(uint80 _roundId)
    external
    view
    returns (
      uint80 roundId,
      int256 answer,
      uint256 startedAt,
      uint256 updatedAt,
      uint80 answeredInRound
    );

  function latestRoundData()
    external
    view
    returns (
      uint80 roundId,
      int256 answer,
      uint256 startedAt,
      uint256 updatedAt,
      uint80 answeredInRound
    );
}

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

contract EvolutionPlanets is Ownable, ReentrancyGuard {
    using Address for address;
    using SafeERC20 for IERC20;

    struct User {
        uint256 partnerId;
        uint64 refCount;
        uint32 regDate;
        address payable wallet;
        uint256 totalEarned;
        uint256 totalLost;
        uint256 place;
        uint8 row;
        uint8 lastRow;
        mapping(uint8 => uint256[]) smallMatrix;
        mapping(uint8 => bool) levelActive;
        mapping(uint8 => uint256) reinvests;
        mapping(uint8 => uint256) earned;
    }

    mapping (address => uint256) public userIds;
    mapping (uint256 => User) public users;
    mapping (uint256 => uint256) public placeToUserId;

    mapping (uint8 => uint256[4]) private payments;

    mapping(uint8 => uint256) private lastFreePlaceInRow;

    mapping(uint8 => uint256) public matrixPool;

    mapping(uint8 => uint256) public maxMatrixPool;

    mapping(uint8 => bool) private levelIsActive;

    uint8 private immutable MAX_ROW = 161;

    uint256 public lastUserId = 1;

    uint256[] public ticketsBought;

    uint256 public maxTickets = 30;

    uint256 public ticketPrice = 300;

    uint256 public nonce;

    uint256 public unclaimed;

    uint256 public lotteryPool;

    uint256 public lotteryWinners = 1;

    uint256 public planetWinners = 1;

    uint256 public planetsPoolMaxAmount = 100000;

    uint256 public planetsPool;

    IERC20 public EPTToken = IERC20(0x035827910e7E599f0b3b2Ff44a8a33A15CdB00e8);

    address private priceFeed = 0x0567F2323251f0Aab15c8dFb1967E4e8A7D42aeE;

    address private lotteryCaller = 0x1d27512724f994c90cA5cfaA2DeF14E5a159923B;

    event Register(uint256 userId, address indexed wallet, uint256 refId, uint256 date);
    event TopWalletChanged(address indexed account);
    event LevelActivated(uint256 userId, uint8 level);
    event Reinvest(uint256 from, uint256 to, uint8 level, uint256 amount);
    event LostProfit(uint256 from, uint256 to, uint8 level, uint256 amount, uint256 rows);
    event OverProfit(uint256 from, uint256 to, uint8 level, uint256 amount, uint256 rows);
    event LevelBonus(uint256 from, uint256 to, uint8 level, uint256 amount);
    event PlanetBonus(uint256 from, uint256 to, uint8 level, uint256 amount);
    event MatrixBonus(uint userId, uint8 level, uint amount);
    event NinePlanetsBonus(uint userId, uint amount);
    event LotteryBonus(uint userId, uint amount);
    event UserPlaced(uint256 placeId, uint8 lastRow);
    event PlanetPoolIsFull();
    event AllTicketsAreBought();


    constructor(address initialOwner,
                address payable topUser) Ownable(initialOwner)
    {
        payments[1] = [2500, 1000, 250, 125];
        payments[2] = [5000, 2000, 500, 250];
        payments[3] = [7500, 3000, 750, 375];
        payments[4] = [10000, 4000, 1000, 500];
        payments[5] = [20000, 8000, 2000, 1000];
        payments[6] = [30000, 12000, 3000, 1500];
        payments[7] = [60000, 25000, 5000, 2500];
        payments[8] = [90000, 35000, 10000, 5000];
        payments[9] = [120000, 45000, 15000, 7500];
        maxMatrixPool[1] = 2500;
        maxMatrixPool[2] = 5000;
        maxMatrixPool[3] = 7500;
        maxMatrixPool[4] = 10000;
        maxMatrixPool[5] = 20000;
        maxMatrixPool[6] = 30000;
        maxMatrixPool[7] = 50000;
        maxMatrixPool[8] = 100000;
        maxMatrixPool[9] = 150000;
        User storage u = users[1];
        u.wallet = topUser;
        u.regDate = uint32(block.timestamp);
        u.partnerId = 1;
        u.place = 1;
        u.row = 1;
        u.lastRow = 2;
        userIds[topUser] = 1;
        placeToUserId[1] = 1;
        emit Register(1, topUser, 1, block.timestamp);
        emit UserPlaced(1,1);
        for (uint8 i = 1; i < 10; i++) {
            u.levelActive[i] = true;
            lastFreePlaceInRow[1] = 2;
            emit LevelActivated(1, i);
        }
    }

    function max(uint256 a, uint256 b) internal pure returns (uint256) {
        return a >= b ? a : b;
    }

    function getRate() public view returns (uint256) {
        ( , int256 basePrice, , , ) = AggregatorV3Interface(priceFeed).latestRoundData();
        return uint256(basePrice);
    }


    function usdToBNB(uint256 amount) public view returns(uint256) {
        uint256 rate = getRate();
        return uint256(amount) * 10 ** 24 / rate;
    }


    function isRegistered(uint256 userId) public view returns(bool) {
        return users[userId].wallet != address(0);

    }

    function isRegistered(address account) public view returns(bool) {
        return userIds[account] > 0;
    }


    function hasLevels(uint256 userId) public view returns(
                                                            bool[] memory,
                                                            uint256[] memory,
                                                            uint256[] memory
                                                            )
    {
        bool[] memory levels = new bool[](9);
        uint256[] memory reinvests = new uint256[](9);
        uint256[] memory income = new uint256[](9);
        for (uint8 i = 1; i<10;i++) {
            levels[i-1] = users[userId].levelActive[i];
            reinvests[i-1] = users[userId].reinvests[i];
            income[i-1] = users[userId].earned[i];

        }
        return (levels, reinvests, income);
    }


    function getLevelPrices() public view returns (uint256[] memory) {
        uint256[] memory result = new uint256[](9);
        for (uint8 i=1; i<10;i++) {
            result[i-1] = payments[i][0];
        }
        return result;
    }


    function getUplinePlaceId(uint256 placeId) internal pure returns (uint256) {
        if (placeId % 3 == 2) {
            return placeId / 3 + 1;
        } else {
            return placeId / 3;
        }
    }


    function findFreePlaceId(uint256 refId) internal view returns(
                                                                    uint256,  // placeId
                                                                    uint256, // lastFreePlaceInRow
                                                                    uint8 // userLastRow
                                                                )
    {
        uint256 placeId = users[refId].place;
        uint8 row = users[refId].row;
        uint8 i = users[refId].lastRow - row;
        uint256 start;
        uint256 end;
        while (true) {
            if (row + i > MAX_ROW) break;
            start = placeId * 3 ** i - (3 ** i / 2);
            end = start + 3 ** i - 1;
            if (lastFreePlaceInRow[row+i] > end) {
                i++;
                continue;
            }
            for (uint256 j=max(start, lastFreePlaceInRow[row+i]); j<=end; j++) {
                if (placeToUserId[j] == 0) {
                    if (j == start && lastFreePlaceInRow[row+i] == 0) {
                        return (j, j + 1, row + i);
                    } else if (start > lastFreePlaceInRow[row+i]) {
                        return (j, lastFreePlaceInRow[row+i], row + i);
                    } else {
                        return (j, j + 1, row + i);
                    }
                }
            }
            i++;
        }
        return (0, 0, 0);
    }

    function registerUser(address wallet, uint256 refId) internal returns (uint256){
        lastUserId++;
        User storage u = users[lastUserId];
        u.wallet = payable(wallet);
        u.regDate = uint32(block.timestamp);
        u.partnerId = refId;
        userIds[wallet] = lastUserId;
        users[refId].refCount += 1;
        emit Register(lastUserId, wallet, refId, block.timestamp);
        return lastUserId;
    }


    function buyPlanet(uint256 partnerId, uint8 level) public payable nonReentrant {
        require(!_msgSender().isContract(), "Only EOA accounts allowed");
        require(users[partnerId].wallet != address(0), "Invalid partner ID");
        require(level > 0 && level < 10, "Invalid level");
        require(levelIsActive[level], "Level is not active");
        require(msg.value >= usdToBNB(payments[level][0]), "Invalid BNB amount");
        require(!users[userIds[_msgSender()]].levelActive[level],
                "User already has this level");
        uint256 userId;
        if (userIds[_msgSender()] == 0) {
            userId = registerUser(_msgSender(), partnerId);
        } else {
            userId = userIds[_msgSender()];
            partnerId = users[userId].partnerId;
        }
        users[userId].levelActive[level] = true;
        emit LevelActivated(userId, level);
        matrixPool[level] += usdToBNB(payments[level][2]);
        if (matrixPool[level] >= usdToBNB(maxMatrixPool[level])) {
            (bool sent, ) = users[userId].wallet.call{
                                                        value: matrixPool[level] / 2,
                                                        gas: 50000
                                                    }("");
            require(sent, "Failed to send BNB");
            users[userId].totalEarned += matrixPool[level] / 2;
            users[userId].earned[level] += matrixPool[level] / 2;
            emit MatrixBonus(userId, level, matrixPool[level] / 2);
            (sent, ) = users[partnerId].wallet.call{
                                                        value: matrixPool[level] / 2,
                                                        gas: 50000
                                                    }("");
            require(sent, "Failed to send BNB");
            users[partnerId].earned[level] += matrixPool[level] / 2;
            users[partnerId].totalEarned += matrixPool[level] / 2;
            emit MatrixBonus(partnerId, level, matrixPool[level] / 2);
            matrixPool[level] = 0;
        }
        planetsPool += usdToBNB(payments[level][3]);
        if (planetsPool >= usdToBNB(planetsPoolMaxAmount)) {
            emit PlanetPoolIsFull();
        }
        lotteryPool += usdToBNB(payments[level][3]);
        placeToSmallMatrix(userId, partnerId, level);
        placeToBigMatrix(userId, partnerId, level);

    }


    function findUpline(uint256 refId, uint8 level) internal view returns (uint256 result) {
        for (uint i = 0; i < 3; i++) {
            if (users[refId].levelActive[level]) {
                result = refId;
                break;
            } else if (i==2) {
                result = 1;
                break;
            }
            refId = users[refId].partnerId;
        }
    }


    function placeToSmallMatrix(uint256 userId, uint256 refId, uint8 level) internal {
        uint8 maxMembers;
        uint256 putId;
        uint256 payId;
        uint amount = usdToBNB(payments[level][1]);
        if (level < 4 || level > 6) {
            maxMembers = 3;
        } else {
            maxMembers = 6;
        }
        putId = findUpline(refId, level);
        users[putId].smallMatrix[level].push(userId);
        EPTToken.safeTransfer(users[userId].wallet, payments[level][0] * 10 ** 16);
        if (users[putId].smallMatrix[level].length == maxMembers) {
            delete users[putId].smallMatrix[level];
            EPTToken.safeTransfer(users[putId].wallet, payments[level][0] * 10 ** 16);
            users[putId].reinvests[level] += 1;
            payId = findUpline(users[putId].partnerId, level);
            if (payId != users[putId].partnerId) {
                emit OverProfit(putId, payId, level, amount, 1);
                emit LostProfit(putId, users[putId].partnerId, level, amount, 1);
                users[users[putId].partnerId].totalLost += amount;
            } else {
                emit Reinvest(putId, payId, level, amount);
            }
        } else {
            payId = putId;
            if (payId != refId) {
                emit OverProfit(userId, payId, level, amount, 1);
                emit LostProfit(userId, refId, level, amount, 1);
                users[refId].totalLost += amount;
            } else {
                emit PlanetBonus(userId, payId, level, amount);
            }

        }
        (bool sent, ) = users[payId].wallet.call{
                                                    value: amount,
                                                    gas: 50000
                                                }("");
        require(sent, "Failed to send BNB");
        users[payId].totalEarned += amount;
        users[payId].earned[level] += amount;
    }


    function placeToBigMatrix(uint256 userId, uint256 refId, uint8 level) internal {
        if (users[userId].place == 0) {
            (uint256 placeId, uint256 newLastPlaceInRow, uint8 lastRow) = findFreePlaceId(refId);
            require(placeId > 0, "No free space left in matrix");
            if (users[refId].lastRow < lastRow) {
                users[refId].lastRow = lastRow;
            }
            if (newLastPlaceInRow > lastFreePlaceInRow[lastRow]) {
                lastFreePlaceInRow[lastRow] = newLastPlaceInRow;
            }
            placeToUserId[placeId] = userId;
            users[userId].place = placeId;
            users[userId].row = lastRow;
            users[userId].lastRow = lastRow + 1;
            emit UserPlaced(placeId, lastRow);
            sendPayments(userId, level, placeId, lastRow);
        } else {
            sendPayments(userId, level, users[userId].place, users[userId].row);
        }

    }


    function sendPayments(uint256 userId,
                           uint8 level,
                           uint256 placeId, uint256 row) internal {
        uint256 part = usdToBNB(payments[level][1]) / 9;
        uint256 amount;
        if (row < 10) {
            unclaimed = unclaimed + (10 - row) * part;
        }
        bool sent;
        for (uint i = 0;i < 9; i++) {
            placeId = getUplinePlaceId(placeId);
            if (placeId <= 1) {
                amount += part * (9 - i);
                break;
            }
            amount += part;
            if (!users[placeToUserId[placeId]].levelActive[level]) {
                users[placeToUserId[placeId]].totalLost += amount;
                emit LostProfit(userId, placeToUserId[placeId], level, amount, amount/part);
                continue;
            } else {
                (sent, ) = users[placeToUserId[placeId]].wallet.call{
                                                        value: amount,
                                                        gas: 50000
                                                    }("");
                require(sent, "Failed to send BNB");
                users[placeToUserId[placeId]].totalEarned += amount;
                users[placeToUserId[placeId]].earned[level] += amount;
                emit LevelBonus(userId, placeToUserId[placeId], level, amount);
                if (amount > part) {
                    emit OverProfit(userId,
                                    placeToUserId[placeId],
                                    level,
                                    amount-part,
                                    (amount-part)/part);
                }
                amount = 0;
            }
        }
        if (amount > 0) {
            (sent, ) = users[1].wallet.call{
                                                    value: amount,
                                                    gas: 50000
                                            }("");
            require(sent, "Failed to send BNB");
            users[1].earned[level] += amount;
            users[1].totalEarned += amount;
            emit LevelBonus(userId, 1, level, amount);
            if (amount > part) {
                emit OverProfit(userId, 1, level, amount-part, (amount-part)/part);
            }

        }
    }

    function checkTickets(uint256 userId) internal view returns (bool) {
        for (uint i = 0;i < ticketsBought.length; i++) {
            if (ticketsBought[i] == userId) return true;
        }
        return false;
    }


    function buyTicket() external payable {
        require(msg.value >= usdToBNB(ticketPrice), "Invalid BNB amount");
        require(ticketsBought.length < maxTickets, "All tickets are bought");
        require (userIds[_msgSender()] > 0, "User is not registered");
        require(!checkTickets(userIds[_msgSender()]), "User already has bought a ticket");
        lotteryPool += msg.value;
        ticketsBought.push(userIds[_msgSender()]);
        if (ticketsBought.length == maxTickets) {
            emit AllTicketsAreBought();
        }
    }

    function runPlanetsPool(uint256[] calldata accounts) external {
        require(_msgSender() == lotteryCaller, "Unauthorized caller");
        require(planetsPool >= usdToBNB(planetsPoolMaxAmount),
                                        "Planet's pool is not full");
        bool sent;
        uint256 amount = planetsPool / accounts.length;
        for (uint i = 0;i < accounts.length; i++) {
                (sent, ) = users[accounts[i]].wallet.call{
                                                        value: amount,
                                                        gas: 50000
                                                    }("");
                require(sent, "Failed to send BNB");
                users[accounts[i]].totalEarned += amount;
                emit NinePlanetsBonus(accounts[i], amount);
        }
        planetsPool = 0;
    }

    function runLottery(uint256[] calldata accounts) external {
        require(_msgSender() == lotteryCaller, "Unauthorized caller");
        require(ticketsBought.length == maxTickets, "Not all tickets are bought");
        bool sent;
        uint256 amount = lotteryPool / accounts.length;
        for (uint i = 0;i < accounts.length; i++) {
                (sent, ) = users[accounts[i]].wallet.call{
                                                        value: amount,
                                                        gas: 50000
                                                    }("");
                require(sent, "Failed to send BNB");
                users[accounts[i]].totalEarned += amount;
                emit LotteryBonus(accounts[i], amount);
        }
        lotteryPool = 0;
        delete ticketsBought;
    }


    function changeTopUser(address account) public onlyOwner {
        require(account != address(0), "Zero account is not allowed");
        address oldWallet = users[1].wallet;
        users[1].wallet = payable(account);
        userIds[account] = 1;
        delete userIds[oldWallet];
        emit TopWalletChanged(account);
    }


    function retriveBNB(address payable to, uint256 amount) external onlyOwner {
        require(to != address(0), "Zero address prohibited");
        uint256 contractBalance = address(this).balance;
        require(amount <= contractBalance, "Insufficient contract BNB balance");
        to.transfer(amount);
    }

    function setMaxMatrixPool(uint8 level, uint256 amount) external onlyOwner {
        require(level > 0 && level < 10, "Invalid level");
        require(amount > 0, "Zero amount not allowed");
        maxMatrixPool[level] = amount;
    }

    function setMaxPlanetsPool(uint256 amount) external onlyOwner {
        require(amount > 0, "Zero amount not allowed");
        planetsPoolMaxAmount = amount;
    }

    function setTicketPrice(uint256 amount) external onlyOwner {
        require(amount > 0, "Zero amount not allowed");
        ticketPrice = amount;
    }

    function setMaxTickets(uint256 tickets) external onlyOwner {
        require(tickets > 0, "Zero amount not allowed");
        maxTickets = tickets;
    }

    function setPriceFeed(address _feed) external onlyOwner {
        require(_feed != address(0), "Zero address not allowed");
        priceFeed = _feed;
    }

    function setLotteryCaller(address _caller) external onlyOwner {
        require(_caller != address(0), "Zero address not allowed");
        lotteryCaller = _caller;
    }

    function setLotteryWinnersNumber(uint256 winners) external onlyOwner {
        require((winners > 0 && winners <= maxTickets) , "Invalid number of winners");
        lotteryWinners = winners;
    }

    function setPlanetWinnersNumber(uint256 winners) external onlyOwner {
        require(winners > 0, "Invalid number of winners");
        planetWinners = winners;
    }


    function updateNonce(uint256 _nonce) external onlyOwner {
        nonce = _nonce;
    }


    function setEPTToken(address _token) external onlyOwner {
        require(_token != address(0), "Zero address not allowed");
        EPTToken = IERC20(_token);
    }

    function getNinePlanetsData() public view returns (
                                                       uint256, // current pool,
                                                       uint256, // required pool
                                                       uint256, //winners
                                                       uint256 //nonce
                                                    )
    {
        return (planetsPool, usdToBNB(planetsPoolMaxAmount), planetWinners, nonce);
    }

    function getLotteryData() public view returns (uint256[] memory, // tickets bought
                                                   uint256, // tickets required
                                                   uint256, // ticket price
                                                   uint256, // pool amount
                                                   uint256 // lottery winners
                                                   )

    {
        return (
                    ticketsBought,
                    maxTickets,
                    usdToBNB(ticketPrice),
                    lotteryPool,
                    lotteryWinners
                );
    }


    function getUserData(uint256 userId) public view returns (
                                                                uint256, //partnerId
                                                                address, //wallet,
                                                                uint256, //refCount
                                                                uint256, //earned
                                                                uint256 //lost,

                                                                )
    {
        return (users[userId].partnerId, users[userId].wallet,
                users[userId].refCount,
                users[userId].totalEarned, users[userId].totalLost);
    }

    function getUserData(address account) public view returns (
                                                                uint256, //userId
                                                                uint256, //partnerId
                                                                address, //wallet,
                                                                uint256, //refCount
                                                                uint256, //earned
                                                                uint256 //lost,
                                                                )
    {

        return (userIds[account], users[userIds[account]].partnerId,
                users[userIds[account]].wallet, users[userIds[account]].refCount,
                users[userIds[account]].totalEarned, users[userIds[account]].totalLost);
    }


    function getMatrixPools() public view returns (uint256[] memory) {
        uint256[] memory result = new uint256[](9);
        for (uint8 i=1; i<10;i++) {
            result[i-1] = usdToBNB(maxMatrixPool[i]) - matrixPool[i];
        }
        return result;
    }


    function getSmallMatrices(uint256 userId) public view returns (uint256[] memory) {
        uint8 maxMembers;
        uint256[] memory result = new uint256[](36);
        uint8 count = 0;
        for (uint8 i = 1; i < 10; i++) {
            if (i < 4 || i > 6) {
                maxMembers = 3;
            } else {
                maxMembers = 6;
            }
            for (uint8 j = 0; j < max(maxMembers, users[userId].smallMatrix[i].length); j++) {
                if (j < users[userId].smallMatrix[i].length) {
                    result[count] = users[userId].smallMatrix[i][j];
                } else {
                    result[count] = 0;
                }
                count++;
            }
        }
        return result;
    }

    function ownerWithdrawToken(uint256 amount, address recepient) public onlyOwner {
        require((recepient != address(0) && amount != 0), "Zero values are not allowed");
        uint256 balance = EPTToken.balanceOf(address(this));
        require(balance >= amount,"Insufficient EPT token balance on contract");
        EPTToken.safeTransfer(recepient, amount);
    }


    function getActivePlanets() public view returns (bool[] memory) {
        bool[] memory result = new bool[](9);
        for (uint8 i=1; i<10; i++) {
            result[i-1] = levelIsActive[i];
        }
        return result;
    }

    function togglePlanets(uint8[] memory planets, bool status) public onlyOwner {
        for (uint8 i = 0; i < planets.length; i++) {
            if (planets[i] > 0 && planets[i] < 10) {
                levelIsActive[planets[i]] = status;
            }
        }
    }

}