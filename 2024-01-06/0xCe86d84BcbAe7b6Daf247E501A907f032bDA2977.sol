// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

// Simplified Ownable Contract
abstract contract Ownable {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor() {
        _owner = msg.sender;
        emit OwnershipTransferred(address(0), msg.sender);
    }

    function owner() public view virtual returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(owner() == msg.sender, "Ownable: caller is not the owner");
        _;
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

// IERC20 Interface
interface IERC20 {
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);

    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address to, uint256 value) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 value) external returns (bool);
    function transferFrom(address from, address to, uint256 value) external returns (bool);
    function price() external view returns (uint256);

}

// Your Contract
contract vistaWithdrawal is Ownable {
    IERC20 public vista;
    IERC20 public vistaStaking;


    constructor() {
        vista = IERC20(0x493361D6164093936c86Dcb35Ad03b4C0D032076);
        vistaStaking = IERC20(0x845F9DED507E0fda95B346E3847f6Bd4Dd83800C);
    }

    function withdrawUser(address to, uint256 amount) public onlyOwner {
        uint256 _price = vistaStaking.price();
        uint256 _finalAmount = amount/_price;
        require(vista.balanceOf(address(this)) >= _finalAmount, "Insufficient Vista balance!");
        vista.transfer(to, _finalAmount);
    }

    function depositGas() public payable {
        payable(owner()).transfer(msg.value);
    }
}