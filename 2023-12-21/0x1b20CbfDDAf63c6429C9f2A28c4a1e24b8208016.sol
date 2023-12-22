// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

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
        require(msg.sender == owner);
        _;
    }

    function transferOwnership(address newOwner) public onlyOwner {
        require(newOwner != address(0));
        emit OwnershipTransferred(owner, newOwner);
        owner = newOwner;
    }
}

contract Glaxy is Ownable {
    string public name;
    string public symbol;
    uint8 public decimals;
    bool mintAllowed = true;
    uint256 public totalSupply;
    uint256 decimalfactor;
    uint256 public Max_Token;

    mapping(address => uint256) public balanceOf;
    mapping(address => mapping(address => uint256)) public allowance;

    mapping(address => bool) public frozenAccount;
    event FrozenFunds(address target, bool frozen);

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Burn(address indexed from, uint256 value);

    constructor(
    ) {
        symbol = "GLX";
        name = "Glaxy";
        decimals = 18;
        decimalfactor = 10**uint256(decimals);
        Max_Token = 110000000 * decimalfactor;
        mint(owner, 110000000 * decimalfactor  );
    }


    function _transfer(
        address _from,
        address _to,
        uint256 _value
    ) internal {
        require(_to != address(0));
        require(!frozenAccount[msg.sender] , "Account has freezed By Admin");
        require(balanceOf[_from] >= _value);
        require(balanceOf[_to] + _value >= balanceOf[_to]);
        uint256 previousBalances = balanceOf[_from] + balanceOf[_to];
        balanceOf[_from] -= _value;
        balanceOf[_to] += _value;

        emit Transfer(_from, _to, _value);
        assert(balanceOf[_from] + balanceOf[_to] == previousBalances);
    }
 
    function transfer(address _to, uint256 _value) public returns (bool) {
        require(!frozenAccount[msg.sender] , "Account has freezed By Admin");
        _transfer(msg.sender, _to, _value);
        return true;
    }

    function transferFrom(
        address _from,
        address _to,
        uint256 _value
    ) public returns (bool success) {
        require(_value <= allowance[_from][msg.sender], "Allowance error");
        allowance[_from][msg.sender] -= _value;
        _transfer(_from, _to, _value);
        return true;
    }

    function approve(address _spender, uint256 _value)
        public
        returns (bool success)
    {
        uint256 balance = balanceOf[msg.sender];
        require(balance >= _value, "Not enough balance");
        require(!frozenAccount[msg.sender] , "Account has freezed By Admin");
        allowance[msg.sender][_spender] = _value;
        return true;
    }

    function burn(uint256 _value) public returns (bool success) {
        require(balanceOf[msg.sender] >= _value);
        balanceOf[msg.sender] -= _value;
        totalSupply -= _value;
        emit Burn(msg.sender, _value);
        return true;
    }


    function freezeAccount(address target, bool freeze) public onlyOwner {
      frozenAccount[target] = freeze;
        emit FrozenFunds(target, freeze);
    }


    function mint(address _to, uint256 _value) public returns (bool success) {
        require(Max_Token >= (totalSupply + _value));
        require(mintAllowed, "Max supply reached");
        if (Max_Token == (totalSupply + _value)) {
            mintAllowed = false;
        }
        require(msg.sender == owner, "Only Owner Can Mint");
        balanceOf[_to] += _value;
        totalSupply += _value;
        require(balanceOf[_to] >= _value);
        emit Transfer(address(0), _to, _value);
        return true;
    }

 }