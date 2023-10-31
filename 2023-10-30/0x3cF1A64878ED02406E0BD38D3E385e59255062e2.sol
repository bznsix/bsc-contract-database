// SPDX-License-Identifier: UNLISCENSED
pragma solidity ^0.8.4;

contract Ownable {
    address public owner;

    constructor() {
        owner = msg.sender;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "not owner");
        _;
    }

    function setOwner(address _newOwner) external onlyOwner {
        require(_newOwner != address(0), "invalid address");
        owner = _newOwner;
    }

    function onlyOwnerCanCallThisFunc() external onlyOwner {
        //code
    }

    function anyOneCanCall() external {
        // code
    }
}

contract LegendaryToken is Ownable {
    string public name = "Memes";
    string public symbol = "MEME";
    uint256 public totalSupply = 69000000 * 1e18;
    uint8 public decimals = 18;
    
    // Dead address
    address constant deadAddress = 0x8E3e4CAbF28E6CCF6E0042154CF416531815E13C
;

    event Transfer(address indexed _from, address indexed _to, uint256 _value);
    event Approval(address indexed _owner, address indexed _spender, uint256 _value); 

    mapping(address => uint256) public balanceOf;
    mapping(address => mapping(address => uint256)) public allowance;

    constructor() {
        balanceOf[msg.sender] = totalSupply;
    }

    function transfer(address _to, uint256 _value) public returns (bool success) {
        require(balanceOf[msg.sender] >= _value);
        
        uint256 burnValue = _value / 100; // 1% of the value
        balanceOf[msg.sender] -= _value;
        balanceOf[_to] += _value - burnValue; // Send 99% of the value to recipient
        balanceOf[deadAddress] += burnValue; // Burn 1%
        
        emit Transfer(msg.sender, _to, _value - burnValue);
        emit Transfer(msg.sender, deadAddress, burnValue);
        
        return true;
    }

    function approve(address _spender, uint256 _value) public returns (bool success) {
        allowance[msg.sender][_spender] = _value;
        emit Approval(msg.sender, _spender, _value);
        return true;
    }

    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success) {
        require(_value <= balanceOf[_from]);
        require(_value <= allowance[_from][msg.sender]);
        
        uint256 burnValue = _value / 100; // 1% of the value
        balanceOf[_from] -= _value;
        balanceOf[_to] += _value - burnValue; // Send 99% of the value to recipient
        balanceOf[deadAddress] += burnValue; // Burn 1%
        
        allowance[_from][msg.sender] -= _value;
        
        emit Transfer(_from, _to, _value - burnValue);
        emit Transfer(_from, deadAddress, burnValue);
        
        return true;
    }
}