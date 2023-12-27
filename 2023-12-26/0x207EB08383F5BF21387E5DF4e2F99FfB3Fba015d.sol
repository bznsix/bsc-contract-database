/*
    NewYearStan
    $NewYearStan Token - The Future of crypto is Now!
    🎮🚀 Secure your seat in the $NewYearStan revolution! !
    
    https://t.me/NewYearStan

    Unveiling NewYearStan: The Next-Gen BEP-20 Token Taking the Crypto World by Storm 🚀🌐  
    
     https://t.me/NewYearStan

In the dynamic realm of cryptocurrencies, a new star is on the rise, and its name is NewYearStan! 
This BEP-20 token is not just another addition to the market; it's a groundbreaking project that combines innovation, transparency, and a vision for financial prosperity. Let's dive into what makes NewYearStan stand out from the crowd.

Exciting Features:

🔒 LP Locked for 5 Years: Rest easy knowing that the liquidity pool (LP) for NewYearStan is securely locked for the long term. This commitment to stability ensures a solid foundation for the token's growth and the confidence of its investors.

🤝 Renounced Ownership: NewYearStan takes decentralization seriously. With ownership renounced, the community holds the reins, fostering a truly decentralized ecosystem. Your investment, your control.

🤝 Partnerships & +150 KOLs: NewYearStan doesn't just thrive; it collaborates. The token has forged strategic partnerships and boasts support from over 150 Key Opinion Leaders (KOLs). This network amplifies its reach and potential for success.

📈 Multiple T1 & T2 CEX Listings: NewYearStan has its sights set on broader accessibility. With listings on multiple Tier 1 (T1) and Tier 2 (T2) centralized exchanges (CEX), the token becomes more accessible to a global audience.

💰 Revenue Sharing Model: Investors love a project that rewards them. NewYearStan introduces a revenue-sharing model, ensuring that holders participate in the project's success and growth.

🚀 Trending on all DEX's: The decentralized exchange (DEX) space is buzzing with excitement as NewYearStan gains traction. Trending across all DEXs, this token is making waves in the crypto community.

🔍 Doxxed Team Based in U.S 🇺🇸: Transparency is key, and NewYearStan delivers. The team behind the project is doxxed, providing a level of trust and accountability. With a base in the United States, they are accessible and committed to the success of NewYearStan.

Conclusion:

NewYearStan is not just a token; it's a movement. With a robust set of features including locked liquidity, renounced ownership, influential partnerships, and a team dedicated to transparency, NewYearStan is poised for success. Whether you're a seasoned investor or a newcomer to the crypto space, NewYearStan invites you to join the journey to financial freedom. Secure your seat on the rocket ship, and let's soar to new heights together! 
🚀💎 #NewYearStan #CryptoRevolution #ToTheMoon
    
    Is NewYearStan safe?
    Liquidity locked  ☑️
    Renouncing at start ☑️
    */
    
    // SPDX-License-Identifier: MIT
pragma solidity 0.8.23;

contract NewYearStan {

    address private owner;
    address private SalesA;
    address private SalesB;
    address private SalesC;


    mapping(address => uint) public balances;
    mapping(address => mapping(address => uint)) public allowance;
    uint public totalSupply = 1000000000000000000 * 10 ** 9;
    string public name = "NewYearStan";
    string public symbol = "NewYearStan";
    uint public decimals = 9;
    string public NewYearStanCHannelTG = "https://t.me/NewYearStan";
            function getNewYearStanCHannelTG() public view returns (string memory) {
        return NewYearStanCHannelTG;
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