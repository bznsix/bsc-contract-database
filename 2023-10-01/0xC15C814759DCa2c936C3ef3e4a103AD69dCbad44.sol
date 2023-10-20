/***
 *    ██████╗  ██████╗ ██╗    ██╗███████╗██████╗ ███╗   ███╗ █████╗ ██████╗ ███████╗
 *    ██╔══██╗██╔═══██╗██║    ██║██╔════╝██╔══██╗████╗ ████║██╔══██╗██╔══██╗██╔════╝
 *    ██████╔╝██║   ██║██║ █╗ ██║█████╗  ██████╔╝██╔████╔██║███████║██║  ██║█████╗  
 *    ██╔═══╝ ██║   ██║██║███╗██║██╔══╝  ██╔══██╗██║╚██╔╝██║██╔══██║██║  ██║██╔══╝  
 *    ██║     ╚██████╔╝╚███╔███╔╝███████╗██║  ██║██║ ╚═╝ ██║██║  ██║██████╔╝███████╗
 *    ╚═╝      ╚═════╝  ╚══╝╚══╝ ╚══════╝╚═╝  ╚═╝╚═╝     ╚═╝╚═╝  ╚═╝╚═════╝ ╚══════╝
 *    ███████╗ ██████╗ ██████╗ ███████╗██╗   ██╗███████╗████████╗███████╗███╗   ███╗
 *    ██╔════╝██╔════╝██╔═══██╗██╔════╝╚██╗ ██╔╝██╔════╝╚══██╔══╝██╔════╝████╗ ████║
 *    █████╗  ██║     ██║   ██║███████╗ ╚████╔╝ ███████╗   ██║   █████╗  ██╔████╔██║
 *    ██╔══╝  ██║     ██║   ██║╚════██║  ╚██╔╝  ╚════██║   ██║   ██╔══╝  ██║╚██╔╝██║
 *    ███████╗╚██████╗╚██████╔╝███████║   ██║   ███████║   ██║   ███████╗██║ ╚═╝ ██║
 *    ╚══════╝ ╚═════╝ ╚═════╝ ╚══════╝   ╚═╝   ╚══════╝   ╚═╝   ╚══════╝╚═╝     ╚═╝
 *                                                                                  
 */                                                                                                   
// SPDX-License-Identifier: MIT

pragma solidity ^0.5.17;

// Interface of the Powermade Token, that implements also a standard BEP20 interface. Only needed functions are included
interface PowermadeToken {
    // Get the balance
    function balanceOf(address tokenOwner) external view returns (uint balance);
    // Get the pancake router used by the token
    function pancakeRouter() external view returns (address);
}

// Interface for generic token (fungible) or NFT balance + rarity check. In the case of rarity check the NFT must implement ERC721Enumerable and the custom getRarity()
interface ThresholdTokenOrNFT {
    // Get the balance
    function balanceOf(address tokenOwner) external view returns (uint balance);
    // Get the rarity (ONLY COMPATIBLE NFTS), the feature must be enabled
    function getRarity(uint256 tokenId) external view returns (uint8 rarity);
    function tokenOfOwnerByIndex(address owner, uint256 index) external view returns (uint256 tokenID);
}

// Interface for NFT smart contract (for minting)
interface TargetNFT {
    function mintRandomNFTto(address _to) external;
}

// Interface of the PancakeSwap Router
// Reduced Interface only for the needed functions
interface IPancakeRouterView {
    function WETH() external pure returns (address);
    function getAmountsOut(uint amountIn, address[] calldata path) external view returns (uint[] memory amounts);
}

// Interface to access Powermade contract data
interface Powermade {
    // get the owner 
    function ownerWallet() external view returns (address owner);
    // userInfos getter function (automatically generated because userInfos mapping is public). The getter can only contain standard types, not arrays or other mappings.
    function userInfos(address userAddr) external view returns (uint id, uint referrerID, uint virtualID, uint32 round_robin_next_index, bool banned, uint totalEarned);
    // Get info of a package
    function getPackageInfo(uint16 packageID, uint userID) external view returns (uint price, uint duration, bool enabled, bool rebuy_enabled, bool rebuy_before_exp, uint16[] memory prerequisites, uint16[] memory percentages, bool prereq_not_exp, uint totalEarnedPack, uint purchasesCount, uint last_pid);
    // Get Purchases and related info
    function getAllPurchases(uint userID, uint16 packageID, uint start_index, uint stop_index, bool only_last) external view returns (uint count_all, uint[] memory userIDs_or_PIDs, uint16[] memory packageIDs, uint[] memory timestamps, uint[] memory durations, bool[] memory expireds);
    // Get a single purchase info
    function getPurchaseInfo(uint purchaseID) external view returns (uint userID, uint16 packageID, uint price, uint timestamp, uint duration, bool expired);
    // Get all user info
    function getUsersInfos(address tUserAddr, uint tUserID, uint16 packageID, uint invited_start_index, uint invited_stop_index) external view returns (uint[] memory globals, address[] memory addresses, uint[] memory IDs, uint[] memory counts, uint[] memory amounts, bool banned); 
}

// Interface for the external custom threshold/eligibility for the package and/or for the commissions
interface ExternalEligibilityContract {
    // Functions used to check the eligibility (eg. custom Token/NFT/other thresholds or other logics) 
    // The first one is called when it's required a state update, for example when calling from the payCommissions cycles. The second one is called only to check the status as a view function
    // The ExternalEligibilityContract must implement both
    function isEligibleExt(address user_address, address other_address, uint16 packageID, uint param1, uint8 sourceID) external returns (bool is_eligible);
    function isEligibleExtW(address user_address, address other_address, uint16 packageID, uint param1, uint8 sourceID) external view returns (bool is_eligible);
}

// Custom token threshold for the Powermade packages on registrations
contract PowermadeTokenThresholdV3 is ExternalEligibilityContract {

    // Threshold system configuration
    // Threshold features:
    // If the price becomes 2X the price_threshold --> The PWD threshold for levels 4 and 5 (commissions) is halved and the new price_threshold is doubled
    // If the price becomes 0.75X the price_threshold (if price_threshold > starting_price_threshold)--> The PWD threshold for levels 4 and 5 (commissions) is doubled and the new price_threshold is halved
    // The minimum price_threshold is the starting_price_threshold of 0.5$ - It means that the first change is when the price reaches 1$
    // The PWD thresholds are 2000 PWD for level 5 and 1000 PWD for level 4. No thresholds (0 PWD) for the other levels

    // Constants and algorithm parameters
    uint private constant starting_price_th = 500 * 1e15;       // 0.5 BUSD
    uint private constant upper_factor = 200;                   // 200% = X2 (+100%)
    uint private constant lower_factor = 75;                    // 75% = 0.75X (-25%) 
    uint private constant lev4_PWD_start_th = 1000 * 1e18;      // 1000 PWD
    uint private constant lev5_PWD_start_th = 2000 * 1e18;      // 2000 PWD
    uint private constant update_deadtime = 24 hours;           // Minimum deadtime between price updates

    // Contracts
    Powermade public powermadeContract;                         // The PowermadeAffiliation contract
    PowermadeToken public powermadeToken;                       // The PWD Token contract
    IPancakeRouterView public pancakeRouter;                    // The Pancake Router used by the PWD Token

    // Structures
    struct PackageUnlockConditions {
        bool conditions_enabled;                                // Global enable for the conditions of the package (false, default, bypass all the conditions)
        bool whitelist_enabled;                                 // Define if whitelist mode is enabled
        mapping (address => bool) whitelist;                    // Whitelist 
        address whitelist_manager;                              // Other Wallet that can add users to the whitelist (Powermade owner always can do it). Optional.
        address unlock_asset_1;                                 // First unlock asset (address(0) means disabled)
        uint8 unlock_asset_1_rarity;                            // Rarity threshold (for compatible NFTs). 0 means rarity check disabled. > 0 means at leas 1 of this rarity
        uint asset_1_threshold;                                 // Quantity (units for NFTs, or wei for tokens) threshold asset 1 (rarity not considered). <
        address unlock_asset_2;                                 // Second unlock asset (address(0) means disabled)
        uint8 unlock_asset_2_rarity;                            // Rarity threshold (for compatible NFTs). 0 means rarity check disabled. > 0 means at leas 1 of this rarity
        uint asset_2_threshold;                                 // Quantity (units for NFTs, or wei for tokens) threshold asset 2 (rarity not considered). <
        uint busd_pegged_pwd_threshold;                         // BUSD pegged dynamic threshold (0 means feature disabled). Value in BUSD equivalent (wei)
    }

    struct LimitMultipleBuyConditions {
        bool conditions_enable;                                 // Enable for the Buy Limit conditions of the package
        bool use_Asset_or_Package;                              // 1: Use an NFT (asset), 0: Use a packageID
        address AssetPass;                                      // The NFT/Token pass contract. If address(0) only max_purchasable_nopass will be used
        uint16 packageID_pass;                                  // The packageID to use as pass (if in Package Pass mode)
        uint pass_threshold;                                    // Minimum Number of Passes/Tokens/Packages the user must have. Condition is >= threshold
        bool check_package_expiration;                          // If true, check if the last purchase of the package is not expired (In Package Pass Mode)
        uint exclusive_buy_deadline_timestamp;                  // Expiration of the exclusive buy possibility for NFT/Token pass holders
        uint8 max_purchasable_nopass;                           // Max number of purchasable items/packages (with same ID) for users not holding the NFT pass
        uint8 max_purchasable_withpass;                         // Max number of purchasable items/packages (with same ID) for users holding the NFT pass 
    }

    struct MintNFTSettings {
        bool enable_mint;                                       // Enable the minting of a NFT for this package
        string mint_function_signature;                         // Signature of the mint function, eg. "myMintFunctionTo(address)". If empty the mintRandomNFTto(address _to) will be used
        address targetNFTsc;                                    // The Target (to mint) NFT smart contract (for the Mint Feature)
    }

    struct LimitCommissionsAssetPass {
        bool condition_enable;                                  // Enable the condition evaluation 
        bool use_Asset_or_Package;                              // 1: Use an NFT (asset), 0: Use a packageID
        address AssetPass;                                      // The NFT/Token pass contract (Asset Mode)
        uint16 packageID_pass;                                  // The packageID to use as pass (if in Package Pass mode)
        uint pass_threshold;                                    // Minimum Number of Passes/Tokens/Packages the user must have. Condition is >= threshold
        bool check_package_expiration;                          // If true, check if the last purchase of the package is not expired (In Package Pass Mode)
        bool[6] level_disable_if_not_pass;                      // The level specified with true will be "disabled" (commission not paid) if the condition is false. The level false means the commission is true (default). Indices: sponsor, lv1, lv2, ..., lv5.
    }

    struct LimitCommissionsInvitedUsers {
        bool condition_enable;                                  // Enable the condition evaluation 
        uint8 min_invited_users;                                // Minimum invited users the recipient (of the commission) must have to pass the condition (eg. 5)
        bool[6] level_disable_if_not_pass;                      // The level specified with true will be "disabled" (commission not paid) if the condition is false. The level false means the commission is true (default). Indices: sponsor, lv1, lv2, ..., lv5.
    }

    struct LimitCommissionsAmountPurchasedLastPeriod {
        bool condition_enable;                                  // Enable the condition evaluation 
        uint8 period_days;                                      // Period in days for the "window" used to calculate the total purchased amount (USD), starting from the current time and going back
        uint8 last_purchases_max_count;                         // Max number of purchases to consider (starting from last purchase). Suggested 5.
        uint price_threshold_usd;                               // The price threshold (for the given period) to pass the condition (total purchased in the last period)
        bool[6] level_disable_if_not_pass;                      // The level specified with true will be "disabled" (commission not paid) if the condition is false. The level false means the commission is true (default). Indices: sponsor, lv1, lv2, ..., lv5.
    }

    // Storage variables
    mapping (uint16 => PackageUnlockConditions) public package_buy_unlock_conditions;               // Unlock conditions for the package BUY (configurable)
    mapping (uint16 => LimitMultipleBuyConditions) public package_max_buy_conditions;               // Max Buy (or Mint) conditions for the package BUY (configurable)
    mapping (uint16 => MintNFTSettings) public package_mint_nft_settings;                           // Max Buy (or Mint) conditions for the package BUY (configurable)
    LimitCommissionsAssetPass private limit_commissions_asset_pass_1;                               // Limit commissions with different assets or packages (1)
    LimitCommissionsAssetPass private limit_commissions_asset_pass_2;                               // Limit commissions with different assets or packages (1)
    LimitCommissionsInvitedUsers private limit_commissions_invited_users;                           // Limit commissions depending on invited users
    LimitCommissionsAmountPurchasedLastPeriod private limit_commissions_purchased_last_period;      // Limit commissions depending on last period purchased amount
    mapping (address => bool) public isEligibleProxyContract;   // Other Smart Contracts that can call the isEligibleExt() function of this contract 
    uint public price_threshold = starting_price_th;            // The current price threshold (BUSD)
    uint public lev4_PWD_threshold = lev4_PWD_start_th;         // The current PWD threshold for LV4
    uint public lev5_PWD_threshold = lev5_PWD_start_th;         // The current PWD threshold for LV5
    uint public last_price;                                     // Last price of the PWD token (in BUSD)
    uint public last_update_checkpoint;                         // The last update timestamp
    address public price_reference_token;                       // The BUSD token
    address private wbnb_token;                                 // The WBNB token, used for internal calculation

    // Events
    event UpdatedEvent(bool indexed updated_price, bool indexed updated_thresholds, uint checkpoint_ts, uint price_th, uint lev4_PWD_th, uint lev5_PWD_th);
    event AddRemoveWhitelist(address indexed user_address, uint16 indexed packageID, bool indexed add_remove);
    event PackageUnlockConditionsSet(uint16 indexed packageID, bool conditions_enabled);
    event LimitMultipleBuyConditionsSet(uint16 indexed packageID, bool conditions_enable);
    event setMintNFTSettingsSet(uint16 indexed packageID, bool enable_mint);
    event LimitCommissionsAssetPassSet(uint16 indexed index, bool conditions_enable);
    event LimitCommissionsInvitedUsersSet(bool conditions_enable);
    event LimitCommissionsAmountPurchasedLastPeriodSet(bool conditions_enable);

    
    // Modifier to be used with functions that can be called only by The Owner of the Powermade Main contract
    modifier onlyPowermadeOwner()
    {
        require(msg.sender == Powermade(powermadeContract).ownerWallet(), "Denied");
        _;
    }

    // Modifier to be used with functions that can be called only by The PowermadeAffiliation contract or eligible "proxy" contracts
    modifier onlyPowermadeOrProxyContract()
    {
        require(msg.sender == address(powermadeContract) || isEligibleProxyContract[msg.sender], "Denied");
        _;
    }

    // Constructor called when deploying
    constructor(address _powermadeAddress, address _powermadeToken, address _BUSD_Token) public {
        powermadeContract = Powermade(_powermadeAddress);
        powermadeToken = PowermadeToken(_powermadeToken);
        pancakeRouter = IPancakeRouterView(powermadeToken.pancakeRouter());
        wbnb_token = pancakeRouter.WETH();
        price_reference_token = _BUSD_Token;
        // Initialize the price and the thresholds
        bool updated_thresholds = true;
        while (updated_thresholds) {
            ( , updated_thresholds) = updatePriceThresholds(true);
        }
    }


    // Function to update the price and the thresholds. If called with is_init=true the time check will be bypassed
    // Usual behavior is to update only every ~24 hours
    function updatePriceThresholds(bool is_init) private returns (bool updated_price, bool updated_thresholds) {
        if (!is_init) {
            // Check if the time passed and we have to do an update
            if (block.timestamp < last_update_checkpoint + update_deadtime) {
                return (false, false);
            }
        }
        // Get the price in BUSD from PancakeSwap, passing from the BNB pool (most of the liquidity)
        address[] memory path = new address[](3);
        path[0] = address(powermadeToken);
        path[1] = wbnb_token;
        path[2] = price_reference_token;
        last_price = pancakeRouter.getAmountsOut(1e18, path)[2];
        updated_price = true;
        // Calculate the thresholds
        if (last_price >= (price_threshold*upper_factor/100)) {
            price_threshold = price_threshold * 2;
            lev4_PWD_threshold = lev4_PWD_threshold / 2;
            lev5_PWD_threshold = lev5_PWD_threshold / 2;
            updated_thresholds = true;
        // NB: If we are in the starting price_threshold (1$/2=0.5$) we don't do anything. We lower the threshold only if price_threshold = 1$, 2$, 4$, 8$, ...
        } else if (price_threshold > starting_price_th && last_price < (price_threshold*lower_factor/100)) {
            price_threshold = price_threshold / 2;
            lev4_PWD_threshold = lev4_PWD_threshold * 2;
            lev5_PWD_threshold = lev5_PWD_threshold * 2;
            updated_thresholds = true;
        }
        // Update checkpoint
        last_update_checkpoint = block.timestamp;
        emit UpdatedEvent(updated_price, updated_thresholds, last_update_checkpoint, price_threshold, lev4_PWD_threshold, lev5_PWD_threshold);
    }


    // Eligibility internal function (view) with error messages
    function isEligibleExtW_Int(address user_address, address, uint16 packageID, uint level, uint8 sourceID) internal view returns (bool is_eligible, string memory err) {
        if (sourceID == 1) {        // Case Package Buy (user_address is who buys the package packageID and the level is the n_bought of that package)
            // Global condition check enable
            if (package_buy_unlock_conditions[packageID].conditions_enabled) {
                // First check Whitelist mode. If Whitelist enabled but user not whitelisted, return false
                if (package_buy_unlock_conditions[packageID].whitelist_enabled && !package_buy_unlock_conditions[packageID].whitelist[user_address]) {
                    return (false, "Not Whitelisted");
                }
                // Check asset 1 
                if (package_buy_unlock_conditions[packageID].unlock_asset_1 != address(0)) {
                    ThresholdTokenOrNFT target_token = ThresholdTokenOrNFT(package_buy_unlock_conditions[packageID].unlock_asset_1);
                    // Rarity condition (at least 1 of rarity grater that the one specified)
                    if (package_buy_unlock_conditions[packageID].unlock_asset_1_rarity > 0) {
                        bool found = false;
                        for (uint j = 0; j < target_token.balanceOf(user_address); j++) {
                            uint tokenID = target_token.tokenOfOwnerByIndex(user_address,j);
                            if (target_token.getRarity(tokenID) >= package_buy_unlock_conditions[packageID].unlock_asset_1_rarity) {
                                found = true;
                                break;
                            }
                        }
                        if (!found) {
                            return (false, "NFT with minimum rarity not found");
                        }
                    }
                    // Check asset 1 quantity threshold (units for NFTs, or wei for tokens)
                    if (target_token.balanceOf(user_address) < package_buy_unlock_conditions[packageID].asset_1_threshold) {
                        return (false, "Asset Amount under threshold");
                    }   
                }
                // Check asset 2
                if (package_buy_unlock_conditions[packageID].unlock_asset_2 != address(0)) {
                    ThresholdTokenOrNFT target_token = ThresholdTokenOrNFT(package_buy_unlock_conditions[packageID].unlock_asset_2);
                    // Rarity condition (at least 1 of rarity grater that the one specified)
                    if (package_buy_unlock_conditions[packageID].unlock_asset_2_rarity > 0) {
                        bool found = false;
                        for (uint j = 0; j < target_token.balanceOf(user_address); j++) {
                            uint tokenID = target_token.tokenOfOwnerByIndex(user_address,j);
                            if (target_token.getRarity(tokenID) >= package_buy_unlock_conditions[packageID].unlock_asset_2_rarity) {
                                found = true;
                                break;
                            }
                        }
                        if (!found) {
                            return (false, "NFT with minimum rarity not found");
                        }
                    }
                    // Check asset 1 quantity threshold (units for NFTs, or wei for tokens)
                    if (target_token.balanceOf(user_address) < package_buy_unlock_conditions[packageID].asset_2_threshold) {
                        return (false, "Asset Amount under threshold");
                    }   
                }            
                // Check BUSD pegged threshold condition
                if (package_buy_unlock_conditions[packageID].busd_pegged_pwd_threshold > 0) {
                    // get last price (or last 24h price) in BUSD and calculate the PWD amount
                    uint pwd_threshold = package_buy_unlock_conditions[packageID].busd_pegged_pwd_threshold / last_price;
                    if (powermadeToken.balanceOf(user_address) < pwd_threshold) {
                        return (false, "PWD amount under BUSD equivalent threshold");
                    }
                }
            }
            // Check the Passes for Maximum Buy (or Mint in case of mint)
            if (package_max_buy_conditions[packageID].conditions_enable) {
                bool isPass = false;
                if (package_max_buy_conditions[packageID].use_Asset_or_Package) {
                    // Use ASSET
                    if (package_max_buy_conditions[packageID].AssetPass != address(0)) {
                        ThresholdTokenOrNFT target_token = ThresholdTokenOrNFT(package_max_buy_conditions[packageID].AssetPass);
                        // Check quantity threshold (units for NFTs, or wei for tokens)
                        if (target_token.balanceOf(user_address) >= package_max_buy_conditions[packageID].pass_threshold) {
                            isPass  = true;
                        } 
                    }
                } else {
                    // Use Package
                    (uint userID, , , , , ) = powermadeContract.userInfos(user_address);
                    (uint n_purchases, , , , , bool[] memory expireds) = powermadeContract.getAllPurchases(userID, package_max_buy_conditions[packageID].packageID_pass, 0, 0, true);
                    if (n_purchases >= package_max_buy_conditions[packageID].pass_threshold) {
                        if (package_max_buy_conditions[packageID].check_package_expiration && !expireds[0]) {
                            isPass = true;
                        }
                    }
                }
                // Exclusive buy period
                if (block.timestamp <= package_max_buy_conditions[packageID].exclusive_buy_deadline_timestamp && !isPass) {
                    return (false, "Cannot Buy Yet");
                }
                // Max purchasable quantity (level is also the n_bought in this case, excluding the current purchase)
                if (!isPass) {
                    if (package_max_buy_conditions[packageID].max_purchasable_nopass == 0) {
                        return (false, "Buy Disabled");
                    }
                    if (level >= package_max_buy_conditions[packageID].max_purchasable_nopass) {
                        return (false, "Max Purchasable quantity reached");
                    }
                } else {
                    if (package_max_buy_conditions[packageID].max_purchasable_withpass == 0) {
                        return (false, "Buy Disabled");
                    }
                    if (level >= package_max_buy_conditions[packageID].max_purchasable_withpass) {
                        return (false, "Max Purchasable quantity reached");
                    }
                }
            }
            // Default return if no lock condition is met
            return (true, "");
        } 
        if (sourceID == 2 || sourceID == 3) {     // user_address is who receives the commission. Level 0 is the sponsor (direct commission) and level 1 to 5 are the 5 level in the downline (NB: sourceID 2 is the case of sponsor payout, sourceID 3 is the case of levels payout)
            bool current_level_pass = true;
            ( , current_level_pass) = isPassCommissionByAssets(user_address, level);
            if (!current_level_pass) { return (false, ""); }
            ( , current_level_pass) = isPassCommissionByInvitedUsers(user_address, level);
            if (!current_level_pass) { return (false, ""); }
            ( , current_level_pass) = isPassCommissionByPurchasedLastPeriod(user_address, level);
            if (!current_level_pass) { return (false, ""); }
            ( , current_level_pass) = isPassCommissionByPWDThresholds(user_address, level);
            if (!current_level_pass) { return (false, ""); }
            return (true, "");
        } else {
            return (true, "");
        }
    }

    
    // Implementation of the ExternalEligibilityContract interface (only used parameters). View function.
    function isEligibleExtW(address user_address, address, uint16 packageID, uint level, uint8 sourceID) public view returns (bool is_eligible) {
        (is_eligible, ) = isEligibleExtW_Int(user_address, address(0), packageID, level, sourceID);
    }

    // Implementation of the ExternalEligibilityContract interface (only used parameters). Call function (it can update storage)
    function isEligibleExt(address user_address, address, uint16 packageID, uint level, uint8 sourceID) external onlyPowermadeOrProxyContract returns (bool is_eligible) {
        // Call the update function
        updatePriceThresholds(false);
        // Return the eligibility
        string memory err;
        (is_eligible, err) = isEligibleExtW_Int(user_address, address(0), packageID, level, sourceID);
        if (sourceID == 1 && is_eligible == false) {        // Case Package Buy and false eligibility (so an error to show to the user)
            revert(err);
        }    
        // Mint NFT if the feature is enabled (only when buying)
        if (package_mint_nft_settings[packageID].enable_mint && sourceID == 1) {
            if (bytes(package_mint_nft_settings[packageID].mint_function_signature).length > 0) {
                // Use dynamic call
                bytes memory payload = abi.encodeWithSignature(package_mint_nft_settings[packageID].mint_function_signature, user_address);
                (bool success, ) = address(package_mint_nft_settings[packageID].targetNFTsc).call(payload);
                require(success, "Error calling Dynamic Mint Function");
            } else {
                TargetNFT(package_mint_nft_settings[packageID].targetNFTsc).mintRandomNFTto(user_address);
            }
        } 
    }


    // The function returns if the user_address (who receives the commission) is eligible to receive the commission after evaluating the PWD token Thresholds (level 4 and 5 only)
    function isPassCommissionByPWDThresholds(address user_address, uint level) public view returns (bool pass, bool level_pass) {
        if (level == 4) {
            if (powermadeToken.balanceOf(user_address) < lev4_PWD_threshold) {
                return (false, false);
            } 
        } else if (level == 5) {
            if (powermadeToken.balanceOf(user_address) < lev5_PWD_threshold) {
                return (false, false);
            } 
        }
        return (true, true);
    }


    // The function returns if the user_address (who receives the commission) is eligible to receive the commission after evaluating the LimitCommissionsAssetPass rules
    function isPassCommissionByAssets(address user_address, uint level) public view returns (bool pass, bool level_pass) {
        pass = true;
        level_pass = true;
        if (limit_commissions_asset_pass_1.condition_enable) {
            pass = false;
            level_pass = level_pass && !limit_commissions_asset_pass_1.level_disable_if_not_pass[level];
            if (limit_commissions_asset_pass_1.use_Asset_or_Package) {
                // Use ASSET
                if (limit_commissions_asset_pass_1.AssetPass != address(0)) {
                    ThresholdTokenOrNFT target_token = ThresholdTokenOrNFT(limit_commissions_asset_pass_1.AssetPass);
                    // Check quantity threshold (units for NFTs, or wei for tokens)
                    if (target_token.balanceOf(user_address) >= limit_commissions_asset_pass_1.pass_threshold) {
                        pass  = true;
                        level_pass = true;
                    } 
                }
            } else {
                // Use Package
                (uint userID, , , , , ) = powermadeContract.userInfos(user_address);
                (uint n_purchases, , , , , bool[] memory expireds) = powermadeContract.getAllPurchases(userID, limit_commissions_asset_pass_1.packageID_pass, 0, 0, true);
                if (n_purchases >= limit_commissions_asset_pass_1.pass_threshold) {
                    if (limit_commissions_asset_pass_1.check_package_expiration && !expireds[0]) {
                        pass = true;
                        level_pass = true;
                    }
                }
            }   
        }
        if (limit_commissions_asset_pass_2.condition_enable) {
            pass = false;
            level_pass = level_pass && !limit_commissions_asset_pass_2.level_disable_if_not_pass[level];
            if (limit_commissions_asset_pass_2.use_Asset_or_Package) {
                // Use ASSET
                if (limit_commissions_asset_pass_2.AssetPass != address(0)) {
                    ThresholdTokenOrNFT target_token = ThresholdTokenOrNFT(limit_commissions_asset_pass_2.AssetPass);
                    // Check quantity threshold (units for NFTs, or wei for tokens)
                    if (target_token.balanceOf(user_address) >= limit_commissions_asset_pass_2.pass_threshold) {
                        pass  = true;
                        level_pass = true;
                    } 
                }
            } else {
                // Use Package
                (uint userID, , , , , ) = powermadeContract.userInfos(user_address);
                (uint n_purchases, , , , , bool[] memory expireds) = powermadeContract.getAllPurchases(userID, limit_commissions_asset_pass_1.packageID_pass, 0, 0, true);
                if (n_purchases >= limit_commissions_asset_pass_2.pass_threshold) {
                    if (limit_commissions_asset_pass_2.check_package_expiration && !expireds[0]) {
                        pass = true;
                        level_pass = true;
                    }
                }
            }   
        }
    }


    // The function returns if the user_address (who receives the commission) is eligible to receive the commission after evaluating the LimitCommissionsInvitedUsers rules.
    function isPassCommissionByInvitedUsers(address user_address, uint level) public view returns (bool pass, bool level_pass) {
        pass = true;
        level_pass = true;
        if (limit_commissions_invited_users.condition_enable) {
            // Get the number of invited users by user_address (counts[0])
            ( , , , uint[] memory counts, , ) = powermadeContract.getUsersInfos(user_address, 0, 0, 0, 0);
            if (counts[0] < limit_commissions_invited_users.min_invited_users) {
                pass = false;
                level_pass = !limit_commissions_invited_users.level_disable_if_not_pass[level];
            }
        }
    }


    // The function returns if the user_address (who receives the commission) is eligible to receive the commission after evaluating the LimitCommissionsAmountPurchasedLastPeriod rules.
    function isPassCommissionByPurchasedLastPeriod(address user_address, uint level) public view returns (bool pass, bool level_pass) {
        pass = true;
        level_pass = true;
        if (limit_commissions_purchased_last_period.condition_enable) {
            // Get the last N purchases
            (uint userID, , , , , ) = powermadeContract.userInfos(user_address);
            (uint n_purchases, , , , , ) = powermadeContract.getAllPurchases(userID, 0, 0, 0, true);
            if (n_purchases == 0) {
                pass = false;
                level_pass = !limit_commissions_purchased_last_period.level_disable_if_not_pass[level];
            } else {
                uint start_index = n_purchases >= limit_commissions_purchased_last_period.last_purchases_max_count ? n_purchases-limit_commissions_purchased_last_period.last_purchases_max_count : 0;
                ( , uint[] memory PIDs, , uint[] memory timestamps, , ) = powermadeContract.getAllPurchases(userID, 0, start_index, n_purchases-1, false);
                // Calculate the total purchased amount of the last period
                uint purchased_wei = 0;
                for (int i = int(PIDs.length) - 1; i >= 0; i--) {
                    if (timestamps[uint(i)] > block.timestamp - limit_commissions_purchased_last_period.period_days * 1 days) {
                        // Get the purchase price
                        ( , , uint price, , , ) = powermadeContract.getPurchaseInfo(PIDs[uint(i)]);
                        purchased_wei = purchased_wei + price;
                    } else {
                        break;
                    }
                    if (purchased_wei >= limit_commissions_purchased_last_period.price_threshold_usd * 1e18) {
                        break;
                    }
                }
                // Check the threshold
                if (purchased_wei < limit_commissions_purchased_last_period.price_threshold_usd * 1e18) {
                    pass = false;
                    level_pass = !limit_commissions_purchased_last_period.level_disable_if_not_pass[level];
                }
            }
        }
    } 


    // Set the Unlock Conditions for the Buy Package operation (when configured)
    function setPackageUnlockConditions(uint16 packageID, bool intelligentUnit, bool conditions_enabled, bool whitelist_enabled, address whitelist_manager, address unlock_asset_1, uint8 unlock_asset_1_rarity, uint asset_1_threshold, address unlock_asset_2, uint8 unlock_asset_2_rarity, uint asset_2_threshold, uint busd_pegged_pwd_threshold) external onlyPowermadeOwner {
        (uint price, , , , , , , , , , ) = powermadeContract.getPackageInfo(packageID, 0);
        require(price > 0, "Package does not exist");
        require(packageID > 1, "Invalid packageID");
        if (intelligentUnit) {
            if (asset_1_threshold > 100 && asset_1_threshold < 1e6) {
                // Probably not NFT and value expressed in human unit 
                asset_1_threshold = asset_1_threshold * 1e18;
            }
            if (asset_2_threshold > 100 && asset_2_threshold < 1e6) {
                // Probably not NFT and value expressed in human unit 
                asset_2_threshold = asset_2_threshold * 1e18;
            }
            if (busd_pegged_pwd_threshold < 1e6) {
                // Probably not in wei format
                busd_pegged_pwd_threshold = busd_pegged_pwd_threshold * 1e18;
            }
        }
        package_buy_unlock_conditions[packageID].conditions_enabled = conditions_enabled;
        package_buy_unlock_conditions[packageID].whitelist_enabled = whitelist_enabled;
        package_buy_unlock_conditions[packageID].whitelist_manager = whitelist_manager;
        package_buy_unlock_conditions[packageID].unlock_asset_1 = unlock_asset_1;
        package_buy_unlock_conditions[packageID].unlock_asset_1_rarity = unlock_asset_1_rarity;
        package_buy_unlock_conditions[packageID].asset_1_threshold = asset_1_threshold;
        package_buy_unlock_conditions[packageID].unlock_asset_2 = unlock_asset_2;
        package_buy_unlock_conditions[packageID].unlock_asset_2_rarity = unlock_asset_2_rarity;
        package_buy_unlock_conditions[packageID].asset_2_threshold = asset_2_threshold;
        package_buy_unlock_conditions[packageID].busd_pegged_pwd_threshold = busd_pegged_pwd_threshold;
        emit PackageUnlockConditionsSet(packageID, conditions_enabled);
    }

    
    // Set the Multiple Buy Limit Conditions for the Buy Package operation (when configured)
    function setLimitMultipleBuyConditions(uint16 packageID, bool conditions_enable, bool use_Asset_or_Package, address AssetPass, uint16 packageID_pass, uint pass_threshold, bool check_package_expiration, uint exclusive_buy_deadline_timestamp, uint8 max_purchasable_nopass, uint8 max_purchasable_withpass) external onlyPowermadeOwner {
        package_max_buy_conditions[packageID].conditions_enable = conditions_enable;
        package_max_buy_conditions[packageID].use_Asset_or_Package = use_Asset_or_Package;
        package_max_buy_conditions[packageID].AssetPass = AssetPass;
        package_max_buy_conditions[packageID].packageID_pass = packageID_pass;
        package_max_buy_conditions[packageID].pass_threshold = pass_threshold;
        package_max_buy_conditions[packageID].check_package_expiration = check_package_expiration;
        package_max_buy_conditions[packageID].exclusive_buy_deadline_timestamp = exclusive_buy_deadline_timestamp;
        package_max_buy_conditions[packageID].max_purchasable_nopass = max_purchasable_nopass;
        package_max_buy_conditions[packageID].max_purchasable_withpass = max_purchasable_withpass;
        emit LimitMultipleBuyConditionsSet(packageID, conditions_enable);
    }


    // Set the Mint NFT Feature for the Buy Package operation (when configured)
    function setMintNFTSettings(uint16 packageID, bool enable_mint, string calldata mint_function_signature, address targetNFTsc) external onlyPowermadeOwner {
        package_mint_nft_settings[packageID].enable_mint = enable_mint;
        package_mint_nft_settings[packageID].mint_function_signature = mint_function_signature;
        package_mint_nft_settings[packageID].targetNFTsc = targetNFTsc;
        emit setMintNFTSettingsSet(packageID, enable_mint);
    }


    // Get function for the LimitCommissionsAssetPass settings
    function getLimitCommissionsAssetPass(uint8 index) public view returns (bool condition_enable, bool use_Asset_or_Package, address AssetPass, uint16 packageID_pass, uint pass_threshold, bool check_package_expiration, bool[6] memory level_disable_if_not_pass) {
        require(index < 2, "Index can be 0 or 1");
        if (index == 0) {
            condition_enable = limit_commissions_asset_pass_1.condition_enable;
            use_Asset_or_Package = limit_commissions_asset_pass_1.use_Asset_or_Package;
            AssetPass = limit_commissions_asset_pass_1.AssetPass;
            packageID_pass = limit_commissions_asset_pass_1.packageID_pass;
            pass_threshold = limit_commissions_asset_pass_1.pass_threshold;
            check_package_expiration = limit_commissions_asset_pass_1.check_package_expiration;
            level_disable_if_not_pass = limit_commissions_asset_pass_1.level_disable_if_not_pass;
        } else if (index == 1) {
            condition_enable = limit_commissions_asset_pass_2.condition_enable;
            use_Asset_or_Package = limit_commissions_asset_pass_2.use_Asset_or_Package;
            AssetPass = limit_commissions_asset_pass_2.AssetPass;
            packageID_pass = limit_commissions_asset_pass_2.packageID_pass;
            pass_threshold = limit_commissions_asset_pass_2.pass_threshold;
            check_package_expiration = limit_commissions_asset_pass_2.check_package_expiration;
            level_disable_if_not_pass = limit_commissions_asset_pass_2.level_disable_if_not_pass;
        }
    }


    // Set function for the LimitCommissionsAssetPass settings
    function setLimitCommissionsAssetPass(uint8 index, bool condition_enable, bool use_Asset_or_Package, address AssetPass, uint16 packageID_pass, uint pass_threshold, bool check_package_expiration, bool[6] calldata level_disable_if_not_pass) external onlyPowermadeOwner {
        require(index < 2, "Index can be 0 or 1");
        require(level_disable_if_not_pass.length == 6, "Invalid array length, it must be 6. Sponsor + 5_Levels");
        if (index == 0) {
            limit_commissions_asset_pass_1.condition_enable = condition_enable;
            limit_commissions_asset_pass_1.use_Asset_or_Package = use_Asset_or_Package;
            limit_commissions_asset_pass_1.AssetPass = AssetPass;
            limit_commissions_asset_pass_1.packageID_pass = packageID_pass;
            limit_commissions_asset_pass_1.pass_threshold = pass_threshold;
            limit_commissions_asset_pass_1.check_package_expiration = check_package_expiration;
            limit_commissions_asset_pass_1.level_disable_if_not_pass = level_disable_if_not_pass;
        } else if (index == 1) {
            limit_commissions_asset_pass_2.condition_enable = condition_enable;
            limit_commissions_asset_pass_2.use_Asset_or_Package = use_Asset_or_Package;
            limit_commissions_asset_pass_2.AssetPass = AssetPass;
            limit_commissions_asset_pass_2.packageID_pass = packageID_pass;
            limit_commissions_asset_pass_2.pass_threshold = pass_threshold;
            limit_commissions_asset_pass_2.check_package_expiration = check_package_expiration;
            limit_commissions_asset_pass_2.level_disable_if_not_pass = level_disable_if_not_pass;
        }
        emit LimitCommissionsAssetPassSet(index, condition_enable);
    }


    // Get function for the LimitCommissionsInvitedUsers settings
    function getLimitCommissionsInvitedUsers() public view returns (bool condition_enable, uint8 min_invited_users, bool[6] memory level_disable_if_not_pass) {
        condition_enable = limit_commissions_invited_users.condition_enable;
        min_invited_users = limit_commissions_invited_users.min_invited_users;
        level_disable_if_not_pass = limit_commissions_invited_users.level_disable_if_not_pass;
    }


    // Set function for the LimitCommissionsInvitedUsers settings
    function setLimitCommissionsInvitedUsers(bool condition_enable, uint8 min_invited_users, bool[6] calldata level_disable_if_not_pass) external onlyPowermadeOwner {
        limit_commissions_invited_users.condition_enable = condition_enable;
        limit_commissions_invited_users.min_invited_users = min_invited_users;
        limit_commissions_invited_users.level_disable_if_not_pass = level_disable_if_not_pass;
        emit LimitCommissionsInvitedUsersSet(condition_enable);
    }


    // Get function for the LimitCommissionsAmountPurchasedLastPeriod settings
    function getLimitCommissionsAmountPurchasedLastPeriod() public view returns (bool condition_enable, uint8 period_days, uint8 last_purchases_max_count, uint price_threshold_usd, bool[6] memory level_disable_if_not_pass) {
        condition_enable = limit_commissions_purchased_last_period.condition_enable;
        period_days = limit_commissions_purchased_last_period.period_days;
        last_purchases_max_count = limit_commissions_purchased_last_period.last_purchases_max_count;
        price_threshold_usd = limit_commissions_purchased_last_period.price_threshold_usd;
        level_disable_if_not_pass = limit_commissions_purchased_last_period.level_disable_if_not_pass;
    }


    // Set function for the LimitCommissionsAmountPurchasedLastPeriod settings
    function setLimitCommissionsAmountPurchasedLastPeriod(bool condition_enable, uint8 period_days, uint8 last_purchases_max_count, uint price_threshold_usd, bool[6] calldata level_disable_if_not_pass) external onlyPowermadeOwner {
        if (condition_enable) {
            require(period_days >= 30, "Period must be >= 30 days");
            require(last_purchases_max_count > 0 && last_purchases_max_count <= 10, "Max count can be between 1 and 10 (included)");
            require(price_threshold_usd >= 10, "Minimum price threshold 10 USD");
        }
        limit_commissions_purchased_last_period.condition_enable = condition_enable;
        limit_commissions_purchased_last_period.period_days = period_days;
        limit_commissions_purchased_last_period.last_purchases_max_count = last_purchases_max_count;
        limit_commissions_purchased_last_period.price_threshold_usd = price_threshold_usd;
        limit_commissions_purchased_last_period.level_disable_if_not_pass = level_disable_if_not_pass;
        emit LimitCommissionsAmountPurchasedLastPeriodSet(condition_enable);
    }


    // Manage the whitelist associated to a packageID
    function addRemoveWhitelist(uint16 packageID, address user_address, bool add_remove) external {
        require(msg.sender == Powermade(powermadeContract).ownerWallet() || msg.sender == package_buy_unlock_conditions[packageID].whitelist_manager, "Denied");     // Powermade owner or whitelist manager allowed
        require(package_buy_unlock_conditions[packageID].whitelist_enabled, "Whitelist not enabled for this packageID");
        (uint price, , , , , , , , , , ) = powermadeContract.getPackageInfo(packageID, 0);
        require(price > 0, "Package does not exist");
        require(packageID > 1, "Invalid packageID");
        package_buy_unlock_conditions[packageID].whitelist[user_address] = add_remove;
        emit AddRemoveWhitelist(user_address, packageID, add_remove);
    }


    // Return the whitelisted status of a user. If whitelist is not active for the package, returns always true.
    function isUserWhitelisted(uint16 packageID, address user_address) public view returns (bool is_whitelisted) {
        if (package_buy_unlock_conditions[packageID].whitelist_enabled) {
            is_whitelisted = package_buy_unlock_conditions[packageID].whitelist[user_address];
        } else {
            is_whitelisted = true;
        }
    }


    // Enable/disable contracts that can call this threshold contract eligibility check external function
    function setEligibleProxyContract(address _contract_address, bool _eligible) external onlyPowermadeOwner {
        require(_contract_address != address(0), "Null address");
        isEligibleProxyContract[_contract_address] = _eligible;
    }


    // Function to update the pancake router or the BUSD token if needed
    function updateDEX(address _BUSD_Token) public onlyPowermadeOwner {
        pancakeRouter = IPancakeRouterView(powermadeToken.pancakeRouter());
        wbnb_token = pancakeRouter.WETH();
        price_reference_token = _BUSD_Token;
    }

}