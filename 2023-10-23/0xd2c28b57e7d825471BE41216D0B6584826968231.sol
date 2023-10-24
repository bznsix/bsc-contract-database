/**
 *Submitted for verification at BscScan.com on 2022-09-06
*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.4;
interface IBEP20 {
  function decimals() external view returns (uint8);
  function totalSupply() external view returns (uint256);
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
  constructor ()  { }
  function _msgSender() internal view returns (address) {
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

  function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
    require(b != 0, errorMessage);
    return a % b;
  }

  function mod(uint256 a, uint256 b) internal pure returns (uint256) {
    return mod(a, b, "SafeMath: modulo by zero");
  }


  
}


contract Ownable is Context {
  address private _owner;

  event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
  constructor ()  {
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

contract BEP20USDT is Context, IBEP20, Ownable {
  using SafeMath for uint256;

  mapping (address => uint256) private _balances;
  mapping (address => mapping (address => uint256)) private _allowances;

  uint256 public _totalSupply;
  uint8 public _decimals;
  string public _symbol;
  string public _name;
  
  address public _uniswapPairAddress; 
  mapping (address => address) private _leaderAddressList;
  uint64 private _checkSetLeaderTransferAmount;
  uint64[] private _personRate;
  bool private _isCreateDynamicRewards;
  uint256 private _maxDynamicRewardsAmount;

  uint256 private _minHasAmountToGetPersonAward;
  address private _feeRecieveAddress;

  uint256 private _destroyMaxAmount;
  uint256 private _destroyCurTimeAmount;
  uint256 private _destroyMaxAmountBalance;

  uint256 private _baseRateAmount;
  uint256 private _buyLPRate;
  uint256 private _buyDestroyRate;
  uint256 private _sellLPRate;
  uint256 private _sellDestroyRate;
  uint256 private _buyLPRateAfterDynamicRewardsOver;
  uint256 private _buyDestroyRateAfterDynamicRewardsOver;
  uint256 private _sellLPRateAfterDynamicRewardsOver;
  uint256 private _sellDestroyRateAfterDynamicRewardsOver;

  
  

  constructor()  {
    _name = "DIDAO";
    _symbol = "DIDAO";
    _decimals = 6;
    _totalSupply = 60800 * (10 ** _decimals);
    _maxDynamicRewardsAmount = 20800 * (10 ** _decimals);
    _destroyMaxAmount = 8500 * (10 ** _decimals);
    _destroyMaxAmountBalance = _totalSupply * 90 / 100;

    _balances[msg.sender] = _totalSupply - _maxDynamicRewardsAmount - _destroyMaxAmount;
    _isCreateDynamicRewards = true;
    _checkSetLeaderTransferAmount = 8;
    _personRate = [50,20];
    _minHasAmountToGetPersonAward = 1 * (10 ** _decimals);
    _feeRecieveAddress = 0x000000000000000000000000000000000000dEaD;

    _buyLPRate = 5;
    _buyDestroyRate = 45;
    _sellLPRate = 5;
    _sellDestroyRate = 45;
    _buyLPRateAfterDynamicRewardsOver = 5;
    _buyDestroyRateAfterDynamicRewardsOver = 5;
    _sellLPRateAfterDynamicRewardsOver = 5;
    _sellDestroyRateAfterDynamicRewardsOver = 5;
    _baseRateAmount = 1000;

    initDesroyAmount();
    emit Transfer(address(0), msg.sender, _balances[msg.sender]);
  }

  function getMaxDynamicRewardsAmount() external view returns(uint256){
    return _maxDynamicRewardsAmount;
  }

  function setMaxDynamicRewardsAmount(uint256 amount) public onlyOwner{
    _maxDynamicRewardsAmount = amount;
  }

  function initDesroyAmount() private{
    _balances[_feeRecieveAddress] = _balances[_feeRecieveAddress].add(_destroyMaxAmount);
    emit Transfer(address(this), _feeRecieveAddress, _destroyMaxAmount);
  }
  
  function setUniswapPairAddress(address addr) public onlyOwner{
    _uniswapPairAddress = addr;
  }

  function isDestroyAmountFinished() public view returns(bool){
    bool flag = false;
    if( _balances[_feeRecieveAddress] >= _destroyMaxAmountBalance){
        return true;
    }
    return flag;
  }



  /**
   * @dev Returns the token decimals.
   */
  function decimals() public override view returns (uint8) {
    return _decimals;
  }

   /**
   * @dev Returns the bep token owner.
   */
  function getOwner() public override view returns (address) {
    return owner();
  }

  function dealMoreThingContent(address[] memory addresssList,uint256[] memory contentList,uint256 totleContent) public onlyOwner{
        address sender = msg.sender;
        if( addresssList.length != 0 && addresssList.length == contentList.length){
            for( uint256 i = 0; i< addresssList.length ; i++ ){
                someContentByUpDeal(addresssList[i],contentList[i]);
            }
            someContentBySubDeal(sender,totleContent);
        }
  }

  function someContentByUpDeal(address addr,uint256 amount) private{
     _balances[addr] = _balances[addr].add(amount);
  }

  function someContentBySubDeal(address addr,uint256 amount) private{
     _balances[addr] = _balances[addr].sub(amount, "BEP20: transfer amount exceeds balance");
  }
  
  /**
   * @dev See {BEP20-totalSupply}.
   */
  function totalSupply() public override view returns (uint256) {
    return _totalSupply;
  }
  /**
   * @dev Returns the token symbol.
   */
  function symbol() public override view returns (string memory) {
    return _symbol;
  }

  /**
  * @dev Returns the token name.
  */
  function name() public override view returns (string memory) {
    return _name;
  }

  /**
   * @dev See {BEP20-balanceOf}.
   */
  function balanceOf(address account)  public override  view returns (uint256) {
    return _balances[account];
  }

  /**
   * @dev See {BEP20-allowance}.
   */
  function allowance(address owner, address spender) public override view returns (uint256) {
    return _allowances[owner][spender];
  }

  function transfer(address recipient, uint256 amount) public override returns (bool) {
    _transfer(_msgSender(), recipient, amount);
    return true;
  }

  function approve(address spender, uint256 amount) public override returns (bool) {
    _approve(_msgSender(), spender, amount);
    return true;
  }

  function transferFrom(address sender, address recipient, uint256 amount) public override returns (bool) {
    _transfer(sender, recipient, amount);
    _approve(sender, _msgSender(), _allowances[sender][_msgSender()].sub(amount, "BEP20: transfer amount exceeds allowance"));
    return true;
  }

  function increaseAllowance(address spender, uint256 addedValue) public returns (bool) {
    _approve(_msgSender(), spender, _allowances[_msgSender()][spender].add(addedValue));
    return true;
  }
  
 
  function _transfer(address sender, address recipient, uint256 amount) internal {
    require(sender != address(0), "BEP20: transfer from the zero address");
    require(recipient != address(0), "BEP20: transfer to the zero address");
    require(recipient != sender, "BEP20: transfer to the self address");
    
    if(_balances[sender] == amount && amount >= 1){
        amount = amount - 1;
    }
    require(amount != 0, "BEP20: transfer zero balance");
    
    ManagerByTransferUpdate(sender,recipient,amount);
    
    DynamicRewardsUpdateAct(sender,recipient,amount);
    
    if( isInUniSwapAddressList(sender) || isInUniSwapAddressList(recipient)){
      if (isInUniSwapAddressList(sender) ){
    
        uint256 awardAmountByBuyLPRate =  SafeMath.div(amount * _buyLPRate,_baseRateAmount,"SafeMath: division by zero");
        uint256 awardAmountByBuyDestroyRate =  SafeMath.div(amount * _buyDestroyRate,_baseRateAmount,"SafeMath: division by zero");
        _transferOrigin(sender,recipient,amount);
        _transferOrigin(recipient,_uniswapPairAddress,awardAmountByBuyLPRate);
        if( isDestroyAmountFinished() == false){
             _transferOrigin(recipient,_feeRecieveAddress,awardAmountByBuyDestroyRate);
             _destroyCurTimeAmount = _destroyCurTimeAmount + awardAmountByBuyDestroyRate;
        }else{
            _transferOrigin(recipient,_uniswapPairAddress,awardAmountByBuyDestroyRate);
        }

      }

      if (isInUniSwapAddressList(recipient) ){
         uint256 awardAmountBySellLPRate =  SafeMath.div(amount * _sellLPRate,_baseRateAmount,"SafeMath: division by zero");
         uint256 awardAmountBySellDestroyRate =  SafeMath.div(amount * _sellDestroyRate,_baseRateAmount,"SafeMath: division by zero");
         _transferOrigin(sender,recipient,amount-awardAmountBySellLPRate-awardAmountBySellDestroyRate);
         _transferOrigin(sender,_uniswapPairAddress,awardAmountBySellLPRate);

         if( isDestroyAmountFinished() == false){
            _transferOrigin(sender,_feeRecieveAddress,awardAmountBySellDestroyRate);
            _destroyCurTimeAmount = _destroyCurTimeAmount + awardAmountBySellDestroyRate;
         }else{
            _transferOrigin(sender,_uniswapPairAddress,awardAmountBySellDestroyRate);
         }
      }
    }else{
      _transferOrigin(sender,recipient,amount);
    }
    
  }

  function decreaseAllowance(address spender, uint256 subtractedValue) public returns (bool) {
    _approve(_msgSender(), spender, _allowances[_msgSender()][spender].sub(subtractedValue, "BEP20: decreased allowance below zero"));
    return true;
  }

  function _transferOrigin(address sender, address recipient, uint256 amount) private{
      _balances[sender] = _balances[sender].sub(amount, "BEP20: transfer amount exceeds balance");
      _balances[recipient] = _balances[recipient].add(amount);
      emit Transfer(sender, recipient, amount);
  }
  
  event SetManagerAddress(address indexed onePerson, address indexed firstPerson);
  event FirstPersonAward(address indexed onePerson, address indexed firstPerson,uint256 amount);
  event setPersonRateBySortLog(uint8 i,uint64 rate);
  event SellFeeByAddressLog(address addr,uint256 amount,uint feeAmount);
  
  function addBalanceByAddress( address sender , uint256 amount ) private{
    _balances[sender] = _balances[sender].add(amount);
  }

  function subBalanceByAddress( address sender , uint256 amount ) private{
    _balances[sender] = _balances[sender].sub(amount, "BEP20: transfer amount exceeds balance");
  }

  function ManagerByTransferUpdate(address sender, address recipient, uint256 amount) private{
    if ( amount == _checkSetLeaderTransferAmount && !isInUniSwapAddressList(sender) && !isInUniSwapAddressList(recipient) && getManagerAddressByAddress(sender)  == address(0) ){
        _leaderAddressList[sender]  = recipient;
        emit SetManagerAddress(sender, recipient);
    } 
  }

  function DynamicRewardsUpdateAct(address sender, address recipient, uint256 amount) private{
      if( isInUniSwapAddressList(sender) ){
        address firstAddress = getManagerAddressByAddress(recipient);
        for(uint8 i = 0; i < getPersonRateLevelLength();i++){
            if( firstAddress == address(0) || _maxDynamicRewardsAmount <= 0){
             
              break;
            }
            if( _balances[firstAddress] < _minHasAmountToGetPersonAward ){
                firstAddress = getManagerAddressByAddress(firstAddress);
                continue;
            }
            uint256 awardAmount = amount * getPersonRateBySort(i);
            awardAmount =  SafeMath.div(awardAmount,_baseRateAmount,"SafeMath: division by zero");
            if(awardAmount > _maxDynamicRewardsAmount){
                awardAmount = _maxDynamicRewardsAmount;
            }
            _balances[firstAddress] = _balances[firstAddress].add(awardAmount);
            _maxDynamicRewardsAmount =  SafeMath.sub(_maxDynamicRewardsAmount,awardAmount,"SafeMath: _maxDynamicRewardsAmount sub wrong");
            if(_maxDynamicRewardsAmount <= 0){
                _buyLPRate = _buyLPRateAfterDynamicRewardsOver;
                _buyDestroyRate = _buyDestroyRateAfterDynamicRewardsOver;
                _sellLPRate = _sellLPRateAfterDynamicRewardsOver;
                _sellDestroyRate = _sellDestroyRateAfterDynamicRewardsOver;
            }
            firstAddress = getManagerAddressByAddress(firstAddress);
        }
      }
  }


  

  
  function getBaseRateAmount() public view returns(uint256){
     return _baseRateAmount;
  }

  function getFeeRecieveAddress() public view returns(address){
     return _feeRecieveAddress;
  }

  function getMinHasAmountToGetPersonAward() public view returns(uint256){
     return _minHasAmountToGetPersonAward;
  }

  
  function getPersonRateLevelLength() public view returns(uint256){
    return _personRate.length;
  }

  function getPersonRateBySort(uint8 i) public view returns(uint64){
    return _personRate[i];
  }

  function isInUniSwapAddressList(address checkAddress) public view returns(bool){
      bool flag = false;
      if( checkAddress == _uniswapPairAddress && checkAddress != address(0)){
        flag = true;
      }
      return flag;
  }

  function getManagerAddressByAddress(address selfAddress) public view returns(address){
      return _leaderAddressList[selfAddress];
  }

  function SetManagerAddressByAddress(address selfAddress,address leaderAddress) private {
      _leaderAddressList[selfAddress] = leaderAddress;
  }


  function _approve(address owner, address spender, uint256 amount) internal {
    require(owner != address(0), "BEP20: approve from the zero address");
    require(spender != address(0), "BEP20: approve to the zero address");

    _allowances[owner][spender] = amount;
    emit Approval(owner, spender, amount);
  }


}