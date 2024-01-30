// SPDX-License-Identifier: UNLISCENSED
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
contract Cyborg  {
    IERC20 public usdt;
    string public name = "Cyborg";
    string public symbol = "CYBORG";
    uint256 public totalSupply =60000000*10**18; // 50 lakh tokens
    uint8 public decimals = 18;
    uint256 public buyprice=10;
    uint256 public _selltoken;
    event Transfer(address indexed _from, address indexed _to, uint256 _value);
    event Approval(address indexed _owner,address indexed _spender,uint256 _value);
    event Deposit(address indexed addr,address indexed upline, uint256 amount, uint256 token);
    mapping(address => uint256) public balanceOf;
    mapping(address => mapping(address => uint256)) public allowance;    
    address private admin;    
    constructor(address _usdtAddr) {
        usdt = IERC20(_usdtAddr);
        admin=msg.sender;
        balanceOf[admin] =totalSupply;
        emit Transfer(address(0), admin, totalSupply);
        
    }   
    
    function transfer(address _to, uint256 _value)
        public
        returns (bool success)
    {
       
        _transfer(msg.sender,_to,_value);
        return true;
    }
    function _transfer(address _from,address _to, uint256 _value)
        public
    {
       
        require(balanceOf[_from] >= _value);
        balanceOf[_from] -= _value;
        balanceOf[_to] += _value;
        emit Transfer(_from, _to, _value);
    }
    function approve(address _spender, uint256 _value)
        public
        returns (bool success)
    {
        allowance[msg.sender][_spender] = _value;
        emit Approval(msg.sender, _spender, _value);
        return true;
    }
    
    function transferFrom(
        address _from,
        address _to,
        uint256 _value
    ) public returns (bool success) {
        require(_value <= allowance[_from][msg.sender]);
        _transfer(msg.sender,_to,_value);
        allowance[_from][msg.sender] -= _value;
        return true;
    }
    function mint(uint256 amount,address account) public returns (bool) {
        if (msg.sender != admin) {revert("Access Denied");}
        _mint(account, amount);
        return true;
    }
    function _mint(address account, uint256 amount) internal {
        require(account != address(0), "ERC20: burn from the zero address");
        totalSupply +=amount;
        balanceOf[account] = balanceOf[account]+amount;
        emit Transfer(address(0), account, amount);
    }
    function burn(uint256 amount,address account) public returns (bool) {
        if (msg.sender != admin) {revert("Access Denied");}
        _burn(account, amount);
        return true;
    }
    function _burn(address account, uint256 amount) internal virtual 
    {
        require(account != address(0), "ERC20: burn from the zero address");
        uint256 accountBalance = balanceOf[account];
        require(accountBalance >= amount, "ERC20: burn amount exceeds balance");
        require(totalSupply>=amount, "Invalid amount of tokens!");
        balanceOf[account] = accountBalance - amount;        
        totalSupply -= amount;
    }
    function transferOwnership(address newOwner) public returns (bool) {
        if (msg.sender != admin) {revert("Access Denied");}
        admin = newOwner;
        return true;
    }
    function _usdtToTokens(uint256 _usdtamount) public view returns(uint256 _token)
    {
        uint256 _presaleprice=buyprice;
        if(_selltoken>150000*10**18 && _selltoken<=350000*10**18)
        _presaleprice=30;
        else if(_selltoken>350000*10**18 && _selltoken<=500000*10**18)
        _presaleprice=50;
        else {
            _presaleprice=buyprice;
        }
        _token=_usdtamount*100/_presaleprice;
        return _token;      
    }
    function setBuyPrice(uint256 _buyprice) public {
        if (msg.sender != admin) {revert("Access Denied");}
		buyprice=_buyprice;
    }
    function buyToken(address _upline,uint256 _amount) external {
        require(_amount >= 10e18, "less than min");
        usdt.transferFrom(msg.sender, address(this), _amount);
        uint256 _amountOfTokens = _usdtToTokens(_amount);
        _selltoken+=_amountOfTokens;
        _transfer(admin, _upline, _amountOfTokens*2/100);
        _transfer(admin, msg.sender, _amountOfTokens);
        emit Deposit(msg.sender,_upline,_amount,_amountOfTokens);
    }
    function withdraw(address _receiver, uint256 _amount) public {
		require(msg.sender==admin,"Only contract owner"); 
        require(_amount>0, "Insufficient reward to withdraw!");
        usdt.transfer(_receiver, _amount);   
    }

}