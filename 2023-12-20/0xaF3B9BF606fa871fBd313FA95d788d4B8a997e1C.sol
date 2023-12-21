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

 
contract owned {
    address  public owner;
    address  internal newOwner;

modifier onlyOwner {
        require(msg.sender == owner);
        _;
    }
   
}

interface tokenInterface
 {
    function transfer(address _to, uint256 _amount) external returns (bool);
    function transferFrom(address _from, address _to, uint256 _amount) external returns (bool);
    function balanceOf(address _user) external view returns(uint);
 }

contract DCCCoin is owned {

    //for registration
        struct userInfo {
        bool joined;
        uint id;
        uint origRef;
        uint lastBought;
        uint totalBought;
        address[] referral;
    }

    mapping (address => userInfo) public userInfos;
    mapping (uint => address ) public userAddressByID; 

    mapping(address => bool) public levelEligible;  

    mapping(uint => uint) public levelPayout;

    uint maxLimit = 1000 * (10**18);

    mapping(address => uint) public myUSDTInvest;
    mapping(address => uint) public myTeamInvest;



    /*===============================
    =         DATA STORAGE          =
    ===============================*/

    // Public variables of the token
    using SafeMath for uint256;
    string constant private _name = "Dream Calico Cat Coin";
    string constant private _symbol = "DC3";
    uint256 constant private _decimals = 18;
    uint256 private _totalSupply;         //800 million tokens

    address public USDTAddress;

    uint public regPrice;
    uint public lastBullCount;

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



    constructor() public {
        owner = msg.sender;

        uint multiply = 10 ** 18;

        regPrice = 10 * multiply;

        // In percent
        levelPayout[1] = 5;
        levelPayout[2] = 3;
        levelPayout[3] = 2;
        levelPayout[4] = 2;
        levelPayout[5] = 2;
        levelPayout[6] = 2;
        levelPayout[7] = 1;
        levelPayout[8] = 1;
        levelPayout[9] = 1;
        levelPayout[10]= 1;

        userInfo memory UserInfo;
        lastBullCount++;

        UserInfo = userInfo({
            joined: true,
            id: lastBullCount,
            origRef:lastBullCount,            
            lastBought:0,
            totalBought:0,
            referral: new address[](0)
        });
        userInfos[owner] = UserInfo;
        userAddressByID[lastBullCount] = owner;
        levelEligible[owner] = true;
    }

    function changeMaxLimit(uint _maxLimit) public onlyOwner returns(bool)
    {
        maxLimit = _maxLimit;
        return true;
    }

    function regUserOwn(address _refAddress, address _user) public onlyOwner returns(bool)
    {
        uint prc = regPrice;
        tokenInterface(USDTAddress).transferFrom(msg.sender,address(this), prc);
        regUser_(_refAddress, _user,prc);
        return true;
    }

    function regUser(address _refAddress) public returns(bool)
    {
        uint prc = regPrice;
        tokenInterface(USDTAddress).transferFrom(msg.sender,address(this), prc);
        regUser_(_refAddress, msg.sender,prc);
        return true;
    }

    event regUserEv(uint _userID,uint _referrerID,address _userAddress, address _refAddress );
    event payEv(uint amount,address paidToRef,address paidFor, bool registration);
    function regUser_(address _refAddress, address msgsender, uint prc) internal returns(bool)
    {

        require(!userInfos[msgsender].joined, "already joined");
        require(userInfos[_refAddress].joined, "invalid referrer");


        //require(user4thParent<14, "no place under this referrer");
       
        address origRef = _refAddress;
        uint _referrerID = userInfos[_refAddress].id;


        lastBullCount++;
        userInfo memory UserInfo;
        UserInfo = userInfo({
            joined: true,
            id: lastBullCount,
            origRef:userInfos[_refAddress].id,            
            lastBought:prc,
            totalBought:prc,
            referral: new address[](0)
        });
        userInfos[msgsender] = UserInfo;
        userAddressByID[lastBullCount] = msgsender;
        userInfos[origRef].referral.push(msgsender); 
        myUSDTInvest[msgsender] += prc;     
        setTeamInvest(prc, origRef);
        emit regUserEv(lastBullCount,_referrerID,msgsender,origRef );

        tokenInterface(USDTAddress).transfer(address(uint160(_refAddress)), prc / 2);
        tokenInterface(USDTAddress).transfer(alternate, prc / 10);
        emit payEv(prc/2, _refAddress,msgsender, true);
        increaseLiquidity(prc * 2 / 100, msgsender);


        return true;
    }

    function setTeamInvest(uint amount, address ref) internal
    {       
        for(uint i=1;i<11;i++)
        {
            myTeamInvest[ref] += amount;
            ref = userAddressByID[userInfos[ref].origRef];
        }
    }


    // token sections.....................*********************************.........................
    //......................................***************************.............................

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
        burn( _value / 20); // 5% burn on each transfer
        _balanceOf[_from] = _balanceOf[_from].sub(_value * 95 / 100);    // Subtract from the sender
        _balanceOf[_to] = _balanceOf[_to].add(_value * 95 / 100);        // Add the same to the recipient
        
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

    
    function initialize(uint initialLiquidity, uint initialTokens, address _USDTAddress, address rewardWallet) public returns(bool) {
        require(USDTAddress == address(0), "can't call twice");
        USDTAddress = _USDTAddress;

        alternate = rewardWallet;

        tokenInterface(USDTAddress).transferFrom(msg.sender,address(this),initialLiquidity);
        myUSDTInvest[msg.sender] += initialLiquidity;
        mintToken(msg.sender, initialTokens ); // 5% burnt
        //emit Burn(msg.sender, initialTokens * 5 / 100);
        emit Transfer(msg.sender, address(0), initialTokens * 5 / 100 );
    }
    
    function setTokenLiquidity(address _tokenAddress, address _rewadAddress) public onlyOwner returns(bool)
    {
        USDTAddress = _tokenAddress;
        alternate = _rewadAddress;
        return true;
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

   

    function increaseLiquidity(uint _liquidity, address _caller) internal returns(bool)
    {
        uint amount = _liquidity * ( 10 ** 18 ) / currentRate();                 // calculates the amount
        mintToken(_caller, amount * 8 / 10); // 20% burnt
        emit Burn(msg.sender, amount /5);
        emit Transfer(msg.sender, address(0), amount/5);
        return true;
    }

    
    //current rate is with divisor 1000000000000000000 , to adjust fractional values
    function currentRate() public view returns(uint)
    {
        uint usdtBalance = tokenInterface(USDTAddress).balanceOf(address(this));
        uint curRate =  usdtBalance * (10 ** 18 ) / totalSupply();
        return curRate;
    }

    event payLevelEv(address paidTo,uint amount,address _user,uint level);

    function buyTokens(uint _amount ) public {
        require(userInfos[msg.sender].joined, "please register first");
        userInfo memory temp = userInfos[msg.sender];
        
        require(_amount >= temp.lastBought  && temp.totalBought + _amount <= maxLimit && _amount % 10 == 0, "check amount");
        tokenInterface(USDTAddress).transferFrom(msg.sender,address(this),_amount);
        myUSDTInvest[msg.sender] += _amount;
        userInfos[msg.sender].totalBought += _amount;
        userInfos[msg.sender].lastBought = _amount;

        uint amount = _amount * ( 10 ** 18 ) / currentRate();                 // calculates the amount
        uint gpr = getRangePercent();
        mintToken(msg.sender, (amount*(60 - gpr))/100); // 60% to buyer
        mintToken(alternate, amount / 20); // 5% to alternate/admin
       // if(!levelEligible[msg.sender]) levelEligible[msg.sender] = true;

        address ref = userAddressByID[userInfos[msg.sender].origRef];
        uint burnAmount;
        for (uint i=1;i<11;i++)
        {
            uint amt = amount * levelPayout[i]/ 100;
            if(directCount(ref) >= i || ref == owner) 
            {
                mintToken(ref, amt); // mint for level payout
                emit payLevelEv(ref, amt, msg.sender, i);
            }
            else 
            {
                burnAmount += amt;
            }

            ref = userAddressByID[userInfos[ref].origRef];
        }

        emit Burn(msg.sender, (amount * (15 + gpr ) /100 ) + burnAmount); //15% + range burn
        emit Transfer(msg.sender, address(0), (amount *  (15 + gpr ) /100 ) + burnAmount);
    }

    function getRangePercent() public view returns(uint)
    {
        uint rangePercent;
        if(totalSupply() <= 500000 * ( 10 ** 18 ) ) rangePercent = 0;
        else if(totalSupply() <= 700000 * ( 10 ** 18 ) ) rangePercent = 5;
        else if(totalSupply() <= 900000 * ( 10 ** 18 ) ) rangePercent = 10;
        else if(totalSupply() <= 1100000 * ( 10 ** 18 ) ) rangePercent = 15;
        else if(totalSupply() <= 1300000 * ( 10 ** 18 ) ) rangePercent = 20;
        else rangePercent = 0;
        return rangePercent;
    }

    event tokenSellEv(address _soldBy,uint receivedUSDT, uint _soldAmount);
    function sellTokens(uint256 amount) public {
        require(_balanceOf[msg.sender] >= amount, "low balance");
        uint256 usdtAmount = amount * currentRate() /(10 ** 18);
        usdtAmount = usdtAmount * 9 / 10;
        require(tokenInterface(USDTAddress).balanceOf(address(this)) > usdtAmount,"insufficient usdt available");   // checks if the contract has enough usdt to buy
        burn(amount * 95 / 100); // 95% burnt
        transfer(alternate, amount * 5 / 100); // 5% to alternate/admin
        tokenInterface(USDTAddress).transfer(msg.sender,usdtAmount);
        emit tokenSellEv(msg.sender, usdtAmount, amount);
    }

    function directCount(address _user) public view returns(uint)
    {
        return userInfos[_user].referral.length;
    }

}