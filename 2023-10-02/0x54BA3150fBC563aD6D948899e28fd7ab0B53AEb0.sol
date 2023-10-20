// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IERC20 {
    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);

    function transfer(address to, uint256 _amount) external returns (bool);
    function balanceOf(address account) external view returns (uint256);
}

interface Calling {
    function _Transfer(address user, uint256 amount)external returns(bool);
}

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        this;
        return msg.data;
    }
}

abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );

    constructor() {
        _setOwner(_msgSender());
    }

    function Owner() public view virtual returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(Owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    function renounceOwnership() public virtual onlyOwner {
        _setOwner(address(0));
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(
            newOwner != address(0),
            "Ownable: new owner is the zero address"
        );
        _setOwner(newOwner);
    }

    function _setOwner(address newOwner) private {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}


contract MMITAmountManager is Ownable, Calling{

    address public tokenAddress;
    address private stakingAddress;

    constructor(address _tokenAddress){
        tokenAddress = _tokenAddress;
    }

    modifier addresses() {
        require( Owner() == _msgSender() ||stakingAddress == _msgSender(),"Only applicable addresses call this method" );
        _;

    }

    function _Transfer(address user, uint256 amount)external override addresses returns(bool){
          IERC20 token = IERC20(tokenAddress);
          bool succes =   token.transfer(user, amount);
          return succes;
    }

    function RescueAmount(address reciver, uint256 amount)external onlyOwner{
        IERC20 token = IERC20(tokenAddress);
        require(amount <= token.balanceOf(address(this)),"please enter valid amount");
        require(token.transfer(reciver, amount),"transaction failed");
    }

    function SetstakingAddress(address _addresses)external onlyOwner{
        stakingAddress = _addresses;
    }
    function setTokenAddress(address setadr)external onlyOwner{
        tokenAddress = setadr;
    }
}