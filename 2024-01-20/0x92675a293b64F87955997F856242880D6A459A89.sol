// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import {Ownable} from "openzeppelin/access/Ownable.sol";
import {ReentrancyGuard} from "openzeppelin/security/ReentrancyGuard.sol";
import {IGrow, IERC20} from "./interfaces/IGrow.sol";
error GrowMiner__NotInitialized();
error GrowMiner__InvalidAmount();
error GrowMiner__NotDeposited();
error GrowMiner__NoEggs();
error GrowMiner__OnlyIntegers();
error GrowMiner__NothingToLiquidate();

/**
 * @title GrowMiner
 * @author TheThinker @ NextGenROI
 * @notice This is a miner, it's very risky, and pretty scammy. It's very high risk and you should not add money here if you have no idea
 * what you're doing. It's a ponzi scheme, and it's not sustainable. It's a game, and it's meant to be fun.
 * If you consider gambling fun...
 * Please consider using our other products like the Fixed Deposit or Drip.
 * DISCLAIMER: The only reason we added this contract is because the community asked for it, we do not endorse this contract, and we do not
 * approve of users being scammed. We are not responsible for any losses you may incur.
 * https://nextgenroi.com/invest
 */
contract GrowMiner is Ownable, ReentrancyGuard {
    struct Mining {
        uint256 miners;
        uint256 totalInvested; // This is in GROW
        uint256 totalRedeemed; // This is in Stable
        uint256 refEggs; // eggs used for referral rewards, these can either be compounded or claimed
        uint256 lockedEggs; // only used for creating miners, not claimable
        uint256 lastInteraction;
        address referrer;
    }
    mapping(address => Mining) public user;
    address[] private owners;
    address[] private participants; // this value is only used for the UI

    uint256 public constant EGGS_TO_HATCH_1MINERS = 2592000;
    uint256 public constant MAX_VAULT_TIME = 24 hours;
    uint256 public constant PERCENT_BASE = 100;

    uint256 public marketEggs;
    uint256 public devFee = 5;
    uint256 public growFee = 5;
    uint256 public liquidatorFee = 15;
    uint256 public totalLiquidated = 0;

    address public grow;

    IGrow public immutable GROW;
    IERC20 public immutable STABLE;
    bool public initialized = false;

    //------------------------
    //  EVENTS
    //------------------------
    event Initialize(uint256 timeStamp);
    event Deposit(
        address indexed _user,
        address indexed _ref,
        uint256 _growAmount
    );
    event PriceAfterBurn(uint256 _price, uint256 _timestamp);
    event Redeem(address indexed _user, uint256 _usdtAmount);
    event Reinvest(address indexed _user, uint256 _growAmount);
    event Liquidation(
        address indexed _liquidator,
        address[] _users,
        uint256 _liquidationReward
    );

    //------------------------
    //  Modifiers
    //------------------------
    modifier onlyInitialized() {
        if (!initialized) revert GrowMiner__NotInitialized();
        _;
    }

    //------------------------
    //  Constructor
    //------------------------
    /**
     *
     * @param _growToken The address of the GROW tokens, this is immutable since the GROW token will never change
     * @param _stable This is the address of the STABLE token that will be used to buy GROW tokens
     * @param _owners List of owners that'll receive the devFees
     */
    constructor(address _growToken, address _stable, address[] memory _owners) {
        GROW = IGrow(_growToken);
        STABLE = IERC20(_stable);
        STABLE.approve(_growToken, type(uint256).max);
        owners = _owners;
    }

    //--------------------------------
    //  External / Public Functions
    //--------------------------------
    /**
     * @notice Deposit STABLE tokens into the miner to create miners and start the "game"
     * @param amount The amount of STABLE tokens to deposit
     * @param referrer The user who referred this user
     */
    function depositIntoMine(
        uint256 amount,
        address referrer
    ) external onlyInitialized nonReentrant {
        if (amount == 0) revert GrowMiner__InvalidAmount();
        if (amount % 1 ether != 0) revert GrowMiner__OnlyIntegers();
        uint256 currentGrow = GROW.balanceOf(address(this));
        uint growFeeAmount = (amount * growFee) / PERCENT_BASE;
        uint stableAmount = amount - growFeeAmount;
        // Create Grow
        STABLE.transferFrom(msg.sender, address(GROW), stableAmount);
        STABLE.transferFrom(msg.sender, address(this), growFeeAmount);
        uint256 boughtGrow = GROW.buyFor(
            address(this),
            stableAmount,
            address(STABLE)
        );
        if (growFeeAmount > 0) {
            GROW.burnWithUnderlying(growFeeAmount, address(STABLE));
            emit PriceAfterBurn(GROW.calculatePrice(), block.timestamp);
        }
        // Send GROW created to owners
        boughtGrow = ownerDistribution(boughtGrow, true);

        uint eggsBought = calculateEggBuy(boughtGrow, currentGrow);
        Mining storage miner = user[msg.sender];

        eggsBought += miner.lockedEggs;

        _checkAndSetRef(referrer, miner);
        // Referrals will only get 2% of the total eggs bought
        _sendRefAmount(miner.referrer, eggsBought / 50);

        uint newMiners = eggsBought / EGGS_TO_HATCH_1MINERS;
        uint leftOver = eggsBought % EGGS_TO_HATCH_1MINERS;
        if (miner.miners == 0) {
            participants.push(msg.sender);
            if (newMiners == 0) {
                newMiners++;
            }
        }
        miner.miners += newMiners;
        miner.refEggs = 0;
        miner.lockedEggs += leftOver;
        miner.totalInvested += boughtGrow;
        miner.lastInteraction = block.timestamp;
        // 20% of eggs bought are added to market to nerf miners hoarding
        marketEggs += eggsBought / 5;

        emit Deposit(msg.sender, user[msg.sender].referrer, boughtGrow);
    }

    /**
     * @notice this function compounds any accumulated eggs into the user's miners
     * @dev Any eggs not used by the user to create a miner will be locked and added to the user's lockedEggs amount
     */
    function compoundResources() external onlyInitialized nonReentrant {
        Mining storage miner = user[msg.sender];
        if (miner.miners == 0) revert GrowMiner__NotDeposited();
        uint256 eggsUsed = getEggs(msg.sender) + miner.lockedEggs;
        if (eggsUsed == 0) revert GrowMiner__NoEggs();
        // reset the locked and ref eggs
        miner.lockedEggs = 0;
        miner.refEggs = 0;
        // This is a calculation based on the amount of eggs that could've turned into GROW tokens, it doens't really
        // mean the GROW was bought so be weary of this value
        uint256 eggsValue = calculateEggSell(eggsUsed);
        uint256 newMiners = eggsUsed / EGGS_TO_HATCH_1MINERS;
        uint256 leftOver = eggsUsed % EGGS_TO_HATCH_1MINERS;

        // boost market to nerf miners hoarding
        eggsUsed /= 5; // 20% of total eggs
        marketEggs += eggsUsed;
        miner.lockedEggs += leftOver;
        miner.miners += newMiners;
        miner.totalInvested += eggsValue;
        miner.lastInteraction = block.timestamp;

        // boost market to nerf miners hoarding
        // Actual eggs value reinvested
        emit Reinvest(msg.sender, eggsValue);
    }

    /**
     * @notice this function allows the user to claim the value of their eggs, whatever that may be
     * @dev This function will sell the user's eggs for the respective GROW amount, and then sell the GROW for STABLE tokens
     */
    function claimFromMine() public onlyInitialized nonReentrant {
        Mining storage miner = user[msg.sender];
        if (miner.miners == 0) revert GrowMiner__NotDeposited();
        uint256 hasEggs = getEggs(msg.sender);
        if (hasEggs == 0) revert GrowMiner__NoEggs();
        uint256 eggsValue = calculateEggSell(hasEggs);
        miner.refEggs = 0;
        miner.lastInteraction = block.timestamp;
        marketEggs += hasEggs;
        eggsValue = _sellEggs(eggsValue, msg.sender, true);
        miner.totalRedeemed += eggsValue;
        emit Redeem(msg.sender, eggsValue);
    }

    /**
     * @notice starts the miner, this is a one time function that can only be called once
     */
    function initializeMiner() external onlyOwner {
        require(marketEggs == 0, "Market eggs not zero");
        initialized = true;
        marketEggs = 25920000000;
        emit Initialize(block.timestamp);
    }

    /**
     * @notice This function allows users to liquidate other users who have gone 1 hour above the MAX_VAULT_TIME and claims for them.
     * @dev The liquidator (caller) will receive 15% of the total GROW tokens liquidated, the rest will be sent to the main user.
     * @param toLiquidate The list of users to liquidate
     */
    function liquidateUsers(
        address[] calldata toLiquidate
    ) external onlyInitialized nonReentrant {
        uint256 totalUsers = toLiquidate.length;
        uint256 currentLiquidator = 0;
        for (uint256 i = 0; i < totalUsers; i++) {
            Mining storage miner = user[toLiquidate[i]];
            if (
                block.timestamp - miner.lastInteraction >
                MAX_VAULT_TIME + 1 hours
            ) {
                uint256 eggs = getEggs(toLiquidate[i]);
                if (eggs == 0) continue;
                uint256 eggsValue = calculateEggSell(eggs);
                miner.refEggs = 0;
                miner.lastInteraction = block.timestamp;
                marketEggs += eggs;
                eggsValue = _sellEggs(eggsValue, msg.sender, false);
                uint liquidatorAmount = (eggsValue * liquidatorFee) /
                    PERCENT_BASE;
                eggsValue -= liquidatorAmount;
                currentLiquidator += liquidatorAmount;
                miner.totalRedeemed += eggsValue;
                marketEggs += eggs;
                STABLE.transfer(toLiquidate[i], eggsValue);
                emit Redeem(toLiquidate[i], eggsValue);
            }
        }
        if (currentLiquidator == 0) revert GrowMiner__NothingToLiquidate();
        totalLiquidated += currentLiquidator;
        if (currentLiquidator > 0) {
            STABLE.transfer(msg.sender, currentLiquidator);
            emit Liquidation(msg.sender, toLiquidate, currentLiquidator);
        }
    }

    //--------------------------------
    //  Internal/Private Functions
    //--------------------------------
    /**
     * @notice this function adds the provided referrer to the user's miner
     * @param _ref The address to add as referrer
     * @param miner The miner struct of the user
     * @dev A user can't be a referrer if the referrer is already set, or the referrer is the user itself, or the referrer has never participated in the miner
     */
    function _checkAndSetRef(address _ref, Mining storage miner) private {
        if (_ref == msg.sender) {
            _ref = address(0);
        }
        if (
            miner.referrer == address(0) &&
            _ref != address(0) &&
            user[_ref].miners > 0
        ) {
            miner.referrer = _ref;
        }
    }

    /**
     * @notice this function sends the referral amount to the referrer
     * @param _ref The address of the referrer
     * @param amount The amount of eggs to send to the referrer
     */
    function _sendRefAmount(address _ref, uint amount) private {
        if (_ref != address(0)) {
            user[_ref].refEggs += amount;
        }
    }

    /**
     * @notice this function distributes the devFee to the owners
     * @param amount The amount of GROW tokens to distribute
     * @param onBuy if it's a buy, base percentage is different
     */
    function ownerDistribution(
        uint amount,
        bool onBuy
    ) private returns (uint amountAfterFee) {
        uint256 base = onBuy ? PERCENT_BASE - growFee : PERCENT_BASE;
        uint256 fee = (amount * devFee) / base;
        fee = fee / owners.length;
        for (uint8 i = 0; i < owners.length; i++) {
            amountAfterFee += fee;
            GROW.transfer(owners[i], fee);
        }
        return amount - amountAfterFee;
    }

    /**
     *
     * @param growSold The amount of GROW tokens that are being sold
     * @param recipient The recipient of the STABLE tokens
     */
    function _sellEggs(
        uint growSold,
        address recipient,
        bool doTransfer
    ) private returns (uint valueOfSell) {
        // send share to dev
        growSold = ownerDistribution(growSold, false);
        uint growFeeAmount = (growSold * growFee) / (PERCENT_BASE - devFee);
        growSold -= growFeeAmount;

        valueOfSell = GROW.sell(growSold, address(STABLE));
        //BURN happens after claiming
        if (growFeeAmount > 0) {
            GROW.burn(growFeeAmount);
        }

        if (doTransfer) STABLE.transfer(recipient, valueOfSell);
    }

    //---------------------------------------
    //  External/Public VIEW/PURE Functions
    //---------------------------------------

    /**
     * @notice This is the trading calculation function, it's taken from bnb.miner AS IS and simplified, to warn users how scammy this is
     * @param rt This is the amount that will be added to the pool
     * @param rs this is the current pool
     * @param bs this is the amount of assets to get the ratio from
     */
    function calculateTrade(
        uint256 rt,
        uint256 rs,
        uint256 bs
    ) public pure returns (uint256) {
        // Original "Algorithm" = (PSN*bs)/(PSNH+((PSN*rs+PSNH*rt)/rt));
        // where PSNH = PSN / 2
        // Simplified version, we're not going to hide stupid math
        return (rt * bs) / (rt + rs);
    }

    /**
     * @notice function to calculate the amount of GROW to sell the eggs for
     * @param eggs The amount of eggs to calculate the sell price for
     * @return The amount of GROW tokens the eggs are worth
     */
    function calculateEggSell(uint256 eggs) public view returns (uint256) {
        return calculateTrade(eggs, marketEggs, GROW.balanceOf(address(this)));
    }

    /**
     * @notice Calculates the amount of eggs that can be bought with the provided amount of GROW tokens
     * @param amount The amount of GROW tokens to calculate the buy price for
     * @param contractBalance The amount of GROW tokens in the contract
     * @return The amount of eggs that can be bought with the provided amount of GROW tokens
     */
    function calculateEggBuy(
        uint256 amount,
        uint256 contractBalance
    ) public view returns (uint256) {
        return calculateTrade(amount, contractBalance, marketEggs);
    }

    /**
     * @notice this funciton is to make it easier for the frontend to calculate the buy price
     * @param amount The amount of GROW tokens to calculate the buy price for
     * @return The amount of eggs that can be bought with the provided amount of GROW tokens
     */
    function calculateEggBuySimple(
        uint256 amount
    ) public view returns (uint256) {
        return calculateEggBuy(amount, GROW.balanceOf(address(this)));
    }

    /**
     * @notice this function returns the amount of GROW tokens in the contract
     * @return The amount of GROW tokens in the contract
     */
    function getBalance() public view returns (uint256) {
        return GROW.balanceOf(address(this));
    }

    /**
     * @notice This function returns the amount of miners a user has
     * @param _user The address of the user to get the miners for
     * @return The amount of miners the user has
     */
    function getMiners(address _user) public view returns (uint256) {
        return user[_user].miners;
    }

    /**
     * @notice this function gets the eggs available for compound or claim
     * @param _user The address of the user to get the eggs for
     * @return The amount of eggs the user has available NOW
     */
    function getEggs(address _user) public view returns (uint256) {
        return user[_user].refEggs + getEggsSinceLastHatch(_user);
    }

    /**
     * @notice this function calculates the amount of eggs a user has accumulated since their last interaction
     * @param adr The address of the user to get the eggs for
     */
    function getEggsSinceLastHatch(address adr) public view returns (uint256) {
        Mining storage currentUser = user[adr];
        uint256 secondsPassed = min(
            MAX_VAULT_TIME,
            (block.timestamp - currentUser.lastInteraction)
        );
        return secondsPassed * currentUser.miners;
    }

    /**
     * @notice This function will return the users that are available to be liquidated
     * @return _usersToLiquidate Array of users available to be liquidated
     * @return _growAmounts The amount of total GROW redeemable by each user (this is an estimate, since liquidating 1 user will affect the next)
     * @dev THIS FUNCTION IS ONLY TO BE CALLED BY THE FRONTEND SINCE IT'S VERY EXPENSIVE AND NOT MEANT TO BE CALLED ON CHAIN
     */
    function getLiquidatableUsers()
        external
        view
        returns (address[] memory _usersToLiquidate, uint[] memory _growAmounts)
    {
        uint256 totalUsers = participants.length;
        uint256 usersToLiquidate = 0;
        uint256[] memory userIndexes = new uint256[](totalUsers);

        for (uint256 i = 0; i < totalUsers; i++) {
            Mining storage miner = user[participants[i]];
            if (
                block.timestamp - miner.lastInteraction >
                MAX_VAULT_TIME + 1 hours
            ) {
                userIndexes[usersToLiquidate] = i;
                usersToLiquidate++;
            }
        }
        if (usersToLiquidate == 0) {
            return (_usersToLiquidate, _growAmounts);
        }
        _usersToLiquidate = new address[](usersToLiquidate);
        _growAmounts = new uint[](usersToLiquidate);
        for (uint256 j = 0; j < usersToLiquidate; j++) {
            uint256 index = userIndexes[j];
            _usersToLiquidate[j] = participants[index];
            uint256 eggs = getEggs(participants[index]);
            uint256 eggsValue = calculateEggSell(eggs);
            _growAmounts[j] = eggsValue;
        }
    }

    //---------------------------------------
    //  Internal/Private VIEW/PURE Functions
    //---------------------------------------
    /**
     * @notice this function gets the minimum of the 2 provided values
     * @param a Value 1
     * @param b Value 2
     * @return The minimum of the 2 provided values
     */
    function min(uint256 a, uint256 b) private pure returns (uint256) {
        return a < b ? a : b;
    }
}
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
//SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import "openzeppelin/token/ERC20/IERC20.sol";

interface IGrow is IERC20 {
    function burn(uint256 amount) external;

    function sell(
        uint256 amount,
        address stable
    ) external returns (uint stableReceived);

    function sell(
        address recipient,
        uint256 amount,
        address stable
    ) external returns (uint stableReceived);

    function sellAll(address _stable) external;

    // These functions are used to buy CLIMB with STABLE, STABLE will need to be approved for transfer in for this contract.
    function buy(uint256 numTokens, address stable) external returns (uint256);

    function buy(
        address recipient,
        uint256 numTokens,
        address stable
    ) external returns (uint256);

    /// @notice although this function has the same parameters as the BUY functions, only Matrix contracts can call this function
    /// @dev the Matrix contract MUST send STABLE tokens to this contract before calling this function. Without this function, the Matrix contract would have to receive STABLE tokens from the user, then approve STABLE tokens to the contract to buy CLIMB token and then CLIMB would need to transfer STABLE back to themselves. This function saves gas and time.
    function buyFor(
        address recipient,
        uint256 numTokens,
        address stable
    ) external returns (uint256);

    function eraseHoldings(uint256 nHoldings) external;

    function volumeFor(address wallet) external view returns (uint256);

    function calculatePrice() external view returns (uint256);

    function burnWithUnderlying(
        uint256 underlyingAmount,
        address _stable
    ) external;

    function stables(
        address _stable
    )
        external
        view
        returns (
            uint balance,
            uint8 index,
            uint8 decimals,
            bool accepted,
            bool setup
        );

    function allStables() external view returns (address[] memory);

    ///@notice this function is called by OWNER only and is used to exchange the complete balance in STABLE1 for STABLE2
    function exchangeTokens(
        address stable1,
        address stable2,
        address _router
    ) external;

    // owner functions
    function setExecutorAddress(address executor, bool exempt) external;

    ///////////////////////////////////
    //////        EVENTS        ///////
    ///////////////////////////////////

    event UpdateShares(uint256 updatedDevShare, uint256 updatedLiquidityShare);
    event UpdateFees(
        uint256 updatedSellFee,
        uint256 updatedMintFee,
        uint256 updatedTransferFee
    );
    event UpdateDevAddress(address updatedDev);
    event SetExecutor(address executor, bool isExecutor);
    event PriceChange(
        uint256 previousPrice,
        uint256 currentPrice,
        uint256 totalSupply
    );
    event ErasedHoldings(address who, uint256 amountTokensErased);
    event GarbageCollected(uint256 amountTokensErased);
    event UpdateTokenSlippage(uint256 newSlippage);
    event TransferOwnership(address newOwner);
    event TokenStaked(uint256 assetsReceived, address recipient);
    event SetFeeExemption(address Contract, bool exempt);
    event TokenActivated(uint256 totalSupply, uint256 price, uint256 timestamp);
    event TokenSold(
        uint256 amountCLIMB,
        uint256 assetsRedeemed,
        address recipient
    );
    event TokenPurchased(uint256 assetsReceived, address recipient);
    event SetStableToken(address stable, bool exempt);
    event ExchangeToken(
        address _from,
        address _to,
        uint256 amountFROM,
        uint256 amountTO
    );
    event Burn(uint amountInGrow, uint amountInStable);
}

interface IOwnableGrow is IGrow {
    function owner() external returns (address);
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
