/*
    SPDX-License-Identifier: MIT
    A Bankteller Production
    Elephant Money
    Copyright 2023
*/

/*
    Elephant Money Futures

    - A high yield cashhflow engine that earns 0.5% daily on cash 
    - Immutable contract and yield generation, 100% on-chain
    - Scalable and always open for business
    - Core yield generation is provided by the unstoppable and proven ELEPHANT Treasury buyback program
    - Deposit BNB and earn BNB rewards; no stable coin risk
    - Paid out at 0.5% daily of your remaining balance
    - Auto compound rewards on ever deposit 
    - Claim at any time down to the second
    - No fees or taxes of any kind
    - Yield is paid by a growing Elephant Treasury
    - 90% of funds market buy ELEPHANT
    - 10% of funds are held in a BNB Reserve for yield repayment
    - 200 USD deposit minimum, 1M USD max balance, 2.5M USD max payouts, and 50K USD max daily claim 

    Only at https://elephant.money

*/

pragma solidity 0.8.18;

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

abstract contract Context is ReentrancyGuard {

    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
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
    address private _previousOwner;
    bool private _paused;

    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );
    event RunStatusUpdated(bool indexed paused);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor() {
        address msgSender = _msgSender();
        _owner = msgSender;
        _paused = false;
        emit RunStatusUpdated(_paused);
        emit OwnershipTransferred(address(0), msgSender);
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view returns (address) {
        return _owner;
    }

    /**
     * @dev Returns if paused status
     */
    function isPaused() public view returns (bool) {
        return _paused;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(_owner == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    /**
     * @dev Throws if called when contract is paused
     */
    modifier isRunning() {
        require(
            _paused == false,
            "Function unavailable because contract is paused"
        );
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
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
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
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }

    /**
     * @dev Pause the contract for functions that check run status
     * Can only be called by the current owner.
     */
    function updateRunStatus(bool paused) public virtual onlyOwner {
        emit RunStatusUpdated(paused);
        _paused = paused;
    }

}

/**
 * @title Whitelist
 * @dev The Whitelist contract has a whitelist of addresses, and provides basic authorization control functions.
 * @dev This simplifies the implementation of "user permissions".
 */
contract Whitelist is Ownable {
    mapping(address => bool) public whitelist;

    event WhitelistedAddressAdded(address addr);
    event WhitelistedAddressRemoved(address addr);

    /**
     * @dev Throws if called by any account that's not whitelisted.
     */
    modifier onlyWhitelisted() {
        require(whitelist[msg.sender], "not whitelisted");
        _;
    }

    function addAddressToWhitelist(address addr)
        public
        onlyOwner
        returns (bool success)
    {
        if (!whitelist[addr]) {
            whitelist[addr] = true;
            emit WhitelistedAddressAdded(addr);
            success = true;
        }
    }

    function addAddressesToWhitelist(address[] memory addrs)
        public
        onlyOwner
        returns (bool success)
    {
        for (uint256 i = 0; i < addrs.length; i++) {
            if (addAddressToWhitelist(addrs[i])) {
                success = true;
            }
        }
    }

    function removeAddressFromWhitelist(address addr)
        public
        onlyOwner
        returns (bool success)
    {
        if (whitelist[addr]) {
            whitelist[addr] = false;
            emit WhitelistedAddressRemoved(addr);
            success = true;
        }
    }

    function removeAddressesFromWhitelist(address[] memory addrs)
        public
        onlyOwner
        returns (bool success)
    {
        for (uint256 i = 0; i < addrs.length; i++) {
            if (removeAddressFromWhitelist(addrs[i])) {
                success = true;
            }
        }
    }
}

// pragma solidity >=0.5.0;

interface IUniswapV2Factory {
    event PairCreated(
        address indexed token0,
        address indexed token1,
        address pair,
        uint256
    );

    function feeTo() external view returns (address);

    function feeToSetter() external view returns (address);

    function getPair(address tokenA, address tokenB)
        external
        view
        returns (address pair);

    function allPairs(uint256) external view returns (address pair);

    function allPairsLength() external view returns (uint256);

    function createPair(address tokenA, address tokenB)
        external
        returns (address pair);

    function setFeeTo(address) external;

    function setFeeToSetter(address) external;
}

// pragma solidity >=0.5.0;

interface IUniswapV2Pair {
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
    event Transfer(address indexed from, address indexed to, uint256 value);

    function name() external pure returns (string memory);

    function symbol() external pure returns (string memory);

    function decimals() external pure returns (uint8);

    function totalSupply() external view returns (uint256);

    function balanceOf(address owner) external view returns (uint256);

    function allowance(address owner, address spender)
        external
        view
        returns (uint256);

    function approve(address spender, uint256 value) external returns (bool);

    function transfer(address to, uint256 value) external returns (bool);

    function transferFrom(
        address from,
        address to,
        uint256 value
    ) external returns (bool);

    function DOMAIN_SEPARATOR() external view returns (bytes32);

    function PERMIT_TYPEHASH() external pure returns (bytes32);

    function nonces(address owner) external view returns (uint256);

    function permit(
        address owner,
        address spender,
        uint256 value,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external;

    event Mint(address indexed sender, uint256 amount0, uint256 amount1);
    event Burn(
        address indexed sender,
        uint256 amount0,
        uint256 amount1,
        address indexed to
    );
    event Swap(
        address indexed sender,
        uint256 amount0In,
        uint256 amount1In,
        uint256 amount0Out,
        uint256 amount1Out,
        address indexed to
    );
    event Sync(uint112 reserve0, uint112 reserve1);

    function MINIMUM_LIQUIDITY() external pure returns (uint256);

    function factory() external view returns (address);

    function token0() external view returns (address);

    function token1() external view returns (address);

    function getReserves()
        external
        view
        returns (
            uint112 reserve0,
            uint112 reserve1,
            uint32 blockTimestampLast
        );

    function price0CumulativeLast() external view returns (uint256);

    function price1CumulativeLast() external view returns (uint256);

    function kLast() external view returns (uint256);

    function mint(address to) external returns (uint256 liquidity);

    function burn(address to)
        external
        returns (uint256 amount0, uint256 amount1);

    function swap(
        uint256 amount0Out,
        uint256 amount1Out,
        address to,
        bytes calldata data
    ) external;

    function skim(address to) external;

    function sync() external;

    function initialize(address, address) external;
}

// pragma solidity >=0.6.2;

interface IUniswapV2Router01 {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);

    function addLiquidity(
        address tokenA,
        address tokenB,
        uint256 amountADesired,
        uint256 amountBDesired,
        uint256 amountAMin,
        uint256 amountBMin,
        address to,
        uint256 deadline
    )
        external
        returns (
            uint256 amountA,
            uint256 amountB,
            uint256 liquidity
        );

    function addLiquidityETH(
        address token,
        uint256 amountTokenDesired,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline
    )
        external
        payable
        returns (
            uint256 amountToken,
            uint256 amountETH,
            uint256 liquidity
        );

    function removeLiquidity(
        address tokenA,
        address tokenB,
        uint256 liquidity,
        uint256 amountAMin,
        uint256 amountBMin,
        address to,
        uint256 deadline
    ) external returns (uint256 amountA, uint256 amountB);

    function removeLiquidityETH(
        address token,
        uint256 liquidity,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline
    ) external returns (uint256 amountToken, uint256 amountETH);

    function removeLiquidityWithPermit(
        address tokenA,
        address tokenB,
        uint256 liquidity,
        uint256 amountAMin,
        uint256 amountBMin,
        address to,
        uint256 deadline,
        bool approveMax,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external returns (uint256 amountA, uint256 amountB);

    function removeLiquidityETHWithPermit(
        address token,
        uint256 liquidity,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline,
        bool approveMax,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external returns (uint256 amountToken, uint256 amountETH);

    function swapExactTokensForTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);

    function swapTokensForExactTokens(
        uint256 amountOut,
        uint256 amountInMax,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);

    function swapExactETHForTokens(
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external payable returns (uint256[] memory amounts);

    function swapTokensForExactETH(
        uint256 amountOut,
        uint256 amountInMax,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);

    function swapExactTokensForETH(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);

    function swapETHForExactTokens(
        uint256 amountOut,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external payable returns (uint256[] memory amounts);

    function quote(
        uint256 amountA,
        uint256 reserveA,
        uint256 reserveB
    ) external pure returns (uint256 amountB);

    function getAmountOut(
        uint256 amountIn,
        uint256 reserveIn,
        uint256 reserveOut
    ) external pure returns (uint256 amountOut);

    function getAmountIn(
        uint256 amountOut,
        uint256 reserveIn,
        uint256 reserveOut
    ) external pure returns (uint256 amountIn);

    function getAmountsOut(uint256 amountIn, address[] calldata path)
        external
        view
        returns (uint256[] memory amounts);

    function getAmountsIn(uint256 amountOut, address[] calldata path)
        external
        view
        returns (uint256[] memory amounts);
}

// pragma solidity >=0.6.2;

interface IUniswapV2Router02 is IUniswapV2Router01 {
    function removeLiquidityETHSupportingFeeOnTransferTokens(
        address token,
        uint256 liquidity,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline
    ) external returns (uint256 amountETH);

    function removeLiquidityETHWithPermitSupportingFeeOnTransferTokens(
        address token,
        uint256 liquidity,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline,
        bool approveMax,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external returns (uint256 amountETH);

    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external;

    function swapExactETHForTokensSupportingFeeOnTransferTokens(
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external payable;

    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external;
}

interface IERC20 {
    /**
     * @dev Function to mint tokens
     * @param _to The address that will receive the minted tokens.
     * @param _amount The amount of tokens to mint.
     * @return A boolean that indicates if the operation was successful.
     */
    function mint(address _to, uint256 _amount) external returns (bool);

    /**
     * @dev Burns the amount of tokens owned by `msg.sender`.
     */
    function burn(uint256 _value) external;

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

interface IElephantYieldEngine {

    function yield(address _user, uint256 _amount)
        external
        returns (uint256  yieldAmount);

    function estimateCollateralToCore(uint256 collateralAmount)
        external
        view
        returns (uint256 wethAmount, uint256 coreAmount);
}

interface ITreasury {
    function withdraw(uint256 tokenAmount) external;

    function withdrawTo(address _to, uint256 _amount) external;
}

interface ITreasuryV2 {
    function withdraw(address _to, uint256 _amount, bool _force) external;

    function withdrawToken(address _to, address _tokenAddress, uint256 _amount, bool _force) external;
}

interface ISponsorData {
    
    function add(address _user, uint256 _amount) external;

    function settle(address _user) external;
}

//@dev Callback function called by FarmEngine.yield upon completion
interface IReferralReport {
    function reward_distribution(address _referrer, address _user, uint _referrer_reward, uint _user_reward) external;

}

interface IEACAggregatorProxy {

    function latestRoundData() external view returns (uint80 roundId , int256 answer , uint256 startedAt , uint256 updatedAt , uint80 answeredInRound);

    function decimals() external view returns (uint8);

}

interface IPcsPeriodicTwapOracle {

    // performs chained update calculations on any number of pairs
    //whitelisted to avoid DDOS attacks since new pairs will be registered
    function updatePath(address[] memory path) external;

    //updates all pairs registered 
    function updateAll() external returns (uint updatedPairs) ;
    
    // performs chained getAmountOut calculations on any number of pairs
    function consultAmountsOut(uint amountIn, address[] memory path) external view returns (uint[] memory amounts);

    // returns the amount out corresponding to the amount in for a given token using the moving average over the time
    // range [now - [windowSize, windowSize - periodSize * 2], now]
    // update must have been called for the bucket corresponding to timestamp `now - windowSize`
    function consult(address tokenIn, uint amountIn, address tokenOut) external view returns (uint amountOut);

}

///@dev Simple onchain referral storage
interface IReferralData {
    
    function updateReferral(address referrer) external ;

    ///@dev Return the referral of the sender
    function myReferrer() external view returns (address);

    //@dev Return true if referrer of user is sender
    function isMyReferral(address _user) external view returns (bool);

    //@dev Return true if user has a referrer
    function hasReferrer(address _user) external view returns (bool);

    ///@dev Return the referral of a participant
    function referrerOf(address participant) external view returns (address) ;

    ///@dev Return the referral count of a participant
    function referralCountOf(address _user) external view returns (uint256) ;
}

//@dev Tracks summary information for users across all farms
struct FuturesUser {
    bool exists; //has the user joined
    uint deposits; //total inbound deposits
    uint compound_deposits; //compound deposit; not fresh capital 
    uint current_balance; //current balance
    uint payouts;  //total yield payouts across all farms
    uint rewards; //partner rewards
    uint last_time; //last interaction
}

struct FuturesGlobals {
    uint256  total_users;
    uint256  total_deposited;
    uint256  total_compound_deposited;
    uint256  total_claimed;
    uint256  total_rewards;
    uint256  total_txs;
    uint256  current_balance;
}

//@dev Immutable Vault that stores ledger for Elephant Money Futures
contract FuturesVault is Whitelist {
    mapping(address => FuturesUser) private users; //Asset -> User

    FuturesGlobals private globals;

    constructor() Ownable() {}


    //@dev Get User info
    function getUser(address _user) external view returns (FuturesUser memory) {
        return users[_user];
    }

    //@dev Get FuturesGlobal info
    function getGlobals() external view returns (FuturesGlobals memory) {
        return globals;
    }

    //@dev commit User Info
    function commitUser(address _user, FuturesUser memory _user_data)  onlyWhitelisted isRunning external {

        //update user
        users[_user].exists = _user_data.exists; 
        users[_user].deposits = _user_data.deposits; 
        users[_user].compound_deposits = _user_data.compound_deposits;  
        users[_user].current_balance = _user_data.current_balance; 
        users[_user].payouts = _user_data.payouts;  
        users[_user].rewards = _user_data.rewards; 
        users[_user].last_time = _user_data.last_time;

    }

    //@dev commit Globals Info
    function commitGlobals(FuturesGlobals memory _globals) onlyWhitelisted isRunning external {

        //update globals
        globals.total_users = _globals.total_users;
        globals.total_deposited = _globals.total_deposited;
        globals.total_compound_deposited = _globals.total_compound_deposited;
        globals.total_claimed = _globals.total_claimed;
        globals.total_rewards = _globals.total_rewards;
        globals.total_txs = _globals.total_txs;
        globals.current_balance = _globals.current_balance ;
        
    }

}

//@dev  Business logic for Elephan Money Futures
//Engine can be swapped out if upgrades are needed
//Only yield infrastructure and vault can be updated
contract FuturesEngine is Ownable {
    using SafeMath for uint256;

    AddressRegistry private registry;

    //Financial Model
    uint256 public constant referenceApr = 182.5e18; //0.5% daily
    uint256 public constant maxBalance = 1000000e18; //1M
    uint256 public constant minimumDeposit = 200e18; //200+ deposits; will compound available rewards
    uint256 public constant maxAvailable = 50000e18; //50K max claim daily, 10 days missed claims 
    uint256 public constant maxPayouts = (maxBalance * 5e18) / 2e18; //2.5M

    bool public forceLiquidity = true;
    uint256 public slippage = 995;

    
    //Immutable long term network contracts
    ITreasuryV2 public  immutable wethTreasury;
    IEACAggregatorProxy public immutable chainlinkProxy;
    ITreasury public immutable coreTreasury;
    IERC20 public immutable coreToken;
    IUniswapV2Router02 public  immutable collateralRouter;
    IPcsPeriodicTwapOracle public immutable oracle;
    
    //Updatable components
    FuturesVault public vault; 
   

    //events
    event Deposit(address indexed user, uint256 amount, uint256 wethAmount);
    event CompoundDeposit(address indexed user, uint256 amount);
    event Claim(address indexed user, uint256 amount, uint256 wethAmount);
    event Transfer(address indexed user, address indexed new_user, uint256 current_balance);
    event UpdateVault(address prev_vault, address vault);
    event UpdateSlippage(uint oldSlippage, uint newSlippage);
    event UpdateForceLiquidity(bool value, bool new_value);

    //@dev Creates a FuturesEngine that contains upgradeable business logic for Futures Vault
    constructor() Ownable() {

         //init reg
        registry = new AddressRegistry();

        /* mythx-disable SWC-113 */

        //treasury setup
        wethTreasury = ITreasuryV2(registry.wethTreasuryAddress()); 

          //setup the core tokens
        coreToken = IERC20(registry.coreAddress());

        //the collateral router can be upgraded in the future
        collateralRouter = IUniswapV2Router02(registry.routerAddress());

        //treasury setup
        coreTreasury = ITreasury(registry.coreTreasuryAddress());

        chainlinkProxy = IEACAggregatorProxy(registry.chainlinkBNBAddress());

        oracle = IPcsPeriodicTwapOracle(registry.oracleAddress());
       

    }

    //Administrative//

    //@dev Update the FuturesVault
    function updateFuturesVault(address _vault) external onlyOwner {
        require(_vault != address(0), "vault must be non-zero");

        emit UpdateVault(address(vault), _vault);

        vault = FuturesVault(_vault);
    }

    function updatesSlippage(uint _slippage) onlyOwner external {
        require(_slippage >= 850 && _slippage < 1000, "slippage must be 850 <= slippage < 1000");

        slippage = _slippage;

        emit UpdateSlippage(slippage, _slippage);
    } 


    ///  Views  ///

    //@dev Get User info
    function getUser(address _user)
        external
        view
        returns (FuturesUser memory)
    {
        return vault.getUser(_user);
    }

    //@dev Get contract snapshot
    function getInfo()
        external
        view
        returns (
            FuturesGlobals memory
        )
    {
        return vault.getGlobals();
    }

    //@dev Forces the yield engine to topoff liquidity in the collateral buffer on every tx
    //a test harness
    function updateForceLiquidity(bool _force) external onlyOwner {
        
        emit UpdateForceLiquidity(forceLiquidity, _force);
        forceLiquidity = _force;
    }

    ////  User Functions ////

    //@dev Deposit BNB and get credit with dollar amount
    //Is not available if the system is paused
    function deposit() isRunning nonReentrant external payable {

        //optimistically update price
        updatePaths();
        
        uint _wethAmount = msg.value;
        uint _amount =  estimateCollateralAmount(_wethAmount);
        
        //Only the key holder can invest their funds
        address _user = msg.sender; 

        FuturesUser memory userData = vault.getUser(_user);
        FuturesGlobals memory globalsData = vault.getGlobals();
        
        require(_amount >= minimumDeposit, "amount less than minimum deposit");
        require(userData.current_balance + _amount <= maxBalance, "max balance exceeded" );
        require(userData.payouts <= maxPayouts, "max payouts exceeded");

        //90% goes directly to the treasury; START WETH ACCOUNTING
        uint _treasuryAmount = _wethAmount * 90 / 100; 
        uint _wethTreasuryAmount = _wethAmount - _treasuryAmount;

        //Buy ELEPHANT
        buyForTreasury(_treasuryAmount);

        //Send 10% to WETHTreasury
        payable(registry.wethTreasuryAddress()).transfer(_wethTreasuryAmount);
        
        //END WETH ACCOUNTING 

        //update user stats
        if (userData.exists == false) {
            //attempt to migrate user
            userData.exists = true;
            globalsData.total_users += 1;  

            //commit updates
            vault.commitUser(_user, userData);
            vault.commitGlobals(globalsData);

        } 

        //if user has an existing balance see if we have to claim yield before proceeding
        //optimistically claim yield before reset
        //if there is a balance we potentially have yield
        if (userData.current_balance > 0){
            compoundYield(_user);

            //reload user data after a mutable function
            userData = vault.getUser(_user); 
            globalsData = vault.getGlobals();
        }

        //update user
        userData.deposits += _amount;
        userData.last_time = block.timestamp;
        userData.current_balance += _amount;

        globalsData.total_deposited += _amount; 
        globalsData.current_balance += _amount;
        globalsData.total_txs += 1;

        //commit updates
        vault.commitUser(_user, userData);
        vault.commitGlobals(globalsData);

        //events
        emit Deposit(_user, _amount, msg.value);
    }


    //@dev Claims earned interest for the caller
    function claim() nonReentrant external returns (bool success){

        //optimistically update price
        updatePaths();
        
        //Only the owner of funds can claim funds
        address _user = msg.sender;

        FuturesUser memory userData = vault.getUser(_user);

        //checks
        require(
            userData.exists,
            "User is not registered"
        );
        require(
            userData.current_balance > 0 ,
            "balance is required to earn yield"
        );

        success = distributeYield(_user);
      
    }


    //@dev Returns tax bracket and adjusted amount based on the bracket 
    function available(address _user) public view returns (uint256 _limiterRate, uint256 _adjustedAmount) {

        //Load data
        FuturesUser memory userData = vault.getUser(_user);

        //calculate gross available
        uint256 share;

        if(userData.current_balance > 0) {
            //Using 1e18 we capture all significant digits when calculating available divs
            share = userData.current_balance //payout is asymptotic and uses the current balance
                    * referenceApr //convert to daily apr
                    / (365 * 100e18)
                    / 24 hours; //divide the profit by payout rate and seconds in the day;
            _adjustedAmount = share * block.timestamp.safeSub(userData.last_time); 

            _adjustedAmount = maxAvailable.min(_adjustedAmount); //minimize red candles

        }

        //apply compound rate limiter
        uint256 _comp_surplus = userData.compound_deposits.safeSub(userData.deposits);

        if (_comp_surplus < 50000e18){
            _limiterRate = 0;
        } else if ( 50000e18 <= _comp_surplus && _comp_surplus < 250000e18 ){
            _limiterRate = 10;
        } else if ( 250000e18 <= _comp_surplus && _comp_surplus < 500000e18 ){
            _limiterRate = 15;
        } else if ( 500000e18 <= _comp_surplus && _comp_surplus < 750000e18 ){
            _limiterRate = 25;
        } else if ( 750000e18 <= _comp_surplus && _comp_surplus < 1000000e18 ){
            _limiterRate = 35;
        } else if (_comp_surplus >= 1000000e18 ){
            _limiterRate = 50;
        }

        _adjustedAmount = _adjustedAmount * (100 - _limiterRate) / 100;


        // payout greater than the balance just pay the balance
        if(_adjustedAmount > userData.current_balance) {
            _adjustedAmount = userData.current_balance;
        }

        _adjustedAmount = scaleByPeg(_adjustedAmount);

    }

    //   Internal Functions  //

    //@dev Checks if yield is available and distributes before performing additional operations
    //distributes only when yield is positive
    //inputs are validated by external facing functions 
    function distributeYield(address _user) private returns (bool success) {

        FuturesUser memory userData = vault.getUser(_user);
        FuturesGlobals memory globalsData = vault.getGlobals();
        
        //get available
        (, uint256 _amount) = available(_user);

        // payout remaining allowable divs if exceeds
        if(userData.payouts + _amount > maxPayouts) {
            _amount = maxPayouts.safeSub(userData.payouts);
            _amount = _amount.min(userData.current_balance);  //withdraw up to the current balance
        }

        //attempt to payout yield and update stats;
        if (_amount > 0) {

            //transfer amount to user; mutable
            uint _wethAmount = yield(_user, _amount);

            //reload data after a mutable function
            userData = vault.getUser(_user);
            globalsData = vault.getGlobals();
        
            if (_amount > 0) { //second check with delivered yield
                //user stats
                userData.payouts += _amount;
                userData.current_balance = userData.current_balance.safeSub(_amount);
                userData.last_time = block.timestamp;

                //total stats
                globalsData.total_claimed += _amount;
                globalsData.total_txs += 1;
                globalsData.current_balance = globalsData.current_balance.safeSub(_amount);

                //commit updates
                vault.commitUser(_user, userData);
                vault.commitGlobals(globalsData);

                //log events
                emit Claim(_user, _amount, _wethAmount);

                return true;
            }

        } 

        //default
        return false;
    } 

    //@dev Checks if yield is available and compound before performing additional operations
    //compound only when yield is positive
    function compoundYield(address _user) private returns (bool success) {

        FuturesUser memory userData = vault.getUser(_user);
        FuturesGlobals memory globalsData = vault.getGlobals();
        
        //get available
        ( , uint256 _amount) = available(_user);

        // payout remaining allowable divs if exceeds
        if(userData.payouts + _amount > maxPayouts) {
            _amount = maxPayouts.safeSub(userData.payouts);
        }

        //attempt to compound yield and update stats;
        if (_amount > 0) {

            //user stats
            userData.deposits += 0; //compounding is not a deposit; here for clarity
            userData.compound_deposits += _amount;
            userData.payouts += _amount;
            userData.current_balance += _amount; 
            userData.last_time = block.timestamp;

            //total stats
            globalsData.total_deposited += 0; //compounding  doesn't move the needle; here for clarity
            globalsData.total_compound_deposited += _amount;
            globalsData.total_claimed += _amount;
            globalsData.current_balance += _amount;
            globalsData.total_txs += 1;
            
            //commit updates
            vault.commitUser(_user, userData);
            vault.commitGlobals(globalsData);

            //log events
            emit Claim(_user, _amount, 0);
            emit CompoundDeposit(_user, _amount);

            return true;

        } else {
            //do nothing upon failure
            return false;
        }
    } 

    //@dev Transfer account to another wallet address
    function transfer(address _newUser) nonReentrant external  {

        address _user = msg.sender;

        FuturesUser memory userData = vault.getUser(_user);
        FuturesUser memory newData =  vault.getUser(_newUser);
        FuturesGlobals memory globalsData = vault.getGlobals();

        //Only the owner can transfer
        require(userData.exists, "user must exists");
        require(newData.exists == false && _newUser != address(0), "new address must not exist");

        //Transfer
        newData.exists = true;
        newData.deposits = userData.deposits;
        newData.current_balance = userData.current_balance;
        newData.payouts = userData.payouts;
        newData.compound_deposits = userData.compound_deposits;
        newData.rewards = userData.rewards;
        newData.last_time = userData.last_time; 

        //Zero out old account
        userData.exists = true; //once an account is created source streams are only counted once
        userData.deposits = 0;
        userData.current_balance = 0;
        userData.compound_deposits = 0;
        userData.payouts = 0;
        userData.rewards = 0;
        userData.last_time = 0;

        //house keeping
        globalsData.total_txs += 1;

        //commit
        vault.commitUser(_user, userData);
        vault.commitUser(_newUser, newData);
        vault.commitGlobals(globalsData);

        //log
        emit Transfer(_user, _newUser, newData.current_balance);

    }

    /// Internal Functions ////

    //@dev Claim and payout using the reserve
    //Sender must implement IReferralReport to succeed
    function yield(address _user, uint256 _amount)
        private
        
        returns (uint wethAmount)
    {
        if (_amount == 0) {
            return 0;
        }

        wethAmount = estimateWethAmount(_amount);

        uint coreAmount = estimateCoreAmount(wethAmount);

        //if yield is greater than 1%
        if (forceLiquidity && wethAmount > registry.wethTreasuryAddress().balance / 100){
            liquidateCore(registry.wethTreasuryAddress(), coreAmount * 110 / 100);
        }

        wethTreasury.withdraw(_user, wethAmount, false);  //will fail if funds aren't available
            
        return wethAmount;
    }

    function buyForTreasury(uint _amount)  private {
        address[] memory path = new address[](2);

        path[0] = collateralRouter.WETH();
        path[1] = registry.coreAddress();

        uint[] memory output =  oracle.consultAmountsOut(_amount, path);

        uint minimum =  output[1] * slippage / 1000;


        //buy immediately and send to the treasury
        collateralRouter.swapExactETHForTokensSupportingFeeOnTransferTokens{value: _amount}(minimum, path, registry.coreTreasuryAddress(), block.timestamp);

    }

    //@dev liquidate core tokens from the treasury to the destination
    function liquidateCore(address destination, uint256 _amount) private returns (uint wethAmount) {
   
        //Convert from collateral to backed
        address[] memory path = new address[](2);

        path[0] = address(coreToken);
        path[1] = collateralRouter.WETH();

        //withdraw from treasury
        coreTreasury.withdraw(_amount);
        
        //approve & swap
        TransferHelper.safeApprove(address(coreToken), address(collateralRouter), _amount, 'FuturesEngine: liquidateCore, approve');

        uint[] memory output =  oracle.consultAmountsOut(_amount, path);

        uint minimumOut = output[1] * slippage / 1000;

        uint initialBalance = destination.balance;

        collateralRouter.swapExactTokensForETHSupportingFeeOnTransferTokens(
            _amount,
            minimumOut, 
            path,
            destination, 
            block.timestamp 
        );
    
        wethAmount = destination.balance - initialBalance;

  }

    function updatePaths() private {
        address[] memory path = new address[](2);

        path[0] = collateralRouter.WETH();
        path[1] = registry.coreAddress();

        // BNB -> ELEPHANT
        oracle.updatePath(path);

        path[1] = registry.backedAddress();

        // BNB -> TRUNK 
        oracle.updatePath(path);

        path[0] = registry.coreAddress();
        path[1] = collateralRouter.WETH();

        // ELEPHANT -> BNB 
        oracle.updatePath(path);

        path = new address[](3);

        path[0] = registry.coreAddress();
        path[1] = collateralRouter.WETH();
        path[2] = registry.backedAddress();

        // ELEPHANT -> TRUNK
        oracle.updatePath(path);

    }


    function estimateWethAmount(uint collateralAmount) public view returns (uint wethAmount){
        (, int256 answer , , , ) = chainlinkProxy.latestRoundData();
        uint8 decimals  = chainlinkProxy.decimals();

        wethAmount = collateralAmount * (10 ** decimals) / uint(answer); 
    }

    function estimateCollateralAmount(uint wethAmount) public view returns (uint collateralAmount){
        (, int256 answer , , , ) = chainlinkProxy.latestRoundData();
        uint8 decimals  = chainlinkProxy.decimals();

        collateralAmount = wethAmount * uint(answer) / (10 ** decimals);
    }

    function estimateCoreAmount(uint wethAmount) public view returns (uint coreAmount) {
        address[] memory path = new address[](2);

        path[0] = collateralRouter.WETH();
        path[1] = registry.coreAddress();

        uint[] memory output =  oracle.consultAmountsOut(wethAmount, path);

        coreAmount = output[1];

    }

    //@dev Scales an amount by how close backed token is to peg
    function scaleByPeg(uint amount) public view returns (uint scaledAmount) {

        FuturesGlobals memory globalsData = vault.getGlobals();

        uint dailyLiability = globalsData.current_balance * 5 / 1000; //0.5% (0.005) per day

        uint wethTreasuryInCollateral = estimateCollateralAmount(registry.wethTreasuryAddress().balance);

        scaledAmount = amount * wethTreasuryInCollateral / dailyLiability;

        scaledAmount = scaledAmount.min(amount);

    }
}

//@dev Simple onchain oracle for important Elephant Money smart contracts
contract AddressRegistry {
    address public constant coreAddress =
        address(0xE283D0e3B8c102BAdF5E8166B73E02D96d92F688); //ELEPHANT
    address public constant coreTreasuryAddress =
        address(0xAF0980A0f52954777C491166E7F40DB2B6fBb4Fc); //ELEPHANT Treasury
    address public constant wethTreasuryAddress = 
        address(0x98F6c7c953Cf4cef0fd632b2509c9e349687FC92); //WETH Treasury
    address public constant collateralAddress =
        address(0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56); //BUSD
    address public constant collateralTreasuryAddress =
        address(0xCb5a02BB3a38e92E591d323d6824586608cE8cE4); //BUSD Treasury
    address public constant collateralRedemptionAddress =
        address(0xD3B4fB63e249a727b9976864B28184b85aBc6fDf); //BUSD Redemption Pool
    address public constant collateralBufferAddress =
        address(0xd9dE89efB084FfF7900Eac23F2A991894500Ec3E); //BUSD Buffer Pool
    address public constant backedAddress =
        address(0xdd325C38b12903B727D16961e61333f4871A70E0); //TRUNK Stable coin
    address public constant backedTreasuryAddress =
        address(0xaCEf13009D7E5701798a0D2c7cc7E07f6937bfDd); //TRUNK Treasury
    address public constant backedLPAddress =
        address(0xf15A72B15fC4CAeD6FaDB1ba7347f6CCD1E0Aede); //TRUNK/BUSD LP
    address public constant routerAddress =
        address(0x10ED43C718714eb63d5aA57B78B54704E256024E);
    address public constant chainlinkBNBAddress = 
        address(0x0567F2323251f0Aab15c8dFb1967E4e8A7D42aeE); //BNB/USD Price
    address public constant oracleAddress = address(0x5606ee12d741716c260fDA2f6C89EfDf60326D3C); //TWAPOracle
    //PCS Factory - 0xcA143Ce32Fe78f1f7019d7d551a6402fC5350c73
    
}

/**
 * @title SafeMath
 * @dev Math operations with safety checks that throw on error
 */
library SafeMath {
    /**
     * @dev Multiplies two numbers, throws on overflow.
     */
    function mul(uint256 a, uint256 b) internal pure returns (uint256 c) {
        if (a == 0) {
            return 0;
        }
        c = a * b;
        assert(c / a == b);
        return c;
    }

    /**
     * @dev Integer division of two numbers, truncating the quotient.
     */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        // assert(b > 0); // Solidity automatically throws when dividing by 0
        // uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold
        return a / b;
    }

    /**
     * @dev Subtracts two numbers, throws on overflow (i.e. if subtrahend is greater than minuend).
     */
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        assert(b <= a);
        return a - b;
    }

    /* @dev Subtracts two numbers, else returns zero */
    function safeSub(uint256 a, uint256 b) internal pure returns (uint256) {
        if (b > a) {
            return 0;
        } else {
            return a - b;
        }
    }

    /**
     * @dev Adds two numbers, throws on overflow.
     */
    function add(uint256 a, uint256 b) internal pure returns (uint256 c) {
        c = a + b;
        assert(c >= a);
        return c;
    }

    function max(uint256 a, uint256 b) internal pure returns (uint256) {
        return a >= b ? a : b;
    }

    function min(uint256 a, uint256 b) internal pure returns (uint256) {
        return a < b ? a : b;
    }

}

library TransferHelper {
    /// @notice Transfers tokens from the targeted address to the given destination
    /// @notice Errors with 'STF' if transfer fails
    /// @param token The contract address of the token to be transferred
    /// @param from The originating address from which the tokens will be transferred
    /// @param to The destination address of the transfer
    /// @param value The amount to be transferred
    function safeTransferFrom(
        address token,
        address from,
        address to,
        uint256 value,
        string memory notes
    ) internal {
        (bool success, bytes memory data) =
            token.call(abi.encodeWithSelector(IERC20.transferFrom.selector, from, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), string.concat('STF', notes));
    }

    /// @notice Transfers tokens from msg.sender to a recipient
    /// @dev Errors with ST if transfer fails
    /// @param token The contract address of the token which will be transferred
    /// @param to The recipient of the transfer
    /// @param value The value of the transfer
    function safeTransfer(
        address token,
        address to,
        uint256 value,
        string memory notes
    ) internal {
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(IERC20.transfer.selector, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), string.concat('ST', notes));
    }

    /// @notice Approves the stipulated contract to spend the given allowance in the given token
    /// @dev Errors with 'SA' if transfer fails
    /// @param token The contract address of the token to be approved
    /// @param to The target of the approval
    /// @param value The amount of the given token the target will be allowed to spend
    function safeApprove(
        address token,
        address to,
        uint256 value,
        string memory notes
    ) internal {
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(IERC20.approve.selector, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), string.concat('SA', notes));
    }

    /// @notice Transfers ETH to the recipient address
    /// @dev Fails with `STE`
    /// @param to The destination of the transfer
    /// @param value The value to be transferred
    function safeTransferETH(address to, uint256 value, string memory notes) internal {
        (bool success, ) = to.call{value: value}(new bytes(0));
        require(success, string.concat('STE', notes));
    }
}