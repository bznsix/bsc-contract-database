// SPDX-License-Identifier: UNLICENSED

pragma solidity 0.8.3;



// Part: Context

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
        return msg.data;
    }
}

// Part: IERC20

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

// Part: IPancakeRouter01

interface IPancakeRouter01 {
    function factory() external pure returns (address);
    function WETH() external pure returns (address);

    function addLiquidity(
        address tokenA,
        address tokenB,
        uint amountADesired,
        uint amountBDesired,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline
    ) external returns (uint amountA, uint amountB, uint liquidity);
    function addLiquidityETH(
        address token,
        uint amountTokenDesired,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external payable returns (uint amountToken, uint amountETH, uint liquidity);
    function removeLiquidity(
        address tokenA,
        address tokenB,
        uint liquidity,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline
    ) external returns (uint amountA, uint amountB);
    function removeLiquidityETH(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external returns (uint amountToken, uint amountETH);
    function removeLiquidityWithPermit(
        address tokenA,
        address tokenB,
        uint liquidity,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountA, uint amountB);
    function removeLiquidityETHWithPermit(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountToken, uint amountETH);
    function swapExactTokensForTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory amounts);
    function swapTokensForExactTokens(
        uint amountOut,
        uint amountInMax,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory amounts);
    function swapExactETHForTokens(uint amountOutMin, address[] calldata path, address to, uint deadline)
        external
        payable
        returns (uint[] memory amounts);
    function swapTokensForExactETH(uint amountOut, uint amountInMax, address[] calldata path, address to, uint deadline)
        external
        returns (uint[] memory amounts);
    function swapExactTokensForETH(uint amountIn, uint amountOutMin, address[] calldata path, address to, uint deadline)
        external
        returns (uint[] memory amounts);
    function swapETHForExactTokens(uint amountOut, address[] calldata path, address to, uint deadline)
        external
        payable
        returns (uint[] memory amounts);

    function quote(uint amountA, uint reserveA, uint reserveB) external pure returns (uint amountB);
    function getAmountOut(uint amountIn, uint reserveIn, uint reserveOut) external pure returns (uint amountOut);
    function getAmountIn(uint amountOut, uint reserveIn, uint reserveOut) external pure returns (uint amountIn);
    function getAmountsOut(uint amountIn, address[] calldata path) external view returns (uint[] memory amounts);
    function getAmountsIn(uint amountOut, address[] calldata path) external view returns (uint[] memory amounts);
}

// Part: LinkTokenInterface

interface LinkTokenInterface {

  function allowance(
    address owner,
    address spender
  )
    external
    view
    returns (
      uint256 remaining
    );

  function approve(
    address spender,
    uint256 value
  )
    external
    returns (
      bool success
    );

  function balanceOf(
    address owner
  )
    external
    view
    returns (
      uint256 balance
    );

  function decimals()
    external
    view
    returns (
      uint8 decimalPlaces
    );

  function decreaseApproval(
    address spender,
    uint256 addedValue
  )
    external
    returns (
      bool success
    );

  function increaseApproval(
    address spender,
    uint256 subtractedValue
  ) external;

  function name()
    external
    view
    returns (
      string memory tokenName
    );

  function symbol()
    external
    view
    returns (
      string memory tokenSymbol
    );

  function totalSupply()
    external
    view
    returns (
      uint256 totalTokensIssued
    );

  function transfer(
    address to,
    uint256 value
  )
    external
    returns (
      bool success
    );

  function transferAndCall(
    address to,
    uint256 value,
    bytes calldata data
  )
    external
    returns (
      bool success
    );

  function transferFrom(
    address from,
    address to,
    uint256 value
  )
    external
    returns (
      bool success
    );

}

// Part: Math

/**
 * @dev Standard math utilities missing in the Solidity language.
 */
library Math {
    /**
     * @dev Returns the largest of two numbers.
     */
    function max(uint256 a, uint256 b) internal pure returns (uint256) {
        return a >= b ? a : b;
    }

    /**
     * @dev Returns the smallest of two numbers.
     */
    function min(uint256 a, uint256 b) internal pure returns (uint256) {
        return a < b ? a : b;
    }

    /**
     * @dev Returns the average of two numbers. The result is rounded towards
     * zero.
     */
    function average(uint256 a, uint256 b) internal pure returns (uint256) {
        // (a + b) / 2 can overflow, so we distribute.
        return (a / 2) + (b / 2) + (((a % 2) + (b % 2)) / 2);
    }

    /**
     * @dev Returns the ceiling of the division of two numbers.
     *
     * This differs from standard division with `/` in that it rounds up instead
     * of rounding down.
     */
    function ceilDiv(uint256 a, uint256 b) internal pure returns (uint256) {
        // (a + b - 1) / b can overflow on addition, so we distribute.
        return a / b + (a % b == 0 ? 0 : 1);
    }
}

// Part: ReentrancyGuard

/**
 * @dev Contract module that helps prevent reentrant calls to a function.
 *
 * Inheriting from `ReentrancyGuard` will make the {nonReentrant} modifier
 * available, which can be applied to functions to make sure there are no nested
 * (reentrant) calls to them.
 *
 * Note that because there is a single `nonReentrant` guard, functions marked as
 * `nonReentrant` may not call one another. This can be worked around by making
 * those functions `private`, and then adding `external` `nonReentrant` entry
 * points to them.
 *
 * TIP: If you would like to learn more about reentrancy and alternative ways
 * to protect against it, check out our blog post
 * https://blog.openzeppelin.com/reentrancy-after-istanbul/[Reentrancy After Istanbul].
 */
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

    constructor() {
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
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");

        // Any calls to nonReentrant after this point will fail
        _status = _ENTERED;

        _;

        // By storing the original value once again, a refund is triggered (see
        // https://eips.ethereum.org/EIPS/eip-2200)
        _status = _NOT_ENTERED;
    }
}

// Part: VRFRequestIDBase

contract VRFRequestIDBase {

  /**
   * @notice returns the seed which is actually input to the VRF coordinator
   *
   * @dev To prevent repetition of VRF output due to repetition of the
   * @dev user-supplied seed, that seed is combined in a hash with the
   * @dev user-specific nonce, and the address of the consuming contract. The
   * @dev risk of repetition is mostly mitigated by inclusion of a blockhash in
   * @dev the final seed, but the nonce does protect against repetition in
   * @dev requests which are included in a single block.
   *
   * @param _userSeed VRF seed input provided by user
   * @param _requester Address of the requesting contract
   * @param _nonce User-specific nonce at the time of the request
   */
  function makeVRFInputSeed(
    bytes32 _keyHash,
    uint256 _userSeed,
    address _requester,
    uint256 _nonce
  )
    internal
    pure
    returns (
      uint256
    )
  {
    return uint256(keccak256(abi.encode(_keyHash, _userSeed, _requester, _nonce)));
  }

  /**
   * @notice Returns the id for this request
   * @param _keyHash The serviceAgreement ID to be used for this request
   * @param _vRFInputSeed The seed to be passed directly to the VRF
   * @return The id for this request
   *
   * @dev Note that _vRFInputSeed is not the seed passed by the consuming
   * @dev contract, but the one generated by makeVRFInputSeed
   */
  function makeRequestId(
    bytes32 _keyHash,
    uint256 _vRFInputSeed
  )
    internal
    pure
    returns (
      bytes32
    )
  {
    return keccak256(abi.encodePacked(_keyHash, _vRFInputSeed));
  }
}

// Part: ArraysModified

/**
 * @dev Collection of functions related to array types.
 */
library ArraysModified {
    /**
     * @dev Searches a sorted `array` and returns the first index that contains
     * a value greater or equal to `element`. If no such index exists (i.e. all
     * values in the array are strictly less than `element`), the array length is
     * returned. Time complexity O(log n).
     * Same as Open Zeppelin implementation with the only difference that a `factor`
     * parameter has been added.
     *
     * `array` is expected to be sorted in ascending order, and to contain no
     * repeated elements.
     */
    function findUpperBound(uint256[] storage array, uint256 element, uint256 factor) internal view returns (uint256) {
        require(factor > 0, "factor should be positive");
        if (array.length == 0) {
            return 0;
        }

        uint256 low = 0;
        uint256 high = array.length;

        uint256 arrayMidScaled;

        while (low < high) {
            uint256 mid = Math.average(low, high);

            // Note that mid will always be strictly less than high (i.e. it will be a valid array index)
            // because Math.average rounds down (it does integer division with truncation).

            arrayMidScaled = array[mid] * factor;
            if (arrayMidScaled > element) {
                high = mid;
            } else {
                low = mid + 1;
            }
        }

        // At this point `low` is the exclusive upper bound. We will return the inclusive upper bound.
        if (low > 0 && array[low - 1] * factor == element) {
            return low - 1;
        } else {
            return low;
        }
    }


    /**
     * @dev Exactly the same as `findUpperBound` except that `array` is in memory rather than
     * storage.
     */
    function findUpperBoundMemory(uint256[] memory array, uint256 element, uint256 factor) internal pure returns (uint256) {
        require(factor > 0, "factor should be positive");
        if (array.length == 0) {
            return 0;
        }

        uint256 low = 0;
        uint256 high = array.length;

        uint256 arrayMidScaled;

        while (low < high) {
            uint256 mid = Math.average(low, high);

            // Note that mid will always be strictly less than high (i.e. it will be a valid array index)
            // because Math.average rounds down (it does integer division with truncation).

            arrayMidScaled = array[mid] * factor;
            if (arrayMidScaled > element) {
                high = mid;
            } else {
                low = mid + 1;
            }
        }

        // At this point `low` is the exclusive upper bound. We will return the inclusive upper bound.
        if (low > 0 && array[low - 1] * factor == element) {
            return low - 1;
        } else {
            return low;
        }
    }
}

// Part: IERC20Gummy

interface IERC20Gummy is IERC20 {
    function burn(uint256 amount) external;
    function applyFees(uint256 amountIn) external pure  returns(uint256, uint256, uint256, uint256);
    function removeFromWhiteList(address account) external;
    function setTeamWallet(address _newTeamWallet) external;
    function setGummyPot(address _newGummyPot) external;
}

// Part: IPancakeRouter02

interface IPancakeRouter02 is IPancakeRouter01 {
    function removeLiquidityETHSupportingFeeOnTransferTokens(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external returns (uint amountETH);
    function removeLiquidityETHWithPermitSupportingFeeOnTransferTokens(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountETH);

    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
    function swapExactETHForTokensSupportingFeeOnTransferTokens(
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external payable;
    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
}

// Part: Ownable

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
     * thereby removing any functionality that is only available to the owner.
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
}

// Part: Pausable

/**
 * @dev Contract module which allows children to implement an emergency stop
 * mechanism that can be triggered by an authorized account.
 *
 * This module is used through inheritance. It will make available the
 * modifiers `whenNotPaused` and `whenPaused`, which can be applied to
 * the functions of your contract. Note that they will not be pausable by
 * simply including this module, only once the modifiers are put in place.
 */
abstract contract Pausable is Context {
    /**
     * @dev Emitted when the pause is triggered by `account`.
     */
    event Paused(address account);

    /**
     * @dev Emitted when the pause is lifted by `account`.
     */
    event Unpaused(address account);

    bool private _paused;

    /**
     * @dev Initializes the contract in unpaused state.
     */
    constructor() {
        _paused = false;
    }

    /**
     * @dev Returns true if the contract is paused, and false otherwise.
     */
    function paused() public view virtual returns (bool) {
        return _paused;
    }

    /**
     * @dev Modifier to make a function callable only when the contract is not paused.
     *
     * Requirements:
     *
     * - The contract must not be paused.
     */
    modifier whenNotPaused() {
        require(!paused(), "Pausable: paused");
        _;
    }

    /**
     * @dev Modifier to make a function callable only when the contract is paused.
     *
     * Requirements:
     *
     * - The contract must be paused.
     */
    modifier whenPaused() {
        require(paused(), "Pausable: not paused");
        _;
    }

    /**
     * @dev Triggers stopped state.
     *
     * Requirements:
     *
     * - The contract must not be paused.
     */
    function _pause() internal virtual whenNotPaused {
        _paused = true;
        emit Paused(_msgSender());
    }

    /**
     * @dev Returns to normal state.
     *
     * Requirements:
     *
     * - The contract must be paused.
     */
    function _unpause() internal virtual whenPaused {
        _paused = false;
        emit Unpaused(_msgSender());
    }
}

// Part: VRFConsumerBase

/** ****************************************************************************
 * @notice Interface for contracts using VRF randomness
 * *****************************************************************************
 * @dev PURPOSE
 *
 * @dev Reggie the Random Oracle (not his real job) wants to provide randomness
 * @dev to Vera the verifier in such a way that Vera can be sure he's not
 * @dev making his output up to suit himself. Reggie provides Vera a public key
 * @dev to which he knows the secret key. Each time Vera provides a seed to
 * @dev Reggie, he gives back a value which is computed completely
 * @dev deterministically from the seed and the secret key.
 *
 * @dev Reggie provides a proof by which Vera can verify that the output was
 * @dev correctly computed once Reggie tells it to her, but without that proof,
 * @dev the output is indistinguishable to her from a uniform random sample
 * @dev from the output space.
 *
 * @dev The purpose of this contract is to make it easy for unrelated contracts
 * @dev to talk to Vera the verifier about the work Reggie is doing, to provide
 * @dev simple access to a verifiable source of randomness.
 * *****************************************************************************
 * @dev USAGE
 *
 * @dev Calling contracts must inherit from VRFConsumerBase, and can
 * @dev initialize VRFConsumerBase's attributes in their constructor as
 * @dev shown:
 *
 * @dev   contract VRFConsumer {
 * @dev     constuctor(<other arguments>, address _vrfCoordinator, address _link)
 * @dev       VRFConsumerBase(_vrfCoordinator, _link) public {
 * @dev         <initialization with other arguments goes here>
 * @dev       }
 * @dev   }
 *
 * @dev The oracle will have given you an ID for the VRF keypair they have
 * @dev committed to (let's call it keyHash), and have told you the minimum LINK
 * @dev price for VRF service. Make sure your contract has sufficient LINK, and
 * @dev call requestRandomness(keyHash, fee, seed), where seed is the input you
 * @dev want to generate randomness from.
 *
 * @dev Once the VRFCoordinator has received and validated the oracle's response
 * @dev to your request, it will call your contract's fulfillRandomness method.
 *
 * @dev The randomness argument to fulfillRandomness is the actual random value
 * @dev generated from your seed.
 *
 * @dev The requestId argument is generated from the keyHash and the seed by
 * @dev makeRequestId(keyHash, seed). If your contract could have concurrent
 * @dev requests open, you can use the requestId to track which seed is
 * @dev associated with which randomness. See VRFRequestIDBase.sol for more
 * @dev details. (See "SECURITY CONSIDERATIONS" for principles to keep in mind,
 * @dev if your contract could have multiple requests in flight simultaneously.)
 *
 * @dev Colliding `requestId`s are cryptographically impossible as long as seeds
 * @dev differ. (Which is critical to making unpredictable randomness! See the
 * @dev next section.)
 *
 * *****************************************************************************
 * @dev SECURITY CONSIDERATIONS
 *
 * @dev A method with the ability to call your fulfillRandomness method directly
 * @dev could spoof a VRF response with any random value, so it's critical that
 * @dev it cannot be directly called by anything other than this base contract
 * @dev (specifically, by the VRFConsumerBase.rawFulfillRandomness method).
 *
 * @dev For your users to trust that your contract's random behavior is free
 * @dev from malicious interference, it's best if you can write it so that all
 * @dev behaviors implied by a VRF response are executed *during* your
 * @dev fulfillRandomness method. If your contract must store the response (or
 * @dev anything derived from it) and use it later, you must ensure that any
 * @dev user-significant behavior which depends on that stored value cannot be
 * @dev manipulated by a subsequent VRF request.
 *
 * @dev Similarly, both miners and the VRF oracle itself have some influence
 * @dev over the order in which VRF responses appear on the blockchain, so if
 * @dev your contract could have multiple VRF requests in flight simultaneously,
 * @dev you must ensure that the order in which the VRF responses arrive cannot
 * @dev be used to manipulate your contract's user-significant behavior.
 *
 * @dev Since the ultimate input to the VRF is mixed with the block hash of the
 * @dev block in which the request is made, user-provided seeds have no impact
 * @dev on its economic security properties. They are only included for API
 * @dev compatability with previous versions of this contract.
 *
 * @dev Since the block hash of the block which contains the requestRandomness
 * @dev call is mixed into the input to the VRF *last*, a sufficiently powerful
 * @dev miner could, in principle, fork the blockchain to evict the block
 * @dev containing the request, forcing the request to be included in a
 * @dev different block with a different hash, and therefore a different input
 * @dev to the VRF. However, such an attack would incur a substantial economic
 * @dev cost. This cost scales with the number of blocks the VRF oracle waits
 * @dev until it calls responds to a request.
 */
abstract contract VRFConsumerBase is VRFRequestIDBase {

  /**
   * @notice fulfillRandomness handles the VRF response. Your contract must
   * @notice implement it. See "SECURITY CONSIDERATIONS" above for important
   * @notice principles to keep in mind when implementing your fulfillRandomness
   * @notice method.
   *
   * @dev VRFConsumerBase expects its subcontracts to have a method with this
   * @dev signature, and will call it once it has verified the proof
   * @dev associated with the randomness. (It is triggered via a call to
   * @dev rawFulfillRandomness, below.)
   *
   * @param requestId The Id initially returned by requestRandomness
   * @param randomness the VRF output
   */
  function fulfillRandomness(
    bytes32 requestId,
    uint256 randomness
  )
    internal
    virtual;

  /**
   * @dev In order to keep backwards compatibility we have kept the user
   * seed field around. We remove the use of it because given that the blockhash
   * enters later, it overrides whatever randomness the used seed provides.
   * Given that it adds no security, and can easily lead to misunderstandings,
   * we have removed it from usage and can now provide a simpler API.
   */
  uint256 constant private USER_SEED_PLACEHOLDER = 0;

  /**
   * @notice requestRandomness initiates a request for VRF output given _seed
   *
   * @dev The fulfillRandomness method receives the output, once it's provided
   * @dev by the Oracle, and verified by the vrfCoordinator.
   *
   * @dev The _keyHash must already be registered with the VRFCoordinator, and
   * @dev the _fee must exceed the fee specified during registration of the
   * @dev _keyHash.
   *
   * @dev The _seed parameter is vestigial, and is kept only for API
   * @dev compatibility with older versions. It can't *hurt* to mix in some of
   * @dev your own randomness, here, but it's not necessary because the VRF
   * @dev oracle will mix the hash of the block containing your request into the
   * @dev VRF seed it ultimately uses.
   *
   * @param _keyHash ID of public key against which randomness is generated
   * @param _fee The amount of LINK to send with the request
   *
   * @return requestId unique ID for this request
   *
   * @dev The returned requestId can be used to distinguish responses to
   * @dev concurrent requests. It is passed as the first argument to
   * @dev fulfillRandomness.
   */
  function requestRandomness(
    bytes32 _keyHash,
    uint256 _fee
  )
    internal
    returns (
      bytes32 requestId
    )
  {
    LINK.transferAndCall(vrfCoordinator, _fee, abi.encode(_keyHash, USER_SEED_PLACEHOLDER));
    // This is the seed passed to VRFCoordinator. The oracle will mix this with
    // the hash of the block containing this request to obtain the seed/input
    // which is finally passed to the VRF cryptographic machinery.
    uint256 vRFSeed  = makeVRFInputSeed(_keyHash, USER_SEED_PLACEHOLDER, address(this), nonces[_keyHash]);
    // nonces[_keyHash] must stay in sync with
    // VRFCoordinator.nonces[_keyHash][this], which was incremented by the above
    // successful LINK.transferAndCall (in VRFCoordinator.randomnessRequest).
    // This provides protection against the user repeating their input seed,
    // which would result in a predictable/duplicate output, if multiple such
    // requests appeared in the same block.
    nonces[_keyHash] = nonces[_keyHash] + 1;
    return makeRequestId(_keyHash, vRFSeed);
  }

  LinkTokenInterface immutable internal LINK;
  address immutable private vrfCoordinator;

  // Nonces for each VRF key from which randomness has been requested.
  //
  // Must stay in sync with VRFCoordinator[_keyHash][this]
  mapping(bytes32 /* keyHash */ => uint256 /* nonce */) private nonces;

  /**
   * @param _vrfCoordinator address of VRFCoordinator contract
   * @param _link address of LINK token contract
   *
   * @dev https://docs.chain.link/docs/link-token-contracts
   */
  constructor(
    address _vrfCoordinator,
    address _link
  ) {
    vrfCoordinator = _vrfCoordinator;
    LINK = LinkTokenInterface(_link);
  }

  // rawFulfillRandomness is called by VRFCoordinator when it receives a valid VRF
  // proof. rawFulfillRandomness then calls fulfillRandomness, after validating
  // the origin of the call
  function rawFulfillRandomness(
    bytes32 requestId,
    uint256 randomness
  )
    external
  {
    require(msg.sender == vrfCoordinator, "Only VRFCoordinator can fulfill");
    fulfillRandomness(requestId, randomness);
  }
}

// File: FlavorTeams.sol

/**
 * @title FlavorTeams.
 */
contract FlavorTeams is Ownable, Pausable, VRFConsumerBase, ReentrancyGuard {

    uint256 immutable public intervalInDays;                     // interval in days between two rounds
    uint256 constant public NUM_TEAMS = 4;
    uint256 constant public PARTNER_TEAM = 0;                    // identifier of the partner team
    uint256 constant public PARTNER_TEAM_BIS = 1;                // identifier of the secondary partner team
    uint256 constant public BURN_NUMERATOR = 250;
    uint256 constant public PARTNER_TEAM_BURN_NUM_LOSS = 0;      // if winning team is not our (secondary) partner team, how much of
                                                                 // the burn should take place in our partner token
    uint256 constant public PARTNER_TEAM_BURN_NUM_WIN = 800;     // if partner team wins, what percentage of the burn
                                                                 // should happen in the partner token as buy-back + burn (80%)
    uint256 constant public PARTNER_TEAM_BURN_NUM_WIN_BIS = 200; // same as above but in case the secondary partner team wins (20%)
    uint256 constant public DENOMINATOR = 1000;
    address constant public BURN_ADDRESS_PARTNER = 0x000000000000000000000000000000000000dEaD;

    struct Round {
        uint40 startedOnDay;                                     // day (since Unix epoch) on which the round started
        bool closingRequested;                                   // has the closing of the been requested?
        bool isClosed;                                           // is the round closed?
        uint256 totalAmount;                                     // total amount betted during the round
        uint256 winningTeam;                                     // identifier of the winning team
        uint256[NUM_TEAMS] amountPerTeam;                        // how much GUMMY was bet on each team?
        mapping(address => uint256[NUM_TEAMS]) amounts;          // maps each users to the amounts he betted on the different teams
        mapping(address => bool) claimed;                        // has the user claimed his gains?
    }


    IERC20Gummy immutable public gummyToken;
    bool private genesisRoundLaunched;
    uint256 public currentRound;
    mapping(uint256 => Round) public rounds;
    mapping(bytes32 => uint256) public requestIdToRound;

    uint40 public utcOffset;

    IPancakeRouter02 public router;
    address immutable public partnerToken;
    address constant WBNB = 0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c;

    // PRNG
    bytes32 internal keyHash;
    uint256 internal fee;


    event ClosingRequested(uint256 indexed round);
    event ClosedRound(uint256 indexed round, uint256 winner, uint256 random);
    event UTCOffsetUpdated(uint40 indexed newUtcOffset);

    constructor (IERC20Gummy _gummyToken,
                 uint40 _utcOffset,
                 IPancakeRouter02 _router,
                 address _partnerToken,
                 uint256 _intervalInDays,
                 address _VRFCoordinator,
                 address _LINKToken,
                 bytes32 _keyHash,
                 uint256 _fee) VRFConsumerBase(
        _VRFCoordinator,
        _LINKToken
    ) {
        gummyToken = _gummyToken;
        setUtcOffset(_utcOffset);
        router = _router;
        partnerToken = _partnerToken;
        intervalInDays = _intervalInDays;
        keyHash = _keyHash;
        fee = _fee;
        _pause();
    }

    /**
     * @dev Defines the time zone for time-dependent functionalities of the contract.
     *
     * @param _newUtcOffset = duration, in seconds, that should be added to the UTC time.
                E.g, if `_newUtcOffset` is set to `7200`, the time zone will be UTC+2.
     */
    function setUtcOffset(uint40 _newUtcOffset) public onlyOwner {
        require(_newUtcOffset <= (3600 * 24 - 1), "invalid offset");
        utcOffset = 24 * 3600 - _newUtcOffset;
        emit UTCOffsetUpdated(utcOffset);
    }

    /**
     * @dev Defines the `IPancakeRouter02` router that should be used in the contract.
     *
     * @param _newRouter = address of the router.
     */
    function setRouter(IPancakeRouter02 _newRouter) external onlyOwner {
        router = _newRouter;
    }

    /**
     * @dev Returns the overal amounts betted on each team at a given round. Helper function
     * for the front end.
     *
     * @param round = which round to consider.
     */
    function getTeamsAmountsAt(uint256 round) external view returns(uint256[NUM_TEAMS] memory){
        return rounds[round].amountPerTeam;
    }

    /**
     * @dev Returns the amounts betted on each team at a given round by a specific user.
     * Helper function for the front end.
     *
     * @param account = address of the user.
     * @param round = which round to consider.
     */
    function getUserAmountsAt(address account, uint256 round) external view returns(uint256[NUM_TEAMS] memory){
        return rounds[round].amounts[account];
    }

    /**
     * @dev Returns the current day since Unix epoch in UTC+`n` format where `n` depends on
     * the value of `utcOffset`.
     */
    function today() public view returns (uint40) {
        return (uint40(block.timestamp) + utcOffset) / (24 * 60 * 60);
    }

    /**
     * @dev Requests to close the current round. If the request is successful (i.e. the round is
     * finished and closing has not been requested yet), a request to chain.link VRF is made
     * to obtain a pseudo-random number. The contract should be provisioned in LINK tokens prior
     * to making a request.
     *
     * Note that this function can be called by any one as calling this functions provides a service
     * to the protocol. Also, this function is called automatically as part of the function `yumYum`
     * if necessary.
     */
    function requestToCloseCurrentRound() public {
        require(rounds[currentRound].startedOnDay + intervalInDays <= today(), "Round is not finished");
        require(!rounds[currentRound].closingRequested, "Closing already requested");
        bytes32 requestId = _requestRandomNumber();
        requestIdToRound[requestId] = currentRound;
        rounds[currentRound].closingRequested = true;
        emit ClosingRequested(currentRound);
    }

    /**
     * @dev Function called by chain.link's VRF callback to fullfill the PRNG request.
     * This function gets a pseudo-random number and designates a winning team.
     *
     * @param requestId = ID of the PRNG request made to chain.link's VRF.
     * @param randomNumber = pseudo-random number returned by chain.link's VRF.
     */
    function _closeCurrentRound(bytes32 requestId, uint256 randomNumber) private {
        uint256 round = requestIdToRound[requestId];
        require(rounds[round].closingRequested, "Closing should be requested");
        require(!rounds[round].isClosed, "Round already closed");

        uint256 _winningFlavor = _drawWinningFlavor(round, randomNumber);

        rounds[round].isClosed = true;
        rounds[round].winningTeam = _winningFlavor;

        emit ClosedRound(round, _winningFlavor, randomNumber);
    }

    /**
     * @dev Given a round identifier and a pseudo-random number, picks the winning team
     * for the specified round.
     *
     * @param round = which round to consider.
     * @param randomNumber = pseudo-random number returned by chain.link's VRF.
     *
     * Due to they way `_drawWinningFlavor` is implemented, we expect that there will be
     * no winner once every 67 millions of billions of billions of the age of the universe,
     * on average, assuming one draw per day. Thus, we do not bother to address it further
     * than this comment because we won't be alive to see this, probably.
     * Also, `_amountPerTeamCumSum` is not a strictly increasing array when there is as least
     * one team that no-one betted on. In this case, it is possible that this team will win but
     * with a probability no greater than 1/(2^256 - 1). Only the lucky ones will live to see
     * this.
     */
    function _drawWinningFlavor(uint256 round, uint256 randomNumber) internal view returns(uint256) {
        require(rounds[round].totalAmount > 0, "No participants");
        uint256[NUM_TEAMS] storage _amountPerTeam = rounds[round].amountPerTeam;
        uint256[] memory _amountPerTeamCumSum = new uint[](NUM_TEAMS);

        _amountPerTeamCumSum[0] = _amountPerTeam[0];

        for(uint256 i=1; i < NUM_TEAMS; i++){
            _amountPerTeamCumSum[i] = _amountPerTeamCumSum[i-1] + _amountPerTeam[i];
        }

        uint256 _factor = type(uint256).max  / _amountPerTeamCumSum[NUM_TEAMS - 1];

        uint256 _winningFlavor = ArraysModified.findUpperBoundMemory(_amountPerTeamCumSum, randomNumber, _factor);
        return _winningFlavor;
    }

    /**
     * @dev Buys back some tokens of our partner before burning them.
     *
     * @param amountPartnerToBurn = amount of GUMMY to use to buy back the
     * our partner token.
     */
    function _partnerBuyBackAndBurn(uint256 amountPartnerToBurn) private {
        if(amountPartnerToBurn > 0){
            address[] memory _path = new address[](3);

            _path[0] = address(gummyToken);
            _path[1] = WBNB;
            _path[2] = address(partnerToken);

            gummyToken.approve(address(router), amountPartnerToBurn);
            router.swapExactTokensForTokensSupportingFeeOnTransferTokens(
                amountPartnerToBurn,
                0,
                _path,
                BURN_ADDRESS_PARTNER,
                block.timestamp + 600
            );
        }
    }

    /**
     * @dev This function is used to participate in the Flavor teams lottery.
     * When calling this function after a lottery round has ended, it automatically
     * requests the closing of the previous round if it hasn't been requested and
     * starts a new round.
     *
     * @param teamId = on which team to place the bet.
     * @param amount = amount of GUMMY to bet.
     */
    function yumYum(uint256 teamId, uint256 amount) external whenNotPaused {
        require(teamId < NUM_TEAMS, "Invalid team identifier");

        // Close current round if the flavor teams lottery is finished
        if(rounds[currentRound].startedOnDay + intervalInDays <= today()){
            if(!rounds[currentRound].closingRequested && rounds[currentRound].totalAmount > 0){
                requestToCloseCurrentRound();
            }
            currentRound++;
            rounds[currentRound].startedOnDay = today();
        }

        // Limiting maximum volume to 2^128 in order to upper bound the rejection sampling probability
        // by 2.93 * 10^(-39).
        // require(_totalAmountAtRound(currentRound) + amount < 2 ** 128, "Maximum volume attained");
        require(rounds[currentRound].totalAmount + amount < 2 ** 128, "Maximum volume attained");


        // Because the GUMMY token implements a tax mechanisms, notice how many tokens
        // were present in the contract prior to the transfer
        uint256 amountReceived = gummyToken.balanceOf(address(this));
        bool success = gummyToken.transferFrom(msg.sender, address(this), amount);
        require(success, "Transfer was not successful");
        amountReceived = gummyToken.balanceOf(address(this)) - amountReceived;

        rounds[currentRound].amountPerTeam[teamId] += amountReceived;
        rounds[currentRound].amounts[msg.sender][teamId] += amountReceived;
        rounds[currentRound].totalAmount += amountReceived;
    }

    /**
     * @dev Claim gains from a given round.
     *
     * @param round = which round to consider.
     */
    function claim(uint256 round) external nonReentrant {
        require(rounds[round].startedOnDay > 0, "Invalid round");
        require(rounds[round].isClosed, "Round is not closed");
        require(!rounds[round].claimed[msg.sender], "Already claimed");

        uint256 _winningTeam = rounds[round].winningTeam;
        uint256 _userBettedOnWin = rounds[round].amounts[msg.sender][_winningTeam];
        uint256 _bettedOnWin = rounds[round].amountPerTeam[_winningTeam];

        require(_userBettedOnWin > 0, "Nothing to claim");
        rounds[round].claimed[msg.sender] = true;

        uint256 _amountWonBeforeBurn = ((rounds[round].totalAmount) * _userBettedOnWin) / _bettedOnWin;

        // Only apply burn on the user's gain minus his stake on the winning team
        uint256 _taxableAmount = _amountWonBeforeBurn - _userBettedOnWin;

        // Depending on the winning team, the burning mechanims will differ.
        // Determine the percentage of the burn that should happen as buy-back and burn of
        // our partner token.
        uint256 _burnPartnerNum = _winningTeam == PARTNER_TEAM ? PARTNER_TEAM_BURN_NUM_WIN : PARTNER_TEAM_BURN_NUM_LOSS;
        _burnPartnerNum = _winningTeam == PARTNER_TEAM_BIS ? PARTNER_TEAM_BURN_NUM_WIN_BIS : _burnPartnerNum;

        // Total amount to burn...
        uint256 _amountToBurn = (_taxableAmount * BURN_NUMERATOR) / DENOMINATOR;
        // ...of which some should be burnt in our partner token.
        uint256 _amountPartnerBuyBack = (_amountToBurn * _burnPartnerNum) / DENOMINATOR;

        // Burn partner token
        if(_amountPartnerBuyBack > 0){
            _partnerBuyBackAndBurn(_amountPartnerBuyBack);
        }

        gummyToken.burn(_amountToBurn - _amountPartnerBuyBack);
        bool success = gummyToken.transfer(msg.sender, _amountWonBeforeBurn - _amountToBurn);
        require(success, "Transfer was not successful");
    }

    /**
     * @dev Starts the flavor teams lottery.
     */
    function startGenesisRound() external onlyOwner {
        require(!genesisRoundLaunched, "Genesis round already started");
        rounds[currentRound].startedOnDay = today();
        genesisRoundLaunched = true;
        _unpause();
    }

    /**
     * @dev Requests randomness.
     */
    function _requestRandomNumber() virtual internal returns (bytes32 requestId) {
        require(LINK.balanceOf(address(this)) >= fee, "Not enough LINK - fill contract with faucet");
        return requestRandomness(keyHash, fee);
    }

     /**
     * @dev Callback function used by VRF Coordinator.
     */
    function fulfillRandomness(bytes32 requestId, uint256 randomness) internal override {
        _closeCurrentRound(requestId, randomness);
    }

    /**
     * @dev Implements a withdraw function to avoid locking LINK in the contract.
     */
    function withdrawLink() external onlyOwner {
        bool success = LINK.transfer(owner(), LINK.balanceOf(address(this)));
        require(success, "Transfer was not successful");
    }

    /**
     * @dev Pauses functions modified with `whenNotPaused`.
     */
    function pause() external virtual whenNotPaused onlyOwner {
        _pause();
    }

    /**
     * @dev Unpauses functions modified with `whenNotPaused`.
     */
    function unpause() external virtual whenPaused onlyOwner {
        require(genesisRoundLaunched, "Genesis round should be started first");
        _unpause();
    }
}
