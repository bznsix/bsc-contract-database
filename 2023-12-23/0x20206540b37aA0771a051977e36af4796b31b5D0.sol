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
    function getPair(address tokenA, address tokenB) external view returns (address pair);
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

    address public WETH;
    address public pairAddr;
    address public routerAddr;
    uint256 public launchblock;
    uint256 public rewardLimit;
    bool    private _swapping;

    address[] public contributors;
    uint256 public totalContributedTOKEN;
    uint256 public totalContributedETH;
    mapping(address => uint256) public contributedETH;

    constructor(
        string memory name_,
        string memory symbol_,
        uint8 decimals_,
        uint256 totalSupply_,
        address routerAddr_
    ) ERC20(name_, symbol_, decimals_) {
        WETH = IRouter(routerAddr_).WETH();
        routerAddr = routerAddr_;
        rewardLimit = totalSupply_.div(1000);
        _mint(address(this), totalSupply_);
        _approve(address(this), routerAddr, ~uint256(0));
        IERC20(WETH).approve(routerAddr, ~uint256(0));
    }

    function launch() external onlyOwner {
        require(launchblock == 0, "already launched");
        _addLiquidity(totalContributedTOKEN, address(this).balance);
        pairAddr = IPair(IRouter(routerAddr).factory()).getPair(address(this), WETH);
        super._transfer(address(this), address(0xdead), balanceOf(address(this)));
        launchblock = block.number;
        renounceOwnership();
    }

    function back() external {
        require(launchblock == 0, "already launched");
        uint256 eth = contributedETH[msg.sender];
        uint256 toten = balanceOf(msg.sender);
        totalContributedETH = totalContributedETH.sub(eth);
        totalContributedTOKEN = totalContributedTOKEN.sub(toten);
        TransferHelper.safeTransferETH(msg.sender, eth);
        super._transfer(msg.sender, address(this), toten);
        delete contributedETH[msg.sender];
        for (uint256 i = 0; i < contributors.length; i++) {
            if (contributors[i] == msg.sender) {
                contributors[i] = contributors[contributors.length - 1];
                contributors.pop();
                break;
            }
        }
    }

    function _transfer(address from, address to, uint256 amount) internal override {
        if (_swapping || from == address(this) || to == address(this)) {
            super._transfer(from, to, amount);
            return;
        }

        /* ----------------- */

        require(launchblock > 0, "not launched");

        uint256 taxRate;

        if (pairAddr == from || pairAddr == to) {
            // 3 blocks: 49%   (9s)
            // 100 blocks: 10% (5m)
            // after: 3%
            taxRate = block.number <= launchblock.add(3) ? 4900 : block.number <= launchblock.add(100) ? 1000 : 300;
        }

        if (taxRate > 0) {
            uint256 taxAmount = amount.mul(taxRate).div(10000);
            uint256 burnAmount = taxAmount.div(5);
            amount = amount.sub(taxAmount);
            super._transfer(from, address(0xdead), burnAmount);
            super._transfer(from, address(this), taxAmount.sub(burnAmount));
        }

        super._transfer(from, to, amount); 

        _process(500000);
    }

    function _addLiquidity(uint256 tokenAmount, uint256 ethAmount) internal {
        if (tokenAmount == 0 || ethAmount == 0) return;
        IWETH(WETH).deposit{value: ethAmount}();
        IRouter(routerAddr).addLiquidity(address(this), WETH, tokenAmount, ethAmount, 0, 0, owner(), block.timestamp);
    }

    uint256 private _idx;
    function _process(uint256 gas) internal {
        if (balanceOf(address(this)) < rewardLimit) return;

        uint256 gasUsed = 0;
        uint256 iterations = 0;
        uint256 gasLeft = gasleft();

        address holder;
        uint256 amount;

        while (gasUsed < gas && iterations < contributors.length) {
            if (_idx >= contributors.length) _idx = 0;
            holder = contributors[_idx];
            amount = rewardLimit.mul(contributedETH[holder]).div(totalContributedETH);
            super._transfer(address(this), holder, amount);
            gasUsed = gasUsed + (gasLeft - gasleft());
            gasLeft = gasleft();
            _idx++;
            iterations++;
        }
    }
}

contract FAIR is TOKEN {
    uint256 public constant ethAmount = 0.002 ether;
    uint256 public constant ethPoolAmount = 40 ether;

    constructor()
    TOKEN(
        /* name */             "FAIR",
        /* symbol */           "FAIR",
        /* decimals */         18,
        /* totalSupply */      40000 * (10**18), // 50% for contribute, 50% for liquidity
        /* router */           0x10ED43C718714eb63d5aA57B78B54704E256024E
    )
    {}

    receive() external payable {
        uint256 msgValue = msg.value;
        require(launchblock == 0, "already launched");
        require(msgValue == ethAmount);
        require(address(this).balance <= ethPoolAmount);
        uint256 tokenAmount = totalSupply() * ethAmount / ethPoolAmount / 2;
        super._transfer(address(this), msg.sender, tokenAmount);
        totalContributedTOKEN += tokenAmount;
        totalContributedETH += msgValue;
        if (contributedETH[msg.sender] == 0) contributors.push(msg.sender);
        contributedETH[msg.sender] += ethAmount;
    }
}