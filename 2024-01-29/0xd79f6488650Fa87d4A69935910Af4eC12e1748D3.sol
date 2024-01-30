/**
 * AGRONIUM - Creating A Sustainable World of Agro-Crypto Realities!
 *
 * SOCIALS
 * https://agroniumcoin.com
 * https://x.com/agronium_coin
 * https://instagram.com/agronium_coin_official
 * https://t.me/AGRONIUMCOINOFFICIAL
 *
 * TOKENOMICS
 * Presale: 31%
 * Liquidity: 14%
 * CEX Listing: 10%
 * Marketing: 12%
 * Staking: 10%
 * Airdrops: 3%
 * Burn: 20%
 */

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.15;

// OpenZeppelin Contracts v4.4.1 (utils/Context.sol)
abstract contract Context {

    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

// OpenZeppelin Contracts (last updated v4.7.0) (access/Ownable.sol)
abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor() {
        _transferOwnership(_msgSender());
    }

    modifier onlyOwner() {
        _checkOwner();
        _;
    }

    function owner() public view virtual returns (address) {
        return _owner;
    }

    function _checkOwner() internal view virtual {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
    }

    function renounceOwnership() public virtual onlyOwner {
        _transferOwnership(address(0));
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _transferOwnership(newOwner);
    }

    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}

// OpenZeppelin Contracts (last updated v4.6.0) (token/ERC20/IERC20.sol)
interface IERC20 {

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);

    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address to, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address from, address to, uint256 amount) external returns (bool);
}

// OpenZeppelin Contracts v4.4.1 (token/ERC20/extensions/IERC20Metadata.sol)
interface IERC20Metadata is IERC20 {

    function name() external view returns (string memory);
    function symbol() external view returns (string memory);
    function decimals() external view returns (uint8);
}

// OpenZeppelin Contracts (last updated v4.8.0) (token/ERC20/ERC20.sol)
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

    function transfer(address to, uint256 amount) public virtual override returns (bool) {
        address owner = _msgSender();
        _transfer(owner, to, amount);
        return true;
    }

    function allowance(address owner, address spender) public view virtual override returns (uint256) {
        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount) public virtual override returns (bool) {
        address owner = _msgSender();
        _approve(owner, spender, amount);
        return true;
    }

    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) public virtual override returns (bool) {
        address spender = _msgSender();
        _spendAllowance(from, spender, amount);
        _transfer(from, to, amount);
        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {
        address owner = _msgSender();
        _approve(owner, spender, allowance(owner, spender) + addedValue);
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {
        address owner = _msgSender();
        uint256 currentAllowance = allowance(owner, spender);
        require(currentAllowance >= subtractedValue, "ERC20: decreased allowance below zero");
        unchecked {
            _approve(owner, spender, currentAllowance - subtractedValue);
        }

        return true;
    }

    function _transfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");

        _beforeTokenTransfer(from, to, amount);

        uint256 fromBalance = _balances[from];
        require(fromBalance >= amount, "ERC20: transfer amount exceeds balance");
        unchecked {
            _balances[from] = fromBalance - amount;
            // Overflow not possible: the sum of all balances is capped by totalSupply, and the sum is preserved by
            // decrementing then incrementing.
            _balances[to] += amount;
        }

        emit Transfer(from, to, amount);

        _afterTokenTransfer(from, to, amount);
    }

    function _mint(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: mint to the zero address");

        _beforeTokenTransfer(address(0), account, amount);

        _totalSupply += amount;
        unchecked {
            // Overflow not possible: balance + amount is at most totalSupply + amount, which is checked above.
            _balances[account] += amount;
        }
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
            // Overflow not possible: amount <= accountBalance <= totalSupply.
            _totalSupply -= amount;
        }

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

    function _spendAllowance(
        address owner,
        address spender,
        uint256 amount
    ) internal virtual {
        uint256 currentAllowance = allowance(owner, spender);
        if (currentAllowance != type(uint256).max) {
            require(currentAllowance >= amount, "ERC20: insufficient allowance");
            unchecked {
                _approve(owner, spender, currentAllowance - amount);
            }
        }
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

interface DexFactory {
    function createPair(address tokenA, address tokenB) external returns (address pair);
}

interface DexRouter {
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
        returns (uint256 amountToken, uint256 amountETH, uint256 liquidity);

    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external;
}

contract Agronium is ERC20, Ownable {

    // State Variables
    uint256 private constant _totalSupply = 100_000_000 * 1e18;

    DexRouter public immutable uniswapRouter;
    address public immutable pairAddress;
    bool public tradingEnabled = false;
    uint256 public startTradingBlock;
    address public marketingWallet = 0x1b1D5e7243412Da0A87597d96535130Cbb8fa4CF;
    mapping(address => bool) private whitelisted;
    bool public swapAndLiquifyEnabled = true;
    uint256 public swapTokensAtAmount = _totalSupply / 100000;
    bool public isSwapping = false;

    // Structs
    struct Tax {
        uint256 marketingTax;
    }

    Tax public buyTaxes = Tax(0);
    Tax public sellTaxes = Tax(0);
    Tax public transferTaxes = Tax(0);

    // Events
    event marketingWalletChanged(address indexed _trWallet);
    event BuyFeesUpdated(uint256 indexed _trFee);
    event SellFeesUpdated(uint256 indexed _trFee);
    event TransferFeesUpdated(uint256 indexed _trFee);
    event SwapThresholdUpdated(uint256 indexed _newThreshold);
    event InternalSwapStatusUpdated(bool indexed _status);
    event Whitelist(address indexed _target, bool indexed _status);
    event ClearedETH(uint256 amount);
    event ClearedERC20(address tokenAddress, address to, uint256 amount);

    // Constructor
    constructor() ERC20("Agronium", "AGC") {

        uniswapRouter = DexRouter(0x10ED43C718714eb63d5aA57B78B54704E256024E); //MAIN BSC
        //uniswapRouter = DexRouter(0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D); //MAIN TEST ETH
        //uniswapRouter = DexRouter(0xD99D1c33F9fC3444f8101754aBC46c52416550D1); //TEST BSC

        pairAddress = DexFactory(uniswapRouter.factory()).createPair(
            address(this),
            uniswapRouter.WETH()
        );
        _mint(msg.sender, _totalSupply);
        whitelisted[msg.sender] = true;
        whitelisted[address(uniswapRouter)] = true;
        whitelisted[address(this)] = true;
    }

    // Public Functions
    function enableTrading() external onlyOwner {
        require(!tradingEnabled, "Trading is already enabled");
        tradingEnabled = true;
        startTradingBlock = block.number;
    }

    function setBuyTaxes(uint256 _marketingTax) external onlyOwner {
        require(_marketingTax <= 5, "Can not set buy fees higher than 5%");
        buyTaxes.marketingTax = _marketingTax;
        emit BuyFeesUpdated(_marketingTax);
    }

    function setSellTaxes(uint256 _marketingTax) external onlyOwner {
        require(_marketingTax <= 5, "Can not set buy fees higher than 5%");
        sellTaxes.marketingTax = _marketingTax;
        emit SellFeesUpdated(_marketingTax);
    }

    function setTransferFees(uint256 _transferTaxes) external onlyOwner {
        require(_transferTaxes <= 5, "Can not set transfer tax higher than 5%");
        transferTaxes.marketingTax = _transferTaxes;
        emit TransferFeesUpdated(_transferTaxes);
    }

    function setSwapTokensAtAmount(uint256 _newAmount) external onlyOwner {
        require(
            _newAmount > 0 && _newAmount <= (_totalSupply * 5) / 1000,
            "Minimum swap amount must be greater than 0 and less than 0.5% of total supply!"
        );
        swapTokensAtAmount = _newAmount;
        emit SwapThresholdUpdated(swapTokensAtAmount);
    }

    function toggleSwapping() external onlyOwner {
        swapAndLiquifyEnabled = (swapAndLiquifyEnabled) ? false : true;
    }

    function setWhitelistStatus(address _wallet, bool _status) external onlyOwner {
        whitelisted[_wallet] = _status;
        emit Whitelist(_wallet, _status);
    }

    function setmarketingWallet(address _newmarketing) external onlyOwner {
        require(
            _newmarketing != address(0),
            "can not set marketing to dead wallet"
        );
        marketingWallet = _newmarketing;
        emit marketingWalletChanged(_newmarketing);
    }

    function clearETH(uint256 weiAmount) external onlyOwner {	
        require(address(this).balance >= weiAmount, "Insufficient ETH balance");
        payable(msg.sender).transfer(weiAmount);	
        emit ClearedETH(weiAmount);
    }

    function clearERC20(address _tokenAddr, address _to, uint256 _amount) external onlyOwner {	
        require(_tokenAddr != address(this), "Owner can't claim native tokens");	
        IERC20(_tokenAddr).transfer(_to, _amount);	// Only interact with trusted ERC20 Tokens
        emit ClearedERC20(_tokenAddr, _to, _amount);
    }

    function checkWhitelist(address _wallet) external view returns (bool) {
        return whitelisted[_wallet];
    }

    // Internal Functions
    function _takeTax(
        address _from,
        address _to,
        uint256 _amount
    ) internal returns (uint256) {
        if (whitelisted[_from] || whitelisted[_to]) {
            return _amount;
        }
        uint256 totalTax = transferTaxes.marketingTax;

        if (_to == pairAddress) {
            totalTax = sellTaxes.marketingTax;
        } else if (_from == pairAddress) {
            totalTax = buyTaxes.marketingTax;
        }

        uint256 tax = 0;
        if (totalTax > 0) {
            tax = (_amount * totalTax) / 100;
            super._transfer(_from, address(this), tax);
        }
        return (_amount - tax);
    }

    function _transfer(
        address _from,
        address _to,
        uint256 _amount
    ) internal virtual override {
        require(_from != address(0), "Transfer from address zero");
        require(_to != address(0), "Transfer to address zero");
        require(_amount > 0, "Transfer amount must be greater than zero");
        uint256 toTransfer = _takeTax(_from, _to, _amount);

        bool canSwap = balanceOf(address(this)) >= swapTokensAtAmount;
        if (

            !whitelisted[_from] &&
            !whitelisted[_to] 
 
        ) {
        require(tradingEnabled, "Trading is not enabled");
            if (pairAddress == _to &&
                swapAndLiquifyEnabled &&
                canSwap&&
                !isSwapping  ) 
            {
        internalSwap();
            }
        }
        super._transfer(_from, _to, toTransfer);
    }

    function internalSwap() internal {
        isSwapping = true;
        uint256 taxAmount = balanceOf(address(this)); 
        if (taxAmount == 0) {
            return;
        }
        swapToETH(balanceOf(address(this)));
       (bool success, ) = marketingWallet.call{value: address(this).balance}("");
        require(success, "Transfer failed.");
        isSwapping = false;
    }

    // Private Functions
    function swapToETH(uint256 _amount) internal {
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = uniswapRouter.WETH();
        _approve(address(this), address(uniswapRouter), _amount);
        uniswapRouter.swapExactTokensForETHSupportingFeeOnTransferTokens(
            _amount,
            0,
            path,
            address(this),
            block.timestamp
        );
    }

    // Fallback and Receive Functions
    receive() external payable {}
}