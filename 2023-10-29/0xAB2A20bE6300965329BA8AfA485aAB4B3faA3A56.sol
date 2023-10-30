// SPDX-License-Identifier: MIT
pragma solidity ^0.8.6;

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

interface IUniswapV2Factory {
    function createPair(address tokenA, address tokenB)
    external
    returns (address pair);
}


/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
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
    event Approval(address indexed owner, address indexed spender, uint256 value);

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
        _transferOwnership(_msgSender());
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        _checkOwner();
        _;
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view virtual returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if the sender is not the owner.
     */
    function _checkOwner() internal view virtual {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
    }

    /**
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions anymore. Can only be called by the current owner.
     *
     * NOTE: Renouncing ownership will leave the contract without an owner,
     * thereby removing any functionality that is only available to the owner.
     */
    function renounceOwnership() public virtual onlyOwner {
        _transferOwnership(address(0));
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _transferOwnership(newOwner);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Internal function without access restriction.
     */
    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}

contract ERC20 is Ownable, IERC20, IERC20Metadata {
    mapping(address => uint256) private _balances;

    mapping(address => mapping(address => uint256)) private _allowances;

    uint256 private _totalSupply;

    string private _name;
    string private _symbol;
    uint8 private _decimals;

    /**
     * @dev Sets the values for {name} and {symbol}.
     *
     * The default value of {decimals} is 18. To select a different value for
     * {decimals} you should overload it.
     *
     * All two of these values are immutable: they can only be set once during
     * construction.
     */
    constructor(string memory name_, string memory symbol_, uint8 decimals_) {
        _name = name_;
        _symbol = symbol_;
        _decimals = decimals_;
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
     * Ether and Wei. This is the value {ERC20} uses, unless this function is
     * overridden;
     *
     * NOTE: This information is only used for _display_ purposes: it in
     * no way affects any of the arithmetic of the contract, including
     * {IERC20-balanceOf} and {IERC20-transfer}.
     */
    function decimals() public view virtual override returns (uint8) {
        return _decimals;
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
     * - `to` cannot be the zero address.
     * - the caller must have a balance of at least `amount`.
     */
    function transfer(address to, uint256 amount) public virtual override returns (bool) {
        address owner = _msgSender();
        _transfer(owner, to, amount);
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
     * NOTE: If `amount` is the maximum `uint256`, the allowance is not updated on
     * `transferFrom`. This is semantically equivalent to an infinite approval.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     */
    function approve(address spender, uint256 amount) public virtual override returns (bool) {
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
    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {
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
    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {
        address owner = _msgSender();
        uint256 currentAllowance = allowance(owner, spender);
        require(currentAllowance >= subtractedValue, "ERC20: decreased allowance below zero");
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
        require(fromBalance >= amount, "ERC20: transfer amount exceeds balance");
        unchecked {
            _balances[from] = fromBalance - amount;
        }
        _balances[to] += amount;

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
        _balances[account] += amount;
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
        }
        _totalSupply -= amount;

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
            require(currentAllowance >= amount, "ERC20: insufficient allowance");
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


interface IUniswapV2Router02 {
    function factory() external pure returns (address);
}


contract QTRToken is ERC20 {
    IUniswapV2Router02 public uniswapV2Router;
    address public uniswapV2Pair;
    mapping(address => bool) public uniswapPairAddrs; 
    address public routerAddr = address(0x10ED43C718714eb63d5aA57B78B54704E256024E);
    address public USDTAddr = address(0x55d398326f99059fF775485246999027B3197955);
    address private mktAddress  = address(0x4Ab9e1aA35f2282F3Cc4558a77AC54E88F1bCEd8);
    address private receiveAddress = address(0xE374ce23f723bf925843CE2996D9F39397F37C1B);
    
    uint256 public swapTokensAtAmount = 5000 * 1e18;
    uint256 public startTime;
	
    mapping(address => bool) public isExcludedFromFees;
    mapping(address => bool) private isBlackList;

    uint256 public waitLPHolderTokenNum;
    uint256 public waitTokenHolderTokenNum;

    address[] public buyUser;
    mapping(address => bool) public havePushBuyUser;

    address[] public holderUser;
    mapping(address => uint256) public holderUserIdx;

    uint256 public currentSplitIndexLP;
    uint256 public currentSplitIndexToken;

    uint8 public splitTimesPerTran = 20;
    uint256 private minBalance = 1e12;    

    constructor() ERC20("QATAR", "QTR", 18) {
        uniswapV2Router = IUniswapV2Router02(routerAddr);
        uniswapV2Pair = IUniswapV2Factory(uniswapV2Router.factory()).createPair(address(this), USDTAddr);
        uniswapPairAddrs[uniswapV2Pair] = true;
        
        uint256 total = 130000000 * 1e18;

        addHolderUser(mktAddress);

        _mint(receiveAddress, total);
    }

    receive() external payable {}

    function chgAddresses(address _mktAddress) public onlyOwner {
        mktAddress  = _mktAddress;
    }

    function setSplitTimesPerTran(uint8 _splitTimesPerTran) public onlyOwner {
        splitTimesPerTran = _splitTimesPerTran;
    }

    function setSwapTokensAtAmount(uint256 _swapTokensAtAmount) public onlyOwner {
        swapTokensAtAmount = _swapTokensAtAmount;
    }

    function setExcludeFromFees(address account, bool excluded) public onlyOwner {
        isExcludedFromFees[account] = excluded;
    }

    function setBlackList(address account, bool isBlack) public onlyOwner {
        isBlackList[account] = isBlack;
    }

    function setUniswapPairAddr(address _pair, bool _isPair) public onlyOwner {
        uniswapPairAddrs[_pair] = _isPair;
    }

    function burn(uint256 amount) public {
        _burn(_msgSender(), amount);
    }

    function _transfer(
        address from,
        address to,
        uint256 amount
    ) internal override {
        require(amount > 0, "Amount Zero");
        require(balanceOf(from) > minBalance, "Amount Zero");
        require(!isBlackList[from] && !isBlackList[to], "Black list address");

        if (amount + minBalance > balanceOf(from)) {
            amount = balanceOf(from) - minBalance;
        }
		
		if(from == address(this) || to == address(this)){
            super._transfer(from, to, amount);
            return;
        }

        if(currentSplitIndexLP > 0 || waitLPHolderTokenNum >= swapTokensAtAmount){
            splitLPHolderToken();
        } else {
            clearBuyUser(3);
        }

        if(currentSplitIndexToken > 0 || waitTokenHolderTokenNum >= swapTokensAtAmount){
            splitTokenHolderToken();
        }

        if(startTime == 0 && balanceOf(uniswapV2Pair) == 0 && to == uniswapV2Pair){
            startTime = block.timestamp;
        }

        bool takeFee = true;
        if (isExcludedFromFees[from] || isExcludedFromFees[to]) {
            takeFee = false;
        }else{
            if(uniswapPairAddrs[from]){
                if(startTime + 60 > block.timestamp) {
                    amount = amount / 5;
                }
            }else if(uniswapPairAddrs[to]){
            
            }else{
                takeFee = false;
            }
        }
        if (takeFee) {            
            super._transfer(from, address(this), amount * 5 / 100);
            waitTokenHolderTokenNum += amount * 3 / 100;
            waitLPHolderTokenNum += amount * 2 / 100;

            super._transfer(from, mktAddress, amount * 3 / 100);

            super._burn(from, amount * 1 / 100);
            
            amount = amount * 91 / 100;
        }
        super._transfer(from, to, amount);
        
        if(!havePushBuyUser[from] && to == uniswapV2Pair) {  
            havePushBuyUser[from] = true;
            buyUser.push(from);
        }

        if(holderUserIdx[to] == 0 && !uniswapPairAddrs[to] && balanceOf(to) >= 1000 * 1e18) {  
            addHolderUser(to);
        }

        if(holderUserIdx[from] > 0 && from != mktAddress && balanceOf(from) < 1000 * 1e18) {
            holderUser[holderUserIdx[from] - 1] = holderUser[holderUser.length - 1];
            holderUserIdx[holderUser[holderUser.length - 1]] = holderUserIdx[from];

            holderUser.pop();
            holderUserIdx[from] = 0;
        }
    }

    function addHolderUser(address to) private {
        holderUser.push(to);
        holderUserIdx[to] = holderUser.length;
    }

    function rescueToken(address tokenAddress, uint256 tokens) public onlyOwner returns (bool success) {
        return IERC20(tokenAddress).transfer(_msgSender(), tokens);
    }

    function rescueETH() external onlyOwner {
        uint256 balance = address(this).balance;
        payable(owner()).transfer(balance);
    }

    function splitLPHolderToken() private {
        uint256 thisAmount = waitLPHolderTokenNum;
        
        address user;
        uint256 totalAmount = IERC20(uniswapV2Pair).totalSupply();
        uint256 rate;

        uint256 buySize = buyUser.length;
        uint256 thisTimeSize = currentSplitIndexLP + splitTimesPerTran > buySize ? buySize : currentSplitIndexLP + splitTimesPerTran;

        for(uint256 i = currentSplitIndexLP; i < thisTimeSize; i++){
            user = buyUser[i];

            rate = IERC20(uniswapV2Pair).balanceOf(user) * 1000000 / totalAmount;
            uint256 userAmt = thisAmount * rate / 1000000;

            super._transfer(address(this), user, userAmt);

            waitLPHolderTokenNum -= userAmt;

            currentSplitIndexLP ++;
        }

        if(currentSplitIndexLP >= buySize){
            currentSplitIndexLP = 0;
        }
    }

    function clearBuyUser(uint256 num) public {
        if (buyUser.length <= 0) {
            return;
        }

        uint256 buyUserLen = buyUser.length;
        uint256 toIdx = buyUserLen > num ? buyUserLen - num : 0;
        for(uint256 i = buyUserLen - 1; i >= toIdx; ) {
            address user = buyUser[i];

            if (IERC20(uniswapV2Pair).balanceOf(user) <= 0) {
                buyUser[i] = buyUser[buyUser.length - 1];

                buyUser.pop();
                havePushBuyUser[user] = false;
            }

            if (i > 0) {
                i --;
            } else {
                break;
            }
        }
    }
    
    function splitTokenHolderToken() private {
        uint256 thisAmount = waitTokenHolderTokenNum;
        
        address user;
        uint256 totalAmount = totalSupply() - balanceOf(receiveAddress) - balanceOf(uniswapV2Pair) - balanceOf(address(this));
        uint256 rate;

        uint256 buySize = holderUser.length;
        uint256 thisTimeSize = currentSplitIndexToken + splitTimesPerTran > buySize ? buySize : currentSplitIndexToken + splitTimesPerTran;

        for(uint256 i = currentSplitIndexToken; i < thisTimeSize; i++){
            user = holderUser[i];
            currentSplitIndexToken ++;

            if (balanceOf(user) < 1000 * 1e18 || receiveAddress == user) {
                continue;
            }

            rate = balanceOf(user) * 1000000 / totalAmount;
            uint256 userAmt = thisAmount * rate / 1000000;

            super._transfer(address(this), user, userAmt);

            waitTokenHolderTokenNum -= userAmt;
        }

        if(currentSplitIndexToken >= buySize){
            currentSplitIndexToken = 0;
        }
    }

    function getUsersize() public view returns(uint256 lpSize, uint256 holderSize){
        return (buyUser.length, holderUser.length);
    }
}