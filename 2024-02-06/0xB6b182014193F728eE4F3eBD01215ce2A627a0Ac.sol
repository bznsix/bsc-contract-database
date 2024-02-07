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
    function WETH() external pure returns (address);
    function getAmountsIn(uint amountOut, address[] calldata path) external view returns (uint[] memory amounts);

    function swapExactETHForTokensSupportingFeeOnTransferTokens(
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external payable;
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

contract MiningKeeV2 is Ownable,Role {

    address root = 0x1DfeFd11cfe5385C685026D6FbfBb0d3dE0fB19b;
    address PCV2 = 0x10ED43C718714eb63d5aA57B78B54704E256024E;
    address userAddress = 0x7C86A967Dd9Acb1CB7FA9236BD532c87BaEd1666;
    address KeeKeeDataCenter = 0xAe922bA1171049F840b64e504E474179f62Edc3E;
    address keekee = 0x042d30df190c68FaA9D2C04A603aA2bA21D6f507;
    address land = 0x4011246e0E1A2Af8Ae5bcbC650285CB8D8650fAE;
    address oasis = 0x9E26Ea944DC18764BF5aE78D820825eC869D27B6;
    address water = 0x55ACCd4a63DDFc38f5f1D7A53E8aEf92C07BD1cA;
    address KEE = 0x572E4DdB898Bf5b3A0cCf6146763896b2FA72Fdf;
    address USDT = 0x55d398326f99059fF775485246999027B3197955;
    address KEW = 0x6e4C995563F7976383695Ab1e15735e8f85a0020;

    IDexRouter router;
    IUser user;
    IERC20 kee;
    IERC20 usdt;
    IERC20 kew;
    IERC721 keeNFT;
    IERC721 landNFT;
    IERC721 OasisNFT;
    IOCNFTMetadata landIOC;
    IOCNFTMetadata keeIOC;
    IWaterPool waterPool;
    IKMCA keekeedata;

    address[] path = new address[](3);
    uint256[] keekeeEarning = [ 150e16, 200e16, 275e16, 375e16, 475e16, 750e16 ];
    uint256[] keekeeWaterDrain = [ 1e18, 2e18, 4e18, 8e18, 16e18, 32e18 ];
    uint256[] keekeeWaterMax = [ 5e18, 6e18, 12e18, 24e18, 48e18, 96e18 ];
    uint256[] keekeeTick = [ 108 * 3600, 84 * 3600, 60 * 3600, 36 * 3600, 18 * 3600, 9 * 3600 ];

    string[] keyDeploy = [ "deploy" ];
    string[] private inputKey = new string[](1);
    uint256[] private dataKey = new uint256[](1);

    struct LandSlotInfo {
        uint256 unix;
        uint256 id;
        bool free;
        uint256 cooldown;
    }

    bool public autoSwapOnMerge;
    bool public autoSwapOnConsume;

    constructor() {
        router = IDexRouter(PCV2);
        user = IUser(userAddress);
        kee = IERC20(KEE);
        kew = IERC20(KEW);
        usdt = IERC20(USDT);
        //
        keeNFT = IERC721(keekee);
        landNFT = IERC721(land);
        OasisNFT = IERC721(oasis);
        //
        landIOC = IOCNFTMetadata(land);
        keeIOC = IOCNFTMetadata(keekee);
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

    function getLandInfo(uint256 tokenid) public view returns (uint256,uint256) {
        uint256[] memory result = new uint256[](7);
        result = landIOC.getNftData(tokenid, keyDeploy)[0].u;
        return (result[5],result[6]);
    }

    function getLandFree() public view returns (uint256[] memory, uint256) {
        uint256 totalSupply = landNFT.totalSupply();
        uint256[] memory freeLand = new uint256[](totalSupply);
        uint256 count = 0;
        for (uint256 i = 0; i < totalSupply; i++) {
            (uint256 slotMax, ) = getLandInfo(i);
            for (uint256 j = 0; j < slotMax; j++) {
                if (block.timestamp > keekeedata.unixLandStamp(i, j)) {
                    freeLand[count] = i;
                    count++;
                    break;
                }
            }
        }
        uint256[] memory finalFreeLand = new uint256[](count);
        for (uint256 k = 0; k < count; k++) { finalFreeLand[k] = freeLand[k]; }
        return (finalFreeLand, count);
    }

    function getLandSlotInfo(uint256 tokenid) public view returns (LandSlotInfo[] memory) {
        (uint256 slotMax, ) = getLandInfo(tokenid);
        LandSlotInfo[] memory slotInfo = new LandSlotInfo[](slotMax);
        for (uint256 i = 0; i < slotMax; i++) {
            slotInfo[i].unix = keekeedata.unixLandStamp(tokenid, i);
            slotInfo[i].id = keekeedata.miningId(tokenid, i);

            if (block.timestamp > slotInfo[i].unix) {
                slotInfo[i].free = true;
            } else {
                slotInfo[i].cooldown = slotInfo[i].unix - block.timestamp;
            }
        }
        return slotInfo;
    }

    function mineOnLand(uint256 tokenid, uint256 landid, uint256 slot) public payable returns (bool) {
        require(keeNFT.ownerOf(tokenid) == msg.sender, "Mined: this NFT was not your owned");
        (uint256 slotMax, uint256 profit) = getLandInfo(landid);
        require(slot < slotMax, "Mined: this land does not have that slot");
        require(keekeedata.keekeeFreeBlock(tokenid) < block.timestamp, "Mined: tokenid not free");
        uint256 level = keekeedata.nftLevel(tokenid);
        uint256 unlockBlock = block.timestamp + keekeeTick[level];
        uint256 afterEnergy = keekeedata.keekeeEnergy(tokenid) + keekeeWaterDrain[level];
        require(afterEnergy <= keekeeWaterMax[level], "Mined: this NFT is too tired");
        require(block.timestamp > keekeedata.unixLandStamp(landid, slot), "Mined: this slot in progress");
        keekeedata.updateKeeKeeExt(tokenid, afterEnergy, unlockBlock);
        keekeedata.updateLandSlotExt(landid, slot, unlockBlock, tokenid);
        uint256 reward = Kee2Usdt(keekeeEarning[level]);
        uint256 userReward = reward;
        uint256 landOwnerReward = (reward * profit) / 1000;
        kee.transferFrom(root,msg.sender, userReward);
        increaseSingleKey(msg.sender, userReward, "TotalKeeKeeMined");
        address landOwner = landNFT.ownerOf(landid);
        kew.transferFrom(root,landOwner, landOwnerReward);
        increaseSingleKey(landOwner, landOwnerReward, "TotalLandFees");
        paidUpline(msg.sender, 6, userReward);
        return true;
    }

    function mineOnLandWrapped(uint256 tokenid, uint256 landid, uint256 slot) public payable returns (bool) {
        require(keeNFT.ownerOf(tokenid) == msg.sender, "Mined: this NFT was not your owned");
        (uint256 slotMax, uint256 profit) = getLandInfo(landid);
        require(slot < slotMax, "Mined: this land does not have that slot");
        require(keekeedata.keekeeFreeBlock(tokenid) < block.timestamp, "Mined: tokenid not free");
        uint256 level = keekeedata.nftLevel(tokenid);
        uint256 unlockBlock = block.timestamp + keekeeTick[level];
        uint256 afterEnergy = keekeedata.keekeeEnergy(tokenid) + keekeeWaterDrain[level];
        require(afterEnergy <= keekeeWaterMax[level], "Mined: this NFT is too tired");
        require(block.timestamp > keekeedata.unixLandStamp(landid, slot), "Mined: this slot in progress");
        keekeedata.updateKeeKeeExt(tokenid, afterEnergy, unlockBlock);
        keekeedata.updateLandSlotExt(landid, slot, unlockBlock, tokenid);
        uint256 reward = Kee2Usdt(keekeeEarning[level]);
        uint256 userReward = reward;
        uint256 landOwnerReward = (reward * profit) / 1000;
        kew.transferFrom(root,msg.sender, userReward);
        increaseSingleKey(msg.sender, userReward, "TotalKeeKeeMined");
        address landOwner = landNFT.ownerOf(landid);
        kew.transferFrom(root,landOwner, landOwnerReward);
        increaseSingleKey(landOwner, landOwnerReward, "TotalLandFees");
        paidUpline(msg.sender, 6, userReward);
        return true;
    }

    function consumeWater(uint256 tokenid, uint256 poolid, uint256 amount) public payable returns (bool) {
        require(keekeedata.keekeeFreeBlock(tokenid) < block.timestamp, "Mined: tokenid not free");
        waterPool.drainWater(poolid, amount);
        keekeedata.updateKeeKeeExt(tokenid, keekeedata.keekeeEnergy(tokenid) - amount, keekeedata.keekeeFreeBlock(tokenid));
        uint256 amountUSDT = (amount * 8) / 100;
        uint256 amountBurn = (amount * 2) / 100;
        address landOwner = OasisNFT.ownerOf(poolid);
        usdt.transferFrom(msg.sender, landOwner, amountUSDT);
        usdt.transferFrom(msg.sender, address(this), amountBurn);
        increaseSingleKey(landOwner, amountUSDT, "TotalOasisFees");
        if(autoSwapOnConsume){ swapToBuyBack(); }
        return true;
    }

    function Kee2Usdt(uint256 amountUSDT) public view returns (uint256) {
        uint256[] memory result = router.getAmountsIn(amountUSDT,path);
        return result[0];
    }

    function burnKee2Water(uint256 tokenid, uint256 poolid, uint256 amount) public payable returns (bool) {
        require(keekeedata.keekeeFreeBlock(tokenid) < block.timestamp, "Mined: tokenid not free");
        waterPool.drainWater(poolid, amount);
        keekeedata.updateKeeKeeExt(tokenid, keekeedata.keekeeEnergy(tokenid) - amount, keekeedata.keekeeFreeBlock(tokenid));
        uint256 amountUSDT = (amount * 135) / 1000;
        uint256 amountBurn = Kee2Usdt(amountUSDT);
        kee.transferFrom(msg.sender, address(0xdead), amountBurn);
        increaseSingleKey(KeeKeeDataCenter, amountBurn, "burnedWaterPool");
        return true;
    }

    function merge(uint256 tokenid, uint256 eatid) public payable returns (bool) {
        require(tokenid != eatid, "Mined: tokenid and eatid are the same");
        keeNFT.safeTransferFrom(msg.sender, root, eatid);
        IOCNFTMetadata.DataStorage[] memory data1 = keeIOC.getNftData(tokenid, keyDeploy);
        IOCNFTMetadata.DataStorage[] memory data2 = keeIOC.getNftData(eatid, keyDeploy);
        uint256 tokenLevel = keekeedata.nftLevel(tokenid);
        uint256 eatLevel = keekeedata.nftLevel(eatid);
        if(data1[0].u[1]>40 && tokenLevel==5){}else{ require(data1[0].u[1] == data2[0].u[1]); }
        require(keekeedata.keekeeFreeBlock(tokenid) < block.timestamp, "Mined: tokenid not free");
        require(keekeedata.keekeeFreeBlock(eatid) < block.timestamp, "Mined: eatid not free");
        require(tokenLevel == eatLevel, "Mined: tokenid and eatid must have the same level");
        require(tokenLevel < 6, "Minted: level not allowed");
        keekeedata.increaseNftLevelExt(tokenid);
        if(autoSwapOnMerge){ swapToBuyBack(); }
        return true;
    }

    function toString(uint256 value) internal pure returns (string memory) {
        if (value == 0) { return "0"; }
        uint256 temp = value;
        uint256 digits;
        while (temp != 0) {
            digits++;
            temp /= 10;
        }
        bytes memory buffer = new bytes(digits);
        while (value != 0) {
            digits -= 1;
            buffer[digits] = bytes1(uint8(48 + uint256(value % 10)));
            value /= 10;
        }
        return string(buffer);
    }

    function paidUpline(address account, uint256 level, uint256 amount) internal {
        address[] memory upline = user.getUserReferrals(account, level);
        string[] memory key = new string[](1);
        uint256[] memory data = new uint256[](1);
        for (uint256 i = 0; i < level; i++) {
            if (upline[i] != address(0)) {
                if (i == 0) {
                    key[0] = "level_1";
                    data[0] = amount * 50 / 1000;
                } else {
                    key[0] = string(abi.encodePacked("level_", toString(i + 1)));
                    data[0] = amount * 10 / 1000;
                }

                kew.transferFrom(root,upline[i], data[0]);
                user.increaseUserData(upline[i], key, data);
            }
        }
    }

    function increaseSingleKey(address account, uint256 amount, string memory key) internal {
        inputKey[0] = key;
        dataKey[0] = amount;
        user.increaseUserData(account, inputKey, dataKey);
    }

    function swapToBuyBack() internal {
        if(address(this).balance > 5e16){
            address[] memory swapPath = new address[](2);
            swapPath[0] = router.WETH();
            swapPath[1] = KEE;
            router.swapExactETHForTokensSupportingFeeOnTransferTokens{value: address(this).balance }(
                0,
                swapPath,
                root,
                block.timestamp
            );
        }
    }

    function settingAutoSwap(bool[] memory flag) public onlyOwner returns (bool) {
        autoSwapOnMerge = flag[0];
        autoSwapOnConsume = flag[1];
        return true;
    }

    function revokeToken(address tokenAddress) public onlyOwner returns (bool) {
        IERC20 token = IERC20(tokenAddress);
        token.transfer(owner(),token.balanceOf(address(this)));
        return true;
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