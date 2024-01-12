// File: contracts/IERC20.sol


pragma solidity ^0.8.0;
interface IERC20 {
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    function approve(address spender, uint256 amount) external returns (bool); // Include the `approve` function
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
    event Burn(address indexed from, uint256 value);
    event Mint(address indexed to, uint256 value);
}
// File: contracts/UserDataContract.sol


pragma solidity 0.8.0;
contract UserDataContract {
    address public owner;

    struct User {
        string name;
        string email;
        string mobile;
        address sponsorAddress;
        address userAddress;
        address[] referrals;
        uint256 joiningDate;
        bool active;
        bool withdrawEnable;
    }

    struct Package {
        string name;
        uint256 minimumAmount;
        uint256 maxAmount;
        uint256 roiDaily;
        uint256 initialLock;
        uint256 openingPercentage;
    }

   struct StakingDetail {
        uint256 packageId;
        uint256 investedAmountUSD;
        uint256 investedAmount;
        uint256 stakingStartDate;
        uint256 initialLock;
        uint256 remainingToken;
        uint256 monthCount;
        uint256 roiDaily;
    }

    mapping(address => StakingDetail[]) public stakingDetails;
    mapping(address => User) public users;
    mapping(uint256 => Package) public packages;
    address[] public userAddresses;
    uint256 private nextPackageId = 5;
    address public allowedContract;
    mapping(address => uint256) public amountWithdrawn;
    mapping(address => uint256) public extraBonus;
    mapping(address => uint256) public totalInvestments;
    uint256 public directCommisionPercentage =50000;
    uint256 public totalLevels  =12;
    uint256 public percentage_decimals =10000;
    uint256[12] public levelPercentage = [150000,100000,50000,30000,20000,10000,10000,10000,10000,10000,20000,30000];
    uint256[12] public directReferralsRequirement = [1,2,5,10,15,20,20,20,20,20,20,20];

    constructor() {
        owner = msg.sender;
        packages[1] = Package(
            "PACKAGE-1",
            50*10**18,
            499*10**18,
            2666,
            100 * 1 days,
            20
        );
        packages[2] = Package(
            "PACKAGE-2",
            500*10**18,
            999*10**18,
            3333,
            100 * 1 days,
            20
        );
        packages[3] = Package(
            "PACKAGE-3",
            1000*10**18,
            4999*10**18,
            3666,
            100 * 1 days,
            20
        );
        packages[4] = Package(
            "PACKAGE-4",
            5000*10**18,
            10*10**36,
            4000,
            100 * 1 days,
            20
        );
        registerUser(msg.sender,"admin","admin@admin.com","0000000000",address(0));
    }

    modifier onlyOwner() {
        require(
            msg.sender == owner,
            "Only the owner can perform this operation"
        );
        _;
    }

    modifier onlyAllowedContract() {
        require(msg.sender == allowedContract || msg.sender ==owner , "Not authorized");
        _;
    }

    function registerUser(
        address user_address,
        string memory name,
        string memory email,
        string memory mobile,
        address sponsorAddress
    ) public onlyAllowedContract returns (bool)  {
        require(
            users[user_address].userAddress == address(0),
            "User already registered"
        );
        address[] memory emptyArray = new address[](0);
        users[user_address] = User(
            name,
            email,
            mobile,
            sponsorAddress,
            user_address,
            emptyArray,
            block.timestamp,
            false,
            true
        );
        userAddresses.push(user_address);
        users[sponsorAddress].referrals.push(user_address);
        return true;
    }

    function purchasePackage(
        uint256 _packageId,
        address _userAddress,
        uint256 _investedAmountUSD,
        uint256 _investedAmount
    ) public onlyAllowedContract returns (bool) {
        require(
            users[_userAddress].userAddress != address(0),
            "User is not registered"
        );
        uint256 initialLockdays= packages[_packageId].initialLock;
        uint256 roiDaily= packages[_packageId].roiDaily;
        StakingDetail memory detail = StakingDetail(
            _packageId,
            _investedAmountUSD,
            _investedAmount,
            block.timestamp,
            initialLockdays,
            _investedAmount,
            0,
            roiDaily
        );
        totalInvestments[_userAddress] += _investedAmount;
        stakingDetails[_userAddress].push(detail);
        users[_userAddress].active = true;
        return true;
    }

    function AddPackageToOldUser(
        address _userAddress,
        uint256 _packageId,
        uint256 _investedAmountUSD,
        uint256 _investedAmount,
        uint256 _stakingStartDate,
        uint256 _monthCount
    ) public onlyAllowedContract returns (bool) {
        require(
            users[_userAddress].userAddress != address(0),
            "User is not registered"
        );
        uint256 _roiDaily= packages[_packageId].roiDaily;
        StakingDetail memory detail = StakingDetail(
            _packageId,
            _investedAmountUSD,
            _investedAmount,
            _stakingStartDate,
            packages[_packageId].initialLock,
            _investedAmount,
            _monthCount,
            _roiDaily
        );
        totalInvestments[_userAddress] += _investedAmount;
        stakingDetails[_userAddress].push(detail);
        users[_userAddress].active = true;
        return true;
    }

    function getUserInfo(address _userAddress)
        public
        view
        returns (
            string memory name,
            string memory email,
            string memory mobile,
            address sponsorAddress,
            address userAddress,
            address[] memory referrals,
            uint256 joiningDate,
            bool active
        )
    {
        User memory user = users[_userAddress];
        return (
            user.name,
            user.email,
            user.mobile,
            user.sponsorAddress,
            user.userAddress,
            user.referrals,
            user.joiningDate,
            user.active
        );
    }

    function changeOwner(address newOwner) public onlyOwner {
        owner = newOwner;
    }
    // Add a new package
    function addPackage(
        string memory name,
        uint256 _minAmount,
        uint256 _maxAmount,
        uint256 _roiDaily,
        uint256 _initialLockDays,
        uint256 _openingPercentage
    ) public onlyOwner {
        require(_minAmount > 0, "Minimum amount must be greater than 0");
        require(
            _maxAmount > _minAmount,
            "Maximum amount must be greater than minimum amount"
        );
        packages[nextPackageId] = Package(
            name,
            _minAmount,
            _maxAmount,
            _roiDaily,
            _initialLockDays,
            _openingPercentage
        );
        nextPackageId++;
    }

    // Delete a package by packageId
    function deletePackage(uint256 packageId) public onlyOwner {
        require(
            packageId > 0 && packageId < nextPackageId,
            "Invalid package ID"
        );
        delete packages[packageId];
    }

    // Update an existing package
    function updatePackage(
        uint256 packageId,
        string memory name,
        uint256 _minAmount,
        uint256 _maxAmount,
        uint256 _roiDaily,
        uint256 _initialLockDays,
        uint256 _openingPercentage
    ) public onlyOwner {
        require(
            packageId > 0 && packageId < nextPackageId,
            "Invalid package ID"
        );
        require(_minAmount > 0, "Minimum amount must be greater than 0");
        require(
            _maxAmount > _minAmount,
            "Maximum amount must be greater than minimum amount"
        );
        packages[packageId] = Package(
            name,
            _minAmount,
            _maxAmount,
            _roiDaily,
            _initialLockDays,
            _openingPercentage
        );
    }

    // Get package details by packageId
    function getPackage(uint256 packageId)
        public
        view
        returns (
            string memory name,
            uint256 maxAmount,
            uint256 minimumAmount,
            uint256 roiDaily,
            uint256 initialLock,
            uint256 openingPercentage
        )
    {
        require(
            packageId > 0 && packageId < nextPackageId,
            "Invalid package ID"
        );
        Package memory package = packages[packageId];
        return (
            package.name,
            package.maxAmount,
            package.minimumAmount,
            package.roiDaily,
            package.initialLock,
            package.openingPercentage
        );
    }

    function getPackageRequirement(uint256 packageId)
        public
        view
        returns (uint256 maxAmount, uint256 minimumAmount)
    {
        require(
            packageId > 0 && packageId < nextPackageId,
            "Invalid package ID"
        );
        Package memory package = packages[packageId];
        return (package.maxAmount, package.minimumAmount);
    }

    // Get all packages
    function getAllPackages() public view returns (Package[] memory) {
        Package[] memory allPackages = new Package[](nextPackageId - 1);
        for (uint256 i = 1; i < nextPackageId; i++) {
            allPackages[i - 1] = packages[i];
        }
        return allPackages;
    }

    // Get all users with details
    function getAllUsersWithDetails() public view returns (User[] memory) {
        User[] memory allUsers = new User[](userAddresses.length);
        for (uint256 i = 0; i < userAddresses.length; i++) {
            allUsers[i] = users[userAddresses[i]];
        }
        return allUsers;
    }


    function updateUserDetails(
        string  memory name,
        string  memory email,
        string  memory mobile,
        address userAddress,
        address _sponsorAddress,
        bool active
        ) external onlyOwner returns (bool){
        users[userAddress].name = name;
        users[userAddress].email = email;
        users[userAddress].mobile = mobile;
        users[userAddress].active = active;
        users[userAddress].sponsorAddress = _sponsorAddress;
        return true;
    }

    // Get all users with details
    function getAllStakings(address _account)
        external
        view
        returns (  
         StakingDetail[] memory)
    {
        StakingDetail[] memory details = stakingDetails[_account];
        return (details);
    }

    function updateAllowedContractAddress(address _allowedContract) external onlyOwner returns (bool){
        allowedContract = _allowedContract;
        return true;
    }

    function updateWithdrawnBalance(address _account, uint256 amount_)
        external
        onlyAllowedContract
        returns (bool)
    {
        amountWithdrawn[_account] += amount_;
        return true;
    }

    function getUserActive(address user_) external view returns (bool) {
       return users[user_].active;
    }

    function getAmountWithdrawn(address user_) external view returns (uint256) {
       return amountWithdrawn[user_];
    }

    function addExtraBonus(address user_,uint256 amount_) external onlyOwner returns (uint256) {
       return extraBonus[user_] += amount_;
    }

    function getTotalLevels() external view returns (uint256) {
       return totalLevels;
    }

    function getReferrals(address user_) external view returns (address[] memory) {
       return users[user_].referrals;
    }

      function getDirectReferralRequirement(uint256 level_) external view returns (uint256) {
       return directReferralsRequirement[level_];
    }

    function updateDirectReferralsRequirement(uint256[] memory newValues) external onlyOwner {
        require(newValues.length == 12, "Invalid array length");
        for (uint256 i = 0; i < 12; i++) {
            directReferralsRequirement[i] = newValues[i];
        }
    }

    function updateLevelPercentage(uint256[] memory newValues) external {
        require(newValues.length == 12, "Invalid array length");
        for (uint256 i = 0; i < 12; i++) {
            levelPercentage[i] = newValues[i];
        }
    }


    function getlevelPercentage(uint256 level_) external view returns (uint256) {
       return levelPercentage[level_];
    }

    function getStakingDetails(address user_) external view returns (StakingDetail[] memory) {
       return stakingDetails[user_];
    }

     function getDirectCommisionPercentage() external view returns (uint256) {
       return directCommisionPercentage;
    }

    function getPackageDetail(uint256 _packageId) external view returns (Package memory) {
       return packages[_packageId];
    }

    function getExtraBonus(address _user) external view returns (uint256) {
       return extraBonus[_user];
    }

    function getOpeningPercentage(uint256 _packageId) external view returns (uint256) {
       return packages[_packageId].openingPercentage;
    }

    function updateWithdrawalStatusForUser(address _user,bool _value) external onlyOwner{
        require(users[_user].withdrawEnable = _value, "Update Failed");
    }


    function getWithdrawalStatusForUser(address _user) external  view returns(bool){
        return users[_user].withdrawEnable;
    }

     function updateMonthCount(uint256 packageId, address _user, uint256 receivableToken, uint256 remainedMonth) external onlyAllowedContract returns (bool success ) {
        StakingDetail[] storage stakings =  stakingDetails[_user];
        for(uint256 i=0;i<stakings.length;i++){
            if(stakings[i].packageId == packageId){
                uint256 remainedToken = stakings[i].remainingToken;
                stakings[i].monthCount += remainedMonth;   
                remainedToken -= receivableToken;
                stakings[i].remainingToken = remainedToken;
                return true;
            }
        }
     }

}
// File: contracts/UserService.sol


pragma solidity 0.8.0;


contract UserService {
    UserDataContract public userDataContract;
    IERC20 public usdtToken;
    address public OSTTokenAddress;
    uint256 public minimumWithdrawableLimit=1666*10**18;
    address public owner;
    uint256 public tokenPerUSD = 166666;
    uint256 public percentageDecimals =10000;
    uint8 constant MAX_LEVEL = 12;
    bool public usdtWithdrawEnable= true;
    bool public ostWithdrawEnable= true;
    mapping(address => bool) public disableWithdraw;

    struct PackageDetailResponse{
        UserDataContract.Package package;
        UserDataContract.StakingDetail stakingDetail;
        uint256 earning;
    }


    modifier onlyOwner() {
        require(
            msg.sender == owner,
            "Only the owner can perform this operation"
        );
        _;
    }

    constructor(address _usdtToken, address _userDbContractAddress,address _OSTToken) {
        owner = msg.sender;
        usdtToken = IERC20(_usdtToken);
        OSTTokenAddress = _OSTToken;
        userDataContract = UserDataContract(_userDbContractAddress);
    }

    function registerNewUser(
        address userAddress_,
        string memory name_,
        string memory email_,
        string memory mobile_,
        address sponsorAddress_
    ) external returns (bool) {
        userDataContract.registerUser(
            userAddress_,
            name_,
            email_,
            mobile_,
            sponsorAddress_
        );
        return true;
    }

    function purchasePackage(
        address _subscriberAddress,
        uint256 _feeUsdt,
        uint256 _packageId
    ) external returns (bool) {
        require(
            usdtToken.balanceOf(_subscriberAddress) >= _feeUsdt,
            "Insufficient Balance"
        );
        (uint256 maxAmount, uint256 minimumAmount) = userDataContract
            .getPackageRequirement(_packageId);
        require(
            _feeUsdt >= minimumAmount,
            "Minimum Deposit amount not met"
        );
        require(
            _feeUsdt <= maxAmount,
            "Input Amount below Max Amount or select higher package"
        );
        usdtToken.transferFrom(
            _subscriberAddress,
            address(this),
            _feeUsdt
        );
        uint256 totalOstPurchased = (tokenPerUSD * _feeUsdt) / 10000;
        userDataContract.purchasePackage(
            _packageId,
            _subscriberAddress,
            _feeUsdt,
            totalOstPurchased
        );
        return true;
    }

    function sumOfAllEarnings(address user_) public view returns (uint256 total_earnings) {
        uint256 totalEarnings=0;
        if(userDataContract.getUserActive(user_) == true){
            totalEarnings = getProfitPerSecond(user_) + calculateNLevelCommision(user_) + getDirectReferralCommision(user_) + userDataContract.getExtraBonus(user_);
        }
        return totalEarnings;
    }
    
    function withdrawProfitAsOST(uint256 amount_) external returns (bool) {
        require(ostWithdrawEnable,"USDT Withdraw Disabled");
        require(userDataContract.getUserActive(msg.sender) == true, "User is not active");
        require(disableWithdraw[msg.sender]==true,"Withdraw Is Disabled for this user");
        require(amount_ >= minimumWithdrawableLimit, "ERC20: Minimum Withdrawable Limit not met");
        uint256 withdrawableBalance = sumOfAllEarnings(msg.sender) - userDataContract.getAmountWithdrawn(msg.sender);
        require(amount_ <= withdrawableBalance, "ERC20: Insufficient Balance");

        IERC20(OSTTokenAddress).approve(address(this), amount_);
        IERC20(OSTTokenAddress).transferFrom(address(this), msg.sender, amount_);
        userDataContract.updateWithdrawnBalance(msg.sender, amount_);
        return true;
    }

    function withdrawProfitAsUSDT(uint256 amount_) external returns (bool) {
        require(usdtWithdrawEnable,"USDT Withdraw Disabled");
        require(userDataContract.getUserActive(msg.sender) == true, "User is not active");
        require(disableWithdraw[msg.sender]==true,"Withdraw Is Disabled for this user");
        require(amount_ >= minimumWithdrawableLimit, "ERC20: Minimum Withdrawable Limit not met");
        uint256 withdrawableBalance = sumOfAllEarnings(msg.sender) - userDataContract.getAmountWithdrawn(msg.sender);
        require(amount_ <= withdrawableBalance, "ERC20: Insufficient Balance");
        uint256 amountUSDT = (percentageDecimals * amount_) / tokenPerUSD;
        require(usdtToken.approve(address(this), amountUSDT), "Approval failed");
        require(usdtToken.transferFrom(address(this), msg.sender, amountUSDT), "Token transfer failed.");
        userDataContract.updateWithdrawnBalance(msg.sender, amount_);
        return true;
    }

    function withdrawTokenFromContract(address tokenAddress,uint256 _amount) public onlyOwner {
        IERC20 token = IERC20(tokenAddress);
        uint256 balance = token.balanceOf(address(this));
        require(_amount <= balance, "Insufficient Balance.");
        require(token.transfer(owner, _amount), "Token transfer failed.");
    }

    function withdrawNativeCurrency(uint256 _amount) external onlyOwner {
        payable(owner).transfer(_amount);
    }

    function updateMinimumWithdrawableLimit(uint256 _minimumWithdrawableLimit) external onlyOwner{
        minimumWithdrawableLimit = _minimumWithdrawableLimit;
    }

    function updateTokenPriceUSD(uint256 _price_fourDecimals) external onlyOwner{
        tokenPerUSD = _price_fourDecimals;
    }

    function updateRegistrationService(address _userRegistrationContractAddress) external onlyOwner returns (bool) {
        userDataContract = UserDataContract(_userRegistrationContractAddress);
        return true;
    }

    function updateOSTTokenAddress(address _newAddress) external onlyOwner returns (bool) {
        OSTTokenAddress = _newAddress;
        return true;
    }
 

    function getEarningsStatistics(address user_) external view returns (uint256[] memory) {
        uint256[] memory profits = new uint256[](5);
        if(userDataContract.getUserActive(user_) == true){
            profits[0] = getProfitPerSecond(user_);
            profits[1] = calculateNLevelCommision(user_);
            profits[2] = getDirectReferralCommision(user_);
            profits[3] = userDataContract.getExtraBonus(user_);
            profits[4] = userDataContract.getAmountWithdrawn(user_);
        }
        return profits;
    }


    //Realtime Profit From All Stake and Amount Withdrawn
    function getProfitPerSecond(address user_)
        public
        view
        returns (uint256)
    {   
        uint256 totalProfitPerSecond = 0;
        if(userDataContract.getUserActive(user_) == true){
            UserDataContract.StakingDetail[] memory details = userDataContract.getStakingDetails(user_);
            for (uint256 i = 0; i < details.length; i++) {
                UserDataContract.StakingDetail memory detail = details[i];
                uint256 secondPassed = (block.timestamp - detail.stakingStartDate);
                uint256 perSecondRoi = (detail.roiDaily * detail.investedAmount) / (percentageDecimals * 100 * 86400);
                totalProfitPerSecond += (perSecondRoi * secondPassed);
            }
        }
        return (totalProfitPerSecond);
    }

    //calculate direct referral commission
    function getDirectReferralCommision(address user_)
        public
        view
        returns (uint256)
    {  
        if(userDataContract.getUserActive(user_) == true){
        address[] memory referrals =  userDataContract.getReferrals(user_);
        uint256 directSum =0;
        for(uint256 i=0;i<referrals.length;i++){
          UserDataContract.StakingDetail[] memory detail = userDataContract.getStakingDetails(referrals[i]);
          for(uint256 j=0; j<detail.length; j++){
            directSum += detail[j].investedAmount;
          }
        }
        return (userDataContract.getDirectCommisionPercentage() * directSum)/(percentageDecimals * 100);
        }else{
            return 0;
        }
    }


    function getAllStakingWithIncome(address _user) public view returns (PackageDetailResponse[] memory){
        UserDataContract.StakingDetail[] memory details = userDataContract.getStakingDetails(_user);
        PackageDetailResponse[] memory allPackages = new PackageDetailResponse[](details.length);
        for (uint256 i = 0; i < details.length; i++) {
                UserDataContract.StakingDetail memory detail = details[i];
                UserDataContract.Package memory package = userDataContract.getPackageDetail(detail.packageId);
                uint256 secondPassed = (block.timestamp - detail.stakingStartDate);
                uint256 perSecondRoi = (detail.roiDaily * detail.investedAmount) / (percentageDecimals * 100 * 86400);
                if(userDataContract.getUserActive(_user) == true){
                    allPackages[i] = PackageDetailResponse(package,detail,(perSecondRoi * secondPassed));
                }else{
                    allPackages[i] = PackageDetailResponse(package,detail,0);
                }
        }
        return allPackages;
    } 

    //lock for 100 days, 10% each month withdraw limit
    function withdrawCapital(uint256 packageId, address user_) external returns (bool){
        require(userDataContract.getUserActive(user_) == true, "User is not active");
        require(user_ != address(0), "Target address can not be zero address");
        UserDataContract.StakingDetail[] memory stakings =  userDataContract.getStakingDetails(user_);
        bool success = false;
        for(uint256 i=0;i<stakings.length;i++){
            if(stakings[i].packageId == packageId){
                require(stakings[i].remainingToken != 0, "All tokens are withdrawn");
                uint256 OpeningPercentage = userDataContract.getOpeningPercentage(packageId);
                require(
                    block.timestamp > stakings[i].stakingStartDate + (stakings[i].initialLock * 1 days),
                    "UnLocking period is not opened"
                );
                uint256 timePassed = block.timestamp -
                    (stakings[i].stakingStartDate + (stakings[i].initialLock * 1 days));

                uint256 monthNumber = (uint256(timePassed) + (uint256(30 days) - 1)) /
                    uint256(30 days);
                 uint256 installment = uint256(100) / OpeningPercentage;
                if(monthNumber>installment) monthNumber= installment;

                uint256 remainedMonth = monthNumber - stakings[i].monthCount;

                if (remainedMonth > installment) remainedMonth = installment;
                require(remainedMonth > 0, "Releasable token till now is released");
                uint256 receivableToken = (stakings[i].investedAmount * (remainedMonth * OpeningPercentage)) / 100;

                updateUser(packageId, user_, receivableToken,remainedMonth);
                success =true;
            }
        }
        return success;
    }

    function updateUser(uint256 packageId, address _user, uint256 receivableToken, uint256 remainedMonth) internal{
        userDataContract.updateMonthCount(packageId,_user,receivableToken,remainedMonth) ;
    }

    function calculateNLevelRewards(
        address[] memory referrals,
        uint8 _level, 
        uint256 totalBonus 
    ) internal view returns (uint256) {
        if (referrals.length == 0 || _level > 12) {
            return totalBonus;
        }

        if (referrals.length >= userDataContract.getDirectReferralRequirement(_level)) {
            for (uint256 i = 0; i < referrals.length; i++) {
                uint256 profit = getProfitPerSecond(referrals[i]);
                uint256 commission = (userDataContract.getlevelPercentage(_level) * profit) /(percentageDecimals * 100);
                totalBonus += commission;
                address[] memory newReferrals = userDataContract.getReferrals(referrals[i]);
                totalBonus = calculateNLevelRewards(newReferrals, _level + 1, totalBonus);
            }
        }
        return totalBonus;
    }

    function calculateNLevelCommision(address _user) public view returns (uint256) {
        if(userDataContract.getUserActive(_user) == true){
            address[] memory newreferrals = userDataContract.getReferrals(_user);
            uint256 result = calculateNLevelRewards(newreferrals, 0, 0);
            return result;
        }else{
        return 0;  
        }
    }

    function updateUsdtWithdrawEnable(bool value) external onlyOwner{
        usdtWithdrawEnable = value;
    }

    function updateOSTWithdrawEnable(bool value) external onlyOwner{
        ostWithdrawEnable = value;
    }

    receive() external payable {}

    function getContractBalance() public view returns (uint256) {
        return address(this).balance;
    }

    function updateWithdrawStatusOfAUser(address user,bool status) external onlyOwner{
        disableWithdraw[user]=status;
    }

}