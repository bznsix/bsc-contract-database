// SPDX-License-Identifier: MIT

pragma solidity 0.8.19;

interface IERC721 {
    event Transfer(address indexed from, address indexed to, uint256 indexed tokenId);
    event Approval(address indexed owner, address indexed approved, uint256 indexed tokenId);
    event ApprovalForAll(address indexed owner, address indexed operator, bool approved);
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

contract OasisWater is Ownable,Role {

    address keekee = 0x042d30df190c68FaA9D2C04A603aA2bA21D6f507;
    address oasis = 0x9E26Ea944DC18764BF5aE78D820825eC869D27B6;

    mapping(uint256 => uint256) public blockCalculate;

    constructor() {
    }

    function getWaterGenAndCap(uint256 tokenid) public view returns (uint256,uint256) {
        IOCNFTMetadata fallbackCall = IOCNFTMetadata(oasis);
        string[] memory key = new string[](1);
        key[0] = "deploy";
        IOCNFTMetadata.DataStorage[] memory data = new IOCNFTMetadata.DataStorage[](1);
        data = fallbackCall.getNftData(tokenid,key);
        uint256[] memory u = new uint256[](6);
        u = data[0].u;
        return (u[3],u[4]);
    }

    function getCurrentWater(uint256 tokenid) public view returns (uint256) {
        (uint256 gen,uint256 cap) = getWaterGenAndCap(tokenid);
        uint256 tick = block.timestamp - blockCalculate[tokenid];
        uint256 water = gen * tick / 86400;
        if(water > cap){ return cap; }
        return water;
    }

    function drainWater(uint256 tokenid,uint256 amount) public onlyRole("PERMIT") returns (bool) {
        (uint256 gen,uint256 cap) = getWaterGenAndCap(tokenid);
        uint256 remainWater = getCurrentWater(tokenid) - amount;
        uint256 divWater = cap - remainWater;
        uint256 tick = divWater * 86400 / gen;
        blockCalculate[tokenid] = block.timestamp - tick;
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