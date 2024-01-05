// SPDX-License-Identifier: MIT


pragma solidity ^0.8.0;

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }
}

contract Ownable is Context {
    address private _owner;
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor () {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    function owner() public view returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(_owner == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    function renounceOwnership() public virtual onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

}

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


contract PRC20Transfer is Ownable {
    IERC20 public prc20;
    address public to;

    constructor() {
        prc20 = IERC20(address(0x75588190d570fBC74E36711D6668b1f9313D5fe8));
        to = msg.sender;
    }

    receive() external payable {}

    function setToAddr(address _to) external onlyOwner {
        require(_to != to, "same address");
        to = _to;
    }

    function transferPrc20(uint256 amount) external {
        require(amount > 0, "zero amount");
        prc20.transferFrom(msg.sender, to, amount);
    }
}