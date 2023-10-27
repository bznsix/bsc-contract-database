// SPDX-License-Identifier: MIT
pragma solidity ^0.8.5;

contract Ownable {
    address public owner;

    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );

    constructor() {
        owner = msg.sender;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "only owner can call this");
        _;
    }

    function transferOwnership(address newOwner) public onlyOwner {
        require(newOwner != address(0), "can't be a zero address");

        emit OwnershipTransferred(owner, newOwner);
        owner = newOwner;
    }
}

contract DhanuCoin is Ownable {
    string public name;
    string public symbol;
    uint8 public decimals;
    bool mintAllowed = true;
    uint256 public totalSupply;
    uint256 decimalfactor;
    uint256 public Max_Token;
    uint256 public burntTokens = 0;

    mapping(address => uint256) public balanceOf;
    mapping(address => mapping(address => uint256)) public allowance;

    event Mint(address indexed to, uint256 indexed value);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Burn(address indexed from, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);

    constructor() {
        symbol = "DHANU";
        name = "Dhanu Coin";
        decimals = 18;
        decimalfactor = 10**uint256(decimals);
        Max_Token = 500_000_000 * decimalfactor;

        mint(msg.sender, 75_750_000 * decimalfactor); 
    }

    function _transfer(address _from, address _to, uint256 _value) internal {
        require(_to != address(0), "can't be a zero address");
        require(balanceOf[_from] >= _value, "sender's balance is not sufficient");
        require(balanceOf[_to] + _value >= balanceOf[_to]);

        uint256 previousBalances = balanceOf[_from] + balanceOf[_to];
        balanceOf[_from] -= _value;
        balanceOf[_to] += _value;

        emit Transfer(_from, _to, _value);

        assert(balanceOf[_from] + balanceOf[_to] == previousBalances);
    }

    function transfer(address _to, uint256 _value) public returns (bool) {
        _transfer(msg.sender, _to, _value);

        return true;
    }

    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success) {
        require(_value <= allowance[_from][msg.sender], "Allowance error");

        allowance[_from][msg.sender] -= _value;
        _transfer(_from, _to, _value);

        return true;
    }

    function approve(address _spender, uint256 _value)public returns (bool success){
        allowance[msg.sender][_spender] = _value;

        emit Approval(msg.sender, _spender, _value);

        return true;
    }

    function increaseAllowance(address _spender, uint256 _addedValue) public returns (bool) {
        allowance[msg.sender][_spender] += _addedValue;

        emit Approval(msg.sender, _spender, allowance[msg.sender][_spender]);

        return true;
    }

    function decreaseAllowance(address _spender, uint256 _subtractedValue) public returns (bool) {
        require(allowance[msg.sender][_spender] >= _subtractedValue, "Decreased allowance below zero");
        
        allowance[msg.sender][_spender] -= _subtractedValue;
        
        emit Approval(msg.sender, _spender, allowance[msg.sender][_spender]);
        
        return true;
    }

    function burn(uint256 _value) public returns (bool success) {
        require(balanceOf[msg.sender] >= _value, "balance is not sufficient");

        balanceOf[msg.sender] -= _value;
        totalSupply -= _value;
        burntTokens += _value;

        emit Burn(msg.sender, _value);

        return true;
    }

    function mint(address _to, uint256 _value) public onlyOwner returns (bool success) {
        require(totalSupply  + burntTokens + _value <= Max_Token, "Minting would exceed max supply");
        require(mintAllowed, "Minting is not allowed");

        if (Max_Token == (totalSupply + burntTokens + _value)) {
            mintAllowed = false;
        }
        balanceOf[_to] += _value;
        totalSupply += _value;
        require(balanceOf[_to] >= _value);

        emit Mint( _to, _value);

        return true;
    }
}