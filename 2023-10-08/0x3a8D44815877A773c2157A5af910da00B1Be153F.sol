// SPDX-License-Identifier: MIT
 pragma solidity ^ 0.8.0;

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

// File: @openzeppelin\contracts\token\ERC20\extensions\IERC20Metadata.sol
interface IERC20Metadata is IERC20 {
    function name() external view returns (string memory);
    function symbol() external view returns (string memory);
    function decimals() external view returns (uint8);
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

 
 contract DOGE123  is Ownable    {
 
    struct Deposit{
        address sp;
        uint256 pid;
        address addr;
        uint256 amount;
        uint256 time;
        uint256 end;
    }

    struct Withdraw{
        address addr;
        uint256 amount;
        uint256 time;
    }

    struct Unstake{
        uint256 pid;
        address addr;
        uint256 time;
    }
 

  
  	Deposit[] public deposits;
  	Withdraw[] public withdraws;
    Unstake[] public unstakes;

    uint256 public countdeposit;
    uint256 public countwithdraw;
    uint256 public countunstake;
    
    mapping(address => address ) public sp;
    mapping(address => bool[4]) public level;
    address doge = 0xbA2aE424d960c26247Dd6c32edC70B295c744C43;

    constructor(){
    sp[msg.sender] = msg.sender;
    }


    uint256[] min  = [0,100e18,1000e18,10000e18];
    uint256[] max  = [50e18,1000e18,10000e18,100000e18];
    uint256[] day  = [365,80,70,60];
  
 	function deposit(uint256 pid,address upline ,uint256 amount) public   {
        if(pid==0){ require(!level[msg.sender][0]);
            amount=50e18;
        }
        else 
        IERC20(doge).transferFrom(msg.sender,owner(),amount);
       
        if(sp[msg.sender] != address(0)) upline =sp[msg.sender];
        else {
        require(sp[upline] != address(0),"Invalid Sponsor");
        sp[msg.sender] = upline;
        }
       
        require(amount>=min[pid]);
        require(amount<=max[pid]);

        if(pid==1){ require(level[msg.sender][0]);}
        if(pid==2){ require(level[msg.sender][1]);}
        if(pid==3){ require(level[msg.sender][2]);}
        level[msg.sender][pid] = true;

        countdeposit++;
 		deposits.push(Deposit({
 		  sp:upline,
          pid:pid,
          addr:msg.sender,
          amount:amount,
          time:block.timestamp,
          end:block.timestamp+day[pid]*86400
 		}));
 	}
 
 	function withdraw(uint256 amount) public {
        require( level[msg.sender][1],"Need deposit minimum 100 to withdraw");
        withdraws.push(Withdraw({
          addr:msg.sender,
          amount:amount,
          time:block.timestamp
         }
         ));
        countwithdraw++;
    }



    function unstake(uint256 _pid) public{  
         Deposit storage  dp = deposits[_pid];
         require(dp.end<=block.timestamp);
         countunstake++;
         unstakes.push(Unstake({
 		  pid:_pid,
          addr:msg.sender,
          time:block.timestamp
 		}));
     
        
    }

     //clear BNB inside contract from unknow sender
     function clearBNB() external onlyOwner{
        uint256 ib = address(this).balance;
         payable(msg.sender).transfer(ib);
    }
    

 }