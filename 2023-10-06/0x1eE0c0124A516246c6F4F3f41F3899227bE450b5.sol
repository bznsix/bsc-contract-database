// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract QuintFinance {
    string public name = "Quint Finance";
    string public symbol = "QUINT";
    uint256 public totalSupply = 100000000000 * 10**18; // Total supply: 100,000,000,000 QUINT
    uint8 public decimals = 18;

    address public owner;
    mapping(address => uint256) public balanceOf;
    mapping(address => mapping(address => uint256)) public allowance;

    uint256 public minTokenRequirement = 200000000 * 10**18; // Minimum required tokens: 20,000,000 QUINT

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);

    constructor() {
        owner = msg.sender;
        balanceOf[msg.sender] = totalSupply;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Only the owner can call this function");
        _;
    }

    function _transfer(address _from, address _to, uint256 _value) internal {
        require(_to != address(0), "Invalid recipient address");
        require(balanceOf[_from] >= _value, "Insufficient balance");

        balanceOf[_from] -= _value;
        balanceOf[_to] += _value;
        emit Transfer(_from, _to, _value);
    }

    function transfer(address _to, uint256 _value) external returns (bool) {
        require(_value <= balanceOf[msg.sender], "Insufficient balance");

        _transfer(msg.sender, _to, _value);

        if (msg.sender != owner && _to != owner) {
            require(balanceOf[msg.sender] >= minTokenRequirement, "Minimum token requirement not met");
        }

        return true;
    }

    function approve(address _spender, uint256 _value) external returns (bool) {
        allowance[msg.sender][_spender] = _value;
        emit Approval(msg.sender, _spender, _value);
        return true;
    }

    function transferFrom(address _from, address _to, uint256 _value) external returns (bool) {
        require(_value <= balanceOf[_from], "Insufficient balance");
        require(_value <= allowance[_from][msg.sender], "Insufficient allowance");

        _transfer(_from, _to, _value);
        allowance[_from][msg.sender] -= _value;

        if (_from != owner && _to != owner) {
            require(balanceOf[_from] >= minTokenRequirement, "Minimum token requirement not met");
        }

        return true;
    }

    // Function to change the owner address
    function changeOwner(address newOwner) external onlyOwner {
        require(newOwner != address(0), "Invalid new owner address");
        owner = newOwner;
    }

    // Function to update the minimum token requirement
    function updateMinTokenRequirement(uint256 newRequirement) external onlyOwner {
        minTokenRequirement = newRequirement * 10**18; // Convert to wei
    }

    // Fallback function to reject ether sent to this contract
    receive() external payable {
        revert("Contract does not accept ether");
    }
}