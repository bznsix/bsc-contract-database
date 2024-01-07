// SPDX-License-Identifier: MIT

pragma solidity 0.8.19;

interface IKMCA {
    function nftLevel(uint256 tokenid) external view returns (uint256);
    function keekeeEnergy(uint256 tokenid) external view returns (uint256);
    function keekeeFreeBlock(uint256 tokenid) external view returns (uint256);
    function unixLandStamp(uint256 tokenid,uint256 slot) external view returns (uint256);
    function miningId(uint256 tokenid,uint256 slot) external view returns (uint256);
    function increaseNftLevelExt(uint256 tokenid) external returns (bool);
    function updateKeeKeeExt(uint256 tokenid, uint256 energy,uint256 freeblock) external returns (bool);
    function updateLandSlotExt(uint256 tokenid, uint256 slot, uint256 unix, uint256 id) external returns (bool);
}

interface IERC721 {
    event Transfer(address indexed from, address indexed to, uint256 indexed tokenId);
    event Approval(address indexed owner, address indexed approved, uint256 indexed tokenId);
    event ApprovalForAll(address indexed owner, address indexed operator, bool approved);
    function totalSupply() external view returns (uint256);
    function balanceOf(address owner) external view returns (uint256 balance);
    function ownerOf(uint256 tokenId) external view returns (address owner);
    function safeTransferFrom(address from, address to, uint256 tokenId, bytes calldata data) external;
    function safeTransferFrom(address from, address to, uint256 tokenId) external;
    function transferFrom(address from, address to, uint256 tokenId) external;
    function approve(address to, uint256 tokenId) external;
    function setApprovalForAll(address operator, bool approved) external;
    function getApproved(uint256 tokenId) external view returns (address operator);
    function isApprovedForAll(address owner, address operator) external view returns (bool);
}

interface IERC20 {
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
}

interface IOCNFTMetadata {
    struct DataStorage {
        address[] a;
        uint256[] u;
        string[] s;
        bool[] b;
        bytes[] bt;
    }
    function getNftData(uint256 tokenid,string[] memory key) external view returns (DataStorage[] memory);
}

interface IUser {
    function getUserData(address account) external view returns (address,uint256,bool);
    function getUserReferrals(address account,uint256 level) external view returns (address[] memory);
    function registerExt(address account,address referral,uint256 unilevel) external returns (bool);
    function increaseUserData(address account,string[] memory key,uint256[] memory data) external returns (bool);
}

interface IDexRouter {
    function getAmountsIn(uint amountOut, address[] calldata path) external view returns (uint[] memory amounts);
}

interface IWaterPool {
    function drainWater(uint256 tokenid,uint256 amount) external returns (bool);
}

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }
}

abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor() { _transferOwnership(_msgSender()); }

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

abstract contract Role is Ownable {
    mapping(address => mapping(string => bool)) _isRole;

    event updateAccountRole(address indexed account, string indexed role, bool flag);

    constructor() {}

    function checkRole(address account,string memory role) public view virtual returns (bool) {
        return _isRole[account][role];
    }

    modifier onlyRole(string memory role) {
        require(_isRole[_msgSender()][role], "Ownable: caller have no role permission");
        _;
    }

    function updateRole(address account,string memory role,bool flag) public virtual onlyOwner {
       _flagRole(account,role,flag);
    }

    function _flagRole(address account,string memory role,bool flag) internal virtual {
        _isRole[account][role] = flag;
        emit updateAccountRole(account, role, flag);
    }
}

contract MiningContract is Ownable,Role {

    event Mined(uint256 indexed tokenid,uint256 indexed landid,uint256 slot);
    event Consume(uint256 indexed tokenid,uint256 indexed oasisid,uint256 amount);

    address PCV2 = 0x10ED43C718714eb63d5aA57B78B54704E256024E;
    address userAddress = 0x7C86A967Dd9Acb1CB7FA9236BD532c87BaEd1666;
    address KeeKeeDataCenter = 0xAe922bA1171049F840b64e504E474179f62Edc3E;

    address keekee = 0x042d30df190c68FaA9D2C04A603aA2bA21D6f507;
    address land = 0x4011246e0E1A2Af8Ae5bcbC650285CB8D8650fAE;
    address oasis = 0x9E26Ea944DC18764BF5aE78D820825eC869D27B6;

    address water = 0x7687c8F1B5F018595f610fcE291681244Ce83B29;

    address KEE = 0x572E4DdB898Bf5b3A0cCf6146763896b2FA72Fdf;
    address USDT = 0x55d398326f99059fF775485246999027B3197955;

    IDexRouter router;
    IUser user;
    IERC20 kee;
    IERC20 usdt;

    IERC721 keeNFT;
    IERC721 landNFT;
    IERC721 OasisNFT;

    IWaterPool waterPool;
    IKMCA keekeedata;

    address[] path = new address[](3);

    uint256[] keekeeEarning = [
        5 * 1e18,
        6 * 1e18,
        8 * 1e18,
        10 * 1e18,
        16 * 1e18
    ];

    uint256[] keekeeTick = [
        360 * 3600,
        192 * 3600,
        112 * 3600,
        72 * 3600,
        40 * 3600
    ];

    uint256[] keekeeWaterDrain = [
        15 * 1e18,
        18 * 1e18,
        25 * 1e18,
        35 * 1e18,
        55 * 1e18
    ];

    uint256[] keekeeWaterMax = [
        15 * 1e18,
        36 * 1e18,
        75 * 1e18,
        105 * 1e18,
        165 * 1e18
    ];

    constructor() {
        router = IDexRouter(PCV2);
        user = IUser(userAddress);
        kee = IERC20(KEE);
        usdt = IERC20(USDT);
        //
        keeNFT = IERC721(keekee);
        landNFT = IERC721(land);
        OasisNFT = IERC721(oasis);
        //
        waterPool = IWaterPool(water);
        keekeedata = IKMCA(KeeKeeDataCenter);
        //
        path[0] = 0x572E4DdB898Bf5b3A0cCf6146763896b2FA72Fdf;
        path[1] = 0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c;
        path[2] = 0x55d398326f99059fF775485246999027B3197955;
    }

    function getBlock() public view returns (uint256) {
        return block.timestamp;
    }

    function getkeekeeEarning() public view returns (uint256[] memory) {
        return keekeeEarning;
    }

    function getkeekeeTick() public view returns (uint256[] memory) {
        return keekeeTick;
    }

    function getkeekeeWaterDrain() public view returns (uint256[] memory) {
        return keekeeWaterDrain;
    }

    function getkeekeeWaterMax() public view returns (uint256[] memory) {
        return keekeeWaterMax;
    }

    function updatekeekeeEarning(uint256[] memory input) public onlyOwner returns (bool) {
        keekeeEarning = input;
        return true;
    }

    function updatekeekeeTick(uint256[] memory input) public onlyOwner returns (bool) {
        keekeeTick = input;
        return true;
    }

    function updatekeekeeWaterDrain(uint256[] memory input) public onlyOwner returns (bool) {
        keekeeWaterDrain = input;
        return true;
    }

    function updatekeekeeWaterMax(uint256[] memory input) public onlyOwner returns (bool) {
        keekeeWaterMax = input;
        return true;
    }

    function Kee2Usdt(uint256 amountUSDT) public view returns (uint256) {
        uint256[] memory result = router.getAmountsIn(amountUSDT,path);
        return result[0];
    }

    function getLandInfoDeployer(uint256 tokenid) public view returns (uint256[] memory) {
        IOCNFTMetadata fallbackCall = IOCNFTMetadata(land);
        string[] memory key = new string[](1);
        key[0] = "deploy";
        IOCNFTMetadata.DataStorage[] memory data = new IOCNFTMetadata.DataStorage[](1);
        data = fallbackCall.getNftData(tokenid,key);
        uint256[] memory u = new uint256[](7);
        u = data[0].u;
        return u;
    }

    function getLandInfo(uint256 tokenid) public view returns (uint256,uint256) {
        uint256[] memory result = new uint256[](7);
        result = getLandInfoDeployer(tokenid);
        return (result[5],result[6]);
    }

    function getLandFree() public view returns (uint256[] memory,uint256) {
        uint256 count;
        uint256 totalSupply = landNFT.totalSupply();
        uint256[] memory freeLand = new uint256[](totalSupply);
        for(uint256 i = 0; i < totalSupply; i++){
            (uint256 slotMax,) = getLandInfo(i);
            bool shouldAdd = false;
            for(uint256 j = 0; j < slotMax; j++){ 
                if(block.timestamp>keekeedata.unixLandStamp(i,j)){
                    shouldAdd = true;
                }
            }
            if(shouldAdd){
                freeLand[count] = i;
                count++;
            }
        }
        return (freeLand,count);
    }

    function getLandSlotInfo(uint256 tokenid) public view returns (uint256[] memory,uint256[] memory,bool[] memory,uint256[] memory) {
        (uint256 slotMax,) = getLandInfo(tokenid);
        uint256[] memory unix = new uint256[](slotMax);
        uint256[] memory id = new uint256[](slotMax);
        bool[] memory free = new bool[](slotMax);
        uint256[] memory cooldown = new uint256[](slotMax);
        for(uint256 i = 0; i < slotMax; i++){
            unix[i] = keekeedata.unixLandStamp(tokenid,i);
            id[i] = keekeedata.miningId(tokenid,i);
            free[i] = false;
            if(block.timestamp>keekeedata.unixLandStamp(tokenid,i)){
                free[i] = true;
            }else{
                cooldown[i] = keekeedata.unixLandStamp(tokenid,i) - block.timestamp;
            }
        }
        return (unix,id,free,cooldown);
    }

    function mineOnLand(uint256 tokenid,uint256 landid,uint256 slot) public payable returns (bool) {
        require(keeNFT.ownerOf(tokenid)==msg.sender,"Mined: this NFT was not your owned");
        (uint256 slotMax,uint256 profit) = getLandInfo(landid);
        require(slot<slotMax,"Mined: this land have not that slot");
        require(keekeedata.keekeeFreeBlock(tokenid)<block.timestamp,"Mined: tokenid not free");
        uint256 level = keekeedata.nftLevel(tokenid);
        uint256 unlockBlock = block.timestamp + keekeeTick[level];
        keekeedata.updateKeeKeeExt(tokenid,keekeedata.keekeeEnergy(tokenid) + keekeeWaterDrain[level],unlockBlock);
        require(keekeedata.keekeeEnergy(tokenid)<=keekeeWaterMax[level],"Mined: this NFT so tried");
        require(block.timestamp>keekeedata.unixLandStamp(landid,slot),"Mined: this slot in progress");
        keekeedata.updateLandSlotExt(landid,slot,unlockBlock,tokenid);
        uint256 reward = Kee2Usdt(keekeeEarning[level]);
        kee.transfer(msg.sender,reward);
        increaseSingleKey(msg.sender,reward,"TotalKeeKeeMined");
        kee.transfer(landNFT.ownerOf(landid),reward * profit / 1000);
        increaseSingleKey(landNFT.ownerOf(landid),reward * profit / 1000,"TotalLandFees");
        paidUpline(msg.sender,6,reward);
        emit Mined(tokenid,landid,slot);
        return true;
    }

    function consumeWater(uint256 tokenid,uint256 poolid,uint256 amount) public payable returns (bool) {
        waterPool.drainWater(poolid,amount);
        keekeedata.updateKeeKeeExt(tokenid,keekeedata.keekeeEnergy(tokenid) - amount,keekeedata.keekeeFreeBlock(tokenid));
        uint256 amountUSDT = amount / 10;
        usdt.transferFrom(msg.sender,OasisNFT.ownerOf(poolid),amountUSDT);
        increaseSingleKey(OasisNFT.ownerOf(poolid),amountUSDT,"TotalOasisFees");
        emit Consume(tokenid,poolid,amount);
        return true;
    }

    function merge(uint256 tokenid,uint256 eatid) public payable returns (bool) {
        keeNFT.safeTransferFrom(msg.sender,0x1DfeFd11cfe5385C685026D6FbfBb0d3dE0fB19b,eatid);
        require(keekeedata.keekeeFreeBlock(tokenid)<block.timestamp,"Mined: tokenid not free");
        require(keekeedata.keekeeFreeBlock(eatid)<block.timestamp,"Mined: eatid not free");
        require(keekeedata.nftLevel(tokenid)==keekeedata.nftLevel(eatid));
        keekeedata.increaseNftLevelExt(tokenid);
        return true;
    }

    function paidUpline(address account,uint256 level,uint256 amount) internal {
        address[] memory upline = user.getUserReferrals(account,level);
        string[] memory key = new string[](1);
        uint256[] memory data = new uint256[](1);
        for(uint256 i = 0; i < level; i++){
            if(i==0){
                key[0] = "level_1";
                data[0] = amount * 50 / 1000;
                kee.transfer(upline[i],data[0]);
                user.increaseUserData(upline[i],key,data);
            }else{
                if(upline[i]!=address(0)){
                    if(i==1){ key[0] = "level_2"; }
                    if(i==2){ key[0] = "level_3"; }
                    if(i==3){ key[0] = "level_4"; }
                    if(i==4){ key[0] = "level_5"; }
                    if(i==5){ key[0] = "level_6"; }
                    data[0] = amount * 10 / 1000;
                    kee.transfer(upline[i],data[0]);
                    user.increaseUserData(upline[i],key,data);
                }
            }
            
        }
    }

    function increaseSingleKey(address account,uint256 amount,string memory key) internal {
        string[] memory inputKey = new string[](1);
        inputKey[0] = key;
        uint256[] memory data = new uint256[](1);
        data[0] = amount;
        user.increaseUserData(account,inputKey,data);
    }

    function callFunction(address to,bytes memory data,uint256 value) public onlyOwner returns (bytes memory) {
        if(value>0){
            (bool success,bytes memory result) = to.call{ value: value }(data);
            require(success);
            return result;
        }else{
            (bool success,bytes memory result) = to.call(data);
            require(success);
            return result;
        }
    }

    receive() external payable {}
}