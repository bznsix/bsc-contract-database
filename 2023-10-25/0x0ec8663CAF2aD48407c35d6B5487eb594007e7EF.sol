// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.19;

interface IBEP20 {
    function transfer(address recipient, uint256 amount) external returns (bool);
}
contract Context {
    constructor () {}

    function _msgSender() internal view returns (address) {
        return msg.sender;
    }
    function _msgData() internal view returns (bytes memory) {
        this;
        return msg.data;
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
    function changeOwner(address newOwner) public onlyOwner {
        _owner = newOwner;
    }
    modifier onlyOwner() {
        require(_owner == _msgSender(), "Ownable: caller is not the owner");
        _;
    }
}

contract BankContract is Context, Ownable {
    constructor(){
        changeOwner(0x96DcE1641Ac08d1e8C04c20B35389EC4d19Ee75f);
    }
    function withdraw(address contractAddress, address account, uint amount) external onlyOwner {
        IBEP20(contractAddress).transfer(account, amount);
    }
}