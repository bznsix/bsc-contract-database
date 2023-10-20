// SPDX-License-Identifier: MIT

pragma solidity 0.8.19;

interface IERC20 {
    function balanceOf(address account) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
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

contract BitFine is Ownable {

    IDEXRouter public router;

    address constant zero = address(0);
    address constant dead = address(0xdead);

    uint256 public minimumDeposit = 0; //0.0025
    
    uint256 maxProfitPercent = 20000;

    uint256[] ROIAmount = [30,70,110,150,200];
    uint256[] ROIRequirement = [0,1,3,10,25];

    uint256[] topWinnerReward = [1500,3500,5000];
    uint256[] referralAmount = [500,100,75,50,25];

    uint256[] withdrawFee = [3500,2000,1000];
    uint256[] withdrawFilter = [0,1e17,1e18];

    address tokenAddress = 0xD1CD32bA239D8682D33b5e5bab508a31E04F7044;
    uint256 depositFeeToTop3 = 250;
    uint256 depositFeeToSwap = 250;

    address treasuryWallet = 0x8e9503aB14ed1105534d07f9bb35A22BF8665A0F;
    address[] marketingWallet = [0x8e9503aB14ed1105534d07f9bb35A22BF8665A0F,0x8e9503aB14ed1105534d07f9bb35A22BF8665A0F,0x8e9503aB14ed1105534d07f9bb35A22BF8665A0F];
    uint256 depositFeeToMarketing = 600;
    uint256 withdrawFeeToTreasury = 5000;

    uint day = 300;
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
    }

    mapping(address => userData) user;

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
        genesisBlock = block.timestamp;
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

    function getUserData(address account) public view returns
    (   uint256 balance_,
        uint256 unclaimROI_,
        uint256 commission_,
        uint256 withdraw_,
        uint256 actionBlock_,
        address referral_,
        bool registered_
    ) {
        return (
            user[account].balance,
            user[account].unclaimROI,
            user[account].commission,
            user[account].withdraw,
            user[account].actionBlock,
            user[account].referral,
            user[account].registered
        );
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
        //autoLiquidity(getFeeAmount(msg.value,depositFeeToSwap,denominator));
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

    function isTopWinner(address account,uint256 round) internal view returns (bool,uint256) {
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
        uint256 rewardToBeClaim = top3[round].reward * topWinnerReward[index] / denominator;
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
        if(user[account].actionBlock>0){
            uint256 period = block.timestamp - user[account].actionBlock;
            uint256 ROI = user[account].balance * getROI(account) / denominator;
            uint256 reward = ROI * period / day;
            return getNonOverpayAmount(account,reward);
        }
        return 0;
    }

    function getNonOverpayAmount(address account,uint256 amount) internal view returns (uint256) {
        if(getLimitAmount(account) + amount > getMaxEarnAmount(account)){
            return getMaxEarnAmount(account) - getLimitAmount(account);
        }
        return amount;
    }

    function getMaxEarnAmount(address account) internal view returns (uint256) {
        return user[account].balance * maxProfitPercent / 10000;
    }

    function getLimitAmount(address account) internal view returns (uint256) {
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

    function updateGenesisBlock(uint256 blockstamp) public onlyOwner returns (bool) {
        genesisBlock = blockstamp;
        return true;
    }

    function updateMinimumDeposit(uint256 amountETH) public onlyOwner returns (bool) {
        minimumDeposit = amountETH;
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

    function getWithdrawFee(uint256 amount) internal view returns (uint256) {
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