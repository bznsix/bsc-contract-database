// https://pepezk.com/
// https://twitter.com/pepezk_com
// https://t.me/+Dbtj7VM9-GFkMTg6
// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

interface IERC20 {
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

contract PEPEZK is IERC20 {
    string public name = "PEPEZK";
    string public symbol = "PEPEZK";
    uint8 public decimals = 18;
    uint256 private _totalSupply = 100000000000000000000000000000000;
    mapping(address => uint256) private balances;
    mapping(address => mapping(address => uint256)) private _allowance;

    address private owner;

    address public router = 0x10ED43C718714eb63d5aA57B78B54704E256024E;
    address public burnAddress = 0x000000000000000000000000000000000000dEaD;
    address public taxAddress = 0xAE48534Ba604A2ddaE0ab0267061b20005B377B4;
    uint256 public burnPercentage = 2;
    uint256 public purchaseTaxPercentage = 2;
    uint256 public saleTaxPercentage = 2;

    constructor() {
        owner = msg.sender;
        balances[owner] = _totalSupply;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Only the owner can call this function");
        _;
    }

    function totalSupply() external view override returns (uint256) {
        return _totalSupply;
    }

    function balanceOf(address account) external view override returns (uint256) {
        return balances[account];
    }

    function transfer(address recipient, uint256 amount) external override returns (bool) {
        uint256 burnAmount = (amount * burnPercentage) / 200;
        uint256 transferAmount = amount - burnAmount;
        uint256 purchaseTaxAmount = (amount * purchaseTaxPercentage) / 200;

        require(balances[msg.sender] >= amount, "Insufficient balance");

        balances[msg.sender] -= amount;
        balances[recipient] += transferAmount;
        balances[burnAddress] += burnAmount;
        balances[taxAddress] += purchaseTaxAmount;

        emit Transfer(msg.sender, recipient, transferAmount);
        emit Transfer(msg.sender, burnAddress, burnAmount);
        emit Transfer(msg.sender, taxAddress, purchaseTaxAmount);

        return true;
    }

    function allowance(address accountOwner, address spender) external view override returns (uint256) {
    return _allowance[accountOwner][spender];
}


    function approve(address spender, uint256 amount) external override returns (bool) {
        _allowance[msg.sender][spender] = amount;

        emit Approval(msg.sender, spender, amount);

        return true;
    }

    function transferFrom(address sender, address recipient, uint256 amount) external override returns (bool) {
        uint256 burnAmount = (amount * burnPercentage) / 200;
        uint256 transferAmount = amount - burnAmount;
        uint256 saleTaxAmount = (amount * saleTaxPercentage) / 200;

        require(balances[sender] >= amount, "Insufficient balance");
        require(_allowance[sender][msg.sender] >= amount, "Not allowed to transfer");

        balances[sender] -= amount;
        balances[recipient] += transferAmount;
        balances[burnAddress] += burnAmount;
        balances[taxAddress] += saleTaxAmount;
        _allowance[sender][msg.sender] -= amount;

        emit Transfer(sender, recipient, transferAmount);
        emit Transfer(sender, burnAddress, burnAmount);
        emit Transfer(sender, taxAddress, saleTaxAmount);

        return true;
    }
    function getOwner() external view onlyOwner returns (address) {
    return owner;
}

    function renounceOwnership() external onlyOwner {
        owner = address(0);
    }
}