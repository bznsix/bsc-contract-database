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


// Interface to access Powermade contract data
interface Powermade {
    // get the owner 
    function ownerWallet() external view returns (address owner);
    // Get info of a package
    function getPackageInfo(uint16 packageID, uint userID) external view returns (uint price, uint duration, bool enabled, bool rebuy_enabled, bool rebuy_before_exp, uint16[] memory prerequisites, uint16[] memory percentages, bool prereq_not_exp, uint totalEarnedPack, uint purchasesCount, uint last_pid);
    // userInfos getter function (automatically generated because userInfos mapping is public). The getter can only contain standard types, not arrays or other mappings.
    function userInfos(address userAddr) external view returns (uint id, uint referrerID, uint virtualID, uint32 round_robin_next_index, bool banned, uint totalEarned);
    // Get Purchases and related info
    function getAllPurchases(uint userID, uint16 packageID, uint start_index, uint stop_index, bool only_last) external view returns (uint count_all, uint[] memory userIDs_or_PIDs, uint16[] memory packageIDs, uint[] memory timestamps, uint[] memory durations, bool[] memory expireds);
    // userIDaddress getter function
    function userIDaddress(uint userID) external view returns (address userAddr);
}

// Interface for the external custom threshold/eligibility for the package and/or for the commissions
interface ExternalEligibilityContract {
    // Functions used to check the eligibility (eg. custom Token/NFT/other thresholds or other logics) 
    // The first one is called when it's required a state update, for example when calling from the payCommissions cycles. The second one is called only to check the status as a view function
    // The ExternalEligibilityContract must implement both
    function isEligibleExt(address user_address, address other_address, uint16 packageID, uint param1, uint8 sourceID) external returns (bool is_eligible);
    function isEligibleExtW(address user_address, address other_address, uint16 packageID, uint param1, uint8 sourceID) external view returns (bool is_eligible);
}

// Custom Thresholds Proxy to manage complex rules for each package, with default/global rules and specific rules.
contract ExternalThresholdRulesProxy is ExternalEligibilityContract {

    // Contracts
    Powermade public powermadeContract;             // The PowermadeAffiliation contract

    // Structures
    struct ThresholdSettings {
        bool and_or_mode;                           // AND (false) or OR (true) mode. For AND: all outcomes must be true. For OR: at least one outcome must be true
        uint8 order_priority_mode;                  // 0: Prefer Specific; 1: Append; 2: Prepend; 3: Bypass Default/Global. Valid only for packageID > 0
        bool append_prepend_and_or_mode;            // AND (false) on OR (true) between global/default rule block and specific rule block. Valid only for packageID > 0
        bool empty_rules_default_outcome;           // Outcome to use in the case of empty specific rules. Valid only for packageID > 0
    }

    struct ThresholdsRuleSettings {
        ExternalEligibilityContract threshold_contract;     // The threshold contract to call (rule)
        bool bypass_unlock_check;                           // Bypass the evaluation of the package unlock condition (during buy operation). Return the specified outcome
        bool bypass_unlock_outcome;
        bool bypass_invited_payout_check;                   // Bypass the evaluation of the invited commission eligibility (payout). Return the specified outcome
        bool bypass_invited_payout_outcome;
        bool[5] bypass_levels_payout_check;                 // Bypass the evaluation of the level commissions eligibility (payout). Return the specified outcomes
        bool[5] bypass_levels_payout_outcome;
    }

    // Storage variables
    mapping (address => bool) public isEligibleProxyContract;   // Other Smart Contracts that can call the isEligibleExt() function of this contract 
    mapping (uint16 => ThresholdSettings) private rules_main_settings;       // The rules settings for each packageID
    mapping (uint16 => mapping (uint8 => ThresholdsRuleSettings)) private threshold_rules;      // The threshold contracts (rules) to call for each packageID


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
    constructor(address _powermadeAddress, address _eligibleProxyContractAddress, address _FirstGlobalRuleContract) public {
        powermadeContract = Powermade(_powermadeAddress);
        if (_eligibleProxyContractAddress != address(0)) {
            isEligibleProxyContract[_eligibleProxyContractAddress] = true;
        }
        if (_FirstGlobalRuleContract != address(0)) {
            threshold_rules[0][0].threshold_contract = ExternalEligibilityContract(_FirstGlobalRuleContract);
        }
    }


    // Implementation of the ExternalEligibilityContract interface (only used parameters). View function.
    function isEligibleExtW(address user_address, address other_address, uint16 packageID, uint level, uint8 sourceID) public view returns (bool is_eligible) {
        if (address(threshold_rules[0][0].threshold_contract) == address(0)) {
            return false ;      // No first global rule. Return False
        }
        if (rules_main_settings[packageID].order_priority_mode == 1) {
            // APPEND mode. First run the Default rules then the specific rules if any
            bool default_rules_outcome = _runRulesW(user_address, other_address, packageID, level, sourceID, 0);
            if (default_rules_outcome && rules_main_settings[packageID].append_prepend_and_or_mode) {
                // OR mode and first block is true
                return true;
            }
            bool specific_rules_outcome = _runRulesW(user_address, other_address, packageID, level, sourceID, packageID);
            if (rules_main_settings[packageID].append_prepend_and_or_mode) {
                // OR mode between global and specific blocks
                return (default_rules_outcome || specific_rules_outcome);
            } else {
                // AND mode between global and specific blocks
                return (default_rules_outcome && specific_rules_outcome);
            }          
        } else if (rules_main_settings[packageID].order_priority_mode == 2) {
            // PREPEND mode. First run the specific rules, if any, then the Default rules
            bool specific_rules_outcome = _runRulesW(user_address, other_address, packageID, level, sourceID, packageID);
            if (specific_rules_outcome && rules_main_settings[packageID].append_prepend_and_or_mode) {
                // OR mode and first block is true
                return true;
            }
            bool default_rules_outcome = _runRulesW(user_address, other_address, packageID, level, sourceID, 0);
            if (rules_main_settings[packageID].append_prepend_and_or_mode) {
                // OR mode between global and specific blocks
                return (default_rules_outcome || specific_rules_outcome);
            } else {
                // AND mode between global and specific blocks
                return (default_rules_outcome && specific_rules_outcome);
            }
        } else if (rules_main_settings[packageID].order_priority_mode == 0) {
            // PREFER SPECIFIC mode. If there are specific rules use them, otherwise the global one(s)
            if (address(threshold_rules[packageID][0].threshold_contract) == address(0)) { 
                // Use global rules
                bool default_rules_outcome = _runRulesW(user_address, other_address, packageID, level, sourceID, 0);
                return default_rules_outcome;
            } else {
                // Use specific rules
                bool specific_rules_outcome = _runRulesW(user_address, other_address, packageID, level, sourceID, packageID);
                return specific_rules_outcome;
            }
        } else if (rules_main_settings[packageID].order_priority_mode == 3) {
            // BYPASS DEFAULT/GLOBAL mode. Use only specific rules. If there are no specific rule(s) return the empty default outcome
            bool specific_rules_outcome = _runRulesW(user_address, other_address, packageID, level, sourceID, packageID);
            return specific_rules_outcome;
        }
    }


    // Implementation of the ExternalEligibilityContract interface (only used parameters). Call function (it can update storage)
    function isEligibleExt(address user_address, address other_address, uint16 packageID, uint level, uint8 sourceID) external onlyPowermadeOrProxyContract returns (bool is_eligible) {
        if (address(threshold_rules[0][0].threshold_contract) == address(0)) {
            revert("No global/default rule set");
        }
        if (rules_main_settings[packageID].order_priority_mode == 1) {
            // APPEND mode. First run the Default rules then the specific rules if any
            bool default_rules_outcome = _runRules(user_address, other_address, packageID, level, sourceID, 0);
            if (default_rules_outcome && rules_main_settings[packageID].append_prepend_and_or_mode) {
                // OR mode and first block is true
                return true;
            }
            bool specific_rules_outcome = _runRules(user_address, other_address, packageID, level, sourceID, packageID);
            if (rules_main_settings[packageID].append_prepend_and_or_mode) {
                // OR mode between global and specific blocks
                return (default_rules_outcome || specific_rules_outcome);
            } else {
                // AND mode between global and specific blocks
                return (default_rules_outcome && specific_rules_outcome);
            }          
        } else if (rules_main_settings[packageID].order_priority_mode == 2) {
            // PREPEND mode. First run the specific rules, if any, then the Default rules
            bool specific_rules_outcome = _runRules(user_address, other_address, packageID, level, sourceID, packageID);
            if (specific_rules_outcome && rules_main_settings[packageID].append_prepend_and_or_mode) {
                // OR mode and first block is true
                return true;
            }
            bool default_rules_outcome = _runRules(user_address, other_address, packageID, level, sourceID, 0);
            if (rules_main_settings[packageID].append_prepend_and_or_mode) {
                // OR mode between global and specific blocks
                return (default_rules_outcome || specific_rules_outcome);
            } else {
                // AND mode between global and specific blocks
                return (default_rules_outcome && specific_rules_outcome);
            }
        } else if (rules_main_settings[packageID].order_priority_mode == 0) {
            // PREFER SPECIFIC mode. If there are specific rules use them, otherwise the global one(s)
            if (address(threshold_rules[packageID][0].threshold_contract) == address(0)) { 
                // Use global rules
                bool default_rules_outcome = _runRules(user_address, other_address, packageID, level, sourceID, 0);
                return default_rules_outcome;
            } else {
                // Use specific rules
                bool specific_rules_outcome = _runRules(user_address, other_address, packageID, level, sourceID, packageID);
                return specific_rules_outcome;
            }
        } else if (rules_main_settings[packageID].order_priority_mode == 3) {
            // BYPASS DEFAULT/GLOBAL mode. Use only specific rules. If there are no specific rule(s) return the empty default outcome
            bool specific_rules_outcome = _runRules(user_address, other_address, packageID, level, sourceID, packageID);
            return specific_rules_outcome;
        }
    }


    // Function to get a quick overview of the unlocked status of packageID and levels of a user_address (Important, the "other_address" parameter is not used and set to address(0) for this check).
    function getUnlockedStatus(uint userID, address user_address, uint16 packageID) public view returns (bool buy_unlocked, bool[6] memory levels_unlocked) {
        if (userID == 0) {
            require(user_address != address(0), "Invalid user_address");
            (userID, , , , , ) = powermadeContract.userInfos(user_address);
        } else {
            require(userID > 1, "Invalid UserID");
            user_address = powermadeContract.userIDaddress(userID);
        }
        (uint n_purchases, , , , , ) = powermadeContract.getAllPurchases(userID, packageID, 0, 0, true);
        buy_unlocked = isEligibleExtW(user_address, address(0), packageID, n_purchases, 1);
        for (uint8 i = 0; i < 6; i++) {
            uint8 source = 3;
            if (i == 0) {
                source = 2;
            }
            levels_unlocked[i] = isEligibleExtW(user_address, address(0), packageID, i, source);
        }
    }

    
    // Internal function to evaluate a rule block (default/global or specific, related to the packageID). View function calls.
    function _runRulesW(address user_address, address other_address, uint16 packageID, uint level, uint8 sourceID, uint16 rules_id) internal view returns (bool outcome) {
        uint8 rule_index = 0;
        outcome = false;
        while (true) {
            if (address(threshold_rules[rules_id][rule_index].threshold_contract) == address(0)) { 
                if (rule_index == 0) {
                    outcome = rules_main_settings[packageID].empty_rules_default_outcome;
                }
                break; 
            }
            if (sourceID == 1) {        // Case Package Buy (level is the n_bought in this case, excluding the current purchase)
                if (threshold_rules[rules_id][rule_index].bypass_unlock_check) {
                    outcome = threshold_rules[rules_id][rule_index].bypass_unlock_outcome;
                } else {
                    outcome = threshold_rules[rules_id][rule_index].threshold_contract.isEligibleExtW(user_address, other_address, packageID, level, sourceID);
                }
            } else if (sourceID == 2) {     // Case sponsor commission (direct). Level is always 0
                if (threshold_rules[rules_id][rule_index].bypass_invited_payout_check) {
                    outcome = threshold_rules[rules_id][rule_index].bypass_invited_payout_outcome;
                } else {
                    outcome = threshold_rules[rules_id][rule_index].threshold_contract.isEligibleExtW(user_address, other_address, packageID, level, sourceID);
                }                    
            } else if (sourceID == 3) {     // Case level commission. level is the distributed level (1 to 5)
                if (threshold_rules[rules_id][rule_index].bypass_levels_payout_check[level-1]) {
                    outcome = threshold_rules[rules_id][rule_index].bypass_levels_payout_outcome[level-1];
                } else {
                    outcome = threshold_rules[rules_id][rule_index].threshold_contract.isEligibleExtW(user_address, other_address, packageID, level, sourceID);
                } 
            } else {
                outcome = true;
            }
            rule_index++;       // increase index
            // AND or OR mode
            if (rules_main_settings[rules_id].and_or_mode) {
                // OR mode
                if (outcome == true) {
                    break;
                }
            } else {
                // AND mode
                if (outcome == false) {
                    break;
                }
            }
        }
    }


    // Internal function to evaluate a rule block (default/global or specific, related to the packageID).
    function _runRules(address user_address, address other_address, uint16 packageID, uint level, uint8 sourceID, uint16 rules_id) internal returns (bool outcome) {
        uint8 rule_index = 0;
        outcome = false;
        while (true) {
            if (address(threshold_rules[rules_id][rule_index].threshold_contract) == address(0)) { 
                if (rule_index == 0) {
                    outcome = rules_main_settings[packageID].empty_rules_default_outcome;
                }
                break; 
            }
            if (sourceID == 1) {        // Case Package Buy (level is the n_bought in this case, excluding the current purchase)
                if (threshold_rules[rules_id][rule_index].bypass_unlock_check) {
                    outcome = threshold_rules[rules_id][rule_index].bypass_unlock_outcome;
                } else {
                    outcome = threshold_rules[rules_id][rule_index].threshold_contract.isEligibleExt(user_address, other_address, packageID, level, sourceID);
                }
            } else if (sourceID == 2) {     // Case sponsor commission (direct). Level is always 0
                if (threshold_rules[rules_id][rule_index].bypass_invited_payout_check) {
                    outcome = threshold_rules[rules_id][rule_index].bypass_invited_payout_outcome;
                } else {
                    outcome = threshold_rules[rules_id][rule_index].threshold_contract.isEligibleExt(user_address, other_address, packageID, level, sourceID);
                }                    
            } else if (sourceID == 3) {     // Case level commission. level is the distributed level (1 to 5)
                if (threshold_rules[rules_id][rule_index].bypass_levels_payout_check[level-1]) {
                    outcome = threshold_rules[rules_id][rule_index].bypass_levels_payout_outcome[level-1];
                } else {
                    outcome = threshold_rules[rules_id][rule_index].threshold_contract.isEligibleExt(user_address, other_address, packageID, level, sourceID);
                } 
            } else {
                outcome = true;
            }
            rule_index++;       // increase index
            // AND or OR mode
            if (rules_main_settings[rules_id].and_or_mode) {
                // OR mode
                if (outcome == true) {
                    break;
                }
            } else {
                // AND mode
                if (outcome == false) {
                    break;
                }
            }
        }
    }


    // Enable/disable contracts that can call this threshold contract eligibility check external function
    function setEligibleProxyContract(address _contract_address, bool _eligible) external onlyPowermadeOwner {
        require(_contract_address != address(0), "Null address");
        isEligibleProxyContract[_contract_address] = _eligible;
    }


    // Function to set the main settings for rules associated to the specified packageID (use 0 to set and_or_mode for default/global rules) 
    function setRulesMainSettings(uint16 packageID, bool and_or_mode, uint8 order_priority_mode, bool append_prepend_and_or_mode, bool empty_rules_default_outcome) external onlyPowermadeOwner {
        require(order_priority_mode <= 3, "Invalid order_priority_mode");
        rules_main_settings[packageID].and_or_mode = and_or_mode;
        rules_main_settings[packageID].order_priority_mode = order_priority_mode;
        rules_main_settings[packageID].append_prepend_and_or_mode = append_prepend_and_or_mode;
        rules_main_settings[packageID].empty_rules_default_outcome = empty_rules_default_outcome;
    }


    // Function to read the main settings for rules associated to the specified packageID (use 0 to set and_or_mode for default/global rules) 
    function getRulesMainSettings(uint16 packageID) public view returns (bool and_or_mode, uint8 order_priority_mode, bool append_prepend_and_or_mode, bool empty_rules_default_outcome) {
        and_or_mode = rules_main_settings[packageID].and_or_mode;
        order_priority_mode = rules_main_settings[packageID].order_priority_mode;
        append_prepend_and_or_mode = rules_main_settings[packageID].append_prepend_and_or_mode;
        empty_rules_default_outcome = rules_main_settings[packageID].empty_rules_default_outcome;
    }


    // Get the number of configured rules associated to the specified packageID (use 0 to set and_or_mode for default/global rules) 
    function getRulesCount(uint16 packageID) public view returns (uint8 count) {
        count = 0;
        while (true) {
            if (address(threshold_rules[packageID][count].threshold_contract) == address(0)) { 
                break; 
            }
            count++;
        }
    }


    // Get the configured rule at given index, associated to the specified packageID (use 0 to set and_or_mode for default/global rules) 
    function getThresholdRulesSettings(uint16 packageID, uint8 index) public view returns (address threshold_contract, bool bypass_unlock_check, bool bypass_unlock_outcome, bool bypass_invited_payout_check, bool bypass_invited_payout_outcome, bool[5] memory bypass_levels_payout_check, bool[5] memory bypass_levels_payout_outcome) {
        require(index < getRulesCount(packageID), "Not valid index");
        threshold_contract = address(threshold_rules[packageID][index].threshold_contract);
        bypass_unlock_check = threshold_rules[packageID][index].bypass_unlock_check;
        bypass_unlock_outcome = threshold_rules[packageID][index].bypass_unlock_outcome;
        bypass_invited_payout_check = threshold_rules[packageID][index].bypass_invited_payout_check;
        bypass_invited_payout_outcome = threshold_rules[packageID][index].bypass_invited_payout_outcome;
        bypass_levels_payout_check = threshold_rules[packageID][index].bypass_levels_payout_check;
        bypass_levels_payout_outcome = threshold_rules[packageID][index].bypass_levels_payout_outcome;
    }


    // Set the configured rule at given index, associated to the specified packageID (use 0 to set and_or_mode for default/global rules) 
    function setThresholdRulesSettings(uint16 packageID, uint8 index, address threshold_contract, bool bypass_unlock_check, bool bypass_unlock_outcome, bool bypass_invited_payout_check, bool bypass_invited_payout_outcome, bool[5] calldata bypass_levels_payout_check, bool[5] calldata bypass_levels_payout_outcome) external onlyPowermadeOwner {
        require(index <= getRulesCount(packageID), "Not valid index");
        require(bypass_levels_payout_check.length == 5 && bypass_levels_payout_outcome.length == 5, "Invalid array length, it must be 5");
        threshold_rules[packageID][index].threshold_contract = ExternalEligibilityContract(threshold_contract);
        threshold_rules[packageID][index].bypass_unlock_check = bypass_unlock_check;
        threshold_rules[packageID][index].bypass_unlock_outcome = bypass_unlock_outcome;
        threshold_rules[packageID][index].bypass_invited_payout_check = bypass_invited_payout_check;
        threshold_rules[packageID][index].bypass_invited_payout_outcome = bypass_invited_payout_outcome;
        threshold_rules[packageID][index].bypass_levels_payout_check = bypass_levels_payout_check;
        threshold_rules[packageID][index].bypass_levels_payout_outcome = bypass_levels_payout_outcome;
    }


}