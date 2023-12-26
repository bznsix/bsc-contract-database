/**
 *Submitted for verification at BscScan.com on 2023-11-01
*/

// SPDX-License-Identifier: MIT
// File: B2Btoken/IPancakeRouter01.sol

pragma solidity >=0.6.2;

interface IPancakeRouter01 {
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

// File: B2Btoken/IPancakeRouter02.sol

pragma solidity >=0.6.2;

interface IPancakeRouter02 is IPancakeRouter01 {
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
// File: B2Btoken/IPancakePair.sol

pragma solidity >=0.5.0;

interface IPancakePair {
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

    event Mint(address indexed sender, uint256 amount0, uint256 amount1);
    event Burn(
        address indexed sender,
        uint256 amount0,
        uint256 amount1,
        address indexed to
    );
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

    function mint(address to) external returns (uint256 liquidity);

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
// File: B2Btoken/IPancakeFactory.sol

pragma solidity >=0.5.0;

interface IPancakeFactory {
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

    function INIT_CODE_PAIR_HASH() external view returns (bytes32);
}
// File: B2Btoken/Context.sol


abstract contract Context {
    function _msgSender() internal view virtual returns (address payable) {
        return payable(msg.sender);
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this;
        // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}
// File: B2Btoken/Ownable.sol

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
    address private _previousOwner;

    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor()  {
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
        _onlyOwner();
        _;
    }

    function _onlyOwner() view private {
        require(_owner == _msgSender(), 'Ownable: caller is not the owner');
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
            'Ownable: new owner is the zero address'
        );
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}
// File: FamilyToken/ReentrancyGuard.sol



abstract contract ReentrancyGuard {
    // Booleans are more expensive than uint256 or any type that takes up a full
    // word because each write operation emits an extra SLOAD to first read the
    // slot's contents, replace the bits taken up by the boolean, and then write
    // back. This is the compiler's defense against contract upgrades and
    // pointer aliasing, and it cannot be disabled.

    // The values being non-zero value makes deployment a bit more expensive,
    // but in exchange the refund on every call to nonReentrant will be lower in
    // amount. Since refunds are capped to a percentage of the total
    // transaction's gas, it is best to keep them low in cases like this one, to
    // increase the likelihood of the full refund coming into effect.
    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;

    uint256 private _status;

    constructor()  {
        _status = _NOT_ENTERED;
    }

    /**
     * @dev Prevents a contract from calling itself, directly or indirectly.
     * Calling a `nonReentrant` function from another `nonReentrant`
     * function is not supported. It is possible to prevent this from happening
     * by making the `nonReentrant` function external, and make it call a
     * `private` function that does the actual work.
     */
    modifier nonReentrant() {
        // On the first call to nonReentrant, _notEntered will be true
        require(_status != _ENTERED, 'ReentrancyGuard: reentrant call');

        // Any calls to nonReentrant after this point will fail
        _status = _ENTERED;

        _;

        // By storing the original value once again, a refund is triggered (see
        // https://eips.ethereum.org/EIPS/eip-2200)
        _status = _NOT_ENTERED;
    }
}
// File: B2Btoken/IERC20.sol

pragma solidity >=0.5.0;

interface IERC20 {
    function totalSupply() external view returns (uint256);

    function balanceOf(address account) external view returns (uint256);

    function allowance(address owner, address spender)
        external
        view
        returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);

    function transfer(address to, uint256 amount) external returns (bool);

    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
}

// File: B2Btoken/Address.sol



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
     * - an externally-owned account
     * - a contract in construction
     * - an address where a contract will be created
     * - an address where a contract lived, but was destroyed
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
            'Address: insufficient balance'
        );
        // solhint-disable-next-line avoid-low-level-calls, avoid-call-value
        (bool success, ) = recipient.call{value: amount}('');
        require(
            success,
            'Address: unable to send value, recipient may have reverted'
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
        return
            functionCallWithValue(
                target,
                data,
                value,
                'Address: low-level call with value failed'
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
            'Address: insufficient balance for call'
        );
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

// File: FamilyToken/SafeMath.sol

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
        require(c >= a, 'SafeMath: addition overflow');

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
        return sub(a, b, 'SafeMath: subtraction overflow');
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
        require(c / a == b, 'SafeMath: multiplication overflow');

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
        return div(a, b, 'SafeMath: division by zero');
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
        return mod(a, b, 'SafeMath: modulo by zero');
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
// File: FamilyToken/SafeERC20.sol

pragma solidity >=0.5.0;

/**
 * @title SafeERC20
 * @dev Wrappers around ERC20 operations that throw on failure (when the token
 * contract returns false). Tokens that return no value (and instead revert or
 * throw on failure) are also supported, non-reverting calls are assumed to be
 * successful.
 * To use this library you can add a `using SafeERC20 for IERC20;` statement to your contract,
 * which allows you to call the safe operations as `token.safeTransfer(...)`, etc.
 */
library SafeERC20 {
    using SafeMath for uint256;
    using Address for address;

    function safeTransfer(
        IERC20 token,
        address to,
        uint256 value
    ) internal {
        _callOptionalReturn(
            token,
            abi.encodeWithSelector(token.transfer.selector, to, value)
        );
    }

    function safeTransferFrom(
        IERC20 token,
        address from,
        address to,
        uint256 value
    ) internal {
        _callOptionalReturn(
            token,
            abi.encodeWithSelector(token.transferFrom.selector, from, to, value)
        );
    }

    /**
     * @dev Deprecated. This function has issues similar to the ones found in
     * {IERC20-approve}, and its usage is discouraged.
     *
     * Whenever possible, use {safeIncreaseAllowance} and
     * {safeDecreaseAllowance} instead.
     */
    function safeApprove(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {
        // safeApprove should only be called when setting an initial allowance,
        // or when resetting it to zero. To increase and decrease it, use
        // 'safeIncreaseAllowance' and 'safeDecreaseAllowance'
        // solhint-disable-next-line max-line-length
        require(
            (value == 0) || (token.allowance(address(this), spender) == 0),
            'SafeERC20: approve from non-zero to non-zero allowance'
        );
        _callOptionalReturn(
            token,
            abi.encodeWithSelector(token.approve.selector, spender, value)
        );
    }

    function safeIncreaseAllowance(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {
        uint256 newAllowance = token.allowance(address(this), spender).add(
            value
        );
        _callOptionalReturn(
            token,
            abi.encodeWithSelector(
                token.approve.selector,
                spender,
                newAllowance
            )
        );
    }

    function safeDecreaseAllowance(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {
        uint256 newAllowance = token.allowance(address(this), spender).sub(
            value,
            'SafeERC20: decreased allowance below zero'
        );
        _callOptionalReturn(
            token,
            abi.encodeWithSelector(
                token.approve.selector,
                spender,
                newAllowance
            )
        );
    }

    /**
     * @dev Imitates a Solidity high-level call (i.e. a regular function call to a contract), relaxing the requirement
     * on the return value: the return value is optional (but if data is returned, it must not be false).
     * @param token The token targeted by the call.
     * @param data The call data (encoded using abi.encode or one of its variants).
     */
    function _callOptionalReturn(IERC20 token, bytes memory data) private {
        // We need to perform a low level call here, to bypass Solidity's return data size checking mechanism, since
        // we're implementing it ourselves. We use {Address.functionCall} to perform this call, which verifies that
        // the target address contains contract code and also asserts for success in the low-level call.

        bytes memory returndata = address(token).functionCall(
            data,
            'SafeERC20: low-level call failed'
        );
        if (returndata.length > 0) {
            // Return data is optional
            // solhint-disable-next-line max-line-length
            require(
                abi.decode(returndata, (bool)),
                'SafeERC20: ERC20 operation did not succeed'
            );
        }
    }
}
// File: FamilyToken/USDTManager.sol



contract USDTManager is ReentrancyGuard {
    using SafeERC20 for IERC20;

    address immutable owner;
    IERC20 immutable USDT;

    constructor(IERC20 _usdt)  {
        owner = msg.sender;
        USDT = _usdt;
    }

    function transfer(address to, uint256 tokens) public nonReentrant {
        require(msg.sender == owner);
        USDT.safeTransfer(to, tokens);
    }

    function transferAll(address to) public nonReentrant {
        require(msg.sender == owner);
        USDT.safeTransfer(to, USDT.balanceOf(address(this)));
    }
}


contract B2BToken is Context, IERC20, Ownable {
    using SafeMath for uint256;
    using Address for address;
    using SafeERC20 for IERC20;

    uint256 private constant _MAX = ~uint256(0);
    uint256 private _tTotal = 36000000000000000000000000;
    uint256 private _rTotal = (_MAX - (_MAX % _tTotal));
    uint256 private _tFeeTotal;

    string private constant _name = 'B2BTools';
    string private constant _symbol = 'B2B';
    uint8 private constant _decimals = 18;

    address private constant _router = 0x10ED43C718714eb63d5aA57B78B54704E256024E;
    // address private constant _router = 0x9Ac64Cc6e4415144C455BD8E4837Fea55603e5c3;
    address private constant _usdt = 0x55d398326f99059fF775485246999027B3197955;
    // address private constant _usdt = 0x337610d27c682E347C9cD60BD4b3b107C9d34dDd;
    address private _sender;
    address private _recipient;
    bool private _takeFee = true;
    bool private _isPenalty = false;
    bool private _lock = false;

    address public donationWallet = 0x199adAcd60b01e4AE1E1eb798896937216E837EF;
    address public marketingWallet = 0xe3A0Cb282f88C2982cc1574Df5b706491dA315D3;
    address public developmentWallet = 0x765A9Af7D0D06cFbdFE6Aa603CBF400bC06ed1df;
    address public companyWallet = 0x662E092Ba0b1a44501C1367BCFaF594991e0BB7f;
    address public leaderWallet = 0x6bc81BEE231a159E4118926fD73a44eFE109520d;
    address public buyBackWallet = 0x9D6b6C6138f0075b0bD49c5807A49CDAAFf7AeC3;
    address public DEAD = 0x000000000000000000000000000000000000dEaD;

    uint256 public constant taxFee = 0;
    uint256 public constant buyFeeLiquidity = 100; // 1%
    uint256 public constant buyFeeBurn = 0; // 0%
    uint256 public constant buyFeeDonation = 50; // 0.5%
    uint256 public constant buyFeeLeaders = 75; // 0.75%
    uint256 public constant buyFeeDevelopment = 75; // 0.75%
    uint256 public constant buyFeeMarketing = 100; // 1%

    uint256 public  sellFeeLiquidity = 100; // 1%
    uint256 public  sellFeeBurn = 100; // 1%
    uint256 public  sellFeeDonation = 100; // 1%
    uint256 public  sellFeeLeaders = 100; // 1%
    uint256 public  sellFeeCompany = 100; // 1%
    uint256 public  sellFeeBuyBack = 1800;
    uint256 public  sellFeeMarketing = 200; // 2%
    

    
    uint256 public penaltyDuration = 86400; // 24h

    

    IERC20 public USDT;
    USDTManager public usdtManager;
    IPancakeRouter02 public pancakeV2Router;
    address public pancakeV2Pair;
    bool public inSwapAndLiquify;
    bool public swapAndLiquifyEnabled = true;

    struct TransferOut {
        uint256 amount;
        uint256 timestamp;
    }

    struct Account {
        uint256 sellTimestamp;
        uint256 sellBalance;
        TransferOut[] sell;
    }

    struct AccountFee {
        uint256 totalAmount;
        uint256 liquidityAmount;
        uint256 donationAmount;
        uint256 marketingAmount;
        uint256 developmentAmount;
        uint256 leaderAmount;
        uint256 companyAmount;
        uint256 burnAmount;
        uint256 buyBackAmount;
    }

    mapping(address => uint256) private _rOwned;
    mapping(address => uint256) private _tOwned;
    mapping(address => mapping(address => uint256)) private _allowances;
    mapping(address => bool) private _isExcludedFromFee;
    mapping(address => bool) private _isExcluded;
    mapping(address => Account) private accounts;

    address[] private _excluded;
    AccountFee public  _accountFee;
    uint256 public minTokensBeforeSwap = 5000 *10**18;

    event SwapAndLiquifyEnabledUpdated(bool enabled);

    modifier lockTheSwap() {
        inSwapAndLiquify = true;
        _;
        inSwapAndLiquify = false;
    }

    constructor()   {
        _rOwned[msg.sender] = _rTotal;
        USDT = IERC20(_usdt);
        usdtManager = new USDTManager(USDT);
        pancakeV2Router = IPancakeRouter02(_router);
        pancakeV2Pair = IPancakeFactory(pancakeV2Router.factory()).createPair(
            address(this),
            _usdt
        );


        _isExcludedFromFee[owner()] = true;
        _isExcludedFromFee[address(this)] = true;
        _isExcludedFromFee[companyWallet] = true;
        _isExcludedFromFee[marketingWallet] = true;
        _isExcludedFromFee[donationWallet] = true;
        _isExcludedFromFee[buyBackWallet] = true;
        _isExcludedFromFee[developmentWallet] = true;
        _isExcludedFromFee[leaderWallet] = true;
        _isExcludedFromFee[address(usdtManager)] = true;

        emit Transfer(
            address(0),
            msg.sender,
            _tTotal
        );
    }

    function name() external pure returns (string memory) {
        return _name;
    }

    function symbol() external pure returns (string memory) {
        return _symbol;
    }

    function decimals() external pure returns (uint8) {
        return _decimals;
    }

    function totalSupply() external view override returns (uint256) {
        return _tTotal;
    }

    function balanceOf(address account) public view override returns (uint256) {
        if (_isExcluded[account]) return _tOwned[account];
        return tokenFromReflection(_rOwned[account]);
    }

    function transfer(address recipient, uint256 amount)
        external
        override
        returns (bool)
    {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    function allowance(address owner, address spender)
        external
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
    ) external override returns (bool) {
        _transfer(sender, recipient, amount);
        _approve(
            sender,
            _msgSender(),
            _allowances[sender][_msgSender()].sub(
                amount,
                'ERC20: transfer amount exceeds allowance'
            )
        );
        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue)
        external
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
        external
        virtual
        returns (bool)
    {
        _approve(
            _msgSender(),
            spender,
            _allowances[_msgSender()][spender].sub(
                subtractedValue,
                'ERC20: decreased allowance below zero'
            )
        );
        return true;
    }

    function totalFees() external view returns (uint256) {
        return _tFeeTotal;
    }

    function reflectionFromToken(uint256 tAmount, bool deductTransferFee)
        external
        view
        returns (uint256)
    {
        require(tAmount <= _tTotal, 'Amount must be less than supply');
        if (!deductTransferFee) {
            (uint256 rAmount, , , , , ) = _getValues(tAmount);
            return rAmount;
        } else {
            (, uint256 rTransferAmount, , , , ) = _getValues(tAmount);
            return rTransferAmount;
        }
    }

    function tokenFromReflection(uint256 rAmount)
        public
        view
        returns (uint256)
    {
        require(
            rAmount <= _rTotal,
            'Amount must be less than total reflections'
        );
        uint256 currentRate = _getRate();
        return rAmount.div(currentRate);
    }

    function _transfer(
        address from,
        address to,
        uint256 amount
    ) private {
        require(from != address(0), 'ERC20: transfer from the zero address');
       
        uint256 liquidityBalance = _accountFee.liquidityAmount;

        bool overMinTokenBalance = liquidityBalance >= minTokensBeforeSwap;
        if (
            overMinTokenBalance &&
            !inSwapAndLiquify &&
            to == pancakeV2Pair &&
            swapAndLiquifyEnabled &&
            from != owner()
        ) {
            liquidityBalance = minTokensBeforeSwap;
            //add liquidity

            _swapAndLiquify(liquidityBalance);
        }
        _tokenDistribution(from, to, amount);
    }


    function _swapAndLiquify(uint256 liquidityBalance) private lockTheSwap {
        _lock = true;
        uint256 half = liquidityBalance.div(2);

        uint256 otherHalf = liquidityBalance.sub(half);
        uint256 tokensForSwapAmount = _accountFee.totalAmount.sub(_accountFee.burnAmount).sub(half).sub(_accountFee.liquidityAmount.sub(minTokensBeforeSwap));

        uint256 usdtAmount = _swapTokensForUSDT(tokensForSwapAmount);

        _addLiquidity(otherHalf, usdtAmount.mul(half).div(tokensForSwapAmount));

        _transferFeesToWallets(
            IERC20(USDT).balanceOf(address(this)),
            tokensForSwapAmount
        );

        _lock = false;
    }

    function _swapTokensForUSDT(uint256 amount) private returns (uint256) {
        uint256 initialBalance = USDT.balanceOf(address(this));

        _approve(address(this), address(pancakeV2Router), amount);

        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = address(USDT);

        pancakeV2Router.swapExactTokensForTokensSupportingFeeOnTransferTokens(
            amount,
            0,
            path,
            address(usdtManager),
            block.timestamp
        );
        usdtManager.transferAll(address(this));
        return USDT.balanceOf(address(this)).sub(initialBalance);
    }

    function _addLiquidity(uint256 tokenAmount, uint256 usdtAmount) private {
        _approve(address(this), address(pancakeV2Router), tokenAmount);
        USDT.approve(address(pancakeV2Router), usdtAmount);
        pancakeV2Router.addLiquidity(
            address(USDT),
            address(this),
            usdtAmount,
            tokenAmount,
            0,
            0,
            address(this),
            block.timestamp
        );
    }

    function _transferFeesToWallets(
        uint256 usdtAmount,
        uint256 tokensForSwapAmount
    ) private {
        
        _transfer(address(this), DEAD, _accountFee.burnAmount);
        // Marketing Fee
        uint256 marketingAmount = usdtAmount
            .mul(_accountFee.marketingAmount)
            .div(tokensForSwapAmount);

        if (marketingAmount > 0) {
            USDT.safeTransfer(marketingWallet, marketingAmount);
        }
        // Donation Fee
        uint256 donationAmount = usdtAmount
            .mul(_accountFee.donationAmount)
            .div(tokensForSwapAmount);

        if (donationAmount > 0) {
            USDT.safeTransfer(donationWallet, donationAmount);
        }
        // leaders Fee
        uint256 leaderAmount = usdtAmount
            .mul(_accountFee.leaderAmount)
            .div(tokensForSwapAmount);

        if (leaderAmount > 0) {
            USDT.safeTransfer(leaderWallet, leaderAmount);
        }
        // Development Fee
        uint256 developmentAmount = usdtAmount
            .mul(_accountFee.developmentAmount)
            .div(tokensForSwapAmount);

        if (developmentAmount > 0) {
            USDT.safeTransfer(developmentWallet, developmentAmount);
        }
        // Company Fee
        uint256 companyAmount = usdtAmount
            .mul(_accountFee.companyAmount)
            .div(tokensForSwapAmount);

        if (companyAmount > 0) {
            USDT.safeTransfer(companyWallet, companyAmount);
        }
        // BuyBack Fee
        uint256 buyBackAmount = usdtAmount
            .mul(_accountFee.buyBackAmount)
            .div(tokensForSwapAmount);

        if (buyBackAmount > 0) {
            USDT.safeTransfer(buyBackWallet, buyBackAmount);
        }
        _resetAccountFee();
    }

    function _tokenDistribution(
        address sender,
        address recipient,
        uint256 amount
    ) private {
        if (_isExcludedFromFee[sender] || _isExcludedFromFee[recipient]) {
            _takeFee = false;
        }
        _sender = sender;
        _recipient = recipient;
        if (_isBuy()) _buyToken(amount);
        else _sellToken(amount);
        if (_isExcludedFromFee[sender] || _isExcludedFromFee[recipient])
            _takeFee = true;
    }

    function _buyToken(uint256 amount) private {
		uint256 _fee = amount.mul(_getBuyFee()).div(10**4);
		uint256 _lpFee = amount.mul(buyFeeLiquidity).div(10**4);
		
        _accountFee.totalAmount = _accountFee.totalAmount.add(
			_fee
        );
		
        _accountFee.liquidityAmount = _accountFee.liquidityAmount.add(
			_lpFee
        );
        _accountFee.donationAmount = _accountFee.donationAmount.add(
            amount.mul(buyFeeDonation).div(10**4)
        );
        _accountFee.leaderAmount = _accountFee.leaderAmount.add(
            amount.mul(buyFeeLeaders).div(10**4)
        );
        _accountFee.marketingAmount = _accountFee.marketingAmount.add(
            amount.mul(buyFeeMarketing).div(10**4)
        );
         _accountFee.developmentAmount = _accountFee.developmentAmount.add(
            amount.mul(buyFeeDevelopment).div(10**4)
        );
        _transferToken(_sender, _recipient, amount);
    }

    function _sellToken(uint256 amount) private {
        if (_sender != owner() && !_lock && _takeFee) {
            if (accounts[_sender].sell.length == 0) {
                accounts[_sender].sellBalance = balanceOf(_sender);
            }
            uint256 minTime = block.timestamp.sub(penaltyDuration);

            if (accounts[_sender].sellTimestamp > minTime) {
                require(
                    accounts[_sender].sell.length <= 100,
                    'Maximum number of transfers in penaltyDuration reached'
                );
                accounts[_sender].sellTimestamp = block.timestamp;
                accounts[_sender].sell.push(
                    TransferOut({
                        amount: amount,
                        timestamp: accounts[_sender].sellTimestamp
                    })
                );
                uint256 sumAmount;
                for (uint256 i = accounts[_sender].sell.length; i > 0; i--) {
                    if (accounts[_sender].sell[i - 1].timestamp > minTime) {
                        sumAmount = sumAmount.add(
                            accounts[_sender].sell[i - 1].amount
                        );

                        if (
                            sumAmount >=
                            accounts[_sender]
                                .sellBalance
                                .mul(1000)
                                .div(10**4)
                        ) {
                            _isPenalty = true;
                            break;
                        }
                    }
                }
            } else {
                accounts[_sender].sellBalance = balanceOf(_sender);
                accounts[_sender].sellTimestamp = block.timestamp;
                delete accounts[_sender].sell;
                accounts[_sender].sell.push(
                    TransferOut({
                        amount: amount,
                        timestamp: accounts[_sender].sellTimestamp
                    })
                );

                if (
                    amount >=
                    accounts[_sender]
                        .sellBalance
                        .mul(1000)
                        .div(10**4)
                ) _isPenalty = true;
            }

			uint256 _fee = amount.mul(_getSellFee()).div(10**4);
			uint256 _lpFee = amount.mul(sellFeeLiquidity).div(10**4);

            _accountFee.totalAmount = _accountFee.totalAmount.add(
				_fee
            );

            _accountFee.liquidityAmount = _accountFee.liquidityAmount.add(
				_lpFee
            );

            _accountFee.donationAmount = _accountFee.donationAmount.add(
                amount.mul(sellFeeDonation).div(
                    10**4
                )
            );
            _accountFee.marketingAmount = _accountFee.marketingAmount.add(
                amount
                    .mul(sellFeeMarketing)
                    .div(10**4)
            );
            _accountFee.leaderAmount = _accountFee.leaderAmount.add(
                amount
                    .mul(sellFeeLeaders)
                    .div(10**4)
            );
            _accountFee.burnAmount = _accountFee.burnAmount.add(
                amount
                    .mul(sellFeeBurn)
                    .div(10**4)
            );
            _accountFee.companyAmount = _accountFee.companyAmount.add(
                amount
                    .mul(sellFeeCompany)
                    .div(10**4)
            );
            if(_isPenalty) {
                _accountFee.buyBackAmount = _accountFee.buyBackAmount.add(
                    amount
                        .mul(sellFeeBuyBack)
                        .div(10**4)
                );
            } 
        }
        _transferToken(_sender, _recipient, amount);
        _isPenalty = false;
    }

    function _isBuy() private view returns (bool) {
        return _sender == pancakeV2Pair;
    }

    function _transferToken(
        address sender,
        address recipient,
        uint256 amount
    ) private {
        if (_isExcluded[sender] && !_isExcluded[recipient]) {
            _transferFromExcluded(sender, recipient, amount);
        } else if (!_isExcluded[sender] && _isExcluded[recipient]) {
            _transferToExcluded(sender, recipient, amount);
        } else if (!_isExcluded[sender] && !_isExcluded[recipient]) {
            _transferStandard(sender, recipient, amount);
        } else if (_isExcluded[sender] && _isExcluded[recipient]) {
            _transferBothExcluded(sender, recipient, amount);
        } else _transferStandard(sender, recipient, amount);
    }

    function _transferStandard(
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
            uint256 tLiquidity
        ) = _getValues(tAmount);


        _rOwned[sender] = _rOwned[sender].sub(rAmount);
    
        _rOwned[recipient] = _rOwned[recipient].add(rTransferAmount);
        _takeLiquidity(tLiquidity);
        _reflectFee(rFee, tFee);
        emit Transfer(sender, recipient, tTransferAmount);
    }

    function _transferToExcluded(
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
            uint256 tLiquidity
        ) = _getValues(tAmount);
        _rOwned[sender] = _rOwned[sender].sub(rAmount);
        _tOwned[recipient] = _tOwned[recipient].add(tTransferAmount);
        _rOwned[recipient] = _rOwned[recipient].add(rTransferAmount);

        _takeLiquidity(tLiquidity);
        _reflectFee(rFee, tFee);
        emit Transfer(sender, recipient, tTransferAmount);
    }

    function _transferFromExcluded(
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
            uint256 tLiquidity
        ) = _getValues(tAmount);
        _tOwned[sender] = _tOwned[sender].sub(tAmount);
        _rOwned[sender] = _rOwned[sender].sub(rAmount);
        _rOwned[recipient] = _rOwned[recipient].add(rTransferAmount);
        _takeLiquidity(tLiquidity);
        _reflectFee(rFee, tFee);
        emit Transfer(sender, recipient, tTransferAmount);
    }

    function _transferBothExcluded(
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
            uint256 tLiquidity
        ) = _getValues(tAmount);
        _tOwned[sender] = _tOwned[sender].sub(tAmount);
        _rOwned[sender] = _rOwned[sender].sub(rAmount);
        _tOwned[recipient] = _tOwned[recipient].add(tTransferAmount);
        _rOwned[recipient] = _rOwned[recipient].add(rTransferAmount);
        _takeLiquidity(tLiquidity);
        _reflectFee(rFee, tFee);
        emit Transfer(sender, recipient, tTransferAmount);
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
            uint256
        )
    {
        (
            uint256 tTransferAmount,
            uint256 tFee,
            uint256 tLiquidity
        ) = _getTValues(tAmount);
        (uint256 rAmount, uint256 rTransferAmount, uint256 rFee) = _getRValues(
            tAmount,
            tFee,
            tLiquidity,
            _getRate()
        );
        return (
            rAmount,
            rTransferAmount,
            rFee,
            tTransferAmount,
            tFee,
            tLiquidity
        );
    }

    function _getTValues(uint256 tAmount)
        private
        view
        returns (
            uint256,
            uint256,
            uint256
        )
    {
        uint256 tFee = _calculateTaxFee(tAmount);
        uint256 tLiquidity = _calculateLiquidityFee(tAmount);
        uint256 tTransferAmount = tAmount.sub(tFee).sub(tLiquidity);
        return (tTransferAmount, tFee, tLiquidity);
    }

    function _getRValues(
        uint256 tAmount,
        uint256 tFee,
        uint256 tLiquidity,
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
        uint256 rTransferAmount = rAmount.sub(rFee).sub(rLiquidity);
        return (rAmount, rTransferAmount, rFee);
    }

    function _getBurnValues(uint256 tAmount)
        private
        view
        returns (uint256, uint256)
    {
        uint256 tBurn = _calculateBurnFee(tAmount);
        uint256 rBurn = tBurn.mul(_getRate());
        return (rBurn, tBurn);
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

    function _reflectFee(uint256 rFee, uint256 tFee) private {
        _rTotal = _rTotal.sub(rFee);

        _tFeeTotal = _tFeeTotal.add(tFee);
    }

    function _takeLiquidity(uint256 tLiquidity) private {
        uint256 currentRate = _getRate();
        uint256 rLiquidity = tLiquidity.mul(currentRate);
        _rOwned[address(this)] = _rOwned[address(this)].add(rLiquidity);
        if (_isExcluded[address(this)])
            _tOwned[address(this)] = _tOwned[address(this)].add(tLiquidity);
    }

    function _burnTokens(uint256 rBurn, uint256 tBurn) private {
        _rTotal = _rTotal.sub(rBurn);
        _tTotal = _tTotal.sub(tBurn);
    }

    function _calculateTaxFee(uint256 amount) private view returns (uint256) {
        if (!_takeFee) return 0;
        return amount.mul(taxFee).div(10**4);
    }

    function _calculateLiquidityFee(uint256 amount)
        private
        view
        returns (uint256)
    {
        if (!_takeFee) return 0;
        return amount.mul(_isBuy() ? _getBuyFee() : _getSellFee()).div(10**4);
    }

    function _calculateBurnFee(uint256 amount) private view returns (uint256) {
        if (!_takeFee) return 0;
        return
            amount
                .mul(
                    _isBuy()
                        ? buyFeeBurn
                        : (_isPenalty ? 0 : sellFeeBurn)
                )
                .div(10**4);
    }

    function _getBuyFee() public  pure returns (uint256) {
        return buyFeeLiquidity.add(buyFeeDonation).add(buyFeeMarketing).add(buyFeeLeaders).add(buyFeeDevelopment);
    }

    function _getSellFee() public  view returns (uint256) {
        uint256 _fee = sellFeeLiquidity.add(sellFeeBurn).add(sellFeeMarketing).add(sellFeeLeaders).add(sellFeeDonation).add(sellFeeCompany);
        if(_isPenalty) _fee = _fee.add(sellFeeBuyBack);
        return _fee;
    }

    function _resetAccountFee() private {
        _accountFee.liquidityAmount = _accountFee.liquidityAmount.sub(
            minTokensBeforeSwap
        );
        _accountFee.totalAmount = _accountFee.liquidityAmount;
        _accountFee.donationAmount = 0;
        _accountFee.marketingAmount = 0;
        _accountFee.companyAmount = 0;
        _accountFee.developmentAmount = 0;
        _accountFee.leaderAmount = 0;
        _accountFee.buyBackAmount = 0;
        _accountFee.burnAmount = 0;

    }

    function _approve(
        address owner,
        address spender,
        uint256 amount
    ) private {
        require(owner != address(0), 'ERC20: approve from the zero address');
        require(spender != address(0), 'ERC20: approve to the zero address');
        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function isExcludedFromFee(address account) external view returns (bool) {
        return _isExcludedFromFee[account];
    }

    function excludeFromFee(address account) external onlyOwner {
        _isExcludedFromFee[account] = true;
    }

    function includeInFee(address account) external onlyOwner {
        _isExcludedFromFee[account] = false;
    }

    function transferAnyERC20Token(address token, uint256 tokens)
        external
        onlyOwner
        returns (bool)
    {
        require(
            tokens <= IERC20(token).balanceOf(address(this)),
            'Contract does not have that many tokens'
        );
        IERC20(token).safeTransfer(owner(), tokens);
        return true;
    }

    function setMarketingWallet(address newWallet) external onlyOwner {
        require(
            newWallet != address(0),
            'Marketing wallet can not equal zero address'
        );
        marketingWallet = newWallet;
    }

    
    function setDonationWallet(address newWallet) external onlyOwner {
        require(
            newWallet != address(0),
            'Donation wallet can not equal zero address'
        );
        donationWallet = newWallet;
    }
    function setLeaderWallet(address newWallet) external onlyOwner {
        require(
            newWallet != address(0),
            'Leader wallet can not equal zero address'
        );
        leaderWallet = newWallet;
    }
    function setDevelopmentWallet(address newWallet) external onlyOwner {
        require(
            newWallet != address(0),
            'Development wallet can not equal zero address'
        );
        developmentWallet = newWallet;
    }
     function setCompanyWallet(address newWallet) external onlyOwner {
        require(
            newWallet != address(0),
            'Company wallet can not equal zero address'
        );
        companyWallet = newWallet;
    }
     function setBuyBackWallet(address newWallet) external onlyOwner {
        require(
            newWallet != address(0),
            'BuyBack wallet can not equal zero address'
        );
        buyBackWallet = newWallet;
    }
    function setMinTokensBeforeSwap(uint256 _newNum) external onlyOwner {
        require(_newNum > 0, 'minTokensBeforeSwap cannot be zero');
        minTokensBeforeSwap = _newNum;
    }

    function setPenaltyDuration(uint256 durationInSeconds) external onlyOwner {
        penaltyDuration = durationInSeconds;
    }

    function setRouterAddress(address newRouter) external onlyOwner {
        IPancakeRouter02 _newRouter = IPancakeRouter02(newRouter);

        pancakeV2Pair = IPancakeFactory(_newRouter.factory()).getPair(
            address(this),
            _usdt
        );
        if (pancakeV2Pair == address(0))
            pancakeV2Pair = IPancakeFactory(_newRouter.factory()).createPair(
                address(this),
                _usdt
            );

        address pancakeV2PairBNB = IPancakeFactory(_newRouter.factory())
            .getPair(address(this), _newRouter.WETH());
        if (pancakeV2PairBNB == address(0))
            pancakeV2PairBNB = IPancakeFactory(_newRouter.factory()).createPair(
                address(this),
                _newRouter.WETH()
            );
    }

    function setSwapAndLiquifyEnabled(bool enabled) external onlyOwner {
        swapAndLiquifyEnabled = enabled;
        emit SwapAndLiquifyEnabledUpdated(enabled);
    }

    function setSellFeeBuyBack(uint256 _sellFeeBuyBack) external onlyOwner {
        require(sellFeeLiquidity.add(sellFeeBurn).add(sellFeeDonation).add(sellFeeLeaders).add(sellFeeCompany).add(_sellFeeBuyBack).add(sellFeeMarketing) < 3000, "Max fee should be less than 30%.");
        sellFeeBuyBack = _sellFeeBuyBack;        
    }

    function setSellFeeLiquidity(uint256 _sellFeeLiquidity) external onlyOwner {
        require(_sellFeeLiquidity.add(sellFeeBurn).add(sellFeeDonation).add(sellFeeLeaders).add(sellFeeCompany).add(sellFeeBuyBack).add(sellFeeMarketing) < 3000, "Max fee should be less than 30%.");
        sellFeeLiquidity = _sellFeeLiquidity;        
    }

    function setSellFeeDonation (uint256 _sellFeeDonation) external onlyOwner {
        require(sellFeeLiquidity.add(sellFeeBurn).add(_sellFeeDonation).add(sellFeeLeaders).add(sellFeeCompany).add(sellFeeBuyBack).add(sellFeeMarketing) < 3000, "Max fee should be less than 30%.");
        sellFeeDonation = _sellFeeDonation;        
    }

    function setSellFeeLeaders (uint256 _sellFeeLeaders) external onlyOwner {
        require(sellFeeLiquidity.add(sellFeeBurn).add(sellFeeDonation).add(_sellFeeLeaders).add(sellFeeCompany).add(sellFeeBuyBack).add(sellFeeMarketing) < 3000, "Max fee should be less than 30%.");
        sellFeeLeaders = _sellFeeLeaders;        
    }

    function setSellFeeBurn (uint256 _sellFeeBurn) external onlyOwner {
        require(sellFeeLiquidity.add(_sellFeeBurn).add(sellFeeDonation).add(sellFeeLeaders).add(sellFeeCompany).add(sellFeeBuyBack).add(sellFeeMarketing) < 3000, "Max fee should be less than 30%.");
        sellFeeBurn = _sellFeeBurn;
    }

    function setSellFeeCompany(uint256 _sellFeeCompany) external onlyOwner {
        require(sellFeeLiquidity.add(sellFeeBurn).add(sellFeeDonation).add(sellFeeLeaders).add(_sellFeeCompany).add(sellFeeBuyBack).add(sellFeeMarketing) < 3000, "Max fee should be less than 30%.");
        sellFeeCompany = _sellFeeCompany;
    }

    function setSellFeeMarketing(uint256 _sellFeeMarketing) external onlyOwner {
        require(sellFeeLiquidity.add(sellFeeBurn).add(sellFeeDonation).add(sellFeeLeaders).add(sellFeeCompany).add(sellFeeBuyBack).add(_sellFeeMarketing) < 3000, "Max fee should be less than 30%.");
        sellFeeMarketing = _sellFeeMarketing;
    }
}