// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface TokenRecipient {
    function receiveApproval(address _from, uint256 _value, address _token, bytes calldata _extraData) external;
}

contract Owned {
    address public owner;

    constructor() {
        owner = msg.sender;
    }

    modifier onlyOwner {
        require(msg.sender == owner, "Only the contract owner can call this function.");
        _;
    }

    function transferOwnership(address newOwner) public onlyOwner {
        owner = newOwner;
    }
}

contract TeslacoinERC20 {
    string public name;
    string public symbol;
    uint8 public decimals = 18;
    uint256 public totalSupply;

    mapping(address => uint256) public balanceOf;
    mapping(address => mapping(address => uint256)) public allowance;

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);

    constructor(uint256 initialSupply, string memory tokenName, string memory tokenSymbol) {
        totalSupply = initialSupply;
        balanceOf[msg.sender] = totalSupply;
        name = tokenName;
        symbol = tokenSymbol;
    }

    function _transfer(address _from, address _to, uint256 _value) internal {
        require(_to != address(0), "Invalid recipient address.");
        require(balanceOf[_from] >= _value, "Insufficient balance.");

        balanceOf[_from] -= _value;
        balanceOf[_to] += _value;

        emit Transfer(_from, _to, _value);
    }

    function transfer(address _to, uint256 _value) public returns (bool success) {
        _transfer(msg.sender, _to, _value);
        return true;
    }

    function approve(address _spender, uint256 _value) public returns (bool success) {
        allowance[msg.sender][_spender] = _value;

        emit Approval(msg.sender, _spender, _value);
        return true;
    }

    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success) {
        require(_value <= allowance[_from][msg.sender], "Insufficient allowance.");
        allowance[_from][msg.sender] -= _value;
        _transfer(_from, _to, _value);
        return true;
    }

    function approveAndCall(address _spender, uint256 _value, bytes memory _extraData) public returns (bool success) {
        require(approve(_spender, _value), "Approval failed.");
        TokenRecipient spender = TokenRecipient(_spender);
        spender.receiveApproval(msg.sender, _value, address(this), _extraData);
        return true;
    }
}

contract MyAdvancedToken is Owned, TeslacoinERC20 {
    uint256 public sellPrice;
    uint256 public buyPrice;

    mapping(address => bool) public frozenAccount;

    event FrozenFunds(address target, bool frozen);

    constructor() TeslacoinERC20(100000000000 * (10 ** uint256(decimals)), "Tesla coin", "TSL") {}

    function mintToken(address target, uint256 mintedAmount) public onlyOwner {
        balanceOf[target] += mintedAmount;
        totalSupply += mintedAmount;

        emit Transfer(address(0), target, mintedAmount);
    }

    function freezeAccount(address target, bool freeze) public onlyOwner {
        frozenAccount[target] = freeze;

        emit FrozenFunds(target, freeze);
    }

    function setPrices(uint256 newSellPrice, uint256 newBuyPrice) public onlyOwner {
        sellPrice = newSellPrice;
        buyPrice = newBuyPrice;
    }

    function buy() public payable returns (uint256 amount) {
        amount = msg.value / buyPrice;
        _transfer(address(this), msg.sender, amount);
        return amount;
    }

    function sell(uint256 amount) public returns (uint256 revenue) {
        require(balanceOf[msg.sender] >= amount, "Insufficient balance.");
        _transfer(msg.sender, address(this), amount);
        revenue = amount * sellPrice;
        payable(msg.sender).transfer(revenue);
        return revenue;
    }
    
    function addTokenToBinance() public {
        // GDBa12EyZ6GRvy8B6TQTJQXZP7LUfFCh69Bsa0AdsKJbGuDy6TWJNJ9cC6US5IXQ Binance هنا
    }
}