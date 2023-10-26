// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.5.0) (token/ERC1155/IERC1155Receiver.sol)

pragma solidity ^0.8.0;

import "../../utils/introspection/IERC165.sol";

/**
 * @dev _Available since v3.1._
 */
interface IERC1155Receiver is IERC165 {
    /**
     * @dev Handles the receipt of a single ERC1155 token type. This function is
     * called at the end of a `safeTransferFrom` after the balance has been updated.
     *
     * NOTE: To accept the transfer, this must return
     * `bytes4(keccak256("onERC1155Received(address,address,uint256,uint256,bytes)"))`
     * (i.e. 0xf23a6e61, or its own function selector).
     *
     * @param operator The address which initiated the transfer (i.e. msg.sender)
     * @param from The address which previously owned the token
     * @param id The ID of the token being transferred
     * @param value The amount of tokens being transferred
     * @param data Additional data with no specified format
     * @return `bytes4(keccak256("onERC1155Received(address,address,uint256,uint256,bytes)"))` if transfer is allowed
     */
    function onERC1155Received(
        address operator,
        address from,
        uint256 id,
        uint256 value,
        bytes calldata data
    ) external returns (bytes4);

    /**
     * @dev Handles the receipt of a multiple ERC1155 token types. This function
     * is called at the end of a `safeBatchTransferFrom` after the balances have
     * been updated.
     *
     * NOTE: To accept the transfer(s), this must return
     * `bytes4(keccak256("onERC1155BatchReceived(address,address,uint256[],uint256[],bytes)"))`
     * (i.e. 0xbc197c81, or its own function selector).
     *
     * @param operator The address which initiated the batch transfer (i.e. msg.sender)
     * @param from The address which previously owned the token
     * @param ids An array containing ids of each token being transferred (order and length must match values array)
     * @param values An array containing amounts of each token being transferred (order and length must match ids array)
     * @param data Additional data with no specified format
     * @return `bytes4(keccak256("onERC1155BatchReceived(address,address,uint256[],uint256[],bytes)"))` if transfer is allowed
     */
    function onERC1155BatchReceived(
        address operator,
        address from,
        uint256[] calldata ids,
        uint256[] calldata values,
        bytes calldata data
    ) external returns (bytes4);
}
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (token/ERC1155/utils/ERC1155Receiver.sol)

pragma solidity ^0.8.0;

import "../IERC1155Receiver.sol";
import "../../../utils/introspection/ERC165.sol";

/**
 * @dev _Available since v3.1._
 */
abstract contract ERC1155Receiver is ERC165, IERC1155Receiver {
    /**
     * @dev See {IERC165-supportsInterface}.
     */
    function supportsInterface(bytes4 interfaceId) public view virtual override(ERC165, IERC165) returns (bool) {
        return interfaceId == type(IERC1155Receiver).interfaceId || super.supportsInterface(interfaceId);
    }
}
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.6.0) (token/ERC721/IERC721Receiver.sol)

pragma solidity ^0.8.0;

/**
 * @title ERC721 token receiver interface
 * @dev Interface for any contract that wants to support safeTransfers
 * from ERC721 asset contracts.
 */
interface IERC721Receiver {
    /**
     * @dev Whenever an {IERC721} `tokenId` token is transferred to this contract via {IERC721-safeTransferFrom}
     * by `operator` from `from`, this function is called.
     *
     * It must return its Solidity selector to confirm the token transfer.
     * If any other value is returned or the interface is not implemented by the recipient, the transfer will be reverted.
     *
     * The selector can be obtained in Solidity with `IERC721Receiver.onERC721Received.selector`.
     */
    function onERC721Received(
        address operator,
        address from,
        uint256 tokenId,
        bytes calldata data
    ) external returns (bytes4);
}
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/introspection/ERC165.sol)

pragma solidity ^0.8.0;

import "./IERC165.sol";

/**
 * @dev Implementation of the {IERC165} interface.
 *
 * Contracts that want to implement ERC165 should inherit from this contract and override {supportsInterface} to check
 * for the additional interface id that will be supported. For example:
 *
 * ```solidity
 * function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
 *     return interfaceId == type(MyInterface).interfaceId || super.supportsInterface(interfaceId);
 * }
 * ```
 *
 * Alternatively, {ERC165Storage} provides an easier to use but more expensive implementation.
 */
abstract contract ERC165 is IERC165 {
    /**
     * @dev See {IERC165-supportsInterface}.
     */
    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return interfaceId == type(IERC165).interfaceId;
    }
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
}
// SPDX-License-Identifier: MIT
// from https://github.com/optionality/clone-factory
pragma solidity 0.8.20;

/*
    The MIT License (MIT)
    Copyright (c) 2018 Murray Software, LLC.
    Permission is hereby granted, free of charge, to any person obtaining
    a copy of this software and associated documentation files (the
    "Software"), to deal in the Software without restriction, including
    without limitation the rights to use, copy, modify, merge, publish,
    distribute, sublicense, and/or sell copies of the Software, and to
    permit persons to whom the Software is furnished to do so, subject to
    the following conditions:
    The above copyright notice and this permission notice shall be included
    in all copies or substantial portions of the Software.
    THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS
    OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
    MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
    IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
    CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
    TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
    SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
*/
//solhint-disable max-line-length
//solhint-disable no-inline-assembly

contract CloneFactory {
  function createClone(address target, bytes32 salt)
    internal
    returns (address payable result)
  {
    bytes20 targetBytes = bytes20(target);
    assembly {
      // load the next free memory slot as a place to store the clone contract data
      let clone := mload(0x40)

      // The bytecode block below is responsible for contract initialization
      // during deployment, it is worth noting the proxied contract constructor will not be called during
      // the cloning procedure and that is why an initialization function needs to be called after the
      // clone is created
      mstore(
        clone,
        0x3d602d80600a3d3981f3363d3d373d3d3d363d73000000000000000000000000
      )

      // This stores the address location of the implementation contract
      // so that the proxy knows where to delegate call logic to
      mstore(add(clone, 0x14), targetBytes)

      // The bytecode block is the actual code that is deployed for each clone created.
      // It forwards all calls to the already deployed implementation via a delegatecall
      mstore(
        add(clone, 0x28),
        0x5af43d82803e903d91602b57fd5bf30000000000000000000000000000000000
      )

      // deploy the contract using the CREATE2 opcode
      // this deploys the minimal proxy defined above, which will proxy all
      // calls to use the logic defined in the implementation contract `target`
      result := create2(0, clone, 0x37, salt)
    }
  }

  function isClone(address target, address query)
    internal
    view
    returns (bool result)
  {
    bytes20 targetBytes = bytes20(target);
    assembly {
      // load the next free memory slot as a place to store the comparison clone
      let clone := mload(0x40)

      // The next three lines store the expected bytecode for a miniml proxy
      // that targets `target` as its implementation contract
      mstore(
        clone,
        0x363d3d373d3d3d363d7300000000000000000000000000000000000000000000
      )
      mstore(add(clone, 0xa), targetBytes)
      mstore(
        add(clone, 0x1e),
        0x5af43d82803e903d91602b57fd5bf30000000000000000000000000000000000
      )

      // the next two lines store the bytecode of the contract that we are checking in memory
      let other := add(clone, 0x40)
      extcodecopy(query, other, 0, 0x2d)

      // Check if the expected bytecode equals the actual bytecode and return the result
      result := and(
        eq(mload(clone), mload(other)),
        eq(mload(add(clone, 0xd)), mload(add(other, 0xd)))
      )
    }
  }
}
// SPDX-License-Identifier: Apache-2.0
pragma solidity 0.8.20;

import '@openzeppelin/contracts/utils/introspection/IERC165.sol';

interface IForwarder is IERC165 {
  /**
   * Sets the autoflush721 parameter.
   *
   * @param autoFlush whether to autoflush erc721 tokens
   */
  function setAutoFlush721(bool autoFlush) external;

  /**
   * Sets the autoflush1155 parameter.
   *
   * @param autoFlush whether to autoflush erc1155 tokens
   */
  function setAutoFlush1155(bool autoFlush) external;

  /**
   * Execute a token transfer of the full balance from the forwarder token to the parent address
   *
   * @param tokenContractAddress the address of the erc20 token contract
   */
  function flushTokens(address tokenContractAddress) external;

  /**
   * Execute a nft transfer from the forwarder to the parent address
   *
   * @param tokenContractAddress the address of the ERC721 NFT contract
   * @param tokenId The token id of the nft
   */
  function flushERC721Token(address tokenContractAddress, uint256 tokenId)
    external;

  /**
   * Execute a nft transfer from the forwarder to the parent address.
   *
   * @param tokenContractAddress the address of the ERC1155 NFT contract
   * @param tokenId The token id of the nft
   */
  function flushERC1155Tokens(address tokenContractAddress, uint256 tokenId)
    external;

  /**
   * Execute a batch nft transfer from the forwarder to the parent address.
   *
   * @param tokenContractAddress the address of the ERC1155 NFT contract
   * @param tokenIds The token ids of the nfts
   */
  function batchFlushERC1155Tokens(
    address tokenContractAddress,
    uint256[] calldata tokenIds
  ) external;
}
// SPDX-License-Identifier: Apache-2.0
pragma solidity 0.8.20;
import './RecoveryWalletSimple.sol';
import '../CloneFactory.sol';

contract RecoveryWalletFactory is CloneFactory {
  address public implementationAddress;

  constructor(address _implementationAddress) {
    implementationAddress = _implementationAddress;
  }

  function createWallet(address[] calldata allowedSigners, bytes32 salt)
    external
  {
    // include the signers in the salt so any contract deployed to a given address must have the same signers
    bytes32 finalSalt = keccak256(abi.encodePacked(allowedSigners, salt));

    address payable clone = createClone(implementationAddress, finalSalt);
    RecoveryWalletSimple(clone).init(allowedSigners[2]);
  }
}
// SPDX-License-Identifier: Apache-2.0
pragma solidity 0.8.20;
import '../IForwarder.sol';

/** ERC721, ERC1155 imports */
import '@openzeppelin/contracts/token/ERC721/IERC721Receiver.sol';
import '@openzeppelin/contracts/token/ERC1155/utils/ERC1155Receiver.sol';

/**
 *
 * RecoveryWallet
 * ============
 *
 * Basic singleSig wallet designed to recover funds.
 *
 */
contract RecoveryWalletSimple is IERC721Receiver, ERC1155Receiver {
  // Public fields
  address public signer;
  bool public initialized = false; // True if the contract has been initialized

  function init(address _signer) external onlyUninitialized {
    signer = _signer;
    initialized = true;
  }

  /**
   * Modifier that will execute internal code block only if the sender is an authorized signer on this wallet
   */
  modifier onlySigner() {
    require(signer == msg.sender, 'Non-signer in onlySigner method');
    _;
  }

  /**
   * Modifier that will execute internal code block only if the contract has not been initialized yet
   */
  modifier onlyUninitialized() {
    require(!initialized, 'Contract already initialized');
    _;
  }

  /**
   * Gets called when a transaction is received with data that does not match any other method
   */
  fallback() external payable {}

  /**
   * Gets called when a transaction is received with ether and no data
   */
  receive() external payable {}

  /**
   * Execute a transaction from this wallet using the signer.
   *
   * @param toAddress the destination address to send an outgoing transaction
   * @param value the amount in Wei to be sent
   * @param data the data to send to the toAddress when invoking the transaction
   */
  function sendFunds(
    address toAddress,
    uint256 value,
    bytes calldata data
  ) external onlySigner {
    // Success, send the transaction
    (bool success, ) = toAddress.call{ value: value }(data);
    require(success, 'Call execution failed');
  }

  /**
   * Execute a token flush from one of the forwarder addresses. This transfer can be done by any external address
   *
   * @param forwarderAddress the address of the forwarder address to flush the tokens from
   * @param tokenContractAddress the address of the erc20 token contract
   */
  function flushForwarderTokens(
    address payable forwarderAddress,
    address tokenContractAddress
  ) external {
    IForwarder forwarder = IForwarder(forwarderAddress);
    forwarder.flushTokens(tokenContractAddress);
  }

  /**
   * Execute a ERC721 token flush from one of the forwarder addresses. This transfer can be done by any external address
   *
   * @param forwarderAddress the address of the forwarder address to flush the tokens from
   * @param tokenContractAddress the address of the erc20 token contract
   */
  function flushERC721ForwarderTokens(
    address payable forwarderAddress,
    address tokenContractAddress,
    uint256 tokenId
  ) external {
    IForwarder forwarder = IForwarder(forwarderAddress);
    forwarder.flushERC721Token(tokenContractAddress, tokenId);
  }

  /**
   * Execute a ERC1155 batch token flush from one of the forwarder addresses.
   * This transfer can be done by any external address.
   *
   * @param forwarderAddress the address of the forwarder address to flush the tokens from
   * @param tokenContractAddress the address of the erc1155 token contract
   */
  function batchFlushERC1155ForwarderTokens(
    address payable forwarderAddress,
    address tokenContractAddress,
    uint256[] calldata tokenIds
  ) external {
    IForwarder forwarder = IForwarder(forwarderAddress);
    forwarder.batchFlushERC1155Tokens(tokenContractAddress, tokenIds);
  }

  /**
   * Execute a ERC1155 token flush from one of the forwarder addresses.
   * This transfer can be done by any external address.
   *
   * @param forwarderAddress the address of the forwarder address to flush the tokens from
   * @param tokenContractAddress the address of the erc1155 token contract
   * @param tokenId the token id associated with the ERC1155
   */
  function flushERC1155ForwarderTokens(
    address payable forwarderAddress,
    address tokenContractAddress,
    uint256 tokenId
  ) external {
    IForwarder forwarder = IForwarder(forwarderAddress);
    forwarder.flushERC1155Tokens(tokenContractAddress, tokenId);
  }

  /**
   * Sets the autoflush 721 parameter on the forwarder.
   *
   * @param forwarderAddress the address of the forwarder to toggle.
   * @param autoFlush whether to autoflush erc721 tokens
   */
  function setAutoFlush721(address forwarderAddress, bool autoFlush)
    external
    onlySigner
  {
    IForwarder forwarder = IForwarder(forwarderAddress);
    forwarder.setAutoFlush721(autoFlush);
  }

  /**
   * Sets the autoflush 721 parameter on the forwarder.
   *
   * @param forwarderAddress the address of the forwarder to toggle.
   * @param autoFlush whether to autoflush erc1155 tokens
   */
  function setAutoFlush1155(address forwarderAddress, bool autoFlush)
    external
    onlySigner
  {
    IForwarder forwarder = IForwarder(forwarderAddress);
    forwarder.setAutoFlush1155(autoFlush);
  }

  /**
   * ERC721 standard callback function for when a ERC721 is transfered.
   *
   * @param _operator The address of the nft contract
   * @param _from The address of the sender
   * @param _tokenId The token id of the nft
   * @param _data Additional data with no specified format, sent in call to `_to`
   */
  function onERC721Received(
    address _operator,
    address _from,
    uint256 _tokenId,
    bytes memory _data
  ) external virtual override returns (bytes4) {
    return this.onERC721Received.selector;
  }

  /**
   * @inheritdoc IERC1155Receiver
   */
  function onERC1155Received(
    address _operator,
    address _from,
    uint256 id,
    uint256 value,
    bytes calldata data
  ) external virtual override returns (bytes4) {
    return this.onERC1155Received.selector;
  }

  /**
   * @inheritdoc IERC1155Receiver
   */
  function onERC1155BatchReceived(
    address _operator,
    address _from,
    uint256[] calldata ids,
    uint256[] calldata values,
    bytes calldata data
  ) external virtual override returns (bytes4) {
    return this.onERC1155BatchReceived.selector;
  }
}
