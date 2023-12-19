// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

// OpenZeppelin Contracts (last updated v4.9.0) (token/ERC20/IERC20.sol)

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

// OpenZeppelin Contracts (last updated v4.9.0) (security/ReentrancyGuard.sol)

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

error GrowDrip__OnlyOwner();
error GrowDrip__InvalidLiquidator();
error GrowDrip__InvalidAddress();
error GrowDrip__InvalidOperation();
error GrowDrip__ZeroLiquidation();
error GrowDrip__MinInitDepositNotMet();

contract GrowDrip is ReentrancyGuard {
    //-------------------------------------------------------------------------
    // Type Definitions
    //-------------------------------------------------------------------------
    struct User {
        uint totalDeposited;
        uint currentGrowAmount;
        uint lastClaimed;
        uint totalClaimed;
        uint position;
    }
    //-------------------------------------------------------------------------
    // State Variables
    //-------------------------------------------------------------------------
    mapping(address => User) public users;
    mapping(address => uint) public liquidatorEarnings;
    mapping(address => bool) public feeExemption;
    address[] private allUsers;
    address[] private owners;
    uint[] private shares;
    IGrow public immutable GROW;
    IERC20 public immutable USDT;
    address public owner;
    uint private totalShares;
    uint public totalClaimed;
    uint public totalDeposits;
    uint public activeDeposits;
    uint public MAX_CLAIMABLE = 5; // 0.5%
    uint public OWNER_FEES = 5; // 5%
    uint public constant LIQUIDATOR_FEES = 190;
    uint public constant PERCENTAGE = 100_0;
    uint public constant SHARE_BASE_PERCENTAGE = 90;
    uint public constant MAX_CLAIM_TIME = 24 hours;
    uint private constant MIN_INIT_DEPOSIT = 100 ether;
    uint private constant MIN_AMOUNT = 1 ether;
    uint public liquidationThresholdHours;
    //-------------------------------------------------------------------------
    // Events
    //-------------------------------------------------------------------------
    //------------------------------DRIP---------------------------------------
    event Deposit(
        address indexed user,
        uint usdtAmount,
        uint growAmount,
        uint timestamp
    );
    event Claim(
        address indexed user,
        uint grow_amount_sold,
        uint usdt_amount_received,
        uint timestamp
    );
    event Liquidated(
        address indexed liquidator,
        uint users_liquidated,
        uint grow_received_from_users,
        uint usdt_amount_for_liquidator,
        uint timestamp
    );
    event PriceAfterBurn(uint price, uint timestamp);
    event Quit(address indexed user, uint timestamp);
    //---------------------------OWNERSHIP-------------------------------------
    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );
    event OwnershipRenounced(address indexed previousOwner);
    event SetLiquidationThreshold(
        uint previousLiquidationThreshold,
        uint newLiquidationThreshold
    );
    //-------------------------------------------------------------------------
    // Modifiers
    //-------------------------------------------------------------------------
    modifier onlyOwner() {
        if (msg.sender == owner) _;
        else revert GrowDrip__OnlyOwner();
    }

    //-------------------------------------------------------------------------
    // Constructor
    //-------------------------------------------------------------------------
    /**
     * Create the GrowDrip contract
     * @param _usdt USDT token address
     * @param _grow GROW token address
     * @param _owners Dev team wallets
     * @param _shares Shares per wallet
     */
    constructor(
        address _usdt,
        address _grow,
        address[] memory _owners,
        uint[] memory _shares
    ) {
        if (_usdt == address(0) || _grow == address(0)) {
            revert GrowDrip__InvalidAddress();
        }
        USDT = IERC20(_usdt);
        GROW = IGrow(_grow);
        owner = msg.sender;
        liquidationThresholdHours = 25 hours;
        USDT.approve(_grow, type(uint).max);
        feeExemption[_owners[0]] = true;
        for (uint i = 0; i < _owners.length; i++) {
            owners.push(_owners[i]);
            shares.push(_shares[i]);
            totalShares += _shares[i];
        }
    }

    //-------------------------------------------------------------------------
    // EXTERNAL / PUBLIC FUNCTIONS
    //-------------------------------------------------------------------------

    /**
     * @notice Deposit USDT to the contract to start the DRIP
     * @param amount Amount of USDT to deposit
     * @dev If there is a pending claim, it'll claim it first.
     */
    function deposit(uint amount) external nonReentrant {
        _claim(msg.sender, false);
        User storage user = users[msg.sender];

        if (user.totalDeposited == 0) {
            if (amount < MIN_INIT_DEPOSIT)
                revert GrowDrip__MinInitDepositNotMet();
            user.position = allUsers.length;
            allUsers.push(msg.sender);
        }
        user.totalDeposited += amount;
        user.lastClaimed = block.timestamp;
        totalDeposits += amount;
        activeDeposits += amount;

        // Deposits creates Grow tokens
        uint growBuy = 0;
        if (feeExemption[msg.sender]) growBuy = (amount * 95) / 100;
        else growBuy = (amount * 9) / 10;

        uint taxAmount = amount - growBuy;
        // 15% tax here
        // buy with 90% of USDT taxless
        USDT.transferFrom(msg.sender, address(GROW), growBuy);
        USDT.transferFrom(msg.sender, address(this), taxAmount);

        uint growBought = GROW.buyFor(address(this), growBuy, address(USDT));
        // 10% burn after buy
        GROW.burnWithUnderlying(taxAmount, address(USDT));
        emit PriceAfterBurn(GROW.calculatePrice(), block.timestamp);
        // 5/90 of GROW to team
        if (!feeExemption[msg.sender])
            growBought = _distributeSharesFromFullValue(growBought);
        user.currentGrowAmount += growBought;
        emit Deposit(msg.sender, amount, growBought, block.timestamp);
    }

    /**
     * @notice Claim drip USDT from the contract
     * @dev This will only claim the caller's pending drip
     */
    function claim() external nonReentrant {
        _claim(msg.sender, false);
    }

    /**
     * @notice Liquidate users that have not claimed for 25 hours
     * @param usersToLiquidate List of users to liquidate
     * @dev If a user tries to liquidate a user who doesn't have a pending claim, it'll claim whatever is pending
     */
    function liquidateUsers(
        address[] calldata usersToLiquidate
    ) external nonReentrant {
        // Make sure it's a valid liquidator
        if (users[msg.sender].totalDeposited == 0)
            revert GrowDrip__InvalidLiquidator();
        // Liquidators can liquidate users that have not claimed for 25 hours
        uint liquidatorAmount;
        uint burnAmount;
        for (uint i = 0; i < usersToLiquidate.length; i++) {
            (uint liq, uint burn) = _claim(usersToLiquidate[i], true);
            liquidatorAmount += liq;
            burnAmount += burn;
        }
        if (liquidatorAmount == 0) revert GrowDrip__ZeroLiquidation();
        uint soldAmount = GROW.sell(liquidatorAmount, address(USDT));
        // Liquidators take 0.1% of the liquidated amount of each user
        // sell the GROW liquidatorAmount and transfer the USDT to them.
        USDT.transfer(msg.sender, soldAmount);
        liquidatorEarnings[msg.sender] += soldAmount;
        if (burnAmount > 0) {
            GROW.burnWithUnderlying(burnAmount, address(USDT));
            emit PriceAfterBurn(GROW.calculatePrice(), block.timestamp);
        }
        emit Liquidated(
            msg.sender,
            usersToLiquidate.length,
            liquidatorAmount,
            soldAmount,
            block.timestamp
        );
    }

    function quit() external nonReentrant {
        User storage user = users[msg.sender];
        if (user.totalDeposited == 0 || user.currentGrowAmount == 0)
            revert GrowDrip__InvalidOperation();

        // get taxed amount
        uint growAmount = user.currentGrowAmount;
        uint devAmount = growAmount / 10; // 10% fee for quitting
        uint burnTax = (growAmount * 5) / 100; // 5% sell tax

        growAmount -= devAmount;
        growAmount -= burnTax;

        uint usdtAmount = GROW.sell(growAmount, address(USDT));
        // reset USER
        activeDeposits -= user.totalDeposited;
        users[msg.sender] = User(0, 0, 0, user.totalClaimed + usdtAmount, 0);
        // remove user from list of active users
        allUsers[user.position] = allUsers[allUsers.length - 1];
        allUsers.pop();

        USDT.transfer(msg.sender, usdtAmount);
        GROW.burn(burnTax);
        emit PriceAfterBurn(GROW.calculatePrice(), block.timestamp);

        uint ownerShare = devAmount / 2;
        devAmount -= ownerShare;
        GROW.transfer(owners[0], ownerShare);
        GROW.transfer(owners[1], devAmount);
        emit Quit(msg.sender, block.timestamp);
    }

    function setLiquidationThreshold(uint _hours) external onlyOwner {
        if (_hours < 24 hours) revert GrowDrip__InvalidOperation();
        emit SetLiquidationThreshold(liquidationThresholdHours, _hours);
        liquidationThresholdHours = _hours;
    }

    function transferOwnership(address newOwner) external onlyOwner {
        emit OwnershipTransferred(owner, newOwner);
        owner = newOwner;
        if (newOwner == address(0)) {
            emit OwnershipRenounced(owner);
        }
    }

    function setFeeExemptStatus(address _who, bool _status) external onlyOwner {
        feeExemption[_who] = _status;
    }

    //-------------------------------------------------------------------------
    // PRIVATE/ INTERNAL FUNCTIONS
    //-------------------------------------------------------------------------

    function _claim(
        address _who,
        bool liquidator
    ) private returns (uint _liquidatorAmount, uint _burnAmount) {
        // do the entire liquidation sequence here
        // Do checks for _who
        User storage user = users[_who];
        if (user.totalDeposited == 0 || user.currentGrowAmount == 0)
            return (0, 0);
        // goal amount and growamount
        (, uint tokenAmount, uint growAmount) = claimable(_who);
        if (tokenAmount == 0) return (0, 0);
        // Liquidator Checks
        if (liquidator) {
            if (block.timestamp - user.lastClaimed < liquidationThresholdHours)
                return (0, 0);
        }

        // Do checks for liquidator
        // if user requires more than amount held, user is reset
        if (growAmount >= user.currentGrowAmount) {
            growAmount = user.currentGrowAmount;
            users[_who] = User(0, 0, 0, user.totalClaimed, 0);
            //remove user from list of active users
            allUsers[user.position] = allUsers[allUsers.length - 1];
            allUsers.pop();
            users[_who] = User(0, 0, 0, user.totalClaimed, 0);
        } else user.currentGrowAmount -= growAmount;
        // liquidator Maths
        if (liquidator) {
            // get 1/5th of the goalAmount to liquidator
            _liquidatorAmount = (growAmount * LIQUIDATOR_FEES) / PERCENTAGE;
            growAmount -= _liquidatorAmount;
        }
        uint trackGrow = growAmount;
        // sell all claimed amount
        tokenAmount = GROW.sell(growAmount, address(USDT));
        if (liquidator) {
            growAmount = (tokenAmount * 5) / 81; // 5% sell tax
            // Accumulate the 5% for a single massive burn
            _burnAmount = growAmount;
        } else {
            // burn 5% of the sell amount
            growAmount = (tokenAmount * 5) / 100; // 5% sell tax
            GROW.burnWithUnderlying(growAmount, address(USDT));
            emit PriceAfterBurn(GROW.calculatePrice(), block.timestamp);
        }
        tokenAmount -= growAmount;
        totalClaimed += tokenAmount;
        user.lastClaimed = block.timestamp;
        user.totalClaimed += tokenAmount;
        USDT.transfer(_who, tokenAmount);
        emit Claim(_who, trackGrow, tokenAmount, block.timestamp);
    }

    function _distributeSharesFromFullValue(
        uint _amount
    ) private returns (uint) {
        // Distribute the shares to the owners
        uint allShares = _ownerShares(_amount);
        for (uint i = 0; i < owners.length; i++) {
            uint share = (allShares * shares[i]) / totalShares;
            _amount -= share;
            GROW.transfer(owners[i], share);
        }
        return _amount;
    }

    //-------------------------------------------------------------------------
    // EXTERNAL / PUBLIC VIEW FUNCTIONS
    //-------------------------------------------------------------------------

    function claimable(
        address _who
    )
        public
        view
        returns (uint maxClaimableAmount, uint tokensToReceive, uint growToBurn)
    {
        User storage user = users[_who];
        // if not a current user, return 0
        if (user.totalDeposited == 0 || user.currentGrowAmount == 0)
            return (0, 0, 0);
        // Returns the amount of USDT that are claimable based on last action
        uint timeDiff = block.timestamp - user.lastClaimed;
        if (timeDiff > MAX_CLAIM_TIME) {
            timeDiff = MAX_CLAIM_TIME;
        }
        // This is capped at 0.5% of the deposited amount
        maxClaimableAmount = (user.totalDeposited * 5) / 100_0; // 0.5% of total deposited
        maxClaimableAmount = (timeDiff * maxClaimableAmount) / MAX_CLAIM_TIME;
        tokensToReceive = (maxClaimableAmount * 100) / 95;
        uint growPrice = GROW.calculatePrice();
        growToBurn = (tokensToReceive * 1 ether) / growPrice;
        if (growToBurn > user.currentGrowAmount) {
            growToBurn = user.currentGrowAmount;
        }
        tokensToReceive = (growToBurn * growPrice) / 1 ether;
    }

    /**
     * This function is intended for FRONTEND use only
     * @return pendingLiquidation List of all users that need to be liquidated
     * @return rewardAmounts
     */
    function usersPendingLiquidation()
        external
        view
        returns (
            address[] memory pendingLiquidation,
            uint[] memory rewardAmounts
        )
    {
        // Returns the list of users that are pending liquidation
        uint count;
        uint[] memory indexes = new uint[](allUsers.length);
        for (uint i = 0; i < allUsers.length; i++) {
            if (
                block.timestamp - users[allUsers[i]].lastClaimed >=
                liquidationThresholdHours * 1 hours
            ) {
                indexes[count] = i;
                count++;
            }
        }
        pendingLiquidation = new address[](count);
        rewardAmounts = new uint[](count);
        // Returns the amount of USDT that the liquidator will receive for liquidating each user
        for (uint j = 0; j < count; j++) {
            address pendingUser = allUsers[indexes[j]];
            pendingLiquidation[j] = pendingUser;
            (, uint actual, ) = claimable(pendingUser);
            rewardAmounts[j] = (actual * LIQUIDATOR_FEES) / PERCENTAGE;
        }
    }

    //-------------------------------------------------------------------------
    // PRIVATE / INTERNAL VIEW FUNCTIONS
    //-------------------------------------------------------------------------

    function _ownerShares(
        uint totalAmount
    ) private view returns (uint allShares) {
        allShares = (totalAmount * OWNER_FEES) / SHARE_BASE_PERCENTAGE;
    }

    function _maxClaimable(uint amount) private view returns (uint) {
        return (amount * MAX_CLAIMABLE) / PERCENTAGE;
    }
}