// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.23;

import { Context } from "@openzeppelin/contracts/utils/Context.sol";
import { IERC20 } from "@openzeppelin/contracts/interfaces/IERC20.sol";
import { EnumerableSet } from "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";
import { MerkleProof } from "@openzeppelin/contracts/utils/cryptography/MerkleProof.sol";
import { ReentrancyGuard } from "@openzeppelin/contracts/utils/ReentrancyGuard.sol";

import { Errors } from "./libraries/Errors.sol";
import { MathHelper } from "./libraries/MathHelper.sol";
import { ERC20Helper } from "./libraries/ERC20Helper.sol";
import { Round, RoundState } from "./types/Round.sol";
import { Configuration } from "./types/Configuration.sol";
import { Fee } from "./types/Fee.sol";
import { IMembership } from "./types/IMembership.sol";
import { ISaleMembership } from "./types/ISaleMembership.sol";
import { IVestingMembership } from "./types/IVestingMembership.sol";
import { IMembershipFactory } from "./types/IMembershipFactory.sol";

/**
 * @title Presale
 * @author
 * @notice
 */
contract Presale is Context, ReentrancyGuard {
    using EnumerableSet for EnumerableSet.UintSet;

    //-------------------------------------------------------------------------
    // Constants & Immutables

    uint256 internal constant ROUND_LOCK_PERIOD = 1 hours;
    uint256 internal constant TGE_LISTING_DIFFRENCE = 1 hours;

    /// @notice ERC20 implementation of the token sold.
    IERC20 public immutable tokenA;

    /// @notice ERC20 implementation of the token collected.
    IERC20 public immutable tokenB;

    /// @notice Address of the manager.
    address internal immutable manager;

    /// @notice Address of the feeCollector.
    address internal immutable feeCollector;

    /// @notice Address of the beneficiary.
    address internal immutable beneficiary;

    /// @notice Implementation of the ISaleMembership.
    ISaleMembership public immutable sMembership;

    /// @notice Implementation of the IVestingMembership.
    IVestingMembership public immutable vMembership;

    /// @notice Numerator for the fee calculation of tokenB.
    uint16 public immutable tokenBFeeNumerator;

    /// @notice Denominator for the fee calculation of tokenB.
    uint16 public immutable tokenBFeeDenominator;

    /// @notice Numerator for the fee calculation of tokenA.
    uint16 public immutable tokenAFeeNumerator;

    /// @notice Denominator for the fee calculation of tokenA.
    uint16 public immutable tokenAFeeDenominator;

    /// @notice How much time in seconds since `listingTimestamp` do Users have to refund TokenA
    uint256 public immutable refundsPeriod;

    //-------------------------------------------------------------------------
    // Storage

    /// @notice Amount of tokens available to distribution during the vesting.
    uint256 public liquidityA;

    /// @notice Amount of tokens collected during the sale.
    uint256 public liquidityB;

    /// @notice Timestamp indicating when the tge should be available.
    uint256 public listingTimestamp;

    /// @notice Incremental value for indexing rounds.
    uint256 internal roundSerialId;

    /// @notice Unlocked amount of tokenB which can be withdrawn to beneficiary.
    uint256 public amountBToWithdraw;

    /// @notice Amount of token B fee for feeCollector.
    uint256 public feeCollectorTokenB;

    /// @notice Amount of token B fee for beneficiary.
    uint256 public beneficiaryTokenB;

    /// @notice Unsold amount of token A which can be withdrawn to,beneficiary.
    uint256 public unsoldAAmount;

    /// @notice List of rounds ids.
    EnumerableSet.UintSet internal roundsIds;

    /// @notice Collection of the rounds.
    mapping(uint256 roundId => Round) internal rounds;

    /// @notice Indicates whether the account participated in the sale state of given round.
    mapping(uint256 roundId => mapping(address => bool)) internal roundParticipants;

    //-------------------------------------------------------------------------
    // Events

    /// @notice Event emitted when the funds has been claimed.
    /// @param vMembershipId Id of the membership.
    /// @param amountA Amount of the claimed funds.
    event Claimed(uint256 vMembershipId, uint256 amountA);

    /// @notice Event emitted when the funds has been deposited.
    /// @param amountA Amount of the deposited funds.
    event Deposited(uint256 amountA);

    /// @notice Event emitted when the round has been updated.
    /// @param id The id of the round.
    event UpdatedRound(uint256 id);

    /// @notice Event emitted when the tge start timestamp has been updated.
    /// @param timestamp The new timestamp.
    event ListingTimestampUpdated(uint256 timestamp);

    /// @notice Event emitted when amountBToWithdraw has been increased.
    /// @param amountBToWithdraw New value of `amountBToWithdraw` after increasing.
    event AmountToWithdrawIncreased(uint256 amountBToWithdraw);

    /// @notice Event emitted when tokenB is has been withdrawn to beneficiary.
    /// @param withdrawnAmountB New value of `amountToWithdraw` after increasing.
    event Withdrawn(uint256 withdrawnAmountB);

    /// @notice Event emitted when tokenB fee has been withdrawn to feeCollector.
    /// @param amountB amount of fee transfered to feeCollector.
    event TokenBFeeCollected(uint256 amountB);

    /// @notice Event emitted when unsold tokens A has been withdrawn to beneficiary.
    /// @param amount amount of unsold tokens were withdrawn.
    event UnsoldTokensAWithdrawn(uint256 amount);

    //-------------------------------------------------------------------------
    // Errors

    /// @notice Cannot update the locked round.
    /// @param id Id of the round.
    error RoundIsLocked(uint256 id);

    /// @notice The round with given id does not exist.
    /// @param id Id of the round.
    error RoundNotExists(uint256 id);

    /// @notice Round is in a different state.
    /// @param id The id of updated round.
    /// @param current Current state of the round.
    /// @param expected Expected state of the round.
    error RoundStateMismatch(uint256 id, RoundState current, RoundState expected);

    /// @notice Claim not allowed by given membership.
    /// @param sMembershipId Id of the membership.
    error ClaimNotAllowed(uint256 sMembershipId);

    /// @notice Refund not allowed for given membership.
    /// @param sMembershipId Id of the membership.
    error RefundNotAllowed(uint256 sMembershipId);

    //--------------------------------------------------------------------------
    // Construction & Initialization

    /// @notice Ensure the sender is the manager.
    /// @param account Address of the sender.
    modifier onlyManager(address account) {
        if (account != manager) revert Errors.Unauthorized(account);
        _;
    }

    /// @notice Ensures that the selected round has given state.
    /// @param roundId Id of the round.
    /// @param expected Expected state of the round.
    modifier onlyRoundInState(uint256 roundId, RoundState expected) {
        RoundState current = getRoundState(roundId);

        if (current != expected) revert RoundStateMismatch(roundId, current, expected);
        _;
    }

    /// @notice Contract state initialization.
    /// @param configuration Configuration of the presale.
    /// @param rounds_ Rounds of the presale.
    constructor(Configuration memory configuration, Round[] memory rounds_, Fee memory fee) {
        if (address(configuration.tokenB) == address(0)) revert Errors.UnacceptableReference();
        if (address(configuration.tokenA) == address(0)) revert Errors.UnacceptableReference();
        if (address(configuration.manager) == address(0)) revert Errors.UnacceptableReference();
        if (address(configuration.feeCollector) == address(0)) revert Errors.UnacceptableReference();
        if (address(configuration.beneficiary) == address(0)) revert Errors.UnacceptableReference();
        if (address(configuration.sMembership.factory) == address(0)) revert Errors.UnacceptableReference();
        if (address(configuration.vMembership.factory) == address(0)) revert Errors.UnacceptableReference();

        // Fee has to be lower than 100%.
        if (fee.tokenBFeeNumerator / fee.tokenBFeeDenominator >= 1) revert Errors.UnacceptableValue();
        if (fee.tokenAFeeNumerator / fee.tokenAFeeDenominator >= 1) revert Errors.UnacceptableValue();

        tokenBFeeNumerator = fee.tokenBFeeNumerator;
        tokenBFeeDenominator = fee.tokenBFeeDenominator;
        tokenAFeeNumerator = fee.tokenAFeeNumerator;
        tokenAFeeDenominator = fee.tokenAFeeDenominator;

        tokenB = configuration.tokenB;
        tokenA = configuration.tokenA;

        manager = configuration.manager;
        beneficiary = configuration.beneficiary;
        feeCollector = configuration.feeCollector;

        listingTimestamp = configuration.listingTimestamp;
        refundsPeriod = configuration.refundsPeriod;

        sMembership = ISaleMembership(
            IMembershipFactory(configuration.sMembership.factory).create(
                address(this),
                configuration.feeCollector,
                configuration.royaltyFraction,
                getTgeTimestamp(),
                configuration.sMembership.metadata
            )
        );

        vMembership = IVestingMembership(
            IMembershipFactory(configuration.vMembership.factory).create(
                address(this),
                configuration.feeCollector,
                configuration.royaltyFraction,
                getTgeTimestamp(),
                configuration.vMembership.metadata
            )
        );

        uint256 size = rounds_.length;
        for (uint256 i = 0; i < size; i++) {
            _addRound(rounds_[i]);
        }
    }

    //--------------------------------------------------------------------------
    // Rounds configuration

    /// @notice Adds new round.
    /// @param round Configuration of the round.
    function addRound(Round memory round) external onlyManager(_msgSender()) {
        _addRound(round);
    }

    /// @notice Updates the round.
    /// @param roundId Id of the round.
    /// @param round Configuration of the round.
    function updateRound(uint256 roundId, Round memory round) external onlyManager(_msgSender()) {
        if (round.startTimestamp >= round.endTimestamp) revert Errors.UnacceptableValue();

        if (block.timestamp >= rounds[roundId].startTimestamp - ROUND_LOCK_PERIOD) {
            revert RoundIsLocked(roundId);
        }

        rounds[roundId] = round;

        emit UpdatedRound(roundId);
    }

    /// @notice Removes the round.
    /// @param roundId Id of the round.
    function removeRound(uint256 roundId) external onlyManager(_msgSender()) {
        if (!roundsIds.contains(roundId)) revert RoundNotExists(roundId);

        if (block.timestamp >= rounds[roundId].startTimestamp - ROUND_LOCK_PERIOD) {
            revert RoundIsLocked(roundId);
        }

        roundsIds.remove(roundId);

        emit UpdatedRound(roundId);
    }

    /// @notice Updates the round whitelist configuration.
    /// @param roundId Id of the round.
    /// @param whitelistRoot Merkle tree root.
    /// @param proofsUri The uri of the proofs.
    function updateWhitelist(uint256 roundId, bytes32 whitelistRoot, string memory proofsUri)
        external
        onlyManager(_msgSender())
    {
        rounds[roundId].proofsUri = proofsUri;
        rounds[roundId].whitelistRoot = whitelistRoot;

        emit UpdatedRound(roundId);
    }

    //--------------------------------------------------------------------------
    // Domain

    /// @notice Transfers `tokenB` tokens and creates the sMembership.
    /// @param roundId Id of the round.
    /// @param amountA amount of token A to buy
    /// @param attributes The membership attributes.
    /// @param proof Merkle tree proof.
    function buyWithProofs(
        uint256 roundId,
        uint256 amountA,
        IMembership.Attributes memory attributes,
        bytes32[] calldata proof
    ) external onlyRoundInState(roundId, RoundState.SALE) {
        address sender = _msgSender();

        bool authorized = _canParticipateInSale(roundId, sender, attributes, proof);

        if (!authorized) revert Errors.AccountMismatch(sender);

        roundParticipants[roundId][sender] = true;

        uint256 membershipId = sMembership.mint(sender, roundId, attributes.allocation, attributes);

        _buyWithSaleMembership(membershipId, amountA);
    }

    /// @notice Transfers `tokenB` tokens and updates usage of the given sMembership.
    /// @param sMembershipId Id of the membership.
    /// @param amountA Amount of tokens to extend the sMembership.
    function buyWithSaleMembership(uint256 sMembershipId, uint256 amountA)
        external
        onlyRoundInState(sMembership.getRoundId(sMembershipId), RoundState.SALE)
    {
        if (sMembership.ownerOf(sMembershipId) != _msgSender()) revert Errors.AccountMismatch(_msgSender());

        _buyWithSaleMembership(sMembershipId, amountA);
    }

    /**
     * @notice Refunds `tokenB` tokens to the membership owner and adds `tokenA` tokens back to the `liquidityA`.
     * @param sMembershipId Id of the membership.
     * @param amountB Amount of `tokenB` tokens to refund.
     *
     * Requirements:
     * - the current timestamp must be earlier than the `refundsEndTimestamp`
     * - the caller must have a sale membership
     * - the sale membership must have an ability to refund (`available` > 0)
     */
    function refund(uint256 sMembershipId, uint256 amountB) external {
        uint256 available = sMembership.refundable(sMembershipId);
        uint256 refundsEndTimestamp = listingTimestamp + refundsPeriod;

        if (block.timestamp > refundsEndTimestamp || available == 0) {
            revert RefundNotAllowed(sMembershipId);
        }

        address sender = _msgSender();

        if (sMembership.ownerOf(sMembershipId) != sender) revert Errors.AccountMismatch(sender);

        IMembership.Attributes memory attributes = sMembership.getAttributes(sMembershipId);

        uint256 denominator = 10 ** ERC20Helper.decimals(tokenA);

        // Calculates the maximum number of `tokenB` tokens to be refunded to the membership owner.
        uint256 refundable = MathHelper.min(amountB, available * attributes.price / denominator);

        // Calculates the number of `tokenAs` tokens to be returned to the `liquidityA`.
        uint256 returnable = refundable * denominator / attributes.price;

        sMembership.beforeRefund(sMembershipId, returnable);

        unchecked {
            liquidityB -= refundable;
            liquidityA += returnable;
            unsoldAAmount += returnable;
        }

        ERC20Helper.transfer(tokenB, sender, refundable);
    }

    /// @notice Creates vMembership and transfers releasable `tokenA` tokens to the caller.
    /// @param sMembershipId Id of membership.
    function claimWithSaleMembership(uint256 sMembershipId) external {
        address sender = _msgSender();

        if (sMembership.ownerOf(sMembershipId) != sender) revert Errors.AccountMismatch(sender);
        uint256 tgeTimestamp = getTgeTimestamp();
        if (tgeTimestamp == 0 || block.timestamp < tgeTimestamp) revert ClaimNotAllowed(sMembershipId);

        IMembership.Usage memory usage = sMembership.getUsage(sMembershipId);

        /**
         * Claim is not possible when usage is equals to zero. This occurs when the user
         * has already used the maximum ability to create new vesting memberships.
         */
        if (usage.max == 0 || usage.current == 0) revert ClaimNotAllowed(sMembershipId);

        /**
         * Claiming affects the sale membership:
         *
         * - redefines sale membership usage - caller can make another purchase if it is possible
         * - blocks the possibility of making a refund
         */
        sMembership.beforeClaim(sMembershipId, usage.max - usage.current);

        uint256 vMembershipId = vMembership.mint(
            sender, sMembership.getRoundId(sMembershipId), usage.current, sMembership.getAttributes(sMembershipId)
        );

        uint256 denominator = 10 ** ERC20Helper.decimals(tokenA);

        /// @dev overflow not possible because amountToWithdraw always less than tokenB total supply.
        unchecked {
            amountBToWithdraw += (usage.current * denominator) / vMembership.getAttributes(vMembershipId).price;
        }

        _release(vMembershipId);
    }

    /// @notice Transfers releasable `tokenA` tokens and updates usage of the given vMembership.
    /// @param vMembershipId Id of the membership.
    function claimWithVestingMembership(uint256 vMembershipId) external {
        if (vMembership.ownerOf(vMembershipId) != _msgSender()) revert Errors.AccountMismatch(_msgSender());

        _release(vMembershipId);
    }

    /// @notice Deposits the `tokenA`.
    /// @param amountA Amount of the tokens to deposit.
    function depositTokenForSale(uint256 amountA) external {
        uint256 deposited = ERC20Helper.transferFrom(tokenA, _msgSender(), address(this), amountA);

        unchecked {
            /// @dev overflow is not possible because transferred amount cannot be higher than token supply.
            liquidityA += deposited;
            unsoldAAmount += deposited;
        }

        emit Deposited(deposited);
    }

    /// @notice Withdrawn unlocked tokenB to beneficiary.
    function triggerTokenBDistribution() external {
        uint256 fee;

        require(listingTimestamp != 0, "not allowed before the listing");

        /// @notice if refunds timestamp in past beneficiary can get all liquidity.
        if (block.timestamp > listingTimestamp + refundsPeriod) {
            amountBToWithdraw = liquidityB;
        }

        /// @dev over/underflow not possible here because fee always will be less than `amountToWithdraw` such as percent of fee cannot be higher or equal than 100.
        unchecked {
            fee = (amountBToWithdraw * tokenBFeeNumerator) / tokenBFeeDenominator;
        }

        feeCollectorTokenB += fee;

        uint256 amount = amountBToWithdraw - fee;

        /// @dev rewrite value to local variable for protecting from reentrancy.
        amountBToWithdraw = 0;
        amount += beneficiaryTokenB;
        beneficiaryTokenB = 0;

        ERC20Helper.transfer(tokenB, beneficiary, amount - fee);

        emit Withdrawn(amountBToWithdraw);
    }

    /// @notice Withdrawn fees tokenB to feeCollector.
    function triggerFeesDistribution() external {
        uint256 fee;

        /// @notice if refunds timestamp in past fee collector can get whole fee in one time.
        if (block.timestamp > listingTimestamp + refundsPeriod) {
            amountBToWithdraw = liquidityB;
        }

        /// @dev over/underflow not possible here because fee always will be less than `amountToWithdraw` such as percent of fee cannot be higher or equal than 100.
        unchecked {
            fee = (amountBToWithdraw * tokenBFeeNumerator) / tokenBFeeDenominator;
        }

        beneficiaryTokenB += amountBToWithdraw - fee;

        /// @dev rewrite value to local variable for protecting from reentrancy.
        amountBToWithdraw = 0;
        fee += feeCollectorTokenB;
        feeCollectorTokenB = 0;

        ERC20Helper.transfer(tokenB, feeCollector, fee);

        emit TokenBFeeCollected(fee);
    }

    /**
     * @notice Beneficiary can withdraw tokenA at any time.
     * @param amountA amount of tokenA to withdraw
     */
    function withdrawUnsoldTokens(uint256 amountA) external {
        if (_msgSender() != beneficiary) revert Errors.Unauthorized(_msgSender());
        if (amountA > unsoldAAmount) revert Errors.UnacceptableValue();

        /// @dev underflow not possible because we checked before that `amountA` < `unsoldAAmount`
        unchecked {
            unsoldAAmount -= amountA;
        }

        ERC20Helper.transfer(tokenA, beneficiary, amountA);

        emit UnsoldTokensAWithdrawn(amountA);
    }

    /**
     * @notice Beneficiary can update listing timestamp
     * @param listingTimestamp_ new listing timestamp
     */
    function updateListingTimestamp(uint256 listingTimestamp_) external onlyManager(_msgSender()) {
        // The value cannot be in the past.
        if (listingTimestamp_ < block.timestamp) revert Errors.UnacceptableValue();

        // Cannot set tge start if it has already passed.
        if (listingTimestamp != 0 && listingTimestamp < block.timestamp) revert Errors.UnacceptableValue();

        listingTimestamp = listingTimestamp_;

        sMembership.setTgeTimestamp(getTgeTimestamp());
        vMembership.setTgeTimestamp(getTgeTimestamp());

        emit ListingTimestampUpdated(listingTimestamp_);
    }

    /// @notice Withdraws the token to the recipient.
    /// @param to Address of the recipient.
    /// @param token Address of the token.
    /// @param amount Amount to withdraw.
    function withdrawToken(address to, IERC20 token, uint256 amount) external onlyManager(_msgSender()) {
        if (to == address(0)) revert Errors.UnacceptableReference();

        ERC20Helper.transfer(token, to, amount);
    }

    function getTgeTimestamp() public view returns (uint256) {
        if (listingTimestamp < 1 hours) return 0;
        return listingTimestamp - TGE_LISTING_DIFFRENCE;
    }

    //--------------------------------------------------------------------------
    // Misc

    /// @notice Returns the list of the rounds and their ids and states.
    function getRounds() external view returns (uint256[] memory, Round[] memory, RoundState[] memory) {
        uint256[] memory ids = roundsIds.values();

        uint256 size = ids.length;
        Round[] memory items = new Round[](size);
        RoundState[] memory states = new RoundState[](size);
        for (uint256 i = 0; i < size; i++) {
            items[i] = rounds[ids[i]];
            states[i] = getRoundState(ids[i]);
        }

        return (ids, items, states);
    }

    /// @notice Returns the round.
    /// @param roundId Id of the round.
    function getRound(uint256 roundId) public view returns (Round memory) {
        if (!roundsIds.contains(roundId)) revert RoundNotExists(roundId);

        return rounds[roundId];
    }

    /// @notice Returns the round state.
    /// @param roundId Id of the round.
    function getRoundState(uint256 roundId) public view returns (RoundState) {
        uint256 timestamp = block.timestamp;

        if (timestamp < rounds[roundId].startTimestamp) return RoundState.PENDING;

        if (timestamp > rounds[roundId].endTimestamp || liquidityA == 0) {
            return RoundState.VESTING;
        }

        return RoundState.SALE;
    }

    /// @notice Adds new round.
    /// @param round Configuration of the round.
    function _addRound(Round memory round) internal {
        if (round.startTimestamp >= round.endTimestamp) revert Errors.UnacceptableValue();

        unchecked {
            ++roundSerialId;
        }

        roundsIds.add(roundSerialId);

        rounds[roundSerialId] = round;

        emit UpdatedRound(roundSerialId);
    }

    /**
     * @notice Transfers `tokenA` tokens and updates usage of the given membership.
     * @param sMembershipId Id of the membership.
     * @param amountB Amount of tokenA to extend the membership.
     *
     * @dev Some state changes are performed after token transfer.
     * The `nonReentrant` modifier is used to protect against reentrancy attack.
     */
    // slither-disable-next-line reentrancy-no-eth
    function _buyWithSaleMembership(uint256 sMembershipId, uint256 amountB) internal nonReentrant {
        /**
         * @dev The `SaleMembership.Usage` properties represent:
         * - `max`: the number of tokens available to be purchased
         * - `current`: the number of tokens purchased
         *
         * The `remainingUsage` is equal to the difference between `max` and `current`.
         */
        uint256 remainingUsage = sMembership.getRemainingUsage(sMembershipId);

        if (remainingUsage == 0) return;

        IMembership.Attributes memory attributes = sMembership.getAttributes(sMembershipId);

        /**
         * Handling the case of an account that has a free membership.
         * In this scenario should receive the remaining of the number of tokens in full,
         * without transferring the `tokenB` tokens.
         */
        if (attributes.price == 0) {
            liquidityA -= remainingUsage;

            sMembership.increaseUsage(sMembershipId, remainingUsage);

            return;
        }

        /**
         * Steps to follow when the membership has a custom price:
         *
         * - calculate how many tokens (`liquidity`) the membership can receive
         * - convert the `amount` of `tokenB` tokens to the number (`amount1`) of `tokenA` tokens
         * - calculate the number of tokens to transfer (`total`):
         *   - when the sender tries to buy exactly/fewer tokens he can purchase ->
         *     transfer the given `amount`
         *   - when the sender tries to buy more tokens he can purchase -> calculate amount
         *     using available `liquidity` and `price`
         * - transfer `tokenB` tokens and check exactly how many have been transferred (`deposited`)
         * - convert the `deposited` of `tokenB` tokens to the number (`released`) of `tokenA` tokens
         * - increase the `sMembership` membership usage by `released`
         */
        uint256 liquidityA_ = MathHelper.min(liquidityA, remainingUsage);

        uint256 denominatorA = 10 ** ERC20Helper.decimals(tokenA);

        uint256 amountA = (amountB * denominatorA) / attributes.price;

        uint256 totalB = amountA <= liquidityA_ ? amountB : liquidityA_ * attributes.price / denominatorA;
        uint256 deposited = ERC20Helper.transferFrom(tokenB, _msgSender(), address(this), totalB);

        uint256 released = (deposited * denominatorA) / attributes.price;

        unchecked {
            liquidityB += deposited;
            liquidityA -= released;
            unsoldAAmount -= released;
        }

        sMembership.increaseUsage(sMembershipId, released);
    }

    /// @notice Transfers releasable `tokenA` tokens and updates usage of the given vMembership.
    /// @param vMembershipId Id of the membership.
    function _release(uint256 vMembershipId) internal {
        IMembership.Usage memory usage = vMembership.getUsage(vMembershipId);

        IMembership.Attributes memory attributes = vMembership.getAttributes(vMembershipId);

        /**
         * @dev Calculate the releasable `amount` based on the difference of available tokens
         * at a given point in time and tokens already released.
         *
         * The `VestingMembership.Usage` properties represent:
         * - `max`: the number of all tokens available to be released
         * - `current`: the number of tokens already released
         */
        uint256 amountA = vMembership.releasable(vMembershipId) - usage.current;

        if (amountA == 0) return;

        vMembership.increaseUsage(vMembershipId, amountA);

        ERC20Helper.transfer(tokenA, _msgSender(), amountA);

        emit AmountToWithdrawIncreased(amountBToWithdraw);
        emit Claimed(vMembershipId, amountA);
    }

    /**
     * @notice Determines whether an account can participate in sale state of a given round.
     *
     * Account cannot participate in the sale state if it is not on the whitelist or has
     * already participated in a round.
     *
     * @param roundId Id of the round.
     * @param account The address of the account.
     * @param attributes The membership attributes.
     * @param proof Merkle tree proof.
     */
    function _canParticipateInSale(
        uint256 roundId,
        address account,
        IMembership.Attributes memory attributes,
        bytes32[] memory proof
    ) internal view returns (bool) {
        if (roundParticipants[roundId][account]) return false;

        return MerkleProof.verify(
            proof,
            rounds[roundId].whitelistRoot,
            keccak256(
                abi.encode(
                    account,
                    attributes.price,
                    attributes.allocation,
                    attributes.refundableUnit,
                    attributes.tgeNumerator,
                    attributes.tgeDenominator,
                    attributes.cliffDuration,
                    attributes.cliffNumerator,
                    attributes.cliffDenominator,
                    attributes.vestingPeriodCount,
                    attributes.vestingPeriodDuration
                )
            )
        );
    }
}
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v5.0.1) (utils/Context.sol)

pragma solidity ^0.8.20;

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

    function _contextSuffixLength() internal view virtual returns (uint256) {
        return 0;
    }
}
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v5.0.0) (interfaces/IERC20.sol)

pragma solidity ^0.8.20;

import {IERC20} from "../token/ERC20/IERC20.sol";
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v5.0.0) (utils/structs/EnumerableSet.sol)
// This file was procedurally generated from scripts/generate/templates/EnumerableSet.js.

pragma solidity ^0.8.20;

/**
 * @dev Library for managing
 * https://en.wikipedia.org/wiki/Set_(abstract_data_type)[sets] of primitive
 * types.
 *
 * Sets have the following properties:
 *
 * - Elements are added, removed, and checked for existence in constant time
 * (O(1)).
 * - Elements are enumerated in O(n). No guarantees are made on the ordering.
 *
 * ```solidity
 * contract Example {
 *     // Add the library methods
 *     using EnumerableSet for EnumerableSet.AddressSet;
 *
 *     // Declare a set state variable
 *     EnumerableSet.AddressSet private mySet;
 * }
 * ```
 *
 * As of v3.3.0, sets of type `bytes32` (`Bytes32Set`), `address` (`AddressSet`)
 * and `uint256` (`UintSet`) are supported.
 *
 * [WARNING]
 * ====
 * Trying to delete such a structure from storage will likely result in data corruption, rendering the structure
 * unusable.
 * See https://github.com/ethereum/solidity/pull/11843[ethereum/solidity#11843] for more info.
 *
 * In order to clean an EnumerableSet, you can either remove all elements one by one or create a fresh instance using an
 * array of EnumerableSet.
 * ====
 */
library EnumerableSet {
    // To implement this library for multiple types with as little code
    // repetition as possible, we write it in terms of a generic Set type with
    // bytes32 values.
    // The Set implementation uses private functions, and user-facing
    // implementations (such as AddressSet) are just wrappers around the
    // underlying Set.
    // This means that we can only create new EnumerableSets for types that fit
    // in bytes32.

    struct Set {
        // Storage of set values
        bytes32[] _values;
        // Position is the index of the value in the `values` array plus 1.
        // Position 0 is used to mean a value is not in the set.
        mapping(bytes32 value => uint256) _positions;
    }

    /**
     * @dev Add a value to a set. O(1).
     *
     * Returns true if the value was added to the set, that is if it was not
     * already present.
     */
    function _add(Set storage set, bytes32 value) private returns (bool) {
        if (!_contains(set, value)) {
            set._values.push(value);
            // The value is stored at length-1, but we add 1 to all indexes
            // and use 0 as a sentinel value
            set._positions[value] = set._values.length;
            return true;
        } else {
            return false;
        }
    }

    /**
     * @dev Removes a value from a set. O(1).
     *
     * Returns true if the value was removed from the set, that is if it was
     * present.
     */
    function _remove(Set storage set, bytes32 value) private returns (bool) {
        // We cache the value's position to prevent multiple reads from the same storage slot
        uint256 position = set._positions[value];

        if (position != 0) {
            // Equivalent to contains(set, value)
            // To delete an element from the _values array in O(1), we swap the element to delete with the last one in
            // the array, and then remove the last element (sometimes called as 'swap and pop').
            // This modifies the order of the array, as noted in {at}.

            uint256 valueIndex = position - 1;
            uint256 lastIndex = set._values.length - 1;

            if (valueIndex != lastIndex) {
                bytes32 lastValue = set._values[lastIndex];

                // Move the lastValue to the index where the value to delete is
                set._values[valueIndex] = lastValue;
                // Update the tracked position of the lastValue (that was just moved)
                set._positions[lastValue] = position;
            }

            // Delete the slot where the moved value was stored
            set._values.pop();

            // Delete the tracked position for the deleted slot
            delete set._positions[value];

            return true;
        } else {
            return false;
        }
    }

    /**
     * @dev Returns true if the value is in the set. O(1).
     */
    function _contains(Set storage set, bytes32 value) private view returns (bool) {
        return set._positions[value] != 0;
    }

    /**
     * @dev Returns the number of values on the set. O(1).
     */
    function _length(Set storage set) private view returns (uint256) {
        return set._values.length;
    }

    /**
     * @dev Returns the value stored at position `index` in the set. O(1).
     *
     * Note that there are no guarantees on the ordering of values inside the
     * array, and it may change when more values are added or removed.
     *
     * Requirements:
     *
     * - `index` must be strictly less than {length}.
     */
    function _at(Set storage set, uint256 index) private view returns (bytes32) {
        return set._values[index];
    }

    /**
     * @dev Return the entire set in an array
     *
     * WARNING: This operation will copy the entire storage to memory, which can be quite expensive. This is designed
     * to mostly be used by view accessors that are queried without any gas fees. Developers should keep in mind that
     * this function has an unbounded cost, and using it as part of a state-changing function may render the function
     * uncallable if the set grows to a point where copying to memory consumes too much gas to fit in a block.
     */
    function _values(Set storage set) private view returns (bytes32[] memory) {
        return set._values;
    }

    // Bytes32Set

    struct Bytes32Set {
        Set _inner;
    }

    /**
     * @dev Add a value to a set. O(1).
     *
     * Returns true if the value was added to the set, that is if it was not
     * already present.
     */
    function add(Bytes32Set storage set, bytes32 value) internal returns (bool) {
        return _add(set._inner, value);
    }

    /**
     * @dev Removes a value from a set. O(1).
     *
     * Returns true if the value was removed from the set, that is if it was
     * present.
     */
    function remove(Bytes32Set storage set, bytes32 value) internal returns (bool) {
        return _remove(set._inner, value);
    }

    /**
     * @dev Returns true if the value is in the set. O(1).
     */
    function contains(Bytes32Set storage set, bytes32 value) internal view returns (bool) {
        return _contains(set._inner, value);
    }

    /**
     * @dev Returns the number of values in the set. O(1).
     */
    function length(Bytes32Set storage set) internal view returns (uint256) {
        return _length(set._inner);
    }

    /**
     * @dev Returns the value stored at position `index` in the set. O(1).
     *
     * Note that there are no guarantees on the ordering of values inside the
     * array, and it may change when more values are added or removed.
     *
     * Requirements:
     *
     * - `index` must be strictly less than {length}.
     */
    function at(Bytes32Set storage set, uint256 index) internal view returns (bytes32) {
        return _at(set._inner, index);
    }

    /**
     * @dev Return the entire set in an array
     *
     * WARNING: This operation will copy the entire storage to memory, which can be quite expensive. This is designed
     * to mostly be used by view accessors that are queried without any gas fees. Developers should keep in mind that
     * this function has an unbounded cost, and using it as part of a state-changing function may render the function
     * uncallable if the set grows to a point where copying to memory consumes too much gas to fit in a block.
     */
    function values(Bytes32Set storage set) internal view returns (bytes32[] memory) {
        bytes32[] memory store = _values(set._inner);
        bytes32[] memory result;

        /// @solidity memory-safe-assembly
        assembly {
            result := store
        }

        return result;
    }

    // AddressSet

    struct AddressSet {
        Set _inner;
    }

    /**
     * @dev Add a value to a set. O(1).
     *
     * Returns true if the value was added to the set, that is if it was not
     * already present.
     */
    function add(AddressSet storage set, address value) internal returns (bool) {
        return _add(set._inner, bytes32(uint256(uint160(value))));
    }

    /**
     * @dev Removes a value from a set. O(1).
     *
     * Returns true if the value was removed from the set, that is if it was
     * present.
     */
    function remove(AddressSet storage set, address value) internal returns (bool) {
        return _remove(set._inner, bytes32(uint256(uint160(value))));
    }

    /**
     * @dev Returns true if the value is in the set. O(1).
     */
    function contains(AddressSet storage set, address value) internal view returns (bool) {
        return _contains(set._inner, bytes32(uint256(uint160(value))));
    }

    /**
     * @dev Returns the number of values in the set. O(1).
     */
    function length(AddressSet storage set) internal view returns (uint256) {
        return _length(set._inner);
    }

    /**
     * @dev Returns the value stored at position `index` in the set. O(1).
     *
     * Note that there are no guarantees on the ordering of values inside the
     * array, and it may change when more values are added or removed.
     *
     * Requirements:
     *
     * - `index` must be strictly less than {length}.
     */
    function at(AddressSet storage set, uint256 index) internal view returns (address) {
        return address(uint160(uint256(_at(set._inner, index))));
    }

    /**
     * @dev Return the entire set in an array
     *
     * WARNING: This operation will copy the entire storage to memory, which can be quite expensive. This is designed
     * to mostly be used by view accessors that are queried without any gas fees. Developers should keep in mind that
     * this function has an unbounded cost, and using it as part of a state-changing function may render the function
     * uncallable if the set grows to a point where copying to memory consumes too much gas to fit in a block.
     */
    function values(AddressSet storage set) internal view returns (address[] memory) {
        bytes32[] memory store = _values(set._inner);
        address[] memory result;

        /// @solidity memory-safe-assembly
        assembly {
            result := store
        }

        return result;
    }

    // UintSet

    struct UintSet {
        Set _inner;
    }

    /**
     * @dev Add a value to a set. O(1).
     *
     * Returns true if the value was added to the set, that is if it was not
     * already present.
     */
    function add(UintSet storage set, uint256 value) internal returns (bool) {
        return _add(set._inner, bytes32(value));
    }

    /**
     * @dev Removes a value from a set. O(1).
     *
     * Returns true if the value was removed from the set, that is if it was
     * present.
     */
    function remove(UintSet storage set, uint256 value) internal returns (bool) {
        return _remove(set._inner, bytes32(value));
    }

    /**
     * @dev Returns true if the value is in the set. O(1).
     */
    function contains(UintSet storage set, uint256 value) internal view returns (bool) {
        return _contains(set._inner, bytes32(value));
    }

    /**
     * @dev Returns the number of values in the set. O(1).
     */
    function length(UintSet storage set) internal view returns (uint256) {
        return _length(set._inner);
    }

    /**
     * @dev Returns the value stored at position `index` in the set. O(1).
     *
     * Note that there are no guarantees on the ordering of values inside the
     * array, and it may change when more values are added or removed.
     *
     * Requirements:
     *
     * - `index` must be strictly less than {length}.
     */
    function at(UintSet storage set, uint256 index) internal view returns (uint256) {
        return uint256(_at(set._inner, index));
    }

    /**
     * @dev Return the entire set in an array
     *
     * WARNING: This operation will copy the entire storage to memory, which can be quite expensive. This is designed
     * to mostly be used by view accessors that are queried without any gas fees. Developers should keep in mind that
     * this function has an unbounded cost, and using it as part of a state-changing function may render the function
     * uncallable if the set grows to a point where copying to memory consumes too much gas to fit in a block.
     */
    function values(UintSet storage set) internal view returns (uint256[] memory) {
        bytes32[] memory store = _values(set._inner);
        uint256[] memory result;

        /// @solidity memory-safe-assembly
        assembly {
            result := store
        }

        return result;
    }
}
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v5.0.0) (utils/cryptography/MerkleProof.sol)

pragma solidity ^0.8.20;

/**
 * @dev These functions deal with verification of Merkle Tree proofs.
 *
 * The tree and the proofs can be generated using our
 * https://github.com/OpenZeppelin/merkle-tree[JavaScript library].
 * You will find a quickstart guide in the readme.
 *
 * WARNING: You should avoid using leaf values that are 64 bytes long prior to
 * hashing, or use a hash function other than keccak256 for hashing leaves.
 * This is because the concatenation of a sorted pair of internal nodes in
 * the Merkle tree could be reinterpreted as a leaf value.
 * OpenZeppelin's JavaScript library generates Merkle trees that are safe
 * against this attack out of the box.
 */
library MerkleProof {
    /**
     *@dev The multiproof provided is not valid.
     */
    error MerkleProofInvalidMultiproof();

    /**
     * @dev Returns true if a `leaf` can be proved to be a part of a Merkle tree
     * defined by `root`. For this, a `proof` must be provided, containing
     * sibling hashes on the branch from the leaf to the root of the tree. Each
     * pair of leaves and each pair of pre-images are assumed to be sorted.
     */
    function verify(bytes32[] memory proof, bytes32 root, bytes32 leaf) internal pure returns (bool) {
        return processProof(proof, leaf) == root;
    }

    /**
     * @dev Calldata version of {verify}
     */
    function verifyCalldata(bytes32[] calldata proof, bytes32 root, bytes32 leaf) internal pure returns (bool) {
        return processProofCalldata(proof, leaf) == root;
    }

    /**
     * @dev Returns the rebuilt hash obtained by traversing a Merkle tree up
     * from `leaf` using `proof`. A `proof` is valid if and only if the rebuilt
     * hash matches the root of the tree. When processing the proof, the pairs
     * of leafs & pre-images are assumed to be sorted.
     */
    function processProof(bytes32[] memory proof, bytes32 leaf) internal pure returns (bytes32) {
        bytes32 computedHash = leaf;
        for (uint256 i = 0; i < proof.length; i++) {
            computedHash = _hashPair(computedHash, proof[i]);
        }
        return computedHash;
    }

    /**
     * @dev Calldata version of {processProof}
     */
    function processProofCalldata(bytes32[] calldata proof, bytes32 leaf) internal pure returns (bytes32) {
        bytes32 computedHash = leaf;
        for (uint256 i = 0; i < proof.length; i++) {
            computedHash = _hashPair(computedHash, proof[i]);
        }
        return computedHash;
    }

    /**
     * @dev Returns true if the `leaves` can be simultaneously proven to be a part of a Merkle tree defined by
     * `root`, according to `proof` and `proofFlags` as described in {processMultiProof}.
     *
     * CAUTION: Not all Merkle trees admit multiproofs. See {processMultiProof} for details.
     */
    function multiProofVerify(
        bytes32[] memory proof,
        bool[] memory proofFlags,
        bytes32 root,
        bytes32[] memory leaves
    ) internal pure returns (bool) {
        return processMultiProof(proof, proofFlags, leaves) == root;
    }

    /**
     * @dev Calldata version of {multiProofVerify}
     *
     * CAUTION: Not all Merkle trees admit multiproofs. See {processMultiProof} for details.
     */
    function multiProofVerifyCalldata(
        bytes32[] calldata proof,
        bool[] calldata proofFlags,
        bytes32 root,
        bytes32[] memory leaves
    ) internal pure returns (bool) {
        return processMultiProofCalldata(proof, proofFlags, leaves) == root;
    }

    /**
     * @dev Returns the root of a tree reconstructed from `leaves` and sibling nodes in `proof`. The reconstruction
     * proceeds by incrementally reconstructing all inner nodes by combining a leaf/inner node with either another
     * leaf/inner node or a proof sibling node, depending on whether each `proofFlags` item is true or false
     * respectively.
     *
     * CAUTION: Not all Merkle trees admit multiproofs. To use multiproofs, it is sufficient to ensure that: 1) the tree
     * is complete (but not necessarily perfect), 2) the leaves to be proven are in the opposite order they are in the
     * tree (i.e., as seen from right to left starting at the deepest layer and continuing at the next layer).
     */
    function processMultiProof(
        bytes32[] memory proof,
        bool[] memory proofFlags,
        bytes32[] memory leaves
    ) internal pure returns (bytes32 merkleRoot) {
        // This function rebuilds the root hash by traversing the tree up from the leaves. The root is rebuilt by
        // consuming and producing values on a queue. The queue starts with the `leaves` array, then goes onto the
        // `hashes` array. At the end of the process, the last hash in the `hashes` array should contain the root of
        // the Merkle tree.
        uint256 leavesLen = leaves.length;
        uint256 proofLen = proof.length;
        uint256 totalHashes = proofFlags.length;

        // Check proof validity.
        if (leavesLen + proofLen != totalHashes + 1) {
            revert MerkleProofInvalidMultiproof();
        }

        // The xxxPos values are "pointers" to the next value to consume in each array. All accesses are done using
        // `xxx[xxxPos++]`, which return the current value and increment the pointer, thus mimicking a queue's "pop".
        bytes32[] memory hashes = new bytes32[](totalHashes);
        uint256 leafPos = 0;
        uint256 hashPos = 0;
        uint256 proofPos = 0;
        // At each step, we compute the next hash using two values:
        // - a value from the "main queue". If not all leaves have been consumed, we get the next leaf, otherwise we
        //   get the next hash.
        // - depending on the flag, either another value from the "main queue" (merging branches) or an element from the
        //   `proof` array.
        for (uint256 i = 0; i < totalHashes; i++) {
            bytes32 a = leafPos < leavesLen ? leaves[leafPos++] : hashes[hashPos++];
            bytes32 b = proofFlags[i]
                ? (leafPos < leavesLen ? leaves[leafPos++] : hashes[hashPos++])
                : proof[proofPos++];
            hashes[i] = _hashPair(a, b);
        }

        if (totalHashes > 0) {
            if (proofPos != proofLen) {
                revert MerkleProofInvalidMultiproof();
            }
            unchecked {
                return hashes[totalHashes - 1];
            }
        } else if (leavesLen > 0) {
            return leaves[0];
        } else {
            return proof[0];
        }
    }

    /**
     * @dev Calldata version of {processMultiProof}.
     *
     * CAUTION: Not all Merkle trees admit multiproofs. See {processMultiProof} for details.
     */
    function processMultiProofCalldata(
        bytes32[] calldata proof,
        bool[] calldata proofFlags,
        bytes32[] memory leaves
    ) internal pure returns (bytes32 merkleRoot) {
        // This function rebuilds the root hash by traversing the tree up from the leaves. The root is rebuilt by
        // consuming and producing values on a queue. The queue starts with the `leaves` array, then goes onto the
        // `hashes` array. At the end of the process, the last hash in the `hashes` array should contain the root of
        // the Merkle tree.
        uint256 leavesLen = leaves.length;
        uint256 proofLen = proof.length;
        uint256 totalHashes = proofFlags.length;

        // Check proof validity.
        if (leavesLen + proofLen != totalHashes + 1) {
            revert MerkleProofInvalidMultiproof();
        }

        // The xxxPos values are "pointers" to the next value to consume in each array. All accesses are done using
        // `xxx[xxxPos++]`, which return the current value and increment the pointer, thus mimicking a queue's "pop".
        bytes32[] memory hashes = new bytes32[](totalHashes);
        uint256 leafPos = 0;
        uint256 hashPos = 0;
        uint256 proofPos = 0;
        // At each step, we compute the next hash using two values:
        // - a value from the "main queue". If not all leaves have been consumed, we get the next leaf, otherwise we
        //   get the next hash.
        // - depending on the flag, either another value from the "main queue" (merging branches) or an element from the
        //   `proof` array.
        for (uint256 i = 0; i < totalHashes; i++) {
            bytes32 a = leafPos < leavesLen ? leaves[leafPos++] : hashes[hashPos++];
            bytes32 b = proofFlags[i]
                ? (leafPos < leavesLen ? leaves[leafPos++] : hashes[hashPos++])
                : proof[proofPos++];
            hashes[i] = _hashPair(a, b);
        }

        if (totalHashes > 0) {
            if (proofPos != proofLen) {
                revert MerkleProofInvalidMultiproof();
            }
            unchecked {
                return hashes[totalHashes - 1];
            }
        } else if (leavesLen > 0) {
            return leaves[0];
        } else {
            return proof[0];
        }
    }

    /**
     * @dev Sorts the pair (a, b) and hashes the result.
     */
    function _hashPair(bytes32 a, bytes32 b) private pure returns (bytes32) {
        return a < b ? _efficientHash(a, b) : _efficientHash(b, a);
    }

    /**
     * @dev Implementation of keccak256(abi.encode(a, b)) that doesn't allocate or expand memory.
     */
    function _efficientHash(bytes32 a, bytes32 b) private pure returns (bytes32 value) {
        /// @solidity memory-safe-assembly
        assembly {
            mstore(0x00, a)
            mstore(0x20, b)
            value := keccak256(0x00, 0x40)
        }
    }
}
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v5.0.0) (utils/ReentrancyGuard.sol)

pragma solidity ^0.8.20;

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
// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.23;

library Errors {
    /// @notice Given value is out of safe bounds.
    error UnacceptableValue();

    /// @notice Given reference is `address(0)`.
    error UnacceptableReference();

    /// @notice The caller account is not authorized to perform an operation.
    /// @param account Address of the account.
    error Unauthorized(address account);

    /// @notice The caller account is not authorized to perform an operation.
    /// @param account Address of the account.
    error AccountMismatch(address account);
}
// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.23;

/**
 * @title MathHelper
 * @notice A utility library for performing mathematical operations on values.
 */
library MathHelper {
    /// @notice Returns a smaller number.
    /// @param a Number to compare.
    /// @param b Number to compare.
    function min(uint256 a, uint256 b) internal pure returns (uint256) {
        return a > b ? b : a;
    }

    /// @notice Rrounds up the given number.
    /// @param fraction Number to round up.
    /// @param denominator Value of the denominator.
    function roundUp(uint256 fraction, uint256 denominator) internal pure returns (uint256) {
        uint256 imprecise = fraction / denominator;

        return fraction - imprecise * denominator > 0 ? imprecise + 1 : imprecise;
    }
}
// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.23;

import { IERC20 } from "@openzeppelin/contracts/interfaces/IERC20.sol";
import { SafeERC20 } from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import { IERC20Metadata } from "@openzeppelin/contracts/token/ERC20/extensions/IERC20Metadata.sol";

/// @title ERC20Helper
/// @notice Contains helper methods for interacting with ERC20 tokens.
library ERC20Helper {
    /// @notice Transfers tokens from the calling contract to a recipient.
    /// @param token The contract address of the token which will be transferred.
    /// @param to The recipient of the transfer.
    /// @param value The value of the transfer.
    function transfer(IERC20 token, address to, uint256 value) internal {
        SafeERC20.safeTransfer(token, to, value);
    }

    /**
     * @notice Transfers tokens from sender to a recipient and returns transferred amount.
     * @param token The contract address of the token which will be transferred.
     * @param sender The sender of the transfer.
     * @param to The recipient of the transfer.
     * @param value The value of the transfer.
     *
     * @dev Transferring tokens in some protocol functions cannot rely on given `amount`
     * because in the case of a token that collects tax or handles the `transfer` in a
     * custom way. In that case the value may not reflect the actual transferred value.
     *
     * Solution:
     * - before the transfer: save the current balance
     * - after the transfer: subtract this value from the new balance
     */
    function transferFrom(IERC20 token, address sender, address to, uint256 value) internal returns (uint256) {
        uint256 balance = token.balanceOf(to);

        SafeERC20.safeTransferFrom(token, sender, to, value);

        return token.balanceOf(to) - balance;
    }

    /// @notice Returns the decimals places of the token.
    ///  @param token The contract address of the token.
    function decimals(IERC20 token) internal view returns (uint256) {
        return IERC20Metadata(address(token)).decimals();
    }
}
// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.23;

enum RoundState {
    PENDING,
    SALE,
    VESTING
}

struct Round {
    string name;
    uint256 startTimestamp;
    uint256 endTimestamp;
    bytes32 whitelistRoot;
    string proofsUri;
}
// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.23;

import { IERC20 } from "@openzeppelin/contracts/interfaces/IERC20.sol";

import { IMembership } from "./IMembership.sol";

struct MembershipConfiguration {
    address factory;
    IMembership.Metadata metadata;
}

struct Configuration {
    IERC20 tokenA;
    IERC20 tokenB;
    address manager;
    address feeCollector;
    address beneficiary;
    uint256 listingTimestamp;
    uint256 refundsPeriod;
    MembershipConfiguration sMembership;
    MembershipConfiguration vMembership;
    uint96 royaltyFraction; // this should belong to the Fee stuct
}
// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.23;

struct Fee {
    uint16 tokenAFeeNumerator;
    uint16 tokenAFeeDenominator;
    uint16 tokenBFeeNumerator;
    uint16 tokenBFeeDenominator;
}
// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.23;

import { IERC721 } from "@openzeppelin/contracts/token/ERC721/IERC721.sol";

/**
 * @title Membership
 * @author
 * @notice
 */
interface IMembership is IERC721 {
    struct Usage {
        uint256 max;
        uint256 current;
    }

    struct Metadata {
        string name;
        string symbol;
        string description;
        string color;
        uint256 denominator;
    }

    struct Attributes {
        uint256 price;
        uint256 allocation;
        uint256 refundableUnit;
        uint32 tgeNumerator;
        uint32 tgeDenominator;
        uint32 cliffDuration;
        uint32 cliffNumerator;
        uint32 cliffDenominator;
        uint32 vestingPeriodCount;
        uint32 vestingPeriodDuration;
    }

    error MembershipInGracePeriod(uint256 membershipId);

    /// @notice Creates new membership and transfers it to given owner.
    /// @param owner_ Address of new address owner.
    /// @param roundId Id of the assigned round.
    /// @param maxUsage Max usage of the new membership.
    /// @param attributes Attributes attached to the membership.
    function mint(address owner_, uint256 roundId, uint256 maxUsage, Attributes memory attributes)
        external
        returns (uint256);

    /// @notice Increases the usage.
    /// @param membershipId Id of the membership.
    /// @param value Value of the new usage.
    function increaseUsage(uint256 membershipId, uint256 value) external;

    /// @notice Returns the usage by given membership id.
    function getUsage(uint256 membershipId) external view returns (Usage memory);

    /// @notice Returns the round by given membership id.
    function getRoundId(uint256 membershipId) external view returns (uint256);

    /// @notice Returns the remaining usage by given membership id.
    function getRemainingUsage(uint256 membershipId) external view returns (uint256 value);

    /// @notice Returns the attributes by given membership id.
    function getAttributes(uint256 membershipId) external view returns (Attributes memory);

    /// @notice Returns the timestamp of next unlock.
    /// @param membershipId Id of the membership.
    function getNextUnlock(uint256 membershipId) external view returns (uint256);

    /// @notice Returns the timestamp of the start.
    /// @param membershipId Id of the membership.
    /// @param start Timestamp to override default start timestamp.
    function getStart(uint256 membershipId, uint256 start) external view returns (uint256);

    /**
     * @notice Sets new tgeTimestamp. tgeTimestamp is a starting point from which the vesting is calculated
     */
    function setTgeTimestamp(uint256 tgeTimestamp) external;

    /// @notice Returns releasable amount in the given timestamp.
    /// @param membershipId Id of the membership.
    function releasable(uint256 membershipId) external view returns (uint256);
}
// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.23;

import { IMembership } from "./IMembership.sol";

/**
 * @title ISaleMembership
 * @author
 * @notice
 */
interface ISaleMembership is IMembership {
    /// @notice Hook which marks given membership as nonrefundable before make claim.
    /// @param membershipId Id of the membership.
    /// @param max Max usage of the new membership.
    function beforeClaim(uint256 membershipId, uint256 max) external;

    /// @notice Hook which decreases the refundable state of the membership.
    /// @param membershipId Id of the membership.
    /// @param amountA Value by which it should be decreased.
    function beforeRefund(uint256 membershipId, uint256 amountA) external;

    /// @notice Determines how many units are available to refund.
    /// @param membershipId Id of the token.
    function refundable(uint256 membershipId) external view returns (uint256 value);
}
// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.23;

import { IMembership } from "./IMembership.sol";

/**
 * @title IVestingMembership
 * @author
 * @notice
 */
interface IVestingMembership is IMembership { }
// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.23;

import { IMembership } from "./IMembership.sol";

interface IMembershipFactory {
    function create(
        address owner,
        address feeCollector,
        uint96 royaltyFraction,
        uint256 tgeTimestamp,
        IMembership.Metadata memory metadata
    ) external returns (address);
}
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v5.0.0) (token/ERC20/IERC20.sol)

pragma solidity ^0.8.20;

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
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v5.0.0) (token/ERC20/utils/SafeERC20.sol)

pragma solidity ^0.8.20;

import {IERC20} from "../IERC20.sol";
import {IERC20Permit} from "../extensions/IERC20Permit.sol";
import {Address} from "../../../utils/Address.sol";

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

    /**
     * @dev An operation with an ERC20 token failed.
     */
    error SafeERC20FailedOperation(address token);

    /**
     * @dev Indicates a failed `decreaseAllowance` request.
     */
    error SafeERC20FailedDecreaseAllowance(address spender, uint256 currentAllowance, uint256 requestedDecrease);

    /**
     * @dev Transfer `value` amount of `token` from the calling contract to `to`. If `token` returns no value,
     * non-reverting calls are assumed to be successful.
     */
    function safeTransfer(IERC20 token, address to, uint256 value) internal {
        _callOptionalReturn(token, abi.encodeCall(token.transfer, (to, value)));
    }

    /**
     * @dev Transfer `value` amount of `token` from `from` to `to`, spending the approval given by `from` to the
     * calling contract. If `token` returns no value, non-reverting calls are assumed to be successful.
     */
    function safeTransferFrom(IERC20 token, address from, address to, uint256 value) internal {
        _callOptionalReturn(token, abi.encodeCall(token.transferFrom, (from, to, value)));
    }

    /**
     * @dev Increase the calling contract's allowance toward `spender` by `value`. If `token` returns no value,
     * non-reverting calls are assumed to be successful.
     */
    function safeIncreaseAllowance(IERC20 token, address spender, uint256 value) internal {
        uint256 oldAllowance = token.allowance(address(this), spender);
        forceApprove(token, spender, oldAllowance + value);
    }

    /**
     * @dev Decrease the calling contract's allowance toward `spender` by `requestedDecrease`. If `token` returns no
     * value, non-reverting calls are assumed to be successful.
     */
    function safeDecreaseAllowance(IERC20 token, address spender, uint256 requestedDecrease) internal {
        unchecked {
            uint256 currentAllowance = token.allowance(address(this), spender);
            if (currentAllowance < requestedDecrease) {
                revert SafeERC20FailedDecreaseAllowance(spender, currentAllowance, requestedDecrease);
            }
            forceApprove(token, spender, currentAllowance - requestedDecrease);
        }
    }

    /**
     * @dev Set the calling contract's allowance toward `spender` to `value`. If `token` returns no value,
     * non-reverting calls are assumed to be successful. Meant to be used with tokens that require the approval
     * to be set to zero before setting it to a non-zero value, such as USDT.
     */
    function forceApprove(IERC20 token, address spender, uint256 value) internal {
        bytes memory approvalCall = abi.encodeCall(token.approve, (spender, value));

        if (!_callOptionalReturnBool(token, approvalCall)) {
            _callOptionalReturn(token, abi.encodeCall(token.approve, (spender, 0)));
            _callOptionalReturn(token, approvalCall);
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
        // we're implementing it ourselves. We use {Address-functionCall} to perform this call, which verifies that
        // the target address contains contract code and also asserts for success in the low-level call.

        bytes memory returndata = address(token).functionCall(data);
        if (returndata.length != 0 && !abi.decode(returndata, (bool))) {
            revert SafeERC20FailedOperation(address(token));
        }
    }

    /**
     * @dev Imitates a Solidity high-level call (i.e. a regular function call to a contract), relaxing the requirement
     * on the return value: the return value is optional (but if data is returned, it must not be false).
     * @param token The token targeted by the call.
     * @param data The call data (encoded using abi.encode or one of its variants).
     *
     * This is a variant of {_callOptionalReturn} that silents catches all reverts and returns a bool instead.
     */
    function _callOptionalReturnBool(IERC20 token, bytes memory data) private returns (bool) {
        // We need to perform a low level call here, to bypass Solidity's return data size checking mechanism, since
        // we're implementing it ourselves. We cannot use {Address-functionCall} here since this should return false
        // and not revert is the subcall reverts.

        (bool success, bytes memory returndata) = address(token).call(data);
        return success && (returndata.length == 0 || abi.decode(returndata, (bool))) && address(token).code.length > 0;
    }
}
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v5.0.0) (token/ERC20/extensions/IERC20Metadata.sol)

pragma solidity ^0.8.20;

import {IERC20} from "../IERC20.sol";

/**
 * @dev Interface for the optional metadata functions from the ERC20 standard.
 */
interface IERC20Metadata is IERC20 {
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
}
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v5.0.0) (token/ERC721/IERC721.sol)

pragma solidity ^0.8.20;

import {IERC165} from "../../utils/introspection/IERC165.sol";

/**
 * @dev Required interface of an ERC721 compliant contract.
 */
interface IERC721 is IERC165 {
    /**
     * @dev Emitted when `tokenId` token is transferred from `from` to `to`.
     */
    event Transfer(address indexed from, address indexed to, uint256 indexed tokenId);

    /**
     * @dev Emitted when `owner` enables `approved` to manage the `tokenId` token.
     */
    event Approval(address indexed owner, address indexed approved, uint256 indexed tokenId);

    /**
     * @dev Emitted when `owner` enables or disables (`approved`) `operator` to manage all of its assets.
     */
    event ApprovalForAll(address indexed owner, address indexed operator, bool approved);

    /**
     * @dev Returns the number of tokens in ``owner``'s account.
     */
    function balanceOf(address owner) external view returns (uint256 balance);

    /**
     * @dev Returns the owner of the `tokenId` token.
     *
     * Requirements:
     *
     * - `tokenId` must exist.
     */
    function ownerOf(uint256 tokenId) external view returns (address owner);

    /**
     * @dev Safely transfers `tokenId` token from `from` to `to`.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `tokenId` token must exist and be owned by `from`.
     * - If the caller is not `from`, it must be approved to move this token by either {approve} or {setApprovalForAll}.
     * - If `to` refers to a smart contract, it must implement {IERC721Receiver-onERC721Received}, which is called upon
     *   a safe transfer.
     *
     * Emits a {Transfer} event.
     */
    function safeTransferFrom(address from, address to, uint256 tokenId, bytes calldata data) external;

    /**
     * @dev Safely transfers `tokenId` token from `from` to `to`, checking first that contract recipients
     * are aware of the ERC721 protocol to prevent tokens from being forever locked.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `tokenId` token must exist and be owned by `from`.
     * - If the caller is not `from`, it must have been allowed to move this token by either {approve} or
     *   {setApprovalForAll}.
     * - If `to` refers to a smart contract, it must implement {IERC721Receiver-onERC721Received}, which is called upon
     *   a safe transfer.
     *
     * Emits a {Transfer} event.
     */
    function safeTransferFrom(address from, address to, uint256 tokenId) external;

    /**
     * @dev Transfers `tokenId` token from `from` to `to`.
     *
     * WARNING: Note that the caller is responsible to confirm that the recipient is capable of receiving ERC721
     * or else they may be permanently lost. Usage of {safeTransferFrom} prevents loss, though the caller must
     * understand this adds an external call which potentially creates a reentrancy vulnerability.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `tokenId` token must be owned by `from`.
     * - If the caller is not `from`, it must be approved to move this token by either {approve} or {setApprovalForAll}.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(address from, address to, uint256 tokenId) external;

    /**
     * @dev Gives permission to `to` to transfer `tokenId` token to another account.
     * The approval is cleared when the token is transferred.
     *
     * Only a single account can be approved at a time, so approving the zero address clears previous approvals.
     *
     * Requirements:
     *
     * - The caller must own the token or be an approved operator.
     * - `tokenId` must exist.
     *
     * Emits an {Approval} event.
     */
    function approve(address to, uint256 tokenId) external;

    /**
     * @dev Approve or remove `operator` as an operator for the caller.
     * Operators can call {transferFrom} or {safeTransferFrom} for any token owned by the caller.
     *
     * Requirements:
     *
     * - The `operator` cannot be the address zero.
     *
     * Emits an {ApprovalForAll} event.
     */
    function setApprovalForAll(address operator, bool approved) external;

    /**
     * @dev Returns the account approved for `tokenId` token.
     *
     * Requirements:
     *
     * - `tokenId` must exist.
     */
    function getApproved(uint256 tokenId) external view returns (address operator);

    /**
     * @dev Returns if the `operator` is allowed to manage all of the assets of `owner`.
     *
     * See {setApprovalForAll}
     */
    function isApprovedForAll(address owner, address operator) external view returns (bool);
}
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v5.0.0) (token/ERC20/extensions/IERC20Permit.sol)

pragma solidity ^0.8.20;

/**
 * @dev Interface of the ERC20 Permit extension allowing approvals to be made via signatures, as defined in
 * https://eips.ethereum.org/EIPS/eip-2612[EIP-2612].
 *
 * Adds the {permit} method, which can be used to change an account's ERC20 allowance (see {IERC20-allowance}) by
 * presenting a message signed by the account. By not relying on {IERC20-approve}, the token holder account doesn't
 * need to send a transaction, and thus is not required to hold Ether at all.
 *
 * ==== Security Considerations
 *
 * There are two important considerations concerning the use of `permit`. The first is that a valid permit signature
 * expresses an allowance, and it should not be assumed to convey additional meaning. In particular, it should not be
 * considered as an intention to spend the allowance in any specific way. The second is that because permits have
 * built-in replay protection and can be submitted by anyone, they can be frontrun. A protocol that uses permits should
 * take this into consideration and allow a `permit` call to fail. Combining these two aspects, a pattern that may be
 * generally recommended is:
 *
 * ```solidity
 * function doThingWithPermit(..., uint256 value, uint256 deadline, uint8 v, bytes32 r, bytes32 s) public {
 *     try token.permit(msg.sender, address(this), value, deadline, v, r, s) {} catch {}
 *     doThing(..., value);
 * }
 *
 * function doThing(..., uint256 value) public {
 *     token.safeTransferFrom(msg.sender, address(this), value);
 *     ...
 * }
 * ```
 *
 * Observe that: 1) `msg.sender` is used as the owner, leaving no ambiguity as to the signer intent, and 2) the use of
 * `try/catch` allows the permit to fail and makes the code tolerant to frontrunning. (See also
 * {SafeERC20-safeTransferFrom}).
 *
 * Additionally, note that smart contract wallets (such as Argent or Safe) are not able to produce permit signatures, so
 * contracts should have entry points that don't rely on permit.
 */
interface IERC20Permit {
    /**
     * @dev Sets `value` as the allowance of `spender` over ``owner``'s tokens,
     * given ``owner``'s signed approval.
     *
     * IMPORTANT: The same issues {IERC20-approve} has related to transaction
     * ordering also apply here.
     *
     * Emits an {Approval} event.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     * - `deadline` must be a timestamp in the future.
     * - `v`, `r` and `s` must be a valid `secp256k1` signature from `owner`
     * over the EIP712-formatted function arguments.
     * - the signature must use ``owner``'s current nonce (see {nonces}).
     *
     * For more information on the signature format, see the
     * https://eips.ethereum.org/EIPS/eip-2612#specification[relevant EIP
     * section].
     *
     * CAUTION: See Security Considerations above.
     */
    function permit(
        address owner,
        address spender,
        uint256 value,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external;

    /**
     * @dev Returns the current nonce for `owner`. This value must be
     * included whenever a signature is generated for {permit}.
     *
     * Every successful call to {permit} increases ``owner``'s nonce by one. This
     * prevents a signature from being used multiple times.
     */
    function nonces(address owner) external view returns (uint256);

    /**
     * @dev Returns the domain separator used in the encoding of the signature for {permit}, as defined by {EIP712}.
     */
    // solhint-disable-next-line func-name-mixedcase
    function DOMAIN_SEPARATOR() external view returns (bytes32);
}
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v5.0.0) (utils/Address.sol)

pragma solidity ^0.8.20;

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
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v5.0.0) (utils/introspection/IERC165.sol)

pragma solidity ^0.8.20;

/**
 * @dev Interface of the ERC165 standard, as defined in the
 * https://eips.ethereum.org/EIPS/eip-165[EIP].
 *
 * Implementers can declare support of contract interfaces, which can then be
 * queried by others ({ERC165Checker}).
 *
 * For an implementation, see {ERC165}.
 */
interface IERC165 {
    /**
     * @dev Returns true if this contract implements the interface defined by
     * `interfaceId`. See the corresponding
     * https://eips.ethereum.org/EIPS/eip-165#how-interfaces-are-identified[EIP section]
     * to learn more about how these ids are created.
     *
     * This function call must use less than 30 000 gas.
     */
    function supportsInterface(bytes4 interfaceId) external view returns (bool);
}
