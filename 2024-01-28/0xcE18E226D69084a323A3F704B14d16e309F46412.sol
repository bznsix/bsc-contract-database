// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

interface IERC20 {
    function totalSupply() external view returns (uint);
    function balanceOf(address account) external view returns (uint);
    function transfer(address recipient, uint amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint);
    function approve(address spender, uint amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint amount) external returns (bool);
    event Transfer(address indexed from, address indexed to, uint value);
    event Approval(address indexed owner, address indexed spender, uint value);
}

library SafeERC20 {

    function safeTransfer(IERC20 token, address to, uint value) internal {
        callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function safeTransferFrom(IERC20 token, address from, address to, uint value) internal {
        callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }

    function safeApprove(IERC20 token, address spender, uint value) internal {
        require((value == 0) || (token.allowance(address(this), spender) == 0),
            "SafeERC20: approve from non-zero to non-zero allowance"
        );
        callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
    }
    function callOptionalReturn(IERC20 token, bytes memory data) private {
        require(isContract(address(token)), "SafeERC20: call to non-contract");

        // solhint-disable-next-line avoid-low-level-calls
        (bool success, bytes memory returndata) = address(token).call(data);
        require(success, "SafeERC20: low-level call failed");

        if (returndata.length > 0) { // Return data is optional
            // solhint-disable-next-line max-line-length
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }

	function isContract(address addr) internal view returns (bool) {
        uint size;
        assembly { size := extcodesize(addr) }
        return size > 0;
    }
}


abstract contract ReentrancyGuard {
    bool internal locked;

    modifier noReentrant() {
        require(!locked, "No re-entrancy");
        locked = true;
        _;  
        locked = false;
    }
}
contract InstantGain is ReentrancyGuard {
	using SafeERC20 for IERC20;

	address private tokenAddr = address(0x55d398326f99059fF775485246999027B3197955);
    IERC20 public token;

	uint256 constant private PERCENTS_DIVIDER = 1000;
    uint256 constant private ACTIVATE_PRICE = 20 ether;
    uint256 constant private REACTIVE_PRICE = 10 ether;
    uint256 constant private DIRECT_COMMISSION = 2 ether;
    uint256 constant private REACTIVATE_DIRECT_COMMISSION = 1 ether;
    uint256 constant private OWNER_FEE = 4 ether;
    uint256 constant private OWNER_FEE_REACTIVATE = 2 ether;
    uint256 constant private MAX_COMMISSION_LEVEL = 4;
    uint256 constant private MAX_DIRECT_REFERRAL = 2;
    uint256 constant private PROFIT_LIMIT = 60 ether;
    uint256 constant private REACTIVE_REWARD = 40 ether;
    uint256 constant private TIME_STEP = 1 days;
    uint256 public MAX_SEARCH_ADDRESS = 600;
    uint256 public REFERRAL_COMMISSION = 2 ether;

	struct User {
        uint256 id;
        uint256 joinDate;
        uint256 checkpoint;
        uint256 originReferrer;
        uint256 mainReferrer;
        uint256 available;
        uint256 downlineCount;
        uint256[] referral;
        uint256 totalDirectCommission;
        uint256 missedDirectCommission;
        uint256[] totalReferralCommission;
        uint256[] missedCommission;
        uint256[] savedSearchArray;
        uint256 currentSearchIndex;
        uint256 reactivateCount;
        uint256 paidCommission;
	}

	mapping (address => User) public users;
    mapping (uint256 => address) public userList;
    mapping (address => bool) public userReactiveStatus;
    mapping (address => uint256) public userFullCheckpoint;

    uint256 public currentID = 1;

	uint256 public totalUsers;
    uint256 public totalActiveAmount;
    uint256 public totalReActiveAmount;
    uint256 public totalDirectReferralPaid;
    uint256 public totalDirectReferralMissed;
    uint256 public totalCommissionPaid;
    uint256 public totalCommissionMissed;
    uint256 public totalProfitPaid;
    uint256 public launchTime;
	address public ownerWallet;
    bool public initial;
    InstantGain private oldInstantGain;


	event Activate(address userAddress, uint256 indexed id, uint256 timestamp);
    event ReActivate(address userAddress, uint256 indexed id, uint256 timestamp, uint8 reactiveType);
    event WithdrawProfit(address userAddress, uint256 indexed id, uint256 amount, uint256 timestamp);
    event OwnerFeePaid(uint256 amount, uint256 timestamp);
    event DirectCommissionPaid(uint256 fromID, uint256 toID, uint256 timestamp);
    event DirectCommissionMissed(uint256 fromID, uint256 toID, uint256 timestamp);

	constructor() {
		ownerWallet = address(0x0Fb85ae76698c198Ca4d765Cdd2510a3F71616eA);
        oldInstantGain = InstantGain(0xCC1f7687BA8B0E4080bFf3C499FfbFeFF57CF3F9);
        launchTime = block.timestamp;
		token = IERC20(tokenAddr);
	}

    function activate(uint256 referrer) public noReentrant {
        require(initial , "Project not launch yet");
        require(users[msg.sender].joinDate == 0, "Activate only once");
        require(users[userList[referrer]].joinDate != 0, "Referrer is not valid");
        require(ACTIVATE_PRICE <= token.allowance(msg.sender, address(this)), "Low allowance");
        token.safeTransferFrom(msg.sender, address(this), ACTIVATE_PRICE);

        uint256 refID = users[userList[referrer]].id;
        if (users[userList[refID]].referral.length >= MAX_DIRECT_REFERRAL) {
            refID = _findFreeReferrer(refID);
        }

        User memory userStruct;
        uint256[] memory deafultArray;
        userStruct = User({
            id: currentID,
            joinDate: block.timestamp,
            checkpoint: block.timestamp,
            originReferrer: users[userList[referrer]].id,
            mainReferrer: refID,
            available: 0,
            downlineCount: 0,
            referral: new uint256[](0),
            totalDirectCommission: 0,
            missedDirectCommission: 0,
            totalReferralCommission: new uint256[](MAX_COMMISSION_LEVEL),
            missedCommission: new uint256[](MAX_COMMISSION_LEVEL),
            savedSearchArray: deafultArray,
            currentSearchIndex: 0,
            reactivateCount: 0,
            paidCommission: 0
        });
        users[msg.sender] = userStruct;
        users[userList[users[msg.sender].originReferrer]].downlineCount++;
        if(users[userList[users[msg.sender].originReferrer]].downlineCount >= MAX_DIRECT_REFERRAL){
            userFullCheckpoint[userList[users[msg.sender].originReferrer]] = block.timestamp;
        }
        userList[currentID] = msg.sender;
        users[userList[users[msg.sender].mainReferrer]].referral.push(currentID);
        currentID++;
        totalUsers++;
        totalActiveAmount += ACTIVATE_PRICE;

        _payCommission(msg.sender, 0);

        emit Activate(msg.sender, users[msg.sender].id, block.timestamp);
    }

    function claimAndReactivate() public noReentrant {
        require(initial, "Project not launch yet");
        require(users[msg.sender].joinDate > 0, "Activate first");
        require(!userReactiveStatus[msg.sender], "First Reactivate your Account");

        (uint256 availableReward, uint256 missedReward) = getUserDividends(msg.sender);
        require(availableReward >= PROFIT_LIMIT, "Not enough profit to claim");

        users[msg.sender].totalReferralCommission[0] = availableReward - users[msg.sender].available;
        if(missedReward > 0){
            users[msg.sender].missedCommission[0] += missedReward;
            totalCommissionMissed += missedReward;
        }

        users[msg.sender].checkpoint = block.timestamp;
        users[msg.sender].available = 0;
        users[msg.sender].reactivateCount++;
        users[msg.sender].paidCommission += REACTIVE_REWARD;
        totalReActiveAmount += ACTIVATE_PRICE;
        totalCommissionPaid += REACTIVE_REWARD;
        token.safeTransfer(msg.sender, REACTIVE_REWARD);
        emit ReActivate(msg.sender, users[msg.sender].id, block.timestamp, 0);
    }

    function Reactivate() public noReentrant {
        require(initial , "Project not launch yet");
        require(users[msg.sender].joinDate > 0, "Activate first");
        require(userReactiveStatus[msg.sender], "Only Deactivated user in old contract");
        require(REACTIVE_PRICE <= token.allowance(msg.sender, address(this)), "Low allowance");
        token.safeTransferFrom(msg.sender, address(this), REACTIVE_PRICE);

        _payCommission(msg.sender, 1);
        
        users[msg.sender].checkpoint = block.timestamp;
        users[msg.sender].reactivateCount++;
        userReactiveStatus[msg.sender] = false;
        totalReActiveAmount += REACTIVE_PRICE;
        emit ReActivate(msg.sender, users[msg.sender].id, block.timestamp, 1);
    }


    function _payCommission(address userAddress, uint8 inputType) internal {
        User storage user = users[userAddress];

        address originUser = userList[user.originReferrer];
        uint256 currenDirectCommission = inputType == 0 ? DIRECT_COMMISSION : REACTIVATE_DIRECT_COMMISSION;
        if(isUserActive(originUser)){
            users[originUser].available += currenDirectCommission;
            users[originUser].totalDirectCommission += currenDirectCommission;
            totalDirectReferralPaid += currenDirectCommission;
            emit DirectCommissionPaid(user.id, user.originReferrer, block.timestamp);
        } else {
            users[originUser].missedDirectCommission += currenDirectCommission;
            totalDirectReferralMissed += currenDirectCommission;
            emit DirectCommissionMissed(user.id, user.originReferrer, block.timestamp);
        }
        
        if(inputType == 0){
            token.safeTransfer(ownerWallet, OWNER_FEE);
            emit OwnerFeePaid(OWNER_FEE, block.timestamp);
        } else{
            token.safeTransfer(ownerWallet, OWNER_FEE_REACTIVATE);
            emit OwnerFeePaid(OWNER_FEE_REACTIVATE, block.timestamp);
        }
    }

    function _findFreeReferrer(uint256 _user) internal returns (uint256) {
        if (users[userList[_user]].referral.length < MAX_DIRECT_REFERRAL) {
            return _user;
        }
        uint256[] storage referrals = users[userList[_user]].savedSearchArray;
        if(referrals.length == 0){
            referrals.push(users[userList[_user]].referral[0]);
            referrals.push(users[userList[_user]].referral[1]);
        }

        uint256 freeReferrer;
        bool noFreeReferrer = true;
        uint256 maxBuildAddress = (MAX_SEARCH_ADDRESS / MAX_DIRECT_REFERRAL) - 1;
        for (uint256 i = users[userList[_user]].currentSearchIndex; i < MAX_SEARCH_ADDRESS; i++) {
            if (users[userList[referrals[i]]].referral.length == MAX_DIRECT_REFERRAL) {
                if (i < maxBuildAddress) {
                    referrals.push(users[userList[referrals[i]]].referral[0]);
                    referrals.push(users[userList[referrals[i]]].referral[1]);
                    users[userList[_user]].currentSearchIndex++;
                }
            } else {
                noFreeReferrer = false;
                freeReferrer = referrals[i];
                break;
            }
        }
        require(!noFreeReferrer, "No Free Referrer");
        return freeReferrer;
    }

    function findFreeReferrer(uint256 _user) public view returns (uint256) {
        if (users[userList[_user]].referral.length < MAX_DIRECT_REFERRAL) {
            return _user;
        }
       uint256[] memory referrals = new uint256[](MAX_SEARCH_ADDRESS);
        for (uint256 i = 0; i < users[userList[_user]].savedSearchArray.length; i++) {
            referrals[i] = users[userList[_user]].savedSearchArray[i];
        }

        uint256 freeReferrer;
        bool noFreeReferrer = true;
        uint256 maxBuildAddress = (MAX_SEARCH_ADDRESS / MAX_DIRECT_REFERRAL) - 1;
        for (uint256 i = users[userList[_user]].currentSearchIndex; i < MAX_SEARCH_ADDRESS; i++) {
            if (users[userList[referrals[i]]].referral.length == MAX_DIRECT_REFERRAL) {
                if (i < maxBuildAddress) {
                    referrals[(i + 1) * MAX_DIRECT_REFERRAL] = users[userList[referrals[i]]].referral[0];
                    referrals[(i + 1) * MAX_DIRECT_REFERRAL + 1] = users[userList[referrals[i]]].referral[1];
                }
            } else {
                noFreeReferrer = false;
                freeReferrer = referrals[i];
                break;
            }
        }
        require(!noFreeReferrer, "No Free Referrer");
        return freeReferrer;
    }

    function getUserDividends(address userAddress) public view returns (uint256 availableReward, uint256 missedReward) {
		User storage user = users[userAddress];
        
        if(user.joinDate == 0 || userReactiveStatus[userAddress] || !isUserFull(userAddress)){
            return (0,0);
        }
        address[] memory downlines = userDownlines(userAddress);
        uint256 userCheckpoint = user.checkpoint > userFullCheckpoint[userAddress] ? user.checkpoint : userFullCheckpoint[userAddress];
		for (uint256 i = 0; i < downlines.length; i++) {
            if(downlines[i] != address(0) && !userReactiveStatus[downlines[i]]){
                uint256 startTime = users[downlines[i]].joinDate > userCheckpoint ? users[downlines[i]].joinDate : userCheckpoint;
                availableReward += (block.timestamp - startTime) / TIME_STEP;
            }
        }
        availableReward = (availableReward * REFERRAL_COMMISSION) + users[userAddress].available;
        if(availableReward >= PROFIT_LIMIT && userAddress != ownerWallet){
            missedReward = availableReward - PROFIT_LIMIT;
            availableReward = PROFIT_LIMIT;
        }
		return (availableReward, missedReward);
	}


    function setMaxSearchAddress(uint256 amount) public {
        require(msg.sender == ownerWallet, "Only owner");
		MAX_SEARCH_ADDRESS = amount;
	}

    function setLevelsGainProfit(uint256 amount) public {
        require(msg.sender == ownerWallet, "Only owner");
        require(amount >= 0.5 ether && amount <= 2 ether, "Not in range");
		REFERRAL_COMMISSION = amount;
	}

    function isUserActive(address userAddress) public view returns (bool) {
        (uint256 availableReward,) = getUserDividends(userAddress);
		if((availableReward < PROFIT_LIMIT && !userReactiveStatus[userAddress] && userAddress != address(0)) || userAddress == ownerWallet){
            return true;
        } else{
            return false;
        }
	}

    function isUserFull(address userAddress) public view returns (bool) {
		if(users[userAddress].downlineCount >= MAX_DIRECT_REFERRAL || userAddress == ownerWallet){
            return true;
        } else{
            return false;
        }
	}

    function getContractBalance() public view returns (uint256) {
        return token.balanceOf(address(this));
    }

	function getSiteInfo() public view returns(uint256 _totalUsers, uint256 _totalActiveAmount, uint256 _totalReActiveAmount, 
        uint256 _totalDirectReferralPaid, uint256 _totalDirectReferralMissed, uint256 _totalCommissionPaid, 
        uint256 _totalCommissionMissed, uint256 _totalProfitPaid, uint256 _launchTime) {
		return(totalUsers, totalActiveAmount, totalReActiveAmount, totalDirectReferralPaid, totalDirectReferralMissed, totalCommissionPaid, totalCommissionMissed, totalProfitPaid, launchTime);
	}

	function getUserExtraInfo(address userAddress) public view returns(uint256 totalReferralCommission, uint256 totalReferralCommissionMissed, uint256 availableProfit, uint256 userDeactivateTime, bool canUserReactive, uint256 _userFullCheckpoint) {
		(uint256 availableReward, uint256 missedReward) = getUserDividends(userAddress);
        return (
            getUserTotalReferralCommission(userAddress) + (availableReward - users[userAddress].available),
            getUserTotalReferralCommissionMissed(userAddress) + missedReward,
            availableReward,
            users[userAddress].checkpoint + TIME_STEP,
            userReactiveStatus[userAddress] ? true : false,
            userFullCheckpoint[userAddress]
        );
	}
    
    function getUserReferral(address userAddress) public view returns(uint256[] memory) {
		return users[userAddress].referral;
	}

    function getUserReferralCommission(address userAddress) public view returns(uint256[] memory) {
		return users[userAddress].totalReferralCommission;
	}

    function getUserTotalReferralCommission(address userAddress) public view returns(uint256 amount) {
        for (uint256 i = 0; i < MAX_COMMISSION_LEVEL; i++) {
            amount += users[userAddress].totalReferralCommission[i];
        }
	}

    function getUserTotalReferralCommissionMissed(address userAddress) public view returns(uint256 amount) {
        for (uint256 i = 0; i < MAX_COMMISSION_LEVEL; i++) {
            amount += users[userAddress].missedCommission[i];
        }
	}

    function getUserMissedCommission(address userAddress) public view returns(uint256[] memory) {
		return users[userAddress].missedCommission;
	}

    function getUserSavedSearchArray(address userAddress) public view returns(uint256[] memory) {
		return users[userAddress].savedSearchArray;
	}

    function getUserReferralLength(address userAddress) public view returns(uint256) {
		return users[userAddress].referral.length;
	}


    function userDownlines(address _user) public view returns (address[] memory) {
        address[] memory referrals = new address[](30);
        uint256[] memory IDs = new uint256[](30);
        IDs[0] = users[_user].referral.length > 0 ? users[_user].referral[0] : 0;
        IDs[1] = users[_user].referral.length > 1 ? users[_user].referral[1] : 0;
        for (uint256 i = 0; i < 14; i++) {
            IDs[(i + 1) * MAX_DIRECT_REFERRAL] = users[userList[IDs[i]]].referral.length > 0 ? users[userList[IDs[i]]].referral[0] : 0;
            IDs[(i + 1) * MAX_DIRECT_REFERRAL + 1] =  users[userList[IDs[i]]].referral.length > 1 ? users[userList[IDs[i]]].referral[1] : 0;
        }
        for (uint256 i = 0; i < 30; i++) {
            if(IDs[i] != 0){
                referrals[i] = userList[IDs[i]];
            }
        }
        return referrals;
    }

    function treeView(address _user) public view returns (address[] memory,bool[] memory, uint256[] memory ) {
        address[] memory referrals = new address[](30);
        bool[] memory activeStatus = new bool[](30);
        uint256[] memory IDs = new uint256[](30);
        IDs[0] = users[_user].referral.length > 0 ? users[_user].referral[0] : 0;
        IDs[1] = users[_user].referral.length > 1 ? users[_user].referral[1] : 0;
        for (uint256 i = 0; i < 14; i++) {
            IDs[(i + 1) * MAX_DIRECT_REFERRAL] = users[userList[IDs[i]]].referral.length > 0 ? users[userList[IDs[i]]].referral[0] : 0;
            IDs[(i + 1) * MAX_DIRECT_REFERRAL + 1] =  users[userList[IDs[i]]].referral.length > 1 ? users[userList[IDs[i]]].referral[1] : 0;
        }
        for (uint256 i = 0; i < 30; i++) {
            activeStatus[i] = isUserActive(userList[IDs[i]]);
            referrals[i] = userList[IDs[i]];
        }
        return (referrals, activeStatus, IDs);
    }

    function MigrateOldUser(uint256 limit) public{
        require(msg.sender == ownerWallet, "Only owner");
        require(!initial, "Only once");
        for (uint i = 0; i < limit; i++) {
            User memory olduser1;
            address oldusers = oldInstantGain.userList(currentID);
            (
                olduser1.id,
                olduser1.joinDate,
                ,
                olduser1.originReferrer,
                olduser1.mainReferrer,,
                olduser1.downlineCount,
                ,,
                olduser1.currentSearchIndex
                ,,olduser1.paidCommission
            ) = oldInstantGain.users(oldusers);

            if(olduser1.joinDate > 0 && users[oldusers].joinDate == 0){
                users[oldusers].id = olduser1.id;
                users[oldusers].joinDate = olduser1.joinDate;
                users[oldusers].checkpoint = launchTime;
                users[oldusers].originReferrer = olduser1.originReferrer;
                users[oldusers].mainReferrer = olduser1.mainReferrer;
                users[oldusers].downlineCount = olduser1.downlineCount;
                users[oldusers].currentSearchIndex = olduser1.currentSearchIndex;
                users[oldusers].referral = oldInstantGain.getUserReferral(oldusers);
                users[oldusers].savedSearchArray = oldInstantGain.getUserSavedSearchArray(oldusers);
                userList[currentID] = oldusers;
                userReactiveStatus[oldusers] = true;
                users[oldusers].totalReferralCommission = new uint256[](MAX_COMMISSION_LEVEL);
                users[oldusers].missedCommission = new uint256[](MAX_COMMISSION_LEVEL);
                if(users[oldusers].downlineCount >= MAX_DIRECT_REFERRAL){
                    userFullCheckpoint[oldusers] = launchTime;
                }
            }
            currentID++;
            if(currentID == oldInstantGain.currentID()){
                currentID = oldInstantGain.currentID();
                totalUsers = oldInstantGain.totalUsers();
                totalActiveAmount = oldInstantGain.totalActiveAmount();
                totalReActiveAmount = oldInstantGain.totalReActiveAmount();
                totalDirectReferralPaid = oldInstantGain.totalDirectReferralPaid();
                totalDirectReferralMissed = oldInstantGain.totalDirectReferralMissed();
                totalCommissionPaid = oldInstantGain.totalCommissionPaid();
                totalCommissionMissed = oldInstantGain.totalCommissionMissed();
                totalProfitPaid = oldInstantGain.totalProfitPaid();
                initial = true;
                break;
            }
        }
    }
}