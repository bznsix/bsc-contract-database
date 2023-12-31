/************************************************************ /
    GLOBALAID.CLUB
    WORLDWIDE GLOBAL POWERLINE

    Website: globalaid.club
    Contract Type: Primary Contract

    Project Developed by SpicyDevs.com (contact@spicydevs.com)
/ ************************************************************/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import '@openzeppelin/contracts/utils/Context.sol';
import '@openzeppelin/contracts/access/Ownable.sol';
import '@openzeppelin/contracts/security/Pausable.sol';
import '@openzeppelin/contracts/interfaces/IERC20.sol';
import '@openzeppelin/contracts/security/ReentrancyGuard.sol';

contract GlobalAidClub is Ownable, Pausable, ReentrancyGuard {
    
    struct USER {
        uint id; //Unique ID for a user
        address referrer; //Address that referred this user
        uint totalReferrals; //All referrals including free
        uint totalActiveReferrals; //Activated referrals count
        uint totalClaimed; //Total rewards claimed from packs
        mapping(uint => uint) packs; //Total packs loop "totalPacks" to display all user packs.
        uint totalPacks; //Used to loop 'packs' to get pack data for a user
        uint packsActivatedTillBronze; //packs Count that have first 3 ranks activated
    }
    mapping(address => USER) public users;
    mapping(uint => address) public idToAddress;
    
    struct PACK {
        address owner; //Owner of the pack
        uint totalClaimed; //Total claimed from this pack
        uint ranksActivated; //Ranks activated in this pack
        mapping(uint => RANK) ranks;
    }
    struct RANK {
        bool started; //If the pack is activated to start receiving rewards
        uint startedTime; //Time when the pack started receiving rewards
        uint endTime; //Time when this pack will stop receiving rewards
        uint lastClaimed; //Time when the user last claimed rewards
        uint totalClaimed; //Total rewards claimed by user
    }
    mapping(uint => PACK) public packs;

    //Plan Settings
    struct RANKCONFIG {
        bool IS_ACTIVE;
        uint REFERRALS_TO_START; //Number of referrals to activate this pack
        uint LEG_COUNT_REQUIRED; //Number of legs required after this pack to start this pack
        uint REWARDS_PER_SECOND;
        uint RANK_DURATION;
        uint REFERRAL_REWARD_PERCENT;
    }
    mapping(uint => RANKCONFIG) public packsConfig;
    uint public TOTAL_RANKS;

    //Payment Flow
    uint public PACK_COST = 5000; //$50
    uint public MANAGEMENT_FEE = 1000; //$10
    uint public FASTSTART_BONUS = 1000; //10$
    address public MANAGER_ADDRESS;
    address public VAULT_ADDRESS;

    uint constant PRECISION = 1E9;
    uint public ONE_USD_WEI = 4700000000000000;
    uint public CLAIM_COOLDOWN = 5 minutes; //Minutes before a user can claim a pack again
    uint public PRE_ACTIVATION_REFS_REQUIRED = 3; //Number of referrals required to activate a pack's first 3 ranks

    uint public totalUsers;
    uint public totalPacks;

    address public adminAddress; //Top address im the system

    //Moderators who will be whitelisted for performing automated tasks
    mapping(address => bool) public moderators;

    mapping(address => bool) public whitelistedAddress;
    uint public LAUNCHED_ON;
    uint public INITIAL_FASTSTART_ALLOW_TIME;

    //Events
    event RegisterUser(address indexed userAddress, uint indexed user_id, uint referrer_id);
    event NewPackPurchased(uint user_id, uint pack_id);
    event RankActivated(uint pack_id, uint rank, uint expiration);
    event RecordExtrasPayment(uint from_id, uint to_id, uint pack_id, uint rank, uint amount, uint paymentType);
    event USDRateModified(uint newRateInWei);

    //Modifiers
    modifier onlyMods() {
        require(moderators[_msgSender()], "#GAEC_012: Not allowed");
        _;
    }

    constructor(address _adminAddress, address _managerAddress, address _vaultAddress) {
        TOTAL_RANKS = 15;

        //Create packs
        setRankConfig(1, true, 75, 150, 40, 5000);
        setRankConfig(2, true, 200, 175, 40, 5000);
        setRankConfig(3, true, 450, 187, 50, 5000);

        setRankConfig(4, true, 1000, 300, 50, 5000);
        setRankConfig(5, true, 2000, 500, 60, 5000);
        setRankConfig(6, true, 5000, 750, 70, 5000);

        setRankConfig(7, true, 10000, 1250, 80, 5000);
        setRankConfig(8, true, 20000, 2250, 80, 5000);
        setRankConfig(9, true, 50000, 3250, 80, 5000);
        
        setRankConfig(10, true, 60000, 6250, 90, 5000);
        setRankConfig(11, true, 70000, 9500, 90, 5000);
        setRankConfig(12, true, 80000, 15000, 120, 5000);

        setRankConfig(13, true, 90000, 31250, 120, 5000);
        setRankConfig(14, true, 110000, 75000, 150, 5000);
        setRankConfig(15, true, 120000, 75000, 250, 5000);
        
        MANAGER_ADDRESS = _managerAddress;
        VAULT_ADDRESS = _vaultAddress;
        adminAddress = _adminAddress;

        //Add admin and manager to moderator
        moderators[_msgSender()] = true;

        createNewUser(adminAddress, adminAddress);

        //Create new pack in struct
        totalPacks++;
        packs[totalPacks].owner = adminAddress;
        users[adminAddress].totalPacks++;
        users[adminAddress].packs[users[adminAddress].totalPacks] = totalPacks;

        emit NewPackPurchased(users[adminAddress].id, totalPacks);
        
    }

    /**  
      * @dev Register into the project (Free to register)
      * @param _referrerAddress Address of the referrer
      */
    function Register(address _referrerAddress) external whenNotPaused nonReentrant {

        require(!isUserExists(_msgSender()), "#GAEC_001: Already registered");
        require(isUserExists(_referrerAddress), "#GAEC_002: Referrer doesnt exist");
        
        address userAddress = _msgSender();

        //Creator cannot be a contract
        uint32 size;
        assembly {
            size := extcodesize(userAddress)
        }
        require(size == 0, "cannot be a contract");
        
        createNewUser(userAddress, _referrerAddress);

    }

    /**  
      * @dev Purchase a pack
      */
    function purchasePack() external payable whenNotPaused nonReentrant {

        address userAddress = _msgSender();

        if(LAUNCHED_ON == 0) {
            require(whitelistedAddress[userAddress], "#GAEC_003: Please wait till launch");
        }

        require(msg.value >= getCost(PACK_COST), "#GAEC_004: Insufficient amount");
        require(isUserExists(userAddress), "#GAEC_005: Register first");

        //Create new pack in struct
        totalPacks++;
        packs[totalPacks].owner = userAddress;
        users[userAddress].totalPacks++;
        users[userAddress].packs[users[userAddress].totalPacks] = totalPacks;

        emit NewPackPurchased(users[userAddress].id, totalPacks);

        address fastStartReceiver = users[userAddress].referrer;
        //Miss fast start payments only after 24 hours after launch.
        if(LAUNCHED_ON > 0 && block.timestamp > LAUNCHED_ON + INITIAL_FASTSTART_ALLOW_TIME && users[fastStartReceiver].totalPacks == 0) {
            //Record missed payment for referrer
            emit RecordExtrasPayment(users[userAddress].id, users[fastStartReceiver].id, totalPacks, 0, FASTSTART_BONUS, 5); //Missed fast start bonus
            fastStartReceiver = adminAddress;
        }

        sendEth(fastStartReceiver, getCost(FASTSTART_BONUS));
        emit RecordExtrasPayment(users[userAddress].id, users[fastStartReceiver].id, totalPacks, 0, FASTSTART_BONUS, 1); //Fast start bonus

        //Send management fee
        sendEth(MANAGER_ADDRESS, getCost(MANAGEMENT_FEE));
        emit RecordExtrasPayment(users[userAddress].id, 0, totalPacks, 0, MANAGEMENT_FEE, 2); //Management fee

        //Increment referral's activeReferrals Count - True when user's first pack is actviated
        if(users[userAddress].totalPacks == 1) {
            users[users[userAddress].referrer].totalActiveReferrals++;
        }

        //Check if the user should activate his first 3 ranks of a pack
        //Check for this user
        activatePackBasedOnReferralCondition(userAddress);
        //Check for his sponsor
        activatePackBasedOnReferralCondition(users[userAddress].referrer);

        activatePacks();
        return;
        
    }

    function activatePackBasedOnReferralCondition(address userAddress) private {
        uint qualifiedPack = users[userAddress].totalActiveReferrals/PRE_ACTIVATION_REFS_REQUIRED;
        uint packsActivatedTillBronze = users[userAddress].packsActivatedTillBronze;
        if(qualifiedPack > 0 && (qualifiedPack - packsActivatedTillBronze > 0)) {
            //Check if the user has atleast 1 pack 
            if(users[userAddress].packs[packsActivatedTillBronze+1] > 0) {
                //Activate next pack's first 3 ranks
                activatePackByRank(users[userAddress].packs[packsActivatedTillBronze+1], 1);
                activatePackByRank(users[userAddress].packs[packsActivatedTillBronze+1], 2);
                activatePackByRank(users[userAddress].packs[packsActivatedTillBronze+1], 3);
            }
        }
    }

    /**  
      * @dev Claim unclaimed rewards from the contract for pack for a rank
      * @param pack_id ID of the pack
      * @param rank rank of the pack
      */
    function claimRewards(uint pack_id, uint rank) public whenNotPaused nonReentrant {
        
        address packOwner = packs[pack_id].owner;

        //Either the user or only a mod can claim rewards for another users
        if(_msgSender() != packOwner) {
            require(moderators[_msgSender()], "#GAEC_006: Not allowed");
        }
        require(packs[pack_id].ranks[rank].started, "#GAEC_007: Rank not activated yet");
        require(packs[pack_id].ranks[rank].lastClaimed+CLAIM_COOLDOWN < block.timestamp, "#GAEC_008: Cooldown active");

        uint unClaimedRewards = getUnclaimedRewards(pack_id, rank);
        require(unClaimedRewards > 0, "#GAEC_009: Nothing to claim");

        //Update totalclaimed
        users[packOwner].totalClaimed += unClaimedRewards;
        packs[pack_id].ranks[rank].totalClaimed += unClaimedRewards; //Update rank
        packs[pack_id].totalClaimed += unClaimedRewards; //Update total claimed in a pack

        //Update last claimed time
        packs[pack_id].ranks[rank].lastClaimed = block.timestamp;
        if(packs[pack_id].ranks[rank].endTime <= block.timestamp) { //Check if rank ended
            packs[pack_id].ranks[rank].lastClaimed = packs[pack_id].ranks[rank].endTime;
        }

        sendEth(packOwner, getCost(unClaimedRewards*100)/PRECISION);
        emit RecordExtrasPayment(0, users[packOwner].id, pack_id, rank, unClaimedRewards, 3); //Claim rewards

        //Send checkmatch to referrer
        address checkMatchReceiver = users[packOwner].referrer;
        uint refBonusAmount = unClaimedRewards * packsConfig[rank].REFERRAL_REWARD_PERCENT / 10000;
        if(users[users[packOwner].referrer].totalPacks == 0) {
            //Record missed payment for referrer
            emit RecordExtrasPayment(users[packOwner].id, users[users[packOwner].referrer].id, pack_id, rank, refBonusAmount, 6); //Missed checkmatch claim rewards
            checkMatchReceiver = adminAddress;
        }
        sendEth(checkMatchReceiver, getCost(refBonusAmount*100)/PRECISION);
        emit RecordExtrasPayment(users[packOwner].id, users[checkMatchReceiver].id, pack_id, rank, refBonusAmount, 4); //check match claim rewards

        return;
        
    }

    /**  
      * @dev Claim multiple ranks of a pack at once
      * @param pack_id ID of the pack
      */
    function claimMultipleRankRewards(uint pack_id) external whenNotPaused {
        for (uint rank = 1; rank <= TOTAL_RANKS; rank++) {

            //Bail out if the pack is not actived assuming next ranks are not actived too
            if(!packs[pack_id].ranks[rank].started) {
                break;
            }
            //Go to next rank if the rank has 0 rewards
            if(getUnclaimedRewards(pack_id, rank) == 0) {
                continue;
            }
            
            claimRewards(pack_id, rank);
        }
    }

    //Manually activate a pack's plan by oracle only
    function manuallyActivateUser(uint pack_id, uint rank) external onlyMods {
        require(!packs[pack_id].ranks[rank].started, "#GAEC_010: Already active");
        activatePackByRank(pack_id, rank);
    }

    //HELPER METHODS
    //Create new user
    function createNewUser(address userAddress, address referrerAddress) private {
        //Create new user in struct
        totalUsers++;
        users[userAddress].id = totalUsers;
        users[userAddress].referrer = referrerAddress;
        idToAddress[totalUsers] = userAddress;

        //Update referrer struct
        users[referrerAddress].totalReferrals++;

        emit RegisterUser(userAddress, users[userAddress].id, users[referrerAddress].id);

    }

    function activatePacks() private {
        for(uint rank = 1; rank <= TOTAL_RANKS; rank++) {
            //Check to activate pack based on legs count
            if(totalPacks+1 <= packsConfig[rank].LEG_COUNT_REQUIRED) {
                return;
            }
            uint packToActivate = (totalPacks+1) - packsConfig[rank].LEG_COUNT_REQUIRED;
            if(packToActivate > 0 && !packs[packToActivate].ranks[rank].started) {
                activatePackByRank(packToActivate, rank);
            }
        }
    }

    function activatePackByRank(uint pack_id, uint rank) private {
        if(packs[pack_id].ranks[rank].started) {
            return;
        }
        packs[pack_id].ranksActivated++;
        packs[pack_id].ranks[rank].started = true;
        packs[pack_id].ranks[rank].startedTime = block.timestamp;
        packs[pack_id].ranks[rank].endTime = block.timestamp + (packsConfig[rank].RANK_DURATION * 1 seconds);
        packs[pack_id].ranks[rank].lastClaimed = block.timestamp;
        emit RankActivated(pack_id, rank, packs[pack_id].ranks[rank].endTime);

        //If pack's rank is 3 then increement packsActivatedTillBronze++
        if(rank == 3) {
            users[packs[pack_id].owner].packsActivatedTillBronze++;
        }
    }

    function getUnclaimedRewards(uint pack_id, uint rank) public view returns (uint _amount) {
        //Check for how many seconds of unclaimed rewards pending
        if(packs[pack_id].ranks[rank].endTime > block.timestamp) { //pack not end yet
            uint unClaimedTime = block.timestamp - packs[pack_id].ranks[rank].lastClaimed;
            return unClaimedTime * packsConfig[rank].REWARDS_PER_SECOND;
        } else {
            uint unClaimedTime = packs[pack_id].ranks[rank].endTime - packs[pack_id].ranks[rank].lastClaimed;
            return unClaimedTime * packsConfig[rank].REWARDS_PER_SECOND;
        }
    }

    function getUnclaimedRewardsOfAllRanks(uint pack_id) public view returns (uint _amount) {
        uint totalRewards = 0;
        for (uint rank = 1; rank <= TOTAL_RANKS; rank++) {
            //Bail out if the pack is not actived assuming next ranks are not actived too
            if(!packs[pack_id].ranks[rank].started) {
                break;
            }
            totalRewards += getUnclaimedRewards(pack_id, rank);
        }
        return totalRewards;
    }

    function sendEth(address _receiver, uint _amount) private {
        (bool sent,) = payable(_receiver).call{value: _amount}("");
        require(sent, "#GAEC_011: Failed to send Ether");
    }

    function bytesToAddress(bytes memory bys) private pure returns (address addr) {
        assembly {
            addr := mload(add(bys, 20))
        }
    }

    //Launch project
    function launchProject(uint _fastStartAllowDays) public onlyOwner {
        LAUNCHED_ON = block.timestamp;
        INITIAL_FASTSTART_ALLOW_TIME = _fastStartAllowDays * 1 days;
    }

    //Set FAST START ALLOW DAYS
    function fastStartAllowDays(uint _fastStartAllowDays) public onlyOwner {
        INITIAL_FASTSTART_ALLOW_TIME = _fastStartAllowDays * 1 days;
    }

    //Add/remove users from whitelist
    function setWhitelistAddresses(address[] calldata addresses, bool excluded) public onlyOwner {
        for(uint256 i = 0; i < addresses.length; i++) {
            whitelistedAddress[addresses[i]] = excluded;
        }
    }

    //CONFIGURATION
    function setRankConfig(uint pack_id, bool _isActive, uint _legCountRequired, uint _rewardsPerDay, uint _rankDurationDays, uint _refRewardPercent) public onlyOwner {
        packsConfig[pack_id].IS_ACTIVE = _isActive;
        packsConfig[pack_id].LEG_COUNT_REQUIRED = _legCountRequired;
        packsConfig[pack_id].REWARDS_PER_SECOND = (_rewardsPerDay*PRECISION/86400)/100;
        packsConfig[pack_id].RANK_DURATION = _rankDurationDays * 1 days;
        packsConfig[pack_id].REFERRAL_REWARD_PERCENT = _refRewardPercent; //(5000 = 50%)
    }

    //Adjust cooldown period
    function setCooldown(uint newMinutes) external onlyOwner {
        CLAIM_COOLDOWN = newMinutes * 1 minutes;
    }

    //Change packcost
    function setPackCost(uint newValue) external onlyOwner {
        PACK_COST = newValue*100;
    }

    //Change Management fee
    function setMangementFee(uint newValue) external onlyOwner {
        MANAGEMENT_FEE = newValue*100;
    }

    //Change Faststart fee
    function setFastStartBonus(uint newValue) external onlyOwner {
        FASTSTART_BONUS = newValue*100;
    }

    //Change Manager addr
    function setManagerAddr(address newValue) external onlyOwner {
        MANAGER_ADDRESS = newValue;
    }

    //Change Moderator status
    function setModeratorStatus(address modAddr, bool state) external onlyOwner {
        moderators[modAddr] = state;
    }

    //Adjust usd rate
    function setUSD(uint dollarInWei) external onlyMods {
        ONE_USD_WEI = dollarInWei;
        emit USDRateModified(dollarInWei);
    }

    function getCost(uint _amount) public view returns (uint amount) {
        return _amount*ONE_USD_WEI/100;
    }

    /**  
      * @dev Checks if a user exists
      * @param _userAddress Address of the user to check
      */
    function isUserExists(address _userAddress) public view returns (bool) {
        return (users[_userAddress].id != 0);
    }

    /**  
      * @dev Gets an unique ID of the user from his address.
      * @param _userAddress Address of the user to check
      */
    function getIdByAddress(address _userAddress) public view returns (uint) {
        return users[_userAddress].id;
    }

    /**  
      * @dev Gets an address of the user from his id
      * @param _id ID of the address to check
      */
    function getAddressById(uint _id) public view returns (address) {
        return idToAddress[_id];
    }

    /**  
      * @dev Gets referrer address of a user from his address
      * @param _userAddress Address of the user
      */
    function getReferrerByAddress(address _userAddress) public view returns(address) {
        return users[_userAddress].referrer;
    }

    /**  
      * @dev Get user info from the address
      * @param _userAddress Address of the user
      */
    function viewUser(address _userAddress) external view returns(uint _id, address _referrer, uint _totalReferrals, uint _totalClaimed, uint _totalPacks) {
        return (
            users[_userAddress].id,
            users[_userAddress].referrer,
            users[_userAddress].totalReferrals,
            users[_userAddress].totalClaimed,
            users[_userAddress].totalPacks
        );
    }

    function viewUserPackIdByKey(address _userAddress, uint _packKey) external view returns (uint pack_id) {
        return users[_userAddress].packs[_packKey];
    }

    function viewPackByRank(uint _pack_id, uint rank) external view returns (address, uint, RANK memory) {
        return (
            packs[_pack_id].owner,
            packs[_pack_id].totalClaimed,
            packs[_pack_id].ranks[rank]
        );
    }

    /** 
    * @dev Pause the Contract
    */
    function pause() external onlyOwner whenNotPaused {
        _pause();
        emit Paused(msg.sender);
    }

    /** 
    * @dev Unpause the Contract
    */
    function unpause() external onlyOwner whenPaused {
        _unpause();
        emit Unpaused(msg.sender);
    }

    /**  
      * @dev Emergency method to withdraw tokens sent to the contract
      * @param _tokenAddress Address of the token to withdraw
      * @param _amount Amount of tokens to send
      */
    function emergencyWithdrawTokens(address _tokenAddress, uint256 _amount) external onlyOwner {
        IERC20(_tokenAddress).transfer(VAULT_ADDRESS, _amount);
    }

    /**  
      * @dev Emergency method to withdraw any ETH sent to the contract
      */
    function emergencyWithdrawAsset() external onlyOwner {
        if(!payable(VAULT_ADDRESS).send(address(this).balance)) {
            return payable(VAULT_ADDRESS).transfer(address(this).balance);
        }
    }
}// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (security/ReentrancyGuard.sol)

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
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (interfaces/IERC20.sol)

pragma solidity ^0.8.0;

import "../token/ERC20/IERC20.sol";
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.7.0) (security/Pausable.sol)

pragma solidity ^0.8.0;

import "../utils/Context.sol";

/**
 * @dev Contract module which allows children to implement an emergency stop
 * mechanism that can be triggered by an authorized account.
 *
 * This module is used through inheritance. It will make available the
 * modifiers `whenNotPaused` and `whenPaused`, which can be applied to
 * the functions of your contract. Note that they will not be pausable by
 * simply including this module, only once the modifiers are put in place.
 */
abstract contract Pausable is Context {
    /**
     * @dev Emitted when the pause is triggered by `account`.
     */
    event Paused(address account);

    /**
     * @dev Emitted when the pause is lifted by `account`.
     */
    event Unpaused(address account);

    bool private _paused;

    /**
     * @dev Initializes the contract in unpaused state.
     */
    constructor() {
        _paused = false;
    }

    /**
     * @dev Modifier to make a function callable only when the contract is not paused.
     *
     * Requirements:
     *
     * - The contract must not be paused.
     */
    modifier whenNotPaused() {
        _requireNotPaused();
        _;
    }

    /**
     * @dev Modifier to make a function callable only when the contract is paused.
     *
     * Requirements:
     *
     * - The contract must be paused.
     */
    modifier whenPaused() {
        _requirePaused();
        _;
    }

    /**
     * @dev Returns true if the contract is paused, and false otherwise.
     */
    function paused() public view virtual returns (bool) {
        return _paused;
    }

    /**
     * @dev Throws if the contract is paused.
     */
    function _requireNotPaused() internal view virtual {
        require(!paused(), "Pausable: paused");
    }

    /**
     * @dev Throws if the contract is not paused.
     */
    function _requirePaused() internal view virtual {
        require(paused(), "Pausable: not paused");
    }

    /**
     * @dev Triggers stopped state.
     *
     * Requirements:
     *
     * - The contract must not be paused.
     */
    function _pause() internal virtual whenNotPaused {
        _paused = true;
        emit Paused(_msgSender());
    }

    /**
     * @dev Returns to normal state.
     *
     * Requirements:
     *
     * - The contract must be paused.
     */
    function _unpause() internal virtual whenPaused {
        _paused = false;
        emit Unpaused(_msgSender());
    }
}
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (access/Ownable.sol)

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
     * @dev Returns the address of the current owner.
     */
    function owner() public view virtual returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
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
