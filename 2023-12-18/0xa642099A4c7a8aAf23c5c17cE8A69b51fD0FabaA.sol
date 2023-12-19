// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract AutomationBase {
  error OnlySimulatedBackend();

  /**
   * @notice method that allows it to be simulated via eth_call by checking that
   * the sender is the zero address.
   */
  function preventExecution() internal view {
    if (tx.origin != address(0)) {
      revert OnlySimulatedBackend();
    }
  }

  /**
   * @notice modifier that allows it to be simulated via eth_call by checking
   * that the sender is the zero address.
   */
  modifier cannotExecute() {
    preventExecution();
    _;
  }
}
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./AutomationBase.sol";
import "./interfaces/AutomationCompatibleInterface.sol";

abstract contract AutomationCompatible is AutomationBase, AutomationCompatibleInterface {}
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface AutomationCompatibleInterface {
  /**
   * @notice method that is simulated by the keepers to see if any work actually
   * needs to be performed. This method does does not actually need to be
   * executable, and since it is only ever simulated it can consume lots of gas.
   * @dev To ensure that it is never called, you may want to add the
   * cannotExecute modifier from KeeperBase to your implementation of this
   * method.
   * @param checkData specified in the upkeep registration so it is always the
   * same for a registered upkeep. This can easily be broken down into specific
   * arguments using `abi.decode`, so multiple upkeeps can be registered on the
   * same contract and easily differentiated by the contract.
   * @return upkeepNeeded boolean to indicate whether the keeper should call
   * performUpkeep or not.
   * @return performData bytes that the keeper should call performUpkeep with, if
   * upkeep is needed. If you would like to encode data to decode later, try
   * `abi.encode`.
   */
  function checkUpkeep(bytes calldata checkData) external returns (bool upkeepNeeded, bytes memory performData);

  /**
   * @notice method that is actually executed by the keepers, via the registry.
   * The data returned by the checkUpkeep simulation will be passed into
   * this method to actually be executed.
   * @dev The input to this method should not be trusted, and the caller of the
   * method should not even be restricted to any single registry. Anyone should
   * be able call it, and the input should be validated, there is no guarantee
   * that the data passed in is the performData returned from checkUpkeep. This
   * could happen due to malicious keepers, racing keepers, or simply a state
   * change while the performUpkeep transaction is waiting for confirmation.
   * Always validate the data passed in.
   * @param performData is the data which was passed back from the checkData
   * simulation. If it is encoded, it can easily be decoded into other types by
   * calling `abi.decode`. This data should not be trusted, and should be
   * validated against the contract's current state.
   */
  function performUpkeep(bytes calldata performData) external;
}
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface VRFCoordinatorV2Interface {
  /**
   * @notice Get configuration relevant for making requests
   * @return minimumRequestConfirmations global min for request confirmations
   * @return maxGasLimit global max for request gas limit
   * @return s_provingKeyHashes list of registered key hashes
   */
  function getRequestConfig()
    external
    view
    returns (
      uint16,
      uint32,
      bytes32[] memory
    );

  /**
   * @notice Request a set of random words.
   * @param keyHash - Corresponds to a particular oracle job which uses
   * that key for generating the VRF proof. Different keyHash's have different gas price
   * ceilings, so you can select a specific one to bound your maximum per request cost.
   * @param subId  - The ID of the VRF subscription. Must be funded
   * with the minimum subscription balance required for the selected keyHash.
   * @param minimumRequestConfirmations - How many blocks you'd like the
   * oracle to wait before responding to the request. See SECURITY CONSIDERATIONS
   * for why you may want to request more. The acceptable range is
   * [minimumRequestBlockConfirmations, 200].
   * @param callbackGasLimit - How much gas you'd like to receive in your
   * fulfillRandomWords callback. Note that gasleft() inside fulfillRandomWords
   * may be slightly less than this amount because of gas used calling the function
   * (argument decoding etc.), so you may need to request slightly more than you expect
   * to have inside fulfillRandomWords. The acceptable range is
   * [0, maxGasLimit]
   * @param numWords - The number of uint256 random values you'd like to receive
   * in your fulfillRandomWords callback. Note these numbers are expanded in a
   * secure way by the VRFCoordinator from a single random value supplied by the oracle.
   * @return requestId - A unique identifier of the request. Can be used to match
   * a request to a response in fulfillRandomWords.
   */
  function requestRandomWords(
    bytes32 keyHash,
    uint64 subId,
    uint16 minimumRequestConfirmations,
    uint32 callbackGasLimit,
    uint32 numWords
  ) external returns (uint256 requestId);

  /**
   * @notice Create a VRF subscription.
   * @return subId - A unique subscription id.
   * @dev You can manage the consumer set dynamically with addConsumer/removeConsumer.
   * @dev Note to fund the subscription, use transferAndCall. For example
   * @dev  LINKTOKEN.transferAndCall(
   * @dev    address(COORDINATOR),
   * @dev    amount,
   * @dev    abi.encode(subId));
   */
  function createSubscription() external returns (uint64 subId);

  /**
   * @notice Get a VRF subscription.
   * @param subId - ID of the subscription
   * @return balance - LINK balance of the subscription in juels.
   * @return reqCount - number of requests for this subscription, determines fee tier.
   * @return owner - owner of the subscription.
   * @return consumers - list of consumer address which are able to use this subscription.
   */
  function getSubscription(uint64 subId)
    external
    view
    returns (
      uint96 balance,
      uint64 reqCount,
      address owner,
      address[] memory consumers
    );

  /**
   * @notice Request subscription owner transfer.
   * @param subId - ID of the subscription
   * @param newOwner - proposed new owner of the subscription
   */
  function requestSubscriptionOwnerTransfer(uint64 subId, address newOwner) external;

  /**
   * @notice Request subscription owner transfer.
   * @param subId - ID of the subscription
   * @dev will revert if original owner of subId has
   * not requested that msg.sender become the new owner.
   */
  function acceptSubscriptionOwnerTransfer(uint64 subId) external;

  /**
   * @notice Add a consumer to a VRF subscription.
   * @param subId - ID of the subscription
   * @param consumer - New consumer which can use the subscription
   */
  function addConsumer(uint64 subId, address consumer) external;

  /**
   * @notice Remove a consumer from a VRF subscription.
   * @param subId - ID of the subscription
   * @param consumer - Consumer to remove from the subscription
   */
  function removeConsumer(uint64 subId, address consumer) external;

  /**
   * @notice Cancel a subscription
   * @param subId - ID of the subscription
   * @param to - Where to send the remaining LINK to
   */
  function cancelSubscription(uint64 subId, address to) external;

  /*
   * @notice Check to see if there exists a request commitment consumers
   * for all consumers and keyhashes for a given sub.
   * @param subId - ID of the subscription
   * @return true if there exists at least one unfulfilled request for the subscription, false
   * otherwise.
   */
  function pendingRequestExists(uint64 subId) external view returns (bool);
}
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

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
 * @dev simple access to a verifiable source of randomness. It ensures 2 things:
 * @dev 1. The fulfillment came from the VRFCoordinator
 * @dev 2. The consumer contract implements fulfillRandomWords.
 * *****************************************************************************
 * @dev USAGE
 *
 * @dev Calling contracts must inherit from VRFConsumerBase, and can
 * @dev initialize VRFConsumerBase's attributes in their constructor as
 * @dev shown:
 *
 * @dev   contract VRFConsumer {
 * @dev     constructor(<other arguments>, address _vrfCoordinator, address _link)
 * @dev       VRFConsumerBase(_vrfCoordinator) public {
 * @dev         <initialization with other arguments goes here>
 * @dev       }
 * @dev   }
 *
 * @dev The oracle will have given you an ID for the VRF keypair they have
 * @dev committed to (let's call it keyHash). Create subscription, fund it
 * @dev and your consumer contract as a consumer of it (see VRFCoordinatorInterface
 * @dev subscription management functions).
 * @dev Call requestRandomWords(keyHash, subId, minimumRequestConfirmations,
 * @dev callbackGasLimit, numWords),
 * @dev see (VRFCoordinatorInterface for a description of the arguments).
 *
 * @dev Once the VRFCoordinator has received and validated the oracle's response
 * @dev to your request, it will call your contract's fulfillRandomWords method.
 *
 * @dev The randomness argument to fulfillRandomWords is a set of random words
 * @dev generated from your requestId and the blockHash of the request.
 *
 * @dev If your contract could have concurrent requests open, you can use the
 * @dev requestId returned from requestRandomWords to track which response is associated
 * @dev with which randomness request.
 * @dev See "SECURITY CONSIDERATIONS" for principles to keep in mind,
 * @dev if your contract could have multiple requests in flight simultaneously.
 *
 * @dev Colliding `requestId`s are cryptographically impossible as long as seeds
 * @dev differ.
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
 * @dev Since the block hash of the block which contains the requestRandomness
 * @dev call is mixed into the input to the VRF *last*, a sufficiently powerful
 * @dev miner could, in principle, fork the blockchain to evict the block
 * @dev containing the request, forcing the request to be included in a
 * @dev different block with a different hash, and therefore a different input
 * @dev to the VRF. However, such an attack would incur a substantial economic
 * @dev cost. This cost scales with the number of blocks the VRF oracle waits
 * @dev until it calls responds to a request. It is for this reason that
 * @dev that you can signal to an oracle you'd like them to wait longer before
 * @dev responding to the request (however this is not enforced in the contract
 * @dev and so remains effective only in the case of unmodified oracle software).
 */
abstract contract VRFConsumerBaseV2 {
  error OnlyCoordinatorCanFulfill(address have, address want);
  address private immutable vrfCoordinator;

  /**
   * @param _vrfCoordinator address of VRFCoordinator contract
   */
  constructor(address _vrfCoordinator) {
    vrfCoordinator = _vrfCoordinator;
  }

  /**
   * @notice fulfillRandomness handles the VRF response. Your contract must
   * @notice implement it. See "SECURITY CONSIDERATIONS" above for important
   * @notice principles to keep in mind when implementing your fulfillRandomness
   * @notice method.
   *
   * @dev VRFConsumerBaseV2 expects its subcontracts to have a method with this
   * @dev signature, and will call it once it has verified the proof
   * @dev associated with the randomness. (It is triggered via a call to
   * @dev rawFulfillRandomness, below.)
   *
   * @param requestId The Id initially returned by requestRandomness
   * @param randomWords the VRF output expanded to the requested number of words
   */
  function fulfillRandomWords(uint256 requestId, uint256[] memory randomWords) internal virtual;

  // rawFulfillRandomness is called by VRFCoordinator when it receives a valid VRF
  // proof. rawFulfillRandomness then calls fulfillRandomness, after validating
  // the origin of the call
  function rawFulfillRandomWords(uint256 requestId, uint256[] memory randomWords) external {
    if (msg.sender != vrfCoordinator) {
      revert OnlyCoordinatorCanFulfill(msg.sender, vrfCoordinator);
    }
    fulfillRandomWords(requestId, randomWords);
  }
}
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.7.0) (access/Ownable.sol)

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
     * `onlyOwner` functions anymore. Can only be called by the current owner.
     *
     * NOTE: Renouncing ownership will leave the contract without an owner,
     * thereby removing any functionality that is only available to the owner.
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
// OpenZeppelin Contracts (last updated v4.6.0) (token/ERC20/IERC20.sol)

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
    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);
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
// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity ^0.8.19;

import {ConsumerConfig} from "../lib/configs/VRFConsumerConfig.sol";

interface IConfiguration {
    function setConsumerConfig(ConsumerConfig calldata _newConfig) external;

    function setSubscriptionId(uint64 _subscriptionId) external;

    function setCallbackGasLimit(uint32 _callbackGasLimit) external;

    function setRequestConfirmations(uint16 _requestConfirmations) external;

    function setGasPriceKey(bytes32 _gasPriceKey) external;

    function setTeamAddress(address _newAddress) external;

    function setTeamAccumulationAddress(address _newAddress) external;

    function setTreasuryAddress(address _newAddress) external;

    function setTreasuryAccumulationAddress(address _newAddress) external;

    function setFeeConfig(uint256 _feeConfigRaw) external;

    function switchSmashTimeLotteryFlag(bool flag) external;

    function switchHoldersLotteryFlag(bool flag) external;

    function switchDonationsLotteryFlag(bool flag) external;

    function excludeFromFee(address account) external;

    function includeInFee(address account) external;

    function setHoldersLotteryTxTrigger(uint64 _txAmount) external;

    function setHoldersLotteryMinPercent(uint256 _minPercent) external;

    function setDonationAddress(address _donationAddress) external;

    function setMinimalDonation(uint256 _minimalDonation) external;

    function setDonationConversionThreshold(uint256 _donationConversionThreshold) external;

    function setSmashTimeLotteryConversionThreshold(
        uint256 _smashTimeLotteryConversionThreshold
    ) external;

    function setSmashTimeLotteryTriggerThreshold(
        uint256 _smashTimeLotteryTriggerThreshold
    ) external;

    function setFee(uint256 _fee) external;

    function setMinimumDonationEntries(uint64 _minimumEntries) external;

    function burnFeePercent() external view returns (uint256);

    function liquidityFeePercent() external view returns (uint256);

    function distributionFeePercent() external view returns (uint256);

    function treasuryFeePercent() external view returns (uint256);

    function devFeePercent() external view returns (uint256);

    function smashTimeLotteryPrizeFeePercent() external view returns (uint256);

    function holdersLotteryPrizeFeePercent() external view returns (uint256);

    function donationLotteryPrizeFeePercent() external view returns (uint256);

    function isExcludedFromFee(address account) external view returns (bool);

    function isExcludedFromReward(address account) external view returns (bool);

    function smashTimeLotteryEnabled() external view returns (bool);

    function smashTimeLotteryConversionThreshold() external view returns (uint256);

    function smashTimeLotteryTriggerThreshold() external view returns (uint256);

    function holdersLotteryEnabled() external view returns (bool);

    function holdersLotteryTxTrigger() external view returns (uint64);

    function holdersLotteryMinPercent() external view returns (uint256);

    function donationAddress() external view returns (address);

    function donationsLotteryEnabled() external view returns (bool);

    function minimumDonationEntries() external view returns (uint64);

    function minimalDonation() external view returns (uint256);

    function donationConversionThreshold() external view returns (uint256);

    function subscriptionId() external view returns (uint64);

    function callbackGasLimit() external view returns (uint32);

    function requestConfirmations() external view returns (uint16);

    function gasPriceKey() external view returns (bytes32);
}
// solhint-disable
// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.5.0;

interface IPancakeFactory {
    event PairCreated(address indexed token0, address indexed token1, address pair, uint256);

    function feeTo() external view returns (address);

    function feeToSetter() external view returns (address);

    function getPair(address tokenA, address tokenB) external view returns (address pair);

    function allPairs(uint256) external view returns (address pair);

    function allPairsLength() external view returns (uint256);

    function createPair(address tokenA, address tokenB) external returns (address pair);

    function setFeeTo(address) external;

    function setFeeToSetter(address) external;

    function INIT_CODE_PAIR_HASH() external view returns (bytes32);
}
// solhint-disable
// SPDX-License-Identifier: GPL-3.0
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
    ) external returns (uint256 amountA, uint256 amountB, uint256 liquidity);

    function addLiquidityETH(
        address token,
        uint256 amountTokenDesired,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline
    ) external payable returns (uint256 amountToken, uint256 amountETH, uint256 liquidity);

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

    function getAmountsOut(
        uint256 amountIn,
        address[] calldata path
    ) external view returns (uint256[] memory amounts);

    function getAmountsIn(
        uint256 amountOut,
        address[] calldata path
    ) external view returns (uint256[] memory amounts);
}
// solhint-disable
// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.6.2;

import {IPancakeRouter01} from "./IPancakeRouter01.sol";

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
// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity ^0.8.19;

import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {IConfiguration} from "../../interfaces/IConfiguration.sol";
import {ConsumerConfig, VRFConsumerConfig} from "./VRFConsumerConfig.sol";
import {DistributionConfig, ProtocolConfig} from "./ProtocolConfig.sol";
import {LotteryConfig, LotteryEngineConfig} from "./LotteryEngineConfig.sol";

abstract contract Configuration is
    IConfiguration,
    VRFConsumerConfig,
    ProtocolConfig,
    LotteryEngineConfig,
    Ownable
{
    uint256 public constant FEE_CAP = 500;

    uint256 internal immutable _creationTime;
    uint256 public fee;

    constructor(
        uint256 _fee,
        ConsumerConfig memory _consumerConfig,
        DistributionConfig memory _distributionConfig,
        LotteryConfig memory _lotteryConfig
    )
        VRFConsumerConfig(_consumerConfig)
        ProtocolConfig(_distributionConfig)
        LotteryEngineConfig(_lotteryConfig)
    {
        fee = _fee;
        _creationTime = block.timestamp;
    }

    function _calcFeePercent() internal view returns (uint256) {
        uint256 currentFees = fee;

        if (_lotteryConfig.smashTimeLotteryEnabled) {
            currentFees *= 2;
        }

        return currentFees >= FEE_CAP ? FEE_CAP : currentFees;
    }

    function setConsumerConfig(ConsumerConfig calldata _newConfig) external onlyOwner {
        _setConfig(_newConfig);
    }

    function setSubscriptionId(uint64 _subscriptionId) external onlyOwner {
        _setSubscriptionId(_subscriptionId);
    }

    function setCallbackGasLimit(uint32 _callbackGasLimit) external onlyOwner {
        _setCallbackGasLimit(_callbackGasLimit);
    }

    function setRequestConfirmations(uint16 _requestConfirmations) external onlyOwner {
        _setRequestConfirmations(_requestConfirmations);
    }

    function setGasPriceKey(bytes32 _gasPriceKey) external onlyOwner {
        _setGasPriceKey(_gasPriceKey);
    }

    function setHolderLotteryPrizePoolAddress(address _newAddress) external onlyOwner {
        _setHolderLotteryPrizePoolAddress(_newAddress);
    }

    function setSmashTimeLotteryPrizePoolAddress(address _newAddress) external onlyOwner {
        _setSmashTimeLotteryPrizePoolAddress(_newAddress);
    }

    function setDonationLotteryPrizePoolAddress(address _newAddress) external onlyOwner {
        _setDonationLotteryPrizePoolAddress(_newAddress);
    }

    function setTeamAddress(address _newAddress) external onlyOwner {
        _setTeamAddress(_newAddress);
    }

    function setTeamAccumulationAddress(address _newAddress) external onlyOwner {
        _setTeamAccumulationAddress(_newAddress);
    }

    function setTreasuryAddress(address _newAddress) external onlyOwner {
        _setTreasuryAddress(_newAddress);
    }

    function setTreasuryAccumulationAddress(address _newAddress) external onlyOwner {
        _setTreasuryAccumulationAddress(_newAddress);
    }

    function setFeeConfig(uint256 _feeConfigRaw) external onlyOwner {
        _setFeeConfig(_feeConfigRaw);
    }

    function switchSmashTimeLotteryFlag(bool flag) external onlyOwner {
        _switchSmashTimeLotteryFlag(flag);
    }

    function switchHoldersLotteryFlag(bool flag) external onlyOwner {
        _switchHoldersLotteryFlag(flag);
    }

    function switchDonationsLotteryFlag(bool flag) external onlyOwner {
        _switchDonationsLotteryFlag(flag);
    }

    function excludeFromFee(address account) external onlyOwner {
        _isExcludedFromFee[account] = true;
    }

    function includeInFee(address account) external onlyOwner {
        _isExcludedFromFee[account] = false;
    }

    function setHoldersLotteryTxTrigger(uint64 _txAmount) external onlyOwner {
        _setHoldersLotteryTxTrigger(_txAmount);
    }

    function setHoldersLotteryMinPercent(uint256 _minPercent) external onlyOwner {
        _setHoldersLotteryMinPercent(_minPercent);
    }

    function setDonationAddress(address _donationAddress) external onlyOwner {
        _setDonationAddress(_donationAddress);
    }

    function setMinimalDonation(uint256 _minimalDonation) external onlyOwner {
        _setMinimanDonation(_minimalDonation);
    }

    function setDonationConversionThreshold(
        uint256 _donationConversionThreshold
    ) external onlyOwner {
        _setDonationConversionThreshold(_donationConversionThreshold);
    }

    function setSmashTimeLotteryConversionThreshold(
        uint256 _smashTimeLotteryConversionThreshold
    ) external onlyOwner {
        _setSmashTimeLotteryConversionThreshold(_smashTimeLotteryConversionThreshold);
    }

    function setSmashTimeLotteryTriggerThreshold(
        uint256 _smashTimeLotteryTriggerThreshold
    ) external onlyOwner {
        _setSmashTimeLotteryTriggerThreshold(_smashTimeLotteryTriggerThreshold);
    }

    function setFee(uint256 _fee) external onlyOwner {
        fee = _fee;
    }

    function setMinimumDonationEntries(uint64 _minimumEntries) external onlyOwner {
        _setMinimumDonationEntries(_minimumEntries);
    }

    function burnFeePercent() external view returns (uint256) {
        return _fees.burnFeePercent(_calcFeePercent());
    }

    function liquidityFeePercent() external view returns (uint256) {
        return _fees.liquidityFeePercent(_calcFeePercent());
    }

    function distributionFeePercent() external view returns (uint256) {
        return _fees.distributionFeePercent(_calcFeePercent());
    }

    function treasuryFeePercent() external view returns (uint256) {
        return _fees.treasuryFeePercent(_calcFeePercent());
    }

    function devFeePercent() external view returns (uint256) {
        return _fees.devFeePercent(_calcFeePercent());
    }

    function smashTimeLotteryPrizeFeePercent() public view returns (uint256) {
        return _fees.smashTimeLotteryPrizeFeePercent(_calcFeePercent());
    }

    function holdersLotteryPrizeFeePercent() public view returns (uint256) {
        return _fees.holdersLotteryPrizeFeePercent(_calcFeePercent());
    }

    function donationLotteryPrizeFeePercent() public view returns (uint256) {
        return _fees.donationLotteryPrizeFeePercent(_calcFeePercent());
    }

    function isExcludedFromFee(address account) external view returns (bool) {
        return _isExcludedFromFee[account];
    }

    function isExcludedFromReward(address account) external view returns (bool) {
        return _isExcludedFromReward[account];
    }

    function smashTimeLotteryEnabled() external view returns (bool) {
        return _lotteryConfig.smashTimeLotteryEnabled;
    }

    function smashTimeLotteryConversionThreshold() external view returns (uint256) {
        return _lotteryConfig.smashTimeLotteryConversionThreshold;
    }

    function smashTimeLotteryTriggerThreshold() external view returns (uint256) {
        return _lotteryConfig.smashTimeLotteryTriggerThreshold;
    }

    function holdersLotteryEnabled() external view returns (bool) {
        return _lotteryConfig.holdersLotteryEnabled;
    }

    function holdersLotteryTxTrigger() external view returns (uint64) {
        return _lotteryConfig.holdersLotteryTxTrigger;
    }

    function holdersLotteryMinPercent() external view returns (uint256) {
        return _lotteryConfig.holdersLotteryMinPercent;
    }

    function donationAddress() external view returns (address) {
        return _lotteryConfig.donationAddress;
    }

    function donationsLotteryEnabled() external view returns (bool) {
        return _lotteryConfig.donationsLotteryEnabled;
    }

    function minimumDonationEntries() external view returns (uint64) {
        return _lotteryConfig.minimumDonationEntries;
    }

    function minimalDonation() external view returns (uint256) {
        return _lotteryConfig.minimalDonation;
    }

    function donationConversionThreshold() external view returns (uint256) {
        return _lotteryConfig.donationConversionThreshold;
    }

    function subscriptionId() external view returns (uint64) {
        return _consumerConfig.subscriptionId;
    }

    function callbackGasLimit() external view returns (uint32) {
        return _consumerConfig.callbackGasLimit;
    }

    function requestConfirmations() external view returns (uint16) {
        return _consumerConfig.requestConfirmations;
    }

    function gasPriceKey() external view returns (bytes32) {
        return _consumerConfig.gasPriceKey;
    }
}
// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity ^0.8.19;

import {LotteryConfig} from "../ConstantsAndTypes.sol";

abstract contract LotteryEngineConfig {
    LotteryConfig internal _lotteryConfig;

    constructor(LotteryConfig memory _config) {
        _lotteryConfig = _config;
    }

    function _switchSmashTimeLotteryFlag(bool _flag) internal {
        _lotteryConfig.smashTimeLotteryEnabled = _flag;
    }

    function _setSmashTimeLotteryConversionThreshold(
        uint256 _smashTimeLotteryConversionThreshold
    ) internal {
        _lotteryConfig.smashTimeLotteryConversionThreshold = _smashTimeLotteryConversionThreshold;
    }

    function _setSmashTimeLotteryTriggerThreshold(
        uint256 _smashTimeLotteryTriggerThreshold
    ) internal {
        _lotteryConfig.smashTimeLotteryTriggerThreshold = _smashTimeLotteryTriggerThreshold;
    }

    function _switchHoldersLotteryFlag(bool _flag) internal {
        _lotteryConfig.holdersLotteryEnabled = _flag;
    }

    function _setHoldersLotteryTxTrigger(uint64 _txAmount) internal {
        _lotteryConfig.holdersLotteryTxTrigger = _txAmount;
    }

    function _setHoldersLotteryMinPercent(uint256 _minPercent) internal {
        _lotteryConfig.holdersLotteryMinPercent = _minPercent;
    }

    function _setDonationAddress(address _donationAddress) internal {
        _lotteryConfig.donationAddress = _donationAddress;
    }

    function _switchDonationsLotteryFlag(bool _flag) internal {
        _lotteryConfig.donationsLotteryEnabled = _flag;
    }

    function _setMinimanDonation(uint256 _minimalDonation) internal {
        _lotteryConfig.minimalDonation = _minimalDonation;
    }

    function _setDonationConversionThreshold(uint256 _donationConversionThreshold) internal {
        _lotteryConfig.donationConversionThreshold = _donationConversionThreshold;
    }

    function _setMinimumDonationEntries(uint64 _minimumEntries) internal {
        _lotteryConfig.minimumDonationEntries = _minimumEntries;
    }
}
// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity ^0.8.19;

import {Fee, DistributionConfig, PRECISION} from "../ConstantsAndTypes.sol";

/**

*/
abstract contract ProtocolConfig {
    address public holderLotteryPrizePoolAddress;
    address public smashTimeLotteryPrizePoolAddress;
    address public donationLotteryPrizePoolAddress;
    address public teamFeesAccumulationAddress;
    address public treasuryFeesAccumulationAddress;
    address public teamAddress;
    address public treasuryAddress;

    mapping(address => bool) internal _isExcludedFromFee;
    mapping(address => bool) internal _isExcludedFromReward;

    Fee internal _fees;

    constructor(DistributionConfig memory _config) {
        holderLotteryPrizePoolAddress = _config.holderLotteryPrizePoolAddress;
        smashTimeLotteryPrizePoolAddress = _config.smashTimeLotteryPrizePoolAddress;
        donationLotteryPrizePoolAddress = _config.donationLotteryPrizePoolAddress;
        teamFeesAccumulationAddress = _config.teamFeesAccumulationAddress;
        treasuryFeesAccumulationAddress = _config.treasuryFeesAccumulationAddress;
        teamAddress = _config.teamAddress;
        treasuryAddress = _config.treasuryAddress;
        _fees = _config.compact();
    }

    function _setHolderLotteryPrizePoolAddress(address _newAddress) internal {
        holderLotteryPrizePoolAddress = _newAddress;
    }

    function _setSmashTimeLotteryPrizePoolAddress(address _newAddress) internal {
        smashTimeLotteryPrizePoolAddress = _newAddress;
    }

    function _setDonationLotteryPrizePoolAddress(address _newAddress) internal {
        donationLotteryPrizePoolAddress = _newAddress;
    }

    function _setTeamAddress(address _newAddress) internal {
        teamAddress = _newAddress;
    }

    function _setTeamAccumulationAddress(address _newAddress) internal {
        teamFeesAccumulationAddress = _newAddress;
    }

    function _setTreasuryAccumulationAddress(address _newAddress) internal {
        treasuryFeesAccumulationAddress = _newAddress;
    }

    function _setTreasuryAddress(address _newAddress) internal {
        treasuryAddress = _newAddress;
    }

    function _setFeeConfig(uint256 _feeConfigRaw) internal {
        _fees = Fee.wrap(_feeConfigRaw);
    }
}
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {ConsumerConfig} from "../ConstantsAndTypes.sol";

/**
	@title VRF Consumer Config
	@author shialabeoufsflag

	This contract is a component of the VRF Consumer contract, which contains
	internal logic for managing Consumer variables.
*/
abstract contract VRFConsumerConfig {
    ConsumerConfig internal _consumerConfig;

    /// Create an instance of the VRF consumer configuration contract.
    constructor(ConsumerConfig memory _config) {
        _consumerConfig = _config;
    }

    function _setConfig(ConsumerConfig calldata _newConfig) internal {
        _consumerConfig = _newConfig;
    }

    function _setSubscriptionId(uint64 _subscriptionId) internal {
        _consumerConfig.subscriptionId = _subscriptionId;
    }

    function _setCallbackGasLimit(uint32 _callbackGasLimit) internal {
        _consumerConfig.callbackGasLimit = _callbackGasLimit;
    }

    function _setRequestConfirmations(uint16 _requestConfirmations) internal {
        _consumerConfig.requestConfirmations = _requestConfirmations;
    }

    function _setGasPriceKey(bytes32 _gasPriceKey) internal {
        _consumerConfig.gasPriceKey = _gasPriceKey;
    }
}
// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity ^0.8.19;

type Fee is uint256;

/**
	Packed configuration variables of the VRF consumer contract.

	subscriptionId - subscription id.
	callbackGasLimit - the maximum gas limit supported for a fulfillRandomWords callback.
	requestConfirmations - the minimum number of confirmation blocks on VRF requests before oracles respond.
	gasPriceKey - Coordinator contract selects callback gas price limit by this key.
*/
struct ConsumerConfig {
    uint64 subscriptionId;
    uint32 callbackGasLimit;
    uint16 requestConfirmations;
    bytes32 gasPriceKey;
}

struct DistributionConfig {
    address holderLotteryPrizePoolAddress;
    address smashTimeLotteryPrizePoolAddress;
    address donationLotteryPrizePoolAddress;
    address teamAddress;
    address treasuryAddress;
    address teamFeesAccumulationAddress;
    address treasuryFeesAccumulationAddress;
    uint32 burnFee;
    uint32 liquidityFee;
    uint32 distributionFee;
    uint32 treasuryFee;
    uint32 devFee;
    uint32 smashTimeLotteryPrizeFee;
    uint32 holdersLotteryPrizeFee;
    uint32 donationLotteryPrizeFee;
}

struct LotteryConfig {
    bool smashTimeLotteryEnabled;
    uint256 smashTimeLotteryConversionThreshold;
    uint256 smashTimeLotteryTriggerThreshold;
    bool holdersLotteryEnabled;
    uint64 holdersLotteryTxTrigger;
    uint256 holdersLotteryMinPercent;
    address donationAddress;
    bool donationsLotteryEnabled;
    uint64 minimumDonationEntries;
    uint256 minimalDonation;
    uint256 donationConversionThreshold;
}

struct Holders {
    address[] first;
    address[] second;
    mapping(address => uint256[2]) idx;
}

enum LotteryType {
    NONE,
    JACKPOT,
    HOLDERS,
    DONATION,
    FINISHED_JACKPOT,
    FINISHED_HOLDERS,
    FINISHED_DONATION
}

enum JackpotEntry {
    NONE,
    USD_100,
    USD_200,
    USD_300,
    USD_400,
    USD_500,
    USD_600,
    USD_700,
    USD_800,
    USD_900,
    USD_1000
}

struct RandomWords {
    uint256 first;
    uint256 second;
}

address constant DEAD_ADDRESS = address(0);
uint256 constant MAX_UINT256 = type(uint256).max;
uint256 constant DAY_ONE_LIMIT = 50;
uint256 constant DAY_TWO_LIMIT = 100;
uint256 constant DAY_THREE_LIMIT = 150;
uint256 constant SEVENTY_FIVE_PERCENTS = 7500;
uint256 constant TWENTY_FIVE_PERCENTS = 2500;
uint256 constant PRECISION = 10_000;
uint256 constant ONE_WORD = 0x20;
uint256 constant TWENTY_FIVE_BITS = 25;

using TypesHelpers for Fee global;
using TypesHelpers for Holders global;
using TypesHelpers for DistributionConfig global;
using TypesHelpers for LotteryConfig global;
using TypesHelpers for LotteryType global;

library TypesHelpers {
    function compact(DistributionConfig memory _config) internal pure returns (Fee) {
        uint256 raw = _config.burnFee;
        raw = (raw << 32) + _config.liquidityFee;
        raw = (raw << 32) + _config.distributionFee;
        raw = (raw << 32) + _config.treasuryFee;
        raw = (raw << 32) + _config.devFee;
        raw = (raw << 32) + _config.smashTimeLotteryPrizeFee;
        raw = (raw << 32) + _config.holdersLotteryPrizeFee;
        raw = (raw << 32) + _config.donationLotteryPrizeFee;
        return Fee.wrap(raw);
    }

    function burnFeePercent(Fee feeConfig, uint256 fee) internal pure returns (uint256) {
        return (fee * uint32(Fee.unwrap(feeConfig) >> 224)) / PRECISION;
    }

    function liquidityFeePercent(Fee feeConfig, uint256 fee) internal pure returns (uint256) {
        return (fee * uint32(Fee.unwrap(feeConfig) >> 192)) / PRECISION;
    }

    function distributionFeePercent(Fee feeConfig, uint256 fee) internal pure returns (uint256) {
        return (fee * uint32(Fee.unwrap(feeConfig) >> 160)) / PRECISION;
    }

    function treasuryFeePercent(Fee feeConfig, uint256 fee) internal pure returns (uint256) {
        return (fee * uint32(Fee.unwrap(feeConfig) >> 128)) / PRECISION;
    }

    function devFeePercent(Fee feeConfig, uint256 fee) internal pure returns (uint256) {
        return (fee * uint32(Fee.unwrap(feeConfig) >> 96)) / PRECISION;
    }

    function smashTimeLotteryPrizeFeePercent(
        Fee feeConfig,
        uint256 fee
    ) internal pure returns (uint256) {
        return (fee * uint32(Fee.unwrap(feeConfig) >> 64)) / PRECISION;
    }

    function holdersLotteryPrizeFeePercent(
        Fee feeConfig,
        uint256 fee
    ) internal pure returns (uint256) {
        return (fee * uint32(Fee.unwrap(feeConfig) >> 32)) / PRECISION;
    }

    function donationLotteryPrizeFeePercent(
        Fee feeConfig,
        uint256 fee
    ) internal pure returns (uint256) {
        return (fee * uint32(Fee.unwrap(feeConfig))) / PRECISION;
    }

    function allTickets(Holders storage _holders) internal view returns (address[] memory) {
        address[] memory merged = new address[](_holders.first.length + _holders.second.length);
        for (uint256 i = 0; i < merged.length; ++i) {
            merged[i] = i < _holders.first.length
                ? _holders.first[i]
                : _holders.second[i - _holders.first.length];
        }
        return merged;
    }

    function addFirst(Holders storage _holders, address _holder) internal {
        if (!existsFirst(_holders, _holder)) {
            _holders.first.push(_holder);
            _holders.idx[_holder][0] = _holders.first.length;
        }
    }

    function removeFirst(Holders storage _holders, address _holder) internal {
        uint256 holderIdx = _holders.idx[_holder][0];

        if (holderIdx == 0) {
            return;
        }

        uint256 arrayIdx = holderIdx - 1;
        uint256 lastIdx = _holders.first.length - 1;

        if (arrayIdx != lastIdx) {
            address lastElement = _holders.first[lastIdx];
            _holders.first[arrayIdx] = lastElement;
            _holders.idx[lastElement][0] = holderIdx;
        }

        _holders.first.pop();
        delete _holders.idx[_holder];
    }

    function existsFirst(Holders storage _holders, address _holder) internal view returns (bool) {
        return _holders.idx[_holder][0] != 0;
    }

    function addSecond(Holders storage _holders, address _holder) internal {
        if (!existsSecond(_holders, _holder)) {
            _holders.second.push(_holder);
            _holders.idx[_holder][1] = _holders.second.length;
        }
    }

    function removeSecond(Holders storage _holders, address _holder) internal {
        uint256 holderIdx = _holders.idx[_holder][1];

        if (holderIdx == 0) {
            return;
        }

        uint256 arrayIdx = holderIdx - 1;
        uint256 lastIdx = _holders.second.length - 1;

        if (arrayIdx != lastIdx) {
            address lastElement = _holders.second[lastIdx];
            _holders.second[arrayIdx] = lastElement;
            _holders.idx[lastElement][1] = holderIdx;
        }

        _holders.second.pop();
        _holders.idx[_holder][1] = 0; // Reset the index to indicate removal
    }

    function existsSecond(Holders storage _holders, address _holder) internal view returns (bool) {
        return _holders.idx[_holder][1] != 0;
    }

    // Function to get the number of tickets for a token holder
    function getNumberOfTickets(
        Holders storage _holders,
        address _holder
    ) internal view returns (uint256) {
        uint256 tickets = 0;

        // Check if the holder is in the first array
        if (_holders.idx[_holder][0] > 0) {
            // Subtract 1 because array indices start from 0, but we stored starting from 1
            uint256 indexInFirst = _holders.idx[_holder][0] - 1;
            if (indexInFirst < _holders.first.length && _holders.first[indexInFirst] == _holder) {
                tickets += 1;
            }
        }
        // Check if the holder is in the second array
        if (_holders.idx[_holder][1] > 0) {
            // Subtract 1 because array indices start from 0, but we stored starting from 1
            uint256 indexInSecond = _holders.idx[_holder][1] - 1;
            if (
                indexInSecond < _holders.second.length && _holders.second[indexInSecond] == _holder
            ) {
                tickets += 1;
            }
        }

        return tickets;
    }
}
// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity ^0.8.19;

import {IPancakeRouter02} from "../interfaces/IPancakeRouter02.sol";
import {IPancakeFactory} from "../interfaces/IPancakeFactory.sol";

abstract contract PancakeAdapter {
    address internal _USDT_ADDRESS;
    address internal _WBNB_ADDRESS;

    IPancakeRouter02 public immutable PANCAKE_ROUTER;

    address public immutable PANCAKE_PAIR;

    constructor(address _routerAddress, address _wbnbAddress, address _usdtAddress) {
        _WBNB_ADDRESS = _wbnbAddress;
        _USDT_ADDRESS = _usdtAddress;
        PANCAKE_ROUTER = IPancakeRouter02(_routerAddress);
        PANCAKE_PAIR = _createPancakeSwapPair();
    }

    function _createPancakeSwapPair() internal returns (address) {
        return IPancakeFactory(PANCAKE_ROUTER.factory()).createPair(address(this), _WBNB_ADDRESS);
    }

    function _addLiquidity(uint256 tokenAmount, uint256 bnbAmount, address _to) internal {
        PANCAKE_ROUTER.addLiquidityETH{value: bnbAmount}(
            address(this),
            tokenAmount,
            0, // slippage is unavoidable
            0, // slippage is unavoidable
            _to,
            block.timestamp
        );
    }

    function _swapTokensForBNB(uint256 _tokensAmount) internal returns (uint256 bnbAmount) {
        uint256 balanceBeforeSwap = address(this).balance;
        // generate the pancakeswap pair path of Token -> BNB
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = _WBNB_ADDRESS;

        // make the swap
        PANCAKE_ROUTER.swapExactTokensForETHSupportingFeeOnTransferTokens(
            _tokensAmount,
            0, // accept any amount of ETH
            path,
            address(this),
            block.timestamp
        );

        unchecked {
            bnbAmount = address(this).balance - balanceBeforeSwap;
        }
    }

    function _swapTokensForBNB(uint256 _tokensAmount, address _to) internal {
        // generate the pancakeswap pair path of Token -> BNB
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = _WBNB_ADDRESS;

        // make the swap
        PANCAKE_ROUTER.swapExactTokensForETHSupportingFeeOnTransferTokens(
            _tokensAmount,
            0, // accept any amount of ETH
            path,
            _to,
            block.timestamp
        );
    }

    function _swapTokensForTUSDT(uint256 _tokensAmount, address _to) internal {
        // generate the pancake pairs path of Token -> BNB -> USDT
        address[] memory path = new address[](3);
        path[0] = address(this);
        path[1] = _WBNB_ADDRESS;
        path[2] = _USDT_ADDRESS;

        PANCAKE_ROUTER.swapExactTokensForTokensSupportingFeeOnTransferTokens(
            _tokensAmount,
            0, // accept any amount of USDT
            path,
            _to,
            block.timestamp
        );
    }

    function _TokenPriceInUSD(uint256 _amount) internal view returns (uint256 usdAmount) {
        // generate the uniswap pair path of BNB -> USDT
        address[] memory path = new address[](3);
        path[0] = address(this);
        path[1] = _WBNB_ADDRESS;
        path[2] = _USDT_ADDRESS;

        usdAmount = PANCAKE_ROUTER.getAmountsOut(_amount, path)[2];
    }
}
// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity ^0.8.19;

import "@chainlink/contracts/src/v0.8/interfaces/VRFCoordinatorV2Interface.sol";
import "@chainlink/contracts/src/v0.8/VRFConsumerBaseV2.sol";
import "@chainlink/contracts/src/v0.8/AutomationCompatible.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {PancakeAdapter} from "./lib/PancakeAdapter.sol";
import {Configuration, ConsumerConfig, DistributionConfig, LotteryConfig} from "./lib/configs/Configuration.sol";
import {TWENTY_FIVE_BITS, DAY_ONE_LIMIT, DAY_TWO_LIMIT, DAY_THREE_LIMIT, MAX_UINT256, DEAD_ADDRESS, TWENTY_FIVE_PERCENTS, SEVENTY_FIVE_PERCENTS, PRECISION, ONE_WORD, RandomWords, Fee, Holders, LotteryType, JackpotEntry} from "./lib/ConstantsAndTypes.sol";

contract TestZ is
    IERC20,
    AutomationCompatibleInterface,
    VRFConsumerBaseV2,
    PancakeAdapter,
    Configuration
{
    error TransferAmountExceededForToday();
    error TransferToZeroAddress();
    error TransferFromZeroAddress();
    error TransferAmountIsZero();
    error TransferAmountExceedsAllowance();
    error CanNotDecreaseAllowance();
    error AccountAlreadyExcluded();
    error AccountAlreadyIncluded();
    error CannotApproveToZeroAddress();
    error ApproveAmountIsZero();
    error AmountIsGreaterThanTotalReflections();
    error TransferAmountExceedsPurchaseAmount();
    error BNBWithdrawalFailed();
    error NoDonationTicketsToTransfer();
    error RecipientsLengthNotEqualToAmounts();

    struct TInfo {
        uint256 tTransferAmount;
        uint256 tBurnFee;
        uint256 tLiquidityFee;
        uint256 tDistributionFee;
        uint256 tTreasuryFee;
        uint256 tDevFundFee;
        uint256 tSmashTimePrizeFee;
        uint256 tHolderPrizeFee;
        uint256 tDonationLotteryPrizeFee;
    }

    struct RInfo {
        uint256 rAmount;
        uint256 rTransferAmount;
        uint256 rBurnFee;
        uint256 rLiquidityFee;
        uint256 rDistributionFee;
        uint256 rTreasuryFee;
        uint256 rDevFundFee;
        uint256 rSmashTimePrizeFee;
        uint256 rHolderPrizeFee;
        uint256 rDonationLotteryPrizeFee;
    }

    enum SwapStatus {
        None,
        Open,
        Locked
    }

    modifier lockTheSwap() {
        _lock = SwapStatus.Locked;
        _;
        _lock = SwapStatus.Open;
    }

    modifier swapLockOnPairCall() {
        if (msg.sender == PANCAKE_PAIR) {
            _lock = SwapStatus.Locked;
            _;
            _lock = SwapStatus.Open;
        } else {
            _;
        }
    }

    SwapStatus private _lock = SwapStatus.Open;

    uint8 public constant decimals = 18;

    mapping(address => uint256) private _rOwned;
    mapping(address => uint256) private _tOwned;
    mapping(address => mapping(address => uint256)) private _allowances;
    mapping(address => bool) public whitelist;

    address[] private _excludedFromReward;

    uint256 public liquiditySupplyThreshold = 1000 * 1e18; // TODO:  use real value
    uint256 public feeSupplyThreshold = 1000 * 1e18; // TODO:  use real value
    uint256 private _tTotal = 20_000_000_000 * 1e18;
    uint256 private _rTotal = (MAX_UINT256 - (MAX_UINT256 % _tTotal));
    uint256 public maxTxAmount = 20_000_000_000 * 1e18;
    uint256 public maxBuyPercent = 10_000;
    uint256 private _tFeeTotal;

    bool public swapAndLiquifyEnabled = true;
    bool public threeDaysProtectionEnabled = false; // TODO:  use real value

    uint256 public smashTimeWins;
    uint256 public donationLotteryWinTimes;
    uint256 public holdersLotteryWinTimes;
    uint256 public totalAmountWonInSmashTimeLottery;
    uint256 public totalAmountWonInDonationLottery;
    uint256 public totalAmountWonInHoldersLottery;
    address public forwarderAddress;

    struct LotteryRound {
        uint256 prize;
        LotteryType lotteryType;
        address winner;
        address jackpotPlayer;
        JackpotEntry jackpotEntry;
    }

    mapping(uint256 => LotteryRound) public rounds;
    mapping(uint256 => mapping(address => uint256[])) private _donatorTicketIdxs;
    address[] private _donators;
    uint256 private _donationRound;
    uint256 private _uniqueDonatorsCounter;
    uint256 private _holdersLotteryTxCounter;

    Holders private _holders;

    IERC20 private _WBNB;
    VRFCoordinatorV2Interface private _COORDINATOR;

    mapping(uint256 => uint256) public donationRequestId;
    mapping(uint256 => uint256) public holderRequestId;
    mapping(uint256 => uint256) public smashtimeRequestId;

    uint256 public donationLotteryBNBPrize;
    uint256 public smashtimeLotteryBNBPrize;

    constructor(
        address _mintSupplyTo,
        address _coordinatorAddress,
        address _routerAddress,
        address _wbnbAddress,
        address _tusdAddress,
        uint256 _fee,
        ConsumerConfig memory _consumerConfig,
        DistributionConfig memory _distributionConfig,
        LotteryConfig memory _lotteryConfig
    )
        VRFConsumerBaseV2(_coordinatorAddress)
        PancakeAdapter(_routerAddress, _wbnbAddress, _tusdAddress)
        Configuration(_fee, _consumerConfig, _distributionConfig, _lotteryConfig)
    {
        _rOwned[_mintSupplyTo] = _rTotal;
        emit Transfer(address(0), _mintSupplyTo, _tTotal);

        // we whitelist treasure and owner to allow pool management
        whitelist[_mintSupplyTo] = true;
        whitelist[owner()] = true;
        whitelist[address(this)] = true;

        //exclude owner and this contract from fee
        _isExcludedFromFee[owner()] = true;
        _isExcludedFromFee[address(this)] = true;
        _isExcludedFromFee[_lotteryConfig.donationAddress] = true;
        _isExcludedFromFee[_mintSupplyTo] = true;
        _isExcludedFromFee[_distributionConfig.holderLotteryPrizePoolAddress] = true;
        _isExcludedFromFee[_distributionConfig.smashTimeLotteryPrizePoolAddress] = true;
        _isExcludedFromFee[_distributionConfig.donationLotteryPrizePoolAddress] = true;
        _isExcludedFromFee[_distributionConfig.teamAddress] = true;
        _isExcludedFromFee[_distributionConfig.teamFeesAccumulationAddress] = true;
        _isExcludedFromFee[_distributionConfig.treasuryAddress] = true;
        _isExcludedFromFee[_distributionConfig.treasuryFeesAccumulationAddress] = true;
        _isExcludedFromFee[_lotteryConfig.donationAddress] = true;
        _isExcludedFromFee[DEAD_ADDRESS] = true;
        _isExcludedFromFee[address(PANCAKE_ROUTER)] = true;

        _approve(address(this), address(PANCAKE_ROUTER), MAX_UINT256);

        _WBNB = IERC20(_wbnbAddress);
        _COORDINATOR = VRFCoordinatorV2Interface(_coordinatorAddress);
    }

    function name() external pure returns (string memory) {
        return "TestZ Token"; // TODO: use real value
    }

    function symbol() external pure returns (string memory) {
        return "TestZ"; // TODO: use real value
    }

    function totalSupply() external view returns (uint256) {
        return _tTotal;
    }

    function balanceOf(address account) public view returns (uint256) {
        if (_isExcludedFromReward[account]) {
            return _tOwned[account];
        }
        return tokenFromReflection(_rOwned[account]);
    }

    function transfer(address recipient, uint256 amount) external returns (bool) {
        _transfer(msg.sender, recipient, amount);
        return true;
    }

    function allowance(address owner, address spender) external view returns (uint256) {
        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount) external returns (bool) {
        if (spender == address(0)) {
            revert CannotApproveToZeroAddress();
        }
        if (amount == 0) {
            revert ApproveAmountIsZero();
        }

        _approve(msg.sender, spender, amount);
        return true;
    }

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool) {
        uint256 currentAllowance = _allowances[sender][msg.sender];
        if (currentAllowance < amount) {
            revert TransferAmountExceedsAllowance();
        }

        _transfer(sender, recipient, amount);

        if (currentAllowance != MAX_UINT256) {
            unchecked {
                _allowances[sender][msg.sender] = currentAllowance - amount;
            }
        }

        return true;
    }

    function increaseAllowance(
        address spender,
        uint256 addedValue
    ) external virtual returns (bool) {
        _allowances[msg.sender][spender] += addedValue;
        return true;
    }

    function decreaseAllowance(
        address spender,
        uint256 subtractedValue
    ) external virtual returns (bool) {
        uint256 currentAllowance = _allowances[msg.sender][spender];
        if (currentAllowance < subtractedValue) {
            revert CanNotDecreaseAllowance();
        }
        _allowances[msg.sender][spender] = currentAllowance - subtractedValue;
        return true;
    }

    function totalFees() external view returns (uint256) {
        return _tFeeTotal;
    }

    function reflectionFromToken(
        uint256 tAmount,
        bool deductTransferFee
    ) external view returns (uint256) {
        if (tAmount > _tTotal) {
            return 0;
        }

        (RInfo memory rr, ) = _getValues(tAmount, deductTransferFee);
        return rr.rTransferAmount;
    }

    function tokenFromReflection(uint256 rAmount) public view returns (uint256) {
        if (rAmount > _rTotal) {
            revert AmountIsGreaterThanTotalReflections();
        }
        return rAmount / _getRate();
    }

    receive() external payable {}

    function _reflectFee(RInfo memory rr, TInfo memory tt) private {
        _rTotal -= rr.rDistributionFee;
        _tFeeTotal +=
            tt.tBurnFee +
            tt.tLiquidityFee +
            tt.tDistributionFee +
            tt.tTreasuryFee +
            tt.tDevFundFee +
            tt.tSmashTimePrizeFee +
            tt.tHolderPrizeFee +
            tt.tDonationLotteryPrizeFee;

        _rOwned[smashTimeLotteryPrizePoolAddress] += rr.rSmashTimePrizeFee;
        _rOwned[holderLotteryPrizePoolAddress] += rr.rHolderPrizeFee;
        _rOwned[donationLotteryPrizePoolAddress] += rr.rDonationLotteryPrizeFee;
        _rOwned[teamFeesAccumulationAddress] += rr.rDevFundFee;
        _rOwned[treasuryFeesAccumulationAddress] += rr.rTreasuryFee;
        _rOwned[DEAD_ADDRESS] += rr.rBurnFee;

        address[6] memory addresses = [
            holderLotteryPrizePoolAddress,
            smashTimeLotteryPrizePoolAddress,
            teamFeesAccumulationAddress,
            treasuryFeesAccumulationAddress,
            donationLotteryPrizePoolAddress,
            DEAD_ADDRESS
        ];

        uint256[6] memory fees = [
            tt.tHolderPrizeFee,
            tt.tSmashTimePrizeFee,
            tt.tDevFundFee,
            tt.tTreasuryFee,
            tt.tDonationLotteryPrizeFee,
            tt.tBurnFee
        ];

        for (uint i = 0; i < addresses.length; i++) {
            if (fees[i] > 0) {
                emit Transfer(msg.sender, addresses[i], fees[i]);
            }
        }
    }

    function _getValues(
        uint256 tAmount,
        bool takeFee
    ) private view returns (RInfo memory rr, TInfo memory tt) {
        tt = _getTValues(tAmount, takeFee);
        rr = _getRValues(tAmount, tt, _getRate());
        return (rr, tt);
    }

    function _getTValues(uint256 tAmount, bool takeFee) private view returns (TInfo memory tt) {
        if (!takeFee) {
            tt.tTransferAmount = tAmount;
            tt.tBurnFee = 0;
            tt.tDistributionFee = 0;
            tt.tTreasuryFee = 0;
            tt.tDevFundFee = 0;
            tt.tSmashTimePrizeFee = 0;
            tt.tHolderPrizeFee = 0;
            tt.tDonationLotteryPrizeFee = 0;
            tt.tLiquidityFee = 0;
            return tt;
        }

        uint256 _fee = _calcFeePercent();
        Fee fees = _fees;

        // Combined calculation for efficiency
        tt.tBurnFee = (fees.burnFeePercent(_fee) * tAmount) / PRECISION;
        tt.tDistributionFee = (fees.distributionFeePercent(_fee) * tAmount) / PRECISION;
        tt.tTreasuryFee = (fees.treasuryFeePercent(_fee) * tAmount) / PRECISION;
        tt.tDevFundFee = (fees.devFeePercent(_fee) * tAmount) / PRECISION;
        tt.tSmashTimePrizeFee = (fees.smashTimeLotteryPrizeFeePercent(_fee) * tAmount) / PRECISION;
        tt.tHolderPrizeFee = (fees.holdersLotteryPrizeFeePercent(_fee) * tAmount) / PRECISION;
        tt.tDonationLotteryPrizeFee =
            (fees.donationLotteryPrizeFeePercent(_fee) * tAmount) /
            PRECISION;
        tt.tLiquidityFee = (fees.liquidityFeePercent(_fee) * tAmount) / PRECISION;

        uint totalFee = tt.tBurnFee +
            tt.tLiquidityFee +
            tt.tDistributionFee +
            tt.tTreasuryFee +
            tt.tDevFundFee +
            tt.tSmashTimePrizeFee +
            tt.tDonationLotteryPrizeFee +
            tt.tHolderPrizeFee;

        tt.tTransferAmount = tAmount - totalFee;
        return tt;
    }

    function _getRValues(
        uint256 tAmount,
        TInfo memory tt,
        uint256 currentRate
    ) private pure returns (RInfo memory rr) {
        rr.rAmount = tAmount * currentRate;
        rr.rBurnFee = tt.tBurnFee * currentRate;
        rr.rLiquidityFee = tt.tLiquidityFee * currentRate;
        rr.rDistributionFee = tt.tDistributionFee * currentRate;
        rr.rTreasuryFee = tt.tTreasuryFee * currentRate;
        rr.rDevFundFee = tt.tDevFundFee * currentRate;
        rr.rSmashTimePrizeFee = tt.tSmashTimePrizeFee * currentRate;
        rr.rHolderPrizeFee = tt.tHolderPrizeFee * currentRate;
        rr.rDonationLotteryPrizeFee = tt.tDonationLotteryPrizeFee * currentRate;

        uint totalFee = rr.rBurnFee +
            rr.rLiquidityFee +
            rr.rDistributionFee +
            rr.rTreasuryFee +
            rr.rDevFundFee +
            rr.rSmashTimePrizeFee +
            rr.rDonationLotteryPrizeFee +
            rr.rHolderPrizeFee;

        rr.rTransferAmount = rr.rAmount - totalFee;
        return rr;
    }

    function _getRate() private view returns (uint256) {
        (uint256 rSupply, uint256 tSupply) = _getCurrentSupply();
        return rSupply / tSupply;
    }

    function _getCurrentSupply() private view returns (uint256, uint256) {
        uint256 rSupply = _rTotal;
        uint256 tSupply = _tTotal;
        for (uint256 i = 0; i < _excludedFromReward.length; i++) {
            if (
                _rOwned[_excludedFromReward[i]] > rSupply ||
                _tOwned[_excludedFromReward[i]] > tSupply
            ) {
                return (_rTotal, _tTotal);
            }
            rSupply = rSupply - _rOwned[_excludedFromReward[i]];
            tSupply = tSupply - _tOwned[_excludedFromReward[i]];
        }
        if (rSupply < _rTotal / _tTotal) {
            return (_rTotal, _tTotal);
        }
        return (rSupply, tSupply);
    }

    function _takeLiquidity(uint256 rLiquidity, uint256 tLiquidity) private {
        _rOwned[address(this)] = _rOwned[address(this)] + rLiquidity;
        if (_isExcludedFromReward[address(this)])
            _tOwned[address(this)] = _tOwned[address(this)] + tLiquidity;
    }

    function _approve(address owner, address spender, uint256 amount) private {
        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function _antiAbuse(address from, address to, uint256 amount) private view {
        // If owner, skip checks
        if (from == owner() || to == owner()) return;

        (, uint256 tSupply) = _getCurrentSupply();
        uint256 lastUserBalance = balanceOf(to) +
            ((amount * (PRECISION - _calcFeePercent())) / PRECISION);

        // Bot / whales prevention
        if (threeDaysProtectionEnabled) {
            uint256 timeSinceCreation = block.timestamp - _creationTime;
            uint256 dayLimit = 0;

            if (timeSinceCreation <= 1 days) {
                dayLimit = DAY_ONE_LIMIT;
            } else if (timeSinceCreation <= 2 days) {
                dayLimit = DAY_TWO_LIMIT;
            } else if (timeSinceCreation <= 3 days) {
                dayLimit = DAY_THREE_LIMIT;
            }

            if (dayLimit > 0) {
                uint256 allowedAmount = (tSupply * dayLimit) / PRECISION;
                if (lastUserBalance >= allowedAmount) {
                    revert TransferAmountExceededForToday();
                }
            }
        }

        if (amount > (balanceOf(PANCAKE_PAIR) * maxBuyPercent) / PRECISION) {
            revert TransferAmountExceedsPurchaseAmount();
        }
    }

    function _transfer(address from, address to, uint256 amount) private swapLockOnPairCall {
        if (from == address(0)) revert TransferFromZeroAddress();
        if (to == address(0)) revert TransferToZeroAddress();
        if (amount == 0) revert TransferAmountIsZero();

        // whitelist to allow treasure to add liquidity:
        uint256 contractTokenBalance = balanceOf(address(this));
        if (!whitelist[from] && !whitelist[to]) {
            if (from == PANCAKE_PAIR) {
                _antiAbuse(from, to, amount);
            }
            // is the token balance of this contract address over the min number of
            // tokens that we need to initiate a swap + liquidity lock?
            // also, don't get caught in a circular liquidity event.
            // also, don't swap & liquify if sender is uniswap pair.
            if (contractTokenBalance >= maxTxAmount) contractTokenBalance = maxTxAmount;
        }
        if (
            contractTokenBalance >= liquiditySupplyThreshold &&
            _lock == SwapStatus.Open &&
            from != PANCAKE_PAIR &&
            to != PANCAKE_PAIR &&
            swapAndLiquifyEnabled
        ) {
            contractTokenBalance = liquiditySupplyThreshold;
            //add liquidity
            _swapAndLiquify(contractTokenBalance);
        }
        //indicates if fee should be deducted from transfer
        bool takeFee = !_isExcludedFromFee[from] && !_isExcludedFromFee[to];
        // process transfer and lotteries
        _lotteryOnTransfer(from, to, amount, takeFee);
        if (_lock == SwapStatus.Open) _distributeFees();
    }

    function _distributeFees() private lockTheSwap {
        _distributeFeeToAddress(teamFeesAccumulationAddress, teamAddress);
        _distributeFeeToAddress(treasuryFeesAccumulationAddress, treasuryAddress);
    }

    function _distributeFeeToAddress(
        address feeAccumulationAddress,
        address destinationAddress
    ) private {
        uint256 accumulatedBalance = balanceOf(feeAccumulationAddress);
        if (accumulatedBalance >= feeSupplyThreshold) {
            uint256 balanceBefore = balanceOf(address(this));

            _tokenTransfer(feeAccumulationAddress, address(this), accumulatedBalance, false);

            _swapTokensForTUSDT(accumulatedBalance / 4, destinationAddress);
            _swapTokensForBNB(accumulatedBalance / 4, destinationAddress);

            uint256 balanceAfter = balanceOf(address(this));

            if (balanceAfter > 0) {
                _tokenTransfer(
                    address(this),
                    destinationAddress,
                    balanceAfter - balanceBefore + accumulatedBalance / 2,
                    false
                );
            }
        }
    }

    function _checkForHoldersLotteryEligibility(
        address _participant,
        uint256 _balanceThreshold
    ) private {
        if (
            _participant == address(PANCAKE_ROUTER) ||
            _participant == PANCAKE_PAIR ||
            _isExcludedFromReward[_participant] ||
            _isExcludedFromFee[_participant]
        ) {
            return;
        }

        uint256 balance = balanceOf(_participant);

        if (balance < _balanceThreshold * 3) {
            _holders.removeSecond(_participant);
        } else {
            _holders.addSecond(_participant);
        }

        if (balance < _balanceThreshold) {
            _holders.removeFirst(_participant);
        } else {
            _holders.addFirst(_participant);
        }
    }

    function _holdersEligibilityThreshold(uint256 _minPercent) private view returns (uint256) {
        return ((_tTotal - balanceOf(DEAD_ADDRESS)) * _minPercent) / PRECISION;
    }

    function _checkForHoldersLotteryEligibilities(
        address _transferrer,
        address _recipient
    ) private {
        if (!_lotteryConfig.holdersLotteryEnabled) {
            return;
        }

        _holdersLotteryTxCounter++;

        _checkForHoldersLotteryEligibility(
            _transferrer,
            _holdersEligibilityThreshold(_lotteryConfig.holdersLotteryMinPercent)
        );

        _checkForHoldersLotteryEligibility(
            _recipient,
            _holdersEligibilityThreshold(_lotteryConfig.holdersLotteryMinPercent)
        );
    }

    function _convertSmashTimeLotteryPrize() private {
        uint256 conversionAmount = _calculateSmashTimeLotteryConversionAmount();
        _tokenTransfer(smashTimeLotteryPrizePoolAddress, address(this), conversionAmount, false);
        uint256 convertedBNB = _swapTokensForBNB(conversionAmount);
        smashtimeLotteryBNBPrize += convertedBNB;
    }

    function _convertDonationLotteryPrize() private {
        uint256 conversionAmount = _calculateDonationLotteryConversionAmount();
        _tokenTransfer(donationLotteryPrizePoolAddress, address(this), conversionAmount, false);
        uint256 convertedBNB = _swapTokensForBNB(conversionAmount);
        donationLotteryBNBPrize += convertedBNB;
    }

    function _lotteryOnTransfer(
        address _transferrer,
        address _recipient,
        uint256 _amount,
        bool _takeFee
    ) private {
        _smashTimeLottery(_transferrer, _recipient, _amount);

        //transfer amount, it will take tax, burn, liquidity fee
        _tokenTransfer(_transferrer, _recipient, _amount, _takeFee);

        _checkForHoldersLotteryEligibilities(_transferrer, _recipient);

        _addDonationsLotteryTickets(_transferrer, _recipient, _amount);
    }

    function _requestRandomWords(uint32 _wordsAmount) private returns (uint256) {
        return
            _COORDINATOR.requestRandomWords(
                _consumerConfig.gasPriceKey,
                _consumerConfig.subscriptionId,
                _consumerConfig.requestConfirmations,
                _consumerConfig.callbackGasLimit,
                _wordsAmount
            );
    }

    function _toRandomWords(
        uint256[] memory _array
    ) private pure returns (RandomWords memory _words) {
        assembly {
            _words := add(_array, ONE_WORD)
        }
    }

    function fulfillRandomWords(
        uint256 _requestId,
        uint256[] memory _randomWords
    ) internal override {
        _finishRound(_requestId, _toRandomWords(_randomWords));
    }

    function checkUpkeep(
        bytes calldata /* checkData */
    ) external view override returns (bool upkeepNeeded, bytes memory performData) {
        uint256 upkeepTasks = 0;
        if (
            balanceOf(smashTimeLotteryPrizePoolAddress) >=
            _lotteryConfig.smashTimeLotteryConversionThreshold
        ) {
            upkeepTasks |= 1;
        }

        if (
            balanceOf(donationLotteryPrizePoolAddress) >= _lotteryConfig.donationConversionThreshold
        ) {
            upkeepTasks |= 2;
        }
        if (
            _lotteryConfig.holdersLotteryEnabled &&
            _holdersLotteryTxCounter >= _lotteryConfig.holdersLotteryTxTrigger &&
            _holders.first.length != 0
        ) {
            upkeepTasks |= 4; // Set a bit for hodl lottery
        }
        if (
            _lotteryConfig.donationsLotteryEnabled &&
            _uniqueDonatorsCounter >= _lotteryConfig.minimumDonationEntries
        ) {
            upkeepTasks |= 8; // Set a bit for donation lottery
        }

        if (upkeepTasks != 0) {
            return (true, abi.encode(upkeepTasks));
        }

        return (false, bytes(""));
    }

    function performUpkeep(bytes calldata performData) external override {
        require(
            msg.sender == forwarderAddress,
            "This address does not have permission to call performUpkeep"
        );
        uint256 tasks = abi.decode(performData, (uint256));

        if (tasks & 1 != 0) {
            _convertSmashTimeLotteryPrize();
        }
        if (tasks & 2 != 0) {
            _convertDonationLotteryPrize();
        }
        if (tasks & 4 != 0) {
            _triggerHoldersLottery();
        }
        if (tasks & 8 != 0) {
            _donationsLottery();
        }
    }

    function _swapAndLiquify(uint256 contractTokenBalance) private lockTheSwap {
        // split the contract balance into halves
        uint256 half = contractTokenBalance / 2;
        uint256 nativeBalance = _swap(half);

        // add liquidity to pancake
        _liquify(half, nativeBalance);
    }

    function _swap(uint256 tokenAmount) private returns (uint256) {
        return _swapTokensForBNB(tokenAmount);
    }

    function _liquify(uint256 tokenAmount, uint256 bnbAmount) private {
        _addLiquidity(tokenAmount, bnbAmount, owner());
    }

    //this method is responsible for taking all fee, if takeFee is true
    function _tokenTransfer(
        address sender,
        address recipient,
        uint256 amount,
        bool takeFee
    ) private {
        bool senderExcluded = _isExcludedFromReward[sender];
        bool recipientExcluded = _isExcludedFromReward[recipient];

        if (!senderExcluded) {
            if (!recipientExcluded) {
                _transferStandard(sender, recipient, amount, takeFee);
            } else {
                _transferToExcluded(sender, recipient, amount, takeFee);
            }
        } else {
            if (recipientExcluded) {
                _transferBothExcluded(sender, recipient, amount, takeFee);
            } else {
                _transferFromExcluded(sender, recipient, amount, takeFee);
            }
        }
    }

    function _transferStandard(
        address sender,
        address recipient,
        uint256 tAmount,
        bool takeFee
    ) private {
        (RInfo memory rr, TInfo memory tt) = _getValues(tAmount, takeFee);
        _rOwned[sender] -= rr.rAmount;
        _rOwned[recipient] += rr.rTransferAmount;
        if (takeFee) {
            _takeLiquidity(rr.rLiquidityFee, tt.tLiquidityFee);
            _reflectFee(rr, tt);
        }

        emit Transfer(sender, recipient, tt.tTransferAmount);
    }

    function _transferToExcluded(
        address sender,
        address recipient,
        uint256 tAmount,
        bool takeFee
    ) private {
        (RInfo memory rr, TInfo memory tt) = _getValues(tAmount, takeFee);
        _rOwned[sender] -= rr.rAmount;
        _tOwned[recipient] += tt.tTransferAmount;
        _rOwned[recipient] += rr.rTransferAmount;

        if (takeFee) {
            _takeLiquidity(rr.rLiquidityFee, tt.tLiquidityFee);
            _reflectFee(rr, tt);
        }

        emit Transfer(sender, recipient, tt.tTransferAmount);
    }

    function _transferFromExcluded(
        address sender,
        address recipient,
        uint256 tAmount,
        bool takeFee
    ) private {
        (RInfo memory rr, TInfo memory tt) = _getValues(tAmount, takeFee);
        _tOwned[sender] -= tAmount;
        _rOwned[sender] -= rr.rAmount;
        _rOwned[recipient] += rr.rTransferAmount;

        if (takeFee) {
            _takeLiquidity(rr.rLiquidityFee, tt.tLiquidityFee);
            _reflectFee(rr, tt);
        }

        emit Transfer(sender, recipient, tt.tTransferAmount);
    }

    function _transferBothExcluded(
        address sender,
        address recipient,
        uint256 tAmount,
        bool takeFee
    ) private {
        (RInfo memory rr, TInfo memory tt) = _getValues(tAmount, takeFee);
        _tOwned[sender] -= tAmount;
        _rOwned[sender] -= rr.rAmount;
        _tOwned[recipient] += tt.tTransferAmount;
        _rOwned[recipient] += rr.rTransferAmount;

        if (takeFee) {
            _takeLiquidity(rr.rLiquidityFee, tt.tLiquidityFee);
            _reflectFee(rr, tt);
        }

        emit Transfer(sender, recipient, tt.tTransferAmount);
    }

    function totalFeePercent() external view returns (uint256) {
        return _calcFeePercent();
    }

    function _finishRound(uint256 _requestId, RandomWords memory _random) private {
        LotteryRound storage round = rounds[_requestId];

        if (round.lotteryType == LotteryType.JACKPOT) {
            _finishSmashTimeLottery(_requestId, round, _random);
        }

        if (round.lotteryType == LotteryType.HOLDERS) {
            _finishHoldersLottery(_requestId, round, _random.first);
        }

        if (round.lotteryType == LotteryType.DONATION) {
            _finishDonationLottery(_requestId, round, _random.first);
        }
    }

    function _calculateSmashTimeLotteryPrize() private view returns (uint256) {
        return (smashtimeLotteryBNBPrize * TWENTY_FIVE_PERCENTS) / PRECISION;
    }

    function _calculateHoldersLotteryPrize() private view returns (uint256) {
        return (balanceOf(holderLotteryPrizePoolAddress) * SEVENTY_FIVE_PERCENTS) / PRECISION;
    }

    function _calculateDonationLotteryPrize() private view returns (uint256) {
        return (donationLotteryBNBPrize * SEVENTY_FIVE_PERCENTS) / PRECISION;
    }

    function _calculateDonationLotteryConversionAmount() private view returns (uint256) {
        return (balanceOf(donationLotteryPrizePoolAddress) * SEVENTY_FIVE_PERCENTS) / PRECISION;
    }

    function _calculateSmashTimeLotteryConversionAmount() private view returns (uint256) {
        return (balanceOf(smashTimeLotteryPrizePoolAddress) * SEVENTY_FIVE_PERCENTS) / PRECISION;
    }

    function _seedTicketsArray(
        address[100] memory _tickets,
        uint256 _index,
        address _player
    ) private pure {
        while (_tickets[_index] == _player) {
            _index = (_index + 1) % 100;
        }
        _tickets[_index] = _player;
    }

    function _finishSmashTimeLottery(
        uint256 _requestId,
        LotteryRound storage _round,
        RandomWords memory _random
    ) private {
        address player = _round.jackpotPlayer;
        address[100] memory tickets;

        for (uint256 i = 0; i < uint8(_round.jackpotEntry); ) {
            uint256 shift = (i * TWENTY_FIVE_BITS);
            uint256 idx = (_random.second >> shift);
            assembly {
                idx := mod(idx, 100)
            }
            _seedTicketsArray(tickets, idx, player);
            unchecked {
                ++i;
            }
        }

        uint256 winnerIdx;
        assembly {
            winnerIdx := mod(mload(_random), 100)
        }

        if (tickets[winnerIdx] == player) {
            uint256 untaxedPrize = _calculateSmashTimeLotteryPrize();
            uint256 tax = (untaxedPrize * smashTimeLotteryPrizeFeePercent()) / maxBuyPercent;

            require(address(this).balance >= untaxedPrize, "Insufficient balance");
            (bool taxSent, ) = owner().call{value: tax}("");
            require(taxSent, "Failed to send tax BNB in smashtime lottery");

            uint256 prize = untaxedPrize - tax;
            (bool prizeSent, ) = player.call{value: prize}("");
            require(prizeSent, "Failed to send prize BNB in smash lottery");

            smashtimeLotteryBNBPrize -= untaxedPrize;
            totalAmountWonInSmashTimeLottery += prize;
            smashtimeRequestId[smashTimeWins] = _requestId;
            smashTimeWins += 1;
            _round.winner = player;
            _round.prize = prize;
        }

        _round.lotteryType = LotteryType.FINISHED_JACKPOT;
    }

    function _finishHoldersLottery(
        uint256 _requestId,
        LotteryRound storage _round,
        uint256 _random
    ) private {
        uint256 winnerIdx;
        uint256 holdersLength = _holders.first.length + _holders.second.length;

        if (holdersLength == 0) {
            return;
        }

        assembly {
            winnerIdx := mod(_random, holdersLength)
        }
        address winner = _holders.allTickets()[winnerIdx];
        uint256 prize = _calculateHoldersLotteryPrize();

        _tokenTransfer(holderLotteryPrizePoolAddress, winner, prize, false);

        holderRequestId[holdersLotteryWinTimes] = _requestId;
        holdersLotteryWinTimes += 1;
        totalAmountWonInHoldersLottery += prize;
        _round.winner = winner;
        _round.prize = prize;
        _round.lotteryType = LotteryType.FINISHED_HOLDERS;
    }

    function _finishDonationLottery(
        uint256 _requestId,
        LotteryRound storage _round,
        uint256 _random
    ) private {
        uint256 winnerIdx;
        uint256 donatorsLength = _donators.length;
        assembly {
            winnerIdx := mod(_random, donatorsLength)
        }
        address winner = _donators[winnerIdx];
        uint256 prize = _calculateDonationLotteryPrize();

        require(address(this).balance >= prize, "Insufficient balance");
        (bool sent, ) = winner.call{value: prize}("");
        require(sent, "Failed to send BNB");

        donationLotteryBNBPrize -= prize;
        donationRequestId[donationLotteryWinTimes] = _requestId;
        donationLotteryWinTimes += 1;
        totalAmountWonInDonationLottery += prize;
        _round.winner = winner;
        _round.prize = prize;
        _round.lotteryType = LotteryType.FINISHED_DONATION;

        delete _donators;
        _donationRound += 1;
    }

    function _smashTimeLottery(address _transferrer, address _recipient, uint256 _amount) private {
        if (
            !_lotteryConfig.smashTimeLotteryEnabled ||
            _transferrer != PANCAKE_PAIR ||
            _recipient == PANCAKE_PAIR ||
            _isExcludedFromReward[_recipient] ||
            _isExcludedFromFee[_recipient]
        ) {
            return;
        }

        uint256 usdAmount = _TokenPriceInUSD(_amount) / 1e18;
        uint256 hundreds = (usdAmount * 100) / _lotteryConfig.smashTimeLotteryTriggerThreshold;
        if (hundreds == 0) {
            return;
        }

        uint256 requestId = _requestRandomWords(2);
        rounds[requestId].lotteryType = LotteryType.JACKPOT;
        rounds[requestId].jackpotEntry = hundreds >= 10
            ? JackpotEntry.USD_1000
            : JackpotEntry(uint8(hundreds));
        rounds[requestId].jackpotPlayer = _recipient;
    }

    function _triggerHoldersLottery() private {
        uint256 requestId = _requestRandomWords(1);
        rounds[requestId].lotteryType = LotteryType.HOLDERS;
        _holdersLotteryTxCounter = 0;
    }

    function _addDonationsLotteryTickets(
        address _transferrer,
        address _recipient,
        uint256 _amount
    ) private {
        if (!_lotteryConfig.donationsLotteryEnabled) {
            return;
        }
        // if this transfer is a donation, add a ticket for transferrer.
        if (
            _recipient == _lotteryConfig.donationAddress &&
            _amount >= _lotteryConfig.minimalDonation
        ) {
            if (_donatorTicketIdxs[_donationRound][_transferrer].length == 0) {
                _uniqueDonatorsCounter++;
            }
            uint256 length = _donators.length;
            _donators.push(_transferrer);
            _donatorTicketIdxs[_donationRound][_transferrer].push(length);
        }
    }

    function _donationsLottery() private {
        uint256 requestId = _requestRandomWords(1);
        rounds[requestId].lotteryType = LotteryType.DONATION;
        _uniqueDonatorsCounter = 0;
    }

    function transferDonationTicket(address _to) external {
        uint256 round = _donationRound;
        uint256 length = _donatorTicketIdxs[round][msg.sender].length;
        if (length == 0) {
            revert NoDonationTicketsToTransfer();
        }

        uint256 idx = _donatorTicketIdxs[round][msg.sender][length - 1];
        _donatorTicketIdxs[round][msg.sender].pop();
        _donators[idx] = _to;
        if (_donatorTicketIdxs[round][_to].length == 0) {
            _uniqueDonatorsCounter++;
        }
        _donatorTicketIdxs[round][_to].push(idx);
    }

    function mintDonationTickets(
        address[] calldata _recipients,
        uint256[] calldata _amounts
    ) external onlyOwner {
        uint256 recipientsLength = _recipients.length;
        if (recipientsLength != _amounts.length) {
            revert RecipientsLengthNotEqualToAmounts();
        }

        uint256 round = _donationRound;
        for (uint256 i = 0; i < recipientsLength; ++i) {
            address recipient = _recipients[i];
            uint256 amount = _amounts[i];
            uint256 idx = _donatorTicketIdxs[round][recipient].length;
            uint256 newIdx = idx + amount;

            if (_donatorTicketIdxs[round][recipient].length == 0) {
                _uniqueDonatorsCounter++;
            }

            for (; idx < newIdx; ++idx) {
                _donators.push(recipient);
                _donatorTicketIdxs[round][recipient].push(idx);
            }
        }
    }

    function holdersLotteryTickets() external view returns (address[] memory) {
        return _holders.allTickets();
    }

    function holdersLotteryTicketsAmountPerHolder(address _holder) external view returns (uint256) {
        return _holders.getNumberOfTickets(_holder);
    }

    function donationLotteryTickets() external view returns (address[] memory) {
        return _donators;
    }

    // Function to get the number of tickets for a donator
    function donationLotteryTicketsAmountPerDonator(
        address donator
    ) external view returns (uint256) {
        return _donatorTicketIdxs[_donationRound][donator].length;
    }

    function donate(uint256 _amount) external {
        _transfer(msg.sender, _lotteryConfig.donationAddress, _amount);
    }

    function updateHolderList(address[] calldata holdersToCheck) external onlyOwner {
        for (uint i = 0; i < holdersToCheck.length; i++) {
            _checkForHoldersLotteryEligibility(
                holdersToCheck[i],
                ((_tTotal - balanceOf(DEAD_ADDRESS)) * _lotteryConfig.holdersLotteryMinPercent) /
                    PRECISION
            );
        }
    }

    function excludeFromReward(address account) external onlyOwner {
        if (_isExcludedFromReward[account]) {
            revert AccountAlreadyExcluded();
        }

        if (_rOwned[account] > 0) {
            _tOwned[account] = tokenFromReflection(_rOwned[account]);
        }
        _isExcludedFromReward[account] = true;
        _excludedFromReward.push(account);
    }

    function includeInReward(address account) external onlyOwner {
        if (!_isExcludedFromReward[account]) {
            revert AccountAlreadyIncluded();
        }
        for (uint256 i = 0; i < _excludedFromReward.length; i++) {
            if (_excludedFromReward[i] == account) {
                _excludedFromReward[i] = _excludedFromReward[_excludedFromReward.length - 1];
                _tOwned[account] = 0;
                _isExcludedFromReward[account] = false;
                _excludedFromReward.pop();
                break;
            }
        }
    }

    // Set functoins
    function setForwarderAddress(address _forwarderAddress) external onlyOwner {
        forwarderAddress = _forwarderAddress;
    }

    function setWhitelist(address account, bool _status) external onlyOwner {
        whitelist[account] = _status;
    }

    function setMaxTxPercent(uint256 maxTxPercent) external onlyOwner {
        maxTxAmount = (_tTotal * maxTxPercent) / PRECISION;
    }

    function setMaxBuyPercent(uint256 _maxBuyPercent) external onlyOwner {
        maxBuyPercent = _maxBuyPercent;
    }

    function setSwapAndLiquifyEnabled(bool _enabled) external onlyOwner {
        swapAndLiquifyEnabled = _enabled;
    }

    function setLiquiditySupplyThreshold(uint256 _amount) external onlyOwner {
        liquiditySupplyThreshold = _amount;
    }

    function setFeeSupplyThreshold(uint256 _amount) external onlyOwner {
        feeSupplyThreshold = _amount;
    }

    function setThreeDaysProtection(bool _enabled) external onlyOwner {
        threeDaysProtectionEnabled = _enabled;
    }

    // Withdraw functions for this contract
    function withdraw(uint256 _amount) external onlyOwner {
        _transferStandard(address(this), msg.sender, _amount, false);
    }

    function withdrawBNB(uint256 _amount) external onlyOwner {
        (bool res, ) = msg.sender.call{value: _amount}("");
        if (!res) {
            revert BNBWithdrawalFailed();
        }
    }
}
