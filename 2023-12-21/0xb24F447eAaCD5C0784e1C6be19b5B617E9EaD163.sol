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

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
    * @dev Initializes the contract setting the deployer as the initial owner.
    */
    constructor () {
      address msgSender = _msgSender();
      _owner = msgSender;
      emit OwnershipTransferred(address(0), msgSender);
    }

    /**
    * @dev Returns the address of the current owner.
    */
    function owner() public view returns (address) {
      return _owner;
    }
    
    modifier onlyOwner() {
      require(_owner == _msgSender(), "Ownable: caller is not the owner");
      _;
    }

    function transferOwnership(address newOwner) public onlyOwner {
      _transferOwnership(newOwner);
    }

    function _transferOwnership(address newOwner) internal {
      require(newOwner != address(0), "Ownable: new owner is the zero address");
      emit OwnershipTransferred(_owner, newOwner);
      _owner = newOwner;
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

contract MetaRise is ReentrancyGuard, Ownable {
	using SafeERC20 for IERC20;

	address private tokenAddr = address(0x55d398326f99059fF775485246999027B3197955);
    IERC20 public token;

	uint256 constant private PERCENTS_DIVIDER = 10000;
    uint256 constant private ACTIVATE_PRICE = 50 ether;
    uint256 constant private REACTIVATE_REWARD = 40 ether;
    uint256 constant private REWARD_REMAINS = 10 ether;
    uint256 constant private DIRECT_COMMISSION = 10 ether;
    uint256 constant private ACTIVATE_OWNER_FEE = 5 ether;
    uint256 constant private REACTIVATE_OWNER_FEE = 10 ether;
    uint256 constant private REFERRAL_COMMISSION = 30 ether;
    uint256 constant private DEACTIVATE_STEP = 90 ether;
    uint256 constant private MAX_DIRECT_REFERRAL = 3;
    uint256 constant private MAX_ROI_PROFIT = 20000;
    uint256 constant private DAILY_PROFIT = 200;
    uint256 constant private MINIMUM_CLAIM = 5 ether;
    uint256 constant private STOP_ROI_STEP = 2;
    uint256 constant private  TIME_STEP = 1 days;
    uint256 public MAX_SEARCH_ADDRESS = 600;

	struct User {
        uint256 id;
        uint256 joinDate;
        uint256 originReferrer;
        uint256 mainReferrer;
        uint256 currentProfit;
        uint256 downlineCount;
        uint256[] referral;
        uint256 totalDirectCommission;
        uint256 missedDirectCommission;
        uint256 totalReferralCommissionPaid;
        uint256 totalReferralCommissionReceived;
        uint256 missedCommission;
        uint256[] savedSearchArray;
        uint256 currentSearchIndex;
	}

    struct UserROI {
        uint256 id;
        uint256 roiCheckpoint;
        uint256 roiFinishCheckpoint;
        uint256 reactivateCount;
        uint256 withdrawn;
	}

	mapping (address => User) public users;
    mapping (address => UserROI) public usersROI;
    mapping(uint256 => address) public userList;

    uint256 public currentID = 1;

	uint256 public totalUsers;
    uint256 public totalActiveAmount;
    uint256 public totalReActiveCount;
    uint256 public totalDirectReferralPaid;
    uint256 public totalDirectReferralMissed;
    uint256 public totalCommissionPaid;
    uint256 public totalCommissionReceived;
    uint256 public totalCommissionMissed;
    uint256 public TotalRewardClaimed;
	address public ownerWallet;
    bool public initial;
    MetaRise private oldMetaRise;


	event Activate(address userAddress, uint256 indexed id, uint256 timestamp);
    event ReActivate(address userAddress, uint256 indexed id, uint256 timestamp);
    event OwnerFeePaid(uint256 amount, uint256 timestamp);
    event DirectCommissionPaid(uint256 fromID, uint256 toID, uint256 timestamp);
    event DirectCommissionMissed(uint256 fromID, uint256 toID, uint256 timestamp);
    event ReferralCommissionReceived(uint256 fromID, uint256 toID, uint256 timestamp);
    event ReferralCommissionPaid(uint256 userID, uint256 timestamp);
    event ReferralCommissionMissed(uint256 fromID, uint256 toID, uint256 timestamp);
    event DailyProfitClaimed(address userAddress, uint256 amount, uint256 timestamp);

	constructor() {
		ownerWallet = address(0x33ec6197C2049902f4082Ea3daffdb3AbCD5C42B);
        oldMetaRise = MetaRise(0xd4b9cB41643149106B4E7BFCff79fFDf17a298D1);
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
        UserROI memory userROIStruct;
        uint256[] memory deafultArray;
        userStruct = User({
            id: currentID,
            joinDate: block.timestamp,
            originReferrer: users[userList[referrer]].id,
            mainReferrer: refID,
            currentProfit: 0,
            downlineCount: 0,
            referral: new uint256[](0),
            totalDirectCommission: 0,
            missedDirectCommission: 0,
            totalReferralCommissionPaid: 0,
            totalReferralCommissionReceived: 0,
            missedCommission: 0,
            savedSearchArray: deafultArray,
            currentSearchIndex: 0
        });

        userROIStruct = UserROI({
            id: currentID,
            roiCheckpoint: block.timestamp,
            roiFinishCheckpoint: 0,
            reactivateCount:0,
            withdrawn: 0
        });

        users[msg.sender] = userStruct;
        usersROI[msg.sender] = userROIStruct;
        users[userList[users[msg.sender].originReferrer]].downlineCount++;
        userList[currentID] = msg.sender;
        users[userList[users[msg.sender].mainReferrer]].referral.push(currentID);
        currentID++;
        totalUsers++;
        totalActiveAmount += ACTIVATE_PRICE;

        _payCommission(msg.sender, 0);

        emit Activate(msg.sender, users[msg.sender].id, block.timestamp);
    }

    function claimAndReactivate() public noReentrant {
        require(initial , "Project not launch yet");
        require(users[msg.sender].joinDate > 0, "Activate first");
        require(users[msg.sender].currentProfit >= DEACTIVATE_STEP, "User is active");

        _payCommission(msg.sender, 1);
        users[msg.sender].currentProfit = users[msg.sender].currentProfit - DEACTIVATE_STEP;
        usersROI[msg.sender].reactivateCount++;
        totalReActiveCount ++;
        if(usersROI[msg.sender].reactivateCount == STOP_ROI_STEP){
            usersROI[msg.sender].roiFinishCheckpoint = block.timestamp;
        }
        emit ReActivate(msg.sender, users[msg.sender].id, block.timestamp);
    }

    function claimDailyProfit() public noReentrant{
        require(initial , "Project not launch yet");

		UserROI storage user = usersROI[msg.sender];
        require(user.roiCheckpoint > 0, "Activate first");

		uint256 totalAmount = getUserDividends(msg.sender);
		require(totalAmount >= MINIMUM_CLAIM, "Dividend must be more than minimum claim");
        require(totalAmount <=  getContractBalance(), "Not enough contract balance");

		user.roiCheckpoint = user.roiFinishCheckpoint < block.timestamp && user.roiFinishCheckpoint != 0 ? user.roiFinishCheckpoint : block.timestamp;
		user.withdrawn += totalAmount;
        TotalRewardClaimed += totalAmount;

        token.safeTransfer(msg.sender, totalAmount); 
		emit DailyProfitClaimed(msg.sender, totalAmount, block.timestamp);
	}

    function _payCommission(address userAddress, uint8 resourceType) internal {
        User storage user = users[userAddress];
        address originUser = userList[user.originReferrer];
        address mainReferrer = userList[user.mainReferrer];
        bool isOriginActivate = isUserActive(originUser);
        bool isMainActivate = isUserActive(mainReferrer);

        if(resourceType == 0) {
            if(isOriginActivate) {
                users[originUser].totalDirectCommission += DIRECT_COMMISSION;
                totalDirectReferralPaid += DIRECT_COMMISSION;
                users[originUser].currentProfit += DIRECT_COMMISSION;
                emit DirectCommissionPaid(user.id, user.originReferrer, block.timestamp);
            } else {
                users[originUser].missedDirectCommission += DIRECT_COMMISSION;
                totalDirectReferralMissed += DIRECT_COMMISSION;
                emit DirectCommissionMissed(user.id, user.originReferrer, block.timestamp);
            }
        } else { 
            totalCommissionPaid += REACTIVATE_REWARD;
            users[userAddress].totalReferralCommissionPaid += REACTIVATE_REWARD;
            token.safeTransfer(userAddress, REACTIVATE_REWARD); 
            emit ReferralCommissionPaid(user.id, block.timestamp);
        }
        
        if (mainReferrer != address(0)) {
            if(isMainActivate){
                users[mainReferrer].currentProfit += REFERRAL_COMMISSION;
                totalCommissionReceived += REFERRAL_COMMISSION;
                users[mainReferrer].totalReferralCommissionReceived += REFERRAL_COMMISSION;
                emit ReferralCommissionReceived(user.id, users[mainReferrer].id, block.timestamp);
            }else{
                users[mainReferrer].missedCommission += REFERRAL_COMMISSION;
                totalCommissionMissed += REFERRAL_COMMISSION;
                emit ReferralCommissionMissed(user.id, users[mainReferrer].id, block.timestamp);
            }
        }
        if(resourceType == 0){
            token.safeTransfer(ownerWallet, ACTIVATE_OWNER_FEE);
        } else {
            token.safeTransfer(ownerWallet, REACTIVATE_OWNER_FEE); 
        }
        emit OwnerFeePaid(resourceType == 0 ? ACTIVATE_OWNER_FEE : REACTIVATE_OWNER_FEE, block.timestamp);
    }

    function _findFreeReferrer(uint256 _user) internal returns (uint256) {
        if (users[userList[_user]].referral.length < MAX_DIRECT_REFERRAL) {
            return _user;
        }
        uint256[] storage referrals = users[userList[_user]].savedSearchArray;
        if(referrals.length == 0){
            referrals.push(users[userList[_user]].referral[0]);
            referrals.push(users[userList[_user]].referral[1]);
            referrals.push(users[userList[_user]].referral[2]);
        }

        uint256 freeReferrer;
        bool noFreeReferrer = true;
        uint256 maxBuildAddress = (MAX_SEARCH_ADDRESS / MAX_DIRECT_REFERRAL) - 1;
        for (uint256 i = users[userList[_user]].currentSearchIndex; i < MAX_SEARCH_ADDRESS; i++) {
            if (users[userList[referrals[i]]].referral.length == MAX_DIRECT_REFERRAL) {
                if (i < maxBuildAddress) {
                    referrals.push(users[userList[referrals[i]]].referral[0]);
                    referrals.push(users[userList[referrals[i]]].referral[1]);
                    referrals.push(users[userList[referrals[i]]].referral[2]);
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
                    referrals[(i + 1) * MAX_DIRECT_REFERRAL + 2] = users[userList[referrals[i]]].referral[2];
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

    function getUserDividends(address userAddress) public view returns (uint256) {
		UserROI storage user = usersROI[userAddress];
        if(user.roiCheckpoint == 0){
            return 0;
        }
		uint256 totalAmount;
        uint256 maxProfit = ACTIVATE_PRICE * MAX_ROI_PROFIT / PERCENTS_DIVIDER;
        
        uint256 share = ACTIVATE_PRICE * DAILY_PROFIT / PERCENTS_DIVIDER;
        uint256 from = user.roiCheckpoint;
        uint256 to = user.roiFinishCheckpoint < block.timestamp && user.roiFinishCheckpoint != 0 ? user.roiFinishCheckpoint : block.timestamp;
        if (from < to) {
            totalAmount = share * (to - from) / TIME_STEP;
        }
        if (user.withdrawn + totalAmount >= maxProfit) {
            totalAmount = maxProfit - user.withdrawn;
        }
		return totalAmount;
	}

    function setMaxSearchAddress(uint256 amount) public {
        require(msg.sender == ownerWallet, "Only owner");
		MAX_SEARCH_ADDRESS = amount;
	}

    function getContractBalance() public view returns (uint256) {
        return token.balanceOf(address(this));
    }

    function isUserActive(address userAddress) public view returns (bool) {
		if((users[userAddress].currentProfit < DEACTIVATE_STEP && userAddress != address(0)) || userAddress == ownerWallet){
            return true;
        } else{
            return false;
        }
	}

	function getSiteInfo() public view returns(uint256 _totalUsers, uint256 _totalActiveAmount, uint256 _totalReActiveCount, uint256 _totalDirectReferralPaid, uint256 _totalDirectReferralMissed, uint256 _totalCommissionPaid, uint256 _totalCommissionReceived , uint256 _totalCommissionMissed, uint256 _TotalRewardClaimed) {
		return(totalUsers, totalActiveAmount, totalReActiveCount, totalDirectReferralPaid, totalDirectReferralMissed, totalCommissionPaid, totalCommissionReceived, totalCommissionMissed, TotalRewardClaimed);
	}

    function getUserMainReferrer(address userAddress) public view returns(address) {
		return userList[users[userAddress].mainReferrer];
	}

    function getUserOriginReferrer(address userAddress) public view returns(address) {
		return userList[users[userAddress].originReferrer];
	}
    
    function getUserReferral(address userAddress) public view returns(uint256[] memory) {
		return users[userAddress].referral;
	}

    function getUserSavedSearchArray(address userAddress) public view returns(uint256[] memory) {
		return users[userAddress].savedSearchArray;
	}

    function getUserReferralLength(address userAddress) public view returns(uint256) {
		return users[userAddress].referral.length;
	}

    function treeView(address _user) public view returns (address[] memory,bool[] memory, uint256[] memory ) {
        address[] memory referrals = new address[](3);
        bool[] memory activeStatus = new bool[](3);
        uint256[] memory IDs = new uint256[](3);
        IDs[0] = users[_user].referral.length > 0 ? users[_user].referral[0] : 0;
        IDs[1] = users[_user].referral.length > 1 ? users[_user].referral[1] : 0;
        IDs[2] = users[_user].referral.length > 2 ? users[_user].referral[2] : 0;
        for (uint256 i = 0; i < 3; i++) {
            activeStatus[i] = isUserActive(userList[IDs[i]]);
            referrals[i] = userList[IDs[i]];
        }
        return (referrals, activeStatus, IDs);
    }

    function MigrateOldUser(uint256 oldId,uint limit) public onlyOwner{
        require(!initial, "Only once");
        for (uint i = 0; i < limit; i++) {
            User memory olduser1;
            User memory olduser2;
            address oldusers = oldMetaRise.userList(oldId);
            (
                olduser1.id,
                olduser1.joinDate,
                olduser1.originReferrer,
                olduser1.mainReferrer,
                olduser1.currentProfit,
                olduser1.downlineCount,
                ,,,,,
            ) = oldMetaRise.users(oldusers);
            (
                ,,,,,,
                olduser2.totalDirectCommission,
                olduser2.missedDirectCommission,
                olduser2.totalReferralCommissionPaid,
                olduser2.totalReferralCommissionReceived,
                olduser2.missedCommission,
                olduser2.currentSearchIndex
            ) = oldMetaRise.users(oldusers);
            
            if(olduser1.joinDate > 0){
                users[oldusers].id = olduser1.id;
                users[oldusers].joinDate = olduser1.joinDate;
                users[oldusers].originReferrer = olduser1.originReferrer;
                users[oldusers].mainReferrer = olduser1.mainReferrer;
                users[oldusers].currentProfit = olduser1.currentProfit;
                users[oldusers].downlineCount = olduser1.downlineCount;
                users[oldusers].totalDirectCommission = olduser2.totalDirectCommission;
                users[oldusers].missedDirectCommission = olduser2.missedDirectCommission;
                users[oldusers].totalReferralCommissionPaid = olduser2.totalReferralCommissionPaid;
                users[oldusers].totalReferralCommissionReceived = olduser2.totalReferralCommissionReceived;
                users[oldusers].missedCommission = olduser2.missedCommission;
                users[oldusers].currentSearchIndex = olduser2.currentSearchIndex;
                users[oldusers].referral = oldMetaRise.getUserReferral(oldusers);
                users[oldusers].savedSearchArray = oldMetaRise.getUserSavedSearchArray(oldusers);

                userList[oldId] = oldusers;

                UserROI memory oldUserROI;
                (
                    oldUserROI.id,
                    oldUserROI.roiCheckpoint,
                    oldUserROI.roiFinishCheckpoint,
                    oldUserROI.reactivateCount,
                    oldUserROI.withdrawn
                ) = oldMetaRise.usersROI(oldusers);
                usersROI[oldusers].id = oldUserROI.id;
                usersROI[oldusers].roiCheckpoint = oldUserROI.roiCheckpoint;
                usersROI[oldusers].roiFinishCheckpoint = oldUserROI.roiFinishCheckpoint;
                usersROI[oldusers].reactivateCount = oldUserROI.reactivateCount;
                usersROI[oldusers].withdrawn = oldUserROI.withdrawn;
            }
            oldId++;
        }
        currentID = oldMetaRise.currentID();
        totalUsers = oldMetaRise.totalUsers();
        totalActiveAmount = oldMetaRise.totalActiveAmount();
        totalReActiveCount = oldMetaRise.totalReActiveCount();
        totalDirectReferralPaid = oldMetaRise.totalDirectReferralPaid();
        totalDirectReferralMissed = oldMetaRise.totalDirectReferralMissed();
        totalCommissionPaid = oldMetaRise.totalCommissionPaid();
        totalCommissionReceived = oldMetaRise.totalCommissionReceived();
        totalCommissionMissed = oldMetaRise.totalCommissionMissed();
        initial = true;
      }
}