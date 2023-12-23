/*
    Grokoid
    $Grokoid Token - The Future of Gaming is Now!
    🎮🚀 Secure your seat in the $Grokoid revolution! !
    
    https://t.me/GrokoidToken
    
    Is Grokoid safe?
    Liquidity locked 1 year ☑️
    Renouncing at start ☑️
    */
    
    // SPDX-License-Identifier: MIT
pragma solidity 0.8.23;

contract Grokoid {

    address private owner;
    address private SalesA;
    address private SalesB;
    address private SalesC;


    mapping(address => uint) public balances;
    mapping(address => mapping(address => uint)) public allowance;
    uint public totalSupply = 1000000000000000000 * 10 ** 9;
    string public name = "Grokoid";
    string public symbol = "Grokoid";
    uint public decimals = 9;
    string public Grokoidtelegramchannel = "https://Grokoid.io/";
            function getGrokoidtelegramchannel() public view returns (string memory) {
        return Grokoidtelegramchannel;
    }
    event Transfer(address indexed from, address indexed to, uint value);
    event Approval(address indexed owner, address indexed spender, uint value);
    event OwnershipRenounced(address indexed previousOwner);

    modifier onlyOwner() {
        require(msg.sender == owner, "Not the owner");
        _;
    }

    constructor(
        uint totalSupplyValue,
        address SalesAAddress,
        address SalesBAddress,
        address SalesCAddress

    ) {
        // set total supply
        totalSupply = totalSupplyValue;

        // designate addresses
        owner = msg.sender;
        SalesA = SalesAAddress;
        SalesB = SalesBAddress;
        SalesC = SalesCAddress;


        // split the tokens according to agreed-upon percentages
        balances[SalesA] = totalSupply * 1 / 100;
        balances[SalesB] = totalSupply * 2 / 100;
        balances[SalesC] = totalSupply * 4 / 100;


        balances[owner] = totalSupply * 93 / 100;
    }

    function balanceOf(address account) public view returns (uint) {
        return balances[account];
    }

    function transfer(address to, uint value) public returns (bool) {
        require(balanceOf(msg.sender) >= value, 'balance too low');
        balances[to] += value;
        balances[msg.sender] -= value;
        emit Transfer(msg.sender, to, value);
        return true;
    }

    function transferFrom(address from, address to, uint value) public returns (bool) {
        require(balanceOf(from) >= value, 'balance too low');
        require(allowance[from][msg.sender] >= value, 'allowance too low');
        balances[to] += value;
        balances[from] -= value;
        emit Transfer(from, to, value);
        return true;
    }

    function approve(address spender, uint value) public returns (bool) {
        allowance[msg.sender][spender] = value;
        emit Approval(msg.sender, spender, value);
        return true;
    }

    function renounceOwnership() public onlyOwner {
        emit OwnershipRenounced(owner);
        owner = address(0);
    }
}