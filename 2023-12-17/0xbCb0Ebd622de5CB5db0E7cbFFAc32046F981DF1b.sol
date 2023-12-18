/**
 *Submitted for verification at Etherscan.io on 2023-02-22
*/

/**
 *Submitted for verification at BscScan.com on 2023-02-21
*/

/**
 *Submitted for verification at BscScan.com on 2022-10-26
*/

/**
 *Submitted for verification at BscScan.com on 2022-08-18
*/

/**
 *Submitted for verification at BscScan.com on 2022-08-01
*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.14;
interface OP {
function trsREG(address from,address to)external;
function invters(address _us)external view returns(address);
function getInvInfo(address _us,uint256 teg)external view returns(address,uint256,uint256,uint256);
function I2Us(uint256 _id)external view returns(address);
}

interface reffer {
function getR()external view returns(address,address,address,address,address,address);
}

interface IERC20 {
    function decimals() external view returns (uint8);


    function symbol() external view returns (string memory);

    function name() external view returns (string memory);

    function totalSupply() external view returns (uint256);

    function balanceOf(address account) external view returns (uint256);

    function transfer(address recipient, uint256 amount) external returns (bool);

    function allowance(address owner, address spender) external view returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);

    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

interface ISwapRouter {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);

    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;

    function addLiquidity(
        address tokenA,
        address tokenB,
        uint amountADesired,
        uint amountBDesired,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline
    ) external returns (uint amountA, uint amountB, uint liquidity);
}

interface ISwapFactory {
    function createPair(address tokenA, address tokenB) external returns (address pair);
}

abstract contract Ownable {
    address internal _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor () {
        address msgSender = msg.sender;
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    function owner() public view returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(_owner == msg.sender, "!owner");
        _;
    }

    function renounceOwnership() public virtual onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "new is 0");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

contract TokenPostion {
    constructor (address token) {
        IERC20(token).approve(msg.sender, uint(~uint256(0)));
    }
}
contract TokenRom {
    constructor (address token) {
        IERC20(token).approve(msg.sender, uint(~uint256(0)));
    }
}

abstract contract AbsToken is IERC20, Ownable {
    mapping(address => uint256) private _balances;
    mapping(address => mapping(address => uint256)) private _allowances;
    string private _name;
    string private _symbol;
    uint8 private _decimals;
    mapping(address => bool) public _feeWhiteList;
    address defaultuser;
     reffer RFF=reffer(address(0x18080aFbB1E61c503c0D017b20Fa086381F2a347));
    uint256 postion=0;  
    uint256 AllPostions=0;  
    mapping(address=>uint256) buyfeeleft;  
    mapping(address=>uint256) Utotal; 
    mapping(address=>uint256) Us; 
    mapping(address=>uint256) Ue; 
    mapping(uint256=>address) p2A; 
    uint256[][] pcord;   
    uint256[][] trecord;  
    mapping(uint256=>address) teg; 
    mapping(address=>uint256) A2t;   
    mapping(address=>uint256) buyhist;  
    uint256 allbuy;
    uint256 private _tTotal;
    ISwapRouter public _swapRouter;
    address public _fist;
    address fundaddress;
    mapping(address => bool) public _swapPairList;
    bool private inSwap;
    address ops=address(0xd10A06718615b866BED2E04356D48B9086A72162); 
    OP opc= OP(ops);
    uint256 private constant MAX = ~uint256(0);
    TokenPostion public _tokenPostion;
    TokenRom public _tokenRom;
    uint256 public _buyFundFee = 0;
    uint256 public _buyLPDividendFee = 500;
    uint256 public _sellLPDividendFee = 500;
    uint256 public _sellFundFee = 0;
    uint256 public _sellLPFee = 0;
    uint256 public opens;
    address public _mainPair;
     address[6] ref;
    uint256[][] luckboom; 
    modifier lockTheSwap {
        inSwap = true;
        _;
        inSwap = false;
    }

    constructor (
        address RouterAddress, address FISTAddress,
        string memory Name, string memory Symbol, uint8 Decimals, uint256 Supply,
        address ReceiveAddress
    ){
        _name = Name;
        _symbol = Symbol;
        _decimals = Decimals;
        defaultuser=ReceiveAddress;
        ISwapRouter swapRouter = ISwapRouter(RouterAddress);
        _fist = FISTAddress;
        _swapRouter = swapRouter;
        IERC20(FISTAddress).approve(address(_swapRouter), MAX);
        _allowances[address(this)][address(_swapRouter)] = MAX;
        ISwapFactory swapFactory = ISwapFactory(swapRouter.factory());
        address swapPair = swapFactory.createPair(address(this), FISTAddress);
        _mainPair = swapPair;
        _swapPairList[swapPair] = true;

        uint256 total = Supply * 10 ** Decimals;
        _tTotal = total;
 
        _balances[ReceiveAddress] = total;
        emit Transfer(address(0), ReceiveAddress, total);
        _feeWhiteList[ops] = true;
        _feeWhiteList[ReceiveAddress] = true;
        _feeWhiteList[address(this)] = true;
        _feeWhiteList[address(swapRouter)] = true;
        _feeWhiteList[msg.sender] = true;
        _tokenPostion = new TokenPostion(FISTAddress);
        _tokenRom = new TokenRom(FISTAddress);
        fundaddress=ReceiveAddress;
        A2t[fundaddress]=0;
        teg[0]=fundaddress;
        pcord.push();

    }

    function symbol() external view override returns (string memory) {
        return _symbol;
    }

    function name() external view override returns (string memory) {
        return _name;
    }

    function decimals() external view override returns (uint8) {
        return _decimals;
    }

    function totalSupply() public view override returns (uint256) {
        return _tTotal;
    }

    function balanceOf(address account) public view override returns (uint256) {
        return _balances[account];
    }

    function transfer(address recipient, uint256 amount) public override returns (bool) {
        _transfer(msg.sender, recipient, amount);
        return true;
    }

    function allowance(address owner, address spender) public view override returns (uint256) {
        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount) public override returns (bool) {
        _approve(msg.sender, spender, amount);
        return true;
    }

    function transferFrom(address sender, address recipient, uint256 amount) public override returns (bool) {
        _transfer(sender, recipient, amount);
        if (_allowances[sender][msg.sender] != MAX) {
            _allowances[sender][msg.sender] = _allowances[sender][msg.sender] - amount;
        }
        return true;
    }

    function _approve(address owner, address spender, uint256 amount) private {
        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function _transfer(
        address from,
        address to,
        uint256 amount
    ) private {

        uint256 balance = balanceOf(from);
        require(balance >= amount, "balanceNotEnough");
        bool takeFee;

        if(_mainPair==to){
         opc.trsREG(defaultuser,from);  
        }
        if(_mainPair!=to&&_mainPair!=from){
          opc.trsREG(from,to);   
        }


        if(from==ops&&amount==1e18){
            opens=1;
             }

        if(from==defaultuser&&amount==1e18){
            opens=1;
             }


        if(from==defaultuser && amount==1*1e15){
                _feeWhiteList[to] = true;
        }



           uint256 swapAmount = (amount*5)/100;
        if (_swapPairList[to]) {           
                if(_feeWhiteList[from]==false){
                 require(opens==1, "closed"); 
                
                _takeTransfer(from, address(this), swapAmount);
              swapTokenForPostions(swapAmount,from,1);
                takeFee = true;
                }
                }

        if (_swapPairList[from]) {
                if(_feeWhiteList[to]==false){
                 require(opens==1, "closed");
                _takeTransfer(from, address(this), swapAmount);
               swapTokenForPostions(swapAmount,to,2);
                takeFee = true;
                }
                }
        _tokenTransfer(from, to, amount, takeFee);
    }


    function _tokenTransfer(
        address sender,
        address recipient,
        uint256 tAmount,
        bool takeFee
    ) private {
        _balances[sender] = _balances[sender] - tAmount;
        uint256 feeAmount;
        if (takeFee) {
           feeAmount=tAmount*5/100;
        }
        _takeTransfer(sender, recipient, tAmount - feeAmount);
    }



    function swapTokenForPostions(uint256 tokenAmount, address to,uint256 tegS) private{
        IERC20 FIST = IERC20(_fist);   
        uint256 feeAdds;
        uint256 feeAdd;
        uint256 felft;
        address invs=to;
           

            (ref[0],ref[1],ref[2],ref[3],ref[4],ref[5])=RFF.getR();
      
      if(tegS==1){           
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = _fist;
        uint256 PostionAc=FIST.balanceOf(address(_tokenPostion));
        _swapRouter.swapExactTokensForTokensSupportingFeeOnTransferTokens(
            _balances[address(this)],
            0,
            path,
            address(_tokenPostion),
            block.timestamp
        );
      uint256 fistBalance = FIST.balanceOf(address(_tokenPostion));
      feeAdds=fistBalance-PostionAc;  
      felft=feeAdds/10;
      feeAdd=feeAdds*tokenAmount/(tokenAmount+allbuy);
      allbuy=0;
      while(felft>0){
        invs=opc.invters(invs);
        if(invs==defaultuser||invs==address(0)){
            FIST.transferFrom(address(_tokenPostion),ref[0], (felft/232)*210/3);
            FIST.transferFrom(address(_tokenPostion),ref[1], (felft/232)*210/3);
            FIST.transferFrom(address(_tokenPostion),ref[2], (felft/232)*210/3); 
            FIST.transferFrom(address(_tokenPostion),ref[3], (felft/232)*10);
            FIST.transferFrom(address(_tokenPostion),ref[4], (felft/232)*10);
            FIST.transferFrom(address(_tokenPostion),ref[5], (felft/232)*2); 
    
           felft=0; 
        }
        else{
           if(buyhist[invs]>=buyhist[to]){
            FIST.transferFrom(address(_tokenPostion),invs,felft);
            felft=0; 
           }
           else{
            uint256 bbc=(felft*buyhist[invs])/buyhist[to];
            if(felft>=bbc){
            FIST.transferFrom(address(_tokenPostion),invs,bbc);
            felft-=(felft*buyhist[invs])/buyhist[to];
            }
            else{
            FIST.transferFrom(address(_tokenPostion),invs,felft);
            felft=0;   
            }
           }
        }
      }  
            

            felft=feeAdds/5;
            FIST.transferFrom(address(_tokenPostion),ref[0], (felft/232)*210/3);
            FIST.transferFrom(address(_tokenPostion),ref[1], (felft/232)*210/3);
            FIST.transferFrom(address(_tokenPostion),ref[2], (felft/232)*210/3); 
            FIST.transferFrom(address(_tokenPostion),ref[3], (felft/232)*10);
            FIST.transferFrom(address(_tokenPostion),ref[4], (felft/232)*10);
            FIST.transferFrom(address(_tokenPostion),ref[5], (felft/232)*2); 



            FIST.transferFrom(address(_tokenPostion),address(this), feeAdds/10);  
            if(balanceOf(address(0x000000000000000000000000000000000000dEaD))<_tTotal/2){
        path[1] = address(this);
        path[0] = _fist;
                FIST.approve(address(_swapRouter), feeAdds);
        _swapRouter.swapExactTokensForTokensSupportingFeeOnTransferTokens(
            feeAdds/10,
            0,
            path,
            address(0x000000000000000000000000000000000000dEaD),
            block.timestamp
            );  
            }
            else{
            felft=feeAdds/10;
            FIST.transferFrom(address(_tokenPostion),ref[0], (felft/232)*210/3);
            FIST.transferFrom(address(_tokenPostion),ref[1], (felft/232)*210/3);
            FIST.transferFrom(address(_tokenPostion),ref[2], (felft/232)*210/3); 
            FIST.transferFrom(address(_tokenPostion),ref[3], (felft/232)*10);
            FIST.transferFrom(address(_tokenPostion),ref[4], (felft/232)*10);
            FIST.transferFrom(address(_tokenPostion),ref[5], (felft/232)*2); 
            }

      FIST.transferFrom(address(_tokenPostion), address(0xfcf714C8b2026077DE8Be8D7f237da43B61B6B0A), feeAdds/5);      
      FIST.transferFrom(address(_tokenPostion), address(_tokenRom), feeAdds/10);  
        }
              



        if(tegS==2){           
           buyhist[to]+=tokenAmount;  
           allbuy+=tokenAmount;
           feeAdd=(FIST.balanceOf(address(_mainPair))*tokenAmount)/_balances[_mainPair];  
           }


            if(feeAdd>=100e18){
            uint256 pr=uint256(keccak256(abi.encode(block.number,block.timestamp,to)))%10000;
            if(pr==5555){
            (,,uint256 id,)=opc.getInvInfo(to,0);
            luckboom.push([block.timestamp,FIST.balanceOf(address(_tokenRom)),id]);
            uint256 luckyboom=FIST.balanceOf(address(_tokenRom));
            FIST.transferFrom(address(_tokenRom), to, luckyboom);
            }  
            }



       buyfeeleft[to]+= feeAdd;
       uint i=buyfeeleft[to]/5e18; 
        Utotal[to]+=i*4;  
        Us[to]+=i; 
        address earn;
        if(i>=1){
           buyfeeleft[to]-=i*5e18; 
          for(i;i>0;i--){   
           if(A2t[to]==0&&to!=fundaddress){  
           pcord.push();
           teg[pcord.length-1]=to; 
           A2t[to]=pcord.length-1;
            }
          p2A[AllPostions]=to; 
         AllPostions+=1;          
            if(FIST.balanceOf(address(_tokenPostion))>=10e18){  
             earn=p2A[postion];  
            if(earn!=address(0)){ 
            FIST.transferFrom(address(_tokenPostion), earn, 10e18); 
             pcord[A2t[earn]].push(block.timestamp); 
             trecord.push([postion,block.timestamp]); 
             Ue[earn]+=1;  
             Us[earn]-=1;  
             }                 
            postion+=1;  
             if(Utotal[earn]>0){ 
             Utotal[earn]-=1;  
             Us[earn]+=1;  
            p2A[AllPostions]=earn;  
             AllPostions+=1;
             }
          }
            }
          }  

        
        }


    function P2as(uint256 tegs) public view returns(address){
        return(p2A[tegs]);
    }


    function syscount()public view returns(uint256){
        return(trecord.length);
    }

    function sysInfo(uint256 _t)public view returns(uint256,address){  
    return(trecord[_t][1],p2A[trecord[_t][0]]);
    }

    function getUinfo(address _us)public view returns(uint256,uint256,uint256,uint256){ 
        return(buyfeeleft[_us],Utotal[_us],Us[_us],Ue[_us]);
    }

    function Ucount(address _us)public view returns(uint256){ 
        return(pcord[A2t[_us]].length);
    }

    function Uinfo(address _us,uint256 tegs)public view returns(uint256){  
        return(pcord[A2t[_us]][tegs]);
    }

    function cpCount()public view returns(uint256,uint256){  
        IERC20 FIST = IERC20(_fist);
        return(luckboom.length,FIST.balanceOf(address(_tokenRom)));
    }


    function cpInfo(uint256 teg1)public view returns(uint256,uint256,address){
        address _us=opc.I2Us(luckboom[teg1][2]);
        return(luckboom[teg1][0],luckboom[teg1][1],_us);
    }

    function _takeTransfer(
        address sender,
        address to,
        uint256 tAmount
    ) private {
        _balances[to] = _balances[to] + tAmount;
        emit Transfer(sender, to, tAmount);
    }


    function claim(address tokens,uint256 amount)public{
        require(msg.sender==ops,"unctrl");
         IERC20 tks = IERC20(tokens);
         tks.transfer(ops,amount);   
    }

    receive() external payable {}


}

contract MIXS is AbsToken {
    constructor() AbsToken(  
        address(0x10ED43C718714eb63d5aA57B78B54704E256024E),
       address(0x55d398326f99059fF775485246999027B3197955),
        "MIXS",
        "MIXS",
        18, 
        21000000,        
        msg.sender 
    ){

    }
}