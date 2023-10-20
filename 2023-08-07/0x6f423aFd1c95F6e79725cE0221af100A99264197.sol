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
    address public admin;
    uint256 public multiplier;
    uint256 public maxDeposit;
    uint256 public maxTotalDepositPerUser;
    address public dispersalToken;
    bool public isActive;
    mapping(address => uint256) public deposits;
    mapping(address => bool) public allowedAddresses;
    mapping(address => uint256) public bnbDeposits; // Track BNB deposits per user

    address[] private depositors;

    event Deposit(address indexed user, uint256 amount);
    event TokensDispersed(address indexed user, uint256 amount);

    // Additional variable to track BNB balance
    uint256 public contractBNBBalance;

    constructor(
        uint256 _multiplier,
        uint256 _maxDeposit,
        uint256 _maxTotalDepositPerUser,
        address _dispersalToken,
        bool _isActive,
        address[] memory _allowedAddresses
    ) {
        admin = msg.sender;
        multiplier = _multiplier;
        maxDeposit = _maxDeposit;
        maxTotalDepositPerUser = _maxTotalDepositPerUser;
        dispersalToken = _dispersalToken;
        isActive = _isActive;

        for (uint256 i = 0; i < _allowedAddresses.length; i++) {
            allowedAddresses[_allowedAddresses[i]] = true;
        }
    }

    // Modifier to restrict access to only the contract owner (admin)
    modifier onlyAdmin() {
        require(msg.sender == admin, "Only admin can call this function");
        _;
    }

    // Modifier to restrict access to only allowed addresses when the contract is active
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
        bnbDeposits[msg.sender] += msg.value; // Track BNB deposits per user

        if (deposits[msg.sender] == msg.value) {
            depositors.push(msg.sender);
        }
        emit Deposit(msg.sender, msg.value);
    }

    function disperseTokens() external onlyAdmin {
        IERC20 newToken = IERC20(dispersalToken);

        for (uint256 i = 0; i < depositors.length; i++) {
            address depositor = depositors[i];
            uint256 tokensToDisperse = calculateDispersalTokensOwed(depositor);
            require(newToken.balanceOf(address(this)) >= tokensToDisperse, "Insufficient new tokens");

            newToken.transfer(depositor, tokensToDisperse);
            emit TokensDispersed(depositor, tokensToDisperse);
        }
    }

    function calculateTotalTokensToDisperse() public view returns (uint256) {
        return bnbDeposits[msg.sender] * multiplier; // Use BNB deposits for token calculation
    }

    function calculateDispersalTokensOwed(address user) public view returns (uint256) {
        return bnbDeposits[user] * multiplier; // Use BNB deposits for token calculation
    }

    function getTotalDeposit(address user) public view returns (uint256) {
        return deposits[user];
    }

    function withdrawTokens() external onlyAdmin {
        IERC20 token = IERC20(dispersalToken);
        uint256 tokenBalance = token.balanceOf(address(this));
        require(tokenBalance > 0, "No tokens to withdraw");
        token.transfer(msg.sender, tokenBalance);

        uint256 totalBNBBalance = address(this).balance; // Get the total BNB balance of the contract, including users' deposits
        require(totalBNBBalance > 0, "No BNB balance to withdraw");

        // Withdraw total BNB balance of the contract
        (bool success, ) = msg.sender.call{value: totalBNBBalance}("");
        require(success, "BNB withdrawal failed");
    }

    function updateAllowedAddresses(address[] memory _allowedAddresses) external onlyAdmin {
        for (uint256 i = 0; i < _allowedAddresses.length; i++) {
            allowedAddresses[_allowedAddresses[i]] = true;
        }
    }

    function removeAllowedAddress(address _address) external onlyAdmin {
        allowedAddresses[_address] = false;
    }

    function setMaxDeposit(uint256 _maxDeposit) external onlyAdmin {
        maxDeposit = _maxDeposit;
    }

    function setDispersalToken(address _dispersalToken) external onlyAdmin {
        dispersalToken = _dispersalToken;
    }

    function activateContract() external onlyAdmin {
        isActive = true;
    }

    function deactivateContract() external onlyAdmin {
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

    // Function for the contract owner to deposit BNB
    function depositBNB() external payable onlyAdmin {
        require(msg.value > 0, "No BNB sent");
        contractBNBBalance += msg.value;
    }

    // Function to update the multiplier, can only be called by the contract owner (admin)
    function updateMultiplier(uint256 newMultiplier) external onlyAdmin {
        multiplier = newMultiplier;
    }
}