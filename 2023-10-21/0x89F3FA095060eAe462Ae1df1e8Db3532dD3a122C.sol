pragma solidity 0.8.18;

// SPDX-License-Identifier: MIT

// This abstract contract provides basic functions to access the sender and message data.
abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender; // Returns the address of the message sender.
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data; // Returns the data of the message.
    }
}

// Interface for the ERC20 token standard.
interface IERC20 {
    function totalSupply() external view returns (uint256); // Get the total token supply.
    function balanceOf(address account) external view returns (uint256); // Get the balance of a specific account.
    function transfer(address recipient, uint256 amount) external returns (bool); // Transfer tokens to a recipient.
    function allowance(address owner, address spender) external view returns (uint256); // Check the amount that one address is allowed to spend on behalf of another.
    function approve(address spender, uint256 amount) external returns (bool); // Approve an address to spend tokens on your behalf.
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool); // Transfer tokens from one address to another.

    event Transfer(address indexed from, address indexed to, uint256 value); // Event emitted when tokens are transferred.
    event Approval(address indexed owner, address indexed spender, uint256 value); // Event emitted when an allowance is set.
}

// Interface for ERC20 token metadata.
interface IERC20Metadata is IERC20 {
    function name() external view returns (string memory); // Get the token name.
    function symbol() external view returns (string memory); // Get the token symbol.
    function decimals() external view returns (uint8); // Get the number of decimals used for token values.
}

// Main contract FUTOSHI inheriting from Context, IERC20, and IERC20Metadata.
contract FUTOSHI is Context, IERC20, IERC20Metadata {
    mapping(address => uint256) private balances; // Store balances of users.
    mapping(address => mapping(address => uint256)) private allowances; // Store allowed transfer amounts.
    string private _name = 'Futoshi'; // Token name.
    string private _symbol = 'MEMEDOG'; // Token symbol.
    uint256 private _totalSupply; // Total supply of tokens.
    uint256 public StartedSupply; // Initial supply.
    uint256 public TotalBurnedSupply; // Total burned tokens.
    address public burnAddress; // Address where tokens are burned.

    constructor() {
        // Initialize the contract with an initial supply and set the burn address.
        _mint(_msgSender(), 20000000000000 * 10 ** 18); // Mint tokens to the contract deployer.
        burnAddress = 0x000000000000000000000000000000000000dEaD; // Set the burn address.
        _totalSupply = 20000000000000 * 10 ** 18; // Set the total supply.
        StartedSupply = 20000000000000 * 10 ** 18; // Record the initial supply.
    }

    function name() public view virtual override returns (string memory) {
        return _name; // Get the token name.
    }

    function symbol() public view virtual override returns (string memory) {
        return _symbol; // Get the token symbol.
    }

    function decimals() public view virtual override returns (uint8) {
        return 18; // Specify the number of decimal places for token values.
    }

    function totalSupply() public view virtual override returns (uint256) {
        return _totalSupply; // Get the total token supply.
    }

    function balanceOf(address account) public view virtual override returns (uint256) {
        return balances[account]; // Get the balance of a specific account.
    }

    function allowance(address owner, address spender) public view virtual override returns (uint256) {
        return allowances[owner][spender]; // Get the allowed amount for an address to spend on behalf of another.
    }

    function approve(address spender, uint256 amount) public virtual override returns (bool) {
        _approve(_msgSender(), spender, amount); // Approve an address to spend tokens on your behalf.
        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {
        _approve(_msgSender(), spender, allowances[_msgSender()][spender] + addedValue); // Increase the allowance for an address to spend tokens.
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {
        uint256 currentAllowance = allowances[_msgSender()][spender];
        require(currentAllowance >= subtractedValue, "ERC20: decreased allowance below zero"); // Ensure the allowance doesn't go below zero.
        _approve(_msgSender(), spender, currentAllowance - subtractedValue); // Decrease the allowance for an address to spend tokens.
        return true;
    }

    function transfer(address recipient, uint256 amount) public override returns (bool) {
        _transfer(_msgSender(), recipient, amount); // Transfer tokens to a recipient.
        return true;
    }

    function transferFrom(address sender, address recipient, uint256 amount) public virtual override returns (bool) {
        _transfer(sender, recipient, amount); // Transfer tokens from one address to another.
        uint256 currentAllowance = allowances[sender][_msgSender()];
        require(currentAllowance >= amount, "ERC20: transfer amount exceeds allowance"); // Ensure the transfer amount is within the allowed limit.
        _approve(sender, _msgSender(), currentAllowance - amount); // Update the allowance.
        return true;
    }

    function _approve(address owner, address spender, uint256 amount) internal virtual {
        require(owner != address(0), "ERC20: approve from the zero address"); // Ensure neither the owner nor spender address is zero.
        require(spender != address(0), "ERC20: approve to the zero address"); // Ensure neither the owner nor spender address is zero.

        if (allowances[owner][spender] != amount) {
            allowances[owner][spender] = amount; // Set the allowance.
            emit Approval(owner, spender, amount); // Emit an event to log the approval.
        }
    }

    function _transfer(address sender, address recipient, uint256 amount) internal virtual {
        require(sender != address(0), "ERC20: transfer from the zero address"); // Ensure the sender address is not zero.
        require(recipient != address(0), "ERC20: transfer to the zero address"); // Ensure the recipient address is not zero.
        require(balances[sender] >= amount, "ERC20: transfer amount exceeds balance"); // Ensure the sender has enough balance to make the transfer.

        balances[sender] -= amount; // Deduct the transferred amount from the sender's balance.
        balances[recipient] += amount; // Add the transferred amount to the recipient's balance.
        if (recipient == burnAddress) {
            _totalSupply -= amount; // Reduce the total supply when tokens are burned.
            TotalBurnedSupply += amount; // Track the total burned tokens.
        }
        emit Transfer(sender, recipient, amount); // Emit an event to log the transfer.
    }

    function _mint(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: mint to the zero address"); // Ensure the minting address is not zero.

        _totalSupply += amount; // Increase the total supply.
        balances[account] += amount; // Add the minted amount to the account's balance.
        emit Transfer(address(0), account, amount); // Emit an event to log the minting.
    }
}