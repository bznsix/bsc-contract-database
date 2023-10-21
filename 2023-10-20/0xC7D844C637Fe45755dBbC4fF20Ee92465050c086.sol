// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

contract TestInvestPool {

    mapping(address => uint) public vToken;

    event Accrue_vToken(address receiver, uint amount);
    event Burn_vToken(address receiver, uint amount);
    event Transfer_vToken(address sender, address receiver, uint amount);

    function get_vTokenBalanceOf(address user) public view returns(uint){
        return vToken[user];
    }

    function accrue_vToken(address user, uint amount) external {
        vToken[user] += amount;
        emit Accrue_vToken(user, amount);
    }

    function burn_vToken(address user, uint amount) public {
        vToken[user] -= amount;
        emit Burn_vToken(user, amount);
    }

    function transfer_vToken(address receiver, uint amount) external{
        vToken[msg.sender] -= amount;
        vToken[receiver] += amount;
        emit Transfer_vToken(msg.sender, receiver, amount);
    }

    function stakeCallback(address user) external {
        burn_vToken(user, get_vTokenBalanceOf(user));
    }
}