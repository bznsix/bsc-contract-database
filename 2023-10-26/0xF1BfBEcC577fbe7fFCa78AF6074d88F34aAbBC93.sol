pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
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
contract FundAllocation {
    address public manager;
    IERC20 public erc20Token; // The ERC-20 token contract
    mapping(address => uint256) public allocations;
    uint256 public totalAllocatedFunds; // New state variable for total allocated funds

    event AllocationUpdated(address indexed recipient, uint256 amount);
    event FundsWithdrawn(address indexed recipient, uint256 amount);
    event FundsDrained(uint256 amount);
    event AllocationAmountUpdated(address indexed recipient, uint256 newAmount);
    event EmergencyWithdraw(address indexed recipient, uint256 amount);

    constructor(address _tokenAddress) {
        manager = msg.sender;
        erc20Token = IERC20(_tokenAddress);
    }

    modifier onlyManager() {
        require(
            msg.sender == manager,
            "Only the manager can call this function"
        );
        _;
    }

    

    function allocateFunds(
        address[] calldata recipients,
        uint256[] calldata amounts
    ) external onlyManager {
        require(
            recipients.length == amounts.length,
            "Array lengths do not match"
        );
        for (uint256 i = 0; i < recipients.length; i++) {
            address recipient = recipients[i];
            uint256 amount = amounts[i];
            require(recipient != address(0), "Invalid recipient address");
            require(amount > 0, "Allocation amount must be greater than zero");
            allocations[recipient] += amount;
            totalAllocatedFunds += amount; // Update total allocated funds
            emit AllocationUpdated(recipient, allocations[recipient]);
        }
    }

    function withdrawFunds(uint256 amount_) external {
        require(allocations[msg.sender] >= amount_ && amount_ > 0, "No funds to withdraw");
        allocations[msg.sender] -= amount_;
        totalAllocatedFunds -= amount_; // Update total allocated funds
        require(erc20Token.transferFrom(manager,msg.sender, amount_), "Transfer failed");
        emit FundsWithdrawn(msg.sender, amount_);
    }

    function getAllocatedFunds(address recipient)
        external
        view
        returns (uint256)
    {
        return allocations[recipient];
    }

    function changeManager(address newManager) external onlyManager {
        require(newManager != address(0), "Invalid manager address");
        manager = newManager;
    }

    function getContractBalance() external view returns (uint256) {
        return erc20Token.balanceOf(address(this));
    }

    function drainTotalFunds() external onlyManager {
        uint256 totalBalance = erc20Token.balanceOf(address(this));
        require(totalBalance > 0, "No funds to drain");
        require(erc20Token.transfer(manager, totalBalance), "Drain failed");
        emit FundsDrained(totalBalance);
    }

    function updateAllocationAmount(address recipient, uint256 newAmount) external onlyManager {
        require(recipient != address(0), "Invalid recipient address");
        require(newAmount > 0, "Allocation amount must be greater than zero");
        totalAllocatedFunds -= allocations[recipient]; // Update total allocated funds
        totalAllocatedFunds += newAmount;
        allocations[recipient] = newAmount;
        emit AllocationAmountUpdated(recipient, newAmount);
    }

   function emergencyWithdraw(uint256 amount) external onlyManager {
    require(amount > 0, "Withdraw amount must be greater than zero");
    require(amount + totalAllocatedFunds <= erc20Token.balanceOf(address(this)), "Withdraw amount exceeds total allocated funds");
    require(erc20Token.transfer(manager, amount), "Emergency withdraw failed");
    emit EmergencyWithdraw(manager, amount);
}

}