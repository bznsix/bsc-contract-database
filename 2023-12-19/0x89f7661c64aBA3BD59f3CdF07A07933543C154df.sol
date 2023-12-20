// SPDX-License-Identifier: MIT

pragma solidity 0.8.19;

interface INft {
    function totalSupply() external view returns (uint256);
    function ownerOf(uint256 tokenid) external view returns (address);
    function getResultEndcode(uint256 nftIndex,uint256 amountReward) external view returns (uint256);
    function ProcessTokenRequest(address account) external returns (bool);
}

interface IUser {
    function getUserUpline(address account,uint256 level) external view returns (address[] memory);
}

interface IMooMint {
    function modAmount(address rewardToken,uint256 rewardAmount) external view returns (uint256);
    function wasClaimed(address rewardToken,uint256 roundid,uint256 rewardAmount) external view returns (bool);
    function transferReward(address token,address to,uint256 amount) external returns (bool);
    function updateWasClaimed(address rewardToken,uint256 roundid,uint256 rewardAmount,bool flag) external returns (bool);
    function updateClaimedAmount(address ownerNft,address rewardToken,uint256 amount,bool isIncrease) external returns (bool);
    function updateClaimedMatching(address ownerNft,address rewardToken,uint256 level,uint256 amount,bool isIncrease) external returns (bool);
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

contract MooMoohMintLottoClaimmer is permission {

    address mooMintAddress = 0x4f26097b09B29a475335304ce4b0893b2CcA6207;
    address mooUserAddress = 0x91EdA823eeddc18d89Ec5124517bA7F14820Ad86;
    address mooNftAddress = 0x1D2424ccda2Cb5858184B42d3c4Ab17fAecF3d78;

    address[] overFilledWallet = [
        0xc5Fca183AC0952417FDdB47dD9d9738E62D258d9,
        0xF0Df31a1A123a63c8DC50B9d89e0eF59Ad80b621,
        0xe21877a5263561BbEBFe9dc6C423e8C949bD8fE2,
        0xB7Db5A08856D2B0DAd03194aBd91deF1DD8eC0D6
    ];

    bool locked;
    modifier noReentrant() {
        require(!locked, "No re-entrancy");
        locked = true;
        _;
        locked = false;

    }

    IMooMint public moomint;
    IUser public user;
    INft public nft;

    constructor() {
        moomint = IMooMint(mooMintAddress);
        user = IUser(mooUserAddress);
        nft = INft(mooNftAddress);
    }

    function isShouldCanClaim(uint256 tokenid,uint256 roundid,uint256 rewardAmount,address rewardToken) public view returns (bool isCanClaim,string memory error) {
 
        uint256 winnerSelector = nft.getResultEndcode(roundid,rewardAmount);
        if(winnerSelector==tokenid){}else{
            return (false,"You Are Not The Winner!");
        }

        bool wasClaimed = moomint.wasClaimed(rewardToken,roundid,rewardAmount);
        if(!wasClaimed){}else{
            return (false,"This Round Was Claimed!");
        }

        uint256 modAmount = moomint.modAmount(rewardToken,rewardAmount);
        if(roundid>8 && (roundid+1) % modAmount == 0){}else{
            return (false,"Round Id Invalid Mod %!");
        }

        return (true,"Approved!");
    }
    
    function claimWinnerMooMint(uint256 tokenid,uint256 roundid,uint256 rewardAmount,address rewardToken) public noReentrant returns (bool) {
        (bool isCanClaim,) = isShouldCanClaim(tokenid,roundid,rewardAmount,rewardToken);
        require(isCanClaim,"Error on claim condition!");

        address claimer = nft.ownerOf(tokenid);
        address[] memory upline = new address[](10);
        upline = user.getUserUpline(claimer,10);

        moomint.updateWasClaimed(rewardToken,roundid,rewardAmount,true);

        moomint.transferReward(rewardToken,claimer,rewardAmount*80/100);
        moomint.transferReward(rewardToken,owner(),rewardAmount*20/100);
        moomint.updateClaimedAmount(claimer,rewardToken,rewardAmount*80/100,true);

        uint256 rewardForDirect = rewardAmount / 10;
        uint256 rewardForDividend = rewardAmount / 100;
        uint256 rewardForSplit = rewardForDividend / overFilledWallet.length;

        for(uint256 i = 0; i < 10; i++){
            if(upline[i]!=address(0)){
                if(i==0){
                    moomint.transferReward(rewardToken,upline[i],rewardForDirect);
                    moomint.updateClaimedMatching(upline[i],rewardToken,rewardForDirect,i,true);
                }else{
                    moomint.transferReward(rewardToken,upline[i],rewardForDividend);
                    moomint.updateClaimedMatching(upline[i],rewardToken,rewardForDividend,i,true);
                }
            }else{
                for(uint256 j = 0; j < overFilledWallet.length; j++){
                    moomint.transferReward(rewardToken,overFilledWallet[j],rewardForSplit);
                }
            }
        }

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