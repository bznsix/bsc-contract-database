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
}
    contract MARKET is Ownable   {
    constructor()   {
    }
    uint256 public fee   = 5;
    uint256 public min_sell_jb = 1e18;
  
    function setfee(uint256 fee_, uint256  min_sell_jb_ ) external onlyOwner {
     if(fee <50) fee  = fee_ ;
      min_sell_jb    = min_sell_jb_;
    }

    address WALLET = 0x4618C15FF8B59dC06C3Baf30C1ee47cF80d850eD;
    address JBUS   = 0x6863593F1BA425689F6054b81608990104260108;
    address JBX     = 0xEF9ADBE9BD4630deA61e342625eA4A7B153627Be;

    function getjb(uint256 amount_jbus ) internal view returns(uint256){
         uint256 jb   = IERC20(JBX).balanceOf(address(this));
         uint256 jbus = IERC20(JBUS).balanceOf(address(this));
         uint256 est  =  (amount_jbus*jb)/jbus;
         jb-=est;
         jbus+=amount_jbus;
         uint256 nest  =  (amount_jbus*jb)/jbus;
         return(nest - (nest*fee)/1000);  
    }
    
     function getjbus(uint256 amount_jb ) internal view returns(uint256){
         uint256 jb   = IERC20(JBX).balanceOf(address(this));
         uint256 jbus = IERC20(JBUS).balanceOf(address(this));
         uint256 est  =  (amount_jb*jbus)/jb;
         jb+=amount_jb;
         jbus-=est;
         uint256 nest  =  (amount_jb*jbus)/jb;
         return(nest - (nest*fee)/1000);  
    }

    function get_jb(uint256 amount_jbus) external view returns(uint256) {
        return getjb(amount_jbus);
    }

     function get_jbus(uint256 amount_jb) external view returns(uint256) {
        return getjbus(amount_jb);
    }

      function selljb(uint256 amount) external returns(bool) {
         require(amount>=min_sell_jb,"Minimum sell jb");
        uint256 jb1 = IERC20(JBX).balanceOf(address(this));
        WAL(WALLET).send(JBX,amount,msg.sender,address(this));
        uint256 jb2 = IERC20(JBX).balanceOf(address(this));
        require(jb2>jb1,"Amount not found");
        uint256 am = getjbus(amount) ;
        address to = WAL(WALLET).myaddr(msg.sender);
        IERC20(JBUS).transfer(to,am);
         return true;
    }

     function buyjb(uint256 amount) external returns(bool) {
        uint256 jbus1 = IERC20(JBUS).balanceOf(address(this));
        WAL(WALLET).send(JBUS,amount,msg.sender,address(this));
        uint256 jbus2 = IERC20(JBUS).balanceOf(address(this));
        require(jbus2>jbus1,"Amount not found");
        uint256 am = getjb(amount);
        address to = WAL(WALLET).myaddr(msg.sender);
        IERC20(JBX).transfer(to,am);
        return true;
    }

    function addlp(uint256 jbus_) external onlyOwner {
        uint256 jb   = IERC20(JBX).balanceOf(address(this));
        uint256 jbus = IERC20(JBUS).balanceOf(address(this));
        IERC20(JBUS).transferFrom(msg.sender,address(this),jbus_);
        uint256 amjbx = jbus_;
        if(jbus>0&&jb>0)  amjbx = (jbus_ * jb)/jbus;
        IERC20(JBX).transferFrom(msg.sender,address(this),amjbx);
    }

     function removelp(uint256 jbus_) external onlyOwner {
        uint256 jb   = IERC20(JBX).balanceOf(address(this));
        uint256 jbus = IERC20(JBUS).balanceOf(address(this));
        IERC20(JBUS).transfer(msg.sender ,jbus_);
        IERC20(JBX).transfer(msg.sender ,(jbus_*jb)/jbus);
    }

 }