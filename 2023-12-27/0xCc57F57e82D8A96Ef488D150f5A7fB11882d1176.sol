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
// OpenZeppelin Contracts (last updated v4.9.4) (utils/Context.sol)

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

    function _contextSuffixLength() internal view virtual returns (uint256) {
        return 0;
    }
}
// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import "@openzeppelin/contracts/access/Ownable.sol";

// Interface for ContractChecker
interface IContractChecker {
    function executeDataCheck(string calldata checkName, address wallet) external view returns (uint256);
}

/**
 * @title MonstroDegenzS1
 * @dev A smart contract for handling deposits, claims, reinvestments, and referrals in a DeFi system.
 */
contract MonstroDegenzS1 is Ownable {
    IContractChecker public contractChecker; // ContractChecker

    bool public depositsAndReinvestsPaused = false;
    modifier whenNotPaused() {
        require(!depositsAndReinvestsPaused, "Deposits and reinvests are paused");
        _;
    }	

    // Events
    event ClaimEvent(address indexed user, uint256 amount);
    event DepositEvent(address indexed user, uint256 amount);
    event DepositsAndReinvestsToggled(bool paused);
    event ReferralEvent(address indexed referrer, address indexed referee, uint256 amount);
    event ReinvestEvent(address indexed user, uint256 amount);
    event CashbackPercentSet(address indexed user, uint256 percent);

    // Payable Wallets
	address payable public walletTeam;
	address payable public walletMarketing;
	address payable public walletFarmz;
	address payable public walletGenesis;

	// Constants
	uint256 public constant BASE_RATE = 200;
	uint256 public constant MAX_BONUS_PERSONAL = 200;
	uint256 public constant MAX_BONUS_NFT = 200;
	uint256 public constant DEPOSIT_SHARE_MAIN = 50;
	uint256 public constant DEPOSIT_SHARE_FARMZ = 30;
	uint256 public constant DEPOSIT_SHARE_REFER = 20;
	uint256 public constant CLAIM_TAX_TEAM = 4;
	uint256 public constant CLAIM_TAX_GENESIS = 1;

	// Struct to hold referral tier information
	struct ReferralTier {
	    uint256 value; // The BNB value for the tier
	    uint256 percentage; // The referral percentage for the tier
	}

	// Array to hold referral tiers
	ReferralTier[] public referralTiers;

	// Struct to hold nft boost information
	struct NFTBoost {
	    uint256 boost;
        string functionName;
	}

	// Array to hold nft boosts
	NFTBoost[] public nftBoosts;

	// Struct to hold reinvestment multiplier information
    struct ReinvestmentMultiplier {
        uint256 percentage; // The reinvestment percentage
        uint256 multiplier; // The bonus multiplier
    }

    // Array to hold reinvestment multipliers
    ReinvestmentMultiplier[] public reinvestmentMultipliers;

    // Define a struct to hold the global statistics
	struct GlobalStats {
	    uint256 globalDeposits;
	    uint256 globalClaimed;
	    uint256 liquidity;
	    uint256 marketing;
	    uint256 farming;
	}

    // Wallet Info struct
    struct WalletInfo {
        uint256 lastAction;
        uint256 maxPayout;
        uint256 cashbackPercent; // Percent of referral reward to give back to referral
        address referAddress; // Who referred this account
        uint256 invites; // How many wallets this account referred
        uint256 totalInvested;
        uint256 totalClaimed;
        uint256 totalReferred;
        uint256 totalReferReceived; // Total referral rewards earned by this wallet
        uint256 totalCashback; // Total cashback received by this wallet
    }

    // Mapping to store wallet data
    mapping(address => WalletInfo) public walletData;

    uint256 public globalDeposits;
	  uint256 public globalClaimed;

    /**
     * @dev Constructor function to initialize the contract with ContractChecker address and payable wallets.
     * @param _contractCheckerAddress The address of the ContractChecker contract.
     * @param _walletTeam The address of the Team wallet.
     * @param _walletMarketing The address of the Marketing wallet.
     * @param _walletFarmz The address of the Farmz wallet.
     * @param _walletGenesis The address of the Genesis wallet.
     */
    constructor(
        address _contractCheckerAddress,
        address payable _walletTeam,
        address payable _walletMarketing,
        address payable _walletFarmz,
        address payable _walletGenesis
    ) {
        contractChecker = IContractChecker(_contractCheckerAddress);

        // Initialize referral tiers in constructor with values and percentages
        referralTiers.push(ReferralTier(0e18, 5));
        referralTiers.push(ReferralTier(20e18, 7));
        referralTiers.push(ReferralTier(60e18, 9));
        referralTiers.push(ReferralTier(200e18, 11));
        referralTiers.push(ReferralTier(400e18, 14));
        referralTiers.push(ReferralTier(1000e18, 16));
        referralTiers.push(ReferralTier(2000e18, 18));
        referralTiers.push(ReferralTier(4000e18, 20));

        // Initialize NFT boosts with corresponding functions
        nftBoosts.push(NFTBoost(25, "partner"));
        nftBoosts.push(NFTBoost(25, "lazarusPit"));
        nftBoosts.push(NFTBoost(25, "monstroFarmz"));
        nftBoosts.push(NFTBoost(50, "monstroCastle"));
        nftBoosts.push(NFTBoost(75, "monstroMonstro"));
        nftBoosts.push(NFTBoost(100, "monstroVault"));
        nftBoosts.push(NFTBoost(150, "monstroKingdom"));

        // Initialize reinvestment multipliers
        reinvestmentMultipliers.push(ReinvestmentMultiplier(25, 200));
        reinvestmentMultipliers.push(ReinvestmentMultiplier(50, 250));
        reinvestmentMultipliers.push(ReinvestmentMultiplier(75, 300));
        reinvestmentMultipliers.push(ReinvestmentMultiplier(100, 400));

        // Initialize payable wallets
        walletTeam = _walletTeam;
        walletMarketing = _walletMarketing;
        walletFarmz = _walletFarmz;
        walletGenesis = _walletGenesis;
    }

    /**
     * @dev Allows users to make a deposit in BNB.
     * @param referrer The address of the referrer.
     */
	function deposit(address referrer) public payable whenNotPaused {
	    require(msg.value > 0, "Deposit amount must be greater than zero");

	    WalletInfo storage user = walletData[msg.sender];

	    // Check if this is their first deposit and if a valid referrer exists to attach
	    if (user.totalInvested == 0 && referrer != msg.sender && referrer != address(0)) {
	        user.referAddress = referrer;
	        walletData[referrer].invites += 1;
	    }

	    // Force a claim
	    claim();	

	    // Call the private _deposit function to handle the deposit logic
	    _deposit(msg.value, 150);
	}

	/**
     * @dev Allows users to claim accumulated rewards in BNB.
     */
    function claim() public {
      uint256 claimableAmount = calculateClaimableAmount(msg.sender);

	    if (claimableAmount > 0) {
        _claim(claimableAmount);
      }
	}
 
	/**
     * @dev Allows users to reinvest their earnings in BNB.
     * @param reinvestPercent The percentage of earnings to reinvest.
     */
	function reinvest(uint256 reinvestPercent) public whenNotPaused {
	    uint256 multiplier = getReinvestmentMultiplierAndCheckValidity(reinvestPercent);
	    uint256 claimableAmount = calculateClaimableAmount(msg.sender);

	    require(claimableAmount > 0, "No claimable amount available for reinvestment");

	    uint256 reinvestmentAmount = (claimableAmount * reinvestPercent) / 100;

	    // Call the private _deposit function to handle the reinvestment
	    _deposit(reinvestmentAmount, multiplier);

	    // Call the private _claim function to claim any remaining earnings
	    uint256 remainingClaimable = claimableAmount - reinvestmentAmount;
	    if (remainingClaimable > 0) {
	        _claim(remainingClaimable);
	    }

	    emit ReinvestEvent(msg.sender, reinvestmentAmount);
	}

	/**
     * @dev Allows users to set their cashback percentage.
     * @param percent The cashback percentage to set.
     */
	function setCashbackPercent(uint256 percent) public {
	    require(percent >= 0 && percent <= 100, "Cashback percentage must be between 0% and 100%");
	    walletData[msg.sender].cashbackPercent = percent;

	    emit CashbackPercentSet(msg.sender, percent);
	}

	/**
     * @dev Emergency function to pause any deposits or reinvests.
     * Only the owner can call this function.
     */
	function toggleDepositsAndReinvests() public onlyOwner {
        depositsAndReinvestsPaused = !depositsAndReinvestsPaused;

        emit DepositsAndReinvestsToggled(depositsAndReinvestsPaused);
    }

    /**
	   * @dev Calculates the NFT boost for a given wallet.
	   * @param wallet The wallet address to calculate the NFT boost for.
	   * @return The NFT boost percentage for the wallet.
	   */
	function calculateNFTBoost(address wallet) public view returns (uint256) {
	    uint256 boost = 0;

	    // Loop through NFT boosts and apply them
	    for (uint i = 0; i < nftBoosts.length; i++) {
	        uint256 boostAmount = 0;

	        // Use executeDataCheck with the correct check name
	        boostAmount = contractChecker.executeDataCheck(nftBoosts[i].functionName, wallet);

	        if (boostAmount > 0) {
	            boost += nftBoosts[i].boost;
	        }
	    }

	    // Apply maximum rate limit
	    if (boost > MAX_BONUS_NFT) {
	        boost = MAX_BONUS_NFT;
	    }

	    return boost;
	}
   
	/**
	 * @dev Calculates the personal boost based on the total investment in BNB for a wallet.
	 * @param wallet The wallet address to calculate the personal boost for.
	 * @return The personal boost percentage for the wallet.
	 */
	function calculatePersonalBoost(address wallet) public view returns (uint256) {
		WalletInfo storage user = walletData[wallet];
		uint256 personalBoost = user.totalInvested / 5e18 * 10;

	    // Apply maximum rate limit for personal boost
	    if (personalBoost > MAX_BONUS_PERSONAL) {
	        personalBoost = MAX_BONUS_PERSONAL;
	    }

	    return personalBoost;
	}

	/**
	 * @dev Calculates the total daily payout rate for a wallet, including NFT and personal boosts.
	 * @param wallet The wallet address to calculate the payout rate for.
	 * @return The total daily payout rate for the wallet.
	 */
	function calculateTotalPayoutRate(address wallet) public view returns (uint256) {
	    uint256 nftBoost = calculateNFTBoost(wallet);
	    uint256 personalBoost = calculatePersonalBoost(wallet);

	    uint256 totalPayoutRate = BASE_RATE + nftBoost + personalBoost;

	    return totalPayoutRate;
	}

	/**
	 * @dev Calculates the current available amount to claim or reinvest for a wallet.
	 * @param wallet The wallet address to calculate the claimable amount for.
	 * @return The claimable amount in BNB.
	 */
	function calculateClaimableAmount(address wallet) public view returns (uint256) {
	    WalletInfo storage user = walletData[wallet];

	    // Ensure that the user has some deposited value
	    if (user.totalInvested == 0) {
	        return 0;
	    }

	    // Calculate the time difference (in seconds) since the last action
	    uint256 timeElapsed = block.timestamp - user.lastAction;

	    // Fetch the daily rate using calculateTotalPayoutRate function
	    uint256 dailyRate = calculateTotalPayoutRate(wallet);

	    // Calculate the claimable amount
	    uint256 claimableAmount = user.totalInvested * dailyRate * timeElapsed / (10000 * 86400);

	    // Check if the claimable amount is greater than zero
	    if (claimableAmount == 0) {
	        return 0;
	    }

	    // Calculate the remaining payout for the wallet
	    uint256 remainingPayout = getRemainingPayout(wallet);

	    // Check if the claim amount is greater than the remaining payout
	    if (claimableAmount > remainingPayout) {
	        claimableAmount = remainingPayout;
	    }

	    // Ensure there is enough balance in the contract
	    if (address(this).balance < claimableAmount) {
	        claimableAmount = address(this).balance;
	    }

	    return claimableAmount;
	}

	/**
	 * @dev Gets the reinvestment multiplier for a given percentage and checks its validity.
	 * @param percentage The reinvestment percentage to look up.
	 * @return The bonus multiplier corresponding to the reinvestment percentage.
	 * @notice This function is used to retrieve the bonus multiplier associated with a specific reinvestment percentage.
	 * It ensures that the provided reinvestment percentage is valid.
	 */
	function getReinvestmentMultiplierAndCheckValidity(uint256 percentage) public view returns (uint256) {
	    for (uint256 i = 0; i < reinvestmentMultipliers.length; i++) {
	        if (percentage == reinvestmentMultipliers[i].percentage) {
	            return reinvestmentMultipliers[i].multiplier;
	        }
	    }
	    revert("Invalid reinvestment percentage: Percentage not found in allowed reinvestment percentages");
	}

	/**
	 * @dev Retrieves the referral tier percentage for a given address.
	 * @param wallet The wallet address to get the referral tier percentage for.
	 * @return The referral tier percentage for the wallet.
	 */
	function getReferralTier(address wallet) public view returns (uint256) {
	    uint256 totalReferredAmount = walletData[wallet].totalReferred;
	    uint256 referralTier = 0;

	    for (uint256 i = 0; i < referralTiers.length; i++) {
	        if (totalReferredAmount >= referralTiers[i].value) {
	            referralTier = referralTiers[i].percentage;
	        }
	    }

	    return referralTier;
	}

	/**
	 * @dev Gets the remaining payout for a wallet.
	 * @param wallet The wallet address to get the remaining payout for.
	 * @return The remaining payout amount in BNB.
	 */
	function getRemainingPayout(address wallet) public view returns (uint256) {
	    WalletInfo storage user = walletData[wallet];
	    return user.maxPayout - user.totalClaimed;
	}

	/**
	 * @dev Retrieves global statistics as a struct containing deposit, claimed, liquidity, marketing, and farming values.
	 * @return The global statistics struct.
	 */
	function getGlobalStats() public view returns (GlobalStats memory) {
	    uint256 liquidity = (globalDeposits / 2) - globalClaimed; // 50% of deposits - claimed
	    uint256 marketing = (globalDeposits * 20) / 100; // 20% of deposits
	    uint256 farming = (globalDeposits * 30) / 100; // 30% of deposits

	    GlobalStats memory stats;
	    stats.globalDeposits = globalDeposits;
	    stats.globalClaimed = globalClaimed;
	    stats.liquidity = liquidity;
	    stats.marketing = marketing;
	    stats.farming = farming;

	    return stats;
	}

	/**
	 * @dev Handles referral logic and transfers referral rewards.
	 * @param amount The deposit amount for which referrals are calculated.
	 * @param referrer The address of the referrer.
	 * @notice This function calculates and transfers referral rewards, cashbacks, and marketing shares
	 * based on the provided deposit amount and referrer address.
	 */
	function _handleReferralLogic(uint256 amount, address referrer) private {
	    if (referrer != address(0)) {
	        // Increment referrer's total referred as its used in calculating referral tier
	        walletData[referrer].totalReferred += amount;

	        // Get the referral percentage based on the referrer's tier
	        uint256 referralPercentage = getReferralTier(referrer);

	        // Calculate the total referral payout
	        uint256 referralPayout = (amount * referralPercentage) / 100;

	        // Calculate the cashback amount
	        uint256 cashbackAmount = 0;
	        if (walletData[referrer].cashbackPercent > 0) {
	            cashbackAmount = (referralPayout * walletData[referrer].cashbackPercent) / 100;
	        }

	        // Calculate net referral payout after cashback
	        uint256 netReferralPayout = referralPayout - cashbackAmount;

			// Check if net referral payout is greater than zero before transferring
			if (netReferralPayout > 0) {
			    // Transfer the net referral payout to the referrer
			    payable(referrer).transfer(netReferralPayout);

			    // Increment total rewards received
			    walletData[referrer].totalReferReceived += netReferralPayout;
			}

	        // Transfer the cashback amount to the depositor
	        if (cashbackAmount > 0) {
	            payable(msg.sender).transfer(cashbackAmount);

	            // Increment cashback for msg.sender
	            walletData[msg.sender].totalCashback += cashbackAmount;
	        }

	        // Calculate the remaining amount after referral and cashback
	        uint256 remainingAmount = (amount * DEPOSIT_SHARE_REFER) / 100 - netReferralPayout - cashbackAmount;

	        // Check if remaining amount is greater than zero before transferring it to marketing
	        if (remainingAmount > 0) {
	            payable(walletMarketing).transfer(remainingAmount);
	        }

	        emit ReferralEvent(referrer, msg.sender, amount);

	    } else {
	        // If there's no referrer, transfer defined share in full to marketing wallet
	        uint256 marketingAmount = (amount * DEPOSIT_SHARE_REFER) / 100;
	        payable(walletMarketing).transfer(marketingAmount);
	    }
	}

	/**
	 * @dev Handles the deposit logic and transfers shares to appropriate wallets.
	 * @param amount The deposit amount in BNB.
	 * @param multiplier The bonus multiplier for the deposit.
	 * @notice This function handles the deposit process, calculates shares, transfers funds
	 * to marketing, farmz, and the contract, and updates user's wallet information.
	 */
	function _deposit(uint256 amount, uint256 multiplier) private {
	    WalletInfo storage user = walletData[msg.sender];

	    // Handle referral logic
	    _handleReferralLogic(amount, user.referAddress);

	    // Update user's wallet info
	    user.lastAction = block.timestamp;
	    user.maxPayout += amount * multiplier / 100;
	    user.totalInvested += amount;

	    // Increment globalDeposits
	    globalDeposits += amount;

	    // Calculate and pay farming wallet
	    uint256 farmzShare = (amount * DEPOSIT_SHARE_FARMZ) / 100;
	    payable(walletFarmz).transfer(farmzShare);

	    emit DepositEvent(msg.sender, amount);
	}


	/**
	 * @dev Handles the claim logic, taxes, and transfers accumulated rewards.
	 * @param claimableAmount The amount of BNB that can be claimed.
	 * @notice This function calculates and transfers rewards to users, deducts taxes, and updates user's wallet information.
	 */
	function _claim(uint256 claimableAmount) private {
	    WalletInfo storage user = walletData[msg.sender];

	    // Calculate taxes
	    uint256 teamTax = (claimableAmount * CLAIM_TAX_TEAM) / 100;
	    uint256 genesisTax = (claimableAmount * CLAIM_TAX_GENESIS) / 100;
	    uint256 netAmount = claimableAmount - teamTax - genesisTax;

	    // Update user's wallet info
	    user.lastAction = block.timestamp;
	    user.totalClaimed += netAmount;

	    // Increment globalClaimed
	    globalClaimed += claimableAmount;

	    // Transfer taxes
	    payable(walletTeam).transfer(teamTax);
	    payable(walletGenesis).transfer(genesisTax);

	    // Transfer net amount to user
	    payable(msg.sender).transfer(netAmount);

	    emit ClaimEvent(msg.sender, netAmount);
	}
}
