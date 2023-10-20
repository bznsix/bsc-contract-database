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

import {
    ConsumerConfig
} from "../lib/configs/VRFConsumerConfig.sol";


interface IConfiguration {

    function setConsumerConfig (ConsumerConfig calldata _newConfig) external;

	function setSubscriptionId (uint64 _subscriptionId) external;

	function setCallbackGasLimit (uint32 _callbackGasLimit) external;

	function setRequestConfirmations (uint16 _requestConfirmations) external;

	function setGasPriceKey (bytes32 _gasPriceKey) external;

	function setHolderLotteryPrizePoolAddress (address _newAddress) external;

	function setSmashTimeLotteryPrizePoolAddress (address _newAddress) external;

	function setDonationLotteryPrizePoolAddress (address _newAddress) external;

	function setTeamAddress (address _newAddress) external;

	function setTeamAccumulationAddress (address _newAddress) external;

	function setTreasuryAddress (address _newAddress) external;

	function setTreasuryAccumulationAddress (address _newAddress) external;

	function setFeeConfig (uint256 _feeConfigRaw) external;

	function switchSmashTimeLotteryFlag (bool flag) external;

    function switchHoldersLotteryFlag (bool flag) external;

    function switchDonationsLotteryFlag (bool flag) external;

	function excludeFromFee (address account) external;

	function includeInFee (address account) external;

	function setHoldersLotteryTxTrigger (uint64 _txAmount) external;

    function setDonationLotteryTxTrigger (uint64 _txAmount) external;

    function setHoldersLotteryMinPercent (uint256 _minPercent) external;

    function setDonationAddress (address _donationAddress) external;

    function setMinimalDonation (uint256 _minimalDonation) external;

	function setFees (uint256 _fee) external;

    function setMinimumDonationEntries (uint64 _minimumEntries) external;

	function burnFeePercent () external view returns (uint256);

	function liquidityFeePercent () external view returns (uint256);

	function distributionFeePercent () external view returns (uint256);

	function treasuryFeePercent () external view returns (uint256);

	function devFeePercent () external view returns (uint256);

	function smashTimeLotteryPrizeFeePercent () external view returns (uint256);

	function holdersLotteryPrizeFeePercent () external view returns (uint256);

	function donationLotteryPrizeFeePercent () external view returns (uint256);

	function isExcludedFromFee (address account) external view returns (bool);

	function isExcludedFromReward (address account) external view returns (bool);

	function smashTimeLotteryEnabled () external view returns (bool);

    function holdersLotteryEnabled () external view returns (bool);

    function holdersLotteryTxTrigger () external view returns (uint64);

    function holdersLotteryMinPercent () external view returns (uint256);

    function donationAddress () external view returns (address);

    function donationsLotteryEnabled () external view returns (bool);

    function minimumDonationEntries () external view returns (uint64);

    function donationLotteryTxTrigger () external view returns (uint64);

    function minimalDonation () external view returns (uint256);

	function subscriptionId () external view returns (uint64);

	function callbackGasLimit () external view returns (uint32);

	function requestConfirmations () external view returns (uint16);

	function gasPriceKey () external view returns (bytes32);
}// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity ^0.8.19;

import {
    IERC20
} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";

interface ILotteryToken is IERC20 {

    function excludeFromReward (address account) external;

	function includeInReward (address account) external;

	function setWhitelist (address account, bool _status) external;

	function setMaxTxPercent (uint256 maxTxPercent) external;

	function setSwapAndLiquifyEnabled(bool _enabled) external;
}// solhint-disable
// SPDX-License-Identifier: GPL-3.0
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

    function getPair(
        address tokenA,
        address tokenB
    ) external view returns (address pair);

    function allPairs(uint256) external view returns (address pair);

    function allPairsLength() external view returns (uint256);

    function createPair(
        address tokenA,
        address tokenB
    ) external returns (address pair);

    function setFeeTo(address) external;

    function setFeeToSetter(address) external;

    function INIT_CODE_PAIR_HASH() external view returns (bytes32);
}// solhint-disable
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

    function getAmountsOut(
        uint256 amountIn,
        address[] calldata path
    ) external view returns (uint256[] memory amounts);

    function getAmountsIn(
        uint256 amountOut,
        address[] calldata path
    ) external view returns (uint256[] memory amounts);
}// solhint-disable
// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.6.2;

import {
    IPancakeRouter01
} from "./IPancakeRouter01.sol";

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
}// SPDX-License-Identifier: MIT
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
	address public immutable VRF_COORDINATOR;

	/**
	* @param _vrfCoordinator address of VRFCoordinator contract
	*/
	constructor(address _vrfCoordinator) {
		VRF_COORDINATOR = _vrfCoordinator;
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
	function _fulfillRandomWords(
		uint256 requestId,
		uint256[] memory randomWords
	) internal virtual;

	// rawFulfillRandomness is called by VRFCoordinator when it receives a valid VRF
	// proof. rawFulfillRandomness then calls fulfillRandomness, after validating
	// the origin of the call
	function rawFulfillRandomWords(
		uint256 requestId,
		uint256[] memory randomWords
	)
	external {
		// if (msg.sender != VRF_COORDINATOR) {
		// revert OnlyCoordinatorCanFulfill(msg.sender, VRF_COORDINATOR);
		// }
		_fulfillRandomWords(requestId, randomWords);
	}
}
// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity ^0.8.19;

import {
	Ownable
} from "@openzeppelin/contracts/access/Ownable.sol";

import {
	IConfiguration
} from "../../interfaces/IConfiguration.sol";

import {
	ConsumerConfig,
	VRFConsumerConfig
} from "./VRFConsumerConfig.sol";

import {
	DistributionConfig,
	ProtocolConfig
} from "./ProtocolConfig.sol";

import {
	LotteryConfig,
	LotteryEngineConfig
} from "./LotteryEngineConfig.sol";

abstract contract Configuration is IConfiguration, VRFConsumerConfig,
	ProtocolConfig, LotteryEngineConfig, Ownable {
	
	uint256 public constant FEE_CAP = 500;

	uint256 internal immutable _creationTime;
	uint256 public fee;

	constructor (
		uint256 _fee,
		ConsumerConfig memory _consumerConfig,
		DistributionConfig memory _distributionConfig,
		LotteryConfig memory _lotteryConfig
	) VRFConsumerConfig (
		_consumerConfig
	) ProtocolConfig(
		_distributionConfig
	) LotteryEngineConfig(
		_lotteryConfig
	){
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

	function setConsumerConfig (
		ConsumerConfig calldata _newConfig
	) external onlyOwner {
		_setConfig(_newConfig);
	}

	function setSubscriptionId (
		uint64 _subscriptionId
	) external onlyOwner {
		_setSubscriptionId(_subscriptionId);
	}

	function setCallbackGasLimit (
		uint32 _callbackGasLimit
	) external onlyOwner {
		_setCallbackGasLimit(_callbackGasLimit);
	}

	function setRequestConfirmations (
		uint16 _requestConfirmations
	) external onlyOwner {
		_setRequestConfirmations(_requestConfirmations);
	}

	function setGasPriceKey (
		bytes32 _gasPriceKey
	) external onlyOwner {
		_setGasPriceKey(_gasPriceKey);
	}

	function setHolderLotteryPrizePoolAddress (
		address _newAddress
	) external onlyOwner {
		_setHolderLotteryPrizePoolAddress(_newAddress);
	}

	function setSmashTimeLotteryPrizePoolAddress (
		address _newAddress
	) external onlyOwner {
		_setSmashTimeLotteryPrizePoolAddress(_newAddress);
	}

	function setDonationLotteryPrizePoolAddress (
		address _newAddress
	) external onlyOwner {
		_setDonationLotteryPrizePoolAddress(_newAddress);
	}

	function setTeamAddress (
		address _newAddress
	) external onlyOwner {
		_setTeamAddress(_newAddress);
	}

	function setTeamAccumulationAddress (
		address _newAddress
	) external onlyOwner {
		_setTeamAccumulationAddress(_newAddress);
	}

	function setTreasuryAddress (
		address _newAddress
	) external onlyOwner {
		_setTreasuryAddress(_newAddress);
	}

	function setTreasuryAccumulationAddress (
		address _newAddress
	) external onlyOwner {
		_setTreasuryAccumulationAddress(_newAddress);
	}

	function setFeeConfig (
		uint256 _feeConfigRaw
	) external onlyOwner {
		_setFeeConfig(_feeConfigRaw);
	}

	function switchSmashTimeLotteryFlag (bool flag) external onlyOwner {
        _switchSmashTimeLotteryFlag(flag);
    }

    function switchHoldersLotteryFlag (bool flag) external onlyOwner {
        _switchHoldersLotteryFlag(flag);
    }

    function switchDonationsLotteryFlag (bool flag) external onlyOwner {
        _switchDonationsLotteryFlag(flag);
    }

	function excludeFromFee (address account) external onlyOwner {
		_isExcludedFromFee[account] = true;
	}

	function includeInFee (address account) external onlyOwner {
		_isExcludedFromFee[account] = false;
	}

    function setHoldersLotteryTxTrigger (
		uint64 _txAmount
	) external onlyOwner {
        _setHoldersLotteryTxTrigger(_txAmount);
    }

    function setDonationLotteryTxTrigger (
		uint64 _txAmount
	) external onlyOwner {
        _setDonationLotteryTxTrigger(_txAmount);
    }

    function setHoldersLotteryMinPercent (
		uint256 _minPercent
	) external onlyOwner {
        _setHoldersLotteryMinPercent(_minPercent);
    }

    function setDonationAddress (
		address _donationAddress
	) external onlyOwner {
        _setDonationAddress(_donationAddress);
    }

    function setMinimalDonation (
		uint256 _minimalDonation
	) external onlyOwner {
        _setMinimanDonation(_minimalDonation);
    }

	function setFees (
		uint256 _fee
	) external onlyOwner {
        fee = _fee;
    }

    function setMinimumDonationEntries (
		uint64 _minimumEntries
	) external onlyOwner {
       _setMinimumDonationEntries(_minimumEntries);
    }

	function burnFeePercent () external view returns (uint256) {
		return _fees.burnFeePercent(
			_calcFeePercent()
		);
	}

	function liquidityFeePercent () external view returns (uint256) {
		return _fees.liquidityFeePercent (
			_calcFeePercent()
		);
	}

	function distributionFeePercent () external view returns (uint256) {
		return _fees.distributionFeePercent(
			_calcFeePercent()
		);
	}

	function treasuryFeePercent () external view returns (uint256) {
		return _fees.treasuryFeePercent(
			_calcFeePercent()
		);
	}

	function devFeePercent () external view returns (uint256) {
		return _fees.devFeePercent(
			_calcFeePercent()
		);
	}

	function smashTimeLotteryPrizeFeePercent () external view returns (uint256) {
		return _fees.smashTimeLotteryPrizeFeePercent(
			_calcFeePercent()
		);
	}

	function holdersLotteryPrizeFeePercent () external view returns (uint256) {
		return _fees.holdersLotteryPrizeFeePercent(
			_calcFeePercent()
		);
	}

	function donationLotteryPrizeFeePercent () external view returns (uint256) {
		return _fees.donationLotteryPrizeFeePercent(
			_calcFeePercent()
		);
	}

	function isExcludedFromFee (address account) external view returns (bool) {
		return _isExcludedFromFee[account];
	}

	function isExcludedFromReward (address account) external view returns (bool) {
		return _isExcluded[account];
	}

	function smashTimeLotteryEnabled () external view returns (bool) {
        return _lotteryConfig.smashTimeLotteryEnabled;
    }

    function holdersLotteryEnabled () external view returns (bool) {
        return _lotteryConfig.smashTimeLotteryEnabled;
    }

    function holdersLotteryTxTrigger () external view returns (uint64) {
        return _lotteryConfig.holdersLotteryTxTrigger;
    }

    function holdersLotteryMinPercent () external view returns (uint256) {
        return _lotteryConfig.holdersLotteryMinPercent;
    }

    function donationAddress () external view returns (address) {
        return _lotteryConfig.donationAddress;
    }

    function donationsLotteryEnabled () external view returns (bool) {
        return _lotteryConfig.donationsLotteryEnabled;
    }

    function minimumDonationEntries () external view returns (uint64) {
        return _lotteryConfig.minimumDonationEntries;
    }

    function donationLotteryTxTrigger () external view returns (uint64) {
        return _lotteryConfig.donationLotteryTxTrigger;
    }

    function minimalDonation () external view returns (uint256) {
        return _lotteryConfig.minimalDonation;
    }

	function subscriptionId () external view returns (uint64) {
		return _consumerConfig.subscriptionId;
	}

	function callbackGasLimit () external view returns (uint32) {
		return _consumerConfig.callbackGasLimit;
	}

	function requestConfirmations () external view returns (uint16) {
		return _consumerConfig.requestConfirmations;
	}

	function gasPriceKey () external view returns (bytes32) {
		return _consumerConfig.gasPriceKey;
	}
}// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity ^0.8.19;

import {
    LotteryConfig
} from "../ConstantsAndTypes.sol";

abstract contract LotteryEngineConfig {

    LotteryConfig internal _lotteryConfig;

    constructor(
        LotteryConfig memory _config
    ) {
        _lotteryConfig = _config;
    }

    function _switchSmashTimeLotteryFlag (bool _flag) internal {
        _lotteryConfig.smashTimeLotteryEnabled = _flag;
    }

    function _switchHoldersLotteryFlag (bool _flag) internal {
        _lotteryConfig.holdersLotteryEnabled = _flag;
    }

    function _switchDonationsLotteryFlag (bool _flag) internal {
        _lotteryConfig.donationsLotteryEnabled = _flag;
    }

    function _setHoldersLotteryTxTrigger (uint64 _txAmount) internal {
        _lotteryConfig.holdersLotteryTxTrigger = _txAmount;
    }

    function _setDonationLotteryTxTrigger (uint64 _txAmount) internal {
        _lotteryConfig.donationLotteryTxTrigger = _txAmount;
    }

    function _setHoldersLotteryMinPercent (uint256 _minPercent) internal {
        _lotteryConfig.holdersLotteryMinPercent = _minPercent;
    }

    function _setDonationAddress (address _donationAddress) internal {
        _lotteryConfig.donationAddress = _donationAddress;
    }

    function _setMinimanDonation (uint256 _minimalDonation) internal {
        _lotteryConfig.minimalDonation = _minimalDonation;
    }

    function _setMinimumDonationEntries (uint64 _minimumEntries) internal {
        _lotteryConfig.minimumDonationEntries = _minimumEntries;
    }
}// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity ^0.8.19;

import {
	Fee,
	DistributionConfig,
	PRECISION
} from "../ConstantsAndTypes.sol";

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

	mapping( address => bool ) internal _isExcludedFromFee;
	mapping( address => bool ) internal _isExcluded;

	Fee internal _fees;

	constructor (
		DistributionConfig memory _config
	) {
		holderLotteryPrizePoolAddress = _config.holderLotteryPrizePoolAddress;
		smashTimeLotteryPrizePoolAddress = _config.smashTimeLotteryPrizePoolAddress;
		donationLotteryPrizePoolAddress = _config.donationLotteryPrizePoolAddress;
		teamFeesAccumulationAddress = _config.teamFeesAccumulationAddress;
		treasuryFeesAccumulationAddress = _config.treasuryFeesAccumulationAddress;
		teamAddress = _config.teamAddress;
		treasuryAddress = _config.treasuryAddress;
		_fees = _config.compact();
	}

	function _setHolderLotteryPrizePoolAddress (address _newAddress) internal {
		holderLotteryPrizePoolAddress = _newAddress;
	}

	function _setSmashTimeLotteryPrizePoolAddress (address _newAddress) internal {
		smashTimeLotteryPrizePoolAddress = _newAddress;
	}

	function _setDonationLotteryPrizePoolAddress (address _newAddress) internal {
		donationLotteryPrizePoolAddress = _newAddress;
	}

	function _setTeamAddress (address _newAddress) internal {
		teamAddress = _newAddress;
	}

	function _setTeamAccumulationAddress (address _newAddress) internal {
		teamFeesAccumulationAddress = _newAddress;
	}

	function _setTreasuryAccumulationAddress (address _newAddress) internal {
		treasuryFeesAccumulationAddress = _newAddress;
	}

	function _setTreasuryAddress (address _newAddress) internal {
		treasuryAddress = _newAddress;
	}

	function _setFeeConfig (uint256 _feeConfigRaw) internal {
		_fees = Fee.wrap(_feeConfigRaw);
	}
}// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {
	ConsumerConfig
} from "../ConstantsAndTypes.sol";

/**
	@title VRF Consumer Config
	@author shialabeoufsflag

	This contract is a component of the VRF Consumer contract, which contains
	internal logic for managing Consumer variables.
*/
abstract contract VRFConsumerConfig {

	ConsumerConfig internal _consumerConfig;

	/// Create an instance of the VRF consumer configuration contract.
	constructor (
		ConsumerConfig memory _config
	)
	{
		_consumerConfig = _config;
	}

	function _setConfig (ConsumerConfig calldata _newConfig) internal {
		_consumerConfig = _newConfig;
	}

	function _setSubscriptionId (uint64 _subscriptionId) internal {
		_consumerConfig.subscriptionId =  _subscriptionId;
	}

	function _setCallbackGasLimit (uint32 _callbackGasLimit) internal {
		_consumerConfig.callbackGasLimit =  _callbackGasLimit;
	}

	function _setRequestConfirmations (uint16 _requestConfirmations) internal {
		_consumerConfig.requestConfirmations =  _requestConfirmations;
	}

	function _setGasPriceKey (bytes32 _gasPriceKey) internal {
		_consumerConfig.gasPriceKey =  _gasPriceKey;
	}
}// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity ^0.8.19;

type Fee is uint256;
type Counter is uint256;
using {addition as +} for Counter global;

using TypesHelpers for Fee global;
using TypesHelpers for Counter global;
using TypesHelpers for Holders global;
using TypesHelpers for RuntimeCounter global;
using TypesHelpers for DistributionConfig global;
using TypesHelpers for LotteryConfig global;
using TypesHelpers for LotteryType global;

function addition(Counter a, Counter b) pure returns(Counter) {
	return Counter.wrap(Counter.unwrap(a) + Counter.unwrap(b));
}

function toRandomWords(
		uint256[] memory _array
	) pure returns (RandomWords memory _words) {
		assembly {
			_words := add(_array, ONE_WORD)
		}
	}

library TypesHelpers {

	function compact(
		DistributionConfig memory _config
	) internal pure returns (Fee) {
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

    function burnFeePercent (
		Fee feeConfig,
		uint256 fee
	) internal pure returns (uint256) {
		return fee * uint32(Fee.unwrap(feeConfig) >> 224) / PRECISION;
	}

	function liquidityFeePercent (
		Fee feeConfig,
		uint256 fee
	) internal pure returns (uint256) {
		return fee * uint32(Fee.unwrap(feeConfig) >> 192) / PRECISION;
	}

	function distributionFeePercent (
		Fee feeConfig,
		uint256 fee
	) internal pure returns (uint256) {
		return fee * uint32(Fee.unwrap(feeConfig) >> 160) / PRECISION;
	}

	function treasuryFeePercent (
		Fee feeConfig,
		uint256 fee
	) internal pure returns (uint256) {
		return fee * uint32(Fee.unwrap(feeConfig) >> 128) / PRECISION;
	}

	function devFeePercent (
		Fee feeConfig,
		uint256 fee
	) internal pure returns (uint256) {
		return fee * uint32(Fee.unwrap(feeConfig) >> 96) / PRECISION;
	}

	function smashTimeLotteryPrizeFeePercent (
		Fee feeConfig,
		uint256 fee
	) internal pure returns (uint256) {
		return fee * uint32(Fee.unwrap(feeConfig) >> 64) / PRECISION;
	}

	function holdersLotteryPrizeFeePercent (
		Fee feeConfig,
		uint256 fee
	) internal pure returns (uint256) {
		return fee * uint32(Fee.unwrap(feeConfig) >> 32) / PRECISION;
	}

	function donationLotteryPrizeFeePercent (
		Fee feeConfig,
		uint256 fee
	) internal pure returns (uint256) {
		return fee * uint32(Fee.unwrap(feeConfig)) / PRECISION;
	}

	function toDonationLotteryRuntime (
		LotteryConfig memory _runtime
	) internal pure returns (DonationLotteryConfig memory donationRuntime) {
		assembly {
			donationRuntime := add(_runtime, FOUR_WORDS)
		}
	}

	function toSmashTimeLotteryRuntime (
		LotteryConfig memory _runtime
	) internal pure returns (SmashTimeLotteryConfig memory smashTimeRuntime) {
		assembly {
			smashTimeRuntime := _runtime
		}
	}

	function toHoldersLotteryRuntime (
		LotteryConfig memory _runtime
	) internal pure returns (HoldersLotteryConfig memory holdersRuntime) {
		assembly {
			holdersRuntime := add(_runtime, ONE_WORD)
		}
	}

	function store (RuntimeCounter memory _counter) internal pure returns (Counter counter) {
		return _counter.counter;
	}

	function increaseDonationLotteryCounter (
		RuntimeCounter memory _counter
	) internal pure {
		_counter.counter = _counter.counter + INCREMENT_DONATION_COUNTER;
	}

	function increaseHoldersLotteryCounter (
		RuntimeCounter memory _counter
	) internal pure {
		_counter.counter = _counter.counter + INCREMENT_HOLDER_COUNTER;
	}

	function donationLotteryTxCounter (
		RuntimeCounter memory _counter
	) internal pure returns (uint256) {
		return Counter.unwrap(_counter.counter) >> 128;
	}

	function holdersLotteryTxCounter (
		RuntimeCounter memory _counter
	) internal pure returns (uint256) {
		return uint256(uint128(Counter.unwrap(_counter.counter)));
	}

	function resetDonationLotteryCounter (
		RuntimeCounter memory _counter
	) internal pure {
		uint256 raw = Counter.unwrap(_counter.counter);
		_counter.counter = Counter.wrap(uint256(uint128(raw)));
	}

	function resetHoldersLotteryCounter (
		RuntimeCounter memory _counter
	) internal pure {
		uint256 raw = Counter.unwrap(_counter.counter) >> 128;
		raw <<= 128;
		_counter.counter = Counter.wrap(raw);
	}


	function counterMemPtr (
		Counter _counter
	) internal pure returns (RuntimeCounter memory runtimeCounter) {
		runtimeCounter.counter = _counter;
	}

	function allTickets (Holders storage _holders) internal view returns (address[] memory) {
		address[] memory first = _holders.first;
		address[] memory second = _holders.second;
		address[] memory merged = new address[](first.length + second.length);
		for (uint256 i = 0; i < first.length;) {
			merged[i] = first[i];
			unchecked {
				++i;
			}
		}
		for (uint256 i = 0; i < second.length;) {
			merged[first.length + i] = second[i];
			unchecked {
				++i;
			}
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

		_holders.idx[_holder][1] = 0;
	}

	function existsSecond(Holders storage _holders, address _holder) internal view returns (bool) {
		return _holders.idx[_holder][1] != 0;
	}

	function isActive(LotteryType _lotteryType) internal pure returns (bool res) {
		assembly {
			switch _lotteryType
				case 1 {
					res := true
				}
				case 2 {
					res := true
				}
				case 3 {
					res := true
				}
				default {}
		}
	}
}

struct RuntimeCounter {
	Counter counter;
}

/**
	Packed configuration variables of the VRF consumer contract.

	subscriptionId - subscription id.
	callbackGasLimit - the maximum gas limit supported for a
		fulfillRandomWords callback.
	requestConfirmations - the minimum number of confirmation blocks on 
		VRF requests before oracles respond.
	gasPriceKey - Coordinator contract selects callback gas price limit by
		this key.
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
	bool holdersLotteryEnabled;
    uint64 holdersLotteryTxTrigger;
	uint256 holdersLotteryMinPercent;
	address donationAddress;
	bool donationsLotteryEnabled;
	uint64 minimumDonationEntries;
    uint64 donationLotteryTxTrigger;
    uint256 minimalDonation;
}

struct DonationLotteryConfig {
	address donationAddress;
	bool enabled;
	uint64 minimumEntries;
    uint64 lotteryTxTrigger;
    uint256 minimalDonation;
}

struct SmashTimeLotteryConfig {
	bool enabled;
}

struct HoldersLotteryConfig {
	bool enabled;
    uint64 lotteryTxTrigger;
	uint256 holdersLotteryMinPercent;
}

struct Holders {
	address[] first;
	address[] second;
	mapping (address => uint256[2]) idx;
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

struct LotteryRound {
	uint256 prize;
	LotteryType lotteryType;
	address winner;
	address jackpotPlayer;
	JackpotEntry jackpotEntry;
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
uint256 constant DONATION_TICKET_TIMEOUT = 3600;
uint256 constant ONE_WORD = 0x20;
uint256 constant FOUR_WORDS = 0x80;
uint256 constant TWENTY_FIVE_BITS = 25;
uint256 constant LOTTERY_CONFIG_SLOT = 10;
Counter constant INCREMENT_DONATION_COUNTER = Counter.wrap((uint256(1) << 128));
Counter constant INCREMENT_HOLDER_COUNTER = Counter.wrap(1);// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity ^0.8.19;

import {
	VRFCoordinatorV2Interface
} from "@chainlink/contracts/src/v0.8/interfaces/VRFCoordinatorV2Interface.sol";

import {
	ConsumerConfig,
	DistributionConfig,
	LotteryConfig,
	PancakeAdapter
} from "./PancakeAdapter.sol";

import {
	Counter,
	Holders,
	RuntimeCounter,
	HoldersLotteryConfig,
	SmashTimeLotteryConfig,
	DonationLotteryConfig,
	LotteryRound,
	LotteryType,
	JackpotEntry,
	DONATION_TICKET_TIMEOUT
} from "./ConstantsAndTypes.sol";

import {
	VRFConsumerBaseV2
} from "./chainlink/VRFConsumerBaseV2.sol";

/**

*/
abstract contract LotteryEngine is PancakeAdapter, VRFConsumerBaseV2 {

	error NoDonationTicketsToTransfer ();
	error RecipientsLengthNotEqualToAmounts ();

	mapping ( uint256 => LotteryRound) public rounds;

	uint256 internal _donationRound;
	mapping ( address => uint256 ) private _nextDonationTimestamp;
	mapping( uint256 => 
		mapping ( address => uint256[] ) ) internal _donatorTicketIdxs;
	address[] internal _donators;
	Holders internal _holders;

	Counter internal _counter;

	constructor (
		address _routerAddress,
		uint256 _fee,
		ConsumerConfig memory _consumerConfig,
		DistributionConfig memory _distributionConfig,
		LotteryConfig memory _lotteryConfig
	) PancakeAdapter(
		_routerAddress,
		_fee,
		_consumerConfig,
		_distributionConfig,
		_lotteryConfig
	) {}

	function _requestRandomWords(uint32 _wordsAmount) internal returns (uint256) {
		return	VRFCoordinatorV2Interface(VRF_COORDINATOR).requestRandomWords(
			_consumerConfig.gasPriceKey,
			_consumerConfig.subscriptionId,
			_consumerConfig.requestConfirmations,
			_consumerConfig.callbackGasLimit,
			_wordsAmount
		);
	}

	function _smashTimeLottery (
		address _transferrer,
		address _recipient,
		uint256 _amount,
		SmashTimeLotteryConfig memory _runtime
	) internal {
		if (_runtime.enabled) {
			if (_transferrer != PANCAKE_PAIR) {
				return;
			}

			if (_isExcluded[_recipient] || _isExcludedFromFee[_recipient]) {
				return;
			}

			uint256 usdAmount = _TokenPriceInUSD(_amount) /  _TUSD_DECIMALS;
			uint256 hundreds = usdAmount / 100;
			if (hundreds == 0) {
				return;
			}
			uint256 requestId = _requestRandomWords(2);
			rounds[requestId].lotteryType = LotteryType.JACKPOT;
			rounds[requestId].jackpotEntry = hundreds >= 10 ? 
				JackpotEntry.USD_1000 : 
				JackpotEntry(uint8(hundreds));
			rounds[requestId].jackpotPlayer = _recipient;
		}
	}

	function _triggerHoldersLottery (
		HoldersLotteryConfig memory _runtime,
		RuntimeCounter memory _runtimeCounter
	) internal {
		// increment tx counter.
		_runtimeCounter.increaseHoldersLotteryCounter();

		if (_runtimeCounter.holdersLotteryTxCounter() <  _runtime.lotteryTxTrigger) {
			return;
		}

		if (_holders.first.length == 0) {
			return;
		}

		uint256 requestId = _requestRandomWords(1);
		rounds[requestId].lotteryType = LotteryType.HOLDERS;
		_runtimeCounter.resetHoldersLotteryCounter();
	}

	function _donationsLottery (
		address _transferrer,
		address _recipient,
		uint256 _amount,
		DonationLotteryConfig memory _runtime,
		RuntimeCounter memory _runtimeCounter
	) internal {
		if (_runtime.enabled) {
			// if donation lottery is running, increment tx counter.
			_runtimeCounter.increaseDonationLotteryCounter();

			// if this transfer is a donation, add a ticket for transferrer.
			if (
				_recipient == _runtime.donationAddress && 
					_amount >= _runtime.minimalDonation
			) {
				if (block.timestamp > _nextDonationTimestamp[_transferrer]) {
					uint256 length = _donators.length;
					_donators.push(_transferrer);
					_donatorTicketIdxs[_donationRound][_transferrer].push(length);
					_nextDonationTimestamp[_transferrer] = 
						block.timestamp + DONATION_TICKET_TIMEOUT;
				}
			}

			// check if minimum donation entries requirement is met.
			if (_donators.length < _runtime.minimumEntries) {
				return;
			}

			// check if tx counter can trigger the lottery.
			if (
				_runtimeCounter.donationLotteryTxCounter() < 
					_runtime.lotteryTxTrigger
			) {
				return;
			}
			uint256 requestId = _requestRandomWords(1);
			rounds[requestId].lotteryType = LotteryType.DONATION;

			_runtimeCounter.resetDonationLotteryCounter();
		}
	}

	function transferDonationTicket (address _to) external {
		uint256 round = _donationRound;
		uint256 length = _donatorTicketIdxs[round][msg.sender].length;
		if (length == 0) {
			revert NoDonationTicketsToTransfer ();
		}

		uint256 idx = _donatorTicketIdxs[round][msg.sender][length - 1];
		_donatorTicketIdxs[round][msg.sender].pop();
		_donators[idx] = _to;
		_donatorTicketIdxs[round][_to].push(idx);
	}

	function mintDonationTickets (
		address[] calldata _recipients,
		uint256[] calldata _amounts
	) external onlyOwner {
		if (_recipients.length != _amounts.length) {
			revert RecipientsLengthNotEqualToAmounts();
		}
		uint256 round = _donationRound;
		for (uint256 i; i < _recipients.length;) {
			uint256 idx = _donatorTicketIdxs[round][_recipients[i]].length;
			for (uint256 j; j < _amounts[i];) {
				_donators.push(_recipients[i]);
				_donatorTicketIdxs[round][_recipients[i]].push(idx);
				unchecked {
					++j;
					++idx;
				}
			}
			unchecked {
				++i;
			}
		}
	}

	function holdersLotteryTickets () external view returns (address[] memory) {
		return _holders.allTickets();
	}

	function donationLotteryTickets () external view returns (address[] memory) {
		return _donators;
	}
}// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity ^0.8.19;

import {
	IPancakeRouter02
} from "../interfaces/IPancakeRouter02.sol";

import {
	IPancakeFactory
} from "../interfaces/IPancakeFactory.sol";

import {
	Configuration
} from "./configs/Configuration.sol";

import {
	ConsumerConfig,
	DistributionConfig,
	LotteryConfig
} from "./ConstantsAndTypes.sol";

abstract contract PancakeAdapter is Configuration {

	address internal constant _TUSD_ADDRESS = 
		0x40af3827F39D0EAcBF4A168f8D4ee67c121D11c9;
	address internal constant _WBNB_ADDRESS = 
		0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c;
	uint256 internal constant _TUSD_DECIMALS = 1e18;

	IPancakeRouter02 public immutable PANCAKE_ROUTER;

	address public immutable PANCAKE_PAIR;

	constructor (
		address _routerAddress,
		uint256 _fee,
		ConsumerConfig memory _consumerConfig,
		DistributionConfig memory _distributionConfig,
		LotteryConfig memory _lotteryConfig
	) Configuration(
		_fee,
		_consumerConfig,
		_distributionConfig,
		_lotteryConfig
	) {
		PANCAKE_ROUTER = IPancakeRouter02(_routerAddress);
		PANCAKE_PAIR = _createPancakeSwapPair();
	}

	function _createPancakeSwapPair () internal returns (address) {
		return IPancakeFactory(PANCAKE_ROUTER.factory()).createPair(
			address(this), _WBNB_ADDRESS
		);
	}

	function _addLiquidity (uint256 tokenAmount, uint256 bnbAmount) internal {
		PANCAKE_ROUTER.addLiquidityETH{value : bnbAmount}(
			address(this),
			tokenAmount,
			0, // slippage is unavoidable
			0, // slippage is unavoidable
			owner(),
			block.timestamp
		);
	}

	function _swapTokensForBNB (
		uint256 _tokensAmount
	) internal returns (uint256 bnbAmount) {
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

		unchecked{
			bnbAmount =  address(this).balance - balanceBeforeSwap;
		}
	}

	function _swapTokensForBNB (
		uint256 _tokensAmount,
		address _to
	) internal {

		// generate the pancakeswap pair path of Token -> BNB
		address[] memory path = new address[](2);
		path[0] = address(this);
		path[1] = _WBNB_ADDRESS;

		// make the swap
		PANCAKE_ROUTER.swapExactTokensForETHSupportingFeeOnTransferTokens(
			_tokensAmount / 10,
			0, // accept any amount of ETH
			path,
			_to,
			block.timestamp
		);
	}

	function _swapTokensForTUSDT (
		uint256 _tokensAmount,
		address _to
	) internal {
		// generate the pancake pairs path of Token -> BNB -> USDT
		address[] memory path = new address[](3);
		path[0] = address(this);
		path[1] = _WBNB_ADDRESS;
		path[2] = _TUSD_ADDRESS;

		PANCAKE_ROUTER.swapExactTokensForTokensSupportingFeeOnTransferTokens(
			_tokensAmount,
			0, // accept any amount of USDT
			path,
			_to,
			block.timestamp
		);
	}

	function _TokenPriceInUSD (
		uint256 _amount
	) internal view returns (uint256 usdAmount) {
		// generate the uniswap pair path of BNB -> USDT
		address[] memory path = new address[](3);
		path[0] = address(this);
		path[1] = _WBNB_ADDRESS;
		path[2] = _TUSD_ADDRESS;

		usdAmount = PANCAKE_ROUTER.getAmountsOut(_amount, path)[2];
	}
}// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity ^0.8.19;

import {
	ILotteryToken
} from "./interfaces/ILotteryToken.sol";

import {
	VRFConsumerBaseV2
} from "./lib/chainlink/VRFConsumerBaseV2.sol";

import {
	HoldersLotteryConfig,
	RuntimeCounter,
	ConsumerConfig,
    DistributionConfig,
	LotteryConfig,
	LotteryEngine,
	LotteryRound
} from "./lib/LotteryEngine.sol";

import {
	TWENTY_FIVE_BITS,
	DAY_ONE_LIMIT,
	DAY_TWO_LIMIT,
	DAY_THREE_LIMIT,
	MAX_UINT256,
	DEAD_ADDRESS,
	TWENTY_FIVE_PERCENTS,
	SEVENTY_FIVE_PERCENTS,
	PRECISION,
	LotteryType,
	RandomWords,
	toRandomWords,
	Fee
} from "./lib/ConstantsAndTypes.sol";
import {
	IERC20
} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract TestToken is LotteryEngine, ILotteryToken {

	error TransferAmountExceededForToday ();
	error TransferToZeroAddress ();
	error TransferFromZeroAddress ();
	error TransferAmountIsZero ();
	error ExcludedAccountCanNotCall ();
	error TransferAmountExceedsAllowance ();
	error CanNotDecreaseAllowance ();
	error AccountAlreadyExcluded ();
	error AccountAlreadyIncluded ();
	error CannotApproveToZeroAddress ();
	error ApproveAmountIsZero ();
	error AmountIsGreaterThanTotalReflections ();
	error TransferAmountExceedsPurchaseAmount ();
	error BNBWithdrawalFailed ();

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

	uint256 public liquiditySupplyThreshold = 1000 * 1e18;

	uint256 public feeSupplyThreshold = 1000 * 1e18;

	uint8 public constant decimals = 18;
	
	modifier lockTheSwap {
		_lock = SwapStatus.Locked;
		_;
		_lock = SwapStatus.Open;
	}

	modifier swapLockOnPairCall {
		if (msg.sender == PANCAKE_PAIR) {
			_lock = SwapStatus.Locked;
			_;
			_lock = SwapStatus.Open;
		} else {
			_;
		}
	}

	SwapStatus private _lock = SwapStatus.Open;
  
	mapping ( address => uint256 ) private _rOwned;
	mapping(address => uint256) private _tOwned;
	mapping(address => mapping(address => uint256)) private _allowances;

	mapping(address => bool) public whitelist;
	address[] private _excluded;

	uint256 private _tTotal = 10_000_000_000 * 1e18;

	uint256 public maxTxAmount = 
		10_000_000_000 * 1e18;

	uint256 public maxBuyPercent = 10_000;

	uint256 private _rTotal = (MAX_UINT256 - (MAX_UINT256 % _tTotal));
	uint256 private _tFeeTotal;

	bool public swapAndLiquifyEnabled = true;
	bool public threeDaysProtectionEnabled = false;

	uint256 public smashTimeWins;
	uint256 public donationLotteryWinTimes;
	uint256 public holdersLotteryWinTimes;
	uint256 public totalAmountWonInSmashTimeLottery;
	uint256 public totalAmountWonInDonationLottery;
	uint256 public totalAmountWonInHoldersLottery;

	constructor (
		address _mintSupplyTo,
		address _coordinatorAddress,
		address _routerAddress,
		uint256 _fee,
		ConsumerConfig memory _cConfig,
		DistributionConfig memory _dConfig,
		LotteryConfig memory _lConfig
	)
		VRFConsumerBaseV2(_coordinatorAddress)
		LotteryEngine(
			_routerAddress,
			_fee,
			_cConfig,
			_dConfig,
			_lConfig
		)
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
		_isExcludedFromFee[_lConfig.donationAddress] = true;
		_isExcludedFromFee[_mintSupplyTo] = true;
		_isExcludedFromFee[_dConfig.holderLotteryPrizePoolAddress] = true;
		_isExcludedFromFee[_dConfig.smashTimeLotteryPrizePoolAddress] = true;
		_isExcludedFromFee[_dConfig.donationLotteryPrizePoolAddress] = true;
		_isExcludedFromFee[_dConfig.teamAddress] = true;
		_isExcludedFromFee[_dConfig.teamFeesAccumulationAddress] = true;
		_isExcludedFromFee[_dConfig.treasuryAddress] = true;
		_isExcludedFromFee[_dConfig.treasuryFeesAccumulationAddress] = true;
		_isExcludedFromFee[DEAD_ADDRESS] = true;

		_approve(address(this), address(PANCAKE_ROUTER), type(uint256).max);
	}

	function name () public pure returns (string memory) {
		return "Test Token";
	}

	function symbol () public pure returns (string memory) {
		return "TT";
	}

	function totalSupply () public view returns (uint256) {
		return _tTotal;
	}

	function balanceOf (address account) public view returns (uint256) {
		if (_isExcluded[account]) {
			return _tOwned[account];	
		}
		return tokenFromReflection(_rOwned[account]);
	}

	function transfer (
		address recipient,
		uint256 amount
	) external returns (bool) {
		_transfer(msg.sender, recipient, amount);
		return true;
	}

	function allowance (
		address owner,
		address spender
	) external view returns (uint256) {
		return _allowances[owner][spender];
	}

	function approve (
		address spender,
		uint256 amount
	) external returns (bool) {
		if (spender == address(0)) {
			revert CannotApproveToZeroAddress();
		}
		if (amount == 0) {
			revert ApproveAmountIsZero();
		}

		_approve(msg.sender, spender, amount);
		return true;
	}

	function transferFrom (
		address sender,
		address recipient,
		uint256 amount
	) public returns (bool) {

		if (_allowances[sender][msg.sender] < amount) {
			revert TransferAmountExceedsAllowance();
		}

		_transfer(sender, recipient, amount);
		if (_allowances[sender][msg.sender] != MAX_UINT256) {
			unchecked {
				_allowances[sender][msg.sender] -= amount;
			}
		}
		return true;
	}

	function increaseAllowance (
		address spender,
		uint256 addedValue
	) external virtual returns (bool) {
		_allowances[msg.sender][spender] += addedValue;
		return true;
	}

	function decreaseAllowance (
		address spender,
		uint256 subtractedValue
	) external virtual returns (bool) {
		if (_allowances[msg.sender][spender] < subtractedValue) {
			revert CanNotDecreaseAllowance();
		}
		_allowances[msg.sender][spender] -= subtractedValue;
		return true;
	}

	function totalFees () public view returns (uint256) {
		return _tFeeTotal;
	}

	function deliver (uint256 tAmount) public {
		if (_isExcluded[msg.sender]) {
			revert ExcludedAccountCanNotCall();
		}
		(RInfo memory rr,) = _getValues(tAmount, true);
		_rOwned[msg.sender] -= rr.rAmount;
		_rTotal -= rr.rAmount;
		_tFeeTotal = _tFeeTotal - tAmount;
	}

	function reflectionFromToken (
		uint256 tAmount,
		bool deductTransferFee
	) public view returns (uint256) {

		if (tAmount > _tTotal) {
			return 0;
		}

		(RInfo memory rr,) = _getValues(tAmount, deductTransferFee);
		return rr.rTransferAmount;
	}

	function tokenFromReflection (uint256 rAmount) public view returns (uint256) {
		if (rAmount > _rTotal) {
			revert AmountIsGreaterThanTotalReflections();
		}
		uint256 currentRate = _getRate();
		return rAmount / currentRate;
	}

	receive () external payable {}

	function _fulfillRandomWords (
		uint256 _requestId,
		uint256[] memory _randomWords
	) internal override {
		_finishRound(_requestId, toRandomWords(_randomWords));
	}

	function _reflectFee (RInfo memory rr, TInfo memory tt) private {
		_rTotal -= rr.rDistributionFee;
		_tFeeTotal += tt.tBurnFee + tt.tLiquidityFee +
			tt.tDistributionFee + tt.tTreasuryFee +
			tt.tDevFundFee + tt.tSmashTimePrizeFee +
			tt.tHolderPrizeFee + tt.tDonationLotteryPrizeFee;

		_rOwned[smashTimeLotteryPrizePoolAddress] +=
			rr.rSmashTimePrizeFee;
		_rOwned[holderLotteryPrizePoolAddress] +=
			rr.rHolderPrizeFee;
		_rOwned[donationLotteryPrizePoolAddress] +=
			rr.rDonationLotteryPrizeFee;
		_rOwned[teamFeesAccumulationAddress] +=
			rr.rDevFundFee;
		_rOwned[treasuryFeesAccumulationAddress] += 
			rr.rTreasuryFee;
		_rOwned[DEAD_ADDRESS] +=
			rr.rBurnFee;

		if( tt.tHolderPrizeFee > 0)
			emit Transfer(
				msg.sender,
				holderLotteryPrizePoolAddress,
				tt.tHolderPrizeFee
			);

		if( tt.tSmashTimePrizeFee > 0)
			emit Transfer(
				msg.sender,
				smashTimeLotteryPrizePoolAddress,
				tt.tSmashTimePrizeFee
			);

		if( tt.tDevFundFee > 0 )
			emit Transfer(
				msg.sender,
				teamFeesAccumulationAddress,
				tt.tDevFundFee
			);

		if( tt.tTreasuryFee > 0 )
			emit Transfer(
				msg.sender,
				treasuryFeesAccumulationAddress,
				tt.tTreasuryFee
			);

		if( tt.tDonationLotteryPrizeFee > 0 )
			emit Transfer(
				msg.sender,
				donationLotteryPrizePoolAddress,
				tt.tDonationLotteryPrizeFee
			);

		if( tt.tBurnFee > 0 )
			emit Transfer(
				msg.sender,
				DEAD_ADDRESS,
				tt.tBurnFee
			);
	}

	function _getValues (
		uint256 tAmount,
		bool takeFee
	) private view returns (RInfo memory rr, TInfo memory tt) {
		tt = _getTValues(tAmount, takeFee);
		rr = _getRValues(
			tAmount,
			tt,
			_getRate()
		);
		return (rr, tt);
	}

	function _getTValues(
		uint256 tAmount,
		bool takeFee
	) private view returns (TInfo memory tt) {
		uint256 fee = _calcFeePercent();
		Fee fees = _fees;
		tt.tBurnFee = takeFee ?
			fees.burnFeePercent(fee) * tAmount / PRECISION : 0;
		tt.tDistributionFee = takeFee ?
			fees.distributionFeePercent(fee) * tAmount / PRECISION : 0;
		tt.tTreasuryFee = takeFee ?
			fees.treasuryFeePercent(fee) * tAmount / PRECISION : 0;
		tt.tDevFundFee = takeFee ?
			fees.devFeePercent(fee) * tAmount / PRECISION : 0;
		tt.tSmashTimePrizeFee = takeFee ?
			fees.smashTimeLotteryPrizeFeePercent(fee) * tAmount / PRECISION : 0;
		tt.tHolderPrizeFee = takeFee ?
			fees.holdersLotteryPrizeFeePercent(fee) * tAmount / PRECISION : 0;
		tt.tDonationLotteryPrizeFee = takeFee ?
			fees.donationLotteryPrizeFeePercent(fee) * tAmount / PRECISION : 0;
		tt.tLiquidityFee = takeFee ? 
			fees.liquidityFeePercent(fee) * tAmount / PRECISION : 0;

		uint totalFee = tt.tBurnFee + tt.tLiquidityFee + tt.tDistributionFee +
			tt.tTreasuryFee + tt.tDevFundFee + tt.tSmashTimePrizeFee +
			tt.tDonationLotteryPrizeFee + tt.tHolderPrizeFee;

		tt.tTransferAmount = tAmount - totalFee;
		return tt;
	}

	function _getRValues (
		uint256 tAmount,
		TInfo memory tt,
		uint256 currentRate
	) private pure returns (RInfo memory rr) {
		rr.rAmount = 
			tAmount * currentRate;
		rr.rBurnFee = 
			tt.tBurnFee * currentRate;
		rr.rLiquidityFee = 
			tt.tLiquidityFee * currentRate;
		rr.rDistributionFee = 
			tt.tDistributionFee * currentRate;
		rr.rTreasuryFee = 
			tt.tTreasuryFee * currentRate;
		rr.rDevFundFee = 
			tt.tDevFundFee * currentRate;
		rr.rSmashTimePrizeFee = 
			tt.tSmashTimePrizeFee * currentRate;
		rr.rHolderPrizeFee = 
			tt.tHolderPrizeFee * currentRate;
		rr.rDonationLotteryPrizeFee = 
			tt.tDonationLotteryPrizeFee * currentRate;
		
		uint totalFee = rr.rBurnFee + rr.rLiquidityFee + rr.rDistributionFee +
			rr.rTreasuryFee + rr.rDevFundFee + rr.rSmashTimePrizeFee +
			rr.rDonationLotteryPrizeFee + rr.rHolderPrizeFee;

		rr.rTransferAmount = rr.rAmount - totalFee;
		return rr;
	}

	function _getRate () private view returns (uint256) {
		(uint256 rSupply, uint256 tSupply) = _getCurrentSupply();
		return rSupply / tSupply;
	}

	function _getCurrentSupply () private view returns (uint256, uint256) {
		uint256 rSupply = _rTotal;
		uint256 tSupply = _tTotal;
		for (uint256 i = 0; i < _excluded.length; i++) {
			if (_rOwned[_excluded[i]] > rSupply || _tOwned[_excluded[i]] > tSupply) {
				return (_rTotal, _tTotal);
			}
			rSupply = rSupply - _rOwned[_excluded[i]];
			tSupply = tSupply - _tOwned[_excluded[i]];
		}
		if (rSupply < _rTotal / _tTotal) {
			return (_rTotal, _tTotal);
		}
		return (rSupply, tSupply);
	}

	function _takeLiquidity (uint256 rLiquidity, uint256 tLiquidity) private {
		_rOwned[address(this)] = _rOwned[address(this)] + rLiquidity;
		if (_isExcluded[address(this)])
			_tOwned[address(this)] = _tOwned[address(this)] + tLiquidity;
	}

	function _approve (address owner, address spender, uint256 amount) private {
		_allowances[owner][spender] = amount;
		emit Approval(owner, spender, amount);
	}


	function _antiAbuse (address from, address to, uint256 amount) private view {

		if (from == owner() || to == owner())
		//  if owner we just return or we can't add liquidity
			return;

		uint256 allowedAmount;

		(, uint256 tSupply) = _getCurrentSupply();
		uint256 lastUserBalance = balanceOf(to) + (amount * 
			(PRECISION - _calcFeePercent()) / PRECISION);

		// bot \ whales prevention
		if (threeDaysProtectionEnabled) {
			if (block.timestamp <= (_creationTime + 1 days)) {
				allowedAmount = tSupply * DAY_ONE_LIMIT / PRECISION;

				if (lastUserBalance >= allowedAmount) {
					revert TransferAmountExceededForToday();
				}
			}
			
			if (block.timestamp <= (_creationTime + 2 days)) {
				allowedAmount = tSupply * DAY_TWO_LIMIT / PRECISION;

				if (lastUserBalance >= allowedAmount) {
					revert TransferAmountExceededForToday();
				}
			} 
			
			if (block.timestamp <= (_creationTime + 3 days)) {
				allowedAmount = tSupply * DAY_THREE_LIMIT / PRECISION;

				if (lastUserBalance >= allowedAmount) {
					revert TransferAmountExceededForToday();
				}
			}
		}
		if (amount > balanceOf(PANCAKE_PAIR) * maxBuyPercent / PRECISION) {
			revert TransferAmountExceedsPurchaseAmount();
		}
	}
		
	function _transfer (
		address from,
		address to,
		uint256 amount
	) private swapLockOnPairCall {
		if (from == address(0)) {
			revert TransferFromZeroAddress();
		}
		if (to == address(0)) {
			revert TransferToZeroAddress();
		}
		if (amount == 0) {
			revert TransferAmountIsZero();
		}
		
		uint256 contractTokenBalance = balanceOf(address(this));
		// whitelist to allow treasure to add liquidity:
		if (!whitelist[from] && !whitelist[to]) {
			if( from == PANCAKE_PAIR ){
				_antiAbuse(from, to, amount);
			}
			
			// is the token balance of this contract address over the min number of
			// tokens that we need to initiate a swap + liquidity lock?
			// also, don't get caught in a circular liquidity event.
			// also, don't swap & liquify if sender is uniswap pair.

			if (contractTokenBalance >= maxTxAmount) {
				contractTokenBalance = maxTxAmount;
			}
		}

		bool overMinTokenBalance = 
			contractTokenBalance >= liquiditySupplyThreshold;
		if (
			overMinTokenBalance &&
			_lock == SwapStatus.Open &&
			from != PANCAKE_PAIR &&
			swapAndLiquifyEnabled
		) {
			contractTokenBalance = liquiditySupplyThreshold;
			//add liquidity
			_swapAndLiquify(contractTokenBalance);
		}

		//indicates if fee should be deducted from transfer
		bool takeFee = !_isExcludedFromFee[from] && !_isExcludedFromFee[to];

		_lotteryOnTransfer(from, to, amount, takeFee);

		// process transfer and lotteries
		if (_lock == SwapStatus.Open) {
			_distributeFees();
		}
	}

	function _distributeFees () private lockTheSwap {
		uint256 teamBalance = balanceOf(teamFeesAccumulationAddress);
		if (teamBalance >= feeSupplyThreshold) {
			uint256 balanceBefore = balanceOf(address(this));
			uint256 half = teamBalance / 2;
			uint256 otherHalf = balanceBefore - half;
			_tokenTransfer(
				teamFeesAccumulationAddress,
				address(this),
				teamBalance,
				false
			);
			uint256 forth = half / 2;
			uint256 otherForth = half - forth;
			_swapTokensForTUSDT(forth, teamAddress);
			_swapTokensForBNB(otherForth, teamAddress);
			uint256 balanceAfter = balanceOf(address(this));
			if (balanceAfter > 0) {
				_tokenTransfer(
					address(this),
					teamAddress,
					balanceAfter - balanceBefore + otherHalf,
					false
				);
			}
		}
		
		uint256 treasuryBalance = balanceOf(treasuryFeesAccumulationAddress);
		if (treasuryBalance >= feeSupplyThreshold) {
			uint256 balanceBefore = balanceOf(address(this));
			uint256 half = teamBalance / 2;
			uint256 otherHalf = balanceBefore - half;
			_tokenTransfer( 
				treasuryFeesAccumulationAddress,
				address(this),
				treasuryBalance,
				false
			);  
			uint256 forth = half / 2;
			uint256 otherForth = half - forth;
			_swapTokensForTUSDT(forth, treasuryAddress);
			_swapTokensForBNB(otherForth, treasuryAddress);
			uint256 balanceAfter = balanceOf(address(this));
			if (balanceAfter > 0) {
				_tokenTransfer(
					address(this),
					treasuryAddress,
					balanceAfter - balanceBefore + otherHalf,
					false
				);
			}
		}
	}

	function _checkForHoldersLotteryEligibility (
		address _participant,
		uint256 _balanceThreshold
	) private {
		if ( _participant == address(PANCAKE_ROUTER)) {
			return;
        }

		if (_participant == PANCAKE_PAIR) {
			return;
		}

		if (_isExcludedFromFee[_participant] || _isExcluded[_participant] ) {
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

	function _holdersEligibilityThreshold (
		uint256 _minPercent
	) private view returns (uint256) {
		return (_tTotal - balanceOf(DEAD_ADDRESS)) *
			_minPercent /
			PRECISION;
	}

	function _holdersLottery (
		address _transferrer,
		address _recipient,
		HoldersLotteryConfig memory _runtime,
		RuntimeCounter memory _runtimeCounter
	) private {

		if (!_runtime.enabled) {
			return;
		}

		_checkForHoldersLotteryEligibility(
			_transferrer,
			_holdersEligibilityThreshold(_runtime.holdersLotteryMinPercent)
		);
		
		_checkForHoldersLotteryEligibility(
			_recipient,
			_holdersEligibilityThreshold(_runtime.holdersLotteryMinPercent)
		);

		_triggerHoldersLottery(
			_runtime,
			_runtimeCounter
		);
	}

	function _lotteryOnTransfer (
		address _transferrer,
		address _recipient,
		uint256 _amount,
		bool _takeFee
	) private {
		// Save configs and counter to memory to decrease amount of storage reads.
		LotteryConfig memory runtime = _lotteryConfig;
		RuntimeCounter memory runtimeCounter = _counter.counterMemPtr();

		_smashTimeLottery(
			_transferrer,
			_recipient,
			_amount,
			runtime.toSmashTimeLotteryRuntime()
		);

		//transfer amount, it will take tax, burn, liquidity fee
		_tokenTransfer(_transferrer, _recipient, _amount, _takeFee);

		_holdersLottery(
			_transferrer,
			_recipient,
			runtime.toHoldersLotteryRuntime(),
			runtimeCounter
		);

		_donationsLottery(
			_transferrer,
			_recipient,
			_amount,
			runtime.toDonationLotteryRuntime(),
			runtimeCounter
		);

		_counter = runtimeCounter.store();
	}

	function _swapAndLiquify (
		uint256 contractTokenBalance
	) private lockTheSwap {
		// split the contract balance into halves
		uint256 half = contractTokenBalance / 2;
		uint256 otherHalf = contractTokenBalance - half;
		uint256 nativeBalance =  _swap(half);

		// add liquidity to pancake
		_liquify(otherHalf, nativeBalance);
	}

	function _swap(uint256 tokenAmount) private returns (uint256) {
		return _swapTokensForBNB(tokenAmount);
	}

	function _liquify (
		uint256 tokenAmount,
		uint256 bnbAmount
	)
	private {
		_addLiquidity(tokenAmount, bnbAmount);
	}

	//this method is responsible for taking all fee, if takeFee is true
	function _tokenTransfer (
		address sender,
		address recipient,
		uint256 amount,
		bool takeFee
	) private {
		bool senderExcluded = _isExcluded[sender];
		bool recipientExcluded = _isExcluded[recipient];

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

	function _transferStandard (
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

	function _transferToExcluded (
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

	function _transferFromExcluded (
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

	function _transferBothExcluded (
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

	function totalFeePercent () external view returns (uint256) {
		return _calcFeePercent();
	}

	function _finishRound (
		uint256 _requestId,
		RandomWords memory _random
	) private {
		LotteryRound storage round = rounds[_requestId];

		if (round.lotteryType == LotteryType.JACKPOT) {
			_finishSmashTimeLottery(round, _random);
		}

		if (round.lotteryType == LotteryType.HOLDERS) {
			_finishHoldersLottery(round, _random.first);
		}

		if (round.lotteryType == LotteryType.DONATION) {
			_finishDonationLottery(round, _random.first);
		}
	}

	function _calculateSmashTimeLotteryPrize () private view returns (uint256) {
		return balanceOf(smashTimeLotteryPrizePoolAddress) *
			TWENTY_FIVE_PERCENTS / PRECISION;
	}

	function _calculateHoldersLotteryPrize () private view returns (uint256) {
		return balanceOf(holderLotteryPrizePoolAddress) *
			SEVENTY_FIVE_PERCENTS / PRECISION;
	}


	function _calculateDonationLotteryPrize () private view returns (uint256) {
		return balanceOf(donationLotteryPrizePoolAddress) * 
			SEVENTY_FIVE_PERCENTS / PRECISION;
	}

	function _seedTicketsArray (
		address[100] memory _tickets,
		uint256 _index,
		address _player
	) internal pure {
		if (_tickets[_index] == _player) {
			_seedTicketsArray(_tickets, _index + 1, _player);
		} else {
			_tickets[_index] = _player;
		}
	}

	function _finishSmashTimeLottery (
		LotteryRound storage _round,
		RandomWords memory _random
	) private {
		address player = _round.jackpotPlayer;
		address[100] memory tickets;
		for (uint256 i; i < uint8(_round.jackpotEntry);) {
			uint256 shift = (i * TWENTY_FIVE_BITS);
			uint256 idx = _random.second >> shift;
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
			uint256 prize = _calculateSmashTimeLotteryPrize();
			_tokenTransfer(
				smashTimeLotteryPrizePoolAddress,
				address(this),
				prize,
				false
			);

			_swapTokensForBNB(prize, player);
			totalAmountWonInSmashTimeLottery += prize;
			smashTimeWins += 1;
			_round.winner = player;
			_round.prize = prize;
		}
		
		_round.lotteryType = LotteryType.FINISHED_JACKPOT;
	}

	function _finishHoldersLottery (
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

		_tokenTransfer(
			holderLotteryPrizePoolAddress,
			winner,
			prize,
			false
		);

		holdersLotteryWinTimes += 1;
		totalAmountWonInHoldersLottery += prize;
		_round.winner = winner;
		_round.prize = prize;
		_round.lotteryType = LotteryType.FINISHED_HOLDERS;
	}

	function _finishDonationLottery (
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

		_tokenTransfer(
			donationLotteryPrizePoolAddress,
			address(this),
			prize,
			false
		);
		
		_swapTokensForBNB(prize, winner);
		
		donationLotteryWinTimes += 1;
		totalAmountWonInDonationLottery += prize;
		_round.winner = winner;
		_round.prize = prize;
		_round.lotteryType = LotteryType.FINISHED_DONATION;

		delete _donators;
		_donationRound += 1;
	}

	function donate (uint256 _amount) external {
		_transfer(msg.sender, _lotteryConfig.donationAddress, _amount);
	}

	function updateHolderList (
		address[] calldata holdersToCheck
	) external onlyOwner {
        for( uint i = 0 ; i < holdersToCheck.length ; i ++ ){
            _checkForHoldersLotteryEligibility(
				holdersToCheck[i],
				(_tTotal - balanceOf(DEAD_ADDRESS)) *
				_lotteryConfig.holdersLotteryMinPercent /
				PRECISION
			);
        }
    }

	function excludeFromReward (address account) public onlyOwner() {
		if (_isExcluded[account]) {
			revert AccountAlreadyExcluded();
		}

		if (_rOwned[account] > 0) {
			_tOwned[account] = tokenFromReflection(_rOwned[account]);
		}
		_isExcluded[account] = true;
		_excluded.push(account);
	}

	function includeInReward (address account) external onlyOwner() {
		if (!_isExcluded[account]) {
			revert AccountAlreadyIncluded();
		}
		for (uint256 i = 0; i < _excluded.length; i++) {
			if (_excluded[i] == account) {
				_excluded[i] = _excluded[_excluded.length - 1];
				_tOwned[account] = 0;
				_isExcluded[account] = false;
				_excluded.pop();
				break;
			}
		}
	}

	// whitelist to add liquidity
	function setWhitelist (address account, bool _status) external onlyOwner {
		whitelist[account] = _status;
	}

	function setMaxTxPercent (uint256 maxTxPercent) external onlyOwner() {
		maxTxAmount = _tTotal * maxTxPercent / PRECISION;
	}

	function setMaxBuyPercent (uint256 _maxBuyPercent) external onlyOwner() {
		maxBuyPercent = _maxBuyPercent;
	}

	function setSwapAndLiquifyEnabled (bool _enabled) external onlyOwner {
		swapAndLiquifyEnabled = _enabled;
	}

	function setLiquiditySupplyThreshold (uint256 _amount) external onlyOwner {
		liquiditySupplyThreshold = _amount;
	}

	function setFeeSupplyThreshold (uint256 _amount) external onlyOwner {
		feeSupplyThreshold = _amount;
	}

	function setThreeDaysProtection (bool _enabled) external onlyOwner {
		threeDaysProtectionEnabled = _enabled;
	}

	function withdraw (uint256 _amount) external onlyOwner {
		_transferStandard(address(this), msg.sender, _amount, false);
	}

	function withdrawBNB (uint256 _amount) external onlyOwner {
		(bool res, ) = msg.sender.call{value: _amount}("");
		if (!res) {
			revert BNBWithdrawalFailed();
		}
	}
}