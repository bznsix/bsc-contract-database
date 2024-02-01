pragma solidity >=0.7.0 <0.9.0;
// SPDX-License-Identifier: MIT

abstract contract ReentrancyGuard {

    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;

    uint256 private _status;

    constructor() {
        _status = _NOT_ENTERED;
    }

    modifier nonReentrant() {
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");
        _status = _ENTERED;
        _;
        _status = _NOT_ENTERED;
    }
}

interface ERC20{
	function balanceOf(address account) external view returns (uint256);
	function transfer(address recipient, uint256 amount) external returns (bool);
	function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    function approve(address spender, uint256 amount) external returns (bool);
}

interface IERC20 {
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount)
        external
        returns (bool);
    function allowance(address owner, address spender)
        external
        view
        returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
}

library SafeMath {

    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");
        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return sub(a, b, "SafeMath: subtraction overflow");
    }

    function sub(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        uint256 c = a - b;
        return c;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");
        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return div(a, b, "SafeMath: division by zero");
    }

    function div(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        uint256 c = a / b;
        return c;
    }
}

interface IUniswapV2Factory {
    function createPair(address tokenA, address tokenB)
        external
        returns (address pair);
}

interface IUniswapV2Router01 {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);
    function addLiquidity(
        address tokenA,
        address tokenB,
        uint256 amountADesired,
        uint256 amountBDesired,
        uint256 amountAMin,
        uint256 amountBMin,
        address to,
        uint256 deadline
    )
        external
        returns (
            uint256 amountA,
            uint256 amountB,
            uint256 liquidity
        );
}

interface IUniswapV2Router02 is IUniswapV2Router01 {
    function factory() external pure override returns (address);
    function WETH() external pure override returns (address);
    
    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external;

    function swapExactETHForTokensSupportingFeeOnTransferTokens(
            uint256 amountOutMin,
            address[] calldata path,
            address to,
            uint256 deadline
        ) external payable;

    function addLiquidityETH(
        address token,
        uint256 amountTokenDesired,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline
    )
        external
        payable
        returns (uint256 amountToken, uint256 amountETH, uint256 liquidity);
}

contract IRONFISHStaking is ReentrancyGuard {

	using SafeMath for uint256;
    address owner;

    IUniswapV2Router02 public pancakeSwapRouter;
    address public token;
    
    receive() external payable {}

	//质押结构体
    struct record { 
        uint256 stakeTime; 
        uint256 stakeAmt; 
        uint256 lastUpdateTime; 
        uint256 accumulatedInterestToUpdateTime; 
        uint256 amtWithdrawn;
        uint256 Fish;
    }

    struct User {
        bool hasDeposited; // 是否已质押
        address referringAddress;// 推荐人地址
        uint256 unclaimedRewards; // 未领取的个人推荐奖励
        uint256 totalTeamReward; // 总团队收益
        uint256 withdrawnTeamReward; // 已提取的团队收益
        uint256 level; // 用户层级
        uint256 totalPerformance; // 总业绩
        uint256 vipLevel; // VIP级别
        mapping(address => uint256) referralsPerformance; // 推荐人业绩
        address[] referrals; // 推荐的用户地址
        uint256 referralsAmtAtLevel0; // 直推业绩
        uint256 referralsCountAtLevel0; // 直推数量
        uint256 referralsAmtAtLevel1; // 间推业绩
        uint256 referralsCountAtLevel1; // 间推数量
    }

    mapping(address => User) public users;
    uint256 public constant MAX_REFERRAL_LEVEL = 20;
	mapping(address => record) public informationAboutStakeScheme;//质押映射
	mapping(uint256 => address) public addressStore;//质押地址存储映射
	uint256 public numberOfAddressesCurrentlyStaked = uint256(0);//质押地址总数量
	uint256 public interestTax = uint256(50000);//利息税
	uint256 public totalWithdrawals = uint256(0);//所有领取的利息
    uint256 public dailyInterestRate = uint256(13000);//日利率

    address public constant USDT = address(0x55d398326f99059fF775485246999027B3197955); // USDT的合约地址
    
	event Staked (address indexed account);//质押事件
    event ReferralRegistered (address indexed referredAddress);//添加推荐人事件
    event TeamRewardWithdrawn(address indexed user, uint256 amount);
    event VIPLevelSet(address indexed user, uint256 vipLevel);
    event ReferrerSet(address indexed user, address indexed referrer);
    event InterestWithdrawn(address indexed user, uint256 amount);

    constructor(address _pancakeSwapRouter, address _token) {
        
        pancakeSwapRouter = IUniswapV2Router02(_pancakeSwapRouter);
        token = _token;
        owner = msg.sender;
        users[owner].referringAddress = address(0);
        users[owner].level = 0;
        users[owner].totalPerformance = 0;
    }

	function changeOwner(address _newOwner) public onlyOwner {
		owner = _newOwner;
	}

	modifier onlyOwner() {
		require(msg.sender == owner);
		_;
	}

	function changeValueOf_interestTax(uint256 _interestTax) external onlyOwner {
		require((uint256(0) < _interestTax), "Tax rate needs to be larger than 0%");
		require((uint256(1000000) > _interestTax), "Tax rate needs to be smaller than 100%");
		interestTax  = _interestTax;
	}

    function minUIntPair(uint _i, uint _j) internal pure returns (uint){
		if (_i < _j){
			return _i;
		}else{
			return _j;
		}
	}

    //注册推荐人地址
    function register(address _referringAddress) external {
        require(users[_referringAddress].hasDeposited, "Referring Address has not made a deposit");
        require(_referringAddress != msg.sender, "Self-referrals are not allowed");
        require(users[msg.sender].referringAddress == address(0), "User has previously indicated a referral address");
        require(users[_referringAddress].level < MAX_REFERRAL_LEVEL, "Referral chain too long");

        // 为用户的每个字段单独赋值
        users[msg.sender].referringAddress = _referringAddress;
        users[msg.sender].level = users[_referringAddress].level + 1;
        users[msg.sender].totalPerformance = 0;
        users[_referringAddress].referrals.push(msg.sender); // 将新用户添加到推荐人的推荐列表中
        emit ReferralRegistered(msg.sender);
    }

    //管理员设置用户推荐人
    function setReferrer(address _user, address _referrer) public onlyOwner {
        require(_user != address(0), "Cannot set referrer for the zero address");
        require(_referrer != address(0), "Referrer cannot be the zero address");
        require(_user != _referrer, "User cannot be their own referrer");
        require(users[_user].referringAddress == address(0), "User already has a referrer");

        // 设置指定用户的推荐人地址
        users[_user].referringAddress = _referrer;

        // 将该用户添加到推荐人的推荐列表中
        users[_referrer].referrals.push(_user);

        emit ReferrerSet(_user, _referrer);
    }

    // 更新总业绩，不包括用户自身的投资，并考虑最多20层推荐人限制
    function updatePerformance(address _user, uint256 _performance) private {
        address referrer = users[_user].referringAddress;
        uint256 level = 0;

        while (referrer != address(0) && level < MAX_REFERRAL_LEVEL) {
            users[referrer].totalPerformance += _performance;

            if (referrer != users[_user].referringAddress) {
                users[referrer].referralsPerformance[_user] += _performance;
            }

            referrer = users[referrer].referringAddress;
            level++;
        }
    }

    //计算大小区业绩
    function calculateBigAndSmallArea(address user) public view returns (uint256 bigArea, uint256 smallArea) {
        uint256 highestPerformance = 0;
        uint256 totalPerformance = users[user].totalPerformance;

        for (uint256 i = 0; i < users[user].referrals.length; i++) {
            address referral = users[user].referrals[i];
            uint256 referralPerformance = users[user].referralsPerformance[referral];

            if (referralPerformance > highestPerformance) {
                highestPerformance = referralPerformance;
            }
        }

        bigArea = highestPerformance;
        smallArea = totalPerformance - bigArea;

        return (bigArea, smallArea);
    }

    // 根据业绩计算VIP等级
    function calculateVIPLevel(address user) internal {
        (uint256 bigArea, uint256 smallArea) = calculateBigAndSmallArea(user);
        uint256 directReferrals = users[user].referrals.length;

        // 需要至少有五个直接推荐
        if (directReferrals >= 5) {
            if (bigArea >= 2000000 * 10**18 && smallArea >= 2000000 * 10**18) {
                users[user].vipLevel = 5; // V5
            } else if (bigArea >= 600000 * 10**18 && smallArea >= 600000 * 10**18) {
                users[user].vipLevel = 4; // V4
            } else if (bigArea >= 200000 * 10**18 && smallArea >= 200000 * 10**18) {
                users[user].vipLevel = 3; // V3
            } else if (bigArea >= 60000 * 10**18 && smallArea >= 60000 * 10**18) {
                users[user].vipLevel = 2; // V2
            } else if (bigArea >= 20 * 10**18 && smallArea >= 20 * 10**18) {
                users[user].vipLevel = 1; // V1
            } else {
                users[user].vipLevel = 0; // 未达到VIP等级
            }
        } else {
            users[user].vipLevel = 0; // 未达到VIP等级
        }
    }

    // 根据VIP级别和总业绩计算并更新团队收益
    function updateTeamReward(address userAddress) internal{
        User storage user = users[userAddress];
        // 直接使用 calculateBigAndSmallArea 函数获取小区业绩
        (, uint256 smallAreaPerformance) = calculateBigAndSmallArea(userAddress);
        uint256 newTeamReward = 0;

        // 根据VIP级别计算团队收益
        if (user.vipLevel == 1) {
            newTeamReward = smallAreaPerformance * 780 / 10000; // 7.8%
        } else if (user.vipLevel == 2) {
            newTeamReward = smallAreaPerformance * 975 / 10000; // 9.75%
        } else if (user.vipLevel == 3) {
            newTeamReward = smallAreaPerformance * 1170 / 10000; // 11.7%
        } else if (user.vipLevel == 4) {
            newTeamReward = smallAreaPerformance * 1365 / 10000; // 13.65%
        } else if (user.vipLevel == 5) {
            newTeamReward = smallAreaPerformance * 1560 / 10000; // 15.6%
        }

        // 更新总团队收益
        user.totalTeamReward = newTeamReward;
    }

    //管理员设置指定用户VIP级别
    function setVIPLevel(address _user, uint256 _vipLevel) public onlyOwner {
        require(_user != address(0), "Cannot set VIP level for the zero address");
        require(_vipLevel <= 5, "Invalid VIP level"); // 假设 VIP 级别从 1 到 5

        // 设置指定用户的 VIP 级别
        users[_user].vipLevel = _vipLevel;
        updateTeamReward(_user);

        emit VIPLevelSet(_user, _vipLevel);
    }

    //领取团队收益
    function withdrawTeamReward(uint256 amount) public {
        User storage user = users[msg.sender];

        // 计算未提取的团队收益
        uint256 unclaimedTeamReward = user.totalTeamReward - user.withdrawnTeamReward;
        require(amount <= unclaimedTeamReward, "Amount exceeds unclaimed team reward");

        // 更新已提取的团队收益
        user.withdrawnTeamReward += amount;

        require((ERC20(address(0x7f69BeD01c397D64205CC2e9D1d81Bbc6958fE84)).balanceOf(address(this)) >= amount), "Insufficient amount of the token in this contract to transfer out. Please contact the contract owner to top up the token.");
		if ((amount > uint256(0))){
			ERC20(address(0x7f69BeD01c397D64205CC2e9D1d81Bbc6958fE84)).transfer(msg.sender, amount);
		}

        emit TeamRewardWithdrawn(msg.sender, amount);
    }

    //计算推荐收益——直推和间推
    function addReferral(uint256 _amt) internal returns (uint256) {
		address referringAddress = users[msg.sender].referringAddress;
		uint256 referralsAllocated = uint256(0);
		if (!(users[msg.sender].hasDeposited)){
			users[msg.sender].hasDeposited  = true;
		}
		if ((referringAddress == address(0))){
			return referralsAllocated;
		}
		users[referringAddress].referralsAmtAtLevel0  = (users[referringAddress].referralsAmtAtLevel0 + _amt);
		users[referringAddress].referralsCountAtLevel0  = (users[referringAddress].referralsCountAtLevel0 + uint256(1));
		users[referringAddress].unclaimedRewards  = (users[referringAddress].unclaimedRewards + ((uint256(8) * _amt) / uint256(100)));
		referralsAllocated  = (referralsAllocated + ((uint256(8) * _amt) / uint256(100)));
		referringAddress  = users[referringAddress].referringAddress;
		if ((referringAddress == address(0))){
			return referralsAllocated;
		}

		users[referringAddress].referralsAmtAtLevel1  = (users[referringAddress].referralsAmtAtLevel1 + _amt);
		users[referringAddress].referralsCountAtLevel1  = (users[referringAddress].referralsCountAtLevel1 + uint256(1));
		users[referringAddress].unclaimedRewards  = (users[referringAddress].unclaimedRewards + ((uint256(4) * _amt) / uint256(100)));
		referralsAllocated  = (referralsAllocated + ((uint256(4) * _amt) / uint256(100)));
		referringAddress  = users[referringAddress].referringAddress;
		return referralsAllocated;
	}

    //提现直推间推收益
    function withdrawReferral(uint256 _amt) public {
        require((users[msg.sender].unclaimedRewards >= _amt), "Insufficient referral rewards to withdraw");
		users[msg.sender].unclaimedRewards  = (users[msg.sender].unclaimedRewards - _amt);
		require((ERC20(address(0x7f69BeD01c397D64205CC2e9D1d81Bbc6958fE84)).balanceOf(address(this)) >= _amt), "Insufficient amount of the token in this contract to transfer out. Please contact the contract owner to top up the token.");
		if ((_amt > uint256(0))){
			ERC20(address(0x7f69BeD01c397D64205CC2e9D1d81Bbc6958fE84)).transfer(msg.sender, _amt);
		}
	}

    function stake() public {
        record storage userRecord = informationAboutStakeScheme[msg.sender];

        // 检查用户是否有可质押的 Fish
        require(userRecord.Fish > 0, "No Fish to stake");

        // 检查用户是否已经有质押
        require(userRecord.stakeAmt == 0, "Need to unstake before restaking");

        uint256 fishToStake = userRecord.Fish; // 使用所有累积的 Fish

        // 更新质押记录
        userRecord.stakeTime = block.timestamp;
        userRecord.stakeAmt = fishToStake;
        userRecord.lastUpdateTime = block.timestamp;
        userRecord.accumulatedInterestToUpdateTime = 0;

        // 将用户地址添加到质押地址存储中
        addressStore[numberOfAddressesCurrentlyStaked] = msg.sender;
        numberOfAddressesCurrentlyStaked += 1;

        // 清除用户累积的 Fish
        userRecord.Fish = 0;

        // 执行质押相关的逻辑
        addReferral(fishToStake); // 计算直推和间推业绩
        updatePerformance(msg.sender, fishToStake); // 计算质押总业绩
        calculateVIPLevel(msg.sender); // 更新VIP级别
        updateTeamReward(msg.sender); // 更新团队收益

        emit Staked(msg.sender);
    }

    // 用户添加流动性并自动进行质押
    function addLiquidityAndBurn(uint256 amountUSDT) public nonReentrant {
        require(amountUSDT > 0, "Must send USDT to add liquidity");

        // 检查用户是否已有质押
        require(informationAboutStakeScheme[msg.sender].stakeAmt == 0, "Already staked");
        
        // 计算USDT的分配
        uint256 amountForTokenPurchase = amountUSDT.mul(40).div(100); // 40%用于购买代币
        uint256 amountForLiquidity = amountUSDT.mul(20).div(100); // 20%用于添加流动性

        // 接收USDT
        ERC20(USDT).transferFrom(msg.sender, address(this), amountUSDT);

        // 使用40%的USDT购买代币
        address[] memory path = new address[](2);
        path[0] = USDT;
        path[1] = token;

        ERC20(USDT).approve(address(pancakeSwapRouter), amountForTokenPurchase);
        uint256 initialTokenBalance = ERC20(token).balanceOf(address(this));

        pancakeSwapRouter.swapExactTokensForTokensSupportingFeeOnTransferTokens(
            amountForTokenPurchase,
            0, // 接受任意数量的代币
            path,
            address(this),
            block.timestamp
        );

        uint256 newTokenBalance = ERC20(token).balanceOf(address(this));
        uint256 tokensBought = newTokenBalance.sub(initialTokenBalance);

        // 授权PancakeSwap路由器可以使用代币和USDT
        ERC20(token).approve(address(pancakeSwapRouter), tokensBought);
        ERC20(USDT).approve(address(pancakeSwapRouter), amountForLiquidity);

        // 添加流动性
        (uint256 tokenUsedForLiquidity, , ) = pancakeSwapRouter.addLiquidity(
            token,
            USDT,
            tokensBought,
            amountForLiquidity,
            0, // 接受任意数量的代币和USDT
            0, // 接受任意数量的代币和USDT
            address(this),
            block.timestamp
        );

        // 计算剩余代币并发送到黑洞地址
        uint256 remainingTokens = tokensBought.sub(tokenUsedForLiquidity);
        if (remainingTokens > 0) {
            ERC20(token).transfer(0x000000000000000000000000000000000000dEaD, remainingTokens);
        }

        // 更新用户的 Fish 数量
        record storage thisrecord = informationAboutStakeScheme[msg.sender];
        thisrecord.Fish += amountUSDT;
    }

	// 提取合约中的代币
    function withdrawToken(address _token, uint256 _amount) public onlyOwner {
        require((IERC20(_token).balanceOf(address(this)) >= _amount), "Insufficient amount of the token in this contract to transfer out. Please contact the contract owner to top up the token.");
        IERC20(_token).transfer(msg.sender, _amount);
    }

    //提取合约中的BNB
    function withdrawTokenbnb(uint256 _amt) public onlyOwner {
		require((address(this).balance >= _amt), "Insufficient amount of native currency in this contract to transfer out. Please contact the contract owner to top up the native currency.");
		if ((_amt > uint256(0))){
			(bool success_1, ) =  payable(msg.sender).call{value : _amt}(""); require(success_1, "can't send money");
		}
	}

    // 允许合约所有者设置新的token地址
    function setTokenAddress(address newTokenAddress) public onlyOwner {
        token = newTokenAddress;
    }

    // 允许合约所有者设置新的PancakeSwap路由器地址
    function setPancakeSwapRouterAddress(address newRouterAddress) public onlyOwner {
        pancakeSwapRouter = IUniswapV2Router02(newRouterAddress);
    }

    //合约内部更新每日收益率
    function updateRecordsWithLatestInterestRates() internal {
		for (uint i0 = 0; i0 < numberOfAddressesCurrentlyStaked; i0++){
			record memory thisRecord = informationAboutStakeScheme[addressStore[i0]];
			informationAboutStakeScheme[addressStore[i0]]  = record (thisRecord.stakeTime, thisRecord.stakeAmt, minUIntPair(block.timestamp, (thisRecord.stakeTime + (uint256(700) * uint256(864)))), (thisRecord.accumulatedInterestToUpdateTime + ((thisRecord.stakeAmt * (minUIntPair(block.timestamp, (thisRecord.stakeTime + (uint256(700) * uint256(864)))) - thisRecord.lastUpdateTime) * dailyInterestRate) / uint256(86400000000))), thisRecord.amtWithdrawn,thisRecord.Fish);
		}
	}

    //计算挖矿利息
    function interestEarnedUpToNowBeforeTaxesAndNotYetWithdrawn(address _address) public view returns (uint256) {
		record memory thisRecord = informationAboutStakeScheme[_address];
		return (thisRecord.accumulatedInterestToUpdateTime + ((thisRecord.stakeAmt * (minUIntPair(block.timestamp, (thisRecord.stakeTime + (uint256(3000) * uint256(864)))) - thisRecord.lastUpdateTime) * dailyInterestRate) / uint256(86400000000)));
	}

    //领取质押利息
    function withdrawInterestWithoutUnstaking(uint256 _withdrawalAmt) public {
		uint256 totalInterestEarnedTillNow = interestEarnedUpToNowBeforeTaxesAndNotYetWithdrawn(msg.sender);
		require((_withdrawalAmt <= totalInterestEarnedTillNow), "Withdrawn amount must be less than withdrawable amount");
		record memory thisRecord = informationAboutStakeScheme[msg.sender];
		informationAboutStakeScheme[msg.sender]  = record (thisRecord.stakeTime, thisRecord.stakeAmt, minUIntPair(block.timestamp, (thisRecord.stakeTime + (uint256(3000) * uint256(864)))), (totalInterestEarnedTillNow - _withdrawalAmt), (thisRecord.amtWithdrawn + _withdrawalAmt),thisRecord.Fish);
		require((ERC20(address(0x7f69BeD01c397D64205CC2e9D1d81Bbc6958fE84)).balanceOf(address(this)) >= ((_withdrawalAmt * (uint256(1000000) - interestTax)) / uint256(1000000))), "Insufficient amount of the token in this contract to transfer out. Please contact the contract owner to top up the token.");
		if ((((_withdrawalAmt * (uint256(1000000) - interestTax)) / uint256(1000000)) > uint256(0))){
			ERC20(address(0x7f69BeD01c397D64205CC2e9D1d81Bbc6958fE84)).transfer(msg.sender, ((_withdrawalAmt * (uint256(1000000) - interestTax)) / uint256(1000000)));
		}

		totalWithdrawals  = (totalWithdrawals + ((_withdrawalAmt * (uint256(1000000) - interestTax)) / uint256(1000000)));
        
	}

	function sendMeNativeCurrency() external payable {
	}
}