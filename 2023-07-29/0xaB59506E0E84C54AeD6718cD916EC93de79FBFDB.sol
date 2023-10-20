pragma solidity ^0.6.0;
 
contract SO23 {
    string public symbol = "SO23";
    string public name = "SO23";
    uint8 public constant decimals = 18;
    uint256 public _totalSupply = 23000000000000000000;
	uint256 public _totalMint = 0;
	uint256 public _totalMintOwner = 0;
	uint256 public divideBy = 10000000;
	uint256 public costPerUnit = 0;
	uint256 public totalReferrals = 0;
	uint256 public totalReferralsMintCount = 0;
	uint256 public totalCosts = 0;
    address public owner;
	address public outerAddress;
	address public referralContract;
    
    event Transfer(address indexed _from, address indexed _to, uint256 _value);
    event Approval(address indexed _owner, address indexed _spender, uint256 _value);
 
    mapping(address => uint256) balances;
	
	mapping(address => uint256) referrals;
	mapping(address => uint256) referralsCountMints;
 
    mapping(address => mapping (address => uint256)) allowed;
 
    constructor(uint _costPerUnit) public {
        owner = msg.sender; 
		outerAddress = msg.sender;
		balances[address(this)] = _totalSupply;
		costPerUnit = _costPerUnit;
    }
   
    function totalSupply() public view returns (uint256 supply) {        
        return _totalSupply;
    }
 
    function balanceOf(address _owner) public view returns (uint256 balance) {
        return balances[_owner];
    }
 
    function transfer(address _to, uint256 _amount) public returns (bool success) {
        if (balances[msg.sender] >= _amount
            && _amount > 0
            && balances[_to] + _amount > balances[_to]) {
            balances[msg.sender] -= _amount;
            balances[_to] += _amount;
            emit Transfer(msg.sender, _to, _amount);
            return true;
        } else {
            return false;
        }
    }

    function transferMint(address _to, uint256 _amount) private returns (bool success) {
        if (balances[address(this)] >= _amount
            && _amount > 0
            && balances[_to] + _amount > balances[_to]) {
            balances[address(this)] -= _amount;
            balances[_to] += _amount;
            emit Transfer(address(this), _to, _amount);
            return true;
        } else {
            return false;
        }
    }
 
    function transferFrom(
        address _from,
        address _to,
        uint256 _amount
    ) public returns (bool success) {
        if (balances[_from] >= _amount
            && allowed[_from][msg.sender] >= _amount
            && _amount > 0
            && balances[_to] + _amount > balances[_to]) {
            balances[_from] -= _amount;
            allowed[_from][msg.sender] -= _amount;
            balances[_to] += _amount;
            emit Transfer(_from, _to, _amount);
            return true;
        } else {
            return false;
        }
    }
 
    function approve(address _spender, uint256 _amount) public returns (bool success) {
        allowed[msg.sender][_spender] = _amount;
        emit Approval(msg.sender, _spender, _amount);
        return true;
    }
 
    function allowance(address _owner, address _spender) public view returns (uint256 remaining) {
        return allowed[_owner][_spender];
    }
	
	function release() public
	{
		address payable add = payable(outerAddress);
		if(!add.send(address(this).balance)) revert();
	}
	
	function setOuterAddress(address _address) public
	{
		if(msg.sender == owner)
			outerAddress = _address;
		else
			revert();
	}
	
	function setCostPerUnit(uint value) public
	{
		if(msg.sender == owner)
			costPerUnit = value;
		else
			revert();
	}
	
	function setDivideBy(uint value) public
	{
		if(msg.sender == owner)
			divideBy = value;
		else
			revert();
	}
	
	function setReferralContract(address _address) public
	{
		if(msg.sender == owner)
			referralContract = _address;
		else
			revert();
	}
	
	function setReferralValue(address _address, uint _value) public
	{
		if(msg.sender == owner || msg.sender == referralContract)
			referrals[_address] = _value;
		else
			revert();
	}
	
	function mint(uint quantity, address referral) public payable {		
		if (quantity == 0) revert();
		
		uint amount = (quantity * (_totalSupply / divideBy));
		
		uint totalCost = (quantity * costPerUnit);
		
		if (msg.value == totalCost || msg.sender == owner)
		{
			if (!transferMint(msg.sender, amount)) revert('transfer error');
            _totalMint += amount;          
			
			if (msg.sender == owner) _totalMintOwner += amount;
			else 
			{
				totalCosts += totalCost;
		
				if (referral != 0x0000000000000000000000000000000000000000 && referral != msg.sender)
				{
					referrals[referral] += totalCost;
					totalReferrals += totalCost;
					referralsCountMints[referral] += 1;
					totalReferralsMintCount++;
				}
			}
		}
		else
		{
			revert('invalid value');
		}		
	}
	
	function getCostPerUnit() public view returns (uint _costPerUnit) 
	{
		return costPerUnit;
	
	}
	
	function finalCost(uint quantity) public view returns (uint _cost) 
	{
		return quantity * costPerUnit;
	}
	
	function getMinted() public view returns (uint _value) 
	{
		return _totalMint;
	}
	
	function getMintedOwner() public view returns (uint _value) 
	{
		return _totalMintOwner;
	}
	
	function unitValue() public view returns (uint _value) 
	{
		return _totalSupply / divideBy;
	}
	
	function getTotalCosts() public view returns (uint _value) 
	{
		return totalCosts;
	}
	
	function getTotalReferrals() public view returns (uint _value) 
	{		
		return totalReferrals;
	}
	
	function getTotalReferralsMintCount() public view returns (uint _value) 
	{		
		return totalReferralsMintCount;
	}
	
	function getReferralAmount(address _address) public view returns (uint _value) 
	{
		return referrals[_address];
	}
	
	function getReferralMints(address _address) public view returns (uint _value) 
	{
		return referralsCountMints[_address];
	}
}