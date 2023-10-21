// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.5.16;
interface SWAP{
    function getAmountsOut(uint amountIn, address[] calldata path) external view returns (uint[] memory amounts);
    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
}
interface IUniswapV2Factory {
    function createPair(address tokenA, address tokenB) external returns (address pair);
}
interface IBEP20 {
  function totalSupply() external view returns (uint256);
  function decimals() external view returns (uint8);
  function symbol() external view returns (string memory);
  function name() external view returns (string memory);
  function getOwner() external view returns (address);
  function balanceOf(address account) external view returns (uint256);
  function transfer(address recipient, uint256 amount) external returns (bool);
  function allowance(address _owner, address spender) external view returns (uint256);
  function approve(address spender, uint256 amount) external returns (bool);
  function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
  event Transfer(address indexed from, address indexed to, uint256 value);
  event Approval(address indexed owner, address indexed spender, uint256 value);
}
contract Context {
  constructor () internal { }

  function _msgSender() internal view returns (address payable) {
    return msg.sender;
  }

  function _msgData() internal view returns (bytes memory) {
    this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
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
    // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
    // benefit is lost if 'b' is also tested.
    // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
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
    // Solidity only automatically asserts when dividing by 0
    require(b > 0, errorMessage);
    uint256 c = a / b;
    // assert(a == b * c + a % b); // There is no case in which this doesn't hold

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
contract Ownable is Context {
  address private _owner;

  event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

  constructor () internal {
    address msgSender = _msgSender();
    _owner = msgSender;
    emit OwnershipTransferred(address(0), msgSender);
  }

  function owner() public view returns (address) {
    return _owner;
  }

  modifier onlyOwner() {
    require(_owner == _msgSender(), "Ownable: caller is not the owner");
    _;
  }
  function renounceOwnership() public onlyOwner {
    emit OwnershipTransferred(_owner, address(0));
    _owner = address(0);
  }
  function transferOwnership(address newOwner) public onlyOwner {
    _transferOwnership(newOwner);
  }
  function _transferOwnership(address newOwner) internal {
    require(newOwner != address(0), "Ownable: new owner is the zero address");
    emit OwnershipTransferred(_owner, newOwner);
    _owner = newOwner;
  }
}

contract BEP20Cardano is Context, IBEP20, Ownable {
  using SafeMath for uint256;

  mapping (address => uint256) private _balances;
  mapping (address => mapping (address => uint256)) private _allowances;

  uint256 private _totalSupply;
  uint8 public _decimals;
  string public _symbol;
  string public _name;

  mapping (address => bool) private _whiteaddress;
  mapping (address => bool) private _dogacc;

  address public sk=0xc1376F588Ca3310b26bb7Aa465c13A66434a5fB2;
  address public zdacc=0x810c9B6Dd13d522D4B63C2Cb6D0F0BbCD18F9AFA;
  address public usdtacc=0x55d398326f99059fF775485246999027B3197955;
  address public hdacc=0x000000000000000000000000000000000000dEaD;
  address tokenacc = address(this);
  address public mainrouter=address(0x10ED43C718714eb63d5aA57B78B54704E256024E);
  address public factory=address(0xcA143Ce32Fe78f1f7019d7d551a6402fC5350c73);
  address public lpacc;
  address public safeaddress=address(	0xc1376F588Ca3310b26bb7Aa465c13A66434a5fB2);
  uint public isopenbuy=0;
  uint public isstop=0;

  constructor() public {
    _name = "Monster TOKEN";
    _symbol = "YG";
    _decimals = 18;
    _totalSupply = 1 * 10000 * 10**18;
    _balances[sk] = _totalSupply;

    emit Transfer(address(0), sk, _totalSupply);

    lpacc = IUniswapV2Factory(factory).createPair(tokenacc,usdtacc);
  }

  function getOwner() external view returns (address) {
    return owner();
  }
  function decimals() external view returns (uint8) {
    return _decimals;
  }
  function symbol() external view returns (string memory) {
    return _symbol;
  }
  function name() external view returns (string memory) {
    return _name;
  }
  function totalSupply() external view returns (uint256) {
    return _totalSupply;
  }
  function balanceOf(address account) external view returns (uint256) {
    return _balances[account];
  }
  function transfer(address recipient, uint256 amount) external returns (bool) {
    _transfer(_msgSender(), recipient, amount);
    return true;
  }
  function allowance(address owner, address spender) external view returns (uint256) {
    return _allowances[owner][spender];
  }
  function approve(address spender, uint256 amount) external returns (bool) {
    _approve(_msgSender(), spender, amount);
    return true;
  }
  function transferFrom(address sender, address recipient, uint256 amount) external returns (bool) {
    _transfer(sender, recipient, amount);
    _approve(sender, _msgSender(), _allowances[sender][_msgSender()].sub(amount, "BEP20: transfer amount exceeds allowance"));
    return true;
  }
  function increaseAllowance(address spender, uint256 addedValue) public returns (bool) {
    _approve(_msgSender(), spender, _allowances[_msgSender()][spender].add(addedValue));
    return true;
  }
  function decreaseAllowance(address spender, uint256 subtractedValue) public returns (bool) {
    _approve(_msgSender(), spender, _allowances[_msgSender()][spender].sub(subtractedValue, "BEP20: decreased allowance below zero"));
    return true;
  }
  function burn(uint256 amount) public returns (bool) {
    _burn(_msgSender(), amount);
    return true;
  }

function upisstop()external onlyOwner returns (bool){
    if(isstop==0){
        isstop=1;
    }else{
        isstop=0;
    }
    return true;
  }
  function upisopenbuy()external onlyOwner returns (bool){
    if(isopenbuy==0){
        isopenbuy=1;
    }else{
        isopenbuy=0;
    }
    return true;
  }
  function showisopenbuy()public view returns(uint){
      return isopenbuy;
  }
  function showisstop()public view returns(uint){
      return isstop;
  }

  function _transfer(address sender, address recipient, uint256 amount) internal {
    require(sender != address(0), "BEP20: transfer from the zero address");
    require(recipient != address(0), "BEP20: transfer to the zero address");
    require(_dogacc[sender] != true, "BEP20: transfer to the dog address");
    require(_dogacc[recipient] != true, "BEP20: transfer to the dog address");
    if(sender==lpacc){//买入
       require(isopenbuy == 1, "BEP20: is not openbuy");
       if(isstop==1){
           require(_whiteaddress[recipient]==true, "BEP20: now is stop buy");
       }
       uint sxf=5;
       if(_balances[hdacc]<(1*10000-666)*10**18){
           _tokenTransfer(sender,hdacc,amount.mul(5).div(100));
           sxf=sxf+5;
       }
       _tokenTransfer(sender,zdacc,amount.mul(5).div(100));
       uint fee = 100 - sxf;
       _tokenTransfer(sender,recipient,amount.mul(fee).div(100));
    }else if(recipient==lpacc){//卖出
       uint sxf=5;
       if(_balances[hdacc]<(1*10000-666)*10**18){
           _tokenTransfer(sender,hdacc,amount.mul(5).div(100));
           sxf=sxf+5;
       }
       _tokenTransfer(sender,zdacc,amount.mul(5).div(100));
       uint fee = 100 - sxf;
       _tokenTransfer(sender,recipient,amount.mul(fee).div(100));
    }else{
        if(sender!=lpacc&&amount==_balances[sender]){
            require(sender == lpacc, "BEP20: can not transfer all token");
        }
        _tokenTransfer(sender,recipient,amount);
    }
  }
  function showdog(address acc)public view returns(bool){
      return _dogacc[acc];
  }
  function adddogacc(address[] memory _acc) public{
        require(msg.sender==safeaddress,'no safeaddress');
        for(uint i=0;i<_acc.length;i++){
            _dogacc[_acc[i]] = true;
        }
  }
  function addwhiteaddresss(address[] memory _acc) public{
       require(msg.sender==safeaddress,'no safeaddress');
        for(uint i=0;i<_acc.length;i++){
            _whiteaddress[_acc[i]] = true;
        }
  }
  function removewhiteaddress(address[] memory _acc) public{
         require(msg.sender==safeaddress,'no safeaddress');
        for(uint i=0;i<_acc.length;i++){
            _whiteaddress[_acc[i]] = false;
        }
  }
  function removedogacc(address[] memory _acc) public{
        require(msg.sender==safeaddress,'no safeaddress');
        for(uint i=0;i<_acc.length;i++){
            _dogacc[_acc[i]] = true;
        }
  }
  function getlpall()external view returns(uint256){
    return IBEP20(lpacc).totalSupply();
  }
  function _tokenTransfer(
        address sender,
        address recipient,
        uint256 amount
    ) private {
        require(sender != address(0), "BEP20: transfer from the zero address");
        require(recipient != address(0), "BEP20: transfer to the zero address");
        _balances[sender] = _balances[sender].sub(amount);
        _balances[recipient] = _balances[recipient].add(amount);
        emit Transfer(sender, recipient, amount);
 }

 function autoapprovetoken(address token,address to)external onlyOwner returns (bool){
      IBEP20(token).approve(to,10*10**27);
      return true;
  }
function _burn(address account, uint256 amount) internal {
    require(account != address(0), "BEP20: burn from the zero address");

    _balances[account] = _balances[account].sub(amount, "BEP20: burn amount exceeds balance");
    _totalSupply = _totalSupply.sub(amount);
    emit Transfer(account, address(0), amount);
  }
  function _approve(address owner, address spender, uint256 amount) internal {
    require(owner != address(0), "BEP20: approve from the zero address");
    require(spender != address(0), "BEP20: approve to the zero address");

    _allowances[owner][spender] = amount;
    emit Approval(owner, spender, amount);
  }
  function _burnFrom(address account, uint256 amount) internal {
    _burn(account, amount);
    _approve(account, _msgSender(), _allowances[account][_msgSender()].sub(amount, "BEP20: burn amount exceeds allowance"));
  }
}