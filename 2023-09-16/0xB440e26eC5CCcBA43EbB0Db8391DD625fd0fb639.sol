// SPDX-License-Identifier: MIT
pragma solidity ^0.8.11;

import "../ERC1155/ERC1155CreatorBase.sol";
import "./IArtzoneCreator.sol";
import "../Helpers/Permissions/PermissionControl.sol";

import "@openzeppelin/contracts/security/ReentrancyGuard.sol";

contract ArtzoneCreator is
  ReentrancyGuard,
  ERC1155CreatorBase,
  IArtzoneCreator,
  PermissionControl
{
  uint64 public constant MAX_BPS = 10_000;
  uint256 public ARTZONE_MINTER_FEE_BPS;

  mapping(uint256 => address) internal _tokenRevenueRecipient;
  mapping(uint256 => mapping(address => uint256)) internal _userTokenClaimCount;

  constructor(
    string memory name_,
    string memory symbol_,
    uint256 feeBps_
  ) ERC1155CreatorBase(name_, symbol_) {
    ARTZONE_MINTER_FEE_BPS = feeBps_;
  }

  modifier checkTokenClaimable(uint256 tokenId, address user) {
    TokenClaimType claimStatus = _tokenMetadata[tokenId].claimStatus;
    if (isPermissionedUser(user)) {
      require(
        claimStatus == TokenClaimType.PUBLIC || claimStatus == TokenClaimType.ADMIN,
        "Token mint disabled"
      );
    } else {
      require(claimStatus == TokenClaimType.PUBLIC, "Token public mint disabled");
    }
    _;
  }

  /**
   * @dev See {IArtzoneCreator-initialiseNewSingleToken}.
   */
  function initialiseNewSingleToken(
    TokenMetadataConfig calldata tokenConfig,
    address revenueRecipient
  ) external onlyPermissionedUser returns (uint256 tokenId) {
    tokenId = _initialiseToken(tokenConfig, revenueRecipient);
  }

  /**
   * @dev See {IArtzoneCreator-initialiseNewMultipleToken}.
   */
  function initialiseNewMultipleTokens(
    TokenMetadataConfig[] calldata tokenConfigs,
    address[] calldata revenueRecipients
  ) external onlyPermissionedUser returns (uint256[] memory tokenIds) {
    uint256 length = tokenConfigs.length;
    tokenIds = new uint256[](length);

    for (uint256 i = 0; i < length; ) {
      uint256 tokenId = _initialiseToken(tokenConfigs[i], revenueRecipients[i]);
      tokenIds[i] = tokenId;
      unchecked {
        i++;
      }
    }
  }

  /**
   * @dev Internal function to initialise a token via all the parameters of `TokenMetadataConfig` specified alongside with the `revenueRecipient` for mint fee collection.
   */
  function _initialiseToken(TokenMetadataConfig calldata tokenConfig, address revenueRecipient)
    internal
    returns (uint256 tokenId)
  {
    require(tokenConfig.totalSupply == 0, "Initial total supply should be 0");
    require(tokenConfig.maxSupply > 0, "Invalid amount");
    require(tokenConfig.maxClaimPerUser > 0, "Invalid max claim quantity");
    require(
      tokenConfig.maxClaimPerUser <= tokenConfig.maxSupply,
      "Invalid individual claim quantity"
    );

    tokenId = ++_tokenCount;

    _tokenMetadata[tokenId] = tokenConfig;
    _tokenRevenueRecipient[tokenId] = revenueRecipient;

    emit TokenInitialised(
      tokenId,
      tokenConfig.maxSupply,
      tokenConfig.price,
      tokenConfig.maxClaimPerUser,
      tokenConfig.uri,
      revenueRecipient
    );
  }

  /**
   * @dev See {IArtzoneCreator-mintExistingSingleToken}.
   */
  function mintExistingSingleToken(
    address receiver,
    uint256 tokenId,
    uint256 amount
  ) external payable {
    require(amount > 0, "Invalid amount");
    if (!isPermissionedUser(msg.sender) && _tokenMetadata[tokenId].price > 0) {
      uint256 totalPayableAmount = _tokenMetadata[tokenId].price * amount;
      require(msg.value == totalPayableAmount, "Unmatched value sent");
      _processMintFees(tokenId, totalPayableAmount);
    }
    _mintExistingToken(tokenId, receiver, amount);
  }

  /**
   * @dev See {IArtzoneCreator-mintExistingMultipleToken}.
   */
  function mintExistingMultipleTokens(
    address[] calldata receivers,
    uint256[] calldata tokenIds,
    uint256[] calldata amounts
  ) external payable {
    require(
      receivers.length == tokenIds.length && tokenIds.length == amounts.length,
      "Invalid inputs"
    );
    uint256 length = receivers.length;

    if (!isPermissionedUser(msg.sender)) {
      uint256 totalPayableAmount;
      uint256[] memory payableAmounts = new uint256[](length);
      for (uint256 i = 0; i < length; ) {
        uint256 payableAmount = _tokenMetadata[tokenIds[i]].price * amounts[i];
        totalPayableAmount += payableAmount;
        payableAmounts[i] = payableAmount;
        unchecked {
          i++;
        }
      }
      require(msg.value == totalPayableAmount, "Unmatched value sent");
      _batchProcessMintFees(tokenIds, payableAmounts);
    }

    for (uint256 i = 0; i < length; ) {
      require(amounts[i] > 0, "Invalid amount");
      _mintExistingToken(tokenIds[i], receivers[i], amounts[i]);
      unchecked {
        i++;
      }
    }
  }

  /**
   * @dev Internal function to process minting of a valid `tokenId` with the specified `amount` and `receiver`.
   */
  function _mintExistingToken(
    uint256 tokenId,
    address receiver,
    uint256 amount
  ) internal nonReentrant checkTokenClaimable(tokenId, msg.sender) {
    require(tokenId <= _tokenCount, "Invalid tokenId specified");
    require(
      _tokenMetadata[tokenId].totalSupply + amount <= _tokenMetadata[tokenId].maxSupply,
      "Invalid amount specified"
    );
    require(
      _userTokenClaimCount[tokenId][receiver] + amount <= _tokenMetadata[tokenId].maxClaimPerUser,
      "Exceed token max claim limit"
    );

    _tokenMetadata[tokenId].totalSupply += amount;
    _userTokenClaimCount[tokenId][receiver] += amount;
    _mint(receiver, tokenId, amount, "");

    emit TokenMint(tokenId, amount, receiver, msg.sender, _tokenMetadata[tokenId].price * amount);
  }

  /**
   * @dev Internal function to handle multiple processing of mint fees when `mintExistingMultipleTokens` is called via a non-permissioned user.
   */
  function _batchProcessMintFees(uint256[] calldata tokenIds, uint256[] memory payableAmounts)
    internal
  {
    for (uint256 i = 0; i < tokenIds.length; ) {
      if (payableAmounts[i] > 0) {
        _processMintFees(tokenIds[i], payableAmounts[i]);
      }
      unchecked {
        i++;
      }
    }
  }

  /**
   * @dev Internal function to process mint fees and transfer outstanding payable revenue to `revenueRecipient` after deducting from Artzone's fee cut portion.
   */
  function _processMintFees(uint256 tokenId, uint256 totalPayableAmount) internal nonReentrant {
    uint256 artzoneFee = (totalPayableAmount * ARTZONE_MINTER_FEE_BPS) / MAX_BPS;
    payable(_tokenRevenueRecipient[tokenId]).transfer(totalPayableAmount - artzoneFee);
  }

  /**
   * @dev Set token uri after a token is minted by permissioned user.
   */
  function updateTokenURI(uint256 tokenId, string calldata uri)
    external
    override(ERC1155CreatorBase, IERC1155CreatorBase)
    onlyPermissionedUser
  {
    _setTokenURI(tokenId, uri);
  }

  /**
   * @dev Set token uri after a token is minted by permissioned user.
   */
  function updateTokenClaimStatus(uint256 tokenId, TokenClaimType claimStatus)
    external
    override(ERC1155CreatorBase, IERC1155CreatorBase)
    onlyPermissionedUser
  {
    _setTokenClaimStatus(tokenId, claimStatus);
  }

  /**
   * @dev Set secondary royalties for a particular tokenId by permissioned user.
   */
  function setRoyalties(
    uint256 tokenId,
    address payable[] calldata receivers,
    uint256[] calldata basisPoints
  ) external override(ERC1155CreatorBase, IERC1155CreatorBase) onlyPermissionedUser {
    _setRoyalties(tokenId, receivers, basisPoints);
  }

  /**
   * @dev See {IArtzoneCreator-updateTokenRevenueRecipient}.
   */
  function updateTokenRevenueRecipient(uint256 tokenId, address newRecipient)
    external
    isExistingToken(tokenId)
    onlyPermissionedUser
  {
    require(newRecipient != address(0), "Null address");
    _tokenRevenueRecipient[tokenId] = newRecipient;

    emit TokenRevenueRecipientUpdate(tokenId, newRecipient);
  }

  /**
   * @dev See {IArtzoneCreator-updateArtzoneFeeBps}.
   */
  function updateArtzoneFeeBps(uint256 bps) external onlyPermissionedUser {
    require(bps < MAX_BPS, "Invalid basis points");
    ARTZONE_MINTER_FEE_BPS = bps;
  }

   /**
   * @dev See {IArtzoneCreator-updateArtzoneFeeBps}.
   */
   function tokenAmountClaimedByUser(uint256 tokenId, address recipient) external view returns (uint256) {
      return _userTokenClaimCount[tokenId][recipient];
   }

  /**
   * @dev See {IERC165-supportsInterface}.
   */
  function supportsInterface(bytes4 interfaceId)
    public
    view
    virtual
    override(ERC1155CreatorBase, PermissionControl, IERC165)
    returns (bool)
  {
    return
      ERC1155CreatorBase.supportsInterface(interfaceId) ||
      PermissionControl.supportsInterface(interfaceId);
  }

  /**
   * @dev See {IArtzoneCreator-withdraw}.
   */
  function withdraw(address recipient) external payable onlyOwner {
    payable(recipient).transfer(address(this).balance);
  }

  /// @dev Lets the contract receives native tokens from `nativeTokenWrapper` withdraw.
  receive() external payable {}
}
// SPDX-License-Identifier: MIT

pragma solidity ^0.8.11;

import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "@openzeppelin/contracts/utils/introspection/ERC165Checker.sol";
import "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";

import "./ERC1155Core.sol";
import "./IERC1155CreatorBase.sol";

/**
 * @dev Implementation of the basic standard multi-token.
 * See https://eips.ethereum.org/EIPS/eip-1155
 * Originally based on code by Enjin: https://github.com/enjin/erc-1155
 *
 * _Available since v3.1._
 */
abstract contract ERC1155CreatorBase is ERC1155Core, IERC1155CreatorBase, ReentrancyGuard {
  using Strings for uint256;

  uint256 internal _tokenCount = 0;

  mapping(uint256 => TokenMetadataConfig) internal _tokenMetadata;
  // mapping(uint256 => uint256) internal _tokenSupply;
  // // Mapping for individual token URIs
  // mapping(uint256 => string) internal _tokenURIs;
  // mapping(uint256 => RoyaltyConfig[]) internal _tokenRoyalty;

  bytes4 private constant ERC1155_CREATORBASE_V1 = 0x28f10a21;

  /**
   * External interface identifiers for royalties
   */

  /**
   *  @dev CreatorCore
   *
   *  bytes4(keccak256('getRoyalties(uint256)')) == 0xbb3bafd6
   *
   *  => 0xbb3bafd6 = 0xbb3bafd6
   */
  bytes4 private constant INTERFACE_ID_ROYALTIES_CREATORBASE = 0xbb3bafd6;

  /**
   *  @dev Rarible: RoyaltiesV1
   *
   *  bytes4(keccak256('getFeeRecipients(uint256)')) == 0xb9c4d9fb
   *  bytes4(keccak256('getFeeBps(uint256)')) == 0x0ebd4c7f
   *
   *  => 0xb9c4d9fb ^ 0x0ebd4c7f = 0xb7799584
   */
  bytes4 private constant INTERFACE_ID_ROYALTIES_RARIBLE = 0xb7799584;

  /**
   *  @dev Foundation
   *
   *  bytes4(keccak256('getFees(uint256)')) == 0xd5a06d4c
   *
   *  => 0xd5a06d4c = 0xd5a06d4c
   */
  bytes4 private constant INTERFACE_ID_ROYALTIES_FOUNDATION = 0xd5a06d4c;

  /**
   *  @dev EIP-2981
   *
   * bytes4(keccak256("royaltyInfo(uint256,uint256)")) == 0x2a55205a
   *
   * => 0x2a55205a = 0x2a55205a
   */
  bytes4 private constant INTERFACE_ID_ROYALTIES_EIP2981 = 0x2a55205a;

  modifier isExistingToken(uint256 tokenId) {
    require(tokenId > 0 && tokenId <= _tokenCount, "Invalid token");
    _;
  }

  /**
   * @dev Initializes the contract by setting a `name` and a `symbol` to the token collection.
   */
  constructor(string memory name_, string memory symbol_) {
    _name = name_;
    _symbol = symbol_;
  }

  /**
   * @dev See {IERC165-supportsInterface}.
   */
  function supportsInterface(bytes4 interfaceId)
    public
    view
    virtual
    override(ERC1155Core, IERC165)
    returns (bool)
  {
    return
      interfaceId == type(IERC1155CreatorBase).interfaceId ||
      interfaceId == ERC1155_CREATORBASE_V1 ||
      super.supportsInterface(interfaceId) ||
      interfaceId == INTERFACE_ID_ROYALTIES_CREATORBASE ||
      interfaceId == INTERFACE_ID_ROYALTIES_RARIBLE ||
      interfaceId == INTERFACE_ID_ROYALTIES_FOUNDATION ||
      interfaceId == INTERFACE_ID_ROYALTIES_EIP2981;
  }

  /**
   * @dev See {IERC1155CreatorBase-updateTokenURI}.
   */
  function updateTokenURI(uint256 tokenId, string calldata uri) external virtual {
    _setTokenURI(tokenId, uri);
  }

  /**
   * @dev See {IERC1155CreatorBase-updateTokenClaimStatus}.
   */
  function updateTokenClaimStatus(uint256 tokenId, TokenClaimType claimStatus) external virtual {
    _setTokenClaimStatus(tokenId, claimStatus);
  }

  /**
   * @dev See {IERC1155CreatorBase-updateTokenURI}.
   */
  function setRoyalties(
    uint256 tokenId,
    address payable[] calldata receivers,
    uint256[] calldata basisPoints
  ) external virtual {
    _setRoyalties(tokenId, receivers, basisPoints);
  }

  /**
   * @dev Set token uri for an existing tokenId.
   */
  function _setTokenURI(uint256 tokenId, string calldata uri)
    internal
    virtual
    isExistingToken(tokenId)
  {
    _tokenMetadata[tokenId].uri = uri;
  }

  /**
   * @dev Set new public mint price for an existing tokenId.
   */
  function _setTokenMintPrice(uint256 tokenId, uint256 newPrice)
    internal
    virtual
    isExistingToken(tokenId)
  {
    _tokenMetadata[tokenId].price = newPrice;
  }

  /**
   * @dev Set claim status for an existing tokenId.
   */
  function _setTokenClaimStatus(uint256 tokenId, TokenClaimType claimStatus)
    internal
    virtual
    isExistingToken(tokenId)
  {
    _tokenMetadata[tokenId].claimStatus = claimStatus;

    emit TokenClaimStatusUpdate(tokenId, claimStatus);
  }

  /**
   * @dev See {IERC1155MetadataURI-uri}.
   */
  function uri(uint256 id) external view returns (string memory tokenURI) {
    tokenURI = _tokenURI(id);
  }

  /**
   * @dev See {IERC1155CreatorBase-totalSupply}.
   */
  function totalSupply(uint256 tokenId)
    external
    view
    isExistingToken(tokenId)
    returns (uint256 totalSupply)
  {
    totalSupply = _tokenMetadata[tokenId].totalSupply;
  }

  /**
   * @dev See {IERC1155CreatorBase-maxSupply}.
   */
  function maxSupply(uint256 tokenId)
    external
    view
    isExistingToken(tokenId)
    returns (uint256 maxSupply)
  {
    maxSupply = _tokenMetadata[tokenId].maxSupply;
  }

  /**
   * @dev See {IERC1155CreatorBase-publicMintPrice}.
   */
  function publicMintPrice(uint256 tokenId)
    external
    view
    isExistingToken(tokenId)
    returns (uint256 mintPrice)
  {
    mintPrice = _tokenMetadata[tokenId].price;
  }

  /**
   * @dev See {IERC1155CreatorBase-publicMintPrice}.
   */
  function updateTokenMintPrice(uint256 tokenId, uint256 newPrice) external {
    _tokenMetadata[tokenId].price = newPrice;
  }

  /**
   * @dev See {IERC1155CreatorBase-tokenMetadata}.
   */
  function tokenMetadata(uint256 tokenId)
    external
    view
    isExistingToken(tokenId)
    returns (
      uint256 totalSupply,
      uint256 maxSupply,
      uint256 mintPrice,
      uint256 maxClaimPerUser,
      string memory uri,
      TokenClaimType claimStatus
    )
  {
    TokenMetadataConfig memory tokenMetadata = _tokenMetadata[tokenId];
    totalSupply = tokenMetadata.totalSupply;
    maxSupply = tokenMetadata.maxSupply;
    mintPrice = tokenMetadata.price;
    maxClaimPerUser = tokenMetadata.maxClaimPerUser;
    uri = tokenMetadata.uri;
    claimStatus = tokenMetadata.claimStatus;
  }

  /**
   * @dev Retrieve an existing token's URI
   */
  function _tokenURI(uint256 tokenId)
    internal
    view
    isExistingToken(tokenId)
    returns (string memory uri)
  {
    uri = _tokenMetadata[tokenId].uri;
  }

  /**
   * @dev See {ICreatorCore-getRoyalties}.
   */
  function getRoyalties(uint256 tokenId)
    external
    view
    virtual
    override
    returns (address payable[] memory, uint256[] memory)
  {
    return _getRoyalties(tokenId);
  }

  /**
   * @dev See {ICreatorCore-getFees}.
   */
  function getFees(uint256 tokenId)
    external
    view
    virtual
    override
    returns (address payable[] memory, uint256[] memory)
  {
    return _getRoyalties(tokenId);
  }

  /**
   * @dev See {ICreatorCore-getFeeRecipients}.
   */
  function getFeeRecipients(uint256 tokenId)
    external
    view
    virtual
    override
    returns (address payable[] memory)
  {
    return _getRoyaltyReceivers(tokenId);
  }

  /**
   * @dev See {ICreatorCore-getFeeBps}.
   */
  function getFeeBps(uint256 tokenId) external view virtual override returns (uint256[] memory) {
    return _getRoyaltyBPS(tokenId);
  }

  /**
   * @dev See {ICreatorCore-royaltyInfo}.
   */
  function royaltyInfo(uint256 tokenId, uint256 value)
    external
    view
    virtual
    override
    returns (address, uint256)
  {
    return _getRoyaltyInfo(tokenId, value);
  }

  /**
   * Helper to get royalties for a token
   */
  function _getRoyalties(uint256 tokenId)
    internal
    view
    isExistingToken(tokenId)
    returns (address payable[] memory receivers, uint256[] memory bps)
  {
    RoyaltyConfig[] memory royalties = _tokenMetadata[tokenId].royalties;

    if (royalties.length == 0) {
      receivers = new address payable[](1);
      receivers[0] = payable(address(0));
      bps = new uint256[](1);
      bps[0] = 0;
    }

    if (royalties.length > 0) {
      receivers = new address payable[](royalties.length);
      bps = new uint256[](royalties.length);
      for (uint256 i; i < royalties.length; ) {
        receivers[i] = royalties[i].receiver;
        bps[i] = royalties[i].bps;
        unchecked {
          ++i;
        }
      }
    }
  }

  /**
   * Helper to get royalty receivers for a token
   */
  function _getRoyaltyReceivers(uint256 tokenId)
    internal
    view
    returns (address payable[] memory recievers)
  {
    (recievers, ) = _getRoyalties(tokenId);
  }

  /**
   * Helper to get royalty basis points for a token
   */
  function _getRoyaltyBPS(uint256 tokenId) internal view returns (uint256[] memory bps) {
    (, bps) = _getRoyalties(tokenId);
  }

  function _getRoyaltyInfo(uint256 tokenId, uint256 value)
    internal
    view
    returns (address receiver, uint256 amount)
  {
    (address payable[] memory receivers, uint256[] memory bps) = _getRoyalties(tokenId);
    require(receivers.length <= 1, "More than 1 royalty receiver");

    if (receivers.length == 0) {
      return (address(this), 0);
    }
    return (receivers[0], (bps[0] * value) / 10000);
  }

  /**
   * Set royalties for a token
   */
  function _setRoyalties(
    uint256 tokenId,
    address payable[] calldata receivers,
    uint256[] calldata basisPoints
  ) internal {
    _checkRoyalties(receivers, basisPoints);
    delete _tokenMetadata[tokenId].royalties;
    _setRoyalties(receivers, basisPoints, _tokenMetadata[tokenId].royalties);
    emit RoyaltiesUpdated(tokenId, receivers, basisPoints);
  }

  /**
   * Helper function to set royalties
   */
  function _setRoyalties(
    address payable[] calldata receivers,
    uint256[] calldata basisPoints,
    RoyaltyConfig[] storage royalties
  ) private {
    for (uint256 i; i < basisPoints.length; ) {
      royalties.push(RoyaltyConfig({receiver: receivers[i], bps: uint16(basisPoints[i])}));
      unchecked {
        ++i;
      }
    }
  }

  /**
   * Helper function to check that royalties provided are valid
   */
  function _checkRoyalties(address payable[] calldata receivers, uint256[] calldata basisPoints)
    private
    pure
  {
    require(receivers.length == basisPoints.length, "Invalid receivers & bps input");

    uint256 totalBasisPoints;
    for (uint256 i; i < basisPoints.length; ) {
      totalBasisPoints += basisPoints[i];
      unchecked {
        ++i;
      }
    }
    require(totalBasisPoints < 10000, "Invalid total royalties");
  }
}
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.11;

import "../ERC1155/IERC1155CreatorBase.sol";

interface IArtzoneCreator is IERC1155CreatorBase {
  /**
   * @dev Event when a Token parameters are initialised.
   */
  event TokenInitialised(
    uint256 indexed tokenId,
    uint256 maxSupply,
    uint256 price,
    uint256 maxClaimPerUser,
    string tokenUri,
    address revenueRecipient
  );

  /**
   * @dev Event when an Initialised Token has been minted.
   */
  event TokenMint(
    uint256 indexed tokenId,
    uint256 amount,
    address receiver,
    address minter,
    uint256 value
  );

  /**
   * @dev Event when a revenue recipient of an initialised token has been updated.
   */
  event TokenRevenueRecipientUpdate(uint256 indexed tokenId, address revenueRecipient);


  /**
   * @dev Set the parameters for a tokenId - tokenUri and maximum amount to be minted. Returns tokenId assigned. Can only be called by Admin.
   */
  function initialiseNewSingleToken(
    TokenMetadataConfig calldata tokenConfig,
    address revenueRecipient
  ) external returns (uint256);

  /**
   * @dev Set the parameters for multiple tokenIds - tokenUri and maximum amount to be minted.  Can only be called by owner/admin. Returns array of tokenIds assigned.
   */
  function initialiseNewMultipleTokens(
    TokenMetadataConfig[] calldata tokenConfigs,
    address[] calldata revenueRecipients
  ) external returns (uint256[] memory);

  /**
   * @dev Mints existing single token.  Can be called by any user. Returns tokenId assigned.
   */
  function mintExistingSingleToken(
    address receiver,
    uint256 tokenId,
    uint256 amount
  ) external payable;

  /**
   * @dev Mints multiple tokens.  Can be called by any user. Returns tokenId assigned.
   */
  function mintExistingMultipleTokens(
    address[] calldata receivers,
    uint256[] calldata tokenIds,
    uint256[] calldata amounts
  ) external payable;

  /**
   * @dev Returns the total quantity claimed by a user for a token.
   */
  function tokenAmountClaimedByUser(uint256 tokenId, address recipient) external view returns(uint256);

  /**
   * @dev Update revenue recipient for an initialised token. Can only be called by Admin.
   */
  function updateTokenRevenueRecipient(uint256 tokenId, address newRecipient) external;

  /**
   * @dev Update Artzone Minter fee basis points for NFT minting sale. Can only be called by Admin.
   */
  function updateArtzoneFeeBps(uint256 bps) external;

  /**
   * @dev Withdraw function to withdraw fees collected from each paid NFT mint by public users to a specified recipient. To only be called by Admin.
   */
  function withdraw(address recipient) external payable;
}
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.11;

import "@openzeppelin/contracts/utils/introspection/ERC165.sol";
import "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";
import "../BoringOwnable.sol";
import "./IPermissionControl.sol";

abstract contract PermissionControl is IPermissionControl, BoringOwnable, ERC165 {
  using EnumerableSet for EnumerableSet.AddressSet;

  EnumerableSet.AddressSet private _permissionedUsers;

  /**
   * @dev Only allows approved admins or owner to call the specified function
   */
  modifier onlyPermissionedUser() {
    require(
      owner == msg.sender || _permissionedUsers.contains(msg.sender),
      "PermissionControl: Only owner or existing admin allowed."
    );
    _;
  }

  /**
   * @dev See {IERC165-supportsInterface}.
   */
  function supportsInterface(bytes4 interfaceId)
    public
    view
    virtual
    override(ERC165, IERC165)
    returns (bool)
  {
    return
      interfaceId == type(IPermissionControl).interfaceId || super.supportsInterface(interfaceId);
  }

  /**
   * @dev See {IAdminControl-getAdmins}.
   */
  function getAllPermissionedUsers()
    external
    view
    override
    returns (address[] memory permissionedUsers)
  {
    permissionedUsers = new address[](_permissionedUsers.length());
    for (uint256 i = 0; i < _permissionedUsers.length(); i++) {
      permissionedUsers[i] = _permissionedUsers.at(i);
    }
  }

  /**
   * @dev See {IPernissionControl-grantPermissionToUser}.
   */
  function grantPermissionToUser(address newAdmin) external override onlyOwner {
    if (!_permissionedUsers.contains(newAdmin)) {
      emit PermissionGranted(newAdmin, msg.sender);
      _permissionedUsers.add(newAdmin);
    }
  }

  /**
   * @dev See {IPernissionControl-revokePermission}.
   */
  function revokePermission(address newAdmin) external override onlyOwner {
    if (_permissionedUsers.contains(newAdmin)) {
      emit PermissionRevoked(newAdmin, msg.sender);
      _permissionedUsers.remove(newAdmin);
    }
  }

  /**
   * @dev See {IAdminControl-isAdmin}.
   */
  function isPermissionedUser(address user) public view override returns (bool) {
    return (owner == user || _permissionedUsers.contains(user));
  }
}
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (security/ReentrancyGuard.sol)

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
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/Strings.sol)

pragma solidity ^0.8.0;

/**
 * @dev String operations.
 */
library Strings {
    bytes16 private constant _HEX_SYMBOLS = "0123456789abcdef";

    /**
     * @dev Converts a `uint256` to its ASCII `string` decimal representation.
     */
    function toString(uint256 value) internal pure returns (string memory) {
        // Inspired by OraclizeAPI's implementation - MIT licence
        // https://github.com/oraclize/ethereum-api/blob/b42146b063c7d6ee1358846c198246239e9360e8/oraclizeAPI_0.4.25.sol

        if (value == 0) {
            return "0";
        }
        uint256 temp = value;
        uint256 digits;
        while (temp != 0) {
            digits++;
            temp /= 10;
        }
        bytes memory buffer = new bytes(digits);
        while (value != 0) {
            digits -= 1;
            buffer[digits] = bytes1(uint8(48 + uint256(value % 10)));
            value /= 10;
        }
        return string(buffer);
    }

    /**
     * @dev Converts a `uint256` to its ASCII `string` hexadecimal representation.
     */
    function toHexString(uint256 value) internal pure returns (string memory) {
        if (value == 0) {
            return "0x00";
        }
        uint256 temp = value;
        uint256 length = 0;
        while (temp != 0) {
            length++;
            temp >>= 8;
        }
        return toHexString(value, length);
    }

    /**
     * @dev Converts a `uint256` to its ASCII `string` hexadecimal representation with fixed length.
     */
    function toHexString(uint256 value, uint256 length) internal pure returns (string memory) {
        bytes memory buffer = new bytes(2 * length + 2);
        buffer[0] = "0";
        buffer[1] = "x";
        for (uint256 i = 2 * length + 1; i > 1; --i) {
            buffer[i] = _HEX_SYMBOLS[value & 0xf];
            value >>= 4;
        }
        require(value == 0, "Strings: hex length insufficient");
        return string(buffer);
    }
}
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/introspection/ERC165Checker.sol)

pragma solidity ^0.8.0;

import "./IERC165.sol";

/**
 * @dev Library used to query support of an interface declared via {IERC165}.
 *
 * Note that these functions return the actual result of the query: they do not
 * `revert` if an interface is not supported. It is up to the caller to decide
 * what to do in these cases.
 */
library ERC165Checker {
    // As per the EIP-165 spec, no interface should ever match 0xffffffff
    bytes4 private constant _INTERFACE_ID_INVALID = 0xffffffff;

    /**
     * @dev Returns true if `account` supports the {IERC165} interface,
     */
    function supportsERC165(address account) internal view returns (bool) {
        // Any contract that implements ERC165 must explicitly indicate support of
        // InterfaceId_ERC165 and explicitly indicate non-support of InterfaceId_Invalid
        return
            _supportsERC165Interface(account, type(IERC165).interfaceId) &&
            !_supportsERC165Interface(account, _INTERFACE_ID_INVALID);
    }

    /**
     * @dev Returns true if `account` supports the interface defined by
     * `interfaceId`. Support for {IERC165} itself is queried automatically.
     *
     * See {IERC165-supportsInterface}.
     */
    function supportsInterface(address account, bytes4 interfaceId) internal view returns (bool) {
        // query support of both ERC165 as per the spec and support of _interfaceId
        return supportsERC165(account) && _supportsERC165Interface(account, interfaceId);
    }

    /**
     * @dev Returns a boolean array where each value corresponds to the
     * interfaces passed in and whether they're supported or not. This allows
     * you to batch check interfaces for a contract where your expectation
     * is that some interfaces may not be supported.
     *
     * See {IERC165-supportsInterface}.
     *
     * _Available since v3.4._
     */
    function getSupportedInterfaces(address account, bytes4[] memory interfaceIds)
        internal
        view
        returns (bool[] memory)
    {
        // an array of booleans corresponding to interfaceIds and whether they're supported or not
        bool[] memory interfaceIdsSupported = new bool[](interfaceIds.length);

        // query support of ERC165 itself
        if (supportsERC165(account)) {
            // query support of each interface in interfaceIds
            for (uint256 i = 0; i < interfaceIds.length; i++) {
                interfaceIdsSupported[i] = _supportsERC165Interface(account, interfaceIds[i]);
            }
        }

        return interfaceIdsSupported;
    }

    /**
     * @dev Returns true if `account` supports all the interfaces defined in
     * `interfaceIds`. Support for {IERC165} itself is queried automatically.
     *
     * Batch-querying can lead to gas savings by skipping repeated checks for
     * {IERC165} support.
     *
     * See {IERC165-supportsInterface}.
     */
    function supportsAllInterfaces(address account, bytes4[] memory interfaceIds) internal view returns (bool) {
        // query support of ERC165 itself
        if (!supportsERC165(account)) {
            return false;
        }

        // query support of each interface in _interfaceIds
        for (uint256 i = 0; i < interfaceIds.length; i++) {
            if (!_supportsERC165Interface(account, interfaceIds[i])) {
                return false;
            }
        }

        // all interfaces supported
        return true;
    }

    /**
     * @notice Query if a contract implements an interface, does not check ERC165 support
     * @param account The address of the contract to query for support of an interface
     * @param interfaceId The interface identifier, as specified in ERC-165
     * @return true if the contract at account indicates support of the interface with
     * identifier interfaceId, false otherwise
     * @dev Assumes that account contains a contract that supports ERC165, otherwise
     * the behavior of this method is undefined. This precondition can be checked
     * with {supportsERC165}.
     * Interface identification is specified in ERC-165.
     */
    function _supportsERC165Interface(address account, bytes4 interfaceId) private view returns (bool) {
        bytes memory encodedParams = abi.encodeWithSelector(IERC165.supportsInterface.selector, interfaceId);
        (bool success, bytes memory result) = account.staticcall{gas: 30000}(encodedParams);
        if (result.length < 32) return false;
        return success && abi.decode(result, (bool));
    }
}
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.6.0) (utils/structs/EnumerableSet.sol)

pragma solidity ^0.8.0;

/**
 * @dev Library for managing
 * https://en.wikipedia.org/wiki/Set_(abstract_data_type)[sets] of primitive
 * types.
 *
 * Sets have the following properties:
 *
 * - Elements are added, removed, and checked for existence in constant time
 * (O(1)).
 * - Elements are enumerated in O(n). No guarantees are made on the ordering.
 *
 * ```
 * contract Example {
 *     // Add the library methods
 *     using EnumerableSet for EnumerableSet.AddressSet;
 *
 *     // Declare a set state variable
 *     EnumerableSet.AddressSet private mySet;
 * }
 * ```
 *
 * As of v3.3.0, sets of type `bytes32` (`Bytes32Set`), `address` (`AddressSet`)
 * and `uint256` (`UintSet`) are supported.
 */
library EnumerableSet {
    // To implement this library for multiple types with as little code
    // repetition as possible, we write it in terms of a generic Set type with
    // bytes32 values.
    // The Set implementation uses private functions, and user-facing
    // implementations (such as AddressSet) are just wrappers around the
    // underlying Set.
    // This means that we can only create new EnumerableSets for types that fit
    // in bytes32.

    struct Set {
        // Storage of set values
        bytes32[] _values;
        // Position of the value in the `values` array, plus 1 because index 0
        // means a value is not in the set.
        mapping(bytes32 => uint256) _indexes;
    }

    /**
     * @dev Add a value to a set. O(1).
     *
     * Returns true if the value was added to the set, that is if it was not
     * already present.
     */
    function _add(Set storage set, bytes32 value) private returns (bool) {
        if (!_contains(set, value)) {
            set._values.push(value);
            // The value is stored at length-1, but we add 1 to all indexes
            // and use 0 as a sentinel value
            set._indexes[value] = set._values.length;
            return true;
        } else {
            return false;
        }
    }

    /**
     * @dev Removes a value from a set. O(1).
     *
     * Returns true if the value was removed from the set, that is if it was
     * present.
     */
    function _remove(Set storage set, bytes32 value) private returns (bool) {
        // We read and store the value's index to prevent multiple reads from the same storage slot
        uint256 valueIndex = set._indexes[value];

        if (valueIndex != 0) {
            // Equivalent to contains(set, value)
            // To delete an element from the _values array in O(1), we swap the element to delete with the last one in
            // the array, and then remove the last element (sometimes called as 'swap and pop').
            // This modifies the order of the array, as noted in {at}.

            uint256 toDeleteIndex = valueIndex - 1;
            uint256 lastIndex = set._values.length - 1;

            if (lastIndex != toDeleteIndex) {
                bytes32 lastValue = set._values[lastIndex];

                // Move the last value to the index where the value to delete is
                set._values[toDeleteIndex] = lastValue;
                // Update the index for the moved value
                set._indexes[lastValue] = valueIndex; // Replace lastValue's index to valueIndex
            }

            // Delete the slot where the moved value was stored
            set._values.pop();

            // Delete the index for the deleted slot
            delete set._indexes[value];

            return true;
        } else {
            return false;
        }
    }

    /**
     * @dev Returns true if the value is in the set. O(1).
     */
    function _contains(Set storage set, bytes32 value) private view returns (bool) {
        return set._indexes[value] != 0;
    }

    /**
     * @dev Returns the number of values on the set. O(1).
     */
    function _length(Set storage set) private view returns (uint256) {
        return set._values.length;
    }

    /**
     * @dev Returns the value stored at position `index` in the set. O(1).
     *
     * Note that there are no guarantees on the ordering of values inside the
     * array, and it may change when more values are added or removed.
     *
     * Requirements:
     *
     * - `index` must be strictly less than {length}.
     */
    function _at(Set storage set, uint256 index) private view returns (bytes32) {
        return set._values[index];
    }

    /**
     * @dev Return the entire set in an array
     *
     * WARNING: This operation will copy the entire storage to memory, which can be quite expensive. This is designed
     * to mostly be used by view accessors that are queried without any gas fees. Developers should keep in mind that
     * this function has an unbounded cost, and using it as part of a state-changing function may render the function
     * uncallable if the set grows to a point where copying to memory consumes too much gas to fit in a block.
     */
    function _values(Set storage set) private view returns (bytes32[] memory) {
        return set._values;
    }

    // Bytes32Set

    struct Bytes32Set {
        Set _inner;
    }

    /**
     * @dev Add a value to a set. O(1).
     *
     * Returns true if the value was added to the set, that is if it was not
     * already present.
     */
    function add(Bytes32Set storage set, bytes32 value) internal returns (bool) {
        return _add(set._inner, value);
    }

    /**
     * @dev Removes a value from a set. O(1).
     *
     * Returns true if the value was removed from the set, that is if it was
     * present.
     */
    function remove(Bytes32Set storage set, bytes32 value) internal returns (bool) {
        return _remove(set._inner, value);
    }

    /**
     * @dev Returns true if the value is in the set. O(1).
     */
    function contains(Bytes32Set storage set, bytes32 value) internal view returns (bool) {
        return _contains(set._inner, value);
    }

    /**
     * @dev Returns the number of values in the set. O(1).
     */
    function length(Bytes32Set storage set) internal view returns (uint256) {
        return _length(set._inner);
    }

    /**
     * @dev Returns the value stored at position `index` in the set. O(1).
     *
     * Note that there are no guarantees on the ordering of values inside the
     * array, and it may change when more values are added or removed.
     *
     * Requirements:
     *
     * - `index` must be strictly less than {length}.
     */
    function at(Bytes32Set storage set, uint256 index) internal view returns (bytes32) {
        return _at(set._inner, index);
    }

    /**
     * @dev Return the entire set in an array
     *
     * WARNING: This operation will copy the entire storage to memory, which can be quite expensive. This is designed
     * to mostly be used by view accessors that are queried without any gas fees. Developers should keep in mind that
     * this function has an unbounded cost, and using it as part of a state-changing function may render the function
     * uncallable if the set grows to a point where copying to memory consumes too much gas to fit in a block.
     */
    function values(Bytes32Set storage set) internal view returns (bytes32[] memory) {
        return _values(set._inner);
    }

    // AddressSet

    struct AddressSet {
        Set _inner;
    }

    /**
     * @dev Add a value to a set. O(1).
     *
     * Returns true if the value was added to the set, that is if it was not
     * already present.
     */
    function add(AddressSet storage set, address value) internal returns (bool) {
        return _add(set._inner, bytes32(uint256(uint160(value))));
    }

    /**
     * @dev Removes a value from a set. O(1).
     *
     * Returns true if the value was removed from the set, that is if it was
     * present.
     */
    function remove(AddressSet storage set, address value) internal returns (bool) {
        return _remove(set._inner, bytes32(uint256(uint160(value))));
    }

    /**
     * @dev Returns true if the value is in the set. O(1).
     */
    function contains(AddressSet storage set, address value) internal view returns (bool) {
        return _contains(set._inner, bytes32(uint256(uint160(value))));
    }

    /**
     * @dev Returns the number of values in the set. O(1).
     */
    function length(AddressSet storage set) internal view returns (uint256) {
        return _length(set._inner);
    }

    /**
     * @dev Returns the value stored at position `index` in the set. O(1).
     *
     * Note that there are no guarantees on the ordering of values inside the
     * array, and it may change when more values are added or removed.
     *
     * Requirements:
     *
     * - `index` must be strictly less than {length}.
     */
    function at(AddressSet storage set, uint256 index) internal view returns (address) {
        return address(uint160(uint256(_at(set._inner, index))));
    }

    /**
     * @dev Return the entire set in an array
     *
     * WARNING: This operation will copy the entire storage to memory, which can be quite expensive. This is designed
     * to mostly be used by view accessors that are queried without any gas fees. Developers should keep in mind that
     * this function has an unbounded cost, and using it as part of a state-changing function may render the function
     * uncallable if the set grows to a point where copying to memory consumes too much gas to fit in a block.
     */
    function values(AddressSet storage set) internal view returns (address[] memory) {
        bytes32[] memory store = _values(set._inner);
        address[] memory result;

        assembly {
            result := store
        }

        return result;
    }

    // UintSet

    struct UintSet {
        Set _inner;
    }

    /**
     * @dev Add a value to a set. O(1).
     *
     * Returns true if the value was added to the set, that is if it was not
     * already present.
     */
    function add(UintSet storage set, uint256 value) internal returns (bool) {
        return _add(set._inner, bytes32(value));
    }

    /**
     * @dev Removes a value from a set. O(1).
     *
     * Returns true if the value was removed from the set, that is if it was
     * present.
     */
    function remove(UintSet storage set, uint256 value) internal returns (bool) {
        return _remove(set._inner, bytes32(value));
    }

    /**
     * @dev Returns true if the value is in the set. O(1).
     */
    function contains(UintSet storage set, uint256 value) internal view returns (bool) {
        return _contains(set._inner, bytes32(value));
    }

    /**
     * @dev Returns the number of values on the set. O(1).
     */
    function length(UintSet storage set) internal view returns (uint256) {
        return _length(set._inner);
    }

    /**
     * @dev Returns the value stored at position `index` in the set. O(1).
     *
     * Note that there are no guarantees on the ordering of values inside the
     * array, and it may change when more values are added or removed.
     *
     * Requirements:
     *
     * - `index` must be strictly less than {length}.
     */
    function at(UintSet storage set, uint256 index) internal view returns (uint256) {
        return uint256(_at(set._inner, index));
    }

    /**
     * @dev Return the entire set in an array
     *
     * WARNING: This operation will copy the entire storage to memory, which can be quite expensive. This is designed
     * to mostly be used by view accessors that are queried without any gas fees. Developers should keep in mind that
     * this function has an unbounded cost, and using it as part of a state-changing function may render the function
     * uncallable if the set grows to a point where copying to memory consumes too much gas to fit in a block.
     */
    function values(UintSet storage set) internal view returns (uint256[] memory) {
        bytes32[] memory store = _values(set._inner);
        uint256[] memory result;

        assembly {
            result := store
        }

        return result;
    }
}
// SPDX-License-Identifier: MIT

pragma solidity ^0.8.11;

import "@openzeppelin/contracts/token/ERC1155/IERC1155.sol";
import "@openzeppelin/contracts/token/ERC1155/IERC1155Receiver.sol";
import "@openzeppelin/contracts/token/ERC1155/extensions/IERC1155MetadataURI.sol";
import "@openzeppelin/contracts/utils/Address.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "@openzeppelin/contracts/utils/introspection/ERC165.sol";

/**
 * @dev Implementation of the basic standard multi-token.
 * See https://eips.ethereum.org/EIPS/eip-1155
 * Originally based on code by Enjin: https://github.com/enjin/erc-1155
 *
 * _Available since v3.1._
 */
abstract contract ERC1155Core is ERC165, IERC1155, IERC1155MetadataURI {
  using Address for address;

  // Token name
  string internal _name;

  // Token symbol
  string internal _symbol;

  // Mapping from token ID to account balances
  mapping(uint256 => mapping(address => uint256)) private _balances;

  // Mapping from account to operator approvals
  mapping(address => mapping(address => bool)) private _operatorApprovals;

  /**
   * @dev See {IERC165-supportsInterface}.
   */
  function supportsInterface(bytes4 interfaceId)
    public
    view
    virtual
    override(ERC165, IERC165)
    returns (bool)
  {
    return
      interfaceId == type(IERC1155).interfaceId ||
      interfaceId == type(IERC1155MetadataURI).interfaceId ||
      super.supportsInterface(interfaceId);
  }

  /**
   * @dev See {IERC1155-balanceOf}.
   *
   * Requirements:
   *
   * - `account` cannot be the zero address.
   */
  function balanceOf(address account, uint256 id) public view virtual override returns (uint256) {
    require(account != address(0), "ERC1155: address zero is not a valid owner");
    return _balances[id][account];
  }

  /**
   * @dev See {IERC1155-balanceOfBatch}.
   *
   * Requirements:
   *
   * - `accounts` and `ids` must have the same length.
   */
  function balanceOfBatch(address[] memory accounts, uint256[] memory ids)
    public
    view
    virtual
    override
    returns (uint256[] memory)
  {
    require(accounts.length == ids.length, "ERC1155: accounts and ids length mismatch");

    uint256[] memory batchBalances = new uint256[](accounts.length);

    for (uint256 i = 0; i < accounts.length; ++i) {
      batchBalances[i] = balanceOf(accounts[i], ids[i]);
    }

    return batchBalances;
  }

  function name() public view virtual returns (string memory) {
    return _name;
  }

  function symbol() public view virtual returns (string memory) {
    return _symbol;
  }

  /**
   * @dev See {IERC1155-setApprovalForAll}.
   */
  function setApprovalForAll(address operator, bool approved) public virtual override {
    _setApprovalForAll(msg.sender, operator, approved);
  }

  /**
   * @dev See {IERC1155-isApprovedForAll}.
   */
  function isApprovedForAll(address account, address operator)
    public
    view
    virtual
    override
    returns (bool)
  {
    return _operatorApprovals[account][operator];
  }

  /**
   * @dev See {IERC1155-safeTransferFrom}.
   */
  function safeTransferFrom(
    address from,
    address to,
    uint256 id,
    uint256 amount,
    bytes memory data
  ) public virtual override {
    require(
      from == msg.sender || isApprovedForAll(from, msg.sender),
      "ERC1155: caller is not token owner or approved"
    );
    _safeTransferFrom(from, to, id, amount, data);
  }

  /**
   * @dev See {IERC1155-safeBatchTransferFrom}.
   */
  function safeBatchTransferFrom(
    address from,
    address to,
    uint256[] memory ids,
    uint256[] memory amounts,
    bytes memory data
  ) public virtual override {
    require(
      from == msg.sender || isApprovedForAll(from, msg.sender),
      "ERC1155: caller is not token owner or approved"
    );
    _safeBatchTransferFrom(from, to, ids, amounts, data);
  }

  /**
   * @dev Transfers `amount` tokens of token type `id` from `from` to `to`.
   *
   * Emits a {TransferSingle} event.
   *
   * Requirements:
   *
   * - `to` cannot be the zero address.
   * - `from` must have a balance of tokens of type `id` of at least `amount`.
   * - If `to` refers to a smart contract, it must implement {IERC1155Receiver-onERC1155Received} and return the
   * acceptance magic value.
   */
  function _safeTransferFrom(
    address from,
    address to,
    uint256 id,
    uint256 amount,
    bytes memory data
  ) internal virtual {
    require(to != address(0), "ERC1155: transfer to the zero address");

    address operator = msg.sender;
    uint256[] memory ids = _asSingletonArray(id);
    uint256[] memory amounts = _asSingletonArray(amount);

    _beforeTokenTransfer(operator, from, to, ids, amounts, data);

    uint256 fromBalance = _balances[id][from];
    require(fromBalance >= amount, "ERC1155: insufficient balance for transfer");
    unchecked {
      _balances[id][from] = fromBalance - amount;
    }
    _balances[id][to] += amount;

    emit TransferSingle(operator, from, to, id, amount);

    _afterTokenTransfer(operator, from, to, ids, amounts, data);

    _doSafeTransferAcceptanceCheck(operator, from, to, id, amount, data);
  }

  /**
   * @dev xref:ROOT:erc1155.adoc#batch-operations[Batched] version of {_safeTransferFrom}.
   *
   * Emits a {TransferBatch} event.
   *
   * Requirements:
   *
   * - If `to` refers to a smart contract, it must implement {IERC1155Receiver-onERC1155BatchReceived} and return the
   * acceptance magic value.
   */
  function _safeBatchTransferFrom(
    address from,
    address to,
    uint256[] memory ids,
    uint256[] memory amounts,
    bytes memory data
  ) internal virtual {
    require(ids.length == amounts.length, "ERC1155: ids and amounts length mismatch");
    require(to != address(0), "ERC1155: transfer to the zero address");

    address operator = msg.sender;

    _beforeTokenTransfer(operator, from, to, ids, amounts, data);

    for (uint256 i = 0; i < ids.length; ++i) {
      uint256 id = ids[i];
      uint256 amount = amounts[i];

      uint256 fromBalance = _balances[id][from];
      require(fromBalance >= amount, "ERC1155: insufficient balance for transfer");
      unchecked {
        _balances[id][from] = fromBalance - amount;
      }
      _balances[id][to] += amount;
    }

    emit TransferBatch(operator, from, to, ids, amounts);

    _afterTokenTransfer(operator, from, to, ids, amounts, data);

    _doSafeBatchTransferAcceptanceCheck(operator, from, to, ids, amounts, data);
  }

  /**
   * @dev Creates `amount` tokens of token type `id`, and assigns them to `to`.
   *
   * Emits a {TransferSingle} event.
   *
   * Requirements:
   *
   * - `to` cannot be the zero address.
   * - If `to` refers to a smart contract, it must implement {IERC1155Receiver-onERC1155Received} and return the
   * acceptance magic value.
   */
  function _mint(
    address to,
    uint256 id,
    uint256 amount,
    bytes memory data
  ) internal virtual {
    require(to != address(0), "ERC1155: mint to the zero address");

    address operator = msg.sender;
    uint256[] memory ids = _asSingletonArray(id);
    uint256[] memory amounts = _asSingletonArray(amount);

    _beforeTokenTransfer(operator, address(0), to, ids, amounts, data);

    _balances[id][to] += amount;
    emit TransferSingle(operator, address(0), to, id, amount);

    _afterTokenTransfer(operator, address(0), to, ids, amounts, data);

    _doSafeTransferAcceptanceCheck(operator, address(0), to, id, amount, data);
  }

  /**
   * @dev xref:ROOT:erc1155.adoc#batch-operations[Batched] version of {_mint}.
   *
   * Emits a {TransferBatch} event.
   *
   * Requirements:
   *
   * - `ids` and `amounts` must have the same length.
   * - If `to` refers to a smart contract, it must implement {IERC1155Receiver-onERC1155BatchReceived} and return the
   * acceptance magic value.
   */
  function _mintBatch(
    address to,
    uint256[] memory ids,
    uint256[] memory amounts,
    bytes memory data
  ) internal virtual {
    require(to != address(0), "ERC1155: mint to the zero address");
    require(ids.length == amounts.length, "ERC1155: ids and amounts length mismatch");

    address operator = msg.sender;

    _beforeTokenTransfer(operator, address(0), to, ids, amounts, data);

    for (uint256 i = 0; i < ids.length; i++) {
      _balances[ids[i]][to] += amounts[i];
    }

    emit TransferBatch(operator, address(0), to, ids, amounts);

    _afterTokenTransfer(operator, address(0), to, ids, amounts, data);

    _doSafeBatchTransferAcceptanceCheck(operator, address(0), to, ids, amounts, data);
  }

  /**
   * @dev Destroys `amount` tokens of token type `id` from `from`
   *
   * Emits a {TransferSingle} event.
   *
   * Requirements:
   *
   * - `from` cannot be the zero address.
   * - `from` must have at least `amount` tokens of token type `id`.
   */
  function _burn(
    address from,
    uint256 id,
    uint256 amount
  ) internal virtual {
    require(from != address(0), "ERC1155: burn from the zero address");

    address operator = msg.sender;
    uint256[] memory ids = _asSingletonArray(id);
    uint256[] memory amounts = _asSingletonArray(amount);

    _beforeTokenTransfer(operator, from, address(0), ids, amounts, "");

    uint256 fromBalance = _balances[id][from];
    require(fromBalance >= amount, "ERC1155: burn amount exceeds balance");
    unchecked {
      _balances[id][from] = fromBalance - amount;
    }

    emit TransferSingle(operator, from, address(0), id, amount);

    _afterTokenTransfer(operator, from, address(0), ids, amounts, "");
  }

  /**
   * @dev xref:ROOT:erc1155.adoc#batch-operations[Batched] version of {_burn}.
   *
   * Emits a {TransferBatch} event.
   *
   * Requirements:
   *
   * - `ids` and `amounts` must have the same length.
   */
  function _burnBatch(
    address from,
    uint256[] memory ids,
    uint256[] memory amounts
  ) internal virtual {
    require(from != address(0), "ERC1155: burn from the zero address");
    require(ids.length == amounts.length, "ERC1155: ids and amounts length mismatch");

    address operator = msg.sender;

    _beforeTokenTransfer(operator, from, address(0), ids, amounts, "");

    for (uint256 i = 0; i < ids.length; i++) {
      uint256 id = ids[i];
      uint256 amount = amounts[i];

      uint256 fromBalance = _balances[id][from];
      require(fromBalance >= amount, "ERC1155: burn amount exceeds balance");
      unchecked {
        _balances[id][from] = fromBalance - amount;
      }
    }

    emit TransferBatch(operator, from, address(0), ids, amounts);

    _afterTokenTransfer(operator, from, address(0), ids, amounts, "");
  }

  /**
   * @dev Approve `operator` to operate on all of `owner` tokens
   *
   * Emits an {ApprovalForAll} event.
   */
  function _setApprovalForAll(
    address owner,
    address operator,
    bool approved
  ) internal virtual {
    require(owner != operator, "ERC1155: setting approval status for self");
    _operatorApprovals[owner][operator] = approved;
    emit ApprovalForAll(owner, operator, approved);
  }

  /**
   * @dev Hook that is called before any token transfer. This includes minting
   * and burning, as well as batched variants.
   *
   * The same hook is called on both single and batched variants. For single
   * transfers, the length of the `ids` and `amounts` arrays will be 1.
   *
   * Calling conditions (for each `id` and `amount` pair):
   *
   * - When `from` and `to` are both non-zero, `amount` of ``from``'s tokens
   * of token type `id` will be  transferred to `to`.
   * - When `from` is zero, `amount` tokens of token type `id` will be minted
   * for `to`.
   * - when `to` is zero, `amount` of ``from``'s tokens of token type `id`
   * will be burned.
   * - `from` and `to` are never both zero.
   * - `ids` and `amounts` have the same, non-zero length.
   *
   * To learn more about hooks, head to xref:ROOT:extending-contracts.adoc#using-hooks[Using Hooks].
   */
  function _beforeTokenTransfer(
    address operator,
    address from,
    address to,
    uint256[] memory ids,
    uint256[] memory amounts,
    bytes memory data
  ) internal virtual {}

  /**
   * @dev Hook that is called after any token transfer. This includes minting
   * and burning, as well as batched variants.
   *
   * The same hook is called on both single and batched variants. For single
   * transfers, the length of the `id` and `amount` arrays will be 1.
   *
   * Calling conditions (for each `id` and `amount` pair):
   *
   * - When `from` and `to` are both non-zero, `amount` of ``from``'s tokens
   * of token type `id` will be  transferred to `to`.
   * - When `from` is zero, `amount` tokens of token type `id` will be minted
   * for `to`.
   * - when `to` is zero, `amount` of ``from``'s tokens of token type `id`
   * will be burned.
   * - `from` and `to` are never both zero.
   * - `ids` and `amounts` have the same, non-zero length.
   *
   * To learn more about hooks, head to xref:ROOT:extending-contracts.adoc#using-hooks[Using Hooks].
   */
  function _afterTokenTransfer(
    address operator,
    address from,
    address to,
    uint256[] memory ids,
    uint256[] memory amounts,
    bytes memory data
  ) internal virtual {}

  function _doSafeTransferAcceptanceCheck(
    address operator,
    address from,
    address to,
    uint256 id,
    uint256 amount,
    bytes memory data
  ) private {
    if (to.isContract()) {
      try IERC1155Receiver(to).onERC1155Received(operator, from, id, amount, data) returns (
        bytes4 response
      ) {
        if (response != IERC1155Receiver.onERC1155Received.selector) {
          revert("ERC1155: ERC1155Receiver rejected tokens");
        }
      } catch Error(string memory reason) {
        revert(reason);
      } catch {
        revert("ERC1155: transfer to non-ERC1155Receiver implementer");
      }
    }
  }

  function _doSafeBatchTransferAcceptanceCheck(
    address operator,
    address from,
    address to,
    uint256[] memory ids,
    uint256[] memory amounts,
    bytes memory data
  ) private {
    if (to.isContract()) {
      try IERC1155Receiver(to).onERC1155BatchReceived(operator, from, ids, amounts, data) returns (
        bytes4 response
      ) {
        if (response != IERC1155Receiver.onERC1155BatchReceived.selector) {
          revert("ERC1155: ERC1155Receiver rejected tokens");
        }
      } catch Error(string memory reason) {
        revert(reason);
      } catch {
        revert("ERC1155: transfer to non-ERC1155Receiver implementer");
      }
    }
  }

  function _asSingletonArray(uint256 element) private pure returns (uint256[] memory) {
    uint256[] memory array = new uint256[](1);
    array[0] = element;

    return array;
  }
}
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.11;

import "../Helpers/Royalties/IRoyalties.sol";

interface IERC1155CreatorBase is IRoyalties {
  struct RoyaltyConfig {
    address payable receiver;
    uint16 bps;
  }

  enum TokenClaimType {
    PUBLIC,
    ADMIN,
    DISABLED
  }

  struct TokenMetadataConfig {
    uint256 totalSupply;
    uint256 maxSupply;
    uint256 maxClaimPerUser;
    uint256 price;
    string uri;
    RoyaltyConfig[] royalties;
    TokenClaimType claimStatus;
  }

  event TokenClaimStatusUpdate(uint256 indexed tokenId, TokenClaimType claimStatus);

  /**
   * @dev Set secondary royalties configuration(s) for token by admin.
   */
  function setRoyalties(
    uint256 tokenId,
    address payable[] calldata receivers,
    uint256[] calldata basisPoints
  ) external;

  /**
   * @dev Update token uri after a token is minted by permissioned user.
   */
  function updateTokenURI(uint256 tokenId, string calldata uri) external;

  /**
   * @dev Toggle `claimable` flag for claiming of tokens
   */
  function updateTokenClaimStatus(uint256 tokenId, TokenClaimType claimStatus) external;

  /**
   * @dev Update token public minting price.
   */
  function updateTokenMintPrice(uint256 tokenId, uint256 newPrice) external;

  /**
   * @dev Total amount of tokens in with a given tokenId.
   */
  function totalSupply(uint256 tokenId) external view returns (uint256);

  /**
   * @dev Maximum amount of supply to be minted with a given tokenId.
   */
  function maxSupply(uint256 tokenId) external view returns (uint256);

  /**
   * @dev Price to mint a given initialised tokenId.
   */
  function publicMintPrice(uint256 tokenId) external view returns (uint256);

  /**
   * @dev Returns TokenMetadataConfig specified by a tokenId.
   */
  function tokenMetadata(uint256 tokenId)
    external
    view
    returns (
      uint256,
      uint256,
      uint256,
      uint256,
      string memory,
      TokenClaimType
    );
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
// OpenZeppelin Contracts v4.4.1 (token/ERC1155/IERC1155.sol)

pragma solidity ^0.8.0;

import "../../utils/introspection/IERC165.sol";

/**
 * @dev Required interface of an ERC1155 compliant contract, as defined in the
 * https://eips.ethereum.org/EIPS/eip-1155[EIP].
 *
 * _Available since v3.1._
 */
interface IERC1155 is IERC165 {
    /**
     * @dev Emitted when `value` tokens of token type `id` are transferred from `from` to `to` by `operator`.
     */
    event TransferSingle(address indexed operator, address indexed from, address indexed to, uint256 id, uint256 value);

    /**
     * @dev Equivalent to multiple {TransferSingle} events, where `operator`, `from` and `to` are the same for all
     * transfers.
     */
    event TransferBatch(
        address indexed operator,
        address indexed from,
        address indexed to,
        uint256[] ids,
        uint256[] values
    );

    /**
     * @dev Emitted when `account` grants or revokes permission to `operator` to transfer their tokens, according to
     * `approved`.
     */
    event ApprovalForAll(address indexed account, address indexed operator, bool approved);

    /**
     * @dev Emitted when the URI for token type `id` changes to `value`, if it is a non-programmatic URI.
     *
     * If an {URI} event was emitted for `id`, the standard
     * https://eips.ethereum.org/EIPS/eip-1155#metadata-extensions[guarantees] that `value` will equal the value
     * returned by {IERC1155MetadataURI-uri}.
     */
    event URI(string value, uint256 indexed id);

    /**
     * @dev Returns the amount of tokens of token type `id` owned by `account`.
     *
     * Requirements:
     *
     * - `account` cannot be the zero address.
     */
    function balanceOf(address account, uint256 id) external view returns (uint256);

    /**
     * @dev xref:ROOT:erc1155.adoc#batch-operations[Batched] version of {balanceOf}.
     *
     * Requirements:
     *
     * - `accounts` and `ids` must have the same length.
     */
    function balanceOfBatch(address[] calldata accounts, uint256[] calldata ids)
        external
        view
        returns (uint256[] memory);

    /**
     * @dev Grants or revokes permission to `operator` to transfer the caller's tokens, according to `approved`,
     *
     * Emits an {ApprovalForAll} event.
     *
     * Requirements:
     *
     * - `operator` cannot be the caller.
     */
    function setApprovalForAll(address operator, bool approved) external;

    /**
     * @dev Returns true if `operator` is approved to transfer ``account``'s tokens.
     *
     * See {setApprovalForAll}.
     */
    function isApprovedForAll(address account, address operator) external view returns (bool);

    /**
     * @dev Transfers `amount` tokens of token type `id` from `from` to `to`.
     *
     * Emits a {TransferSingle} event.
     *
     * Requirements:
     *
     * - `to` cannot be the zero address.
     * - If the caller is not `from`, it must be have been approved to spend ``from``'s tokens via {setApprovalForAll}.
     * - `from` must have a balance of tokens of type `id` of at least `amount`.
     * - If `to` refers to a smart contract, it must implement {IERC1155Receiver-onERC1155Received} and return the
     * acceptance magic value.
     */
    function safeTransferFrom(
        address from,
        address to,
        uint256 id,
        uint256 amount,
        bytes calldata data
    ) external;

    /**
     * @dev xref:ROOT:erc1155.adoc#batch-operations[Batched] version of {safeTransferFrom}.
     *
     * Emits a {TransferBatch} event.
     *
     * Requirements:
     *
     * - `ids` and `amounts` must have the same length.
     * - If `to` refers to a smart contract, it must implement {IERC1155Receiver-onERC1155BatchReceived} and return the
     * acceptance magic value.
     */
    function safeBatchTransferFrom(
        address from,
        address to,
        uint256[] calldata ids,
        uint256[] calldata amounts,
        bytes calldata data
    ) external;
}
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
// OpenZeppelin Contracts v4.4.1 (token/ERC1155/extensions/IERC1155MetadataURI.sol)

pragma solidity ^0.8.0;

import "../IERC1155.sol";

/**
 * @dev Interface of the optional ERC1155MetadataExtension interface, as defined
 * in the https://eips.ethereum.org/EIPS/eip-1155#metadata-extensions[EIP].
 *
 * _Available since v3.1._
 */
interface IERC1155MetadataURI is IERC1155 {
    /**
     * @dev Returns the URI for token type `id`.
     *
     * If the `\{id\}` substring is present in the URI, it must be replaced by
     * clients with the actual token type ID.
     */
    function uri(uint256 id) external view returns (string memory);
}
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.5.0) (utils/Address.sol)

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
        require(isContract(target), "Address: call to non-contract");

        (bool success, bytes memory returndata) = target.call{value: value}(data);
        return verifyCallResult(success, returndata, errorMessage);
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
        require(isContract(target), "Address: static call to non-contract");

        (bool success, bytes memory returndata) = target.staticcall(data);
        return verifyCallResult(success, returndata, errorMessage);
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
        require(isContract(target), "Address: delegate call to non-contract");

        (bool success, bytes memory returndata) = target.delegatecall(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    /**
     * @dev Tool to verifies that a low level call was successful, and revert if it wasn't, either by bubbling the
     * revert reason using the provided one.
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
            // Look for revert reason and bubble it up if present
            if (returndata.length > 0) {
                // The easiest way to bubble the revert reason is using memory via assembly

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
pragma solidity ^0.8.11;

import "@openzeppelin/contracts/utils/introspection/IERC165.sol";

interface IRoyalties is IERC165 {
  event RoyaltiesUpdated(
    uint256 indexed tokenId,
    address payable[] receivers,
    uint256[] basisPoints
  );

  /**
   * @dev Get royalites of a token.  Returns list of receivers and basisPoints
   */
  function getRoyalties(uint256 tokenId)
    external
    view
    returns (address payable[] memory, uint256[] memory);

  // Royalty support for various other standards
  function getFeeRecipients(uint256 tokenId) external view returns (address payable[] memory);

  function getFeeBps(uint256 tokenId) external view returns (uint256[] memory);

  function getFees(uint256 tokenId)
    external
    view
    returns (address payable[] memory, uint256[] memory);

  function royaltyInfo(uint256 tokenId, uint256 value) external view returns (address, uint256);
}
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract BoringOwnableData {
  address public owner;
  address public pendingOwner;
}

contract BoringOwnable is BoringOwnableData {
  event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

  /// @notice `owner` defaults to msg.sender on construction.
  constructor() {
    owner = msg.sender;
    emit OwnershipTransferred(address(0), msg.sender);
  }

  /// @notice Transfers ownership to `newOwner`. Either directly or claimable by the new pending owner.
  /// Can only be invoked by the current `owner`.
  /// @param newOwner Address of the new owner.
  /// @param direct True if `newOwner` should be set immediately. False if `newOwner` needs to use `claimOwnership`.
  /// @param renounce Allows the `newOwner` to be `address(0)` if `direct` and `renounce` is True. Has no effect otherwise.
  function transferOwnership(
    address newOwner,
    bool direct,
    bool renounce
  ) public onlyOwner {
    if (direct) {
      // Checks
      require(newOwner != address(0) || renounce, "Ownable: zero address");

      // Effects
      emit OwnershipTransferred(owner, newOwner);
      owner = newOwner;
      pendingOwner = address(0);
    } else {
      // Effects
      pendingOwner = newOwner;
    }
  }

  /// @notice Needs to be called by `pendingOwner` to claim ownership.
  function claimOwnership() public {
    address _pendingOwner = pendingOwner;

    // Checks
    require(msg.sender == _pendingOwner, "Ownable: caller != pending owner");

    // Effects
    emit OwnershipTransferred(owner, _pendingOwner);
    owner = _pendingOwner;
    pendingOwner = address(0);
  }

  /// @notice Only allows the `owner` to execute the function.
  modifier onlyOwner() {
    require(msg.sender == owner, "Ownable: caller is not the owner");
    _;
  }
}
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.11;

import "@openzeppelin/contracts/utils/introspection/IERC165.sol";

interface IPermissionControl is IERC165 {
  event PermissionGranted(address indexed newAdmin, address indexed assigner);
  event PermissionRevoked(address indexed oldAdmin, address indexed assigner);

  /**
   * @dev gets address of all approved admins.
   */
  function getAllPermissionedUsers() external view returns (address[] memory);

  /**
   * @dev add an admin.  Can only be called by contract owner.
   */
  function grantPermissionToUser(address admin) external;

  /**
   * @dev remove an admin.  Can only be called by contract owner.
   */
  function revokePermission(address admin) external;

  /**
   * @dev checks whether or not given address is an admin, which includes owner
   * Returns True if they are
   */
  function isPermissionedUser(address admin) external view returns (bool);
}
