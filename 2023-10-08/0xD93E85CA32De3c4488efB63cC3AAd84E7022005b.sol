// SPDX-License-Identifier: MIT

pragma solidity 0.6.12;

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
        // This method relies in extcodesize, which returns 0 for contracts in
        // construction, since the code is only stored at the end of the
        // constructor execution.

        uint256 size;
        // solhint-disable-next-line no-inline-assembly
        assembly {
            size := extcodesize(account)
        }
        return size > 0;
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
        require(address(this).balance >= amount, "Address: insufficient balance");

        // solhint-disable-next-line avoid-low-level-calls, avoid-call-value
        (bool success, ) = recipient.call{value: amount}("");
        require(success, "Address: unable to send value, recipient may have reverted");
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
        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
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
        require(address(this).balance >= value, "Address: insufficient balance for call");
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
        _callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function safeTransferFrom(
        IERC20 token,
        address from,
        address to,
        uint256 value
    ) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
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
        require((value == 0) || (token.allowance(address(this), spender) == 0), "SafeERC20: approve from non-zero to non-zero allowance");
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
    }

    function safeIncreaseAllowance(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {
        uint256 newAllowance = token.allowance(address(this), spender).add(value);
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function safeDecreaseAllowance(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {
        uint256 newAllowance = token.allowance(address(this), spender).sub(value, "SafeERC20: decreased allowance below zero");
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
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

        bytes memory returndata = address(token).functionCall(data, "SafeERC20: low-level call failed");
        if (returndata.length > 0) {
            // Return data is optional
            // solhint-disable-next-line max-line-length
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
}

interface IUniswapV2Router {
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

    function getAmountsOut(uint256 amountIn, address[] calldata path) external view returns (uint256[] memory amounts);

    function getAmountsIn(uint256 amountOut, address[] calldata path) external view returns (uint256[] memory amounts);

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

interface Balancer {
    function balanceOf(address account) external view returns (uint256);

    function transfer(address recipient, uint256 amount) external returns (bool);

    function joinPool(uint256 poolAmountOut, uint256[] calldata maxAmountsIn) external;

    function exitPool(uint256 poolAmountIn, uint256[] calldata minAmountsOut) external;

    function swapExactAmountIn(
        address tokenIn,
        uint256 tokenAmountIn,
        address tokenOut,
        uint256 minAmountOut,
        uint256 maxPrice
    ) external returns (uint256 tokenAmountOut, uint256 spotPriceAfter);

    function swapExactAmountOut(
        address tokenIn,
        uint256 maxAmountIn,
        address tokenOut,
        uint256 tokenAmountOut,
        uint256 maxPrice
    ) external returns (uint256 tokenAmountIn, uint256 spotPriceAfter);

    function joinswapExternAmountIn(
        address tokenIn,
        uint256 tokenAmountIn,
        uint256 minPoolAmountOut
    ) external returns (uint256 poolAmountOut);

    function exitswapPoolAmountIn(
        address tokenOut,
        uint256 poolAmountIn,
        uint256 minAmountOut
    ) external returns (uint256 tokenAmountOut);

    function getBalance(address token) external view returns (uint256);

    function totalSupply() external view returns (uint256);

    function getTotalDenormalizedWeight() external view returns (uint256);

    function getNormalizedWeight(address token) external view returns (uint256);

    function getDenormalizedWeight(address token) external view returns (uint256);
}

interface IVSafeVault {
    function cap() external view returns (uint256);

    function getVaultMaster() external view returns (address);

    function balance() external view returns (uint256);

    function token() external view returns (address);

    function available() external view returns (uint256);

    function accept(address _input) external view returns (bool);

    function earn() external;

    function harvest(address reserve, uint256 amount) external;

    function addNewCompound(uint256, uint256) external;

    function withdraw_fee(uint256 _shares) external view returns (uint256);

    function calc_token_amount_deposit(uint256 _amount) external view returns (uint256);

    function calc_token_amount_withdraw(uint256 _shares) external view returns (uint256);

    function getPricePerFullShare() external view returns (uint256);

    function deposit(uint256 _amount, uint256 _min_mint_amount) external returns (uint256);

    function depositFor(
        address _account,
        address _to,
        uint256 _amount,
        uint256 _min_mint_amount
    ) external returns (uint256 _mint_amount);

    function withdraw(uint256 _shares, uint256 _min_output_amount) external returns (uint256);

    function withdrawFor(
        address _account,
        uint256 _shares,
        uint256 _min_output_amount
    ) external returns (uint256 _output_amount);

    function harvestStrategy(address _strategy) external;

    function harvestAllStrategies() external;
}

interface IController {
    function vault() external view returns (IVSafeVault);

    function getStrategyCount() external view returns (uint256);

    function strategies(uint256 _stratId)
        external
        view
        returns (
            address _strategy,
            uint256 _quota,
            uint256 _percent
        );

    function getBestStrategy() external view returns (address _strategy);

    function want() external view returns (address);

    function balanceOf() external view returns (uint256);

    function withdraw_fee(uint256 _amount) external view returns (uint256); // eg. 3CRV => pJar: 0.5% (50/10000)

    function investDisabled() external view returns (bool);

    function withdraw(uint256) external returns (uint256 _withdrawFee);

    function earn(address _token, uint256 _amount) external;

    function harvestStrategy(address _strategy) external;

    function harvestAllStrategies() external;

    function beforeDeposit() external;

    function withdrawFee(uint256) external view returns (uint256); // pJar: 0.5% (50/10000)
}

interface IVaultMaster {
    event UpdateBank(address bank, address vault);
    event UpdateVault(address vault, bool isAdd);
    event UpdateController(address controller, bool isAdd);
    event UpdateStrategy(address strategy, bool isAdd);

    function bank(address) external view returns (address);

    function isVault(address) external view returns (bool);

    function isController(address) external view returns (bool);

    function isStrategy(address) external view returns (bool);

    function slippage(address) external view returns (uint256);

    function convertSlippage(address _input, address _output) external view returns (uint256);

    function reserveFund() external view returns (address);

    function performanceReward() external view returns (address);

    function performanceFee() external view returns (uint256);

    function gasFee() external view returns (uint256);

    function withdrawalProtectionFee() external view returns (uint256);
}

interface IValueLiquidRouter {
    function factory() external view returns (address);

    function controller() external view returns (address);

    function formula() external view returns (address);

    function WETH() external view returns (address);

    function addLiquidity(
        address pair,
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
        address pair,
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

    function swapExactTokensForTokens(
        address tokenIn,
        address tokenOut,
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);

    function swapTokensForExactTokens(
        address tokenIn,
        address tokenOut,
        uint256 amountOut,
        uint256 amountInMax,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);

    function swapExactETHForTokens(
        address tokenOut,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external payable returns (uint256[] memory amounts);

    function swapTokensForExactETH(
        address tokenIn,
        uint256 amountOut,
        uint256 amountInMax,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);

    function swapExactTokensForETH(
        address tokenIn,
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);

    function swapETHForExactTokens(
        address tokenOut,
        uint256 amountOut,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external payable returns (uint256[] memory amounts);

    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        address tokenIn,
        address tokenOut,
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external;

    function swapExactETHForTokensSupportingFeeOnTransferTokens(
        address tokenOut,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external payable;

    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        address tokenIn,
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external;

    function createPair(
        address tokenA,
        address tokenB,
        uint256 amountA,
        uint256 amountB,
        uint32 tokenWeightA,
        uint32 swapFee,
        address to
    ) external returns (uint256 liquidity);

    function createPairETH(
        address token,
        uint256 amountToken,
        uint32 tokenWeight,
        uint32 swapFee,
        address to
    ) external payable returns (uint256 liquidity);

    function removeLiquidity(
        address pair,
        address tokenA,
        address tokenB,
        uint256 liquidity,
        uint256 amountAMin,
        uint256 amountBMin,
        address to,
        uint256 deadline
    ) external returns (uint256 amountA, uint256 amountB);

    function removeLiquidityETH(
        address pair,
        address token,
        uint256 liquidity,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline
    ) external returns (uint256 amountToken, uint256 amountETH);

    function removeLiquidityWithPermit(
        address pair,
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
        address pair,
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

    function removeLiquidityETHSupportingFeeOnTransferTokens(
        address pair,
        address token,
        uint256 liquidity,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline
    ) external returns (uint256 amountETH);

    function removeLiquidityETHWithPermitSupportingFeeOnTransferTokens(
        address pair,
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
}

interface IStrategy {
    event Deposit(address token, uint256 amount);
    event Withdraw(address token, uint256 amount, address to);
    event Harvest(uint256 priceShareBefore, uint256 priceShareAfter, address compoundToken, uint256 compoundBalance, address profitToken, uint256 reserveFundAmount);

    function baseToken() external view returns (address);

    function deposit() external;

    function withdraw(address _asset) external returns (uint256);

    function withdraw(uint256 _amount) external returns (uint256);

    function withdrawToController(uint256 _amount) external;

    function skim() external;

    function harvest(address _mergedStrategy) external;

    function withdrawAll() external returns (uint256);

    function balanceOf() external view returns (uint256);

    function beforeDeposit() external;
}

/*

 A strategy must implement the following calls;

 - deposit()
 - withdraw(address) must exclude any tokens used in the yield - Controller role - withdraw should return to Controller
 - withdraw(uint) - Controller | Vault role - withdraw should always return to vault
 - withdrawAll() - Controller | Vault role - withdraw should always return to vault
 - balanceOf()

 Where possible, strategies must remain as immutable as possible, instead of updating variables, we update the contract by linking it in the controller

*/
abstract contract StrategyBase is IStrategy {
    using SafeERC20 for IERC20;
    using Address for address;
    using SafeMath for uint256;

    IUniswapV2Router public unirouter = IUniswapV2Router(0x05fF2B0DB69458A0750badebc4f9e13aDd608C7F);
    IValueLiquidRouter public vSwaprouter = IValueLiquidRouter(0xb7e19a1188776f32E8C2B790D9ca578F2896Da7C);

    address public override baseToken;
    address public farmingToken;
    address public targetCompoundToken; // farmingToken -> compoundToken -> baseToken
    address public targetProfitToken; // compoundToken -> profit

    address public governance;
    address public timelock = address(0x36fcf1c1525854b2d195F5d03d483f01549e06f2);

    address public controller;
    address public strategist;

    IVSafeVault public vault;
    IVaultMaster public vaultMaster;

    mapping(address => mapping(address => address[])) public uniswapPaths; // [input -> output] => uniswap_path
    mapping(address => mapping(address => address[])) public vSwapPairs; // [input -> output] => vswap pair

    uint256 public performanceFee = 0; //1400 <-> 14.0%
    uint256 public lastHarvestTimeStamp;
    bool internal _initialized = false;

    function initialize(
        address _baseToken,
        address _farmingToken,
        address _controller,
        address _targetCompoundToken,
        address _targetProfitToken
    ) internal {
        baseToken = _baseToken;
        farmingToken = _farmingToken;
        targetCompoundToken = _targetCompoundToken;
        targetProfitToken = _targetProfitToken;
        controller = _controller;
        vault = IController(_controller).vault();
        require(address(vault) != address(0), "!vault");
        vaultMaster = IVaultMaster(vault.getVaultMaster());
        governance = msg.sender;
        strategist = msg.sender;

        if (farmingToken != address(0)) {
            IERC20(farmingToken).approve(address(unirouter), type(uint256).max);
            IERC20(farmingToken).approve(address(vSwaprouter), type(uint256).max);
        }
        if (targetCompoundToken != address(0) && targetCompoundToken != farmingToken) {
            IERC20(targetCompoundToken).approve(address(unirouter), type(uint256).max);
            IERC20(targetCompoundToken).approve(address(vSwaprouter), type(uint256).max);
        }
        if (targetProfitToken != address(0) && targetProfitToken != targetCompoundToken && targetProfitToken != farmingToken) {
            IERC20(targetProfitToken).approve(address(unirouter), type(uint256).max);
            IERC20(targetProfitToken).approve(address(vSwaprouter), type(uint256).max);
        }
    }

    modifier onlyGovernance() {
        require(msg.sender == governance, "!governance");
        _;
    }

    modifier onlyStrategist() {
        require(msg.sender == strategist || msg.sender == governance, "!strategist");
        _;
    }

    modifier onlyAuthorized() {
        require(msg.sender == address(controller) || msg.sender == strategist || msg.sender == governance, "!authorized");
        _;
    }

    function getName() public pure virtual returns (string memory);

    function approveForSpender(
        IERC20 _token,
        address _spender,
        uint256 _amount
    ) external onlyGovernance {
        _token.approve(_spender, _amount);
    }

    function setUnirouter(IUniswapV2Router _unirouter) external onlyGovernance {
        unirouter = _unirouter;
        if (farmingToken != address(0)) {
            IERC20(farmingToken).approve(address(unirouter), type(uint256).max);
        }
        if (targetCompoundToken != address(0) && targetCompoundToken != farmingToken) IERC20(targetCompoundToken).approve(address(unirouter), type(uint256).max);
        if (targetProfitToken != address(0) && targetProfitToken != targetCompoundToken && targetProfitToken != farmingToken) {
            IERC20(targetProfitToken).approve(address(unirouter), type(uint256).max);
        }
    }

    function setVSwaprouter(IValueLiquidRouter _vSwaprouter) external onlyGovernance {
        vSwaprouter = _vSwaprouter;
        if (farmingToken != address(0)) {
            IERC20(farmingToken).approve(address(vSwaprouter), type(uint256).max);
        }
        if (targetCompoundToken != address(0) && targetCompoundToken != farmingToken) IERC20(targetCompoundToken).approve(address(vSwaprouter), type(uint256).max);
        if (targetProfitToken != address(0) && targetProfitToken != targetCompoundToken && targetProfitToken != farmingToken) {
            IERC20(targetProfitToken).approve(address(vSwaprouter), type(uint256).max);
        }
    }

    function setUnirouterPath(
        address _input,
        address _output,
        address[] memory _path
    ) public onlyStrategist {
        uniswapPaths[_input][_output] = _path;
    }

    function setVSwapPairs(
        address _input,
        address _output,
        address[] memory _pair
    ) public onlyStrategist {
        vSwapPairs[_input][_output] = _pair;
    }

    function beforeDeposit() external virtual override onlyAuthorized {}

    function deposit() public virtual override;

    function skim() external override {
        IERC20(baseToken).safeTransfer(controller, IERC20(baseToken).balanceOf(address(this)));
    }

    function withdraw(address _asset) external override onlyAuthorized returns (uint256 balance) {
        require(baseToken != _asset, "lpPair");

        balance = IERC20(_asset).balanceOf(address(this));
        IERC20(_asset).safeTransfer(controller, balance);
        emit Withdraw(_asset, balance, controller);
    }

    function withdrawToController(uint256 _amount) external override onlyAuthorized {
        require(controller != address(0), "!controller"); // additional protection so we don't burn the funds

        uint256 _balance = IERC20(baseToken).balanceOf(address(this));
        if (_balance < _amount) {
            _amount = _withdrawSome(_amount.sub(_balance));
            _amount = _amount.add(_balance);
        }

        IERC20(baseToken).safeTransfer(controller, _amount);
        emit Withdraw(baseToken, _amount, controller);
    }

    function _withdrawSome(uint256 _amount) internal virtual returns (uint256);

    // Withdraw partial funds, normally used with a vault withdrawal
    function withdraw(uint256 _amount) external override onlyAuthorized returns (uint256) {
        uint256 _balance = IERC20(baseToken).balanceOf(address(this));
        if (_balance < _amount) {
            _amount = _withdrawSome(_amount.sub(_balance));
            _amount = _amount.add(_balance);
        }

        IERC20(baseToken).safeTransfer(address(vault), _amount);
        emit Withdraw(baseToken, _amount, address(vault));
        return _amount;
    }

    // Withdraw all funds, normally used when migrating strategies
    function withdrawAll() external override onlyAuthorized returns (uint256 balance) {
        _withdrawAll();
        balance = IERC20(baseToken).balanceOf(address(this));
        IERC20(baseToken).safeTransfer(address(vault), balance);
        emit Withdraw(baseToken, balance, address(vault));
    }

    function _withdrawAll() internal virtual;

    function claimReward() public virtual;

    function _swapTokens(
        address _input,
        address _output,
        uint256 _amount
    ) internal returns (uint256) {
        if (_input == _output) return _amount;
        address[] memory path = vSwapPairs[_input][_output];
        uint256[] memory amounts;
        if (path.length > 0) {
            // use vSwap
            amounts = vSwaprouter.swapExactTokensForTokens(_input, _output, _amount, 1, path, address(this), now.add(1800));
        } else {
            // use Uniswap
            path = uniswapPaths[_input][_output];
            if (path.length == 0) {
                // path: _input -> _output
                path = new address[](2);
                path[0] = _input;
                path[1] = _output;
            }
            amounts = unirouter.swapExactTokensForTokens(_amount, 1, path, address(this), now.add(1800));
        }
        return amounts[amounts.length - 1];
    }

    function _buyWantAndReinvest() internal virtual;

    function harvest(address _mergedStrategy) external virtual override {
        require(msg.sender == controller || msg.sender == strategist || msg.sender == governance, "!authorized");

        uint256 pricePerFullShareBefore = vault.getPricePerFullShare();
        claimReward();
        address _targetCompoundToken = targetCompoundToken;
        {
            address _farmingToken = farmingToken;
            if (_farmingToken != address(0)) {
                uint256 _farmingTokenBal = IERC20(_farmingToken).balanceOf(address(this));
                if (_farmingTokenBal > 0) {
                    _swapTokens(_farmingToken, _targetCompoundToken, _farmingTokenBal);
                }
            }
        }

        uint256 _targetCompoundBal = IERC20(_targetCompoundToken).balanceOf(address(this));

        if (_targetCompoundBal > 0) {
            if (_mergedStrategy != address(0)) {
                require(vaultMaster.isStrategy(_mergedStrategy), "!strategy"); // additional protection so we don't burn the funds
                IERC20(_targetCompoundToken).safeTransfer(_mergedStrategy, _targetCompoundBal); // forward WETH to one strategy and do the profit split all-in-one there (gas saving)
            } else {
                address _reserveFund = vaultMaster.reserveFund();
                address _performanceReward = vaultMaster.performanceReward();
                uint256 _performanceFee = getPerformanceFee();
                uint256 _gasFee = vaultMaster.gasFee();

                uint256 _reserveFundAmount;
                address _targetProfitToken = targetProfitToken;
                if (_performanceFee > 0 && _reserveFund != address(0)) {
                    _reserveFundAmount = _targetCompoundBal.mul(_performanceFee).div(10000);
                    _reserveFundAmount = _swapTokens(_targetCompoundToken, _targetProfitToken, _reserveFundAmount);
                    IERC20(_targetProfitToken).safeTransfer(_reserveFund, _reserveFundAmount);
                }

                if (_gasFee > 0 && _performanceReward != address(0)) {
                    uint256 _amount = _targetCompoundBal.mul(_gasFee).div(10000);
                    _amount = _swapTokens(_targetCompoundToken, _targetProfitToken, _amount);
                    IERC20(_targetProfitToken).safeTransfer(_performanceReward, _amount);
                }

                _buyWantAndReinvest();

                uint256 pricePerFullShareAfter = vault.getPricePerFullShare();
                emit Harvest(pricePerFullShareBefore, pricePerFullShareAfter, _targetCompoundToken, _targetCompoundBal, _targetProfitToken, _reserveFundAmount);
            }
        }

        lastHarvestTimeStamp = block.timestamp;
    }

    // Only allows to earn some extra yield from non-core tokens
    function earnExtra(address _token) public {
        require(msg.sender == address(this) || msg.sender == controller || msg.sender == strategist || msg.sender == governance, "!authorized");
        require(address(_token) != address(baseToken), "token");
        uint256 _amount = IERC20(_token).balanceOf(address(this));
        _swapTokens(_token, targetCompoundToken, _amount);
    }

    function balanceOfPool() public view virtual returns (uint256);

    function balanceOf() public view override returns (uint256) {
        return IERC20(baseToken).balanceOf(address(this)).add(balanceOfPool());
    }

    function claimable_tokens() external view virtual returns (address[] memory, uint256[] memory);

    function claimable_token() external view virtual returns (address, uint256);

    function getTargetFarm() external view virtual returns (address);

    function getTargetPoolId() external view virtual returns (uint256);

    function getPerformanceFee() public view returns (uint256) {
        if (performanceFee > 0) {
            return performanceFee;
        } else {
            return vaultMaster.performanceFee();
        }
    }

    function setGovernance(address _governance) external onlyGovernance {
        governance = _governance;
    }

    function setTimelock(address _timelock) external {
        require(msg.sender == timelock, "!timelock");
        timelock = _timelock;
    }

    function setStrategist(address _strategist) external onlyGovernance {
        strategist = _strategist;
    }

    function setController(address _controller) external {
        require(msg.sender == governance, "!governance");
        controller = _controller;
        vault = IVSafeVault(IController(_controller).vault());
        require(address(vault) != address(0), "!vault");
        vaultMaster = IVaultMaster(vault.getVaultMaster());
    }

    function setPerformanceFee(uint256 _performanceFee) public onlyGovernance {
        performanceFee = _performanceFee;
    }

    function setFarmingToken(address _farmingToken) public onlyStrategist {
        farmingToken = _farmingToken;
    }

    function setTargetCompoundToken(address _targetCompoundToken) public onlyStrategist {
        targetCompoundToken = _targetCompoundToken;
    }

    function setTargetProfitToken(address _targetProfitToken) public onlyStrategist {
        targetProfitToken = _targetProfitToken;
    }

    function setApproveRouterForToken(address _token, uint256 _amount) public onlyStrategist {
        IERC20(_token).approve(address(unirouter), _amount);
        IERC20(_token).approve(address(vSwaprouter), _amount);
    }

    event ExecuteTransaction(address indexed target, uint256 value, string signature, bytes data);

    /**
     * @dev This is from Timelock contract.
     */
    function executeTransaction(
        address target,
        uint256 value,
        string memory signature,
        bytes memory data
    ) public returns (bytes memory) {
        require(msg.sender == timelock, "!timelock");

        bytes memory callData;

        if (bytes(signature).length == 0) {
            callData = data;
        } else {
            callData = abi.encodePacked(bytes4(keccak256(bytes(signature))), data);
        }

        // solium-disable-next-line security/no-call-value
        (bool success, bytes memory returnData) = target.call{value: value}(callData);
        require(success, string(abi.encodePacked(getName(), "::executeTransaction: Transaction execution reverted.")));

        emit ExecuteTransaction(target, value, signature, data);

        return returnData;
    }
}

interface IStakePool {
    function stake(uint256) external;

    function stakeFor(address _account) external;

    function withdraw(uint256) external;

    function exit() external;

    function getReward(uint8 _pid, address _account) external;

    function getAllRewards(address _account) external;

    function claimReward() external;

    function emergencyWithdraw() external;

    function updateReward() external;

    function updateReward(uint8 _pid) external;

    function pendingReward(uint8 _pid, address _account) external view returns (uint256);

    function allowRecoverRewardToken(address _token) external view returns (bool);

    function getRewardPerBlock(uint8 pid) external view returns (uint256);

    function rewardPoolInfoLength() external view returns (uint256);

    function rewardPoolInfo(uint256 index) external view returns (address);

    function unfrozenStakeTime(address _account) external view returns (uint256);

    function version() external view returns (uint256);

    function stakeToken() external view returns (address);

    function getRewardMultiplier(
        uint8 _pid,
        uint256 _from,
        uint256 _to,
        uint256 _rewardPerBlock
    ) external view returns (uint256);

    function getRewardRebase(
        uint8 _pid,
        address _rewardToken,
        uint256 _pendingReward
    ) external view returns (uint256);

    function getUserInfo(uint8 _pid, address _account)
        external
        view
        returns (
            uint256 amount,
            uint256 rewardDebt,
            uint256 accumulatedEarned,
            uint256 lockReward,
            uint256 lockRewardReleased
        );

    function userInfo(address _account) external view returns (uint256 amount);
}

/*

 A strategy must implement the following calls;

 - deposit()
 - withdraw(address) must exclude any tokens used in the yield - Controller role - withdraw should return to Controller
 - withdraw(uint) - Controller | Vault role - withdraw should always return to vault
 - withdrawAll() - Controller | Vault role - withdraw should always return to vault
 - balanceOf()

 Where possible, strategies must remain as immutable as possible, instead of updating variables, we update the contract by linking it in the controller

*/
contract StrategyStakePoolVSwapWeightLp is StrategyBase {
    uint256 public blocksToReleaseCompound = 0; // disable

    address public stakePool;

    address public token0;
    address public token1;
    uint256 public token0Weight; //max 100
    uint256 public token1Weight; //max 100

    // baseToken       = 0xf98313f818c53E40Bd758C5276EF4B434463Bec4 (gvValueBUSD-vSwapLP)
    // farmingToken = 0x0 (dynamic)
    // targetCompound = 0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56 (BUSD)
    // token0 = 0x0610C2d9F6EbC40078cf081e2D1C4252dD50ad15 (gvValue)
    // token1 = 0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56 (BUSD)
    function initialize(
        address _baseToken,
        address _stakePool,
        address _targetCompound,
        address _targetProfit,
        uint256 _token0Weight,
        address _token0,
        address _token1,
        address _controller
    ) public {
        require(_initialized == false, "Strategy: Initialize must be false.");
        initialize(_baseToken, address(0), _controller, _targetCompound, _targetProfit);
        stakePool = _stakePool;
        token0 = _token0;
        token0Weight = _token0Weight;
        token1Weight = 100 - _token0Weight;
        token1 = _token1;

        IERC20(baseToken).approve(stakePool, type(uint256).max);
        if (token0 != farmingToken && token0 != targetCompoundToken) {
            IERC20(token0).approve(address(unirouter), type(uint256).max);
            IERC20(token0).approve(address(vSwaprouter), type(uint256).max);
        }
        if (token1 != farmingToken && token1 != targetCompoundToken && token1 != token0) {
            IERC20(token1).approve(address(unirouter), type(uint256).max);
            IERC20(token1).approve(address(vSwaprouter), type(uint256).max);
        }

        uint256 rewardPoolLength = IStakePool(_stakePool).rewardPoolInfoLength();
        for (uint256 index = 0; index < rewardPoolLength; index++) {
            address _rewardToken = IStakePool(_stakePool).rewardPoolInfo(index);
            IERC20(_rewardToken).approve(address(unirouter), type(uint256).max);
            IERC20(_rewardToken).approve(address(vSwaprouter), type(uint256).max);
        }
        _initialized = true;
    }

    function getName() public pure override returns (string memory) {
        return "StrategyStakePoolVSwapWeightLp";
    }

    function deposit() public override {
        uint256 _baseBal = IERC20(baseToken).balanceOf(address(this));
        if (_baseBal > 0) {
            IStakePool(stakePool).stake(_baseBal);
            emit Deposit(baseToken, _baseBal);
        }
    }

    function _withdrawSome(uint256 _amount) internal override returns (uint256) {
        uint256 _stakedAmount = IStakePool(stakePool).userInfo(address(this));
        if (_amount > _stakedAmount) {
            _amount = _stakedAmount;
        }

        uint256 _before = IERC20(baseToken).balanceOf(address(this));
        IStakePool(stakePool).withdraw(_amount);
        uint256 _after = IERC20(baseToken).balanceOf(address(this));
        _amount = _after.sub(_before);

        return _amount;
    }

    function _withdrawAll() internal override {
        IStakePool(stakePool).exit();
    }

    function claimReward() public override {
        address _stakePool = stakePool;
        IStakePool(_stakePool).claimReward();

        uint256 rewardPoolLength = IStakePool(_stakePool).rewardPoolInfoLength();
        for (uint256 index = 0; index < rewardPoolLength; index++) {
            address _rewardToken = IStakePool(_stakePool).rewardPoolInfo(index);
            uint256 _rewardBal = IERC20(_rewardToken).balanceOf(address(this));
            if (_rewardBal > 0) {
                _swapTokens(_rewardToken, targetCompoundToken, _rewardBal);
            }
        }
    }

    function _buyWantAndReinvest() internal override {
        {
            address _targetCompoundToken = targetCompoundToken;
            uint256 _targetCompoundBal = IERC20(_targetCompoundToken).balanceOf(address(this));
            if (_targetCompoundToken != token0) {
                uint256 _compoundToBuyToken0 = _targetCompoundBal.mul(token0Weight).div(100);
                _swapTokens(_targetCompoundToken, token0, _compoundToBuyToken0);
            }
            if (_targetCompoundToken != token1) {
                uint256 _compoundToBuyToken1 = _targetCompoundBal.mul(token1Weight).div(100);
                _swapTokens(_targetCompoundToken, token1, _compoundToBuyToken1);
            }
        }

        address _baseToken = baseToken;
        uint256 _before = IERC20(_baseToken).balanceOf(address(this));
        _addLiquidity();
        uint256 _after = IERC20(_baseToken).balanceOf(address(this));
        if (_after > 0) {
            if (_after > _before && vaultMaster.isStrategy(address(this))) {
                uint256 _compound = _after.sub(_before);
                vault.addNewCompound(_compound, blocksToReleaseCompound);
            }
            deposit();
        }
    }

    function _addLiquidity() internal {
        address _token0 = token0;
        address _token1 = token1;
        uint256 _amount0 = IERC20(_token0).balanceOf(address(this));
        uint256 _amount1 = IERC20(_token1).balanceOf(address(this));
        if (_amount0 > 0 && _amount1 > 0) {
            IValueLiquidRouter(vSwaprouter).addLiquidity(baseToken, _token0, _token1, _amount0, _amount1, 0, 0, address(this), block.timestamp + 1);
        }
    }

    function balanceOfPool() public view override returns (uint256) {
        uint256 amount = IStakePool(stakePool).userInfo(address(this));
        return amount;
    }

    function claimable_tokens() external view override returns (address[] memory farmToken, uint256[] memory totalDistributedValue) {
        uint256 rewardPoolLength = IStakePool(stakePool).rewardPoolInfoLength();
        farmToken = new address[](rewardPoolLength);
        totalDistributedValue = new uint256[](rewardPoolLength);

        for (uint256 index = 0; index < rewardPoolLength; index++) {
            address _rewardToken = IStakePool(stakePool).rewardPoolInfo(index);
            farmToken[index] = _rewardToken;
            totalDistributedValue[index] = IStakePool(stakePool).pendingReward(uint8(index), address(this));
        }
    }

    function claimable_token() external view override returns (address farmToken, uint256 totalDistributedValue) {
        uint256 rewardPoolLength = IStakePool(stakePool).rewardPoolInfoLength();
        if (rewardPoolLength > 0) {
            address _rewardToken = IStakePool(stakePool).rewardPoolInfo(0);
            farmToken = _rewardToken;
            totalDistributedValue = IStakePool(stakePool).pendingReward(0, address(this));
        }
    }

    function getTargetFarm() external view override returns (address) {
        return stakePool;
    }

    function getTargetPoolId() external view override returns (uint256) {
        return 0;
    }

    /**
     * @dev Function that has to be called as part of strat migration. It sends all the available funds back to the
     * vault, ready to be migrated to the new strat.
     */
    function retireStrat() external onlyStrategist {
        IStakePool(stakePool).emergencyWithdraw();

        uint256 baseBal = IERC20(baseToken).balanceOf(address(this));
        IERC20(baseToken).transfer(address(vault), baseBal);
    }

    function setBlocksToReleaseCompound(uint256 _blocks) external onlyStrategist {
        blocksToReleaseCompound = _blocks;
    }

    function setStakePoolContract(address _stakePool) external onlyStrategist {
        stakePool = _stakePool;
    }

    function setTokenLp(
        address _token0,
        address _token1,
        uint256 _token0Weight
    ) external onlyStrategist {
        token0 = _token0;
        token0Weight = _token0Weight;
        token1Weight = 100 - _token0Weight;
        token1 = _token1;

        if (token0 != farmingToken && token0 != targetCompoundToken) {
            IERC20(token0).approve(address(unirouter), type(uint256).max);
            IERC20(token0).approve(address(vSwaprouter), type(uint256).max);
        }
        if (token1 != farmingToken && token1 != targetCompoundToken && token1 != token0) {
            IERC20(token1).approve(address(unirouter), type(uint256).max);
            IERC20(token1).approve(address(vSwaprouter), type(uint256).max);
        }
    }

    function updateApproveReward() external onlyStrategist {
        uint256 rewardPoolLength = IStakePool(stakePool).rewardPoolInfoLength();
        for (uint256 index = 0; index < rewardPoolLength; index++) {
            address _rewardToken = IStakePool(stakePool).rewardPoolInfo(index);
            IERC20(_rewardToken).approve(address(unirouter), type(uint256).max);
            IERC20(_rewardToken).approve(address(vSwaprouter), type(uint256).max);
        }
    }
}