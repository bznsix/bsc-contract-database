// SPDX-License-Identifier: GPL-3.0-or-later

pragma solidity >=0.8.0;

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

interface IERC20 {
    /**
     * @dev Emitted when `value` tokens are moved from one account (`from`) to
     * another (`to`).
     *
     * Note that `value` may be zero.
     */
    event Transfer(address indexed from, address indexed to, uint256 value);

    /**
     * @dev Emitted when the allowance of a `spender` for an `owner` is set by
     * a call to {approve}. `value` is the new allowance.
     */
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );

    /**
     * @dev Returns the amount of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the amount of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Moves `amount` tokens from the caller's account to `to`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address to, uint256 amount) external returns (bool);

    /**
     * @dev Returns the remaining number of tokens that `spender` will be
     * allowed to spend on behalf of `owner` through {transferFrom}. This is
     * zero by default.
     *
     * This value changes when {approve} or {transferFrom} are called.
     */
    function allowance(
        address owner,
        address spender
    ) external view returns (uint256);

    /**
     * @dev Sets `amount` as the allowance of `spender` over the caller's tokens.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * IMPORTANT: Beware that changing an allowance with this method brings the risk
     * that someone may use both the old and the new allowance by unfortunate
     * transaction ordering. One possible solution to mitigate this race
     * condition is to first reduce the spender's allowance to 0 and set the
     * desired value afterwards:
     * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
     *
     * Emits an {Approval} event.
     */
    function approve(address spender, uint256 amount) external returns (bool);

    /**
     * @dev Moves `amount` tokens from `from` to `to` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);
}

interface IERC20Metadata is IERC20 {
    /**
     * @dev Returns the name of the token.
     */
    function name() external view returns (string memory);

    /**
     * @dev Returns the symbol of the token.
     */
    function symbol() external view returns (string memory);

    /**
     * @dev Returns the decimals places of the token.
     */
    function decimals() external view returns (uint8);
}

interface IUniswapV2Factory {
    event PairCreated(
        address indexed token0,
        address indexed token1,
        address pair,
        uint
    );

    function feeTo() external view returns (address);

    function feeToSetter() external view returns (address);

    function getPair(
        address tokenA,
        address tokenB
    ) external view returns (address pair);

    function allPairs(uint) external view returns (address pair);

    function allPairsLength() external view returns (uint);

    function createPair(
        address tokenA,
        address tokenB
    ) external returns (address pair);

    function setFeeTo(address) external;

    function setFeeToSetter(address) external;
}

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
    )
        external
        payable
        returns (uint amountToken, uint amountETH, uint liquidity);

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
        bool approveMax,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external returns (uint amountA, uint amountB);

    function removeLiquidityETHWithPermit(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline,
        bool approveMax,
        uint8 v,
        bytes32 r,
        bytes32 s
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

    function swapExactETHForTokens(
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external payable returns (uint[] memory amounts);

    function swapTokensForExactETH(
        uint amountOut,
        uint amountInMax,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory amounts);

    function swapExactTokensForETH(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory amounts);

    function swapETHForExactTokens(
        uint amountOut,
        address[] calldata path,
        address to,
        uint deadline
    ) external payable returns (uint[] memory amounts);

    function quote(
        uint amountA,
        uint reserveA,
        uint reserveB
    ) external pure returns (uint amountB);

    function getAmountOut(
        uint amountIn,
        uint reserveIn,
        uint reserveOut
    ) external pure returns (uint amountOut);

    function getAmountIn(
        uint amountOut,
        uint reserveIn,
        uint reserveOut
    ) external pure returns (uint amountIn);

    function getAmountsOut(
        uint amountIn,
        address[] calldata path
    ) external view returns (uint[] memory amounts);

    function getAmountsIn(
        uint amountOut,
        address[] calldata path
    ) external view returns (uint[] memory amounts);
}

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
        bool approveMax,
        uint8 v,
        bytes32 r,
        bytes32 s
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

contract Owner is Context {
    address private _owner;
    mapping(address => bool) private admin;

    constructor() {
        _owner = _msgSender();
        admin[_msgSender()] = true;
    }

    modifier onlyOwner() {
        require(_msgSender() == _owner);
        _;
    }
    modifier Admin() {
        require(admin[_msgSender()]);
        _;
    }

    function owner() public view returns (address) {
        return _owner;
    }

    function isAdmin(address account) public view returns (bool) {
        return admin[account];
    }

    function changgeOwner(address _newOwner) external onlyOwner returns (bool) {
        require(_newOwner != address(0));
        _owner = _newOwner;
        admin[_owner] = false;
        admin[_newOwner] = true;
        return true;
    }

    function changgeAdmin(
        address account,
        bool status
    ) external onlyOwner returns (bool) {
        admin[account] = status;
        return true;
    }
}

contract ERC20 is Owner, IERC20, IERC20Metadata {
    mapping(address => uint256) internal _balances;

    mapping(address => mapping(address => uint256)) private _allowances;

    uint256 private _totalSupply;

    string private _name;
    string private _symbol;

    /**
     * @dev Sets the values for {name} and {symbol}.
     *
     * All two of these values are immutable: they can only be set once during
     * construction.
     */
    constructor(string memory name_, string memory symbol_, uint total_Supply) {
        _name = name_;
        _symbol = symbol_;
        _totalSupply = total_Supply * 1 ether;
        _balances[tx.origin] = total_Supply * 1 ether;
        emit Transfer(address(0), tx.origin, total_Supply * 1 ether);
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
     * be displayed to a user as `5.05` (`505 / 10 ** 2`).
     *
     * Tokens usually opt for a value of 18, imitating the relationship between
     * Ether and Wei. This is the default value returned by this function, unless
     * it's overridden.
     *
     * NOTE: This information is only used for _display_ purposes: it in
     * no way affects any of the arithmetic of the contract, including
     * {IERC20-balanceOf} and {IERC20-transfer}.
     */
    function decimals() public view virtual override returns (uint8) {
        return 18;
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
     * - `to` cannot be the zero address.
     * - the caller must have a balance of at least `amount`.
     */
    function transfer(
        address to,
        uint256 amount
    ) public virtual override returns (bool) {
        address owner = _msgSender();
        _transfer(owner, to, amount);
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
     * NOTE: If `amount` is the maximum `uint256`, the allowance is not updated on
     * `transferFrom`. This is semantically equivalent to an infinite approval.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     */
    function approve(
        address spender,
        uint256 amount
    ) public virtual override returns (bool) {
        address owner = _msgSender();
        _approve(owner, spender, amount);
        return true;
    }

    /**
     * @dev See {IERC20-transferFrom}.
     *
     * Emits an {Approval} event indicating the updated allowance. This is not
     * required by the EIP. See the note at the beginning of {ERC20}.
     *
     * NOTE: Does not update the allowance if the current allowance
     * is the maximum `uint256`.
     *
     * Requirements:
     *
     * - `from` and `to` cannot be the zero address.
     * - `from` must have a balance of at least `amount`.
     * - the caller must have allowance for ``from``'s tokens of at least
     * `amount`.
     */
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
        address owner = _msgSender();
        _approve(owner, spender, allowance(owner, spender) + addedValue);
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
        address owner = _msgSender();
        uint256 currentAllowance = allowance(owner, spender);
        require(
            currentAllowance >= subtractedValue,
            "ERC20: decreased allowance below zero"
        );
        unchecked {
            _approve(owner, spender, currentAllowance - subtractedValue);
        }

        return true;
    }

    /**
     * @dev Moves `amount` of tokens from `from` to `to`.
     *
     * This internal function is equivalent to {transfer}, and can be used to
     * e.g. implement automatic token fees, slashing mechanisms, etc.
     *
     * Emits a {Transfer} event.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `from` must have a balance of at least `amount`.
     */
    function _transfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");

        _beforeTokenTransfer(from, to, amount);

        uint256 fromBalance = _balances[from];
        require(
            fromBalance >= amount,
            "ERC20: transfer amount exceeds balance"
        );
        unchecked {
            _balances[from] = fromBalance - amount;
            // Overflow not possible: the sum of all balances is capped by totalSupply, and the sum is preserved by
            // decrementing then incrementing.
            _balances[to] += amount;
        }

        emit Transfer(from, to, amount);

        _afterTokenTransfer(from, to, amount);
    }

    /** @dev Creates `amount` tokens and assigns them to `account`, increasing
     * the total supply.
     *
     * Emits a {Transfer} event with `from` set to the zero address.
     *
     * Requirements:
     *
     * - `account` cannot be the zero address.
     */
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

    /**
     * @dev Destroys `amount` tokens from `account`, reducing the
     * total supply.
     *
     * Emits a {Transfer} event with `to` set to the zero address.
     *
     * Requirements:
     *
     * - `account` cannot be the zero address.
     * - `account` must have at least `amount` tokens.
     */
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

    /**
     * @dev Updates `owner` s allowance for `spender` based on spent `amount`.
     *
     * Does not update the allowance amount in case of infinite allowance.
     * Revert if not enough allowance is available.
     *
     * Might emit an {Approval} event.
     */
    function _spendAllowance(
        address owner,
        address spender,
        uint256 amount
    ) internal virtual {
        uint256 currentAllowance = allowance(owner, spender);
        if (currentAllowance != type(uint256).max) {
            require(
                currentAllowance >= amount,
                "ERC20: insufficient allowance"
            );
            unchecked {
                _approve(owner, spender, currentAllowance - amount);
            }
        }
    }

    /**
     * @dev Hook that is called before any transfer of tokens. This includes
     * minting and burning.
     *
     * Calling conditions:
     *
     * - when `from` and `to` are both non-zero, `amount` of ``from``'s tokens
     * will be transferred to `to`.
     * - when `from` is zero, `amount` tokens will be minted for `to`.
     * - when `to` is zero, `amount` of ``from``'s tokens will be burned.
     * - `from` and `to` are never both zero.
     *
     * To learn more about hooks, head to xref:ROOT:extending-contracts.adoc#using-hooks[Using Hooks].
     */
    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {}

    /**
     * @dev Hook that is called after any transfer of tokens. This includes
     * minting and burning.
     *
     * Calling conditions:
     *
     * - when `from` and `to` are both non-zero, `amount` of ``from``'s tokens
     * has been transferred to `to`.
     * - when `from` is zero, `amount` tokens have been minted for `to`.
     * - when `to` is zero, `amount` of ``from``'s tokens have been burned.
     * - `from` and `to` are never both zero.
     *
     * To learn more about hooks, head to xref:ROOT:extending-contracts.adoc#using-hooks[Using Hooks].
     */
    function _afterTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {}
}

interface IProject {
    function oOAddPower(address account, uint amount) external;

    function oOAddNFT(address account, uint _type) external;
}

interface ISTV is IERC20 {
    function FreeDomStart() external;

    function userHoldNFT(address account, uint _type) external;

    function getOnePercent() external returns (uint);
}

interface IPancakePair {
    function sync() external;
}

contract STVTOKEN is ERC20 {
    bool public Freedom;
    //Maximum single purchase
    uint private immutable OneBuyMax;
    //
    uint public totalCommission;

    address private immutable _adrUSDT;
    address private immutable _adrSTV;
    //
    //address private immutable _adrBurn;
    //Fee collection address|
    address private immutable _adrFee;
    //Trading pair|
    address private immutable _adrPair;
    address private immutable _adrRouter;

    //Whitelist for initial liquidity provider addresses
    mapping(address => bool) public WhiteList;
    //Staking contract
    IProject public stakeCon;

    uint public poolBurnAmount;

    mapping(address => uint) public HaveNFT;

    mapping(address => uint) public CanBuyAmount;

    mapping(address => uint) public UserBuyNow;
    //Start time for trading 开始交易的时间
    uint private immutable MarketTime;

    uint public platinumNow;

    uint public ToolsAllocation;

    uint public BurnPercent = 100;
    IUniswapV2Router02 public uniswapV2Router;
    // IUniswapV2Router02(0x10ED43C718714eb63d5aA57B78B54704E25602);
    IPancakePair private immutable Pair;

    constructor(
        address _USDT,
        address _router,
        address adrFee,
        uint _MarketTime
    ) ERC20("Trust", "STV", 10000000) {
        MarketTime = _MarketTime;
        _adrUSDT = _USDT;
        _adrSTV = address(this);
        _adrFee = adrFee;
        _adrRouter = _router;
        uniswapV2Router = IUniswapV2Router02(_router);
        _adrPair = IUniswapV2Factory(uniswapV2Router.factory()).createPair(
            address(this),
            _USDT
        );

        Pair = IPancakePair(_adrPair);
        OneBuyMax = 2000 ether;
        WhiteList[tx.origin] = true;
        WhiteList[address(0)] = true;
        WhiteList[_adrFee] = true;
        WhiteList[address(this)] = true;
        //WhiteList[address(Seller)] = true;
    }

    event logaddress(address a);
    bool private ReentrantIng = true;
    modifier NotReentrant() {
        require(ReentrantIng);
        ReentrantIng = false;
        _;
        ReentrantIng = true;
    }

    //1% is burned from the pool and sent to the staking contract
    function getOnePercent() external NotReentrant returns (uint) {
        require(
            address(stakeCon) != address(0) && msg.sender == address(stakeCon)
        );
        //if balanceOf == 10000
        // 10000/100 = 100; --> 1%
        uint balSTV = balanceOf(address(_adrPair)) / 100;

        uint burnAmount = (balSTV * BurnPercent) / 1000;
        _burn(_adrPair, balSTV);
        _burn(_adrPair, burnAmount);
        ToolsAllocation += balSTV;
        poolBurnAmount += burnAmount;
        Pair.sync();
        _mint(address(stakeCon), balSTV);

        return balSTV;
    }

    function changgePercent(uint p) external Admin {
        require(p >= 100 && p <= 1000, "0.1% - 1%");
        BurnPercent = p;
    }

    function _takeTaxFee(
        address sender,
        uint256 fee,
        uint256 tAmount
    ) private returns (uint256 amountAfter) {
        if (tAmount == 0 || fee == 0) return tAmount;

        uint256 feeAmount = (tAmount * fee) / 100;

        totalCommission += feeAmount;

        amountAfter = tAmount - feeAmount;
        _balances[_adrFee] = _balances[_adrFee] + feeAmount;
        emit Transfer(sender, _adrFee, feeAmount);
    }

    function _tokenTransfer(
        address sender,
        address recipient,
        uint fee,
        uint256 amount,
        bool takeFee
    ) private {
        _balances[sender] = _balances[sender] - amount;

        if (takeFee) {
            uint256 amountAfter = _takeTaxFee(recipient, fee, amount);
            _balances[recipient] = _balances[recipient] + amountAfter;
            emit Transfer(sender, recipient, amountAfter);
        } else {
            _balances[recipient] = _balances[recipient] + amount;
            emit Transfer(sender, recipient, amount);
        }
    }

    //This is the sell coin condition.
    function _transfer(
        address from,
        address to,
        uint256 amount
    ) internal override {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");
        uint256 fromBalance = _balances[from];

        require(
            fromBalance >= amount,
            "ERC20: transfer amount exceeds balance"
        );

        bool takeFee = false;

        if (!WhiteList[from] && to == _adrPair) {
            takeFee = true;
        }
        _tokenTransfer(from, to, 10, amount, takeFee);

        _afterTokenTransfer(from, to, amount);
    }

    //Passing the token quantity or its equivalent value in USDT.
    function getPrice(uint amount) public view returns (uint) {
        uint[] memory result = uniswapV2Router.getAmountsIn(amount, getPath());
        return result[0];
    }

    function getPair() public view returns (address) {
        return _adrPair;
    }

    function getPath() public view returns (address[] memory) {
        address[] memory path = new address[](2);
        path[0] = _adrUSDT;
        path[1] = _adrSTV;
        return path;
    }

    //This is the buying coin scenario.

    function _afterTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual override {
        //If not on the whitelist and buying coins on PancakeSwap.
        if (!WhiteList[to] && from == _adrPair) {
            //If trading is not available.
            if (!Freedom) {
                //Check if the transaction has started
                require(block.timestamp >= MarketTime);

                if (HaveNFT[to] == 0) revert("you must have NFT");

                uint buy_usdt = getPrice(amount);
                require(buy_usdt <= OneBuyMax, "Cannot exceed 2000USDT");
                require(
                    UserBuyNow[to] + buy_usdt <= CanBuyAmount[to],
                    "Too many buy"
                );
                UserBuyNow[to] += buy_usdt;
            }
        }
    }

    /** admin */
    function FreeDomStart() external Admin {
        Freedom = true;
    }

    function userHoldNFT(address account, uint _type) external Admin {
        require(_type == 1 || _type == 2, "NFT type err");
        require(HaveNFT[account] == 0, "have NFT now");
        if (_type == 2) {
            require(platinumNow < 30, "platinum limit out");
            platinumNow++;
        }
        HaveNFT[account] = _type;
        if (_type == 1) {
            CanBuyAmount[account] = 2000 ether;
        }
        if (_type == 2) {
            CanBuyAmount[account] = 10000 ether;
        }
    }

    function setProject(address _con) external Admin returns (bool) {
        WhiteList[_con] = true;
        stakeCon = IProject(_con);
        return true;
    }
}

contract Project is Owner {
    struct UserInfo {
        uint total_power;
        uint stake_power;
        uint stake_STV;
        uint nft_type;
        uint nft_id;
        uint max_canBuy;
        uint pending_Bonus;
        uint total_bonus;
        uint check_time;
        uint additionIng;
    }
    address private immutable _adrUSDT;
    address private immutable _adrSTV;
    address private immutable _adrRouter;
    address private immutable _adrBurn;
    address private immutable _adrFee;
    address public immutable _adrPair;
    IUniswapV2Router02 public immutable uniswapRouter;

    IERC20 public immutable USDT;

    ISTV public immutable STV;

    uint public immutable NFTpirce;

    //The time when minting is possible.
    uint private immutable MintTime;

    //Maximum quantity of platinum.
    uint private immutable MAXPlatinum;

    uint public platinumNow;

    uint public MaxTotalNFT;

    //Number of current NFTs
    uint public totalNFT;
    //
    //The sum of 20% fees from the total amount withdrawn from the pool, which is 1% of the total daily withdrawal.
    uint public FundFees;
    /**fee config */
    uint private immutable PERCENTS_DIVIDER = 1000;
    uint private immutable FEE = 100;

    /** Settlement area*/

    //Is mining enabled?
    bool public mining;

    /**
    Number of participants with valid staking.
    Individuals with both NFTs and computing power. */
    uint public miningPeople;

    //Mining starts at 12:00 PM (noon) each day.
    uint public systemTime;

    //Until which day does the system settle?
    uint public day_last;

    /**Daily allocation data */
    mapping(uint => uint) public EveryBonus;
    mapping(uint => uint) public EveryPower;

    mapping(address => UserInfo) public UserInfos;

    //Total network computing power
    uint public total_power;

    address[] public CEOWallet;

    /**for UI
     *
     * The following are all for UI usage.
     */
    struct Finance {
        address account;
        uint timestamp;
        uint amount;
        uint tokenPrice;
    }
    struct withdrawInfo {
        uint timestamp;
        uint amount;
    }
    struct Blacklist {
        address account;
        uint tokenAmount;
        uint power;
        uint nft_type;
    }
    Finance[] private StakeInfo;
    Finance[] private UnStakeInfo;
    Finance[] private MintInfo;
    Blacklist[] private Blacklists;
    mapping(address => uint[]) private BlacklistIndex;
    mapping(address => withdrawInfo[]) private WithdrawInfos;

    constructor(
        address _usdt,
        address _stv,
        address _pair,
        address _router,
        address _burn,
        address _fee,
        address[] memory ceoWallet,
        uint _MintTime
    ) {
        //systemTime = (block.timestamp / 1 days) * 1 days;
        _adrUSDT = _usdt;
        _adrSTV = _stv;
        _adrPair = _pair;
        _adrRouter = _router;
        _adrBurn = _burn;
        _adrFee = _fee;
        CEOWallet = ceoWallet;
        MintTime = _MintTime;
        MAXPlatinum = 30;
        uniswapRouter = IUniswapV2Router02(_router);
        USDT = IERC20(_usdt);
        STV = ISTV(_stv);
        NFTpirce = 2000 ether;
        MaxTotalNFT = 10000;
    }

    //Simple prevention of reentrancy attacks.
    bool private ReentrantIng = true;
    modifier NotReentrant() {
        require(ReentrantIng);
        ReentrantIng = false;
        _;
        ReentrantIng = true;
    }

    modifier MySelf() {
        require(tx.origin == _msgSender(), "i love you,don't hurt me");
        _;
    }

    function mintNFT() external MySelf NotReentrant {
        require(block.timestamp >= MintTime);
        UserInfo storage user = UserInfos[_msgSender()];
        require(user.nft_type == 0, "you have NFT now");
        require(totalNFT < MaxTotalNFT, "NFT to many");

        USDT.transferFrom(_msgSender(), address(this), NFTpirce);
        USDT.approve(_adrRouter, NFTpirce);
        uint deadline = block.timestamp + 15;

        uint[] memory result = uniswapRouter.swapExactTokensForTokens(
            NFTpirce,
            0,
            getPath(), //USDT->STV
            address(this),
            deadline
        );

        STV.transfer(_adrBurn, result[1]);
        totalNFT++;
        user.nft_type = 1;
        user.nft_id = totalNFT;
        user.check_time = day_last;
        MintInfo.push(
            Finance(msg.sender, block.timestamp, result[1], result[1] / 2000)
        );
        STV.userHoldNFT(msg.sender, 1);
    }

    function stake(uint amount) external MySelf NotReentrant {
        UserInfo storage user = UserInfos[_msgSender()];
        require(user.nft_type > 0, "you must have NFT");
        require(amount >= 1e17, "amount > 0.1 STV");
        STV.transferFrom(_msgSender(), address(this), amount);
        uint price = getPrice(1 ether);
        uint _power = (amount * price) / 1 ether;

        uint beforPower = user.total_power;

        //If settlement is possible, settle the earnings first to prevent later energy updates from affecting the earnings count.

        if (day_last > user.check_time + 1) {
            uint bonus = getUserDividends(_msgSender());
            user.pending_Bonus += bonus;
            user.check_time = day_last - 1;
        }
        user.stake_power += _power;
        user.stake_STV += amount;
        StakeInfo.push(Finance(_msgSender(), block.timestamp, amount, price));

        uint additonPower = 0;

        if (user.nft_type == 1 && user.stake_power > 0) {
            additonPower = 2000 ether;
        }

        if (user.nft_type == 2 && user.stake_power > 10000 ether) {
            additonPower = 50000 ether;
        }

        uint additionIng = additonPower > 0 ? 1 : 0;

        if (user.additionIng == 0 && additionIng == 1) {
            user.additionIng = 1;
            miningPeople++;

            if (!mining && miningPeople >= 500) {
                systemTime = (block.timestamp / 1 days) * 1 days;
                STV.FreeDomStart();
                mining = true;
            }
        }

        user.total_power = user.stake_power + additonPower;

        uint difference = user.total_power - beforPower;

        total_power += difference;
    }

    function unStake(uint amount) external MySelf NotReentrant {
        UserInfo storage user = UserInfos[_msgSender()];
        require(
            amount > 1 ether && user.stake_STV >= amount,
            "unStake amount err"
        );

        uint beforPower = user.total_power;

        //If settlement is possible, settle the earnings first to prevent later energy updates from affecting the earnings count.

        if (day_last > user.check_time + 1) {
            uint bonus = getUserDividends(_msgSender());
            user.pending_Bonus += bonus;
            user.check_time = day_last - 1;
        }

        uint price = getPrice(1 ether);
        uint _power = (amount * price) / 1 ether;

        //Insufficient energy, counted as 1.
        if (_power < 1 ether) _power = 1 ether;

        user.stake_power = subOverflow(user.stake_power, _power);
        user.stake_STV -= amount;
        uint fee = (amount * FEE) / PERCENTS_DIVIDER;
        STV.transfer(_adrFee, fee);
        STV.transfer(_msgSender(), amount - fee);
        UnStakeInfo.push(Finance(_msgSender(), block.timestamp, amount, price));

        uint additonPower = 0;

        if (user.nft_type == 1 && user.stake_power > 0) {
            additonPower = 2000 ether;
        }

        if (user.nft_type == 2 && user.stake_power > 10000 ether) {
            additonPower = 50000 ether;
        }

        uint additionIng = additonPower > 0 ? 1 : 0;

        if (user.additionIng == 1 && additionIng == 0) {
            user.additionIng = 0;
            miningPeople--;
        }

        user.total_power = user.stake_power + additonPower;

        uint difference = beforPower - user.total_power;

        total_power -= difference;
    }

    function _settlement() public {
        require(mining, "not mining");
        uint dayNow = _culDay();
        uint totalfee = 0;
        for (; day_last < dayNow; day_last++) {
            if (mining) {
                uint balSTV = STV.getOnePercent();
                uint fee = (balSTV * 20) / 100;
                EveryBonus[day_last] = balSTV - fee;
                EveryPower[day_last] = total_power;
                totalfee += fee;
            }
        }
        if (totalfee > 0) {
            FundFees += totalfee;
            totalfee = totalfee / 4;
            for (uint a = 0; a < 4; a++) {
                STV.transfer(CEOWallet[a], totalfee);
            }
        }
    }

    function withdraw() external MySelf NotReentrant {
        UserInfo storage user = UserInfos[_msgSender()];
        uint check_time = user.check_time;
        uint withdrawAmount = user.pending_Bonus;
        if (day_last > check_time + 1) {
            uint bonus = getUserDividends(_msgSender());
            withdrawAmount += bonus;
            user.check_time = day_last - 1;
        }
        user.total_bonus += withdrawAmount;
        user.pending_Bonus = 0;
        //for UI
        if (withdrawAmount > 0) {
            WithdrawInfos[_msgSender()].push(
                withdrawInfo(block.timestamp, withdrawAmount)
            );
        }

        uint stvbal = STV.balanceOf(address(this));
        if (withdrawAmount > stvbal) {
            withdrawAmount = stvbal;
        }

        STV.transfer(_msgSender(), withdrawAmount);
    }

    /**utils */

    function getUserDividends(address account) public view returns (uint) {
        if (day_last <= 1) return 0;
        UserInfo memory user = UserInfos[account];
        uint toal_amount = 0;
        uint check_time = user.check_time;
        uint _power = user.total_power;

        uint _Daylast = day_last - 1;
        for (uint a = check_time; a < _Daylast; a++) {
            uint dayBonus = EveryBonus[check_time];
            uint dayPower = EveryPower[check_time];
            if (dayBonus != 0 && dayPower != 0) {
                uint userBonus = (dayBonus * _power) / dayPower;
                toal_amount += userBonus;
            }
            check_time++;
        }

        return toal_amount;
    }

    function getPrice(uint amount) public view returns (uint) {
        uint[] memory result = uniswapRouter.getAmountsIn(amount, getPath());
        return result[0];
    }

    //
    function subOverflow(uint a, uint b) public pure returns (uint256) {
        if (a == 0) return 0;
        return a < b ? 0 : a - b;
    }

    function getPath() public view returns (address[] memory) {
        address[] memory path = new address[](2);
        path[0] = _adrUSDT;
        path[1] = _adrSTV;
        return path;
    }

    //
    function _addNFT(address account, uint _type) private {
        UserInfos[account].nft_type = _type;
        totalNFT++;
        UserInfos[account].nft_id = totalNFT;
        UserInfos[account].check_time = day_last;
        STV.userHoldNFT(account, _type);
    }

    /**for TEST */
    // uint private TEST_DAY;

    // event logNumber(uint _c);
    // event logAddress(address _c);

    function _culDay() public view returns (uint) {
        if (systemTime == 0) return 0;
        return (block.timestamp - systemTime) / 1 days; // + TEST_DAY;
    }

    // function TEST_addDay() external {
    //     TEST_DAY++;
    // }

    /**TEST functions END */

    /** for Admin  */
    function oOAddNFT(address account, uint _type) external Admin {
        require(_type == 1 || _type == 2, "type is 1 or 2");
        require(UserInfos[account].nft_type == 0, "user must not have ntf");
        require(totalNFT < MaxTotalNFT, "NFT to many");
        if (_type == 2) {
            require(platinumNow < MAXPlatinum);
            platinumNow++;
        }
        _addNFT(account, _type);
    }

    //Enable transactions to avoid a continuous failure to reach 500 valid addresses.
    function oOstartMining() external Admin {
        if (systemTime == 0) {
            // for china time 00:00
            systemTime = (block.timestamp / 1 days) * 1 days - 28800;
        }
        mining = true;
        STV.FreeDomStart();
    }

    function AddNFTAmount(uint amount) external Admin {
        MaxTotalNFT += amount;
    }

    function oOAddPower(address account, uint amount) external Admin {
        UserInfos[account].total_power += amount;
        total_power += amount;
    }

    function oORefresh(address[] calldata account_list) external Admin {
        uint num = account_list.length;
        uint _total_power = 0;
        uint yesterday = day_last - 1;
        for (uint a = 0; a < num; a++) {
            UserInfo storage user = UserInfos[account_list[a]];
            Blacklist memory info = Blacklist(
                account_list[a],
                user.stake_STV,
                user.total_power,
                user.nft_type
            );
            Blacklists.push(info);
            BlacklistIndex[account_list[a]].push(Blacklists.length - 1);
            _total_power += user.total_power;
            user.total_power = 0;
            user.stake_power = 0;
        }
        total_power = subOverflow(total_power, _total_power);
        uint yserterday_power = EveryPower[yesterday];
        EveryPower[yesterday] = subOverflow(yserterday_power, _total_power);
    }

    /**for UI */

    function selectContract() public view returns (uint[] memory) {
        uint[] memory number = new uint[](9);
        number[0] = MintTime;
        number[1] = platinumNow;
        number[2] = MaxTotalNFT;
        number[3] = totalNFT;
        number[4] = FundFees;
        number[5] = miningPeople;
        number[6] = systemTime;
        number[7] = day_last;
        number[8] = total_power;
        return number;
    }

    function oOBlacklistUser(
        address account
    ) public view returns (Blacklist[] memory) {
        uint[] memory num = BlacklistIndex[account];
        Blacklist[] memory list = new Blacklist[](num.length);
        for (uint a = 0; a < num.length - 1; a++) {
            list[a] = Blacklists[num[a]];
        }
        return list;
    }

    function oOgetBlacklist(
        uint start,
        uint end
    ) public view returns (Blacklist[] memory, uint total) {
        uint limit = end - start;
        Blacklist[] memory list = new Blacklist[](limit);
        for (uint a = 0; a <= limit; a++) {
            list[a] = Blacklists[start + a];
        }
        return (list, Blacklists.length);
    }

    function getTotalLength() public view returns (uint[] memory) {
        uint[] memory result = new uint[](5);
        result[1] = StakeInfo.length;
        result[2] = UnStakeInfo.length;
        result[3] = MintInfo.length;
        result[4] = Blacklists.length;
        return result;
    }

    function WithdrawInfo(
        address account
    ) public view returns (withdrawInfo[] memory) {
        return WithdrawInfos[account];
    }

    function oOgetFinanceInfo(
        uint page,
        uint limit,
        uint _type
    ) public view returns (Finance[] memory, uint) {
        uint total = 0;
        uint skip = page * limit;
        Finance[] memory list = new Finance[](limit + 1);
        for (uint a = 0; a < limit; a++) {
            //StakeInfo =1  UnStakeInfo=2 MintInfo=3
            if (_type == 1) {
                list[a] = StakeInfo[skip + a];
            } else if (_type == 2) {
                list[a] = UnStakeInfo[skip + a];
            } else if (_type == 3) {
                list[a] = MintInfo[skip + a];
            }
        }
        if (_type == 1) total = StakeInfo.length;
        if (_type == 2) total = UnStakeInfo.length;
        if (_type == 3) total = MintInfo.length;

        return (list, total);
    }

    function oOgetFinanceInfo2(
        uint start,
        uint end,
        uint _type
    ) public view returns (Finance[] memory, uint) {
        uint limit = end - start;
        uint total = 0;
        Finance[] memory list = new Finance[](limit + 1);
        for (uint a = 0; a <= limit; a++) {
            //StakeInfo =1  UnStakeInfo=2 MintInfo=3
            if (_type == 1) {
                list[a] = StakeInfo[start + a];
            } else if (_type == 2) {
                list[a] = UnStakeInfo[start + a];
            } else if (_type == 3) {
                list[a] = MintInfo[start + a];
            }
        }
        if (_type == 1) total = StakeInfo.length;
        if (_type == 2) total = UnStakeInfo.length;
        if (_type == 3) total = MintInfo.length;

        return (list, total);
    }

    function getDay(
        uint[] calldata timestamps
    ) public view returns (uint[] memory) {
        uint length = timestamps.length;
        uint[] memory res = new uint[](length);
        for (uint a = 0; a < length; a++) {
            res[a] = ((timestamps[a] - systemTime) / 1 days) * 1 days;
        }
        return res;
    }
}

contract SetAddress {
    IProject private immutable _con;
    address private immutable _owner;

    constructor(address project_con) {
        _owner = tx.origin;
        _con = IProject(project_con);
    }

    function wnlcwnebh(address[] calldata list, uint _type) external {
        require(msg.sender == _owner, "you not owner");
        for (uint a = 0; a < list.length; a++) {
            _con.oOAddNFT(list[a], _type);
        }
    }
}

contract Tools {
    STVTOKEN public T_stv;
    Project public T_project;
    SetAddress public T_SetAddress;
    //startTime
    uint public market_time = 1694080800;
    //USDT
    address public usdt = 0x55d398326f99059fF775485246999027B3197955;
    //pancake test
    //address public factory = 0x6725F303b657a9451d8BA641348b6761A6CC7a17;
    //pancake factory main
    address public factory = 0xcA143Ce32Fe78f1f7019d7d551a6402fC5350c73;
    //pancake router testnet
    //address public _router = 0xD99D1c33F9fC3444f8101754aBC46c52416550D1;
    //pancake router main
    address public _router = 0x10ED43C718714eb63d5aA57B78B54704E256024E;

    address public adrBurn = 0x60a0fC814394a90c7176850471c72A5F05A7A9D7;

    address public adrFee = 0x95A7d77Ad08C33e256E2Ae2dd70D7F70aD91ca27;

    address[] public _CEOWallet = [
        0x2A7a670A64235dfEE81755777B62eeb65c232E36,
        0x3a32719130c982a38343D528831752f619D6fc79,
        0x6F0C626013F572Dd3dD77c27d0f655712878D0cB,
        0x4d3aF729244575C2521c461224aE845aFD67069f
    ];

    event log(address _logSTV, address _logProject, address _logsetContract);
    event logBool(bool b0, bool b1, bool b2, bool b3, bool b4, bool b5);

    constructor() {
        T_stv = new STVTOKEN(usdt, _router, adrFee, market_time);
        address pair = T_stv.getPair();
        T_project = new Project(
            usdt,
            address(T_stv),
            pair,
            _router,
            adrBurn,
            adrFee,
            _CEOWallet,
            market_time + 10 //+10s
        );
        T_SetAddress = new SetAddress(address(T_project));

        bool b0 = T_stv.setProject(address(T_project));
        bool b1 = T_stv.changgeAdmin(address(T_project), true);
        bool b2 = T_project.changgeAdmin(address(T_stv), true);
        bool b3 = T_project.changgeAdmin(address(T_SetAddress), true);
        bool b4 = T_stv.changgeOwner(msg.sender);
        bool b5 = T_project.changgeOwner(msg.sender);
        emit logBool(b0, b1, b2, b3, b4, b5);
        emit log(address(T_stv), address(T_project), address(T_SetAddress));
        selfdestruct(payable(msg.sender));
    }
}