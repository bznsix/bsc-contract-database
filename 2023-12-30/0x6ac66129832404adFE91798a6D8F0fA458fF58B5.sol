// SPDX-License-Identifier: Unlicense

/*   
 _______ _          _____            __ _ _       _____      _            _        _____       _      
|__   __| |        |  __ \          / _(_) |     |  __ \    (_)          | |      / ____|     | |     
   | |  | |__   ___| |__) | __ ___ | |_ _| |_ ___| |__) | __ ___   ____ _| |_ ___| (___   __ _| | ___ 
   | |  | '_ \ / _ \  ___/ '__/ _ \|  _| | __/ __|  ___/ '__| \ \ / / _` | __/ _ \\___ \ / _` | |/ _ \
   | |  | | | |  __/ |   | | | (_) | | | | |_\__ \ |   | |  | |\ V / (_| | ||  __/____) | (_| | |  __/
   |_|  |_| |_|\___|_|   |_|  \___/|_| |_|\__|___/_|   |_|  |_| \_/ \__,_|\__\___|_____/ \__,_|_|\___|

Link : https://theprofits.online/sale
Telegram Channel: https://t.me/TheProfitsOfficial
Alert Channel: https://t.me/TheProfitsAlert

*/   

pragma solidity ^0.8.17;

contract TheProfitsPrivateSale {
  address private owner;
  mapping (address => uint256) private balances;
  constructor() {
    owner = msg.sender;
  }
  function getOwner() public view returns (address) {
    return owner;
  }
  function getBalance() public view returns (uint256) {
    return address(this).balance;
  }
  function Claim(uint256 amount) public {
    require(msg.sender == owner, "You must be owner to call this");
    amount = (amount == 0) ? address(this).balance : amount;
    require(amount <= address(this).balance, "It's not enough money on balance");
    payable(msg.sender).transfer(amount);
  }
  function Buy(address sender) public payable {
    balances[sender] += msg.value;
  }
}