/**
 *Submitted for verification at BscScan.com on 2024-01-29
*/

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

interface IRouter {
    function WETH() external view returns (address);
    function factory() external view returns (address);
    function swapExactTokensForTokensSupportingFeeOnTransferTokens(uint amountIn, uint amountOutMin, address[] calldata path, address to, uint deadline) external;
    function swapExactTokensForETHSupportingFeeOnTransferTokens(uint256 amountIn, uint256 amountOutMin, address[] calldata path, address to, uint256 deadline) external;
    function addLiquidityETH(address token, uint256 amountTokenDesired, uint256 amountTokenMin, uint256 amountETHMin, address to, uint256 deadline) external payable returns (uint256 amountToken, uint256 amountETH, uint256 liquidity);
}

interface IFactory {
    function getPair(address tokenA, address tokenB) external view returns (address pair);
}

interface IPair {
    function getReserves() external view returns (uint112 reserve0, uint112 reserve1, uint32 blockTimestampLast);
    function sync() external;
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

abstract contract TOKEN is ERC20, Ownable {
    using SafeMath for uint256;

    address public WETH;
    address public LP;

    uint256 public mrktFee1 = 200; // 2.0%
    uint256 public mrktFee2 = 180; // 1.8%

    address public routerAddr;
    address public marketingAddr1;
    address public marketingAddr2;

    uint256 public lastBurnTime;
    uint256 public lpBurnPercent = 30; // 0.3%
    uint256 public lpBurnDuration = 30 minutes;

    bool    public launched;
    bool    private _swapping;

    mapping(address => bool) private _isExcludedFromFees;

    modifier lockSwap() { _swapping = true; _; _swapping = false; }
    event BURN_LP(uint256 amount);

    constructor(
        string memory name_,
        string memory symbol_,
        uint8 decimals_,
        uint256 totalSupply_,
        address routerAddr_,
        address marketingAddr1_,
        address marketingAddr2_
    ) ERC20(name_, symbol_, decimals_) {
        WETH = IRouter(routerAddr_).WETH();
        routerAddr = routerAddr_;
        marketingAddr1 = marketingAddr1_;
        marketingAddr2 = marketingAddr2_;

        _isExcludedFromFees[marketingAddr1] = true;
        _isExcludedFromFees[marketingAddr2] = true;
        _isExcludedFromFees[address(this)] = true;
        _isExcludedFromFees[msg.sender] = true;
        _isExcludedFromFees[address(0xdead)] = true;

        _mint(address(this), totalSupply_);
        _approve(address(this), routerAddr, ~uint256(0));
    }

    // MINT CONFIG
    // CAN TOTAL MINT 8000 TIMES
    uint256 public constant MINT_VALUE = 0.02 ether;                // per mint 0.02 BNB
    uint256 public constant MINT_AMOUNT = 100 * (10**18);          // per mint 1000 token
    uint256 public constant MAX_MINTABLE_AMOUNT = 50 * MINT_AMOUNT; // 50 times
    uint256 public constant ADDLP_VALUE = 0.25 ether;               // per addlp 0.25 BNB
    uint256 public constant ADDLP_AMOUNT = 1250 * (10**18);        // per addlp 12500 token

    receive() external payable {
        require(!launched, "LAUNCHED");
        require(msg.sender == tx.origin, "!EOA");
        require(msg.value == MINT_VALUE, "!VALUE");
        require(balanceOf(msg.sender) <= MAX_MINTABLE_AMOUNT - MINT_AMOUNT, "!MAX_MINTABLE_AMOUNT");

        super._transfer(address(this), msg.sender, MINT_AMOUNT);

        // per 50 mint, add liquidity once
        if (address(this).balance >= 50 * MINT_VALUE) {
            addLiquidity(ADDLP_AMOUNT, ADDLP_VALUE);
            TransferHelper.safeTransferETH(marketingAddr1, address(this).balance);
        }

        if (balanceOf(address(this)) == 0) {
            launch();
        }
    }

    function launch() internal { launched = true; lastBurnTime = block.timestamp; }
    function manualLaunch() external onlyOwner { 
        if (address(this).balance > 0) TransferHelper.safeTransferETH(marketingAddr1, address(this).balance);
        if (balanceOf(address(this)) > 0) super._transfer(address(this), address(0xdead), balanceOf(address(this)));
        launch();
    }

    function excludeFromFees(address[] memory accounts, bool excluded) public onlyOwner {
        for (uint256 i = 0; i < accounts.length; i++) {
            _isExcludedFromFees[accounts[i]] = excluded;
        }
    }

    function set_fees(uint256 _mrktFee1, uint256 _mrktFee2) public onlyOwner {
        require(_mrktFee1 <= 2000, "invalid tax");
        require(_mrktFee2 <= 2000, "invalid tax");
        require(_mrktFee1 + _mrktFee2 > 0, "invalid tax");
        mrktFee1 = _mrktFee1;
        mrktFee2 = _mrktFee2;
    }

    function set_marketingAddr(address _marketingAddr1, address _marketingAddr2) public onlyOwner {
        marketingAddr1 = _marketingAddr1;
        marketingAddr2 = _marketingAddr2;
    }

    function set_lpBurnPercent(uint256 _lpBurnPercent) public onlyOwner {
        require(_lpBurnPercent <= 1000, "invalid burn percent");
        lpBurnPercent = _lpBurnPercent;
    }

    function set_lpBurnDuration(uint256 _lpBurnDuration) public onlyOwner {
        lpBurnDuration = _lpBurnDuration;
    }

    function _transfer(address from, address to, uint256 amount) internal override {
        require(from != address(0) && to != address(0) && amount != 0);

        if (_swapping || _isExcludedFromFees[from] || _isExcludedFromFees[to]) {
            super._transfer(from, to, amount);
            return;
        }

        require(launched, "not launched");
        
        bool isSell = to == LP;
        uint256 mrktFee1Amount = amount.mul(mrktFee1).div(10000);
        uint256 mrktFee2Amount = amount.mul(mrktFee2).div(10000);
        amount = amount.sub(mrktFee1Amount).sub(mrktFee2Amount);

        super._transfer(from, address(this), mrktFee1Amount + mrktFee2Amount);

        if (isSell && block.timestamp - lastBurnTime >= lpBurnDuration) burnLP();
        if (isSell && balanceOf(address(this)) > 0) {
            swapTokensForEth(balanceOf(address(this)).mul(mrktFee1).div(mrktFee1 + mrktFee2), marketingAddr1);
            swapTokensForEth(balanceOf(address(this)), marketingAddr2);
        }

        super._transfer(from, to, amount);
    }

    function burnLP() internal {
        uint256 burnAmount = balanceOf(LP).mul(lpBurnPercent).div(10000);
        super._transfer(LP, address(0xdead), burnAmount);
        IPair(LP).sync();
        lastBurnTime = block.timestamp;
        emit BURN_LP(burnAmount);
    }

    function swapTokensForEth(uint256 amount, address to) internal lockSwap {
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = WETH;
        IRouter(routerAddr).swapExactTokensForETHSupportingFeeOnTransferTokens(
            amount,
            0,
            path,
            to,
            block.timestamp
        );
    }

    function addLiquidity(uint256 tokenAmount, uint256 ethAmount) internal lockSwap {
        IRouter(routerAddr).addLiquidityETH{value: ethAmount}(
            address(this),
            tokenAmount,
            0,
            0,
            marketingAddr1,
            block.timestamp
        );
        if (LP == address(0)) LP = IFactory(IRouter(routerAddr).factory()).getPair(address(this), WETH);
    }
}

contract H8 is TOKEN {
    constructor()
    TOKEN(
        /* name */             "H8",
        /* symbol */           "H8",
        /* decimals */         18,
        /* totalSupply */      100 * 10000 * (10**18),
        /* router */           0x10ED43C718714eb63d5aA57B78B54704E256024E,
        /* marketingAddr1 */   0xD4404ea557B16587596060BEa90dE8903D34A192,
        /* marketingAddr2 */   0x37a06492311f9680EC8aF006236911109bE23e69
    )
    {}
}