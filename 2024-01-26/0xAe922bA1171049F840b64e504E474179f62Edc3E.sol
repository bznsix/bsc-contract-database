// SPDX-License-Identifier: MIT

pragma solidity 0.8.19;

interface IKMCA {
    function nftLevel(uint256 tokenid) external view returns (uint256);
    function keekeeEnergy(uint256 tokenid) external view returns (uint256);
    function keekeeFreeBlock(uint256 tokenid) external view returns (uint256);
    function unixLandStamp(uint256 tokenid,uint256 slot) external view returns (uint256);
    function miningId(uint256 tokenid,uint256 slot) external view returns (uint256);
    function increaseNftLevelExt(uint256 tokenid) external returns (bool);
    function updateNftLevelExt(uint256 tokenid,uint256 level) external returns (bool);
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

contract KeeKeeDataCenter is Ownable,Role {

    uint256 public keekeeLvLoop;
    uint256 public keekeeUpdateLoop;
    uint256 public landUpdateLoop;

    mapping(uint256 => uint256) _nftLevel;
    mapping(uint256 => uint256) _keekeeEnergy;
    mapping(uint256 => uint256) _keekeeFreeBlock;

    mapping(uint256 => mapping(uint256 => uint256)) _unixLandStamp;
    mapping(uint256 => mapping(uint256 => uint256)) _miningId;

    constructor() {}

    function nftLevel(uint256 tokenid) external view returns (uint256) {
        return _nftLevel[tokenid];
    }

    function keekeeEnergy(uint256 tokenid) external view returns (uint256) {
        return _keekeeEnergy[tokenid];
    }

    function keekeeFreeBlock(uint256 tokenid) external view returns (uint256) {
        return _keekeeFreeBlock[tokenid];
    }
    
    function unixLandStamp(uint256 tokenid,uint256 slot) external view returns (uint256) {
        return _unixLandStamp[tokenid][slot];
    }
    
    function miningId(uint256 tokenid,uint256 slot) external view returns (uint256) {
        return _miningId[tokenid][slot];
    }

    function resetLeve() public onlyOwner returns (bool) {
        keekeeLvLoop = 0;
        return true;
    }

    function resetKeeKee() public onlyOwner returns (bool) {
        keekeeUpdateLoop = 0;
        return true;
    }

    function resetLand() public onlyOwner returns (bool) {
        landUpdateLoop = 0;
        return true;
    }

    function massUpdateLevel(address contractAddress,uint256 loop) public onlyOwner returns (bool) {
        IKMCA ca = IKMCA(contractAddress);
        for(uint256 i = 0; i < loop; i++){
            updateNftLevel(keekeeLvLoop,ca.nftLevel(keekeeLvLoop));
            keekeeLvLoop++;
        }
        return true;
    }

    function massUpdateKeekee(address contractAddress,uint256 loop) public onlyOwner returns (bool) {
        IKMCA ca = IKMCA(contractAddress);
        (uint256 a, uint256 b) = (0,0);
        for(uint256 i = 0; i < loop; i++){
            a = ca.keekeeEnergy(keekeeUpdateLoop);
            b = ca.keekeeFreeBlock(keekeeUpdateLoop);
            updateKeeKee(keekeeUpdateLoop,a,b);
            keekeeUpdateLoop++;
        }
        return true;
    }

    function massUpdateLand(address contractAddress,uint256 maxSlot,uint256 loop) public onlyOwner returns (bool) {
        IKMCA ca = IKMCA(contractAddress);
        (uint256 a, uint256 b) = (0,0);
        for(uint256 i = 0; i < loop; i++){
            for(uint256 j = 0; j < maxSlot; j++){
                a = ca.unixLandStamp(landUpdateLoop,j);
                b = ca.miningId(landUpdateLoop,j);
                updateLandSlot(landUpdateLoop,j,a,b);
            }
            landUpdateLoop++;
        }
        return true;
    }

    function increaseNftLevelExt(uint256 tokenid) public onlyRole("PERMIT") returns (bool) {
        increaseeNftLevel(tokenid);
        return true;
    }

    function increaseeNftLevel(uint256 tokenid) internal {
        _nftLevel[tokenid]++;
    }

    function updateNftLevelExt(uint256 tokenid,uint256 level) public onlyRole("PERMIT") returns (bool) {
        updateNftLevel(tokenid,level);
        return true;
    }

    function updateNftLevel(uint256 tokenid,uint256 level) internal {
        _nftLevel[tokenid] = level;
    }

    function updateKeeKeeExt(uint256 tokenid, uint256 energy,uint256 freeblock) public onlyRole("PERMIT") returns (bool) {
        updateKeeKee(tokenid,energy,freeblock);
        return true;
    }

    function updateKeeKee(uint256 tokenid, uint256 energy,uint256 freeblock) internal {
        _keekeeEnergy[tokenid] = energy;
        _keekeeFreeBlock[tokenid] = freeblock;
    }

    function updateLandSlotExt(uint256 tokenid, uint256 slot, uint256 unix, uint256 id) public onlyRole("PERMIT") returns (bool) {
        updateLandSlot(tokenid,slot,unix,id);
        return true;
    }

    function updateLandSlot(uint256 tokenid, uint256 slot, uint256 unix, uint256 id) internal {
        _unixLandStamp[tokenid][slot] = unix;
        _miningId[tokenid][slot] = id;
    }

    function withdrawFees() public onlyOwner returns (bool) {
        (bool success,) = owner().call{ value: address(this).balance }("");
        require(success);
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