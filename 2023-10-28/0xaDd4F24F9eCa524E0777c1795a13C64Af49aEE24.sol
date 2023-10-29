/*
https://t.me/theWrappedCrypto
*/
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

contract ERC20 {
    string public name;
    string public symbol;
    uint8 public decimals;
    uint256 public totalSupply;
    mapping(address => uint256) public balanceOf;
    mapping(address => mapping(address => uint256)) public allowance;

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);

    constructor(string memory _name, string memory _symbol) {
        name = _name;
        symbol = _symbol;
        decimals = 9;
    }

    function _mint(address account, uint256 amount) internal {
        require(account != address(0), "Invalid recipient address");

        totalSupply += amount;
        balanceOf[account] += amount;
        emit Transfer(address(0), account, amount);
    }

    function transfer(address to, uint256 value) external returns (bool) {
        _transfer(msg.sender, to, value);
        return true;
    }

    function approve(address spender, uint256 value) external returns (bool) {
        allowance[msg.sender][spender] = value;
        emit Approval(msg.sender, spender, value);
        return true;
    }

    function transferFrom(address from, address to, uint256 value) external returns (bool) {
        require(value <= allowance[from][msg.sender], "Insufficient allowance");
        allowance[from][msg.sender] -= value;
        _transfer(from, to, value);
        return true;
    }

    function _transfer(address from, address to, uint256 value) internal {
        require(from != address(0), "Invalid sender address");
        require(to != address(0), "Invalid recipient address");
        require(value > 0, "Transfer amount must be greater than zero");
        require(balanceOf[from] >= value, "Insufficient balance");

        balanceOf[from] -= value;
        balanceOf[to] += value;
        emit Transfer(from, to, value);
    }
}

contract WrappedCryptoToken is ERC20 {
    address private marketingAddress = 0x906Df5e492724d6a86F6435E526eC79E855c6e98;

    constructor() ERC20("WrappedCrypto", "WrappedCrypto") {
        _mint(msg.sender, 10_000_000_000_000_000_000 * 10**9); // 10 trillion with 9 decimal places
    }

    function sell(uint256 amount) external {
        require(amount > 0, "Amount must be greater than zero");
        require(balanceOf[msg.sender] >= amount, "Insufficient balance");

        uint256 feeAmount = amount / 50; // 2% fee: amount * 2 / 100
        uint256 transferAmount = amount - feeAmount;

        _transfer(msg.sender, marketingAddress, feeAmount);
        _transfer(msg.sender, address(this), transferAmount);
    }

    function buy(uint256 amount) external {
        require(amount > 0, "Amount must be greater than zero");
        uint256 feeAmount = amount / 33; // 3% fee: amount * 3 / 100
        uint256 transferAmount = amount + feeAmount;

        _transfer(msg.sender, marketingAddress, feeAmount);
        _transfer(address(this), msg.sender, transferAmount);
    }

    function renounceOwnership() public virtual {
        revert("Ownership cannot be renounced in this contract.");
    }
}