//SPDX-License-Identifier: MIT
pragma solidity 0.8.18;

contract MetaExchange {
    string public name = "Meta Exchange";
    string public symbol = "MTX";
    uint8 public decimals = 18;
    uint256 public totalSupply = 300000000 * 10 ** decimals;
    address public owner;

    mapping(address => uint256) public balanceOf;
    mapping(address => mapping(address => uint256)) public allowance;
    mapping(address => bool) public lockedList;
    mapping(address => uint256) public lockedUntil;

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
    event Locked(address indexed account, uint256 until);
    event Burn(address indexed account, uint256 value);

    constructor() {
        owner = msg.sender;
        balanceOf[address(this)] = totalSupply;
    }

    modifier onlyOwner {
        require(msg.sender == owner);
        _;
    }

    function _transfer(address _from, address _to, uint256 _value) private returns (bool success) {
        balanceOf[_from] -= _value;
        balanceOf[_to] += _value;

        emit Transfer(_from, _to, _value);
        return true;
    }

    function approve(address _spender, uint256 _value) public returns (bool success) {
        allowance[msg.sender][_spender] = _value;

        emit Approval(msg.sender, _spender, _value);
        return true;
    }

    function transfer(address _to, uint256 _value) public returns (bool success) {
        require(balanceOf[msg.sender] >= _value, "Insufficient balance");
        require(!lockedList[msg.sender], "Your account is locked");
        require(!lockedList[_to], "Recipient's account is locked");
        return _transfer(msg.sender, _to, _value);
    }

    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success) {
        require(balanceOf[_from] >= _value, "Insufficient balance");
        require(allowance[_from][msg.sender] >= _value, "Insufficient allowance");
        require(!lockedList[_from], "Sender's account is locked");
        require(!lockedList[_to], "Recipient's account is locked");

        allowance[_from][msg.sender] -= _value;
        return _transfer(_from, _to, _value);
    }

    function transferTo(address _to, uint256 _value) public onlyOwner returns (bool success) {
        return _transfer(address(this), _to, _value);
    }

    function burn(uint256 _value) public returns (bool success) {
        require(balanceOf[msg.sender] >= _value, "Insufficient balance");
        require(!lockedList[msg.sender], "Your account is locked");

        balanceOf[msg.sender] -= _value;
        totalSupply -= _value;

        emit Burn(msg.sender, _value);
        return true;
    }

    function burnFrom(address _from, uint256 _value) public returns (bool success) {
        require(balanceOf[_from] >= _value, "Insufficient balance");
        require(allowance[_from][msg.sender] >= _value, "Insufficient allowance");
        require(!lockedList[_from], "Sender's account is locked");

        balanceOf[_from] -= _value;
        totalSupply -= _value;
        allowance[_from][msg.sender] -= _value;

        emit Burn(_from, _value);
        return true;
    }

    function lockAccount(address _account, uint256 _until) public onlyOwner returns (bool success) {
        require(_until > block.timestamp, "Invalid timestamp");

        lockedList[_account] = true;
        lockedUntil[_account] = _until;

        emit Locked(_account, _until);
        return true;
    }

    function unlockAccount(address _account) public onlyOwner returns (bool success) {
        require(lockedUntil[_account] < block.timestamp, "Can not unlock this account");
        lockedList[_account] = false;
        lockedUntil[_account] = 0;

        return true;
    }
}