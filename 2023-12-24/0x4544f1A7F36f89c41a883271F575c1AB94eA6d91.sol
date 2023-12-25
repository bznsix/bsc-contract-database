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
// OpenZeppelin Contracts (last updated v4.9.0) (security/ReentrancyGuard.sol)

pragma solidity ^0.8.0;

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
     * by making the `nonReentrant` function external, and making it call a
     * `private` function that does the actual work.
     */
    modifier nonReentrant() {
        _nonReentrantBefore();
        _;
        _nonReentrantAfter();
    }

    function _nonReentrantBefore() private {
        // On the first call to nonReentrant, _status will be _NOT_ENTERED
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");

        // Any calls to nonReentrant after this point will fail
        _status = _ENTERED;
    }

    function _nonReentrantAfter() private {
        // By storing the original value once again, a refund is triggered (see
        // https://eips.ethereum.org/EIPS/eip-2200)
        _status = _NOT_ENTERED;
    }

    /**
     * @dev Returns true if the reentrancy guard is currently set to "entered", which indicates there is a
     * `nonReentrant` function in the call stack.
     */
    function _reentrancyGuardEntered() internal view returns (bool) {
        return _status == _ENTERED;
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
// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.12;

library Flags {

  /* ========== FLAGS ========== */

  /// @dev Flag to unwrap ETH
  uint256 public constant UNWRAP_ETH = 0;
  /// @dev Flag to revert if external call fails
  uint256 public constant REVERT_IF_EXTERNAL_FAIL = 1;
  /// @dev Flag to call proxy with a sender contract
  uint256 public constant PROXY_WITH_SENDER = 2;
  /// @dev Data is hash in DeBridgeGate send method
  uint256 public constant SEND_HASHED_DATA = 3;
  /// @dev First 24 bytes from data is gas limit for external call
  uint256 public constant SEND_EXTERNAL_CALL_GAS_LIMIT = 4;
  /// @dev Support multi send for externall call
  uint256 public constant MULTI_SEND = 5;

  /// @dev Get flag
  /// @param _packedFlags Flags packed to uint256
  /// @param _flag Flag to check
  function getFlag(
    uint256 _packedFlags,
    uint256 _flag
  ) internal pure returns (bool) {
    uint256 flag = (_packedFlags >> _flag) & uint256(1);
    return flag == 1;
  }

  /// @dev Set flag
  /// @param _packedFlags Flags packed to uint256
  /// @param _flag Flag to set
  /// @param _value Is set or not set
  function setFlag(
    uint256 _packedFlags,
    uint256 _flag,
    bool _value
  ) internal pure returns (uint256) {
    if (_value)
      return _packedFlags | uint256(1) << _flag;
    else
      return _packedFlags & ~(uint256(1) << _flag);
  }
}
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.12;

interface ICallProxy {

  /// @dev Chain from which the current submission is received
  function submissionChainIdFrom() external returns (uint256);
  /// @dev Native sender of the current submission
  function submissionNativeSender() external returns (bytes memory);

  /// @dev Used for calls where native asset transfer is involved.
  /// @param _reserveAddress Receiver of the tokens if the call to _receiver fails
  /// @param _receiver Contract to be called
  /// @param _data Call data
  /// @param _flags Flags to change certain behavior of this function, see Flags library for more details
  /// @param _nativeSender Native sender
  /// @param _chainIdFrom Id of a chain that originated the request
  function call(
    address _reserveAddress,
    address _receiver,
    bytes memory _data,
    uint256 _flags,
    bytes memory _nativeSender,
    uint256 _chainIdFrom
  ) external payable returns (bool);

  /// @dev Used for calls where ERC20 transfer is involved.
  /// @param _token Asset address
  /// @param _reserveAddress Receiver of the tokens if the call to _receiver fails
  /// @param _receiver Contract to be called
  /// @param _data Call data
  /// @param _flags Flags to change certain behavior of this function, see Flags library for more details
  /// @param _nativeSender Native sender
  /// @param _chainIdFrom Id of a chain that originated the request
  function callERC20(
    address _token,
    address _reserveAddress,
    address _receiver,
    bytes memory _data,
    uint256 _flags,
    bytes memory _nativeSender,
    uint256 _chainIdFrom
  ) external returns (bool);
}
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.12;

interface IDeBridgeGate {
  /* ========== STRUCTS ========== */

  struct TokenInfo {
    uint256 nativeChainId;
    bytes nativeAddress;
  }

  struct DebridgeInfo {
    uint256 chainId; // native chain id
    uint256 maxAmount; // maximum amount to transfer
    uint256 balance; // total locked assets
    uint256 lockedInStrategies; // total locked assets in strategy (AAVE, Compound, etc)
    address tokenAddress; // asset address on the current chain
    uint16 minReservesBps; // minimal hot reserves in basis points (1/10000)
    bool exist;
  }

  struct DebridgeFeeInfo {
    uint256 collectedFees; // total collected fees
    uint256 withdrawnFees; // fees that already withdrawn
    mapping(uint256 => uint256) getChainFee; // whether the chain for the asset is supported
  }

  struct ChainSupportInfo {
    uint256 fixedNativeFee; // transfer fixed fee
    bool isSupported; // whether the chain for the asset is supported
    uint16 transferFeeBps; // transfer fee rate nominated in basis points (1/10000) of transferred amount
  }

  struct DiscountInfo {
    uint16 discountFixBps; // fix discount in BPS
    uint16 discountTransferBps; // transfer % discount in BPS
  }

  /// @param executionFee Fee paid to the transaction executor.
  /// @param fallbackAddress Receiver of the tokens if the call fails.
  struct SubmissionAutoParamsTo {
    uint256 executionFee;
    uint256 flags;
    bytes fallbackAddress;
    bytes data;
  }

  /// @param executionFee Fee paid to the transaction executor.
  /// @param fallbackAddress Receiver of the tokens if the call fails.
  struct SubmissionAutoParamsFrom {
    uint256 executionFee;
    uint256 flags;
    address fallbackAddress;
    bytes data;
    bytes nativeSender;
  }

  struct FeeParams {
    uint256 receivedAmount;
    uint256 fixFee;
    uint256 transferFee;
    bool useAssetFee;
    bool isNativeToken;
  }

  /* ========== PUBLIC VARS GETTERS ========== */

  /// @dev Returns whether the transfer with the submissionId was claimed.
  /// submissionId is generated in getSubmissionIdFrom
  function isSubmissionUsed(bytes32 submissionId) view external returns (bool);

  /// @dev Returns native token info by wrapped token address
  function getNativeInfo(address token) view external returns (
    uint256 nativeChainId,
    bytes memory nativeAddress);

  /// @dev Returns address of the proxy to execute user's calls.
  function callProxy() external view returns (address);

  /// @dev Fallback fixed fee in native asset, used if a chain fixed fee is set to 0
  function globalFixedNativeFee() external view returns (uint256);

  /// @dev Fallback transfer fee in BPS, used if a chain transfer fee is set to 0
  function globalTransferFeeBps() external view returns (uint16);

  /* ========== FUNCTIONS ========== */

  /// @dev Submits the message to the deBridge infrastructure to be broadcasted to another supported blockchain (identified by _dstChainId)
  ///      with the instructions to call the _targetContractAddress contract using the given _targetContractCalldata
  /// @notice NO ASSETS ARE BROADCASTED ALONG WITH THIS MESSAGE
  /// @notice DeBridgeGate only accepts submissions with msg.value (native ether) covering a small protocol fee
  ///         (defined in the globalFixedNativeFee property). Any excess amount of ether passed to this function is
  ///         included in the message as the execution fee - the amount deBridgeGate would give as an incentive to
  ///         a third party in return for successful claim transaction execution on the destination chain.
  /// @notice DeBridgeGate accepts a set of flags that control the behaviour of the execution. This simple method
  ///         sets the default set of flags: REVERT_IF_EXTERNAL_FAIL, PROXY_WITH_SENDER
  /// @param _dstChainId ID of the destination chain.
  /// @param _targetContractAddress A contract address to be called on the destination chain
  /// @param _targetContractCalldata Calldata to execute against the target contract on the destination chain
  function sendMessage(
    uint256 _dstChainId,
    bytes memory _targetContractAddress,
    bytes memory _targetContractCalldata
  ) external payable returns (bytes32 submissionId);

  /// @dev Submits the message to the deBridge infrastructure to be broadcasted to another supported blockchain (identified by _dstChainId)
  ///      with the instructions to call the _targetContractAddress contract using the given _targetContractCalldata
  /// @notice NO ASSETS ARE BROADCASTED ALONG WITH THIS MESSAGE
  /// @notice DeBridgeGate only accepts submissions with msg.value (native ether) covering a small protocol fee
  ///         (defined in the globalFixedNativeFee property). Any excess amount of ether passed to this function is
  ///         included in the message as the execution fee - the amount deBridgeGate would give as an incentive to
  ///         a third party in return for successful claim transaction execution on the destination chain.
  /// @notice DeBridgeGate accepts a set of flags that control the behaviour of the execution. This simple method
  ///         sets the default set of flags: REVERT_IF_EXTERNAL_FAIL, PROXY_WITH_SENDER
  /// @param _dstChainId ID of the destination chain.
  /// @param _targetContractAddress A contract address to be called on the destination chain
  /// @param _targetContractCalldata Calldata to execute against the target contract on the destination chain
  /// @param _flags A bitmask of toggles listed in the Flags library
  /// @param _referralCode Referral code to identify this submission
  function sendMessage(
    uint256 _dstChainId,
    bytes memory _targetContractAddress,
    bytes memory _targetContractCalldata,
    uint256 _flags,
    uint32 _referralCode
  ) external payable returns (bytes32 submissionId);

  /// @dev This method is used for the transfer of assets [from the native chain](https://docs.debridge.finance/the-core-protocol/transfers#transfer-from-native-chain).
  /// It locks an asset in the smart contract in the native chain and enables minting of deAsset on the secondary chain.
  /// @param _tokenAddress Asset identifier.
  /// @param _amount Amount to be transferred (note: the fee can be applied).
  /// @param _chainIdTo Chain id of the target chain.
  /// @param _receiver Receiver address.
  /// @param _permitEnvelope Permit for approving the spender by signature. bytes (amount + deadline + signature)
  /// @param _useAssetFee use assets fee for pay protocol fix (work only for specials token)
  /// @param _referralCode Referral code
  /// @param _autoParams Auto params for external call in target network
  function send(
    address _tokenAddress,
    uint256 _amount,
    uint256 _chainIdTo,
    bytes memory _receiver,
    bytes memory _permitEnvelope,
    bool _useAssetFee,
    uint32 _referralCode,
    bytes calldata _autoParams
  ) external payable returns (bytes32 submissionId) ;

  /// @dev Is used for transfers [into the native chain](https://docs.debridge.finance/the-core-protocol/transfers#transfer-from-secondary-chain-to-native-chain)
  /// to unlock the designated amount of asset from collateral and transfer it to the receiver.
  /// @param _debridgeId Asset identifier.
  /// @param _amount Amount of the transferred asset (note: the fee can be applied).
  /// @param _chainIdFrom Chain where submission was sent
  /// @param _receiver Receiver address.
  /// @param _nonce Submission id.
  /// @param _signatures Validators signatures to confirm
  /// @param _autoParams Auto params for external call
  function claim(
    bytes32 _debridgeId,
    uint256 _amount,
    uint256 _chainIdFrom,
    address _receiver,
    uint256 _nonce,
    bytes calldata _signatures,
    bytes calldata _autoParams
  ) external;

  /// @dev Withdraw collected fees to feeProxy
  /// @param _debridgeId Asset identifier.
  function withdrawFee(bytes32 _debridgeId) external;

  /// @dev Returns asset fixed fee value for specified debridge and chainId.
  /// @param _debridgeId Asset identifier.
  /// @param _chainId Chain id.
  function getDebridgeChainAssetFixedFee(
    bytes32 _debridgeId,
    uint256 _chainId
  ) external view returns (uint256);

  /* ========== EVENTS ========== */

  /// @dev Emitted once the tokens are sent from the original(native) chain to the other chain; the transfer tokens
  /// are expected to be claimed by the users.
  event Sent(
    bytes32 submissionId,
    bytes32 indexed debridgeId,
    uint256 amount,
    bytes receiver,
    uint256 nonce,
    uint256 indexed chainIdTo,
    uint32 referralCode,
    FeeParams feeParams,
    bytes autoParams,
    address nativeSender
  // bool isNativeToken //added to feeParams
  );

  /// @dev Emitted once the tokens are transferred and withdrawn on a target chain
  event Claimed(
    bytes32 submissionId,
    bytes32 indexed debridgeId,
    uint256 amount,
    address indexed receiver,
    uint256 nonce,
    uint256 indexed chainIdFrom,
    bytes autoParams,
    bool isNativeToken
  );

  /// @dev Emitted when new asset support is added.
  event PairAdded(
    bytes32 debridgeId,
    address tokenAddress,
    bytes nativeAddress,
    uint256 indexed nativeChainId,
    uint256 maxAmount,
    uint16 minReservesBps
  );

  event MonitoringSendEvent(
    bytes32 submissionId,
    uint256 nonce,
    uint256 lockedOrMintedAmount,
    uint256 totalSupply
  );

  event MonitoringClaimEvent(
    bytes32 submissionId,
    uint256 lockedOrMintedAmount,
    uint256 totalSupply
  );

  /// @dev Emitted when the asset is allowed/disallowed to be transferred to the chain.
  event ChainSupportUpdated(uint256 chainId, bool isSupported, bool isChainFrom);
  /// @dev Emitted when the supported chains are updated.
  event ChainsSupportUpdated(
    uint256 chainIds,
    ChainSupportInfo chainSupportInfo,
    bool isChainFrom);

  /// @dev Emitted when the new call proxy is set.
  event CallProxyUpdated(address callProxy);
  /// @dev Emitted when the transfer request is executed.
  event AutoRequestExecuted(
    bytes32 submissionId,
    bool indexed success,
    address callProxy
  );

  /// @dev Emitted when a submission is blocked.
  event Blocked(bytes32 submissionId);
  /// @dev Emitted when a submission is unblocked.
  event Unblocked(bytes32 submissionId);

  /// @dev Emitted when fee is withdrawn.
  event WithdrawnFee(bytes32 debridgeId, uint256 fee);

  /// @dev Emitted when globalFixedNativeFee and globalTransferFeeBps are updated.
  event FixedNativeFeeUpdated(
    uint256 globalFixedNativeFee,
    uint256 globalTransferFeeBps);

  /// @dev Emitted when globalFixedNativeFee is updated by feeContractUpdater
  event FixedNativeFeeAutoUpdated(uint256 globalFixedNativeFee);
}
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.12;

interface ITokenController {
  /**
   * @dev Reverts when the caller is not a bridge.
   */
  error CallerIsNotABridge();

  /**
   * @dev Reverts when the address is zero.
   */
  error ZeroAddressError();

  /**
   * @dev Release tokens to the recipient.
   * @param recipient Address of the recipient.
   * @param amount Amount of tokens to release.
   */
  function releaseTokens(address recipient, uint256 amount) external;

  /**
   * @dev Reserve tokens from the sender.
   * @param sender Address of the sender.
   * @param amount Amount of tokens to reserve.
   */
  function reserveTokens(address sender, uint256 amount) external;

  /**
   * @dev Set the bridge contract address.
   * @param _bridgeContract Address of the bridge contract.
   */
  function setBridgeContract(address _bridgeContract) external;
}
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "@openzeppelin/contracts/access/Ownable.sol";
import "./interfaces/IDeBridgeGate.sol";
import "./interfaces/Flags.sol";
import "./interfaces/ICallProxy.sol";
import "./interfaces/ITokenController.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";

contract PrqBridge is Ownable, ReentrancyGuard {
  /**
   * @notice Reverts when chain contract address is not specified
   */
  error ChainContractAddressNotSpecified();

  /**
   * @notice Reverts when chain id does not match
   * @param expected Expected chain id
   * @param actual Actual chain id
   */
  error ChainMismatch(uint256 expected, uint256 actual);

  /**
   * @notice Reverts when cross-chain caller is not a proxy
   * @param proxyAddress Proxy address
   * @param callerAddress Caller address
   */
  error OnlyProxyCanBeACaller(address proxyAddress, address callerAddress);

  /**
   * @notice Reverts when sender is not the expected one
   */
  error WrongSender();

  /**
   * @notice Reverts when fees are not covered
   * @param required Required amount
   * @param provided Provided amount
   */
  error FeesAreNotCovered(uint256 required, uint256 provided);

  IDeBridgeGate public deBridgeGate;
  uint256 public immutable currentChainId;

  mapping(uint256 => address) public counterChainContract;

  ITokenController public tokenController;

  modifier checkChainContract(uint256 _chainId) {
    if (counterChainContract[_chainId] == address(0)) {
      revert ChainContractAddressNotSpecified();
    }
    _;
  }

  constructor(IDeBridgeGate _deBridgeGate, ITokenController _tokenController) Ownable() {
    deBridgeGate = _deBridgeGate;
    tokenController = _tokenController;
    currentChainId = block.chainid;
  }

  /**
   * @dev Send tokens to another chain
   * @param _toChainID Chain id of the destination chain
   * @param _amount Amount of tokens to send
   * @param _recipient Address of the recipient on the destination chain
   */
  function sendToChain(uint256 _toChainID, uint256 _amount, address _recipient) external payable nonReentrant checkChainContract(_toChainID) {
    tokenController.reserveTokens(_msgSender(), _amount);

    bytes memory dstTxCall = _encodeUnlockCommand(_amount, _recipient);
    _send(dstTxCall, _toChainID, 0);
  }

  /**
   * @dev Unlock tokens from another chain
   * @param _fromChainID Chain id of the source chain
   * @param _amount Amount of tokens to unlock
   * @param _recipient Address of the recipient on the destination chain
   */
  function unlock(uint256 _fromChainID, uint256 _amount, address _recipient) external checkChainContract(_fromChainID) {
    _onlyCrossChain(_fromChainID);

    tokenController.releaseTokens(_recipient, _amount);
  }

  /**
   * @dev Validates that the call is coming from the CallProxy contract
   * @param _fromChainID Chain id of the source chain
   */
  function _onlyCrossChain(uint256 _fromChainID) internal {
    ICallProxy callProxy = ICallProxy(deBridgeGate.callProxy());

    // caller is CallProxy?
    if (address(callProxy) != _msgSender()) {
      revert OnlyProxyCanBeACaller(address(callProxy), _msgSender());
    }

    if (callProxy.submissionChainIdFrom() != _fromChainID) {
      revert ChainMismatch(callProxy.submissionChainIdFrom(), _fromChainID);
    }

    bytes memory nativeSender = callProxy.submissionNativeSender();

    if (keccak256(abi.encodePacked(counterChainContract[_fromChainID])) != keccak256(nativeSender)) {
      revert WrongSender();
    }
  }

  /**
   * @dev Encodes the unlock command to be sent to the destination chain
   * @param _amount Amount of tokens to unlock
   * @param _recipient Address of the recipient on the destination chain
   */
  function _encodeUnlockCommand(uint256 _amount, address _recipient) view internal returns (bytes memory) {
    return
      abi.encodeWithSelector(
      this.unlock.selector,
      currentChainId,
      _amount,
      _recipient
    );
  }

  /**
   * @dev Sends a transaction to the destination chain
   * @param _dstTransactionCall Destination transaction call
   * @param _toChainId Chain id of the destination chain
   * @param _executionFee Execution fee to be paid to the executor
   */
  function _send(bytes memory _dstTransactionCall, uint256 _toChainId, uint256 _executionFee) internal {
    //
    // sanity checks
    //
    uint256 protocolFee = deBridgeGate.globalFixedNativeFee();
    uint256 totalFee = protocolFee + _executionFee;

    if (msg.value < totalFee) {
      revert FeesAreNotCovered(msg.value, totalFee);
    }

    // we bridge as much asset as specified in the _executionFee arg
    // (i.e. bridging the minimum necessary amount to to cover the cost of execution)
    // However, deBridge cuts a small fee off the bridged asset, so
    // we must ensure that executionFee < amountToBridge
    uint assetFeeBps = deBridgeGate.globalTransferFeeBps();
    uint amountToBridge = _executionFee;
    uint amountAfterBridge = amountToBridge * (10000 - assetFeeBps) / 10000;

    //
    // start configuring a message
    //
    IDeBridgeGate.SubmissionAutoParamsTo memory autoParams;

    // use the whole amountAfterBridge as the execution fee to be paid to the executor
    autoParams.executionFee = amountAfterBridge;

    // Exposing nativeSender must be requested explicitly
    // We request it bc of CrossChainCounter's onlyCrossChainIncrementor modifier
    autoParams.flags = Flags.setFlag(
      autoParams.flags,
      Flags.PROXY_WITH_SENDER,
      true
    );

    // if something happens, we need to revert the transaction, otherwise the sender will loose assets
    autoParams.flags = Flags.setFlag(
      autoParams.flags,
      Flags.REVERT_IF_EXTERNAL_FAIL,
      true
    );

    autoParams.data = _dstTransactionCall;
    autoParams.fallbackAddress = abi.encodePacked(_msgSender());

    deBridgeGate.send{value: msg.value}(
      address(0), // _tokenAddress
      amountToBridge, // _amount
      _toChainId, // _chainIdTo
      abi.encodePacked(counterChainContract[_toChainId]), // _receiver
      "", // _permit
      true, // _useAssetFee
      0, // _referralCode
      abi.encode(autoParams) // _autoParams
    );
  }

  /**
   * @dev Sets the DeBridgeGate contract address
   * @param _deBridgeGate DeBridgeGate contract address
   */
  function setDeBridgeGate(IDeBridgeGate _deBridgeGate) external onlyOwner {
    deBridgeGate = _deBridgeGate;
  }

  /**
   * @dev Sets the TokenController contract address
   * @param _tokenController TokenController contract address
   */
  function setTokenController(ITokenController _tokenController) external onlyOwner {
    tokenController = _tokenController;
  }

  /**
   * @dev Sets the contract address for a specific chain
   * @param _chainId Chain id
   * @param _contract Contract address
   */
  function setCounterChainContract(uint256 _chainId, address _contract) external onlyOwner {
    counterChainContract[_chainId] = _contract;
  }
}
