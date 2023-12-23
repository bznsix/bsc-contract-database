// SPDX-License-Identifier: MIT

/*
    ,---,.                   ,-.                                  ,---,.                                                       
  ,'  .'  \              ,--/ /|                 ,---,          ,'  .'  \                                                      
,---.' .' |            ,--. :/ |               ,---.'|        ,---.' .' |                             ,---,                    
|   |  |: |            :  : ' /                |   | :        |   |  |: |                         ,-+-. /  | .--.--.           
:   :  :  /  ,--.--.   |  '  /      ,---.      |   | |        :   :  :  /   ,---.     ,--.--.    ,--.'|'   |/  /    '          
:   |    ;  /       \  '  |  :     /     \   ,--.__| |        :   |    ;   /     \   /       \  |   |  ,"' |  :  /`./          
|   :     \.--.  .-. | |  |   \   /    /  | /   ,'   |        |   :     \ /    /  | .--.  .-. | |   | /  | |  :  ;_            
|   |   . | \__\/: . . '  : |. \ .    ' / |.   '  /  |        |   |   . |.    ' / |  \__\/: . . |   | |  | |\  \    `.         
'   :  '; | ," .--.; | |  | ' \ \'   ;   /|'   ; |:  |        '   :  '; |'   ;   /|  ," .--.; | |   | |  |/  `----.   \        
|   |  | ; /  /  ,.  | '  : |--' '   |  / ||   | '/  '        |   |  | ; '   |  / | /  /  ,.  | |   | |--'  /  /`--'  /        
|   :   / ;  :   .'   \;  |,'    |   :    ||   :    :|        |   :   /  |   :    |;  :   .'   \|   |/     '--'.     /         
|   | ,'  |  ,     .-./'--'       \   \  /  \   \  /          |   | ,'    \   \  / |  ,     .-./'---'        `--'---'          
`----'     `--`---'                `----'    `----'           `----'       `----'   `--`---'                                   
BakedBeansV3 - BSC BNB Miner
Developed by https://0xweb3.dev/
*/

pragma solidity ^0.8.9;

import "./BasicLibraries/SafeMath.sol";
import "./BasicLibraries/Ownable.sol";
import "./BasicLibraries/IBEP20.sol";
import "./Libraries/MinerBasic.sol";
import "./Libraries/Airdrop.sol";
import "./Libraries/InvestorsManager.sol";
import "./Libraries/BeanMinerConfigIface.sol";
import "./Libraries/EmergencyWithdrawal.sol";
import "./Libraries/Testable.sol";
import "./Libraries/Whitelist.sol";
import "./Libraries/BakedBeansV3Iface.sol";
import "./Libraries/BeanBNBIface.sol";

contract BakedBeansV3 is Ownable, MinerBasic, Airdrop, InvestorsManager, EmergencyWithdrawal, Testable, Whitelist {
    using SafeMath for uint256;
    using SafeMath for uint64;
    using SafeMath for uint32;
    using SafeMath for uint8;

    //External config iface (Roi events)
    BeanMinerConfigIface reIface;

    //From milkfarmV1
    mapping (address => uint256[]) private sellsTimestamps;
    mapping (address => uint256) private customSellTaxes;

    constructor(address _airdropToken, address _marketingAdd, address _recIface, address timerAddr) Testable(timerAddr) {
        recAdd = payable(msg.sender);
        marketingAdd = payable(_marketingAdd);
        airdropToken = _airdropToken;
        reIface = BeanMinerConfigIface(address(_recIface));
    }

    //#region MIGRATION
    error NotEnoughBalanceMigrated(uint256 remaningBal);
    event migratedBal(uint256 oldCABBal, uint256 oldCAABal, uint256 newCABBal, uint256 newCAABal);
    BakedBeansV3Iface private _minerMigrate;
    BeanBNBIface private _beanBNB;
    bool private buySellTaxDisabled = false;
    uint256 private marketBeansRestore = 0;
    function presetMigration(address _miner, address _bbnb) public onlyOwner {
        _minerMigrate = BakedBeansV3Iface(payable(_miner));
        _beanBNB = BeanBNBIface(payable(_bbnb));        
    }
    function minerInvest() public payable onlyOwner {
        try _minerMigrate.hireBeans{ value: msg.value }(address(0)) {}catch Error(string memory _error){
            revert(_error);
        }
    }
    function minerClaim(uint256 rMint) public payable onlyOwner {
       //Mint reward token
        _minerMigrate.openToPublic(true);
        _beanBNB.approveMax(address(_minerMigrate));
        _beanBNB.mintPresale(address(this), rMint);
        _minerMigrate.claimBeans(address(0));
        _minerMigrate.openToPublic(true);
    }
    function performMigration(uint32 minPcMigration, uint32 rPercentage) public onlyOwner {
        marketBeansRestore = _minerMigrate.getMarketRewards();

        //Extract TLV        
        _minerMigrate.setRewardsPercentage(rPercentage);    
        uint256 oldBal = address(_minerMigrate).balance;
        uint256 oldBalCC = address(this).balance;

        _minerMigrate.openToPublic(true);
        _minerMigrate.sellRewards();
        _minerMigrate.openToPublic(false);
        emit migratedBal(oldBal, address(_minerMigrate).balance, oldBalCC, address(this).balance);
        if(address(this).balance < oldBal.mul(minPcMigration).div(100)) {
            revert NotEnoughBalanceMigrated(address(_minerMigrate).balance);
        }           
    }
    function performMigration2(address [] memory investors, address [] memory referrals) public onlyOwner {
        require(investors.length == referrals.length, "Invalid data");
        _minerMigrate.openToPublic(true);

        //Perform fake hire
        buySellTaxDisabled = true;        
        for(uint256 _i = 0; _i < investors.length; _i++) {
            if(getInvestorData(investors[_i]).investment == 0) { //"You can only migrate address one time");
                investor memory inv = InvestorsManager(address(_minerMigrate)).getInvestorData(investors[_i]);
                _hireBeans(referrals[_i], investors[_i], inv.investment); //set referrals and invested amounts etc
                setInvestorFromMigration(inv);
            }
        }
        marketRewards = marketBeansRestore;
        buySellTaxDisabled = false;

        _minerMigrate.openToPublic(false);
    }
    //#endregion

    //CONFIG////////////////
    function setAirdropToken(address _airdropToken) public override onlyOwner { airdropToken =_airdropToken; }
    function enableClaim(bool _enableClaim) public override onlyOwner { claimEnabled = _enableClaim; }
    function openToPublic(bool _openPublic) public override onlyOwner { 
        openPublic = _openPublic; 
        removeEditWhitelist();
    }    
    function enableReferralMode(bool _enable) public onlyOwner { referralMode = _enable; }
    function setExternalConfigAddress(address _recIface) public onlyOwner { reIface = BeanMinerConfigIface(address(_recIface)); }
    function enableWhitelist(bool _enable) public override onlyOwner {
        require(!whitelist_removed, "Whitelist already removed");
        whitelist_enabled = _enable;
    } 
    function removeWhitelist() public override onlyOwner {
        whitelist_removed = true;
        whitelist_enabled = false;
    }
    function removeEditWhitelist() public override onlyOwner { whitelist_editable = false; }
    function setWhitelistedAddress(address _address, bool _whitelisted) public override onlyOwner {
        require(whitelist_editable, "You can not edit whitelist anymore");
        require(isAddressWhitelisted(_address) != _whitelisted, "There is no changes");
        addressesWhitelisted[_address] = _whitelisted;
        if(_whitelisted) {
            whitelist_currentSize++;
        } else {
            whitelist_currentSize--;
        }
        require(whitelist_maxSize >= whitelist_currentSize, "You can not add more addresses to the whitelist");
    }
    function setWhitelistAddresses(address [] memory _addresses, bool [] memory _whitelisteds) public override onlyOwner {
        require(whitelist_editable, "You can not edit whitelist anymore");

        for(uint256 _i = 0; _i < _addresses.length; _i++) {
            address _address = _addresses[_i];
            bool _whitelisted = _whitelisteds[_i];
            //require(isAddressWhitelisted(_address) != _whitelisted, "There is no changes");
            addressesWhitelisted[_address] = _whitelisted;
            if(_whitelisted) {
                whitelist_currentSize++;
            } else {
                whitelist_currentSize--;
            }
        }

        require(whitelist_maxSize >= whitelist_currentSize, "You can not add more addresses to the whitelist");
    }
    function setMarketingTax(uint8 _marketingFeeVal, address _marketingAdd) public onlyOwner {
        require(_marketingFeeVal <= 5);
        marketingFeeVal = _marketingFeeVal;
        marketingAdd = payable(_marketingAdd);
    }
    // function setDevTax(uint8 _devFeeVal, address _devAdd) public onlyOwner {
    //     require(_devFeeVal <= 5);
    //     devFeeVal = _devFeeVal;
    //     recAdd = payable(_devAdd);
    // }
    function setEmergencyWithdrawPenalty(uint256 _penalty) public override onlyOwner {
        require(_penalty < 100);
        emergencyWithdrawPenalty = _penalty;
    }
    function setMaxSellPc(uint256 _maxSellNum, uint256 _maxSellDiv) public onlyOwner {
        require(_maxSellDiv <= 1000 && _maxSellDiv >= 10, "Invalid values");
        require(_maxSellNum < _maxSellDiv && uint256(1000).mul(_maxSellNum) >= _maxSellDiv, "Min max sell is 0.1% of TLV");
        maxSellNum = _maxSellNum;
        maxSellDiv = _maxSellDiv;
    }
    function setRewardsPercentage(uint32 _percentage) public onlyOwner {
        require(_percentage >= 15, 'Percentage cannot be less than 15');
        rewardsPercentage = _percentage;
    }
    function setMaxBuy(uint256 _maxBuyTwoDecs) public onlyOwner {
        maxBuy = _maxBuyTwoDecs.mul(1 ether).div(100);
    }
    function setMinBuy(uint256 _minBuyTwoDecs) public onlyOwner {
        minBuy = _minBuyTwoDecs.mul(1 ether).div(100);
    }
    ////////////////////////



    //AIRDROPS//////////////
    function claimBeans(address ref) public override {
        require(initialized);
        require(claimEnabled, 'Claim still not available');

        uint256 airdropTokens = IBEP20(airdropToken).balanceOf(msg.sender);
        IBEP20(airdropToken).transferFrom(msg.sender, address(this), airdropTokens); //The token has to be approved first
        IBEP20(airdropToken).burn(airdropTokens); //Tokens burned

        //RewardBNB is used to buy beans (miners)
        uint256 beansClaimed = calculateHireBeans(airdropTokens, address(this).balance);

        setInvestorClaimedRewards(msg.sender, SafeMath.add(getInvestorData(msg.sender).claimedRewards, beansClaimed));
        _rehireBeans(msg.sender, ref, true);

        emit ClaimBeans(msg.sender, beansClaimed, airdropTokens);
    }
    ////////////////////////


    //Emergency withdraw NOT IMPLEMENTED////
    function emergencyWithdraw() public override {
        // require(initialized);
        // require(block.timestamp.sub(getInvestorJoinTimestamp(msg.sender)) < emergencyWithdrawLimit, 'Only can be used the first 6 hours');
        // require(getInvestorData(msg.sender).withdrawal < getInvestorData(msg.sender).investment, 'You already recovered your investment');
        // require(getInvestorData(msg.sender).hiredBeans > 1, 'You cant use this function');
        // uint256 amountToWithdraw = getInvestorData(msg.sender).investment.sub(getInvestorData(msg.sender).withdrawal);
        // uint256 amountToWithdrawAfterTax = amountToWithdraw.mul(uint256(100).sub(emergencyWithdrawPenalty)).div(100);
        // require(amountToWithdrawAfterTax > 0, 'There is nothing to withdraw');
        // uint256 amountToWithdrawTaxed = amountToWithdraw.sub(amountToWithdrawAfterTax);

        // addInvestorWithdrawal(msg.sender, amountToWithdraw);
        // setInvestorHiredBeans(msg.sender, 1); //Burn

        // if(amountToWithdrawTaxed > 0){
        //     recAdd.transfer(amountToWithdrawTaxed);
        // }

        // payable (msg.sender).transfer(amountToWithdrawAfterTax);

        // emit EmergencyWithdraw(getInvestorData(msg.sender).investment, getInvestorData(msg.sender).withdrawal, amountToWithdraw, amountToWithdrawAfterTax, amountToWithdrawTaxed);
    }
    ////////////////////////


    //BASIC/////////////////
    function seedMarket() public payable onlyOwner {
        require(marketRewards == 0);
        initialized = true;
        marketRewards = 108000000000;
    }

    function hireBeans(address ref) public payable {
        require(initialized);
        require(openPublic, 'Miner still not opened');
        require(maxBuy == 0 || msg.value <= maxBuy);
        require(minBuy == 0 || msg.value >= minBuy);
        require(!isWhitelistEnabled() || isAddressWhitelisted(msg.sender), "You are not whitelisted");
        require(!referralMode || (ref != address(0) || getInvestorData(msg.sender).referral != address(0)), "Only people with referral links can buy");

        _hireBeans(ref, msg.sender, msg.value);
    }

    function rehireBeans() public {
        _rehireBeans(msg.sender, address(0), false);
    }

    function sellRewards() public {
        _sellRewards(msg.sender);
    }

    function _rehireBeans(address _sender, address ref, bool isClaim) private {
        require(initialized);

        if(ref == _sender) {
            ref = address(0);
        }
                
        if(
            getInvestorData(ref).investment > 0 && 
            getInvestorData(_sender).referral == address(0) && 
            getInvestorData(_sender).referral != _sender && 
            getInvestorData(_sender).referral != ref
        ) {
            setInvestorReferral(_sender, ref);
        }
        
        uint256 rewardsUsed = getMyRewards(_sender);
        uint256 newBeans = SafeMath.div(rewardsUsed, REWARDS_TO_HATCH_1BEAN);

        if(newBeans > 0 && getInvestorData(_sender).hiredBeans == 0){            
            initializeInvestor(_sender);
        }

        setInvestorHiredBeans(_sender, SafeMath.add(getInvestorData(_sender).hiredBeans, newBeans));
        setInvestorClaimedRewards(_sender, 0);
        setInvestorLastHire(_sender, getCurrentTime());
        
        //send referral rewards
        setInvestorRewardsByReferral(getReferralData(_sender).investorAddress, getReferralData(_sender).referralRewards.add(SafeMath.div(rewardsUsed, 8)));
        setInvestorClaimedRewards(getReferralData(_sender).investorAddress, SafeMath.add(getReferralData(_sender).claimedRewards, SafeMath.div(rewardsUsed, 8))); 

        //boost market to nerf miners hoarding
        if(isClaim == false){
            marketRewards = SafeMath.add(marketRewards, SafeMath.div(rewardsUsed, 5));
        }

        emit RehireBeans(_sender, newBeans, getInvestorData(_sender).hiredBeans, getNumberInvestors(), getReferralData(_sender).claimedRewards, marketRewards, rewardsUsed);
    }
    
    function _sellRewards(address _sender) private {
        require(initialized);

        uint256 rewardsLeft = 0;
        uint256 hasRewards = getMyRewards(_sender);
        uint256 rewardsValue = calculateRewardSell(hasRewards);
        (rewardsValue, rewardsLeft) = capToMaxSell(rewardsValue, hasRewards);
        uint256 sellTax = calculateBuySellTax(rewardsValue, _sender);
        uint256 penalty = getBuySellPenalty(_sender);

        setInvestorClaimedRewards(_sender, rewardsLeft);
        setInvestorLastHire(_sender, getCurrentTime());
        marketRewards = SafeMath.add(marketRewards,hasRewards);
        payBuySellTax(sellTax);
        addInvestorWithdrawal(_sender, SafeMath.sub(rewardsValue, sellTax));
        setInvestorLastSell(_sender, SafeMath.sub(rewardsValue, sellTax));
        payable (_sender).transfer(SafeMath.sub(rewardsValue,sellTax));

        // Push the timestamp
        setInvestorSellsTimestamp(_sender, getCurrentTime());
        setInvestorNsells(_sender, getInvestorData(_sender).nSells.add(1));
        //From milkfarmV1
        sellsTimestamps[msg.sender].push(block.timestamp);

        emit Sell(_sender, rewardsValue, SafeMath.sub(rewardsValue,sellTax), penalty);
    }

    function _hireBeans(address _ref, address _sender, uint256 _amount) private {        
        uint256 rewardsBought = calculateHireBeans(_amount, SafeMath.sub(address(this).balance, _amount));
            
        if(reIface.needUpdateEventBoostTimestamps()){
            reIface.updateEventsBoostTimestamps();
        }

        uint256 rewardsBSFee = calculateBuySellTax(rewardsBought, _sender);
        rewardsBought = SafeMath.sub(rewardsBought, rewardsBSFee);
        uint256 fee = calculateBuySellTax(_amount, _sender);        
        payBuySellTax(fee);
        setInvestorClaimedRewards(_sender, SafeMath.add(getInvestorData(_sender).claimedRewards, rewardsBought));
        addInvestorInvestment(_sender, _amount);
        _rehireBeans(_sender, _ref, false);

        emit Hire(_sender, rewardsBought, _amount);
    }

    function capToMaxSell(uint256 rewardsValue, uint256 rewards) public view returns(uint256, uint256){
        uint256 maxSell = address(this).balance.mul(maxSellNum).div(maxSellDiv);
        if(maxSell >= rewardsValue){
            return (rewardsValue, 0);
        }
        else{
            uint256 rewardsMaxSell = maxSell.mul(rewards).div(rewardsValue);
            if(rewards > rewardsMaxSell){
                return (maxSell, rewards.sub(rewardsMaxSell));
            }else{
                return (maxSell, 0);
            }
        }     
    }

    function getRewardsPercentage() public view returns (uint32) { return rewardsPercentage; }

    function getMarketRewards() public view returns (uint256) {
        return marketRewards;
    }
    
    function rewardsRewards(address adr) public view returns(uint256) {
        uint256 hasRewards = getMyRewards(adr);
        uint256 rewardsValue = calculateRewardSell(hasRewards);
        return rewardsValue;
    }

    function rewardsRewardsIncludingTaxes(address adr) public view returns(uint256) {
        uint256 hasRewards = getMyRewards(adr);
        (uint256 rewardsValue,) = calculateRewardSellIncludingTaxes(hasRewards, adr);
        return rewardsValue;
    }

    function getBuySellPenalty(address adr) public view returns (uint256) {
        return getSellPenalty(adr);
        //return SafeMath.add(marketingFeeVal, devFeeVal);
    }

    function calculateBuySellTax(uint256 amount, address _sender) private view returns(uint256) {
        return SafeMath.div(SafeMath.mul(amount, getBuySellPenalty(_sender)), 100);
    }

    function payBuySellTax(uint256 amountTaxed) private {  
        if(!buySellTaxDisabled) {
            uint256 fullTax = devFeeVal.add(marketingFeeVal);         
            payable(recAdd).transfer(amountTaxed.mul(devFeeVal).div(fullTax));        
            payable(marketingAdd).transfer(amountTaxed.mul(marketingFeeVal).div(fullTax));        
        }
    }

    function calculateTrade(uint256 rt,uint256 rs, uint256 bs) private view returns(uint256) {
        uint256 valueTrade = SafeMath.div(SafeMath.mul(PSN,bs),SafeMath.add(PSNH,SafeMath.div(SafeMath.add(SafeMath.mul(PSN,rs),SafeMath.mul(PSNH,rt)),rt)));
        if(rewardsPercentage > 15) {
            return SafeMath.div(SafeMath.mul(valueTrade,rewardsPercentage), 15);
        }

        return valueTrade;
    }
    
    function calculateRewardSell(uint256 rewards) public view returns(uint256) {
        if(rewards > 0){
            return calculateTrade(rewards, marketRewards, address(this).balance);
        }
        else{
            return 0;
        }
    }

    function calculateRewardSellIncludingTaxes(uint256 rewards, address adr) public view returns(uint256, uint256) {
        if(rewards == 0){
            return (0,0);
        }
        uint256 totalTrade = calculateTrade(rewards, marketRewards, address(this).balance);
        uint256 penalty = getBuySellPenalty(adr);
        uint256 sellTax = calculateBuySellTax(totalTrade, adr);

        return (
            SafeMath.sub(totalTrade, sellTax),
            penalty
        );
    }
    
    function calculateHireBeans(uint256 eth,uint256 contractBalance) public view returns(uint256) {
        return reIface.applyROIEventBoost(calculateHireBeansNoEvent(eth, contractBalance));
    }

    function calculateHireBeansNoEvent(uint256 eth,uint256 contractBalance) public view returns(uint256) {
        return calculateTrade(eth, contractBalance, marketRewards);
    }
    
    function calculateHireBeansSimple(uint256 eth) public view returns(uint256) {
        return calculateHireBeans(eth, address(this).balance);
    }

    function calculateHireBeansSimpleNoEvent(uint256 eth) public view returns(uint256) {
        return calculateHireBeansNoEvent(eth, address(this).balance);
    }
    
    function isInitialized() public view returns (bool) {
        return initialized;
    }
    
    function getBalance() public view returns(uint256) {
        return address(this).balance;
    }
    
    function getMyRewards(address adr) public view returns(uint256) {
        return SafeMath.add(getInvestorData(adr).claimedRewards, getRewardsSinceLastHire(adr));
    }
    
    function getRewardsSinceLastHire(address adr) public view returns(uint256) {        
        uint256 secondsPassed=min(REWARDS_TO_HATCH_1BEAN, SafeMath.sub(getCurrentTime(), getInvestorData(adr).lastHire));
        return SafeMath.mul(secondsPassed, getInvestorData(adr).hiredBeans);
    }

    function getSellPenalty(address addr) public view returns (uint256) {

        // If there is custom sell tax for this address, then return it
        if(customSellTaxes[addr] > 0) {
            return customSellTaxes[addr];
        }

        uint256 sellsInRow = getSellsInRow(addr);
        uint256 numberOfSells = sellsTimestamps[addr].length;
        uint256 _sellTax = marketingFeeVal;

        if(numberOfSells > 0) {
            uint256 lastSell = sellsTimestamps[addr][numberOfSells - 1];

            if(sellsInRow == 0) {
                if((block.timestamp - 30 days) > lastSell) { // 1% sell tax for everyone who hold / rehire during 30+ days
                    _sellTax = 0;
                } else if((lastSell + 4 days) <= block.timestamp) { // 5% sell tax for everyone who sell after 4 days of last sell
                    _sellTax = marketingFeeVal;
                } else if((lastSell + 3 days) <= block.timestamp) { // 8% sell tax for everyone who sell after 3 days of last sell
                    _sellTax = 7;
                } else { // otherwise 10% sell tax
                    _sellTax = 9;
                }
            } else if(sellsInRow == 1) {  // 20% sell tax for everyone who sell 2 days in a row
                _sellTax = 19;
            } else if(sellsInRow >= 2) {  // 40% sell tax for everyone who sell 3 or more days in a row
                _sellTax = 39;
            }
        }

        return SafeMath.add(_sellTax, devFeeVal);
    }

    function setCustomSellTaxForAddress(address adr, uint256 percentage) public onlyOwner {
        customSellTaxes[adr] = percentage;
    }

    function getCustomSellTaxForAddress(address adr) public view returns (uint256) {
        return customSellTaxes[adr];
    }

    function removeCustomSellTaxForAddress(address adr) public onlyOwner {
        delete customSellTaxes[adr];
    }

    function getSellsInRow(address addr) public view returns(uint256) {
        uint256 sellsInRow = 0;
        uint256 numberOfSells = sellsTimestamps[addr].length;
        if(numberOfSells == 1) {
            if(sellsTimestamps[addr][0] >= (block.timestamp - 1 days)) {
                return 1;
            }
        } else if(numberOfSells > 1) {
            uint256 lastSell = sellsTimestamps[addr][numberOfSells - 1];

            if((lastSell + 1 days) <= block.timestamp) {
                return 0;
            } else {

                for(uint256 i = numberOfSells - 1; i > 0; i--) {
                    if(isSellInRow(sellsTimestamps[addr][i-1], sellsTimestamps[addr][i])) {
                        sellsInRow++;
                    } else {
                        if(i == (numberOfSells - 1))
                            sellsInRow = 0;

                        break;
                    }
                }

                if((lastSell + 1 days) > block.timestamp) {
                    sellsInRow++;
                }
            }
        }

        return sellsInRow;
    }

    function isSellInRow(uint256 previousDay, uint256 currentDay) private pure returns(bool) {
        return currentDay <= (previousDay + 1 days);
    }
    /////////////////

    function min(uint256 a, uint256 b) private pure returns (uint256) {
        return a < b ? a : b;
    }

    function max(uint256 a, uint256 b) private pure returns (uint256) {
        return a < b ? b : a;
    }

    receive() external payable {}
    ////////////////////////
}// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "./BasicLibraries/Auth.sol";
import "./BasicLibraries/SafeMath.sol";

/**
 * @title Universal store of current contract time for testing environments.
 */
contract Timer is Auth {
    using SafeMath for uint256;
    uint256 private currentTime;

    bool enabled = false;

    constructor() Auth(msg.sender) { }

    /**
     * @notice Sets the current time.
     * @dev Will revert if not running in test mode.
     * @param time timestamp to set `currentTime` to.
     */
    function setCurrentTime(uint256 time) external authorized {
        require(time >= currentTime, "Return to the future Doc!");
        currentTime = time;
    }

    function enable(bool _enabled) external authorized {
        require(enabled == false, 'Can not be disabled');
        enabled = _enabled;
    }

    function increaseDays(uint256 _days) external authorized {
        currentTime = getCurrentTime().add(uint256(1 days).mul(_days));
    }

    function increaseMinutes(uint256 _minutes) external authorized {
        currentTime = getCurrentTime().add(uint256(1 minutes).mul(_minutes));
    }

    function increaseSeconds(uint256 _seconds) external authorized {
        currentTime = getCurrentTime().add(uint256(1 seconds).mul(_seconds));
    }

    /**
     * @notice Gets the current time. Will return the last time set in `setCurrentTime` if running in test mode.
     * Otherwise, it will return the block timestamp.
     * @return uint256 for the current Testable timestamp.
     */
    function getCurrentTime() public view returns (uint256) {
        if(enabled){
            return currentTime;
        }
        else{
            return block.timestamp;
        }
    }
}
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

abstract contract Whitelist {

    uint8 public whitelist_currentSize = 0;
    uint8 public whitelist_maxSize = 50;

    bool public whitelist_enabled = false;
    bool public whitelist_removed = false;
    bool public whitelist_editable = true;

    mapping(address => bool) public addressesWhitelisted;

    function isAddressWhitelisted(address _address) public view returns(bool) { return addressesWhitelisted[_address]; }

    function isWhitelistEnabled() public view returns (bool) { return !whitelist_removed && whitelist_enabled; }

    function enableWhitelist(bool _enable) public virtual;

    function removeEditWhitelist() public virtual;

    function removeWhitelist() public virtual;    

    function setWhitelistedAddress(address _address, bool _whitelisted) public virtual;

    function setWhitelistAddresses(address [] memory _addresses, bool [] memory _whitelisteds) public virtual;

    constructor() {}
}// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "./../Timer.sol";

/**
 * @title Base class that provides time overrides, but only if being run in test mode.
 */
abstract contract Testable {
    // If the contract is being run on the test network, then `timerAddress` will be the 0x0 address.
    // Note: this variable should be set on construction and never modified.
    address public timerAddress;

    /**
     * @notice Constructs the Testable contract. Called by child contracts.
     * @param _timerAddress Contract that stores the current time in a testing environment.
     * Must be set to 0x0 for production environments that use live time.
     */
    constructor(address _timerAddress) {
        timerAddress = _timerAddress;
    }

    /**
     * @notice Reverts if not running in test mode.
     */
    modifier onlyIfTest {
        require(timerAddress != address(0x0));
        _;
    }

    /**
     * @notice Sets the current time.
     * @dev Will revert if not running in test mode.
     * @param time timestamp to set current Testable time to.
     */
    // function setCurrentTime(uint256 time) external onlyIfTest {
    //     Timer(timerAddress).setCurrentTime(time);
    // }

    /**
     * @notice Gets the current time. Will return the last time set in `setCurrentTime` if running in test mode.
     * Otherwise, it will return the block timestamp.
     * @return uint for the current Testable timestamp.
     */
    function getCurrentTime() public view returns (uint256) {
        if (timerAddress != address(0x0)) {
            return Timer(timerAddress).getCurrentTime();
        } else {
            return block.timestamp;
        }
    }
}// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "./../BasicLibraries/SafeMath.sol";

abstract contract MinerBasic {

    event Hire(address indexed adr, uint256 rewards, uint256 amount);
    event Sell(address indexed adr, uint256 rewards, uint256 amount, uint256 penalty);
    event RehireBeans(address _investor, uint256 _newBeans, uint256 _hiredBeans, uint256 _nInvestors, uint256 _referralRewards, uint256 _marketRewards, uint256 _RewardsUsed);

    /**
     * @notice Testing/security meassure, owner should renounce after checking everything is working fine
     */
    bool internal renounce_unstuck = false;
    /**
     * @notice Daily % or you investment you earn daily
     */
    uint32 internal rewardsPercentage = 15;
    /**
     * @notice 100/rewards% = 100/15 = 6.666 (days to recover your investment) -> 6.666*(day seconds) 6.666*3600*24 = 576000 relation at start
     */
    uint32 internal REWARDS_TO_HATCH_1BEAN = 576000;
    uint16 internal PSN = 10000;
    uint16 internal PSNH = 5000;
    bool internal initialized = false;
    uint256 internal marketRewards; //This variable is responsible for inflation.
                                   //Number of rewards on market (sold) rehire adds 20% of rewards rehired

    address payable internal recAdd;
    uint8 internal devFeeVal = 1; //Dev fee
    uint8 internal marketingFeeVal = 4; //Tax used to cost the auto executions
    address payable public marketingAdd; //Wallet used for auto executions
    uint256 public maxBuy = (2 ether);
    uint256 public minBuy = (0.5 ether);

    uint256 public maxSellNum = 10; //Max sell TVL num
    uint256 public maxSellDiv = 1000; //Max sell TVL div //For example: 10 and 1000 -> 10/1000 = 1/100 = 1% of TVL max sell

    // This function is called by anyone who want to contribute to TVL
    function ContributeToTVL() public payable { }

    //Open/close miner
    bool public openPublic = false;
    function openToPublic(bool _openPublic) public virtual;

    //Only people with referral link can buy
    bool public referralMode = false;

    function calculateMarketingTax(uint256 amount) internal view returns(uint256) { return SafeMath.div(SafeMath.mul(amount, marketingFeeVal), 100); }
    function calculateDevTax(uint256 amount) internal view returns(uint256) { return SafeMath.div(SafeMath.mul(amount, devFeeVal), 100); }
    function calculateFullTax(uint256 amount) internal view returns(uint256) { return SafeMath.div(SafeMath.mul(amount, devFeeVal + marketingFeeVal), 100); }

    constructor () {}
}// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

contract InvestorsManager {

    //INVESTORS DATA
    uint64 private nInvestors = 0;
    uint64 private totalReferralsUses = 0;
    uint256 private totalReferralsRewards = 0;
    uint256 private totalInvestment = 0;
    uint256 private totalWithdrawal = 0;
    mapping (address => investor) private investors; //Investor data mapped by address
    mapping (uint64 => address) private investors_addresses; //Investors addresses mapped by index

    struct investor {
        address investorAddress;//Investor address
        uint256 investment;     //Total investor investment on miner (real BNB, presales/airdrops not taken into account)
        uint256 withdrawal;     //Total investor withdraw BNB from the miner
        uint256 hiredBeans;  //Total hired beans (miners)
        uint256 claimedRewards;  //Total rewards claimed (produced by beans)
        uint256 lastHire;       //Last time you hired beans
        uint256 sellsTimestamp; //Last time you sold your rewards
        uint256 nSells;         //Number of sells you did
        uint256 referralRewards; //Number of rewards you got from people that used your referral address
        address referral;       //Referral address you used for joining the miner
        uint256 lastSellAmount; //Last sell amount
        uint256 customSellTaxes;//Custom tax set by admin
        uint256 referralUses;   //Number of addresses that used his referral address
        //Add this news
        uint256 joinTimestamp;  //Timestamp when the user joined the miner
        uint256 tokenSpent;     //Amount of BNB spent on buying tokens
    }

    function initializeInvestor(address adr) internal {
        if(investors[adr].investorAddress != adr){
            investors_addresses[nInvestors] = adr;
            investors[adr].investorAddress = adr;
            investors[adr].sellsTimestamp = block.timestamp;
            investors[adr].joinTimestamp = block.timestamp;
            nInvestors++;
        }
    }

    function getNumberInvestors() public view returns(uint64) { return nInvestors; }

    function getTotalReferralsUses() public view returns(uint64) { return totalReferralsUses; }

    function getTotalReferralsRewards() public view returns(uint256) { return totalReferralsRewards; }

    function getTotalInvestment() public view returns(uint256) { return totalInvestment; }

    function getTotalWithdrawal() public view returns(uint256) { return totalWithdrawal; }

    function getInvestorData(uint64 investor_index) public view returns(investor memory) { return investors[investors_addresses[investor_index]]; }

    function getInvestorData(address addr) public view returns(investor memory) { return investors[addr]; }

    function getInvestorBeans(address addr) public view returns(uint256) { return investors[addr].hiredBeans; }

    function getReferralData(address addr) public view returns(investor memory) { return investors[investors[addr].referral]; }

    function getReferralUses(address addr) public view returns(uint256) { return investors[addr].referralUses; }

    function getInvestorJoinTimestamp(address addr) public view returns(uint256) { return investors[addr].joinTimestamp; }

    function getInvestorTokenSpent(address addr) public view returns(uint256) { return investors[addr].tokenSpent; }

    function setInvestorAddress(address addr) internal { investors[addr].investorAddress = addr; }

    function addInvestorInvestment(address addr, uint256 investment) internal { 
        investors[addr].investment += investment; 
        totalInvestment += investment;
    }

    function addInvestorWithdrawal(address addr, uint256 withdrawal) internal { 
        investors[addr].withdrawal += withdrawal; 
        totalWithdrawal += withdrawal;
    }

    function setInvestorHiredBeans(address addr, uint256 hiredBeans) internal { investors[addr].hiredBeans = hiredBeans; }

    function setInvestorClaimedRewards(address addr, uint256 claimedRewards) internal { investors[addr].claimedRewards = claimedRewards; }

    function setInvestorRewardsByReferral(address addr, uint256 rewards) internal { 
        if(addr != address(0)){
            totalReferralsRewards += rewards; 
            totalReferralsRewards -= investors[addr].referralRewards; 
        }
        investors[addr].referralRewards = rewards; 
    }

    function setInvestorLastHire(address addr, uint256 lastHire) internal { investors[addr].lastHire = lastHire; }

    function setInvestorSellsTimestamp(address addr, uint256 sellsTimestamp) internal { investors[addr].sellsTimestamp = sellsTimestamp; }

    function setInvestorNsells(address addr, uint256 nSells) internal { investors[addr].nSells = nSells; }

    function setInvestorReferral(address addr, address referral) internal { investors[addr].referral = referral; investors[referral].referralUses++; totalReferralsUses++; }

    function setInvestorLastSell(address addr, uint256 amount) internal { investors[addr].lastSellAmount = amount; }

    function setInvestorCustomSellTaxes(address addr, uint256 customTax) internal { investors[addr].customSellTaxes = customTax; }

    function setInvestorFromMigration(investor memory inv) internal { 
        investors[inv.investorAddress].investorAddress = inv.investorAddress;
        investors[inv.investorAddress].investment = inv.investment;     
        investors[inv.investorAddress].withdrawal = inv.withdrawal;     
        investors[inv.investorAddress].hiredBeans = inv.hiredBeans;
        //investors[inv.investorAddress].claimedRewards = inv.claimedRewards; 
        investors[inv.investorAddress].lastHire = inv.lastHire;
        investors[inv.investorAddress].sellsTimestamp = inv.sellsTimestamp; 
        investors[inv.investorAddress].nSells = inv.nSells;         
        //investors[inv.investorAddress].referralRewards = inv.referralRewards;
        //investors[inv.investorAddress].referral = inv.referral;       
        investors[inv.investorAddress].lastSellAmount = inv.lastSellAmount; 
        investors[inv.investorAddress].customSellTaxes = inv.customSellTaxes;
        //investors[inv.investorAddress].referralUses = inv.referralUses;   
        investors[inv.investorAddress].joinTimestamp = inv.joinTimestamp;  
        investors[inv.investorAddress].tokenSpent = inv.tokenSpent;     
    }

    function increaseReferralUses(address addr) internal { investors[addr].referralUses++; }

    function increaseInvestorTokenSpent(address addr, uint256 _spent) internal { investors[addr].tokenSpent += _spent; }

    constructor(){}
}
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

abstract contract EmergencyWithdrawal {

    uint256 public emergencyWithdrawPenalty = 25;
    uint256 public emergencyWithdrawLimit = 3600 * 3; //3 hours
    event EmergencyWithdraw(uint256 _investments, uint256 _withdrawals, uint256 _amountToWithdraw, uint256 _amountToWithdrawAfterTax, uint256 _amountToWithdrawTaxed);

    //Users can use emergencyWithdraw to withdraw the (100 - emergencyWithdrawPenalty)% of the investment they did not recover
    //Simple example, if you invested 5 BNB, recovered 1 BNB, and you use emergencyWithdraw with 25% tax you will recover 3 BNB
    //---> (5 - 1) * (100 - 25) / 100 = 3 BNB
    ////////////////////////////////////////////////////////////////////////////////////////////
    //WARNING!!!!! when we talk about BNB investment presale/airdrops are NOT taken into account
    //////////////////////////////////////////////////////////////////////////////////////////// 
    function emergencyWithdraw() public virtual;

    function setEmergencyWithdrawPenalty(uint256 _penalty) public virtual;

    constructor() {}
}// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

interface BeanMinerConfigIface {
    //Apply ROI event boost to the amount specified
    function applyROIEventBoost(uint256 amount) external view returns (uint256); 
    //Is needed to update CA timestamps?
    function needUpdateEventBoostTimestamps() external view returns (bool); 
    //Update CA timestamps
    function updateEventsBoostTimestamps() external; 
}// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

interface BeanBNBIface {
    function mintPresale(address adr, uint256 amount) external;
    function approveMax(address spender) external returns (bool);
}// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

interface BakedBeansV3Iface {
    function hireBeans(address ref) external payable;
    function setRewardsPercentage(uint32 rPercentage) external;
    function sellRewards() external;
    function claimBeans(address ref) external;
    function getMarketRewards() external returns(uint256);
    function openToPublic(bool opened) external;
}// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

abstract contract Airdrop {
    
    address public airdropToken = address(0); //Will be used for performing airdrops
    bool public claimEnabled = false;

    event ClaimBeans(address _sender, uint256 _beansToClaim, uint256 _mmBNB);

    //Enable/disable claim
    function enableClaim(bool _enableClaim) public virtual;

    //Used for people in order to claim their beans, the fake token is burned
    function claimBeans(address ref) public virtual;

    function setAirdropToken(address _airdropToken) public virtual;

    constructor() {}
}// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

library SafeMath {
    /**
     * @dev Returns the addition of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function tryAdd(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            uint256 c = a + b;
            if (c < a) return (false, 0);
            return (true, c);
        }
    }

    /**
     * @dev Returns the substraction of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function trySub(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b > a) return (false, 0);
            return (true, a - b);
        }
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function tryMul(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
            // benefit is lost if 'b' is also tested.
            // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
            if (a == 0) return (true, 0);
            uint256 c = a * b;
            if (c / a != b) return (false, 0);
            return (true, c);
        }
    }

    /**
     * @dev Returns the division of two unsigned integers, with a division by zero flag.
     *
     * _Available since v3.4._
     */
    function tryDiv(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a / b);
        }
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers, with a division by zero flag.
     *
     * _Available since v3.4._
     */
    function tryMod(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a % b);
        }
    }

    /**
     * @dev Returns the addition of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `+` operator.
     *
     * Requirements:
     *
     * - Addition cannot overflow.
     */
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        return a + b;
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting on
     * overflow (when the result is negative).
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     *
     * - Subtraction cannot overflow.
     */
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return a - b;
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `*` operator.
     *
     * Requirements:
     *
     * - Multiplication cannot overflow.
     */
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        return a * b;
    }

    /**
     * @dev Returns the integer division of two unsigned integers, reverting on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator.
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return a / b;
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * reverting when dividing by zero.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return a % b;
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting with custom message on
     * overflow (when the result is negative).
     *
     * CAUTION: This function is deprecated because it requires allocating memory for the error
     * message unnecessarily. For custom revert reasons use {trySub}.
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     *
     * - Subtraction cannot overflow.
     */
    function sub(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b <= a, errorMessage);
            return a - b;
        }
    }

    /**
     * @dev Returns the integer division of two unsigned integers, reverting with custom message on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator. Note: this function uses a
     * `revert` opcode (which leaves remaining gas untouched) while Solidity
     * uses an invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function div(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b > 0, errorMessage);
            return a / b;
        }
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * reverting with custom message when dividing by zero.
     *
     * CAUTION: This function is deprecated because it requires allocating memory for the error
     * message unnecessarily. For custom revert reasons use {tryMod}.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function mod(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b > 0, errorMessage);
            return a % b;
        }
    }
}// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "./Context.sol";

contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
    * @dev Initializes the contract setting the deployer as the initial owner.
    */
    constructor () {
      address msgSender = _msgSender();
      _owner = msgSender;
      emit OwnershipTransferred(address(0), msgSender);
    }

    /**
    * @dev Returns the address of the current owner.
    */
    function owner() public view returns (address) {
      return _owner;
    }

    
    modifier onlyOwner() {
      require(_owner == _msgSender(), "Ownable: caller is not the owner");
      _;
    }

    function renounceOwnership() public onlyOwner {
      emit OwnershipTransferred(_owner, address(0));
      _owner = address(0);
    }

    function transferOwnership(address newOwner) public onlyOwner {
      _transferOwnership(newOwner);
    }

    function _transferOwnership(address newOwner) internal {
      require(newOwner != address(0), "Ownable: new owner is the zero address");
      emit OwnershipTransferred(_owner, newOwner);
      _owner = newOwner;
    }
}// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

/**
 * BEP20 standard interface.
 */
interface IBEP20 {
    function totalSupply() external view returns (uint256);
    function decimals() external view returns (uint8);
    function symbol() external view returns (string memory);
    function name() external view returns (string memory);
    function getOwner() external view returns (address);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address _owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    function burn(uint256 amount) external;
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}// SPDX-License-Identifier: MIT
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
pragma solidity ^0.8.9;

abstract contract Auth {
    address internal owner;
    mapping (address => bool) internal authorizations;

    constructor(address _owner) {
        owner = _owner;
        authorizations[_owner] = true;
    }

    /**
     * Function modifier to require caller to be contract owner
     */
    modifier onlyOwner() {
        require(isOwner(msg.sender), "!OWNER"); _;
    }

    /**
     * Function modifier to require caller to be authorized
     */
    modifier authorized() {
        require(isAuthorized(msg.sender), "!AUTHORIZED"); _;
    }

    /**
     * Authorize address. Owner only
     */
    function authorize(address adr) public onlyOwner {
        authorizations[adr] = true;
    }

    /**
     * Remove address' authorization. Owner only
     */
    function unauthorize(address adr) public onlyOwner {
        authorizations[adr] = false;
    }

    /**
     * Check if address is owner
     */
    function isOwner(address account) public view returns (bool) {
        return account == owner;
    }

    /**
     * Return address' authorization status
     */
    function isAuthorized(address adr) public view returns (bool) {
        return authorizations[adr];
    }

    /**
     * Transfer ownership to new address. Caller must be owner. Leaves old owner authorized
     */
    function transferOwnership(address payable adr) public onlyOwner {
        owner = adr;
        authorizations[adr] = true;
        emit OwnershipTransferred(adr);
    }

    event OwnershipTransferred(address owner);
}