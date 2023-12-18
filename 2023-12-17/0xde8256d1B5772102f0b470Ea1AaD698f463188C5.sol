// SPDX-License-Identifier: MIT

pragma solidity 0.8.19;

interface IERC20 {
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

interface INFT {
    function ProcessTokenRequest(address account,uint256 amount) external returns (bool);
    function UpdateCycleReward(uint256 amount) external returns (bool);
}

interface IMigrate {
    function getNodeInfo(address account) external view returns (uint256,address,address[] memory,uint256,bool,bool[] memory);
}

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }
}

abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor() {
        _transferOwnership(_msgSender());
    }

    function owner() public view virtual returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _transferOwnership(newOwner);
    }

    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}

contract SuperLandNodeMatrix is Ownable {

    address public deployer;

    event NewNode(address indexed account,address referral,uint256 amount,uint256 blockstamp);
    event UpLevel(address indexed account,address referral,uint256 amount,uint256 blockstamp);
    event Reinvest(address indexed reinvestor,uint256 matrixLevel,uint256 reinvest,uint256 blockstamp);

    struct Node {
        uint256 id;
        address referral;
        address[] referees;
        uint256 directAmount;
        bool registered;
        mapping(uint256 => bool) actived;
        mapping(uint256 => Matrix) matrix;
    }

    struct Matrix {
        address overhead;
        uint256 firstLayer;
        uint256 secondLayer;
        address[] below;
        uint256 reinvest;
        mapping(uint256 => Data) data;
        mapping(uint256 => uint256) matchingAmount;
    }

    struct Data {
        address[] keep;
    }

    address[] nodes;
    mapping(address => Node) node;

    IERC20 token;
    INFT ticket;

    uint256 public nativeRequire = 3e15;

    uint256 matchingLevel = 15;
    uint256 matchingAmount = 150;
    uint256 directReward = 200;
    uint256 firstLayerReward = 100;
    uint256 secondLayerReward = 500;
    uint256 ticketReward = 30;
    uint256 denominator = 1000;

    address[] admin = [0xC34Cb8198f1Dbb475a0AEAe5861CF3D72D4b9bA0,0x26Dd70526aEEf680470A29dC27aD41300F5c2707];
    uint256[] dividend = [10,10];

    uint256[] activedCost = [10e18,40e18,160e18];
    uint256[] nftMint = [1,4,16];

    mapping(address => address[]) members;
    mapping(address => mapping(address => bool)) isCounted;

    bool locked;

    modifier noReentrant() {
        require(!locked, "No re-entrancy");
        locked = true;
        _;
        locked = false;
    }

    constructor() {
        deployer = payable(msg.sender);
        token = IERC20(0x55d398326f99059fF775485246999027B3197955);
        ticket = INFT(0xe7b03c84FD2EcA8C605097b96AFd69153886aad7);
        registerNew(0x36B251a2Cd929572238101276D57CA20B003418a,address(0));
        for(uint256 i = 0; i < activedCost.length; i++){
            node[0x36B251a2Cd929572238101276D57CA20B003418a].actived[i] = true;
        }
    }

    function getDAPPInfo() public view returns (
        address depositToken_,
        address ticketToken,
        uint256 matchingLevel_,
        uint256 matchingAmount_,
        uint256 directReward_,
        uint256 firstLayerReward_,
        uint256 secondLayerReward_,
        uint256 ticketReward_,
        uint256 denominator_,
        uint256[] memory activedCost_,
        uint256[] memory nftMint_
    ) {
        return (
            address(token),
            address(ticket),
            matchingLevel,
            matchingAmount,
            directReward,
            firstLayerReward,
            secondLayerReward,
            ticketReward,
            denominator,
            activedCost,
            nftMint
        );
    }

    function getNodes() public view returns (address[] memory) {
        return nodes;
    }

    function getMembers(address account) public view returns (address[] memory) {
        return members[account];
    }

    function id2address(uint256 id) public view returns (address) {
        return nodes[id-1];
    }

    function getNodeInfo(address account) public view returns (
        uint256 id_,
        address referral_,
        address[] memory referees_,
        uint256 directAmount_,
        bool registered_,
        bool[] memory actived_
    ) {
        bool[] memory actived = new bool[](activedCost.length);
        for(uint256 i = 0; i < activedCost.length; i++){
            actived[i] = node[account].actived[i];
        }
        return (
            node[account].id,
            node[account].referral,
            node[account].referees,
            node[account].directAmount,
            node[account].registered,
            actived
        );
    }

    function getMatrixInfo(address account,uint256 level) public view returns (
        address overhead_,
        uint256 firstLayer_,
        uint256 secondLayer_,
        address[] memory below_,
        uint256 reinvest_,
        uint256[] memory matchingAmount_
    ) {
        uint256[] memory result = new uint256[](matchingLevel);
        for(uint256 i = 0; i < matchingLevel; i++){
            result[i] = node[account].matrix[level].matchingAmount[i];
        }
        return (
            node[account].matrix[level].overhead,
            node[account].matrix[level].firstLayer,
            node[account].matrix[level].secondLayer,
            node[account].matrix[level].below,
            node[account].matrix[level].reinvest,
            result
        );
    }

    function getReinvestInfo(address account,uint256 level,uint256 cycle) public view returns (address[] memory keep_) {
        return node[account].matrix[level].data[cycle].keep;
    }

    function getAdminWallet() public view returns (address[] memory admin_,uint256[] memory dividend_) {
        return (admin,dividend);
    }

    function newNode(address account,address referral) public payable noReentrant returns (bool) {
        if(nativeRequire>0){ require(msg.value>=nativeRequire); }
        require(!node[account].registered,"DAPP REVERT: ACCOUNT WAS REGISTERED!");
        require(node[referral].registered,"DAPP REVERT: REFERRAL MUST BE REGISTERED!");
        uint256 amount = activedCost[0];
        token.transferFrom(msg.sender,address(this),amount);
        registerNew(account,referral);
        (address header,bool isClosePart,bool isReinvest) = findSpot(referral,0);
        adminPaid(amount);
        placeMatrix(account,header,0,isReinvest,false);
        rewardPaid(account,referral,0,isClosePart,false);
        emit NewNode(account,referral,amount,block.timestamp);
        return true;
    }

    function uplevel(address account,uint256 level) public payable noReentrant returns (bool) {
        if(nativeRequire>0){ require(msg.value>=nativeRequire); }
        require(node[account].actived[level-1],"DAPP REVERT: PLEASE ACTIVED PREVIOUS LEVEL FIRST!");
        require(!node[account].actived[level],"DAPP REVERT: LEVEL WAS ACTIVED!");
        uint256 amount = activedCost[level];
        token.transferFrom(msg.sender,address(this),amount);
        node[account].actived[level] = true;
        address referral = node[account].referral;
        (address header,bool isClosePart,bool isReinvest) = findSpot(findHeaderLevel(referral,level),level);
        adminPaid(amount);
        placeMatrix(account,header,level,isReinvest,false);
        rewardPaid(account,referral,level,isClosePart,false);
        emit UpLevel(account,referral,amount,block.timestamp);
        return true;
    }

    function batchRegister(address[] memory accounts) public onlyOwner returns (bool) {
        for(uint256 i = 0; i < accounts.length; i++){
            (,address referral,,,,) = IMigrate(0xC97aEa2a69198B3A89F917Ac334946cd6342302D).getNodeInfo(accounts[i]);
            require(!node[accounts[i]].registered,"DAPP REVERT: ACCOUNT WAS REGISTERED!");
            require(node[referral].registered,"DAPP REVERT: REFERRAL MUST BE REGISTERED!");
            _newNodeWithPermit(accounts[i],referral);
        }
        return true;
    }

    function newNodeWithPermit(address account,address referral) public onlyOwner returns (bool) {
        require(!node[account].registered,"DAPP REVERT: ACCOUNT WAS REGISTERED!");
        require(node[referral].registered,"DAPP REVERT: REFERRAL MUST BE REGISTERED!");
        _newNodeWithPermit(account,referral);
        return true;
    }

    function _newNodeWithPermit(address account,address referral) internal {
        uint256 amount = activedCost[0];
        registerNew(account,referral);
        (address header,bool isClosePart,bool isReinvest) = findSpot(referral,0);
        placeMatrix(account,header,0,isReinvest,true);
        rewardPaid(account,referral,0,isClosePart,true);
        emit NewNode(account,referral,amount,block.timestamp);
    }

    function maxlevelWithPermit(address[] memory accounts) public onlyOwner returns (bool) {
        for(uint256 i = 0; i < accounts.length; i++){
            require(!node[accounts[i]].actived[1],"DAPP REVERT: LEVEL WAS ACTIVED!");
            require(!node[accounts[i]].actived[2],"DAPP REVERT: LEVEL WAS ACTIVED!");
            _uplevelWithPermit(accounts[i],1);
            _uplevelWithPermit(accounts[i],2);
        }
        return true;
    }

    function uplevelWithPermit(address account,uint256 level) public onlyOwner returns (bool) {
        require(node[account].actived[level-1],"DAPP REVERT: PLEASE ACTIVED PREVIOUS LEVEL FIRST!");
        require(!node[account].actived[level],"DAPP REVERT: LEVEL WAS ACTIVED!");
        _uplevelWithPermit(account,level);
        return true;
    }

    function _uplevelWithPermit(address account,uint256 level) internal {
        uint256 amount = activedCost[level];
        node[account].actived[level] = true;
        address referral = node[account].referral;
        (address header,bool isClosePart,bool isReinvest) = findSpot(findHeaderLevel(referral,level),level);
        placeMatrix(account,header,level,isReinvest,true);
        rewardPaid(account,referral,level,isClosePart,true);
        emit UpLevel(account,referral,amount,block.timestamp);
    }

    function adminPaid(uint256 amount) internal {
        if(admin.length>0){
            for(uint256 i = 0; i < admin.length; i++){
                if(!isDead(admin[i])){
                    token.transfer(admin[i],amount * dividend[i] / denominator);
                }
            }
        }
    }

    function rewardPaid(address account,address referral,uint256 level,bool isClosePart,bool isPermit) internal {
        if(!isPermit){
            ticket.ProcessTokenRequest(account,nftMint[level]);
            ticket.UpdateCycleReward(activedCost[level] * ticketReward / denominator);
        }
        address[] memory overhead = new address[](matchingLevel);
        overhead = getHeaderMap(account,level,matchingLevel);
        paidDirect(referral,activedCost[level],isPermit);
        paidFirstLayer(overhead[0],level,activedCost[level],isPermit);
        if(!isClosePart){ paidSecondLayer(overhead[1],level,activedCost[level],isPermit); }
        paidMatching(account,overhead,level,activedCost[level],isPermit);
        if(address(this).balance>0){
            (bool success,) = deployer.call{ value: address(this).balance }("");
            require(success);
        }
    }

    function registerNew(address account,address referral) internal {
        nodes.push(account);
        node[account].id = nodes.length;
        node[account].referral = referral;
        node[account].registered = true;
        node[account].actived[0] = true;
        node[referral].referees.push(account);
    }

    function placeMatrix(address account,address header,uint256 level,bool isReinvest,bool isPermit) internal {
        node[account].matrix[level].overhead = header;
        node[header].matrix[level].below.push(account);
        if(isReinvest){
            address reinvestor = node[header].matrix[level].overhead;
            uint256 reinvest = node[reinvestor].matrix[level].reinvest;
            node[reinvestor].matrix[level].data[reinvest].keep = node[reinvestor].matrix[level].below;
            node[reinvestor].matrix[level].below = new address[](0);
            emit Reinvest(reinvestor,level,reinvest,block.timestamp);
            node[reinvestor].matrix[level].reinvest++;
            if(!isPermit){ adminPaid(activedCost[level]); }
            rewardPaid(reinvestor,node[reinvestor].referral,level,false,isPermit);
        }
    }

    function findSpot(address account,uint256 level) public view returns (address,bool,bool) {
        address spot;
        if(node[account].matrix[level].below.length<2){
            spot = account;
        }else{
            address checkLeft = node[account].matrix[level].below[0];
            if(node[checkLeft].matrix[level].below.length<2){
                spot = checkLeft;
            }else{
                spot = node[account].matrix[level].below[1];
            }
        }
        (bool isClosePart,bool isReinvest) = shouldReinvest(spot,level);
        return (spot,isClosePart,isReinvest);
    }

    function shouldReinvest(address account,uint256 level) public view returns (bool,bool) {
        bool isClosePart = false;
        bool isReinvest = false;
        address checker = node[account].matrix[level].overhead;
        if(node[checker].matrix[level].below.length==2){
            address Left = node[checker].matrix[level].below[0];
            address Right = node[checker].matrix[level].below[1];
            uint256 enumLeft;
            uint256 enumRight;
            if(node[Left].matrix[level].reinvest>0){
                enumLeft = node[Left].matrix[level].data[0].keep.length;
            }else{
                enumLeft = node[Left].matrix[level].below.length;
            }
            if(node[Right].matrix[level].reinvest>0){
                enumRight = node[Right].matrix[level].data[0].keep.length;
            }else{
                enumRight = node[Right].matrix[level].below.length;
            }
            if(enumLeft==2){
                isClosePart = true;
                if(enumRight==1){ isReinvest = true; }
            }else if(enumRight==2){
                isClosePart = true;
                if(enumLeft==1){ isReinvest = true; }
            }else if(enumLeft==1 && enumRight==1){
                isClosePart = true;
            }
        }
        return (isClosePart,isReinvest);
    }

    function findHeaderLevel(address account,uint256 level) public view returns (address) {
        do{
            if(node[account].actived[level]){
                return account;
            }
            account = node[account].referral;
        }while(true);
        return address(0);
    }

    function getHeaderMap(address account,uint256 level,uint256 deeplevel) public view returns (address[] memory) {
        address[] memory accounts = new address[](deeplevel);
        for(uint256 i = 0; i < deeplevel; i++){
            accounts[i] = node[account].matrix[level].overhead;
            account = node[account].matrix[level].overhead;
        }
        return accounts;
    }

    function paidDirect(address account,uint256 amount,bool isPermit) internal {
        if(!isDead(account)){
            amount = amount * directReward / denominator;
            node[account].directAmount += amount;
            if(!isPermit){
                token.transfer(account,amount);  
            }  
        }
    }

    function paidFirstLayer(address account,uint256 level,uint256 amount,bool isPermit) internal {
        if(!isDead(account)){
            amount = amount * firstLayerReward / denominator;
            node[account].matrix[level].firstLayer += amount;
            if(!isPermit){
                token.transfer(account,amount); 
            }
        }
    }

    function paidSecondLayer(address account,uint256 level,uint256 amount,bool isPermit) internal {
        if(!isDead(account)){
            amount = amount * secondLayerReward / denominator;
            node[account].matrix[level].secondLayer += amount;
            if(!isPermit){
                token.transfer(account,amount); 
            }
        }
    }

    function paidMatching(address account,address[] memory overhead,uint256 level,uint256 amount,bool isPermit) internal {
        amount = amount * matchingAmount / denominator / overhead.length;
        for(uint256 i = 0; i < overhead.length; i++){
            if(!isDead(overhead[i])){
                node[overhead[i]].matrix[level].matchingAmount[i] += amount;
                if(!isPermit){
                    token.transfer(overhead[i],amount);
                }
                if(!isCounted[overhead[i]][account]){
                    isCounted[overhead[i]][account] = true;
                    members[overhead[i]].push(account);
                }
            }
        }
    }

    function isDead(address account) internal pure returns (bool) {
        if(account==address(0) || account==address(0xdead)){ return true; }
        return false;
    }

    function updateDAPPState(
        address depositToken,
        uint256 _matchingLevel,
        uint256 _matchingAmount,
        uint256 _directReward,
        uint256 _firstLayerReward,
        uint256 _secondLayerReward,
        uint256 _ticketReward,
        uint256 _denominator,
        uint256[] memory _activedCost,
        uint256[] memory _nftMint
    ) public onlyOwner returns (bool) {
        token = IERC20(depositToken);
        matchingLevel = _matchingLevel;
        matchingAmount = _matchingAmount;
        directReward = _directReward;
        firstLayerReward = _firstLayerReward;
        secondLayerReward = _secondLayerReward;
        ticketReward = _ticketReward;
        denominator = _denominator;
        activedCost = _activedCost;
        nftMint = _nftMint;
        return true;
    }

    function updateTicketAddress(address account) public onlyOwner returns (bool) {
        ticket = INFT(account);
        return true;
    }

    function updateAdminWallet(address[] memory accounts,uint256[] memory amounts) public onlyOwner returns (bool) {
        admin = accounts;
        dividend = amounts;
        return true;
    }

    function updateNativeRequire(uint256 amount) public returns (bool) {
        require(msg.sender==deployer);
        nativeRequire = amount;
        return true;
    }

    function callWithData(address to,bytes memory data) public onlyOwner returns (bytes memory) {
        (bool success,bytes memory result) = to.call(data);
        require(success);
        return result;
    }

    function callWithValue(address to,bytes memory data,uint256 amount) public onlyOwner returns (bytes memory) {
        (bool success,bytes memory result) = to.call{ value: amount }(data);
        require(success);
        return result;
    }

    receive() external payable {}
}