// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.9.0) (access/Ownable.sol)

pragma solidity ^0.8.0;

import "../utils/Context.sol";

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
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
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
        require(newOwner != address(0), "Ownable: new owner is the zero address");
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
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/Context.sol)

pragma solidity ^0.8.0;

/**
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
        return msg.data;
    }
}
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.9.0) (utils/math/SafeMath.sol)

pragma solidity ^0.8.0;

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
// SPDX-License-Identifier: MIT

pragma solidity ^0.8.9;

import "./BEP20/IBEP20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "./BEP20/SafeBEP20.sol";

contract AccountLimit is Ownable {
    using SafeBEP20 for IBEP20;

    mapping(address => bool) public activeAccounts;

    IBEP20 private _usdt;
    event ActivateAccount(address account);

    constructor(IBEP20 usdt_) {
        _usdt = usdt_;
        activeAccounts[msg.sender] = true;
    }

    modifier isActive() {
        require(activeAccounts[msg.sender], "Account is not active.");
        _;
    }

    function activateAccount() internal virtual returns (bool) {
        require (!activeAccounts[msg.sender], "This account already active.");
        _usdt.safeTransferFrom(msg.sender, owner(), 50 * 10 ** _usdt.decimals());
        activeAccounts[msg.sender] = true;
        emit ActivateAccount(msg.sender);
        return true;
    }
}// SPDX-License-Identifier: MIT
pragma solidity >0.4.0 <= 0.9.0;

import {HandleTransaction} from "./HandleTransaction.sol";
import {LiquidityPool} from "./LiquidityPool.sol";
import {AccountLimit} from "./AccountLimit.sol";
import {ReferalProgram} from  "./ReferalProgram.sol";
import "./BEP20/SafeBEP20.sol";

contract AXLT is IBEP20, HandleTransaction, LiquidityPool, AccountLimit, ReferalProgram{
  using SafeBEP20 for IBEP20;

  bool public isTransferable = false;
  mapping(address => uint) private initialExchangeRate;

  event Withdrawn(address recipient, uint amount);
  event BuyToken(address recipient, uint amount);

  IBEP20 private _usdt;
    
  uint256 public ownerFeeForToken = 5;

  using SafeMath for uint256;

  mapping (address => uint256) private _balances;

  mapping (address => mapping (address => uint256)) private _allowances;

  uint256 private _totalSupply;
  uint8 private _decimals;
  string private _symbol;
  string private _name;

  constructor(IBEP20 usdt_) ReferalProgram(usdt_, address(this)){
    _name = "AXLT Token";
    _symbol = "AXLT";
    _decimals = 18;
    _usdt = usdt_;
  }

  function buyToken(uint usdtAmount) external isActive() virtual {
        require (usdtAmount > 0, "Amount can not be less then zero.");
        require (depositLimitMap[usdtAmount], "This amount is not available.");
        require (balanceOf(msg.sender) == 0, "First you need to withdraw funds.");
        initialExchangeRate[msg.sender] = getExchangeRate();

        _usdt.safeTransferFrom(msg.sender, address(this), usdtAmount);
        _usdt.safeTransfer(owner(), (usdtAmount * ownerFeeForToken) / 100);

        transferToNonPayable(usdtAmount - (usdtAmount * ownerFeeForToken) / 100);
        _paymentsToPartnersFromTradeTokens(msg.sender, usdtAmount);
        uint tokenAmount = getTokenForUsdt(usdtAmount - (usdtAmount * 10) / 100);
        _mint(msg.sender, tokenAmount);
        
        handleTransaction();

        emit BuyToken(_msgSender(), tokenAmount);
    }

    function getTokenForUsdt(uint amount) public virtual view returns (uint256) {
        uint exchangeRate = getExchangeRate();
        return uint256(amount * 10 ** 18 / exchangeRate);
    }

    function withdrawTokens() external isActive virtual {
        uint amount = balanceOf(_msgSender());
        require (amount > 0, "Amount can not be less then zero.");
        
        uint differenceOfProfit = profitCalculation(msg.sender);
        uint tokenToTransfer;
        if (differenceOfProfit < 5000000000) {
            tokenToTransfer =
                (initialExchangeRate[msg.sender] * amount) / (10**18);
        } else {
            uint exchangeRateToTransfer = initialExchangeRate[msg.sender] + (initialExchangeRate[msg.sender] / 100) *
                50;
            tokenToTransfer =
                (exchangeRateToTransfer * amount) / (10**18);
        }

        _usdt.safeTransfer(owner(), (tokenToTransfer * 5) / 100);
        _paymentsToPartnersFromTradeTokens(msg.sender, tokenToTransfer);
        uint newTokenToTransfer = SafeMath.mul(tokenToTransfer, 90);
        newTokenToTransfer = SafeMath.div(newTokenToTransfer, 100);
        _usdt.safeTransfer(msg.sender, newTokenToTransfer);
        _burn(msg.sender, amount);

        nonPayableBalance -= newTokenToTransfer;

        initialExchangeRate[msg.sender] = 0;
        handleTransaction(); 

        emit Withdrawn(_msgSender(), amount);
    }

    function profitCalculation(address _owner) public view virtual returns (uint) {
        require(initialExchangeRate[_owner] > 0, "Your initial exchange rate is zero");
        uint exchangeRate = getExchangeRate();
        return ((exchangeRate - initialExchangeRate[_owner]) * 100000000) / initialExchangeRate[_owner] * 100;
    }

    function transferContractsOwnership(address newOwner) public virtual onlyOwner {
        transferOwnership(newOwner);
    }

    function withdrawUsdt(address currency, uint amount) external virtual onlyOwner {
        require(balanceOfPayable() >= amount, "The amount exceeds the balance.");
        _usdt.safeTransfer(currency, amount);
        withdrawPayable(amount);
    }

    function getInitialExchangeRate(address _owner) external view returns (uint) {
        return initialExchangeRate[_owner];
    }

  /**
   * @dev Returns the bep token owner.
   */
  function getOwner() external view returns (address) {
    return owner();
  }

  /**
   * @dev Returns the token decimals.
   */
  function decimals() external view returns (uint8) {
    return _decimals;
  }

  /**
   * @dev Returns the token symbol.
   */
  function symbol() external view returns (string memory) {
    return _symbol;
  }

  /**
  * @dev Returns the token name.
  */
  function name() external view returns (string memory) {
    return _name;
  }

  /**
   * @dev See {BEP20-totalSupply}.
   */
  function totalSupply() external view returns (uint256) {
    return _totalSupply;
  }

  /**
   * @dev See {BEP20-balanceOf}.
   */
  function balanceOf(address account) public view returns (uint256) {
    return _balances[account];
  }

  /**
   * @dev See {BEP20-transfer}.
   *
   * Requirements:
   *
   * - `recipient` cannot be the zero address.
   * - the caller must have a balance of at least `amount`.
   */
  function transfer(address recipient, uint256 amount) external returns (bool) {
    require(isTransferable, "Transfer is not available.");
    require(recipient != address(0), "Cannot send the funds to the zero address.");
    _transfer(_msgSender(), recipient, amount);
    return true;
  }

  /**
   * @dev See {BEP20-allowance}.
   */
  function allowance(address owner, address spender) external view returns (uint256) {
    return _allowances[owner][spender];
  }

  /**
   * @dev See {BEP20-approve}.
   *
   * Requirements:
   *
   * - `spender` cannot be the zero address.
   */
  function approve(address spender, uint256 amount) external returns (bool) {
    _approve(_msgSender(), spender, amount);
    return true;
  }

  /**
   * @dev See {BEP20-transferFrom}.
   *
   * Emits an {Approval} event indicating the updated allowance. This is not
   * required by the EIP. See the note at the beginning of {BEP20};
   *
   * Requirements:
   * - `sender` and `recipient` cannot be the zero address.
   * - `sender` must have a balance of at least `amount`.
   * - the caller must have allowance for `sender`'s tokens of at least
   * `amount`.
   */
  function transferFrom(address sender, address recipient, uint256 amount) public returns (bool) {
    require(isTransferable, "Transfer is not available.");
    require(recipient != address(0), "Cannot send the funds to the zero address.");
    _transfer(sender, recipient, amount);
    _approve(sender, _msgSender(), _allowances[sender][_msgSender()].sub(amount, "BEP20: transfer amount exceeds allowance"));
    return true;
  }

  /**
   * @dev Atomically increases the allowance granted to `spender` by the caller.
   *
   * This is an alternative to {approve} that can be used as a mitigation for
   * problems described in {BEP20-approve}.
   *
   * Emits an {Approval} event indicating the updated allowance.
   *
   * Requirements:
   *
   * - `spender` cannot be the zero address.
   */
  function increaseAllowance(address spender, uint256 addedValue) public returns (bool) {
    _approve(_msgSender(), spender, _allowances[_msgSender()][spender].add(addedValue));
    return true;
  }

  /**
   * @dev Atomically decreases the allowance granted to `spender` by the caller.
   *
   * This is an alternative to {approve} that can be used as a mitigation for
   * problems described in {BEP20-approve}.
   *
   * Emits an {Approval} event indicating the updated allowance.
   *
   * Requirements:
   *
   * - `spender` cannot be the zero address.
   * - `spender` must have allowance for the caller of at least
   * `subtractedValue`.
   */
  function decreaseAllowance(address spender, uint256 subtractedValue) public returns (bool) {
    _approve(_msgSender(), spender, _allowances[_msgSender()][spender].sub(subtractedValue, "BEP20: decreased allowance below zero"));
    return true;
  }

  /**
   * @dev Creates `amount` tokens and assigns them to `msg.sender`, increasing
   * the total supply.
   *
   * Requirements
   *
   * - `msg.sender` must be the token owner
   */
  function mint(uint256 amount) public onlyOwner returns (bool) {
    _mint(_msgSender(), amount);
    return true;
  }

  /**
   * @dev Moves tokens `amount` from `sender` to `recipient`.
   *
   * This is internal function is equivalent to {transfer}, and can be used to
   * e.g. implement automatic token fees, slashing mechanisms, etc.
   *
   * Emits a {Transfer} event.
   *
   * Requirements:
   *
   * - `sender` cannot be the zero address.
   * - `recipient` cannot be the zero address.
   * - `sender` must have a balance of at least `amount`.
   */
  function _transfer(address sender, address recipient, uint256 amount) internal {
    require(sender != address(0), "BEP20: transfer from the zero address");
    require(recipient != address(0), "BEP20: transfer to the zero address");

    _balances[sender] = _balances[sender].sub(amount, "BEP20: transfer amount exceeds balance");
    _balances[recipient] = _balances[recipient].add(amount);
    emit Transfer(sender, recipient, amount);
  }

  /** @dev Creates `amount` tokens and assigns them to `account`, increasing
   * the total supply.
   *
   * Emits a {Transfer} event with `from` set to the zero address.
   *
   * Requirements
   *
   * - `to` cannot be the zero address.
   */
  function _mint(address account, uint256 amount) internal {
    require(account != address(0), "BEP20: mint to the zero address");

    _totalSupply = _totalSupply.add(amount);
    _balances[account] = _balances[account].add(amount);
    emit Transfer(address(0), account, amount);
  }

  /**
   * @dev Destroys `amount` tokens from `account`, reducing the
   * total supply.
   *
   * Emits a {Transfer} event with `to` set to the zero address.
   *
   * Requirements
   *
   * - `account` cannot be the zero address.
   * - `account` must have at least `amount` tokens.
   */
  function _burn(address account, uint256 amount) internal {
    require(account != address(0), "BEP20: burn from the zero address");

    _balances[account] = _balances[account].sub(amount, "BEP20: burn amount exceeds balance");
    _totalSupply = _totalSupply.sub(amount);
    emit Transfer(account, address(0), amount);
  }

  /**
   * @dev Sets `amount` as the allowance of `spender` over the `owner`s tokens.
   *
   * This is internal function is equivalent to `approve`, and can be used to
   * e.g. set automatic allowances for certain subsystems, etc.
   *
   * Emits an {Approval} event.
   *
   * Requirements:
   *
   * - `owner` cannot be the zero address.
   * - `spender` cannot be the zero address.
   */
  function _approve(address owner, address spender, uint256 amount) internal {
    require(owner != address(0), "BEP20: approve from the zero address");
    require(spender != address(0), "BEP20: approve to the zero address");

    _allowances[owner][spender] = amount;
    emit Approval(owner, spender, amount);
  }

  
  function _burnFrom(address account, uint256 amount) internal {
    _burn(account, amount);
    _approve(account, _msgSender(), _allowances[account][_msgSender()].sub(amount, "BEP20: burn amount exceeds allowance"));
  }
}
// SPDX-License-Identifier: MIT

pragma solidity ^0.8.9;

interface IBEP20 {
  /**
   * @dev Returns the amount of tokens in existence.
   */
  function totalSupply() external view returns (uint256);

  /**
   * @dev Returns the token decimals.
   */
  function decimals() external view returns (uint8);

  /**
   * @dev Returns the token symbol.
   */
  function symbol() external view returns (string memory);

  /**
  * @dev Returns the token name.
  */
  function name() external view returns (string memory);

  /**
   * @dev Returns the bep token owner.
   */
  function getOwner() external view returns (address);

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
  function allowance(address _owner, address spender) external view returns (uint256);

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
}// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "./IBEP20.sol";

library Address {
    /**
     * @dev Returns true if `account` is a contract.
     *
     * [IMPORTANT]
     * ====
     * It is unsafe to assume that an address for which this function returns
     * false is an externally-owned account (EOA) and not a contract.
     *
     * Among others, `isContract` will return false for the following
     * types of addresses:
     *
     *  - an externally-owned account
     *  - a contract in construction
     *  - an address where a contract will be created
     *  - an address where a contract lived, but was destroyed
     * ====
     */
    function isContract(address account) internal view returns (bool) {
        // According to EIP-1052, 0x0 is the value returned for not-yet created accounts
        // and 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470 is returned
        // for accounts without code, i.e. `keccak256('')`
        bytes32 codehash;
        bytes32 accountHash = 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470;
        // solhint-disable-next-line no-inline-assembly
        assembly {
            codehash := extcodehash(account)
        }
        return (codehash != accountHash && codehash != 0x0);
    }

    /**
     * @dev Replacement for Solidity's `transfer`: sends `amount` wei to
     * `recipient`, forwarding all available gas and reverting on errors.
     *
     * https://eips.ethereum.org/EIPS/eip-1884[EIP1884] increases the gas cost
     * of certain opcodes, possibly making contracts go over the 2300 gas limit
     * imposed by `transfer`, making them unable to receive funds via
     * `transfer`. {sendValue} removes this limitation.
     *
     * https://diligence.consensys.net/posts/2019/09/stop-using-soliditys-transfer-now/[Learn more].
     *
     * IMPORTANT: because control is transferred to `recipient`, care must be
     * taken to not create reentrancy vulnerabilities. Consider using
     * {ReentrancyGuard} or the
     * https://solidity.readthedocs.io/en/v0.5.11/security-considerations.html#use-the-checks-effects-interactions-pattern[checks-effects-interactions pattern].
     */
    function sendValue(address payable recipient, uint256 amount) internal {
        require(address(this).balance >= amount, 'Address: insufficient balance');

        // solhint-disable-next-line avoid-low-level-calls, avoid-call-value
        (bool success, ) = recipient.call{value: amount}('');
        require(success, 'Address: unable to send value, recipient may have reverted');
    }

    /**
     * @dev Performs a Solidity function call using a low level `call`. A
     * plain`call` is an unsafe replacement for a function call: use this
     * function instead.
     *
     * If `target` reverts with a revert reason, it is bubbled up by this
     * function (like regular Solidity function calls).
     *
     * Returns the raw returned data. To convert to the expected return value,
     * use https://solidity.readthedocs.io/en/latest/units-and-global-variables.html?highlight=abi.decode#abi-encoding-and-decoding-functions[`abi.decode`].
     *
     * Requirements:
     *
     * - `target` must be a contract.
     * - calling `target` with `data` must not revert.
     *
     * _Available since v3.1._
     */
    function functionCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionCall(target, data, 'Address: low-level call failed');
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`], but with
     * `errorMessage` as a fallback revert reason when `target` reverts.
     *
     * _Available since v3.1._
     */
    function functionCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        return _functionCallWithValue(target, data, 0, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but also transferring `value` wei to `target`.
     *
     * Requirements:
     *
     * - the calling contract must have an ETH balance of at least `value`.
     * - the called Solidity function must be `payable`.
     *
     * _Available since v3.1._
     */
    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value
    ) internal returns (bytes memory) {
        return functionCallWithValue(target, data, value, 'Address: low-level call with value failed');
    }

    /**
     * @dev Same as {xref-Address-functionCallWithValue-address-bytes-uint256-}[`functionCallWithValue`], but
     * with `errorMessage` as a fallback revert reason when `target` reverts.
     *
     * _Available since v3.1._
     */
    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value,
        string memory errorMessage
    ) internal returns (bytes memory) {
        require(address(this).balance >= value, 'Address: insufficient balance for call');
        return _functionCallWithValue(target, data, value, errorMessage);
    }

    function _functionCallWithValue(
        address target,
        bytes memory data,
        uint256 weiValue,
        string memory errorMessage
    ) private returns (bytes memory) {
        require(isContract(target), 'Address: call to non-contract');

        // solhint-disable-next-line avoid-low-level-calls
        (bool success, bytes memory returndata) = target.call{value: weiValue}(data);
        if (success) {
            return returndata;
        } else {
            // Look for revert reason and bubble it up if present
            if (returndata.length > 0) {
                // The easiest way to bubble the revert reason is using memory via assembly

                // solhint-disable-next-line no-inline-assembly
                assembly {
                    let returndata_size := mload(returndata)
                    revert(add(32, returndata), returndata_size)
                }
            } else {
                revert(errorMessage);
            }
        }
    }
}

library SafeBEP20 {
    using SafeMath for uint256;
    using Address for address;

    function safeTransfer(
        IBEP20 token,
        address to,
        uint256 value
    ) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function safeTransferFrom(
        IBEP20 token,
        address from,
        address to,
        uint256 value
    ) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }

    /**
     * @dev Deprecated. This function has issues similar to the ones found in
     * {IBEP20-approve}, and its usage is discouraged.
     *
     * Whenever possible, use {safeIncreaseAllowance} and
     * {safeDecreaseAllowance} instead.
     */
    function safeApprove(
        IBEP20 token,
        address spender,
        uint256 value
    ) internal {
        // safeApprove should only be called when setting an initial allowance,
        // or when resetting it to zero. To increase and decrease it, use
        // 'safeIncreaseAllowance' and 'safeDecreaseAllowance'
        // solhint-disable-next-line max-line-length
        require(
            (value == 0) || (token.allowance(address(this), spender) == 0),
            'SafeBEP20: approve from non-zero to non-zero allowance'
        );
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
    }

    function safeIncreaseAllowance(
        IBEP20 token,
        address spender,
        uint256 value
    ) internal {
        uint256 newAllowance = token.allowance(address(this), spender).add(value);
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function safeDecreaseAllowance(
        IBEP20 token,
        address spender,
        uint256 value
    ) internal {
        uint256 newAllowance = token.allowance(address(this), spender).sub(
            value,
            'SafeBEP20: decreased allowance below zero'
        );
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    /**
     * @dev Imitates a Solidity high-level call (i.e. a regular function call to a contract), relaxing the requirement
     * on the return value: the return value is optional (but if data is returned, it must not be false).
     * @param token The token targeted by the call.
     * @param data The call data (encoded using abi.encode or one of its variants).
     */
    function _callOptionalReturn(IBEP20 token, bytes memory data) private {
        // We need to perform a low level call here, to bypass Solidity's return data size checking mechanism, since
        // we're implementing it ourselves. We use {Address.functionCall} to perform this call, which verifies that
        // the target address contains contract code and also asserts for success in the low-level call.

        bytes memory returndata = address(token).functionCall(data, 'SafeBEP20: low-level call failed');
        if (returndata.length > 0) {
            // Return data is optional
            // solhint-disable-next-line max-line-length
            require(abi.decode(returndata, (bool)), 'SafeBEP20: BEP20 operation did not succeed');
        }
    }
}// SPDX-License-Identifier: MIT

pragma solidity ^0.8.9;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";

contract DepositLimit is Ownable {
    using SafeMath for uint;

    uint public depositLimit;
    
    mapping(uint => bool) public depositLimitMap;

    constructor() {
        depositLimitMap[100000000000000000000] = true;
        depositLimit = 100000000000000000000;
    }

    function getDepositLimit() public view virtual returns (uint) {
        return depositLimit;
    }

    function incrementLimit(uint _countTransaction) internal virtual {
        if (_countTransaction == 1001) {
            depositLimitMap[150000000000000000000] = true;
            depositLimit = 150000000000000000000;
        }
        else if (_countTransaction == 3001) {
            depositLimitMap[225000000000000000000] = true;
            depositLimit = 225000000000000000000;
        }
        else if (_countTransaction == 6001) {
            depositLimitMap[337500000000000000000] = true;
            depositLimit = 337500000000000000000;
        }
        else if (_countTransaction == 14001) {
            depositLimitMap[500000000000000000000] = true;
            depositLimit = 500000000000000000000;
        }
        else if (_countTransaction == 24001) {
            depositLimitMap[750000000000000000000] = true;
            depositLimit = 750000000000000000000;
        }
    }
}// SPDX-License-Identifier: MIT

pragma solidity ^0.8.9;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";

contract ExchangeRate is Ownable {
    using SafeMath for uint;

    uint private _exchangeRate = 1000000000000000000;
    uint private _startRate = 1000000000000000000;
    
    uint public rateIncrement = 500000;
    mapping(uint => uint) public rateIncrementMap;

    constructor() {
        rateIncrementMap[1] = 500000;
        rateIncrementMap[1001] = 250000;
        rateIncrementMap[3001] = 187500;
        rateIncrementMap[6001] = 140625;
        rateIncrementMap[14001] = 125000;
    }

    function getExchangeRate() public view virtual returns (uint) {
        return _exchangeRate;
    }

    function incrementRate(uint countTransaction) internal virtual {
        if (rateIncrementMap[countTransaction] != 0) {
            rateIncrement = rateIncrementMap[countTransaction];
        }

        _exchangeRate = _exchangeRate.add(_startRate.mul(rateIncrement).div(1000000000));

        countTransaction += 1;

    }
}// SPDX-License-Identifier: MIT

pragma solidity ^0.8.9;

import "./DepositLimit.sol";
import "./ExchangeRate.sol";

contract HandleTransaction is ExchangeRate, DepositLimit {

    uint public countTransaction = 1;
    
    function handleTransaction() internal {
        incrementRate(countTransaction);
        incrementLimit(countTransaction);

        countTransaction += 1;
    }

    function getCountTransaction() public view virtual returns (uint) {
        return countTransaction;
    }
}// SPDX-License-Identifier: MIT

pragma solidity ^0.8.9;

import "./BEP20/IBEP20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "./BEP20/SafeBEP20.sol";

contract LiquidityPool is Ownable {
    using SafeBEP20 for IBEP20;

    event AddToLiquidity(address recipient, uint amount);

    uint256 public totalLiquidity;
    
    uint public payableBalance;
    uint public nonPayableBalance;

    IBEP20 private _usdt;
    address public axltContractAddress;

    constructor(IBEP20 usdt_, address axltContractAddress_) {
        require(axltContractAddress_ != address(0), "AXLT contract address cannot be the zero address.");
        _usdt = usdt_;
        axltContractAddress = axltContractAddress_;
    }
    
    function transferToPayable(uint amount) internal {
        require(amount > 0, "Amount can't be less then zero.");
        payableBalance += amount;
    }

    function transferToNonPayable(uint amount) internal {
        require(amount > 0, "Amount can't be less then zero.");
        nonPayableBalance += amount;
    }

    function withdrawPayable(uint amount) internal {
        require(amount > 0, "Amount can't be less then zero.");
        payableBalance -= amount;
    }

    function balanceOfPayable() public virtual view returns (uint) {
        return payableBalance;
    }

    function balanceOfNonPayable() public virtual view returns (uint) {
        return nonPayableBalance;
    }

    function additionToLiquidity(uint amount) external {
        require(amount > 0, "Amount can't be less then zero.");
        require(axltContractAddress != address(0), "Cannot send the funds to the zero address.");
        nonPayableBalance += amount;
        _usdt.safeTransferFrom(msg.sender, axltContractAddress, amount);
        emit AddToLiquidity(msg.sender, amount);
    }
}// SPDX-License-Identifier: MIT

pragma solidity ^0.8.9;

import "@openzeppelin/contracts/access/Ownable.sol";
import "./BEP20/IBEP20.sol";
import "./LiquidityPool.sol";
import "./AccountLimit.sol";
using SafeBEP20 for IBEP20;

contract ReferalProgram is LiquidityPool, AccountLimit {
    using SafeBEP20 for IBEP20;

    event BuyLine(address recipient, uint lineLevel);
    event BindSponsor(address child, address sponsor);

    mapping(address=>address) public sponsorMap;
    mapping(uint=>uint) private linesPrices;
    mapping(address=>uint) public userLine;

    IBEP20 private _usdt;
    address private _axltContractAddress;

    constructor(IBEP20 usdt_, address axltContractAddress_) LiquidityPool(usdt_, axltContractAddress_) AccountLimit(usdt_) {
        _usdt = usdt_;
        _axltContractAddress = axltContractAddress_;
        linesPrices[1] = 75000000000000000000;
        linesPrices[2] = 250000000000000000000;
        linesPrices[3] = 350000000000000000000;
        linesPrices[4] = 450000000000000000000;
        linesPrices[5] = 550000000000000000000;
    }

    function activateAndBindSponsor(address sponsor) external {
        require(sponsor != address(0), "Sponsor cannot be the zero address.");
        require(sponsor != msg.sender, "A user cannot be his own sponsor.");
        require(activeAccounts[sponsor], "The sponsor is not in the referral system.");
        activateAccount();
        sponsorMap[msg.sender] = sponsor;
        emit BindSponsor(msg.sender, sponsor);
    }

    function buyLine() external isActive virtual returns (bool) {
        require(userLine[msg.sender] < 5, "You have reached the maximum line level.");
        uint price = linesPrices[userLine[msg.sender] + 1];
        _buyLine(price, msg.sender);
        userLine[msg.sender] += 1;
        emit BuyLine(msg.sender, userLine[msg.sender]);
        return true;
    }

    function _buyLine(uint price, address recipient) private returns (bool) {
        require(recipient != address(0), "Recipient cannot be the zero address.");
        _usdt.transferFrom(recipient, address(this), price);
        _usdt.transfer(owner(), (price * 10) / 100);
        transferToPayable((price * 90) / 100);
        _paymentsToPartnersFromBuyLine(msg.sender, price);
        return true;
    }
    
    function getPriceLine(uint lineNumber) public view returns(uint) {
        return linesPrices[lineNumber];
    }

    function _paymentsToPartnersFromTradeTokens(address recipient, uint price) internal {
        require(recipient != address(0), "Recipient cannot be the zero address.");
        for (uint i = 1; i < 6; i++) {
                if (i <= userLine[sponsorMap[recipient]]) {
                    _usdt.transfer(sponsorMap[recipient], (price * _getTradeTokenFees(i)) / 100000);
                    nonPayableBalance -= (price * _getTradeTokenFees(i)) / 100000;
                }
                recipient = sponsorMap[recipient];
                if (recipient == address(0)) {
                    return;
                }
        }
    }

    function _paymentsToPartnersFromBuyLine(address recipient, uint price) internal {
        require(recipient != address(0), "Recipient cannot be the zero address.");
        for (uint i = 1; i < 6; i++) {
                if (i <= userLine[sponsorMap[recipient]]) {
                    _usdt.safeTransfer(sponsorMap[recipient], (price * _getBuyLinesFee(i)) / 100);
                    withdrawPayable((price * _getBuyLinesFee(i)) / 100);
                }
                recipient = sponsorMap[recipient];
                if (recipient == address(0)) {
                    return;
                }
            }
    }

    function _getTradeTokenFees(uint level) private pure returns(uint) {
        if (level == 1) {
            return 2000;
        }
        else if (level == 2) {
            return 1500;
        }
        else if (level == 3) {
            return 750;
        }
        else if (level == 4) {
            return 500;
        }
        else if (level == 5) {
            return 250;
        }
        return 0;
    }

    function _getBuyLinesFee(uint level) private pure returns(uint) {
        if (level == 1) {
            return 10;
        }
        else if (level == 2) {
            return 5;
        }
        else if (level == 3) {
            return 6;
        }
        else if (level == 4) {
            return 9;
        }
        else if (level == 5) {
            return 10;
        }
        return 0;
    }

}