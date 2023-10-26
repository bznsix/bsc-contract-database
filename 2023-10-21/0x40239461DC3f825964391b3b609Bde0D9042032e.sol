// SPDX-License-Identifier: MIT
pragma solidity ^0.8.2;

/**
 * @title Arktos Coin (ARK) Token
 * @dev ERC-20 token with additional features like burning, minting, and airdrops.
 */
contract Token {
    mapping(address => uint) public balances; // Balances of token holders
    mapping(address => mapping(address => uint)) public allowance; // Allowance for spender
    uint256 public totalSupply; // Total supply of the token
    string public name = "Arktos Coin"; // Name of the token
    string public symbol = "ARK"; // Symbol of the token
    uint8 public decimals = 18; // Decimals for token division
    address public owner; // Owner of the contract
    uint8 public burnFeePercentage = 1; // 1% burn fee by default

    event Transfer(address indexed from, address indexed to, uint value); // Emitted when tokens are transferred
    event Approval(address indexed owner, address indexed spender, uint value); // Emitted when an allowance is set
    event Mint(address indexed to, uint value); // Emitted when new tokens are minted
    event Burn(address indexed from, uint value); // Emitted when tokens are burned
    event Airdrop(address indexed from, address[] addresses, uint[] values); // Emitted during an airdrop

    /**
     * @dev Constructor to initialize the contract with an initial supply.
     */
    constructor() {
        totalSupply = 21_000_000 * 10**uint256(decimals);
        balances[msg.sender] = totalSupply;
        owner = msg.sender;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner can call this function");
        _;
    }

    /**
     * @dev Get the balance of a specific address.
     * @param account The address to query the balance for.
     * @return The balance of the specified address.
     */
    function balanceOf(address account) public view returns (uint) {
        return balances[account];
    }

    /**
     * @dev Transfer tokens to a specified address.
     * @param to The recipient address.
     * @param value The amount of tokens to send.
     * @return A boolean indicating success.
     */
    function transfer(address to, uint value) public returns (bool) {
        require(balances[msg.sender] >= value, 'balance too low');
        uint burnAmount = (value * burnFeePercentage) / 100;
        uint transferAmount = value - burnAmount;
        _burn(msg.sender, burnAmount);
        _transfer(msg.sender, to, transferAmount);
        return true;
    }

    /**
     * @dev Transfer tokens from one address to another.
     * @param from The sender's address.
     * @param to The recipient address.
     * @param value The amount of tokens to send.
     * @return A boolean indicating success.
     */
    function transferFrom(address from, address to, uint value) public returns (bool) {
        require(balances[from] >= value, 'balance too low');
        require(allowance[from][msg.sender] >= value, 'allowance too low');
        uint burnAmount = (value * burnFeePercentage) / 100;
        uint transferAmount = value - burnAmount;
        _burn(from, burnAmount);
        _transfer(from, to, transferAmount);
        allowance[from][msg.sender] -= value;
        return true;
    }

    /**
     * @dev Approve a spender to spend a specified amount of tokens on your behalf.
     * @param spender The address allowed to spend tokens.
     * @param value The maximum amount of tokens they can spend.
     * @return A boolean indicating success.
     */
    function approve(address spender, uint value) public returns (bool) {
        allowance[msg.sender][spender] = value;
        emit Approval(msg.sender, spender, value);
        return true;
    }

    /**
     * @dev Mint new tokens and add them to the total supply.
     * @param to The address to receive the newly minted tokens.
     * @param value The amount of tokens to mint.
     */
    function mint(address to, uint value) public onlyOwner {
        require(to != address(0), "Invalid address");
        totalSupply += value;
        balances[to] += value;
        emit Mint(to, value);
        emit Transfer(address(0), to, value);
    }

    /**
     * @dev Burn tokens, reducing both the total supply and the sender's balance.
     * @param value The amount of tokens to burn.
     */
    function burn(uint value) public onlyOwner {
        require(balances[msg.sender] >= value, "Insufficient balance to burn");
        balances[msg.sender] -= value;
        totalSupply -= value;
        emit Burn(msg.sender, value);
        emit Transfer(msg.sender, address(0), value);
    }

    /**
     * @dev Airdrop tokens to multiple addresses.
     * @param recipients An array of recipient addresses.
     * @param amounts An array of token amounts to send to each recipient.
     */
    function airdrop(address[] memory recipients, uint[] memory amounts) public onlyOwner {
        require(recipients.length == amounts.length, "Arrays length mismatch");

        for (uint i = 0; i < recipients.length; i++) {
            require(recipients[i] != address(0), "Invalid address");
            require(amounts[i] > 0, "Invalid amount for address");
            _transfer(msg.sender, recipients[i], amounts[i]);
        }

        emit Airdrop(msg.sender, recipients, amounts);
    }

    function _transfer(address sender, address recipient, uint amount) internal {
        balances[sender] -= amount;
        balances[recipient] += amount;
        emit Transfer(sender, recipient, amount);
    }

    function _burn(address from, uint amount) internal {
        balances[from] -= amount;
        totalSupply -= amount;
        emit Burn(from, amount);
        emit Transfer(from, address(0), amount);
    }

    /**
     * @dev Set the burn fee percentage, which determines the percentage of tokens to burn during transfers.
     * @param _feePercentage The new burn fee percentage.
     */
    function setBurnFeePercentage(uint8 _feePercentage) public onlyOwner {
        require(_feePercentage <= 100, "Invalid fee percentage");
        burnFeePercentage = _feePercentage;
    }
}