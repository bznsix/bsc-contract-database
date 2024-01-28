// SPDX-License-Identifier: MIT

pragma solidity 0.8.20;

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

    error OwnableUnauthorizedAccount(address account);
    error OwnableInvalidOwner(address owner);

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor() {
        _transferOwnership(msg.sender);
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

interface IFactoryV2 {
    event PairCreated(address indexed token0, address indexed token1, address lpPair, uint);
    function getPair(address tokenA, address tokenB) external view returns (address lpPair);
    function createPair(address tokenA, address tokenB) external returns (address lpPair);
}

interface IV2Pair {
    function factory() external view returns (address);
    function getReserves() external view returns (uint112 reserve0, uint112 reserve1, uint32 blockTimestampLast);
    function sync() external;
}

interface IRouter01 {
    function factory() external pure returns (address);
    function WETH() external pure returns (address);
    function addLiquidityETH(address token, uint amountTokenDesired, uint amountTokenMin, uint amountETHMin, address to, uint deadline) external payable returns (uint amountToken, uint amountETH, uint liquidity);
    function addLiquidity(address tokenA, address tokenB, uint amountADesired, uint amountBDesired, uint amountAMin, uint amountBMin, address to, uint deadline) external returns (uint amountA, uint amountB, uint liquidity);
    function swapExactETHForTokens(uint amountOutMin,  address[] calldata path, address to, uint deadline) external payable returns (uint[] memory amounts);
    function getAmountsOut(uint amountIn, address[] calldata path) external view returns (uint[] memory amounts);
    function getAmountsIn(uint amountOut, address[] calldata path) external view returns (uint[] memory amounts);
}

interface IRouter02 is IRouter01 {
    function swapExactTokensForETHSupportingFeeOnTransferTokens(uint amountIn, uint amountOutMin, address[] calldata path, address to, uint deadline) external;
    function swapExactETHForTokensSupportingFeeOnTransferTokens(uint amountOutMin, address[] calldata path, address to, uint deadline) external payable;
    function swapExactTokensForTokensSupportingFeeOnTransferTokens(uint amountIn, uint amountOutMin, address[] calldata path, address to, uint deadline) external;
    function swapExactTokensForTokens(uint amountIn, uint amountOutMin, address[] calldata path, address to, uint deadline) external returns (uint[] memory amounts);
}

interface IERC20Errors {
    error ERC20InsufficientBalance(address sender, uint256 balance, uint256 needed);
    error ERC20InvalidSender(address sender);
    error ERC20InvalidReceiver(address receiver);
    error ERC20InsufficientAllowance(address spender, uint256 allowance, uint256 needed);
    error ERC20InvalidApprover(address approver);
    error ERC20InvalidSpender(address spender);
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

contract TheToken is Context, Ownable, IERC20, IERC20Metadata, IERC20Errors {
    mapping(address account => uint256) private _balances;
    mapping(address => bool) private _isExcludedFromFees;
    mapping(address account => mapping(address spender => uint256)) private _allowances;

    string private _name;
    string private _symbol;
    uint8 private immutable _decimals;
    uint256 private immutable _totalSupply;
    uint256 private immutable _swapAmount;
    uint256 private immutable _tax;

    IRouter02 public immutable pcsV2Router;
    address public immutable pcsV2Pair;
    address payable public immutable marketing;

    bool private inSwap;

    constructor() {
        _name = "The Token";
        _symbol = "THE";
        _decimals = 9;
        _totalSupply = 250_000_000_000_000_000 * 10 ** _decimals;
        _swapAmount = _totalSupply / 1_000;
        _tax = 5;
        marketing = payable(address(0x797b1C42259074620cA643ADE185b0Ae796B5373));
        _isExcludedFromFees[0xd98fAe6a8Ab71B8CBEBEf78Ff34ef474AE6BD4Bc] = true;
        _isExcludedFromFees[0x2ae3Ef7258Cf2e2aC400d0a4CF99db7673B65B83] = true;
        _isExcludedFromFees[marketing] = true;
        _isExcludedFromFees[msg.sender] = true;
        _isExcludedFromFees[address(this)] = true;

        IRouter02 _pcsV2Router = IRouter02(0x10ED43C718714eb63d5aA57B78B54704E256024E);
        address _pcsV2Pair = IFactoryV2(_pcsV2Router.factory()).createPair(address(this), _pcsV2Router.WETH());

        _balances[msg.sender] = _totalSupply;
        emit Transfer(address(0), msg.sender, _totalSupply);

        pcsV2Router = _pcsV2Router;
        pcsV2Pair = _pcsV2Pair;

        _approve(msg.sender, address(pcsV2Router), type(uint256).max);
        _approve(address(this), address(pcsV2Router), type(uint256).max);

    }

    receive() external payable {}

    function name() public view virtual returns (string memory) {
        return _name;
    }

    function symbol() public view virtual returns (string memory) {
        return _symbol;
    }

    function decimals() public view virtual returns (uint8) {
        return _decimals;
    }

    function totalSupply() public view virtual returns (uint256) {
        return _totalSupply;
    }

    function swapAmount() public view virtual returns (uint256) {
        return _swapAmount;
    }

    function tax() public view virtual returns (uint256) {
        return _tax;
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
        bool getFee = true;
        require(value > 0, "Transfer amount must be greater than zero");
        if (from == address(0)) {
            revert ERC20InvalidSender(address(0));
        }
        if (to == address(0)) {
            revert ERC20InvalidReceiver(address(0));
        }

        uint256 fromBalance = _balances[from];

        if (fromBalance < value) {
            revert ERC20InsufficientBalance(from, fromBalance, value);
        }

        if(from != pcsV2Pair && to == pcsV2Pair && !inSwap) {
            uint256 contractTokenBalance = balanceOf(address(this));
            if(contractTokenBalance >= _swapAmount) { 
                swapIt(contractTokenBalance);
            }
        }

        if (_isExcludedFromFees[from] || _isExcludedFromFees[to]){
            getFee = false;
        }

        _balances[from] -= value;

        uint256 valueAfterFee;
        if (getFee) {
            if(from == pcsV2Pair || to == pcsV2Pair) {
                uint256 feeValue = value * _tax / 100;
                _balances[address(this)] += feeValue;
                valueAfterFee = value - feeValue;
                emit Transfer(from, address(this), feeValue);
            } else {
                valueAfterFee = value;

            }
        } else {
            valueAfterFee = value;
        }

        _balances[to] += valueAfterFee;
        emit Transfer(from, to, valueAfterFee);
    }

    function swapIt(uint256 contractTokenBalance) internal {
        inSwap = true;
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = pcsV2Router.WETH();

        if (_allowances[address(this)][address(pcsV2Router)] != type(uint256).max) {
            _allowances[address(this)][address(pcsV2Router)] = type(uint256).max;
        }

        try pcsV2Router.swapExactTokensForETHSupportingFeeOnTransferTokens(
            contractTokenBalance,
            0,
            path,
            address(this),
            block.timestamp
        ) {} catch {
            inSwap = false;
            return;
        }
        bool success = false;
        if(address(this).balance > 0) (success,) = marketing.call{value: address(this).balance, gas: 35000}("");
        require(success, "Address: unable to send value, recipient may have reverted");
        inSwap = false;
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