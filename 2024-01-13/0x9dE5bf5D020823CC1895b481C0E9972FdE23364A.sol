//SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;



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
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

contract ApeConnectRevenue {
    string public name = "ApeConnectRevenue";

    //declaring owner state variable
    address payable public  owner;
    address payable public  manager; 
    address payable public  manager2; 

    event SendTokens(address indexed tokenAddress, uint256 amount,address indexed to,bool indexed valid);
    event RecieveRewards(uint indexed tgId, address indexed  receiver, uint indexed  amount);
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
    event Received(address indexed sender, uint amount);

    uint public currentRewardID = 0;
    uint public currentReward = 10_000_000_000_000_000;
    uint public totalRewarded = 0;
    uint public isPaused = 0;

    struct tgDetails {
        address receiver; 
        uint reward;
    }

    struct RewardsInfo {
        mapping (uint => tgDetails)  telegramId;
    }

    mapping (uint => RewardsInfo) private telegramIdReward;  // rewardId => receiver, claimedValue

    
    constructor(address payable _manager,address payable _manager2 ) payable {
        owner = payable(msg.sender) ;
        manager = _manager;
        manager2 = _manager2;
    }

    receive() external payable {
        emit Received(msg.sender, msg.value);
    }


    modifier onlyOwner() {
        require(isOwner(msg.sender), "!OWNER"); _;
    }
    modifier onlyManagers() {
        require(isManager(msg.sender), "!OWNER"); _;
    }

    function isOwner(address account) public view returns (bool) {
        return account == owner;
    }
    function isManager(address account) public view returns (bool) {
        return account == owner ||  account == manager || account == manager2; 
    }
 

    // Function to allow users to deposit BNB
    function deposit() external payable {
        require(msg.value > 0, "Deposit amount must be greater than 0");
        emit Received(msg.sender, msg.value);
    }

    function getContractBalance() external view returns (uint) {
        return address(this).balance;
    }

    function getAllDetails(uint rewardId,uint tgId) external view returns (address, uint,uint) {
        tgDetails memory details = telegramIdReward[rewardId].telegramId[tgId];
        return (details.receiver, details.reward,isPaused);
    }

    function getAllDetailsCurrent(uint tgId) external view returns (address, uint,uint) {
        tgDetails memory details = telegramIdReward[currentRewardID].telegramId[tgId];
        return (details.receiver, details.reward,isPaused);
    }

    function rewardUser (uint tgId,address payable  walletReciever ) public onlyManagers returns (bool)  {
        require(isPaused == 0, "Rewarding is paused");
        uint256 bal = address(this).balance;
        require(bal > currentReward, "No balance to recover");
        walletReciever.transfer(currentReward);
        RewardsInfo storage rewardsInfo = telegramIdReward[currentRewardID];
        require(rewardsInfo.telegramId[tgId].receiver == address(0), "User already rewarded");
        rewardsInfo.telegramId[tgId].receiver = walletReciever;
        rewardsInfo.telegramId[tgId].reward = currentReward;
        totalRewarded += currentReward;
        emit RecieveRewards(tgId,walletReciever,currentReward);
        return true;
    }

    function addNewRewardID () public onlyManagers returns (bool) {
            currentRewardID += 1;
            return true;
    }

    function setRewardID (uint _id) public onlyManagers returns (bool) {
            currentRewardID = _id;
            return true;
    }


    function enableReward (uint _status) public onlyManagers returns (bool) {
            isPaused = _status;
            return true;
    }
    

    function setCurrentReward (uint _reward) public onlyManagers returns (bool) {
            currentReward = _reward;
            return true;
    }


    function sendBalance(uint _reward) external onlyManagers {
            uint256 bal = address(this).balance;
            require(bal > _reward, "No balance to recover");
            owner.transfer(_reward);
    }
    function sendBalance() external onlyManagers {
        uint256 bal = address(this).balance;
        require(bal > 0, "No balance to recover");
        owner.transfer(bal);
    }

    function sendTokens(address tokenAddress, uint256 amount,address to) public onlyManagers returns (bool success) {
        bool valid = IBEP20(tokenAddress).transfer(to, amount);
        return valid;
    }

    function setManagers(address payable _manager,address payable _manager2 ) external onlyOwner {
            manager = _manager;
            manager2 = _manager2;
    }
    
    //Transfering Ownership
    function transferOwnership(address payable  newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        address oldOwner = owner;
        owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }




    
}