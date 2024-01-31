/**
 * BabyDogWif BEP20 Token Contract
 *
 * 1 Billion Fixed Supply
 * 5% Fixed Total Tax
 * No Adverse Owner Functions
 *
 */

//SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

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

    constructor () {
       
        _owner = msg.sender ;
        emit OwnershipTransferred(address(0), _owner);
    }

    function owner() public view returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(_owner == _msgSender() , "Ownable: caller is not the owner");
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

interface IERC20Metadata is IERC20 {

    function name() external view returns (string memory);
    function symbol() external view returns (string memory);
    function decimals() external view returns (uint8);
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

contract BabyDogWif is ERC20, Ownable {

    //Constant for total supply of 1 billion tokens
    uint256 private constant _totalSupply = 1_000_000_000 * 1e18;

    //DexRouter for interacting with the PancakeSwap DEX
    DexRouter public immutable uniswapRouter;

    //Pair address for liquidity pool on the DEX
    address public immutable pairAddress;

    //Struct for defining tax rates
    struct Tax {
        uint256 marketingTax;
    }

    //Tax rates for buying and selling
    Tax public buyTaxes = Tax(5);
    Tax public sellTaxes = Tax(5);

    //Mapping to keep track of addresses that are whitelisted from taxes/trade limits
    mapping(address => bool) private whitelisted;

    //Threshold for swapping tokens to BNB (0.001% of total supply)
    uint256 public swapTokensAtAmount = _totalSupply / 100000; //Once 0.001% of total supply is collected, swap it to BNB

    //Flags for managing swapping and trading
    bool public swapAndLiquifyEnabled = true;
    bool public isSwapping = false;
    bool public tradingEnabled = false;

    //Block number when trading starts
    uint256 public startTradingBlock;

    //Wallets for marketing and development funds
    address public marketingWallet = 0x430b2BB038Be0C31d72E722153BAbb7F7eE9edAF;
    address public developmentWallet = 0x4A82833D9B536f8aA4A3672e2209Ea14726E8aA9;

    //Events for logging changes and important actions
    event marketingWalletChanged(address indexed _trWallet);
    event developmentWalletChanged(address indexed _trWallet);
    event TradingStatusChanged(bool isEnabled);
    event TradingStarted(uint256 startBlock);
    event SwapThresholdUpdated(uint256 indexed _newThreshold);
    event SwapAndLiquifyEnabledChanged(bool isEnabled);
    event Whitelist(address indexed _target, bool indexed _status);
    event ClearedBNB(uint256 amount);
    event ClearedTokens(address tokenAddress, address to, uint256 amount);
    event TransferFailed(address recipient, uint256 amount);

    //Constructor to initialize the token and DEX settings
    constructor() ERC20("BabyDogWif", "BabyDogWif") {

        uniswapRouter = DexRouter(0x10ED43C718714eb63d5aA57B78B54704E256024E); //MAINNET-BEP20
        pairAddress = DexFactory(uniswapRouter.factory()).createPair(
            address(this),
            uniswapRouter.WETH()
        );
        whitelisted[msg.sender] = true;
        whitelisted[address(uniswapRouter)] = true;
        whitelisted[address(this)] = true;       
        _mint(msg.sender, _totalSupply);

    }

    //Owner-only functions
    function setmarketingWallet(address _newMarketing) external onlyOwner {
        require(_newMarketing != address(0), "Do not set marketing to dead wallet");
        marketingWallet = _newMarketing;
        emit marketingWalletChanged(_newMarketing);
    }

    function setdevelopmentWallet(address _newDevelopment) external onlyOwner {
        require(_newDevelopment != address(0), "Do not set development to dead wallet");
        developmentWallet = _newDevelopment;
        emit developmentWalletChanged(_newDevelopment);
    }

    function enableTrading() external onlyOwner {
        require(!tradingEnabled, "Trading is already enabled");
        tradingEnabled = true;
        startTradingBlock = block.number;
        emit TradingStatusChanged(true);
        emit TradingStarted(startTradingBlock);
    }

    function setSwapTokensAtAmount(uint256 _newAmount) external onlyOwner {
        require(_newAmount > 0 && _newAmount <= (_totalSupply * 5) / 1000, "Minimum swap amount must be greater than 0 and less than 0.5% of total supply!");
        swapTokensAtAmount = _newAmount;
        emit SwapThresholdUpdated(swapTokensAtAmount);
    }

    function toggleSwapping() external onlyOwner {
        swapAndLiquifyEnabled = !swapAndLiquifyEnabled;
        emit SwapAndLiquifyEnabledChanged(swapAndLiquifyEnabled);
    }

    function setWhitelistStatus(address _wallet, bool _status) external onlyOwner {
        whitelisted[_wallet] = _status;
        emit Whitelist(_wallet, _status);
    }

    function clearBNB(uint256 weiAmount) external onlyOwner {	
        require(address(this).balance >= weiAmount, "Insufficient BNB balance");
        payable(msg.sender).transfer(weiAmount);	
        emit ClearedBNB(weiAmount);
    }

    function clearTokens(address _tokenAddr, address _to, uint256 _amount) external onlyOwner {	
        require(_tokenAddr != address(this), "Owner can't claim native tokens");	
        IERC20(_tokenAddr).transfer(_to, _amount);	//Only interact with trusted ERC20 Tokens
        emit ClearedTokens(_tokenAddr, _to, _amount);
    }

    //View functions
    function checkWhitelist(address _wallet) external view returns (bool) {
        return whitelisted[_wallet];
    }

    //Takes tax from a transfer if neither the sender nor the recipient is whitelisted
    //Calculates the tax based on whether the transaction is a buy or sell
    function _takeTax(address _from, address _to, uint256 _amount) internal returns (uint256) {
    
        //Skip tax calculation if sender or receiver is whitelisted
        if (whitelisted[_from] || whitelisted[_to]) {
            return _amount;
        }

        uint256 totalTax = 0;
        //Determine the type of transaction and apply appropriate tax rate
            if (_to == pairAddress) {
        //Sell transaction
            totalTax = sellTaxes.marketingTax;
            } else if (_from == pairAddress) {
        //Buy transaction
            totalTax = buyTaxes.marketingTax;
        }

        uint256 tax = 0;
        //Calculate and transfer the tax amount to the contract if applicable
            if (totalTax > 0) {
            tax = (_amount * totalTax) / 100;
            super._transfer(_from, address(this), tax);
        }
        return (_amount - tax);
    }

    //Enforces trading activation and performs token swap if conditions are met
    function _transfer(address _from, address _to, uint256 _amount) internal virtual override {
        require(_from != address(0), "Transfer from address zero");
        require(_to != address(0), "Transfer to address zero");
        require(_amount > 0, "Transfer amount must be greater than zero");

        //Apply tax logic and get the amount to be transferred after tax
        uint256 toTransfer = _takeTax(_from, _to, _amount);

        //Check if token swap can be triggered
        bool canSwap = balanceOf(address(this)) >= swapTokensAtAmount;
        if (!whitelisted[_from] && !whitelisted[_to]) {
            require(tradingEnabled, "Trading is not active");
            // Trigger swap if selling to pair, swapping enabled, can swap, and not currently swapping
            if (pairAddress == _to && swapAndLiquifyEnabled && canSwap && !isSwapping) {
                internalSwap();
            }
        }

        //Perform the standard ERC20 token transfer
        super._transfer(_from, _to, toTransfer);
    }

    //Transfers collected tax to appropriate wallets
    function internalSwap() internal {
        isSwapping = true;
        uint256 taxAmount = balanceOf(address(this)); 
        if (taxAmount == 0) {
            return;
        }

        //Perform the token swap to BNB
        //Calculate the amount to transfer to each wallet
        swapToETH(balanceOf(address(this)));
        (bool success, ) = marketingWallet.call{value: address(this).balance*2/5}("");
        (bool success2, ) = developmentWallet.call{value: address(this).balance}("");

        if (!success) {
            emit TransferFailed(marketingWallet, address(this).balance);
        } else {
            isSwapping = false;
        }
        if (!success2) {
            emit TransferFailed(developmentWallet, address(this).balance);
        } else {
            isSwapping = false;
        }
    }

    //Swaps the contract tokens for BNB using DEX
    function swapToETH(uint256 _amount) internal {
        //Define the swap path (token to BNB)
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = uniswapRouter.WETH();

        //Approve the Uniswap router to spend the tokens
        _approve(address(this), address(uniswapRouter), _amount);

        //Execute the swap from tokens to BNB
        uniswapRouter.swapExactTokensForETHSupportingFeeOnTransferTokens(
            _amount,
            0, //Minimum amount of BNB to accept in return
            path,
            address(this), //Recipient of the BNB
            block.timestamp //Deadline for the swap
        );
    }

    receive() external payable {}
}