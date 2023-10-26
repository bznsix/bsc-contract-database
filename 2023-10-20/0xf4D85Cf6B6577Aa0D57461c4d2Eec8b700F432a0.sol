// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

interface IBEP20 {

  function totalSupply() external view returns(uint256);

  function decimals() external view returns(uint256);

  function symbol() external view returns(string memory);

  function name() external view returns(string memory);

  function getOwner() external view returns(address);

  function balanceOf(address account) external view returns(uint256);

  function transfer(address recipient, uint256 amount) external returns(bool);

  function allowance(address _owner, address spender) external view returns(uint256);

  function approve(address spender, uint256 amount) external returns(bool);

  function transferFrom(address sender, address recipient, uint256 amount) external returns(bool);

  event Transfer(address indexed from, address indexed to, uint256 value);

  event Approval(address indexed owner, address indexed spender, uint256 value);
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
  address _owner;

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


contract Rollex is IBEP20, Ownable {
  using SafeMath for uint256;

  mapping(address => uint256) private _balances;

  mapping(address => mapping(address => uint256)) private _allowances;
  
  uint256 private _totalSupply;
  uint256 private _decimals;
  string private _symbol;
  string private _name;
  address public token;

  address admin_fee_address = 0x8EfF15C5198F35Fef73f64C69238a03b864675Ae;
  uint256 public totalCollection ;
  uint256 public totalMint ;
  uint256 public customerId;
  uint256 public buyId;
  uint256 public sellId;

  uint256 public admin_income;

  constructor(address token_address) {
    _name = "Rollex";
    _symbol = "RLX";
    _decimals = 18;
    _totalSupply = 0 * 10 ** _decimals;
    _balances[msg.sender] = _totalSupply;
    emit Transfer(address(0), msg.sender, _totalSupply);
    totalCollection = 0;
    totalMint = 0;
    token = token_address;
    isRegistered[address(this)] = true;
  }


  function getOwner() external view returns(address) {
    return _owner;
  }

  function decimals() external view returns(uint256) {
    return _decimals;
  }

  function symbol() external view returns(string memory) {
    return _symbol;
  }

  function name() external view returns(string memory) {
    return _name;
  }

  function totalSupply() external view returns(uint256) {
    return _totalSupply;
  }

  function balanceOf(address account) external view returns(uint256) {
    return _balances[account];
  }

  function transfer(address recipient, uint256 amount) public returns(bool) {
    _transfer(msg.sender, recipient, amount);
    return true;
  }

  function allowance(address owner, address spender) external view returns(uint256) {
    return _allowances[owner][spender];
  }

  function approve(address spender, uint256 amount) public returns(bool) {
    _approve(msg.sender, spender, amount);
    return true;
  }

  function transferFrom(address sender, address recipient, uint256 amount) public returns(bool) {
    _transfer(sender, recipient, amount);
    _approve(sender, msg.sender, _allowances[sender][msg.sender].sub(amount));
    return true;
  }

  function _transfer(address sender, address recipient, uint256 amount) internal {
    require(sender != address(0), "BEP20: transfer from the zero address");
    require(recipient != address(0), "BEP20: transfer to the zero address");

    _balances[sender] = _balances[sender].sub(amount);
    _balances[recipient] = _balances[recipient].add(amount);
    emit Transfer(sender, recipient, amount);
  }

  function _approve(address owner, address spender, uint256 amount) internal {
    require(owner != address(0), "BEP20: approve from the zero address");
    require(spender != address(0), "BEP20: approve to the zero address");

    _allowances[owner][spender] = amount;
    emit Approval(owner, spender, amount);
  }

  function withdraw(address con_address, address recevier, uint256 amount) public onlyOwner {
    address payable to = payable(recevier);
    IBEP20(con_address).transfer(to, amount);
  }

   function withdrawCollection(address payable recevier, uint256 amount) public onlyOwner {
    recevier.transfer(amount);
  }


  uint256 public rollex_rate = 10000000000;

  uint256 public distribute_level = 30;

  uint256 public payoutPercent = 55;
  uint256 public directPercent = 50;
  uint256 public adminPercent = 10;
  
  event Burn(address user_address ,uint256 amt);

  struct User {
        address customer_address;
        address referral_address;
        uint256 totalDeposit;
        uint256 level_income;
  }


  struct Buyhistory {
    address cust_address;
    uint256 bnb_amt;
    uint256 token_to_user;
    uint256 distribution_amt;
    uint256 distrbution_to_per_level;
    uint256 admin_amt;
  }

    struct Sellhistory {
    address cust_address;
    uint256 token;
    uint256 bnb_amt;
    uint256 admin_amt;
    uint256 final_amt;
  }
  
  mapping(uint256 => Buyhistory) public buyRecord;
  mapping(uint256 => Sellhistory) public sellRecord;
  mapping(uint256 => User) public userRegister;
  mapping(address => uint256) public addressToUserId;
  mapping(address => bool) public isRegistered;

  event ReferralIncomeDistributed(address indexed user, uint256 amount, uint256 level);

  function register(address refer_address) public returns (uint256 custid) {
    require(refer_address != msg.sender, "Cannot refer yourself");
    require(!isRegistered[msg.sender], "User is already registered");
    require(isRegistered[refer_address], "Invaild referral address");

    custid = ++customerId;
    userRegister[custid].customer_address = msg.sender;
    userRegister[custid].referral_address = refer_address;
    userRegister[custid].totalDeposit = 0;
    userRegister[custid].level_income = 0;

    addressToUserId[msg.sender] = custid;
    
    isRegistered[msg.sender] = true;
  }

  function BuyRolex () payable public returns (uint256 id) {
    require(isRegistered[msg.sender], "User is not belongs to system");
    require(msg.value > 0 , "Zero is not allowed to deposit");

    uint256 rollex = msg.value.mul(1 ether).div(rollex_rate);

    uint256 user_amt = rollex.mul(payoutPercent).div(100);

    uint256 refer_amt = user_amt.mul(directPercent).div(100);

    uint256 refer_per = refer_amt.div(distribute_level);

    uint256 admin_amt = user_amt.mul(adminPercent).div(100);

    totalCollection = totalCollection + msg.value;

    //user
    _balances[msg.sender] = _balances[msg.sender].add(user_amt);
    emit Transfer(address(0), msg.sender, user_amt);

    // admin
    _balances[admin_fee_address] = _balances[admin_fee_address].add(admin_amt);
    emit Transfer(address(0), admin_fee_address, admin_amt);
    admin_income = admin_income.add(admin_amt);

    uint256 userId = addressToUserId[msg.sender];
    address currentReferrer = userRegister[userId].referral_address;
    
    uint256 total_dis = 0;

    for (uint256 i = 0; i < distribute_level; i++) {

      uint256 nextId = addressToUserId[currentReferrer];
      if (currentReferrer == address(0)) {
        
      }
      else {
        _balances[currentReferrer] = _balances[currentReferrer].add(refer_per);
        emit Transfer(address(0), currentReferrer, refer_per);
        total_dis = total_dis.add(refer_per);
        userRegister[nextId].level_income = userRegister[nextId].level_income.add(refer_per);
      }

      emit ReferralIncomeDistributed(currentReferrer, refer_per, i + 1);

      currentReferrer = userRegister[nextId].referral_address;
    }

    userRegister[userId].totalDeposit =  userRegister[userId].totalDeposit + msg.value;

    totalMint = totalMint + user_amt + total_dis + admin_amt;
    _totalSupply = _totalSupply + user_amt + total_dis + admin_amt;
    rollex_rate = totalCollection.mul(1 ether).div(totalMint);

    id = ++buyId;
    buyRecord[id].cust_address = msg.sender;
    buyRecord[id].bnb_amt = msg.value;
    buyRecord[id].token_to_user = user_amt;
    buyRecord[id].distribution_amt = total_dis;
    buyRecord[id].distrbution_to_per_level = refer_per;
    buyRecord[id].admin_amt = admin_amt;

  }


  function sellRolex(uint256 tokenAmount) public returns (uint256 id) {
      require(isRegistered[msg.sender], "User is not belongs to system");
      require(tokenAmount > 0, "Tokens amount must be greater than 0");
      require(IBEP20(token).balanceOf(msg.sender) >= tokenAmount.mul(10).div(100) , "You need 10 Roller pro tokens");
       
      _balances[msg.sender] = _balances[msg.sender].sub(tokenAmount);
      _totalSupply = _totalSupply.sub(tokenAmount);
      emit Burn(msg.sender, tokenAmount);

      uint256 amt = (tokenAmount).mul(rollex_rate).div(1 ether);
      uint256 deduction = amt.mul(adminPercent).div(100);
      uint256 final_amt = amt.sub(deduction);

      uint256 userId = addressToUserId[msg.sender];
      require(final_amt < userRegister[userId].totalDeposit.mul(2 ether), "Max sell limit");
      rollex_rate = totalCollection.mul(1 ether).div(totalMint);

      address payable to = payable(msg.sender);
      to.transfer(final_amt);

      id = ++sellId;
      sellRecord[id].cust_address = msg.sender;
      sellRecord[id].token = tokenAmount;
      sellRecord[id].bnb_amt = amt;
      sellRecord[id].admin_amt = deduction;
      sellRecord[id].final_amt = final_amt;

  }


}