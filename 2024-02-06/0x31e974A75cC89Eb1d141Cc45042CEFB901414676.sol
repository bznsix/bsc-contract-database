// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

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

contract MinerGoldGame is Context, ReentrancyGuard, Ownable {
    using SafeMath for uint256;
    using Address for address;

    address private _tokenAddress;
    uint256 private constant DECIMALFACTOR = 10 ** uint256(18);
    uint256 private _yieldFactor = 100000;
    uint256 private _cashFactor = 2;
    uint256 private _transaction_fee = 5;
    uint256 private _PartnersPercent = 15;
    uint256 private _repairPercent = 100;
    uint256 private _multBoxId = 3;
    uint256 private _cargoPrice1 = 100 * DECIMALFACTOR;
    uint256 private _cargoPrice2 =  150 * DECIMALFACTOR;
    uint256 public currentSiloLevel;
    uint256 public totalUsers;
    uint256 public totalMines;
    uint256 public totalMiners;
    uint256 public totalInvested;

    struct ReferSystem {
        uint256[3] referGoldPercent;
        uint256[3] referCashPercent;
    }
    ReferSystem private referSystemConfig;

    uint private _ManagerId;
    struct Managers_Percents {
        address _PartnerAddress;
        uint256 _PartnerPercent;
        bool exist;
    }
    mapping(uint => Managers_Percents) private ManagersPercentage;

    // Define a struct to hold Silo level details
    struct SiloConfig {
        uint256 upgradeCost;
        uint256 siloPercent;
    }
    mapping(uint => SiloConfig) public siloConfigs;
    
    // Struct to store mine upgrade details
    struct MineConfig {
        uint256 upgradeCost;
        uint256 improvingPercent;
    }
    // Mapping from mine level (1-8) and improving level (1-5) to MineConfig
    mapping(uint => mapping(uint => MineConfig)) public mineConfigs;

    struct referConfig {
        address[3] referrers;
        address ref;
        uint256 refs;
        uint256 refGold;
        uint256 refCash;
        uint256 refTotal;
    }

    struct Miner {
        uint rarity;
        bool isActive;
    }

    // Struct to store user mine information
    struct Mine {
        uint mineLevel;
        uint improvingLevel;
        uint256 percentage;
        uint256 investiment;
        uint256 lastCollectionTime;
        bool exists;
    }

    struct userConfig {
        uint256 GoldCoins;
        uint256 CashGame;
        uint256 investiment;
        uint256 totalYield;
        referConfig refer_config;
        Mine[8] mines;
        Miner[5][8] miners;
        uint silo;
        uint cargo;
        uint256 timestamp;
        bool exist;
    }
    mapping(address => userConfig) public caveUserConf;

    uint boxId;
    uint[] private boxIds;
    //Percentage yield by rarity
    uint256[] public rarityPercentages = [100, 120, 150];
    uint[] public raritiesChance = [60, 40, 5];
    struct MysteryBox {
        uint256 price;
        uint256 legendaryChance;
        bool exists;
    }
    mapping(uint => MysteryBox) public mysteryBoxes;

    //Function for Future rewards 
    struct Receivers {
        address wallet;
        uint256 GoldCoins;
        uint256 CashGame;
    }

    bool _MaxLimit = true;
    uint256 private _maxWithdrawPercent = 75;
    struct widthLimit {
        uint256 maxAmount;
        uint256 maxLimitAmount;
        uint256 timestamp;
    }
    mapping(address => widthLimit) private maxLimitWidth;

    bool public bonusNewUser = true;
    bool public isCargoActive = true;
    bool public paused;
    modifier isPausable() {
        require(!paused, "The Contract is paused. Mintable is paused");
        _;
    }

    constructor(
        address TokenAddress
    ) Ownable(msg.sender) {
        // Address manager
        _tokenAddress = TokenAddress;
    }

    function totalBalance() external view returns (uint256) {
        return payable(address(this)).balance;
    }

    function balanceUser(address account)
        public
        view
        returns (
            uint256 GoldCoins,
            uint256 CashGame,
            uint256 estimateToken
        )
    {
        return (
            caveUserConf[account].GoldCoins,
            caveUserConf[account].CashGame,
            ((caveUserConf[account].GoldCoins).div(_cashFactor)).add(caveUserConf[account].CashGame)
        );
    }

    function getCashFactor() public view returns (uint256) {
        return _cashFactor;
    }

    /*get getManagers_Percents*/
    function getManagers_Percents()
        public view returns (Managers_Percents[] memory)
    {
        Managers_Percents[] memory items = new Managers_Percents[](_ManagerId);
        for (uint i = 0; i < _ManagerId; i++) {
            Managers_Percents storage Partner = ManagersPercentage[i];
            if(Partner._PartnerAddress != address(0)){
                items[i] = Partner;
            }
        }
        return items;
    }

    function getTransactionFee() public view returns (uint256) {
        return _transaction_fee;
    }

    //Function to return the settings of all silos created up to the current level
    function getSiloDetails(uint level) public view returns (
        uint256 upgradeCost,
        uint256 siloPercent
    ) {
        SiloConfig memory config = siloConfigs[level];
        return (config.upgradeCost, config.siloPercent);
    }

    // Function to return the settings of a specific mine level
    function getMineConfig(uint mineLevel) public view returns (MineConfig[5] memory) {
        require(mineLevel >= 1 && mineLevel <= 8, "Invalid mineLevel");
        MineConfig[5] memory configs;
        for (uint improvingLevel = 0; improvingLevel < 5; improvingLevel++) {
            MineConfig memory config = mineConfigs[mineLevel - 1][improvingLevel];
            configs[improvingLevel] = config;
        }
        return configs;
    }

    //Function to return the settings of all silos created up to the current level
    function getSiloConfigs() public view returns (SiloConfig[] memory) {
        SiloConfig[] memory configs = new SiloConfig[](currentSiloLevel+1);
        for (uint i = 0; i < currentSiloLevel+1; i++) {
            SiloConfig storage config = siloConfigs[i];
            configs[i] = config;
        }
        return configs;
    }

    // Function to get user mine details
    function getUserMineDetails(
        address account,
        uint mineLevel
    ) public view returns (
        uint improvementLevel,
        uint totalPercentage,
        uint256 userInvestiment
    ) {
        require(mineLevel >= 1 && mineLevel <= 8, "Invalid mineId");
        userConfig memory userMine = caveUserConf[account];
        return (userMine.mines[mineLevel-1].improvingLevel, userMine.mines[mineLevel-1].percentage, userMine.mines[mineLevel-1].investiment);
    }

    // Function to get user miners details and count of active miners
    function getUserMinersDetails(
        address account,
        uint mineLevel
    ) public view returns (Miner[5] memory miners, uint activeMinersCount) {
        require(mineLevel >= 1 && mineLevel <= 8, "Invalid mineLevel"); // Validação do nível da mina
        Miner[5] memory tempMiners;
        uint count = 0;
        for (uint i = 0; i < 5; i++) {
            tempMiners[i] = caveUserConf[account].miners[mineLevel-1][i];
            if (tempMiners[i].isActive) {
                count++;
            }
        }
        return (tempMiners, count);
    }

    //Function to calculate a user's maximum return
    function getMaxUserReturn(address user) public view returns (uint256) {
        uint256 siloLevel = caveUserConf[user].silo;
        SiloConfig memory siloConfig = siloConfigs[siloLevel];
        return caveUserConf[user].investiment * siloConfig.siloPercent / 100;
    }

    function getBoxList() public view returns (uint[] memory, MysteryBox[] memory) {
        MysteryBox[] memory boxes = new MysteryBox[](boxIds.length);
        for (uint i = 0; i < boxIds.length; i++) {
            boxes[i] = mysteryBoxes[boxIds[i]];
        }
        return (boxIds, boxes);
    }

    function getReferralConfig() public view returns (uint256[3] memory, uint256[3] memory) {
        return (referSystemConfig.referGoldPercent, referSystemConfig.referCashPercent);
    }

    function getTokenAdress() public view returns (address) {
        return _tokenAddress;
    }

    /*get get repair Percent */
    function getRepairPercent()
        public view returns (uint256 RepairPercentage)
    {
        return _repairPercent;
    }

    function getCostRepair(address account) 
        public view
        returns ( uint256 repairCost )
    {
        uint256 investValue = caveUserConf[account].investiment.mul(_repairPercent).div(100);
        return investValue;
    }

    function getCargoPrice()
        public view returns (uint256, uint256)
    {
        return (_cargoPrice1, _cargoPrice2);
    }

    function gatIsMaxLimit() public view returns (bool) {
        return _MaxLimit;
    }

    function getMaxWidthdrawFee() public view returns (uint256) {
        return _maxWithdrawPercent;
    }

    function getMaxLimitUser(address account)
        public view
        returns (
            uint256,
            uint256,
            uint256
        )
    {
        widthLimit storage limit = maxLimitWidth[account];
        uint256 resetDaily = limit.timestamp == 0 ? 0 : (block.timestamp - limit.timestamp) / 1 days;
        uint256 maxLimitAmount = limit.maxLimitAmount;
        uint256 maxAmount = limit.maxAmount;
        if (resetDaily >= 1) {
            maxAmount = 0;
            maxLimitAmount = 0;
        }
        if (maxLimitAmount <= 0) {
            uint256 BalanceUser = caveUserConf[account].CashGame;
            maxLimitAmount = BalanceUser.mul(_maxWithdrawPercent).div(100);
        }
        return (maxLimitAmount, maxAmount, limit.timestamp);
    }

    //Function to calculate the total income of all a user's mines
    function calculateTotalMinerIncome(address user) public view returns (uint256) {
        uint256 totalIncome = 0;
        //Iterates on all 8 mines
        for (uint mineId = 0; mineId < 8; mineId++) {
            Mine storage userMine = caveUserConf[user].mines[mineId];
            
            //Check if the mine exists
            if (!userMine.exists) {
                continue; //Jump to the next mine if it doesn't exist
            }

            //Calculates the mine's base rent
            uint256 resultPercentage = userMine.percentage;
            uint256 baseInvestiment = (userMine.investiment).mul(resultPercentage).div(_yieldFactor);
            uint256 baseMineIncome = baseInvestiment / 5 / 24;
            //Itera on each miner in the mine
            for (uint minerId = 0; minerId < 5; minerId++) {
                Miner storage miner = caveUserConf[user].miners[mineId][minerId];
                if (miner.isActive) {
                    uint rarity = miner.rarity;
                    require(rarity >= 1 && rarity <= 3, "Invalid rarity");
                    uint256 rarityPercent = rarityPercentages[rarity - 1];
                    //Calculates the miner's income based on the mine's rarity and base rent
                    uint256 minerIncome = baseMineIncome.mul(rarityPercent).div(100);
                    totalIncome += minerIncome;
                }
            }
        }

        return totalIncome;
    }

    //Function to calculate the user's total income
    function calculateMinerIncome(address user, uint mineId) public view returns (uint256) {
        require(mineId >= 1 && mineId <= 8, "Invalid mineId");
        uint256 totalIncome = 0;
        Mine storage userMine = caveUserConf[user].mines[mineId-1];
        //Check if the mine exists
        if (!userMine.exists) {
            return 0;
        }

        //Calculates the mine's base rent
        uint256 resultPercentage = userMine.percentage;
        uint256 baseInvestiment = (userMine.investiment).mul(resultPercentage).div(_yieldFactor);
        uint256 baseMineIncome = baseInvestiment / 5 / 24;
        //Itera on each miner in the mine
        for (uint minerId = 0; minerId < 5; minerId++) {
            Miner storage miner = caveUserConf[user].miners[mineId-1][minerId];
            if (miner.isActive) {
                uint rarity = miner.rarity;
                require(rarity >= 1 && rarity <= 3, "Invalid rarity");
                uint256 rarityPercent = rarityPercentages[rarity - 1];

                //Calculates the miner's income based on the mine's rarity and base rent
                uint256 minerIncome = baseMineIncome.mul(rarityPercent).div(100);
                totalIncome += minerIncome;
            }
        }
        return totalIncome;
    }

    /**
     * @dev Enables the contract to receive BNB.
     */
    receive() external payable {}
    fallback() external payable {}

    function addCoins(address ref, uint256 tokenAmount) public nonReentrant isPausable {
        uint256 GoldCoins = tokenAmount * _cashFactor;
        address user = msg.sender;
        if (!caveUserConf[user].exist) {
            _registerRefer(ref);
            caveUserConf[user].timestamp = block.timestamp;
            caveUserConf[user].cargo = 1;
            caveUserConf[user].exist = true;
            if(bonusNewUser){
                caveUserConf[user].mines[0].mineLevel+=1;
                caveUserConf[user].mines[0].improvingLevel+=1;
                caveUserConf[user].mines[0].percentage+=mineConfigs[0][0].improvingPercent;
                caveUserConf[user].mines[0].investiment+=mineConfigs[0][0].upgradeCost;
                caveUserConf[user].investiment+=mineConfigs[0][0].upgradeCost;
                caveUserConf[user].mines[0].exists = true;
                caveUserConf[user].miners[0][0].rarity=1;
                caveUserConf[user].miners[0][0].isActive = true;
                totalMines += 1;
                totalMiners += 1;
            }
            totalUsers += 1;
        }else{
            IERC20 ContractAdd = IERC20(_tokenAddress);
            require(
                ContractAdd.transferFrom(user, address(this), tokenAmount),
                "Insufficient balance for this requisition"
            );
            if(caveUserConf[msg.sender].refer_config.ref == owner() && ref != owner()){
                _registerRefer(ref);
            }
            
            _distributeReferralRewards(user, tokenAmount, GoldCoins);
            caveUserConf[user].GoldCoins += GoldCoins;
            uint256 PartnerValue = tokenAmount.mul(_PartnersPercent).div(100);
            for (uint256 i = 0; i < _ManagerId+1; i++) {
                if (
                    ManagersPercentage[i]._PartnerAddress != address(0) ||
                    ManagersPercentage[i]._PartnerPercent > 0
                ) {
                    uint256 ManageAmount = (PartnerValue).mul(ManagersPercentage[i]._PartnerPercent).div(100);
                    caveUserConf[ManagersPercentage[i]._PartnerAddress].CashGame += ManageAmount;
                }
            }

            totalInvested += tokenAmount;
            emit addCoin(msg.sender, tokenAmount, GoldCoins);
        }
    }

    function _registerRefer(address referrer) private {
        //Logic for defining the three levels of referencers
        address refer1 = referrer;
        address refer2 = caveUserConf[refer1].refer_config.referrers[0];
        if(refer2 == address(0)){
            refer2 = referrer;
        }
        address refer3 = caveUserConf[refer2].refer_config.referrers[0];
        if(refer3 == address(0)){
            refer3 = owner();
        }

        caveUserConf[msg.sender].refer_config.ref = refer1;
        caveUserConf[msg.sender].refer_config.referrers = [refer1, refer2, refer3];
        caveUserConf[refer1].refer_config.refs++;
    }

    function _distributeReferralRewards(address user, uint256 investment, uint256 GoldCoins) private {
        address[3] memory referrers = caveUserConf[user].refer_config.referrers;
        for (uint i = 0; i < referrers.length; i++) {
            if (referrers[i] != address(0)) {
                uint256 goldCoinReward = GoldCoins.mul(referSystemConfig.referGoldPercent[i]).div(100);
                caveUserConf[referrers[i]].GoldCoins += goldCoinReward;
                caveUserConf[referrers[i]].refer_config.refGold += goldCoinReward;

                uint256 cashReward = investment.mul(referSystemConfig.referCashPercent[i]).div(100);
                caveUserConf[referrers[i]].CashGame += cashReward;
                caveUserConf[referrers[i]].refer_config.refCash += cashReward;
                caveUserConf[referrers[i]].refer_config.refTotal += (goldCoinReward/_cashFactor).add(cashReward);
            }
        }
    }

    function processGoldToCash() public isPausable {
        address user = msg.sender;
        require(
            caveUserConf[user].exist,
            "A User does not exist, check the contract or create it first"
        );
        require(
            caveUserConf[user].timestamp > 0,
            "This user does not contain a valid time"
        );
        uint256 hrs = block.timestamp / 3600 - caveUserConf[user].timestamp / 3600;
        uint256 collected;
        if (hrs > 0 && caveUserConf[user].investiment > 0) {
            if(isCargoActive){
                uint256 time = _getCargoTime(caveUserConf[user].cargo);
                if (hrs > time) {
                    hrs = time;
                }
            }
            collected = calculateTotalMinerIncome(user) * hrs;
            uint256 yield = collected;
            uint256 yieldTotal = caveUserConf[user].totalYield + yield;
            uint256 yieldTotalTier = getMaxUserReturn(user);
            if(yieldTotal < yieldTotalTier){
                caveUserConf[user].CashGame += (collected / _cashFactor);
                caveUserConf[user].totalYield+=yield;
            }
        }
        
        caveUserConf[user].timestamp = block.timestamp;
        emit CollectMoney(msg.sender, collected);
    }

    function _getCargoTime(uint cargo) private pure returns (uint256) {
        if(cargo == 3){
            return 72;
        } else if(cargo == 2){
            return 48;
        } else {
            return 24;
        }
    }

    function withdrawCash() public isPausable {
        address user = msg.sender;
        uint256 amount = caveUserConf[user].CashGame;
        uint256 BalanceUser = caveUserConf[user].CashGame;        
        require(
            amount > 0 && amount <= BalanceUser,
            "You do not have enough balance for this withdrawal"
        );
        if (_MaxLimit) {
            uint256 resetDaily = maxLimitWidth[user].timestamp == 0
                ? 0
                : (block.timestamp - maxLimitWidth[user].timestamp) / 1 days;
            if (resetDaily >= 1) {
                maxLimitWidth[user].maxAmount = 0;
                maxLimitWidth[user].maxLimitAmount = 0;
            }

            uint256 maxLimitAmount = maxLimitWidth[user].maxLimitAmount;
            if (maxLimitAmount <= 0) {
                maxLimitAmount = BalanceUser.mul(_maxWithdrawPercent).div(
                    100
                );
                maxLimitWidth[user].maxLimitAmount = maxLimitAmount;
            }

            uint256 sumMaxLimit = maxLimitWidth[user].maxAmount + amount;
            require(
                sumMaxLimit <= maxLimitAmount,
                "It is not possible to make this withdrawal. You have reached your daily maximum limit."
            );
            maxLimitWidth[user].maxAmount += amount;
            maxLimitWidth[user].timestamp = block.timestamp;
        }

        uint256 fee = amount.mul(_transaction_fee).div(100);
        IERC20 ContractAdd = IERC20(_tokenAddress);
        require(ContractAdd.transfer(user, amount.sub(fee)), "You do not have enough balance for this withdrawal");

        caveUserConf[user].CashGame = 0;
        emit WithdrawMoney(user, amount);
    }

    function upgradeSiloRepair() public isPausable {
        processGoldToCash();
        address user = msg.sender;
        uint256 repairCost = getCostRepair(user);
        require(
            caveUserConf[user].GoldCoins >= repairCost,
            "You don't have enough GoldCoins for this transaction"
        );

        caveUserConf[user].GoldCoins -= repairCost;
        caveUserConf[user].totalYield = 0;
    }

    function MultBuyMysteryBox(uint mineId) public isPausable {
        address user = msg.sender;
        require(mineId >= 1 && mineId <= 8, "Invalid mineId"); //Make sure mineId is valid
        require(mysteryBoxes[_multBoxId].exists, "Box does not exist");

        MysteryBox storage box = mysteryBoxes[_multBoxId];
        require(caveUserConf[user].GoldCoins > box.price, "You do not have enough balance for this transaction");
        caveUserConf[user].GoldCoins -= box.price;

        for (uint I; I < 5; I++) {
            uint randomHash = uint(keccak256(abi.encodePacked(block.timestamp, msg.sender, gasleft(), I))) % 100;        
            uint newRarity = 1; //Sets the default rarity to 1 (Common)
            for (uint index = 0; index < raritiesChance.length; index++) {
                if (randomHash < raritiesChance[index]) {
                    newRarity = index + 1; //Adjusts to match the rarity indexChance
                }
            }
            if(randomHash <= box.legendaryChance && newRarity != 3){
                newRarity = 3;
            }

            Miner[5] storage _miner = caveUserConf[user].miners[mineId-1];
            uint lowestRarityIndex = 0;
            bool hasEmptySlot = false;
            for (uint i = 0; i < _miner.length; i++) {
                if (!_miner[i].isActive && _miner[i].rarity == 0) { // Slot vazio
                    lowestRarityIndex = i;
                    hasEmptySlot = true;
                    break;
                } else if (_miner[i].rarity < _miner[lowestRarityIndex].rarity) {
                    lowestRarityIndex = i;
                }
            }
            //Replace the lowest rarity miner or add to the empty slot
            if (hasEmptySlot || newRarity > _miner[lowestRarityIndex].rarity) {
                _miner[lowestRarityIndex].rarity = newRarity;
                _miner[lowestRarityIndex].isActive = true; //Activate the miner
                totalMiners++;
            }
        }
    }

    function buyMysteryBox(uint _boxId, uint mineId) public isPausable {
        address user = msg.sender;
        require(mineId >= 1 && mineId <= 8, "Invalid mineId"); //Make sure mineId is valid
        require(mysteryBoxes[_boxId].exists, "Box does not exist");

        MysteryBox storage box = mysteryBoxes[_boxId];
        require(caveUserConf[user].GoldCoins > box.price, "You do not have enough balance for this transaction");
        caveUserConf[user].GoldCoins -= box.price;
        uint randomHash = uint(keccak256(abi.encodePacked(block.timestamp, msg.sender, gasleft()))) % 100;        
        uint newRarity = 1; //Sets the default rarity to 1 (Common)
        for (uint index = 0; index < raritiesChance.length; index++) {
            if (randomHash < raritiesChance[index]) {
                newRarity = index + 1; //Adjusts to match the rarity indexChance
            }
        }
        if(randomHash <= box.legendaryChance && newRarity != 3){
            newRarity = 3;
        }

        Miner[5] storage _miner = caveUserConf[user].miners[mineId-1];        
        uint lowestRarityIndex = 0;
        bool hasEmptySlot = false;
        for (uint i = 0; i < _miner.length; i++) {
            if (!_miner[i].isActive && _miner[i].rarity == 0) {
                lowestRarityIndex = i;
                hasEmptySlot = true;
                break;
            } else if (_miner[i].rarity < _miner[lowestRarityIndex].rarity) {
                lowestRarityIndex = i;
            }
        }

        //Replace the lowest rarity miner or add to the empty slot
        if (hasEmptySlot || newRarity > _miner[lowestRarityIndex].rarity) {
            _miner[lowestRarityIndex].rarity = newRarity;
            _miner[lowestRarityIndex].isActive = true; //Activate the miner
            totalMiners++;
        }
    }

    // Function for a user to upgrade their mine
    function upgradeUserMine(uint mineLevel) public isPausable {
        address account = msg.sender;
        require(mineLevel >= 1 && mineLevel <= 8, "Invalid mineId");
        userConfig storage userMine = caveUserConf[account];
        uint256 mineUser = mineLevel-1;
        if(!userMine.mines[mineUser].exists){
            totalMines++;
            userMine.mines[mineUser].exists = true;
        }
        uint level = userMine.mines[mineUser].improvingLevel + 1;
        require(level <= 5, "You've reached the limit of improvement.");
        
        // Get the cost and percentage of the next improvement level
        MineConfig memory config = mineConfigs[mineUser][level-1];
        require(
            userMine.GoldCoins >= config.upgradeCost,
            "You don't have enough GoldCoins for this transaction"
        );

        // Increment the improvement level
        userMine.GoldCoins -= config.upgradeCost;
        userMine.investiment += config.upgradeCost;
        userMine.mines[mineUser].improvingLevel++;
        userMine.mines[mineUser].percentage += config.improvingPercent;
        userMine.mines[mineUser].investiment += config.upgradeCost;
        emit upgradeMine(account, mineUser, userMine.mines[mineUser].improvingLevel);
    }

    // Function for a user to upgrade their Silo
    function upgradeUserSilo() public isPausable {
        address account = msg.sender;
        uint currentLevel = caveUserConf[account].silo;
        SiloConfig memory levelDetails = siloConfigs[currentLevel + 1];

        // Check if user has enough Golds to upgrade
        require(caveUserConf[account].GoldCoins >= levelDetails.upgradeCost, "Not enough Golds to upgrade.");

        // Increment the user's Silo level
        caveUserConf[account].silo++;
        caveUserConf[account].GoldCoins -= levelDetails.upgradeCost;
        // Emit an event (optional)
        emit SiloUpgraded(account, caveUserConf[account].silo);
    }
    
    // Function for a user to upgrade their Cargo Time
    function upgradeCargo() public isPausable {
        address user = msg.sender;
        require(
            caveUserConf[user].cargo <= 2,
            "You reached the maximum number of cargos"
        );
        require(
            caveUserConf[user].GoldCoins >= _cargoPrice1 ||
            caveUserConf[user].GoldCoins >= _cargoPrice2,
            "You don't have enough GoldCoins for this transaction"
        );

        if (caveUserConf[user].cargo == 1) {
            caveUserConf[user].GoldCoins -= _cargoPrice1;
            caveUserConf[user].cargo += 1;
        } else if (caveUserConf[user].cargo == 2) {
            caveUserConf[user].GoldCoins -= _cargoPrice2;
            caveUserConf[user].cargo += 1;
        }
    }

    //Function for managers redistribution at Correction time.
    function createManagerList(address PercentAddr, uint256 PartnerPercent) external onlyOwner {
        require(ManagersPercentage[_ManagerId]._PartnerAddress != PercentAddr, "This user already exists, check again");
        uint256 totalPercent = PartnerPercent;
        for (uint i = 0; i < _ManagerId+1; i++) {
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
    function updateManagerList(uint MangerId, address PartnerAddress, uint256 PartnerPercent) external onlyOwner {
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

    function createMysteryBox(uint256 price, uint256 legendaryChance) external onlyOwner {
        require(
            legendaryChance <= 100,
            "The fee percentage cannot be more than 100%"
        );
        require(price > 0, "Value not defined");

        mysteryBoxes[boxId] = MysteryBox(price, legendaryChance, true);
        boxIds.push(boxId);
        boxId+=1;
    }

    function updateMysteryBox(uint _boxId, uint256 newPrice, uint256 newLegendaryChance) external onlyOwner {
        require(
            newLegendaryChance <= 100,
            "The fee percentage cannot be more than 100%"
        );
        require(mysteryBoxes[_boxId].exists, "Box does not exist");
        require(newPrice > 0, "Value not defined");

        mysteryBoxes[_boxId].price = newPrice;
        mysteryBoxes[_boxId].legendaryChance = newLegendaryChance;
    }

    function addRarityChance(uint _chance) external onlyOwner {
        //Here, you can add an access modifier, such as onlyOwner, to restrict who can call this function
        raritiesChance.push(_chance);
    }

    function editRarityChance(uint _index, uint _newChance) external onlyOwner {
        //Check that the index is valid to avoid runtime errors
        require(_index < raritiesChance.length, "Index out of bounds");
        //Again, consider adding an access modifier here
        raritiesChance[_index] = _newChance;
    }

    function setRarityPercentage(uint percentage_) external onlyOwner {
        rarityPercentages.push(percentage_);
    }
    
    function editRarityPercentages(uint _index, uint percentage_) external onlyOwner {
        //Check that the index is valid to avoid runtime errors
        require(_index < rarityPercentages.length, "Index out of bounds");
        //Again, consider adding an access modifier here
        rarityPercentages[_index] = percentage_;
    }

    function deleteMysteryBox(uint _boxId) external onlyOwner {
        require(mysteryBoxes[_boxId].exists, "Box does not exist");
        delete mysteryBoxes[_boxId];
        for (uint i = 0; i < boxIds.length; i++) {
            if (boxIds[i] == _boxId) {
                boxIds[i] = boxIds[boxIds.length - 1];
                boxIds.pop();
                break;
            }
        }
    }

    //Updates the distribution rates of the indecation system in levels.
    function updateReferPercents(uint256[3] memory newReferGoldPercent, uint256[3] memory newReferCashPercent) external onlyOwner {
        //Checks that all percentages are within an acceptable range
        uint256 checkGold;
        uint256 checkCash;
        for (uint i = 0; i < 3; i++) {
            checkGold+=newReferGoldPercent[i];
            checkCash+=newReferCashPercent[i];
        }
        require(checkGold <= 50, "Total fees should not be more than 50%.");
        require(checkCash <= 50, "Total fees should not be more than 50%.");

        referSystemConfig.referGoldPercent = newReferGoldPercent;
        referSystemConfig.referCashPercent = newReferCashPercent;
    }

    //Multiplier factor for managing in-game value.
    function updateCashFactor(uint256 factorValue) external onlyOwner {
        require(factorValue > 0, "You need to enter a valid value");
        _cashFactor = factorValue;
    }

    // Function to set the details of each Silo level
    function setSiloDetails(uint256 cost, uint256 percentage) external onlyOwner {
        siloConfigs[currentSiloLevel+1] = SiloConfig(cost, percentage);
        currentSiloLevel++;
    }

    // Function to upgrade the details of each Silo level
    function upgradeSiloDetails(uint level, uint256 cost, uint256 percentage) external onlyOwner {
        siloConfigs[level] = SiloConfig(cost, percentage);
    }

    // Function to set the details for all improvement levels of a specific mine level
    function upgradeMineConfig(
        uint mineLevel,
        uint256[5] memory costs,
        uint256 percentage
    ) external onlyOwner {
        require(mineLevel >= 1 && mineLevel <= 8, "Invalid mineLevel");
        uint256 _percentagePerLevel = (percentage * _yieldFactor) / (1000 * 5);
        for (uint i = 0; i < 5; i++) {
            require(costs[i] > 0, "Invalid cost"); // Verifica se o custo é válido
            mineConfigs[mineLevel-1][i] = MineConfig(costs[i]*DECIMALFACTOR, _percentagePerLevel);
        }
    }

    function updateFee(uint256 _transactionFee) external onlyOwner {
        require(
            _transactionFee <= 100,
            "The fee percentage cannot be more than 100%"
        );
        _transaction_fee = _transactionFee;
    }

    function updateRepairPercent(uint256 repairPercentage) external onlyOwner {
        require(
            repairPercentage <= 100,
            "The Repair percentage cannot be more than 100%"
        );
        _repairPercent = repairPercentage;
    }

    function updateTokenAdress(address tokenAddress) external onlyOwner {
        require(tokenAddress != address(0), "The address entered is not valid");
        _tokenAddress = tokenAddress;
    }

    function updateCargoPrice(uint256 Cargo, uint256 price) external onlyOwner {
        require(Cargo == 1 || Cargo == 2, "You need to enter a valid value");
        require(price > 0, "You need to enter a valid value");
        if (Cargo == 1) {
            _cargoPrice1 = price;
        } else if (Cargo == 2) {
            _cargoPrice2 = price;
        }
    }

    //Function to update rarityPercentages values
    function updateRarityPercentages(uint256[] memory newPercentages) external onlyOwner {
        rarityPercentages = newPercentages;
    }

    //Sends tokens to users in the event of upgrades or bonuses.
    function AirDropMultSender(Receivers[] memory wallets) external onlyOwner {
        uint256 totalDistUsers;
        uint256 totalGold;
        uint256 totalCash;
        uint256 totalDistribute = wallets.length;
        for (uint256 i = 0; i < totalDistribute; i++){        
            caveUserConf[wallets[i].wallet].GoldCoins += wallets[i].GoldCoins;
            caveUserConf[wallets[i].wallet].CashGame += wallets[i].CashGame;
            totalGold += wallets[i].GoldCoins;
            totalCash += wallets[i].CashGame;
            totalDistUsers++;
        }
        emit distributeReward(totalDistUsers, totalGold, totalCash);
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

    /*
     * @dev Function created to recover funds sent by mistake or 
     * remove suspicious tokens sent as spam
     */
    function rescueBalanceTokens(address _contractAdd) external onlyOwner {
        IERC20 ContractAdd = IERC20(_contractAdd);
        uint256 dexBalance = ContractAdd.balanceOf(address(this));
        require(
            dexBalance > 0,
            "You do not have enough balance for this withdrawal"
        );
        ContractAdd.transfer(_owner, dexBalance); 
    }

    /*
     * @dev Activates or Inactive the main activities carried out by Bonus for new users.
     */
    function updateBonusNewUser() external onlyOwner {
        bonusNewUser ? bonusNewUser = false : bonusNewUser = true;
    }

    /*
     * @dev Activates or deactivates the cargo system.
     */
    function updateCargoActive() external onlyOwner {
        isCargoActive ? isCargoActive = false : isCargoActive = true;
    }

    function setIsMaxLimit() external onlyOwner {
        _MaxLimit ? _MaxLimit = false : _MaxLimit = true;
    }

    /*
     * @dev Activates or pauses the main activities carried out by users.
     * For security reasons or to prevent any harm to the system.
     */
    function pause() external onlyOwner {
        paused ? paused = false : paused = true;
    }
    
    event SiloUpgraded(address indexed user, uint newLevel);
    event distributeReward(uint256 totalUsers, uint256 totalGold, uint256 totalCash);
    event upgradeMine(address indexed user, uint mineLevel, uint improvingLevel);
    event addCoin(address indexed userAddress, uint256 Amount, uint256 GoldCoins);
    event CollectMoney(address indexed userAddress, uint256 CashCoins);
    event WithdrawMoney(address indexed userAddress, uint256 MGoldAmaunt);
}