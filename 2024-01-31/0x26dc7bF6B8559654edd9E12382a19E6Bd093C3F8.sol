// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

// File: @openzeppelin\contracts\token\ERC20\IERC20.sol
interface IERC20 {
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address to, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address from, address to, uint256 amount) external returns (bool);
}
 
contract JBX_RANK  {
    constructor() {
    }
    function distribution(address token, address[] memory _addr,   uint256[]  memory _amount) external {
    for(uint256 a=0;a<_addr.length;a++){
        IERC20(token).transferFrom(msg.sender,_addr[a],_amount[a]);
    }
    }
    
     
 
}