// SPDX-License-Identifier: MIT
pragma solidity 0.8.18;

interface IERC20 {
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

interface IERC20Metadata is IERC20 {
    function name() external view returns (string memory);
    function symbol() external view returns (string memory);
    function decimals() external view returns (uint8);
}

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}

abstract contract Ownable is Context {
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

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

contract ERC20 is Context, IERC20, IERC20Metadata {
    mapping(address => uint256) private _balances;

    mapping(address => mapping(address => uint256)) private _allowances;

    uint256 private _totalSupply;

    string private _name;
    string private _symbol;

    constructor(string memory name_, string memory symbol_) {
        _name = name_;
        _symbol = symbol_;
    }

    function name() public view virtual override returns (string memory) {
        return _name;
    }

    function symbol() public view virtual override returns (string memory) {
        return _symbol;
    }

    function decimals() public view virtual override returns (uint8) {
        return 18;
    }

    function totalSupply() public view virtual override returns (uint256) {
        return _totalSupply;
    }

    function balanceOf(address account) public view virtual override returns (uint256) {
        return _balances[account];
    }

    function transfer(address recipient, uint256 amount) public virtual override returns (bool) {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    function allowance(address owner, address spender) public view virtual override returns (uint256) {
        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount) public virtual override returns (bool) {
        _approve(_msgSender(), spender, amount);
        return true;
    }

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) public virtual override returns (bool) {
        uint256 currentAllowance = _allowances[sender][_msgSender()];
        if (currentAllowance != type(uint256).max) {
            require(currentAllowance >= amount, "ERC20: transfer amount exceeds allowance");
            unchecked {
                _approve(sender, _msgSender(), currentAllowance - amount);
            }
        }

        _transfer(sender, recipient, amount);

        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender] + addedValue);
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {
        uint256 currentAllowance = _allowances[_msgSender()][spender];
        require(currentAllowance >= subtractedValue, "ERC20: decreased allowance below zero");
        unchecked {
            _approve(_msgSender(), spender, currentAllowance - subtractedValue);
        }

        return true;
    }

    function _transfer(
        address sender,
        address recipient,
        uint256 amount
    ) internal virtual {
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");

        _beforeTokenTransfer(sender, recipient, amount);

        uint256 senderBalance = _balances[sender];
        require(senderBalance >= amount, "ERC20: transfer amount exceeds balance");
        unchecked {
            _balances[sender] = senderBalance - amount;
        }
        _balances[recipient] += amount;

        emit Transfer(sender, recipient, amount);

        _afterTokenTransfer(sender, recipient, amount);
    }

    function _mint(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: mint to the zero address");

        _beforeTokenTransfer(address(0), account, amount);

        _totalSupply += amount;
        _balances[account] += amount;
        emit Transfer(address(0), account, amount);

        _afterTokenTransfer(address(0), account, amount);
    }

    function _burn(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: burn from the zero address");

        _beforeTokenTransfer(account, address(0), amount);

        uint256 accountBalance = _balances[account];
        require(accountBalance >= amount, "ERC20: burn amount exceeds balance");
        unchecked {
            _balances[account] = accountBalance - amount;
        }
        _totalSupply -= amount;

        emit Transfer(account, address(0), amount);

        _afterTokenTransfer(account, address(0), amount);
    }

    function _approve(
        address owner,
        address spender,
        uint256 amount
    ) internal virtual {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {}

    function _afterTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {}
}

interface IUniswapV2Factory {
    function createPair(address tokenA, address tokenB) external returns (address pair);
}

interface IUniswapV2Router02 {
    function factory() external pure returns (address);
    function WETH() external pure returns (address);
    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
}

contract BABYCATCEO is ERC20, Ownable {

    uint256 public marketingFeeOnBuy    = 5;
    uint256 public marketingFeeOnSell   = 5;

    address public marketingWallet = 0x0ed632051736FA2A2D2B1a8F75cEF3eB85042524;

    IUniswapV2Router02 public uniswapV2Router;
    address public  uniswapV2Pair;
    
    address private DEAD = 0x000000000000000000000000000000000000dEaD;

    bool    private swapping;
    uint256 public swapTokensAtAmount;
    bool    public tradingEnabled = false;

    mapping (address => bool) private _isExcludedFromFees;
    mapping (address => bool) private _isExcludedFromLimits;
    mapping (address => bool) public automatedMarketMakerPairs;

    event ExcludeFromFees(address indexed account, bool isExcluded);
    event ExcludeFromLimits(address indexed account, bool isExcluded);
    event MarketingWalletChanged(address indexed newWallet);
    event MarketingFeeOnBuyChanged(uint256 newFee);
    event MarketingFeeOnSellChanged(uint256 newFee);
    event TradingEnabled(bool value);
    event SetAutomatedMarketMakerPair(address indexed pair, bool indexed value);

    constructor () ERC20("BABY CAT CEO", "BCCO") 
    {   
        super.transferOwnership(0x0E9E08e6A143043370453BCAF2cc5cc659FfD6C6);
        IUniswapV2Router02 _uniswapV2Router = IUniswapV2Router02(0x10ED43C718714eb63d5aA57B78B54704E256024E);

        address _uniswapV2Pair = IUniswapV2Factory(_uniswapV2Router.factory())
            .createPair(address(this), _uniswapV2Router.WETH());

        uniswapV2Router = _uniswapV2Router;
        uniswapV2Pair   = _uniswapV2Pair;

        _approve(address(this), address(uniswapV2Router), type(uint256).max);

        _setAutomatedMarketMakerPair(_uniswapV2Pair, true);

        _isExcludedFromFees[owner()] = true;
        _isExcludedFromFees[DEAD] = true;
        _isExcludedFromFees[address(this)] = true;
        _isExcludedFromFees[marketingWallet] = true;
        
        _isExcludedFromLimits[owner()] = true;
        _isExcludedFromLimits[DEAD] = true;
        _isExcludedFromLimits[address(this)] = true;
        _isExcludedFromLimits[marketingWallet] = true;
        _isExcludedFromLimits[address(0)] = true;
        
        _mint(owner(), 1e12 * (10 ** 18));
        swapTokensAtAmount = totalSupply() / 5000;
    }

    receive() external payable {

}

    function claimStuckTokens(address token) external onlyOwner {
        require(token != address(this), "Owner cannot claim native tokens");
        if (token == address(0x0)) {
            payable(msg.sender).transfer(address(this).balance);
            return;
        }
        IERC20 ERC20token = IERC20(token);
        uint256 balance = ERC20token.balanceOf(address(this));
        ERC20token.transfer(msg.sender, balance);
    }

    function isContract(address account) internal view returns (bool) {
        return account.code.length > 0;
    }

    function sendETH(address payable recipient, uint256 amount) internal {
        require(address(this).balance >= amount, "Address: insufficient balance");

        (bool success, ) = recipient.call{value: amount}("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }

    function _setAutomatedMarketMakerPair(address pair, bool value) private {
        require(automatedMarketMakerPairs[pair] != value, "Automated market maker pair is already set to that value");
        automatedMarketMakerPairs[pair] = value;

        emit SetAutomatedMarketMakerPair(pair, value);
    }

    function changeMarketingWallet(address newWallet) external onlyOwner {
        require(newWallet != address(0), "Wallet cannot be the zero address");
        require(!isContract(newWallet), "Wallet cannot be a contract");
        require(newWallet != marketingWallet, "Wallet is already the value of 'newWallet'");

        _isExcludedFromFees[marketingWallet] = false;
        _isExcludedFromLimits[marketingWallet] = false;
        marketingWallet = newWallet;
        _isExcludedFromFees[newWallet] = true;
        _isExcludedFromLimits[newWallet] = true;

        emit MarketingWalletChanged(newWallet);
    }

    function excludeFromFees(address account, bool excluded) external onlyOwner {
        require(_isExcludedFromFees[account] != excluded, "Account is already the value of 'excluded'");
        _isExcludedFromFees[account] = excluded;

        emit ExcludeFromFees(account, excluded);
    }

    function isExcludedFromFees(address account) public view returns(bool) {
        return _isExcludedFromFees[account];
    }

    function changeMarketingFeeOnBuy(uint256 newFee) external onlyOwner {
        require(newFee <= 10, "Fee cannot be greater than 10%");
        require(newFee != marketingFeeOnBuy, "Fee is already the value of 'newFee'");

        marketingFeeOnBuy = newFee;

        emit MarketingFeeOnBuyChanged(newFee);
    }

    function changeMarketingFeeOnSell(uint256 newFee) external onlyOwner {
        require(newFee <= 10, "Fee cannot be greater than 10%");
        require(newFee != marketingFeeOnSell, "Fee is already the value of 'newFee'");

        marketingFeeOnSell = newFee;

        emit MarketingFeeOnSellChanged(newFee);
    }

    function excludeFromLimits(address account, bool excluded) external onlyOwner {
        require(_isExcludedFromLimits[account] != excluded, "Account is already the value of 'excluded'");
        _isExcludedFromLimits[account] = excluded;

        emit ExcludeFromLimits(account, excluded);
    }

    function isExcludedFromLimits(address account) public view returns(bool) {
        return _isExcludedFromLimits[account];
    }

    function enableTrading() external onlyOwner {
        require(!tradingEnabled, "Trading is already enabled");
        tradingEnabled = true;

        emit TradingEnabled(true);
    }

    function _transfer(
        address from,
        address to,
        uint256 amount
    ) internal  override {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");

        if(amount == 0) {
            super._transfer(from, to, 0);
            return;
        }

        if(!_isExcludedFromLimits[from] && !_isExcludedFromLimits[to]) {
            require(tradingEnabled, "Trading is not enabled");
        }

		uint256 contractTokenBalance = balanceOf(address(this));

        bool canSwap = contractTokenBalance >= swapTokensAtAmount;

        if( canSwap &&
            !swapping &&
            !automatedMarketMakerPairs[from] &&
            !_isExcludedFromFees[from] &&
            !_isExcludedFromFees[to]
        ) {
            swapping = true;

            uint256 initialBalance = address(this).balance;

            address[] memory path = new address[](2);
            path[0] = address(this);
            path[1] = uniswapV2Router.WETH();

            uniswapV2Router.swapExactTokensForETHSupportingFeeOnTransferTokens(
                contractTokenBalance,
                0, // accept any amount of ETH
                path,
                address(this),
                block.timestamp);

            uint256 newBalance = address(this).balance - initialBalance;

            sendETH(payable(marketingWallet), newBalance);

            swapping = false;
        }

        bool takeFee = !swapping;

        if((_isExcludedFromFees[from] || _isExcludedFromFees[to]) || ( from != uniswapV2Pair && to != uniswapV2Pair)){
            takeFee = false;
        }

        if(takeFee) {
            uint256 _totalFees = 0;
            if(from == uniswapV2Pair) {
                _totalFees = marketingFeeOnBuy;
            } else if(to == uniswapV2Pair) {
                _totalFees = marketingFeeOnSell;
            }

            if (_totalFees > 0) {
                uint256 fees = amount * _totalFees / 100;
                amount = amount - fees;
                super._transfer(from, address(this), fees);
            }
        }

        super._transfer(from, to, amount);

    }

    function setSwapTokensAtAmount(uint256 newAmount) external onlyOwner{
        require(newAmount > totalSupply() / 100000, "SwapTokensAtAmount must be greater than 0.001% of total supply");
        swapTokensAtAmount = newAmount;
    }

}