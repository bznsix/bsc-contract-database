// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

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
}

contract BabyLFG2024 {
  using SafeMath for uint256;

  string public name = "Baby LFG 2024";
  string public symbol = "BLFG";
  uint8 public decimals = 18;
  uint256 public totalSupply = 2024420000000000000000000;
  uint256 public circulatingSupply = 2024420000000000000000000;

  mapping(address => uint256) public balances;
  mapping(address => mapping(address => uint256)) public allowed;

  address public constant burnAddress = 0x000000000000000000000000000000000000dEaD;
  address payable public owner;



  constructor() {
    owner = payable(msg.sender);
    balances[owner] = totalSupply;
    circulatingSupply = totalSupply;

  }

  modifier onlyOwner {
    require(msg.sender == owner, "Only owner can call this function");
    _;
}

  function withdrawBNB(uint256 amount) external onlyOwner {
    owner.transfer(amount);
}

  function transfer(address _to, uint256 _value) public returns (bool success) {
    require(_to != address(0), "Invalid address");
    require(_value > 0, "Invalid value");
    require(_value <= balances[msg.sender], "Insufficient balance");

    uint256 burnFee = _value.mul(2).div(100); // 2% burn fee
    uint256 contractFee = _value.mul(1).div(100); // 1% contract fee
    uint256 ownerFee = _value.mul(2).div(100); // 2% owner fee
    uint256 transferAmount = _value.sub(burnFee).sub(contractFee).sub(ownerFee);

    balances[msg.sender] = balances[msg.sender].sub(_value);
    balances[_to] = balances[_to].add(transferAmount);
    balances[burnAddress] = balances[burnAddress].add(burnFee);
    balances[address(this)] = balances[address(this)].add(contractFee);
    balances[owner] = balances[owner].add(ownerFee);
    circulatingSupply = circulatingSupply.sub(burnFee);

    emit Transfer(msg.sender, _to, transferAmount);
    emit Transfer(msg.sender, burnAddress, burnFee);
    emit Transfer(msg.sender, address(this), contractFee);
    emit Transfer(msg.sender, owner, ownerFee);

    return true;

}

function transferFrom(address _from, address _to, uint256 _value) public returns (bool success) {
require(_from != address(0), "Invalid sender address");
require(_to != address(0), "Invalid recipient address");
require(_value > 0, "Invalid value");
require(_value <= balances[_from], "Insufficient balance");
require(_value <= allowed[_from][msg.sender], "Insufficient allowance");
uint256 burnFee = _value.mul(2).div(100); // 2% para queima
uint256 contractFee = _value.mul(1).div(100); // 1% para o contrato
uint256 ownerFee = _value.mul(2).div(100); // 2% para o dono

uint256 transferAmount = _value.sub(burnFee).sub(contractFee).sub(ownerFee);

balances[_from] = balances[_from].sub(_value);
balances[_to] = balances[_to].add(transferAmount);
balances[burnAddress] = balances[burnAddress].add(burnFee);
balances[address(this)] = balances[address(this)].add(contractFee);
balances[owner] = balances[owner].add(ownerFee);
allowed[_from][msg.sender] = allowed[_from][msg.sender].sub(_value);
circulatingSupply = circulatingSupply.sub(burnFee);

emit Transfer(_from, _to, transferAmount);
emit Transfer(_from, burnAddress, burnFee);
emit Transfer(_from, address(this), contractFee);
emit Transfer(_from, owner, ownerFee);

return true;
}
function approve(address _spender, uint256 _value) public returns (bool success) {
require(_spender != address(0), "Invalid spender address");
allowed[msg.sender][_spender] = _value;
emit Approval(msg.sender, _spender, _value);
return true;
}

function allowance(address _owner, address _spender) public view returns (uint256 remaining) {
require(_owner != address(0), "Invalid owner address");
require(_spender != address(0), "Invalid spender address");
return allowed[_owner][_spender];
}

function balanceOf(address _owner) public view returns (uint256 balance) {
require(_owner != address(0), "Invalid address");
return balances[_owner];
}

function burn(uint256 _value) public {
require(_value > 0, "Invalid value");
require(balances[msg.sender] >= _value, "Insufficient balance");
balances[msg.sender] = balances[msg.sender].sub(_value);
circulatingSupply = circulatingSupply.sub(_value);

emit Transfer(msg.sender, burnAddress, _value);
}

event Transfer(address indexed _from, address indexed _to, uint256 _value);
event Approval(address indexed _owner, address indexed _spender, uint256 _value);
}