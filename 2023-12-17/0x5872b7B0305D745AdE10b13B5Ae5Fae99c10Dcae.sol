// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

interface ISTARDEXCore {
    function sell(address wallet, uint amount) external;
    function receiveTokens(address wallet, uint amount, uint data) external;
    function receiveTokens(address wallet, uint amount, bytes memory data) external;
}

interface IERC20 {
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address to, uint256 value) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 value) external returns (bool);
    function transferFrom(address from, address to, uint256 value) external returns (bool);
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

interface IERC20Errors {
    error ERC20InsufficientBalance(address sender, uint256 balance, uint256 needed);
    error ERC20InvalidSender(address sender);
    error ERC20InvalidReceiver(address receiver);
    error ERC20InsufficientAllowance(address spender, uint256 allowance, uint256 needed);
    error ERC20InvalidApprover(address approver);
    error ERC20InvalidSpender(address spender);
}

abstract contract ERC20 is Context, IERC20, IERC20Metadata, IERC20Errors {
    mapping(address account => uint256) private _balances;

    mapping(address account => mapping(address spender => uint256)) private _allowances;

    uint256 private _totalSupply;

    string private _name;
    string private _symbol;

    constructor(string memory name_, string memory symbol_) {
        _name = name_;
        _symbol = symbol_;
    }

    function name() public view virtual returns (string memory) {
        return _name;
    }

    function symbol() public view virtual returns (string memory) {
        return _symbol;
    }

    function decimals() public view virtual returns (uint8) {
        return 18;
    }

    function totalSupply() public view virtual returns (uint256) {
        return _totalSupply;
    }

    function balanceOf(address account) public view virtual returns (uint256) {
        return _balances[account];
    }

    function transfer(address to, uint256 value) public virtual returns (bool) {
        address owner = _msgSender();
        _transfer(owner, to, value);
        return true;
    }

    function allowance(address owner, address spender) public view virtual returns (uint256) {
        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 value) public virtual returns (bool) {
        address owner = _msgSender();
        _approve(owner, spender, value);
        return true;
    }

    function transferFrom(address from, address to, uint256 value) public virtual returns (bool) {
        address spender = _msgSender();
        _spendAllowance(from, spender, value);
        _transfer(from, to, value);
        return true;
    }

    function _transfer(address from, address to, uint256 value) internal {
        if (from == address(0)) {
            revert ERC20InvalidSender(address(0));
        }
        if (to == address(0)) {
            revert ERC20InvalidReceiver(address(0));
        }
        _update(from, to, value);
    }

    function _update(address from, address to, uint256 value) internal virtual {
        if (from == address(0)) {
            _totalSupply += value;
        } else {
            uint256 fromBalance = _balances[from];
            if (fromBalance < value) {
                revert ERC20InsufficientBalance(from, fromBalance, value);
            }
            unchecked {
                _balances[from] = fromBalance - value;
            }
        }

        if (to == address(0)) {
            unchecked {
                _totalSupply -= value;
            }
        } else {
            unchecked {
                _balances[to] += value;
            }
        }

        emit Transfer(from, to, value);
    }

    function _mint(address account, uint256 value) internal {
        if (account == address(0)) {
            revert ERC20InvalidReceiver(address(0));
        }
        _update(address(0), account, value);
    }

    function _burn(address account, uint256 value) internal {
        if (account == address(0)) {
            revert ERC20InvalidSender(address(0));
        }
        _update(account, address(0), value);
    }

    function _approve(address owner, address spender, uint256 value) internal {
        _approve(owner, spender, value, true);
    }

    function _approve(address owner, address spender, uint256 value, bool emitEvent) internal virtual {
        if (owner == address(0)) {
            revert ERC20InvalidApprover(address(0));
        }
        if (spender == address(0)) {
            revert ERC20InvalidSpender(address(0));
        }
        _allowances[owner][spender] = value;
        if (emitEvent) {
            emit Approval(owner, spender, value);
        }
    }

    function _spendAllowance(address owner, address spender, uint256 value) internal virtual {
        uint256 currentAllowance = allowance(owner, spender);
        if (currentAllowance != type(uint256).max) {
            if (currentAllowance < value) {
                revert ERC20InsufficientAllowance(spender, currentAllowance, value);
            }
            unchecked {
                _approve(owner, spender, currentAllowance - value, false);
            }
        }
    }
}

abstract contract ERC20Burnable is Context, ERC20 {
    function burn(uint256 value) public virtual {
        _burn(_msgSender(), value);
    }

    function burnFrom(address account, uint256 value) public virtual {
        _spendAllowance(account, _msgSender(), value);
        _burn(account, value);
    }
}

abstract contract Ownable is Context {
    address private _owner;

    error OwnableUnauthorizedAccount(address account);
    error OwnableInvalidOwner(address owner);

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor(address initialOwner) {
        if (initialOwner == address(0)) {
            revert OwnableInvalidOwner(address(0));
        }
        _transferOwnership(initialOwner);
    }

    modifier onlyOwner() {
        _checkOwner();
        _;
    }

    function owner() public view virtual returns (address) {
        return _owner;
    }

    function _checkOwner() internal view virtual {
        if (owner() != _msgSender()) {
            revert OwnableUnauthorizedAccount(_msgSender());
        }
    }

    function renounceOwnership() public virtual onlyOwner {
        _transferOwnership(address(0));
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        if (newOwner == address(0)) {
            revert OwnableInvalidOwner(address(0));
        }
        _transferOwnership(newOwner);
    }

    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}

contract STARDEXCoin is ERC20, ERC20Burnable, Ownable {
    bool public mintersInitialized;
    mapping (address => bool) public minters;

    event LockUpdated(address indexed wallet, bool enabled, uint256 amount, uint256 expired);

    struct Lock {
        bool enabled;
        uint256 amount;
        uint256 expired; //unixtime unlock
    }

    mapping (address => Lock) private _locks;

    function isContract(address minter) internal view returns (bool) {
        uint32 size;
        assembly {
            size := extcodesize(minter)
        }
        return (size > 0);
    }

    constructor(address initialOwner)
        ERC20("STARDEX Coin", "STAR")
        Ownable(initialOwner)
    {}

    function mint(address to, uint256 amount) public {
        require(minters[_msgSender()] || owner() == _msgSender(), "only minters/owner");

        _mint(to, amount);
    }

    function mint(address to, uint256 amount, uint256 expired, bool rewriteAmount) public {
        require(minters[_msgSender()] || owner() == _msgSender(), "only minters/owner");

        _mint(to, amount);

        if (rewriteAmount || !_locks[to].enabled) {
            Lock memory lock = Lock(true, amount, expired);
            _locks[to] = lock;
            emit LockUpdated(to, lock.enabled, lock.amount, lock.expired);
        } else {
            Lock storage lock = _locks[to];
            lock.enabled = true;
            lock.expired = expired;
            lock.amount += amount;
            emit LockUpdated(to, lock.enabled, lock.amount, lock.expired);
        }
    }

    function transferFrom(address from, address to, uint256 value) public override  returns (bool) {
        require(value > 0, "Value error");

        uint256 lockedAmount = amountLocks(from);
        if (lockedAmount > 0) {
            if (balanceOf(from) >= lockedAmount) {
                require(balanceOf(from) - lockedAmount >= value, "Transfer value locked");
            } else {
                revert("Transfer value locked");
            }
        }

        return super.transferFrom(from, to, value);
    }

    function lockCoins(address wallet, bool enabled, uint256 amount, uint256 expired, bool rewriteAmount) public {
        require(minters[_msgSender()] || owner() == _msgSender(), "only minters/owner");

        if (rewriteAmount || !_locks[wallet].enabled) {
            Lock memory lock = Lock(enabled, amount, expired);
            _locks[wallet] = lock;
            emit LockUpdated(wallet, lock.enabled, lock.amount, lock.expired);
        } else {
            Lock storage lock = _locks[wallet];       
            lock.enabled = enabled;
            lock.expired = expired;
            lock.amount += amount;
            emit LockUpdated(wallet, lock.enabled, lock.amount, lock.expired);
        }
    }

    function transfer(address to, uint256 value) public override returns (bool) {
        require(value > 0, "Value error");

        address owner = _msgSender();
        uint256 lockedAmount = amountLocks(owner);
        if (lockedAmount > 0) {
            if (balanceOf(owner) >= lockedAmount) {
                require(balanceOf(owner) - lockedAmount >= value, "Transfer value locked");
            } else {
                revert("Transfer value locked");
            }
        }

        return super.transfer(to, value);
    }

    function balanceAvailable(address wallet) public view returns (uint256) {
        uint256 balanceAmount = balanceOf(wallet);
        uint256 locksAmount = amountLocks(wallet);

        if (balanceAmount == 0 || balanceAmount < locksAmount) {
            return 0;
        } else {
            return balanceAmount - locksAmount;
        }
    }

    function amountLocks(address wallet) public view returns (uint256) {
        uint256 amount = 0;
        if (wallet == address(0)) {
            return amount;
        } else {
            Lock memory lock = _locks[wallet];
            if (lock.enabled && lock.expired >= block.timestamp) {
                amount = lock.amount;
            }
            return amount;
        }
    }

    function locks(address wallet) public view returns (Lock memory) {
        return _locks[wallet];
    }
 
    function updateMinters(address minter, bool value) public onlyOwner {
        require(minter != address(0), "Minter address null");

        if (!mintersInitialized) {
            minters[minter] = value;
        } else {
            revert();
        }
    }

    function finalizeMinters() public onlyOwner {
        mintersInitialized = true;
    }

    function send(address receiver, uint amount, uint data)
    public 
    returns (bool approved) 
    {
        require(!isContract(_msgSender()), "only wallets");

        if (approve(receiver, amount)) {
            ISTARDEXCore(receiver).receiveTokens(_msgSender(), amount, data);
            return true;
        } else {
            return false;
        }
    }

    function send(address receiver, uint amount, bytes memory data)
    public 
    returns (bool approved) 
    {
        require(!isContract(_msgSender()), "only wallets");

        if (approve(receiver, amount)) {
            ISTARDEXCore(receiver).receiveTokens(_msgSender(), amount, data);
            return true;
        } else {
            return false;
        }
    }

    function sell(address receiver, uint amount)
    public 
    returns (bool approved) 
    {
        require(!isContract(_msgSender()), "only wallets");

        if (approve(receiver, amount)) {
            ISTARDEXCore(receiver).sell(_msgSender(), amount);
            return true;
        } else {
            return false;
        }
    }

    function withdraw(address token) public onlyOwner {
        if (token == address(0)) {
            payable(msg.sender).transfer(address(this).balance);
        } else {
            IERC20(token).transfer(msg.sender, IERC20(token).balanceOf(address(this)));
        }
    }
}