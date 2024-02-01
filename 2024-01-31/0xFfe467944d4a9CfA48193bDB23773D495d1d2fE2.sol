// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v5.0.0) (token/ERC20/IERC20.sol)

pragma solidity ^0.8.20;

/**
 * @dev Interface of the ERC-20 standard as defined in the ERC.
 */
interface IERC20 {
    /**
     * @dev Emitted when `value` tokens are moved from one account (`from`) to
     * another (`to`).
     *
     * Note that `value` may be zero.
     */
    event Transfer(address indexed from, address indexed to, uint256 value);

    /**
     * @dev Emitted when the allowance of a `spender` for an `owner` is set by
     * a call to {approve}. `value` is the new allowance.
     */
    event Approval(address indexed owner, address indexed spender, uint256 value);

    /**
     * @dev Returns the value of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the value of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Moves a `value` amount of tokens from the caller's account to `to`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address to, uint256 value) external returns (bool);

    /**
     * @dev Returns the remaining number of tokens that `spender` will be
     * allowed to spend on behalf of `owner` through {transferFrom}. This is
     * zero by default.
     *
     * This value changes when {approve} or {transferFrom} are called.
     */
    function allowance(address owner, address spender) external view returns (uint256);

    /**
     * @dev Sets a `value` amount of tokens as the allowance of `spender` over the
     * caller's tokens.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * IMPORTANT: Beware that changing an allowance with this method brings the risk
     * that someone may use both the old and the new allowance by unfortunate
     * transaction ordering. One possible solution to mitigate this race
     * condition is to first reduce the spender's allowance to 0 and set the
     * desired value afterwards:
     * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
     *
     * Emits an {Approval} event.
     */
    function approve(address spender, uint256 value) external returns (bool);

    /**
     * @dev Moves a `value` amount of tokens from `from` to `to` using the
     * allowance mechanism. `value` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(address from, address to, uint256 value) external returns (bool);
}

contract KLPTPaymentGateway {
    address public owner;
    IERC20 public ercToken;

    struct MiningPlan {
        uint256 hashRate;
        uint256 amount;
        string planName;
        uint256 roi; // Return on Investment
        uint256 duration; // Duration in days
        uint256 purchasedDate;
    }

    mapping(address => MiningPlan[]) public userMiningPlans;
    MiningPlan[] public miningPlans;
    uint256 public totalPlans;

    uint256 public transactionFee; // Transaction fee in ETH

    bool private locked; // Mutex to prevent reentrancy
    event MiningPlanPurchased(address indexed user, uint256 planIndex, uint256 purchasedDate);
    event MiningPlanAdded(uint256 planIndex);
    event MiningPlanUpdated(uint256 planIndex);
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
    event TransactionFeeUpdated(uint256 newTransactionFee);
    event EtherWithdrawn(address indexed beneficiary, uint256 amount);

    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner can call this function");
        _;
    }

    modifier noReentrancy() {
        require(!locked, "Reentrant call");
        locked = true;
        _;
        locked = false;
    }

    constructor(address _ercTokenAddress) {
        owner = msg.sender;
        ercToken = IERC20(_ercTokenAddress);
        transactionFee = 0; // Initialize transaction fee to zero
    }

   // Function to receive Ether
    receive() external payable {}

    
    function setTransactionFee(uint256 _newTransactionFee) external onlyOwner {
        transactionFee = _newTransactionFee;
        emit TransactionFeeUpdated(_newTransactionFee);
    }



    function buyMiningPlan(uint256 _planIndex, uint256 _amount) external noReentrancy returns (bool) {
        require(_planIndex < totalPlans, "Invalid plan index");

        MiningPlan storage plan = miningPlans[_planIndex];
        require(plan.amount == _amount, "Invalid plan amount");

        // Ensure that the user has enough ERC tokens to buy the mining plan
        require(ercToken.balanceOf(msg.sender) >= _amount, "Insufficient balance");

        // Calculate the total amount to be transferred including the transaction fee
        uint256 totalAmount = _amount;

        // Transfer ERC tokens from the user to the contract owner
        require(ercToken.transferFrom(msg.sender, address(this), totalAmount), "Token transfer failed");
       payable(owner).transfer(transactionFee);
        // Add the mining plan to the user's plans
        userMiningPlans[msg.sender].push(MiningPlan({
            hashRate: plan.hashRate,
            amount: _amount,
            planName: plan.planName,
            roi: plan.roi,
            duration: plan.duration,
            purchasedDate: block.timestamp
        }));

        // Emit an event to notify the purchase
        emit MiningPlanPurchased(msg.sender, _planIndex, block.timestamp);

        // Return true indicating successful purchase
        return true;
    }

    function addMiningPlan(uint256 _hashRate, uint256 _amount, string memory _planName, uint256 _roi, uint256 _duration) external onlyOwner noReentrancy {
        miningPlans.push(MiningPlan({
            hashRate: _hashRate,
            amount: _amount,
            planName: _planName,
            roi: _roi,
            duration: _duration,
            purchasedDate: 0 // Not purchased yet
        }));

        totalPlans = miningPlans.length;

        // Emit an event to notify the addition of a new plan
        emit MiningPlanAdded(totalPlans);
    }

    function updateMiningPlan(uint256 _planIndex, uint256 _hashRate, uint256 _amount, string memory _planName, uint256 _roi, uint256 _duration) external onlyOwner noReentrancy {
        require(_planIndex < totalPlans, "Invalid plan index");

        MiningPlan storage plan = miningPlans[_planIndex];
        plan.hashRate = _hashRate;
        plan.amount = _amount;
        plan.planName = _planName;
        plan.roi = _roi;
        plan.duration = _duration;

        // Emit an event to notify the update of the plan
        emit MiningPlanUpdated(_planIndex);
    }

    function getAllMiningPlans() external view returns (MiningPlan[] memory) {
        return miningPlans;
    }

    function getUserMiningPlans(address _user) external view returns (MiningPlan[] memory) {
        return userMiningPlans[_user];
    }

    function getMiningPlan(uint256 _planIndex) external view returns (MiningPlan memory) {
        require(_planIndex < totalPlans, "Invalid plan index");
        return miningPlans[_planIndex];
    }

    function getNotExpiredPlans(address _user) external view returns (MiningPlan[] memory) {
        uint256 currentTime = block.timestamp;
        MiningPlan[] memory userPlans = userMiningPlans[_user];
        uint256 notExpiredCount = 0;

        for (uint256 i = 0; i < userPlans.length; i++) {
            if (userPlans[i].purchasedDate + userPlans[i].duration * 1 days > currentTime) {
                notExpiredCount++;
            }
        }

        MiningPlan[] memory notExpiredPlans = new MiningPlan[](notExpiredCount);
        uint256 index = 0;

        for (uint256 i = 0; i < userPlans.length; i++) {
            if (userPlans[i].purchasedDate + userPlans[i].duration * 1 days > currentTime) {
                notExpiredPlans[index] = userPlans[i];
                index++;
            }
        }

        return notExpiredPlans;
    }

    function withdrawFunds(uint256 _amount) external onlyOwner noReentrancy {
        // Owner can withdraw funds from the contract
        ercToken.transfer(owner, _amount);
    }

    function withdrawEth(uint256 _amount) external onlyOwner noReentrancy {
        // Owner can withdraw Ether sent to the contract
        require(address(this).balance >= _amount, "Insufficient contract balance");
        payable(owner).transfer(_amount);
        emit EtherWithdrawn(owner, _amount);
    }

   

    // Function to transfer ownership
    function transferOwnership(address _newOwner) external onlyOwner noReentrancy {
        require(_newOwner != address(0), "Invalid new owner address");
        emit OwnershipTransferred(owner, _newOwner);
        owner = _newOwner;
    }


    function withdrawERC20Tokens(address _to, uint256 _amount) external onlyOwner noReentrancy {
    require(_to != address(0), "Invalid recipient address");
    require(_amount > 0, "Invalid withdrawal amount");

    // Owner can withdraw ERC-20 tokens from the contract
    require(ercToken.transfer(_to, _amount), "Token transfer failed");
}
}