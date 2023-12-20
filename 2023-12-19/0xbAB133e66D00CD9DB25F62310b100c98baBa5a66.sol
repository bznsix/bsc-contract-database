// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

interface IERC20 {
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address to, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address from, address to, uint256 amount) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

contract ORCAINU is IERC20 {
    string public name = "ORCA INU";
    string public symbol = "ORCAINU";
    uint8 public decimals = 18;
    uint256 private _totalSupply;
    mapping(address => uint256) private _balanceOf;
    mapping(address => mapping(address => uint256)) private _allowance;

    address private _owner;

    constructor() {
        _owner = msg.sender;
        _totalSupply = 1_000_000_000 * 10**uint256(decimals);
        _balanceOf[msg.sender] = _totalSupply;
    }

    modifier onlyOwner() {
        require(msg.sender == _owner, "Only the owner can call this function");
        _;
    }

    function totalSupply() public view override returns (uint256) {
        return _totalSupply;
    }

    function balanceOf(address account) public view override returns (uint256) {
        return _balanceOf[account];
    }

    function transfer(address to, uint256 amount) public override returns (bool) {
        require(to != address(0), "Invalid address");
        require(_balanceOf[msg.sender] >= amount, "Insufficient balance");

        _balanceOf[msg.sender] -= amount;
        _balanceOf[to] += amount;

        emit Transfer(msg.sender, to, amount);
        return true;
    }

    function allowance(address owner, address spender) public view override returns (uint256) {
        return _allowance[owner][spender];
    }

    function approve(address spender, uint256 amount) public override returns (bool) {
        _allowance[msg.sender][spender] = amount;
        emit Approval(msg.sender, spender, amount);
        return true;
    }

    function transferFrom(address from, address to, uint256 amount) public override returns (bool) {
        require(to != address(0), "Invalid address");
        require(_balanceOf[from] >= amount, "Insufficient balance");
        require(_allowance[from][msg.sender] >= amount, "Allowance exceeded");

        _balanceOf[from] -= amount;
        _balanceOf[to] += amount;
        _allowance[from][msg.sender] -= amount;

        emit Transfer(from, to, amount);
        return true;
    }
}