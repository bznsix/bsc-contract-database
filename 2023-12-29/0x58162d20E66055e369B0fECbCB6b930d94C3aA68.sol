// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

interface IERC20 {
  function balanceOf(address account) external view returns(uint256);
  function transfer(address recipient, uint256 amount) external returns(bool);
}

library SafeMath {
  function mul(uint256 a, uint256 b) internal pure returns(uint256) {
    if (a == 0) {
      return 0;
    }
        uint256 c = a * b;
    assert(c / a == b);
    return c;
  }

  function div(uint256 a, uint256 b) internal pure returns(uint256) {
        // assert(b > 0); // Solidity automatically throws when dividing by 0
        uint256 c = a / b;
    // assert(a == b * c + a % b); // There is no case in which this doesn't hold
    return c;
  }

  function sub(uint256 a, uint256 b) internal pure returns(uint256) {
    assert(b <= a);
    return a - b;
  }

  function add(uint256 a, uint256 b) internal pure returns(uint256) {
        uint256 c = a + b;
    assert(c >= a);
    return c;
  }
}

 
contract Ownable {
  address public _owner;

  event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

  constructor() {
    _owner = msg.sender;
    emit OwnershipTransferred(address(0), msg.sender);
  }

  modifier onlyOwner() {
    require(msg.sender == _owner);
    _;
  }

  function transferOwnership(address newOwner) public onlyOwner {
    _transferOwnership(newOwner);
  }

  function _transferOwnership(address newOwner) internal {
    require(newOwner != address(0), "Ownable: new owner is the zero address");
    emit OwnershipTransferred(_owner, newOwner);
    _owner = newOwner;
  }
}


contract LiquidityManagerRLXT is IERC20, Ownable {

  using SafeMath for uint256;

  IERC20 public token;
  uint256 public rlxt_rate;

  uint256 public customerId;
  uint256 public buyId;

  struct User {
      address customer_address;
      uint256 totalDeposit;
      uint256 token_from_sc;
      uint256 totalWithdraw;
  }

  struct Buyhistory {
      address cust_address;
      uint256 bnb_amt;
      uint256 token_to_user;
  }

  
  mapping(uint256 => Buyhistory) public buyRecord;
  mapping(uint256 => User) public userRegister;
  mapping(address => uint256) public addressToUserId;
  mapping(address => bool) public isRegistered;

  constructor(address token_address) {
    token = IERC20(token_address);
    isRegistered[address(this)] = true;
    rlxt_rate = 0.001 ether;
  }

  function balanceOf(address account) external view override returns(uint256) {
  // implementation of the balanceOf function
  }

  function transfer(address recipient, uint256 amount) external override returns(bool) {
  // implementation of the transfer function
  }

  function withdrawCollection(address payable recevier, uint256 amount) public onlyOwner {
    recevier.transfer(amount);
  }

  function register() public returns (uint256 custid) {
    require(!isRegistered[msg.sender], "User is already registered");

    custid = ++customerId;
    userRegister[custid].customer_address = msg.sender;
    userRegister[custid].totalDeposit = 0;
    userRegister[custid].token_from_sc = 0;
    userRegister[custid].totalWithdraw = 0;

    addressToUserId[msg.sender] = custid;
    
    isRegistered[msg.sender] = true;
  }


  function BuyRlxt () payable public returns (uint256 id) {
    require(isRegistered[msg.sender], "User is not registered.");

    uint256 token_amt = msg.value.mul(1 ether).div(rlxt_rate);

    require(IERC20(token).balanceOf(address(this)) >= token_amt, "Unable to buy RLXT.");

    IERC20(token).transfer(msg.sender, token_amt);

    id = ++buyId;
    buyRecord[id].cust_address = msg.sender;
    buyRecord[id].bnb_amt = msg.value;
    buyRecord[id].token_to_user = token_amt;

    uint256 userId = addressToUserId[msg.sender];
    userRegister[userId].totalDeposit += msg.value;
    userRegister[userId].token_from_sc += token_amt;

  }

  function updateRate(uint256 new_rate) public onlyOwner {
     rlxt_rate = new_rate;
  }

  function bnbAmount() public view returns(uint256) {
     return address(this).balance;
  }

  function update_sellvalue(address user_address, uint256 token_amt, uint256 bnb_amt) public onlyOwner {
    require(isRegistered[user_address], "User is not registered.");

    uint256 userId = addressToUserId[user_address];
    userRegister[userId].token_from_sc -= token_amt;
    userRegister[userId].totalWithdraw += bnb_amt;
  }

}