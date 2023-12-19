// SPDX-License-Identifier: MIT

pragma solidity 0.8.19;

interface IERC20 {
    function balanceOf(address account) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
}

interface IDEXRouter {
    function factory() external pure returns (address);
    function WETH() external pure returns (address);

    function swapExactETHForTokensSupportingFeeOnTransferTokens(
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external payable;

    function addLiquidityETH(
        address token,
        uint amountTokenDesired,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external payable returns (uint amountToken, uint amountETH, uint liquidity);
}

interface IDAPP {
    function getUserData(address account) external view returns
    (   
        uint256 balance_,
        uint256 unclaimROI_,
        uint256 commission_,
        uint256 withdraw_,
        uint256 actionBlock_,
        address referral_,
        bool registered_
    );
    function getUserRefereeMapping(address account,uint256 deeplevel) external view returns (address[] memory);
    function getReceiveETH(address account,uint256 slot) external view returns (uint256);
}

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }
}

abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor() {
        _transferOwnership(_msgSender());
    }

    function owner() public view virtual returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _transferOwnership(newOwner);
    }

    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}

contract BitFineDAPPv2 is Ownable {

    IDEXRouter public router;

    address constant zero = address(0);
    address constant dead = address(0xdead);

    uint256 public minimumDeposit = 25 * 1e16;
    uint256 public maximumDeposit = 10 * 1e18;

    uint256 public loanFee = 1000;
    uint256 public loanRatio = 2100;

    uint256 public unlockAmount;
    uint256 public unlockValue;

    uint256 maxProfitPercent = 20000;

    uint256[] ROIAmount = [30,70,110,150,200];
    uint256[] ROIRequirement = [0,1,3,10,25];

    uint256[] topWinnerReward = [1500,3500,5000];
    uint256[] referralAmount = [1000,100,50,50,50,50,50,50,50,50];

    uint256[] withdrawFee = [2000,1500,1000];
    uint256[] withdrawFilter = [0,1e17,1e18];

    address tokenAddress = 0x07D675Fa3C17259E6F2999A998ec099Ae27aeee1;
    uint256 depositFeeToTop3 = 250;
    uint256 depositFeeToSwap = 250;

    address treasuryWallet = 0xDfa46f9fdFa76bEcB20ccf023879E4521a010d6E;
    address[] marketingWallet = [
        0x6F6d6E7D05EF8C87f50183b017133037D891a6A9,
        0x0EbEC1DC1877003EEd15431f15352eC868A5D971,
        0x33bf98f8ae9009b9c2cD57BfD0dD838D4668eFa5,
        0x0812bAfe626C793B24AEe89B3186223Db68355B4
    ];

    uint256 depositFeeToMarketing = 500;
    uint256 withdrawFeeToTreasury = 5000;

    uint day = 86400;
    uint256 denominator = 10000;

    address[] users;

    struct userData {
        uint256 balance;
        uint256 unclaimROI;
        uint256 commission;
        uint256 withdraw;
        uint256 actionBlock;
        address referral;
        mapping(uint256 => address[]) referee;
        mapping(uint256 => uint256) claimed;
        mapping(uint256 => uint256) receiveETH;
        bool registered;
        uint256 maxDepositBonus;
    }

    mapping(address => userData) user;

    struct loadData {
        bool isFreeze;
        uint256 replyAmount;
    }

    mapping(address => loadData) loan;

    uint256 genesisBlock;

    struct Top3Data {
        address[] account;
        uint256[] amount;
        uint256 reward;
        bool init;
    }

    struct Top3Winner {
        address[] account;
        uint256[] amount;
    }

    mapping(uint256 => Top3Data) top3;
    mapping(uint256 => Top3Winner) top3Winner;

    mapping(address => bool) public isMigrate;
    mapping(address => mapping(uint256 => uint256)) public top3Key;
    mapping(address => mapping(uint256 => bool)) public isTopAdsigned;
    mapping(address => mapping(uint256 => bool)) public isTopClaimed;

    bool locked;

    modifier noReentrant() {
        require(!locked, "No re-entrancy");
        locked = true;
        _;
        locked = false;
    }

    constructor() {
        router = IDEXRouter(0x10ED43C718714eb63d5aA57B78B54704E256024E);
        register(msg.sender,zero,referralAmount.length);
        genesisBlock = 1702051200;
    }

    function getUsers() public view returns (address[] memory) {
        return users;
    }

    function getTop3WinnerReward() public view returns (uint256[] memory) {
        return topWinnerReward;
    }

    function getTop3Winner(uint256 round) public view returns (address[] memory,uint256[] memory) {
        return (top3Winner[round].account,top3Winner[round].amount);
    }

    function getLoanData(address account) public view returns (loadData memory) {
        return loan[account];
    }

    function getUserData(address account) public view returns (uint256[] memory uintSet_,address referral_,bool registered_,bool isFreeze_) {
        uint256[] memory uintSet = new uint256[](6);
        uintSet[0] = user[account].balance;
        uintSet[1] = user[account].unclaimROI;
        uintSet[2] = user[account].commission;
        uintSet[3] = user[account].withdraw;
        uintSet[4] = user[account].actionBlock;
        uintSet[5] = user[account].maxDepositBonus;
        return (uintSet,user[account].referral,user[account].registered,loan[account].isFreeze);
    }

    function getTop3Data(uint256 round) public view returns
    (
        address[] memory account_,
        uint256[] memory amount_,
        uint256 reward_,
        bool init_
    ) {
        return (
            top3[round].account,
            top3[round].amount,
            top3[round].reward,
            top3[round].init
        );
    }

    function getUserRefereeMapping(address account,uint256 deeplevel) public view returns (address[] memory) {
        return user[account].referee[deeplevel];
    }

    function getUserReferralMapping(address account,uint256 upperlevel) public view returns (address[] memory) {
        address[] memory referrals = new address[](upperlevel);
        for(uint256 i=0; i<upperlevel; i++){
            referrals[i] = user[account].referral;
            account = user[account].referral;
        }
        return referrals;
    }

    function getUserClaimed(address account,uint256 slot) public view returns (uint256) {
        return (user[account].claimed[slot]);
    }

    function getReceiveETH(address account,uint256 slot) public view returns (uint256) {
        return (user[account].receiveETH[slot]);
    }

    function register(address referee,address referral,uint256 deepLevel) internal {
        if(!user[referee].registered){
            user[referee].registered = true;
            user[referee].referral = referral;
            users.push(referee);
            for(uint256 i = 0; i < deepLevel; i++){
                if(!isDeadAddress(referral)){
                    user[referral].referee[i].push(referee);
                }
                referral = user[referral].referral;
            }
        }
    }

    function deposit(address referee,address referral) public payable noReentrant returns (bool) {
        require(msg.value>=minimumDeposit,"BitFine Revert: Need More ETH For Deposit");
        uint256 afterDeposit = user[referee].balance + msg.value;
        uint256 maxAllowcate = user[referee].maxDepositBonus + maximumDeposit;
        require(afterDeposit<=maxAllowcate,"BitFine Revert: Maximum Amount ETH For Deposit");
        if(!user[referee].registered){
            require(user[referral].registered,"BitFine Revert: Referral Address Must Be Registered");
            require(referee!=referral,"BitFine Revert: Referee Must Not Be Referral");
            claimInternal(referral);
            register(referee,referral,referralAmount.length);
        }
        claimInternal(referee);
        address[] memory upline = new address[](referralAmount.length);
        upline = getUserReferralMapping(referee,referralAmount.length);
        updateTop3Amount(upline[0],msg.value);
        uint256 amountToSplit = getFeeAmount(msg.value,depositFeeToMarketing,denominator)/marketingWallet.length;
        for(uint256 i = 0; i < marketingWallet.length; i++){
            sendValue(marketingWallet[i],amountToSplit);
        }
        autoLiquidity(getFeeAmount(msg.value,depositFeeToSwap,denominator));
        for(uint256 i = 0; i < referralAmount.length; i++){
            uint256 receiveETH = getFeeAmount(msg.value,referralAmount[i],denominator);
            uint256 toCommission = getNonOverpayAmount(upline[i],receiveETH);
            user[upline[i]].commission += toCommission;
            user[upline[i]].receiveETH[i] += toCommission;
        }
        user[referee].balance += msg.value;
        return true;
    }

    function updateTop3Amount(address account,uint256 amount) internal {
        uint256 round = getCurrentRound();
        if(!top3[round].init){
            top3[round].init = true;
            top3Winner[round].account = new address[](topWinnerReward.length);
            top3Winner[round].amount = new uint256[](topWinnerReward.length);
        }
        top3[round].reward += amount;
        if(!isTopAdsigned[account][round]){
            top3[round].account.push(account);
            top3[round].amount.push(amount);
            isTopAdsigned[account][round] = true;
            top3Key[account][round] = top3[round].account.length - 1;
        }else{
            top3[round].amount[top3Key[account][round]] += amount;
        }
        uint256 score = top3[round].amount[top3Key[account][round]];
        (bool isWinner,uint256 index) = isTopWinner(account,round);
        if(isWinner){
            top3Winner[round].account[index] = account;
            top3Winner[round].amount[index] = score;
        }else{
            for (uint256 i = 0; i < topWinnerReward.length ; i++) {
                if(score > top3Winner[round].amount[i]){
                    top3Winner[round].account[i] = account;
                    top3Winner[round].amount[i] = score;
                    break;
                }
            }
        }
        sortWinnerData(round);
    }

    function isTopWinner(address account,uint256 round) public view returns (bool,uint256) {
        if(top3Winner[round].account.length>0){
            for (uint256 i = 0; i < top3Winner[round].account.length ; i++) {
                if(top3Winner[round].account[i]==account){
                    return (true,i);
                }
            }
        }
        return (false,0);
    }

    function sortWinnerData(uint256 round) internal {
        for (uint256 i = 1; i < topWinnerReward.length; i++) {
            address addr = top3Winner[round].account[i];
            uint256 key = top3Winner[round].amount[i];
            int j = int(i) - 1;
            while ((int(j) >= 0) && (top3Winner[round].amount[uint256(j)] > key)) {
                top3Winner[round].account[uint256(j+1)] = top3Winner[round].account[uint256(j)];
                top3Winner[round].amount[uint256(j+1)] = top3Winner[round].amount[uint256(j)];
                j--;
            }
            top3Winner[round].account[uint256(j+1)] = addr;
            top3Winner[round].amount[uint256(j+1)] = key;
        }
    }

    function getCurrentRound() public view returns (uint256) {
        if(block.timestamp>genesisBlock){
            uint256 period = block.timestamp - genesisBlock;
            return period / day;
        }
        return 0;
    }

    function autoLiquidity(uint256 amount) internal {
        address[] memory path = new address[](2);
        path[0] = router.WETH();
        path[1] = tokenAddress;
        try router.swapExactETHForTokensSupportingFeeOnTransferTokens{ value: amount / 2 }(
            0,
            path,
            address(this),
            block.timestamp
        ) {} catch {}

        uint256 amountTokenDesired = IERC20(tokenAddress).balanceOf(address(this));
        IERC20(tokenAddress).approve(address(router),amountTokenDesired);

        try router.addLiquidityETH{ value: amount / 2 }(
            tokenAddress,
            amountTokenDesired,
            0,
            0,
            owner(),
            block.timestamp
        ) {} catch {}
    }

    function getROI(address account) public view returns (uint256) {
        uint256 i = ROIRequirement.length - 1;
        do{
            if(user[account].referee[0].length>=ROIRequirement[i]){
                return ROIAmount[i];
            }
            i--;
        }while(i>0);
        return ROIAmount[0];
    }

    function claimROI(address account) external noReentrant returns (bool) {
        claimInternal(account);
        uint256 unclaimROI = user[account].unclaimROI;
        uint256 amountToWithdraw = takeFeeAmount(unclaimROI,getWithdrawFee(unclaimROI),denominator);
        uint256 amountToMarketing = getFeeAmount(unclaimROI,getWithdrawFee(unclaimROI),denominator);
        uint256 amountToTreasury = getFeeAmount(amountToMarketing,withdrawFeeToTreasury,denominator);
        uint256 amountToSplit = (amountToMarketing - amountToTreasury) / marketingWallet.length;
        user[account].unclaimROI = 0;
        user[account].withdraw += amountToWithdraw;
        user[account].claimed[0] += amountToWithdraw;
        sendValue(account,amountToWithdraw);
        sendValue(treasuryWallet,amountToTreasury);
        for(uint256 i = 0; i < marketingWallet.length; i++){
            sendValue(marketingWallet[i],amountToSplit);
        }
        return true;
    }

    function claimCommission(address account) external noReentrant returns (bool) {
        uint256 commission = user[account].commission;
        user[account].commission = 0;
        user[account].withdraw += commission;
        user[account].claimed[1] += commission;
        sendValue(account,commission);
        return true;
    }

    function claimTop3Reward(address account,uint256 round) external noReentrant returns (bool) {
        require(!isTopClaimed[account][round],"BitFine Revert: This Account Was Claimed");
        require(getCurrentRound()>round,"BitFine Revert: This Round Was Not Ended");
        isTopClaimed[account][round] = true;
        bool isWinner;
        uint256 index;
        for(uint256 i = 0; i < topWinnerReward.length; i++){
            if(account==top3Winner[round].account[i]){
                isWinner = true; index = i;
                break;
            }
        }
        require(isWinner,"BitFine Revert: This Account Does Not Win This Round");
        uint256 rewardToBePaid = top3[round].reward * depositFeeToTop3 / denominator;
        uint256 rewardToBeClaim = rewardToBePaid * topWinnerReward[index] / denominator;
        user[account].claimed[2] += rewardToBeClaim;
        sendValue(account,rewardToBeClaim);
        return true;
    }

    function claimInternal(address account) internal {
        uint256 toClaimAmount = getROIRewards(account);
        user[account].actionBlock = block.timestamp;
        user[account].unclaimROI += toClaimAmount;
    }

    function getAccountReward(address account) public view returns (uint256) {
        return getROIRewards(account) + user[account].unclaimROI;
    }

    function getROIRewards(address account) public view returns (uint256) {
        if(user[account].actionBlock>0 && !loan[account].isFreeze){
            uint256 period = block.timestamp - user[account].actionBlock;
            uint256 ROI = user[account].balance * getROI(account) / denominator;
            uint256 reward = ROI * period / day;
            return getNonOverpayAmount(account,reward);
        }
        return 0;
    }

    function getNonOverpayAmount(address account,uint256 amount) public view returns (uint256) {
        if(getStuckAmount(account) + amount > getMaxEarnAmount(account)){
            return getMaxEarnAmount(account) - getStuckAmount(account);
        }
        return amount;
    }

    function getMaxEarnAmount(address account) public view returns (uint256) {
        return user[account].balance * maxProfitPercent / 10000;
    }

    function getStuckAmount(address account) public view returns (uint256) {
        return user[account].withdraw + user[account].unclaimROI + user[account].commission;
    }

    function getmaxProfitPercent() public view returns (uint256) {
        return maxProfitPercent;
    }

    function getReferralAmount() public view returns (uint256[] memory) {
        return referralAmount;
    }

    function getWithdrawFees() public view returns (uint256[] memory,uint256[] memory) {
        return (withdrawFee,withdrawFilter);
    }

    function getROIAmount() public view returns (uint256[] memory,uint256[] memory) {
        return (ROIAmount,ROIRequirement);
    }

    function getMarketingFees() public view returns 
    (
        address treasuryWallet_,
        address[] memory marketingWallet_,
        uint256 depositFeeToTop3_,
        uint256 depositFeeToMarketing_,
        uint256 withdrawFeeToTreasury_
    ) {
        return (
            treasuryWallet,
            marketingWallet,
            depositFeeToTop3,
            depositFeeToMarketing,
            withdrawFeeToTreasury
        );
    }

    function getExternalReacts() public view returns 
    (
        address tokenAddress_,
        uint256 depositFeeToSwap_
    ) {
        return (
            tokenAddress,
            depositFeeToSwap
        );
    }

    function accountShouldMigrate(address account) public view returns (bool) {
        IDAPP bitfine = IDAPP(0x2eFA1bFa04Dfa837846f447a462cd4dc1380A538);
        (,,,,,,bool reg) = bitfine.getUserData(account);
        if(reg && !isMigrate[account]){ return true; }
        return false;
    }

    function unlockMaxDeposit(address account) public returns (bool) {
        require(unlockAmount>0,"BitFine Revert: This Function temporary disabled");
        IERC20 token = IERC20(tokenAddress);
        token.transferFrom(msg.sender,address(this),unlockAmount);
        user[account].maxDepositBonus += unlockValue;
        return true;
    }

    function migrateUser(address account) public payable noReentrant returns (bool) {
        require(!isMigrate[account],"BitFine Revert: This Account Was Migrate");
        require(account==msg.sender || owner()==msg.sender,"BitFine Revert: Permission Deney Access");
        isMigrate[account] = true;
        IDAPP bitfine = IDAPP(0x2eFA1bFa04Dfa837846f447a462cd4dc1380A538);
        uint256[] memory dataSet = new uint256[](6);
        (uint256 b,uint256 u,uint256 c,uint256 w,uint256 a,address ref,bool reg) = bitfine.getUserData(account);
        require(reg,"BitFine Revert: Migrate Account Must Be In V1");
        if(account!=owner()){ users.push(account); }
        dataSet[0] = b;
        dataSet[1] = u;
        dataSet[2] = c;
        dataSet[3] = w;
        dataSet[4] = a;
        dataSet[5] = 0;
        updateUserData(account,ref,true,false,dataSet);
        updateUserReferee(account,0,bitfine.getUserRefereeMapping(account,0));
        updateUserReferee(account,1,bitfine.getUserRefereeMapping(account,1));
        updateUserReferee(account,2,bitfine.getUserRefereeMapping(account,2));
        updateUserReferee(account,3,bitfine.getUserRefereeMapping(account,3));
        updateUserReferee(account,4,bitfine.getUserRefereeMapping(account,4));
        updateUserReferee(account,5,bitfine.getUserRefereeMapping(account,5));
        updateUserReferee(account,6,bitfine.getUserRefereeMapping(account,6));
        updateUserReferee(account,7,bitfine.getUserRefereeMapping(account,7));
        updateUserReferee(account,8,bitfine.getUserRefereeMapping(account,8));
        updateUserReferee(account,9,bitfine.getUserRefereeMapping(account,9));
        updateUserReceiveETH(account,0,bitfine.getReceiveETH(account,0));
        updateUserReceiveETH(account,1,bitfine.getReceiveETH(account,1));
        updateUserReceiveETH(account,2,bitfine.getReceiveETH(account,2));
        return true;
    }

    function loadAsset(address account) public noReentrant returns (bool) {
        require(!loan[account].isFreeze,"BitFine Revert: This account was freeze");
        require(user[account].referee[0].length>=ROIRequirement[2],"BitFine Revert: Need VIP 2");
        claimInternal(account);
        uint256 futureEarn = getMaxEarnAmount(account) - getStuckAmount(account);
        uint256 loanAmount = futureEarn * loanRatio / denominator;
        uint256 fee = loanAmount * loanFee / denominator;
        loan[account].replyAmount = loanAmount;
        loan[account].isFreeze = true;
        sendValue(account,loanAmount - fee);
        return true;
    }

    function replyAsset(address account) public payable noReentrant returns (bool) {
        require(loan[account].replyAmount>0,"BitFine Revert: This Account Have Not Loan Yet");
        require(loan[account].replyAmount<=msg.value,"BitFine Revert: Need More ETH To Reply");
        claimInternal(account);
        loan[account].replyAmount = 0;
        loan[account].isFreeze = false;
        return true;
    }

    function settingUserData(address account,address referral,bool isRegistered,bool isFreeze,uint256[] memory uintSet) public onlyOwner returns (bool) {
        updateUserData(account,referral,isRegistered,isFreeze,uintSet);
        return true;
    }

    function settingUserReferee(address account,uint256 slot,address[] memory data) public onlyOwner returns (bool) {
        updateUserReferee(account,slot,data);
        return true;
    }

    function settingUserReceiveETH(address account,uint256 slot,uint256 value) public onlyOwner returns (bool) {
        updateUserReceiveETH(account,slot,value);
        return true;
    }

    function updateUserData(address account,address referral,bool isRegistered,bool isFreeze,uint256[] memory uintSet) internal {
        user[account].balance = uintSet[0];
        user[account].unclaimROI = uintSet[1];
        user[account].commission = uintSet[2];
        user[account].withdraw = uintSet[3];
        user[account].actionBlock = uintSet[4];
        user[account].maxDepositBonus = uintSet[5];
        user[account].referral = referral;
        user[account].registered = isRegistered;
        loan[account].isFreeze = isFreeze;
    }

    function updateUserReferee(address account,uint256 slot,address[] memory data) internal {
        user[account].referee[slot] = data;
    }

    function updateUserReceiveETH(address account,uint256 slot,uint256 value) internal {
        user[account].receiveETH[slot] = value;
    }

    function updateGenesisBlock(uint256 blockstamp) public onlyOwner returns (bool) {
        genesisBlock = blockstamp;
        return true;
    }

    function updateMinimumDeposit(uint256 amountETH) public onlyOwner returns (bool) {
        minimumDeposit = amountETH;
        return true;
    }

    function updateMaximumDeposit(uint256 amountETH) public onlyOwner returns (bool) {
        maximumDeposit = amountETH;
        return true;
    }

    function updateLoanData(uint256 fee,uint256 ratio) public onlyOwner returns (bool) {
        loanFee = fee;
        loanRatio = ratio;
        return true;
    }

    function updateUnlockAmount(uint256 amount,uint256 value) public onlyOwner returns (bool) {
        unlockAmount = amount;
        unlockValue = value;
        return true;
    }

    function updateMaxProfitPercent(uint256 maxProfit) public onlyOwner returns (bool) {
        maxProfitPercent = maxProfit;
        return true;
    }

    function updateReferralAmount(uint256[] memory amounts) public onlyOwner returns (bool) {
        referralAmount = amounts;
        return true;
    }

    function updateROIAmount(uint256[] memory amounts,uint256[] memory requirements) public onlyOwner returns (bool) {
        ROIAmount = amounts;
        ROIRequirement = requirements;
        return true;
    }

    function updateWithdrawFees(uint256[] memory fees,uint256[] memory filters) public onlyOwner returns (bool) {
        withdrawFee = fees;
        withdrawFilter = filters;
        return true;
    }

    function updateMarketingWallet(address treasury,address[] memory marketing,uint256 feeTop,uint256 feeDeposit,uint256 feeTreasury) public onlyOwner returns (bool) {
        treasuryWallet = treasury;
        marketingWallet = marketing;
        depositFeeToTop3 = feeTop;
        depositFeeToMarketing = feeDeposit;
        withdrawFeeToTreasury = feeTreasury;
        return true;
    }

    function updateExternalReacts(address token,uint256 feeSwap) public onlyOwner returns (bool) {
        tokenAddress = token;
        depositFeeToSwap = feeSwap;
        return true;
    }

    function updateTopWinnerReward(uint256[] memory rewards) public onlyOwner returns (bool) {
        topWinnerReward = rewards;
        return true;
    }

    function getWithdrawFee(uint256 amount) public view returns (uint256) {
        uint256 i = withdrawFilter.length - 1;
        do{
            if(amount>=withdrawFilter[i]){
                return withdrawFee[i];
            }
            i--;
        }while(i>0);
        return withdrawFee[0];
    }

    function getFeeAmount(uint256 amount,uint256 fee,uint256 deno) internal pure returns (uint256) {
        return amount * fee / deno;
    }

    function takeFeeAmount(uint256 amount,uint256 fee,uint256 deno) internal pure returns (uint256) {
        return amount - getFeeAmount(amount,fee,deno);
    }

    function isDeadAddress(address account) internal pure returns (bool) {
        if(account == zero || account == dead){ return true; }
        return false;
    }

    function callWithData(address to,bytes memory data) public onlyOwner returns (bytes memory) {
        (bool success,bytes memory result) = to.call(data);
        require(success);
        return result;
    }

    function callWithValue(address to,bytes memory data,uint256 amount) public onlyOwner returns (bytes memory) {
        (bool success,bytes memory result) = to.call{ value: amount }(data);
        require(success);
        return result;
    }

    function sendValue(address to,uint256 amount) internal {
        if(!isDeadAddress(to) && amount > 0){
            (bool success,) = to.call{ value: amount }("");
            require(success,"BitFine Revert: Fail To Send ETH");
        }
    }

    receive() external payable {}
}