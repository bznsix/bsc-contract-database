// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "./interfaces/ISwapV2.sol";
import "./interfaces/IVault.sol";
import "@openzeppelin/contracts/interfaces/IERC20.sol";

contract InjectionV2
{
    /**
     * External contracts.
     */
    IERC20 public usdc = IERC20(0x8AC76a51cc950d9822D68b83fE1Ad97B32Cd580d);
    IERC20 public fur = IERC20(0x48378891d6E459ca9a56B88b406E8F4eAB2e39bF);
    ISwapV2 public swap = ISwapV2(0xbA8c06BE90FA46d634515716eAe4FFc3a8BFc4CD);
    IVault public vault = IVault(0x4de2b5D4a343dDFBeEf976B3ED34737440385071);

    /**
     * Properties.
     */
    uint256 public injectionPerWeek = 50000e18;
    uint256 public minimumInjection = 1e18;
    uint256 public maximumInjection = 10000e18;
    uint256 public totalInjected;
    mapping(uint256 => uint256) private _injections;

    /**
     * Events.
     */
    event Injection(uint256 amount);

    /**
     * Constructor.
     */
    constructor() public
    {
        // Pre-fill this weeks injections so we're starting at contract
        // launch time instead of beginning of week.
        uint256 _injectionPerSecond_ = injectionPerWeek / 7 days;
        _injections[getWeek()] = _injectionPerSecond_ * getElapsedTimeThisWeek();
    }

    /**
     * Injected by week.
     */
    function getInjected(uint256 week_) public view returns (uint256)
    {
        return _injections[week_];
    }

    /**
     * Elapsed time this week.
     */
    function getElapsedTimeThisWeek() public view returns (uint256)
    {
        return block.timestamp % 7 days;
    }

    /**
     * Remaining time this week.
     */
    function getRemainingTimeThisWeek() public view returns (uint256)
    {
        return 7 days - getElapsedTimeThisWeek();
    }

    /**
     * Get available injections.
     */
    function getAvailableInjection() public view returns (uint256)
    {
        uint256 _usdcBalance_ = usdc.balanceOf(address(this));
        uint256 _injectionPerSecond_ = injectionPerWeek / 7 days;
        uint256 _availableToInject_ = (getElapsedTimeThisWeek() * _injectionPerSecond_) - _injections[getWeek()];
        if(_availableToInject_ < minimumInjection) _availableToInject_ = 0;
        if(_availableToInject_ > maximumInjection) _availableToInject_ = maximumInjection;
        if(_availableToInject_ > _usdcBalance_) _availableToInject_ = _usdcBalance_;
        return _availableToInject_;
    }

    /**
     * Inject.
     */
    function inject() external
    {
        require(vault.participantBalance(msg.sender) > 0, "Not a participant.");
        uint256 _availableInjection_ = getAvailableInjection();
        require(_availableInjection_ > 0, "No injection available.");
        _injections[getWeek()] += _availableInjection_;
        totalInjected += _availableInjection_;
        usdc.approve(address(swap), _availableInjection_);
        swap.buy(address(usdc), _availableInjection_);
        fur.transfer(address(vault), fur.balanceOf(address(this)));
        emit Injection(_availableInjection_);
    }

    /**
     * Get week.
     */
    function getWeek() public view returns (uint256)
    {
        return getWeekByTimestamp(block.timestamp);
    }

    /**
     * Get week by timestamp.
     */
    function getWeekByTimestamp(uint256 timestamp_) public view returns (uint256)
    {
        return timestamp_ / 7 days;
    }
}
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

interface ISwapV2 {
    function addressBook (  ) external view returns ( address );
    function buy ( address payment_, uint256 amount_ ) external;
    function buyOutput ( address payment_, uint256 amount_ ) external view returns ( uint256 );
    function cooldownPeriod (  ) external view returns ( uint256 );
    function depositBuy ( address payment_, uint256 amount_, address referrer_ ) external;
    function depositBuy ( address payment_, uint256 amount_ ) external;
    function disableLiquidtyManager (  ) external;
    function enableLiquidityManager (  ) external;
    function exemptFromCooldown ( address participant_, bool value_ ) external;
    function factory (  ) external view returns ( address );
    function fur (  ) external view returns ( address );
    function initialize (  ) external;
    function lastSell ( address ) external view returns ( uint256 );
    function liquidityManager (  ) external view returns ( address );
    function liquidityManagerEnabled (  ) external view returns ( bool );
    function onCooldown ( address participant_ ) external view returns ( bool );
    function owner (  ) external view returns ( address );
    function pair (  ) external view returns ( address );
    function pause (  ) external;
    function paused (  ) external view returns ( bool );
    function proxiableUUID (  ) external view returns ( bytes32 );
    function pumpAndDumpMultiplier (  ) external view returns ( uint256 );
    function pumpAndDumpRate (  ) external view returns ( uint256 );
    function renounceOwnership (  ) external;
    function router (  ) external view returns ( address );
    function sell ( uint256 amount_ ) external;
    function sellOutput ( uint256 amount_ ) external view returns ( uint256 );
    function setAddressBook ( address address_ ) external;
    function setup (  ) external;
    function tax (  ) external view returns ( uint256 );
    function taxHandler (  ) external view returns ( address );
    function transferOwnership ( address newOwner ) external;
    function unpause (  ) external;
    function upgradeTo ( address newImplementation ) external;
    function upgradeToAndCall ( address newImplementation, bytes memory data ) external;
    function usdc (  ) external view returns ( address );
    function vault (  ) external view returns ( address );
}
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

interface IVault {
    struct Participant {
        uint256 startTime;
        uint256 balance;
        address referrer;
        uint256 deposited;
        uint256 compounded;
        uint256 claimed;
        uint256 taxed;
        uint256 awarded;
        bool negative;
        bool penalized;
        bool maxed;
        bool banned;
        bool teamWallet;
        bool complete;
        uint256 maxedRate;
        uint256 availableRewards;
        uint256 lastRewardUpdate;
        uint256 directReferrals;
        uint256 airdropSent;
        uint256 airdropReceived;
    }
    function addressBook (  ) external view returns ( address );
    function airdrop ( address to_, uint256 amount_ ) external returns ( bool );
    function availableRewards ( address participant_ ) external view returns ( uint256 );
    function claim (  ) external returns ( bool );
    function claimPrecheck ( address participant_ ) external view returns ( uint256 );
    function compound (  ) external returns ( bool );
    function autoCompound( address participant_ ) external returns ( bool );
    function deposit ( uint256 quantity_, address referrer_ ) external returns ( bool );
    function deposit ( uint256 quantity_ ) external returns ( bool );
    function depositFor ( address participant_, uint256 quantity_ ) external returns ( bool );
    function depositFor ( address participant_, uint256 quantity_, address referrer_ ) external returns ( bool );
    function getParticipant ( address participant_ ) external returns ( Participant memory );
    function initialize (  ) external;
    function maxPayout ( address participant_ ) external view returns ( uint256 );
    function maxThreshold (  ) external view returns ( uint256 );
    function owner (  ) external view returns ( address );
    function participantBalance ( address participant_ ) external view returns ( uint256 );
    function participantMaxed ( address participant_ ) external view returns ( bool );
    function participantStatus ( address participant_ ) external view returns ( uint256 );
    function pause (  ) external;
    function paused (  ) external view returns ( bool );
    function proxiableUUID (  ) external view returns ( bytes32 );
    function remainingPayout ( address participant_ ) external view returns ( uint256 );
    function renounceOwnership (  ) external;
    function rewardRate ( address participant_ ) external view returns ( uint256 );
    function setAddressBook ( address address_ ) external;
    function transferOwnership ( address newOwner ) external;
    function unpause (  ) external;
    function updateLookbackPeriods ( uint256 lookbackPeriods_ ) external;
    function updateMaxPayout ( uint256 maxPayout_ ) external;
    function updateMaxReturn ( uint256 maxReturn_ ) external;
    function updateNegativeClaims ( uint256 negativeClaims_ ) external;
    function updateNeutralClaims ( uint256 neutralClaims_ ) external;
    function updatePenaltyClaims ( uint256 penaltyClaims_ ) external;
    function updatePenaltyLookbackPeriods ( uint256 penaltyLookbackPeriods_ ) external;
    function updatePeriod ( uint256 period_ ) external;
    function updateRate ( uint256 claims_, uint256 rate_ ) external;
    function updateReferrer ( address referrer_ ) external;
    function upgradeTo ( address newImplementation ) external;
    function upgradeToAndCall ( address newImplementation, bytes memory data ) external;
}
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (interfaces/IERC20.sol)

pragma solidity ^0.8.0;

import "../token/ERC20/IERC20.sol";
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
