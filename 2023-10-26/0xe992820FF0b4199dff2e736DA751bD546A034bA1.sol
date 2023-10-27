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
pragma solidity ^0.8.10;

interface ArbGasInfo {
    // return gas prices in wei, assuming the specified aggregator is used
    //        (
    //            per L2 tx,
    //            per L1 calldata unit, (zero byte = 4 units, nonzero byte = 16 units)
    //            per storage allocation,
    //            per ArbGas base,
    //            per ArbGas congestion,
    //            per ArbGas total
    //        )
    function getPricesInWeiWithAggregator(
        address aggregator
    ) external view returns (uint, uint, uint, uint, uint, uint);

    // return gas prices in wei, as described above, assuming the caller's preferred aggregator is used
    //     if the caller hasn't specified a preferred aggregator, the default aggregator is assumed
    function getPricesInWei()
        external
        view
        returns (uint, uint, uint, uint, uint, uint);

    // return prices in ArbGas (per L2 tx, per L1 calldata unit, per storage allocation),
    //       assuming the specified aggregator is used
    function getPricesInArbGasWithAggregator(
        address aggregator
    ) external view returns (uint, uint, uint);

    // return gas prices in ArbGas, as described above, assuming the caller's preferred aggregator is used
    //     if the caller hasn't specified a preferred aggregator, the default aggregator is assumed
    function getPricesInArbGas() external view returns (uint, uint, uint);

    // return gas accounting parameters (speedLimitPerSecond, gasPoolMax, maxTxGasLimit)
    function getGasAccountingParams() external view returns (uint, uint, uint);

    // get ArbOS's estimate of the L1 gas price in wei
    function getL1GasPriceEstimate() external view returns (uint);

    // set ArbOS's estimate of the L1 gas price in wei
    // reverts unless called by chain owner or designated gas oracle (if any)
    function setL1GasPriceEstimate(uint priceInWei) external;

    // get L1 gas fees paid by the current transaction (txBaseFeeWei, calldataFeeWei)
    function getCurrentTxL1GasFees() external view returns (uint);
}

interface ArbSys {
    /**
     * @notice Get Arbitrum block number (distinct from L1 block number; Arbitrum genesis block has block number 0)
     * @return block number as int
     */
    function arbBlockNumber() external view returns (uint256);

    /**
     * @notice Get Arbitrum block hash (reverts unless currentBlockNum-256 <= arbBlockNum < currentBlockNum)
     * @return block hash
     */
    function arbBlockHash(uint256 arbBlockNum) external view returns (bytes32);

    /**
     * @notice Gets the rollup's unique chain identifier
     * @return Chain identifier as int
     */
    function arbChainID() external view returns (uint256);

    /**
     * @notice Get internal version number identifying an ArbOS build
     * @return version number as int
     */
    function arbOSVersion() external view returns (uint256);

    /**
     * @notice Returns 0 since Nitro has no concept of storage gas
     * @return uint 0
     */
    function getStorageGasAvailable() external view returns (uint256);

    /**
     * @notice (deprecated) check if current call is top level (meaning it was triggered by an EoA or a L1 contract)
     * @dev this call has been deprecated and may be removed in a future release
     * @return true if current execution frame is not a call by another L2 contract
     */
    function isTopLevelCall() external view returns (bool);

    /**
     * @notice map L1 sender contract address to its L2 alias
     * @param sender sender address
     * @param unused argument no longer used
     * @return aliased sender address
     */
    function mapL1SenderContractAddressToL2Alias(
        address sender,
        address unused
    ) external pure returns (address);

    /**
     * @notice check if the caller (of this caller of this) is an aliased L1 contract address
     * @return true iff the caller's address is an alias for an L1 contract address
     */
    function wasMyCallersAddressAliased() external view returns (bool);

    /**
     * @notice return the address of the caller (of this caller of this), without applying L1 contract address aliasing
     * @return address of the caller's caller, without applying L1 contract address aliasing
     */
    function myCallersAddressWithoutAliasing() external view returns (address);

    /**
     * @notice Send given amount of Eth to dest from sender.
     * This is a convenience function, which is equivalent to calling sendTxToL1 with empty data.
     * @param destination recipient address on L1
     * @return unique identifier for this L2-to-L1 transaction.
     */
    function withdrawEth(
        address destination
    ) external payable returns (uint256);

    /**
     * @notice Send a transaction to L1
     * @dev it is not possible to execute on the L1 any L2-to-L1 transaction which contains data
     * to a contract address without any code (as enforced by the Bridge contract).
     * @param destination recipient address on L1
     * @param data (optional) calldata for L1 contract call
     * @return a unique identifier for this L2-to-L1 transaction.
     */
    function sendTxToL1(
        address destination,
        bytes calldata data
    ) external payable returns (uint256);

    /**
     * @notice Get send Merkle tree state
     * @return size number of sends in the history
     * @return root root hash of the send history
     * @return partials hashes of partial subtrees in the send history tree
     */
    function sendMerkleTreeState()
        external
        view
        returns (uint256 size, bytes32 root, bytes32[] memory partials);

    /**
     * @notice creates a send txn from L2 to L1
     * @param position = (level << 192) + leaf = (0 << 192) + leaf = leaf
     */
    event L2ToL1Tx(
        address caller,
        address indexed destination,
        uint256 indexed hash,
        uint256 indexed position,
        uint256 arbBlockNum,
        uint256 ethBlockNum,
        uint256 timestamp,
        uint256 callvalue,
        bytes data
    );

    /// @dev DEPRECATED in favour of the new L2ToL1Tx event above after the nitro upgrade
    event L2ToL1Transaction(
        address caller,
        address indexed destination,
        uint256 indexed uniqueId,
        uint256 indexed batchNumber,
        uint256 indexInBatch,
        uint256 arbBlockNum,
        uint256 ethBlockNum,
        uint256 timestamp,
        uint256 callvalue,
        bytes data
    );

    /**
     * @notice logs a merkle branch for proof synthesis
     * @param reserved an index meant only to align the 4th index with L2ToL1Transaction's 4th event
     * @param hash the merkle hash
     * @param position = (level << 192) + leaf
     */
    event SendMerkleUpdate(
        uint256 indexed reserved,
        bytes32 indexed hash,
        uint256 indexed position
    );
}

//@dev A library that abstracts out opcodes that behave differently across chains.
//@dev The methods below return values that are pertinent to the given chain.
//@dev For instance, ChainSpecificUtil.getBlockNumber() returns L2 block number in L2 chains
library ChainSpecificUtil {
    address private constant ARBSYS_ADDR =
        address(0x0000000000000000000000000000000000000064);
    ArbSys private constant ARBSYS = ArbSys(ARBSYS_ADDR);
    address private constant ARBGAS_ADDR =
        address(0x000000000000000000000000000000000000006C);
    ArbGasInfo private constant ARBGAS = ArbGasInfo(ARBGAS_ADDR);
    uint256 private constant ARB_MAINNET_CHAIN_ID = 42161;
    uint256 private constant ARB_GOERLI_TESTNET_CHAIN_ID = 421613;

    function getBlockhash(uint256 blockNumber) internal view returns (bytes32) {
        uint256 chainid = block.chainid;
        if (
            chainid == ARB_MAINNET_CHAIN_ID ||
            chainid == ARB_GOERLI_TESTNET_CHAIN_ID
        ) {
            if (
                (getBlockNumber() - blockNumber) > 256 ||
                blockNumber >= getBlockNumber()
            ) {
                return "";
            }
            return ARBSYS.arbBlockHash(blockNumber);
        }
        return blockhash(blockNumber);
    }

    function getBlockNumber() internal view returns (uint256) {
        uint256 chainid = block.chainid;
        if (
            chainid == ARB_MAINNET_CHAIN_ID ||
            chainid == ARB_GOERLI_TESTNET_CHAIN_ID
        ) {
            return ARBSYS.arbBlockNumber();
        }
        return block.number;
    }

    function getCurrentTxL1GasFees() internal view returns (uint256) {
        uint256 chainid = block.chainid;
        if (
            chainid == ARB_MAINNET_CHAIN_ID ||
            chainid == ARB_GOERLI_TESTNET_CHAIN_ID
        ) {
            return ARBGAS.getCurrentTxL1GasFees();
        }
        return 0;
    }
}
// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {IDAO} from "./interface/IDAO.sol";
import "./ChainSpecificUtil.sol";

contract HashBet is Ownable, ReentrancyGuard {
    // Modulo is the number of equiprobable outcomes in a game:
    //  2 for coin flip
    //  6 for dice roll
    //  6*6 = 36 for double dice
    //  37 for roulette
    //  100 for hashroll
    uint constant MAX_MODULO = 100;

    // Modulos below MAX_MASK_MODULO are checked against a bit mask, allowing betting on specific outcomes.
    // For example in a dice roll (modolo = 6),
    // 000001 mask means betting on 1. 000001 converted from binary to decimal becomes 1.
    // 101000 mask means betting on 4 and 6. 101000 converted from binary to decimal becomes 40.
    // The specific value is dictated by the fact that 256-bit intermediate
    // multiplication result allows implementing population count efficiently
    // for numbers that are up to 42 bits, and 40 is the highest multiple of
    // eight below 42.
    uint constant MAX_MASK_MODULO = 40;

    // EVM BLOCKHASH opcode can query no further than 256 blocks into the
    // past. Given that settleBet uses block hash of placeBet as one of
    // complementary entropy sources, we cannot process bets older than this
    // threshold. On rare occasions dice2.win croupier may fail to invoke
    // settleBet in this timespan due to technical issues or extreme Ethereum
    // congestion; such bets can be refunded via invoking refundBet.
    uint constant BET_EXPIRATION_BLOCKS = 250;

    // Some deliberately invalid address to initialize the secret signer with.
    // Forces maintainers to invoke setCroupier before processing any bets.
    address constant DUMMY_ADDRESS = 0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE;

    // This is a check on bet mask overflow. Maximum mask is equivalent to number of possible binary outcomes for maximum modulo.
    uint constant MAX_BET_MASK = 2 ** MAX_MASK_MODULO;

    // These are constants taht make O(1) population count in placeBet possible.
    uint constant POPCNT_MULT =
        0x0000000000002000000000100000000008000000000400000000020000000001;
    uint constant POPCNT_MASK =
        0x0001041041041041041041041041041041041041041041041041041041041041;
    uint constant POPCNT_MODULO = 0x3F;

    // Sum of all historical deposits and withdrawals. Used for calculating profitability. Profit = Balance - cumulativeDeposit + cumulativeWithdrawal
    uint public cumulativeDeposit;
    uint public cumulativeWithdrawal;

    // In addition to house edge, wealth tax is added every time the bet amount exceeds a multiple of a threshold.
    // For example, if wealthTaxIncrementThreshold = 3000 ether,
    // A bet amount of 3000 ether will have a wealth tax of 1% in addition to house edge.
    // A bet amount of 6000 ether will have a wealth tax of 2% in addition to house edge.
    uint public wealthTaxIncrementThreshold = 3000 ether;
    uint public wealthTaxIncrementPercent = 1;

    // The minimum and maximum bets.
    uint public minBetAmount = 0.01 ether;
    uint public maxBetAmount = 10000 ether;

    // max bet profit. Used to cap bets against dynamic odds.
    uint public maxProfit = 300000 ether;

    // Funds that are locked in potentially winning bets. Prevents contract from committing to new bets that it cannot pay out.
    mapping(address => uint256) public lockedInBets;

    // The minimum larger comparison value.
    uint public minOverValue = 1;

    // The maximum smaller comparison value.
    uint public maxUnderValue = 98;

    // Croupier account.
    address public croupier;

    // address for DAO management operations
    address public dao;

    // Info of each bet.
    struct Bet {
        uint betID;
        // Wager amount in wei.
        uint wager;
        // Modulo of a game.
        uint8 modulo;
        // Number of winning outcomes, used to compute winning payment (* modulo/rollEdge),
        // and used instead of mask for games with modulo > MAX_MASK_MODULO.
        uint8 rollEdge;
        // Bit mask representing winning bet outcomes (see MAX_MASK_MODULO comment).
        uint40 mask;
        // Block number of placeBet tx.
        uint placeBlockNumber;
        // Address of a gambler, used to pay out winning bets.
        address payable gambler;
        // Status of bet settlement.
        bool isSettled;
        // Win amount.
        uint winAmount;
        // Keccak256 hash of some secret "reveal" random number.
        uint256[] commits;
        // Comparison method.
        bool isLarger;
        uint256 stopGain;
        uint256 stopLoss;
        address tokenAddress;
    }

    // Each bet is deducted dynamic
    uint public defaultHouseEdgePercent = 2;

    // Mapping from commits to all currently active & processed bets.
    mapping(uint => Bet) public bets;

    mapping(uint32 => uint32) public houseEdgePercents;

    // stable token that we use to deposit/withdrawal
    mapping(address => bool) public whitelistedERC20;

    // Events
    event BetPlaced(
        address indexed gambler,
        uint256 wager,
        uint8 indexed modulo,
        uint8 rollEdge,
        uint40 mask,
        uint256[] commits,
        bool isLarger,
        uint256 betID
    );
    event BetSettled(
        address indexed gambler,
        uint256 wager,
        uint8 indexed modulo,
        uint8 rollEdge,
        uint40 mask,
        uint256[] outcomes,
        uint256[] payouts,
        uint256 payout,
        uint32 numGames,
        uint256 betID
    );
    event BetRefunded(address indexed gambler, uint256 betID, uint256 amount);

    event TransferFunds(
        uint256 indexed id,
        address indexed to,
        address indexed token,
        uint256 amount
    );

    /**
     * @dev Emitted when `value` tokens are moved from one account (`from`) to
     * another (`to`).
     *
     * Note that `value` may be zero.
     */
    event Transfer(address indexed from, address indexed to, uint256 value);

    constructor() Ownable() {
        croupier = DUMMY_ADDRESS;
        houseEdgePercents[2] = 1;
        houseEdgePercents[6] = 1;
        houseEdgePercents[36] = 1;
        houseEdgePercents[37] = 1;
        houseEdgePercents[100] = 1;
    }

    modifier onlyWhitelist(address token) {
        require(whitelistedERC20[token], "OW");
        _;
    }

    // Standard modifier on methods invokable only by contract owner.
    modifier onlyCroupier() {
        require(msg.sender == croupier, "OC");
        _;
    }

    // any admin can whitelist new erc20 token to use
    function whitelistERC20(address token) external onlyOwner {
        whitelistedERC20[token] = true;
    }

    // any admin can unwhitelist erc20 token to use
    function unwhitelistERC20(address token) external onlyOwner {
        require(whitelistedERC20[token], "W");
        delete whitelistedERC20[token];
    }

    // getter for IERC20 of some token
    function getIERC(address token) internal pure returns (IERC20) {
        // allow only whitelisted tokens
        return IERC20(token);
    }

    // getter for total lockedInBets funds for some token
    function getLockedInBets(address token) external view returns (uint256) {
        return lockedInBets[token];
    }

    function getBalance(address token) external view returns (uint256) {
        if (token != address(0)) {
            return getIERC(token).balanceOf(address(this));
        } else {
            return address(this).balance;
        }
    }

    // Fallback payable function used to top up the bank roll.
    fallback() external payable {}

    receive() external payable {
        emit Transfer(msg.sender, address(this), msg.value);
    }

    // Set default house edge percent
    function setDefaultHouseEdgePercent(
        uint _houseEdgePercent
    ) external onlyOwner {
        require(
            _houseEdgePercent >= 1 && _houseEdgePercent <= 100,
            "houseEdgePercent must be a sane number"
        );
        defaultHouseEdgePercent = _houseEdgePercent;
    }

    // Set modulo house edge percent
    function setModuloHouseEdgePercent(
        uint32 _houseEdgePercent,
        uint32 modulo
    ) external onlyOwner {
        require(
            _houseEdgePercent >= 1 && _houseEdgePercent <= 100,
            "houseEdgePercent must be a sane number"
        );
        houseEdgePercents[modulo] = _houseEdgePercent;
    }

    // Set min bet amount. minBetAmount should be large enough such that its house edge fee can cover the Chainlink oracle fee.
    function setMinBetAmount(uint _minBetAmount) external onlyOwner {
        minBetAmount = _minBetAmount * 1 gwei;
    }

    // Set max bet amount.
    function setMaxBetAmount(uint _maxBetAmount) external onlyOwner {
        require(
            _maxBetAmount < 5000000 ether,
            "maxBetAmount must be a sane number"
        );
        maxBetAmount = _maxBetAmount;
    }

    // Set max bet reward. Setting this to zero effectively disables betting.
    function setMaxProfit(uint _maxProfit) external onlyOwner {
        require(_maxProfit < 50000000 ether, "maxProfit must be a sane number");
        maxProfit = _maxProfit;
    }

    // Set wealth tax percentage to be added to house edge percent. Setting this to zero effectively disables wealth tax.
    function setWealthTaxIncrementPercent(
        uint _wealthTaxIncrementPercent
    ) external onlyOwner {
        wealthTaxIncrementPercent = _wealthTaxIncrementPercent;
    }

    // Set threshold to trigger wealth tax.
    function setWealthTaxIncrementThreshold(
        uint _wealthTaxIncrementThreshold
    ) external onlyOwner {
        wealthTaxIncrementThreshold = _wealthTaxIncrementThreshold;
    }

    // Change the croupier address.
    function setCroupier(address newCroupier) external onlyOwner {
        require(newCroupier != address(0), "0"); //0x0 addr
        croupier = newCroupier;
    }

    function setInitialDao(address initialDaoAddress) external onlyOwner {
        require(dao == address(0), "dao not empty");
        require(initialDaoAddress != address(0), "0"); //0x0 addr
        dao = initialDaoAddress;
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(
        address
    ) public virtual override onlyOwner {
        revert("Unimplemented");
    }

    // request to change DAO address
    function daoChange(uint256 id) external {
        address currentDAO = dao;
        dao = IDAO(currentDAO).isDAOChangeAvailable(id);
        require(
            dao != address(0),
            "New dao is the zero address"
        );
        require(IDAO(currentDAO).confirmDAOChange(id), "N"); // not confirmed
    }

    // request to DAO for change owner
    function ownerChange(uint256 id) external {
        address newOwner = IDAO(dao).isOwnerChangeAvailable(id);
        require(
            newOwner != address(0),
            "Ownable: new owner is the zero address"
        );
        _transferOwnership(newOwner);
        require(IDAO(dao).confirmOwnerChange(id), "C"); //not confirmed
    }

    // request to DAO for transfer funds
    function transferFunds(uint256 id) external {
        address token;
        uint256 amount;
        address recepient;
        (amount, recepient, token) = IDAO(dao).isTransferAvailable(id);
        require(amount <= this.getBalance(token) - lockedInBets[token], "R"); // not enough reserve

        doTransfer(recepient, token, amount);

        require(IDAO(dao).confirmTransfer(id), "N"); // not confirmed
        emit TransferFunds(id, recepient, token, amount);
    }

    // Place bet
    function placeBet(
        uint256 betID,
        uint256 wager,
        uint betMask,
        uint modulo,
        uint commitLastBlock,
        bool isLarger,
        uint256[] calldata commits,
        uint256 stopGain,
        uint256 stopLoss,
        address tokenAddress
    ) external payable onlyCroupier onlyWhitelist(tokenAddress) nonReentrant {
        Bet storage bet = bets[betID];
        require(bet.gambler == address(0), "Bet should be in a 'clean' state.");

        bet.betID = betID;

        validateArguments(
            betID,
            wager,
            betMask,
            modulo,
            commitLastBlock,
            isLarger,
            commits,
            stopGain,
            stopLoss
        );

        if (modulo <= MAX_MASK_MODULO) {
            // Small modulo games can specify exact bet outcomes via bit mask.
            // rollEdge is a number of 1 bits in this mask (population count).
            // This magic looking formula is an efficient way to compute population
            // count on EVM for numbers below 2**40.
            bet.rollEdge = uint8(
                ((betMask * POPCNT_MULT) & POPCNT_MASK) % POPCNT_MODULO
            );
            bet.mask = uint40(betMask);
        } else {
            // Larger modulos games specify the right edge of half-open interval of winning bet outcomes.
            bet.rollEdge = uint8(betMask);
        }

        bet.wager = wager;
        // Winning amount.
        bet.winAmount = getDiceWinAmount(
            bet.wager,
            modulo,
            bet.rollEdge,
            isLarger
        );

        checkBalance(tokenAddress, bet.winAmount * commits.length);
        bet.tokenAddress = tokenAddress;

        // Store bet
        bet.modulo = uint8(modulo);
        bet.placeBlockNumber = ChainSpecificUtil.getBlockNumber();
        bet.gambler = payable(msg.sender);
        bet.isSettled = false;
        bet.commits = commits;
        bet.isLarger = isLarger;
        bet.stopGain = stopGain;
        bet.stopLoss = stopLoss;

        // Record bet in event logs
        emit BetPlaced(
            msg.sender,
            bet.wager,
            bet.modulo,
            bet.rollEdge,
            bet.mask,
            bet.commits,
            bet.isLarger,
            bet.betID
        );
    }

    // Get the expected win amount after house edge is subtracted.
    function getDiceWinAmount(
        uint amount,
        uint modulo,
        uint rollEdge,
        bool isLarger
    ) private view returns (uint winAmount) {
        require(
            0 < rollEdge && rollEdge <= modulo,
            "Win probability out of range."
        );
        uint houseEdge = (amount *
            (getModuloHouseEdgePercent(uint32(modulo)) +
                getWealthTax(amount))) / 100;
        uint realRollEdge = rollEdge;
        if (modulo == MAX_MODULO && isLarger) {
            realRollEdge = MAX_MODULO - rollEdge - 1;
        }
        winAmount = ((amount - houseEdge) * modulo) / realRollEdge;

        // round down to multiple 1000Gweis
        winAmount = (winAmount / 1e12) * 1e12;

        uint maxWinAmount = amount + maxProfit;

        if (winAmount > maxWinAmount) {
            winAmount = maxWinAmount;
        }
    }

    // Get wealth tax
    function getWealthTax(uint amount) private view returns (uint wealthTax) {
        wealthTax =
            (amount / wealthTaxIncrementThreshold) *
            wealthTaxIncrementPercent;
    }

    // This is the method used to settle 99% of bets. To process a bet with a specific
    // "commit", settleBet should supply a "reveal" number that would Keccak256-hash to
    // "commit". "blockHash" is the block hash of placeBet block as seen by croupier; it
    // is additionally asserted to prevent changing the bet outcomes on Ethereum reorgs.
    function settleBet(
        uint256 betID,
        uint256[] calldata reveal,
        bytes32 blockHash
    ) external onlyCroupier {
        Bet storage bet = bets[betID];
        require(bet.gambler != address(0), "Bet should be in a 'bet' state.");
        // Fetch bet parameters into local variables (to save gas).
        uint wager = bet.wager;
        // Validation check
        require(wager > 0, "Bet does not exist."); // Check that bet exists
        require(bet.isSettled == false, "Bet is settled already"); // Check that bet is not settled yet
        require(
            bet.commits.length == reveal.length,
            "Settlement data mismatch"
        ); // wrong settlement data

        uint placeBlockNumber = bet.placeBlockNumber;
        // Check that bet has not expired yet (see comment to BET_EXPIRATION_BLOCKS).
        require(
            ChainSpecificUtil.getBlockNumber() > placeBlockNumber,
            "settleBet before placeBet"
        );

        uint256 numBets = bet.commits.length;
        uint32 i = 0;
        int256 totalValue = 0;
        uint256 payout = 0;

        uint256[] memory outcomes = new uint256[](numBets);
        uint256[] memory payouts = new uint256[](numBets);

        for (i = 0; i < numBets; i++) {
            if (bet.stopGain > 0 && totalValue >= int256(bet.stopGain)) {
                break;
            }
            if (bet.stopLoss > 0 && totalValue <= -int256(bet.stopLoss)) {
                break;
            }
            uint curReval = reveal[i];
            bytes32 curBlockHash = blockHash;
            uint commit = uint256(keccak256(abi.encodePacked(curReval)));
            require(bet.commits[i] == commit, "Reveal data mismatch");

            // Settle bet using reveal and blockHash as entropy sources.
            (uint256 winAmount, uint256 outcome) = settleBetCommon(
                bet,
                curReval,
                curBlockHash
            );
            outcomes[i] = outcome;

            if (winAmount > 0) {
                totalValue += int256(winAmount - bet.wager);
                payout += winAmount;
                payouts[i] = winAmount;
                continue;
            }

            totalValue -= int256(bet.wager);
        }

        payout += (numBets - i) * bet.wager;

        // Win amount if gambler wins this bet
        uint possibleWinAmount = bet.winAmount;
        // Unlock possibleWinAmount from lockedInBets, regardless of the outcome.
        lockedInBets[bet.tokenAddress] -= (possibleWinAmount *
            bet.commits.length);

        // Update bet records
        bet.isSettled = true;
        uint curBetID = bet.betID;

        emit BetSettled(
            bet.gambler,
            bet.wager,
            uint8(bet.modulo),
            uint8(bet.rollEdge),
            bet.mask,
            outcomes,
            payouts,
            payout,
            i,
            curBetID
        );
    }

    // Common settlement code for settleBet & settleBetUncleMerkleProof.
    function settleBetCommon(
        Bet storage bet,
        uint reveal,
        bytes32 entropyBlockHash
    ) private view returns (uint256 winAmount, uint256 outcome) {
        // Fetch bet parameters into local variables (to save gas).
        uint modulo = bet.modulo;
        uint rollEdge = bet.rollEdge;
        bool isLarger = bet.isLarger;

        // The RNG - combine "reveal" and blockhash of placeBet using Keccak256. Miners
        // are not aware of "reveal" and cannot deduce it from "commit" (as Keccak256
        // preimage is intractable), and house is unable to alter the "reveal" after
        // placeBet have been mined (as Keccak256 collision finding is also intractable).
        bytes32 entropy = keccak256(abi.encodePacked(reveal, entropyBlockHash));

        // Do a roll by taking a modulo of entropy. Compute winning amount.
        outcome = uint(entropy) % modulo;

        // Win amount if gambler wins this bet
        uint possibleWinAmount = bet.winAmount;

        // Actual win amount by gambler
        winAmount = 0;

        // Determine dice outcome.
        if (modulo <= MAX_MASK_MODULO) {
            // For small modulo games, check the outcome against a bit mask.
            if ((2 ** outcome) & bet.mask != 0) {
                winAmount = possibleWinAmount;
            }
        } else {
            // For larger modulos, check inclusion into half-open interval.
            if (isLarger) {
                if (outcome > rollEdge) {
                    winAmount = possibleWinAmount;
                }
            } else {
                if (outcome < rollEdge) {
                    winAmount = possibleWinAmount;
                }
            }
        }
    }

    // Return the bet in extremely unlikely scenario it was not settled by Chainlink VRF.
    // In case you ever find yourself in a situation like this, just contact hashbet support.
    // However, nothing precludes you from calling this method yourself.
    function refundBet(uint256 betID) external payable nonReentrant {
        Bet storage bet = bets[betID];
        uint amount = bet.wager * bet.commits.length;

        // Validation check
        require(amount > 0, "Bet does not exist."); // Check that bet exists
        require(bet.isSettled == false, "Bet is settled already."); // Check that bet is still open
        require(
            block.number > bet.placeBlockNumber + BET_EXPIRATION_BLOCKS,
            "Wait after placing bet before requesting refund."
        );

        uint possibleWinAmount = bet.winAmount;

        // Unlock possibleWinAmount from lockedInBets, regardless of the outcome.
        lockedInBets[bet.tokenAddress] -= (possibleWinAmount *
            bet.commits.length);

        // Update bet records
        bet.isSettled = true;
        bet.winAmount = 0;

        // Record refund in event logs
        emit BetRefunded(bet.gambler, betID, amount);
    }

    // Check arguments
    function validateArguments(
        uint256 betID,
        uint wager,
        uint betMask,
        uint modulo,
        uint commitLastBlock,
        bool isLarger,
        uint256[] calldata commits,
        uint256 stopGain,
        uint256 stopLoss
    ) private view {
        // Validate input data.
        require(
            modulo == 2 ||
                modulo == 6 ||
                modulo == 36 ||
                modulo == 37 ||
                modulo == 100,
            "Modulo should be valid value."
        );
        require(
            wager >= minBetAmount && wager <= maxBetAmount,
            "Bet amount should be within range."
        );
        require(
            betMask > 0 && betMask < MAX_BET_MASK,
            "Mask should be within range."
        );

        require(
            commits.length >= 1 && commits.length <= 100,
            "Invalid commits length"
        );

        // Check that commit is valid - it has not expired and its signature is valid.
        require(
            ChainSpecificUtil.getBlockNumber() <= commitLastBlock,
            "Commit has expired."
        );

        if (modulo <= MAX_MASK_MODULO) {
            require(
                betMask > 0 && betMask < MAX_BET_MASK,
                "Mask should be within range."
            );
        }

        if (modulo == MAX_MODULO) {
            require(
                betMask >= minOverValue && betMask <= maxUnderValue,
                "High modulo range, Mask should be within range."
            );
        }
    }

    function getModuloHouseEdgePercent(
        uint32 modulo
    ) internal view returns (uint32 houseEdgePercent) {
        houseEdgePercent = houseEdgePercents[modulo];
        if (houseEdgePercent == 0) {
            houseEdgePercent = uint32(defaultHouseEdgePercent);
        }
    }

    function checkBalance(address tokenAddress, uint256 lockAmount) internal {
        // Check whether contract has enough funds to accept this bet.
        require(
            lockedInBets[tokenAddress] + lockAmount <= this.getBalance(tokenAddress),
            "Unable to accept bet due to insufficient funds"
        );

        // Update lock funds,lock single winning amount multipy number of bets
        lockedInBets[tokenAddress] += lockAmount;
    }

    function doTransfer(
        address recepient,
        address token,
        uint256 amount
    ) internal {
        if (token != address(0)) {
            require(getIERC(token).transfer(recepient, amount), "C"); // not transfered
        } else {
            (bool sent, ) = recepient.call{value: amount}("");
            require(sent, "F"); // not transfered
        }
    }
}
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IDAO {
    function isTransferAvailable(
        uint256 id
    ) external view returns (uint256, address, address);

    function confirmTransfer(uint256 id) external returns (bool);

    function isOwnerChangeAvailable(uint256 id) external view returns (address);

    function confirmOwnerChange(uint256 id) external returns (bool);

    function isDAOChangeAvailable(uint256 id) external view returns (address);

    function confirmDAOChange(uint256 id) external returns (bool);
}
