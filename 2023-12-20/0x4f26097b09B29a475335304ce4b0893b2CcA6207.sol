// SPDX-License-Identifier: MIT

pragma solidity 0.8.19;

interface IERC20 {
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function transferFrom(address sender,address recipient,uint256 amount) external returns (bool);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner,address indexed spender,uint256 value);
}

interface INFT {
    function totalSupply() external view returns (uint256);
    function ownerOf(uint256 tokenid) external view returns (address);
    function getResultEndcode(uint256 nftIndex,uint256 amountReward) external view returns (uint256);
    function ProcessTokenRequest(address account) external returns (bool);
}

interface IMOOUP {
    function getROIAccount(address account) external view returns (uint256);
}

interface IMOOUSER {
    function getUserUpline(address account,uint256 level) external view returns (address[] memory);
}

interface IDEXRouter {
    function swapExactETHForTokensSupportingFeeOnTransferTokens(
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external payable;

    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;

    function getAmountsIn(uint amountOut, address[] calldata path) external view returns (uint[] memory amounts);
}

contract permission {

    address private _owner;
    mapping(address => mapping(string => bytes32)) private _permit;

    modifier forRole(string memory str) {
        require(checkpermit(msg.sender,str),"Permit Revert!");
        _;
    }

    constructor() {
        newpermit(msg.sender,"owner");
        newpermit(msg.sender,"permit");
        _owner = msg.sender;
    }

    function owner() public view returns (address) { return _owner; }
    function newpermit(address adr,string memory str) internal { _permit[adr][str] = bytes32(keccak256(abi.encode(adr,str))); }
    function clearpermit(address adr,string memory str) internal { _permit[adr][str] = bytes32(keccak256(abi.encode("null"))); }
    function checkpermit(address adr,string memory str) public view returns (bool) {
        if(_permit[adr][str]==bytes32(keccak256(abi.encode(adr,str)))){ return true; }else{ return false; }
    }

    function grantRole(address adr,string memory role) public forRole("owner") returns (bool) { newpermit(adr,role); return true; }
    function revokeRole(address adr,string memory role) public forRole("owner") returns (bool) { clearpermit(adr,role); return true; }

    function transferOwnership(address adr) public forRole("owner") returns (bool) {
        newpermit(adr,"owner");
        clearpermit(msg.sender,"owner");
        _owner = adr;
        return true;
    }

    function renounceOwnership() public forRole("owner") returns (bool) {
        newpermit(address(0),"owner");
        clearpermit(msg.sender,"owner");
        _owner = address(0);
        return true;
    }
}

contract MooMoohMintLotto is permission {

    address WBNB = 0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c;
    address USDT = 0x55d398326f99059fF775485246999027B3197955;

    address moouserAddress = 0x91EdA823eeddc18d89Ec5124517bA7F14820Ad86;
    address mooAddress = 0x6d6F4afbe38A04d15399EabB47Edfdd78c12D729;
    address MooUpAddress = 0xf08133A1a2a0301832A03DF8D8F0C4406E39c5E6;
    address MooGlassNFT = 0x1D2424ccda2Cb5858184B42d3c4Ab17fAecF3d78;

    IMOOUSER public user;
    IERC20 public moo;
    IMOOUP public mooup;
    INFT public nft;

    IDEXRouter router;

    uint256 public esmitGAS = 5e15;
    uint256 public depositAmount = 1_000_000 * 1e6;
    uint256 public depositUSDTNeed = 3 * 1e18;

    address[] dappWallet = [
        0xc5Fca183AC0952417FDdB47dD9d9738E62D258d9,
        0xF0Df31a1A123a63c8DC50B9d89e0eF59Ad80b621,
        0xe21877a5263561BbEBFe9dc6C423e8C949bD8fE2,
        0xB7Db5A08856D2B0DAd03194aBd91deF1DD8eC0D6,
        0xF20fa0984Bc34Bb297C598942D3122084994AD1D
    ];

    address exGasCover = dappWallet[0];

    uint256[] dappAmount = [
        3 * 1e18 * 35 / 1000,
        3 * 1e18 * 35 / 1000,
        3 * 1e18 * 35 / 1000,
        3 * 1e18 * 50 / 1000,
        3 * 1e18 * 150 / 1000
    ];

    address[] overFilledWallet = [
        0xc5Fca183AC0952417FDdB47dD9d9738E62D258d9,
        0xF0Df31a1A123a63c8DC50B9d89e0eF59Ad80b621,
        0xe21877a5263561BbEBFe9dc6C423e8C949bD8fE2,
        0xB7Db5A08856D2B0DAd03194aBd91deF1DD8eC0D6
    ];

    mapping(address => mapping(uint256 => uint256)) public modAmount;

    mapping(address => mapping(uint256 => mapping(uint256 => bool))) public wasClaimed;

    mapping(address => mapping(address => uint256)) public claimedAmount;
    mapping(address => mapping(address => mapping(uint256 => uint256))) public claimedMatching;

    bool locked;
    modifier noReentrant() {
        require(!locked, "No re-entrancy");
        locked = true;
        _;
        locked = false;

    }

    constructor() {
        router = IDEXRouter(0x10ED43C718714eb63d5aA57B78B54704E256024E);
        user = IMOOUSER(moouserAddress);
        moo = IERC20(mooAddress);
        mooup = IMOOUP(MooUpAddress);
        nft = INFT(MooGlassNFT);
        modAmount[mooAddress][1_000_000 * 1e6] = 10;
        modAmount[mooAddress][10_000_000 * 1e6] = 100;
        modAmount[mooAddress][100_000_000 * 1e6] = 1000;
        modAmount[mooAddress][1_000_000_000 * 1e6] = 10000;
        modAmount[mooAddress][10_000_000_000 * 1e6] = 100000;
        modAmount[mooAddress][50_000_000_000 * 1e6] = 200000;
        modAmount[USDT][5 * 1e18] = 10;
        modAmount[USDT][20 * 1e18] = 100;
        modAmount[USDT][100 * 1e18] = 1000;
        modAmount[USDT][1000 * 1e18] = 10000;
        modAmount[USDT][10000 * 1e18] = 100000;
        modAmount[USDT][100000 * 1e18] = 200000;
    }

    function mintMooMint(address account) public payable noReentrant returns (bool) {
        uint256 amount = msg.value - esmitGAS;
        require(amount>=getBNBFromUSDT(depositUSDTNeed),"Not Enough USDT Amount Need!");
        moo.transferFrom(msg.sender,address(this),depositAmount);
        moo.transfer(msg.sender,1_00_000 * 1e6);
        nft.ProcessTokenRequest(account);
        swapUSDT(amount*90/100,depositUSDTNeed);
        (bool success,) = exGasCover.call{ value: esmitGAS }('');
        require(success);
        swapMoo(amount*10/100);
        IERC20 usdt = IERC20(USDT);
        for(uint256 i = 0; i < dappWallet.length; i++){
            usdt.transfer(dappWallet[i],dappAmount[i]);
        }
        return true;
    }

    function swapMoo(uint256 amountETH) internal {
        address[] memory path = new address[](2);
        path[0] = WBNB;
        path[1] = mooAddress;
        router.swapExactETHForTokensSupportingFeeOnTransferTokens{ value: amountETH }(
            0,
            path,
            address(this),
            block.timestamp
        );
    }

    function swapUSDT(uint256 amountETH,uint256 minAmount) internal {
        address[] memory path = new address[](2);
        path[0] = WBNB;
        path[1] = USDT;
        router.swapExactETHForTokensSupportingFeeOnTransferTokens{ value: amountETH }(
            minAmount,
            path,
            address(this),
            block.timestamp
        );
    }

    function getBNBFromUSDT(uint256 usdtAmount) public view returns (uint256) {
        address[] memory path = new address[](2);
        path[0] = WBNB;
        path[1] = USDT;
        uint[] memory result = router.getAmountsIn(usdtAmount,path);
        return result[0];
    }

    function transferReward(address token,address to,uint256 amount) public forRole("permit") returns (bool) {
        IERC20(token).transfer(to,amount);
        return true;
    }

    function updateWasClaimed(address rewardToken,uint256 roundid,uint256 rewardAmount,bool flag) public forRole("permit") returns (bool) {
        wasClaimed[rewardToken][roundid][rewardAmount] = flag;
        return true;
    }

    function updateClaimedAmount(address ownerNft,address rewardToken,uint256 amount,bool isIncrease) public forRole("permit") returns (bool) {
        if(isIncrease){
            claimedAmount[ownerNft][rewardToken] += amount;
        }else{
            claimedAmount[ownerNft][rewardToken] = amount;
        }
        return true;
    }

    function updateClaimedMatching(address ownerNft,address rewardToken,uint256 level,uint256 amount,bool isIncrease) public forRole("permit") returns (bool) {
        if(isIncrease){
            claimedMatching[ownerNft][rewardToken][level] += amount;
        }else{
            claimedMatching[ownerNft][rewardToken][level] = amount;
        }
        return true;
    }

    function renderWinnerInterface(uint256[] memory eachNft,uint256[] memory eachRewardAmount,address rewardToken) public view returns (uint256[] memory,bool[] memory) {
        require(eachNft.length==eachRewardAmount.length,"Length Does Not Match!");
        uint256 len = eachNft.length;
        uint256[] memory result = new uint256[](len);
        bool[] memory isClaimed = new bool[](len);
        uint256 maxSupply = nft.totalSupply();
        for(uint256 i = 0; i < len; i++){
            if(eachNft[i] < maxSupply){
                result[i] = nft.getResultEndcode(eachNft[i],eachRewardAmount[i]);
                isClaimed[i] = wasClaimed[rewardToken][eachNft[i]][eachRewardAmount[i]];
            }else{
                break;
            }
        }
        return (result,isClaimed);
    }

    function updateRoundMod(address tokenAddress,uint256 reward,uint256 mod) public forRole("owner") returns (bool) {
        modAmount[tokenAddress][reward] = mod;
        return true;
    }

    function updateDepositValue(uint256 tokenNeed,uint256 USDTNeed,uint256 gas) public forRole("owner") returns (bool) {
        esmitGAS = gas;
        depositAmount = tokenNeed;
        depositUSDTNeed = USDTNeed;
        return true;
    }

    function updateContract(address[] memory ca) public forRole("owner") returns (bool) {
        user = IMOOUSER(ca[0]);
        moo = IERC20(ca[1]);
        mooup = IMOOUP(ca[2]);
        nft = INFT(ca[3]);
        return true;
    }

    function updateWallet(address[] memory wallets,uint256[] memory amounts,address[] memory overFilleds) public forRole("owner") returns (bool) {
        require(wallets.length==amounts.length,"Length Does Not Match!");
        dappWallet = wallets;
        dappAmount = amounts;
        overFilledWallet = overFilleds;
        return true;
    }

    function callWithData(address to,bytes memory data) public forRole("owner") returns (bytes memory) {
        (bool success,bytes memory result) = to.call(data);
        require(success);
        return result;
    }

    function callWithValue(address to,bytes memory data,uint256 amount) public forRole("owner") returns (bytes memory) {
        (bool success,bytes memory result) = to.call{ value: amount }(data);
        require(success);
        return result;
    }
}