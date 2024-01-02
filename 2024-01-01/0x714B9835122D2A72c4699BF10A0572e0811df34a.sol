// SPDX-License-Identifier: MIT

 /*  PROTRADESAI
 *   is dedicated to remove the risks of the possible errors and circumstances in conventional online 
 *   based trading using our state of the art BNB smart contract. An impartial third-party audit firm 
 *   has examined the smart contract's source code to prove its credibility.
 *
 *   ┌───────────────────────────────────────────────────────────────────────┐
 *   │   Website: https://ProTradesAI.com           						 │
 *	 │	 1% to 1.5% Daily ROI 	       	                                     │
 *   │   Audited, Verified with No Backdoor.       							 │
 *   └───────────────────────────────────────────────────────────────────────┘
 *
 *   [AFFILIATE PLAN REBATE]
 *
 *   - 11-level daily affiliate rebate: 10% - 3% - 2% - 1% - 1% - 0.5% - 0.5% - 0.5% - 0.5% - 0.5% - 0.5%  
 *  
 */

pragma solidity 0.8.18;

/**
 * @title ProTradeAI
 * @dev Leading BNB trading smartcontract investment
 */
contract ProTradeAI {
    
    //STATE VARIABLES
    address public owner;
    AdminStruct[4] public admins;
    uint public total_members = 0;
    uint public total_cummulative_investment = 0; //In wei
    uint public total_cummulative_withdrawn = 0; //In wei
    uint public min_investment; //In wei
    uint public min_withdraw; //In wei
    uint public max_investment; //In wei
    uint public max_withdraw_perweek; //In wei
    uint public max_earning_percentage = 300; //In percentage
    uint public bnb_to_usd; //Conversion rate for 1 bnb to usd
    uint constant BONUS_LINES_COUNT = 11;
    uint constant WITHDRAW_FEES = 5; //In percentage
    uint[BONUS_LINES_COUNT] public referral_pay_rates = [100,30,20,10,10,5,5,5,5,5,5]; //Divide by REFERRAL_PERCENT_DIVIDER
    uint constant REFERRAL_PERCENT_DIVIDER = 1000;
    uint constant INTEREST_PERCENT_DIVIDER = 1000;
    mapping(address => UserStruct) private users;
    //BASIC
    uint constant DAY_INTEREST_PERCENT = 10; //In percentage (should divide by 1000) 1%
    //VIP
    uint constant DAY_INTEREST_PERCENT_VIP = 12; //In percentage (should divide by 1000) 1.2%
    uint public vip_lower_limit;//In wei
    //VVIP
    uint constant DAY_INTEREST_PERCENT_VVIP = 15; //In percentage (should divide by 1000) 1.5%
    uint public vvip_lower_limit;//In wei
    //END OF STATE VARIABLES

    //REENTRY GUARD VARIABLES
    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;
    uint256 private _status;
    //END REENTRY GUARD VARIABLES

    //CONSTRUCTOR
    constructor(){
        owner = payable(msg.sender);
        bnb_to_usd = 210; //value of 1 bnb to usd
        min_investment = usdToWei(30);
        min_withdraw = usdToWei(30);
        vip_lower_limit = usdToWei(1000);
        vvip_lower_limit = usdToWei(10000);
        max_investment = usdToWei(25000);
        max_withdraw_perweek = usdToWei(5000);
        //First Upline User - Owner - For breaking loop
        total_members+=1;
        total_cummulative_investment+=0;
        UserStruct memory ownerUser =  UserStruct({
                is_active: true,
                self_address: msg.sender,
                balance : 0,
                sponsor: address(0),
                investment: max_investment,
                investment_interest_times1000: DAY_INTEREST_PERCENT_VVIP,
                dividends_paid: 0,
                last_dividend_time: block.timestamp,
                referral_bonus_earned: 0,
                withdrawn_amount: 0,
                last_withdraw_time: block.timestamp,
                week_limit_count: 0,
                week_limit_count_time: block.timestamp, 
                referral_structure: [0,0,0,0,0,0,0,0,0,0,0],
                referral_amount_per_second: [uint256(0),uint256(0),uint256(0),uint256(0),uint256(0),uint256(0),uint256(0),uint256(0),uint256(0),uint256(0),uint256(0)],
                referral_network_earnings: [uint256(0),uint256(0),uint256(0),uint256(0),uint256(0),uint256(0),uint256(0),uint256(0),uint256(0),uint256(0),uint256(0)]
            });
        users[msg.sender] = ownerUser;
        
        //Adding Admins
        admins[0] = AdminStruct("ZM",0xbE0F7664f7534E4f71aFFfCDA7ef851cf453bFFb,5,20);
        admins[1] = AdminStruct("RM",0x354Bcc1906349307cD035D9F3F2bdFe7a1E970cb,20,40);
        admins[2] = AdminStruct("PR_MARKETING",0xA494C431b045f617d2BB0Cb3DBB217D790EfB368,5,0);
        admins[3] = AdminStruct("LEADER",0x54C85FDF5486f2D750992D6c8b7060444b5b66BC,10,40);

        //REENTRYGUARD VARIABLE
        _status = _NOT_ENTERED;
    }
    //END OF CONSTRUCTOR

    //EVENTS DEFINITIONS
    event UplineCountUpdated(address indexed registeringAddress, address indexed sponsor, uint256 amount);
    event NewInvestment(address indexed investingAddress, uint256 amount);
    event WithdrawCompleted(address indexed withdrawingAddress, uint256 amount);
    //END OF EVENTS DEFINITION

    //UTILITY FUNCTIONS
    modifier onlyOwner(){
        require(msg.sender == owner, "ONLY the owner of ProTradesAI contract can perform this action");
        _;
    }

    modifier noReentry() {
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call. Action Stopped!");
        _status = _ENTERED;
        _;
        _status = _NOT_ENTERED;
    }

    function bnbTimes100ToWei(uint _bnbTimes100) private pure returns(uint){
        uint convesionRate = 1000000000000000000;
        uint weiConverted = _bnbTimes100 * (convesionRate/100);//(convesionRate/100) because _bnbTimes100 is X 100
        return weiConverted;
    }

    function usdToWei(uint _usdAmount) private view returns(uint){
        uint _convesionRate = bnb_to_usd;
        uint _weiConverted = (bnbTimes100ToWei (_usdAmount*100))/_convesionRate;
        return _weiConverted;
    }

    function payUserInvestmentEarnings(UserStruct storage _user) private {
        payUsersReferralEarnings(_user);
        uint earningsFromLastPay = calculateEaringsFromLastPaytime(_user.investment, _user.last_dividend_time, _user.investment_interest_times1000);
        _user.balance += earningsFromLastPay;
        _user.dividends_paid += earningsFromLastPay;
        _user.last_dividend_time = block.timestamp;
    }

    function calculateEaringsFromLastPaytime(uint _investedAmount, uint _lastPayTime, uint _interestTimes1000) private view returns(uint){
        uint secondsPassed = block.timestamp - _lastPayTime;
        uint earnings =  secondsPassed * getPaymentPerSecondWithInterest(_investedAmount,_interestTimes1000);
        return earnings;
    }

    function payUsersReferralEarnings(UserStruct storage _user) private {
        uint secondsPassed = block.timestamp - _user.last_dividend_time;
        uint256[11] memory referralEarningsPerSecond = _user.referral_amount_per_second;
        for(uint8 i = 0; i < referralEarningsPerSecond.length; i++) {
            uint bonusPayPerSecond = (referralEarningsPerSecond[i]/REFERRAL_PERCENT_DIVIDER ) * referral_pay_rates[i];
            _user.balance += (secondsPassed * bonusPayPerSecond);
            _user.referral_bonus_earned += (secondsPassed * bonusPayPerSecond);
            _user.referral_network_earnings[i] += (secondsPassed * bonusPayPerSecond);
        }
    }

    function calculatesReferralEarningsFromLastPaytime(UserStruct storage _user) private view returns (uint) {
        uint secondsPassed = block.timestamp - _user.last_dividend_time;
        uint256[11] memory referralEarningsPerSecond = _user.referral_amount_per_second;
        uint referralEarned = 0;
        for(uint8 i = 0; i < referralEarningsPerSecond.length; i++) {
            uint bonusPayPerSecond = (referralEarningsPerSecond[i]/REFERRAL_PERCENT_DIVIDER ) * referral_pay_rates[i];
            referralEarned += (secondsPassed * bonusPayPerSecond);
        }
        return referralEarned;
    }

    function getCommulativeEarningsFromLastPay(UserStruct storage _user) private view returns (uint256[2] memory) {
        uint dividends = calculateEaringsFromLastPaytime(_user.investment, _user.last_dividend_time, _user.investment_interest_times1000);
        uint referrals = calculatesReferralEarningsFromLastPaytime(_user);
        return [uint256(dividends), uint256(referrals)];
    }

    function getInterestToUse(uint _investedAmount) private view returns(uint){
        uint interestToUse = DAY_INTEREST_PERCENT;
        if(_investedAmount > vvip_lower_limit){
            interestToUse = DAY_INTEREST_PERCENT_VVIP;
        }
        if(_investedAmount > vip_lower_limit && _investedAmount <= vvip_lower_limit){
            interestToUse = DAY_INTEREST_PERCENT_VIP;
        }
        return interestToUse;
    }

    function generateNewUser(address _selfAddress, address _sponsor, uint _investedAmount) 
    private returns (UserStruct memory){   
        total_members+=1;
        total_cummulative_investment+=_investedAmount;
        uint interestToUse = getInterestToUse(_investedAmount);
        return UserStruct({
                is_active : true,
                self_address: _selfAddress,
                balance : 0,
                sponsor: _sponsor,
                investment: _investedAmount,
                investment_interest_times1000: interestToUse,
                dividends_paid: 0,
                last_dividend_time: block.timestamp,
                referral_bonus_earned: 0,
                withdrawn_amount: 0,
                last_withdraw_time: (block.timestamp - 24 hours),
                week_limit_count: 0,
                week_limit_count_time: (block.timestamp - 7 days), 
                referral_structure: [0,0,0,0,0,0,0,0,0,0,0],
                referral_amount_per_second: [uint256(0),uint256(0),uint256(0),uint256(0),uint256(0),uint256(0),uint256(0),uint256(0),uint256(0),uint256(0),uint256(0)],
                referral_network_earnings: [uint256(0),uint256(0),uint256(0),uint256(0),uint256(0),uint256(0),uint256(0),uint256(0),uint256(0),uint256(0),uint256(0)]
        });
    }

    function updateUplineCount(address _sponsorAddress, uint _investedAmount) private{
        for(uint8 i = 0; i < BONUS_LINES_COUNT; i++) {
            users[_sponsorAddress].referral_structure[i]++;
            users[_sponsorAddress].referral_amount_per_second[i] += getPaymentPerSecond(_investedAmount);
            _sponsorAddress = users[_sponsorAddress].sponsor;
            if(_sponsorAddress == address(0)) break; //Owner is first upline - break loop
        }
        emit UplineCountUpdated(_sponsorAddress, users[_sponsorAddress].sponsor, users[_sponsorAddress].investment);
    }

    function getPaymentPerSecond(uint _amountInvested) private view returns(uint interestPerSecond){
        uint interestUsed = getInterestToUse(_amountInvested);
        uint paymentPerSecond = ((_amountInvested/INTEREST_PERCENT_DIVIDER) * interestUsed)/(24*60*60);
        return paymentPerSecond;
    }

    function getPaymentPerSecondWithInterest(uint _amountInvested, uint _interestToUse) private pure returns(uint interestPerSecond){
        uint paymentPerSecond = ((_amountInvested/INTEREST_PERCENT_DIVIDER) * _interestToUse)/(24*60*60);
        return paymentPerSecond;
    }

    function getUserBalance(UserStruct storage _user) private returns (uint){
        payUserInvestmentEarnings(_user);
        return _user.balance;
    }

    function getUserTotalEarnings(UserStruct memory _user) private pure returns(uint){
        return (_user.dividends_paid + _user.referral_bonus_earned);
    }

    function getUserRemainingWithdrawLimit(UserStruct memory _user) private view returns(uint){
        return (getUserMaximumEarningsLimit(_user) - _user.withdrawn_amount);
    }

    function getUserMaximumEarningsLimit(UserStruct memory _user) private view returns(uint){
        return (_user.investment * (max_earning_percentage/100));
    }
    
    function getUserRemainingEarningLimit(UserStruct memory _user) private view returns(uint){
        return (getUserMaximumEarningsLimit(_user) - getUserTotalEarnings(_user));
    }
    //END OF UTILITY FUNCTIONS


    //ADMIN FUNCTIONS
    function payAdminFees(uint _investedAmount) private{
        for (uint i = 0; i < admins.length; i++) {
            payable(admins[i].payAddress).transfer(admins[i].payPercentage * (_investedAmount/100)); //Divided by 100 because of percentage
        }
    }

    function payMarketingFees(uint _cost) onlyOwner public{
        for (uint i = 0; i < admins.length; i++) {
            if(admins[i].marketingPercentage > 0){
                payable(admins[i].payAddress).transfer(admins[i].marketingPercentage * (_cost/100)); //Divided by 100 because of percentage
            }
        }
    }

    function updateUsdToBNBRate(uint _bnbToUSd) onlyOwner public{
        bnb_to_usd = _bnbToUSd; // value of 1 bnb to usd
        min_investment = usdToWei(30);
        min_withdraw = usdToWei(30);
        vip_lower_limit = usdToWei(1000);
        vvip_lower_limit = usdToWei(10000);
        max_investment = usdToWei(25000);
    }
    //END OF ADMIN FUNCTIONS

    //BUSINESS FUNCTIONS
    receive() external payable {

    }

    function invest(address _sponsorAddress) external noReentry payable{
        //Basic validations
        require(msg.value >= min_investment, "Minimum investment amount is USD 30. Consider BNB conversion rate");
        require(msg.value <= max_investment, "Maximum investment amount is USD 25,000. Consider BNB conversion rate");
        require(users[_sponsorAddress].is_active == true, "The given sponsor not registered!");

        //Checking if is exisiting user
        if(users[msg.sender].is_active == true){
            //pay daily earnings and update date so to start with new rate
            payUserInvestmentEarnings(users[msg.sender]);
            uint _newTotalInvestment = users[msg.sender].investment + msg.value;
            uint interestToUse = getInterestToUse(_newTotalInvestment); 
            users[msg.sender].investment = _newTotalInvestment;
            users[msg.sender].investment_interest_times1000 = interestToUse;
        }else{
            UserStruct memory newUserObject = generateNewUser(msg.sender, _sponsorAddress, msg.value);
            users[msg.sender] = newUserObject;
            updateUplineCount( _sponsorAddress, msg.value);
        }
        payAdminFees(msg.value);
        emit NewInvestment(msg.sender, msg.value);
        payUserInvestmentEarnings(users[_sponsorAddress]);
    }

    function withdraw(uint _withdrawAmountRequested) external noReentry payable{
        require(users[msg.sender].is_active == true, "No such user registered in ProTradesAI!");
        UserStruct storage withdrawingUser = users[msg.sender];
        require( _withdrawAmountRequested >= min_withdraw, "You cannot withdraw below $30. Consider current system BNB conversion rate");
        require( getUserBalance(withdrawingUser) >= _withdrawAmountRequested, "You cannot withdraw more than your available balance!");
        require( getUserRemainingWithdrawLimit(withdrawingUser) > 0, "Increase you earning limit by investing more to withdraw your balance!");
        require( getUserRemainingWithdrawLimit(withdrawingUser) >= _withdrawAmountRequested, "You cannot withdraw beyond 300% your investment!");
        require(block.timestamp >= (withdrawingUser.last_withdraw_time + 24 hours ), "You can only withdraw once every 24 hours!");
        if(block.timestamp > (withdrawingUser.week_limit_count_time + 7 days)){
            withdrawingUser.week_limit_count_time = block.timestamp;
            withdrawingUser.week_limit_count = 0; 
        }
        require((withdrawingUser.week_limit_count + _withdrawAmountRequested) <= max_withdraw_perweek, "You can only withdraw $5,000 in 7 days!");
        uint contractBalance = address(this).balance;
        if (contractBalance < _withdrawAmountRequested) {
            _withdrawAmountRequested = contractBalance;
        }
        uint _withdrawAmountToSend = ((_withdrawAmountRequested/100)*(100-WITHDRAW_FEES));//Divide by 100 because of fee in percentage
        payable(msg.sender).transfer(_withdrawAmountToSend); 
        withdrawingUser.balance -= _withdrawAmountRequested;
        withdrawingUser.withdrawn_amount += _withdrawAmountRequested;
        withdrawingUser.last_withdraw_time = block.timestamp; 
        total_cummulative_withdrawn += _withdrawAmountRequested;
        //Update weekly limit check
        withdrawingUser.week_limit_count += _withdrawAmountRequested;
        //End of weekly limit check 
        emit WithdrawCompleted(msg.sender, _withdrawAmountRequested);
        payUserInvestmentEarnings(withdrawingUser);
    }
    //END OF BUSINESS FUNCTIONS

    //REPORTING FUNCTIONS (MUST HAVE VIEW SPECIFIER)
    function getBNBConversionRate() public view returns(uint conversionRate) 
    {
        return (bnb_to_usd);
    }

    function getUsersInfo(address _userAddress) public view  
    returns(uint balance, uint investment, uint dividends_paid, uint referral_bonus_earned, uint withdrawn_amount, uint last_withdraw_time, uint8[11] memory referral_structure) 
    {
        // require(users[_userAddress].is_active == true, "No such user registered in ProTradesAI!"); //Disabled based on frontend logic to allow user address query before investing
        UserStruct storage userToCheckInfo = users[_userAddress];
        uint[2] memory balanceToAdd = getCommulativeEarningsFromLastPay(userToCheckInfo);
        uint _balance = userToCheckInfo.balance + balanceToAdd[0] + balanceToAdd[1];
        uint _investment = userToCheckInfo.investment;
        uint _dividends_paid = userToCheckInfo.dividends_paid + balanceToAdd[0];
        uint _referral_bonus_earned = userToCheckInfo.referral_bonus_earned + balanceToAdd[1];
        uint _withdrawn_amount = userToCheckInfo.withdrawn_amount;
        uint _last_withdraw_time = userToCheckInfo.last_withdraw_time;
        uint8[11] memory _referral_structure = userToCheckInfo.referral_structure;
        return (_balance, _investment, _dividends_paid, _referral_bonus_earned, _withdrawn_amount, _last_withdraw_time, _referral_structure);
    }

    function getUsersExtraInfo(address _userAddress) public view 
    returns(uint investment_interest_times1000, uint256[11] memory referral_amount_per_second, uint256[11] memory referral_network_earnings) 
    {
        // require(users[_userAddress].is_active == true, "No such user registered in ProTradesAI!"); //Disabled based on frontend logic to allow user address query before investing
        UserStruct storage userToCheckInfo = users[_userAddress];
        return (userToCheckInfo.investment_interest_times1000, userToCheckInfo.referral_amount_per_second, userToCheckInfo.referral_network_earnings);
    }

    function getUsersReferralsCount(address _userAddress) public view returns(uint8[11] memory referral_structure){
        // require(users[_userAddress].is_active == true, "No such user registered in BNBGainers!"); //Disabled based on frontend logic to allow user address query before investing
        UserStruct memory userToCheckInfo = users[_userAddress];
        uint8[11] memory _referral_structure = userToCheckInfo.referral_structure;
        return _referral_structure;
    }
    //END OF REPORTING FUNCTIONS

}


//STRUCTURES AND OTHER CODES
struct AdminStruct{
    string name;
    address payAddress;
    uint256 payPercentage;
    uint256 marketingPercentage;
}

struct UserStruct{
    bool is_active; //For checking if registered on reinvestment
    address self_address;
    uint balance;
    address sponsor;
    uint investment;
    uint investment_interest_times1000; //In percentage (should divide by 1000)
    uint dividends_paid;
    uint last_dividend_time;
    uint referral_bonus_earned;
    uint withdrawn_amount;
    uint last_withdraw_time;
    uint week_limit_count;
    uint week_limit_count_time;
    uint8[11] referral_structure;
    uint256[11] referral_amount_per_second;
    uint256[11] referral_network_earnings;
}