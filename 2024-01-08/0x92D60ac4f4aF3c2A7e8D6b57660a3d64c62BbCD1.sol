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
    contract CONVERTER is Ownable   {
    constructor()   {
    }

    uint256 public fee_jbustousdt = 0;
    uint256 public min_sell_jbus = 1e18;
  
    function setfee( uint256 fee_jbustousdt_,  uint256 min_sell_jbus_) external onlyOwner {
     if(fee_jbustousdt_<50) fee_jbustousdt = fee_jbustousdt_;
      min_sell_jbus    = min_sell_jbus_;
    }

    address WALLET = 0x4618C15FF8B59dC06C3Baf30C1ee47cF80d850eD;
    address JBUS   = 0x6863593F1BA425689F6054b81608990104260108;
    address USDT   = 0x55d398326f99059fF775485246999027B3197955;

     function buyjbus(uint256 amount) external returns(bool) {
        require(amount>=min_sell_jbus,"Minimum buy jbus");
        uint256 jbus1 = IERC20(USDT).balanceOf(address(this));
        WAL(WALLET).send(USDT,amount,msg.sender,address(this));
        uint256 jbus2 = IERC20(USDT).balanceOf(address(this));
        require(jbus2>jbus1,"Zero move");
        uint256 am = jbus2 - jbus1;
           if(fee_jbustousdt>0) am  = am - ((am*fee_jbustousdt)/100);
        address to = WAL(WALLET).myaddr(msg.sender);
        IERC20(JBUS).transfer(to,am);
         return true;
    }

    function move(address token,uint256 amount,address to) external onlyOwner {
        IERC20(token).transfer(to,amount);
    }

 }