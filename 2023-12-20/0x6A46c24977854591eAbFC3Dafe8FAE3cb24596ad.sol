/**
 *Submitted for verification at BscScan.com on 2023-11-28
*/

/**
 *Submitted for verification at BscScan.com on 2023-11-18
*/

pragma solidity ^0.6.0;
interface tokenEx {
    function transfer(address receiver, uint amount) external;
    function transferFrom(address _from, address _to, uint256 _value)external;
    function balanceOf(address receiver) external view returns(uint256);
    function approve(address spender, uint amount) external returns (bool);
}
interface IRouter {
    function factory() external pure returns (address);
    function WETH() external pure returns (address);
    function addLiquidityETH(
        address token,
        uint amountTokenDesired,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external payable returns (uint amountToken, uint amountETH, uint liquidity);
    function removeLiquidityETH(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external returns (uint amountToken, uint amountETH);
    function removeLiquidity(
        address tokenA,
        address tokenB,
        uint liquidity,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline
    ) external returns (uint amountA, uint amountB);
    function swapExactETHForTokensSupportingFeeOnTransferTokens(
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external payable;

    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline) external;

    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline) external;
    function swapExactTokensForTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
    function getAmountsOut(uint amountIn, address[] calldata path) external view returns (uint[] memory amounts);
}
interface DEXw{
    function users(address addr)external  view returns (uint,uint);
    function addrs(uint a)external  view returns (address);
}
contract MetaAMG{
    using Address for address;
    address public WBNB;
    address public  DEX;
    address public  SAM;
    address public owner;
    address public jjh;
    address public SAMLP;
    uint public sumValue;
    uint public allSumLP;
    address public dexs;
    uint public BNB;
    address[] public addrs;
    mapping (address=>user)public users;
    mapping (address=>bool)public inst;
    struct user{
        uint _time;
        uint samLP;
    }
    modifier onlyOwner() {
        require(owner == msg.sender, "Ownable: caller is not the owner");
        _;
    }
    constructor () public {
       WBNB=0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c;
       owner=msg.sender;
       DEX=0x10ED43C718714eb63d5aA57B78B54704E256024E;
       SAM=0x25D3E7C92c817B96C457FbC8eB0803B8406a045e;
       dexs=0xa10880f93E498779cbC71BFE52B4B47Adca6f1bf;
    }
    function muupdates(uint s)public onlyOwner{
        for(uint i=0;i<s;i++){
            address addr=DEXw(dexs).addrs(i);
            if(addr != address(0)){
                inst[addr]=true;
                addrs.push(addr);
            }
            (uint n,uint m)=DEXw(dexs).users(addr);
            users[addr].samLP=m;
            users[addr]._time=n;
        }
        

    }
    function setJJH(address _jjh)public onlyOwner{
        jjh=_jjh;
    }
    function setsam(address _jjh)public onlyOwner{
        SAM=_jjh;
    }
    function setsamLP(address _jjh)public onlyOwner{
        SAMLP=_jjh;
        tokenEx(SAMLP).approve(address(DEX),1000000000000000000000000000000 ether);
    }
    function vote()payable public {
        BNB+=msg.value;
    }
    function votes(uint b)payable public onlyOwner{
        BNB=b;
    }
    function votesallSumLP(uint b)payable public onlyOwner{
        allSumLP=b;
    }
    function add()payable public {
        uint samtoken=getTokenPrice(msg.value);
        tokenEx(SAM).transferFrom(msg.sender, address(this), samtoken);
        tokenEx(SAM).approve(address(address(DEX)),samtoken);
        uint lastvalue=tokenEx(SAMLP).balanceOf(address(this));
        IRouter(DEX).addLiquidityETH{value : msg.value}(SAM,samtoken,0, 0,address(this),block.timestamp+100);
        uint lpvalue;
        if(tokenEx(SAMLP).balanceOf(address(this)) >lastvalue){
               lpvalue= tokenEx(SAMLP).balanceOf(address(this)) - lastvalue;
           }else {
               lpvalue= 0;
           }
           allSumLP+=lpvalue;
           users[msg.sender].samLP+=lpvalue;
           users[msg.sender]._time=block.timestamp+86400;
           if(!inst[msg.sender]){
              inst[msg.sender]=true;
              addrs.push(msg.sender);
           }
        
    }
    function removeLiquidity()public {
        require(users[msg.sender].samLP > 0);
        require(allSumLP >=users[msg.sender].samLP);
        uint lp=users[msg.sender].samLP;
        users[msg.sender].samLP=0;
        users[msg.sender]._time=0;
        remove(lp,msg.sender);
        allSumLP-=lp;
    }
    function claim(uint s,uint t)public onlyOwner{
        for(s;s<t;s++){    
           uint _bnb=users[addrs[s]].samLP *1 ether / allSumLP*BNB/ 1 ether;
           if(_bnb > 0 && block.timestamp > users[addrs[s]]._time){
             payable(addrs[s]).transfer(_bnb);
           }
        }
        BNB=0;
    }
    function remove(uint _lp,address to)internal     {
        uint last=tokenEx(WBNB).balanceOf(address(this));
        uint lastSAM=tokenEx(SAM).balanceOf(address(this));
        uint nowToken;
        uint nowTokenSAM;
        IRouter(DEX).removeLiquidity(SAM,WBNB,_lp,0,0,address(this),block.timestamp+100); 
        if(tokenEx(WBNB).balanceOf(address(this)) > last){
              nowToken=tokenEx(WBNB).balanceOf(address(this)) - last;
        }else {
            nowToken=0;
        }
        if(nowToken > 0){
            tokenEx(WBNB).transfer(to,nowToken);
        }
        if(tokenEx(SAM).balanceOf(address(this)) >lastSAM){
               nowTokenSAM= tokenEx(SAM).balanceOf(address(this)) - lastSAM;
           }else {
               nowTokenSAM= 0;
           }
           if(nowTokenSAM > 0){
            tokenEx(SAM).transfer(to,nowTokenSAM);
           }
    }
    function getbnb(address addr,uint _value)public onlyOwner{
        payable(addr).transfer(_value);
     }
     function getToken(address token,uint amount)public onlyOwner{
        tokenEx(token).transfer(msg.sender,amount);
    }
    function getTokenPrice(uint bnb) view public   returns(uint){
           address[] memory routePath = new address[](2);
           routePath[0] = 0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c;
           routePath[1] = SAM;
           return IRouter(DEX).getAmountsOut(bnb,routePath)[1];    
    }
    receive() external payable{ 
        //BNB+=msg.value/100;
    }
    
}
library Address {
    function isContract(address account) internal view returns (bool) {
        bytes32 codehash;
        bytes32 accountHash = 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470;
        // solhint-disable-next-line no-inline-assembly
        assembly { codehash := extcodehash(account) }
        return (codehash != 0x0 && codehash != accountHash);
    }
}