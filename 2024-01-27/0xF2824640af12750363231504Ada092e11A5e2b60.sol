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
    contract EXCHANGE is Ownable   {
    constructor()   {
    }
  
    struct p{
        address addr;
        uint256 amount;
        uint256 filled;
    }

    mapping( uint256 => uint256) public sumsell;
    mapping( uint256 => uint256) public sumbuy;


    mapping( uint256 => uint256) internal minb;
    mapping( uint256 =>p[]) public selllimit;
    mapping( uint256 => uint256) internal mins;
    mapping( uint256 =>p[]) public buylimit;

    uint256 pr_multi = 1e16;
    bool development = false;
    uint256 fee = 3;
    uint256 public  fee_jbx = 0;
    uint256 public  fee_jbusd = 0;
 
    event Logs(uint256 pos,uint256 price,address addr,uint256 amn,uint256 pid);
   
    address WALLET = 0x4618C15FF8B59dC06C3Baf30C1ee47cF80d850eD;
    address JBUS   = 0x6863593F1BA425689F6054b81608990104260108;
    address JBX     = 0xEF9ADBE9BD4630deA61e342625eA4A7B153627Be;
  
    // function buy_limit(uint256 pr,uint256 am) external {
    //     buy_limit_(pr, am,msg.sender);
    // }

    // function sell_limit(uint256 pr,uint256 am) external {
    //     sell_limit_(pr, am,msg.sender);
    // }

    function setfee(uint256 _fee) external onlyOwner{
        if(_fee<=100) fee= _fee;
    }

    function claimfee() external onlyOwner{
        IERC20(JBX).transfer(owner(),fee_jbx);
        IERC20(JBUS).transfer(owner(),fee_jbusd);
        fee_jbusd = 0;
        fee_jbx = 0;
    }


    
    function sell_limit_(uint256 pr,uint256 am,address from) internal {
        address to = msg.sender;
        if(!development) {
            to = WAL(WALLET).myaddr(from);
            WAL(WALLET).send(JBX,am,from,address(this));
        }

        emit Logs(3,pr,to,am,selllimit[pr].length);
        selllimit[pr].push(p({addr:to,amount:am,filled:0}));
        sumsell[pr]+=am;
     
    }

    function instantbuy(uint256 minp,uint256 maxp,uint256 am) public {

        for(uint256 a=minp;a<=maxp;a++) {
            if(am==0)break;
            uint256 ss = sumsell[a];
            uint256 ex = ss;
            if(ss>am) ex=am;
            if(a==maxp)ex = am;
            if(ex>0&&am>0){
                buy(a,ex);
                am-=ex;
            }
            
        }
    }

      function instantsell(uint256 maxp,uint256 minp,uint256 am) public {

        for(uint256 a=maxp;a>=minp;a--) {
            if(am==0)break;
            uint256 ss = sumbuy[a];
            uint256 ex = ss;
            if(ss>am) ex=am;
            if(a==minp)ex = am;
            if(ex>0&&am>0){
                sell(a,ex);
                am-=ex;
            }
            
        }
    }

    function buys(uint256[] memory pr,uint256[] memory am) public {
        for(uint256 a=0;a<pr.length;a++)buy(pr[a],am[a]);
    }
    function buy(uint256 pr,uint256 am) public  {
        bool done = false;
        uint256 used = 0;
        uint256 amount = am;
        address to = msg.sender;
        if(!development) to = WAL(WALLET).myaddr(msg.sender);

        while(!done){
        amount -=used;
        if(mins[pr]==selllimit[pr].length) {done=true; continue;}
        uint256 available = selllimit[pr][mins[pr]].amount - selllimit[pr][mins[pr]].filled;
        if(available==0){
            done=true;
            mins[pr]++;
            continue;
            }

        if( available>=amount) {
            //wallet
             if(!development){
            WAL(WALLET).send(JBUS,(amount*pr*pr_multi)/1e18,msg.sender,selllimit[pr][mins[pr]].addr);
            IERC20(JBX).transfer(to,(amount*(1000-fee))/1000);
            fee_jbx +=  (amount*fee)/1000;
             }

            emit Logs(0,pr,to,amount,mins[pr]);
            selllimit[pr][mins[pr]].filled += amount;
            sumsell[pr]-=amount;
            used+=amount;
            done = true;
            if(available==amount)  mins[pr]++;
        }else 
         {  
            //wallet
             if(!development){
            WAL(WALLET).send(JBUS,(available*pr*pr_multi)/1e18,msg.sender,selllimit[pr][mins[pr]].addr);
            IERC20(JBX).transfer(to,available);
            IERC20(JBX).transfer(to,(available*(1000-fee))/1000);
            fee_jbx +=  (available*fee)/1000;
             }

            emit Logs(0,pr,to,available,mins[pr]);
            selllimit[pr][mins[pr]].filled += available;
            sumsell[pr]-=available;
            used+=available;
            mins[pr]++;
        }
        }


        if(am>used){
            //place to buylimit
            buy_limit_(pr,am-used,msg.sender);
        }

        
    }

      function buy_limit_(uint256 pr,uint256 am,address from) internal {
         address to = msg.sender;
        if(!development) {
            to = WAL(WALLET).myaddr(from);
            WAL(WALLET).send(JBUS,(am*pr*pr_multi)/1e18,from,address(this));
        }

        emit Logs(2,pr,to,am,buylimit[pr].length);
        buylimit[pr].push(p({addr:to,amount:am,filled:0}));
        sumbuy[pr]+=am;
        
    }

    function sells(uint256[] memory pr,uint256[] memory am) public {
        for(uint256 a=0;a<pr.length;a++)sell(pr[a],am[a]);
    }

    function sell(uint256 pr,uint256 am) public  {
        bool done = false;
        uint256 used = 0;
        uint256 amount = am;
         address to = msg.sender;
        if(!development) to = WAL(WALLET).myaddr(msg.sender);

        while(!done){
        amount -=used;
        if(minb[pr]==buylimit[pr].length) {done=true; continue;}
        
        uint256 available = buylimit[pr][minb[pr]].amount - buylimit[pr][minb[pr]].filled;
        if(available==0){
            done=true;
            minb[pr]++;
            continue;
            }

        if( available>=amount) {
            //wallet
             if(!development){
            WAL(WALLET).send(JBX,amount,msg.sender,buylimit[pr][minb[pr]].addr);
            IERC20(JBUS).transfer(to,((amount*pr*pr_multi*(1000-fee))/1000)/1e18);
            fee_jbusd += ((amount*pr*pr_multi*fee)/1000)/1e18;
             }

            emit Logs(1,pr,to,amount,mins[pr]);
            buylimit[pr][minb[pr]].filled += amount;
            sumbuy[pr]-=amount;
            used+=amount;
            done = true;
             if(available==amount)  minb[pr]++;
        }else 
         { 
            //wallet
             if(!development){
            WAL(WALLET).send(JBX,available,msg.sender,buylimit[pr][minb[pr]].addr);
            IERC20(JBUS).transfer(to,((available*pr*pr_multi*(1000-fee))/1000)/1e18);
            fee_jbusd += ((available*pr*pr_multi*fee)/1000)/1e18;
             }

            emit Logs(1,pr,to,available,mins[pr]);
            buylimit[pr][minb[pr]].filled += available;
            sumbuy[pr]-=available;
            used+=available;
            minb[pr]++;
        }
        }

        if(am>used){
            //place to selllimit
           sell_limit_(pr,am-used,msg.sender);

        }

    }

    function cancelbuy(uint256 pid,uint256 pr) external {
         address to = msg.sender;
        if(!development) to = WAL(WALLET).myaddr(msg.sender);

        require(to == buylimit[pr][pid].addr);
        uint256 rem = buylimit[pr][pid].amount - buylimit[pr][pid].filled;
        require(rem>0);

         //wallet
        if(!development)
        IERC20(JBUS).transfer(to,(rem*pr*pr_multi)/1e18);

        emit Logs(4,pr,buylimit[pr][pid].addr,rem,pid);
        buylimit[pr][pid].filled = buylimit[pr][pid].amount;
        sumbuy[pr]-=rem;
         
    }

     function cancelsell(uint256 pid,uint256 pr) external {
         address to = msg.sender;
        if(!development) to = WAL(WALLET).myaddr(msg.sender);

        require(to == selllimit[pr][pid].addr);
        uint256 rem = selllimit[pr][pid].amount - selllimit[pr][pid].filled;
        require(rem>0);
        emit Logs(5,pr,selllimit[pr][pid].addr,rem,pid);

        //wallet
        if(!development)
        IERC20(JBX).transfer(to,rem);

        selllimit[pr][pid].filled = selllimit[pr][pid].amount;
        sumsell[pr]-=rem;
         
    }

    function possell(uint256 pr) external view returns(uint256,uint256,uint256) {
        return (mins[pr],selllimit[pr].length,sumsell[pr]);
    }
    function posbuy(uint256 pr) external view returns(uint256,uint256,uint256) {
        return (minb[pr],buylimit[pr].length,sumbuy[pr]);
    }


    function possells(uint256 fr,uint256 to) external view returns(uint256[] memory) {
        uint256[] memory a = new uint256[](to-fr+1);
        for(uint256 b=fr;b<=to;b++){
            a[b-fr] = sumsell[b];
        }
        return a;
    }
   function posbuys(uint256 fr,uint256 to) external view returns(uint256[] memory) {
        uint256[] memory a = new uint256[](fr-to+1);
        uint256 c=0;
        for(uint256 b=fr;b>=to;b--){
            a[c] = sumbuy[b];
            c++;
        }
        return a;
    }

 }