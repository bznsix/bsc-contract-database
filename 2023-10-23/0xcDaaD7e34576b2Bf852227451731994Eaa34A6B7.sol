// File: @chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol

pragma solidity ^0.8.0;

interface AggregatorV3Interface {
    function decimals() external view returns (uint8);

    function description() external view returns (string memory);

    function version() external view returns (uint256);

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

// File: @openzeppelin/contracts/security/ReentrancyGuard.sol

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

// File: @openzeppelin/contracts/utils/Context.sol

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

// File: @openzeppelin/contracts/access/Ownable.sol

// OpenZeppelin Contracts (last updated v4.9.0) (access/Ownable.sol)

pragma solidity ^0.8.0;

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

    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );

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
        require(
            newOwner != address(0),
            "Ownable: new owner is the zero address"
        );
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

// File: @openzeppelin/contracts/utils/Address.sol

// OpenZeppelin Contracts (last updated v4.9.0) (utils/Address.sol)

pragma solidity ^0.8.1;

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
     *
     * Furthermore, `isContract` will also return true if the target contract within
     * the same transaction is already scheduled for destruction by `SELFDESTRUCT`,
     * which only has an effect at the end of a transaction.
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
     * https://consensys.net/diligence/blog/2019/09/stop-using-soliditys-transfer-now/[Learn more].
     *
     * IMPORTANT: because control is transferred to `recipient`, care must be
     * taken to not create reentrancy vulnerabilities. Consider using
     * {ReentrancyGuard} or the
     * https://solidity.readthedocs.io/en/v0.8.0/security-considerations.html#use-the-checks-effects-interactions-pattern[checks-effects-interactions pattern].
     */
    function sendValue(address payable recipient, uint256 amount) internal {
        require(
            address(this).balance >= amount,
            "Address: insufficient balance"
        );

        (bool success, ) = recipient.call{value: amount}("");
        require(
            success,
            "Address: unable to send value, recipient may have reverted"
        );
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
    function functionCall(address target, bytes memory data)
        internal
        returns (bytes memory)
    {
        return
            functionCallWithValue(
                target,
                data,
                0,
                "Address: low-level call failed"
            );
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
        (bool success, bytes memory returndata) = target.call{value: value}(
            data
        );
        return
            verifyCallResultFromTarget(
                target,
                success,
                returndata,
                errorMessage
            );
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but performing a static call.
     *
     * _Available since v3.3._
     */
    function functionStaticCall(address target, bytes memory data)
        internal
        view
        returns (bytes memory)
    {
        return
            functionStaticCall(
                target,
                data,
                "Address: low-level static call failed"
            );
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
        (bool success, bytes memory returndata) = target.staticcall(data);
        return
            verifyCallResultFromTarget(
                target,
                success,
                returndata,
                errorMessage
            );
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but performing a delegate call.
     *
     * _Available since v3.4._
     */
    function functionDelegateCall(address target, bytes memory data)
        internal
        returns (bytes memory)
    {
        return
            functionDelegateCall(
                target,
                data,
                "Address: low-level delegate call failed"
            );
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
        (bool success, bytes memory returndata) = target.delegatecall(data);
        return
            verifyCallResultFromTarget(
                target,
                success,
                returndata,
                errorMessage
            );
    }

    /**
     * @dev Tool to verify that a low level call to smart-contract was successful, and revert (either by bubbling
     * the revert reason or using the provided one) in case of unsuccessful call or if target was not a contract.
     *
     * _Available since v4.8._
     */
    function verifyCallResultFromTarget(
        address target,
        bool success,
        bytes memory returndata,
        string memory errorMessage
    ) internal view returns (bytes memory) {
        if (success) {
            if (returndata.length == 0) {
                // only check isContract if the call was successful and the return data is empty
                // otherwise we already know that it was a contract
                require(isContract(target), "Address: call to non-contract");
            }
            return returndata;
        } else {
            _revert(returndata, errorMessage);
        }
    }

    /**
     * @dev Tool to verify that a low level call was successful, and revert if it wasn't, either by bubbling the
     * revert reason or using the provided one.
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
            _revert(returndata, errorMessage);
        }
    }

    function _revert(bytes memory returndata, string memory errorMessage)
        private
        pure
    {
        // Look for revert reason and bubble it up if present
        if (returndata.length > 0) {
            // The easiest way to bubble the revert reason is using memory via assembly
            /// @solidity memory-safe-assembly
            assembly {
                let returndata_size := mload(returndata)
                revert(add(32, returndata), returndata_size)
            }
        } else {
            revert(errorMessage);
        }
    }
}

// File: @openzeppelin/contracts/token/ERC20/IERC20.sol

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
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );

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

// File: newLaunchpadd.sol

pragma solidity >=0.8.0 <0.9.0;

contract MaxiRuby is ReentrancyGuard, Ownable {
    uint256 public presaleId;
    uint256 public BASE_MULTIPLIER;
    uint256 public MONTH;
    uint256 public totalBnbReceivedInAllTier;
    uint256 public totalBnbInTierOne;
    uint256 public totalBnbInTierTwo;
    uint256 public totalBnbInTierThree;
    uint256 public totalBnbInTierFour;
    uint256 public totalBnbInTierFive;
    uint256 public totalparticipants;
    address payable public projectOwner;
    uint256 public tierOneMaxCap;
    uint256 public tierTwoMaxCap;
    uint256 public tierThreeMaxCap;
    uint256 public tierFourMaxCap;
    uint256 public tierFiveMaxCap;
    uint256 public totalUserInTierOne;
    uint256 public totalUserInTierTwo;
    uint256 public totalUserInTierThree;
    uint256 public totalUserInTierFour;
    uint256 public totalUserInTierFive;
    address[] private whitelistTierOne;
    address[] private whitelistTierTwo;
    address[] private whitelistTierThree;
    address[] private whitelistTierFour;
    address[] private whitelistTierFive;
    mapping(address => uint256) public buyInOneTier;
    mapping(address => uint256) public buyInTwoTier;
    mapping(address => uint256) public buyInThreeTier;
    mapping(address => uint256) public buyInFourTier;
    mapping(address => uint256) public buyInFiveTier;
    mapping(address => uint256) public minBuyInOneTier;
    mapping(address => uint256) public minBuyInTwoTier;
    mapping(address => uint256) public minBuyInThreeTier;
    mapping(address => uint256) public minBuyInFourTier;
    mapping(address => uint256) public minBuyInFiveTier;

    struct Presale {
        address saleToken;
        uint256 startTime;
        uint256 endTime;
        uint256 price;
        uint256 tokensToSell;
        uint256 baseDecimals;
        uint256 inSale;
        uint256 vestingStartTime;
        uint256 vestingCliff;
        uint256 vestingPeriod;
        uint256 enableBuyWithEth;
        uint256 enableBuyWithUsdt;
        bool whitelistEnabled;
    }

    struct Vesting {
        uint256 totalAmount;
        uint256 claimedAmount;
        uint256 claimStart;
        uint256 claimEnd;
    }

    IERC20 public USDTInterface;
    AggregatorV3Interface internal aggregatorInterface;

    mapping(uint256 => bool) public paused;
    mapping(uint256 => Presale) public presale;
    mapping(address => mapping(uint256 => Vesting)) public userVesting;
    // Mapping for minimum allocation per user in a tier
    mapping(uint256 => uint256) public minAllocaPerUserTier;

    // Mapping for maximum allocation per user in a tier
    mapping(uint256 => uint256) public maxAllocaPerUserTier;

    event PresaleCreated(
        uint256 indexed _id,
        uint256 _totalTokens,
        uint256 _startTime,
        uint256 _endTime,
        uint256 enableBuyWithEth,
        uint256 enableBuyWithUsdt,
        bool whitelistEnabled
    );

    event PresaleUpdated(
        bytes32 indexed key,
        uint256 prevValue,
        uint256 newValue,
        uint256 timestamp
    );

    event TokensBought(
        address indexed user,
        uint256 indexed id,
        address indexed purchaseToken,
        uint256 tokensBought,
        uint256 amountPaid,
        uint256 timestamp
    );

    event TokensClaimed(
        address indexed user,
        uint256 indexed id,
        uint256 amount,
        uint256 timestamp
    );

    event PresaleTokenAddressUpdated(
        address indexed prevValue,
        address indexed newValue,
        uint256 timestamp
    );

    //Modifier

    modifier checkUserTier(uint256 amount) {
        uint256 userTier = getUserTier(msg.sender);

        if (userTier > 0) {
            uint256 userTierAllocation;
            if (userTier == 1) userTierAllocation = buyInOneTier[msg.sender];
            else if (userTier == 2)
                userTierAllocation = buyInTwoTier[msg.sender];
            else if (userTier == 3)
                userTierAllocation = buyInThreeTier[msg.sender];
            else if (userTier == 4)
                userTierAllocation = buyInFourTier[msg.sender];
            else if (userTier == 5)
                userTierAllocation = buyInFiveTier[msg.sender];

            require(
                userTierAllocation + amount <= maxAllocaPerUserTier[userTier],
                "Exceeds tier allocation"
            );
        }

        _;
    }

    modifier checkPresaleId(uint256 _id) {
        require(_id > 0 && _id <= presaleId, "Invalid presale id");
        _;
    }

    modifier checkSaleState(uint256 _id, uint256 amount) {
        require(
            block.timestamp >= presale[_id].startTime &&
                block.timestamp <= presale[_id].endTime,
            "Invalid time for buying"
        );
        require(
            amount > 0 && amount <= presale[_id].inSale,
            "Invalid sale amount"
        );
        _;
    }

    event PresalePaused(uint256 indexed id, uint256 timestamp);
    event PresaleUnpaused(uint256 indexed id, uint256 timestamp);

    constructor() {
        address _oracle = 0x1A26d803C2e796601794f8C5609549643832702C;
        address _usdt = 0x90e650225178dc0dDd49ad238FDF4CA2CCFE6f25;
        require(_oracle != address(0), "Zero aggregator address");
        require(_usdt != address(0), "Zero USDT address");

        aggregatorInterface = AggregatorV3Interface(_oracle);
        USDTInterface = IERC20(_usdt);
        BASE_MULTIPLIER = (10**18);
        MONTH = (30 * 24 * 3600);
        // Tier 1 settings
        minAllocaPerUserTier[1] = 1 ether; // Minimum allocation for tier 1
        maxAllocaPerUserTier[1] = 500 ether; // Maximum allocation for tier 1

        // Tier 2 settings
        minAllocaPerUserTier[2] = 1 ether; // Minimum allocation for tier 2
        maxAllocaPerUserTier[2] = 300 ether; // Maximum allocation for tier 2
        // Tier 3 settings
        minAllocaPerUserTier[3] = 1 ether; // Minimum allocation for tier 3
        maxAllocaPerUserTier[3] = 300 ether; // Maximum allocation for tier 3
        // Tier 4 settings
        minAllocaPerUserTier[4] = 1 ether; // Minimum allocation for tier 4
        maxAllocaPerUserTier[4] = 300 ether; // Maximum allocation for tier 4
        // Tier 2 settings
        minAllocaPerUserTier[5] = 1 ether; // Minimum allocation for tier 5
        maxAllocaPerUserTier[5] = 300 ether; // Maximum allocation for tier 5
    }

    function changeUsdtAddress(address _newUsdtAddress) external onlyOwner {
        require(_newUsdtAddress != address(0), "Zero USDT address");
        USDTInterface = IERC20(_newUsdtAddress);
    }

    function changeOraleAddress(address _newOracleAddress) external onlyOwner {
        require(_newOracleAddress != address(0), "Zero Oracle Addresss");
        aggregatorInterface = AggregatorV3Interface(_newOracleAddress);
    }

    function createPresale(
        address _tokenAddress,
        uint256 _startTime,
        uint256 _endTime,
        uint256 _price,
        uint256 _tokensToSell,
        uint256 _baseDecimals,
        uint256 _vestingStartTime,
        uint256 _vestingCliff,
        uint256 _vestingPeriod,
        uint256 _enableBuyWithEth,
        uint256 _enableBuyWithUsdt,
        bool _whitelistEnabled
    ) external onlyOwner {
        require(
            _startTime > block.timestamp && _endTime > _startTime,
            "Invalid time"
        );
        require(_price > 0, "Zero price");
        require(_tokensToSell > 0, "Zero tokens to sell");
        require(_baseDecimals > 0, "Zero decimals for the token");
        require(
            _vestingStartTime >= _endTime,
            "Vesting starts before Presale ends"
        );
        require(
            _tokenAddress != address(0),
            "Token Address not be equal zero address"
        );

        IERC20 token = IERC20(_tokenAddress);
        require(
            token.transferFrom(msg.sender, address(this), _tokensToSell),
            "Token transfer failed"
        );

        presaleId++;
        presale[presaleId] = Presale(
            _tokenAddress,
            _startTime,
            _endTime,
            _price,
            _tokensToSell,
            _baseDecimals,
            _tokensToSell,
            _vestingStartTime,
            _vestingCliff,
            _vestingPeriod,
            _enableBuyWithEth,
            _enableBuyWithUsdt,
            _whitelistEnabled
        );

        emit PresaleCreated(
            presaleId,
            _tokensToSell,
            _startTime,
            _endTime,
            _enableBuyWithEth,
            _enableBuyWithUsdt,
            _whitelistEnabled
        );
    }

    function changeSaleTimes(
        uint256 _id,
        uint256 _startTime,
        uint256 _endTime
    ) external checkPresaleId(_id) onlyOwner {
        require(_startTime > 0 || _endTime > 0, "Invalid parameters");
        if (_startTime > 0) {
            uint256 prevValue = presale[_id].startTime;
            presale[_id].startTime = _startTime;
            emit PresaleUpdated(
                bytes32("START"),
                prevValue,
                _startTime,
                block.timestamp
            );
        }

        if (_endTime > 0) {
            uint256 prevValue = presale[_id].endTime;
            presale[_id].endTime = _endTime;
            emit PresaleUpdated(
                bytes32("END"),
                prevValue,
                _endTime,
                block.timestamp
            );
        }
    }

    function changeVestingStartTime(uint256 _id, uint256 _vestingStartTime)
        external
        checkPresaleId(_id)
        onlyOwner
    {
        require(
            _vestingStartTime >= presale[_id].endTime,
            "Vesting starts before Presale ends"
        );
        uint256 prevValue = presale[_id].vestingStartTime;
        presale[_id].vestingStartTime = _vestingStartTime;
        emit PresaleUpdated(
            bytes32("VESTING_START_TIME"),
            prevValue,
            _vestingStartTime,
            block.timestamp
        );
    }

    function changeSaleTokenAddress(uint256 _id, address _newAddress)
        external
        checkPresaleId(_id)
        onlyOwner
    {
        require(_newAddress != address(0), "Zero token address");
        address prevValue = presale[_id].saleToken;
        presale[_id].saleToken = _newAddress;
        emit PresaleTokenAddressUpdated(
            prevValue,
            _newAddress,
            block.timestamp
        );
    }

    function changePrice(uint256 _id, uint256 _newPrice)
        external
        checkPresaleId(_id)
        onlyOwner
    {
        require(_newPrice > 0, "Zero price");
        uint256 prevValue = presale[_id].price;
        presale[_id].price = _newPrice;
        emit PresaleUpdated(
            bytes32("PRICE"),
            prevValue,
            _newPrice,
            block.timestamp
        );
    }

    function changeEnableBuyWithEth(uint256 _id, uint256 _enableToBuyWithEth)
        external
        checkPresaleId(_id)
        onlyOwner
    {
        uint256 prevValue = presale[_id].enableBuyWithEth;
        presale[_id].enableBuyWithEth = _enableToBuyWithEth;
        emit PresaleUpdated(
            bytes32("ENABLE_BUY_WITH_ETH"),
            prevValue,
            _enableToBuyWithEth,
            block.timestamp
        );
    }

    function changeEnableBuyWithUsdt(uint256 _id, uint256 _enableToBuyWithUsdt)
        external
        checkPresaleId(_id)
        onlyOwner
    {
        uint256 prevValue = presale[_id].enableBuyWithUsdt;
        presale[_id].enableBuyWithUsdt = _enableToBuyWithUsdt;
        emit PresaleUpdated(
            bytes32("ENABLE_BUY_WITH_USDT"),
            prevValue,
            _enableToBuyWithUsdt,
            block.timestamp
        );
    }

    function pausePresale(uint256 _id) external checkPresaleId(_id) onlyOwner {
        require(!paused[_id], "Already paused");
        paused[_id] = true;
        emit PresalePaused(_id, block.timestamp);
    }

    function unPausePresale(uint256 _id)
        external
        checkPresaleId(_id)
        onlyOwner
    {
        require(paused[_id], "Not paused");
        paused[_id] = false;
        emit PresaleUnpaused(_id, block.timestamp);
    }

    function addWhitelistTierOne(address[] calldata users) external onlyOwner {
        for (uint256 i = 0; i < users.length; i++) {
            whitelistTierOne.push(users[i]);
        }
    }

    function addWhitelistTierTwo(address[] calldata users) external onlyOwner {
        for (uint256 i = 0; i < users.length; i++) {
            whitelistTierTwo.push(users[i]);
        }
    }

    function addWhitelistTierThree(address[] calldata users)
        external
        onlyOwner
    {
        for (uint256 i = 0; i < users.length; i++) {
            whitelistTierThree.push(users[i]);
        }
    }

    function addWhitelistTierFour(address[] calldata users) external onlyOwner {
        for (uint256 i = 0; i < users.length; i++) {
            whitelistTierFour.push(users[i]);
        }
    }

    function addWhitelistTierFive(address[] calldata users) external onlyOwner {
        for (uint256 i = 0; i < users.length; i++) {
            whitelistTierFive.push(users[i]);
        }
    }

    function removeWhitelistTierOne(address[] calldata users)
        external
        onlyOwner
    {
        for (uint256 i = 0; i < users.length; i++) {
            uint256 indexToRemove = findIndex(whitelistTierOne, users[i]);
            if (indexToRemove < whitelistTierOne.length) {
                whitelistTierOne[indexToRemove] = whitelistTierOne[
                    whitelistTierOne.length - 1
                ];
                whitelistTierOne.pop();
            }
        }
    }

    function removeWhitelistTierTwo(address[] calldata users)
        external
        onlyOwner
    {
        for (uint256 i = 0; i < users.length; i++) {
            uint256 indexToRemove = findIndex(whitelistTierTwo, users[i]);
            if (indexToRemove < whitelistTierTwo.length) {
                whitelistTierTwo[indexToRemove] = whitelistTierTwo[
                    whitelistTierTwo.length - 1
                ];
                whitelistTierTwo.pop();
            }
        }
    }

    function removeWhitelistTierThree(address[] calldata users)
        external
        onlyOwner
    {
        for (uint256 i = 0; i < users.length; i++) {
            uint256 indexToRemove = findIndex(whitelistTierThree, users[i]);
            if (indexToRemove < whitelistTierThree.length) {
                whitelistTierThree[indexToRemove] = whitelistTierThree[
                    whitelistTierThree.length - 1
                ];
                whitelistTierThree.pop();
            }
        }
    }

    function removeWhitelistTierFour(address[] calldata users)
        external
        onlyOwner
    {
        for (uint256 i = 0; i < users.length; i++) {
            uint256 indexToRemove = findIndex(whitelistTierFour, users[i]);
            if (indexToRemove < whitelistTierFour.length) {
                whitelistTierFour[indexToRemove] = whitelistTierFour[
                    whitelistTierFour.length - 1
                ];
                whitelistTierFour.pop();
            }
        }
    }

    function removeWhitelistTierFive(address[] calldata users)
        external
        onlyOwner
    {
        for (uint256 i = 0; i < users.length; i++) {
            uint256 indexToRemove = findIndex(whitelistTierFive, users[i]);
            if (indexToRemove < whitelistTierFive.length) {
                whitelistTierFive[indexToRemove] = whitelistTierFive[
                    whitelistTierFive.length - 1
                ];
                whitelistTierFive.pop();
            }
        }
    }

    function findIndex(address[] storage whitelist, address user)
        internal
        view
        returns (uint256)
    {
        for (uint256 i = 0; i < whitelist.length; i++) {
            if (whitelist[i] == user) {
                return i;
            }
        }
        return uint256(0);
    }

    function updateMinAllocation(uint256 tier, uint256 newMinAllocation)
        external
        onlyOwner
    {
        require(tier >= 1 && tier <= 5, "Invalid tier");
        minAllocaPerUserTier[tier] = newMinAllocation;
    }

    function updateMaxAllocation(uint256 tier, uint256 newMaxAllocation)
        external
        onlyOwner
    {
        require(tier >= 1 && tier <= 5, "Invalid tier");
        maxAllocaPerUserTier[tier] = newMaxAllocation;
    }

    function getLatestPrice() public view returns (uint256) {
        (, int256 price, , , ) = aggregatorInterface.latestRoundData();
        price = (price * (10**10));
        return uint256(price);
    }

    function isAddressInWhitelist(address[] memory tier, address user)
        private
        pure
        returns (bool)
    {
        for (uint256 i = 0; i < tier.length; i++) {
            if (tier[i] == user) {
                return true;
            }
        }
        return false;
    }

    function buyWithUSDT(uint256 _id, uint256 amount)
        external
        checkPresaleId(_id)
        checkSaleState(_id, amount)
        checkUserTier(amount)
        returns (bool)
    {
        if (presale[_id].whitelistEnabled) {
            require(
                isAddressInWhitelist(whitelistTierOne, _msgSender()) ||
                    isAddressInWhitelist(whitelistTierTwo, _msgSender()) ||
                    isAddressInWhitelist(whitelistTierThree, _msgSender()) ||
                    isAddressInWhitelist(whitelistTierFour, _msgSender()) ||
                    isAddressInWhitelist(whitelistTierFive, _msgSender()),
                "You are not whitelisted!"
            );
        }
        if (presale[_id].whitelistEnabled) {
            uint256 userTier = getUserTier(msg.sender);
            require(amount >= minAllocaPerUserTier[userTier], "Amount too low");
            require(
                amount <= maxAllocaPerUserTier[userTier],
                "Amount too high"
            );
        }
        uint256 usdPrice = amount * presale[_id].price;
        usdPrice = usdPrice / (10**18);
        presale[_id].inSale -= amount;
        Presale memory _presale = presale[_id];

        if (userVesting[_msgSender()][_id].totalAmount > 0) {
            userVesting[_msgSender()][_id].totalAmount += (amount);
        } else {
            userVesting[_msgSender()][_id] = Vesting(
                (amount),
                0,
                _presale.vestingStartTime + _presale.vestingCliff,
                _presale.vestingStartTime +
                    _presale.vestingCliff +
                    _presale.vestingPeriod
            );
        }
        require(
            USDTInterface.transferFrom(_msgSender(), owner(), usdPrice),
            "Transfer of USDT failed"
        );

        emit TokensBought(
            _msgSender(),
            _id,
            address(USDTInterface),
            amount,
            usdPrice,
            block.timestamp
        );
        return true;
    }

    function buyWithEth(uint256 _id, uint256 amount)
        external
        payable
        checkPresaleId(_id)
        checkSaleState(_id, amount)
        checkUserTier(amount)
        nonReentrant
        returns (bool)
    {
        require(!paused[_id], "Presale paused");
        require(
            presale[_id].enableBuyWithEth > 0,
            "Not allowed to buy with ETH"
        );
        if (presale[_id].whitelistEnabled) {
            require(
                isAddressInWhitelist(whitelistTierOne, _msgSender()) ||
                    isAddressInWhitelist(whitelistTierTwo, _msgSender()) ||
                    isAddressInWhitelist(whitelistTierThree, _msgSender()) ||
                    isAddressInWhitelist(whitelistTierFour, _msgSender()) ||
                    isAddressInWhitelist(whitelistTierFive, _msgSender()),
                "You are not whitelisted!"
            );
        }
        if (presale[_id].whitelistEnabled) {
            uint256 userTier = getUserTier(msg.sender);
            require(amount >= minAllocaPerUserTier[userTier], "Amount too low");
            require(
                amount <= maxAllocaPerUserTier[userTier],
                "Amount too high"
            );
        }
        uint256 usdPrice = amount * presale[_id].price;
        uint256 ethAmount = (usdPrice * BASE_MULTIPLIER) / getLatestPrice();
        require(msg.value >= ethAmount, "Less payment");
        uint256 excess = msg.value - ethAmount;
        presale[_id].inSale -= amount;
        Presale memory _presale = presale[_id];

        if (userVesting[_msgSender()][_id].totalAmount > 0) {
            userVesting[_msgSender()][_id].totalAmount += (amount);
        } else {
            userVesting[_msgSender()][_id] = Vesting(
                (amount),
                0,
                _presale.vestingStartTime + _presale.vestingCliff,
                _presale.vestingStartTime +
                    _presale.vestingCliff +
                    _presale.vestingPeriod
            );
        }
        sendValue(payable(owner()), ethAmount);
        if (excess > 0) sendValue(payable(_msgSender()), excess);
        emit TokensBought(
            _msgSender(),
            _id,
            address(0),
            amount,
            ethAmount,
            block.timestamp
        );
        return true;
    }

    function ethBuyHelper(uint256 _id, uint256 amount)
        external
        view
        checkPresaleId(_id)
        returns (uint256 ethAmount)
    {
        uint256 usdPrice = amount * presale[_id].price;
        ethAmount = (usdPrice * BASE_MULTIPLIER) / getLatestPrice();
    }

    function usdtBuyHelper(uint256 _id, uint256 amount)
        external
        view
        checkPresaleId(_id)
        returns (uint256 usdPrice)
    {
        usdPrice = amount * presale[_id].price;
        usdPrice = usdPrice / (10**12);
    }

    function sendValue(address payable recipient, uint256 amount) internal {
        require(address(this).balance >= amount, "Low balance");
        (bool success, ) = recipient.call{value: amount}("");
        require(success, "ETH Payment failed");
    }

    function claimableAmount(address user, uint256 _id)
        public
        view
        checkPresaleId(_id)
        returns (uint256)
    {
        Vesting memory _user = userVesting[user][_id];
        require(_user.totalAmount > 0, "Nothing to claim");
        uint256 amount = _user.totalAmount - _user.claimedAmount;
        require(amount > 0, "Already claimed");

        if (block.timestamp < _user.claimStart) return 0;
        if (block.timestamp >= _user.claimEnd) return amount;

        uint256 noOfMonthsPassed = (block.timestamp - _user.claimStart) / MONTH;

        uint256 perMonthClaim = (_user.totalAmount * BASE_MULTIPLIER * MONTH) /
            (_user.claimEnd - _user.claimStart);

        uint256 amountToClaim = ((noOfMonthsPassed * perMonthClaim) /
            BASE_MULTIPLIER) - _user.claimedAmount;

        return amountToClaim;
    }

    function claim(address user, uint256 _id) public returns (bool) {
        uint256 amount = claimableAmount(user, _id);
        require(amount > 0, "Zero claim amount");
        require(
            presale[_id].saleToken != address(0),
            "Presale token address not set"
        );
        require(
            amount <= IERC20(presale[_id].saleToken).balanceOf(address(this)),
            "Not enough tokens in the contract"
        );
        userVesting[user][_id].claimedAmount += amount;
        bool status = IERC20(presale[_id].saleToken).transfer(user, amount);
        require(status, "Token transfer failed");
        emit TokensClaimed(user, _id, amount, block.timestamp);
        return true;
    }

    function claimMultiple(address[] calldata users, uint256 _id)
        external
        returns (bool)
    {
        require(users.length > 0, "Zero users length");
        for (uint256 i; i < users.length; i++) {
            require(claim(users[i], _id), "Claim failed");
        }
        return true;
    }

    function getUserTier(address user) public view returns (uint256) {
        for (uint256 i = 0; i < whitelistTierOne.length; i++) {
            if (whitelistTierOne[i] == user) {
                return 1;
            }
        }

        for (uint256 i = 0; i < whitelistTierTwo.length; i++) {
            if (whitelistTierTwo[i] == user) {
                return 2;
            }
        }

        for (uint256 i = 0; i < whitelistTierThree.length; i++) {
            if (whitelistTierThree[i] == user) {
                return 3;
            }
        }

        for (uint256 i = 0; i < whitelistTierFour.length; i++) {
            if (whitelistTierFour[i] == user) {
                return 4;
            }
        }

        for (uint256 i = 0; i < whitelistTierFive.length; i++) {
            if (whitelistTierFive[i] == user) {
                return 5;
            }
        }
        return 0;
    }

    function withdrawBNB(uint256 _amount) external onlyOwner {
        require(address(this).balance >= _amount, "Not enough BNB in contract");
        payable(msg.sender).transfer(_amount);
    }

    function withdraw(address _tokenAddress, uint256 _amount)
        external
        onlyOwner
    {
        IERC20 token = IERC20(_tokenAddress);
        require(token.transfer(msg.sender, _amount), "Token transfer failed");
    }
}