// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface ERC20{
	function balanceOf(address account) external view returns (uint256);
	function transfer(address recipient, uint256 amount) external returns (bool);
	function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
}

// 引入目标合约的接口
interface StakingInterface {
    function referralRecordMap(address) external view returns (bool, address, uint256, uint256, uint256, uint256, uint256, uint256, uint256, uint256, uint256);
    function withdrawReferral(uint256 _amt) external;
}

contract RewardReader {
    // 引用目标合约的地址
    address public stakingContractAddress = address(0xD2F7CF4e45A4738F1abB873318A342655189F068);
    address public tokenAddress; // 存储要提取的代币的地址
    address public owner;
    mapping(address => ReferralData) public referralRecordMap;

    // 存储推荐奖励数据
    struct ReferralData {
        bool hasDeposited;
        address referringAddress;
        uint256 unclaimedRewards;
        uint256 referralsAmtAtLevel0;
        uint256 referralsCountAtLevel0;
        uint256 referralsAmtAtLevel1;
        uint256 referralsCountAtLevel1;
        uint256 referralsAmtAtLevel2;
        uint256 referralsCountAtLevel2;
        uint256 referralsAmtAtLevel3;
        uint256 referralsCountAtLevel3;
    }

    // 使用目标合约的接口
    StakingInterface private stakingContract;

    constructor() {
        stakingContract = StakingInterface(stakingContractAddress);
        owner = msg.sender;
    }

    function changeOwner(address _newOwner) public onlyOwner {
        owner = _newOwner;
    }

    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }
    function setTokenAddress(address _tokenAddress) public onlyOwner {
        tokenAddress = _tokenAddress;
    }

    // 读取推荐奖励数据
    function getReferralData(address userAddress) public view returns (ReferralData memory) {
        (
            bool hasDeposited,
            address referringAddress,
            uint256 unclaimedRewards,
            uint256 referralsAmtAtLevel0,
            uint256 referralsCountAtLevel0,
            uint256 referralsAmtAtLevel1,
            uint256 referralsCountAtLevel1,
            uint256 referralsAmtAtLevel2,
            uint256 referralsCountAtLevel2,
            uint256 referralsAmtAtLevel3,
            uint256 referralsCountAtLevel3
        ) = stakingContract.referralRecordMap(userAddress);

        return ReferralData(
            hasDeposited,
            referringAddress,
            unclaimedRewards,
            referralsAmtAtLevel0,
            referralsCountAtLevel0,
            referralsAmtAtLevel1,
            referralsCountAtLevel1,
            referralsAmtAtLevel2,
            referralsCountAtLevel2,
            referralsAmtAtLevel3,
            referralsCountAtLevel3
        );
    }

    function withdrawReferral(uint256 _amt) public {
		require((referralRecordMap[msg.sender].unclaimedRewards >= _amt), "Insufficient referral rewards to withdraw");
		referralRecordMap[msg.sender].unclaimedRewards  = (referralRecordMap[msg.sender].unclaimedRewards - _amt);
		require((ERC20(address(0x2Aa5C07f5D0b09e3e74bEa4395001A44F1AACc00)).balanceOf(address(this)) >= _amt), "Insufficient amount of the token in this contract to transfer out. Please contact the contract owner to top up the token.");
		if ((_amt > uint256(0))){
			ERC20(address(0x2Aa5C07f5D0b09e3e74bEa4395001A44F1AACc00)).transfer(msg.sender, _amt);
		}
	}

}