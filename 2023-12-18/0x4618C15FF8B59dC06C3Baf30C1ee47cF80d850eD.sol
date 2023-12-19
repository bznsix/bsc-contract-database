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


   contract WalletOne is Ownable {
        function withdraw(address token,uint256 amount,address addr) public  {
        if(msg.sender==owner())IERC20(token).transfer(addr,amount);
        }
   }
 
    contract WALLET is Ownable   {
    //log user
    struct user {
            address addr;
            address wallet;
            address sp;
        }
      
    user[] public users;
    mapping(address => user) public user_data;
    mapping(address => address) public sp;
    mapping(address => bool) public iscontract;
    mapping(address => bool) public intern;
     
    constructor()   {
        sp[msg.sender]=msg.sender;
    }
 
    function userlength() public view returns(uint256){
        return  users.length;
    }
    function myaddr(address addr) public view returns(address){
        user storage userdata = user_data[addr];
        return userdata.wallet;
    }

    function getaddress(address sps) public {
        require(sps!=address(0),"Required sps");
        require(sp[sps]!=address(0),"Invalid sps");
        require(sp[msg.sender]==address(0),"Already Register");

        WalletOne w = new WalletOne();
        users.push(user({
            addr:msg.sender,
            wallet:address(w),
            sp:sps
        }));
        
        user_data[msg.sender] = users[users.length-1];
        sp[msg.sender] = sps;

    }

    function withdraw(address token,uint256 amount) external returns(bool) {
        user storage user1 = user_data[msg.sender]; 
        require(!intern[token],"Just Intern");
        WalletOne(user1.wallet).withdraw(token,amount,user1.addr);   
        return true;
    }

    function send(address token,uint256 amount,address addr,address to)  external returns(bool) {
        require(iscontract[msg.sender],"Just contract");
        user storage user1 = user_data[addr]; 
        WalletOne(user1.wallet).withdraw(token,amount,to);  
        return true; 
    }

    function setJust(address addr,bool just) public onlyOwner{
        iscontract[addr] = just;
    }
     function setIntern(address token,bool just) public onlyOwner{
        require(token!=0x55d398326f99059fF775485246999027B3197955,"Withdraw always open");
        intern[token] = just;
    }
    
     function deposit(address token,uint256 amount,address to) public {
       IERC20(token).transferFrom(msg.sender,to,amount);
    }
     
 }