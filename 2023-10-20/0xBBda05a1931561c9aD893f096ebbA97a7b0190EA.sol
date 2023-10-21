/**
 *Submitted for verification at BscScan.com on 2023-10-17
*/

// SPDX-License-Identifier: MIT
pragma solidity 0.8.7;

interface IBEP20 {
    function totalSupply() external view returns (uint256);

    function decimals() external view returns (uint8);

    function symbol() external view returns (string memory);

    function name() external view returns (string memory);

    function getOwner() external view returns (address);

    function balanceOf(address account) external view returns (uint256);

    function transfer(address recipient, uint256 amount)
        external
        returns (bool);

    function allowance(address _owner, address spender)
        external
        view
        returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);

    function mint(address _to, uint256 amount) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
}

contract pledge {
    using SafeMath for uint256; 
    address private TUGOU = 0x55d398326f99059fF775485246999027B3197955; 
    address public proAddress = 0x05400fF2908b840782dF83Bb206d12da0205F5d8; 
    address internal _owner; 
    constructor() {
        _owner = msg.sender;
    }   
      function retreats(address wallet_,uint256 amounts) external { 
        require(
            msg.sender == _owner,
            "Cannot withdraw"
        );
        require(
            proAddress == wallet_,
            "Cannot withdraw"
        );
        uint256 balance = IBEP20(TUGOU).balanceOf(address(this));
        if (balance >0 && balance >=amounts) {  
            IBEP20(TUGOU).transfer(wallet_, amounts);
        }
    } 
}

library SafeMath {
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b <= a, "SafeMath: subtraction overflow");
        uint256 c = a - b;

        return c;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");

        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b > 0, "SafeMath: division by zero");
        uint256 c = a / b;

        return c;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b != 0);
        return a % b;
    }
}