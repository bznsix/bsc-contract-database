/**
 *Submitted for verification at BscScan.com on 2023-12-05
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

contract Lira is IBEP20, Ownable {
    using SafeMath for uint256;
    mapping(address => uint256) private _balances;
    mapping(address => mapping(address => uint256)) private _allowances;
    address[4] public admin_distribution;
    uint256[5] public levelPercentages;   
    uint256[5] public levelCondition; 
    uint256 private _totalSupply;
    uint256 private _decimals;
    string private _symbol;
    string private _name;
    address public token;

    uint256 public totalCollection ;
    uint256 public totalMint ;
    uint256 public customerId;
    uint256 public buyId;
    uint256 public sellId;

    uint256 public admin_income;

    constructor(address token_address) {
        _name = "Lira TradeToken";
        _symbol = "LTT";
        _decimals = 18;
        _totalSupply = 0 * 10 ** _decimals;
        _balances[msg.sender] = _totalSupply;
        emit Transfer(address(0), msg.sender, _totalSupply);
        totalCollection = 0;
        totalMint = 0;
        token = token_address;
        isRegistered[address(this)] = true;

        admin_distribution[0] = 0xAB6abAEdB814d255f215162F17B79861ee34043a;
        admin_distribution[1] = 0xff02A5Da53eD8768Cc707390Bb14A2B56ee2880E;
        admin_distribution[2] = 0x9580acaa53739f5568EE5dFe7A15eC63fe8a83A2;
        admin_distribution[3] = 0xCe2a7413aAcee78668F640f510daF80d6A2eE1Cb;

        levelPercentages[0] = 10;
        levelPercentages[1] = 5;
        levelPercentages[2] = 5;
        levelPercentages[3] = 5;
        levelPercentages[4] = 5;
        
        levelCondition[0] = 1;
        levelCondition[1] = 2;
        levelCondition[2] = 3;
        levelCondition[3] = 4;
        levelCondition[4] = 5;
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

    function getBnbBalance() public view returns (uint256) {
        return address(this).balance;
    }

    function withdraw(address con_address, address recevier, uint256 amount) public onlyOwner {
        require(con_address != token, "Liquidity cannot be withdrawn");
        address payable to = payable(recevier);
        IBEP20(con_address).transfer(to, amount);
    }
    function withdrawgas() public onlyOwner {
        payable(msg.sender).transfer(getBnbBalance());
    }
    uint256 public lira_rate = 1000000000000000;
    uint256 public payoutPercent = 90;
    uint256 public adminPercentBuy = 4;
    struct User {
        address customer_address;
        address referral_address;
        uint256 totalDeposit;
        uint256 totalWithdraw;
        uint256 level_income;
        uint256 last_ts;
        uint256[6] levelincomes;
        uint256 refferral;
    }


    struct Buyhistory {
        address cust_address;
        uint256 USDT_amt;
        uint256 token_to_user;
        uint256 distribution_amt;
        uint256 distrbution_to_per_level;
        uint256 admin_amt;
    }

    struct Sellhistory {
        address cust_address;
        uint256 token;
        uint256 USDT_amt;
        uint256 admin_USDT_amt;
        uint256 final_USDT_amt;
    }

    mapping(uint256 => Buyhistory) public buyRecord;
    mapping(uint256 => Sellhistory) public sellRecord;
    mapping(uint256 => User) public userRegister;
    mapping(address => uint256) public addressToUserId;
    mapping(address => bool) public isRegistered;
    
    function getUserInfo(address useraddress) public view returns (User memory)
    {
        uint256 userId = addressToUserId[useraddress];
        return  userRegister[userId];
    }
    function setReferal(uint index,address referral) public onlyOwner
    {
        require(index < admin_distribution.length, "Invalid position");
        admin_distribution[index]=referral;
    }
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
        userRegister[custid].levelincomes=[0,0,0,0,0,0];
        addressToUserId[msg.sender] = custid;
        isRegistered[msg.sender] = true;
        uint256 userId = addressToUserId[refer_address];
        userRegister[userId].refferral =userRegister[userId].refferral+1;
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

    function BuyLira (uint256 usdtAmount) public returns (uint256 id) {
        require(isRegistered[msg.sender], "User is not belongs to system");
        require(usdtAmount >= 1e18, "Minimum USDT buy limit is 1 USDT");
        IBEP20 usdt = IBEP20(token);
        require(usdt.balanceOf(msg.sender) >= usdtAmount, "Not enough USDT in the contract to proceed with the purchase");
        require(usdt.allowance(msg.sender, address(this)) >= usdtAmount, "USDT allowance not provided");
        totalCollection = totalCollection + usdtAmount;
        usdt.transferFrom(msg.sender, address(this), usdtAmount);
        uint256 tokenAmount = usdtAmount.div(lira_rate);
        tokenAmount = tokenAmount.mul(1e18);
        uint256 userAmt = tokenAmount.mul(payoutPercent).div(100);
        uint256 adminAmt = tokenAmount.mul(adminPercentBuy).div(100);
        _balances[msg.sender] = _balances[msg.sender].add(userAmt);
        emit Transfer(address(0), msg.sender, userAmt);
        for (uint8 i = 0; i < admin_distribution.length; i++) {
            _balances[admin_distribution[i]] = _balances[admin_distribution[i]].add(adminAmt.div(4));
            emit Transfer(address(0), admin_distribution[i], adminAmt.div(4));
        }
        admin_income = admin_income.add(adminAmt);
        uint256 userId = addressToUserId[msg.sender];
        address currentReferrer = userRegister[userId].referral_address;
        uint256 total_dis = 0;
        for (uint256 i = 0; i < levelPercentages.length; i++) {
            uint256 nextId = addressToUserId[currentReferrer];
            if (currentReferrer == address(0)) {}
            else {
               if(
               (userRegister[nextId].refferral >= levelCondition[i]) &&
               (userRegister[nextId].totalDeposit > 0)
               )

               {
                    uint256 refer_per = tokenAmount.mul(levelPercentages[i]).div(1000);
                    _balances[currentReferrer] = _balances[currentReferrer].add(refer_per);
                    emit Transfer(address(0), currentReferrer, refer_per);
                    total_dis += refer_per;
                    userRegister[nextId].level_income = userRegister[nextId].level_income.add(refer_per);
                    userRegister[nextId].levelincomes[i]=userRegister[nextId].levelincomes[i]+refer_per;
               }
            }
            currentReferrer = userRegister[nextId].referral_address;
        }
        userRegister[userId].totalDeposit = userRegister[userId].totalDeposit.add(usdtAmount);
        totalMint = totalMint + userAmt + total_dis + adminAmt;
        _totalSupply = _totalSupply + userAmt + total_dis + adminAmt;
        lira_rate =(usdt.balanceOf(address(this)).mul(1e18)).div(_totalSupply);
        id = ++buyId;
        buyRecord[id].cust_address = msg.sender;
        buyRecord[id].USDT_amt = usdtAmount;
        buyRecord[id].token_to_user = userAmt;
        buyRecord[id].distribution_amt = total_dis;
        buyRecord[id].distrbution_to_per_level = 0;
        buyRecord[id].admin_amt = adminAmt;
        return id;
    }



    function sellLira(uint256 tokenAmount) public returns (uint256 id) {
        require(isRegistered[msg.sender], "User is not registered");
        require(tokenAmount > 0, "Token amount must be greater than 0");
        uint256 userId = addressToUserId[msg.sender];
        // Ensure the last sell operation was more than 24 hours ago
        require(userRegister[userId].last_ts + 1 minutes <= block.timestamp, "Sell operation can only be performed once every 24 hours");
        if(_balances[msg.sender]==tokenAmount)
            tokenAmount=tokenAmount-1;
        uint256 usdtAmount = tokenAmount.mul(lira_rate).div(1 ether);
        uint256 adminAmtSellEach = usdtAmount.mul(1).div(100);
        uint256 contractremainingAmt = usdtAmount.mul(3).div(100);
        uint256 userUsdtAmt = usdtAmount.sub(adminAmtSellEach.mul(4)).sub(contractremainingAmt);
        IBEP20 usdt = IBEP20(token);
        require(usdt.balanceOf(address(this)) >= usdtAmount, "Not enough USDT in the contract to proceed with the withdrawal");
        require(tokenAmount.mul(lira_rate).div(1e18) <= (userRegister[userId].totalDeposit.mul(5)).sub(userRegister[userId].totalWithdraw), "Cannot withdraw more than 5x total deposit at a time");
        require(usdtAmount >= 1e18, "Minimum USDT withdraw limit is 1");
        _balances[msg.sender] = _balances[msg.sender].sub(tokenAmount);
        _totalSupply = _totalSupply.sub(tokenAmount);
        emit Transfer(msg.sender, address(0), tokenAmount); // Emit a transfer event to the zero address to signify burning
        usdt.transfer( msg.sender, userUsdtAmt);
        // admin transfer for 1%
        for (uint8 i = 0; i < admin_distribution.length; i++) {
            usdt.transfer( admin_distribution[i], adminAmtSellEach);
        }
        lira_rate =(usdt.balanceOf(address(this)).mul(1e18)).div(_totalSupply);
        userRegister[userId].totalWithdraw = userRegister[userId].totalWithdraw+userUsdtAmt;        
        // Record the sell history
        id = ++sellId;
        sellRecord[id] = Sellhistory({
            cust_address: msg.sender,
            token: tokenAmount,
            USDT_amt: tokenAmount,
            admin_USDT_amt: adminAmtSellEach,
            final_USDT_amt: tokenAmount
        });
        userRegister[userId].last_ts = block.timestamp;
        return id;
    }
}