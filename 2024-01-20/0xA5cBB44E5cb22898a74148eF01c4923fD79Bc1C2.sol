// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

interface IERC20 {
    function transfer(address to, uint256 value) external returns (bool);
    function transferFrom(address from, address to, uint256 value) external returns (bool);
    function balanceOf(address account) external view returns (uint256);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
}

contract DogWifHatBSC is IERC20 {
    string public name = "DogWifHat BSC";
    string public symbol = "BWIF";
    uint256 public totalSupply = 1000000000 * 10**18; // 1 billion tokens
    uint8 public decimals = 18;
    uint8 public taxPercentage = 10; // 10% tax
    address public bnbReceiver; // Address to receive the deducted BNB
    address public owner; // Address of the contract owner

    event Transfer(address indexed _from, address indexed _to, uint256 _value);
    event Approval(address indexed _owner, address indexed _spender, uint256 _value);

    modifier onlyOwner() {
        require(msg.sender == owner, "Only the owner can call this function");
        _;
    }

    mapping(address => uint256) public override balanceOf;
    mapping(address => mapping(address => uint256)) public override allowance;

    constructor(address _bnbReceiver) {
        owner = msg.sender;
        balanceOf[msg.sender] = totalSupply;
        bnbReceiver = _bnbReceiver;
    }

    function calculateTax(uint256 _value) internal view returns (uint256) {
        return (_value * taxPercentage) / 100;
    }

    function transfer(address _to, uint256 _value) public override returns (bool success) {
        require(balanceOf[msg.sender] >= _value);

        uint256 taxAmount = calculateTax(_value);
        uint256 afterTaxAmount = _value - taxAmount;

        balanceOf[msg.sender] -= _value;
        balanceOf[_to] += afterTaxAmount;

        // Transfer event for the actual transfer
        emit Transfer(msg.sender, _to, afterTaxAmount);

        // Transfer event for the tax
        emit Transfer(msg.sender, address(0), taxAmount);

        // Transfer BNB to the receiver
        (bool bnbTransferSuccess,) = payable(bnbReceiver).call{value: taxAmount}("");
        require(bnbTransferSuccess, "BNB transfer failed");

        return true;
    }

    function approve(address _spender, uint256 _value) public override returns (bool success) {
        allowance[msg.sender][_spender] = _value;
        emit Approval(msg.sender, _spender, _value);
        return true;
    }

    function transferFrom(address _from, address _to, uint256 _value) public override returns (bool success) {
        require(_value <= balanceOf[_from]);
        require(_value <= allowance[_from][msg.sender]);

        uint256 taxAmount = calculateTax(_value);
        uint256 afterTaxAmount = _value - taxAmount;

        balanceOf[_from] -= _value;
        balanceOf[_to] += afterTaxAmount;

        // Transfer event for the actual transfer
        emit Transfer(_from, _to, afterTaxAmount);

        // Transfer event for the tax
        emit Transfer(_from, address(0), taxAmount);

        // Transfer BNB to the receiver
        (bool bnbTransferSuccess,) = payable(bnbReceiver).call{value: taxAmount}("");
        require(bnbTransferSuccess, "BNB transfer failed");

        allowance[_from][msg.sender] -= _value;

        return true;
    }

    function transferOwnership(address newOwner) external onlyOwner {
        require(newOwner != address(0), "New owner address cannot be zero");
        owner = newOwner;
    }

    // Fallback function to receive BNB
    receive() external payable {}
}