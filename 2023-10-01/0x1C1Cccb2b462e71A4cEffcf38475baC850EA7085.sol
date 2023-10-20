// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import {CCIPReceiver} from "@chainlink/contracts-ccip/src/v0.8/ccip/applications/CCIPReceiver.sol";
import {Client} from "@chainlink/contracts-ccip/src/v0.8/ccip/libraries/Client.sol";
import {IRouterClient} from "@chainlink/contracts-ccip/src/v0.8/ccip/interfaces/IRouterClient.sol";
import {IERC721} from "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import {Pausable} from "@openzeppelin/contracts/security/Pausable.sol";
import {ReentrancyGuard} from "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import {Address} from "@openzeppelin/contracts/utils/Address.sol";

import {KreepyKrittersPortalTypes} from "./KreepyKrittersPortalTypes.sol";
import {KreepyKrittersPortalEncoder} from "./KreepyKrittersPortalEncoder.sol";
import {CCIPApprovedSource, ConfirmedOwner} from "./CCIPApprovedSource.sol";
import {BytesLib} from "./BytesLib.sol";
import {IOnTokenBurnedListener} from "./IOnTokenBurnedListener.sol";
import {IBurnable} from "./IBurnable.sol";
import {IMaxSupply} from "./IMaxSupply.sol";
import {IERC20, Recoverable} from "./Recoverable.sol";

/**
 * @title KreepyKritters Portal (https://kreepykritters.io/)
 *
 * @notice CCIP cross chain bridge to transfer KreepyKritters NFTs between different chains.
 * When transfering NFTs, the NFTs are locked on the source chain in this contract
 * and unlocked on the destination chain.
 *
 * @dev When deploying on a new chain, the entire non-burned
 * supply of the collection has to be minted into this conract.
 * This contract supports synchronization of burns on different chains, by either manually calling
 * {notifyBurn} or automatically on each burn in case the NFT contract on the chain has a
 * {IOnTokenBurnedListener} interface.
 * This contract is gas optimized for uint16 tokenIds and requires tokenIds to start at 1.
 * This contract has emergency recover methods callable by the owner. These methods are
 * meant to be used in case of a critical bug which requires migration to a new Portal contract.
 * Due to the nature of these methods, it is strongly recommended to transfer the ownership to
 * a multisig wallet after the initial setup is completed.
 */
contract KreepyKrittersPortal is
    CCIPReceiver,
    CCIPApprovedSource,
    IOnTokenBurnedListener,
    Pausable,
    ReentrancyGuard,
    Recoverable,
    KreepyKrittersPortalEncoder,
    KreepyKrittersPortalTypes
{
    using BytesLib for bytes;

    address public immutable token;
    address private immutable link;
    uint256 private immutable maxSupply;
    bool private immutable transferToDeadAsBurn;

    mapping(uint64 chainSelector => address portals) public crossChainTarget;
    mapping(uint64 chainSelector => bool) public transferEnabled;
    mapping(address => bool) public burnOperators;
    bytes public burnListenerExtraArgs;
    uint64 public burnListenerDestinationChainSelector;
    uint256 public fundEthOnReceiverForFreshWallet;
    uint64 private processingMessageFrom;
    bytes32 private processingMessageId;

    modifier onlyBurnOperator() {
        if (!burnOperators[msg.sender]) revert OnlyBurnOperator();
        _;
    }

    modifier processingMessage(uint64 chainSelector, bytes32 messageId) {
        processingMessageFrom = chainSelector;
        processingMessageId = messageId;
        _;
        processingMessageFrom = 0;
        processingMessageId = 0;
    }

    /**
     * @dev Create a new KreepyKritters Portal for this chain.
     * The same contract can be used on source and all destination chains.
     * In case this is not the source chain, this contract expects the entire non-burned supply
     * of the collection to be minted into this contract.
     * This contract is gas optimized for uint16 tokenIds and requires tokenIds to start at 1.
     * @param _router CCIP router
     * @param _link LINK token address
     * @param _token NFT token this contract is transfering cross chain
     * @param _transferToDeadAsBurn Whether 'burn' on this chain means that the NFT is sent to 0xdead
     */
    constructor(
        address _router,
        address _link,
        address _token,
        bool _transferToDeadAsBurn,
        address _owner
    ) CCIPReceiver(_router) ConfirmedOwner(_owner) {
        token = _token;
        link = _link;
        maxSupply = IMaxSupply(_token).maxSupply();
        transferToDeadAsBurn = _transferToDeadAsBurn;
        IERC20(_link).approve(_router, type(uint256).max);

        if (maxSupply >= type(uint16).max) revert MaxSupplyTooHigh(maxSupply);
    }

    /**
     * @dev Allows receiving native tokens for use in funding fresh wallets.
     * See {setFundEthOnReceiverForFreshWallet}.
     */
    receive() external payable {}

    /* -----------------------*/
    /* --- User interface --- */
    /* -----------------------*/

    /**
     * @notice Transfer NFTs to `destinationChainSelector`.
     * Payment for CCIP service is payed in native tokens, use {getTransferFee} to calculate fees.
     * Users need to set NFT approval for this contract once via {ERC721-setApprovalForAll}.
     * @dev NFTs are locked in this contract on the source chain and unlocked on the destination chain.
     * @param destinationChainSelector CCIP chain selector for destination chain.
     * @param data Encoded transfer data of sender, recipient and tokenIds, can be obtained via {KreepyKrittersPortalEncoder-encodeTransfer}.
     * @param extraArgs CCIP extraArgs, encoding gasLimit on destination chain and possibly future protocol options.
     */
    function transfer(
        uint64 destinationChainSelector,
        bytes memory data,
        bytes calldata extraArgs
    ) external payable whenNotPaused nonReentrant {
        address target = crossChainTarget[destinationChainSelector];
        if (target == address(0))
            revert InvalidDestinationChainSelector(destinationChainSelector);

        if (!transferEnabled[destinationChainSelector])
            revert TransferNotEnabled(destinationChainSelector);

        uint256 command = data.readUInt8(OFFSET_COMMAND);
        if (command != COMMAND_UNLOCK)
            revert InvalidCommandEncoding(command, COMMAND_UNLOCK);

        address sender = data.readAddress(OFFSET_SENDER);
        if (sender != msg.sender)
            revert InvalidSenderEncoding(sender, msg.sender);

        address recipient = data.readAddress(OFFSET_UNLOCK_RECIPIENT);

        {
            uint256 length = (data.length - OFFSET_UNLOCK_TOKENIDS) /
                SIZE_TOKENID;
            uint256 tokenId;
            for (uint256 i = 0; i < length; ) {
                unchecked {
                    tokenId = data.readUInt16(
                        OFFSET_UNLOCK_TOKENIDS + i * SIZE_TOKENID
                    );
                }
                IERC721(token).transferFrom(msg.sender, address(this), tokenId);
                unchecked {
                    ++i;
                }
            }
        }

        Client.EVM2AnyMessage memory message = Client.EVM2AnyMessage({
            receiver: abi.encode(target),
            data: data,
            tokenAmounts: new Client.EVMTokenAmount[](0),
            extraArgs: extraArgs,
            feeToken: address(0)
        });
        uint256 fee = IRouterClient(i_router).getFee(
            destinationChainSelector,
            message
        );

        if (fee > msg.value) revert InsufficientFees();

        bytes32 messageId = IRouterClient(i_router).ccipSend{value: fee}(
            destinationChainSelector,
            message
        );

        emit TransferInitiated(
            msg.sender,
            recipient,
            destinationChainSelector,
            messageId
        );

        if (msg.value > fee) {
            Address.sendValue(payable(msg.sender), msg.value - fee);
        }
    }

    /**
     * @notice Calculate CCIP fees charged by {transfer} for the given parameters.
     * @param destinationChainSelector CCIP chain selector for destination chain.
     * @param data Encoded transfer data of sender, recipient and tokenIds, can be obtained via {KreepyKrittersPortalEncoder-encodeTransfer}.
     * @param extraArgs CCIP extraArgs, encoding gasLimit on destination chain and possibly future protocol options.
     * @return fee in native gas token
     */
    function getTransferFee(
        uint64 destinationChainSelector,
        bytes memory data,
        bytes calldata extraArgs
    ) external view returns (uint256 fee) {
        address target = crossChainTarget[destinationChainSelector];
        if (target == address(0))
            revert InvalidDestinationChainSelector(destinationChainSelector);

        if (!transferEnabled[destinationChainSelector])
            revert TransferNotEnabled(destinationChainSelector);

        uint256 command = data.readUInt8(OFFSET_COMMAND);
        if (command != COMMAND_UNLOCK)
            revert InvalidCommandEncoding(command, COMMAND_UNLOCK);

        Client.EVM2AnyMessage memory message = Client.EVM2AnyMessage({
            receiver: abi.encode(target),
            data: data,
            tokenAmounts: new Client.EVMTokenAmount[](0),
            extraArgs: extraArgs,
            feeToken: address(0)
        });
        fee = IRouterClient(i_router).getFee(destinationChainSelector, message);
    }

    /* ------------------------*/
    /* --- Admin interface --- */
    /* ------------------------*/

    /**
     * @notice Transfer a users NFTs to `destinationChainSelector`.
     * Payment for CCIP service is payed in link stored in this contract.
     * The user needs to have set NFT approval for this contract via {ERC721-setApprovalForAll}.
     * Only callable by owner.
     * @dev NFTs are locked in this contract on the source chain and unlocked on the destination chain.
     * @param destinationChainSelector CCIP chain selector for destination chain.
     * @param data Encoded transfer data of sender, recipient and tokenIds, can be obtained via {KreepyKrittersPortalEncoder-encodeTransfer}.
     * @param extraArgs CCIP extraArgs, encoding gasLimit on destination chain and possibly future protocol options.
     */
    function transferFor(
        uint64 destinationChainSelector,
        bytes memory data,
        bytes calldata extraArgs
    ) external onlyOwner whenNotPaused nonReentrant {
        address target = crossChainTarget[destinationChainSelector];
        if (target == address(0)) {
            revert InvalidDestinationChainSelector(destinationChainSelector);
        }
        if (!transferEnabled[destinationChainSelector]) {
            revert TransferNotEnabled(destinationChainSelector);
        }

        uint256 command = data.readUInt8(OFFSET_COMMAND);
        if (command != COMMAND_UNLOCK)
            revert InvalidCommandEncoding(command, COMMAND_UNLOCK);

        address sender = data.readAddress(OFFSET_SENDER);
        if (sender != msg.sender)
            revert InvalidSenderEncoding(sender, msg.sender);

        address owner = data.readAddress(OFFSET_UNLOCK_RECIPIENT);

        uint256 length = (data.length - OFFSET_UNLOCK_TOKENIDS) / SIZE_TOKENID;
        uint256 tokenId;
        for (uint256 i = 0; i < length; ) {
            unchecked {
                tokenId = data.readUInt16(
                    OFFSET_UNLOCK_TOKENIDS + i * SIZE_TOKENID
                );
            }
            IERC721(token).transferFrom(owner, address(this), tokenId);
            unchecked {
                ++i;
            }
        }

        Client.EVM2AnyMessage memory message = Client.EVM2AnyMessage({
            receiver: abi.encode(target),
            data: data,
            tokenAmounts: new Client.EVMTokenAmount[](0),
            extraArgs: extraArgs,
            feeToken: link
        });

        bytes32 messageId = IRouterClient(i_router).ccipSend(
            destinationChainSelector,
            message
        );

        emit TransferInitiated(
            msg.sender,
            owner,
            destinationChainSelector,
            messageId
        );
    }

    /**
     * @notice Configure the target CCIP message receiver on the given destination chain.
     * Only callable by owner.
     * @param chainSelector CCIP chain selector of destination chain to configure.
     * @param target Contract address to send messages to when targeting destination chain.
     */
    function setCrossChainTarget(
        uint64 chainSelector,
        address target
    ) external onlyOwner {
        crossChainTarget[chainSelector] = target;
        emit CrossChainTagetChanged(chainSelector, target);
    }

    /**
     * @notice Enable/Disable transfers from this contract to destination chain given by `chainSelector`.
     * Only callable by owner.
     * @param chainSelector CCIP chain selector of destination chain to configure.
     * @param enabled the new state for the given destination chain.
     */
    function setTransferEnabled(
        uint64 chainSelector,
        bool enabled
    ) external onlyOwner {
        transferEnabled[chainSelector] = enabled;
        emit TransferEnabledChanged(chainSelector, enabled);
    }

    /**
     * @notice Configure `operator`'s `isBurnOperator` state.
     * Only callable by owner.
     * @dev BurnOperators can call notifyBurn, which spends this contracts link balance.
     * @param operator wallet to set isBurnOperator state.
     * @param isBurnOperator new isBurnOperator state.
     */
    function setBurnOperator(
        address operator,
        bool isBurnOperator
    ) external onlyOwner {
        burnOperators[operator] = isBurnOperator;
        emit BurnOperatorChanged(operator, isBurnOperator);
    }

    /**
     * @notice Configure parameters for the autoburn listener.
     * Only callable by owner.
     * @param _burnListenerDestinationChainSelector chain selector of chain to notify in case of observed burn event.
     * @param _burnListenerExtraArgs CCIP extraArgs used to send the burn notification.
     */
    function setBurnListenerNotifier(
        uint64 _burnListenerDestinationChainSelector,
        bytes calldata _burnListenerExtraArgs
    ) external onlyOwner {
        burnListenerDestinationChainSelector = _burnListenerDestinationChainSelector;
        burnListenerExtraArgs = _burnListenerExtraArgs;
        emit BurnListenerNotifierChanged(
            _burnListenerDestinationChainSelector,
            _burnListenerExtraArgs
        );
    }

    /**
     * @notice Configure amount of native gas tokens which will be sent to recipients of
     * NFT transfers in case the recipient wallet does not have any gas.
     * Only callable by owner.
     * @param _fundEthOnReceiverForFreshWallet amount of native gas tokens in wei.
     */
    function setFundEthOnReceiverForFreshWallet(
        uint256 _fundEthOnReceiverForFreshWallet
    ) external onlyOwner {
        fundEthOnReceiverForFreshWallet = _fundEthOnReceiverForFreshWallet;
        emit FundEthOnReceiverForFreshWalletChanged(
            _fundEthOnReceiverForFreshWallet
        );
    }

    /**
     * @notice Pause all functionality of this contract.
     * Only callable by owner.
     */
    function pause() external onlyOwner whenNotPaused {
        _pause();
    }

    /**
     * @notice Resume all functionality of this contract.
     * Only callable by owner.
     */
    function unpause() external onlyOwner whenPaused {
        _unpause();
    }

    /* --------------------------------*/
    /* --- Burn operator interface --- */
    /* --------------------------------*/

    /**
     * @notice Notify cross chain portal instance on `destinationChainSelector` that tokens were burned on this chain.
     * Payment for CCIP service is payed in link stored in this contract.
     * Only callable by BurnOperators.
     * @dev After validation that the given tokenIds are burned on this chain, they will be burned on the destination chain too.
     * @param destinationChainSelector CCIP chain selector for destination chain.
     * @param data Encoded brun data of sender and tokenIds, can be obtained via {KreepyKrittersPortalEncoder-encodeBurn}.
     * @param extraArgs CCIP extraArgs, encoding gasLimit on destination chain and possibly future protocol options.
     */
    function notifyBurned(
        uint64 destinationChainSelector,
        bytes memory data,
        bytes calldata extraArgs
    ) external onlyBurnOperator whenNotPaused {
        address target = crossChainTarget[destinationChainSelector];
        if (target == address(0)) {
            revert InvalidDestinationChainSelector(destinationChainSelector);
        }

        uint256 command = data.readUInt8(OFFSET_COMMAND);
        if (command != COMMAND_BURN)
            revert InvalidCommandEncoding(command, COMMAND_BURN);

        address sender = data.readAddress(OFFSET_SENDER);
        if (sender != msg.sender)
            revert InvalidSenderEncoding(sender, msg.sender);

        uint256 length = (data.length - OFFSET_BURN_TOKENIDS) / SIZE_TOKENID;
        uint256 tokenId;
        for (uint256 i = 0; i < length; ) {
            unchecked {
                tokenId = data.readUInt16(
                    OFFSET_BURN_TOKENIDS + i * SIZE_TOKENID
                );
            }
            if (!_isBurned(tokenId)) revert NotBurned(tokenId);
            unchecked {
                ++i;
            }
        }

        _notifyBurned(destinationChainSelector, target, data, extraArgs);
    }

    /* ----------------------------------*/
    /* --- IOnBurnListener interface --- */
    /* ----------------------------------*/

    function onTokenBurned(uint256 tokenId) external override {
        if (msg.sender != token) revert InvalidListenerCaller(msg.sender);

        uint64 _burnListenerDestinationChainSelector = burnListenerDestinationChainSelector;
        uint64 _processingMessageFrom = processingMessageFrom;
        if (
            _burnListenerDestinationChainSelector == 0 ||
            _processingMessageFrom == _burnListenerDestinationChainSelector
        ) return;
        address _target = crossChainTarget[
            _burnListenerDestinationChainSelector
        ];
        if (_target == address(0)) return;

        bytes memory data = new bytes(OFFSET_BURN_TOKENIDS + SIZE_TOKENID);
        data.writeUInt8(OFFSET_COMMAND, COMMAND_BURN);
        data.writeAddress(OFFSET_SENDER, msg.sender);
        data.writeUInt16(OFFSET_BURN_TOKENIDS, tokenId);

        _notifyBurned(
            _burnListenerDestinationChainSelector,
            _target,
            data,
            burnListenerExtraArgs
        );
    }

    /* -----------------------*/
    /* --- CCIP interface --- */
    /* -----------------------*/

    function _ccipReceive(
        Client.Any2EVMMessage memory message
    )
        internal
        override
        onlyApprovedSource(message.sourceChainSelector, message.sender)
        processingMessage(message.sourceChainSelector, message.messageId)
        nonReentrant
        whenNotPaused
    {
        uint256 command = message.data.readUInt8(0);
        if (command == COMMAND_UNLOCK) {
            _processUnlockMessage(message.data);
        } else if (command == COMMAND_BURN) {
            _processBurnMessage(message.data);
        } else {
            revert UnknownCommand(command);
        }
    }

    /* ---------------------------*/
    /* --- Internal interface --- */
    /* ---------------------------*/

    /**
     * @dev Fund fresh wallets with gas tokens when configured to do so via
     * {setFundEthOnReceiverForFreshWallet}.
     */
    function _fundFreshWallet(address recipient) internal {
        uint256 _fundEthOnReceiverForFreshWallet = fundEthOnReceiverForFreshWallet;
        if (
            _fundEthOnReceiverForFreshWallet > 0 &&
            address(this).balance >= _fundEthOnReceiverForFreshWallet &&
            recipient.balance == 0
        ) {
            Address.sendValue(
                payable(recipient),
                _fundEthOnReceiverForFreshWallet
            );
        }
    }

    /**
     * @dev Burn `tokenId` from managed NFT.
     * Depending on {transferToDeadAsBurn} set in constructor, this will transfer to 0xdead
     * or call the burn method on the NFT contract.
     */
    function _burn(uint256 tokenId) internal {
        if (_isBurned(tokenId)) return;
        if (transferToDeadAsBurn) {
            IERC721(token).transferFrom(
                address(this),
                address(0xdead),
                tokenId
            );
        } else {
            IBurnable(token).burn(tokenId);
        }
    }

    /**
     * @dev Send a notification to destination chain that some tokens were burned on this chain.
     * @param destinationChainSelector destination chain CCIP selector.
     * @param messageReceiver contract on destination chain to handle the message.
     * @param data encoded burn data from {KreepyKrittersPortalEncoder-encodeBurn}.
     * @param extraArgs encoded CCIP extraArgs with gasLimit, strict mode and possibly future protocol options.
     */
    function _notifyBurned(
        uint64 destinationChainSelector,
        address messageReceiver,
        bytes memory data,
        bytes memory extraArgs
    ) internal {
        Client.EVM2AnyMessage memory message = Client.EVM2AnyMessage({
            receiver: abi.encode(messageReceiver),
            data: data,
            tokenAmounts: new Client.EVMTokenAmount[](0),
            extraArgs: extraArgs,
            feeToken: link
        });

        bytes32 messageId = IRouterClient(i_router).ccipSend(
            destinationChainSelector,
            message
        );

        emit BurnInitiated(msg.sender, destinationChainSelector, messageId);
    }

    /**
     * @dev Process the transfer message which was received over CCIP from a different source chain.
     * Transfers tokens from this contract to the recipient specified in the message.
     * Optionally funds fresh wallets with gas tokens when configured ({setFundEthOnReceiverForFreshWallet}).
     * @param data encoded burn data ({KreepyKrittersPortalEncoder-encodeTransfer} / {KreepyKrittersPortalEncoder-decodeTransfer})
     */
    function _processUnlockMessage(bytes memory data) internal {
        uint256 length = (data.length - OFFSET_UNLOCK_TOKENIDS) / SIZE_TOKENID;

        address sender = data.readAddress(OFFSET_SENDER);
        address recipient = data.readAddress(OFFSET_UNLOCK_RECIPIENT);
        uint256 tokenId;

        for (uint256 i = 0; i < length; ) {
            unchecked {
                tokenId = data.readUInt16(
                    OFFSET_UNLOCK_TOKENIDS + i * SIZE_TOKENID
                );
            }
            IERC721(token).safeTransferFrom(address(this), recipient, tokenId);
            unchecked {
                ++i;
            }
        }

        _fundFreshWallet(recipient);

        emit TransferProcessed(
            sender,
            recipient,
            processingMessageFrom,
            processingMessageId
        );
    }

    /**
     * @dev Process the burn message which was received over CCIP from a different source chain.
     * @param data encoded burn data ({KreepyKrittersPortalEncoder-encodeBurn} / {KreepyKrittersPortalEncoder-decodeBurn})
     */
    function _processBurnMessage(bytes memory data) internal {
        uint256 length = (data.length - OFFSET_BURN_TOKENIDS) / SIZE_TOKENID;
        address sender = data.readAddress(OFFSET_SENDER);
        uint256 tokenId;

        for (uint256 i = 0; i < length; ) {
            unchecked {
                tokenId = data.readUInt16(
                    OFFSET_BURN_TOKENIDS + i * SIZE_TOKENID
                );
            }
            _burn(tokenId);
            unchecked {
                ++i;
            }
        }

        emit BurnProcessed(sender, processingMessageFrom, processingMessageId);
    }

    /**
     * @dev Verify that a tokenId is burned on this chain.
     * This is true when it does not exist and ownerOf(tokenId) fails, or when its owned by 0xdead.
     * @param tokenId tokenId to check
     */
    function _isBurned(uint256 tokenId) internal view returns (bool) {
        if (tokenId == 0 || tokenId > maxSupply) revert InvalidTokenId(tokenId);
        (bool success, bytes memory data) = token.staticcall(
            abi.encodeWithSignature("ownerOf(uint256)", [tokenId])
        );
        return !success || abi.decode(data, (address)) == address(0xdead);
    }
}
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/**
 * @title Error and typedefinitions of KreepyKrittersPortal 
 */
interface KreepyKrittersPortalTypes {
    error InvalidListenerCaller(address caller);
    error InvalidDestinationChainSelector(uint64 chainSelector);
    error InvalidTokenId(uint256 tokenId);
    error NotBurned(uint256 tokenId);
    error OnlySelf();
    error OnlyExternal();
    error OnlyBurnOperator();
    error InsufficientFees();
    error TransferNotEnabled(uint64 chainSelector);
    error InvalidCommandEncoding(uint256 command, uint256 expected);
    error InvalidSenderEncoding(address sender, address expetced);
    error UnknownCommand(uint256 command);
    error MaxSupplyTooHigh(uint256 maxSupply);

    event CrossChainTagetChanged(uint64 chainSelector, address target);
    event TransferEnabledChanged(uint64 chainSelector, bool enabled);
    event BurnOperatorChanged(address operator, bool isBurnOperator);
    event FundEthOnReceiverForFreshWalletChanged(
        uint256 newFundEthOnReceiverForFreshWallet
    );
    event BurnListenerNotifierChanged(
        uint64 burnListenerDestinationChainSelector,
        bytes burnListenerExtraArgs
    );
    event TransferInitiated(
        address indexed sender,
        address indexed recipient,
        uint64 destinationChainSelector,
        bytes32 indexed messageId
    );
    event TransferProcessed(
        address indexed sender,
        address indexed recipient,
        uint64 sourceChainSelector,
        bytes32 indexed messageId
    );
    event BurnInitiated(
        address indexed sender,
        uint64 destinationChainSelector,
        bytes32 indexed messageId
    );
    event BurnProcessed(
        address indexed sender,
        uint64 sourceChainSelector,
        bytes32 indexed messageId
    );
}
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {BytesLib} from "./BytesLib.sol";

/**
 * @title KreepyKrittersPortalEncoder to encode/decode ccip message data.
 * @dev On CCIP and some L2 chains specifically, calldata size is a main contributor
 * to gas costs. This encoder provides a size and gas optimized packing of message
 * parameters.
 */
contract KreepyKrittersPortalEncoder {
    using BytesLib for bytes;

    uint256 internal constant COMMAND_UNLOCK = 1;
    uint256 internal constant COMMAND_BURN = 2;

    uint256 internal constant OFFSET_COMMAND = 0;
    uint256 internal constant OFFSET_SENDER = 1;
    uint256 internal constant OFFSET_UNLOCK_RECIPIENT = 21;
    uint256 internal constant OFFSET_UNLOCK_TOKENIDS = 41;
    uint256 internal constant OFFSET_BURN_TOKENIDS = 21;
    uint256 internal constant SIZE_TOKENID = 2;

    /**
     * @dev Encode cross chain token transfer message data
     * @param sender sender of the transaction
     * @param recipient recipient of the unlocked NFTs on destination chain
     * @param tokenIds tokenIds to transfer
     */
    function encodeTransfer(
        address sender,
        address recipient,
        uint256[] memory tokenIds
    ) external pure returns (bytes memory data) {
        uint256 length = tokenIds.length;
        data = new bytes(OFFSET_UNLOCK_TOKENIDS + length * SIZE_TOKENID);

        data.writeUInt8(OFFSET_COMMAND, COMMAND_UNLOCK);
        data.writeAddress(OFFSET_SENDER, sender);
        data.writeAddress(OFFSET_UNLOCK_RECIPIENT, recipient);

        for (uint256 i = 0; i < length; ) {
            unchecked {
                data.writeUInt16(
                    OFFSET_UNLOCK_TOKENIDS + i * SIZE_TOKENID,
                    tokenIds[i]
                );
                ++i;
            }
        }
    }

    /**
     * @dev Decode cross chain token transfer message data
     * @param data encoded transfer message data
     * @return sender sender of the transaction
     * @return recipient recipient of the unlocked NFTs on destination chain
     * @return tokenIds tokenIds to transfer
     */
    function decodeTransfer(
        bytes memory data
    )
        external
        pure
        returns (address sender, address recipient, uint256[] memory tokenIds)
    {
        uint256 length = (data.length - OFFSET_UNLOCK_TOKENIDS) / SIZE_TOKENID;
        tokenIds = new uint256[](length);

        sender = data.readAddress(OFFSET_SENDER);
        recipient = data.readAddress(OFFSET_UNLOCK_RECIPIENT);

        for (uint256 i = 0; i < length; ) {
            unchecked {
                tokenIds[i] = data.readUInt16(
                    OFFSET_UNLOCK_TOKENIDS + i * SIZE_TOKENID
                );
                ++i;
            }
        }
    }

    /**
     * @dev Encode cross chain token burn message data
     * @param sender sender of the transaction
     * @param tokenIds tokenIds to transfer
     */
    function encodeBurn(
        address sender,
        uint256[] memory tokenIds
    ) external pure returns (bytes memory data) {
        uint256 length = tokenIds.length;
        data = new bytes(OFFSET_BURN_TOKENIDS + length * SIZE_TOKENID);

        data.writeUInt8(OFFSET_COMMAND, COMMAND_BURN);
        data.writeAddress(OFFSET_SENDER, sender);
        for (uint256 i = 0; i < length; ) {
            unchecked {
                data.writeUInt16(
                    OFFSET_BURN_TOKENIDS + i * SIZE_TOKENID,
                    tokenIds[i]
                );
                ++i;
            }
        }
    }

    /**
     * @dev Decode cross chain token burn message data
     * @param data encoded transfer message data
     * @return sender sender of the transaction
     * @return tokenIds tokenIds to burn
     */
    function decodeBurn(
        bytes memory data
    ) external pure returns (address sender, uint256[] memory tokenIds) {
        uint256 length = (data.length - OFFSET_BURN_TOKENIDS) / SIZE_TOKENID;
        tokenIds = new uint256[](length);

        sender = data.readAddress(OFFSET_SENDER);

        for (uint256 i = 0; i < length; ) {
            unchecked {
                tokenIds[i] = data.readUInt16(
                    OFFSET_BURN_TOKENIDS + i * SIZE_TOKENID
                );
                ++i;
            }
        }
    }
}
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {ConfirmedOwner} from "@chainlink/contracts-ccip/src/v0.8/ConfirmedOwner.sol";

abstract contract CCIPApprovedSource is ConfirmedOwner {
    error SourceNotApproved(uint64 chainSelector, address sender);

    event SourceApproved(uint64 chainSelector, address sender);
    event SourceApprovalRevoked(uint64 chainSelector, address sender);

    mapping(uint256 sourceChainAndAddress => bool) private _sources;

    modifier onlyApprovedSource(uint64 chainSelector, bytes memory sender) {
        address _sender = abi.decode(sender, (address));
        if (!_sourceApproved(chainSelector, _sender)) revert SourceNotApproved(chainSelector, _sender);
        _;
    }

    function approveSource(uint64 chainSelector, address sender) external onlyOwner {
        uint256 sourceChainAndAddress = uint256(uint160(sender)) | (chainSelector) << 160;
        _sources[sourceChainAndAddress] = true;
        emit SourceApproved(chainSelector, sender);
    }

    function revokeSourceApproval(uint64 chainSelector, address sender) external onlyOwner {
        uint256 sourceChainAndAddress = uint256(uint160(sender)) | (chainSelector) << 160;
        _sources[sourceChainAndAddress] = false;
        emit SourceApprovalRevoked(chainSelector, sender);
    }

    function sourceApproved(uint64 chainSelector, address sender) external view returns (bool) {
        return _sourceApproved(chainSelector, sender);
    }

    function _sourceApproved(uint64 chainSelector, address sender) internal view returns (bool) {
        uint256 sourceChainAndAddress = uint256(uint160(sender)) | (chainSelector) << 160;
        return _sources[sourceChainAndAddress];
    }

}// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

library BytesLib {
    function writeAddress(
        bytes memory _data,
        uint256 _offset,
        address _address
    ) internal pure {
        assembly {
            let pos := add(_data, add(_offset, 20))
            let neighbor := and(
                mload(pos),
                0xffffffffffffffffffffffff0000000000000000000000000000000000000000
            )
            mstore(
                pos,
                xor(
                    neighbor,
                    and(_address, 0xffffffffffffffffffffffffffffffffffffffff)
                )
            )
        }
    }

    function writeUInt8(
        bytes memory _data,
        uint256 _offset,
        uint256 _uint8
    ) internal pure {
        assembly {
            let pos := add(_data, add(_offset, 1))
            let neighbor := and(
                mload(pos),
                0xffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff00
            )

            mstore(pos, xor(neighbor, and(_uint8, 0xff)))
        }
    }

    function writeUInt16(
        bytes memory _data,
        uint256 _offset,
        uint256 _uint16
    ) internal pure {
        assembly {
            let pos := add(_data, add(_offset, 2))
            let neighbor := and(
                mload(pos),
                0xffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff0000
            )

            mstore(pos, xor(neighbor, and(_uint16, 0xffff)))
        }
    }

    function readAddress(
        bytes memory _data,
        uint256 _offset
    ) internal pure returns (address _address) {
        assembly {
            _address := and(
                mload(add(_data, add(_offset, 20))),
                0xffffffffffffffffffffffffffffffffffffffff
            )
        }
    }

    function readUInt16(
        bytes memory _data,
        uint256 _offset
    ) internal pure returns (uint256 _uint16) {
        assembly {
            _uint16 := and(mload(add(_data, add(_offset, 2))), 0xffff)
        }
    }

    function readUInt8(
        bytes memory _data,
        uint256 _offset
    ) internal pure returns (uint256 _uint8) {
        assembly {
            _uint8 := and(mload(add(_data, add(_offset, 1))), 0xff)
        }
    }
}
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IOnTokenBurnedListener {
    function onTokenBurned(uint256 tokenId) external;
}// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IBurnable {
    function burn(uint256 tokenId) external;
}// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IMaxSupply {
    function maxSupply() external view returns (uint256);
}// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {ConfirmedOwner} from "@chainlink/contracts-ccip/src/v0.8/ConfirmedOwner.sol";
import {IERC721} from "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import {SafeERC20, IERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import {Address} from "@openzeppelin/contracts/utils/Address.sol";

abstract contract Recoverable is ConfirmedOwner {
    using SafeERC20 for IERC20;

    /**
     * @notice Allows the owner to recover non-fungible tokens sent to the contract by mistake
     * @param _token: NFT token address
     * @param _recipient: recipient
     * @param _tokenIds: tokenIds
     * @dev Callable by owner
     */
    function recoverERC721(address _token, address _recipient, uint256[] calldata _tokenIds) external onlyOwner {
         for (uint256 i = 0; i < _tokenIds.length; ) {
            IERC721(_token).transferFrom(address(this), _recipient, _tokenIds[i]);
            unchecked { ++i; }
         }
    }

    /**
     * @notice Allows the owner to recover tokens sent to the contract by mistake
     * @param _token: token address
     * @param _recipient: recipient
     * @dev Callable by owner
     */
    function recoverERC20(address _token, address _recipient) external onlyOwner {
        uint256 balance = IERC20(_token).balanceOf(address(this));
        require(balance != 0, "Cannot recover zero balance");

        IERC20(_token).safeTransfer(_recipient, balance);
    }

    /**
     * @notice Allows the owner to recover eth sent to the contract by mistake
     * @param _recipient: recipient
     * @dev Callable by owner
     */
    function recoverEth(address payable _recipient) external onlyOwner {
        uint256 balance = address(this).balance;
        require(balance != 0, "Cannot recover zero balance");

        Address.sendValue(_recipient, balance);
    }
}// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {IAny2EVMMessageReceiver} from "../interfaces/IAny2EVMMessageReceiver.sol";

import {Client} from "../libraries/Client.sol";

import {IERC165} from "../../vendor/openzeppelin-solidity/v4.8.0/utils/introspection/IERC165.sol";

/// @title CCIPReceiver - Base contract for CCIP applications that can receive messages.
abstract contract CCIPReceiver is IAny2EVMMessageReceiver, IERC165 {
  address internal immutable i_router;

  constructor(address router) {
    if (router == address(0)) revert InvalidRouter(address(0));
    i_router = router;
  }

  /// @notice IERC165 supports an interfaceId
  /// @param interfaceId The interfaceId to check
  /// @return true if the interfaceId is supported
  function supportsInterface(bytes4 interfaceId) public pure override returns (bool) {
    return interfaceId == type(IAny2EVMMessageReceiver).interfaceId || interfaceId == type(IERC165).interfaceId;
  }

  /// @inheritdoc IAny2EVMMessageReceiver
  function ccipReceive(Client.Any2EVMMessage calldata message) external virtual override onlyRouter {
    _ccipReceive(message);
  }

  /// @notice Override this function in your implementation.
  /// @param message Any2EVMMessage
  function _ccipReceive(Client.Any2EVMMessage memory message) internal virtual;

  /////////////////////////////////////////////////////////////////////
  // Plumbing
  /////////////////////////////////////////////////////////////////////

  /// @notice Return the current router
  /// @return i_router address
  function getRouter() public view returns (address) {
    return address(i_router);
  }

  error InvalidRouter(address router);

  /// @dev only calls from the set router are accepted.
  modifier onlyRouter() {
    if (msg.sender != address(i_router)) revert InvalidRouter(msg.sender);
    _;
  }
}
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

// End consumer library.
library Client {
  struct EVMTokenAmount {
    address token; // token address on the local chain.
    uint256 amount; // Amount of tokens.
  }

  struct Any2EVMMessage {
    bytes32 messageId; // MessageId corresponding to ccipSend on source.
    uint64 sourceChainSelector; // Source chain selector.
    bytes sender; // abi.decode(sender) if coming from an EVM chain.
    bytes data; // payload sent in original message.
    EVMTokenAmount[] destTokenAmounts; // Tokens and their amounts in their destination chain representation.
  }

  // If extraArgs is empty bytes, the default is 200k gas limit and strict = false.
  struct EVM2AnyMessage {
    bytes receiver; // abi.encode(receiver address) for dest EVM chains
    bytes data; // Data payload
    EVMTokenAmount[] tokenAmounts; // Token transfers
    address feeToken; // Address of feeToken. address(0) means you will send msg.value.
    bytes extraArgs; // Populate this with _argsToBytes(EVMExtraArgsV1)
  }

  // extraArgs will evolve to support new features
  // bytes4(keccak256("CCIP EVMExtraArgsV1"));
  bytes4 public constant EVM_EXTRA_ARGS_V1_TAG = 0x97a657c9;
  struct EVMExtraArgsV1 {
    uint256 gasLimit; // ATTENTION!!! MAX GAS LIMIT 4M FOR BETA TESTING
    bool strict; // See strict sequencing details below.
  }

  function _argsToBytes(EVMExtraArgsV1 memory extraArgs) internal pure returns (bytes memory bts) {
    return abi.encodeWithSelector(EVM_EXTRA_ARGS_V1_TAG, extraArgs);
  }
}
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {Client} from "../libraries/Client.sol";

interface IRouterClient {
  error UnsupportedDestinationChain(uint64 destChainSelector);
  error InsufficientFeeTokenAmount();
  error InvalidMsgValue();

  /// @notice Checks if the given chain ID is supported for sending/receiving.
  /// @param chainSelector The chain to check.
  /// @return supported is true if it is supported, false if not.
  function isChainSupported(uint64 chainSelector) external view returns (bool supported);

  /// @notice Gets a list of all supported tokens which can be sent or received
  /// to/from a given chain id.
  /// @param chainSelector The chainSelector.
  /// @return tokens The addresses of all tokens that are supported.
  function getSupportedTokens(uint64 chainSelector) external view returns (address[] memory tokens);

  /// @param destinationChainSelector The destination chainSelector
  /// @param message The cross-chain CCIP message including data and/or tokens
  /// @return fee returns guaranteed execution fee for the specified message
  /// delivery to destination chain
  /// @dev returns 0 fee on invalid message.
  function getFee(
    uint64 destinationChainSelector,
    Client.EVM2AnyMessage memory message
  ) external view returns (uint256 fee);

  /// @notice Request a message to be sent to the destination chain
  /// @param destinationChainSelector The destination chain ID
  /// @param message The cross-chain CCIP message including data and/or tokens
  /// @return messageId The message ID
  /// @dev Note if msg.value is larger than the required fee (from getFee) we accept
  /// the overpayment with no refund.
  function ccipSend(
    uint64 destinationChainSelector,
    Client.EVM2AnyMessage calldata message
  ) external payable returns (bytes32);
}
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.8.0) (token/ERC721/IERC721.sol)

pragma solidity ^0.8.0;

import "../../utils/introspection/IERC165.sol";

/**
 * @dev Required interface of an ERC721 compliant contract.
 */
interface IERC721 is IERC165 {
    /**
     * @dev Emitted when `tokenId` token is transferred from `from` to `to`.
     */
    event Transfer(address indexed from, address indexed to, uint256 indexed tokenId);

    /**
     * @dev Emitted when `owner` enables `approved` to manage the `tokenId` token.
     */
    event Approval(address indexed owner, address indexed approved, uint256 indexed tokenId);

    /**
     * @dev Emitted when `owner` enables or disables (`approved`) `operator` to manage all of its assets.
     */
    event ApprovalForAll(address indexed owner, address indexed operator, bool approved);

    /**
     * @dev Returns the number of tokens in ``owner``'s account.
     */
    function balanceOf(address owner) external view returns (uint256 balance);

    /**
     * @dev Returns the owner of the `tokenId` token.
     *
     * Requirements:
     *
     * - `tokenId` must exist.
     */
    function ownerOf(uint256 tokenId) external view returns (address owner);

    /**
     * @dev Safely transfers `tokenId` token from `from` to `to`.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `tokenId` token must exist and be owned by `from`.
     * - If the caller is not `from`, it must be approved to move this token by either {approve} or {setApprovalForAll}.
     * - If `to` refers to a smart contract, it must implement {IERC721Receiver-onERC721Received}, which is called upon a safe transfer.
     *
     * Emits a {Transfer} event.
     */
    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId,
        bytes calldata data
    ) external;

    /**
     * @dev Safely transfers `tokenId` token from `from` to `to`, checking first that contract recipients
     * are aware of the ERC721 protocol to prevent tokens from being forever locked.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `tokenId` token must exist and be owned by `from`.
     * - If the caller is not `from`, it must have been allowed to move this token by either {approve} or {setApprovalForAll}.
     * - If `to` refers to a smart contract, it must implement {IERC721Receiver-onERC721Received}, which is called upon a safe transfer.
     *
     * Emits a {Transfer} event.
     */
    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId
    ) external;

    /**
     * @dev Transfers `tokenId` token from `from` to `to`.
     *
     * WARNING: Note that the caller is responsible to confirm that the recipient is capable of receiving ERC721
     * or else they may be permanently lost. Usage of {safeTransferFrom} prevents loss, though the caller must
     * understand this adds an external call which potentially creates a reentrancy vulnerability.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `tokenId` token must be owned by `from`.
     * - If the caller is not `from`, it must be approved to move this token by either {approve} or {setApprovalForAll}.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(
        address from,
        address to,
        uint256 tokenId
    ) external;

    /**
     * @dev Gives permission to `to` to transfer `tokenId` token to another account.
     * The approval is cleared when the token is transferred.
     *
     * Only a single account can be approved at a time, so approving the zero address clears previous approvals.
     *
     * Requirements:
     *
     * - The caller must own the token or be an approved operator.
     * - `tokenId` must exist.
     *
     * Emits an {Approval} event.
     */
    function approve(address to, uint256 tokenId) external;

    /**
     * @dev Approve or remove `operator` as an operator for the caller.
     * Operators can call {transferFrom} or {safeTransferFrom} for any token owned by the caller.
     *
     * Requirements:
     *
     * - The `operator` cannot be the caller.
     *
     * Emits an {ApprovalForAll} event.
     */
    function setApprovalForAll(address operator, bool _approved) external;

    /**
     * @dev Returns the account approved for `tokenId` token.
     *
     * Requirements:
     *
     * - `tokenId` must exist.
     */
    function getApproved(uint256 tokenId) external view returns (address operator);

    /**
     * @dev Returns if the `operator` is allowed to manage all of the assets of `owner`.
     *
     * See {setApprovalForAll}
     */
    function isApprovedForAll(address owner, address operator) external view returns (bool);
}
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.7.0) (security/Pausable.sol)

pragma solidity ^0.8.0;

import "../utils/Context.sol";

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
     * @dev Modifier to make a function callable only when the contract is not paused.
     *
     * Requirements:
     *
     * - The contract must not be paused.
     */
    modifier whenNotPaused() {
        _requireNotPaused();
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
        _requirePaused();
        _;
    }

    /**
     * @dev Returns true if the contract is paused, and false otherwise.
     */
    function paused() public view virtual returns (bool) {
        return _paused;
    }

    /**
     * @dev Throws if the contract is paused.
     */
    function _requireNotPaused() internal view virtual {
        require(!paused(), "Pausable: paused");
    }

    /**
     * @dev Throws if the contract is not paused.
     */
    function _requirePaused() internal view virtual {
        require(paused(), "Pausable: not paused");
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
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.8.0) (security/ReentrancyGuard.sol)

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
}
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.8.0) (utils/Address.sol)

pragma solidity ^0.8.1;

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
     *
     * [IMPORTANT]
     * ====
     * You shouldn't rely on `isContract` to protect against flash loan attacks!
     *
     * Preventing calls from contracts is highly discouraged. It breaks composability, breaks support for smart wallets
     * like Gnosis Safe, and does not provide security since it can be circumvented by calling from a contract
     * constructor.
     * ====
     */
    function isContract(address account) internal view returns (bool) {
        // This method relies on extcodesize/address.code.length, which returns 0
        // for contracts in construction, since the code is only stored at the end
        // of the constructor execution.

        return account.code.length > 0;
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

        (bool success, ) = recipient.call{value: amount}("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }

    /**
     * @dev Performs a Solidity function call using a low level `call`. A
     * plain `call` is an unsafe replacement for a function call: use this
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
        return functionCallWithValue(target, data, 0, "Address: low-level call failed");
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
        (bool success, bytes memory returndata) = target.call{value: value}(data);
        return verifyCallResultFromTarget(target, success, returndata, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but performing a static call.
     *
     * _Available since v3.3._
     */
    function functionStaticCall(address target, bytes memory data) internal view returns (bytes memory) {
        return functionStaticCall(target, data, "Address: low-level static call failed");
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
        (bool success, bytes memory returndata) = target.staticcall(data);
        return verifyCallResultFromTarget(target, success, returndata, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but performing a delegate call.
     *
     * _Available since v3.4._
     */
    function functionDelegateCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionDelegateCall(target, data, "Address: low-level delegate call failed");
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
        (bool success, bytes memory returndata) = target.delegatecall(data);
        return verifyCallResultFromTarget(target, success, returndata, errorMessage);
    }

    /**
     * @dev Tool to verify that a low level call to smart-contract was successful, and revert (either by bubbling
     * the revert reason or using the provided one) in case of unsuccessful call or if target was not a contract.
     *
     * _Available since v4.8._
     */
    function verifyCallResultFromTarget(
        address target,
        bool success,
        bytes memory returndata,
        string memory errorMessage
    ) internal view returns (bytes memory) {
        if (success) {
            if (returndata.length == 0) {
                // only check isContract if the call was successful and the return data is empty
                // otherwise we already know that it was a contract
                require(isContract(target), "Address: call to non-contract");
            }
            return returndata;
        } else {
            _revert(returndata, errorMessage);
        }
    }

    /**
     * @dev Tool to verify that a low level call was successful, and revert if it wasn't, either by bubbling the
     * revert reason or using the provided one.
     *
     * _Available since v4.3._
     */
    function verifyCallResult(
        bool success,
        bytes memory returndata,
        string memory errorMessage
    ) internal pure returns (bytes memory) {
        if (success) {
            return returndata;
        } else {
            _revert(returndata, errorMessage);
        }
    }

    function _revert(bytes memory returndata, string memory errorMessage) private pure {
        // Look for revert reason and bubble it up if present
        if (returndata.length > 0) {
            // The easiest way to bubble the revert reason is using memory via assembly
            /// @solidity memory-safe-assembly
            assembly {
                let returndata_size := mload(returndata)
                revert(add(32, returndata), returndata_size)
            }
        } else {
            revert(errorMessage);
        }
    }
}
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {Client} from "../libraries/Client.sol";

/// @notice Application contracts that intend to receive messages from
/// the router should implement this interface.
interface IAny2EVMMessageReceiver {
  /// @notice Called by the Router to deliver a message.
  /// If this reverts, any token transfers also revert. The message
  /// will move to a FAILED state and become available for manual execution.
  /// @param message CCIP Message
  /// @dev Note ensure you check the msg.sender is the OffRampRouter
  function ccipReceive(Client.Any2EVMMessage calldata message) external;
}
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/introspection/IERC165.sol)

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC165 standard, as defined in the
 * https://eips.ethereum.org/EIPS/eip-165[EIP].
 *
 * Implementers can declare support of contract interfaces, which can then be
 * queried by others ({ERC165Checker}).
 *
 * For an implementation, see {ERC165}.
 */
interface IERC165 {
  /**
    * @dev Returns true if this contract implements the interface defined by
    * `interfaceId`. See the corresponding
    * https://eips.ethereum.org/EIPS/eip-165#how-interfaces-are-identified[EIP section]
    * to learn more about how these ids are created.
    *
    * This function call must use less than 30 000 gas.
    */
  function supportsInterface(bytes4 interfaceId) external view returns (bool);
}// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/introspection/IERC165.sol)

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC165 standard, as defined in the
 * https://eips.ethereum.org/EIPS/eip-165[EIP].
 *
 * Implementers can declare support of contract interfaces, which can then be
 * queried by others ({ERC165Checker}).
 *
 * For an implementation, see {ERC165}.
 */
interface IERC165 {
    /**
     * @dev Returns true if this contract implements the interface defined by
     * `interfaceId`. See the corresponding
     * https://eips.ethereum.org/EIPS/eip-165#how-interfaces-are-identified[EIP section]
     * to learn more about how these ids are created.
     *
     * This function call must use less than 30 000 gas.
     */
    function supportsInterface(bytes4 interfaceId) external view returns (bool);
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
pragma solidity ^0.8.0;

import "./ConfirmedOwnerWithProposal.sol";

/**
 * @title The ConfirmedOwner contract
 * @notice A contract with helpers for basic contract ownership.
 */
contract ConfirmedOwner is ConfirmedOwnerWithProposal {
  constructor(address newOwner) ConfirmedOwnerWithProposal(newOwner, address(0)) {}
}
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./interfaces/OwnableInterface.sol";

/**
 * @title The ConfirmedOwner contract
 * @notice A contract with helpers for basic contract ownership.
 */
contract ConfirmedOwnerWithProposal is OwnableInterface {
  address private s_owner;
  address private s_pendingOwner;

  event OwnershipTransferRequested(address indexed from, address indexed to);
  event OwnershipTransferred(address indexed from, address indexed to);

  constructor(address newOwner, address pendingOwner) {
    require(newOwner != address(0), "Cannot set owner to zero");

    s_owner = newOwner;
    if (pendingOwner != address(0)) {
      _transferOwnership(pendingOwner);
    }
  }

  /**
   * @notice Allows an owner to begin transferring ownership to a new address,
   * pending.
   */
  function transferOwnership(address to) public override onlyOwner {
    _transferOwnership(to);
  }

  /**
   * @notice Allows an ownership transfer to be completed by the recipient.
   */
  function acceptOwnership() external override {
    require(msg.sender == s_pendingOwner, "Must be proposed owner");

    address oldOwner = s_owner;
    s_owner = msg.sender;
    s_pendingOwner = address(0);

    emit OwnershipTransferred(oldOwner, msg.sender);
  }

  /**
   * @notice Get the current owner
   */
  function owner() public view override returns (address) {
    return s_owner;
  }

  /**
   * @notice validate, transfer ownership, and emit relevant events
   */
  function _transferOwnership(address to) private {
    require(to != msg.sender, "Cannot transfer to self");

    s_pendingOwner = to;

    emit OwnershipTransferRequested(s_owner, to);
  }

  /**
   * @notice validate access
   */
  function _validateOwnership() internal view {
    require(msg.sender == s_owner, "Only callable by owner");
  }

  /**
   * @notice Reverts if called by anyone other than the contract owner.
   */
  modifier onlyOwner() {
    _validateOwnership();
    _;
  }
}
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface OwnableInterface {
  function owner() external returns (address);

  function transferOwnership(address recipient) external;

  function acceptOwnership() external;
}
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.8.0) (token/ERC20/utils/SafeERC20.sol)

pragma solidity ^0.8.0;

import "../IERC20.sol";
import "../extensions/draft-IERC20Permit.sol";
import "../../../utils/Address.sol";

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
        require(
            (value == 0) || (token.allowance(address(this), spender) == 0),
            "SafeERC20: approve from non-zero to non-zero allowance"
        );
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
    }

    function safeIncreaseAllowance(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {
        uint256 newAllowance = token.allowance(address(this), spender) + value;
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function safeDecreaseAllowance(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {
        unchecked {
            uint256 oldAllowance = token.allowance(address(this), spender);
            require(oldAllowance >= value, "SafeERC20: decreased allowance below zero");
            uint256 newAllowance = oldAllowance - value;
            _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
        }
    }

    function safePermit(
        IERC20Permit token,
        address owner,
        address spender,
        uint256 value,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) internal {
        uint256 nonceBefore = token.nonces(owner);
        token.permit(owner, spender, value, deadline, v, r, s);
        uint256 nonceAfter = token.nonces(owner);
        require(nonceAfter == nonceBefore + 1, "SafeERC20: permit did not succeed");
    }

    /**
     * @dev Imitates a Solidity high-level call (i.e. a regular function call to a contract), relaxing the requirement
     * on the return value: the return value is optional (but if data is returned, it must not be false).
     * @param token The token targeted by the call.
     * @param data The call data (encoded using abi.encode or one of its variants).
     */
    function _callOptionalReturn(IERC20 token, bytes memory data) private {
        // We need to perform a low level call here, to bypass Solidity's return data size checking mechanism, since
        // we're implementing it ourselves. We use {Address-functionCall} to perform this call, which verifies that
        // the target address contains contract code and also asserts for success in the low-level call.

        bytes memory returndata = address(token).functionCall(data, "SafeERC20: low-level call failed");
        if (returndata.length > 0) {
            // Return data is optional
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
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
// OpenZeppelin Contracts v4.4.1 (token/ERC20/extensions/draft-IERC20Permit.sol)

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC20 Permit extension allowing approvals to be made via signatures, as defined in
 * https://eips.ethereum.org/EIPS/eip-2612[EIP-2612].
 *
 * Adds the {permit} method, which can be used to change an account's ERC20 allowance (see {IERC20-allowance}) by
 * presenting a message signed by the account. By not relying on {IERC20-approve}, the token holder account doesn't
 * need to send a transaction, and thus is not required to hold Ether at all.
 */
interface IERC20Permit {
    /**
     * @dev Sets `value` as the allowance of `spender` over ``owner``'s tokens,
     * given ``owner``'s signed approval.
     *
     * IMPORTANT: The same issues {IERC20-approve} has related to transaction
     * ordering also apply here.
     *
     * Emits an {Approval} event.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     * - `deadline` must be a timestamp in the future.
     * - `v`, `r` and `s` must be a valid `secp256k1` signature from `owner`
     * over the EIP712-formatted function arguments.
     * - the signature must use ``owner``'s current nonce (see {nonces}).
     *
     * For more information on the signature format, see the
     * https://eips.ethereum.org/EIPS/eip-2612#specification[relevant EIP
     * section].
     */
    function permit(
        address owner,
        address spender,
        uint256 value,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external;

    /**
     * @dev Returns the current nonce for `owner`. This value must be
     * included whenever a signature is generated for {permit}.
     *
     * Every successful call to {permit} increases ``owner``'s nonce by one. This
     * prevents a signature from being used multiple times.
     */
    function nonces(address owner) external view returns (uint256);

    /**
     * @dev Returns the domain separator used in the encoding of the signature for {permit}, as defined by {EIP712}.
     */
    // solhint-disable-next-line func-name-mixedcase
    function DOMAIN_SEPARATOR() external view returns (bytes32);
}
