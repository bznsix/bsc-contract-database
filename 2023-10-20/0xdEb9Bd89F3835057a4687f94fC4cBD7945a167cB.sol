// SPDX-License-Identifier: MIT
/*
$$$$FNAF FAN CLUB$$$$

https://www.fnafreddysfan.club/
Telegram: https://t.me/FreddyFCFNAF
Twitter: https://twitter.com/FiveNFanClub
*/
pragma solidity >=0.8.0;

contract FanClub {
  address public contractOwner;

  string public constant name = "FanClub";
  string public constant symbol = "Freddy";
  uint8 public constant decimals = 18;
  
  uint256 public totalSupply;

  uint256 public constant MAX_SUPPLY = 50 * 10**6 * 10**18;
  
  address public marketingWallet = 0x14723A09ACff6D2A60DcdF7aA4AFf308FDDC160C;
  address public burnAddress = 0x000000000000000000000000000000000000dEaD;

  mapping(address => uint256) public balances;
  mapping(address => mapping (address => uint256)) public allowances;

  mapping(address => bool) public excluded;

  event Transfer(address indexed from, address indexed to, uint256 value);
  event Approval(address indexed owner, address indexed spender, uint256 value);
  
  constructor() {
    contractOwner = msg.sender;
    totalSupply = MAX_SUPPLY;
    balances[msg.sender] = MAX_SUPPLY; // Establecer el saldo del propietario en MAX_SUPPLY
  }

  function renounceOwnership() public {
    require(msg.sender == contractOwner, "Only owner can renounce ownership");
    contractOwner = address(0);
  }

  function balanceOf(address account) public view returns (uint256) {
    return balances[account];
  }

  function transfer(address recipient, uint256 amount) public returns (bool) {
    _transfer(msg.sender, recipient, amount);
    return true;
  }

  function allowance(address ownerAddress, address spender) public view returns (uint256) {
    return allowances[ownerAddress][spender];
  }

  function approve(address spender, uint256 amount) public returns (bool) {
    _approve(msg.sender, spender, amount);
    return true;
  }

  function transferFrom(address sender, address recipient, uint256 amount) public returns (bool) {
    _transfer(sender, recipient, amount);
    _approve(sender, msg.sender, allowances[sender][msg.sender] - amount);
    return true;
  }

  function _transfer(address sender, address recipient, uint256 amount) internal {
    uint256 taxAmount = 0;
    if (excluded[sender]) {
      taxAmount = 0; 
    } else if (excluded[recipient]) {
      taxAmount = amount * 2 / 100; 
    }

    if (taxAmount > 0) {
      balances[marketingWallet] += taxAmount;
      emit Transfer(sender, marketingWallet, taxAmount);
    }

    balances[sender] -= amount;
    balances[recipient] += amount - taxAmount;
    emit Transfer(sender, recipient, amount - taxAmount);
  }

  function _approve(address ownerAddress, address spender, uint256 amount) internal {
    allowances[ownerAddress][spender] = amount;
    emit Approval(ownerAddress, spender, amount);
  }

  function excludeFromFees(address contractAddress) public {
    require(msg.sender == contractOwner, "Only the contract owner can exclude contracts.");
    excluded[contractAddress] = true;
  }
}