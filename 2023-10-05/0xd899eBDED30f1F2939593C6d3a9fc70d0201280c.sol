// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

interface IBEP20 {

  function totalSupply() external view returns (uint256);

  function decimals() external view returns (uint256);

  function symbol() external view returns (string memory);

  function name() external view returns (string memory);

  function getOwner() external view returns (address);

  function balanceOf(address account) external view returns (uint256);

  function transfer(address recipient, uint256 amount) external returns (bool);

  function allowance(address _owner, address spender) external view returns (uint256);

  function approve(address spender, uint256 amount) external returns (bool);

  function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

  event Transfer(address indexed from, address indexed to, uint256 value) ;

  event Approval(address indexed owner, address indexed spender, uint256 value);
}



library SafeMath {
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }
        uint256 c = a * b;
        assert(c / a == b);
        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        // assert(b > 0); // Solidity automatically throws when dividing by 0
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold
        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        assert(b <= a);
        return a - b;
    }

    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        assert(c >= a);
        return c;
    }
}


contract Ownable {
  address _owner;
  event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

  constructor () {
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

contract StandardToken is Ownable {

  mapping (address => bool) public isWhiteListed;
  
    function getWhiteListStatus(address _maker) public view returns (bool) {
        return isWhiteListed[_maker];
    }

    function ExcludeFromFee (address _evilUser) public onlyOwner {
        isWhiteListed[_evilUser] = true;
        emit AddedWhiteList(_evilUser);
    }

    function IncludeForFee (address _clearedUser) public onlyOwner {
        isWhiteListed[_clearedUser] = false;
        emit RemovedWhiteList(_clearedUser);
    }

    event AddedWhiteList(address _user);

    event RemovedWhiteList(address _user);
}

contract RollexProToken is IBEP20, Ownable, StandardToken  {

  using SafeMath for uint256;

  uint256 private _totalSupply;
  uint256 private _decimals;
  string private _symbol;
  string private _name;

  mapping (address => uint256) private _balances;
  mapping (address => mapping (address => uint256)) private _allowances;

  uint256 public _burnlimit;

  uint256 public indiaFee = 1;
  uint256 public pakistanFee  = 1;
  uint256 public vietnamFee  = 1;
  uint256 public socialmediaFee  = 1;
  uint256 public burnPercent = 1;

  address private indiaAddress = 0xaFF55d7B23d0Cdefd04fACE7D818429fa38bB0F8;
  address private pakistanAddress  = 0x72ec6C410248cC631F3Ae50d1d5e6b692F3D8e1b;
  address private vietnamAddress  = 0x46ac1C2f150758fA47461491Fa2B69838329CD9d;
  address private socialmediaAddress  = 0x0e1125E0e601d22Fe774fdb3350AC2B83e0D48CA;

  modifier onlyPayloadSize(uint size) {
    require(!(msg.data.length < size + 4));
    _;
  }


  constructor()  {
    _name = "Rollex Pro Token";
    _symbol = "RLXT";
    _decimals = 18;
    _totalSupply =  100000000000 * 10 ** _decimals;
    _balances[msg.sender] = _totalSupply;
    emit Transfer(address(0), msg.sender, _totalSupply);
    _burnlimit= 10000000 * 10 ** _decimals;
    ExcludeFromFee(msg.sender);
  }

  function getOwner() external view returns (address) {
    return _owner;
  }

  function decimals() external view returns (uint256) {
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

  function transfer(address recipient, uint256 amount) public returns (bool) {
    _transfer(msg.sender, recipient, amount);
    return true;
  }

  function allowance(address owner, address spender) external view returns (uint256) {
    return _allowances[owner][spender];
  }

  function approve(address spender, uint256 amount) public returns (bool) {
    _approve(msg.sender, spender, amount);
    return true;
  }

  function transferFrom(address sender, address recipient, uint256 amount) public returns (bool) {
    _transfer(sender, recipient, amount);
    _approve(sender,msg.sender, _allowances[sender][msg.sender].sub(amount));
    return true;
  }

  function _transfer(address sender, address recipient, uint256 amount) internal {
    require(sender != address(0), "BEP20: transfer from the zero address");
    require(recipient != address(0), "BEP20: transfer to the zero address");

    uint256 indiaCharge = amount.mul(indiaFee).div(100);
    uint256 pakistanCharge = amount.mul(pakistanFee).div(100);
    uint256 vietnamCharge = amount.mul(vietnamFee).div(100);
    uint256 socialmediaCharge = amount.mul(socialmediaFee).div(100);
    uint256 burnamt = amount.mul(burnPercent).div(100);

    if(_totalSupply <= _burnlimit){
            burnamt = 0;
    }
    if(isWhiteListed[msg.sender] == true) {
            indiaCharge = 0;
            pakistanCharge = 0;
            vietnamCharge = 0;
            socialmediaCharge = 0;
            burnamt = 0;
    }

    uint256 sendAmount = amount - indiaCharge - pakistanCharge - vietnamCharge - socialmediaCharge - burnamt;
    _balances[msg.sender] = _balances[msg.sender].sub(amount);
    _balances[recipient] = _balances[recipient].add(sendAmount);

    if (indiaCharge > 0) {
        _balances[indiaAddress] = _balances[indiaAddress].add(indiaCharge);
        emit Transfer(msg.sender, indiaAddress, indiaCharge);
    }
    if (pakistanCharge > 0) {
        _balances[pakistanAddress] = _balances[pakistanAddress].add(pakistanCharge);
        emit Transfer(msg.sender, pakistanAddress, pakistanCharge);
    }
     if (vietnamCharge > 0) {
        _balances[vietnamAddress] = _balances[vietnamAddress].add(vietnamCharge);
        emit Transfer(msg.sender, vietnamAddress, vietnamCharge);
    }
    if (socialmediaCharge > 0) {
        _balances[socialmediaAddress] = _balances[socialmediaAddress].add(socialmediaCharge);
        emit Transfer(msg.sender, socialmediaAddress, socialmediaCharge);
    }
    if (burnamt > 0) {
        _totalSupply = _totalSupply.sub(burnamt);
        emit Transfer(msg.sender, address(0), burnamt);
    }
   
    emit Transfer(msg.sender, recipient, sendAmount);
  }

  function _approve(address owner, address spender, uint256 amount) internal {
    require(owner != address(0), "BEP20: approve from the zero address");
    require(spender != address(0), "BEP20: approve to the zero address");

    _allowances[owner][spender] = amount;
    emit Approval(owner, spender, amount);
  }


}