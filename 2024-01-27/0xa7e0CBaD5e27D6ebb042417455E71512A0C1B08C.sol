/**
 *Submitted for verification at BscScan.com on 2024-01-25
*/

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


contract MERCURY is IBEP20, Ownable {
  using SafeMath for uint256;

  mapping(address => uint256) private _balances;

  mapping(address => mapping(address => uint256)) private _allowances;
  mapping(uint256 => address) public admin_distribution;

  uint256[16] public levelPercentages; 
  uint256[16] public levelCondition; 
  
  uint256 private _totalSupply;
  uint256 private _decimals;
  string private _symbol;
  string private _name;
  address public token;
  address public usdt;

  uint256 public totalCollection ;
  uint256 public totalMint ;
  uint256 public customerId;
  uint256 public buyId;
  uint256 public sellId;

  uint256 public admin_income;

  constructor(address token_address, address usdt_address) {
    _name = "MERCURY";
    _symbol = "MRY";
    _decimals = 18;
    _totalSupply = 0 * 10 ** _decimals;
    _balances[msg.sender] = _totalSupply;
    emit Transfer(address(0), msg.sender, _totalSupply);
    totalCollection = 0;
    totalMint = 0;
    token = token_address;
    usdt = usdt_address;
    isRegistered[address(this)] = true;

    admin_distribution[1] = 0x37d01aF1864c7C3dB7EF171FDd9d1abD7c4a37CB;

    levelPercentages[1] = 5 ether;
    levelPercentages[2] = 3 ether;
    levelPercentages[3] = 2 ether;
    levelPercentages[4] = 1 ether;
    levelPercentages[5] = 1 ether;
    levelPercentages[6] = 1 ether;
    levelPercentages[7] = 1 ether;
    levelPercentages[8] = 1 ether;
    levelPercentages[9] = 1 ether;
    levelPercentages[10] = 1 ether;
    levelPercentages[11] = 1 ether;
    levelPercentages[12] = 0.5 ether;
    levelPercentages[13] = 0.5 ether;
    levelPercentages[14] = 0.5 ether;
    levelPercentages[15] = 0.5 ether;

    levelCondition[1] = 0;
    levelCondition[2] = 200;
    levelCondition[3] = 300;
    levelCondition[4] = 400;
    levelCondition[5] = 500;
    levelCondition[6] = 600;
    levelCondition[7] = 800;
    levelCondition[8] = 1000;
    levelCondition[9] = 1200;
    levelCondition[10] = 1400;
    levelCondition[11] = 1600;
    levelCondition[12] = 1800;
    levelCondition[13] = 2000;
    levelCondition[14] = 2200;
    levelCondition[15] = 2500;

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

  function getusdtBalance() public view returns (uint256) {
    return IBEP20(usdt).balanceOf(address(this));
  }

  function withdraw(address con_address, address recevier, uint256 amount) public onlyOwner {
    address payable to = payable(recevier);
    IBEP20(con_address).transfer(to, amount);
  }

  function withdrawBNB(address recevier,uint256 amount) public onlyOwner {
    require(address(this).balance >= amount, "Insufficient balance in the contract");
    address payable owner = payable(recevier);
    owner.transfer(amount);
  }

  uint256 public mry_rate = 240000000000000;

  uint256 public distribute_level = 15;

  uint256 public payoutPercent = 50;
  uint256 public directPercent = 20;
  uint256 public adminPercent = 10;

  uint256 public minBuy = 20 ether;
  uint256 public maxBuy = 1000 ether;
  
  struct User {
    address customer_address;
    address referral_address;
    uint256 totalDeposit;
    uint256 totalWithdraw;
    uint256 level_income;
    uint256 last_ts;
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

  function register(address refer_address) public returns (uint256 custid) {
    require(refer_address != msg.sender, "Cannot refer yourself");
    require(!isRegistered[msg.sender], "User is already registered");
    require(isRegistered[refer_address], "Invaild referral address");

    custid = ++customerId;
    userRegister[custid].customer_address = msg.sender;
    userRegister[custid].referral_address = refer_address;
    userRegister[custid].totalDeposit = 0;
    userRegister[custid].totalWithdraw = 0;
    userRegister[custid].level_income = 0;
    userRegister[custid].last_ts = 0;  

    addressToUserId[msg.sender] = custid;
    
    isRegistered[msg.sender] = true;
  }


  function getTotalLevelIncome(address sponsorAddress) public view returns (uint256) {
    uint256 count = 0;

    for (uint256 i = 1; i <= customerId; i++) {
        if (userRegister[i].referral_address == sponsorAddress) {
            count += userRegister[i].totalDeposit;
        }
    }
    return count;
  }


  function BuyMercury (uint256 usdtAmount) public returns (uint256 id) {
    require(isRegistered[msg.sender], "User is not belongs to system");
    require(usdtAmount >= minBuy, "Below minimum buy limit");
    require(usdtAmount <= maxBuy, "Exceeds maximum buy limit");

    require(IBEP20(usdt).approve(address(this),usdtAmount), "Failed to approve USDT transfer");
    require(IBEP20(usdt).transferFrom(msg.sender, address(this), usdtAmount), "Failed to transfer USDT");

    uint256 mercury =  usdtAmount.mul(1 ether).div(mry_rate);

    uint256 user_amt = mercury.mul(payoutPercent).div(100);

    uint256 admin_amt = mercury.mul(adminPercent).div(100);

    totalCollection = totalCollection + usdtAmount;

    //user
    _balances[msg.sender] = _balances[msg.sender].add(user_amt);
    emit Transfer(address(0), msg.sender, user_amt);

    //airdrop 
    uint256 airdrop_amt_user = usdtAmount.mul(100);
    IBEP20(token).transfer(payable(msg.sender), airdrop_amt_user);

    // admin
    _balances[admin_distribution[1]] = _balances[admin_distribution[1]].add(admin_amt);
    emit Transfer(address(0), admin_distribution[1], admin_amt);

    admin_income = admin_income.add(admin_amt);

    uint256 userId = addressToUserId[msg.sender];
    address currentReferrer = userRegister[userId].referral_address;
    
    uint256 total_dis = 0;

    for (uint256 i = 1; i < distribute_level; i++) {

      uint256 nextId = addressToUserId[currentReferrer];
      if (currentReferrer == address(0)) {}
      else {
          if(getTotalLevelIncome(currentReferrer) >= levelCondition[i])
          {
            uint256 refer_per = mercury.mul(levelPercentages[i]).div(100).div(1 ether);
            _balances[currentReferrer] = _balances[currentReferrer].add(refer_per);
            emit Transfer(address(0), currentReferrer, refer_per);
            total_dis += refer_per;
            userRegister[nextId].level_income = userRegister[nextId].level_income.add(refer_per);
          }
      }
      currentReferrer = userRegister[nextId].referral_address;
    }

    userRegister[userId].totalDeposit = userRegister[userId].totalDeposit.add(usdtAmount);

    totalMint = totalMint + user_amt + total_dis + admin_amt;
    _totalSupply = _totalSupply + user_amt + total_dis + admin_amt;
    mry_rate = IBEP20(usdt).balanceOf(address(this)).mul(1 ether).div(_totalSupply);

    id = ++buyId;
    buyRecord[id].cust_address = msg.sender;
    buyRecord[id].bnb_amt = usdtAmount;
    buyRecord[id].token_to_user = user_amt;
    buyRecord[id].distribution_amt = total_dis;
    buyRecord[id].distrbution_to_per_level = 0;
    buyRecord[id].admin_amt = admin_amt;

  }


function sellMercury(uint256 tokenAmount) public returns (uint256 id) {
    require(isRegistered[msg.sender], "User is not registered");
    require(tokenAmount > 0, "Token amount must be greater than 0");

    uint256 mry_per = tokenAmount.mul(1).div(100);
    require(IBEP20(token).balanceOf(msg.sender) >= mry_per , "You need 1% Mercury tokens on withdrawal amount");

    uint256 userId = addressToUserId[msg.sender];
    // Ensure the last sell operation was more than 24 hours ago
    require(userRegister[userId].last_ts + 1 days <= block.timestamp, "Sell operation can only be performed once every 24 hours");

    uint256 bnbAmount = tokenAmount.mul(mry_rate).div(1 ether);
    uint256 adminServiceCharge = bnbAmount.mul(20).div(100); // 20% of bnbAmount
    bnbAmount = bnbAmount.sub(adminServiceCharge);

    // Check if the contract has enough BNB to proceed with the withdrawal
    require(IBEP20(usdt).balanceOf(address(this)) >= bnbAmount, "Not enough USDT in the contract to proceed with the withdrawal");

    // Ensure the bnbAmount is less than or equal to the total deposit of the user
    require(bnbAmount <= userRegister[userId].totalDeposit.mul(3), "Cannot withdraw more than 3x total deposit at a time");

    // Burn the token amount and update total supply
    _balances[msg.sender] = _balances[msg.sender].sub(tokenAmount);
    _totalSupply = _totalSupply.sub(tokenAmount);
    emit Transfer(msg.sender, address(0), tokenAmount); // Emit a transfer event to the zero address to signify burning

    // Send USDT to the user's address
    IBEP20(usdt).transfer(payable(msg.sender), bnbAmount);
    mry_rate = IBEP20(usdt).balanceOf(address(this)).mul(1 ether).div(_totalSupply);

    // Update the last sell timestamp
    userRegister[userId].last_ts = block.timestamp;
    // update the totalwithdraw
    userRegister[userId].totalWithdraw = bnbAmount;
   
   // Record the sell history
    id = ++sellId;
    sellRecord[id] = Sellhistory({
        cust_address: msg.sender,
        token: tokenAmount,
        bnb_amt: bnbAmount,
        admin_amt: adminServiceCharge,
        final_amt: bnbAmount
    });

    return id;
}
}