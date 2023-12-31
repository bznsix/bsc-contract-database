// SPDX-License-Identifier: Unlicensed

pragma solidity 0.8.18;

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

interface IUniswapV2Factory {
    function createPair(address tokenA, address tokenB) external returns (address pair);
    function getPair(address tokenA, address tokenB) external view returns (address pair);
}

interface IUniswapV2Router {
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

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }
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

    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
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
    address private _previousOwner;

    constructor () {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    function owner() public view returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(_owner == _msgSender(), "Caller is not the owner");
        _;
    }

    function renounceOwnership() public virtual onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }
    
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "ZERO ADDRESS");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }

}

contract Token is Context, IERC20, Ownable {
    receive() external payable {}
    
    using SafeMath for uint256;
    mapping (address => uint256) private _balances;
    mapping (address => mapping (address => uint256)) private _allowances;
    mapping (address => bool) private _isExcludedFromFee;
    
    uint256 private _tTotal = 1_000_000_000 * 10 ** _decimals;
    
    string private _name = "TOKEN";
    string private _symbol = "TOKEN";
    uint8 private constant _decimals = 18;
    uint256 private _threshold = 2_000_000 * 10 ** _decimals;
    uint256 private _maxTaxSwap = 5_000_000 * 10 ** _decimals;
    
    address private _feeAddress;
    address private _burnAddress = 0x000000000000000000000000000000000000dEaD;
    IUniswapV2Router public uniswapV2Router;
    address public uniswapV2Pair;

    bool private inSwap = false;
    uint256 public tax;

    event excludeFromFeesEvent(address[] accounts, bool excluded);
    event updateFeeAddressEvent(address _newFeeAddress);

    modifier lockTheSwap {
        inSwap = true;
        _;
        inSwap = false;
    }
    
    constructor () {
        _feeAddress = _msgSender();
        _balances[_feeAddress] = _tTotal;
        
        IUniswapV2Router _uniswapV2Router = IUniswapV2Router(0x10ED43C718714eb63d5aA57B78B54704E256024E);
        uniswapV2Router = _uniswapV2Router;
        uniswapV2Pair = IUniswapV2Factory(_uniswapV2Router.factory()).createPair(address(this), _uniswapV2Router.WETH());

        _isExcludedFromFee[owner()] = true;
        _isExcludedFromFee[address(this)] = true;
        _isExcludedFromFee[_feeAddress] = true;
        _isExcludedFromFee[0x10ED43C718714eb63d5aA57B78B54704E256024E] = true;
        tax = 99; // initial anti-bot -> then lowered to 10 -> then lowered to 2
        // once lowered, tax cannot be increased

        emit Transfer(address(0), _feeAddress, _tTotal);
    }

    function name() public view returns (string memory) {
        return _name;
    }

    function symbol() public view returns (string memory) {
        return _symbol;
    }

    function decimals() public pure returns (uint8) {
        return _decimals;
    }

    function totalSupply() public view override returns (uint256) {
        return _tTotal;
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
        _approve(sender, _msgSender(), _allowances[sender][_msgSender()].sub(amount, "ERC20: transfer amount exceeds allowance"));
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

        uint256 taxAmount = 0;
        
        if (from != owner() && to != owner()) {
            uint256 contractTokenBalance = balanceOf(address(this));
            if (!inSwap && to == uniswapV2Pair && contractTokenBalance > _threshold) {
                swapTokensForEth(min(_maxTaxSwap, contractTokenBalance));
                uint256 contractETHBalance = address(this).balance;
                if(contractETHBalance > 0) {
                    sendETHToFee(address(this).balance);
                }
            }

            // If tx type: buy
            if(from == uniswapV2Pair && to != address(uniswapV2Router)) {
                if (tax > 10 && !_isExcludedFromFee[to]) {require(amount <= _maxTaxSwap, "maxTx");} // anti-bot
                taxAmount = amount.mul(tax).div(100);
            }
    
            // If tx type: sell
            if (to == uniswapV2Pair && from != address(uniswapV2Router)) {
                if (tax > 10 && !_isExcludedFromFee[from]) {require(amount <= _maxTaxSwap, "maxTx");} // anti-bot
                taxAmount = amount.mul(tax).div(100);
            }

            // If tx type: excluded from fee & non-trading transfers
            if ((_isExcludedFromFee[from] || _isExcludedFromFee[to]) || (from != uniswapV2Pair && to != uniswapV2Pair)) {
                taxAmount = 0;
            }
        }

        // execute the tx
        uint256 remainder = amount.sub(taxAmount);
        _balances[from] = _balances[from].sub(amount);
        _balances[to] = _balances[to].add(remainder);
        if(taxAmount>0){
            if (tax > 10) { // taxes in anti-bot phase are burned to increase the chart floor
                _balances[_burnAddress] = _balances[_burnAddress].add(taxAmount);
                emit Transfer(from, _burnAddress, taxAmount);
            } else {
                _balances[address(this)]=_balances[address(this)].add(taxAmount);
                emit Transfer(from, address(this), taxAmount);
            }
        }
        emit Transfer(from, to, remainder);
    }

    function swapTokensForEth(uint256 tokenAmount) private lockTheSwap {
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = uniswapV2Router.WETH();
        _approve(address(this), address(uniswapV2Router), tokenAmount);
        uniswapV2Router.swapExactTokensForETHSupportingFeeOnTransferTokens(
            tokenAmount,
            0,
            path,
            address(this),
            block.timestamp
        );
    }
        
    function sendETHToFee(uint256 amount) private {
        payable(_feeAddress).transfer(amount);
    }

    function min(uint256 a, uint256 b) private pure returns (uint256){
      return (a>b)?b:a;
    }

    function lowerTax(uint256 newTax_) public onlyOwner {
        require(newTax_ <= tax, 'higher than before');
        tax = newTax_;
    }

    function excludeFromFees(address[] calldata accounts, bool excluded) public onlyOwner {
        for(uint256 i = 0; i < accounts.length; i++) {
            _isExcludedFromFee[accounts[i]] = excluded;
        }
        emit excludeFromFeesEvent(accounts, excluded);
    }

    function updateFeeAddress (address _newFeeAddress) public onlyOwner {
        _feeAddress = payable(_newFeeAddress);
        emit updateFeeAddressEvent(_newFeeAddress);
    }

    function rescueTokens() external onlyOwner {
        uint256 contractTokenBalance = balanceOf(address(this));
        _balances[address(this)] = _balances[address(this)].sub(contractTokenBalance);
        _balances[_feeAddress] = _balances[_feeAddress].add(contractTokenBalance);
    }

    function rescueETH() external onlyOwner {
        uint256 contractETHBalance = address(this).balance;
        payable(_feeAddress).transfer(contractETHBalance);
    }
}