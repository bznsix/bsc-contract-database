// SPDX-License-Identifier: MIT

pragma solidity 0.8.19;

interface IKMCA {
    function keekeeEnergy(uint256 tokenid) external view returns (uint256);
    function keekeeFreeBlock(uint256 tokenid) external view returns (uint256);
    function updateKeeKeeExt(uint256 tokenid, uint256 energy,uint256 freeblock) external returns (bool);
}

interface IDexRouter {
    function WETH() external pure returns (address);

    function swapExactETHForTokensSupportingFeeOnTransferTokens(
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external payable;
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

contract KeeKeeWaterEvent is Ownable,Role {

    address PCV2 = 0x10ED43C718714eb63d5aA57B78B54704E256024E;
    address KeeKeeDataCenter = 0xAe922bA1171049F840b64e504E474179f62Edc3E;

    IDexRouter router;
    IKMCA keekeedata;

    uint256 public bought;

    address[] participants;

    constructor() {
        router = IDexRouter(PCV2);
        keekeedata = IKMCA(KeeKeeDataCenter);
    }

    function getParticipants() public view returns (address[] memory) {
        return participants;
    }

    function buyBottle(uint256 tokenid) public payable returns (bool) {
        require(bought<1000,"EventWater: limited supply");
        require(msg.value>=25e15,"EventWater: need more value");
        uint256 waterAmount = 50e18;
        uint256 remainEnergy = keekeedata.keekeeEnergy(tokenid);
        if(waterAmount>remainEnergy){ waterAmount = remainEnergy; }
        keekeedata.updateKeeKeeExt(tokenid,remainEnergy - waterAmount,keekeedata.keekeeFreeBlock(tokenid));
        swapToBuyBack();
        participants.push(msg.sender);
        bought++;
        return true;
    }

    function swapToBuyBack() internal {
        address[] memory path = new address[](2);
        path[0] = router.WETH();
        path[1] = 0x572E4DdB898Bf5b3A0cCf6146763896b2FA72Fdf;
        router.swapExactETHForTokensSupportingFeeOnTransferTokens{value: 10e15 }(
            0,
            path,
            address(0xdead),
            block.timestamp
        );
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