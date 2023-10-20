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
// OpenZeppelin Contracts (last updated v4.9.0) (token/ERC20/IERC20.sol)

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IERC20 {
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

    /**
     * @dev Returns the amount of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the amount of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Moves `amount` tokens from the caller's account to `to`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address to, uint256 amount) external returns (bool);

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
     * @dev Moves `amount` tokens from `from` to `to` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(address from, address to, uint256 amount) external returns (bool);
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
// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity >=0.5.0;

/// @title Callback for IUniswapV3PoolActions#swap
/// @notice Any contract that calls IUniswapV3PoolActions#swap must implement this interface
interface IUniswapV3SwapCallback {
    /// @notice Called to `msg.sender` after executing a swap via IUniswapV3Pool#swap.
    /// @dev In the implementation you must pay the pool tokens owed for the swap.
    /// The caller of this method must be checked to be a UniswapV3Pool deployed by the canonical UniswapV3Factory.
    /// amount0Delta and amount1Delta can both be 0 if no tokens were swapped.
    /// @param amount0Delta The amount of token0 that was sent (negative) or must be received (positive) by the pool by
    /// the end of the swap. If positive, the callback must send that amount of token0 to the pool.
    /// @param amount1Delta The amount of token1 that was sent (negative) or must be received (positive) by the pool by
    /// the end of the swap. If positive, the callback must send that amount of token1 to the pool.
    /// @param data Any data passed through by the caller via the IUniswapV3PoolActions#swap call
    function uniswapV3SwapCallback(
        int256 amount0Delta,
        int256 amount1Delta,
        bytes calldata data
    ) external;
}
// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity >=0.7.5;
pragma abicoder v2;

import '@uniswap/v3-core/contracts/interfaces/callback/IUniswapV3SwapCallback.sol';

/// @title Router token swapping functionality
/// @notice Functions for swapping tokens via Uniswap V3
interface ISwapRouter is IUniswapV3SwapCallback {
    struct ExactInputSingleParams {
        address tokenIn;
        address tokenOut;
        uint24 fee;
        address recipient;
        uint256 deadline;
        uint256 amountIn;
        uint256 amountOutMinimum;
        uint160 sqrtPriceLimitX96;
    }

    /// @notice Swaps `amountIn` of one token for as much as possible of another token
    /// @param params The parameters necessary for the swap, encoded as `ExactInputSingleParams` in calldata
    /// @return amountOut The amount of the received token
    function exactInputSingle(ExactInputSingleParams calldata params) external payable returns (uint256 amountOut);

    struct ExactInputParams {
        bytes path;
        address recipient;
        uint256 deadline;
        uint256 amountIn;
        uint256 amountOutMinimum;
    }

    /// @notice Swaps `amountIn` of one token for as much as possible of another along the specified path
    /// @param params The parameters necessary for the multi-hop swap, encoded as `ExactInputParams` in calldata
    /// @return amountOut The amount of the received token
    function exactInput(ExactInputParams calldata params) external payable returns (uint256 amountOut);

    struct ExactOutputSingleParams {
        address tokenIn;
        address tokenOut;
        uint24 fee;
        address recipient;
        uint256 deadline;
        uint256 amountOut;
        uint256 amountInMaximum;
        uint160 sqrtPriceLimitX96;
    }

    /// @notice Swaps as little as possible of one token for `amountOut` of another token
    /// @param params The parameters necessary for the swap, encoded as `ExactOutputSingleParams` in calldata
    /// @return amountIn The amount of the input token
    function exactOutputSingle(ExactOutputSingleParams calldata params) external payable returns (uint256 amountIn);

    struct ExactOutputParams {
        bytes path;
        address recipient;
        uint256 deadline;
        uint256 amountOut;
        uint256 amountInMaximum;
    }

    /// @notice Swaps as little as possible of one token for `amountOut` of another along the specified path (reversed)
    /// @param params The parameters necessary for the multi-hop swap, encoded as `ExactOutputParams` in calldata
    /// @return amountIn The amount of the input token
    function exactOutput(ExactOutputParams calldata params) external payable returns (uint256 amountIn);
}
// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity ^0.8.6;

interface IPermitV2 {
  /// @notice Shared errors between signature based transfers and allowance based transfers.

  /// @notice Thrown when validating an inputted signature that is stale
  /// @param signatureDeadline The timestamp at which a signature is no longer valid
  error SignatureExpired(uint256 signatureDeadline);

  /// @notice Thrown when validating that the inputted nonce has not been used
  error InvalidNonce();

  function approve(
    address token,
    address spender,
    uint160 amount,
    uint48 expiration
  ) external;

  function allowance(
    address,
    address,
    address
  )
    external
    view
    returns (
      uint160,
      uint48,
      uint48
    );
}
// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity ^0.8.6;
pragma abicoder v2;

/// @title QuoterV2 Interface
/// @notice Supports quoting the calculated amounts from exact input or exact output swaps.
/// @notice For each pool also tells you the number of initialized ticks crossed and the sqrt price of the pool after the swap.
/// @dev These functions are not marked view because they rely on calling non-view functions and reverting
/// to compute the result. They are also not gas efficient and should not be called on-chain.
interface IQuoterV2 {
  /// @notice Returns the amount out received for a given exact input swap without executing the swap
  /// @param path The path of the swap, i.e. each token pair and the pool fee
  /// @param amountIn The amount of the first token to swap
  /// @return amountOut The amount of the last token that would be received
  /// @return sqrtPriceX96AfterList List of the sqrt price after the swap for each pool in the path
  /// @return initializedTicksCrossedList List of the initialized ticks that the swap crossed for each pool in the path
  /// @return gasEstimate The estimate of the gas that the swap consumes
  function quoteExactInput(bytes memory path, uint256 amountIn)
    external
    returns (
      uint256 amountOut,
      uint160[] memory sqrtPriceX96AfterList,
      uint32[] memory initializedTicksCrossedList,
      uint256 gasEstimate
    );

  struct QuoteExactInputSingleParams {
    address tokenIn;
    address tokenOut;
    uint256 amountIn;
    uint24 fee;
    uint160 sqrtPriceLimitX96;
  }

  /// @notice Returns the amount out received for a given exact input but for a swap of a single pool
  /// @param params The params for the quote, encoded as `QuoteExactInputSingleParams`
  /// tokenIn The token being swapped in
  /// tokenOut The token being swapped out
  /// fee The fee of the token pool to consider for the pair
  /// amountIn The desired input amount
  /// sqrtPriceLimitX96 The price limit of the pool that cannot be exceeded by the swap
  /// @return amountOut The amount of `tokenOut` that would be received
  /// @return sqrtPriceX96After The sqrt price of the pool after the swap
  /// @return initializedTicksCrossed The number of initialized ticks that the swap crossed
  /// @return gasEstimate The estimate of the gas that the swap consumes
  function quoteExactInputSingle(
    QuoteExactInputSingleParams memory params
  )
    external
    returns (
      uint256 amountOut,
      uint160 sqrtPriceX96After,
      uint32 initializedTicksCrossed,
      uint256 gasEstimate
    );

  /// @notice Returns the amount in required for a given exact output swap without executing the swap
  /// @param path The path of the swap, i.e. each token pair and the pool fee. Path must be provided in reverse order
  /// @param amountOut The amount of the last token to receive
  /// @return amountIn The amount of first token required to be paid
  /// @return sqrtPriceX96AfterList List of the sqrt price after the swap for each pool in the path
  /// @return initializedTicksCrossedList List of the initialized ticks that the swap crossed for each pool in the path
  /// @return gasEstimate The estimate of the gas that the swap consumes
  function quoteExactOutput(bytes memory path, uint256 amountOut)
    external
    returns (
      uint256 amountIn,
      uint160[] memory sqrtPriceX96AfterList,
      uint32[] memory initializedTicksCrossedList,
      uint256 gasEstimate
    );

  struct QuoteExactOutputSingleParams {
    address tokenIn;
    address tokenOut;
    uint256 amount;
    uint24 fee;
    uint160 sqrtPriceLimitX96;
  }

  /// @notice Returns the amount in required to receive the given exact output amount but for a swap of a single pool
  /// @param params The params for the quote, encoded as `QuoteExactOutputSingleParams`
  /// tokenIn The token being swapped in
  /// tokenOut The token being swapped out
  /// fee The fee of the token pool to consider for the pair
  /// amountOut The desired output amount
  /// sqrtPriceLimitX96 The price limit of the pool that cannot be exceeded by the swap
  /// @return amountIn The amount required as the input for the swap in order to receive `amountOut`
  /// @return sqrtPriceX96After The sqrt price of the pool after the swap
  /// @return initializedTicksCrossed The number of initialized ticks that the swap crossed
  /// @return gasEstimate The estimate of the gas that the swap consumes
  function quoteExactOutputSingle(
    QuoteExactOutputSingleParams memory params
  )
    external
    returns (
      uint256 amountIn,
      uint160 sqrtPriceX96After,
      uint32 initializedTicksCrossed,
      uint256 gasEstimate
    );
}
// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity ^0.8.6;

interface IUniversalRouter {
  /// @notice Thrown when a required command has failed
  error ExecutionFailed(uint256 commandIndex, bytes message);

  /// @notice Thrown when attempting to send ETH directly to the contract
  error ETHNotAccepted();

  /// @notice Thrown when executing commands with an expired deadline
  error TransactionDeadlinePassed();

  /// @notice Thrown when attempting to execute commands and an incorrect number of inputs are provided
  error LengthMismatch();

  /// @notice Executes encoded commands along with provided inputs. Reverts if deadline has expired.
  /// @param commands A set of concatenated commands, each 1 byte in length
  /// @param inputs An array of byte strings containing abi encoded inputs for each command
  /// @param deadline The deadline by which the transaction must be executed
  function execute(
    bytes calldata commands,
    bytes[] calldata inputs,
    uint256 deadline
  ) external payable;
}
// SPDX-License-Identifier: MIT

pragma solidity 0.8.17;

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
    // This method relies on extcodesize, which returns 0 for contracts in
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
  function sendValue(address payable recipient, uint256 amount)
    internal
  {
    require(
      address(this).balance >= amount,
      "Address: insufficient balance"
    );

    // solhint-disable-next-line avoid-low-level-calls, avoid-call-value
    (bool success, ) = recipient.call{ value: amount }("");
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
    return
      functionCall(target, data, "Address: low-level call failed");
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
    return functionCallWithValue(target, data, 0, errorMessage);
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
    require(isContract(target), "Address: call to non-contract");

    // solhint-disable-next-line avoid-low-level-calls
    (bool success, bytes memory returndata) = target.call{
      value: value
    }(data);
    return _verifyCallResult(success, returndata, errorMessage);
  }

  /**
   * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
   * but performing a static call.
   *
   * _Available since v3.3._
   */
  function functionStaticCall(address target, bytes memory data)
    internal
    view
    returns (bytes memory)
  {
    return
      functionStaticCall(
        target,
        data,
        "Address: low-level static call failed"
      );
  }

  /**
   * @dev Same as {xref-Address-functionCall-address-bytes-string-}[`functionCall`],
   * but performing a static call.
   *
   * _Available since v3.3._
   */
  function functionStaticCall(
    address target,
    bytes memory data,
    string memory errorMessage
  ) internal view returns (bytes memory) {
    require(
      isContract(target),
      "Address: static call to non-contract"
    );

    // solhint-disable-next-line avoid-low-level-calls
    (bool success, bytes memory returndata) = target.staticcall(data);
    return _verifyCallResult(success, returndata, errorMessage);
  }

  /**
   * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
   * but performing a delegate call.
   *
   * _Available since v3.4._
   */
  function functionDelegateCall(address target, bytes memory data)
    internal
    returns (bytes memory)
  {
    return
      functionDelegateCall(
        target,
        data,
        "Address: low-level delegate call failed"
      );
  }

  /**
   * @dev Same as {xref-Address-functionCall-address-bytes-string-}[`functionCall`],
   * but performing a delegate call.
   *
   * _Available since v3.4._
   */
  function functionDelegateCall(
    address target,
    bytes memory data,
    string memory errorMessage
  ) internal returns (bytes memory) {
    require(
      isContract(target),
      "Address: delegate call to non-contract"
    );

    // solhint-disable-next-line avoid-low-level-calls
    (bool success, bytes memory returndata) = target.delegatecall(
      data
    );
    return _verifyCallResult(success, returndata, errorMessage);
  }

  function _verifyCallResult(
    bool success,
    bytes memory returndata,
    string memory errorMessage
  ) private pure returns (bytes memory) {
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
}// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity ^0.8.6;

/// @title Commands
/// @notice Command Flags used to decode commands
library Commands {
  // Masks to extract certain bits of commands
  bytes1 internal constant FLAG_ALLOW_REVERT = 0x80;
  bytes1 internal constant COMMAND_TYPE_MASK = 0x3f;

  // Command Types. Maximum supported command at this moment is 0x3f.

  // Command Types where value<0x08, executed in the first nested-if block
  uint256 constant V3_SWAP_EXACT_IN = 0x00;
  uint256 constant V3_SWAP_EXACT_OUT = 0x01;
  uint256 constant PERMIT2_TRANSFER_FROM = 0x02;
  uint256 constant PERMIT2_PERMIT_BATCH = 0x03;
  uint256 constant SWEEP = 0x04;
  uint256 constant TRANSFER = 0x05;
  uint256 constant PAY_PORTION = 0x06;
  // COMMAND_PLACEHOLDER = 0x07;

  // The commands are executed in nested if blocks to minimise gas consumption
  // The following constant defines one of the boundaries where the if blocks split commands
  uint256 constant FIRST_IF_BOUNDARY = 0x08;

  // Command Types where 0x08<=value<=0x0f, executed in the second nested-if block
  uint256 constant V2_SWAP_EXACT_IN = 0x08;
  uint256 constant V2_SWAP_EXACT_OUT = 0x09;
  uint256 constant PERMIT2_PERMIT = 0x0a;
  uint256 constant WRAP_ETH = 0x0b;
  uint256 constant UNWRAP_WETH = 0x0c;
  uint256 constant PERMIT2_TRANSFER_FROM_BATCH = 0x0d;
  uint256 constant BALANCE_CHECK_ERC20 = 0x0e;
  // COMMAND_PLACEHOLDER = 0x0f;

  // The commands are executed in nested if blocks to minimise gas consumption
  // The following constant defines one of the boundaries where the if blocks split commands
  uint256 constant SECOND_IF_BOUNDARY = 0x10;

  // Command Types where 0x10<=value<0x18, executed in the third nested-if block
  uint256 constant SEAPORT_V1_5 = 0x10;
  uint256 constant LOOKS_RARE_V2 = 0x11;
  uint256 constant NFTX = 0x12;
  uint256 constant CRYPTOPUNKS = 0x13;
  // 0x14;
  uint256 constant OWNER_CHECK_721 = 0x15;
  uint256 constant OWNER_CHECK_1155 = 0x16;
  uint256 constant SWEEP_ERC721 = 0x17;

  // The commands are executed in nested if blocks to minimise gas consumption
  // The following constant defines one of the boundaries where the if blocks split commands
  uint256 constant THIRD_IF_BOUNDARY = 0x18;

  // Command Types where 0x18<=value<=0x1f, executed in the final nested-if block
  uint256 constant X2Y2_721 = 0x18;
  uint256 constant SUDOSWAP = 0x19;
  uint256 constant NFT20 = 0x1a;
  uint256 constant X2Y2_1155 = 0x1b;
  uint256 constant FOUNDATION = 0x1c;
  uint256 constant SWEEP_ERC1155 = 0x1d;
  uint256 constant ELEMENT_MARKET = 0x1e;
  // COMMAND_PLACEHOLDER = 0x1f;

  // The commands are executed in nested if blocks to minimise gas consumption
  // The following constant defines one of the boundaries where the if blocks split commands
  uint256 constant FOURTH_IF_BOUNDARY = 0x20;

  // Command Types where 0x20<=value
  uint256 constant SEAPORT_V1_4 = 0x20;
  uint256 constant EXECUTE_SUB_PLAN = 0x21;
  uint256 constant APPROVE_ERC20 = 0x22;
  // COMMAND_PLACEHOLDER for 0x23 to 0x3f (all unused)
}
// SPDX-License-Identifier: MIT

pragma solidity 0.8.17;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "./Address.sol";

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
      abi.encodeWithSelector(
        token.transferFrom.selector,
        from,
        to,
        value
      )
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
      "SafeERC20: approve from non-zero to non-zero allowance"
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
    uint256 newAllowance = token.allowance(address(this), spender) +
      value;
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
    unchecked {
      uint256 oldAllowance = token.allowance(address(this), spender);
      require(
        oldAllowance >= value,
        "SafeERC20: decreased allowance below zero"
      );
      uint256 newAllowance = oldAllowance - value;
      _callOptionalReturn(
        token,
        abi.encodeWithSelector(
          token.approve.selector,
          spender,
          newAllowance
        )
      );
    }
  }

  /**
   * @dev Imitates a Solidity high-level call (i.e. a regular function call to a contract), relaxing the requirement
   * on the return value: the return value is optional (but if data is returned, it must not be false).
   * @param token The token targeted by the call.
   * @param data The call data (encoded using abi.encode or one of its variants).
   */
  function _callOptionalReturn(IERC20 token, bytes memory data)
    private
  {
    // We need to perform a low level call here, to bypass Solidity's return data size checking mechanism, since
    // we're implementing it ourselves. We use {Address.functionCall} to perform this call, which verifies that
    // the target address contains contract code and also asserts for success in the low-level call.

    bytes memory returndata = address(token).functionCall(
      data,
      "SafeERC20: low-level call failed"
    );
    if (returndata.length > 0) {
      // Return data is optional
      // solhint-disable-next-line max-line-length
      require(
        abi.decode(returndata, (bool)),
        "SafeERC20: ERC20 operation did not succeed"
      );
    }
  }
}// SPDX-License-Identifier: AGPL-3.0-or-later
pragma solidity 0.8.17;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@uniswap/v3-periphery/contracts/interfaces/ISwapRouter.sol";
import "./interfaces/IUniversalRouter.sol";
import "./interfaces/IPermitV2.sol";
import "./interfaces/IQuoterV2.sol";
import "./libraries/Commands.sol";
import "./libraries/SafeERC20.sol";

interface IStableRouter {
  function exchange(
    int128 i,
    int128 j,
    uint256 dx,
    uint256 min_dy
  ) external returns (uint256);

  function get_dy(
    int128 i,
    int128 j,
    uint256 dx
  ) external view returns (uint256);
}

interface ITreasury {
  function mint(uint256 _amount) external returns (uint256);

  function redeem(uint256 _amount) external returns (uint256);

  function reserveToTMAmount(uint256 _amount)
    external
    view
    returns (uint256);

  function tmToReserveAmount(uint256 _amount)
    external
    view
    returns (uint256);
}

contract TemplarRouter is Ownable {
  using SafeERC20 for IERC20;
  ISwapRouter swapRouter;

  address public immutable treasury;
  address public immutable tm;
  address public immutable busd;
  address public immutable wbnb;
  address public immutable tem;
  address public immutable stableRouter;
  address public immutable uniRouter;
  address public immutable permit2;
  address public immutable quoter2;

  mapping(address => bool) public tokenList;
  mapping(address => int128) public tokenParam;

  event Swap(
    address indexed _address,
    address _tokenA,
    address _tokenB,
    uint256 _amountIn,
    uint256 _minAmountOut,
    uint256 _amountOut
  );

  modifier allowTokenList(address _tokenA, address _tokenB) {
    require(_tokenA != _tokenB, "not same token");
    require(
      tokenList[_tokenA] && tokenList[_tokenB],
      "token not allow"
    );
    _;
  }

  constructor(
    address _treasury,
    address _tm,
    address _busd,
    address _usdt,
    address _usdc,
    address _dai,
    address _tem,
    address _wbnb,
    address _stableRouter,
    address _uniRouter,
    address _permit2,
    address _quoter2
  ) {
    require(_treasury != address(0), "invalid address");
    require(_tm != address(0), "invalid address");
    require(_busd != address(0), "invalid address");
    require(_usdt != address(0), "invalid address");
    require(_usdc != address(0), "invalid address");
    require(_dai != address(0), "invalid address");
    require(_tem != address(0), "invalid TEM address");
    require(_wbnb != address(0), "invalid WBNB address");
    require(_stableRouter != address(0), "invalid address");
    require(
      _uniRouter != address(0),
      "invalid UniswapV3 router address"
    );
    require(_permit2 != address(0), "invalid permit2 address");

    treasury = _treasury;
    tm = _tm;
    busd = _busd;
    wbnb = _wbnb;
    tem = _tem;
    stableRouter = _stableRouter;
    uniRouter = _uniRouter;
    permit2 = _permit2;
    quoter2 = _quoter2;

    // initial token list
    tokenList[_tm] = true;
    tokenList[_busd] = true;
    tokenList[_usdt] = true;
    tokenList[_dai] = true;
    tokenList[_usdc] = true;
    tokenList[_tem] = true;

    // initial stable swap param
    tokenParam[_busd] = 0;
    tokenParam[_usdt] = 1;
    tokenParam[_dai] = 2;
    tokenParam[_usdc] = 3;
  }

  function swap(
    address _tokenA,
    address _tokenB,
    uint256 _amountIn,
    uint256 _minAmountOut
  )
    external
    allowTokenList(_tokenA, _tokenB)
    returns (uint256 _amountOut)
  {
    IERC20(_tokenA).safeTransferFrom(
      msg.sender,
      address(this),
      _amountIn
    );

    if (_tokenA == tem) {
      _amountOut = _swapWithUniswapV3(_amountIn, 0, tem, busd);
      if (_tokenB != busd) {
        _amountOut = _swapStableTM(busd, _tokenB, _amountOut, 0);
      }
    } else if (_tokenB == tem) {
      uint256 amountIn = _amountIn;
      if (_tokenA != busd) {
        amountIn = _swapStableTM(_tokenA, busd, amountIn, 0);
      }
      _amountOut = _swapWithUniswapV3(amountIn, 0, busd, tem);
    } else {
      _amountOut = _swapStableTM(_tokenA, _tokenB, _amountIn, 0);
    }

    require(_amountOut >= _minAmountOut, "slippage");
    IERC20(_tokenB).safeTransfer(msg.sender, _amountOut);

    emit Swap(
      msg.sender,
      _tokenA,
      _tokenB,
      _amountIn,
      _minAmountOut,
      _amountOut
    );
  }

  function getAmountOut(
    address _tokenA,
    address _tokenB,
    uint256 _amountIn
  )
    external
    allowTokenList(_tokenA, _tokenB)
    returns (uint256 _amountOut)
  {
    if (_tokenA == tem) {
      _amountOut = _getQuoteExactInput(tem, busd, _amountIn);
      if (_tokenB != busd) {
        _amountOut = _getExactInputSwapStableTM(
          busd,
          _tokenB,
          _amountOut
        );
      }
    } else if (_tokenB == tem) {
      uint256 amountIn = _amountIn;
      if (_tokenA != busd) {
        amountIn = _getExactInputSwapStableTM(
          _tokenA,
          busd,
          amountIn
        );
      }
      _amountOut = _getQuoteExactInput(busd, tem, amountIn);
    } else {
      _amountOut = _getExactInputSwapStableTM(
        _tokenA,
        _tokenB,
        _amountIn
      );
    }
  }

  // ------------------------------
  // internal
  // ------------------------------
  function _getQuoteExactInput(
    address _tokenA,
    address _tokenB,
    uint256 _amountIn
  ) internal returns (uint256 amountOut) {
    bytes memory paths = abi.encodePacked(
      _tokenA,
      uint24(3000),
      wbnb,
      uint24(3000),
      _tokenB
    );
    IQuoterV2 q = IQuoterV2(quoter2);
    (amountOut, , , ) = q.quoteExactInput(paths, _amountIn);
  }

  function _getExactInputSwapStableTM(
    address _tokenA,
    address _tokenB,
    uint256 _amountIn
  ) internal view returns (uint256 _amountOut) {
    if (_tokenA == tm) {
      _amountOut = ITreasury(treasury).tmToReserveAmount(_amountIn);
    } else if (_tokenB == tm) {
      _amountOut = ITreasury(treasury).reserveToTMAmount(_amountIn);
    } else {
      _amountOut = IStableRouter(stableRouter).get_dy(
        tokenParam[_tokenA],
        tokenParam[_tokenB],
        _amountIn
      );
    }
  }

  function _swapStableTM(
    address _tokenA,
    address _tokenB,
    uint256 _amountIn,
    uint256 _minAmountOut
  ) internal returns (uint256 _amountOut) {
    if (_tokenA == tm) {
      _amountOut = _zapRedeem(_tokenB, _amountIn, _minAmountOut);
    } else if (_tokenB == tm) {
      _amountOut = _zapMint(_tokenA, _amountIn, _minAmountOut);
    } else {
      _amountOut = _stableSwap(
        _tokenA,
        _tokenB,
        _amountIn,
        _minAmountOut
      );
    }
  }

  function _zapMint(
    address _token,
    uint256 _amountIn,
    uint256 _minAmountOut
  ) internal returns (uint256 _amountOut) {
    // swap to BUSD
    uint256 _balance = (_token == busd)
      ? _amountIn
      : _swap(_token, busd, _amountIn, _minAmountOut);

    // mint
    IERC20(busd).safeApprove(treasury, _balance);
    _amountOut = ITreasury(treasury).mint(_balance);
  }

  function _zapRedeem(
    address _token,
    uint256 _amountIn,
    uint256 _minAmountOut
  ) internal returns (uint256 _amountOut) {
    // redeem to BUSD
    IERC20(tm).safeApprove(treasury, _amountIn);
    uint256 _balance = ITreasury(treasury).redeem(_amountIn);

    // swap from BUSD
    _amountOut = (_token == busd)
      ? _balance
      : _swap(busd, _token, _balance, _minAmountOut);
  }

  function _stableSwap(
    address _tokenA,
    address _tokenB,
    uint256 _amountIn,
    uint256 _minAmountOut
  ) internal returns (uint256 _amountOut) {
    _amountOut = _swap(_tokenA, _tokenB, _amountIn, _minAmountOut);
  }

  function _swap(
    address _tokenA,
    address _tokenB,
    uint256 _amountIn,
    uint256 _minAmountOut
  ) internal returns (uint256 _amountOut) {
    IERC20(_tokenA).safeApprove(stableRouter, _amountIn);
    _amountOut = IStableRouter(stableRouter).exchange(
      tokenParam[_tokenA],
      tokenParam[_tokenB],
      _amountIn,
      _minAmountOut
    );
  }

  function _swapWithUniswapV3(
    uint256 _amountIn,
    uint256 _minAmountOut,
    address _tokenA,
    address _tokenB
  ) internal returns (uint256 _amountOut) {
    // Get balance before
    uint256 balanceBefore = IERC20(_tokenB).balanceOf(address(this));

    // Permit2 token approval
    IERC20(_tokenA).safeApprove(permit2, _amountIn);
    IPermitV2(permit2).approve(
      _tokenA,
      uniRouter,
      uint160(_amountIn),
      uint48(block.timestamp + 60)
    );

    // Create commands and inputs
    // 0x00 = V3_SWAP_EXACT_IN
    bytes memory commands = abi.encodePacked(
      bytes1(uint8(Commands.V3_SWAP_EXACT_IN))
    );
    bytes[] memory inputs = new bytes[](1);

    // Just only paths supported
    // BUSD -> WBNB -> TEM
    // TEM -> WBNB -> BUSD
    bytes memory paths = abi.encodePacked(
      _tokenA,
      uint24(3000),
      wbnb,
      uint24(3000),
      _tokenB
    );

    // 0x00 V3_SWAP_EXACT_IN
    // (recipient, amountIn, minAmountOut, paths, bool A flag from msg.sender)
    inputs[0] = abi.encode(
      address(0x0000000000000000000000000000000000000001), // MSG_SENDER
      _amountIn,
      _minAmountOut,
      paths,
      true
    );

    IUniversalRouter router = IUniversalRouter(uniRouter);
    router.execute(commands, inputs, block.timestamp + 60);

    uint256 balanceAfter = IERC20(_tokenB).balanceOf(address(this));
    _amountOut = balanceAfter - balanceBefore;
  }

  // ------------------------------
  // onlyOwner
  // ------------------------------
  function addTokenList(address _token) external onlyOwner {
    require(_token != address(0), "address invalid");
    tokenList[_token] = true;
  }

  function removeTokenList(address _token) external onlyOwner {
    require(_token != address(0), "address invalid");
    tokenList[_token] = false;
  }
}
