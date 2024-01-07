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

interface MAR {
    function get_jb(uint256 amount_jbus) external view returns(uint256);
}

contract JBX_1 is Ownable {
    
	struct position {
        uint256 pid;
		address sp1;
        address sp2;
        address sp3;
		address addr;
		uint256 day;
        uint256 rate;
        uint256 amount;
		uint256 time;
        uint256 lastclaim;
        bool done;
	}

   position[] public stakes;
 
   mapping(uint256 => uint256 ) public day;
   mapping(uint256 => uint256 ) public rate;
   mapping(uint256 => bool ) public open;
   mapping(address => uint256 ) public affiliate;
   mapping(address => uint256 ) public mystake;
   mapping(address => uint256 ) public myjb;
   
   uint256 public minimum = 1e18;
   address pool ;
   bool public   migisdone = false;

 
    constructor() {
    day[0]=10; rate[0]=10;open[0]=true;
    day[1]=20; rate[1]=12;open[1]=true;
    day[2]=30; rate[2]=15;open[2]=true;
    }


    event Aff(uint256 time, address from, address  to, uint256 value);
    event Claim(uint256 time, address  to, uint256 value);
    event Buy(uint256 time, address  to, uint256 value);
    event Unstake(uint256 time,uint256 id, address  to, uint256 value);
    event Deposit(uint256 time, address  to, uint256 value);
    event Extend(uint256 time, uint256 id);

    address WALLET  =  0x4618C15FF8B59dC06C3Baf30C1ee47cF80d850eD;
    address JB      =  0xEF9ADBE9BD4630deA61e342625eA4A7B153627Be;
    address MARKET  =  0x459754390221Cf9e59B14c87d2244945e8B52275;
    address USDT    =  0x55d398326f99059fF775485246999027B3197955;

    function update(uint256 pid,uint256 day_,uint256 rate_,bool _open) external onlyOwner {
       day[pid] = day_;
       rate[pid] = rate_;
       open[pid] = _open;
    }

     function updatem(address market) external onlyOwner {
      MARKET = market;
    }

    function mig_u(address addr,uint256 amount,uint256 jb,uint256 stk) external onlyOwner {
    if(migisdone) return;
       affiliate[addr] = amount; 
       myjb[addr] = jb;
       mystake[addr] = stk;
    }

    function mig_done() external onlyOwner {
     migisdone = true;
    }
    
    function mig_s(uint256 id ,uint256 pid ,address sp1,address sp2,address sp3,address addr,uint256 _day,uint256 _rate,uint256 amount,uint256 time,uint256 lastclaim ) public onlyOwner{
        if(migisdone) return;
        require(id<=stakes.length,"pid to high");
        if(id==stakes.length) {
        stakes.push(position({
          pid:pid,
          sp1:sp1,
          sp2:sp2,
          sp3:sp3,
		  addr:addr,
		  day:_day,
          rate:_rate,
          amount:amount,
		  time:time,
          lastclaim:lastclaim,
          done:false
        }));
        }
        else {
         position storage stake_info = stakes[id];
          stake_info.sp1=sp1;
          stake_info.sp2=sp2;
          stake_info.sp3=sp3;
		  stake_info.addr=addr;
		  stake_info.day=_day;
          stake_info.rate=_rate;
          stake_info.amount=amount;
		  stake_info.time=time;
          stake_info.lastclaim=lastclaim;
          stake_info.done=false;
        }
	}

    function set_done(uint256 id , bool done) public {
        if(migisdone) return;
         position storage stake_info = stakes[id];
         stake_info.done=done;
	}

    function setmin(uint256 min,address addr) external onlyOwner {
       minimum = min;
       pool = addr;
    }

    
    function buy(uint256 amount) external returns(bool) {
    require(amount >0 ,"Amount required");
    uint256 jb1 = MAR(MARKET).get_jb(1e18);
    require(amount >=1e8 ,"Invalid Amount");
    uint256 est = (amount*jb1)/1e18;
    WAL(WALLET).send(USDT,amount,msg.sender,pool);
    myjb[msg.sender]+=est;
    emit Buy(block.timestamp,msg.sender,amount);
    return true;
    }

    function deposit(uint256 amount) external returns(bool) {
    require(amount >0 ,"Amount required");
    uint256 jb1 = IERC20(JB).balanceOf(address(this));
    WAL(WALLET).send(JB,amount,msg.sender,address(this));
    uint256 jb2 = IERC20(JB).balanceOf(address(this));
    require(jb2 > jb1 ,"Amount required");
    amount = jb2-jb1;
    myjb[msg.sender]+=amount;
    emit Deposit(block.timestamp,msg.sender,amount);
    return true;
    }

	function stake(uint256 pid,uint256 amount) external returns(bool) {
        require(open[pid],"Staking paused");
        require(amount >= minimum ,"Staking minimum");
        require(amount <= myjb[msg.sender] ,"Staking minimum");

        address sp1 = WAL(WALLET).sp(msg.sender);
        address sp2 = WAL(WALLET).sp(sp1);
        address sp3 = WAL(WALLET).sp(sp2);

        mystake[msg.sender]+=amount;
        myjb[msg.sender]-=amount;
        stakes.push(position({
          pid:pid,
          sp1:sp1,
          sp2:sp2,
          sp3:sp3,
		  addr:msg.sender,
		  day:day[pid],
          rate:rate[pid],
          amount:amount,
		  time:block.timestamp,
          lastclaim:block.timestamp,
          done:false
        }));
        return true;
    
	}

    function stakingslenght() external  view returns(uint256) {
        return stakes.length;
    }

	function pending(uint256 pid) public view returns(uint256) {
		position storage stake_info = stakes[pid];
        uint256 rps = ((stake_info.amount * stake_info.rate) /  1000 )  / 86400;
        uint256 ent = block.timestamp;
        uint256 endtime = stake_info.time + (stake_info.day*86400);
        if(ent>endtime) ent = endtime;
        if(stake_info.lastclaim>=endtime) return 0;
		return (rps * (ent - stake_info.lastclaim));
	}

    function claim(uint256 pid) public  returns(bool) {
        uint256 pend = pending(pid);
        if(pend > 0 ){
            position storage stake_info = stakes[pid];
            address addr = WAL(WALLET).myaddr(stake_info.addr);
            IERC20(JB).transfer(addr,pend);
            emit Claim(block.timestamp,stake_info.addr,pend);

            if(mystake[stake_info.sp1]>0){
            affiliate[stake_info.sp1] = affiliate[stake_info.sp1] + (pend*10)/100;
            emit Aff(block.timestamp,stake_info.addr,stake_info.sp1,(pend*10)/100);
            }

             if(mystake[stake_info.sp2]>0){
            affiliate[stake_info.sp2] = affiliate[stake_info.sp2] + (pend*10)/100;
             emit Aff(block.timestamp,stake_info.addr,stake_info.sp2,(pend*10)/100);
             }

            if(mystake[stake_info.sp3]>0){
            affiliate[stake_info.sp3] = affiliate[stake_info.sp3] + (pend*5)/100;
            emit Aff(block.timestamp,stake_info.addr,stake_info.sp3,(pend*5)/100);
            }

            stake_info.lastclaim = block.timestamp;
        }
    return true;
    }

     function claim_affiliate() external  returns(bool) {
        uint256 pend = affiliate[msg.sender];
        if(pend > 0 ){
            address addr = WAL(WALLET).myaddr(msg.sender);
            IERC20(JB).transfer(addr,pend);
            affiliate[msg.sender] = 0;
        }
    return true;
    }

	function unstake(uint256 id) public {
	    position storage stake_info = stakes[id];
        uint256 endtime = stake_info.time + (stake_info.day*86400);
        require(block.timestamp>=endtime,"Waiting end time");
        require(!stake_info.done,"Has been unstake");
        require(stake_info.addr == msg.sender,"Just owner");
        claim(id);
		address addr = WAL(WALLET).myaddr(msg.sender);
        IERC20(JB).transfer(addr,stake_info.amount);
        mystake[msg.sender]-=stake_info.amount;
        stake_info.done = true;
        emit Unstake(block.timestamp,id,msg.sender,stake_info.amount);
	}

    function extend(uint256 id) public {
	    position storage stake_info = stakes[id];
        uint256 endtime = stake_info.time + (stake_info.day*86400);
        require(block.timestamp>=endtime,"Waiting end time");
        require(!stake_info.done,"Has been claimed");
        require(stake_info.addr == msg.sender,"Just owner");
        require(open[stake_info.pid],"Staking paused");
        claim(id);
        stake_info.time = block.timestamp;
        stake_info.day = day[stake_info.pid];
        stake_info.rate = rate[stake_info.pid];
        stake_info.lastclaim=block.timestamp;
        emit Extend(block.timestamp, id);
	}

}