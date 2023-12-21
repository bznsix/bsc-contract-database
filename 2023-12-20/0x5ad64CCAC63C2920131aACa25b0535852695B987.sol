//SPDX-License-Identifier: MIT

 /* 
  * |=============|======= 
  * Iron Bar - It's just an iron bar
  * Telegram : https://t.me/ironbarbsc
  *
*/

pragma solidity ^0.8.18;

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        this;
        return msg.data;
    }
}

interface IERC20 {
    function totalSupply() external view returns (uint256);

    function balanceOf(address account) external view returns (uint256);

    function transfer(
        address recipient,
        uint256 amount
    ) external returns (bool);

    function allowance(
        address owner,
        address spender
    ) external view returns (uint256);

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

interface IERC20Metadata is IERC20 {
    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);
}

contract ERC20 is Context, IERC20, IERC20Metadata {
    mapping(address => uint256) internal _balances;

    mapping(address => mapping(address => uint256)) internal _allowances;

    uint256 private _totalSupply;

    string private _name;
    string private _symbol;

    /**
     * @dev Sets the values for {name} and {symbol}.
     *
     * The defaut value of {decimals} is 9. To select a different value for
     * {decimals} you should overload it.
     *
     * All two of these values are immutable: they can only be set once during
     * construction.
     */
    constructor(string memory name_, string memory symbol_) {
        _name = name_;
        _symbol = symbol_;
    }

    /**
     * @dev Returns the name of the token.
     */
    function name() public view virtual override returns (string memory) {
        return _name;
    }

    /**
     * @dev Returns the symbol of the token, usually a shorter version of the
     * name.
     */
    function symbol() public view virtual override returns (string memory) {
        return _symbol;
    }

    /**
     * @dev Returns the number of decimals used to get its user representation.
     * For example, if `decimals` equals `2`, a balance of `505` tokens should
     * be displayed to a user as `5,05` (`505 / 10 ** 2`).
     *
     * Tokens usually opt for a value of 9, imitating the relationship between
     * Ether and Wei. This is the value {ERC20} uses, unless this function is
     * overridden;
     *
     * NOTE: This information is only used for _display_ purposes: it in
     * no way affects any of the arithmetic of the contract, including
     * {IERC20-balanceOf} and {IERC20-transfer}.
     */
    function decimals() public view virtual override returns (uint8) {
        return 9;
    }

    /**
     * @dev See {IERC20-totalSupply}.
     */
    function totalSupply() public view virtual override returns (uint256) {
        return _totalSupply;
    }

    /**
     * @dev See {IERC20-balanceOf}.
     */
    function balanceOf(
        address account
    ) public view virtual override returns (uint256) {
        return _balances[account];
    }

    /**
     * @dev See {IERC20-transfer}.
     *
     * Requirements:
     *
     * - `recipient` cannot be the zero address.
     * - the caller must have a balance of at least `amount`.
     */
    function transfer(
        address recipient,
        uint256 amount
    ) public virtual override returns (bool) {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    /**
     * @dev See {IERC20-allowance}.
     */
    function allowance(
        address owner,
        address spender
    ) public view virtual override returns (uint256) {
        return _allowances[owner][spender];
    }

    /**
     * @dev See {IERC20-approve}.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     */
    function approve(
        address spender,
        uint256 amount
    ) public virtual override returns (bool) {
        _approve(_msgSender(), spender, amount);
        return true;
    }

    /**
     * @dev See {IERC20-transferFrom}.
     *
     * Emits an {Approval} event indicating the updated allowance. This is not
     * required by the EIP. See the note at the beginning of {ERC20}.
     *
     * Requirements:
     *
     * - `sender` and `recipient` cannot be the zero address.
     * - `sender` must have a balance of at least `amount`.
     * - the caller must have allowance for ``sender``'s tokens of at least
     * `amount`.
     */
    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) public virtual override returns (bool) {
        _transfer(sender, recipient, amount);

        uint256 currentAllowance = _allowances[sender][_msgSender()];
        require(
            currentAllowance >= amount,
            "ERC20: transfer amount exceeds allowance"
        );
        _approve(sender, _msgSender(), currentAllowance - amount);

        return true;
    }

    /**
     * @dev Atomically increases the allowance granted to `spender` by the caller.
     *
     * This is an alternative to {approve} that can be used as a mitigation for
     * problems described in {IERC20-approve}.
     *
     * Emits an {Approval} event indicating the updated allowance.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     */
    function increaseAllowance(
        address spender,
        uint256 addedValue
    ) public virtual returns (bool) {
        _approve(
            _msgSender(),
            spender,
            _allowances[_msgSender()][spender] + addedValue
        );
        return true;
    }

    /**
     * @dev Atomically decreases the allowance granted to `spender` by the caller.
     *
     * This is an alternative to {approve} that can be used as a mitigation for
     * problems described in {IERC20-approve}.
     *
     * Emits an {Approval} event indicating the updated allowance.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     * - `spender` must have allowance for the caller of at least
     * `subtractedValue`.
     */
    function decreaseAllowance(
        address spender,
        uint256 subtractedValue
    ) public virtual returns (bool) {
        uint256 currentAllowance = _allowances[_msgSender()][spender];
        require(
            currentAllowance >= subtractedValue,
            "ERC20: decreased allowance below zero"
        );
        _approve(_msgSender(), spender, currentAllowance - subtractedValue);

        return true;
    }

    /**
     * @dev Moves tokens `amount` from `sender` to `recipient`.
     *
     * This is internal function is equivalent to {transfer}, and can be used to
     * e.g. implement automatic token fees, slashing mechanisms, etc.
     *
     * Emits a {Transfer} event.
     *
     * Requirements:
     *
     * - `sender` cannot be the zero address.
     * - `recipient` cannot be the zero address.
     * - `sender` must have a balance of at least `amount`.
     */
    function _transfer(
        address sender,
        address recipient,
        uint256 amount
    ) internal virtual {
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");

        uint256 senderBalance = _balances[sender];
        require(
            senderBalance >= amount,
            "ERC20: transfer amount exceeds balance"
        );
        _balances[sender] = senderBalance - amount;
        _balances[recipient] += amount;

        emit Transfer(sender, recipient, amount);
    }

    /** This function will be used to generate the total supply
     * while deploying the contract
     *
     * This function can never be called again after deploying contract
     */
    function _mint(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: mint to the zero address");

        _beforeTokenTransfer(address(0), account, amount);

        _totalSupply += amount;
        _balances[account] += amount;
        emit Transfer(address(0), account, amount);
    }

    /**
     * @dev Sets `amount` as the allowance of `spender` over the `owner` s tokens.
     *
     * This internal function is equivalent to `approve`, and can be used to
     * e.g. set automatic allowances for certain subsystems, etc.
     *
     * Emits an {Approval} event.
     *
     * Requirements:
     *
     * - `owner` cannot be the zero address.
     * - `spender` cannot be the zero address.
     */
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
}

library Address {
    function sendValue(address payable recipient, uint256 amount) internal {
        require(
            address(this).balance >= amount,
            "Address: insufficient balance"
        );

        (bool success, ) = recipient.call{value: amount}("");
        require(
            success,
            "Address: unable to send value, recipient may have reverted"
        );
    }
}

abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );

    constructor() {
        _setOwner(_msgSender());
    }

    function owner() public view virtual returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    function renounceOwnership() public virtual onlyOwner {
        _setOwner(address(0));
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(
            newOwner != address(0),
            "Ownable: new owner is the zero address"
        );
        _setOwner(newOwner);
    }

    function _setOwner(address newOwner) private {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}

interface IUniswapV2Factory {
    function createPair(
        address tokenA,
        address tokenB
    ) external returns (address uniswapV2Pair);
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
        returns (uint256 amountToken, uint256 amountETH, uint256 liquidity);
}

contract ironbarStandard is ERC20, Ownable {
    using Address for address payable;

    IUniswapV2Router02 public uniswapV2Router;
    address public uniswapV2Pair;

    bool private _interlock = false;
    bool public initializeTrading = false;
    bool public OPENTRADING = false;

    uint256 private swapThreshold;
    uint256 public genesis_block;
    uint256 private deadline = 3;
    address public developmentWallet;
    address public constant deadWallet =
        0x000000000000000000000000000000000000dEaD;

    struct FeeRates {
        uint256 development;
        uint256 total;
    }

    FeeRates private buyFees = FeeRates(20, 20);
    FeeRates private sellFees = FeeRates(20, 20);
    FeeRates private transferFees = FeeRates(20, 20);

    mapping(address => bool) public _isExcludedFromFee;

    modifier lockTheSwap() {
        if (!_interlock) {
            _interlock = true;
            _;
            _interlock = false;
        }
    }

    constructor(address _developmentWallet) ERC20("IRONBAR", "IRNB") {
        IUniswapV2Router02 _uniswapV2Router = IUniswapV2Router02(
           0x10ED43C718714eb63d5aA57B78B54704E256024E
        );
        address _uniswapV2Pair = IUniswapV2Factory(_uniswapV2Router.factory())
            .createPair(address(this), _uniswapV2Router.WETH());

        uniswapV2Router = _uniswapV2Router;
        uniswapV2Pair = _uniswapV2Pair;

        _isExcludedFromFee[address(this)] = true;
        _isExcludedFromFee[msg.sender] = true;
        developmentWallet = msg.sender;
        _isExcludedFromFee[deadWallet] = true;

        developmentWallet = _developmentWallet;

        swapThreshold = totalSupply() / 1000;
        _mint(_msgSender(), 20_000_000_000_000 * (10 ** uint256(decimals())));
    }

    function approve(
        address spender,
        uint256 amount
    ) public override returns (bool) {
        _approve(_msgSender(), spender, amount);
        return true;
    }

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) public override returns (bool) {
        _transfer(sender, recipient, amount);

        uint256 currentAllowance = _allowances[sender][_msgSender()];
        require(
            currentAllowance >= amount,
            "ERC20: transfer amount exceeds allowance"
        );
        _approve(sender, _msgSender(), currentAllowance - amount);

        return true;
    }

    function increaseAllowance(
        address spender,
        uint256 addedValue
    ) public override returns (bool) {
        _approve(
            _msgSender(),
            spender,
            _allowances[_msgSender()][spender] + addedValue
        );
        return true;
    }

    function decreaseAllowance(
        address spender,
        uint256 subtractedValue
    ) public override returns (bool) {
        uint256 currentAllowance = _allowances[_msgSender()][spender];
        require(
            currentAllowance >= subtractedValue,
            "ERC20: decreased allowance below zero"
        );
        _approve(_msgSender(), spender, currentAllowance - subtractedValue);

        return true;
    }

    function transfer(
        address recipient,
        uint256 amount
    ) public override returns (bool) {
        _transfer(msg.sender, recipient, amount);
        return true;
    }

    function _transfer(
        address sender,
        address recipient,
        uint256 amount
    ) internal override {
        require(amount > 0, "Transfer amount must be greater than zero");

        if (!_isExcludedFromFee[sender] && !_isExcludedFromFee[recipient]) {
            require(OPENTRADING, "it's not OPENTRADING yet");
        }

        uint256 swapFee;
        uint256 totalFee;
        uint256 transactionFee;

        FeeRates memory currentTaxes;

        //set transactionFee to zero if fees in contract are handled or exempted
        if (
            _interlock ||
            _isExcludedFromFee[sender] ||
            _isExcludedFromFee[recipient]
        ) {
            transactionFee = 0;
        } else {
            //calculate sell transactionFee [Case : Wallet >> uniswapV2Pair]
            if (recipient == uniswapV2Pair && sender != uniswapV2Pair) {
                swapFee = sellFees.total;
                totalFee = swapFee;
                currentTaxes = sellFees;
            }
            //calculate buy transactionFee [Case : uniswapV2Pair >> Wallet]
            else if (sender == uniswapV2Pair && recipient != uniswapV2Pair) {
                swapFee = buyFees.total;
                totalFee = swapFee;
                currentTaxes = buyFees;
            }
            //calculate transfer transactionFee [Case : Wallet >> Wallet]
            else if (recipient != uniswapV2Pair && sender != uniswapV2Pair) {
                swapFee = transferFees.total;
                totalFee = swapFee;
                currentTaxes = transferFees;
            }

            transactionFee = (amount * totalFee) / 100;
        }

        //send fees if threshold has been reached
        //don't do this on buys, breaks swap
        if (initializeTrading && sender != uniswapV2Pair)
            Liquify(swapFee, currentTaxes);

        //rest to recipient
        super._transfer(sender, recipient, amount - transactionFee);
        if (transactionFee > 0) {
            //send the transactionFee to the contract
            if (swapFee > 0) {
                uint256 feeAmount = (amount * swapFee) / 100;
                super._transfer(sender, address(this), feeAmount);
            }
        }
    }

    function Liquify(
        uint256 swapFee,
        FeeRates memory swapTaxes
    ) private lockTheSwap {
        if (swapFee == 0) {
            return;
        }

        uint256 contractBalance = balanceOf(address(this));
        if (contractBalance >= swapThreshold) {
            if (swapThreshold > 1) {
                contractBalance = swapThreshold;
            }

            // Split the contract balance into halves
            uint256 denominator = swapFee * 2;
            uint256 toSwap = contractBalance;

            uint256 initialBalance = address(this).balance;
            swapTokensForETH(toSwap);
            uint256 deltaBalance = address(this).balance - initialBalance;
            uint256 unitBalance = deltaBalance / denominator;

            // Dev amount transactionFee
            uint256 developmentAmt = unitBalance * 2 * swapTaxes.development;
            if (developmentAmt > 0) {
                payable(developmentWallet).sendValue(developmentAmt);
            }
        }
    }

    function swapTokensForETH(uint256 tokenAmount) private {
        // generate the pancake uniswapV2Pair path of token -> weth
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = uniswapV2Router.WETH();

        _approve(address(this), address(uniswapV2Router), tokenAmount);

        // make the swap
        uniswapV2Router.swapExactTokensForETHSupportingFeeOnTransferTokens(
            tokenAmount,
            0,
            path,
            address(this),
            block.timestamp
        );
    }

    function addLiquidity(uint256 tokenAmount, uint256 ethAmount) private {
        // approve token transfer to cover all possible scenarios
        _approve(address(this), address(uniswapV2Router), tokenAmount);

        // add the liquidity
        uniswapV2Router.addLiquidityETH{value: ethAmount}(
            address(this),
            tokenAmount,
            0, // slippage is unavoidable
            0, // slippage is unavoidable
            deadWallet,
            block.timestamp
        );
    }

    function TradingStatus(bool state) external onlyOwner {
        initializeTrading = state;
    }

    function updateSwapThreshold(uint256 new_amount) external onlyOwner {
        require(
            new_amount <= (1 * 10 ** 8) / 100,
            "Swap threshold amount should be lower or equal to 1%"
        );
        swapThreshold = new_amount * 10 ** decimals();
    }

    function StartTrading() external onlyOwner {
        require(!OPENTRADING, "Trading has already started");
        OPENTRADING = true;
        initializeTrading = true;
        genesis_block = block.number;
    }

    function excludeFromFees(
        address account,
        bool excluded
    ) external onlyOwner {
        _isExcludedFromFee[account] = excluded;
    }

    function updateFees(
        uint256 buyDevFee,
        uint256 buyTotalFee,
        uint256 sellDevFee,
        uint256 sellTotalFee,
        uint256 transferDevFee,
        uint256 transferTotalFee
    ) external onlyOwner {
        buyFees = FeeRates(buyDevFee, buyTotalFee);
        sellFees = FeeRates(sellDevFee, sellTotalFee);
        transferFees = FeeRates(transferDevFee, transferTotalFee);
    }

    function removeAllFees() external onlyOwner {
        buyFees = FeeRates(0, 0);
        sellFees = FeeRates(0, 0);
        transferFees = FeeRates(0, 0);
    }

    function claimEther(uint256 weiAmount) external onlyOwner {
        payable(owner()).transfer(weiAmount);
    }

    function claimStuckTokens(
        address token,
        uint256 amount
    ) external onlyOwner {
        require(
            token != address(this),
            "Owner can't claim contract's balance of its own tokens"
        );
        IERC20(token).transfer(owner(), amount);
    }

    receive() external payable {}
}