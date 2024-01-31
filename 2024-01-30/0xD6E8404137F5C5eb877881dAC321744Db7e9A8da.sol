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
// OpenZeppelin Contracts v4.4.1 (utils/cryptography/draft-EIP712.sol)

pragma solidity ^0.8.0;

import "./ECDSA.sol";

/**
 * @dev https://eips.ethereum.org/EIPS/eip-712[EIP 712] is a standard for hashing and signing of typed structured data.
 *
 * The encoding specified in the EIP is very generic, and such a generic implementation in Solidity is not feasible,
 * thus this contract does not implement the encoding itself. Protocols need to implement the type-specific encoding
 * they need in their contracts using a combination of `abi.encode` and `keccak256`.
 *
 * This contract implements the EIP 712 domain separator ({_domainSeparatorV4}) that is used as part of the encoding
 * scheme, and the final step of the encoding to obtain the message digest that is then signed via ECDSA
 * ({_hashTypedDataV4}).
 *
 * The implementation of the domain separator was designed to be as efficient as possible while still properly updating
 * the chain id to protect against replay attacks on an eventual fork of the chain.
 *
 * NOTE: This contract implements the version of the encoding known as "v4", as implemented by the JSON RPC method
 * https://docs.metamask.io/guide/signing-data.html[`eth_signTypedDataV4` in MetaMask].
 *
 * _Available since v3.4._
 */
abstract contract EIP712 {
    /* solhint-disable var-name-mixedcase */
    // Cache the domain separator as an immutable value, but also store the chain id that it corresponds to, in order to
    // invalidate the cached domain separator if the chain id changes.
    bytes32 private immutable _CACHED_DOMAIN_SEPARATOR;
    uint256 private immutable _CACHED_CHAIN_ID;
    address private immutable _CACHED_THIS;

    bytes32 private immutable _HASHED_NAME;
    bytes32 private immutable _HASHED_VERSION;
    bytes32 private immutable _TYPE_HASH;

    /* solhint-enable var-name-mixedcase */

    /**
     * @dev Initializes the domain separator and parameter caches.
     *
     * The meaning of `name` and `version` is specified in
     * https://eips.ethereum.org/EIPS/eip-712#definition-of-domainseparator[EIP 712]:
     *
     * - `name`: the user readable name of the signing domain, i.e. the name of the DApp or the protocol.
     * - `version`: the current major version of the signing domain.
     *
     * NOTE: These parameters cannot be changed except through a xref:learn::upgrading-smart-contracts.adoc[smart
     * contract upgrade].
     */
    constructor(string memory name, string memory version) {
        bytes32 hashedName = keccak256(bytes(name));
        bytes32 hashedVersion = keccak256(bytes(version));
        bytes32 typeHash = keccak256(
            "EIP712Domain(string name,string version,uint256 chainId,address verifyingContract)"
        );
        _HASHED_NAME = hashedName;
        _HASHED_VERSION = hashedVersion;
        _CACHED_CHAIN_ID = block.chainid;
        _CACHED_DOMAIN_SEPARATOR = _buildDomainSeparator(typeHash, hashedName, hashedVersion);
        _CACHED_THIS = address(this);
        _TYPE_HASH = typeHash;
    }

    /**
     * @dev Returns the domain separator for the current chain.
     */
    function _domainSeparatorV4() internal view returns (bytes32) {
        if (address(this) == _CACHED_THIS && block.chainid == _CACHED_CHAIN_ID) {
            return _CACHED_DOMAIN_SEPARATOR;
        } else {
            return _buildDomainSeparator(_TYPE_HASH, _HASHED_NAME, _HASHED_VERSION);
        }
    }

    function _buildDomainSeparator(
        bytes32 typeHash,
        bytes32 nameHash,
        bytes32 versionHash
    ) private view returns (bytes32) {
        return keccak256(abi.encode(typeHash, nameHash, versionHash, block.chainid, address(this)));
    }

    /**
     * @dev Given an already https://eips.ethereum.org/EIPS/eip-712#definition-of-hashstruct[hashed struct], this
     * function returns the hash of the fully encoded EIP712 message for this domain.
     *
     * This hash can be used together with {ECDSA-recover} to obtain the signer of a message. For example:
     *
     * ```solidity
     * bytes32 digest = _hashTypedDataV4(keccak256(abi.encode(
     *     keccak256("Mail(address to,string contents)"),
     *     mailTo,
     *     keccak256(bytes(mailContents))
     * )));
     * address signer = ECDSA.recover(digest, signature);
     * ```
     */
    function _hashTypedDataV4(bytes32 structHash) internal view virtual returns (bytes32) {
        return ECDSA.toTypedDataHash(_domainSeparatorV4(), structHash);
    }
}
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.7.3) (utils/cryptography/ECDSA.sol)

pragma solidity ^0.8.0;

import "../Strings.sol";

/**
 * @dev Elliptic Curve Digital Signature Algorithm (ECDSA) operations.
 *
 * These functions can be used to verify that a message was signed by the holder
 * of the private keys of a given address.
 */
library ECDSA {
    enum RecoverError {
        NoError,
        InvalidSignature,
        InvalidSignatureLength,
        InvalidSignatureS,
        InvalidSignatureV
    }

    function _throwError(RecoverError error) private pure {
        if (error == RecoverError.NoError) {
            return; // no error: do nothing
        } else if (error == RecoverError.InvalidSignature) {
            revert("ECDSA: invalid signature");
        } else if (error == RecoverError.InvalidSignatureLength) {
            revert("ECDSA: invalid signature length");
        } else if (error == RecoverError.InvalidSignatureS) {
            revert("ECDSA: invalid signature 's' value");
        } else if (error == RecoverError.InvalidSignatureV) {
            revert("ECDSA: invalid signature 'v' value");
        }
    }

    /**
     * @dev Returns the address that signed a hashed message (`hash`) with
     * `signature` or error string. This address can then be used for verification purposes.
     *
     * The `ecrecover` EVM opcode allows for malleable (non-unique) signatures:
     * this function rejects them by requiring the `s` value to be in the lower
     * half order, and the `v` value to be either 27 or 28.
     *
     * IMPORTANT: `hash` _must_ be the result of a hash operation for the
     * verification to be secure: it is possible to craft signatures that
     * recover to arbitrary addresses for non-hashed data. A safe way to ensure
     * this is by receiving a hash of the original message (which may otherwise
     * be too long), and then calling {toEthSignedMessageHash} on it.
     *
     * Documentation for signature generation:
     * - with https://web3js.readthedocs.io/en/v1.3.4/web3-eth-accounts.html#sign[Web3.js]
     * - with https://docs.ethers.io/v5/api/signer/#Signer-signMessage[ethers]
     *
     * _Available since v4.3._
     */
    function tryRecover(bytes32 hash, bytes memory signature) internal pure returns (address, RecoverError) {
        if (signature.length == 65) {
            bytes32 r;
            bytes32 s;
            uint8 v;
            // ecrecover takes the signature parameters, and the only way to get them
            // currently is to use assembly.
            /// @solidity memory-safe-assembly
            assembly {
                r := mload(add(signature, 0x20))
                s := mload(add(signature, 0x40))
                v := byte(0, mload(add(signature, 0x60)))
            }
            return tryRecover(hash, v, r, s);
        } else {
            return (address(0), RecoverError.InvalidSignatureLength);
        }
    }

    /**
     * @dev Returns the address that signed a hashed message (`hash`) with
     * `signature`. This address can then be used for verification purposes.
     *
     * The `ecrecover` EVM opcode allows for malleable (non-unique) signatures:
     * this function rejects them by requiring the `s` value to be in the lower
     * half order, and the `v` value to be either 27 or 28.
     *
     * IMPORTANT: `hash` _must_ be the result of a hash operation for the
     * verification to be secure: it is possible to craft signatures that
     * recover to arbitrary addresses for non-hashed data. A safe way to ensure
     * this is by receiving a hash of the original message (which may otherwise
     * be too long), and then calling {toEthSignedMessageHash} on it.
     */
    function recover(bytes32 hash, bytes memory signature) internal pure returns (address) {
        (address recovered, RecoverError error) = tryRecover(hash, signature);
        _throwError(error);
        return recovered;
    }

    /**
     * @dev Overload of {ECDSA-tryRecover} that receives the `r` and `vs` short-signature fields separately.
     *
     * See https://eips.ethereum.org/EIPS/eip-2098[EIP-2098 short signatures]
     *
     * _Available since v4.3._
     */
    function tryRecover(
        bytes32 hash,
        bytes32 r,
        bytes32 vs
    ) internal pure returns (address, RecoverError) {
        bytes32 s = vs & bytes32(0x7fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff);
        uint8 v = uint8((uint256(vs) >> 255) + 27);
        return tryRecover(hash, v, r, s);
    }

    /**
     * @dev Overload of {ECDSA-recover} that receives the `r and `vs` short-signature fields separately.
     *
     * _Available since v4.2._
     */
    function recover(
        bytes32 hash,
        bytes32 r,
        bytes32 vs
    ) internal pure returns (address) {
        (address recovered, RecoverError error) = tryRecover(hash, r, vs);
        _throwError(error);
        return recovered;
    }

    /**
     * @dev Overload of {ECDSA-tryRecover} that receives the `v`,
     * `r` and `s` signature fields separately.
     *
     * _Available since v4.3._
     */
    function tryRecover(
        bytes32 hash,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) internal pure returns (address, RecoverError) {
        // EIP-2 still allows signature malleability for ecrecover(). Remove this possibility and make the signature
        // unique. Appendix F in the Ethereum Yellow paper (https://ethereum.github.io/yellowpaper/paper.pdf), defines
        // the valid range for s in (301): 0 < s < secp256k1n ÷ 2 + 1, and for v in (302): v ∈ {27, 28}. Most
        // signatures from current libraries generate a unique signature with an s-value in the lower half order.
        //
        // If your library generates malleable signatures, such as s-values in the upper range, calculate a new s-value
        // with 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFEBAAEDCE6AF48A03BBFD25E8CD0364141 - s1 and flip v from 27 to 28 or
        // vice versa. If your library also generates signatures with 0/1 for v instead 27/28, add 27 to v to accept
        // these malleable signatures as well.
        if (uint256(s) > 0x7FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF5D576E7357A4501DDFE92F46681B20A0) {
            return (address(0), RecoverError.InvalidSignatureS);
        }
        if (v != 27 && v != 28) {
            return (address(0), RecoverError.InvalidSignatureV);
        }

        // If the signature is valid (and not malleable), return the signer address
        address signer = ecrecover(hash, v, r, s);
        if (signer == address(0)) {
            return (address(0), RecoverError.InvalidSignature);
        }

        return (signer, RecoverError.NoError);
    }

    /**
     * @dev Overload of {ECDSA-recover} that receives the `v`,
     * `r` and `s` signature fields separately.
     */
    function recover(
        bytes32 hash,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) internal pure returns (address) {
        (address recovered, RecoverError error) = tryRecover(hash, v, r, s);
        _throwError(error);
        return recovered;
    }

    /**
     * @dev Returns an Ethereum Signed Message, created from a `hash`. This
     * produces hash corresponding to the one signed with the
     * https://eth.wiki/json-rpc/API#eth_sign[`eth_sign`]
     * JSON-RPC method as part of EIP-191.
     *
     * See {recover}.
     */
    function toEthSignedMessageHash(bytes32 hash) internal pure returns (bytes32) {
        // 32 is the length in bytes of hash,
        // enforced by the type signature above
        return keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n32", hash));
    }

    /**
     * @dev Returns an Ethereum Signed Message, created from `s`. This
     * produces hash corresponding to the one signed with the
     * https://eth.wiki/json-rpc/API#eth_sign[`eth_sign`]
     * JSON-RPC method as part of EIP-191.
     *
     * See {recover}.
     */
    function toEthSignedMessageHash(bytes memory s) internal pure returns (bytes32) {
        return keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n", Strings.toString(s.length), s));
    }

    /**
     * @dev Returns an Ethereum Signed Typed Data, created from a
     * `domainSeparator` and a `structHash`. This produces hash corresponding
     * to the one signed with the
     * https://eips.ethereum.org/EIPS/eip-712[`eth_signTypedData`]
     * JSON-RPC method as part of EIP-712.
     *
     * See {recover}.
     */
    function toTypedDataHash(bytes32 domainSeparator, bytes32 structHash) internal pure returns (bytes32) {
        return keccak256(abi.encodePacked("\x19\x01", domainSeparator, structHash));
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

library ArrayUtils {
    error EmptyArray();

    error NotSubarray();

    error UnsortedArray(uint256 id);

    error DuplicateId(uint256 id, uint256 index);

    error NotInArray(uint256 id);

    /**
     * @param tokenIds Array of token ids to be zipped
     */
    function revertIfArrayIsEmpty(uint256[] memory tokenIds) internal pure {
        if (tokenIds.length == 0) {
            revert EmptyArray();
        }
    }

    /**
     *
     * @param tokenIds Array of token ids to be zipped
     */
    function revertIfArrayIsNotSorted(uint256[] memory tokenIds) internal pure {
        for (uint256 i = 0; i < tokenIds.length - 1; i++) {
            if (tokenIds[i] >= tokenIds[i + 1]) {
                revert UnsortedArray(i);
            }
        }
    }

    /**
     * @dev Checks if lead token id is not in the array of token ids
     * @param leadId Lead token id
     * @param tokenIds Array of token ids to be zipped
     */
    function revertIfDuplicatedIdInArray(uint256 leadId, uint256[] memory tokenIds) internal pure {
        for (uint256 i = 0; i < tokenIds.length; i++) {
            if (tokenIds[i] == leadId) {
                revert DuplicateId(leadId, i);
            }
        }
    }

    /**
     *
     * @param mainArray Main array
     * @param subArray Sub array to be checked
     */
    function revertIfNotSubarray(uint256[] memory mainArray, uint256[] memory subArray) internal pure {
        uint256 mainArrayLength = mainArray.length;
        uint256 subArrayLength = subArray.length;

        if (subArrayLength > mainArrayLength) {
            revert NotSubarray();
        }

        uint256 mainArrayCounter;
        uint256 subArrayCounter;

        while (mainArrayCounter < mainArrayLength && subArrayCounter < subArrayLength) {
            if (mainArray[mainArrayCounter] == subArray[subArrayCounter]) {
                subArrayCounter++;
            }
            mainArrayCounter++;
        }

        if (subArrayCounter != subArrayLength) {
            revert NotSubarray();
        }
    }

    /**
     * @dev Checks if there are any entries of subArray in mainArray
     * @param mainArray Main array
     * @param subArray Sub array to be checked
     */
    function revertIfDuplicatesFound(uint256[] memory mainArray, uint256[] memory subArray) internal pure {
        uint256 mainArrayLength = mainArray.length;
        uint256 subArrayLength = subArray.length;

        uint256 mainArrayCounter;
        uint256 subArrayCounter;

        while (mainArrayCounter < mainArrayLength && subArrayCounter < subArrayLength) {
            while (mainArray[mainArrayCounter] < subArray[subArrayCounter]) {
                mainArrayCounter++;
                if (mainArrayCounter == mainArrayLength) {
                    return;
                }
            }
            if (mainArray[mainArrayCounter] == subArray[subArrayCounter]) {
                revert DuplicateId(subArray[subArrayCounter], subArrayCounter);
            }
            subArrayCounter++;
            mainArrayCounter++;
        }
    }

    /**
     * @dev Remove subArray from mainArray
     * @param mainArray Main array
     * @param arrayToSubstract Sub array
     */
    function substractArray(
        uint256[] memory mainArray,
        uint256[] memory arrayToSubstract
    ) internal pure returns (uint256[] memory result) {
        uint256 mainArrayLength = mainArray.length;
        uint256 subArrayLength = arrayToSubstract.length;

        result = new uint256[](mainArrayLength - subArrayLength);

        uint256 mainArrayCounter;
        uint256 subArrayCounter;

        while (mainArrayCounter < mainArrayLength) {
            if (subArrayCounter < subArrayLength && mainArray[mainArrayCounter] == arrayToSubstract[subArrayCounter]) {
                subArrayCounter++;
            } else {
                result[mainArrayCounter - subArrayCounter] = mainArray[mainArrayCounter];
            }
            mainArrayCounter++;
        }

        return result;
    }

    /**
     * @dev Merge two arrays
     * @param mainArray Main array
     * @param subArray Sub array
     */
    function mergeArrays(
        uint256[] memory mainArray,
        uint256[] memory subArray
    ) internal pure returns (uint256[] memory result) {
        uint256 mainArrayLength = mainArray.length;
        uint256 subArrayLength = subArray.length;

        result = new uint256[](mainArrayLength + subArrayLength);

        uint256 mainArrayCounter;
        uint256 subArrayCounter;
        uint256 resultCounter;

        while (mainArrayCounter < mainArrayLength && subArrayCounter < subArrayLength) {
            if (mainArray[mainArrayCounter] < subArray[subArrayCounter]) {
                result[resultCounter] = mainArray[mainArrayCounter];
                mainArrayCounter++;
            } else {
                result[resultCounter] = subArray[subArrayCounter];
                subArrayCounter++;
            }
            resultCounter++;
        }

        if (mainArrayCounter < mainArrayLength) {
            for (; mainArrayCounter < mainArrayLength; mainArrayCounter++) {
                result[resultCounter] = mainArray[mainArrayCounter];
                resultCounter++;
            }
        } else {
            for (; subArrayCounter < subArrayLength; subArrayCounter++) {
                result[resultCounter] = subArray[subArrayCounter];
                resultCounter++;
            }
        }

        return result;
    }
}
// SPDX-License-Identifier: MIT

pragma solidity 0.8.17;

import { AccessControl } from "@openzeppelin/contracts/access/AccessControl.sol";

contract DefaultRoles is AccessControl {
    error OnlyOwner(address sender);
    error OnlyAdmin(address sender);
    error OnlyExecutor(address sender);

    error CannotRemoveSelf(address owner);

    error FunctionDisabled(bytes4 functionId);

    bytes32 public constant OWNER_ROLE = keccak256("OWNER_ROLE");
    bytes32 public constant ADMIN_ROLE = keccak256("ADMIN_ROLE");
    bytes32 public constant EXECUTOR_ROLE = keccak256("EXECUTOR_ROLE");

    /**
     *
     * @param owner Address of the owner
     * @param admin Address of the admin
     * @param executors Addresses of the executors
     */
    constructor(address owner, address admin, address[] memory executors) AccessControl() {
        _grantRole(OWNER_ROLE, owner);
        _grantRole(ADMIN_ROLE, admin);
        _addExecutors(executors);
    }

    /**
     *
     * @param owner Address of the owner to add
     */
    function addOwner(address owner) external virtual onlyOwner {
        _addOwner(owner);
    }

    function _addOwner(address owner) internal virtual {
        _grantRole(OWNER_ROLE, owner);
    }

    /**
     *
     * @param owner Address of the owner ro revoke
     */
    function revokeOwner(address owner) external virtual onlyOwner {
        if (owner == _msgSender()) {
            revert CannotRemoveSelf(owner);
        }
        _revokeOwner(owner);
    }

    function _revokeOwner(address owner) internal virtual {
        _revokeRole(OWNER_ROLE, owner);
    }

    /**
     *
     * @param admin Address of the admin to add
     */
    function addAdmin(address admin) external virtual onlyOwner {
        _addAdmin(admin);
    }

    function _addAdmin(address admin) internal virtual {
        _grantRole(ADMIN_ROLE, admin);
    }

    /**
     *
     * @param admin Address of the admin to revoke
     */
    function revokeAdmin(address admin) external virtual onlyOwner {
        _revokeAdmin(admin);
    }

    function _revokeAdmin(address admin) internal virtual {
        _revokeRole(ADMIN_ROLE, admin);
    }

    /**
     *
     * @param executors Addresses of the executors to add
     */
    function addExecutors(address[] calldata executors) external virtual onlyAdmin {
        _addExecutors(executors);
    }

    /**
     *
     * @param executors Addresses of the executors to revoke
     */
    function revokeExecutors(address[] calldata executors) external virtual onlyAdmin {
        for (uint256 i = 0; i < executors.length; i++) {
            _revokeRole(EXECUTOR_ROLE, executors[i]);
        }
    }

    /**
     *
     * @param executors Addresses of the executors to add
     */
    function _addExecutors(address[] memory executors) internal virtual {
        for (uint256 i = 0; i < executors.length; i++) {
            _addExecutor(executors[i]);
        }
    }

    function _addExecutor(address executor) internal virtual {
        _grantRole(EXECUTOR_ROLE, executor);
    }

    /**
     * @inheritdoc AccessControl
     */
    function grantRole(bytes32, address) public virtual override {
        revert FunctionDisabled(AccessControl.grantRole.selector);
    }

    /**
     * @inheritdoc AccessControl
     */
    function revokeRole(bytes32, address) public virtual override {
        revert FunctionDisabled(AccessControl.revokeRole.selector);
    }

    /**
     * @inheritdoc AccessControl
     */
    function renounceRole(bytes32, address) public virtual override {
        revert FunctionDisabled(AccessControl.renounceRole.selector);
    }

    modifier onlyOwner() {
        if (!hasRole(OWNER_ROLE, _msgSender())) {
            revert OnlyOwner(_msgSender());
        }
        _;
    }

    modifier onlyAdmin() {
        if (!hasRole(ADMIN_ROLE, _msgSender())) {
            revert OnlyAdmin(_msgSender());
        }
        _;
    }

    modifier onlyExecutor() {
        if (!hasRole(EXECUTOR_ROLE, _msgSender())) {
            revert OnlyExecutor(_msgSender());
        }
        _;
    }
}
// SPDX-License-Identifier: MIT

pragma solidity 0.8.17;

import { EIP712 } from "@openzeppelin/contracts/utils/cryptography/draft-EIP712.sol";
import { Pausable } from "@openzeppelin/contracts/security/Pausable.sol";
import { ReentrancyGuard } from "@openzeppelin/contracts/security/ReentrancyGuard.sol";

import { DefaultRoles } from "../common/utils/DefaultRoles.sol";

import { ISignatureVerification } from "../signature-verifier/interfaces/ISignatureVerification.sol";
import { SignatureVerificationExt } from "../signature-verifier/extensions/SignatureVerificationExt.sol";

import { IMinter } from "../token-minter/interfaces/IMinter.sol";
import { IGameMinter } from "./interfaces/IGameMinter.sol";

import { ArrayUtils } from "../common/utils/ArrayUtils.sol";

contract GameMinter is IGameMinter, EIP712, SignatureVerificationExt, Pausable, ReentrancyGuard {
    error InvalidTokenOrder(uint256 id);
    bytes32 constant OFFCHAIN_ASSETS_TYPEHASH =
        keccak256("OffchainAsset(address contractAddress,uint256 tokenId,uint256 amount)");
    bytes32 constant WITHDRAW_REQUEST_TYPEHASH =
        keccak256(
            "WithdrawRequest(address user,uint256 nonce,OffchainAsset[] assets,uint256 deadline)OffchainAsset(address contractAddress,uint256 tokenId,uint256 amount)"
        );
    IMinter public tokenMinter;

    mapping(address => uint256) public userNonces;

    /// @param owner_ Address of the owner
    /// @param admin_ Address of the admin
    /// @param signatureVerifier_ Address of the external signature verifier
    /// @param tokenMinter_ Address of the external token minter
    constructor(
        address owner_,
        address admin_,
        address signatureVerifier_,
        address tokenMinter_
    )
        EIP712("GameMinter", "1")
        DefaultRoles(owner_, admin_, new address[](0))
        SignatureVerificationExt(signatureVerifier_)
    {
        tokenMinter = IMinter(tokenMinter_);
    }

    // Disable receiving eth by plain transfers
    receive() external payable {
        revert();
    }

    fallback() external payable {
        revert();
    }

    /// @inheritdoc IGameMinter
    function mintGameAssets(
        OffchainAsset[] calldata offchainAssets,
        ISignatureVerification.Signature[] calldata sigs,
        uint256[] calldata deadlines
    ) external whenNotPaused nonReentrant {
        uint256 nonce = userNonces[msg.sender];

        bytes32[] memory digests = new bytes32[](deadlines.length);

        for (uint256 id = 0; id < deadlines.length; id++) {
            digests[id] = _getWithdrawRequestHash(offchainAssets, deadlines[id], nonce);
        }

        _verifySignatures(sigs, digests);

        userNonces[msg.sender] = nonce + 1;

        uint256 assetsLen = offchainAssets.length;

        for (uint256 assetId = 0; assetId < assetsLen; assetId++) {
            OffchainAsset memory oa = offchainAssets[assetId];
            emit GameAssetWithdrawn(msg.sender, nonce, oa.contractAddress, oa.tokenId, oa.amount);
            tokenMinter.mint(oa.contractAddress, msg.sender, oa.tokenId, oa.amount, "");
        }
    }

    /// @dev creates hash for ephemeral structure WithdrawRequest that is used for signing
    /// @param offchainAssets Offchain assets to withdraw
    /// @param deadline Deadline
    /// @param nonce Nonce of withdraw
    function _getWithdrawRequestHash(
        OffchainAsset[] calldata offchainAssets,
        uint256 deadline,
        uint256 nonce
    ) internal view returns (bytes32) {
        bytes32 structHash = keccak256(
            abi.encode(WITHDRAW_REQUEST_TYPEHASH, msg.sender, nonce, _getOffchainAssetHash(offchainAssets), deadline)
        );

        bytes32 digest = _hashTypedDataV4(structHash);

        return digest;
    }

    /// @dev Creates hash for structure
    /// @param oa Offchain assets to get hash from
    function _getOffchainAssetHash(OffchainAsset[] calldata oa) internal pure returns (bytes32) {
        bytes32[] memory offchainItemsHash = new bytes32[](oa.length);
        for (uint256 id = 0; id < oa.length; id++) {
            offchainItemsHash[id] = keccak256(
                abi.encode(OFFCHAIN_ASSETS_TYPEHASH, oa[id].contractAddress, oa[id].tokenId, oa[id].amount)
            );
        }

        return keccak256(abi.encodePacked(offchainItemsHash));
    }

    /// @notice Pause contract
    function pause() external onlyAdmin {
        _pause();
    }

    /// @notice Unpause contract
    function unpause() external onlyAdmin {
        _unpause();
    }
}
// SPDX-License-Identifier: MIT

pragma solidity 0.8.17;

import { ISignatureVerification } from "../../signature-verifier/interfaces/ISignatureVerification.sol";

interface IGameMinter {
    struct OffchainAsset {
        address contractAddress;
        uint256 tokenId;
        uint256 amount;
    }

    /// @param user Address of the user
    /// @param nonce Nonce of the withdraw
    /// @param contractAddress Address of the target contract
    /// @param tokenId Id of the target token
    /// @param amount Amount of tokens that was minted
    event GameAssetWithdrawn(
        address indexed user,
        uint256 indexed nonce,
        address contractAddress,
        uint256 tokenId,
        uint256 amount
    );

    /// @notice Mint offchain assests
    /// @param offchainAssets Offchain assets to withdraw, ERC721 and ERC1155 are supported
    /// @param sigs Signatures for withdraw
    /// @param deadlines Deadlines for the withdraw
    function mintGameAssets(
        OffchainAsset[] calldata offchainAssets,
        ISignatureVerification.Signature[] calldata sigs,
        uint256[] calldata deadlines
    ) external;
}
// SPDX-License-Identifier: MIT

pragma solidity 0.8.17;

import { DefaultRoles } from "../../common/utils/DefaultRoles.sol";
import { ISignatureVerification } from "../interfaces/ISignatureVerification.sol";

abstract contract SignatureVerificationExt is DefaultRoles {
    event SignatureVerifierChanged(address indexed newSignatureVerifier, address indexed oldSignatureVerifier);
    error SignatureVerifierZeroAddress();

    ISignatureVerification public signatureVerifier;

    /**
     *
     * @param signatureVerifier_ The address of the signature verifier.
     */
    constructor(address signatureVerifier_) {
        _setSignatureVerifier(signatureVerifier_);
    }

    function _verifySignatures(
        ISignatureVerification.Signature[] memory signerInfo,
        bytes32[] memory digests
    ) internal {
        signatureVerifier.verifySignatures(signerInfo, digests);
    }

    /**
     *
     * @param signatureVerifier_ The address of the new signature verifier.
     */
    function _setSignatureVerifier(address signatureVerifier_) internal {
        if (signatureVerifier_ == address(0)) {
            revert SignatureVerifierZeroAddress();
        }
        if (signatureVerifier_ == address(signatureVerifier)) {
            return;
        }
        emit SignatureVerifierChanged(signatureVerifier_, address(signatureVerifier));
        signatureVerifier = ISignatureVerification(signatureVerifier_);
    }

    /**
     *
     * @param signatureVerifier_ The address of the new signature verifier.
     */
    function setSignatureVerifier(address signatureVerifier_) external onlyAdmin {
        _setSignatureVerifier(signatureVerifier_);
    }
}
// SPDX-License-Identifier: MIT

pragma solidity 0.8.17;

interface ISignatureVerification {
    struct Signature {
        bytes32 r;
        bytes32 s;
        uint8 v;
    }

    /**
     * @dev Checks if signatures are valid. If some kind of error is detected, it will revert.
     * @param signerInfo The signatures of the backend signers.
     * @param digests Hashed typed data.
     */
    function verifySignatures(Signature[] memory signerInfo, bytes32[] memory digests) external returns (bool);

    /**
     * @dev Returns true if the account is a signer.
     * @param account The address to check.
     */
    function isSigner(address account) external view returns (bool);

    /**
     * @dev Returns the amount of required signatures.
     */
    function requiredSignatures() external view returns (uint256);
}
// SPDX-License-Identifier: MIT

pragma solidity 0.8.17;

interface IMinter {
    /******************************************************************************/
    /*                   Multiple tokens for multiple receivers                   */
    /******************************************************************************/

    /**
     * @dev Mint multiple tokens for multiple receivers
     * @param token address of the token to mint
     * @param to Addresses of the receivers
     * @param tokenId Array of arrays of token ids to mint
     * @param amounts Amounts of tokens to mint (1-1 mapping with tokenIds), empty for ERC721
     * @param data Data to pass to the minter (currently unused)
     */
    function mint(
        address token,
        address[] calldata to,
        uint256[][] calldata tokenId,
        uint256[][] calldata amounts,
        bytes calldata data
    ) external;

    /**
     * @dev batch mint multiple tokens for multiple receivers
     */
    function batchMint(
        address[] calldata token,
        address[][] calldata to,
        uint256[][][] calldata tokenId,
        uint256[][][] calldata amounts,
        bytes[] calldata data
    ) external;

    /******************************************************************************/
    /*                      Multiple tokens for one receiver                      */
    /******************************************************************************/

    /**
     * @dev Mint multiple tokens for a single receiver
     * @param token address of the token to mint
     * @param to Address of the receiver
     * @param tokenId Array of token ids to mint
     * @param amounts Amounts of tokens to mint (1-1 mapping with tokenIds), empty for ERC721
     * @param data Data to pass to the minter (currently unused)
     */
    function mint(
        address token,
        address to,
        uint256[] calldata tokenId,
        uint256[] calldata amounts,
        bytes calldata data
    ) external;

    /**
     * @dev batch mint multiple tokens for a single receiver
     */
    function batchMint(
        address[] calldata token,
        address[] calldata to,
        uint256[][] calldata tokenId,
        uint256[][] calldata amounts,
        bytes[] calldata data
    ) external;

    /******************************************************************************/
    /*                        One token for each receiver                         */
    /******************************************************************************/

    /**
     * @dev Mint a single token for multiple receivers
     * @param token address of the token to mint
     * @param to Addresses of the receivers
     * @param tokenId Id of the token to mint
     * @param amounts Amounts of tokens to mint (1-1 mapping with tokenIds), empty for ERC721
     * @param data Data to pass to the minter (currently unused)
     */
    function mint(
        address token,
        address[] calldata to,
        uint256[] calldata tokenId,
        uint256[] calldata amounts,
        bytes calldata data
    ) external;

    /**
     * @dev batch mint a single token for multiple receivers
     */
    function batchMint(
        address[] calldata token,
        address[][] calldata to,
        uint256[][] calldata tokenId,
        uint256[][] calldata amounts,
        bytes[] calldata data
    ) external;

    /******************************************************************************/
    /*                         One token for one receiver                         */
    /******************************************************************************/

    /**
     * @dev Mint a single token for a single receiver
     * @param token address of the token to mint
     * @param to Address of the receiver
     * @param tokenId Id of the token to mint
     * @param amount Amount of tokens to mint, 0 for ERC721
     * @param data Data to pass to the minter (currently unused)
     */
    function mint(address token, address to, uint256 tokenId, uint256 amount, bytes calldata data) external;

    /**
     * @dev batch mint a single token for a single receiver
     */
    function batchMint(
        address[] calldata token,
        address[] calldata to,
        uint256[] calldata tokenId,
        uint256[] calldata amounts,
        bytes[] calldata data
    ) external;
}
