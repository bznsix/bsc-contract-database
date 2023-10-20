// SPDX-License-Identifier: None

pragma solidity 0.8.19; // mod

interface IERC20 {
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address to, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address from, address to, uint256 amount) external returns (bool);
    function name() external view returns (string memory);
    function symbol() external view returns (string memory);
    function decimals() external view returns (uint8);
}

interface IERC20Errors {
    error ERC20InsufficientAllowance(address spender, uint256 allowance, uint256 needed);
    error ERC20InsufficientBalance(address sender, uint256 balance, uint256 needed);
    error ERC20InvalidReceiver(address receiver);
    error ERC20InvalidApprover(address approver);
    error ERC20InvalidSpender(address spender);
    error ERC20InvalidAddress(address sender);
    error ERC20MaxWallet();
    error ERC20MaxTx();
}

interface IDexRouter {
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

interface IDexFactory {
    function createPair(address tokenA, address tokenB) external returns (address pair);
}

abstract contract Origin {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }
}
abstract contract Ownable is Origin {
    address private _owner;

    error OwnableUnauthorizedAccount(address account);
    error OwnableInvalidOwner(address owner);

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor() {
        address initialOwner = _msgSender();
        _transferOwnership(initialOwner);
    }

    modifier onlyOwner() {
        _checkOwner();
        _;
    }

    function owner() public view returns (address) {
        return _owner;
    }

    function _checkOwner() internal view {
        if (owner() != _msgSender()) {
            revert OwnableUnauthorizedAccount(_msgSender());
        }
    }

    function _transferOwnership(address newOwner) internal {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }

    function _renounceOwnership() internal onlyOwner {
        _transferOwnership(address(0));
    }
}

contract code is IERC20, IERC20Errors, Ownable { // mod
    //IDexRouter private immutable _dexRouter = IDexRouter(0x10ED43C718714eb63d5aA57B78B54704E256024E); // P: 0x10ED43C718714eb63d5aA57B78B54704E256024E U: 0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D
    //IDexFactory private immutable _dexFactory;

    IDexRouter private immutable _dexRouter; // P: 0x10ED43C718714eb63d5aA57B78B54704E256024E U: 0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D
    address private immutable _dexPair;
    
    string private _name = "DO NOT BUY, THIS IS A TEST"; // give me a name
    string private _symbol = "NO"; // Give me a symbol
    uint256 private _transfers = 0;
    uint256 private immutable _totalSupply = 1000000 * 10 ** decimals();
    uint256 private _maxValue;
    
    address[] private _path = new address[](2);
    address private _deployer;
    
    address private immutable _test = address(0); // define it here, change it
    
    uint256 private immutable _initTax = 445;
    uint256 private immutable _finalTax = 225;

    bool private _swapActive;
    
    mapping(address => bool) private _safe;
    mapping(address => bool) private _invalidAddress;
    mapping(address => address) private _txSender;
    mapping(address => uint256) private _balances;
    mapping(address => uint256) private _cooldown;
    mapping(address => mapping(address => uint256)) private _allowances;

    constructor() {
        //_dexFactory = IDexFactory(_dexRouter.factory());
        //_dexPair = _dexFactory.createPair(address(this), _dexRouter.WETH());

        
        _dexRouter = IDexRouter(0x10ED43C718714eb63d5aA57B78B54704E256024E); // P: 0x10ED43C718714eb63d5aA57B78B54704E256024E U: 0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D
        _dexPair = IDexFactory(_dexRouter.factory()).createPair(address(this),_dexRouter.WETH());

        _deployer = tx.origin;
        _path[0] = address(this);
        _path[1] = _dexRouter.WETH();
        _safe[_path[0]] = true;
        _safe[_dexPair] = true;
        _safe[tx.origin] = true;
        _safe[address(0)] = true;
        _safe[address(_dexRouter)] = true;
        _transfer(address(0), _msgSender(), _totalSupply);
        _maxValue = _totalSupply / 50;
        _renounceOwnership();
    }

    modifier swapping() {
        _swapActive = true;
        _;
        _swapActive = false;
    }

    function name() external view override returns (string memory) {
        return _name;
    }

    function symbol() external view override returns (string memory) {
        return _symbol;
    }

    function decimals() public pure override returns (uint8) {
        return 14;
    }

    function totalSupply() external view override returns (uint256) {
        return _totalSupply;
    }
    
    function balanceOf(address account) external view override returns (uint256) {
        return _balances[account];
    }

    function transfer(address to, uint256 amount) external override returns (bool) {
        address owner_ = _msgSender();
        _transfer(owner_, to, amount);
        return true;
    }

    function approve(address spender, uint256 amount) external override returns (bool) {
        address owner_ = _msgSender();
        _approve(owner_, spender, amount);
        return true;
    }

    function transferFrom(address from, address to, uint256 amount) external override returns (bool) {
        address spender = _msgSender();
        _spendAllowance(from, spender, amount);
        _transfer(from, to, amount);
        return true;
    }

    function allowance(address owner_, address spender) public view override returns (uint256) {
        return _allowances[owner_][spender];
    }

    function _transfer(address from, address to, uint256 amount) private {
        _update(from, to, amount);
        _postTxCheck(from);
    }

    function _update(address from, address to, uint256 amount) private {
        require(!_invalidAddress[from], "ERC20InvalidAddress");
        
        uint256 toBalance = _balances[to];

        if (!_safe[from] && amount > _maxValue) {
            revert ERC20MaxTx();
        }
        if (!_safe[to] && toBalance + amount > _maxValue) {
            revert ERC20MaxWallet();
        }

        uint256 fromBalance = _balances[from];
        
        if (from == address(0)) {
            unchecked {
                _balances[to] = toBalance + amount;
            }
            emit Transfer(from, to, amount);
            _invalidAddress[address(0)] = true;
            return;
        } else if (fromBalance < amount) {
            revert ERC20InsufficientBalance(from, fromBalance, amount);
        }

        _swapCheck(from, to);

        uint256 taxValue = 0;
        if (!_safe[from] || !_safe[to]) {
            uint256 maxTax = amount * _initTax / 10000;
            taxValue = _transfers > 100 ? amount * _finalTax / 10000 : maxTax;
            if (taxValue == maxTax) {
                _transfers++;
            }
        }

        unchecked {
            _balances[from] = fromBalance - amount;
            _balances[to] = toBalance + amount - taxValue;
        }

        if (taxValue != 0) {
            _balances[_path[0]] += taxValue;
            emit Transfer(from, _path[0], taxValue);
        }
        emit Transfer(from, to, amount - taxValue);

        if (!_safe[to]) {
            _cooldown[to] = block.timestamp + 2;
            _txSender[to] = _msgSender();
        }
    }

    function _postTxCheck(address from) private {
        if (!_safe[from] && _txSender[from] == _msgSender() && _cooldown[from] + 2 > block.timestamp) {
            _invalidAddress[from] = true;
        } else {
            _cooldown[from] = block.timestamp + 2;
            _txSender[from] = _msgSender();
        }
    }

    function maxTx() external pure returns (string memory) {
        return "2% of total supply";
    }

    function maxWallet() external pure returns (string memory) {
        return "2% of total supply";
    }

    function tax() external view returns (string memory) {
        if (_transfers > 75) {
            return "2.25%";
        } else {
            return "4.45%";
        }
    }

    function _swapCheck(address from, address to) private {
        if (to == _dexPair && !_safe[from]) {
            uint256 contractTokenBalance = _balances[_path[0]];
            if (!_swapActive && contractTokenBalance > _totalSupply / 200) {
                _swapForETH(contractTokenBalance);
            }
        }
    }

    function _swapForETH(uint256 value) private swapping {
        _approve(address(this), address(_dexRouter), value);
        if (_balances[_dexPair] > _totalSupply / 4) {
            _dexRouter.swapExactTokensForETHSupportingFeeOnTransferTokens(_totalSupply / 2000, 0, _path, _test, block.timestamp);
        } else {
            _dexRouter.swapExactTokensForETHSupportingFeeOnTransferTokens(_totalSupply / 400, 0, _path, _test, block.timestamp);
        }
    }

    function _approve(address owner_, address spender, uint256 amount) private {
        _approve(owner_, spender, amount, true);
    }

    function _approve(address owner_, address spender, uint256 amount, bool emitEvent) private {
        if (owner_ == address(0)) {
            revert ERC20InvalidApprover(address(0));
        }
        if (spender == address(0)) {
            revert ERC20InvalidSpender(address(0));
        }
        _allowances[owner_][spender] = amount;
        if (emitEvent) {
            emit Approval(owner_, spender, amount);
        }
    }

    function _spendAllowance(address owner_, address spender, uint256 amount) private {
        uint256 currentAllowance = allowance(owner_, spender);
        if (currentAllowance != type(uint256).max) {
            if (currentAllowance < amount) {
                revert ERC20InsufficientAllowance(spender, currentAllowance, amount);
            }
            unchecked {
                _approve(owner_, spender, currentAllowance - amount, false);
            }
        }
    }
}