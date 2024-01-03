// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.7.0) (access/AccessControl.sol)

pragma solidity ^0.8.0;

import "./IAccessControl.sol";
import "../utils/Context.sol";
import "../utils/Strings.sol";
import "../utils/introspection/ERC165.sol";

/**
 * @dev Contract module that allows children to implement role-based access
 * control mechanisms. This is a lightweight version that doesn't allow enumerating role
 * members except through off-chain means by accessing the contract event logs. Some
 * applications may benefit from on-chain enumerability, for those cases see
 * {AccessControlEnumerable}.
 *
 * Roles are referred to by their `bytes32` identifier. These should be exposed
 * in the external API and be unique. The best way to achieve this is by
 * using `public constant` hash digests:
 *
 * ```
 * bytes32 public constant MY_ROLE = keccak256("MY_ROLE");
 * ```
 *
 * Roles can be used to represent a set of permissions. To restrict access to a
 * function call, use {hasRole}:
 *
 * ```
 * function foo() public {
 *     require(hasRole(MY_ROLE, msg.sender));
 *     ...
 * }
 * ```
 *
 * Roles can be granted and revoked dynamically via the {grantRole} and
 * {revokeRole} functions. Each role has an associated admin role, and only
 * accounts that have a role's admin role can call {grantRole} and {revokeRole}.
 *
 * By default, the admin role for all roles is `DEFAULT_ADMIN_ROLE`, which means
 * that only accounts with this role will be able to grant or revoke other
 * roles. More complex role relationships can be created by using
 * {_setRoleAdmin}.
 *
 * WARNING: The `DEFAULT_ADMIN_ROLE` is also its own admin: it has permission to
 * grant and revoke this role. Extra precautions should be taken to secure
 * accounts that have been granted it.
 */
abstract contract AccessControl is Context, IAccessControl, ERC165 {
    struct RoleData {
        mapping(address => bool) members;
        bytes32 adminRole;
    }

    mapping(bytes32 => RoleData) private _roles;

    bytes32 public constant DEFAULT_ADMIN_ROLE = 0x00;

    /**
     * @dev Modifier that checks that an account has a specific role. Reverts
     * with a standardized message including the required role.
     *
     * The format of the revert reason is given by the following regular expression:
     *
     *  /^AccessControl: account (0x[0-9a-f]{40}) is missing role (0x[0-9a-f]{64})$/
     *
     * _Available since v4.1._
     */
    modifier onlyRole(bytes32 role) {
        _checkRole(role);
        _;
    }

    /**
     * @dev See {IERC165-supportsInterface}.
     */
    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return interfaceId == type(IAccessControl).interfaceId || super.supportsInterface(interfaceId);
    }

    /**
     * @dev Returns `true` if `account` has been granted `role`.
     */
    function hasRole(bytes32 role, address account) public view virtual override returns (bool) {
        return _roles[role].members[account];
    }

    /**
     * @dev Revert with a standard message if `_msgSender()` is missing `role`.
     * Overriding this function changes the behavior of the {onlyRole} modifier.
     *
     * Format of the revert message is described in {_checkRole}.
     *
     * _Available since v4.6._
     */
    function _checkRole(bytes32 role) internal view virtual {
        _checkRole(role, _msgSender());
    }

    /**
     * @dev Revert with a standard message if `account` is missing `role`.
     *
     * The format of the revert reason is given by the following regular expression:
     *
     *  /^AccessControl: account (0x[0-9a-f]{40}) is missing role (0x[0-9a-f]{64})$/
     */
    function _checkRole(bytes32 role, address account) internal view virtual {
        if (!hasRole(role, account)) {
            revert(
                string(
                    abi.encodePacked(
                        "AccessControl: account ",
                        Strings.toHexString(uint160(account), 20),
                        " is missing role ",
                        Strings.toHexString(uint256(role), 32)
                    )
                )
            );
        }
    }

    /**
     * @dev Returns the admin role that controls `role`. See {grantRole} and
     * {revokeRole}.
     *
     * To change a role's admin, use {_setRoleAdmin}.
     */
    function getRoleAdmin(bytes32 role) public view virtual override returns (bytes32) {
        return _roles[role].adminRole;
    }

    /**
     * @dev Grants `role` to `account`.
     *
     * If `account` had not been already granted `role`, emits a {RoleGranted}
     * event.
     *
     * Requirements:
     *
     * - the caller must have ``role``'s admin role.
     *
     * May emit a {RoleGranted} event.
     */
    function grantRole(bytes32 role, address account) public virtual override onlyRole(getRoleAdmin(role)) {
        _grantRole(role, account);
    }

    /**
     * @dev Revokes `role` from `account`.
     *
     * If `account` had been granted `role`, emits a {RoleRevoked} event.
     *
     * Requirements:
     *
     * - the caller must have ``role``'s admin role.
     *
     * May emit a {RoleRevoked} event.
     */
    function revokeRole(bytes32 role, address account) public virtual override onlyRole(getRoleAdmin(role)) {
        _revokeRole(role, account);
    }

    /**
     * @dev Revokes `role` from the calling account.
     *
     * Roles are often managed via {grantRole} and {revokeRole}: this function's
     * purpose is to provide a mechanism for accounts to lose their privileges
     * if they are compromised (such as when a trusted device is misplaced).
     *
     * If the calling account had been revoked `role`, emits a {RoleRevoked}
     * event.
     *
     * Requirements:
     *
     * - the caller must be `account`.
     *
     * May emit a {RoleRevoked} event.
     */
    function renounceRole(bytes32 role, address account) public virtual override {
        require(account == _msgSender(), "AccessControl: can only renounce roles for self");

        _revokeRole(role, account);
    }

    /**
     * @dev Grants `role` to `account`.
     *
     * If `account` had not been already granted `role`, emits a {RoleGranted}
     * event. Note that unlike {grantRole}, this function doesn't perform any
     * checks on the calling account.
     *
     * May emit a {RoleGranted} event.
     *
     * [WARNING]
     * ====
     * This function should only be called from the constructor when setting
     * up the initial roles for the system.
     *
     * Using this function in any other way is effectively circumventing the admin
     * system imposed by {AccessControl}.
     * ====
     *
     * NOTE: This function is deprecated in favor of {_grantRole}.
     */
    function _setupRole(bytes32 role, address account) internal virtual {
        _grantRole(role, account);
    }

    /**
     * @dev Sets `adminRole` as ``role``'s admin role.
     *
     * Emits a {RoleAdminChanged} event.
     */
    function _setRoleAdmin(bytes32 role, bytes32 adminRole) internal virtual {
        bytes32 previousAdminRole = getRoleAdmin(role);
        _roles[role].adminRole = adminRole;
        emit RoleAdminChanged(role, previousAdminRole, adminRole);
    }

    /**
     * @dev Grants `role` to `account`.
     *
     * Internal function without access restriction.
     *
     * May emit a {RoleGranted} event.
     */
    function _grantRole(bytes32 role, address account) internal virtual {
        if (!hasRole(role, account)) {
            _roles[role].members[account] = true;
            emit RoleGranted(role, account, _msgSender());
        }
    }

    /**
     * @dev Revokes `role` from `account`.
     *
     * Internal function without access restriction.
     *
     * May emit a {RoleRevoked} event.
     */
    function _revokeRole(bytes32 role, address account) internal virtual {
        if (hasRole(role, account)) {
            _roles[role].members[account] = false;
            emit RoleRevoked(role, account, _msgSender());
        }
    }
}
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (access/IAccessControl.sol)

pragma solidity ^0.8.0;

/**
 * @dev External interface of AccessControl declared to support ERC165 detection.
 */
interface IAccessControl {
    /**
     * @dev Emitted when `newAdminRole` is set as ``role``'s admin role, replacing `previousAdminRole`
     *
     * `DEFAULT_ADMIN_ROLE` is the starting admin for all roles, despite
     * {RoleAdminChanged} not being emitted signaling this.
     *
     * _Available since v3.1._
     */
    event RoleAdminChanged(bytes32 indexed role, bytes32 indexed previousAdminRole, bytes32 indexed newAdminRole);

    /**
     * @dev Emitted when `account` is granted `role`.
     *
     * `sender` is the account that originated the contract call, an admin role
     * bearer except when using {AccessControl-_setupRole}.
     */
    event RoleGranted(bytes32 indexed role, address indexed account, address indexed sender);

    /**
     * @dev Emitted when `account` is revoked `role`.
     *
     * `sender` is the account that originated the contract call:
     *   - if using `revokeRole`, it is the admin role bearer
     *   - if using `renounceRole`, it is the role bearer (i.e. `account`)
     */
    event RoleRevoked(bytes32 indexed role, address indexed account, address indexed sender);

    /**
     * @dev Returns `true` if `account` has been granted `role`.
     */
    function hasRole(bytes32 role, address account) external view returns (bool);

    /**
     * @dev Returns the admin role that controls `role`. See {grantRole} and
     * {revokeRole}.
     *
     * To change a role's admin, use {AccessControl-_setRoleAdmin}.
     */
    function getRoleAdmin(bytes32 role) external view returns (bytes32);

    /**
     * @dev Grants `role` to `account`.
     *
     * If `account` had not been already granted `role`, emits a {RoleGranted}
     * event.
     *
     * Requirements:
     *
     * - the caller must have ``role``'s admin role.
     */
    function grantRole(bytes32 role, address account) external;

    /**
     * @dev Revokes `role` from `account`.
     *
     * If `account` had been granted `role`, emits a {RoleRevoked} event.
     *
     * Requirements:
     *
     * - the caller must have ``role``'s admin role.
     */
    function revokeRole(bytes32 role, address account) external;

    /**
     * @dev Revokes `role` from the calling account.
     *
     * Roles are often managed via {grantRole} and {revokeRole}: this function's
     * purpose is to provide a mechanism for accounts to lose their privileges
     * if they are compromised (such as when a trusted device is misplaced).
     *
     * If the calling account had been granted `role`, emits a {RoleRevoked}
     * event.
     *
     * Requirements:
     *
     * - the caller must be `account`.
     */
    function renounceRole(bytes32 role, address account) external;
}
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.6.0) (interfaces/IERC2981.sol)

pragma solidity ^0.8.0;

import "../utils/introspection/IERC165.sol";

/**
 * @dev Interface for the NFT Royalty Standard.
 *
 * A standardized way to retrieve royalty payment information for non-fungible tokens (NFTs) to enable universal
 * support for royalty payments across all NFT marketplaces and ecosystem participants.
 *
 * _Available since v4.5._
 */
interface IERC2981 is IERC165 {
    /**
     * @dev Returns how much royalty is owed and to whom, based on a sale price that may be denominated in any unit of
     * exchange. The royalty amount is denominated and should be paid in that same unit of exchange.
     */
    function royaltyInfo(uint256 tokenId, uint256 salePrice)
        external
        view
        returns (address receiver, uint256 royaltyAmount);
}
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.7.0) (token/common/ERC2981.sol)

pragma solidity ^0.8.0;

import "../../interfaces/IERC2981.sol";
import "../../utils/introspection/ERC165.sol";

/**
 * @dev Implementation of the NFT Royalty Standard, a standardized way to retrieve royalty payment information.
 *
 * Royalty information can be specified globally for all token ids via {_setDefaultRoyalty}, and/or individually for
 * specific token ids via {_setTokenRoyalty}. The latter takes precedence over the first.
 *
 * Royalty is specified as a fraction of sale price. {_feeDenominator} is overridable but defaults to 10000, meaning the
 * fee is specified in basis points by default.
 *
 * IMPORTANT: ERC-2981 only specifies a way to signal royalty information and does not enforce its payment. See
 * https://eips.ethereum.org/EIPS/eip-2981#optional-royalty-payments[Rationale] in the EIP. Marketplaces are expected to
 * voluntarily pay royalties together with sales, but note that this standard is not yet widely supported.
 *
 * _Available since v4.5._
 */
abstract contract ERC2981 is IERC2981, ERC165 {
    struct RoyaltyInfo {
        address receiver;
        uint96 royaltyFraction;
    }

    RoyaltyInfo private _defaultRoyaltyInfo;
    mapping(uint256 => RoyaltyInfo) private _tokenRoyaltyInfo;

    /**
     * @dev See {IERC165-supportsInterface}.
     */
    function supportsInterface(bytes4 interfaceId) public view virtual override(IERC165, ERC165) returns (bool) {
        return interfaceId == type(IERC2981).interfaceId || super.supportsInterface(interfaceId);
    }

    /**
     * @inheritdoc IERC2981
     */
    function royaltyInfo(uint256 _tokenId, uint256 _salePrice) public view virtual override returns (address, uint256) {
        RoyaltyInfo memory royalty = _tokenRoyaltyInfo[_tokenId];

        if (royalty.receiver == address(0)) {
            royalty = _defaultRoyaltyInfo;
        }

        uint256 royaltyAmount = (_salePrice * royalty.royaltyFraction) / _feeDenominator();

        return (royalty.receiver, royaltyAmount);
    }

    /**
     * @dev The denominator with which to interpret the fee set in {_setTokenRoyalty} and {_setDefaultRoyalty} as a
     * fraction of the sale price. Defaults to 10000 so fees are expressed in basis points, but may be customized by an
     * override.
     */
    function _feeDenominator() internal pure virtual returns (uint96) {
        return 10000;
    }

    /**
     * @dev Sets the royalty information that all ids in this contract will default to.
     *
     * Requirements:
     *
     * - `receiver` cannot be the zero address.
     * - `feeNumerator` cannot be greater than the fee denominator.
     */
    function _setDefaultRoyalty(address receiver, uint96 feeNumerator) internal virtual {
        require(feeNumerator <= _feeDenominator(), "ERC2981: royalty fee will exceed salePrice");
        require(receiver != address(0), "ERC2981: invalid receiver");

        _defaultRoyaltyInfo = RoyaltyInfo(receiver, feeNumerator);
    }

    /**
     * @dev Removes default royalty information.
     */
    function _deleteDefaultRoyalty() internal virtual {
        delete _defaultRoyaltyInfo;
    }

    /**
     * @dev Sets the royalty information for a specific token id, overriding the global default.
     *
     * Requirements:
     *
     * - `receiver` cannot be the zero address.
     * - `feeNumerator` cannot be greater than the fee denominator.
     */
    function _setTokenRoyalty(
        uint256 tokenId,
        address receiver,
        uint96 feeNumerator
    ) internal virtual {
        require(feeNumerator <= _feeDenominator(), "ERC2981: royalty fee will exceed salePrice");
        require(receiver != address(0), "ERC2981: Invalid parameters");

        _tokenRoyaltyInfo[tokenId] = RoyaltyInfo(receiver, feeNumerator);
    }

    /**
     * @dev Resets royalty information for the token id back to the global default.
     */
    function _resetTokenRoyalty(uint256 tokenId) internal virtual {
        delete _tokenRoyaltyInfo[tokenId];
    }
}
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.7.0) (token/ERC721/ERC721.sol)

pragma solidity ^0.8.0;

import "./IERC721.sol";
import "./IERC721Receiver.sol";
import "./extensions/IERC721Metadata.sol";
import "../../utils/Address.sol";
import "../../utils/Context.sol";
import "../../utils/Strings.sol";
import "../../utils/introspection/ERC165.sol";

/**
 * @dev Implementation of https://eips.ethereum.org/EIPS/eip-721[ERC721] Non-Fungible Token Standard, including
 * the Metadata extension, but not including the Enumerable extension, which is available separately as
 * {ERC721Enumerable}.
 */
contract ERC721 is Context, ERC165, IERC721, IERC721Metadata {
    using Address for address;
    using Strings for uint256;

    // Token name
    string private _name;

    // Token symbol
    string private _symbol;

    // Mapping from token ID to owner address
    mapping(uint256 => address) private _owners;

    // Mapping owner address to token count
    mapping(address => uint256) private _balances;

    // Mapping from token ID to approved address
    mapping(uint256 => address) private _tokenApprovals;

    // Mapping from owner to operator approvals
    mapping(address => mapping(address => bool)) private _operatorApprovals;

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
    function supportsInterface(bytes4 interfaceId) public view virtual override(ERC165, IERC165) returns (bool) {
        return
            interfaceId == type(IERC721).interfaceId ||
            interfaceId == type(IERC721Metadata).interfaceId ||
            super.supportsInterface(interfaceId);
    }

    /**
     * @dev See {IERC721-balanceOf}.
     */
    function balanceOf(address owner) public view virtual override returns (uint256) {
        require(owner != address(0), "ERC721: address zero is not a valid owner");
        return _balances[owner];
    }

    /**
     * @dev See {IERC721-ownerOf}.
     */
    function ownerOf(uint256 tokenId) public view virtual override returns (address) {
        address owner = _owners[tokenId];
        require(owner != address(0), "ERC721: invalid token ID");
        return owner;
    }

    /**
     * @dev See {IERC721Metadata-name}.
     */
    function name() public view virtual override returns (string memory) {
        return _name;
    }

    /**
     * @dev See {IERC721Metadata-symbol}.
     */
    function symbol() public view virtual override returns (string memory) {
        return _symbol;
    }

    /**
     * @dev See {IERC721Metadata-tokenURI}.
     */
    function tokenURI(uint256 tokenId) public view virtual override returns (string memory) {
        _requireMinted(tokenId);

        string memory baseURI = _baseURI();
        return bytes(baseURI).length > 0 ? string(abi.encodePacked(baseURI, tokenId.toString())) : "";
    }

    /**
     * @dev Base URI for computing {tokenURI}. If set, the resulting URI for each
     * token will be the concatenation of the `baseURI` and the `tokenId`. Empty
     * by default, can be overridden in child contracts.
     */
    function _baseURI() internal view virtual returns (string memory) {
        return "";
    }

    /**
     * @dev See {IERC721-approve}.
     */
    function approve(address to, uint256 tokenId) public virtual override {
        address owner = ERC721.ownerOf(tokenId);
        require(to != owner, "ERC721: approval to current owner");

        require(
            _msgSender() == owner || isApprovedForAll(owner, _msgSender()),
            "ERC721: approve caller is not token owner nor approved for all"
        );

        _approve(to, tokenId);
    }

    /**
     * @dev See {IERC721-getApproved}.
     */
    function getApproved(uint256 tokenId) public view virtual override returns (address) {
        _requireMinted(tokenId);

        return _tokenApprovals[tokenId];
    }

    /**
     * @dev See {IERC721-setApprovalForAll}.
     */
    function setApprovalForAll(address operator, bool approved) public virtual override {
        _setApprovalForAll(_msgSender(), operator, approved);
    }

    /**
     * @dev See {IERC721-isApprovedForAll}.
     */
    function isApprovedForAll(address owner, address operator) public view virtual override returns (bool) {
        return _operatorApprovals[owner][operator];
    }

    /**
     * @dev See {IERC721-transferFrom}.
     */
    function transferFrom(
        address from,
        address to,
        uint256 tokenId
    ) public virtual override {
        //solhint-disable-next-line max-line-length
        require(_isApprovedOrOwner(_msgSender(), tokenId), "ERC721: caller is not token owner nor approved");

        _transfer(from, to, tokenId);
    }

    /**
     * @dev See {IERC721-safeTransferFrom}.
     */
    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId
    ) public virtual override {
        safeTransferFrom(from, to, tokenId, "");
    }

    /**
     * @dev See {IERC721-safeTransferFrom}.
     */
    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId,
        bytes memory data
    ) public virtual override {
        require(_isApprovedOrOwner(_msgSender(), tokenId), "ERC721: caller is not token owner nor approved");
        _safeTransfer(from, to, tokenId, data);
    }

    /**
     * @dev Safely transfers `tokenId` token from `from` to `to`, checking first that contract recipients
     * are aware of the ERC721 protocol to prevent tokens from being forever locked.
     *
     * `data` is additional data, it has no specified format and it is sent in call to `to`.
     *
     * This internal function is equivalent to {safeTransferFrom}, and can be used to e.g.
     * implement alternative mechanisms to perform token transfer, such as signature-based.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `tokenId` token must exist and be owned by `from`.
     * - If `to` refers to a smart contract, it must implement {IERC721Receiver-onERC721Received}, which is called upon a safe transfer.
     *
     * Emits a {Transfer} event.
     */
    function _safeTransfer(
        address from,
        address to,
        uint256 tokenId,
        bytes memory data
    ) internal virtual {
        _transfer(from, to, tokenId);
        require(_checkOnERC721Received(from, to, tokenId, data), "ERC721: transfer to non ERC721Receiver implementer");
    }

    /**
     * @dev Returns whether `tokenId` exists.
     *
     * Tokens can be managed by their owner or approved accounts via {approve} or {setApprovalForAll}.
     *
     * Tokens start existing when they are minted (`_mint`),
     * and stop existing when they are burned (`_burn`).
     */
    function _exists(uint256 tokenId) internal view virtual returns (bool) {
        return _owners[tokenId] != address(0);
    }

    /**
     * @dev Returns whether `spender` is allowed to manage `tokenId`.
     *
     * Requirements:
     *
     * - `tokenId` must exist.
     */
    function _isApprovedOrOwner(address spender, uint256 tokenId) internal view virtual returns (bool) {
        address owner = ERC721.ownerOf(tokenId);
        return (spender == owner || isApprovedForAll(owner, spender) || getApproved(tokenId) == spender);
    }

    /**
     * @dev Safely mints `tokenId` and transfers it to `to`.
     *
     * Requirements:
     *
     * - `tokenId` must not exist.
     * - If `to` refers to a smart contract, it must implement {IERC721Receiver-onERC721Received}, which is called upon a safe transfer.
     *
     * Emits a {Transfer} event.
     */
    function _safeMint(address to, uint256 tokenId) internal virtual {
        _safeMint(to, tokenId, "");
    }

    /**
     * @dev Same as {xref-ERC721-_safeMint-address-uint256-}[`_safeMint`], with an additional `data` parameter which is
     * forwarded in {IERC721Receiver-onERC721Received} to contract recipients.
     */
    function _safeMint(
        address to,
        uint256 tokenId,
        bytes memory data
    ) internal virtual {
        _mint(to, tokenId);
        require(
            _checkOnERC721Received(address(0), to, tokenId, data),
            "ERC721: transfer to non ERC721Receiver implementer"
        );
    }

    /**
     * @dev Mints `tokenId` and transfers it to `to`.
     *
     * WARNING: Usage of this method is discouraged, use {_safeMint} whenever possible
     *
     * Requirements:
     *
     * - `tokenId` must not exist.
     * - `to` cannot be the zero address.
     *
     * Emits a {Transfer} event.
     */
    function _mint(address to, uint256 tokenId) internal virtual {
        require(to != address(0), "ERC721: mint to the zero address");
        require(!_exists(tokenId), "ERC721: token already minted");

        _beforeTokenTransfer(address(0), to, tokenId);

        _balances[to] += 1;
        _owners[tokenId] = to;

        emit Transfer(address(0), to, tokenId);

        _afterTokenTransfer(address(0), to, tokenId);
    }

    /**
     * @dev Destroys `tokenId`.
     * The approval is cleared when the token is burned.
     *
     * Requirements:
     *
     * - `tokenId` must exist.
     *
     * Emits a {Transfer} event.
     */
    function _burn(uint256 tokenId) internal virtual {
        address owner = ERC721.ownerOf(tokenId);

        _beforeTokenTransfer(owner, address(0), tokenId);

        // Clear approvals
        _approve(address(0), tokenId);

        _balances[owner] -= 1;
        delete _owners[tokenId];

        emit Transfer(owner, address(0), tokenId);

        _afterTokenTransfer(owner, address(0), tokenId);
    }

    /**
     * @dev Transfers `tokenId` from `from` to `to`.
     *  As opposed to {transferFrom}, this imposes no restrictions on msg.sender.
     *
     * Requirements:
     *
     * - `to` cannot be the zero address.
     * - `tokenId` token must be owned by `from`.
     *
     * Emits a {Transfer} event.
     */
    function _transfer(
        address from,
        address to,
        uint256 tokenId
    ) internal virtual {
        require(ERC721.ownerOf(tokenId) == from, "ERC721: transfer from incorrect owner");
        require(to != address(0), "ERC721: transfer to the zero address");

        _beforeTokenTransfer(from, to, tokenId);

        // Clear approvals from the previous owner
        _approve(address(0), tokenId);

        _balances[from] -= 1;
        _balances[to] += 1;
        _owners[tokenId] = to;

        emit Transfer(from, to, tokenId);

        _afterTokenTransfer(from, to, tokenId);
    }

    /**
     * @dev Approve `to` to operate on `tokenId`
     *
     * Emits an {Approval} event.
     */
    function _approve(address to, uint256 tokenId) internal virtual {
        _tokenApprovals[tokenId] = to;
        emit Approval(ERC721.ownerOf(tokenId), to, tokenId);
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
        require(owner != operator, "ERC721: approve to caller");
        _operatorApprovals[owner][operator] = approved;
        emit ApprovalForAll(owner, operator, approved);
    }

    /**
     * @dev Reverts if the `tokenId` has not been minted yet.
     */
    function _requireMinted(uint256 tokenId) internal view virtual {
        require(_exists(tokenId), "ERC721: invalid token ID");
    }

    /**
     * @dev Internal function to invoke {IERC721Receiver-onERC721Received} on a target address.
     * The call is not executed if the target address is not a contract.
     *
     * @param from address representing the previous owner of the given token ID
     * @param to target address that will receive the tokens
     * @param tokenId uint256 ID of the token to be transferred
     * @param data bytes optional data to send along with the call
     * @return bool whether the call correctly returned the expected magic value
     */
    function _checkOnERC721Received(
        address from,
        address to,
        uint256 tokenId,
        bytes memory data
    ) private returns (bool) {
        if (to.isContract()) {
            try IERC721Receiver(to).onERC721Received(_msgSender(), from, tokenId, data) returns (bytes4 retval) {
                return retval == IERC721Receiver.onERC721Received.selector;
            } catch (bytes memory reason) {
                if (reason.length == 0) {
                    revert("ERC721: transfer to non ERC721Receiver implementer");
                } else {
                    /// @solidity memory-safe-assembly
                    assembly {
                        revert(add(32, reason), mload(reason))
                    }
                }
            }
        } else {
            return true;
        }
    }

    /**
     * @dev Hook that is called before any token transfer. This includes minting
     * and burning.
     *
     * Calling conditions:
     *
     * - When `from` and `to` are both non-zero, ``from``'s `tokenId` will be
     * transferred to `to`.
     * - When `from` is zero, `tokenId` will be minted for `to`.
     * - When `to` is zero, ``from``'s `tokenId` will be burned.
     * - `from` and `to` are never both zero.
     *
     * To learn more about hooks, head to xref:ROOT:extending-contracts.adoc#using-hooks[Using Hooks].
     */
    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 tokenId
    ) internal virtual {}

    /**
     * @dev Hook that is called after any transfer of tokens. This includes
     * minting and burning.
     *
     * Calling conditions:
     *
     * - when `from` and `to` are both non-zero.
     * - `from` and `to` are never both zero.
     *
     * To learn more about hooks, head to xref:ROOT:extending-contracts.adoc#using-hooks[Using Hooks].
     */
    function _afterTokenTransfer(
        address from,
        address to,
        uint256 tokenId
    ) internal virtual {}
}
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.7.0) (token/ERC721/extensions/ERC721Burnable.sol)

pragma solidity ^0.8.0;

import "../ERC721.sol";
import "../../../utils/Context.sol";

/**
 * @title ERC721 Burnable Token
 * @dev ERC721 Token that can be burned (destroyed).
 */
abstract contract ERC721Burnable is Context, ERC721 {
    /**
     * @dev Burns `tokenId`. See {ERC721-_burn}.
     *
     * Requirements:
     *
     * - The caller must own `tokenId` or be an approved operator.
     */
    function burn(uint256 tokenId) public virtual {
        //solhint-disable-next-line max-line-length
        require(_isApprovedOrOwner(_msgSender(), tokenId), "ERC721: caller is not token owner nor approved");
        _burn(tokenId);
    }
}
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (token/ERC721/extensions/IERC721Metadata.sol)

pragma solidity ^0.8.0;

import "../IERC721.sol";

/**
 * @title ERC-721 Non-Fungible Token Standard, optional metadata extension
 * @dev See https://eips.ethereum.org/EIPS/eip-721
 */
interface IERC721Metadata is IERC721 {
    /**
     * @dev Returns the token collection name.
     */
    function name() external view returns (string memory);

    /**
     * @dev Returns the token collection symbol.
     */
    function symbol() external view returns (string memory);

    /**
     * @dev Returns the Uniform Resource Identifier (URI) for `tokenId` token.
     */
    function tokenURI(uint256 tokenId) external view returns (string memory);
}
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.7.0) (token/ERC721/IERC721.sol)

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
     * WARNING: Usage of this method is discouraged, use {safeTransferFrom} whenever possible.
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
// OpenZeppelin Contracts (last updated v4.7.0) (utils/Address.sol)

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
// OpenZeppelin Contracts (last updated v4.7.0) (utils/Strings.sol)

pragma solidity ^0.8.0;

/**
 * @dev String operations.
 */
library Strings {
    bytes16 private constant _HEX_SYMBOLS = "0123456789abcdef";
    uint8 private constant _ADDRESS_LENGTH = 20;

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

    /**
     * @dev Converts an `address` with fixed length of 20 bytes to its not checksummed ASCII `string` hexadecimal representation.
     */
    function toHexString(address addr) internal pure returns (string memory) {
        return toHexString(uint256(uint160(addr)), _ADDRESS_LENGTH);
    }
}
// SPDX-License-Identifier: MIT

pragma solidity 0.8.17;

import { IGetStatus } from "../interfaces/IGetStatus.sol";
import { IGetTokenStatus } from "../interfaces/IGetTokenStatus.sol";
import { VerboseReverts } from "../libraries/VerboseReverts.sol";
import { UserBlocklist } from "./UserBlocklist.sol";

import { ERC721 } from "@openzeppelin/contracts/token/ERC721/ERC721.sol";

// Check if user is blocked and perform action
abstract contract ERC721UserBlocklist is ERC721, UserBlocklist {
    string internal constant ERC721_LOCK_USER_MESSAGE = "ERC721UserBlocklist: Transfer is blocked for user";
    string internal constant ERC721_LOCK_TOKEN_MESSAGE = "ERC721UserBlocklist: Transfer is blocked for token";

    constructor(address blocklist_) UserBlocklist(blocklist_) {}

    /**
     * @inheritdoc UserBlocklist
     */
    function supportsInterface(bytes4 interfaceId) public view virtual override(ERC721, UserBlocklist) returns (bool) {
        return super.supportsInterface(interfaceId);
    }

    /**
     * @inheritdoc ERC721
     */
    function _beforeTokenTransfer(address from, address to, uint256 tokenId) internal virtual override {
        super._beforeTokenTransfer(from, to, tokenId);

        BlocklistInfo memory blocklistInfo = _getBlocklist();
        if (!blocklistInfo.enabled) return;

        bool actionByOperator = _msgSender() != from;

        address[] memory usersToCheck = new address[](actionByOperator ? 3 : 2);
        usersToCheck[0] = from;
        usersToCheck[1] = to;
        if (actionByOperator) {
            usersToCheck[2] = _msgSender();
        }
        _checkIfActionIsAllowed(blocklistInfo.blocklist, usersToCheck, tokenId);
    }

    /**
     * @dev Check if user is blocked
     * @param blocklist_ address of blocklist
     * @param tokenId id of token
     */
    function _checkIfActionIsAllowed(address blocklist_, address[] memory users, uint256 tokenId) internal view {
        bool[] memory userStatuses;
        bool tokenStatus;
        (userStatuses, tokenStatus) = IGetStatus(blocklist_).usersTokenIdBlockStatus(users, address(this), tokenId);

        for (uint256 id; id < userStatuses.length; id++) {
            if (userStatuses[id]) {
                VerboseReverts._revertWithAddress(ERC721_LOCK_USER_MESSAGE, users[id]);
            }
        }

        if (tokenStatus) {
            VerboseReverts._revertWithUint(ERC721_LOCK_TOKEN_MESSAGE, tokenId);
        }
    }
}
// SPDX-License-Identifier: MIT

pragma solidity 0.8.17;

import { IGetStatus } from "../interfaces/IGetStatus.sol";
import { IGetUserStatus } from "../interfaces/IGetUserStatus.sol";
import { VerboseReverts } from "../libraries/VerboseReverts.sol";

import { ERC165 } from "@openzeppelin/contracts/utils/introspection/ERC165.sol";

bytes4 constant USER_LOCK_HASH = 0x91659165;

// Check if user is blocked and perform action
contract UserBlocklist is ERC165 {
    struct BlocklistInfo {
        bool enabled;
        address blocklist;
    }

    event BlocklistChanged(address indexed oldBlocklist, address indexed newBlocklist);
    event BlocklistStatusChanged(bool indexed newStatus);

    string internal constant USERLOCK_MESSAGE = "UserBlocklist: Action is blocked for";

    // For some gas optimization these two variables are in the same slot, so they can be read in one SLOAD
    BlocklistInfo private _blocklistInfo;

    /**
     * @param blocklist_ address of the blocklist
     */
    constructor(address blocklist_) {
        _setBlocklist(blocklist_);
    }

    /**
     * @inheritdoc ERC165
     */
    function supportsInterface(bytes4 interfaceId) public view virtual override(ERC165) returns (bool) {
        return interfaceId == USER_LOCK_HASH || super.supportsInterface(interfaceId);
    }

    /**
     * @dev Returns the address of the blocklist.
     * @return address of the blocklist
     */
    function blocklist() public view returns (address) {
        return _blocklistInfo.blocklist;
    }

    /**
     * @dev If true the blocklist is enabled, false otherwise.
     * @param state true if the blocklist is enabled, false otherwise
     */
    function _changeBlocklistState(bool state) internal virtual {
        emit BlocklistStatusChanged(state);
        _blocklistInfo.enabled = state;
    }

    /**
     * @dev Sets the address of the blocklist.
     * @param blocklist_ address of the blocklist
     */
    function _setBlocklist(address blocklist_) internal virtual {
        emit BlocklistChanged(_blocklistInfo.blocklist, blocklist_);
        _blocklistInfo.blocklist = blocklist_;

        _changeBlocklistState(blocklist_ == address(0) ? false : true);
    }

    /**
     * @dev Returns blocklist info.
     * @return Full blocklist info
     */
    function _getBlocklist() internal view returns (BlocklistInfo memory) {
        return _blocklistInfo;
    }

    /**
     * @dev Reverts if the user is blocked.
     * @param user address of the user
     * @param message message to revert with
     */
    function _checkIfActionIsAllowed(address user, string memory message) internal view virtual {
        BlocklistInfo memory ri = _blocklistInfo;
        if (!ri.enabled) return;
        _checkIfActionIsAllowed(ri.blocklist, user, message);
    }

    /**
     * @dev Reverts if the user is blocked.
     * @param blocklist_ address of the blocklist
     * @param user address of the user
     * @param message message to revert with
     */
    function _checkIfActionIsAllowed(address blocklist_, address user, string memory message) internal view virtual {
        if (IGetUserStatus(blocklist_).isUserBlocked(user)) {
            VerboseReverts._revertWithAddress(bytes(message).length > 0 ? message : USERLOCK_MESSAGE, user);
        }
    }

    /**
     * @dev Reverts if any of the users are blocked.
     * @param users array of addresses of the users
     * @param message message to revert with
     */
    function _batchCheckIfActionIsAllowed(address[] memory users, string memory message) internal view virtual {
        BlocklistInfo memory ri = _blocklistInfo;
        if (!ri.enabled) return;
        _batchCheckIfActionIsAllowed(ri.blocklist, users, message);
    }

    /**
     * @dev Reverts if any of the users are blocked.
     * @param blocklist_ address of the blocklist
     * @param users array of addresses of the users
     * @param message message to revert with
     */
    function _batchCheckIfActionIsAllowed(
        address blocklist_,
        address[] memory users,
        string memory message
    ) internal view virtual {
        bool[] memory statuses = IGetUserStatus(blocklist_).batchIsUserBlocked(users);
        for (uint256 i = 0; i < users.length; i++) {
            if (statuses[i]) {
                VerboseReverts._revertWithAddress(bytes(message).length > 0 ? message : USERLOCK_MESSAGE, users[i]);
            }
        }
    }
}
// SPDX-License-Identifier: MIT

pragma solidity 0.8.17;

interface IGetStatus {
    /**
     * @dev Returns if the user is blocked and if the token is blocked
     * @param user The user address
     * @param contractAddress The contract address
     * @param tokenId The token id
     * @return (userBlocked, tokenBlocked)
     */
    function userTokenIdBlockStatus(
        address user,
        address contractAddress,
        uint256 tokenId
    ) external view returns (bool, bool);

    /**
     * @dev Returns if the user is blocked and if the tokens are blocked
     * @param user The user address
     * @param contractAddress The contract address
     * @param tokenIds Array of token ids
     * @return (userBlocked, tokenIdsBlocked)
     */
    function userTokenIdsBlockStatus(
        address user,
        address contractAddress,
        uint256[] calldata tokenIds
    ) external view returns (bool, bool[] memory);

    /**
     * @dev Returns if the user is blocked and if the tokens are blocked
     * @param users Array of user addresses
     * @param contractAddress The contract address
     * @param tokenId The token id
     * @return (usersBlocked, tokenBlocked)
     */
    function usersTokenIdBlockStatus(
        address[] calldata users,
        address contractAddress,
        uint256 tokenId
    ) external view returns (bool[] memory, bool);

    /**
     * @dev Returns if the users are blocked and if the tokens ids of a token are blocked
     * @param users Array of user addresses
     * @param contractAddress The contract address
     * @param tokenIds Array of token ids
     * @return (usersBlocked, tokenIdsBlocked)
     */
    function usersTokenIdsBlockStatus(
        address[] calldata users,
        address contractAddress,
        uint256[] calldata tokenIds
    ) external view returns (bool[] memory, bool[] memory);

    /**
     * @dev Returns if the users are blocked and if the tokens are blocked
     * @param users Array of user addresses
     * @param contractAddresses Array of contract addresses
     * @param tokenIds Array of token ids
     * @return (usersBlocked, tokenIdsBlocked)
     */
    function usersTokensIdsBlockStatus(
        address[] calldata users,
        address[] calldata contractAddresses,
        uint256[][] calldata tokenIds
    ) external view returns (bool[] memory, bool[][] memory);
}
// SPDX-License-Identifier: MIT

pragma solidity 0.8.17;

interface IGetTokenStatus {
    /**
     * @dev Returns true if the token is blocked.
     * @param contractAddress address of the contract
     * @param tokenId id of the token
     * @return true if the token is blocked, false otherwise
     */
    function isTokenBlocked(address contractAddress, uint256 tokenId) external view returns (bool);

    /**
     * @dev Returns true if the tokens are blocked.
     * @param contractAddress address of the contract
     * @param tokenIds array of ids of the tokens
     * @return array of booleans, true if the token is blocked, false otherwise
     */
    function isTokenIdsBlocked(
        address contractAddress,
        uint256[] calldata tokenIds
    ) external view returns (bool[] memory);

    /**
     * @dev Returns true if the token is blocked.
     * @param contractAddresses array of addresses of the contracts
     * @param tokenIds array of ids of the tokens
     * @return array of booleans, true if the token is blocked, false otherwise
     */
    function batchIsTokenIdsBlocked(
        address[] calldata contractAddresses,
        uint256[][] calldata tokenIds
    ) external view returns (bool[][] memory);
}
// SPDX-License-Identifier: MIT

pragma solidity 0.8.17;

interface IGetUserStatus {
    /**
     * @dev Returns true if the user is blocked.
     * @param user address of the user
     * @return true if the user is blocked, false otherwise
     */
    function isUserBlocked(address user) external view returns (bool);

    /**
     * @dev Returns true if the user is blocked.
     * @param users array of addresses of the users
     * @return array of booleans, true if the user is blocked, false otherwise
     */
    function batchIsUserBlocked(address[] calldata users) external view returns (bool[] memory);
}
// SPDX-License-Identifier: MIT

pragma solidity 0.8.17;

import { Strings } from "@openzeppelin/contracts/utils/Strings.sol";

library VerboseReverts {
    function _revertWithAddress(string memory message, address user) internal pure {
        revert(string(abi.encodePacked(message, ": ", Strings.toHexString(uint160(user), 20))));
    }

    function _revertWithUint(string memory message, uint256 value) internal pure {
        revert(string(abi.encodePacked(message, ": ", Strings.toHexString(value, 32))));
    }
}
// SPDX-License-Identifier: MIT

import { IERC165, ERC165 } from "@openzeppelin/contracts/utils/introspection/ERC165.sol";
import { ERC721 } from "@openzeppelin/contracts/token/ERC721/ERC721.sol";

import "./extensions/ERC721BatchRetriever.sol";
import { ERC721Mintable, MintableToken } from "./extensions/ERC721Mintable.sol";
import { ERC721Metadata, ContractMetadata } from "./extensions/ERC721TokenMetadata.sol";
import "./extensions/ERC2981Royalty.sol";

pragma solidity ^0.8.17;

abstract contract ERC721Default is ERC721, ERC721BatchRetriever, ERC721Mintable, ERC721Metadata, ERC2981Royalty {
    constructor(
        string memory name,
        string memory symbol,
        address feeReceiver,
        address royaltySetter_,
        string memory contractURI_,
        string memory tokenBaseURI_,
        address owner_,
        address minter_,
        address uriUpdater_,
        address metadataUpdater_
    )
        ERC721(name, symbol)
        TokenRoles(owner_)
        ERC2981Royalty(feeReceiver, 250, royaltySetter_)
        ContractMetadata(contractURI_, tokenBaseURI_, uriUpdater_, metadataUpdater_)
        MintableToken(minter_)
    {}

    /******************************************************************************/
    /*                                   ERC165                                   */
    /******************************************************************************/

    /**
     * @inheritdoc ERC165
     */
    function supportsInterface(
        bytes4 interfaceId
    ) public view virtual override(ERC721, ERC2981Royalty, ERC721Mintable, ERC721Metadata, IERC165) returns (bool) {
        return
            ERC721.supportsInterface(interfaceId) ||
            ERC2981Royalty.supportsInterface(interfaceId) ||
            ERC721Mintable.supportsInterface(interfaceId) ||
            ERC721Metadata.supportsInterface(interfaceId);
    }

    /******************************************************************************/
    /*                               ERC271Metadata                               */
    /******************************************************************************/

    /**
     * @inheritdoc ERC721Metadata
     */
    function tokenURI(uint256 tokenId) public view virtual override(ERC721Metadata, ERC721) returns (string memory) {
        return super.tokenURI(tokenId);
    }
}
// SPDX-License-Identifier: MIT

pragma solidity 0.8.17;

import "@openzeppelin/contracts/token/common/ERC2981.sol";

import "../interfaces/IERC2981Royalty.sol";

import "./TokenRoles.sol";

abstract contract ERC2981Royalty is TokenRoles, ERC2981, IERC2981Royalty {
    error NotRoyaltySetterOrOwner(address sender);

    bytes32 public constant ROYALTY_SETTER_ROLE = keccak256("ROYALTY_SETTER_ROLE");

    /**
     * @param receiver Who will receive royalties
     * @param royalty Numerator of the fee fraction (royalty/10000)
     */
    constructor(address receiver, uint96 royalty, address royaltySetter_) {
        _setDefaultRoyalty(receiver, royalty);
        _setupRolesRoyalty(royaltySetter_);
    }

    function _setupRolesRoyalty(address royaltySetter_) private {
        _grantRole(ROYALTY_SETTER_ROLE, royaltySetter_);
        _setRoleAdmin(ROYALTY_SETTER_ROLE, OWNER_ROLE);
    }

    /**
     * @inheritdoc AccessControl
     */
    function supportsInterface(bytes4 interfaceId) public view virtual override(AccessControl, ERC2981) returns (bool) {
        return
            type(IERC2981Royalty).interfaceId == interfaceId ||
            ERC2981.supportsInterface(interfaceId) ||
            AccessControl.supportsInterface(interfaceId);
    }

    /**
     * @param receiver Who will receive royalty
     * @param royalty Numerator of the royalty fraction (royalty/10000)
     */
    function setDefaultRoyalty(address receiver, uint96 royalty) external override onlyOwner {
        _setDefaultRoyalty(receiver, royalty);
    }

    function resetDefaultRoyalty() external override onlyOwner {
        _deleteDefaultRoyalty();
    }

    /**
     * @param tokenId Token id to set royalty for
     * @param receiver Who will receive property
     * @param royalty Numerator of the royalty fraction (feeNumerator/10000)
     */
    function setTokenRoyalty(uint256 tokenId, address receiver, uint96 royalty) external override royaltySetterOrOwner {
        _setTokenRoyalty(tokenId, receiver, royalty);
    }

    /**
     * @param tokenId Id of token to reset royalty for
     */
    function resetTokenRoyalty(uint256 tokenId) external override royaltySetterOrOwner {
        _resetTokenRoyalty(tokenId);
    }

    /******************************************************************************/
    /*                               AccessControl                                */
    /******************************************************************************/

    /**
     * @param account Address to grant royalty setter role to
     */
    function addRoyaltySetter(address account) external onlyOwner {
        _grantRole(ROYALTY_SETTER_ROLE, account);
    }

    /**
     * @param account Address to revoke royalty setter role from
     */
    function revokeRoyaltySetter(address account) external onlyOwner {
        _revokeRole(ROYALTY_SETTER_ROLE, account);
    }

    modifier royaltySetterOrOwner() {
        if (!hasRole(ROYALTY_SETTER_ROLE, _msgSender()) && !hasRole(OWNER_ROLE, _msgSender())) {
            revert NotRoyaltySetterOrOwner(_msgSender());
        }
        _;
    }
}
// SPDX-License-Identifier: MIT

pragma solidity 0.8.17;

import "../interfaces/IERC4906.sol";

abstract contract ERC4906 is IERC4906 {
    function notifyMetadataUpdate(uint256 tokenId) external virtual {
        emit MetadataUpdate(tokenId);
    }

    function supportsInterface(bytes4 interfaceId) public view virtual returns (bool) {
        return interfaceId == bytes4(0x49064906);
    }
}
// SPDX-License-Identifier: MIT

pragma solidity 0.8.17;

import { ERC721Burnable } from "@openzeppelin/contracts/token/ERC721/extensions/ERC721Burnable.sol";

abstract contract ERC721BatchBurnable is ERC721Burnable {
    function burnBatch(uint256[] calldata tokenIds) public virtual {
        for (uint256 id = 0; id < tokenIds.length; id++) {
            burn(tokenIds[id]);
        }
    }
}
// SPDX-License-Identifier: MIT

pragma solidity 0.8.17;

import { IERC721 } from "@openzeppelin/contracts/token/ERC721/IERC721.sol";

abstract contract ERC721BatchRetriever is IERC721 {
    /**
     * @param accounts Array of accounts to check balances
     * @return balances Array of balances of provided accounts
     */
    function retrieveMultipleBalances(address[] calldata accounts) external view returns (uint256[] memory balances) {
        balances = new uint256[](accounts.length);

        for (uint256 id = 0; id < accounts.length; id++) {
            balances[id] = this.balanceOf(accounts[id]);
        }
    }

    /**
     * @param tokenIds Array of token Ids to check owners of
     * @return owners Array of owners that own provided tokens
     */
    function retriveBatchOwners(uint256[] calldata tokenIds) external view returns (address[] memory owners) {
        owners = new address[](tokenIds.length);

        for (uint256 id = 0; id < tokenIds.length; id++) {
            owners[id] = this.ownerOf(tokenIds[id]);
        }
    }
}
// SPDX-License-Identifier: MIT

pragma solidity 0.8.17;

import "../interfaces/IERC721Mintable.sol";
import { MintableToken } from "./MintableToken.sol";
import { AccessControl } from "@openzeppelin/contracts/access/AccessControl.sol";

import { IERC165 } from "@openzeppelin/contracts/utils/introspection/IERC165.sol";
import { ERC721 } from "@openzeppelin/contracts/token/ERC721/ERC721.sol";

abstract contract ERC721Mintable is MintableToken, ERC721, IERC721Mintable {
    /**
     * @inheritdoc IERC165
     */
    function supportsInterface(bytes4 interfaceId) public view virtual override(ERC721, AccessControl) returns (bool) {
        return
            interfaceId == type(IERC721Mintable).interfaceId ||
            ERC721.supportsInterface(interfaceId) ||
            AccessControl.supportsInterface(interfaceId);
    }

    /**
     * @inheritdoc IERC721Mintable
     */
    function mintTo(address _to, uint256 _tokenId) external override minterOrOwner {
        _mintTo(_to, _tokenId);
    }

    /**
     * @param _to Address to mint token to
     * @param _tokenId Id of token to mint
     */
    function _mintTo(address _to, uint256 _tokenId) internal virtual {
        _safeMint(_to, _tokenId);
    }

    /**
     * @inheritdoc IERC721Mintable
     */
    function mintBatchTo(address _to, uint256[] calldata _tokenIds) external override minterOrOwner {
        _mintBatchTo(_to, _tokenIds);
    }

    /**
     * @inheritdoc IERC721Mintable
     */
    function mintBatchToMultiple(
        address[] calldata _to,
        uint256[][] calldata _tokenIds
    ) external override minterOrOwner {
        for (uint256 i = 0; i < _to.length; i++) {
            _mintBatchTo(_to[i], _tokenIds[i]);
        }
    }

    /**
     * @param _to Address to mint token to
     * @param _tokenIds Array with token ids to mint
     */
    function _mintBatchTo(address _to, uint256[] calldata _tokenIds) internal {
        uint256 length = _tokenIds.length;
        for (uint256 i = 0; i < length; i++) {
            _mintTo(_to, _tokenIds[i]);
        }
    }
}
// SPDX-License-Identifier: MIT

pragma solidity ^0.8.17;

import { ERC721 } from "@openzeppelin/contracts/token/ERC721/ERC721.sol";

import "./ERC4906.sol";
import "./TokenMetadata.sol";

abstract contract ERC721Metadata is ContractMetadata, ERC721 {
    using Strings for uint256;

    string internal _tokenBaseURI;

    /******************************************************************************/
    /*                                   ERC165                                   */
    /******************************************************************************/

    /**
     * @param interfaceId IntrefaceId to check
     * @return Is interface implemented or not
     */
    function supportsInterface(
        bytes4 interfaceId
    ) public view virtual override(ERC721, ContractMetadata) returns (bool) {
        return ERC721.supportsInterface(interfaceId) || ContractMetadata.supportsInterface(interfaceId);
    }

    /******************************************************************************/
    /*                               ERC721Metadata                               */
    /******************************************************************************/

    /**
     * @inheritdoc ERC721
     */
    function tokenURI(uint256 tokenId) public view virtual override returns (string memory) {
        if (bytes(_tokenBaseURI).length == 0) return "";

        return string(abi.encodePacked(_tokenBaseURI, tokenId.toString(), ".json"));
    }

    /**
     * @param uri_ Base token uri_
     * @param totalTokens Total supply when all tokens will be minted
     */
    function setTokenURI(string memory uri_, uint256 totalTokens) external onlyUriUpdater {
        _setTokenURI(uri_, totalTokens);
    }

    /**
     * @param uri_ New base URI for token metadata
     */
    function _setTokenURI(string memory uri_, uint256 totalTokens) internal override {
        emit BatchMetadataUpdate(0, totalTokens);
        _tokenBaseURI = uri_;
    }
}
// SPDX-License-Identifier: MIT

pragma solidity 0.8.17;

import "../interfaces/IERC1155Mintable.sol";
import "./TokenRoles.sol";

abstract contract MintableToken is TokenRoles {
    bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");

    error NotMinterOrOwner(address minter_);

    constructor(address minter_) {
        _setupRolesMintable(minter_);
    }

    /**
     * @dev Grants MINTER_ROLE to minter_ and sets OWNER_ROLE as admin role
     * @param minter_ Address to grant MINTER_ROLE to
     */
    function _setupRolesMintable(address minter_) private {
        _grantRole(MINTER_ROLE, minter_);
        _setRoleAdmin(MINTER_ROLE, OWNER_ROLE);
    }

    /******************************************************************************/
    /*                               AccessControl                                */
    /******************************************************************************/

    /**
     * @param _minter Address to grant minter role to
     */
    function addMinter(address _minter) external onlyOwner {
        _grantRole(MINTER_ROLE, _minter);
    }

    /**
     * @param _minter Address to revoke minter role from
     */
    function revokeMinter(address _minter) external onlyOwner {
        _revokeRole(MINTER_ROLE, _minter);
    }

    modifier minterOrOwner() {
        if (!hasRole(MINTER_ROLE, _msgSender()) && !hasRole(OWNER_ROLE, _msgSender())) {
            revert NotMinterOrOwner(_msgSender());
        }
        _;
    }
}
// SPDX-License-Identifier: MIT

pragma solidity ^0.8.17;

import "./ERC4906.sol";
import "./TokenRoles.sol";

abstract contract ContractMetadata is TokenRoles, ERC4906 {
    using Strings for uint256;

    error NotURIUpdater(address account);
    error NotMetadataUpdater(address account);

    event ContractURIUpdate(string newContractURI);

    string internal _contractURI;

    bytes32 public constant URI_UPDATER_ROLE = keccak256("URI_UPDATER_ROLE");
    bytes32 public constant METADATA_UPDATER_ROLE = keccak256("METADATA_UPDATER_ROLE");

    constructor(
        string memory contractURI_,
        string memory tokenBaseURI_,
        address uriUpdater_,
        address metadataUpdater_
    ) {
        require(bytes(contractURI_).length != 0, "ContractMetadata: contract uri cannot be empty!");

        _setContractURI(contractURI_);
        _setTokenURI(tokenBaseURI_, 0);
        _setupRolesMetadata(uriUpdater_, metadataUpdater_);
    }

    /******************************************************************************/
    /*                                 TokenRoles                                 */
    /******************************************************************************/

    /**
     *
     * @param uriUpdater_ Uri updater address
     * @param metadataUpdater_ Metadata updater address
     */
    function _setupRolesMetadata(address uriUpdater_, address metadataUpdater_) private {
        _grantRole(URI_UPDATER_ROLE, uriUpdater_);
        _setRoleAdmin(URI_UPDATER_ROLE, OWNER_ROLE);
        _grantRole(METADATA_UPDATER_ROLE, metadataUpdater_);
        _setRoleAdmin(METADATA_UPDATER_ROLE, OWNER_ROLE);
    }

    function addUriUpdater(address account) external onlyOwner {
        _grantRole(URI_UPDATER_ROLE, account);
    }

    function revokeUriUpdater(address account) external onlyOwner {
        _revokeRole(URI_UPDATER_ROLE, account);
    }

    function addMetadataUpdater(address account) external onlyOwner {
        _grantRole(METADATA_UPDATER_ROLE, account);
    }

    function revokeMetadataUpdater(address account) external onlyOwner {
        _revokeRole(METADATA_UPDATER_ROLE, account);
    }

    modifier onlyUriUpdater() {
        if (!hasRole(URI_UPDATER_ROLE, _msgSender()) && !hasRole(OWNER_ROLE, _msgSender())) {
            revert NotURIUpdater(_msgSender());
        }
        _;
    }

    modifier onlyMetadataUpdater() {
        if (!hasRole(METADATA_UPDATER_ROLE, _msgSender()) && !hasRole(OWNER_ROLE, _msgSender())) {
            revert NotMetadataUpdater(_msgSender());
        }
        _;
    }

    /******************************************************************************/
    /*                                   ERC165                                   */
    /******************************************************************************/

    /**
     * @param interfaceId IntrefaceId to check
     * @return Is interface implemented or not
     */
    function supportsInterface(bytes4 interfaceId) public view virtual override(ERC4906, AccessControl) returns (bool) {
        return ERC4906.supportsInterface(interfaceId) || AccessControl.supportsInterface(interfaceId);
    }

    /******************************************************************************/
    /*                              ContractMetadata                              */
    /******************************************************************************/

    function contractURI() public view virtual returns (string memory) {
        return _contractURI;
    }

    /**
     * @param uri_ New contract URI
     */
    function _setContractURI(string memory uri_) internal {
        emit ContractURIUpdate(uri_);
        _contractURI = uri_;
    }

    /**
     * @param uri_ Contract URI
     */
    function setContractURI(string memory uri_) external onlyUriUpdater {
        _setContractURI(uri_);
    }

    function _setTokenURI(string memory, uint256) internal virtual {}

    /******************************************************************************/
    /*                                  ERC4906                                   */
    /******************************************************************************/

    /**
     * @inheritdoc ERC4906
     */
    function notifyMetadataUpdate(uint256 tokenId) external override onlyMetadataUpdater {
        _notifyMetadataUpdate(tokenId);
    }

    function _notifyMetadataUpdate(uint256 tokenId) internal {
        emit MetadataUpdate(tokenId);
    }

    /**
     * @dev Notify metadata update
     * @param from First token id to update
     * @param to Last token id to update
     */
    function notifyBatchMetadataUpdate(uint256 from, uint256 to) external onlyMetadataUpdater {
        _notifyBatchMetadataUpdate(from, to);
    }

    function _notifyBatchMetadataUpdate(uint256 from, uint256 to) internal {
        emit BatchMetadataUpdate(from, to);
    }

    /**
     * @dev Notify metadata update for multiple tokens
     * @param tokenIds Array of token ids to update
     */
    function notifyMetadataUpdateForMultipleTokens(uint256[] calldata tokenIds) external onlyMetadataUpdater {
        for (uint256 i = 0; i < tokenIds.length; i++) {
            _notifyMetadataUpdate(tokenIds[i]);
        }
    }
}
// SPDX-License-Identifier: MIT

pragma solidity 0.8.17;

// Improt access control contracts
import "@openzeppelin/contracts/access/AccessControl.sol";

abstract contract TokenRoles is AccessControl {
    error NotOwner(address account);

    error FunctionDisabled(bytes4 selector);
    error CannotRevokeSelf(address owner_);

    bytes32 public constant OWNER_ROLE = keccak256("OWNER_ROLE");

    constructor(address owner_) {
        _setupRoles(owner_);
    }

    /**
     * @dev Grants OWNER_ROLE to owner_ and sets OWNER_ROLE as admin role
     * @param owner_ Address to grant OWNER_ROLE to
     */
    function _setupRoles(address owner_) private {
        _grantRole(OWNER_ROLE, owner_);
        _setRoleAdmin(OWNER_ROLE, OWNER_ROLE);
    }

    /**
     * @param owner_ Address to grant OWNER_ROLE to
     */
    function addOwner(address owner_) external onlyOwner {
        _grantRole(OWNER_ROLE, owner_);
    }

    /**
     * @param owner_ Address to revoke OWNER_ROLE from
     */
    function revokeOwner(address owner_) external onlyOwner {
        if (owner_ == _msgSender()) {
            revert CannotRevokeSelf(owner_);
        }
        _revokeRole(OWNER_ROLE, owner_);
    }

    function grantRole(bytes32, address) public pure override {
        revert FunctionDisabled(AccessControl.grantRole.selector);
    }

    function revokeRole(bytes32, address) public pure override {
        revert FunctionDisabled(AccessControl.revokeRole.selector);
    }

    function renounceRole(bytes32, address) public pure override {
        revert FunctionDisabled(AccessControl.renounceRole.selector);
    }

    /**
     * @dev Modifier to make a function callable only by the owner.
     */
    modifier onlyOwner() {
        if (!hasRole(OWNER_ROLE, _msgSender())) {
            revert NotOwner(_msgSender());
        }
        _;
    }
}
// SPDX-License-Identifier: MIT

pragma solidity 0.8.17;

interface IERC1155Mintable {
    /**
     * @param _to Address to mint token to
     * @param _tokenId Id of token to mint
     */
    function mintTo(address _to, uint256 _tokenId, uint256 _amount) external;

    /**
     * @param _to Address to mint token to
     * @param _tokenIds Array with token ids to mint
     * @param _amounts Array with token amounts to mint
     */
    function mintBatchTo(address _to, uint256[] calldata _tokenIds, uint256[] calldata _amounts) external;

    /**
     * @param _to Array of addresses to mint token to
     * @param _tokenIds Array of arrays with token ids to mint
     * @param _amounts Array of arrays with token amounts to mint
     */
    function mintBatchToMultiple(
        address[] calldata _to,
        uint256[][] calldata _tokenIds,
        uint256[][] calldata _amounts
    ) external;
}
// SPDX-License-Identifier: MIT

pragma solidity 0.8.17;

interface IERC2981Royalty {
    /**
     * @param receiver Who will receive royalty
     * @param royalty Numerator of the royalty fraction (royalty/10000)
     */
    function setDefaultRoyalty(address receiver, uint96 royalty) external;

    function resetDefaultRoyalty() external;

    /**
     * @param tokenId Token id to set royalty for
     * @param receiver Who will receive property
     * @param royalty Numerator of the royalty fraction (feeNumerator/10000)
     */
    function setTokenRoyalty(uint256 tokenId, address receiver, uint96 royalty) external;

    /**
     * @param tokenId Id of token to reset royalty for
     */
    function resetTokenRoyalty(uint256 tokenId) external;
}
// SPDX-License-Identifier: MIT

pragma solidity 0.8.17;

import "@openzeppelin/contracts/utils/introspection/IERC165.sol";

/// @title EIP-721 Metadata Update Extension
interface IERC4906 is IERC165 {
    /// @dev This event emits when the metadata of a token is changed.
    /// So that the third-party platforms such as NFT market could
    /// timely update the images and related attributes of the NFT.
    event MetadataUpdate(uint256 _tokenId);

    /// @dev This event emits when the metadata of a range of tokens is changed.
    /// So that the third-party platforms such as NFT market could
    /// timely update the images and related attributes of the NFTs.
    event BatchMetadataUpdate(uint256 _fromTokenId, uint256 _toTokenId);
}
// SPDX-License-Identifier: MIT

pragma solidity 0.8.17;

interface IERC721Mintable {
    /**
     * @param _to Address to mint token to
     * @param _tokenId Id of token to mint
     */
    function mintTo(address _to, uint256 _tokenId) external;

    /**
     * @param _to Address to mint token to
     * @param _tokenIds Array with token ids to mint
     */
    function mintBatchTo(address _to, uint256[] calldata _tokenIds) external;

    /**
     * @param _to Array of addresses to mint tokens to
     * @param _tokenIds Array of arrays with token ids to mint
     */
    function mintBatchToMultiple(address[] calldata _to, uint256[][] calldata _tokenIds) external;
}
// SPDX-License-Identifier: MIT

pragma solidity 0.8.17;

import { ERC721 } from "@openzeppelin/contracts/token/ERC721/ERC721.sol";

import "../../common/tokens/ERC721Default.sol";
import "../../blocklist/extensions/ERC721UserBlocklist.sol";

abstract contract ERC721Base is ERC721Default, ERC721UserBlocklist {
    constructor(
        string memory name_,
        string memory symbol_,
        address feeReceiver_,
        address royaltySetter_,
        string memory contractURI_,
        string memory tokenBaseURI_,
        address blocklist_,
        address owner_,
        address minter_,
        address uriUpdater_,
        address metadataUpdater_
    )
        ERC721Default(
            name_,
            symbol_,
            feeReceiver_,
            royaltySetter_,
            contractURI_,
            tokenBaseURI_,
            owner_,
            minter_,
            uriUpdater_,
            metadataUpdater_
        )
        ERC721UserBlocklist(blocklist_)
    {}

    /**
     * @inheritdoc ERC721UserBlocklist
     */
    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 tokenId
    ) internal virtual override(ERC721UserBlocklist, ERC721) {
        super._beforeTokenTransfer(from, to, tokenId);
    }

    function supportsInterface(
        bytes4 interfaceId
    ) public view virtual override(ERC721Default, ERC721UserBlocklist) returns (bool) {
        return ERC721Default.supportsInterface(interfaceId) || ERC721UserBlocklist.supportsInterface(interfaceId);
    }

    /**
     * @inheritdoc ERC721Default
     */
    function tokenURI(uint256 tokenId) public view virtual override(ERC721Default, ERC721) returns (string memory) {
        return super.tokenURI(tokenId);
    }

    /**
     * @param state - true to enable blocklist, false to disable
     */
    function changeBlocklistState(bool state) external onlyOwner {
        _changeBlocklistState(state);
    }

    /**
     * @param blocklist_ - address of the new blocklist
     */
    function changeBlocklist(address blocklist_) external onlyOwner {
        _setBlocklist(blocklist_);
    }
}
// SPDX-License-Identifier: MIT

pragma solidity 0.8.17;

import { ERC721Base } from "./base/ERC721TokenBase.sol";
import { ERC721BatchBurnable } from "../common/tokens/extensions/ERC721BatchBurnable.sol";

import { ERC721 } from "@openzeppelin/contracts/token/ERC721/ERC721.sol";

contract CharactersNFT is ERC721Base, ERC721BatchBurnable {
    constructor(
        string memory name_,
        string memory symbol_,
        string memory contractURI_,
        string memory tokenBaseURI_,
        address feeReceiver_,
        address royaltySetter_,
        address blocklist_,
        address owner_,
        address minter_,
        address uriUpdater_,
        address metadataUpdater_
    )
        ERC721Base(
            name_,
            symbol_,
            feeReceiver_,
            royaltySetter_,
            contractURI_,
            tokenBaseURI_,
            blocklist_,
            owner_,
            minter_,
            uriUpdater_,
            metadataUpdater_
        )
    {}

    /**
     * @inheritdoc ERC721Base
     */
    function tokenURI(uint256 tokenId) public view virtual override(ERC721Base, ERC721) returns (string memory) {
        return ERC721Base.tokenURI(tokenId);
    }

    /**
     * @inheritdoc ERC721Base
     */
    function supportsInterface(bytes4 interfaceId) public view virtual override(ERC721Base, ERC721) returns (bool) {
        return ERC721Base.supportsInterface(interfaceId);
    }

    /**
     * @inheritdoc ERC721Base
     */
    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 tokenId
    ) internal virtual override(ERC721Base, ERC721) {
        super._beforeTokenTransfer(from, to, tokenId);
    }
}
