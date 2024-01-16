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

interface IInstantGain{
    function users(address userAddress) external view returns (
        uint256 id,
        uint256 joinDate,
        uint256 checkpoint,
        uint256 originReferrer,
        uint256 mainReferrer,
        uint256 available,
        uint256 downlineCount,
        uint256 totalDirectCommission,
        uint256 missedDirectCommission,
        uint256 currentSearchIndex,
        uint256 reactivateCount,
        uint256 paidCommission
    );
    function userReactiveStatus(address userAddress) external view returns (bool);
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
contract InstantGain_ROI is ReentrancyGuard {
	using SafeERC20 for IERC20;

	address private tokenAddr = address(0x55d398326f99059fF775485246999027B3197955);
    address private mainContact = address(0x520d0516bd176D8f3C1d0Ca328E24C2c9dd4A6C5);
    address public ownerWallet;
    IERC20 public token;

	uint256 constant private PERCENTS_DIVIDER = 1000;
    uint256 constant private ACTIVATE_PRICE = 50 ether;
    uint256 constant private ROI_PROFIT = 1 ether;
    uint256 constant private PROFIT_LIMIT = 50 ether;
    uint256 constant private TIME_STEP = 1 days;

    struct UserStruct {
        uint256 roiCheckpoint;
        uint256 claimed;
	}

	mapping (address => UserStruct) public usersRoi;

	uint256 public totalClaimed;
    uint256 public startRoi;


	event ClaimROI(address userAddress, uint256 timestamp);

	constructor() {
		token = IERC20(tokenAddr);
        ownerWallet = address(0x0Fb85ae76698c198Ca4d765Cdd2510a3F71616eA);
        startRoi = block.timestamp - TIME_STEP;
	}

    function claimProfit() public noReentrant {
        (,
            uint256 joinDate,
            uint256 checkpoint,
            ,,,,,,,,
            uint256 paidCommission
        ) = IInstantGain(mainContact).users(msg.sender);

        require(checkpoint >= startRoi, "Roi not started for this user");
        require(joinDate > 0, "User is not active in the main contract");
        require(usersRoi[msg.sender].claimed < PROFIT_LIMIT, "Total ROI claim should be less than 50 USDT");
        require(paidCommission < PROFIT_LIMIT, "Total Commission claim should be less than 50 USDT in the main contract");
        require(checkpoint + TIME_STEP <= block.timestamp, "Not time to claim in main contract");
        require(usersRoi[msg.sender].roiCheckpoint < checkpoint, "Claim only once per day");

        usersRoi[msg.sender].claimed += ROI_PROFIT;
        usersRoi[msg.sender].roiCheckpoint = block.timestamp;
        totalClaimed += ROI_PROFIT;

        token.safeTransfer(msg.sender, ROI_PROFIT);
        emit ClaimROI(msg.sender, block.timestamp);
    }


    function getUserDividends(address userAddress) public view returns (uint256) {
        (,
            uint256 joinDate,
            uint256 checkpoint,
            ,,,,,,,,
            uint256 paidCommission
        ) = IInstantGain(mainContact).users(userAddress);

        if(checkpoint < startRoi || joinDate == 0 || usersRoi[userAddress].roiCheckpoint > checkpoint || 
            usersRoi[userAddress].claimed >= PROFIT_LIMIT || paidCommission >= PROFIT_LIMIT){
            return 0;
        }
		uint256 totalAmount;
        
        uint256 share = ACTIVATE_PRICE + ROI_PROFIT;
        uint256 from = checkpoint;
        uint256 to =  block.timestamp;
        if (from < to) {
            uint256 duration = to - from > TIME_STEP ? TIME_STEP : to - from;
            totalAmount = share * duration / TIME_STEP;
        }
		return totalAmount;
	}

    function roiStatus(address userAddress) public view returns (bool) {
        (,
            uint256 joinDate,
            uint256 checkpoint,
            ,,,,,,,,
            uint256 paidCommission
        ) = IInstantGain(mainContact).users(userAddress);

        if(checkpoint >= startRoi && joinDate > 0 && usersRoi[userAddress].claimed < PROFIT_LIMIT && paidCommission < PROFIT_LIMIT && 
            checkpoint + TIME_STEP > block.timestamp){
            return true;
        } else{
            return false;
        }
	}

    function isClaimed(address userAddress) public view returns (bool) {
        (,
            uint256 joinDate,
            uint256 checkpoint,
            ,,,,,,,,
        ) = IInstantGain(mainContact).users(userAddress);
        if(checkpoint < startRoi){
            return true;
        }
        if(joinDate > 0 && checkpoint + TIME_STEP <= block.timestamp && usersRoi[userAddress].roiCheckpoint > checkpoint){
            return true;
        } else{
            return false;
        }
	}

    function Refund(uint256 amount) public {
        require(msg.sender == ownerWallet, "Only onwer");
        uint256 finalAmount = amount == 0 || amount >= token.balanceOf(address(this)) ? token.balanceOf(address(this)) : amount;
        token.safeTransfer(msg.sender, finalAmount);
	}
}