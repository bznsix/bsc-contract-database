//SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

library Clones {
    /**
     * @dev Deploys and returns the address of a clone that mimics the behaviour of `implementation`.
     *
     * This function uses the create opcode, which should never revert.
     */
    function clone(address implementation) internal returns (address instance) {
        assembly {
            let ptr := mload(0x40)
            mstore(
                ptr,
                0x3d602d80600a3d3981f3363d3d373d3d3d363d73000000000000000000000000
            )
            mstore(add(ptr, 0x14), shl(0x60, implementation))
            mstore(
                add(ptr, 0x28),
                0x5af43d82803e903d91602b57fd5bf30000000000000000000000000000000000
            )
            instance := create(0, ptr, 0x37)
        }
        require(instance != address(0), "ERC1167: create failed");
    }
}
// SPDX-License-Identifier: MIT

pragma solidity ^0.8.6;

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
}// SPDX-License-Identifier: MIT

pragma solidity ^0.8.6;

import "./IERC20.sol";
import "./Context.sol";
import "./SafeMath.sol";

/**
 * @dev Implementation of the {IERC20} interface.
 *
 * This implementation is agnostic to the way tokens are created. This means
 * that a supply mechanism has to be added in a derived contract using {_tokengeneration}.
 * TIP: For a detailed writeup see our guide
 * https://forum.zeppelin.solutions/t/how-to-implement-erc20-supply-mechanisms/226[How
 * to implement supply mechanisms].
 *
 * We have followed general OpenZeppelin guidelines: functions revert instead
 * of returning `false` on failure. This behavior is nonetheless conventional
 * and does not conflict with the expectations of ERC20 applications.
 *
 * Additionally, an {Approval} event is emitted on calls to {transferFrom}.
 * This allows applications to reconstruct the allowance for all accounts just
 * by listening to said events. Other implementations of the EIP may not emit
 * these events, as it isn't required by the specification.
 *
 * Finally, the non-standard {decreaseAllowance} and {increaseAllowance}
 * functions have been added to mitigate the well-known issues around setting
 * allowances. See {IERC20-approve}.
 */
contract ERC20 is Context, IERC20, IERC20Metadata {
    using SafeMath for uint256;

    mapping(address => uint256) private _balances;

    mapping(address => mapping(address => uint256)) private _allowances;

    uint256 private _totalSupply;

    string private _name;
    string private _symbol;
    uint8 private _deciamls;

    /**
     * @dev Sets the values for {name} and {symbol}.
     *
     * The default value of {decimals} is 18. To select a different value for
     * {decimals} you should overload it.
     *
     * All two of these values are immutable: they can only be set once during
     * construction.
     */

    function initERC20(
        string memory name_,
        string memory symbol_,
        uint8 decimal_
    ) internal {
        _name = name_;
        _symbol = symbol_;
        _deciamls = decimal_;
    }

    /**
     * @dev Returns the name of the token.
     */
    function name() public view virtual override returns (string memory) {
        return _name;
    }

    /**
     * @dev Returns the symbol of the token, usually a shorter version of the
     * name.
     */
    function symbol() public view virtual override returns (string memory) {
        return _symbol;
    }

    /**
     * @dev Returns the number of decimals used to get its user representation.
     * For example, if `decimals` equals `2`, a balance of `505` tokens should
     * be displayed to a user as `5,05` (`505 / 10 ** 2`).
     *
     * Tokens usually opt for a value of 18, imitating the relationship between
     * Ether and Wei. This is the value {ERC20} uses, unless this function is
     * overridden;
     *
     * NOTE: This information is only used for _display_ purposes: it in
     * no way affects any of the arithmetic of the contract, including
     * {IERC20-balanceOf} and {IERC20-transfer}.
     */
    function decimals() public view virtual override returns (uint8) {
        return _deciamls;
    }

    /**
     * @dev See {IERC20-totalSupply}.
     */
    function totalSupply() public view virtual override returns (uint256) {
        return _totalSupply;
    }

    /**
     * @dev See {IERC20-balanceOf}.
     */
    function balanceOf(
        address account
    ) public view virtual override returns (uint256) {
        return _balances[account];
    }

    /**
     * @dev See {IERC20-transfer}.
     *
     * Requirements:
     *
     * - `recipient` cannot be the zero address.
     * - the caller must have a balance of at least `amount`.
     */
    function transfer(
        address recipient,
        uint256 amount
    ) public virtual override returns (bool) {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    /**
     * @dev See {IERC20-allowance}.
     */
    function allowance(
        address owner,
        address spender
    ) public view virtual override returns (uint256) {
        return _allowances[owner][spender];
    }

    /**
     * @dev See {IERC20-approve}.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     */
    function approve(
        address spender,
        uint256 amount
    ) public virtual override returns (bool) {
        _approve(_msgSender(), spender, amount);
        return true;
    }

    /**
     * @dev See {IERC20-transferFrom}.
     *
     * Emits an {Approval} event indicating the updated allowance. This is not
     * required by the EIP. See the note at the beginning of {ERC20}.
     *
     * Requirements:
     *
     * - `sender` and `recipient` cannot be the zero address.
     * - `sender` must have a balance of at least `amount`.
     * - the caller must have allowance for ``sender``'s tokens of at least
     * `amount`.
     */
    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) public virtual override returns (bool) {
        _transfer(sender, recipient, amount);
        _approve(
            sender,
            _msgSender(),
            _allowances[sender][_msgSender()].sub(
                amount,
                "ERC20: transfer amount exceeds allowance"
            )
        );
        return true;
    }

    /**
     * @dev Atomically increases the allowance granted to `spender` by the caller.
     *
     * This is an alternative to {approve} that can be used as a mitigation for
     * problems described in {IERC20-approve}.
     *
     * Emits an {Approval} event indicating the updated allowance.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     */
    function increaseAllowance(
        address spender,
        uint256 addedValue
    ) public virtual returns (bool) {
        _approve(
            _msgSender(),
            spender,
            _allowances[_msgSender()][spender].add(addedValue)
        );
        return true;
    }

    /**
     * @dev Atomically decreases the allowance granted to `spender` by the caller.
     *
     * This is an alternative to {approve} that can be used as a mitigation for
     * problems described in {IERC20-approve}.
     *
     * Emits an {Approval} event indicating the updated allowance.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     * - `spender` must have allowance for the caller of at least
     * `subtractedValue`.
     */
    function decreaseAllowance(
        address spender,
        uint256 subtractedValue
    ) public virtual returns (bool) {
        _approve(
            _msgSender(),
            spender,
            _allowances[_msgSender()][spender].sub(
                subtractedValue,
                "ERC20: decreased allowance below zero"
            )
        );
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
    function _transfer(
        address sender,
        address recipient,
        uint256 amount
    ) internal virtual {
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");

        _beforeTokenTransfer(sender, recipient, amount);

        _balances[sender] = _balances[sender].sub(
            amount,
            "ERC20: transfer amount exceeds balance"
        );
        _balances[recipient] = _balances[recipient].add(amount);
        emit Transfer(sender, recipient, amount);
    }

    /*
            _tokengeneration is an internal function in ERC20.sol that is only called here to generate the total supply first time,
            and CANNOT be called ever again
        */
    function _tokengeneration(
        address account,
        uint256 amount
    ) internal virtual {
        require(account != address(0), "ERC20: new tokens to the zero address");

        _beforeTokenTransfer(address(0), account, amount);

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
     * Requirements:
     *
     * - `account` cannot be the zero address.
     * - `account` must have at least `amount` tokens.
     */
    function _burn(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: burn from the zero address");

        _beforeTokenTransfer(account, address(0), amount);

        _balances[account] = _balances[account].sub(
            amount,
            "ERC20: burn amount exceeds balance"
        );
        _totalSupply = _totalSupply.sub(amount);
        emit Transfer(account, address(0), amount);
    }

    /**
     * @dev Sets `amount` as the allowance of `spender` over the `owner` s tokens.
     *
     * This internal function is equivalent to `approve`, and can be used to
     * e.g. set automatic allowances for certain subsystems, etc.
     *
     * Emits an {Approval} event.
     *
     * Requirements:
     *
     * - `owner` cannot be the zero address.
     * - `spender` cannot be the zero address.
     */
    function _approve(
        address owner,
        address spender,
        uint256 amount
    ) internal virtual {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {}
}
// SPDX-License-Identifier: MIT

pragma solidity ^0.8.6;

interface IPair {
    function sync() external;
}

interface IFactory {
    function createPair(
        address tokenA,
        address tokenB
    ) external returns (address pair);

    function getPair(
        address tokenA,
        address tokenB
    ) external view returns (address pair);
}

interface IRouter {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);

    function addLiquidityETH(
        address token,
        uint amountTokenDesired,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    )
        external
        payable
        returns (uint amountToken, uint amountETH, uint liquidity);

    function swapExactETHForTokensSupportingFeeOnTransferTokens(
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external payable;

    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;

    function swapExactETHForTokens(
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external payable returns (uint[] memory amounts);

    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
}
// SPDX-License-Identifier: MIT

pragma solidity ^0.8.6;

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
    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);

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

/**
 * @dev Interface for the optional metadata functions from the ERC20 standard.
 *
 * _Available since v4.1._
 */
interface IERC20Metadata is IERC20 {
    /**
     * @dev Returns the name of the token.
     */
    function name() external view returns (string memory);

    /**
     * @dev Returns the symbol of the token.
     */
    function symbol() external view returns (string memory);

    /**
     * @dev Returns the decimals places of the token.
     */
    function decimals() external view returns (uint8);
}pragma solidity ^0.8.6;

// SPDX-License-Identifier: MIT License

import "./Context.sol";

contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor() {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(_owner == _msgSender(), "Ownable: caller is not the owner");
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
        require(
            newOwner != address(0),
            "Ownable: new owner is the zero address"
        );
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }

    function _transferOwnership(address newOwner) internal virtual {
        _owner = newOwner;
    }
}
// SPDX-License-Identifier: MIT

pragma solidity ^0.8.6;

library SafeMath {
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
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
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
        return sub(a, b, "SafeMath: subtraction overflow");
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting with custom message on
     * overflow (when the result is negative).
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     *
     * - Subtraction cannot overflow.
     */
    function sub(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        uint256 c = a - b;

        return c;
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
        // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
        // benefit is lost if 'b' is also tested.
        // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");

        return c;
    }

    /**
     * @dev Returns the integer division of two unsigned integers. Reverts on
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
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return div(a, b, "SafeMath: division by zero");
    }

    /**
     * @dev Returns the integer division of two unsigned integers. Reverts with custom message on
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
    function div(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold

        return c;
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * Reverts when dividing by zero.
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
        return mod(a, b, "SafeMath: modulo by zero");
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * Reverts with custom message when dividing by zero.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function mod(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        require(b != 0, errorMessage);
        return a % b;
    }
}

/**
 * @title SafeMathInt
 * @dev Math operations for int256 with overflow safety checks.
 */
library SafeMathInt {
    int256 private constant MIN_INT256 = int256(1) << 255;
    int256 private constant MAX_INT256 = ~(int256(1) << 255);

    /**
     * @dev Multiplies two int256 variables and fails on overflow.
     */
    function mul(int256 a, int256 b) internal pure returns (int256) {
        int256 c = a * b;

        // Detect overflow when multiplying MIN_INT256 with -1
        require(c != MIN_INT256 || (a & MIN_INT256) != (b & MIN_INT256));
        require((b == 0) || (c / b == a));
        return c;
    }

    /**
     * @dev Division of two int256 variables and fails on overflow.
     */
    function div(int256 a, int256 b) internal pure returns (int256) {
        // Prevent overflow when dividing MIN_INT256 by -1
        require(b != -1 || a != MIN_INT256);

        // Solidity already throws when dividing by 0.
        return a / b;
    }

    /**
     * @dev Subtracts two int256 variables and fails on overflow.
     */
    function sub(int256 a, int256 b) internal pure returns (int256) {
        int256 c = a - b;
        require((b >= 0 && c <= a) || (b < 0 && c > a));
        return c;
    }

    /**
     * @dev Adds two int256 variables and fails on overflow.
     */
    function add(int256 a, int256 b) internal pure returns (int256) {
        int256 c = a + b;
        require((b >= 0 && c >= a) || (b < 0 && c < a));
        return c;
    }

    /**
     * @dev Converts to absolute value, and fails on overflow.
     */
    function abs(int256 a) internal pure returns (int256) {
        require(a != MIN_INT256);
        return a < 0 ? -a : a;
    }

    function toUint256Safe(int256 a) internal pure returns (uint256) {
        require(a >= 0);
        return uint256(a);
    }
}

/**
 * @title SafeMathUint
 * @dev Math operations with safety checks that revert on error
 */
library SafeMathUint {
    function toInt256Safe(uint256 a) internal pure returns (int256) {
        int256 b = int256(a);
        require(b >= 0);
        return b;
    }
}
// SPDX-License-Identifier: MIT

pragma solidity ^0.8.17;

import "./IDex.sol";
import "./ERC20.sol";
import "./Ownable.sol";

interface IDividendTracker {
    function processAccount(address payable account, bool automatic) external;

    function process(
        uint256 gas
    )
        external
        returns (
            uint256 iterations,
            uint256 claims,
            uint256 lastProcessedIndex
        );

    function setBalance(address from, uint256 balance) external;

    function getLastProcessedIndex() external view returns (uint256);

    function getNumberOfTokenHolders() external view returns (uint256);

    function getAccount(
        address account
    )
        external
        view
        returns (
            address,
            int256,
            int256,
            uint256,
            uint256,
            uint256,
            uint256,
            uint256
        );

    function getAccountAtIndex(
        uint256 index
    )
        external
        view
        returns (
            address,
            int256,
            int256,
            uint256,
            uint256,
            uint256,
            uint256,
            uint256
        );

    function withdrawableDividendOf(
        address account
    ) external view returns (uint256);

    function getCurrentRewardToken() external view returns (string memory);

    function balanceOf(address account) external view returns (uint256);

    function updateClaimWait(uint256 claimWait) external;

    function claimWait() external view returns (uint256);

    function totalDividendsDistributed() external view returns (uint256);

    function setMinBalanceForDividends(uint256 amount) external;

    function excludeFromDividends(address account, bool value) external;
}

contract Token is ERC20, Ownable {
    struct Taxes {
        uint256 rewards;
        uint256 marketing;
        uint256 burn;
        uint256 liquidity;
    }
    IDividendTracker public dividendTracker;
    IRouter public router;
    address public pair;
    bool private swapping;
    bool public swapEnabled = true;
    bool public tradingEnabled;
    bool public antiBot;
    uint256 public startingBlock;
    uint256 public swapTokensAtAmount;
    address public constant deadWallet =
        0x000000000000000000000000000000000000dEaD;
    bool public initialized;
    address public marketingWallet;

    Taxes public buyTaxes;
    Taxes public sellTaxes;
    Taxes public transferTaxes;
    Taxes public antiBotTaxes = Taxes(0, 99, 0, 0);

    uint256 public totalMarketingFees = 0;
    uint256 public totalLiquidityFees = 0;
    uint256 public totalRewardFees = 0;

    mapping(address => bool) private _isExcludedFromFees;
    mapping(address => bool) public automatedMarketMakerPairs;
    uint256 public gasForProcessing = 300000;

    event ExcludeFromFees(address indexed account, bool isExcluded);
    event ExcludeMultipleAccountsFromFees(address[] accounts, bool isExcluded);
    event SetAutomatedMarketMakerPair(address indexed pair, bool indexed value);
    event GasForProcessingUpdated(
        uint256 indexed newValue,
        uint256 indexed oldValue
    );
    event SendDividends(uint256 tokensSwapped, uint256 amount);
    event ProcessedDividendTracker(
        uint256 iterations,
        uint256 claims,
        uint256 lastProcessedIndex,
        bool indexed automatic,
        uint256 gas,
        address indexed processor
    );

    modifier noInitialized() {
        require(!initialized, "Already initialized!");
        _;
        initialized = true;
    }

    function init(bytes memory data) public onlyOwner noInitialized {
        (
            string memory tokenName,
            string memory tokenSymbol,
            uint8 tokenDecimal,
            uint256 supply,
            address newOwner,
            address dexAddress,
            uint256[] memory _buyTaxes,
            uint256[] memory _sellTaxes,
            uint256[] memory _transferTaxes,
            address payable _dividendTracker,
            bool _antiBot
        ) = abi.decode(
                data,
                (
                    string,
                    string,
                    uint8,
                    uint256,
                    address,
                    address,
                    uint256[],
                    uint256[],
                    uint256[],
                    address,
                    bool
                )
            );
        initERC20(tokenName, tokenSymbol, tokenDecimal);
        _tokengeneration(newOwner, supply);
        router = IRouter(dexAddress);
        pair = IFactory(router.factory()).createPair(
            address(this),
            router.WETH()
        );
        dividendTracker = IDividendTracker(_dividendTracker);
        dividendTracker.excludeFromDividends(address(dividendTracker), true);
        dividendTracker.excludeFromDividends(address(this), true);
        dividendTracker.excludeFromDividends(newOwner, true);
        dividendTracker.excludeFromDividends(deadWallet, true);
        _setAutomatedMarketMakerPair(pair, true);
        excludeFromFees(newOwner, true);
        excludeFromFees(address(this), true);
        swapTokensAtAmount = totalSupply() / 10000;
        buyTaxes = Taxes(
            _buyTaxes[0],
            _buyTaxes[1],
            _buyTaxes[2],
            _buyTaxes[3]
        );
        sellTaxes = Taxes(
            _sellTaxes[0],
            _sellTaxes[1],
            _sellTaxes[2],
            _sellTaxes[3]
        );
        transferTaxes = Taxes(
            _transferTaxes[0],
            _transferTaxes[1],
            _transferTaxes[2],
            _transferTaxes[3]
        );
        totalMarketingFees =
            buyTaxes.marketing +
            sellTaxes.marketing +
            transferTaxes.marketing;
        totalRewardFees =
            buyTaxes.rewards +
            sellTaxes.rewards +
            transferTaxes.rewards;
        totalLiquidityFees =
            buyTaxes.liquidity +
            sellTaxes.liquidity +
            transferTaxes.liquidity;
        antiBot = _antiBot;
        transferOwnership(newOwner);
    }

    function excludeFromFees(address account, bool excluded) public onlyOwner {
        require(
            _isExcludedFromFees[account] != excluded,
            "Account is already the value of 'excluded'"
        );
        _isExcludedFromFees[account] = excluded;

        emit ExcludeFromFees(account, excluded);
    }

    function excludeMultipleAccountsFromFees(
        address[] calldata accounts,
        bool excluded
    ) public onlyOwner {
        for (uint256 i = 0; i < accounts.length; i++) {
            _isExcludedFromFees[accounts[i]] = excluded;
        }
        emit ExcludeMultipleAccountsFromFees(accounts, excluded);
    }

    function excludeFromDividends(
        address account,
        bool value
    ) external onlyOwner {
        dividendTracker.excludeFromDividends(account, value);
    }

    function setMarketingWallet(address newWallet) external onlyOwner {
        require(newWallet != address(0), "Fee Address cannot be zero address");
        marketingWallet = newWallet;
    }

    function setSwapTokensAtAmount(uint256 amount) external onlyOwner {
        require(
            amount > totalSupply() / 1000000,
            "Swap Threshold should be greater than 0.00001% of total supply"
        );
        swapTokensAtAmount = amount;
    }

    function setSwapEnabled(bool _enabled) external onlyOwner {
        swapEnabled = _enabled;
    }

    function setMinBalanceForDividends(uint256 amount) external onlyOwner {
        dividendTracker.setMinBalanceForDividends(amount);
    }

    function _setAutomatedMarketMakerPair(address newPair, bool value) private {
        require(
            automatedMarketMakerPairs[newPair] != value,
            "Automated market maker pair is already set to that value"
        );
        automatedMarketMakerPairs[newPair] = value;
        if (value) {
            dividendTracker.excludeFromDividends(newPair, true);
        }
        emit SetAutomatedMarketMakerPair(newPair, value);
    }

    function setGasForProcessing(uint256 newValue) external onlyOwner {
        require(
            newValue >= 200000 && newValue <= 500000,
            "gasForProcessing must be between 200,000 and 500,000"
        );
        require(
            newValue != gasForProcessing,
            "Cannot update gasForProcessing to same value"
        );
        emit GasForProcessingUpdated(newValue, gasForProcessing);
        gasForProcessing = newValue;
    }

    function setClaimWait(uint256 claimWait) external onlyOwner {
        dividendTracker.updateClaimWait(claimWait);
    }

    function getClaimWait() external view returns (uint256) {
        return dividendTracker.claimWait();
    }

    function getTotalDividendsDistributed() external view returns (uint256) {
        return dividendTracker.totalDividendsDistributed();
    }

    function isExcludedFromFees(address account) public view returns (bool) {
        return _isExcludedFromFees[account];
    }

    function withdrawableDividendOf(
        address account
    ) public view returns (uint256) {
        return dividendTracker.withdrawableDividendOf(account);
    }

    function getCurrentRewardToken() external view returns (string memory) {
        return dividendTracker.getCurrentRewardToken();
    }

    function dividendTokenBalanceOf(
        address account
    ) public view returns (uint256) {
        return dividendTracker.balanceOf(account);
    }

    function enableTrading() public onlyOwner {
        require(!tradingEnabled, "trading is already enabled");
        tradingEnabled = true;
        startingBlock = block.number;
    }

    function getAccountDividendsInfo(
        address account
    )
        external
        view
        returns (
            address,
            int256,
            int256,
            uint256,
            uint256,
            uint256,
            uint256,
            uint256
        )
    {
        return dividendTracker.getAccount(account);
    }

    function getAccountDividendsInfoAtIndex(
        uint256 index
    )
        external
        view
        returns (
            address,
            int256,
            int256,
            uint256,
            uint256,
            uint256,
            uint256,
            uint256
        )
    {
        return dividendTracker.getAccountAtIndex(index);
    }

    function getLastProcessedIndex() external view returns (uint256) {
        return dividendTracker.getLastProcessedIndex();
    }

    function getNumberOfDividendTokenHolders() external view returns (uint256) {
        return dividendTracker.getNumberOfTokenHolders();
    }

    function _transfer(
        address from,
        address to,
        uint256 amount
    ) internal override {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");
        if (amount == 0) {
            super._transfer(from, to, 0);
            return;
        }
        // Internal swap
        uint256 contractTokenBalance = balanceOf(address(this));
        bool canSwap = contractTokenBalance >= swapTokensAtAmount;
        if (
            canSwap &&
            !swapping &&
            swapEnabled &&
            !automatedMarketMakerPairs[from] &&
            !_isExcludedFromFees[from] &&
            !_isExcludedFromFees[to]
        ) {
            swapping = true;
            {
                uint256 totalShares = totalMarketingFees +
                    totalLiquidityFees +
                    totalRewardFees;
                if (totalShares > 0) {
                    if (totalRewardFees > 0) {
                        internalSwap(
                            (contractTokenBalance * totalRewardFees) /
                                totalShares,
                            address(dividendTracker)
                        );
                    }
                    if (totalLiquidityFees > 0) {
                        liquify(
                            (contractTokenBalance * totalLiquidityFees) /
                                totalShares
                        );
                    }
                    if (totalMarketingFees > 0) {
                        internalSwap(balanceOf(address(this)), marketingWallet);
                    }
                }
            }
            swapping = false;
        }
        bool takeFee = !swapping;
        if (_isExcludedFromFees[from] || _isExcludedFromFees[to]) {
            takeFee = false;
        } else {
            require(tradingEnabled, "trading is not enabled yet");
        }
        if (takeFee) {
            uint256 swapAmt;
            uint256 burnAmt;
            Taxes memory taxes;
            if (antiBot && startingBlock + 10 >= block.number) {
                taxes = Taxes(0, 99, 0, 0);
            } else {
                if (automatedMarketMakerPairs[to]) {
                    taxes = sellTaxes;
                } else if (automatedMarketMakerPairs[from]) {
                    taxes = buyTaxes;
                } else {
                    taxes = transferTaxes;
                }
            }
            uint256 burnTax = taxes.burn;
            uint256 totalTax = taxes.liquidity +
                taxes.marketing +
                taxes.rewards;
            swapAmt = (amount * totalTax) / 100;
            burnAmt = (amount * burnTax) / 100;
            if (burnAmt > 0) {
                super._transfer(from, deadWallet, burnAmt);
            }
            amount = amount - (swapAmt + burnAmt);
            super._transfer(from, address(this), swapAmt);
        }

        super._transfer(from, to, amount);

        try dividendTracker.setBalance(from, balanceOf(from)) {} catch {}
        try dividendTracker.setBalance(to, balanceOf(to)) {} catch {}
        if (!swapping) {
            uint256 gas = gasForProcessing;
            try dividendTracker.process(gas) returns (
                uint256 iterations,
                uint256 claims,
                uint256 lastProcessedIndex
            ) {
                emit ProcessedDividendTracker(
                    iterations,
                    claims,
                    lastProcessedIndex,
                    true,
                    gas,
                    tx.origin
                );
            } catch {}
        }
    }

    function liquify(uint256 tokens) internal {
        if (tokens == 0) return;
        uint256 half = tokens / 2;
        uint256 otherHalf = tokens - half;
        uint256 initialBalance = address(this).balance;
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = router.WETH();
        _approve(address(this), address(router), ~uint256(0));
        try
            router.swapExactTokensForETHSupportingFeeOnTransferTokens(
                half,
                0,
                path,
                address(this),
                block.timestamp
            )
        {} catch {}
        uint256 newBalance = address(this).balance - initialBalance;
        try
            router.addLiquidityETH{value: newBalance}(
                address(this),
                otherHalf,
                0,
                0,
                address(deadWallet),
                block.timestamp
            )
        {} catch {}
    }

    function internalSwap(uint256 tokenAmount, address wallet) internal {
        if (balanceOf(address(this)) == 0 || tokenAmount == 0) return;
        uint256 initialBalance = address(this).balance;
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = router.WETH();
        try
            router.swapExactTokensForETHSupportingFeeOnTransferTokens(
                tokenAmount,
                0,
                path,
                address(this),
                block.timestamp
            )
        {} catch {
            return;
        }
        uint256 newBalance = address(this).balance - initialBalance;
        (bool success, ) = address(wallet).call{value: newBalance}("");
        if (wallet == address(dividendTracker)) {
            if (success) emit SendDividends(tokenAmount, newBalance);
        }
    }

    function processDividendTracker(uint256 gas) external {
        (
            uint256 iterations,
            uint256 claims,
            uint256 lastProcessedIndex
        ) = dividendTracker.process(gas);
        emit ProcessedDividendTracker(
            iterations,
            claims,
            lastProcessedIndex,
            false,
            gas,
            tx.origin
        );
    }

    function claim() external {
        dividendTracker.processAccount(payable(msg.sender), false);
    }

    function rescueERC20Tokens(address tokenAddress) external onlyOwner {
        if (tokenAddress == address(0)) {
            uint256 ETHbalance = address(this).balance;
            (bool success, ) = (msg.sender).call{value: ETHbalance}("");
        } else {
            IERC20(tokenAddress).transfer(
                msg.sender,
                IERC20(tokenAddress).balanceOf(address(this))
            );
        }
    }

    receive() external payable {}
}
//SPDX-License-Identifier: MIT

import {Token, Ownable, ERC20} from "./CostumeRewards/Token.sol";
import "./Clone.sol";

pragma solidity ^0.8.17;

interface IDex {
    function getAmountsOut(
        uint256 amountIn,
        address[] memory path
    ) external view returns (uint256[] memory);

    function WETH() external pure returns (address);
}

interface TokenInterface {
    function init(bytes memory data) external;

    function setMarketingWallet(address newWallet) external;
}

interface IDividendTracker {
    function init(
        address router_,
        address rewardToken_,
        uint8 decimal,
        address newOwner
    ) external;
}

contract Nero_Creator is Ownable {
    using Clones for address;

    struct TokenParameters {
        string name;
        string symbol;
        uint8 decimals;
        uint256 totalSupply;
        uint256[] buyTaxes;
        uint256[] sellTaxes;
        uint256[] transferTaxes;
        address[] addressArgs;
        bool antiBot;
    }

    uint256 public feeCreationInUSD;
    address public immutable USDT;
    IDex public router;
    mapping(address => bool) public allowedToken;
    mapping(address => address[]) public pathToUSDT;
    mapping(address => bool) public isStable;

    mapping(bytes32 => bool) public isAllowedToDeploy;
    mapping(address => address[]) public createdContractsByUser;

    struct Taxes {
        uint256 rewards;
        uint256 marketing;
        uint256 burn;
        uint256 liquidity;
    }

    constructor(address usdt, uint256 fee, address _router) {
        feeCreationInUSD = fee * 10 ** ERC20(usdt).decimals();
        USDT = usdt;
        router = IDex(_router);
        allowedToken[address(0)] = true;
    }

    function changeFeeUSD(uint256 fee) public onlyOwner {
        feeCreationInUSD = fee * 10 ** ERC20(USDT).decimals();
    }

    function createToken(
        TokenParameters memory params,
        address tracker
    ) public payable {
        require(allowedToken[params.addressArgs[3]], "fee token not allowed!");
        Token token = new Token();
        address newTracker = tracker.clone();
        IDividendTracker(newTracker).init(
            params.addressArgs[2],
            params.addressArgs[0],
            params.decimals,
            address(token)
        );
        token.setMarketingWallet(params.addressArgs[1]);
        bytes memory encodedArgs = abi.encode(
            params.name,
            params.symbol,
            params.decimals,
            params.totalSupply,
            msg.sender,
            params.addressArgs[2],
            params.buyTaxes,
            params.sellTaxes,
            params.transferTaxes,
            address(newTracker),
            params.antiBot
        );
        token.init(encodedArgs);
        if (params.addressArgs[3] == address(0)) {
            _payFee(address(0), msg.value);
        } else {
            _payFee(params.addressArgs[3], feeCreationInUSD);
        }
        createdContractsByUser[msg.sender].push(address(token));
    }

    function setTokenForFee(
        address token,
        bool allowed,
        bool isStableCoin,
        address[] memory _pathToUSDT
    ) public onlyOwner {
        allowedToken[token] = allowed;
        isStable[token] = isStableCoin;
        if (allowed && !isStableCoin) {
            require(
                _pathToUSDT[_pathToUSDT.length - 1] == USDT,
                "Invalid path"
            );
            require(_pathToUSDT[0] == token, "Invalid path");
            pathToUSDT[token] = _pathToUSDT;
        }
    }

    function _payFee(address feeToken, uint256 amount) internal {
        uint256 valueInUSD;
        if (feeToken == address(0)) {
            address[] memory path = new address[](2);
            path[0] = router.WETH();
            path[1] = USDT;
            uint256[] memory output = router.getAmountsOut(amount, path);
            valueInUSD = output[1];
        } else if (isStable[feeToken]) {
            valueInUSD =
                (amount * ERC20(USDT).decimals()) /
                ERC20(feeToken).decimals();
        } else {
            uint256[] memory output = router.getAmountsOut(
                amount,
                pathToUSDT[feeToken]
            );
            valueInUSD = output[output.length - 1];
        }
        require(valueInUSD >= feeCreationInUSD, "not enough fee!");
        if (feeToken == address(0)) {
            (bool success, ) = address(owner()).call{value: amount}("");
        } else {
            ERC20(feeToken).transferFrom(msg.sender, owner(), amount);
        }
    }

    function rescueERC20Tokens(address tokenAddress) external onlyOwner {
        ERC20(tokenAddress).transfer(
            msg.sender,
            ERC20(tokenAddress).balanceOf(address(this))
        );
    }

    function rescueETH() external onlyOwner {
        uint256 ETHbalance = address(this).balance;
        (bool success, ) = (msg.sender).call{value: ETHbalance}("");
    }

    function userContracts(
        address user
    ) external view returns (address[] memory) {
        return createdContractsByUser[user];
    }

    receive() external payable {}

    fallback() external payable {}
}
