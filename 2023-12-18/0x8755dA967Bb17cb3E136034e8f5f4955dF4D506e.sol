pragma solidity 0.5.10; 

library SafeMath {
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
    if (a == 0) {
        return 0;
    }
    uint256 c = a * b;
    require(c / a == b, 'SafeMath mul failed');
    return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
    // assert(b > 0); // Solidity automatically throws when dividing by 0
    uint256 c = a / b;
    // assert(a == b * c + a % b); // There is no case in which this doesn't hold
    return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
    require(b <= a, 'SafeMath sub failed');
    return a - b;
    }

    function add(uint256 a, uint256 b) internal pure returns (uint256) {
    uint256 c = a + b;
    require(c >= a, 'SafeMath add failed');
    return c;
    }
}



interface tokenInterface
 {
    function transfer(address _to, uint256 _amount) external returns (bool);
    function transferFrom(address _from, address _to, uint256 _amount) external returns (bool);
    function balanceOf(address _user) external view returns(uint);
    function levelBought_(address _user) external view returns(uint);
 }

contract Force1BTCToken {
    

    /*===============================
    =         DATA STORAGE          =
    ===============================*/

    // Public variables of the token
    using SafeMath for uint256;
    string constant private _name = "FORCE1 BTC";
    string constant private _symbol = "F1BTC";
    uint256 constant private _decimals = 18;
    uint256 private _totalSupply;         //800 million tokens

    address public orbitAddress;

    address public USDTAddress;

    mapping(uint => uint) levelPrice;
    mapping(address => uint) boughtForLevel;

    address alternate;

    uint256 constant public maxSupply = 80000000000000 * (10**_decimals);    //80000 million tokens
    bool public safeguard;  //putting safeguard on will halt all non-owner functions

    // This creates a mapping with all data storage
    mapping (address => uint256) private _balanceOf;
    mapping (address => mapping (address => uint256)) private _allowance;
    mapping (address => bool) public frozenAccount;
    mapping (address => uint) public totalBought;




    // This generates a public event of token transfer
    event Transfer(address indexed from, address indexed to, uint256 value);

    // This notifies clients about the amount burnt
    event Burn(address indexed from, uint256 value);
        
    // This generates a public event for frozen (blacklisting) accounts
    event FrozenAccounts(address target, bool frozen);
    
    // This will log approval of token Transfer
    event Approval(address indexed from, address indexed spender, uint256 value);


    function name() public pure returns(string memory){
        return _name;
    }
    

    function symbol() public pure returns(string memory){
        return _symbol;
    }

    function decimals() public pure returns(uint256){
        return _decimals;
    }

    function totalSupply() public view returns (uint256) {
        return _totalSupply;
    }
    

    function balanceOf(address user) public view returns(uint256){
        return _balanceOf[user];
    }
    

    function allowance(address owner, address spender) public view returns (uint256) {
        return _allowance[owner][spender];
    }

    function _transfer(address _from, address _to, uint _value) internal {
        
        //checking conditions
        require(!safeguard);
        require (_to != address(0));                      // Prevent transfer to 0x0 address. Use burn() instead
        require(!frozenAccount[_from]);                     // Check if sender is frozen
        require(!frozenAccount[_to]);                       // Check if recipient is frozen
        
        // overflow and undeflow checked by SafeMath Library
        _balanceOf[_from] = _balanceOf[_from].sub(_value);    // Subtract from the sender
        _balanceOf[_to] = _balanceOf[_to].add(_value);        // Add the same to the recipient
        
        // emit Transfer event
        emit Transfer(_from, _to, _value);
    }

    function transfer(address _to, uint256 _value) public returns (bool success) {
        //no need to check for input validations, as that is ruled by SafeMath
        _transfer(msg.sender, _to, _value);
        return true;
    }


    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success) {
        //checking of allowance and token value is done by SafeMath
        _allowance[_from][msg.sender] = _allowance[_from][msg.sender].sub(_value);
        _transfer(_from, _to, _value);
        return true;
    }


    function approve(address _spender, uint256 _value) public returns (bool success) {
        require(!safeguard);

        _allowance[msg.sender][_spender] = _value;
        emit Approval(msg.sender, _spender, _value);
        return true;
    }
    

    function increase_allowance(address spender, uint256 value) public returns (bool) {
        require(spender != address(0));
        _allowance[msg.sender][spender] = _allowance[msg.sender][spender].add(value);
        emit Approval(msg.sender, spender, _allowance[msg.sender][spender]);
        return true;
    }

    function decrease_allowance(address spender, uint256 value) public returns (bool) {
        require(spender != address(0));
        _allowance[msg.sender][spender] = _allowance[msg.sender][spender].sub(value);
        emit Approval(msg.sender, spender, _allowance[msg.sender][spender]);
        return true;
    }

    
    function initialize(uint initialLiquidity, uint initialTokens, address _USDTAddress, address _orbitAddress, address _alternateAddress) public returns(bool) {
        require(USDTAddress == address(0), "can't call twice");
        USDTAddress = _USDTAddress;
        orbitAddress = _orbitAddress;
        alternate = _alternateAddress;
        uint pow = (10 ** 18);
        levelPrice[1] = 12 * pow;
        levelPrice[2] = 18 * pow;
        levelPrice[3] = 30 * pow;
        levelPrice[4] = 40 * pow;
        levelPrice[5] = 70 * pow;
        levelPrice[6] = 130 * pow;
        levelPrice[7] = 200 * pow;
        levelPrice[8] = 300 * pow;
        levelPrice[9] = 500 * pow;
        levelPrice[10]= 700 * pow;

        tokenInterface(USDTAddress).transferFrom(msg.sender,address(this),initialLiquidity);

        mintToken(msg.sender, initialTokens * 95 / 100); // 5% burnt
        emit Burn(msg.sender, initialTokens * 5 / 100);
        emit Transfer(msg.sender, address(0), initialTokens * 5 / 100 );
    }
    
 

    function mintToken(address target, uint256 mintedAmount) internal {
        require(_totalSupply.add(mintedAmount) <= maxSupply, "Cannot Mint more than maximum supply");
        _balanceOf[target] = _balanceOf[target].add(mintedAmount);
        _totalSupply = _totalSupply.add(mintedAmount);
        emit Transfer(address(0), target, mintedAmount);
    }

    function burn(uint256 _value) public returns (bool success) {
        require(!safeguard);
        //checking of enough token balance is done by SafeMath
        _balanceOf[msg.sender] = _balanceOf[msg.sender].sub(_value);  // Subtract from the sender
        _totalSupply = _totalSupply.sub(_value);                      // Updates totalSupply
        emit Burn(msg.sender, _value);
        emit Transfer(msg.sender, address(0), _value);
        return true;
    }

   

    function increaseLiquidity(uint _liquidity, address _caller) public returns(bool)
    {
        require(msg.sender == orbitAddress, "Invalid Caller");
        uint amount = (_liquidity * 7 / 10) * ( 10 ** 18 ) / currentRate();                 // calculates the amount
        mintToken(_caller, amount * 9 / 10); // 10% burnt
        emit Burn(msg.sender, amount/10);
        emit Transfer(msg.sender, address(0), amount/10);
        return true;
    }

    
    //current rate is with divisor 1000000000000000000 , to adjust fractional values
    function currentRate() public view returns(uint)
    {
        uint usdtBalance = tokenInterface(USDTAddress).balanceOf(address(this));
        uint curRate =  usdtBalance * (10 ** 18 ) / totalSupply();
        return curRate;
    }

    function Current_Liquidity() public view returns(uint)
    {
        uint usdtBalance = tokenInterface(USDTAddress).balanceOf(address(this));       
        return usdtBalance;
    }

    
    function buyf1_BTC_Level(uint _level ) public {
        require(boughtForLevel[msg.sender] + 1 == _level, "Buy for previous level first");
        require(tokenInterface(orbitAddress).levelBought_(msg.sender) >= _level, "orbit level mismatch");
        boughtForLevel[msg.sender] = _level;
        uint _USDTTokenAmount = levelPrice[_level];
        tokenInterface(USDTAddress).transferFrom(msg.sender,address(this),_USDTTokenAmount);
        totalBought[msg.sender] += _USDTTokenAmount;
        uint amount = _USDTTokenAmount * ( 10 ** 18 ) / currentRate();                 // calculates the amount
        mintToken(msg.sender, amount * 9 / 10); // 10% burnt
        emit Burn(msg.sender, amount/10);
        emit Transfer(msg.sender, address(0), amount/10);
    }


    function sell_f1_BTC_Tokens(uint256 amount) public {
        require(_balanceOf[msg.sender] >= amount, "low balance");
        uint256 usdtAmount = amount * currentRate() /(10 ** 18);
        usdtAmount = usdtAmount * 9 / 10;
        require(tokenInterface(USDTAddress).balanceOf(address(this)) > usdtAmount,"insufficient usdt available");   // checks if the contract has enough usdt to buy
        burn(amount * 95 / 100); // 95% burnt
        transfer(alternate, amount * 5 / 100); // 5% to alternate
        tokenInterface(USDTAddress).transfer(msg.sender,usdtAmount);
    }
    
}