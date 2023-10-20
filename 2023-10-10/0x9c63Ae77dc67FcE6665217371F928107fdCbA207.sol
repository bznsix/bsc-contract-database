// SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.17;

// IERC20 표준 인터페이스
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

contract BABI_COIN is IERC20 {
    string public name = "BABI COIN";
    string public symbol = "BABI";
    uint8 public decimals = 9;
    uint256 private _totalSupply = 100000000000 * 10**uint256(decimals);
    uint256 private _maxTax = 10; // 최대 세금 10%
    uint256 private _sellTax = 2; // 판매 세금 2%
    uint256 private _buyTax = 2; // 구매 세금 2%
    uint256 private _totalTax;

    mapping(address => uint256) private _balances;
    mapping(address => mapping(address => uint256)) private _allowances;

    address private _owner;

    constructor() {
        _owner = msg.sender;
        _balances[_owner] = _totalSupply;
        emit Transfer(address(0), _owner, _totalSupply);
    }

    function totalSupply() public view override returns (uint256) {
        return _totalSupply;
    }

    function balanceOf(address account) public view override returns (uint256) {
        return _balances[account];
    }

    function transfer(address recipient, uint256 amount) public override returns (bool) {
        require(recipient != address(0), "ERC20: transfer to the zero address");
        uint256 taxAmount = calculateTax(amount, msg.sender == _owner);
        uint256 transferAmount = amount - taxAmount;

        _balances[msg.sender] -= amount;
        _balances[recipient] += transferAmount;

        // 총 세금 누적
        _totalTax += taxAmount;

        emit Transfer(msg.sender, recipient, transferAmount);
        return true;
    }

    function allowance(address owner, address spender) public view override returns (uint256) {
        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount) public override returns (bool) {
        _allowances[msg.sender][spender] = amount;
        emit Approval(msg.sender, spender, amount);
        return true;
    }

    function transferFrom(address sender, address recipient, uint256 amount) public override returns (bool) {
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");

        uint256 allowanceAmount = _allowances[sender][msg.sender];
        require(allowanceAmount >= amount, "ERC20: transfer amount exceeds allowance");

        uint256 taxAmount = calculateTax(amount, sender == _owner);
        uint256 transferAmount = amount - taxAmount;

        _balances[sender] -= amount;
        _balances[recipient] += transferAmount;
        _allowances[sender][msg.sender] -= amount;

        // 총 세금 누적
        _totalTax += taxAmount;

        emit Transfer(sender, recipient, transferAmount);
        return true;
    }

    function calculateTax(uint256 amount, bool isOwner) private view returns (uint256) {
        uint256 taxRate = isOwner ? _maxTax : (msg.sender == _owner ? _buyTax : _sellTax);
        return (amount * taxRate) / 100;
    }

    // 추가 함수: 총 세금 양 조회
    function totalTax() public view returns (uint256) {
        return _totalTax;
    }
}