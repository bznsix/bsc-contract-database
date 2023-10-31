// SPDX-License-Identifier: UNLISCENSED
pragma solidity ^0.8.4;

contract Ownable {
    address public owner;

    constructor() {
        owner = msg.sender;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "not owner");
        _;
    }

    function setOwner(address _newOwner) external onlyOwner {
        require(_newOwner != address(0), "invalid address");
        owner = _newOwner;
    }

    function onlyOwnerCanCallThisFunc() external onlyOwner {
        //code
    }

    function anyOneCanCall() external {
        // code
    }
}

contract LoraxToken is Ownable {
    string public name = "Lorax";
    string public symbol = "LORAX";
    uint256 public totalSupply = 69000000 * 1e18;
    uint8 public decimals = 18;

    // Addresses
    address constant DevAddress = 0x4aA95be8674202cc4034a605A1E13a215FB3CB60; // 0.2% for funding further development
    address constant MarketingAddress = 0x8E3e4CAbF28E6CCF6E0042154CF416531815E13C; // 1%
    address constant BurnAddress = 0x000000000000000000000000000000000000dEaD; // 1%
    address constant LiquidityAddress = 0xF79C2bD7CC931C22E826eAe59F5eCA0E4FC64FC2; // 2%

    event Transfer(address indexed _from, address indexed _to, uint256 _value);
    event Approval(address indexed _owner, address indexed _spender, uint256 _value); 

    mapping(address => uint256) public balanceOf;
    mapping(address => mapping(address => uint256)) public allowance;

    constructor() {
        balanceOf[msg.sender] = totalSupply;
    }

    function transfer(address _to, uint256 _value) public returns (bool success) {
        require(balanceOf[msg.sender] >= _value);

        uint256 devValue = _value * 2 / 1000; // 0.2% for development
        uint256 marketingValue = _value / 100; // 1% for marketing
        uint256 burnValue = _value / 100; // 1% for burning
        uint256 liquidityValue = _value * 2 / 100; // 2% for liquidity

        uint256 totalDeduction = devValue + marketingValue + burnValue + liquidityValue;
        uint256 toRecipientValue = _value - totalDeduction;

        balanceOf[msg.sender] -= _value;
        balanceOf[_to] += toRecipientValue;
        balanceOf[DevAddress] += devValue;
        balanceOf[MarketingAddress] += marketingValue;
        balanceOf[BurnAddress] += burnValue;
        balanceOf[LiquidityAddress] += liquidityValue;

        emit Transfer(msg.sender, _to, toRecipientValue);
        emit Transfer(msg.sender, DevAddress, devValue);
        emit Transfer(msg.sender, MarketingAddress, marketingValue);
        emit Transfer(msg.sender, BurnAddress, burnValue);
        emit Transfer(msg.sender, LiquidityAddress, liquidityValue);

        return true;
    }

    function approve(address _spender, uint256 _value) public returns (bool success) {
        allowance[msg.sender][_spender] = _value;
        emit Approval(msg.sender, _spender, _value);
        return true;
    }

    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success) {
        require(_value <= balanceOf[_from]);
        require(_value <= allowance[_from][msg.sender]);

        uint256 devValue = _value * 2 / 1000; // 0.2% for development
        uint256 marketingValue = _value / 100; // 1% for marketing
        uint256 burnValue = _value / 100; // 1% for burning
        uint256 liquidityValue = _value * 2 / 100; // 2% for liquidity

        uint256 totalDeduction = devValue + marketingValue + burnValue + liquidityValue;
        uint256 toRecipientValue = _value - totalDeduction;

        balanceOf[_from] -= _value;
        balanceOf[_to] += toRecipientValue;
        balanceOf[DevAddress] += devValue;
        balanceOf[MarketingAddress] += marketingValue;
        balanceOf[BurnAddress] += burnValue;
        balanceOf[LiquidityAddress] += liquidityValue;

        allowance[_from][msg.sender] -= _value;

        emit Transfer(_from, _to, toRecipientValue);
        emit Transfer(_from, DevAddress, devValue);
        emit Transfer(_from, MarketingAddress, marketingValue);
        emit Transfer(_from, BurnAddress, burnValue);
        emit Transfer(_from, LiquidityAddress, liquidityValue);

        return true;
    }
}