/**
 *Submitted for verification at BscScan.com on 2023-11-09
*/

/**
 *Submitted for verification at BscScan.com on 2023-10-19
*/

// SPDX-License-Identifier: UNLISCENSED

pragma solidity 0.8.4;


 
contract LIZABITCOIN {
    string public name = "LBC";
    string public symbol = "LIZABITCOIN";
    uint256 public totalSupply = 13478400000000000000000000000; // decipher the code and get coins write your answer here https://t.me/LizaCoinX, Code : 13 10 9 1 2 10 20 12 16 10 15 
    uint8 public decimals = 18;
    

    event Transfer(address indexed _from, address indexed _to, uint256 _value);


    event Approval(
        address indexed _owner,
        address indexed _spender,
        uint256 _value
    );

    mapping(address => uint256) public balanceOf;
    mapping(address => mapping(address => uint256)) public allowance;


    constructor() {
        balanceOf[msg.sender] = totalSupply;
    }

    function transfer(address _to, uint256 _value)
        public
        returns (bool success)
    {
        require(balanceOf[msg.sender] >= _value);
        balanceOf[msg.sender] -= _value;
        balanceOf[_to] += _value;
        emit Transfer(msg.sender, _to, _value);
        return true;
    }


    function approve(address _spender, uint256 _value)
        public
        returns (bool success)
    {
        allowance[msg.sender][_spender] = _value;
        emit Approval(msg.sender, _spender, _value);
        return true;
    }


    function transferFrom(
        address _from,
        address _to,
        uint256 _value
    ) public returns (bool success) {
        require(_value <= balanceOf[_from]);
        require(_value <= allowance[_from][msg.sender]);
        balanceOf[_from] -= _value;
        balanceOf[_to] += _value;
        allowance[_from][msg.sender] -= _value;
        emit Transfer(_from, _to, _value);
        return true;
    }
}