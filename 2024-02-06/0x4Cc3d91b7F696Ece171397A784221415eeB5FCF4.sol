pragma solidity ^0.4.26;

contract simpleToken {

    uint256 public totalSupply_; // Объявляем totalSupply_ как публичную переменную
    string public constant name = "DTINTRASTCOIN";
    string public constant symbol = "DTINTRAST";
    uint8 public constant decimals = 18;

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);

    mapping (address => uint256) public balances; 
    mapping (address => mapping (address => uint256)) public allowed;

    function totalSupply() public view returns (uint256){
        return totalSupply_;
    }

    function balanceOf(address _owner) public view returns (uint256){
        return balances[_owner];
    }

    function allowance(address _owner, address _spender) public view returns (uint256) {
        return allowed[_owner][_spender];
    }

    function transfer(address _to, uint256 _value) public returns (bool) {
        require(_to != address(0));
        require(balances[msg.sender] >= _value); 
        balances[msg.sender] -= _value; 
        balances[_to] += _value; 
        emit Transfer(msg.sender, _to, _value);
        return true;
    }

    function approve(address _spender, uint256 _value) public returns (bool) {
        allowed[msg.sender][_spender] = _value;
        emit Approval(msg.sender, _spender, _value);
        return true;
    }

    function transferFrom(address _from, address _to, uint256 _value) public returns (bool) {
        require(_to != address(0));
        require(_value <= balances[_from]);
        require(_value <= allowed[_from][msg.sender]); 
        balances[_from] -= _value; 
        balances[_to] += _value; 
        allowed[_from][msg.sender] -= _value; 
        emit Transfer(_from, _to, _value); 
        return true; 
    } 

    function increaseApproval(address _spender, uint _addedValue) public returns (bool) { 
        allowed[msg.sender][_spender] += _addedValue; 
        emit Approval(msg.sender, _spender, allowed[msg.sender][_spender]); 
        return true; 
    } 

    function decreaseApproval(address _spender, uint _subtractedValue) public returns (bool) { 
        uint oldValue = allowed[msg.sender][_spender]; 
        if (_subtractedValue > oldValue) {
            allowed[msg.sender][_spender] = 0;
        } else {
            allowed[msg.sender][_spender] -= _subtractedValue;
        }
        emit Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
        return true;
    }

    // Убираем функцию mint и оставляем только установку начального предложения монет в конструкторе
    function simpleToken() public {
        totalSupply_ = 1000000000 * (10**uint256(decimals)); // Устанавливаем начальное предложение монет
        balances[msg.sender] = totalSupply_;
        emit Transfer(0x0, msg.sender, totalSupply_);
    }
}