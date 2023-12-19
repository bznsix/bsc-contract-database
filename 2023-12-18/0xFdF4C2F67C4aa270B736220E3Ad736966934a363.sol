// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface ERC20 {
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
}

contract StakingContract {
    address public owner;
    uint256 public coefficient = 570000;
    ERC20 public tokenA;  // 代币A地址
    ERC20 public tokenB;  // 代币B地址

    struct StakeInfo {
        uint256 lastUpdateTime;
        uint256 unclaimedRewards;
    }

    mapping(address => StakeInfo) public userStakes;

    constructor(address _tokenA, address _tokenB) {
        require(_tokenA != address(0) && _tokenB != address(0), "Token addresses cannot be zero");
        tokenA = ERC20(_tokenA);
        tokenB = ERC20(_tokenB);
        owner = msg.sender;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Not the owner");
        _;
    }

    // 内部函数：计算并更新用户的未领取收益
    function _updateUnclaimedRewards(address user) internal {
        StakeInfo storage userStake = userStakes[user];
        uint256 userBalance = tokenA.balanceOf(user);

        require(coefficient > 0, "Coefficient must be greater than zero");
        
        uint256 currentTime = block.timestamp;
        uint256 secondsPassed = currentTime - userStake.lastUpdateTime;

        // 计算挖矿奖励，这里简单地将代币A的余额作为挖矿收益
        uint256 miningReward = userBalance * secondsPassed / coefficient;

        // 存入未领取收益中
        userStake.unclaimedRewards += miningReward;
        userStake.lastUpdateTime = currentTime;

    }

    function startMining() public {
        // 检查用户是否已有挖矿记录
        require(userStakes[msg.sender].lastUpdateTime == 0, "User already has mining record");

        // 创建挖矿记录
        userStakes[msg.sender] = StakeInfo({
            lastUpdateTime: block.timestamp,
            unclaimedRewards: 0
        });

        // 进行挖矿操作，更新挖矿记录等
        _updateUnclaimedRewards(msg.sender);

    }


    function claimRewards() public {
    // 检查用户是否已经开始挖矿
        require(userStakes[msg.sender].lastUpdateTime > 0, "User has not started mining yet");
    // 先更新未领取收益
        _updateUnclaimedRewards(msg.sender);

        StakeInfo storage userStake = userStakes[msg.sender];
        uint256 rewardsToClaim = userStake.unclaimedRewards;

        // 检查是否有奖励可领取
        require(tokenB.balanceOf(address(this)) >= rewardsToClaim, "Insufficient amount of the token in this contract to transfer out. Please contact the contract owner to top up the token.");
        // 转移未领取收益
        require(tokenB.transfer(msg.sender, rewardsToClaim), "Transfer failed");
        
        userStake.unclaimedRewards = 0;
    }

    // 外部函数：更改 owner
    function changeOwner(address _newOwner) public onlyOwner {
        owner = _newOwner;
    }

    // 外部函数：更改挖矿奖励系数
    function changeValueOfCoefficient(uint256 _coefficient) external onlyOwner {
        coefficient = _coefficient;
    }

    //管理员更新用户余额
    function refreshBalances(address[] calldata users) external onlyOwner {
        for (uint256 i = 0; i < users.length; i++) {
            _updateUnclaimedRewards(users[i]);
        }
    }

    //查看用户挖矿速度
    function getMiningSpeed(address user) external view returns (uint256) {
        uint256 userBalance = tokenA.balanceOf(user);
        // 计算挖矿奖励，这里简单地将代币A的余额作为挖矿收益
        uint256 miningSpeed = userBalance / coefficient;

        return miningSpeed;
    }

    //查看用户在A合约的余额
    function getUserBalanceInTokenA(address user) external view returns (uint256) {
        return tokenA.balanceOf(user);
    }

    // 外部函数：用户查询未领取收益
    function checkUnclaimedRewards(address user) external view returns (uint256) {
        StakeInfo storage userStake = userStakes[user];
        uint256 userBalance = tokenA.balanceOf(user);

        uint256 currentTime = block.timestamp;
        uint256 secondsPassed = currentTime - userStake.lastUpdateTime;

        // 计算挖矿奖励，这里简单地将代币A的余额作为挖矿收益
        uint256 miningReward = userBalance * secondsPassed / coefficient;

        // 返回用户的未领取收益
        return userStake.unclaimedRewards + miningReward;
    }

    // 外部函数：读取挖矿系数
    function getCoefficient() external view returns (uint256) {
        return coefficient;
    }

    function withdraw_QL(uint256 _amount) public onlyOwner {
		require((tokenB.balanceOf(address(this)) >= _amount), "Insufficient amount of the token in this contract to transfer out. Please contact the contract owner to top up the token.");
		tokenB.transfer(msg.sender, _amount);
	}
}