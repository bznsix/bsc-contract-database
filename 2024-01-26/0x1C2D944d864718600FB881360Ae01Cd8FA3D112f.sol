pragma solidity >=0.7.0 <0.9.0;
// SPDX-License-Identifier: MIT

interface ERC20{
	function balanceOf(address account) external view returns (uint256);
	function transfer(address recipient, uint256 amount) external returns (bool);
	function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
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

contract BTXJStaking {

    using SafeMath for uint256;
    IUniswapV2Router02 public pancakeSwapRouter;
    address public token;
	address owner;

    receive() external payable {}

	uint256 public interestAmtInBank = uint256(0);
	uint256 public principalAmtInBank = uint256(0);
	
    struct record1 { 
        uint256 stakeTime; 
        uint256 stakeAmt; 
        uint256 lastUpdateTime; 
        uint256 accumulatedInterestToUpdateTime; 
        uint256 amtWithdrawn; 
    }

    struct record2 { 
        uint256 stakeTime; 
        uint256 stakeAmt; 
        uint256 lastUpdateTime; 
        uint256 accumulatedInterestToUpdateTime; 
        uint256 amtWithdrawn; 
    }

    struct record3 { 
        uint256 stakeTime; 
        uint256 stakeAmt; 
        uint256 lastUpdateTime; 
        uint256 accumulatedInterestToUpdateTime; 
        uint256 amtWithdrawn; 
    }

    struct record4 {
        uint256 stakeTime;
        uint256 stakeAmt;
        uint256 lastUpdateTime;
        uint256 accumulatedInterestToUpdateTime;
        uint256 amtWithdrawn;
    }

	mapping(address => record1) public informationAboutStakeScheme1;
    mapping(address => record2) public informationAboutStakeScheme2;
    mapping(address => record3) public informationAboutStakeScheme3;
    mapping(address => record4) public informationAboutStakeScheme4;

	mapping(uint256 => address) public addressStore1;
    mapping(uint256 => address) public addressStore2;
    mapping(uint256 => address) public addressStore3;
    mapping(uint256 => address) public addressStore4;

	uint256 public numberOfAddressesCurrentlyStaked1 = uint256(0);
    uint256 public numberOfAddressesCurrentlyStaked2 = uint256(0);
    uint256 public numberOfAddressesCurrentlyStaked3 = uint256(0);
    uint256 public numberOfAddressesCurrentlyStaked4 = uint256(0);

	uint256 public minStakeAmt = uint256(100000000000000000000);
	uint256 public maxStakeAmt = uint256(1000000000000000000000);
	uint256 public principalWithdrawalTax = uint256(0);
	uint256 public interestTax = uint256(50000);
	
    uint256 public dailyInterestRate1 = uint256(8000);
    uint256 public dailyInterestRate2 = uint256(10000);
    uint256 public dailyInterestRate3 = uint256(12000);
    uint256 public dailyInterestRate4 = uint256(15000);
	
    uint256 public minStakePeriod1 = (uint256(700) * uint256(864));
    uint256 public minStakePeriod2 = (uint256(1500) * uint256(864));
    uint256 public minStakePeriod3 = (uint256(3000) * uint256(864));

	uint256 public totalWithdrawals1 = uint256(0);
    uint256 public totalWithdrawals2 = uint256(0);
    uint256 public totalWithdrawals3 = uint256(0);
    uint256 public totalWithdrawals4 = uint256(0);
	
	struct referralRecord { 
        bool hasDeposited;
        bool hasMadeValidReferral; 
        address referringAddress; 
        uint256 unclaimedRewards;
        uint256 validDirectReferrals; 
        }
    
    mapping(address => referralRecord) public referralRecordMap;
	event ReferralAddressAdded (address indexed referredAddress);
	uint256 public totalClaimedRewards = uint256(0);
	event Staked (address indexed account);
	event Unstaked (address indexed account);

    constructor(address _pancakeSwapRouter, address _token) {
        
        pancakeSwapRouter = IUniswapV2Router02(_pancakeSwapRouter);
        token = _token;
        owner = msg.sender;
    }

	//This function allows the owner to specify an address that will take over ownership rights instead. Please double check the address provided as once the function is executed, only the new owner will be able to change the address back.
	function changeOwner(address _newOwner) public onlyOwner {
		owner = _newOwner;
	}

	modifier onlyOwner() {
		require(msg.sender == owner);
		_;
	}

	function minUIntPair(uint _i, uint _j) internal pure returns (uint){
		if (_i < _j){
			return _i;
		}else{
			return _j;
		}
	}

	function changeValueOf_minStakeAmt(uint256 _minStakeAmt) external onlyOwner {
		minStakeAmt  = _minStakeAmt;
	}

	function changeValueOf_maxStakeAmt(uint256 _maxStakeAmt) external onlyOwner {
		maxStakeAmt  = _maxStakeAmt;
	}

	function changeValueOf_principalWithdrawalTax(uint256 _principalWithdrawalTax) external onlyOwner {
		principalWithdrawalTax  = _principalWithdrawalTax;
	}

	function changeValueOf_interestTax(uint256 _interestTax) external onlyOwner {
		interestTax  = _interestTax;
	}

	function changeValueOf_minStakePeriod1(uint256 _minStakePeriod) external onlyOwner {
		minStakePeriod1  = _minStakePeriod;
	}

    function changeValueOf_minStakePeriod2(uint256 _minStakePeriod) external onlyOwner {
		minStakePeriod2  = _minStakePeriod;
	}

    function changeValueOf_minStakePeriod3(uint256 _minStakePeriod) external onlyOwner {
		minStakePeriod3  = _minStakePeriod;
	}

	function addReferralAddress(address _referringAddress) external {
		require(referralRecordMap[_referringAddress].hasDeposited, "Referring Address has not made a deposit");
		require(!((_referringAddress == msg.sender)), "Self-referrals are not allowed");
		require((referralRecordMap[msg.sender].referringAddress == address(0)), "User has previously indicated a referral address");
		referralRecordMap[msg.sender].referringAddress  = _referringAddress;
		emit ReferralAddressAdded(msg.sender);
	}

	function withdrawReferral(uint256 _amt) public {
		require(hasActiveStake(msg.sender), "No active stake found"); //判断当前是否有质押记录
        require((referralRecordMap[msg.sender].unclaimedRewards >= _amt), "Insufficient referral rewards to withdraw");
		referralRecordMap[msg.sender].unclaimedRewards  = (referralRecordMap[msg.sender].unclaimedRewards - _amt);
		totalClaimedRewards  = (totalClaimedRewards + _amt);
		require((ERC20(address(0x75Eee84ab02E6FECD8e94ba07dc8757289fc6241)).balanceOf(address(this)) >= _amt), "Insufficient amount of the token in this contract to transfer out. Please contact the contract owner to top up the token.");
		if ((_amt > uint256(0))){
			ERC20(address(0x75Eee84ab02E6FECD8e94ba07dc8757289fc6241)).transfer(msg.sender, _amt);
		}
	}

	// 计算常规挖矿推荐收益
	function addReferral1(uint256 stakeEarnings) internal returns (uint256) {
		address referringAddress = referralRecordMap[msg.sender].referringAddress;
		address level2Referrer = address(0);
        address level3Referrer = address(0);
        address level4Referrer = address(0);
        address level5Referrer = address(0);
        address level6Referrer = address(0);
        address level7Referrer = address(0);
        address level8Referrer = address(0);
        uint256 referralsAllocated = 0;

		if (!(referralRecordMap[msg.sender].hasDeposited)) {
			referralRecordMap[msg.sender].hasDeposited = true;
		}

        if ((referringAddress == address(0))) {
            return referralsAllocated;
        }

        uint256 reward = (stakeEarnings * 5) / 100; // 使用传递的收益计算奖励

		// 1st level referral
        referralRecordMap[referringAddress].unclaimedRewards += reward;
        referralsAllocated += reward;

        // Check 2nd level referral
        level2Referrer = referralRecordMap[referringAddress].referringAddress;
        if (level2Referrer != address(0)) {

            if (referralRecordMap[level2Referrer].validDirectReferrals >= 2) {
                referralRecordMap[level2Referrer].unclaimedRewards += reward;
                referralsAllocated += reward;
            }

                // Check 3rd level referral
                level3Referrer = referralRecordMap[level2Referrer].referringAddress;
                if (level3Referrer != address(0)) {

                    if (referralRecordMap[level3Referrer].validDirectReferrals >= 3) {
                        referralRecordMap[level3Referrer].unclaimedRewards += reward;
                        referralsAllocated += reward;
                    }

                    // Check 4rd level referral
                    level4Referrer = referralRecordMap[level3Referrer].referringAddress;
                    if (level4Referrer != address(0)) {

                        if (referralRecordMap[level4Referrer].validDirectReferrals >= 4) {
                            referralRecordMap[level4Referrer].unclaimedRewards += reward;
                            referralsAllocated += reward;
                        }

                        // Check 5rd level referral
                        level5Referrer = referralRecordMap[level4Referrer].referringAddress;
                        if (level5Referrer != address(0)) {

                            if (referralRecordMap[level5Referrer].validDirectReferrals >= 5) {
                                referralRecordMap[level5Referrer].unclaimedRewards += reward;
                                referralsAllocated += reward;
                            }

                            // Check 6rd level referral
                            level6Referrer = referralRecordMap[level5Referrer].referringAddress;
                            if (level6Referrer != address(0)) {

                                if (referralRecordMap[level6Referrer].validDirectReferrals >= 6) {
                                    referralRecordMap[level6Referrer].unclaimedRewards += reward;
                                    referralsAllocated += reward;
                                }

                                // Check 7rd level referral
                                level7Referrer = referralRecordMap[level6Referrer].referringAddress;
                                if (level7Referrer != address(0)) {

                                    if (referralRecordMap[level7Referrer].validDirectReferrals >= 7) {
                                        referralRecordMap[level7Referrer].unclaimedRewards += reward;
                                        referralsAllocated += reward;
                                    }

                                    // Check 8rd level referral
                                    level8Referrer = referralRecordMap[level7Referrer].referringAddress;
                                    if (level8Referrer != address(0)) {

                                        if (referralRecordMap[level8Referrer].validDirectReferrals >= 8) {
                                            referralRecordMap[level8Referrer].unclaimedRewards += reward;
                                            referralsAllocated += reward;
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }

		return referralsAllocated;
    }

    function addReferral2(uint256 _amt) internal returns (uint256) {
		address referringAddress = referralRecordMap[msg.sender].referringAddress;
		uint256 referralsAllocated = uint256(0);
		if (!(referralRecordMap[msg.sender].hasDeposited)){
			referralRecordMap[msg.sender].hasDeposited  = true;
		}
		if ((referringAddress == address(0))){
			return referralsAllocated;
		}
		referralRecordMap[referringAddress].unclaimedRewards  = (referralRecordMap[referringAddress].unclaimedRewards + ((uint256(5) * _amt) / uint256(100)));
		referralsAllocated  = (referralsAllocated + ((uint256(5) * _amt) / uint256(100)));
		referringAddress  = referralRecordMap[referringAddress].referringAddress;
		if ((referringAddress == address(0))){
			return referralsAllocated;
		}
		referralRecordMap[referringAddress].unclaimedRewards  = (referralRecordMap[referringAddress].unclaimedRewards + ((uint256(2) * _amt) / uint256(100)));
		referralsAllocated  = (referralsAllocated + ((uint256(2) * _amt) / uint256(100)));
		referringAddress  = referralRecordMap[referringAddress].referringAddress;
		if ((referringAddress == address(0))){
			return referralsAllocated;
		}
		referralRecordMap[referringAddress].unclaimedRewards  = (referralRecordMap[referringAddress].unclaimedRewards + ((uint256(1) * _amt) / uint256(100)));
		referralsAllocated  = (referralsAllocated + ((uint256(1) * _amt) / uint256(100)));
		referringAddress  = referralRecordMap[referringAddress].referringAddress;
		return referralsAllocated;
	}

	//7天质押
    function stake1(uint256 _stakeAmt) public {
		require((_stakeAmt > uint256(0)), "Staked amount needs to be greater than 0");
		record1 memory thisRecord = informationAboutStakeScheme1[msg.sender];
		require((_stakeAmt >= minStakeAmt), "Less than minimum stake amount");
		require(((_stakeAmt + thisRecord.stakeAmt) <= maxStakeAmt), "More than maximum stake amount");
		require((thisRecord.stakeAmt == uint256(0)), "Need to unstake before restaking");
		
        // 检查推荐人并更新有效推荐人数
        address referrer = referralRecordMap[msg.sender].referringAddress;
        if (thisRecord.stakeAmt == 0 && referrer != address(0) && !referralRecordMap[msg.sender].hasMadeValidReferral) {
            referralRecordMap[referrer].validDirectReferrals += 1;
            referralRecordMap[msg.sender].hasMadeValidReferral = true; // 标记为已产生有效推荐
        }

        informationAboutStakeScheme1[msg.sender]  = record1 (block.timestamp, _stakeAmt, block.timestamp, uint256(0), uint256(0));
		addressStore1[numberOfAddressesCurrentlyStaked1]  = msg.sender;
		numberOfAddressesCurrentlyStaked1  = (numberOfAddressesCurrentlyStaked1 + uint256(1));
		ERC20(address(0x75Eee84ab02E6FECD8e94ba07dc8757289fc6241)).transferFrom(msg.sender, address(this), _stakeAmt);
        
        uint256 stakeEarnings = interestEarnedUpToNowBeforeTaxesAndNotYetWithdrawn1(msg.sender);
        addReferral1(stakeEarnings);
		emit Staked(msg.sender);
	}

    //15天质押
    function stake2(uint256 _stakeAmt) public {
		require((_stakeAmt > uint256(0)), "Staked amount needs to be greater than 0");
		record2 memory thisRecord = informationAboutStakeScheme2[msg.sender];
		require((_stakeAmt >= minStakeAmt), "Less than minimum stake amount");
		require(((_stakeAmt + thisRecord.stakeAmt) <= maxStakeAmt), "More than maximum stake amount");
		require((thisRecord.stakeAmt == uint256(0)), "Need to unstake before restaking");
		
        // 检查推荐人并更新有效推荐人数
        address referrer = referralRecordMap[msg.sender].referringAddress;
        if (thisRecord.stakeAmt == 0 && referrer != address(0) && !referralRecordMap[msg.sender].hasMadeValidReferral) {
            referralRecordMap[referrer].validDirectReferrals += 1;
            referralRecordMap[msg.sender].hasMadeValidReferral = true; // 标记为已产生有效推荐
        }

        informationAboutStakeScheme2[msg.sender]  = record2 (block.timestamp, _stakeAmt, block.timestamp, uint256(0), uint256(0));
		addressStore2[numberOfAddressesCurrentlyStaked2]  = msg.sender;
		numberOfAddressesCurrentlyStaked2  = (numberOfAddressesCurrentlyStaked2 + uint256(1));
		ERC20(address(0x75Eee84ab02E6FECD8e94ba07dc8757289fc6241)).transferFrom(msg.sender, address(this), _stakeAmt);
        
        uint256 stakeEarnings = interestEarnedUpToNowBeforeTaxesAndNotYetWithdrawn2(msg.sender);
        addReferral1(stakeEarnings);

		emit Staked(msg.sender);
	}

    //30天质押
    function stake3(uint256 _stakeAmt) public {
		require((_stakeAmt > uint256(0)), "Staked amount needs to be greater than 0");
		record3 memory thisRecord = informationAboutStakeScheme3[msg.sender];
		require((_stakeAmt >= minStakeAmt), "Less than minimum stake amount");
		require(((_stakeAmt + thisRecord.stakeAmt) <= maxStakeAmt), "More than maximum stake amount");
		require((thisRecord.stakeAmt == uint256(0)), "Need to unstake before restaking");
		
        // 检查推荐人并更新有效推荐人数
        address referrer = referralRecordMap[msg.sender].referringAddress;
        if (thisRecord.stakeAmt == 0 && referrer != address(0) && !referralRecordMap[msg.sender].hasMadeValidReferral) {
            referralRecordMap[referrer].validDirectReferrals += 1;
            referralRecordMap[msg.sender].hasMadeValidReferral = true; // 标记为已产生有效推荐
        }
        
        informationAboutStakeScheme3[msg.sender]  = record3 (block.timestamp, _stakeAmt, block.timestamp, uint256(0), uint256(0));
		addressStore3[numberOfAddressesCurrentlyStaked3]  = msg.sender;
		numberOfAddressesCurrentlyStaked3  = (numberOfAddressesCurrentlyStaked3 + uint256(1));
		ERC20(address(0x75Eee84ab02E6FECD8e94ba07dc8757289fc6241)).transferFrom(msg.sender, address(this), _stakeAmt);
        
        uint256 stakeEarnings = interestEarnedUpToNowBeforeTaxesAndNotYetWithdrawn3(msg.sender);
        addReferral1(stakeEarnings);

		emit Staked(msg.sender);
	}

	//解除质押7天
    function unstake1(uint256 _unstakeAmt) public {
		record1 memory thisRecord = informationAboutStakeScheme1[msg.sender];
		require((_unstakeAmt <= thisRecord.stakeAmt), "Withdrawing more than staked amount");
		require(((block.timestamp - minStakePeriod1) >= thisRecord.stakeTime), "Insufficient stake period");
		uint256 newAccum = (thisRecord.accumulatedInterestToUpdateTime + ((thisRecord.stakeAmt * (minUIntPair(block.timestamp, (thisRecord.stakeTime + (uint256(700) * uint256(864)))) - thisRecord.lastUpdateTime) * dailyInterestRate1) / uint256(86400000000)));
		uint256 interestToRemove = ((newAccum * _unstakeAmt) / thisRecord.stakeAmt);
		principalAmtInBank  = (principalAmtInBank + ((_unstakeAmt * principalWithdrawalTax * uint256(100)) / uint256(100000000)));
		interestAmtInBank  = (interestAmtInBank + ((interestToRemove * interestTax * uint256(100)) / uint256(100000000)));
		if ((_unstakeAmt == thisRecord.stakeAmt)){
			for (uint i0 = 0; i0 < numberOfAddressesCurrentlyStaked1; i0++){
				if ((addressStore1[i0] == msg.sender)){
					addressStore1[i0]  = addressStore1[(numberOfAddressesCurrentlyStaked1 - uint256(1))];
					numberOfAddressesCurrentlyStaked1  = (numberOfAddressesCurrentlyStaked1 - uint256(1));
					break;
				}
			}
		}
		informationAboutStakeScheme1[msg.sender]  = record1 (thisRecord.stakeTime, (thisRecord.stakeAmt - _unstakeAmt), block.timestamp, (newAccum - interestToRemove), (thisRecord.amtWithdrawn + interestToRemove));
		
        addReferral1(interestToRemove); // 更新推荐奖励

        emit Unstaked(msg.sender);
		require((ERC20(address(0x75Eee84ab02E6FECD8e94ba07dc8757289fc6241)).balanceOf(address(this)) >= (((_unstakeAmt * (uint256(1000000) - principalWithdrawalTax)) / uint256(1000000)) + ((interestToRemove * (uint256(1000000) - interestTax)) / uint256(1000000)))), "Insufficient amount of the token in this contract to transfer out. Please contact the contract owner to top up the token.");
		if (((((_unstakeAmt * (uint256(1000000) - principalWithdrawalTax)) / uint256(1000000)) + ((interestToRemove * (uint256(1000000) - interestTax)) / uint256(1000000))) > uint256(0))){
			ERC20(address(0x75Eee84ab02E6FECD8e94ba07dc8757289fc6241)).transfer(msg.sender, (((_unstakeAmt * (uint256(1000000) - principalWithdrawalTax)) / uint256(1000000)) + ((interestToRemove * (uint256(1000000) - interestTax)) / uint256(1000000))));
		}
		totalWithdrawals1  = (totalWithdrawals1 + ((interestToRemove * (uint256(1000000) - interestTax)) / uint256(1000000)));
	}

    //解除质押15天
    function unstake2(uint256 _unstakeAmt) public {
		record2 memory thisRecord = informationAboutStakeScheme2[msg.sender];
		require((_unstakeAmt <= thisRecord.stakeAmt), "Withdrawing more than staked amount");
		require(((block.timestamp - minStakePeriod2) >= thisRecord.stakeTime), "Insufficient stake period");
		uint256 newAccum = (thisRecord.accumulatedInterestToUpdateTime + ((thisRecord.stakeAmt * (minUIntPair(block.timestamp, (thisRecord.stakeTime + (uint256(1500) * uint256(864)))) - thisRecord.lastUpdateTime) * dailyInterestRate2) / uint256(86400000000)));
		uint256 interestToRemove = ((newAccum * _unstakeAmt) / thisRecord.stakeAmt);
		principalAmtInBank  = (principalAmtInBank + ((_unstakeAmt * principalWithdrawalTax * uint256(100)) / uint256(100000000)));
		interestAmtInBank  = (interestAmtInBank + ((interestToRemove * interestTax * uint256(100)) / uint256(100000000)));
		if ((_unstakeAmt == thisRecord.stakeAmt)){
			for (uint i0 = 0; i0 < numberOfAddressesCurrentlyStaked2; i0++){
				if ((addressStore2[i0] == msg.sender)){
					addressStore2[i0]  = addressStore2[(numberOfAddressesCurrentlyStaked2 - uint256(1))];
					numberOfAddressesCurrentlyStaked2  = (numberOfAddressesCurrentlyStaked2 - uint256(1));
					break;
				}
			}
		}
		informationAboutStakeScheme2[msg.sender]  = record2 (thisRecord.stakeTime, (thisRecord.stakeAmt - _unstakeAmt), block.timestamp, (newAccum - interestToRemove), (thisRecord.amtWithdrawn + interestToRemove));
		
        addReferral1(interestToRemove); // 更新推荐奖励

        emit Unstaked(msg.sender);
		require((ERC20(address(0x75Eee84ab02E6FECD8e94ba07dc8757289fc6241)).balanceOf(address(this)) >= (((_unstakeAmt * (uint256(1000000) - principalWithdrawalTax)) / uint256(1000000)) + ((interestToRemove * (uint256(1000000) - interestTax)) / uint256(1000000)))), "Insufficient amount of the token in this contract to transfer out. Please contact the contract owner to top up the token.");
		if (((((_unstakeAmt * (uint256(1000000) - principalWithdrawalTax)) / uint256(1000000)) + ((interestToRemove * (uint256(1000000) - interestTax)) / uint256(1000000))) > uint256(0))){
			ERC20(address(0x75Eee84ab02E6FECD8e94ba07dc8757289fc6241)).transfer(msg.sender, (((_unstakeAmt * (uint256(1000000) - principalWithdrawalTax)) / uint256(1000000)) + ((interestToRemove * (uint256(1000000) - interestTax)) / uint256(1000000))));
		}
		totalWithdrawals2  = (totalWithdrawals2 + ((interestToRemove * (uint256(1000000) - interestTax)) / uint256(1000000)));
	}

    //解除质押30天
    function unstake3(uint256 _unstakeAmt) public {
		record3 memory thisRecord = informationAboutStakeScheme3[msg.sender];
		require((_unstakeAmt <= thisRecord.stakeAmt), "Withdrawing more than staked amount");
		require(((block.timestamp - minStakePeriod3) >= thisRecord.stakeTime), "Insufficient stake period");
		uint256 newAccum = (thisRecord.accumulatedInterestToUpdateTime + ((thisRecord.stakeAmt * (minUIntPair(block.timestamp, (thisRecord.stakeTime + (uint256(3000) * uint256(864)))) - thisRecord.lastUpdateTime) * dailyInterestRate3) / uint256(86400000000)));
		uint256 interestToRemove = ((newAccum * _unstakeAmt) / thisRecord.stakeAmt);
		principalAmtInBank  = (principalAmtInBank + ((_unstakeAmt * principalWithdrawalTax * uint256(100)) / uint256(100000000)));
		interestAmtInBank  = (interestAmtInBank + ((interestToRemove * interestTax * uint256(100)) / uint256(100000000)));
		if ((_unstakeAmt == thisRecord.stakeAmt)){
			for (uint i0 = 0; i0 < numberOfAddressesCurrentlyStaked3; i0++){
				if ((addressStore3[i0] == msg.sender)){
					addressStore3[i0]  = addressStore3[(numberOfAddressesCurrentlyStaked3 - uint256(1))];
					numberOfAddressesCurrentlyStaked3  = (numberOfAddressesCurrentlyStaked3 - uint256(1));
					break;
				}
			}
		}
		informationAboutStakeScheme3[msg.sender]  = record3 (thisRecord.stakeTime, (thisRecord.stakeAmt - _unstakeAmt), block.timestamp, (newAccum - interestToRemove), (thisRecord.amtWithdrawn + interestToRemove));
		
        addReferral1(interestToRemove); // 更新推荐奖励

        emit Unstaked(msg.sender);
		require((ERC20(address(0x75Eee84ab02E6FECD8e94ba07dc8757289fc6241)).balanceOf(address(this)) >= (((_unstakeAmt * (uint256(1000000) - principalWithdrawalTax)) / uint256(1000000)) + ((interestToRemove * (uint256(1000000) - interestTax)) / uint256(1000000)))), "Insufficient amount of the token in this contract to transfer out. Please contact the contract owner to top up the token.");
		if (((((_unstakeAmt * (uint256(1000000) - principalWithdrawalTax)) / uint256(1000000)) + ((interestToRemove * (uint256(1000000) - interestTax)) / uint256(1000000))) > uint256(0))){
			ERC20(address(0x75Eee84ab02E6FECD8e94ba07dc8757289fc6241)).transfer(msg.sender, (((_unstakeAmt * (uint256(1000000) - principalWithdrawalTax)) / uint256(1000000)) + ((interestToRemove * (uint256(1000000) - interestTax)) / uint256(1000000))));
		}
		totalWithdrawals3  = (totalWithdrawals3 + ((interestToRemove * (uint256(1000000) - interestTax)) / uint256(1000000)));
	}

	function updateRecordsWithLatestInterestRates1() internal {
		for (uint i0 = 0; i0 < numberOfAddressesCurrentlyStaked1; i0++){
			record1 memory thisRecord = informationAboutStakeScheme1[addressStore1[i0]];
			informationAboutStakeScheme1[addressStore1[i0]]  = record1 (thisRecord.stakeTime, thisRecord.stakeAmt, minUIntPair(block.timestamp, (thisRecord.stakeTime + (uint256(700) * uint256(864)))), (thisRecord.accumulatedInterestToUpdateTime + ((thisRecord.stakeAmt * (minUIntPair(block.timestamp, (thisRecord.stakeTime + (uint256(700) * uint256(864)))) - thisRecord.lastUpdateTime) * dailyInterestRate1) / uint256(86400000000))), thisRecord.amtWithdrawn);
		}
	}

    function updateRecordsWithLatestInterestRates2() internal {
		for (uint i0 = 0; i0 < numberOfAddressesCurrentlyStaked2; i0++){
			record2 memory thisRecord = informationAboutStakeScheme2[addressStore2[i0]];
			informationAboutStakeScheme2[addressStore2[i0]]  = record2 (thisRecord.stakeTime, thisRecord.stakeAmt, minUIntPair(block.timestamp, (thisRecord.stakeTime + (uint256(1500) * uint256(864)))), (thisRecord.accumulatedInterestToUpdateTime + ((thisRecord.stakeAmt * (minUIntPair(block.timestamp, (thisRecord.stakeTime + (uint256(1500) * uint256(864)))) - thisRecord.lastUpdateTime) * dailyInterestRate2) / uint256(86400000000))), thisRecord.amtWithdrawn);
		}
	}

    function updateRecordsWithLatestInterestRates3() internal {
		for (uint i0 = 0; i0 < numberOfAddressesCurrentlyStaked3; i0++){
			record3 memory thisRecord = informationAboutStakeScheme3[addressStore3[i0]];
			informationAboutStakeScheme3[addressStore2[i0]]  = record3 (thisRecord.stakeTime, thisRecord.stakeAmt, minUIntPair(block.timestamp, (thisRecord.stakeTime + (uint256(3000) * uint256(864)))), (thisRecord.accumulatedInterestToUpdateTime + ((thisRecord.stakeAmt * (minUIntPair(block.timestamp, (thisRecord.stakeTime + (uint256(3000) * uint256(864)))) - thisRecord.lastUpdateTime) * dailyInterestRate3) / uint256(86400000000))), thisRecord.amtWithdrawn);
		}
	}

    function updateRecordsWithLatestInterestRates4() internal {
		for (uint i0 = 0; i0 < numberOfAddressesCurrentlyStaked4; i0++){
			record4 memory thisRecord = informationAboutStakeScheme4[addressStore3[i0]];
			informationAboutStakeScheme4[addressStore2[i0]]  = record4 (thisRecord.stakeTime, thisRecord.stakeAmt, minUIntPair(block.timestamp, (thisRecord.stakeTime + (uint256(3000) * uint256(864)))), (thisRecord.accumulatedInterestToUpdateTime + ((thisRecord.stakeAmt * (minUIntPair(block.timestamp, (thisRecord.stakeTime + (uint256(3000) * uint256(864)))) - thisRecord.lastUpdateTime) * dailyInterestRate4) / uint256(86400000000))), thisRecord.amtWithdrawn);
		}
	}

	function interestEarnedUpToNowBeforeTaxesAndNotYetWithdrawn1(address _address) public view returns (uint256) {
		record1 memory thisRecord = informationAboutStakeScheme1[_address];
		return (thisRecord.accumulatedInterestToUpdateTime + ((thisRecord.stakeAmt * (minUIntPair(block.timestamp, (thisRecord.stakeTime + (uint256(700) * uint256(864)))) - thisRecord.lastUpdateTime) * dailyInterestRate1) / uint256(86400000000)));
	}

    function interestEarnedUpToNowBeforeTaxesAndNotYetWithdrawn2(address _address) public view returns (uint256) {
		record2 memory thisRecord = informationAboutStakeScheme2[_address];
		return (thisRecord.accumulatedInterestToUpdateTime + ((thisRecord.stakeAmt * (minUIntPair(block.timestamp, (thisRecord.stakeTime + (uint256(1500) * uint256(864)))) - thisRecord.lastUpdateTime) * dailyInterestRate2) / uint256(86400000000)));
	}

    function interestEarnedUpToNowBeforeTaxesAndNotYetWithdrawn3(address _address) public view returns (uint256) {
		record3 memory thisRecord = informationAboutStakeScheme3[_address];
		return (thisRecord.accumulatedInterestToUpdateTime + ((thisRecord.stakeAmt * (minUIntPair(block.timestamp, (thisRecord.stakeTime + (uint256(3000) * uint256(864)))) - thisRecord.lastUpdateTime) * dailyInterestRate3) / uint256(86400000000)));
	}

    function interestEarnedUpToNowBeforeTaxesAndNotYetWithdrawn4(address _address) public view returns (uint256) {
		record4 memory thisRecord = informationAboutStakeScheme4[_address];
        return (thisRecord.accumulatedInterestToUpdateTime + ((thisRecord.stakeAmt * (minUIntPair(block.timestamp, (thisRecord.stakeTime + (uint256(3000) * uint256(864)))) - thisRecord.lastUpdateTime) * dailyInterestRate4) / uint256(86400000000)));
	}

	function totalStakedAmount1() public view returns (uint256) {
		uint256 total = uint256(0);
		for (uint i0 = 0; i0 < numberOfAddressesCurrentlyStaked1; i0++){
			record1 memory thisRecord = informationAboutStakeScheme1[addressStore1[i0]];
			total  = (total + thisRecord.stakeAmt);
		}
		return total;
	}

    function totalStakedAmount2() public view returns (uint256) {
		uint256 total = uint256(0);
		for (uint i0 = 0; i0 < numberOfAddressesCurrentlyStaked2; i0++){
			record2 memory thisRecord = informationAboutStakeScheme2[addressStore2[i0]];
			total  = (total + thisRecord.stakeAmt);
		}
		return total;
	}

    function totalStakedAmount3() public view returns (uint256) {
		uint256 total = uint256(0);
		for (uint i0 = 0; i0 < numberOfAddressesCurrentlyStaked3; i0++){
			record3 memory thisRecord = informationAboutStakeScheme3[addressStore3[i0]];
			total  = (total + thisRecord.stakeAmt);
		}
		return total;
	}

    function totalStakedAmount4() public view returns (uint256) {
		uint256 total = uint256(0);
		for (uint i0 = 0; i0 < numberOfAddressesCurrentlyStaked4; i0++){
			record4 memory thisRecord = informationAboutStakeScheme4[addressStore4[i0]];
			total  = (total + thisRecord.stakeAmt);
		}
		return total;
	}

	//不提取本金情况下领取7天收益
    function withdrawInterestWithoutUnstaking1(uint256 _withdrawalAmt) public {
		uint256 totalInterestEarnedTillNow = interestEarnedUpToNowBeforeTaxesAndNotYetWithdrawn1(msg.sender);
		require((_withdrawalAmt <= totalInterestEarnedTillNow), "Withdrawn amount must be less than withdrawable amount");
		record1 memory thisRecord = informationAboutStakeScheme1[msg.sender];
		informationAboutStakeScheme1[msg.sender]  = record1 (thisRecord.stakeTime, thisRecord.stakeAmt, minUIntPair(block.timestamp, (thisRecord.stakeTime + (uint256(700) * uint256(864)))), (totalInterestEarnedTillNow - _withdrawalAmt), (thisRecord.amtWithdrawn + _withdrawalAmt));
		require((ERC20(address(0x75Eee84ab02E6FECD8e94ba07dc8757289fc6241)).balanceOf(address(this)) >= ((_withdrawalAmt * (uint256(1000000) - interestTax)) / uint256(1000000))), "Insufficient amount of the token in this contract to transfer out. Please contact the contract owner to top up the token.");
		if ((((_withdrawalAmt * (uint256(1000000) - interestTax)) / uint256(1000000)) > uint256(0))){
			ERC20(address(0x75Eee84ab02E6FECD8e94ba07dc8757289fc6241)).transfer(msg.sender, ((_withdrawalAmt * (uint256(1000000) - interestTax)) / uint256(1000000)));
		}
		interestAmtInBank  = (interestAmtInBank + ((_withdrawalAmt * interestTax * uint256(100)) / uint256(100000000)));
		totalWithdrawals1  = (totalWithdrawals1 + ((_withdrawalAmt * (uint256(1000000) - interestTax)) / uint256(1000000)));
        
        addReferral1(_withdrawalAmt); // 更新推荐奖励
	}

    //不提取本金情况下领取15天收益
    function withdrawInterestWithoutUnstaking2(uint256 _withdrawalAmt) public {
		uint256 totalInterestEarnedTillNow = interestEarnedUpToNowBeforeTaxesAndNotYetWithdrawn2(msg.sender);
		require((_withdrawalAmt <= totalInterestEarnedTillNow), "Withdrawn amount must be less than withdrawable amount");
		record2 memory thisRecord = informationAboutStakeScheme2[msg.sender];
		informationAboutStakeScheme2[msg.sender]  = record2 (thisRecord.stakeTime, thisRecord.stakeAmt, minUIntPair(block.timestamp, (thisRecord.stakeTime + (uint256(1500) * uint256(864)))), (totalInterestEarnedTillNow - _withdrawalAmt), (thisRecord.amtWithdrawn + _withdrawalAmt));
		require((ERC20(address(0x75Eee84ab02E6FECD8e94ba07dc8757289fc6241)).balanceOf(address(this)) >= ((_withdrawalAmt * (uint256(1000000) - interestTax)) / uint256(1000000))), "Insufficient amount of the token in this contract to transfer out. Please contact the contract owner to top up the token.");
		if ((((_withdrawalAmt * (uint256(1000000) - interestTax)) / uint256(1000000)) > uint256(0))){
			ERC20(address(0x75Eee84ab02E6FECD8e94ba07dc8757289fc6241)).transfer(msg.sender, ((_withdrawalAmt * (uint256(1000000) - interestTax)) / uint256(1000000)));
		}
		interestAmtInBank  = (interestAmtInBank + ((_withdrawalAmt * interestTax * uint256(100)) / uint256(100000000)));
		totalWithdrawals2  = (totalWithdrawals2 + ((_withdrawalAmt * (uint256(1000000) - interestTax)) / uint256(1000000)));
	
        addReferral1(_withdrawalAmt); // 更新推荐奖励
    }

    //不提取本金情况下领取30天收益
    function withdrawInterestWithoutUnstaking3(uint256 _withdrawalAmt) public {
		uint256 totalInterestEarnedTillNow = interestEarnedUpToNowBeforeTaxesAndNotYetWithdrawn3(msg.sender);
		require((_withdrawalAmt <= totalInterestEarnedTillNow), "Withdrawn amount must be less than withdrawable amount");
		record3 memory thisRecord = informationAboutStakeScheme3[msg.sender];
		informationAboutStakeScheme3[msg.sender]  = record3 (thisRecord.stakeTime, thisRecord.stakeAmt, minUIntPair(block.timestamp, (thisRecord.stakeTime + (uint256(3000) * uint256(864)))), (totalInterestEarnedTillNow - _withdrawalAmt), (thisRecord.amtWithdrawn + _withdrawalAmt));
		require((ERC20(address(0x75Eee84ab02E6FECD8e94ba07dc8757289fc6241)).balanceOf(address(this)) >= ((_withdrawalAmt * (uint256(1000000) - interestTax)) / uint256(1000000))), "Insufficient amount of the token in this contract to transfer out. Please contact the contract owner to top up the token.");
		if ((((_withdrawalAmt * (uint256(1000000) - interestTax)) / uint256(1000000)) > uint256(0))){
			ERC20(address(0x75Eee84ab02E6FECD8e94ba07dc8757289fc6241)).transfer(msg.sender, ((_withdrawalAmt * (uint256(1000000) - interestTax)) / uint256(1000000)));
		}
		interestAmtInBank  = (interestAmtInBank + ((_withdrawalAmt * interestTax * uint256(100)) / uint256(100000000)));
		totalWithdrawals3  = (totalWithdrawals3 + ((_withdrawalAmt * (uint256(1000000) - interestTax)) / uint256(1000000)));
	
        addReferral1(_withdrawalAmt); // 更新推荐奖励
    }

	function modifyDailyInterestRate1(uint256 _dailyInterestRate) public onlyOwner {
		updateRecordsWithLatestInterestRates1();
		dailyInterestRate1  = _dailyInterestRate;
	}

    function modifyDailyInterestRate2(uint256 _dailyInterestRate) public onlyOwner {
		updateRecordsWithLatestInterestRates2();
		dailyInterestRate2  = _dailyInterestRate;
	}

    function modifyDailyInterestRate3(uint256 _dailyInterestRate) public onlyOwner {
		updateRecordsWithLatestInterestRates3();
		dailyInterestRate3  = _dailyInterestRate;
	}

    function modifyDailyInterestRate4(uint256 _dailyInterestRate) public onlyOwner {
		updateRecordsWithLatestInterestRates4();
		dailyInterestRate4  = _dailyInterestRate;
	}

	function interestTaxWithdrawAmt() public onlyOwner {
		require((ERC20(address(0x75Eee84ab02E6FECD8e94ba07dc8757289fc6241)).balanceOf(address(this)) >= interestAmtInBank), "Insufficient amount of the token in this contract to transfer out. Please contact the contract owner to top up the token.");
		if ((interestAmtInBank > uint256(0))){
			ERC20(address(0x75Eee84ab02E6FECD8e94ba07dc8757289fc6241)).transfer(msg.sender, interestAmtInBank);
		}
		interestAmtInBank  = uint256(0);
	}

    // 提取合约中的WBNB（或其他代币）
    function withdrawToken(address _token, uint256 _amount) public onlyOwner {
        require((IERC20(_token).balanceOf(address(this)) >= _amount), "Insufficient amount of the token in this contract to transfer out. Please contact the contract owner to top up the token.");
        IERC20(_token).transfer(msg.sender, _amount);
    }

    //提取合约中的BNB
    function withdrawTokenbnb(uint256 _amt) public onlyOwner {
		require((address(this).balance >= _amt), "Insufficient amount of native currency in this contract to transfer out. Please contact the contract owner to top up the native currency.");
		payable(msg.sender).transfer(_amt);
	}

    // 允许合约所有者设置新的token地址
    function setTokenAddress(address newTokenAddress) public onlyOwner {
        token = newTokenAddress;
    }

    // 允许合约所有者设置新的PancakeSwap路由器地址
    function setPancakeSwapRouterAddress(address newRouterAddress) public onlyOwner {
        pancakeSwapRouter = IUniswapV2Router02(newRouterAddress);
    }

    //判断当前用户是否有质押记录
    function hasActiveStake(address _user) private view returns (bool) {
        return informationAboutStakeScheme1[_user].stakeAmt > 0 ||
            informationAboutStakeScheme2[_user].stakeAmt > 0 ||
            informationAboutStakeScheme3[_user].stakeAmt > 0 ||
            informationAboutStakeScheme4[_user].stakeAmt > 0;
    }

    // 用户购买代币并自动进行质押
    function buyTokensAndStake(uint256 amountOutMin) public payable {
        require(msg.value > 0, "Must send BNB to buy tokens");

        // 检查用户是否已有质押
        record4 memory existingStakeRecord = informationAboutStakeScheme4[msg.sender];
        require(existingStakeRecord.stakeAmt == 0, "Existing stake found. Please unstake before staking again.");
        
        // 检查推荐人并更新有效推荐人数
        record4 memory thisRecord = informationAboutStakeScheme4[msg.sender];
        address referrer = referralRecordMap[msg.sender].referringAddress;
        if (thisRecord.stakeAmt == 0 && referrer != address(0) && !referralRecordMap[msg.sender].hasMadeValidReferral) {
            referralRecordMap[referrer].validDirectReferrals += 1;
            referralRecordMap[msg.sender].hasMadeValidReferral = true; // 标记为已产生有效推荐
        }

        address[] memory path = new address[](2);
        path[0] = pancakeSwapRouter.WETH();
        path[1] = token;

        uint256 initialTokenBalance = ERC20(token).balanceOf(address(this));

        // 购买代币
        pancakeSwapRouter.swapExactETHForTokensSupportingFeeOnTransferTokens{ 
            value: msg.value 
        }(
            amountOutMin,
            path,
            address(this), // 代币发送到合约地址
            block.timestamp.add(300) // 设置交易的截止时间
        );

        uint256 newTokenBalance = ERC20(token).balanceOf(address(this));
        uint256 tokensBought = newTokenBalance.sub(initialTokenBalance);

        // 进行第三周期质押
        _stake4(tokensBought);
    }

    function _stake4(uint256 _stakeAmt) private {
        record4 storage record = informationAboutStakeScheme4[msg.sender];
        record.stakeTime = block.timestamp;
        record.stakeAmt = _stakeAmt;
        record.lastUpdateTime = block.timestamp;
		
        addressStore4[numberOfAddressesCurrentlyStaked4]  = msg.sender;
		numberOfAddressesCurrentlyStaked4  = (numberOfAddressesCurrentlyStaked4 + uint256(1));
        
        addReferral2(_stakeAmt);
		emit Staked(msg.sender);
	}

    // 从 stake4 解除质押
    function unstake4(uint256 _unstakeAmt) public {
        record4 memory thisRecord = informationAboutStakeScheme4[msg.sender];
        require(((block.timestamp - minStakePeriod3) >= thisRecord.stakeTime), "Insufficient stake period");
		uint256 newAccum = (thisRecord.accumulatedInterestToUpdateTime + ((thisRecord.stakeAmt * (minUIntPair(block.timestamp, (thisRecord.stakeTime + (uint256(3000) * uint256(864)))) - thisRecord.lastUpdateTime) * dailyInterestRate4) / uint256(86400000000)));
		uint256 interestToRemove = ((newAccum * _unstakeAmt) / thisRecord.stakeAmt);
		principalAmtInBank  = (principalAmtInBank + ((_unstakeAmt * principalWithdrawalTax * uint256(100)) / uint256(100000000)));
		interestAmtInBank  = (interestAmtInBank + ((interestToRemove * interestTax * uint256(100)) / uint256(100000000)));
		if ((_unstakeAmt == thisRecord.stakeAmt)){
			for (uint i0 = 0; i0 < numberOfAddressesCurrentlyStaked4; i0++){
				if ((addressStore4[i0] == msg.sender)){
					addressStore3[i0]  = addressStore4[(numberOfAddressesCurrentlyStaked4 - uint256(1))];
					numberOfAddressesCurrentlyStaked4  = (numberOfAddressesCurrentlyStaked4 - uint256(1));
					break;
				}
			}
		}
		informationAboutStakeScheme4[msg.sender]  = record4 (thisRecord.stakeTime, (thisRecord.stakeAmt - _unstakeAmt), block.timestamp, (newAccum - interestToRemove), (thisRecord.amtWithdrawn + interestToRemove));
		
        emit Unstaked(msg.sender);
		require((ERC20(address(0x75Eee84ab02E6FECD8e94ba07dc8757289fc6241)).balanceOf(address(this)) >= (((_unstakeAmt * (uint256(1000000) - principalWithdrawalTax)) / uint256(1000000)) + ((interestToRemove * (uint256(1000000) - interestTax)) / uint256(1000000)))), "Insufficient amount of the token in this contract to transfer out. Please contact the contract owner to top up the token.");
		if (((((_unstakeAmt * (uint256(1000000) - principalWithdrawalTax)) / uint256(1000000)) + ((interestToRemove * (uint256(1000000) - interestTax)) / uint256(1000000))) > uint256(0))){
			ERC20(address(0x75Eee84ab02E6FECD8e94ba07dc8757289fc6241)).transfer(msg.sender, (((_unstakeAmt * (uint256(1000000) - principalWithdrawalTax)) / uint256(1000000)) + ((interestToRemove * (uint256(1000000) - interestTax)) / uint256(1000000))));
		}
		totalWithdrawals4  = (totalWithdrawals4 + ((interestToRemove * (uint256(1000000) - interestTax)) / uint256(1000000)));
    }

    //不提取本金情况下领取一键质押收益
    function withdrawInterestWithoutUnstaking4(uint256 _withdrawalAmt) public {
		uint256 totalInterestEarnedTillNow = interestEarnedUpToNowBeforeTaxesAndNotYetWithdrawn4(msg.sender);
		require((_withdrawalAmt <= totalInterestEarnedTillNow), "Withdrawn amount must be less than withdrawable amount");
		record4 memory thisRecord = informationAboutStakeScheme4[msg.sender];
		informationAboutStakeScheme4[msg.sender]  = record4 (thisRecord.stakeTime, thisRecord.stakeAmt, minUIntPair(block.timestamp, (thisRecord.stakeTime + (uint256(3000) * uint256(864)))), (totalInterestEarnedTillNow - _withdrawalAmt), (thisRecord.amtWithdrawn + _withdrawalAmt));
		require((ERC20(address(0x75Eee84ab02E6FECD8e94ba07dc8757289fc6241)).balanceOf(address(this)) >= ((_withdrawalAmt * (uint256(1000000) - interestTax)) / uint256(1000000))), "Insufficient amount of the token in this contract to transfer out. Please contact the contract owner to top up the token.");
		if ((((_withdrawalAmt * (uint256(1000000) - interestTax)) / uint256(1000000)) > uint256(0))){
			ERC20(address(0x75Eee84ab02E6FECD8e94ba07dc8757289fc6241)).transfer(msg.sender, ((_withdrawalAmt * (uint256(1000000) - interestTax)) / uint256(1000000)));
		}
		interestAmtInBank  = (interestAmtInBank + ((_withdrawalAmt * interestTax * uint256(100)) / uint256(100000000)));
		totalWithdrawals4  = (totalWithdrawals4 + ((_withdrawalAmt * (uint256(1000000) - interestTax)) / uint256(1000000)));
    }

}