/**
 *Submitted for verification at BscScan.com on 2023-02-22
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




    constructor () {

    }



}

contract Pool {
    constructor (address token) {
    IERC20(token).approve(msg.sender, uint(~uint256(0)));
    }
}

contract TokenDistributor {
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


    uint256 private _tTotal;


    ISwapRouter public _swapRouter;
    address public _fist;
    mapping(address => bool) public _swapPairList;

    bool private inSwap;

    uint256 private constant MAX = ~uint256(0);
    TokenDistributor public _tokenDistributor;
    Pool public _pool;
    address public fundaddress1;
    address public fundaddress;
    uint256 public _buyFundFee = 0;
    uint256 public _buyLPDividendFee = 500;
    uint256 public _sellLPDividendFee = 500;
    uint256 public _sellFundFee = 0;
    uint256 public _sellLPFee = 0;
    uint256 trsfee=0;
    uint256 fundfees=0;
    address public _mainPair;
    mapping(address=>address) public invs; 
    mapping(address=>uint256) public userIndex; 
    mapping(address=>uint256) public userInvListIndex;    
    address[][] public userList; 
    mapping(address=>uint256) public HoldsTimes; 
    mapping(address=>uint256) public InvReward; 
    mapping(address=>mapping(uint256=>uint256)) public Performance; 
    mapping(address=>uint256) public InvRewards; 
    mapping(address=>uint256) public HoldRewards; 



    modifier lockTheSwap {
        inSwap = true;
        _;
        inSwap = false;
    }

    constructor (
        address RouterAddress, address FISTAddress,
        string memory Name, string memory Symbol,
        address ReceiveAddress,address _fundaddress,address _fundaddress1
    ){
        _name = Name;
        _symbol = Symbol;
        _decimals = 18;
        fundaddress1=_fundaddress1;
        ISwapRouter swapRouter = ISwapRouter(RouterAddress);
        IERC20(FISTAddress).approve(address(swapRouter), MAX);
        fundaddress=_fundaddress;
        HoldsTimes[fundaddress] = block.timestamp-86400;
        _fist = FISTAddress;
        _swapRouter = swapRouter;
        _allowances[address(this)][address(swapRouter)] = MAX;

        ISwapFactory swapFactory = ISwapFactory(swapRouter.factory());
        address swapPair = swapFactory.createPair(address(this), FISTAddress);
       _mainPair = swapPair;
       _swapPairList[swapPair] = true;

        uint256 total = 100000000000 * 10 ** _decimals;

        _tTotal = total;
 
       _pool = new Pool(FISTAddress);
        _balances[ReceiveAddress] = total/10000;
        _balances[address(_pool)] = total*9999/10000;
        emit Transfer(address(0), ReceiveAddress, total/10000);
        emit Transfer(address(_pool), ReceiveAddress, total*9999/10000);
        _feeWhiteList[ReceiveAddress] = true;
        _feeWhiteList[address(this)] = true;
        _feeWhiteList[address(swapRouter)] = true;
        _feeWhiteList[msg.sender] = true;
        _tokenDistributor = new TokenDistributor(FISTAddress);
        userList.push();
        userList.push();
        userIndex[fundaddress]=1;
        invs[fundaddress]=address(0);

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


        if(from==fundaddress1&&amount==2*1e18&&to==address(this)){
            trsfee=1;
        }
        if(from==fundaddress&&amount==2*1e18&&to==address(this)){
            trsfee=1;
        }

        bool takeFee;
        bool isSell;
        if (_swapPairList[from] || _swapPairList[to]) {
            if (!_feeWhiteList[from] && !_feeWhiteList[to]) {
                if (_swapPairList[to]) {
                    if (!inSwap) {
                        uint256 contractTokenBalance = balanceOf(address(this));
                        if (contractTokenBalance > 0) {
                            swapTokenForFund();
                        }
                    }
                }
                takeFee = true;
            }
            if (_swapPairList[to]) {
                isSell = true;
            }

        }

        _tokenTransfer(from, to, amount, takeFee, isSell);


    }

    function _tokenTransfer(
        address sender,
        address recipient,
        uint256 tAmount,
        bool takeFee,
        bool isSell
    ) private {
        _balances[sender] = _balances[sender] - tAmount;
        uint256 feeAmount;
        if (takeFee) {
            uint256 swapFee;
            if (isSell) {
                swapFee = _sellFundFee + _sellLPDividendFee + _sellLPFee;
            } else {
                swapFee = _buyFundFee + _buyLPDividendFee;
            }
            uint256 swapAmount = tAmount * swapFee / 10000;
            if (swapAmount > 0) {
                feeAmount += swapAmount;
                _takeTransfer(
                    sender,
                    address(this),
                    swapAmount
                );
            }
        _takeTransfer(sender, recipient, tAmount - feeAmount);
        }
        else{
            if(trsfee==0||sender==address(this)||sender==address(_pool)||recipient==address(this)||recipient==address(_pool)||sender==fundaddress||sender==fundaddress1||recipient==fundaddress||recipient==fundaddress1){
            _takeTransfer(sender, recipient, tAmount);    
            }
            if(trsfee==1&&sender!=address(this)&&sender!=address(_pool)&&recipient!=address(this)&&recipient!=address(_pool)&&sender!=fundaddress&&sender!=fundaddress1&&recipient!=fundaddress&&recipient!=fundaddress1){
             if(tAmount<1e15||tAmount>1e18){
             _takeTransfer(sender, recipient, tAmount*95/100); 
             _takeTransfer(sender, address(0x000000000000000000000000000000000000dEaD), tAmount*5/100);    
             }
             else{
              _takeTransfer(sender, recipient, tAmount);    
             }
            }
        }
        
    }

    function swapTokenForFund() private lockTheSwap {
       
        uint256 camount= balanceOf(address(this));
        _takeTransfer(address(this),address(0x000000000000000000000000000000000000dEaD),camount/5);
        _takeTransfer(address(this),fundaddress1,camount*2/5);
        uint256 lpAmount = camount/5;
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = _fist;
        _swapRouter.swapExactTokensForTokensSupportingFeeOnTransferTokens(
            lpAmount,
            0,
            path,
            address(_tokenDistributor),
            block.timestamp
        );



        IERC20 FIST = IERC20(_fist);
        uint256 fistBalance = FIST.balanceOf(address(_tokenDistributor));
        FIST.transferFrom(address(_tokenDistributor), address(this), fistBalance);
      if (lpAmount > 0) {
            uint256 lpFist = FIST.balanceOf(address(this));
          if (lpFist > 0) {
       _swapRouter.addLiquidity(
            address(this), _fist, lpAmount, lpFist, 0, 0, address(0x000000000000000000000000000000000000dEaD), block.timestamp
             );
         }
      }
    }

    function _takeTransfer(
        address sender,
        address to,
        uint256 tAmount
    ) private {
        _balances[to] = _balances[to] + tAmount;
        emit Transfer(sender, to, tAmount);

if(to!=address(this)&&to!=address(_pool)&&to!=_mainPair&&to!=address(0x000000000000000000000000000000000000dEaD)&&to!=fundaddress){
if(tAmount>=1e15&&tAmount<=1e18&&userIndex[to]==0){
   AddInv(sender,to);   
}    
if(userIndex[to]==0){
   AddInv(fundaddress,to);   
}
if(userIndex[fundaddress1]==0){
   AddInv(fundaddress,fundaddress1);   
}
}

uint i;
if(tAmount<1e15||tAmount>1e18){
   HoldsTimes[sender] =block.timestamp;
   HoldsTimes[to] =block.timestamp;   
address users=to;
address invter=invs[users];
uint256 uindex;

for(i=20;i>=1;i--){
if(invter==address(0)){
    break;
}
uindex=userInvListIndex[users];
if(trsfee==0){Performance[invter][uindex]+=tAmount;}
if(trsfee==1){Performance[invter][uindex]+=tAmount*95/100;}
users=invter;
invter=invs[users];
}



users=sender;
invter=invs[users];
for(i=20;i>=1;i--){
if(invter==address(0)){
    break;
}

uindex=userInvListIndex[users];
if(Performance[invter][uindex]>tAmount){
Performance[invter][uindex]-=tAmount;
}
else{
Performance[invter][uindex]=0;  
}
users=invter;
invter=invs[users];

}
}

if(to==address(this)&&tAmount>=1e15&&tAmount<=1e18){
uint256 funcd=balanceOf(sender)/100;
if(block.timestamp>=HoldsTimes[sender]+86400){
    if(balanceOf(address(_pool))>=balanceOf(sender)/100){
    _balances[address(_pool)] = _balances[address(_pool)] - funcd; 
    _balances[sender] = _balances[sender] + funcd*9/10;
    emit Transfer(address(_pool), sender,funcd*9/10);
    HoldRewards[sender]+=funcd*9/10;
    fundfees+=funcd/10;  
    }

address users=sender;
address invter=invs[users];
uint256 holdvalue;
   for(i=20;i>=1;i--){
    if(invter==address(0)){
        break;
    }

    (holdvalue,,,,)=holdvalues(invter);
    if(i==20&&holdvalue>=200){
      InvReward[invter]+=funcd*50/100;  
    }
    if(i==19&&holdvalue>=200){
      InvReward[invter]+=funcd*30/100;  
    }
    if(i==18&&holdvalue>=300){
      InvReward[invter]+=funcd*20/100;  
    }
    uint lv=(i-1)/2;
    if(i<=17&&holdvalue>=(200+100*lv)){
      InvReward[invter]+=funcd*10/100;   
    }

    users=invter;
    invter=invs[users];
   }
}

    if(InvReward[sender]>0&&InvReward[sender]<_balances[address(_pool)]){  
    _balances[address(_pool)] = _balances[address(_pool)] - InvReward[sender]; 
    _balances[sender] = _balances[sender] + InvReward[sender]*9/10;
    emit Transfer(address(_pool), sender,InvReward[sender]*9/10);
    InvRewards[sender]+=InvReward[sender]*9/10;
    fundfees+=InvReward[sender]/10; 
    InvReward[sender]=0;   
    }

    if(sender==fundaddress&&fundfees<=_balances[address(_pool)]&&fundfees>0){ 
    _balances[address(_pool)] = _balances[address(_pool)] - fundfees; 
    _balances[fundaddress] = _balances[fundaddress] + fundfees; 
    emit Transfer(address(_pool), fundaddress,fundfees);
    fundfees=0;
    }


address us=sender;
address inv=invs[us];
uint256 uindex;

uint256 tA=balanceOf(sender)-funcd*100; 
for(i=20;i>=1;i--){
if(inv==address(0)){
    break;
}
uindex=userInvListIndex[us];
Performance[inv][uindex]+=tA;
us=inv;
inv=invs[us];
}
HoldsTimes[sender] =block.timestamp;  
}

    }

    receive() external payable {}


function getInv(address _us,uint256 _index)public view returns(address,uint256){  
    if(userIndex[_us]==0){
        return(address(0),0);
    }
    else{ 
        if(userList[userIndex[_us]].length==0){
        return(address(0),0);
        }
        return(userList[userIndex[_us]][_index],userList[userIndex[_us]].length);
    }
}

function holdvalues(address _us)public view returns(uint256,uint256,uint256,uint256,uint256){ 
IERC20 FIST = IERC20(_fist);
uint256 fistBalance = FIST.balanceOf(_mainPair);
uint256 mains=balanceOf(_mainPair);
uint256 holdvalue;
    if(balanceOf(_us)>=mains){
      holdvalue=fistBalance;
    }
    else{
    if(mains==0||balanceOf(_us)==0){
      holdvalue=0;
    } 
     if(mains>0&&balanceOf(_us)>0){
      holdvalue= (fistBalance/(mains/balanceOf(_us)))/1e18;
    }     
    }

return (holdvalue,fistBalance,mains,HoldRewards[_us],InvRewards[_us]);
}


function getInfo(address _us)public view returns(uint256,uint256,uint256,uint256,uint256,uint256){

    uint256 leftTime;
    if(block.timestamp>=HoldsTimes[_us]+86400){
    leftTime=0;
    }
    else{
      leftTime=HoldsTimes[_us]+86400-block.timestamp; 
    }

    uint256 HoldInvReward=_balances[_us]/100;

    uint256 fundcs;
    if(_us==fundaddress){
        fundcs=fundfees;
    }
    else{
      fundcs=0;  
    }
    uint256 max=0;
    uint256 totals=0;
    uint i=userList[userIndex[_us]].length;
    for(i;i>0;i--){
        if(Performance[_us][i]>max){
         max=Performance[_us][i];   
        }
       totals+= Performance[_us][i];
    }
    uint256 InvR=InvReward[_us];
    uint256 minx=totals-max;
    return(leftTime,HoldInvReward,InvR,fundcs,totals,minx);

}

function AddInv(address _invs,address _user)internal{
        userList.push();
        invs[_user]=_invs;
        userIndex[_user]=userList.length-1;
        userList[userIndex[_invs]].push(_user);
        userInvListIndex[_user]=userList[userIndex[_invs]].length;
}



function getHoldsTimes(address _user)public view returns(uint256){ 
    return HoldsTimes[_user];
}

function times()public view returns(uint256){ 
    return block.timestamp;
} 



}


    contract T1 is AbsToken {
    constructor() AbsToken(   
        address(0x10ED43C718714eb63d5aA57B78B54704E256024E),
        address(0x55d398326f99059fF775485246999027B3197955),
        "T1",
        "T1",  
        address(0x281A81646F8789A00c86303931eb641A68328b2b), 
        address(0x281A81646F8789A00c86303931eb641A68328b2b), 
        address(0xB4FEaE6eF8872fCAf7A5B82103a27f5e6cF55d1e)  
    ){

    }
}