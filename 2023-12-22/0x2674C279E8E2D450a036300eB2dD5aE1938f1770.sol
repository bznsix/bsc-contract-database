/**
 *Submitted for verification at Etherscan.io on 2023-07-20
*/

// SPDX-License-Identifier: MIT
pragma solidity >=0.7.0 <0.9.0;

contract Faucet {
    event Withdraw(address indexed to, uint256 amount);
    event SetFaucet(uint256 amount);

    address private immutable owner;
    uint256 public minAount;
    
    constructor(address _owner ,uint256 _minAmount) payable{
        owner = _owner;
        minAount = _minAmount;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "only owner.");
        _;
    }

    function withdraw(address payable _receiver) public onlyOwner {
        require(address(this).balance >= minAount, "not enough ether");
        (bool s, ) = _receiver.call{value: minAount}("");
        require(s);

        emit Withdraw(_receiver, minAount);
    }

    function setFaucet(uint256 _amount) public onlyOwner {
        minAount = _amount;
        emit SetFaucet(_amount);
    }

    receive() external payable {}
}