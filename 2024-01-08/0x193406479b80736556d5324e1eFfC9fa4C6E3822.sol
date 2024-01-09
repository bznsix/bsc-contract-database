// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

// File: @openzeppelin\contracts\token\ERC20\IERC20.sol
interface IERC20 {
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address to, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address from, address to, uint256 amount) external returns (bool);
}

// File: @openzeppelin\contracts\utils\Context.sol
abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}
 
// File: @openzeppelin\contracts\access\Ownable.sol
abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
    constructor() {
        _transferOwnership(_msgSender());
    }
    modifier onlyOwner() {
        _checkOwner();
        _;
    }
    function owner() public view virtual returns (address) {
        return _owner;
    }
    function _checkOwner() internal view virtual {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
    }
    function renounceOwnership() public virtual onlyOwner {
        _transferOwnership(address(0));
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


interface WAL {
    function send(address token, uint256 amount ,  address addr, address to) external returns (bool);
    function myaddr(address addr) external view returns (address);
    function sp(address addr) external view returns (address);
}

 
contract CON is Ownable {
    address WALLET  =  0x4618C15FF8B59dC06C3Baf30C1ee47cF80d850eD;
    address JBX      =  0xEF9ADBE9BD4630deA61e342625eA4A7B153627Be;
    address JB      =  0x531C1149068aDc6bcf01088e4a2D082dC1351E4C;
    mapping(address => uint256 ) public limit;

    function setlimit(address addr,uint256 amount) external  onlyOwner(){
         limit[addr] =amount;
    }

    function convert(uint256 amount) external {
    if(limit[msg.sender] == 1) return;
    if(limit[msg.sender]>1 && amount>limit[msg.sender]) return;
    address a = WAL(WALLET).myaddr(msg.sender);
    uint256 am = IERC20(JB).balanceOf(a);
    if(amount>0)am = amount;
    WAL(WALLET).send(JB,am,msg.sender,address(this));
    IERC20(JBX).transfer(a,am);
    limit[msg.sender] =1;
    }

    function wd(uint256 jb,uint256 amount) external onlyOwner {
    if(jb==0)IERC20(JB).transfer(msg.sender,amount);
    if(jb==1)IERC20(JBX).transfer(msg.sender,amount);
    }
	 
 
}