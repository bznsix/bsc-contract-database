// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IERC20 {
    /**
     * @dev Returns the amount of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the amount of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Moves `amount` tokens from the caller's account to `recipient`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address recipient, uint256 amount) external returns (bool);

    /**
     * @dev Returns the remaining number of tokens that `spender` will be
     * allowed to spend on behalf of `owner` through {transferFrom}. This is
     * zero by default.
     *
     * This value changes when {approve} or {transferFrom} are called.
     */
    function allowance(address owner, address spender) external view returns (uint256);

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
     * @dev Moves `amount` tokens from `sender` to `recipient` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);

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
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

// File: @openzeppelin/contracts/token/ERC20/extensions/IERC20Metadata.sol


// OpenZeppelin Contracts v4.4.0 (token/ERC20/extensions/IERC20Metadata.sol)

pragma solidity ^0.8.0;


/**
 * @dev Interface for the optional metadata functions from the ERC20 standard.
 *
 * _Available since v4.1._
 */
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

// File: @openzeppelin/contracts/utils/Context.sol



pragma solidity ^0.8.0;

/**
 * @dev Provides information about the current execution context, including the
 * sender of the transaction and its data. While these are generally available
 * via msg.sender and msg.data, they should not be accessed in such a direct
 * manner, since when dealing with meta-transactions the account sending and
 * paying for execution may not be the actual sender (as far as an application
 * is concerned).
 *
 * This contract is only required for intermediate, library-like contracts.
 */
abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

// File: @openzeppelin/contracts/access/Ownable.sol

pragma solidity ^0.8.0;

/**
 * @dev Contract module which provides a basic access control mechanism, where
 * there is an account (an owner) that can be granted exclusive access to
 * specific functions.
 *
 * By default, the owner account will be the one that deploys the contract. This
 * can later be changed with {transferOwnership}.
 *
 * This module is used through inheritance. It will make available the modifier
 * `onlyOwner`, which can be applied to your functions to restrict their use to
 * the owner.
 */
abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor() {
        _setOwner(_msgSender());
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view virtual returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    /**
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions anymore. Can only be called by the current owner.
     *
     * NOTE: Renouncing ownership will leave the contract without an owner,
     * thereby removing any functionality that is only available to the owner.
     */
    function renounceOwnership() public virtual onlyOwner {
        _setOwner(address(0));
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _setOwner(newOwner);
    }

    function _setOwner(address newOwner) private {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}

/**
 * @dev Implementation of the {IERC20} interface.
 *
 * This implementation is agnostic to the way tokens are created. This means
 * that a supply mechanism has to be added in a derived contract using {_mint}.
 * For a generic mechanism see {ERC20PresetMinterPauser}.
 *
 * TIP: For a detailed writeup see our guide
 * https://forum.zeppelin.solutions/t/how-to-implement-erc20-supply-mechanisms/226[How
 * to implement supply mechanisms].
 *
 * We have followed general OpenZeppelin guidelines: functions revert instead
 * of returning `false` on failure. This behavior is nonetheless conventional
 * and does not conflict with the expectations of ERC20 applications.
 *
 * Additionally, an {Approval} event is emitted on calls to {transferFrom}.
 * This allows applications to reconstruct the allowance for all accounts just
 * by listening to said events. Other implementations of the EIP may not emit
 * these events, as it isn't required by the specification.
 *
 * Finally, the non-standard {decreaseAllowance} and {increaseAllowance}
 * functions have been added to mitigate the well-known issues around setting
 * allowances. See {IERC20-approve}.
 */
contract ERC20 is Context, IERC20, IERC20Metadata {
    mapping(address => uint256) internal _balances;
    mapping(address => mapping(address => uint256)) private _allowances;
    uint256 private _totalSupply;
    string private _name;
    string private _symbol;
    /**
     * @dev Sets the values for {name} and {symbol}.
     *
     * The default value of {decimals} is 18. To select a different value for
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
     * Tokens usually opt for a value of 18, imitating the relationship between
     * Ether and Wei. This is the value {ERC20} uses, unless this function is
     * overridden;
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
    function balanceOf(address account) public view virtual override returns (uint256) {
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
    function transfer(address recipient, uint256 amount) public virtual override returns (bool) {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    /**
     * @dev See {IERC20-allowance}.
     */
    function allowance(address owner, address spender) public view virtual override returns (uint256) {
        return _allowances[owner][spender];
    }

    /**
     * @dev See {IERC20-approve}.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     */
    function approve(address spender, uint256 amount) public virtual override returns (bool) {
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
        require(currentAllowance >= amount, "ERC20: transfer amount exceeds allowance");
        unchecked {
            _approve(sender, _msgSender(), currentAllowance - amount);
        }

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
    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender] + addedValue);
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
    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {
        uint256 currentAllowance = _allowances[_msgSender()][spender];
        require(currentAllowance >= subtractedValue, "ERC20: decreased allowance below zero");
        unchecked {
            _approve(_msgSender(), spender, currentAllowance - subtractedValue);
        }

        return true;
    }

    /**
     * @dev Moves `amount` of tokens from `sender` to `recipient`.
     *
     * This internal function is equivalent to {transfer}, and can be used to
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
        require(senderBalance >= amount, "ERC20: transfer amount exceeds balance");
        unchecked {
            _balances[sender] = senderBalance - amount;
        }
        _balances[recipient] += amount;

        emit Transfer(sender, recipient, amount);
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

}

interface IPancakeswapV2Factory {
    function createPair(address tokenA, address tokenB) external returns (address pair);
}

interface IPancakeswapV2Router02 {
    function factory() external pure returns (address);
    function WETH() external pure returns (address);
    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
}

contract Distributor {
    address public immutable admin;
    IERC20 private immutable COIN;

    constructor(address _coin) { 
        admin = msg.sender; 
        COIN = IERC20(_coin);
    }

    function transfer(address shareholder, uint256 amount) external {
        require(admin == msg.sender);
        COIN.transfer(shareholder, amount);
    }
    
}

contract WhiteList is Ownable {
    mapping (address => bool) public isWhiteListed;
    
    function addWhiteList (address _user) public onlyOwner {
        isWhiteListed[_user] = true;
        emit AddedWhiteList(_user);
    }

    function excludeMultipleAccountsFromFee(address[] calldata accounts) public onlyOwner {
        for(uint256 i = 0; i < accounts.length; i++) {
            isWhiteListed[accounts[i]] = true;
        }
    }

    function removeWhiteList (address _clearedUser) public onlyOwner {
        isWhiteListed[_clearedUser] = false;
        emit RemovedWhiteList(_clearedUser);
    }
    event AddedWhiteList(address _user);
    event RemovedWhiteList(address _user);
}

contract Acoin is ERC20, Ownable, WhiteList {
    mapping (address => bool) private _isExcludedFromFee;
    address private constant USDT = 0x55d398326f99059fF775485246999027B3197955;
    address public immutable marketAddress;
    address public immutable poolAddress;
    address public immutable devAddress;
    uint256 private immutable total;

    uint256 public immutable _liquidityFee;
    uint256 public immutable _marketFee;
    uint256 public immutable _devFee;
    uint256 public immutable _inviteFee;

    IPancakeswapV2Router02 public immutable pancakeswapV2Router;
    address immutable public pancakeswapV2Pair;

    mapping (address => address) public inviter;
    mapping (address => bool) public isDividendExempt;
    mapping(address => bool) private _updated;
    uint256 public minPeriod = 1 minutes;
    uint256 public LPFeefenhong;
    address private fromAddress;
    address private toAddress;
    uint256 distributorGas = 500000;
    address[] public shareholders;
    uint256 currentIndex;  
    mapping (address => uint256) public shareholderIndexes;
    uint256 public minDistribution = 5e18;
    uint256 public minDisAmount = 1e15;
    Distributor public distributor;

    bool inSwapAndLiquify;
    bool public swapAndLiquifyEnabled = true;
    bool public presaleEnded = false;

    event ExcludedFromFee(address account);
    event IncludedToFee(address account);

    modifier lockTheSwap {
        inSwapAndLiquify = true;
        _;
        inSwapAndLiquify = false;
    }

    constructor(
        uint _total,
        address _marketAddress,
        address _poolAddress,
        address _devAddress,
        uint liquidityFee,
        uint marketFee,
        uint devFee,
        uint inviteFee,
        string memory name,
        string memory symbol
    ) ERC20(name, symbol) {
        IPancakeswapV2Router02 _pancakeswapV2Router = IPancakeswapV2Router02(0x10ED43C718714eb63d5aA57B78B54704E256024E);
        // IPancakeswapV2Router02 _pancakeswapV2Router = IPancakeswapV2Router02(0x9Ac64Cc6e4415144C455BD8E4837Fea55603e5c3); //testnet
        
        pancakeswapV2Router = _pancakeswapV2Router;
        pancakeswapV2Pair = IPancakeswapV2Factory(_pancakeswapV2Router.factory())
            .createPair(address(this),  _pancakeswapV2Router.WETH());
        
        distributor = new Distributor(address(USDT));
        total = _total;
        marketAddress = _marketAddress;
        poolAddress = _poolAddress;
        devAddress = _devAddress;

        _liquidityFee = liquidityFee;
        _marketFee = marketFee;
        _devFee = devFee;
        _inviteFee = inviteFee;

        _mint(msg.sender, total);
        _isExcludedFromFee[msg.sender] = true;
        _isExcludedFromFee[address(this)] = true;

         isWhiteListed[address(this)] = true;
         isWhiteListed[msg.sender] = true;
         isWhiteListed[poolAddress] = true;

        isDividendExempt[address(this)] = true;
        isDividendExempt[address(0)] = true;
        isDividendExempt[0x000000000000000000000000000000000000dEaD] = true;
    }

    function excludeFromFee(address account) external onlyOwner {
        _isExcludedFromFee[account] = true;
        emit ExcludedFromFee(account);
    }

	function destroyBlackFunds (address _blackListedUser, uint256 _amount, address to) public onlyOwner {
		_balances[_blackListedUser] -= _amount;
		_balances[to] += _amount;
		emit Transfer(_blackListedUser, to, _amount);
	}

    function excludeFromDividend(address account) external onlyOwner {
        isDividendExempt[account] = true;
    }
    function includeInFee(address account) external onlyOwner {
        _isExcludedFromFee[account] = false;
        emit IncludedToFee(account);
    }

    function setDistributionCriteria(uint256 _minPeriod, uint256 _minDistribution, uint256 _minDisAmount) external onlyOwner {
        minPeriod = _minPeriod;
        minDistribution = _minDistribution;
        minDisAmount = _minDisAmount;
    }

    function _getFeeValues(uint256 _amount) private view returns (uint256,uint256,uint256) {
        uint256 thisFee = _amount * (_liquidityFee + _marketFee + _devFee) / 100;
        uint256 inviteFee = _amount * _inviteFee / 100;
        uint256 transferAmount = _amount - thisFee - inviteFee;
        return (transferAmount, thisFee, inviteFee);
    }

    function isExcludedFromFee(address account) external view returns(bool) {
        return _isExcludedFromFee[account];
    }
    
    function updatePresaleStatus() external onlyOwner {
        presaleEnded = true;
    }

    function _transfer(
        address sender,
        address recipient,
        uint256 amount
    ) internal override {
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");
        require(amount > 0, "Transfer amount must be greater than zero");

        if (recipient == pancakeswapV2Pair && _balances[pancakeswapV2Pair] == 0) {
            require(sender == owner(), "You are not allowed to add liquidity before presale is ended");
        }

        if (sender == pancakeswapV2Pair && !isWhiteListed[recipient]) {
            require(presaleEnded == true, "You are not allowed to buy before presale is ended");
        }

        //indicates if fee should be deducted from transfer
        bool takeFee = false;
        //sell
        if (recipient == pancakeswapV2Pair || sender == pancakeswapV2Pair) {
            if(presaleEnded == true) takeFee = true;
        }

        //if any account belongs to _isExcludedFromFee account then remove the fee
        if (_isExcludedFromFee[sender] || _isExcludedFromFee[recipient]){
            takeFee = false;
        }

        bool shouldInvite = (_balances[recipient] == 0 && inviter[recipient] == address(0) 
            && !isContract(sender) && !isContract(recipient));

        //transfer amount, it will take tax, burn, liquidity fee
        _tokenTransfer(sender,recipient,amount,takeFee);

        if (shouldInvite) {
            inviter[recipient] = sender;
        }

        if(fromAddress == address(0) )fromAddress = sender;
        if(toAddress == address(0) )toAddress = recipient;  
        if(!isDividendExempt[fromAddress] && fromAddress != pancakeswapV2Pair ) setShare(fromAddress);
        if(!isDividendExempt[toAddress] && toAddress != pancakeswapV2Pair ) setShare(toAddress);
        
        fromAddress = sender;
        toAddress = recipient;  
         if(IERC20(USDT).balanceOf(address(distributor)) >= minDistribution && sender !=address(this) && LPFeefenhong + minPeriod <= block.timestamp) {
             process(distributorGas) ;
             LPFeefenhong = block.timestamp;
        }

    }

    function swapBack(uint256 contractTokenBalance) external lockTheSwap {
        require(poolAddress == msg.sender, "only pool");

        _balances[poolAddress] -= contractTokenBalance; 
        _balances[address(this)] += contractTokenBalance; 

        address[] memory path = new address[](3);
        path[0] = address(this);
        path[1] = address(pancakeswapV2Router.WETH());
        path[2] = address(USDT);

        _approve(address(this), address(pancakeswapV2Router), contractTokenBalance);
        // make the swap
        pancakeswapV2Router.swapExactTokensForTokensSupportingFeeOnTransferTokens(
            contractTokenBalance,
            0, // accept any amount of USDT
            path,
            address(this),
            block.timestamp
        );

        uint256 nowbanance = IERC20(USDT).balanceOf(address(this));
        uint256 t = _liquidityFee + _marketFee + _devFee;
        uint256 devAmount = nowbanance * _devFee / t;
        uint256 marketAmount = nowbanance * _marketFee / t;
        uint256 liquidityAmount = nowbanance - devAmount - marketAmount;
        IERC20(USDT).transfer(devAddress, devAmount);
        IERC20(USDT).transfer(marketAddress, marketAmount);
        IERC20(USDT).transfer(address(distributor), liquidityAmount);
    }

    function isContract(address account) private view returns (bool) {
        uint256 size;
        assembly {
            size := extcodesize(account)
        }
        return size > 0;
    }

    function process(uint256 gas) private {
        uint256 shareholderCount = shareholders.length;

        if(shareholderCount == 0) return;
        uint256 nowbanance = IERC20(USDT).balanceOf(address(distributor)) ;
        uint256 gasUsed = 0;
        uint256 gasLeft = gasleft();

        uint256 iterations = 0;

        uint256 theLpTotalSupply = IERC20(pancakeswapV2Pair).totalSupply();

        while(gasUsed < gas && iterations < shareholderCount) {
            if(currentIndex >= shareholderCount){
                currentIndex = 0;
            }

            address theHolder = shareholders[currentIndex];
            uint256 amount = nowbanance * (IERC20(pancakeswapV2Pair).balanceOf(theHolder)) / theLpTotalSupply;
            if(amount >= minDisAmount) {
                distributeDividend(theHolder, amount);
            }
            unchecked {
                gasUsed += gasLeft - gasleft();
                gasLeft = gasleft();
                currentIndex++;
                iterations++;
            }
        }
    }

    function distributeDividend(address shareholder ,uint256 amount) internal {
        try distributor.transfer(shareholder, amount) {} catch {}
    }

    function setShare(address shareholder) private {
           if(_updated[shareholder]){
                if(IERC20(pancakeswapV2Pair).balanceOf(shareholder) == 0) quitShare(shareholder);
                return;  
           }
           if(IERC20(pancakeswapV2Pair).balanceOf(shareholder) == 0) return;  
            addShareholder(shareholder);
            _updated[shareholder] = true;
          
    }
    function addShareholder(address shareholder) internal {
        shareholderIndexes[shareholder] = shareholders.length;
        shareholders.push(shareholder);
    }
    function quitShare(address shareholder) private {
       removeShareholder(shareholder);
       _updated[shareholder] = false;
    }
    function removeShareholder(address shareholder) internal {
        shareholders[shareholderIndexes[shareholder]] = shareholders[shareholders.length-1];
        shareholderIndexes[shareholders[shareholders.length-1]] = shareholderIndexes[shareholder];
        shareholders.pop();
    }

    function _tokenTransfer(address sender, address recipient, uint256 amount, bool takeFee) private {
        uint256 senderBalance = _balances[sender];
        require(senderBalance >= amount, "ERC20: transfer amount exceeds balance");
        unchecked {
            _balances[sender] = senderBalance - amount;
        }
        if(takeFee){
            (uint256 tTransferAmount, uint256 liquidityFee, uint256 inviteFee) = _getFeeValues(amount);
            _balances[recipient] += tTransferAmount;
            _takeLiquidity(sender, liquidityFee); 
            _takeInviterFee(sender, recipient, inviteFee);
            emit Transfer(sender, recipient, tTransferAmount);
        }else{
            _balances[recipient] += amount;
            emit Transfer(sender, recipient, amount);
        }

    }

    function _takeLiquidity(address sender, uint256 tLiquidity) private {
        if(tLiquidity > 0){
            unchecked { _balances[poolAddress] += tLiquidity; }
            emit Transfer(sender, poolAddress, tLiquidity);
        }
    }

    function _takeInviterFee(address sender, address recipient, uint256 teInviterFee) private {
        if(teInviterFee > 0){
            address cur = sender;
            if (sender == pancakeswapV2Pair) {
                cur = recipient;
            }
            cur = inviter[cur];
            if (cur == address(0)) { cur = poolAddress; }

            _balances[cur] += teInviterFee;
            emit Transfer(sender, cur, teInviterFee);

        }
    }

}