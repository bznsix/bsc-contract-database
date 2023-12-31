// SPDX-License-Identifier: MIT

pragma solidity 0.8.19;

interface IERC20 {
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
}

interface INFT {
    function processTokenRequest(address account) external returns (bool);
    function deployNftData(
        string memory key,
        address[] memory a,
        uint256[] memory u,
        string[] memory s,
        bool[] memory b,
        bytes[] memory bt
    ) external returns (bool);
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

contract KeeKeeNFTMinter is Ownable {

    address PCV2 = 0x10ED43C718714eb63d5aA57B78B54704E256024E;
    address userAddress = 0x7C86A967Dd9Acb1CB7FA9236BD532c87BaEd1666;

    address KEE = 0x572E4DdB898Bf5b3A0cCf6146763896b2FA72Fdf;
    address USDT = 0x55d398326f99059fF775485246999027B3197955;

    IDexRouter router;
    IUser user;
    IERC20 kee;
    IERC20 usdt;

    address[] path = new address[](3);
    address[] operator = new address[](3);
    address[] nftAddress = new address[](3);

    uint256[] keekeeprice = [
        10 * 1e18,
        40 * 1e18,
        75 * 1e18
    ];

    uint256[] keekeeenum = [1,5,10];

    uint256 amountToTreasury = 870;
    uint256 amountToMarketing = 30;
    uint256 amountToReferral = 50;
    uint256 amountToMatching = 10;
    uint256 denominator = 1000;

    struct MiningLand {
        uint256 level;
        uint256 price;
        uint256 supply;
        uint256 slot;
        uint256 profit;
    }

    mapping(uint256 => MiningLand) miningland;

    struct OasisLand {
        uint256 level;
        uint256 price;
        uint256 gen;
        uint256 cap;
        uint256 profit;
    }

    mapping(uint256 => OasisLand) oasisland;

    bool locked;
    modifier noReentrant() {
        require(!locked, "No re-entrancy");
        locked = true;
        _;
        locked = false;
    }

    mapping(uint256 => uint256) public totalMiningLandMinted;
    mapping(uint256 => uint256) public totalOasisLandMinted;
    mapping(address => bool) public isUnlock;

    constructor() {
        router = IDexRouter(PCV2);
        user = IUser(userAddress);
        kee = IERC20(KEE);
        usdt = IERC20(USDT);
        //
        path[0] = 0x572E4DdB898Bf5b3A0cCf6146763896b2FA72Fdf;
        path[1] = 0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c;
        path[2] = 0x55d398326f99059fF775485246999027B3197955;
        //
        operator = [
            0x6934174F2b1D3a9b43a7a82611cc7b70834B3Fdb,
            0x1DfeFd11cfe5385C685026D6FbfBb0d3dE0fB19b,
            0xFC28eA63d6A84FE038F32077850cfa9755352DB9
        ];
        nftAddress = [
            0x042d30df190c68FaA9D2C04A603aA2bA21D6f507,
            0x4011246e0E1A2Af8Ae5bcbC650285CB8D8650fAE,
            0x9E26Ea944DC18764BF5aE78D820825eC869D27B6
        ];
        //
        miningland[0] = MiningLand(1,1000_000_000 * 1e18,500,4,110);
        miningland[1] = MiningLand(2,1750_000_000 * 1e18,250,6,120);
        miningland[2] = MiningLand(3,3000_000_000 * 1e18,125,8,130);
        miningland[3] = MiningLand(4,5500_000_000 * 1e18,75,10,140);
        miningland[4] = MiningLand(5,10000_000_000 * 1e18,50,12,150);
        miningland[5] = MiningLand(6,17500_000_000 * 1e18,40,14,200);
        miningland[6] = MiningLand(7,30000_000_000 * 1e18,25,16,250);
        miningland[7] = MiningLand(8,50000_000_000 * 1e18,15,18,300);
        miningland[8] = MiningLand(9,85000_000_000 * 1e18,10,20,350);
        miningland[9] = MiningLand(10,150000_000_000 * 1e18,5,25,400);
        oasisland[0] = OasisLand(1,25 * 1e18,5 * 1e18,50 * 1e18,100);
        oasisland[1] = OasisLand(2,50 * 1e18,10 * 1e18,100 * 1e18,100);
        oasisland[2] = OasisLand(3,100 * 1e18,20 * 1e18,200 * 1e18,100);
        oasisland[3] = OasisLand(4,200 * 1e18,40 * 1e18,400 * 1e18,100);
        oasisland[4] = OasisLand(5,400 * 1e18,80 * 1e18,800 * 1e18,100);
        //
        totalMiningLandMinted[0] = 1;
        totalOasisLandMinted[0] = 1;
        isUnlock[address(0)] = true;
        isUnlock[address(0xFC28eA63d6A84FE038F32077850cfa9755352DB9)] = true;
    }

    function getOperators() public view returns (address[] memory operaters,address[] memory nfts) {
        return (operator,nftAddress);
    }

    function getMiningLandData(uint256 index) public view returns (MiningLand memory) {
        return miningland[index];
    }

    function getKeeKeePrice() public view returns (uint256[] memory,uint256[] memory) {
        return (keekeeprice,keekeeenum);
    }

    function getOasisLandData(uint256 index) public view returns (OasisLand memory) {
        return oasisland[index];
    }

    function Kee2Usdt(uint256 amountUSDT) public view returns (uint256) {
        uint256[] memory result = router.getAmountsIn(amountUSDT,path);
        return result[0];
    }

    function generateRandomNumber(uint256 a, uint256 b, uint256 ref) internal view returns (uint256) {
        require(b > a, "Invalid range");
        uint256 randomNumber = uint256(keccak256(abi.encodePacked(ref,block.prevrandao,block.timestamp,blockhash(block.number - 1))));
        return a + (randomNumber % (b - a + 1));
    }

    function register(address account,address referral) public payable noReentrant returns (bool) {
        (,,bool registered) = user.getUserData(account);
        (,,bool checkRef) = user.getUserData(referral);
        require(!registered,"Minter: this account was registered");
        require(checkRef,"Minter: referral was not registered");
        require(isUnlock[referral],"Minter: referral should mint at least 1 tx");
        user.registerExt(account,referral,6);
        sendValue();
        return true;
    }

    function mintKeeKee(address account,uint256 index) public payable noReentrant returns (bool) {
        isUnlock[account] = true;
        uint256 amount = Kee2Usdt(keekeeprice[index]);
        require(amount>0,"Minter: not found KeeKee set index data");
        kee.transferFrom(msg.sender,address(this),amount);
        paidUpline(account,6,amount);
        INFT nft = INFT(nftAddress[0]);
        for(uint256 i = 0; i < keekeeenum[index]; i++){
            uint256 randomNumber = generateRandomNumber(1,40,i);
            nft.processTokenRequest(account);
            uint256[] memory uintData = new uint256[](3);
            uintData[0] = block.timestamp;
            uintData[1] = randomNumber;
            uintData[2] = keekeeprice[index];
            nft.deployNftData(
                "deploy",
                new address[](0),
                uintData,
                new string[](0),
                new bool[](0),
                new bytes[](0)
            );
        }
        return true;
    }

    function mintMiningLand(address account,uint256 index) public payable noReentrant returns (bool) {
        isUnlock[account] = true;
        uint256 amount = miningland[index].price;
        require(amount>0,"Minter: not found Land index data");
        require(totalMiningLandMinted[index]<miningland[index].supply,"Minter: not found Land index data");
        totalMiningLandMinted[index]++;
        kee.transferFrom(msg.sender,address(this),amount);
        paidUpline(account,6,amount);
        INFT nft = INFT(nftAddress[1]);
        nft.processTokenRequest(account);
        uint256[] memory uintData = new uint256[](7);
        uintData[0] = block.timestamp;
        uintData[1] = miningland[index].level;
        uintData[2] = miningland[index].price;
        uintData[3] = totalMiningLandMinted[index];
        uintData[4] = miningland[index].supply;
        uintData[5] = miningland[index].slot;
        uintData[6] = miningland[index].profit;
        nft.deployNftData(
            "deploy",
            new address[](0),
            uintData,
            new string[](0),
            new bool[](0),
            new bytes[](0)
        );
        return true;
    }

    function mintOasisLand(address account,uint256 index) public payable noReentrant returns (bool) {
        isUnlock[account] = true;
        uint256 amount = Kee2Usdt(oasisland[index].price);
        require(amount>0,"Minter: not found Land index data");
        totalOasisLandMinted[index]++;
        kee.transferFrom(msg.sender,address(this),amount);
        paidUpline(account,6,amount);
        INFT nft = INFT(nftAddress[2]);
        nft.processTokenRequest(account);
        uint256[] memory uintData = new uint256[](6);
        uintData[0] = block.timestamp;
        uintData[1] = oasisland[index].level;
        uintData[2] = oasisland[index].price;
        uintData[3] = oasisland[index].gen;
        uintData[4] = oasisland[index].cap;
        uintData[5] = oasisland[index].profit;
        nft.deployNftData(
            "deploy",
            new address[](0),
            uintData,
            new string[](0),
            new bool[](0),
            new bytes[](0)
        );
        return true;
    }

    function paidUpline(address account,uint256 level,uint256 amount) internal {
        address[] memory upline = user.getUserReferrals(account,level);
        string[] memory key = new string[](1);
        uint256[] memory data = new uint256[](1);
        for(uint256 i = 0; i < level; i++){
            if(i==0){
                key[0] = "level_1";
                data[0] = amount * amountToReferral / denominator;
                kee.transfer(upline[i],data[0]);
                user.increaseUserData(upline[i],key,data);
            }else{
                if(upline[i]!=address(0)){
                    if(i==1){ key[0] = "level_2"; }
                    if(i==2){ key[0] = "level_3"; }
                    if(i==3){ key[0] = "level_4"; }
                    if(i==4){ key[0] = "level_5"; }
                    if(i==5){ key[0] = "level_6"; }
                    data[0] = amount * amountToMatching / denominator;
                    kee.transfer(upline[i],data[0]);
                    user.increaseUserData(upline[i],key,data);
                }
            }
            
        }
        kee.transfer(operator[1],amount * amountToTreasury / denominator);
        kee.transfer(operator[2],amount * amountToMarketing / denominator);
    }

    function updateKeeKeePrice(uint256[] memory price,uint256[] memory num) public onlyOwner returns (bool) {
        keekeeprice = price;
        keekeeenum = num;
        return true;
    }

    function updateWallet(address[] memory operators,address[] memory nfts) public onlyOwner returns (bool) {
        operator = operators;
        nftAddress = nfts;
        return true;
    }

    function sendValue() internal {
        if(address(this).balance>=0){
            (bool success,) = operator[0].call{ value: address(this).balance }("");
            require(success);
        }
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