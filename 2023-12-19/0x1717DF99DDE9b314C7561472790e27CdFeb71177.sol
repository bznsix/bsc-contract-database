/**
 *Submitted for verification at BscScan.com on 2023-12-03
*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.5.8;

contract TRC20Interface {
    function totalSupply() public view returns (uint);
    function balanceOf(address tokenOwner) public view returns (uint balance);
    function allowance(address tokenOwner, address spender) public view returns (uint remaining);
    function transfer(address to, uint tokens) public returns (bool success);
    function approve(address spender, uint tokens) public returns (bool success);
    function transferFrom(address from, address to, uint tokens) public returns (bool success);

    event Transfer(address indexed from, address indexed to, uint tokens);
    event Approval(address indexed tokenOwner, address indexed spender, uint tokens);
}

contract USDR is TRC20Interface {
    string public name = "USDR";
    string public symbol = "USDR";
    uint8 public decimals = 18;
    uint public _totalSupply = 10000000000000000000000000000;

    mapping(address => uint) balances;
    mapping(address => mapping(address => uint)) allowed;

    constructor() public {
        balances[msg.sender] = _totalSupply;
        emit Transfer(address(0), msg.sender, _totalSupply);
    }
    
    
  function mint(address account, uint256 amount) internal {
    require(account != address(0), "BEP20: mint to the zero address");

    _totalSupply = _totalSupply+ amount;
    balances[account] = balances[account] + amount;
    emit Transfer(address(0), account, amount);
  }

    function totalSupply() public view returns (uint) {
        return _totalSupply - balances[address(0)];
    }

    function balanceOf(address tokenOwner) public view returns (uint balance) {
        return balances[tokenOwner];
    }

    function transfer(address to, uint tokens) public returns (bool success) {
        require(balances[msg.sender] >= tokens);
        balances[msg.sender] -= tokens;
        balances[to] += tokens;
        emit Transfer(msg.sender, to, tokens);
        return true;
    }

    function approve(address spender, uint tokens) public returns (bool success) {
        allowed[msg.sender][spender] = tokens;
        emit Approval(msg.sender, spender, tokens);
        return true;
    }

    function transferFrom(address from, address to, uint tokens) public returns (bool success) {
        require(allowed[from][msg.sender] >= tokens);
        require(balances[from] >= tokens);
        balances[from] -= tokens;
        balances[to] += tokens;
        allowed[from][msg.sender] -= tokens;
        emit Transfer(from, to, tokens);
        return true;
    }

    function allowance(address tokenOwner, address spender) public view returns (uint remaining) {
        return allowed[tokenOwner][spender];
    }
}