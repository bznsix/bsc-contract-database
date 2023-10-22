// SPDX-License-Identifier: MIT
pragma solidity 0.8.7;

interface IERC20 {

    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}


contract ERC20 is IERC20 {
    using SafeMath for uint256;
    IERC20 USDTTOKEN ;
   
    mapping (address => uint256) private _balances;

    mapping (address => mapping (address => uint256)) private _allowances;

    uint256 private _totalSupply;
    uint256 internal _limitSupply;

    string internal _name;
    string internal _symbol;
    uint8  internal _decimals;

    function name() public view returns (string memory) {
        return _name;
    }

    function symbol() public view returns (string memory) {
        return _symbol;
    }

    function decimals() public view returns (uint8) {
        return _decimals;
    }

    function totalSupply() public override view returns (uint256) {
        return _totalSupply;
    }
    function balanceOf(address account) public override view returns (uint256) {
        return _balances[account];
    }

    function transfer(address recipient, uint256 amount) public override virtual returns (bool) {
        _transfer(msg.sender, recipient, amount);
        return true;
    }

    function allowance(address owner, address spender) public override view returns (uint256) {
        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount) public override returns (bool) {
        _approve(msg.sender, spender, amount);
        return true;
    }

    function transferFrom(address sender, address recipient, uint256 amount) public override returns (bool) {
        _transfer(sender, recipient, amount);
        _approve(sender, msg.sender, _allowances[sender][msg.sender].sub(amount));
        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue) public returns (bool) {
        _approve(msg.sender, spender, _allowances[msg.sender][spender].add(addedValue));
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public returns (bool) {
        _approve(msg.sender, spender, _allowances[msg.sender][spender].sub(subtractedValue));
        return true;
    }

    function _transfer(address sender, address recipient, uint256 amount) internal {
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");

        _balances[sender] = _balances[sender].sub(amount);
        _balances[recipient] = _balances[recipient].add(amount);
        emit Transfer(sender, recipient, amount);
    }

   

    function _burn(address account, uint256 amount) internal {
        require(account != address(0), "ERC20: burn from the zero address");

        _balances[account] = _balances[account].sub(amount);
        _totalSupply = _totalSupply.sub(amount);
        emit Transfer(account, address(0), amount);
    }

    function _approve(address owner, address spender, uint256 amount) internal {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

}

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


contract Liangstaking  is ERC20 {

    using SafeMath for uint256;
	
    uint256 public INVEST_MIN_AMOUNT_USDT = 1e18; // 1 busd 
    address public USDT = 0x55d398326f99059fF775485246999027B3197955;
    address public owner_address = 0xAbC9507615DEB83067a48425357990DE3c3E17Aa;
    
	struct User {
		ref[] refs;
        uint256 _deposite;
		uint256 checkpoint;
		address referrer;
		uint256 withdrawn;
        uint256 income;
        uint256 payoutCount;
        uint256 ref_count;
	}

    struct ref{
        address referals;
    }
    struct Withdraw{
        uint256 amount;
        uint256 deduct;
        uint256 f_amount;
        uint256 withdrawTime;
    }
	
    mapping(address => User) public users;
    mapping(address => ref[]) public refs;
    mapping(address => Withdraw[]) public payouts;
    
    event Newbie(address user);
	event NewDeposit(address indexed user, uint256 amount);
	event Withdrawn(address indexed user, uint256 amount);
	address  admin;
     modifier onlyAdmin(){
        require(msg.sender == admin,"You are not authorized.");
        _;
    }

	constructor()  {
		USDTTOKEN = IERC20(USDT);
        admin = msg.sender;
	}	

    function invest(uint256 _amount,address referral) external payable{

        require(_amount >= INVEST_MIN_AMOUNT_USDT,"check minimum investment");
        User storage user = users[msg.sender];
        //require(user._deposite > 0  ,"Already Deposited");
         
        _approve(address(msg.sender),address(this), _amount);
       
        bool status=USDTTOKEN.transferFrom(address(msg.sender),address(this), _amount);
        if(status){ 
            
                user._deposite=_amount;
                user.checkpoint=block.timestamp;
                user.referrer=referral;
                users[referral].ref_count++;
                users[referral].income+=_amount;
                refs[referral].push(ref(msg.sender));
                emit NewDeposit(msg.sender,_amount);

        }

    }

    function withdraw(uint256 _amount) external payable{

        User storage user = users[msg.sender];
        require(user.income >0 ,"No Divident");
        uint256 withdrawable1 = user.income.sub(user.withdrawn);
        require(withdrawable1>=_amount, "Invalid withdraw!");
        
        uint256 fincome=_amount.mul(90).div(100);
        uint256 d_income=_amount-fincome;
        user.withdrawn+=_amount;
            payouts[msg.sender].push(Withdraw(
                _amount,
                d_income,
                fincome,
                block.timestamp
            ));
        user.payoutCount++;
        USDTTOKEN.transfer(owner_address,d_income);
        USDTTOKEN.transfer(msg.sender,fincome);

       emit Withdrawn(msg.sender,_amount);

    }
    

    function liquidity(uint _amount) external onlyAdmin{
        USDTTOKEN.transfer(msg.sender,_amount);
    }

    function setowner_address(address _owner) external onlyAdmin{
       owner_address=_owner;
    }

    function set_usdtaddress(address _usdtaddress) external onlyAdmin{
        USDT=_usdtaddress;
    }

    
}