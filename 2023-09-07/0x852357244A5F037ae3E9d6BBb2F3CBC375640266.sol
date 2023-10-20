// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.6.0) (token/ERC20/IERC20.sol)

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
     * @dev Returns the amount of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the amount of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Moves `amount` tokens from the caller's account to `to`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address to, uint256 amount) external returns (bool);

    /**
     * @dev Returns the remaining number of tokens that `spender` will be
     * allowed to spend on behalf of `owner` through {transferFrom}. This is
     * zero by default.
     *
     * This value changes when {approve} or {transferFrom} are called.
     */
    function allowance(address owner, address spender) external view returns (uint256);

    /**
     * @dev Sets `amount` as the allowance of `spender` over the caller's tokens.
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
    function approve(address spender, uint256 amount) external returns (bool);

    /**
     * @dev Moves `amount` tokens from `from` to `to` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);
}
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract Presale {
    address public owner;
    uint256 public multiplier;
    uint256 public maxDeposit;
    uint256 public maxTotalDepositPerUser;
    address public dispersalToken;
    bool public isActive;
    mapping(address => uint256) public deposits;
    mapping(address => bool) public allowedAddresses;
    mapping(address => uint256) public bnbDeposits;

    address[] private depositors;

    uint256 public contractBNBBalance;

    constructor(
        uint256 _multiplier,
        uint256 _maxDeposit,
        uint256 _maxTotalDepositPerUser,
        address _dispersalToken,
        bool _isActive,
        address[] memory _allowedAddresses
    ) {
        owner = msg.sender;
        multiplier = _multiplier;
        maxDeposit = _maxDeposit;
        maxTotalDepositPerUser = _maxTotalDepositPerUser;
        dispersalToken = _dispersalToken;
        isActive = _isActive;

        for (uint256 i = 0; i < _allowedAddresses.length; i++) {
            allowedAddresses[_allowedAddresses[i]] = true;
        }
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner can call this function");
        _;
    }

    modifier onlyAllowed() {
        require(isActive, "The contract is currently inactive");
        require(allowedAddresses[msg.sender], "You are not allowed to participate in the presale");
        _;
    }

    function deposit() external payable onlyAllowed {
        require(msg.value > 0, "No BNB sent");
        require(msg.value <= maxDeposit, "Deposit amount exceeds the maximum deposit limit");

        uint256 remainingAmount = maxTotalDepositPerUser - deposits[msg.sender];
        require(msg.value <= remainingAmount, "Deposit amount exceeds the maximum total deposit per user");

        deposits[msg.sender] += msg.value;
        bnbDeposits[msg.sender] += msg.value;

        if (deposits[msg.sender] == msg.value) {
            depositors.push(msg.sender);
        }
    }

    function disperseTokens() external onlyOwner {
        IERC20 newToken = IERC20(dispersalToken);

        for (uint256 i = 0; i < depositors.length; i++) {
            address depositor = depositors[i];
            uint256 tokensToDisperse = calculateDispersalTokensOwed(depositor);
            require(newToken.balanceOf(address(this)) >= tokensToDisperse, "Insufficient new tokens");

            newToken.transfer(depositor, tokensToDisperse);
        }
    }

    function calculateTotalTokensToDisperse() public view returns (uint256) {
        return bnbDeposits[msg.sender] * multiplier;
    }

    function calculateDispersalTokensOwed(address user) public view returns (uint256) {
        return bnbDeposits[user] * multiplier;
    }

    function getTotalDeposit(address user) public view returns (uint256) {
        return deposits[user];
    }

    function updateAllowedAddresses(address[] memory _allowedAddresses) external onlyOwner {
        for (uint256 i = 0; i < _allowedAddresses.length; i++) {
            allowedAddresses[_allowedAddresses[i]] = true;
        }
    }

    function removeAllowedAddress(address _address) external onlyOwner {
        allowedAddresses[_address] = false;
    }

    function setMaxDeposit(uint256 _maxDeposit) external onlyOwner {
        maxDeposit = _maxDeposit;
    }

    function setDispersalToken(address _dispersalToken) external onlyOwner {
        dispersalToken = _dispersalToken;
    }

    function activateContract() external onlyOwner {
        isActive = true;
    }

    function deactivateContract() external onlyOwner {
        isActive = false;
    }

    function isAddressAllowed(address _address) public view returns (bool) {
        return allowedAddresses[_address];
    }

    function totalDepositors() public view returns (uint256) {
        return depositors.length;
    }

    function depositorAtIndex(uint256 index) public view returns (address) {
        require(index < depositors.length, "Index out of range");
        return depositors[index];
    }

    function depositBNB() external payable onlyOwner {
        require(msg.value > 0, "No BNB sent");
        contractBNBBalance += msg.value;
    }

    function updateMultiplier(uint256 newMultiplier) external onlyOwner {
        multiplier = newMultiplier;
    }

    function transferOwnership(address newOwner) external onlyOwner {
        require(newOwner != address(0), "Invalid address");
        owner = newOwner;
    }

    function withdrawBNB(uint256 amount) external onlyOwner {
        require(amount > 0, "Amount must be greater than 0");
        require(amount <= contractBNBBalance, "Insufficient contract BNB balance");

        payable(owner).transfer(amount);
        contractBNBBalance -= amount;
    }

    // Withdraw function to allow the owner to withdraw any balance (BNB and tokens)
    function withdrawAll() external onlyOwner {
        uint256 contractBalance = address(this).balance;
        contractBNBBalance = 0; // Reset the contract BNB balance
        payable(owner).transfer(contractBalance);

        IERC20 token = IERC20(dispersalToken);
        uint256 tokenBalance = token.balanceOf(address(this));
        if (tokenBalance > 0) {
            token.transfer(owner, tokenBalance);
        }
    }
}