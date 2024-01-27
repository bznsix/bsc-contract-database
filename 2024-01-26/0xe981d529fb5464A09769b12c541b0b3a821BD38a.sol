/**
 *Submitted for verification at BscScan.com on 2024-01-19
*/

// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

interface IBEP20 {

  function totalSupply() external view returns(uint256);

  function decimals() external view returns(uint256);

  function symbol() external view returns(string memory);

  function name() external view returns(string memory);

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
  address private _owner;

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


contract RollexRider is IBEP20, Ownable {
  using SafeMath for uint256;

  mapping(address => uint256) private _balances;

  mapping(address => mapping(address => uint256)) private _allowances;
  mapping(uint256 => address) public admin_distribution;

  uint256[12] public levelPercentages; 
  uint256[12] public tlb1;
  uint256[12] public tlb2;
  
  uint256 private _totalSupply;
  uint256 private _decimals;
  string private _symbol;
  string private _name;
  address public token;
  address public superAdmin;
  address public rollexInu;

  uint256 public totalCollection ;
  uint256 public totalMint ;
  uint256 public customerId;
  uint256 public buyId;
  uint256 public sellId;
  
  uint256 public admin_income;

  constructor(address token_address, address superadmin, address rollex_inu) {
    _name = "Rollex Rider";
    _symbol = "RLR";
    _decimals = 18;
    _totalSupply = 0 * 10 ** _decimals;
    _balances[msg.sender] = _totalSupply;
    emit Transfer(address(0), msg.sender, _totalSupply);
    totalCollection = 0;
    totalMint = 0;
    token = token_address;
    isRegistered[address(this)] = true;
    superAdmin = superadmin;
    rollexInu = rollex_inu;

    admin_distribution[1] = 0x3F77aB79bFb2cd12a90416a10F6f82720E44253D;
    admin_distribution[2] = 0x4e66F98EBEaF992b9a5D53c1d1CB80c2c0a1cb03;

    levelPercentages[1] = 8;
    levelPercentages[2] = 1;
    levelPercentages[3] = 1;
    levelPercentages[4] = 1;
    levelPercentages[5] = 1;
    levelPercentages[6] = 1;
    levelPercentages[7] = 1;
    levelPercentages[8] = 1;
    levelPercentages[9] = 1;
    levelPercentages[10] = 1;
    levelPercentages[11] = 1;

    tlb1[1] = 10 ether;
    tlb1[2] = 20 ether;
    tlb1[3] = 40 ether;
    tlb1[4] = 80 ether;
    tlb1[5] = 160 ether;
    tlb1[6] = 320 ether;
    tlb1[7] = 640 ether;
    tlb1[8] = 1280 ether;
    tlb1[9] = 2560 ether;
    tlb1[10] = 5120 ether;
    tlb1[11] = 10240 ether;


    tlb2[1] = 1 ether;
    tlb2[2] = 2 ether;
    tlb2[3] = 4 ether;
    tlb2[4] = 8 ether;
    tlb2[5] = 16 ether;
    tlb2[6] = 32 ether;
    tlb2[7] = 64 ether;
    tlb2[8] = 128 ether;
    tlb2[9] = 256 ether;
    tlb2[10] = 512 ether;
    tlb2[11] = 1024 ether;
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

  function balanceOf(address account) public view returns(uint256) {
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

    uint256 amt = amount.mul(80).div(100);
    uint256 burn_amt = amount.sub(amt);
    _balances[sender] = _balances[sender].sub(amount);
    _balances[recipient] = _balances[recipient].add(amt);
    emit Transfer(sender, recipient, amt);
    _totalSupply = _totalSupply.sub(burn_amt);
    emit Transfer(sender, address(0), burn_amt);
  }

  function _approve(address owner, address spender, uint256 amount) internal {
    require(owner != address(0), "BEP20: approve from the zero address");
    require(spender != address(0), "BEP20: approve to the zero address");

    _allowances[owner][spender] = amount;
    emit Approval(owner, spender, amount);
  }

  function getBnbBalance() public view returns (uint256) {
    return address(this).balance;
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

  uint256 public rollex_rate = 1000000000000;
  uint256 public inuRate = 39000000000000;

  uint256 public distribute_level = 11;

  uint256 public payoutPercent = 32;
  uint256 public airdropPayout = 20;
  uint256 public directPercent = 18;
  uint256 public adminOnePercent = 1.5 ether;
  uint256 public adminTwoPercent = 2.5 ether;

  uint256 public tlb1_percent = 10;
  uint256 public tlb2_percent = 10;

  struct User {
        address customer_address;
        address referral_address;
        uint256 totalDeposit;
        uint256 totalWithdraw;
        uint256 level_income;
        uint256 tlb_income;
        uint256 last_ts;
        uint256 position;
        bool status;
  }

  struct Buyhistory {
    address cust_address;
    uint256 bnb_amt;
    uint256 token_to_user;
    uint256 airdrop_amt;
    uint256 distribution_amt;
    uint256 distrbution_to_per_level;
    uint256 admin_amt;
  }

  struct Sellhistory {
    address cust_address;
    uint256 token;
    uint256 bnb_amt;
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
    require(isRegistered[refer_address] || superAdmin == refer_address, "Invaild referral address");

    custid = ++customerId;
    userRegister[custid].customer_address = msg.sender;
    userRegister[custid].referral_address = refer_address;
    userRegister[custid].totalDeposit = 0;
    userRegister[custid].totalWithdraw = 0;
    userRegister[custid].level_income = 0;
    userRegister[custid].tlb_income = 0;
    userRegister[custid].last_ts = 0;  
    userRegister[custid].position = 0;  
    userRegister[custid].status = true;

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

  function getUserStatus(uint256 userId) public view returns (bool) {
        require(userId > 0 && userId <= customerId, "Invalid user ID");

        return userRegister[userId].status;
  }

  function updateUserPosition(address userAddress, uint256 newPosition) public onlyOwner {
    require(isRegistered[userAddress], "User is not registered");
    uint256 userId = addressToUserId[userAddress];
    userRegister[userId].position = newPosition;
    
   }

  function distributeTLBPosition(uint256 userId) internal {
    address currentReferrer = userRegister[userId].referral_address;

   while (userId >= 1) {
        uint256 nextId = addressToUserId[currentReferrer];
        
        if (userRegister[nextId].totalDeposit >= tlb1[userId] || userRegister[nextId].totalDeposit >= tlb2[userId] || userRegister[nextId].position == 1 || userRegister[nextId].position == 2) {
            uint256 refer_per = msg.value.mul(tlb1_percent).div(100);
            payable(currentReferrer).transfer(refer_per);
            userRegister[nextId].tlb_income = userRegister[nextId].tlb_income.add(refer_per);
        }

        currentReferrer = userRegister[nextId].referral_address;
        userId = nextId;
    }
}


  function BuyRollexRider () payable public returns (uint256 id) {
    require(isRegistered[msg.sender], "User is not belongs to system");
    require(balanceOf(msg.sender) == 0, "Rollex ultima balance must be zero before buying");
    require(msg.value > 1000000000000 , "Minimum buy limit");
    require(msg.value <= 5000000000000000000 , "Maximum buy limit");
    
    uint256 userbnbValue = msg.value.mul(payoutPercent).div(100);
    
    uint256 user_amt = userbnbValue.div(rollex_rate).mul( 1 ether);

    uint256 airdrop_amt = msg.value.mul(airdropPayout).div(100);

    uint256 admin_amt_1 = msg.value.mul(adminOnePercent).div(100).div(1 ether);
    uint256 admin_amt_2 = msg.value.mul(adminTwoPercent).div(100).div(1 ether);

    totalCollection = totalCollection + msg.value;

    //user
    _balances[msg.sender] = _balances[msg.sender].add(user_amt);
    emit Transfer(address(0), msg.sender, user_amt);

    //airdrop 
    uint256 airdrop_amt_user = airdrop_amt.div(inuRate).mul(1 ether);
    IBEP20(rollexInu).transfer(msg.sender, airdrop_amt_user);

     // admin
    uint256 admin_amt = admin_amt_1.add(admin_amt_2);

    payable(admin_distribution[1]).transfer(admin_amt_1);
    payable(admin_distribution[2]).transfer(admin_amt_2);

    admin_income = admin_income.add(admin_amt);

    uint256 userId = addressToUserId[msg.sender];
    address currentReferrer = userRegister[userId].referral_address;
    
    uint256 total_dis = 0;

    for (uint256 i = 1; i < distribute_level; i++) {

    uint256 nextId = addressToUserId[currentReferrer];
      if (currentReferrer == address(0)) {}
      else {
            uint256 refer_per = msg.value.mul(levelPercentages[i]).div(100);
            payable(currentReferrer).transfer(refer_per);

            total_dis += refer_per;
            userRegister[nextId].level_income = userRegister[nextId].level_income.add(refer_per);
      }
      currentReferrer = userRegister[nextId].referral_address;
    }
    userRegister[userId].totalDeposit = userRegister[userId].totalDeposit.add(msg.value);

    distributeTLBPosition(userId);

    if(userRegister[userId].status == false)
    {
        userRegister[userId].status = true;
    }

    totalMint = totalMint + user_amt;
    _totalSupply = _totalSupply + user_amt;
    rollex_rate = address(this).balance.mul(1 ether).div(_totalSupply);

    id = ++buyId;
    buyRecord[id].cust_address = msg.sender;
    buyRecord[id].bnb_amt = msg.value;
    buyRecord[id].token_to_user = user_amt;
    buyRecord[id].airdrop_amt = airdrop_amt;
    buyRecord[id].distribution_amt = total_dis;
    buyRecord[id].distrbution_to_per_level = 0;
    buyRecord[id].admin_amt = admin_amt;

  }

 function sellRider(uint256 tokenAmount) public returns (uint256 id) {
    require(isRegistered[msg.sender], "User is not registered");
    require(tokenAmount > 0, "Token amount must be greater than 0");
    uint256 rollexMint = tokenAmount.mul(1).div(100);
    require(IBEP20(token).balanceOf(msg.sender) >= rollexMint , "You need 1% Rollex mint tokens on withdrawal amount");

    uint256 userId = addressToUserId[msg.sender];
    // Ensure the last sell operation was more than 24 hours ago
    require(userRegister[userId].last_ts + 1 days <= block.timestamp, "Sell operation can only be performed once every 24 hours");

    uint256 bnbAmount = tokenAmount.mul(rollex_rate).div(1 ether);
    // uint256 adminServiceCharge = bnbAmount.mul(15).div(100); // 15% of bnbAmount
    // bnbAmount = bnbAmount.sub(adminServiceCharge);

    // Check if the contract has enough BNB to proceed with the withdrawal
    require(address(this).balance >= bnbAmount, "Not enough BNB in the contract to proceed with the withdrawal");

    // Ensure the bnbAmount is less than or equal to the total deposit of the user
    require(bnbAmount <= userRegister[userId].totalDeposit.mul(3), "Cannot withdraw more than 3x total deposit at a time");

    // Ensure the bnbAmount is greater than or equal to 0.01 BNB
    require(bnbAmount >= 0.01 ether, "Minimum BNB withdraw limit is 0.01");

    // Ensure the bnbAmount is less than or equal to 5 BNB
    require(bnbAmount <= 5 ether, "Maximum BNB withdraw limit is 5");

    // Check if the user has withdrawn more than 3x of their total deposit
    if (bnbAmount >= userRegister[userId].totalDeposit.mul(3)) {
        // Update user status to false
        userRegister[userId].status = false;
    }

    // Burn the token amount and update total supply
    _balances[msg.sender] = _balances[msg.sender].sub(tokenAmount);
    _totalSupply = _totalSupply.sub(tokenAmount);
    emit Transfer(msg.sender, address(0), tokenAmount); // Emit a transfer event to the zero address to signify burning

    // Send BNB to the user's address
    payable(msg.sender).transfer(bnbAmount);
    rollex_rate = address(this).balance.mul(1 ether).div(_totalSupply);

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
        final_amt: bnbAmount
    });

    return id;
}

function registerUser(address refer_address, uint256 deposit, uint256 pos) public onlyOwner returns (uint256 custid) {
    require(refer_address != msg.sender, "Cannot refer yourself");
    require(!isRegistered[msg.sender], "User is already registered");
    require(isRegistered[refer_address] || superAdmin == refer_address, "Invalid referral address");

    custid = ++customerId;
    userRegister[custid].customer_address = msg.sender;
    userRegister[custid].referral_address = refer_address;
    userRegister[custid].totalDeposit = deposit;
    userRegister[custid].totalWithdraw = 0;
    userRegister[custid].level_income = 0;
    userRegister[custid].tlb_income = 0;
    userRegister[custid].last_ts = 0;
    userRegister[custid].position = pos;
    userRegister[custid].status = true;

    addressToUserId[msg.sender] = custid;

    isRegistered[msg.sender] = true;

    return custid;
}


}