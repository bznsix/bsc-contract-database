// SPDX-License-Identifier: MIT
pragma solidity ^0.8.6;

interface IERC20 {
    function balanceOf(address account) external view returns (uint256);
    function transfer(address to, uint256 amount) external returns (bool);
}

abstract contract Ownable {
    address internal _owner;

    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );

    constructor() {
        address msgSender = msg.sender;
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    function owner() public view returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(_owner == msg.sender, "!owner");
        _;
    }

    function renounceOwnership() public virtual onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "new is 0");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

contract LPLock is Ownable{
    address public immutable LP;
    uint256 public Lock_Period;

    constructor(address lp) {
        LP = lp;
        Lock_Period = block.timestamp;
    }

    function addPeriod(uint256 second) external onlyOwner() returns (bool) {
        Lock_Period += second;

        return true;
    }

    function Withdraw(address token) external onlyOwner() returns (bool) {
        if(token == LP) {
            require(block.timestamp >= Lock_Period, 'Too early');

            IERC20(LP).transfer(msg.sender, IERC20(LP).balanceOf(address(this)));

            return true;
        }
        
        IERC20(token).transfer(msg.sender, IERC20(token).balanceOf(address(this)));

        return true;
    }
}