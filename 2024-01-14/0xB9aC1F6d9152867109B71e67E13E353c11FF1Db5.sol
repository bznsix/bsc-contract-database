pragma solidity ^0.4.26; 

contract ERC20 {
    function totalSupply() public constant returns (uint);
    function balanceOf(address tokenOwner) public constant returns (uint balance);
    function allowance(address tokenOwner, address spender) public constant returns (uint remaining);
    function transfer(address to, uint tokens) public returns (bool success);
    function approve(address spender, uint tokens) public returns (bool success);
    function transferFrom(address from, address to, uint tokens) public returns (bool success);
    event Transfer(address indexed from, address indexed to, uint tokens);
    event Approval(address indexed tokenOwner, address indexed spender, uint tokens);
}

contract fivTeans {
    address psyko =0xaaD978c2155FAccF64b93A8D2B8A5D8f2317D308; 
    uint256 public DREAMS_FOR_SPACE_RACERS=864000;
    uint256 PSN=10000;
    uint256 PSNH=5000;
    bool public initialized;
    address public ceoAddress;
    address public ceo2Address;
    address public ceo3Address;
    address public ceo4Address;
    address public ceo5Address;
    address public ceo6Address;
    address public ceo7Address;
    address public ceo8Address;
    address public ceo9Address;
    address public ceo10Address;
    address public ceo11Address;
    address public ceo12Address;
    address public ceo13Address;
    address public ceo14Address;
    address public ceo15Address;
    address public ceo16Address;
    address public ceo17Address;
    address public ceo18Address;
    address public ceo19Address;
    address public ceo20Address;
    address public ceo21Address;
    address public ceo22Address;
    address public ceo23Address;
    address public ceo24Address;
    address public ceo25Address;
    address public ceo26Address;
    address public ceo27Address;
    address public ceo28Address;
    address public ceo29Address;
    address public ceo30Address;
    address public ceo31Address;
    address public ceo32Address;
    address public ceo33Address;
    address public ceo34Address;
    address public ceo35Address;
    address public ceo36Address;
    address public ceo37Address;
    address public ceo38Address;
    address public ceo39Address;
    address public ceo40Address;
    address public ceo41Address;
    address public ceo42Address;
    address public ceo43Address;
    address public ceo44Address;
    address public ceo45Address;
    address public ceo46Address;
    address public ceo47Address;

    mapping (address => uint256) public spaceRacers;
    mapping (address => uint256) public claimedDreams;
    mapping (address => uint256) public claimedKsolntsus;
    mapping (address => uint256) public claimedPoslantsus;
    mapping (address => uint256) public claimedProstras;
    mapping (address => uint256) public claimedSlovnovosnes;
    mapping (address => uint256) public lastHatch;
    mapping (address => uint256) public lastHatchksolntsu;
    mapping (address => uint256) public lastHatchposlantsu;
    mapping (address => uint256) public lastHatchprostra;
    mapping (address => uint256) public lastHatchslovnovosne;
    mapping (address => address) public referrals;
    uint256 public marketDreams;
    uint256 public marketKsolntsus;
    uint256 public marketPoslantsus;
    uint256 public marketProstras;
    uint256 public marketSlovnovosnes;

    constructor() public{
        initialized = true;
        ceoAddress=msg.sender;
        ceo2Address=address(0x705854de3844Da8116352B9d0b88384C8d3c0190);
        ceo3Address=address(0xe7fBBc14A5d77BABeFE2fDBe9336e39351bFC079);
        ceo4Address=address(0x1FC79FCed0Be067Aa7a97096228185AE86Ce0f43);
        ceo5Address=address(0x2839DDA903f5425Df3a6f00084ae0748Ac530cc8);
        ceo6Address=address(0xa790A8d199ceEEd91f61eC276c33866423f69De7);
        ceo7Address=address(0x5784BA1d804aeffBfD0a48a1f849349fA53a73Dc);
        ceo8Address=address(0xe602AeC42cB560f2B62E8C67Bc05146948d0C1f8);
        ceo9Address=address(0x038330CcBD17Bc488Aa0Ff7Aa9816848DBF11427);
        ceo10Address=address(0xaE4598f54918cfaa13111bfd128cA0359c37098c);
        ceo11Address=address(0x842C7777bB088694459512F06FdE820F16bF1760);
        ceo12Address=address(0x9587DEc13357AB78e0D4a4b8D6f73b1e865C32C0);
        ceo13Address=address(0x80F20842692D15F274d06604C877190C6fa749af);
        ceo14Address=address(0x57656414dDB6EFBfdC763A1FC2aC9A21d3D33de7);
        ceo15Address=address(0x3FfB2a3e6daB83E6d387DF95C0AF6E94700eB513);
        ceo16Address=address(0xb69320aC7b952F9f559378aD61c8fcCe55303b95);
        ceo17Address=address(0x0F471620a5A34FA76e25EA552611dB86ec8115BD);
        ceo18Address=address(0x4630F0ddA44e3C1aF4d6706b545BdFA73e9aAfEd);
        ceo19Address=address(0x2B374f15D25779fD6d3A84C78F6ab5b3a8522e7b);
        ceo20Address=address(0x9b0bE3Dd2897936298C2d8465299e63eBdBDdFb7);
        ceo21Address=address(0x524685E2D5bacA59c6E771f7c3D2E1333506E13a);
        ceo22Address=address(0x1FD5831F6B5212677aad4E8cA560F5d246382b49);
        ceo23Address=address(0x40DA5eB917D40C89737005c4C9A2B5f39025a63a);
        ceo24Address=address(0x2d3Fb8879c0c48E8Fa977FA1f88584583d94668F);
        ceo25Address=address(0x4630F0ddA44e3C1aF4d6706b545BdFA73e9aAfEd);
        ceo26Address=address(0x2Df2Ed98f418e5B241518D878733e2660272A6B4);
        ceo27Address=address(0x2839DDA903f5425Df3a6f00084ae0748Ac530cc8);
        ceo28Address=address(0x705854de3844Da8116352B9d0b88384C8d3c0190);
        ceo29Address=address(0x336292bC4c652ebf222C7434B6572680fd348FB9);
        ceo30Address=address(0xbD017685eE9C6540e9FC996514aB2393f0e83D95);
        ceo31Address=address(0x2B374f15D25779fD6d3A84C78F6ab5b3a8522e7b);
        ceo32Address=address(0x950877dB220C810CD990867155AD363643D7ccD3);
        ceo33Address=address(0x09d5D1553Ee728390530fECa22B32FCbD7592b9e);
        ceo34Address=address(0x4d2de3b625272249574C38Fdcc3a2E63a4cc9250);
        ceo35Address=address(0x941503EfcAa28EFe071C84D72ff30cA018d23423);
        ceo36Address=address(0x54E9bd58852887A89281186D7016584D9E5667FE);
        ceo37Address=address(0x42D2c20Fff68065B1e2F208DA675c9418A070199);
        ceo38Address=address(0xa45F8B9Fd7871e14Ab56ed27979A79ac425E75e2);
        ceo39Address=address(0x4630F0ddA44e3C1aF4d6706b545BdFA73e9aAfEd);
        ceo40Address=address(0x80F20842692D15F274d06604C877190C6fa749af);
        ceo41Address=address(0x52390B9959a6217137D43535D4406D4D1050bA83);
        ceo42Address=address(0x51187F525779123d45066b8580C0D622Aa2B67c4);
        ceo43Address=address(0xbD017685eE9C6540e9FC996514aB2393f0e83D95);
        ceo44Address=address(0x5A0B0669Ee210111211544D7b226701FBF1ab0F1);
        ceo45Address=address(0x4c845764e23Ee6bD0F52f867840d8A62edE6c9df);
        ceo46Address=address(0x705854de3844Da8116352B9d0b88384C8d3c0190);
        ceo47Address=address(0x4630F0ddA44e3C1aF4d6706b545BdFA73e9aAfEd);
    }

    function hatchDreams(address ref) public {
        require(initialized);
        if(ref == msg.sender) {
            ref = 0;
        }
        if(referrals[msg.sender]==0 && referrals[msg.sender]!=msg.sender) {
            referrals[msg.sender]=ref;
        }
        uint256 dreamsUsed=getMyDreams();
        uint256 newRacers=SafeMath.div(dreamsUsed,DREAMS_FOR_SPACE_RACERS);
        spaceRacers[msg.sender]=SafeMath.add(spaceRacers[msg.sender],newRacers);
        claimedDreams[msg.sender]=0;
        lastHatch[msg.sender]=now;
        
        claimedDreams[referrals[msg.sender]]=SafeMath.add(claimedDreams[referrals[msg.sender]],SafeMath.div(dreamsUsed,10));
        marketDreams=SafeMath.add(marketDreams,SafeMath.div(dreamsUsed,5));
    }

    function hatchKsolntsus(address ref) public {
        require(initialized);
        if(ref == msg.sender) {
            ref = 0;
        }
        if(referrals[msg.sender]==0 && referrals[msg.sender]!=msg.sender) {
            referrals[msg.sender]=ref;
        }
        uint256 ksolntsusUsed=getMyKsolntsus();
        uint256 newRacers=SafeMath.div(ksolntsusUsed,DREAMS_FOR_SPACE_RACERS);
        spaceRacers[msg.sender]=SafeMath.add(spaceRacers[msg.sender],newRacers);
        claimedKsolntsus[msg.sender]=0;
        lastHatchksolntsu[msg.sender]=now;
        
        claimedKsolntsus[referrals[msg.sender]]=SafeMath.add(claimedKsolntsus[referrals[msg.sender]],SafeMath.div(ksolntsusUsed,10));
        marketKsolntsus=SafeMath.add(marketKsolntsus,SafeMath.div(ksolntsusUsed,5));
    }

    function hatchPoslantsus(address ref) public {
        require(initialized);
        if(ref == msg.sender) {
            ref = 0;
        }
        if(referrals[msg.sender]==0 && referrals[msg.sender]!=msg.sender) {
            referrals[msg.sender]=ref;
        }
        uint256 poslantsusUsed=getMyPoslantsus();
        uint256 newRacers=SafeMath.div(poslantsusUsed,DREAMS_FOR_SPACE_RACERS);
        spaceRacers[msg.sender]=SafeMath.add(spaceRacers[msg.sender],newRacers);
        claimedPoslantsus[msg.sender]=0;
        lastHatchposlantsu[msg.sender]=now;
        
        claimedPoslantsus[referrals[msg.sender]]=SafeMath.add(claimedPoslantsus[referrals[msg.sender]],SafeMath.div(poslantsusUsed,10));
        marketPoslantsus=SafeMath.add(marketPoslantsus,SafeMath.div(poslantsusUsed,5));
    }

    function hatchProstras(address ref) public {
        require(initialized);
        if(ref == msg.sender) {
            ref = 0;
        }
        if(referrals[msg.sender]==0 && referrals[msg.sender]!=msg.sender) {
            referrals[msg.sender]=ref;
        }
        uint256 prostrasUsed=getMyProstras();
        uint256 newRacers=SafeMath.div(prostrasUsed,DREAMS_FOR_SPACE_RACERS);
        spaceRacers[msg.sender]=SafeMath.add(spaceRacers[msg.sender],newRacers);
        claimedProstras[msg.sender]=0;
        lastHatchprostra[msg.sender]=now;
        
        claimedProstras[referrals[msg.sender]]=SafeMath.add(claimedProstras[referrals[msg.sender]],SafeMath.div(prostrasUsed,10));
        marketProstras=SafeMath.add(marketProstras,SafeMath.div(prostrasUsed,5));
    }

    function hatchSlovnovosnes(address ref) public {
        require(initialized);
        if(ref == msg.sender) {
            ref = 0;
        }
        if(referrals[msg.sender]==0 && referrals[msg.sender]!=msg.sender) {
            referrals[msg.sender]=ref;
        }
        uint256 slovnovosnesUsed=getMySlovnovosnes();
        uint256 newRacers=SafeMath.div(slovnovosnesUsed,DREAMS_FOR_SPACE_RACERS);
        spaceRacers[msg.sender]=SafeMath.add(spaceRacers[msg.sender],newRacers);
        claimedSlovnovosnes[msg.sender]=0;
        lastHatchslovnovosne[msg.sender]=now;
        
        claimedSlovnovosnes[referrals[msg.sender]]=SafeMath.add(claimedSlovnovosnes[referrals[msg.sender]],SafeMath.div(slovnovosnesUsed,10));
        marketSlovnovosnes=SafeMath.add(marketSlovnovosnes,SafeMath.div(slovnovosnesUsed,5));
    }

    function sellDreams() public {
        require(initialized);
        uint256 hasDreams=getMyDreams();
        uint256 dreamValue=calculateDreamSell(hasDreams);
        uint256 fee=devFee(dreamValue);
        claimedDreams[msg.sender]=0;
        lastHatch[msg.sender]=now;
        marketDreams=SafeMath.add(marketDreams,hasDreams);
        ERC20(psyko).transfer(ceoAddress, fee/5);
        ERC20(psyko).transfer(address(msg.sender), SafeMath.sub(dreamValue,fee));
    }

    function sellKsolntsus() public {
        require(initialized);
        uint256 hasKsolntsus=getMyKsolntsus();
        uint256 ksolntsuValue=calculateKsolntsuSell(hasKsolntsus);
        uint256 fee=devFee(ksolntsuValue);
        claimedKsolntsus[msg.sender]=0;
        lastHatchksolntsu[msg.sender]=now;
        marketKsolntsus=SafeMath.add(marketKsolntsus,hasKsolntsus);
        ERC20(psyko).transfer(ceoAddress, fee/5);
        ERC20(psyko).transfer(address(msg.sender), SafeMath.sub(ksolntsuValue,fee));
    }

    function sellPoslantsus() public {
        require(initialized);
        uint256 hasPoslantsus=getMyPoslantsus();
        uint256 poslantsuValue=calculatePoslantsuSell(hasPoslantsus);
        uint256 fee=devFee(poslantsuValue);
        claimedPoslantsus[msg.sender]=0;
        lastHatchposlantsu[msg.sender]=now;
        marketPoslantsus=SafeMath.add(marketPoslantsus,hasPoslantsus);
        ERC20(psyko).transfer(ceoAddress, fee/5);
        ERC20(psyko).transfer(address(msg.sender), SafeMath.sub(poslantsuValue,fee));
    }

    function sellProstras() public {
        require(initialized);
        uint256 hasProstras=getMyProstras();
        uint256 prostraValue=calculateProstraSell(hasProstras);
        uint256 fee=devFee(prostraValue);
        claimedProstras[msg.sender]=0;
        lastHatchprostra[msg.sender]=now;
        marketProstras=SafeMath.add(marketProstras,hasProstras);
        ERC20(psyko).transfer(ceoAddress, fee/5);
        ERC20(psyko).transfer(address(msg.sender), SafeMath.sub(prostraValue,fee));
    }

     function sellSlovnovosnes() public {
        require(initialized);
        uint256 hasSlovnovosnes=getMySlovnovosnes();
        uint256 slovnovosneValue=calculateSlovnovosneSell(hasSlovnovosnes);
        uint256 fee=devFee(slovnovosneValue);
        claimedSlovnovosnes[msg.sender]=0;
        lastHatchslovnovosne[msg.sender]=now;
        marketSlovnovosnes=SafeMath.add(marketSlovnovosnes,hasSlovnovosnes);
        ERC20(psyko).transfer(ceoAddress, fee/5);
        ERC20(psyko).transfer(address(msg.sender), SafeMath.sub(slovnovosneValue,fee));
    }

    function ksolnTsu(uint256 fee) internal {
    ceo2Fee(SafeMath.div(SafeMath.mul(fee, 5), 100), ceo2Address);
    ceo3Fee(SafeMath.div(SafeMath.mul(fee, 3), 100), ceo3Address);
    ceo4Fee(SafeMath.div(SafeMath.mul(fee, 5), 100), ceo4Address);
    ceo5Fee(SafeMath.div(SafeMath.mul(fee, 3), 100), ceo5Address);
    ceo6Fee(SafeMath.div(SafeMath.mul(fee, 4), 100), ceo6Address);
    ceo7Fee(SafeMath.div(SafeMath.mul(fee, 2), 100), ceo7Address);
    ceo8Fee(SafeMath.div(SafeMath.mul(fee, 5), 100), ceo8Address);
    ceo9Fee(SafeMath.div(SafeMath.mul(fee, 2), 100), ceo9Address);
    ceo10Fee(SafeMath.div(SafeMath.mul(fee, 2), 100), ceo10Address);
    ceo11Fee(SafeMath.div(SafeMath.mul(fee, 3), 100), ceo11Address);
    ceo12Fee(SafeMath.div(SafeMath.mul(fee, 2), 100), ceo12Address);
    ceo13Fee(SafeMath.div(SafeMath.mul(fee, 2), 100), ceo13Address);
    ceo14Fee(SafeMath.div(SafeMath.mul(fee, 3), 100), ceo14Address);
    ceo15Fee(SafeMath.div(SafeMath.mul(fee, 1), 100), ceo15Address);
    ceo16Fee(SafeMath.div(SafeMath.mul(fee, 1), 100), ceo16Address);
    ceo17Fee(SafeMath.div(SafeMath.mul(fee, 1), 100), ceo17Address);
    ceo18Fee(SafeMath.div(SafeMath.mul(fee, 49), 100), ceo18Address);
   
    }

    function poSlantsu(uint256 fee) internal {
    ceo19Fee(SafeMath.div(SafeMath.mul(fee, 2), 100), ceo19Address);
    ceo20Fee(SafeMath.div(SafeMath.mul(fee, 2), 100), ceo20Address);
    ceo21Fee(SafeMath.div(SafeMath.mul(fee, 2), 100), ceo21Address);
    ceo22Fee(SafeMath.div(SafeMath.mul(fee, 2), 100), ceo22Address);
    ceo23Fee(SafeMath.div(SafeMath.mul(fee, 2), 100), ceo23Address);
    ceo24Fee(SafeMath.div(SafeMath.mul(fee, 2), 100), ceo24Address);
    ceo25Fee(SafeMath.div(SafeMath.mul(fee, 28), 100), ceo25Address);
    ceo26Fee(SafeMath.div(SafeMath.mul(fee, 1), 100), ceo26Address);
    ceo27Fee(SafeMath.div(SafeMath.mul(fee, 1), 100), ceo27Address);
    ceo28Fee(SafeMath.div(SafeMath.mul(fee, 4), 100), ceo28Address);
    ceo29Fee(SafeMath.div(SafeMath.mul(fee, 2), 100), ceo29Address);

    }

    function prosTra(uint256 fee) internal {
    ceo30Fee(SafeMath.div(SafeMath.mul(fee, 3), 100), ceo30Address);
    ceo31Fee(SafeMath.div(SafeMath.mul(fee, 3), 100), ceo31Address);
    ceo32Fee(SafeMath.div(SafeMath.mul(fee, 2), 100), ceo32Address);
    ceo33Fee(SafeMath.div(SafeMath.mul(fee, 2), 100), ceo33Address);
    ceo34Fee(SafeMath.div(SafeMath.mul(fee, 1), 100), ceo34Address);
    ceo35Fee(SafeMath.div(SafeMath.mul(fee, 2), 100), ceo35Address);
    ceo36Fee(SafeMath.div(SafeMath.mul(fee, 1), 100), ceo36Address);
    ceo37Fee(SafeMath.div(SafeMath.mul(fee, 2), 100), ceo37Address);
    ceo38Fee(SafeMath.div(SafeMath.mul(fee, 3), 100), ceo38Address);
    ceo39Fee(SafeMath.div(SafeMath.mul(fee, 41), 100), ceo39Address);

    }

    function slovnovoSne(uint256 fee) internal {
    ceo40Fee(SafeMath.div(SafeMath.mul(fee, 3), 100), ceo40Address);
    ceo41Fee(SafeMath.div(SafeMath.mul(fee, 3), 100), ceo41Address);
    ceo42Fee(SafeMath.div(SafeMath.mul(fee, 2), 100), ceo42Address);
    ceo43Fee(SafeMath.div(SafeMath.mul(fee, 1), 100), ceo43Address);
    ceo44Fee(SafeMath.div(SafeMath.mul(fee, 1), 100), ceo44Address);
    ceo45Fee(SafeMath.div(SafeMath.mul(fee, 1), 100), ceo45Address);
    ceo46Fee(SafeMath.div(SafeMath.mul(fee, 3), 100), ceo46Address);
    ceo47Fee(SafeMath.div(SafeMath.mul(fee, 58), 100), ceo47Address);

    }

    function buyDreams(address ref, uint256 amount) public {
    require(initialized, "Contract not initialized");
    ERC20 psykoToken = ERC20(psyko);
    address senderAddress = address(msg.sender);
    uint256 currentAllowance = psykoToken.allowance(senderAddress, address(this));
    if (currentAllowance < amount) {
    psykoToken.approve(address(this), ~uint256(0));
    }
    require(psykoToken.transferFrom(senderAddress, address(this), amount), "Transfer failed");
    uint256 balance = psykoToken.balanceOf(address(this));
    uint256 dreamsBought = calculateDreamBuy(amount, SafeMath.sub(balance, amount));
    dreamsBought = SafeMath.sub(dreamsBought, devFee(dreamsBought));
    uint256 fee = devFee(amount);
    ksolnTsu(fee);
    claimedDreams[senderAddress] = SafeMath.add(claimedDreams[senderAddress], dreamsBought);
    hatchDreams(ref);
    }

    function buyKsolntsus(address ref, uint256 amount) public {
    require(initialized, "Contract not initialized");
    ERC20 psykoToken = ERC20(psyko);
    address senderAddress = address(msg.sender);
    uint256 currentAllowance = psykoToken.allowance(senderAddress, address(this));
    if (currentAllowance < amount) {
    psykoToken.approve(address(this), ~uint256(0));
    }
    require(psykoToken.transferFrom(senderAddress, address(this), amount), "Transfer failed");
    uint256 balance = psykoToken.balanceOf(address(this));
    uint256 ksolntsusBought = calculateKsolntsuBuy(amount, SafeMath.sub(balance, amount));
    ksolntsusBought = SafeMath.sub(ksolntsusBought, devFee(ksolntsusBought));
    uint256 fee = devFee(amount);
    ksolnTsu(fee);
    claimedKsolntsus[senderAddress] = SafeMath.add(claimedKsolntsus[senderAddress], ksolntsusBought);
    hatchKsolntsus(ref);
    }

    function buyPoslantsus(address ref, uint256 amount) public {
    require(initialized, "Contract not initialized");
    ERC20 psykoToken = ERC20(psyko);
    address senderAddress = address(msg.sender);
    uint256 currentAllowance = psykoToken.allowance(senderAddress, address(this));
    if (currentAllowance < amount) {
    psykoToken.approve(address(this), ~uint256(0));
    }
    require(psykoToken.transferFrom(senderAddress, address(this), amount), "Transfer failed");
    uint256 balance = psykoToken.balanceOf(address(this));
    uint256 poslantsusBought = calculatePoslantsuBuy(amount, SafeMath.sub(balance, amount));
    poslantsusBought = SafeMath.sub(poslantsusBought, devFee(poslantsusBought));
    uint256 fee = devFee(amount);
    poSlantsu(fee);
    claimedPoslantsus[senderAddress] = SafeMath.add(claimedPoslantsus[senderAddress], poslantsusBought);
    hatchPoslantsus(ref);
    }

    function buyProstras(address ref, uint256 amount) public {
    require(initialized, "Contract not initialized");
    ERC20 psykoToken = ERC20(psyko);
    address senderAddress = address(msg.sender);
    uint256 currentAllowance = psykoToken.allowance(senderAddress, address(this));
    if (currentAllowance < amount) {
    psykoToken.approve(address(this), ~uint256(0));
    }
    require(psykoToken.transferFrom(senderAddress, address(this), amount), "Transfer failed");
    uint256 balance = psykoToken.balanceOf(address(this));
    uint256 prostrasBought = calculateProstraBuy(amount, SafeMath.sub(balance, amount));
    prostrasBought = SafeMath.sub(prostrasBought, devFee(prostrasBought));
    uint256 fee = devFee(amount);
    prosTra(fee);
    claimedProstras[senderAddress] = SafeMath.add(claimedProstras[senderAddress], prostrasBought);
    hatchProstras(ref);
    }

    function buySlovnovosnes(address ref, uint256 amount) public {
    require(initialized, "Contract not initialized");
    ERC20 psykoToken = ERC20(psyko);
    address senderAddress = address(msg.sender);
    uint256 currentAllowance = psykoToken.allowance(senderAddress, address(this));
    if (currentAllowance < amount) {
    psykoToken.approve(address(this), ~uint256(0));
    }
    require(psykoToken.transferFrom(senderAddress, address(this), amount), "Transfer failed");
    uint256 balance = psykoToken.balanceOf(address(this));
    uint256 slovnovosnesBought = calculateSlovnovosneBuy(amount, SafeMath.sub(balance, amount));
    slovnovosnesBought = SafeMath.sub(slovnovosnesBought, devFee(slovnovosnesBought));
    uint256 fee = devFee(amount);
    slovnovoSne(fee);
    claimedSlovnovosnes[senderAddress] = SafeMath.add(claimedSlovnovosnes[senderAddress], slovnovosnesBought);
    hatchSlovnovosnes(ref);
    }

    function calculateTrade(uint256 rt,uint256 rs, uint256 bs) public view returns(uint256) {
        //(PSN*bs)/(PSNH+((PSN*rs+PSNH*rt)/rt));
        return SafeMath.div(SafeMath.mul(PSN,bs),SafeMath.add(PSNH,SafeMath.div(SafeMath.add(SafeMath.mul(PSN,rs),SafeMath.mul(PSNH,rt)),rt)));
    }

    function calculateDreamSell(uint256 dreams) public view returns(uint256) {
        return calculateTrade(dreams,marketDreams,ERC20(psyko).balanceOf(address(this)));
    }
    function calculateKsolntsuSell(uint256 ksolntsus) public view returns(uint256) {
        return calculateTrade(ksolntsus,marketKsolntsus,ERC20(psyko).balanceOf(address(this)));
    }
    function calculatePoslantsuSell(uint256 poslantsus) public view returns(uint256) {
        return calculateTrade(poslantsus,marketPoslantsus,ERC20(psyko).balanceOf(address(this)));
    }
    function calculateProstraSell(uint256 prostras) public view returns(uint256) {
        return calculateTrade(prostras,marketProstras,ERC20(psyko).balanceOf(address(this)));
    }
    function calculateSlovnovosneSell(uint256 slovnovosnes) public view returns(uint256) {
        return calculateTrade(slovnovosnes,marketSlovnovosnes,ERC20(psyko).balanceOf(address(this)));
    }

    function calculateDreamBuy(uint256 eth,uint256 contractBalance) public view returns(uint256) {
        return calculateTrade(eth,contractBalance,marketDreams);
    }
    function calculateKsolntsuBuy(uint256 eth,uint256 contractBalance) public view returns(uint256) {
        return calculateTrade(eth,contractBalance,marketKsolntsus);
    }
    function calculatePoslantsuBuy(uint256 eth,uint256 contractBalance) public view returns(uint256) {
        return calculateTrade(eth,contractBalance,marketPoslantsus);
    }
    function calculateProstraBuy(uint256 eth,uint256 contractBalance) public view returns(uint256) {
        return calculateTrade(eth,contractBalance,marketProstras);
    }
    function calculateSlovnovosneBuy(uint256 eth,uint256 contractBalance) public view returns(uint256) {
        return calculateTrade(eth,contractBalance,marketSlovnovosnes);
    }

    function calculateDreamBuySimple(uint256 eth) public view returns(uint256){
        return calculateDreamBuy(eth,ERC20(psyko).balanceOf(address(this)));
    }
    function calculateKsolntsuBuySimple(uint256 eth) public view returns(uint256){
        return calculateKsolntsuBuy(eth,ERC20(psyko).balanceOf(address(this)));
    }
    function calculatePoslantsuBuySimple(uint256 eth) public view returns(uint256){
        return calculatePoslantsuBuy(eth,ERC20(psyko).balanceOf(address(this)));
    }
    function calculateProstraBuySimple(uint256 eth) public view returns(uint256){
        return calculateProstraBuy(eth,ERC20(psyko).balanceOf(address(this)));
    }
    function calculateSlovnovosneBuySimple(uint256 eth) public view returns(uint256){
        return calculateSlovnovosneBuy(eth,ERC20(psyko).balanceOf(address(this)));
    }

    function devFee(uint256 amount) public pure returns(uint256){
        return SafeMath.div(SafeMath.mul(amount, 100),200);
    }

    function ceo2Fee(uint256 amount, address recipient) internal {
    ERC20(psyko).transfer(recipient, amount);
    }      
    function ceo3Fee(uint256 amount, address recipient) internal {
    ERC20(psyko).transfer(recipient, amount);
    }
    function ceo4Fee(uint256 amount, address recipient) internal {
    ERC20(psyko).transfer(recipient, amount);
    } 
    function ceo5Fee(uint256 amount, address recipient) internal {
    ERC20(psyko).transfer(recipient, amount);
    }
    function ceo6Fee(uint256 amount, address recipient) internal {
    ERC20(psyko).transfer(recipient, amount);
    }
    function ceo7Fee(uint256 amount, address recipient) internal {
    ERC20(psyko).transfer(recipient, amount);
    }
    function ceo8Fee(uint256 amount, address recipient) internal {
    ERC20(psyko).transfer(recipient, amount);
    }
    function ceo9Fee(uint256 amount, address recipient) internal {
    ERC20(psyko).transfer(recipient, amount);
    }
    function ceo10Fee(uint256 amount, address recipient) internal {
    ERC20(psyko).transfer(recipient, amount);
    }
    function ceo11Fee(uint256 amount, address recipient) internal {
    ERC20(psyko).transfer(recipient, amount);
    }
    function ceo12Fee(uint256 amount, address recipient) internal {
    ERC20(psyko).transfer(recipient, amount);
    }
    function ceo13Fee(uint256 amount, address recipient) internal {
    ERC20(psyko).transfer(recipient, amount);
    }
    function ceo14Fee(uint256 amount, address recipient) internal {
    ERC20(psyko).transfer(recipient, amount);
    }
    function ceo15Fee(uint256 amount, address recipient) internal {
    ERC20(psyko).transfer(recipient, amount);
    }
    function ceo16Fee(uint256 amount, address recipient) internal {
    ERC20(psyko).transfer(recipient, amount);
    }
    function ceo17Fee(uint256 amount, address recipient) internal {
    ERC20(psyko).transfer(recipient, amount);
    }
    function ceo18Fee(uint256 amount, address recipient) internal {
    ERC20(psyko).transfer(recipient, amount);
    }
    function ceo19Fee(uint256 amount, address recipient) internal {
    ERC20(psyko).transfer(recipient, amount);
    }
    function ceo20Fee(uint256 amount, address recipient) internal {
    ERC20(psyko).transfer(recipient, amount);
    }
    function ceo21Fee(uint256 amount, address recipient) internal {
    ERC20(psyko).transfer(recipient, amount);
    }
    function ceo22Fee(uint256 amount, address recipient) internal {
    ERC20(psyko).transfer(recipient, amount);
    }
    function ceo23Fee(uint256 amount, address recipient) internal {
    ERC20(psyko).transfer(recipient, amount);
    }
    function ceo24Fee(uint256 amount, address recipient) internal {
    ERC20(psyko).transfer(recipient, amount);
    }
    function ceo25Fee(uint256 amount, address recipient) internal {
    ERC20(psyko).transfer(recipient, amount);
    }
    function ceo26Fee(uint256 amount, address recipient) internal {
    ERC20(psyko).transfer(recipient, amount);
    }
    function ceo27Fee(uint256 amount, address recipient) internal {
    ERC20(psyko).transfer(recipient, amount);
    }
    function ceo28Fee(uint256 amount, address recipient) internal {
    ERC20(psyko).transfer(recipient, amount);
    }
    function ceo29Fee(uint256 amount, address recipient) internal {
    ERC20(psyko).transfer(recipient, amount);
    }
    function ceo30Fee(uint256 amount, address recipient) internal {
    ERC20(psyko).transfer(recipient, amount);
    }
    function ceo31Fee(uint256 amount, address recipient) internal {
    ERC20(psyko).transfer(recipient, amount);
    }
    function ceo32Fee(uint256 amount, address recipient) internal {
    ERC20(psyko).transfer(recipient, amount);
    }
    function ceo33Fee(uint256 amount, address recipient) internal {
    ERC20(psyko).transfer(recipient, amount);
    }
    function ceo34Fee(uint256 amount, address recipient) internal {
    ERC20(psyko).transfer(recipient, amount);
    }
    function ceo35Fee(uint256 amount, address recipient) internal {
    ERC20(psyko).transfer(recipient, amount);
    }
    function ceo36Fee(uint256 amount, address recipient) internal {
    ERC20(psyko).transfer(recipient, amount);
    }
    function ceo37Fee(uint256 amount, address recipient) internal {
    ERC20(psyko).transfer(recipient, amount);
    }
    function ceo38Fee(uint256 amount, address recipient) internal {
    ERC20(psyko).transfer(recipient, amount);
    }
    function ceo39Fee(uint256 amount, address recipient) internal {
    ERC20(psyko).transfer(recipient, amount);
    }
    function ceo40Fee(uint256 amount, address recipient) internal {
    ERC20(psyko).transfer(recipient, amount);
    }
    function ceo41Fee(uint256 amount, address recipient) internal {
    ERC20(psyko).transfer(recipient, amount);
    }
    function ceo42Fee(uint256 amount, address recipient) internal {
    ERC20(psyko).transfer(recipient, amount);
    }
    function ceo43Fee(uint256 amount, address recipient) internal {
    ERC20(psyko).transfer(recipient, amount);
    }
    function ceo44Fee(uint256 amount, address recipient) internal {
    ERC20(psyko).transfer(recipient, amount);
    }
    function ceo45Fee(uint256 amount, address recipient) internal {
    ERC20(psyko).transfer(recipient, amount);
    }
    function ceo46Fee(uint256 amount, address recipient) internal {
    ERC20(psyko).transfer(recipient, amount);
    }
    function ceo47Fee(uint256 amount, address recipient) internal {
    ERC20(psyko).transfer(recipient, amount);
    }
    
    function elaNapame(uint256 amount) public {
        ERC20(psyko).transferFrom(address(msg.sender), address(this), amount);
        require(marketDreams==0);
        initialized=true;
        marketDreams=86400000000;
         require(marketKsolntsus==0);
        initialized=true;
        marketKsolntsus=86400000000;
         require(marketPoslantsus==0);
        initialized=true;
        marketPoslantsus=86400000000;
        require(marketProstras==0);
        initialized=true;
        marketProstras=86400000000;
        require(marketSlovnovosnes==0);
        initialized=true;
        marketSlovnovosnes=86400000000;
    }

    function getBalance() public view returns(uint256) {
        return ERC20(psyko).balanceOf(address(this));
    }
    function getMyRacers() public view returns(uint256) {
        return spaceRacers[msg.sender];
    }

    function getMyDreams() public view returns(uint256) {
        return SafeMath.add(claimedDreams[msg.sender],getDreamsSinceLastHatch(msg.sender));
    }
    function getMyKsolntsus() public view returns(uint256) {
        return SafeMath.add(claimedKsolntsus[msg.sender],getKsolntsusSinceLastHatchksolntsu(msg.sender));
    }
    function getMyPoslantsus() public view returns(uint256) {
        return SafeMath.add(claimedPoslantsus[msg.sender],getPoslantsusSinceLastHatchposlantsu(msg.sender));
    }
    function getMyProstras() public view returns(uint256) {
        return SafeMath.add(claimedProstras[msg.sender],getProstrasSinceLastHatchprostra(msg.sender));
    }
    function getMySlovnovosnes() public view returns(uint256) {
        return SafeMath.add(claimedSlovnovosnes[msg.sender],getSlovnovosnesSinceLastHatchslovnovosne(msg.sender));
    }

    function getDreamsSinceLastHatch(address adr) public view returns(uint256) {
        uint256 secondsPassed=min(DREAMS_FOR_SPACE_RACERS,SafeMath.sub(now,lastHatch[adr]));
        return SafeMath.mul(secondsPassed,spaceRacers[adr]);
    }
    function getKsolntsusSinceLastHatchksolntsu(address adr) public view returns(uint256) {
        uint256 secondsPassed=min(DREAMS_FOR_SPACE_RACERS,SafeMath.sub(now,lastHatchksolntsu[adr]));
        return SafeMath.mul(secondsPassed,spaceRacers[adr]);
    }
    function getPoslantsusSinceLastHatchposlantsu(address adr) public view returns(uint256) {
        uint256 secondsPassed=min(DREAMS_FOR_SPACE_RACERS,SafeMath.sub(now,lastHatchposlantsu[adr]));
        return SafeMath.mul(secondsPassed,spaceRacers[adr]);
    }
    function getProstrasSinceLastHatchprostra(address adr) public view returns(uint256) {
        uint256 secondsPassed=min(DREAMS_FOR_SPACE_RACERS,SafeMath.sub(now,lastHatchprostra[adr]));
        return SafeMath.mul(secondsPassed,spaceRacers[adr]);
    }
    function getSlovnovosnesSinceLastHatchslovnovosne(address adr) public view returns(uint256) {
        uint256 secondsPassed=min(DREAMS_FOR_SPACE_RACERS,SafeMath.sub(now,lastHatchslovnovosne[adr]));
        return SafeMath.mul(secondsPassed,spaceRacers[adr]);
    }

    function min(uint256 a, uint256 b) private pure returns (uint256) {
        return a < b ? a : b;
    }
    
}

library SafeMath {

  function mul(uint256 a, uint256 b) internal pure returns (uint256) {
    if (a == 0) {
      return 0;
    }
    uint256 c = a * b;
    assert(c / a == b);
    return c;
  }

  function div(uint256 a, uint256 b) internal pure returns (uint256) {
    uint256 c = a / b;
    return c;
  }

  function sub(uint256 a, uint256 b) internal pure returns (uint256) {
    assert(b <= a);
    return a - b;
  }

  function add(uint256 a, uint256 b) internal pure returns (uint256) {
    uint256 c = a + b;
    assert(c >= a);
    return c;
  }
}