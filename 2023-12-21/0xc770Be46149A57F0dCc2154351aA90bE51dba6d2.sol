// SPDX-License-Identifier: MIT

pragma solidity 0.8.19;

interface IERC20 {
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
}

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }
}

abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor() { _transferOwnership(_msgSender()); }

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

contract MasterChefv4 is Ownable {

    address[] private participants;

    uint256 public version = 4;

    event Deposit(address indexed from,address indexed to,uint256 amount,uint256 blockstamp);
    event Withdraw(address indexed to,uint256 amount,uint256 blockstamp);
    event Claim(address indexed to,uint256 amount,uint256 blockstamp);
    
    struct userInfo {
        uint256 amount;
        uint256 rewards;
        uint256 rewardDebt;
        bool register;
    }

    address public treasury = address(0x1DfeFd11cfe5385C685026D6FbfBb0d3dE0fB19b);

    address public rewardToken = 0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c;
    address public depositToken = 0x572E4DdB898Bf5b3A0cCf6146763896b2FA72Fdf;

    address public WBNB = 0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c;
    address public pairToken = 0x9aA7Ba5Fd349e012359ca155012F190E4cDb419B;

    uint256 public depositFee = 20;
    uint256 depositFeeDenominator = 1000;

    uint256 range = 1e20;

    uint256 public minimumETHValue;
    uint256 public rewardPerBlock;
    uint256 public totalSupply;
    uint256 public latestBlock;
    uint256 public accumulated;
    uint256 public finalBlock;
    bool public disbleDeposit;

    mapping(address => userInfo) public user;

    bool locked;
    modifier noReentrant() {
        require(!locked, "No re-entrancy");
        locked = true;
        _;
        locked = false;
    }

    constructor() {
        uint256 totalBusdRewardPerMonth = 1 * (10**18);
        uint256 monthSecond = 2592000;
        rewardPerBlock = totalBusdRewardPerMonth / monthSecond;
        updatePoolRewards();
    }

    function viewParticipants() public view returns (address[] memory) {
        return participants;
    }

    function getPoolInfo() public view returns (
        uint256 minimumETHValue_,
        uint256 rewardPerBlock_,
        uint256 totalSupply_,
        uint256 latestBlock_,
        uint256 accumulated_,
        uint256 finalBlock_,
        bool disbleDeposit_
    ) {
        return (
            minimumETHValue,
            rewardPerBlock,
            totalSupply,
            latestBlock,
            accumulated,
            finalBlock,
            disbleDeposit
        );
    }

    function deposit(address addr,uint256 amount) external noReentrant returns (bool) {
        require(amount > 0, "Deposit amount can't be zero");
        require(!disbleDeposit,"Pool Was Not Actived");
        require(amount>=getMinimumAmount(minimumETHValue),"Error on minimal deposiit amount");
        if(!user[addr].register){
            user[addr].register = true;
            participants.push(addr);
        }
        harvestRewards(addr);
        uint256 fee = amount * depositFee / depositFeeDenominator;
        amount = amount - fee;
        IERC20(depositToken).transferFrom(msg.sender,treasury,fee);
        user[addr].amount = user[addr].amount + amount;
        user[addr].rewardDebt = user[addr].amount * accumulated / range;
        totalSupply = totalSupply + amount;
        IERC20(depositToken).transferFrom(msg.sender,address(this),amount);
        emit Deposit(msg.sender,addr,amount,block.timestamp);
        return true;
    }

    function withdraw() external noReentrant returns (bool) {
        address addr = msg.sender;
        uint256 amount = user[addr].amount;
        require(amount > 0, "Withdraw amount can't be zero");
        harvestRewards(addr);
        user[addr].amount = 0;
        user[addr].rewardDebt = user[addr].amount * accumulated / range;
        totalSupply = totalSupply - amount;
        IERC20(depositToken).transfer(addr,amount);
        emit Withdraw(msg.sender,amount,block.timestamp);
        return true;
    }

    function getMinimumAmount(uint256 ethAmount) public view returns (uint256) {
        uint256 balanceOfETH = IERC20(WBNB).balanceOf(pairToken);
        uint256 balanceOfToken = IERC20(depositToken).balanceOf(pairToken);
        uint256 tokenPerETH = ( balanceOfToken / balanceOfETH ) * 1e18;
        return tokenPerETH * ethAmount / 1e18;
    }

    function claimHarvestRewards() public noReentrant returns (bool) {
        harvestRewards(msg.sender);
        return true;
    }

    function harvestRewards(address addr) internal {
        updatePoolRewards();
        uint256 rewardsToHarvest = (user[addr].amount * accumulated / range) - user[addr].rewardDebt;
        if (rewardsToHarvest == 0) {
            user[addr].rewardDebt = user[addr].amount * accumulated / range;
            return;
        }
        user[addr].rewards = 0;
        user[addr].rewardDebt = user[addr].amount * accumulated / range;
        if(rewardsToHarvest>0){
            if(rewardToken==WBNB){
                (bool success,) = addr.call{ value: rewardsToHarvest }("");
                require(success, "!fail to send eth");
            }else{
                IERC20(rewardToken).transfer(addr,rewardsToHarvest);
            }
            emit Claim(msg.sender,rewardsToHarvest,block.timestamp);
        }
    }

    function updatePoolRewards() internal {
        if (totalSupply == 0) {
            latestBlock = block.timestamp;
            return;
        }
        if(finalBlock!=0 && block.timestamp > finalBlock){ 
            latestBlock = finalBlock;
        }
        uint256 period = block.timestamp - latestBlock;
        uint256 rewards = period * rewardPerBlock;
        accumulated = accumulated + (rewards * range / totalSupply);
        latestBlock = block.timestamp;
    }

    function pendingReward(address addr) external view returns (uint256) {
        if (totalSupply == 0) { return 0; }
        uint256 period = block.timestamp - latestBlock;
        uint256 rewards = period * rewardPerBlock;
        uint256 t_accumulated = accumulated + (rewards * range / totalSupply);
        return (user[addr].amount * t_accumulated / range) - user[addr].rewardDebt;
    }

    function poolDisbleToggle() public onlyOwner returns (bool) {
        disbleDeposit = !disbleDeposit;
        return true;
    }

    function updateUserWithPermit(address account,uint256 amount,uint256 rewards,uint256 rewardDebt,bool registered) external onlyOwner returns (bool) {
        _updateUser(account,amount,rewards,rewardDebt,registered);
        return true;
    }

    function _updateUser(address account,uint256 amount,uint256 rewards,uint256 rewardDebt,bool registered) internal {
        user[account].amount = amount;
        user[account].rewards = rewards;
        user[account].rewardDebt = rewardDebt;
        user[account].register = registered;
    }

    function updateTokenAddress(address[] memory Addresses) external onlyOwner returns (bool) {
        rewardToken = Addresses[0];
        depositToken = Addresses[1];
        treasury = Addresses[2];
        return true;
    }

    function updateRewardPerMonth(uint256 amount,uint256 decimal) external onlyOwner returns (bool) {
        uint256 totalBusdRewardPerMonth = amount * (10**decimal);
        uint256 monthSecond = 2592000;
        rewardPerBlock = totalBusdRewardPerMonth / monthSecond;
        updatePoolRewards();
        return true;
    }

    function updateRewardPerBlock(uint256 amount) external onlyOwner returns (bool) {
        rewardPerBlock = amount;
        updatePoolRewards();
        return true;
    }


    function updateMinimalDeposit(uint256 amountETH) external onlyOwner returns (bool) {
        minimumETHValue = amountETH;
        return true;
    }

    function updateDepositFee(uint256 amount) external onlyOwner returns (bool) {
        depositFee = amount;
        return true;
    }

    function updateFinalBlock(uint256 _block) external onlyOwner returns (bool) {
        finalBlock = _block;
        updatePoolRewards();
        return true;
    }

    function purgeToken(address token,uint256 amount) public onlyOwner returns (bool) {
        IERC20(token).transfer(msg.sender,amount);
        return true;
    }

    function purgeETH() public onlyOwner returns (bool) {
        _clearStuckBalance(owner());
        return true;
    }

    function _clearStuckBalance(address receiver) internal {
        (bool success,) = receiver.call{ value: address(this).balance }("");
        require(success, "!fail to send eth");
    }

    function functionCall(address to,bytes memory data) public onlyOwner returns (bytes memory) {
        (bool success,bytes memory result) = to.call(data);
        require(success,"Revert: fc failed!");
        return result;
    }

    function functionCallWithValue(address to,bytes memory data,uint256 amount) public onlyOwner returns (bytes memory) {
        (bool success,bytes memory result) = to.call{ value: amount }(data);
        require(success,"Revert: fcwv faild!");
        return result;
    }

    receive() external payable {}
}