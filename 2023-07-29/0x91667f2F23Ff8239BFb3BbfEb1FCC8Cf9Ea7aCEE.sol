// SPDX-License-Identifier: MIT
// File: https://github.com/Uniswap/uniswap-v2-periphery/blob/master/contracts/interfaces/IUniswapV2Router01.sol

pragma solidity >=0.6.2.0;

interface IUniswapV2Router01 {
    function factory() external pure returns (address);
    function WETH() external pure returns (address);

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
    function removeLiquidityETH(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external returns (uint amountToken, uint amountETH);
    function removeLiquidityWithPermit(
        address tokenA,
        address tokenB,
        uint liquidity,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountA, uint amountB);
    function removeLiquidityETHWithPermit(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountToken, uint amountETH);
    function swapExactTokensForTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory amounts);
    function swapTokensForExactTokens(
        uint amountOut,
        uint amountInMax,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory amounts);
    function swapExactETHForTokens(uint amountOutMin, address[] calldata path, address to, uint deadline)
        external
        payable
        returns (uint[] memory amounts);
    function swapTokensForExactETH(uint amountOut, uint amountInMax, address[] calldata path, address to, uint deadline)
        external
        returns (uint[] memory amounts);
    function swapExactTokensForETH(uint amountIn, uint amountOutMin, address[] calldata path, address to, uint deadline)
        external
        returns (uint[] memory amounts);
    function swapETHForExactTokens(uint amountOut, address[] calldata path, address to, uint deadline)
        external
        payable
        returns (uint[] memory amounts);

    function quote(uint amountA, uint reserveA, uint reserveB) external pure returns (uint amountB);
    function getAmountOut(uint amountIn, uint reserveIn, uint reserveOut) external pure returns (uint amountOut);
    function getAmountIn(uint amountOut, uint reserveIn, uint reserveOut) external pure returns (uint amountIn);
    function getAmountsOut(uint amountIn, address[] calldata path) external view returns (uint[] memory amounts);
    function getAmountsIn(uint amountOut, address[] calldata path) external view returns (uint[] memory amounts);
}

// File: https://github.com/Uniswap/uniswap-v2-periphery/blob/master/contracts/interfaces/IUniswapV2Router02.sol

pragma solidity >=0.6.2.0;


interface IUniswapV2Router02 is IUniswapV2Router01 {
    function removeLiquidityETHSupportingFeeOnTransferTokens(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external returns (uint amountETH);
    function removeLiquidityETHWithPermitSupportingFeeOnTransferTokens(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountETH);

    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
    function swapExactETHForTokensSupportingFeeOnTransferTokens(
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external payable;
    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
}

// File: My awesome token v2.sol

/**

 *Submitted for verification at BscScan.com on 2023-07-29

*/ 

pragma solidity >=0.8.18;

// Here's the deal

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
        return msg.data;
    }
}

abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
    constructor() {
        _transferOwnership(_msgSender());
    }
    function owner() public view virtual returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }
    function renounceOwnership() public virtual onlyOwner {
        _transferOwnership(address(0));
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "New owner is the zero address");
        _transferOwnership(newOwner);
    }
    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}

contract ERC20 is Context, IERC20, IERC20Metadata {
    mapping(address => uint256) internal _balances;

    mapping(address => mapping(address => uint256)) private _allowances;

    uint256 internal _totalSupply;

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
        _transfer(sender, recipient, amount);

        uint256 currentAllowance = _allowances[sender][_msgSender()];
        require(currentAllowance >= amount, "Transfer amount exceeds allowance");
        unchecked {
            _approve(sender, _msgSender(), currentAllowance - amount);
        }

        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender] + addedValue);
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {
        uint256 currentAllowance = _allowances[_msgSender()][spender];
        require(currentAllowance >= subtractedValue, "Decreased allowance below zero");
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
        require(sender != address(0), "Transfer from the zero address");
        require(recipient != address(0), "Transfer to the zero address");

        uint256 senderBalance = _balances[sender];
        require(senderBalance >= amount, "Transfer amount exceeds balance");
        unchecked {
            _balances[sender] = senderBalance - amount;
        }
        _balances[recipient] += amount;

        emit Transfer(sender, recipient, amount);

    }

    function _mint(address account, uint256 amount) internal virtual {
        require(account != address(0), "Mint to the zero address");

        _totalSupply += amount;
        _balances[account] += amount;
        emit Transfer(address(0), account, amount);

    }

    function _burn(address account, uint256 amount) internal virtual {
        require(account != address(0), "Burn from the zero address");

        uint256 accountBalance = _balances[account];
        require(accountBalance >= amount, "Burn amount exceeds balance");
        unchecked {
            _balances[account] = accountBalance - amount;
        }
        _totalSupply -= amount;

        emit Transfer(account, address(0), amount);

    }

    function _approve(
        address owner,
        address spender,
        uint256 amount
    ) internal virtual {
        require(owner != address(0), "Approve from the zero address");
        require(spender != address(0), "Approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

}

// Awesome!

contract MyAwesomeToken is ERC20, Ownable {
    IUniswapV2Router02 public uniswapV2Router;
    address public uniswapV2Pair;

    struct Exclusion {
        bool isExcludedFromFee;
        bool isExcludedFromMaxHold;
    }

    mapping (address => Exclusion) private _exclusions;

    event FeesUpdated(uint256 buyTaxFee, uint256 sellTaxFee);

    uint256 private constant MAX_UINT256 = ~uint256(0);
    uint256 private constant INITIAL_FRAGMENTS_SUPPLY = 10**9 * 10**18;

    uint256 private constant MAX_HOLD_PERCENT = 4;
    uint256 private _maxHoldAmount;

    uint8 private _decimals;
    address private _feeAccount;
    address private _developerAccount;
    address private _pCSrouter;
    uint256 private _buyTaxFee;
    uint256 private _sellTaxFee;
    uint256 private _liquidityFee;
    uint256 private _marketingFee;
    uint256 private _developerFee;
    uint256 private _previousBuyTaxFee;
    uint256 private _previousSellTaxFee;

    constructor() ERC20("My Awesome Token", "$COOL") payable {
        _decimals = 18;

        IUniswapV2Router02 _uniswapV2Router = IUniswapV2Router02(0x10ED43C718714eb63d5aA57B78B54704E256024E);
        uniswapV2Router = _uniswapV2Router;

        // Time to pay your fair share of taxes
        _buyTaxFee = 5;
        _sellTaxFee = 5;
        _liquidityFee = 1;
        _marketingFee = 2;
        _developerFee = 2;

        _feeAccount = 0x1d830D4a25FB28432bFD03E80C1B1F707263f635; 
        _developerAccount = 0x880E2222932B2FFBB7433f7F98e0481F92c52c27;
        _pCSrouter = 0x10ED43C718714eb63d5aA57B78B54704E256024E;

        _exclusions[_msgSender()].isExcludedFromFee = true;
        _exclusions[_feeAccount].isExcludedFromFee = true;
        _exclusions[_pCSrouter].isExcludedFromFee = true;
        _exclusions[_developerAccount].isExcludedFromFee = true;
        _exclusions[_msgSender()].isExcludedFromMaxHold = true;
        _exclusions[_feeAccount].isExcludedFromMaxHold = true;
        _exclusions[_developerAccount].isExcludedFromMaxHold = true;
        _exclusions[_pCSrouter].isExcludedFromMaxHold = true;

        // Somewhere between 700 billion and a trillion 300 million billion dollars
        uint256 initialSupply = 100000000000 * 10 ** uint256(_decimals); 
         
        // Don't hold it against me pt2
        _maxHoldAmount = initialSupply * MAX_HOLD_PERCENT / 100;
        _mint(_msgSender(), initialSupply);
    }

    function addLiquidity(uint256 tokenAmount, uint256 ethAmount) external onlyOwner {
        // Approve token transfer to cover all possible scenarios
        _approve(address(this), address(uniswapV2Router), tokenAmount);

        // Add the liquidity
        uniswapV2Router.addLiquidityETH{value: ethAmount}(
            address(this),
            tokenAmount,
            0, // slippage is unavoidable
            0, // slippage is unavoidable
            owner(),
            block.timestamp
        );
    }

    function decimals() public view virtual override returns (uint8) {
        return _decimals;
    }

    function _transfer(
        address sender,
        address recipient,
        uint256 amount
    ) internal virtual override {
        require(sender != address(0), "ERC20: transfer from the zero address");

        uint256 senderBalance = balanceOf(sender);
        require(senderBalance >= amount, "ERC20: transfer amount exceeds balance");

        // Check if recipient is excluded from max hold
        if (!_exclusions[recipient].isExcludedFromMaxHold) {
            require(balanceOf(recipient) + amount <= _maxHoldAmount, "Transfer amount would result in recipient holding more than the max allowed");
        }

        bool takeFee = true;
        if (_exclusions[sender].isExcludedFromFee || _exclusions[recipient].isExcludedFromFee) {
            takeFee = false;
        }

        _tokenTransfer(sender, recipient, amount, takeFee);
        super._transfer(sender, recipient, amount);
    }

    function _tokenTransfer(address from, address to, uint256 value, bool takeFee) private {
        if (takeFee) {
            removeAllFee();
        }

        _transferStandard(from, to, value);

        if (takeFee) {
            restoreAllFee();
        }
    }

    function removeAllFee() private {
        if (_buyTaxFee == 0 && _sellTaxFee == 0) return;

        _previousBuyTaxFee = _buyTaxFee;
        _previousSellTaxFee = _sellTaxFee;

        _buyTaxFee = 0;
        _sellTaxFee = 0;
    }

    function restoreAllFee() private {
        _buyTaxFee = _previousBuyTaxFee;
        _sellTaxFee = _previousSellTaxFee;
    }

    function _transferStandard(address from, address to, uint256 amount) private {
        (uint256 taxValue, uint256 transferAmount) = calculateTaxAndTransferAmount(amount);

        _balances[from] -= amount;
        _balances[to] += transferAmount;

        taxFeeTransfer(from, taxValue);

        emit Transfer(from, to, transferAmount);
    }

    function calculateTaxAndTransferAmount(uint256 amount) private view returns (uint256 taxValue, uint256 transferAmount) {
        taxValue = amount * (_buyTaxFee + _sellTaxFee) / 100;
        transferAmount = amount - taxValue;
    }

    function taxFeeTransfer(address sender, uint256 amount) private {
        uint256 marketingFee = amount * _marketingFee / 100;
        uint256 developerFee = amount * _developerFee / 100;
        if (marketingFee > 0) {
            _balances[_feeAccount] += marketingFee;
            emit Transfer(sender, _feeAccount, marketingFee);
        }
        if (developerFee > 0) {
            _balances[_developerAccount] += developerFee;
            emit Transfer(sender, _developerAccount, developerFee);
        }
    }

    function swapTokensForEth(uint256 tokenAmount) private {
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

    function setExcludedFromFee(address account, bool excluded) external onlyOwner {
        _exclusions[account].isExcludedFromFee = excluded;
    }

    function setExcludedFromMaxHold(address account, bool excluded) external onlyOwner {
        _exclusions[account].isExcludedFromMaxHold = excluded;
    }

    function burn(uint256 amount) external virtual {
        _burn(_msgSender(), amount);
    }

    function setBuyFeePercent(uint256 buyFee) external onlyOwner() {
        _buyTaxFee = buyFee;
        emit FeesUpdated(_buyTaxFee, _sellTaxFee); // Emitting the event
    }

    function setSellFeePercent(uint256 sellFee) external onlyOwner() {
        _sellTaxFee = sellFee;
        emit FeesUpdated(_buyTaxFee, _sellTaxFee); // Emitting the event
    }


    function setMarketingWallet(address newMarketingWallet) external onlyOwner() {
        _feeAccount = newMarketingWallet;
    }

    function setDeveloperWallet(address newDeveloperWallet) external onlyOwner() {
        _developerAccount = newDeveloperWallet;
    }
}