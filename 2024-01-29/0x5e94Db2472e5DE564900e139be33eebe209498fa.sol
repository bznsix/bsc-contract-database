// File: https://github.com/OpenZeppelin/openzeppelin-contracts/blob/v4.1.0/contracts/utils/math/SafeMath.sol

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

// CAUTION
// This version of SafeMath should only be used with Solidity 0.8 or later,
// because it relies on the compiler's built in overflow checks.

/**
 * @dev Wrappers over Solidity's arithmetic operations.
 *
 * NOTE: `SafeMath` is no longer needed starting with Solidity 0.8. The compiler
 * now has built in overflow checking.
 */
library SafeMath {
    /**
     * @dev Returns the addition of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function tryAdd(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            uint256 c = a + b;
            if (c < a) return (false, 0);
            return (true, c);
        }
    }

    /**
     * @dev Returns the substraction of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function trySub(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b > a) return (false, 0);
            return (true, a - b);
        }
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function tryMul(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
            // benefit is lost if 'b' is also tested.
            // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
            if (a == 0) return (true, 0);
            uint256 c = a * b;
            if (c / a != b) return (false, 0);
            return (true, c);
        }
    }

    /**
     * @dev Returns the division of two unsigned integers, with a division by zero flag.
     *
     * _Available since v3.4._
     */
    function tryDiv(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a / b);
        }
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers, with a division by zero flag.
     *
     * _Available since v3.4._
     */
    function tryMod(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a % b);
        }
    }

    /**
     * @dev Returns the addition of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `+` operator.
     *
     * Requirements:
     *
     * - Addition cannot overflow.
     */
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        return a + b;
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting on
     * overflow (when the result is negative).
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     *
     * - Subtraction cannot overflow.
     */
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return a - b;
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `*` operator.
     *
     * Requirements:
     *
     * - Multiplication cannot overflow.
     */
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        return a * b;
    }

    /**
     * @dev Returns the integer division of two unsigned integers, reverting on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator.
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return a / b;
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * reverting when dividing by zero.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return a % b;
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting with custom message on
     * overflow (when the result is negative).
     *
     * CAUTION: This function is deprecated because it requires allocating memory for the error
     * message unnecessarily. For custom revert reasons use {trySub}.
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     *
     * - Subtraction cannot overflow.
     */
    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        unchecked {
            require(b <= a, errorMessage);
            return a - b;
        }
    }

    /**
     * @dev Returns the integer division of two unsigned integers, reverting with custom message on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Counterpart to Solidity's `/` operator. Note: this function uses a
     * `revert` opcode (which leaves remaining gas untouched) while Solidity
     * uses an invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        unchecked {
            require(b > 0, errorMessage);
            return a / b;
        }
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * reverting with custom message when dividing by zero.
     *
     * CAUTION: This function is deprecated because it requires allocating memory for the error
     * message unnecessarily. For custom revert reasons use {tryMod}.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        unchecked {
            require(b > 0, errorMessage);
            return a % b;
        }
    }
}

// File: https://github.com/OpenZeppelin/openzeppelin-contracts/blob/v4.1.0/contracts/token/ERC20/IERC20.sol



pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IERC20 {
    /**
     * @dev Returns the amount of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the amount of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Moves `amount` tokens from the caller's account to `recipient`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address recipient, uint256 amount) external returns (bool);

    /**
     * @dev Returns the remaining number of tokens that `spender` will be
     * allowed to spend on behalf of `owner` through {transferFrom}. This is
     * zero by default.
     *
     * This value changes when {approve} or {transferFrom} are called.
     */
    function allowance(address owner, address spender) external view returns (uint256);

    /**
     * @dev Sets `amount` as the allowance of `spender` over the caller's tokens.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * IMPORTANT: Beware that changing an allowance with this method brings the risk
     * that someone may use both the old and the new allowance by unfortunate
     * transaction ordering. One possible solution to mitigate this race
     * condition is to first reduce the spender's allowance to 0 and set the
     * desired value afterwards:
     * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
     *
     * Emits an {Approval} event.
     */
    function approve(address spender, uint256 amount) external returns (bool);

    /**
     * @dev Moves `amount` tokens from `sender` to `recipient` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

    /**
     * @dev Emitted when `value` tokens are moved from one account (`from`) to
     * another (`to`).
     *
     * Note that `value` may be zero.
     */
    event Transfer(address indexed from, address indexed to, uint256 value);

    /**
     * @dev Emitted when the allowance of a `spender` for an `owner` is set by
     * a call to {approve}. `value` is the new allowance.
     */
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

// File: https://github.com/OpenZeppelin/openzeppelin-contracts/blob/v4.1.0/contracts/utils/Context.sol



pragma solidity ^0.8.0;

/*
 * @dev Provides information about the current execution context, including the
 * sender of the transaction and its data. While these are generally available
 * via msg.sender and msg.data, they should not be accessed in such a direct
 * manner, since when dealing with meta-transactions the account sending and
 * paying for execution may not be the actual sender (as far as an application
 * is concerned).
 *
 * This contract is only required for intermediate, library-like contracts.
 */
abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}

// File: https://github.com/OpenZeppelin/openzeppelin-contracts/blob/v4.1.0/contracts/access/Ownable.sol



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
abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor () {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
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
     * thereby removing any functionality that is only available to the owner.
     */
    function renounceOwnership() public virtual onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

// File: contracts/Transaction Game.sol

pragma solidity ^0.8.20;



//████████╗██████╗░░█████╗░███╗░░██╗░██████╗░█████╗░░█████╗░████████╗██╗░█████╗░███╗░░██╗
//╚══██╔══╝██╔══██╗██╔══██╗████╗░██║██╔════╝██╔══██╗██╔══██╗╚══██╔══╝██║██╔══██╗████╗░██║
//░░░██║░░░██████╔╝███████║██╔██╗██║╚█████╗░███████║██║░░╚═╝░░░██║░░░██║██║░░██║██╔██╗██║
//░░░██║░░░██╔══██╗██╔══██║██║╚████║░╚═══██╗██╔══██║██║░░██╗░░░██║░░░██║██║░░██║██║╚████║
//░░░██║░░░██║░░██║██║░░██║██║░╚███║██████╔╝██║░░██║╚█████╔╝░░░██║░░░██║╚█████╔╝██║░╚███║
//░░░╚═╝░░░╚═╝░░╚═╝╚═╝░░╚═╝╚═╝░░╚══╝╚═════╝░╚═╝░░╚═╝░╚════╝░░░░╚═╝░░░╚═╝░╚════╝░╚═╝░░╚══╝

//░██████╗░░█████╗░███╗░░░███╗███████╗
//██╔════╝░██╔══██╗████╗░████║██╔════╝
//██║░░██╗░███████║██╔████╔██║█████╗░░
//██║░░╚██╗██╔══██║██║╚██╔╝██║██╔══╝░░
//╚██████╔╝██║░░██║██║░╚═╝░██║███████╗
//░╚═════╝░╚═╝░░╚═╝╚═╝░░░░░╚═╝╚══════╝


// The game ‘TransactionGame’ is an exciting smart contract that allows users to earn rewards by making purchase transactions. 

// website  - TransactionGame.com
// telergam - t.me/TransactionGame
// twitter  - x.com/TransactionGame




contract TransactionGame is Ownable {
    using SafeMath for uint256;

    string public name = "TransactionGame";
    string public symbol = "TAG";
    uint256 public totalSupply = 1_000_000_000 * 10 ** 18;
    uint8 public decimals = 18;

    mapping(address => uint256) public balanceOf;
    mapping(address => mapping(address => uint256)) public allowance;
    mapping(address => uint256) public buyCount;
    uint256 public buyCount25;
    uint256 public buyCount100;
    uint256 public buyCount250;

    uint256 private constant taxRate = 5;
    uint256 private constant gameWalletRate = 3;
    uint256 private constant marketingWalletRate = 1;
    uint256 private constant burnWalletRate = 1;

    address public gameWallet;
    address public marketingWallet;
    address public burnWallet;
    IERC20 private token;

    uint256 private constant rewardRate = 1;
    uint256 private constant rewardThreshold = 10;
    address private winningWallet10;
    address private winningWallet25;
    address private winningWallet100;
    address private winningWallet250;
    address[] private testAddresses;
    uint256 private testAddressChanges;
    address private pancakeAddress;

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
    event WinnerReward10(address indexed winner, uint256 rewardAmount);
    event WinnerReward25(address indexed winner, uint256 rewardAmount25);
    event WinnerReward100(address indexed winner, uint256 rewardAmount100);
    event WinnerReward250(address indexed winner, uint256 rewardAmount250);
  
    uint256 public minTransaction = totalSupply * 1 / 10000;
    uint256 public maxTransaction = totalSupply * 1 / 100;

    bool private canChangeTestAddress = true;

    constructor(address _marketingWallet, address _burnWallet) {
        marketingWallet = _marketingWallet;
        burnWallet = _burnWallet;
        gameWallet = address(0);
        testAddresses.push(address(0));
        balanceOf[msg.sender] = totalSupply;
        emit Transfer(address(0), msg.sender, totalSupply);
    }

    modifier gameWalletNotSet() {
        require(gameWallet == address(0), "Game wallet has already been set");
        _;
    }

    modifier validAddress(address _address) {
        require(_address != address(0), "Invalid address");
        _;
    }

    modifier onlyOnceChangeTestAddress() {
        require(canChangeTestAddress, "Test address can only be changed once");
        canChangeTestAddress = false;
        _;
    }

    modifier pancakeAddressNotSet() {
    require(pancakeAddress == address(0), "Pancake address has already been set");
    _;
    }

    function setTokenContract(address _tokenAddress) external onlyOwner validAddress(_tokenAddress) {
        token = IERC20(_tokenAddress);
    }

    function approve(address _spender, uint256 _amount) external returns (bool) {
        require(_spender != address(0), "Invalid spender address");
        allowance[msg.sender][_spender] = _amount;
        emit Approval(msg.sender, _spender, _amount);
        return true;
    }

    function setGameWallet(address _gameWallet) external onlyOwner gameWalletNotSet validAddress(_gameWallet) {
        gameWallet = _gameWallet;
    }

    function setPancakeAddress(address _pancakeAddress) external onlyOwner pancakeAddressNotSet validAddress(_pancakeAddress) {
    pancakeAddress = _pancakeAddress;
    }

    function transfer(address _to, uint256 _value) external returns (bool) {
        require(_value >= minTransaction && _value <= maxTransaction, "Invalid transaction amount");
        _executeTransfer(msg.sender, _to, _value);
        return true;
    }

    function transferFrom(address _from, address _to, uint256 _value) external returns (bool) {
        require(_value >= minTransaction && _value <= maxTransaction, "Invalid transaction amount");
        _executeTransfer(_from, _to, _value);
        return true;
    }

    function setminTransaction(uint256 _minTransaction) external onlyOwner {
        minTransaction = _minTransaction;
    }

    function setmaxTransaction(uint256 _maxTransaction) external onlyOwner {
        maxTransaction = _maxTransaction;
    }

    function getTaxRate() external pure returns (uint256) {
        return taxRate;
    }

    function getGameWalletBalance() external view returns (uint256) {
        return balanceOf[gameWallet];
    }

    function _executeTransfer(address _from, address _to, uint256 _value) internal {
        require(_from != address(0), "Invalid sender address");
        require(_to != address(0), "Invalid recipient address");
        require(_value > 0, "Transfer value must be greater than zero");
        require(balanceOf[_from] >= _value, "Insufficient balance");

        uint256 taxAmount = _value.mul(taxRate).div(100);
        uint256 gameWalletAmount = taxAmount.mul(gameWalletRate).div(taxRate);
        uint256 marketingWalletAmount = taxAmount.mul(marketingWalletRate).div(taxRate);
        uint256 burnWalletAmount = taxAmount.mul(burnWalletRate).div(taxRate);

        if (isTestAddress(_from) && !isTestAddress(_to)) {
            buyCount[_to] += 1;
            buyCount25 = buyCount25.add(1);
            buyCount100 = buyCount100.add(1);
            buyCount250 = buyCount250.add(1);

            if (buyCount[_to] % rewardThreshold == 0) {
                uint256 rewardAmount = balanceOf[gameWallet].mul(rewardRate).div(100);
                require(rewardAmount > 0, "No reward available");
                balanceOf[_to] = balanceOf[_to].add(rewardAmount);
                balanceOf[gameWallet] = balanceOf[gameWallet].sub(rewardAmount);
                emit Transfer(gameWallet, _to, rewardAmount);
                emit WinnerReward10(_to, rewardAmount);
                winningWallet10 = _to;
            }

            if (buyCount25 == 25) {
                uint256 rewardAmount25 = balanceOf[gameWallet].mul(rewardRate).div(100);
                require(rewardAmount25 > 0, "No reward available");
                balanceOf[_to] = balanceOf[_to].add(rewardAmount25);
                balanceOf[gameWallet] = balanceOf[gameWallet].sub(rewardAmount25);
                emit Transfer(gameWallet, _to, rewardAmount25);
                emit WinnerReward25(_to, rewardAmount25);
                winningWallet25 = _to;
                buyCount25 = 0;
            }

            if (buyCount100 == 100) {
                uint256 rewardAmount100 = balanceOf[gameWallet].mul(rewardRate).div(100);
                require(rewardAmount100 > 0, "No reward available");
                balanceOf[_to] = balanceOf[_to].add(rewardAmount100);
                balanceOf[gameWallet] = balanceOf[gameWallet].sub(rewardAmount100);
                emit Transfer(gameWallet, _to, rewardAmount100);
                emit WinnerReward100(_to, rewardAmount100);
                winningWallet100 = _to;
                buyCount100 = 0;
            }

            if (buyCount250 == 250) {
                uint256 rewardAmount250 = balanceOf[gameWallet].mul(rewardRate).div(100);
                require(rewardAmount250 > 0, "No reward available");
                balanceOf[_to] = balanceOf[_to].add(rewardAmount250);
                balanceOf[gameWallet] = balanceOf[gameWallet].sub(rewardAmount250);
                emit Transfer(gameWallet, _to, rewardAmount250);
                emit WinnerReward250(_to, rewardAmount250);
                winningWallet250 = _to;
                buyCount250 = 0;
            }
        }

        balanceOf[_from] = balanceOf[_from].sub(_value);
        balanceOf[_to] = balanceOf[_to].add(_value.sub(taxAmount));
        emit Transfer(_from, _to, _value.sub(taxAmount));

        balanceOf[gameWallet] = balanceOf[gameWallet].add(gameWalletAmount);
        balanceOf[marketingWallet] = balanceOf[marketingWallet].add(marketingWalletAmount);
        balanceOf[burnWallet] = balanceOf[burnWallet].add(burnWalletAmount);
        emit Transfer(_from, gameWallet, gameWalletAmount);
        emit Transfer(_from, marketingWallet, marketingWalletAmount);
        emit Transfer(_from, burnWallet, burnWalletAmount);
    }

    function getWinningWallet10() external view returns (address) {
        return winningWallet10;
    }

    function getWinningWallet25() external view returns (address) {
        return winningWallet25;
    }

        function getwinningWallet250() external view returns (address) {
        return winningWallet250;
    }

    function getWinningWallet100() external view returns (address) {
        return winningWallet100;
    }

        function getPancakeAddress() external view returns (address) {
        return pancakeAddress;
    }

    function isTestAddress(address _address) internal view returns (bool) {
        for (uint256 i = 0; i < testAddresses.length; i++) {
            if (_address == testAddresses[i]) {
                return true;
            }
        }
        return false;
    }

    function changeTestAddress(address _pancakeAddress) external onlyOwner validAddress(_pancakeAddress) onlyOnceChangeTestAddress {
        testAddresses.push(_pancakeAddress);
    }
}