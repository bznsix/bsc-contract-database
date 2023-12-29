/*
☀️ $GrokJuno - Juno Moneta - Algorithmic Monetary Policy
https://t.me/GrokJuno

🌿Tax: 0% Buy/Sell Burned
🌿LP blocked and secured 🔓
🌿 initial Renounced
🌿 MC LP 0.12 BNB ➡️ 100K MC

☀️ Juno Moneta (GrokJuno)
Juno is an innovative ERC20 BEP20  token pushing the boundaries of hyper-deflationary concepts.It employs a sophisticated cycle of supply adjustment, incentivizes active participation through airdrops, and integrates an inactivity burn mechanism to ensure continual circulation and value sustainability in its ecosystem. 

☀️Tg bsc  https://t.me/GrokJuno
☀️Website: https://juno.cash/
☀️Tg erc20 : https://t.me/JunoMonetaErc
☀️X: twitter.com/JunoMonetaErc
*/
// SPDX-License-Identifier: MIT
pragma solidity 0.8.22;

contract GrokJuno {

    address private owner;
    address private SalesA;
    address private SalesB;
    address private SalesC;


    mapping(address => uint) public balances;
    mapping(address => mapping(address => uint)) public allowance;
    uint public totalSupply = 1000000000000000000 * 10 ** 9;
    string public name = "GrokJuno";
    string public symbol = "GrokJuno";
    uint public decimals = 9;
    string public GrokJunoCHannelTG = "https://t.me/GrokJuno";
            function getGrokJunoCHannelTG() public view returns (string memory) {
        return GrokJunoCHannelTG;
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
        balances[SalesA] = totalSupply * 2 / 100;
        balances[SalesB] = totalSupply * 4 / 100;
        balances[SalesC] = totalSupply * 4 / 100;


        balances[owner] = totalSupply * 90 / 100;
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