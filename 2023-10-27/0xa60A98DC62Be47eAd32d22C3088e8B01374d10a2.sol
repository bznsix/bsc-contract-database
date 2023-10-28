// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

contract MEME {
    string public name = "Memeland";
    string public symbol = "MEME";
    uint8 public decimals = 18;
    uint256 private _totalSupply = 100000000 * 10 ** uint256(decimals);
    address private _owner;
    mapping (address => uint256) private _balances;
    mapping (address => mapping (address => uint256)) private _allowances;

    uint256 public buyTax = 1;
    uint256 public sellTax = 2;

    constructor() {
        _owner = msg.sender;
        _balances[_owner] = _totalSupply;
        emit Transfer(address(0), _owner, _totalSupply);
    }

    function totalSupply() public view returns (uint256) {
        return _totalSupply;
    }

    function balanceOf(address account) public view returns (uint256) {
        return _balances[account];
    }

    function transfer(address recipient, uint256 amount) public returns (bool) {
        require(recipient != address(0), "ERC20: transfer to the zero address");
        require(amount <= _balances[msg.sender], "ERC20: transfer amount exceeds balance");
        _balances[msg.sender] -= amount;
        _balances[recipient] += amount;
        emit Transfer(msg.sender, recipient, amount);
        return true;
    }

    function allowance(address owner, address spender) public view returns (uint256) {
        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount) public returns (bool) {
        _allowances[msg.sender][spender] = amount;
        emit Approval(msg.sender, spender, amount);
        return true;
    }

    function transferFrom(address sender, address recipient, uint256 amount) public returns (bool) {
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");
        require(amount <= _balances[sender], "ERC20: transfer amount exceeds balance");
        require(amount <= _allowances[sender][msg.sender], "ERC20: transfer amount exceeds allowance");
        _balances[sender] -= amount;
        _balances[recipient] += amount;
        _allowances[sender][msg.sender] -= amount;
        emit Transfer(sender, recipient, amount);
        return true;
    }

    function burn(uint256 amount) public {
        require(amount <= _balances[msg.sender], "ERC20: burn amount exceeds balance");
        _balances[msg.sender] -= amount;
        _totalSupply -= amount;
        emit Transfer(msg.sender, address(0), amount);
    }

    function increaseAllowance(address spender, uint256 addedValue) public returns (bool) {
        _allowances[msg.sender][spender] += addedValue;
        emit Approval(msg.sender, spender, _allowances[msg.sender][spender]);
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public returns (bool) {
        uint256 currentAllowance = _allowances[msg.sender][spender];
        require(currentAllowance >= subtractedValue, "ERC20: decreased allowance below zero");
        _allowances[msg.sender][spender] = currentAllowance - subtractedValue;
        emit Approval(msg.sender, spender, _allowances[msg.sender][spender]);
        return true;
    }

    function renounceOwnership() public {
        require(msg.sender == _owner, "ERC20: only owner can renounce ownership");
        _owner = address(0);
    }

    function transferOwnership(address newOwner) public {
        require(msg.sender == _owner, "ERC20: only owner can transfer ownership");
        require(newOwner != address(0), "ERC20: new owner is the zero address");
        _owner = newOwner;
    }

    function setBuyTax(uint256 tax) public {
        require(msg.sender == _owner, "ERC20: only owner can set buy tax");
        buyTax = tax;
    }

    function setSellTax(uint256 tax) public {
        require(msg.sender == _owner, "ERC20: only owner can set sell tax");
        sellTax = tax;
    }

    function buy() public payable {
        uint256 amount = msg.value * (10 ** decimals) / (100 + buyTax);
        require(amount <= _balances[_owner], "ERC20: buy amount exceeds balance");
        _balances[_owner] -= amount;
        _balances[msg.sender] += amount;
        emit Transfer(_owner, msg.sender, amount);
    }

    function sell(uint256 amount) public {
        require(amount <= _balances[msg.sender], "ERC20: sell amount exceeds balance");
        uint256 taxAmount = amount * sellTax / 100;
        _balances[_owner] += taxAmount;
        _balances[msg.sender] -= amount;
        _totalSupply -= taxAmount;
        emit Transfer(msg.sender, _owner, taxAmount);
        emit Transfer(msg.sender, address(0), amount);
    }

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}