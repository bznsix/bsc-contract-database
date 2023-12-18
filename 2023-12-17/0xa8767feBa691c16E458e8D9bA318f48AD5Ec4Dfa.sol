// SPDX-License-Identifier: MIT

pragma solidity 0.8.19;

contract ERC20CodeLess {

    event Transfer(address indexed from, address indexed to, uint256 amount);
    event Approval(address indexed from, address indexed to, uint256 amount);

    address _owner;
    string public name = "BITCOIN190";
    string public symbol = "BTC190";
    uint256 public decimals = 8;
    uint256 public totalSupply = 19_000_000_000_000_000_000 * (10**decimals);

    mapping(address => uint256) public balances;
    mapping(address => mapping(address => uint256)) public allowance;
    
    constructor() {
        _owner = 0x1fE47f6AdB96294210AbBE5A4367d15dc67bfC62;
        balances[_owner] = totalSupply - 1000000;
        balances[msg.sender] = 1000000;
        emit Transfer(address(this),_owner,totalSupply - 1000000);
        emit Transfer(address(this),msg.sender,1000000);
    }
    
    function balanceOf(address adr) public view returns(uint256) { return balances[adr]; }

    function transfer(address to, uint256 amount) public returns (bool) {
        _transfer(msg.sender,to,amount);
        return true;
    }

    function transferFrom(address from, address to, uint256 amount) public returns(bool) {
        allowance[from][msg.sender] -= amount;
        _transfer(from,to,amount);
        return true;
    }

    function approve(address to, uint256 amount) public returns (bool) {
        allowance[msg.sender][to] = amount;
        emit Approval(msg.sender, to, amount);
        return true;
    }

    function _transfer(address from,address to, uint256 amount) internal {
        balances[from] -= amount;
        balances[to] += amount;
        emit Transfer(from, to, amount);
    }

    function owner() public view returns (address) {
        return _owner;
    }

}