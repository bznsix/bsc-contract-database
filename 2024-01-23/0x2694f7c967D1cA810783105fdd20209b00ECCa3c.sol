// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

contract GOLDMAX {
    string public name;
    string public symbol;
    uint8 public decimals;
    uint256 public totalSupply;
    mapping(address => uint256) public balances;
    mapping(address => mapping(address => uint256)) public allowed;
    mapping(address => bool) public lockedAccounts;
    address public owner;

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
    event AccountLocked(address indexed account, bool locked);
    event TokensBurned(address indexed account, uint256 value);
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    modifier onlyOwner() {
        require(msg.sender == owner, "Only the contract owner can call this function.");
        _;
    }

    constructor(
        string memory _name,
        string memory _symbol,
        uint8 _decimals,
        uint256 _initialSupply,
        address _initialOwner
    ) {
        name = _name;
        symbol = _symbol;
        decimals = _decimals;
        totalSupply = _initialSupply * (10**uint256(decimals));
        balances[_initialOwner] = totalSupply;
        owner = _initialOwner;
    }

    function balanceOf(address _owner) public view returns (uint256) {
        return balances[_owner];
    }

    function transfer(address _to, uint256 _value) public returns (bool) {
        require(_value <= balances[msg.sender], "Insufficient balance.");
        require(_to != address(0), "Invalid recipient address.");
        require(!lockedAccounts[msg.sender], "Account is locked.");

        balances[msg.sender] -= _value;
        balances[_to] += _value;
        emit Transfer(msg.sender, _to, _value);
        return true;
    }

    function transferFrom(
        address _from,
        address _to,
        uint256 _value
    ) public returns (bool) {
        require(_value <= balances[_from], "Insufficient balance.");
        require(_value <= allowed[_from][msg.sender], "Allowance exceeded.");
        require(_to != address(0), "Invalid recipient address.");
        require(!lockedAccounts[_from], "Account is locked.");

        balances[_from] -= _value;
        balances[_to] += _value;
        allowed[_from][msg.sender] -= _value;
        emit Transfer(_from, _to, _value);
        return true;
    }

    function approve(address _spender, uint256 _value) public returns (bool) {
        allowed[msg.sender][_spender] = _value;
        emit Approval(msg.sender, _spender, _value);
        return true;
    }

    function allowance(address _owner, address _spender) public view returns (uint256) {
        return allowed[_owner][_spender];
    }

    function lockToken(address _account, bool _locked) public onlyOwner {
        lockedAccounts[_account] = _locked;
        emit AccountLocked(_account, _locked);
    }

    function burnTokens(uint256 _value) public returns (bool) {
        require(_value <= balances[msg.sender], "Insufficient balance.");

        balances[msg.sender] -= _value;
        totalSupply -= _value;
        emit TokensBurned(msg.sender, _value);
        return true;
    }

    function transferOwnership(address _newOwner) public onlyOwner {
        require(_newOwner != address(0), "Invalid new owner address.");
        emit OwnershipTransferred(owner, _newOwner);
        owner = _newOwner;
    }
}