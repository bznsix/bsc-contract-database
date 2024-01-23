// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.9.0) (access/AccessControl.sol)

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
 * ```solidity
 * bytes32 public constant MY_ROLE = keccak256("MY_ROLE");
 * ```
 *
 * Roles can be used to represent a set of permissions. To restrict access to a
 * function call, use {hasRole}:
 *
 * ```solidity
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
 * accounts that have been granted it. We recommend using {AccessControlDefaultAdminRules}
 * to enforce additional security measures for this role.
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
                        Strings.toHexString(account),
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
// OpenZeppelin Contracts (last updated v4.9.0) (interfaces/IERC5267.sol)

pragma solidity ^0.8.0;

interface IERC5267 {
    /**
     * @dev MAY be emitted to signal that the domain could have changed.
     */
    event EIP712DomainChanged();

    /**
     * @dev returns the fields and values that describe the domain separator used by this contract for EIP-712
     * signature.
     */
    function eip712Domain()
        external
        view
        returns (
            bytes1 fields,
            string memory name,
            string memory version,
            uint256 chainId,
            address verifyingContract,
            bytes32 salt,
            uint256[] memory extensions
        );
}
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.9.0) (proxy/Clones.sol)

pragma solidity ^0.8.0;

/**
 * @dev https://eips.ethereum.org/EIPS/eip-1167[EIP 1167] is a standard for
 * deploying minimal proxy contracts, also known as "clones".
 *
 * > To simply and cheaply clone contract functionality in an immutable way, this standard specifies
 * > a minimal bytecode implementation that delegates all calls to a known, fixed address.
 *
 * The library includes functions to deploy a proxy using either `create` (traditional deployment) or `create2`
 * (salted deterministic deployment). It also includes functions to predict the addresses of clones deployed using the
 * deterministic method.
 *
 * _Available since v3.4._
 */
library Clones {
    /**
     * @dev Deploys and returns the address of a clone that mimics the behaviour of `implementation`.
     *
     * This function uses the create opcode, which should never revert.
     */
    function clone(address implementation) internal returns (address instance) {
        /// @solidity memory-safe-assembly
        assembly {
            // Cleans the upper 96 bits of the `implementation` word, then packs the first 3 bytes
            // of the `implementation` address with the bytecode before the address.
            mstore(0x00, or(shr(0xe8, shl(0x60, implementation)), 0x3d602d80600a3d3981f3363d3d373d3d3d363d73000000))
            // Packs the remaining 17 bytes of `implementation` with the bytecode after the address.
            mstore(0x20, or(shl(0x78, implementation), 0x5af43d82803e903d91602b57fd5bf3))
            instance := create(0, 0x09, 0x37)
        }
        require(instance != address(0), "ERC1167: create failed");
    }

    /**
     * @dev Deploys and returns the address of a clone that mimics the behaviour of `implementation`.
     *
     * This function uses the create2 opcode and a `salt` to deterministically deploy
     * the clone. Using the same `implementation` and `salt` multiple time will revert, since
     * the clones cannot be deployed twice at the same address.
     */
    function cloneDeterministic(address implementation, bytes32 salt) internal returns (address instance) {
        /// @solidity memory-safe-assembly
        assembly {
            // Cleans the upper 96 bits of the `implementation` word, then packs the first 3 bytes
            // of the `implementation` address with the bytecode before the address.
            mstore(0x00, or(shr(0xe8, shl(0x60, implementation)), 0x3d602d80600a3d3981f3363d3d373d3d3d363d73000000))
            // Packs the remaining 17 bytes of `implementation` with the bytecode after the address.
            mstore(0x20, or(shl(0x78, implementation), 0x5af43d82803e903d91602b57fd5bf3))
            instance := create2(0, 0x09, 0x37, salt)
        }
        require(instance != address(0), "ERC1167: create2 failed");
    }

    /**
     * @dev Computes the address of a clone deployed using {Clones-cloneDeterministic}.
     */
    function predictDeterministicAddress(
        address implementation,
        bytes32 salt,
        address deployer
    ) internal pure returns (address predicted) {
        /// @solidity memory-safe-assembly
        assembly {
            let ptr := mload(0x40)
            mstore(add(ptr, 0x38), deployer)
            mstore(add(ptr, 0x24), 0x5af43d82803e903d91602b57fd5bf3ff)
            mstore(add(ptr, 0x14), implementation)
            mstore(ptr, 0x3d602d80600a3d3981f3363d3d373d3d3d363d73)
            mstore(add(ptr, 0x58), salt)
            mstore(add(ptr, 0x78), keccak256(add(ptr, 0x0c), 0x37))
            predicted := keccak256(add(ptr, 0x43), 0x55)
        }
    }

    /**
     * @dev Computes the address of a clone deployed using {Clones-cloneDeterministic}.
     */
    function predictDeterministicAddress(
        address implementation,
        bytes32 salt
    ) internal view returns (address predicted) {
        return predictDeterministicAddress(implementation, salt, address(this));
    }
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
// OpenZeppelin Contracts (last updated v4.9.0) (utils/Address.sol)

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
     *
     * Furthermore, `isContract` will also return true if the target contract within
     * the same transaction is already scheduled for destruction by `SELFDESTRUCT`,
     * which only has an effect at the end of a transaction.
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
     * https://consensys.net/diligence/blog/2019/09/stop-using-soliditys-transfer-now/[Learn more].
     *
     * IMPORTANT: because control is transferred to `recipient`, care must be
     * taken to not create reentrancy vulnerabilities. Consider using
     * {ReentrancyGuard} or the
     * https://solidity.readthedocs.io/en/v0.8.0/security-considerations.html#use-the-checks-effects-interactions-pattern[checks-effects-interactions pattern].
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
    function functionCallWithValue(address target, bytes memory data, uint256 value) internal returns (bytes memory) {
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
// OpenZeppelin Contracts (last updated v4.9.0) (utils/cryptography/ECDSA.sol)

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
        InvalidSignatureV // Deprecated in v4.8
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
    function tryRecover(bytes32 hash, bytes32 r, bytes32 vs) internal pure returns (address, RecoverError) {
        bytes32 s = vs & bytes32(0x7fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff);
        uint8 v = uint8((uint256(vs) >> 255) + 27);
        return tryRecover(hash, v, r, s);
    }

    /**
     * @dev Overload of {ECDSA-recover} that receives the `r and `vs` short-signature fields separately.
     *
     * _Available since v4.2._
     */
    function recover(bytes32 hash, bytes32 r, bytes32 vs) internal pure returns (address) {
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
    function tryRecover(bytes32 hash, uint8 v, bytes32 r, bytes32 s) internal pure returns (address, RecoverError) {
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
    function recover(bytes32 hash, uint8 v, bytes32 r, bytes32 s) internal pure returns (address) {
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
    function toEthSignedMessageHash(bytes32 hash) internal pure returns (bytes32 message) {
        // 32 is the length in bytes of hash,
        // enforced by the type signature above
        /// @solidity memory-safe-assembly
        assembly {
            mstore(0x00, "\x19Ethereum Signed Message:\n32")
            mstore(0x1c, hash)
            message := keccak256(0x00, 0x3c)
        }
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
    function toTypedDataHash(bytes32 domainSeparator, bytes32 structHash) internal pure returns (bytes32 data) {
        /// @solidity memory-safe-assembly
        assembly {
            let ptr := mload(0x40)
            mstore(ptr, "\x19\x01")
            mstore(add(ptr, 0x02), domainSeparator)
            mstore(add(ptr, 0x22), structHash)
            data := keccak256(ptr, 0x42)
        }
    }

    /**
     * @dev Returns an Ethereum Signed Data with intended validator, created from a
     * `validator` and `data` according to the version 0 of EIP-191.
     *
     * See {recover}.
     */
    function toDataWithIntendedValidatorHash(address validator, bytes memory data) internal pure returns (bytes32) {
        return keccak256(abi.encodePacked("\x19\x00", validator, data));
    }
}
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.9.0) (utils/cryptography/EIP712.sol)

pragma solidity ^0.8.8;

import "./ECDSA.sol";
import "../ShortStrings.sol";
import "../../interfaces/IERC5267.sol";

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
 * NOTE: In the upgradeable version of this contract, the cached values will correspond to the address, and the domain
 * separator of the implementation contract. This will cause the `_domainSeparatorV4` function to always rebuild the
 * separator from the immutable values, which is cheaper than accessing a cached version in cold storage.
 *
 * _Available since v3.4._
 *
 * @custom:oz-upgrades-unsafe-allow state-variable-immutable state-variable-assignment
 */
abstract contract EIP712 is IERC5267 {
    using ShortStrings for *;

    bytes32 private constant _TYPE_HASH =
        keccak256("EIP712Domain(string name,string version,uint256 chainId,address verifyingContract)");

    // Cache the domain separator as an immutable value, but also store the chain id that it corresponds to, in order to
    // invalidate the cached domain separator if the chain id changes.
    bytes32 private immutable _cachedDomainSeparator;
    uint256 private immutable _cachedChainId;
    address private immutable _cachedThis;

    bytes32 private immutable _hashedName;
    bytes32 private immutable _hashedVersion;

    ShortString private immutable _name;
    ShortString private immutable _version;
    string private _nameFallback;
    string private _versionFallback;

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
        _name = name.toShortStringWithFallback(_nameFallback);
        _version = version.toShortStringWithFallback(_versionFallback);
        _hashedName = keccak256(bytes(name));
        _hashedVersion = keccak256(bytes(version));

        _cachedChainId = block.chainid;
        _cachedDomainSeparator = _buildDomainSeparator();
        _cachedThis = address(this);
    }

    /**
     * @dev Returns the domain separator for the current chain.
     */
    function _domainSeparatorV4() internal view returns (bytes32) {
        if (address(this) == _cachedThis && block.chainid == _cachedChainId) {
            return _cachedDomainSeparator;
        } else {
            return _buildDomainSeparator();
        }
    }

    function _buildDomainSeparator() private view returns (bytes32) {
        return keccak256(abi.encode(_TYPE_HASH, _hashedName, _hashedVersion, block.chainid, address(this)));
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

    /**
     * @dev See {EIP-5267}.
     *
     * _Available since v4.9._
     */
    function eip712Domain()
        public
        view
        virtual
        override
        returns (
            bytes1 fields,
            string memory name,
            string memory version,
            uint256 chainId,
            address verifyingContract,
            bytes32 salt,
            uint256[] memory extensions
        )
    {
        return (
            hex"0f", // 01111
            _name.toStringWithFallback(_nameFallback),
            _version.toStringWithFallback(_versionFallback),
            block.chainid,
            address(this),
            bytes32(0),
            new uint256[](0)
        );
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
// OpenZeppelin Contracts (last updated v4.9.0) (utils/math/Math.sol)

pragma solidity ^0.8.0;

/**
 * @dev Standard math utilities missing in the Solidity language.
 */
library Math {
    enum Rounding {
        Down, // Toward negative infinity
        Up, // Toward infinity
        Zero // Toward zero
    }

    /**
     * @dev Returns the largest of two numbers.
     */
    function max(uint256 a, uint256 b) internal pure returns (uint256) {
        return a > b ? a : b;
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
        // (a + b) / 2 can overflow.
        return (a & b) + (a ^ b) / 2;
    }

    /**
     * @dev Returns the ceiling of the division of two numbers.
     *
     * This differs from standard division with `/` in that it rounds up instead
     * of rounding down.
     */
    function ceilDiv(uint256 a, uint256 b) internal pure returns (uint256) {
        // (a + b - 1) / b can overflow on addition, so we distribute.
        return a == 0 ? 0 : (a - 1) / b + 1;
    }

    /**
     * @notice Calculates floor(x * y / denominator) with full precision. Throws if result overflows a uint256 or denominator == 0
     * @dev Original credit to Remco Bloemen under MIT license (https://xn--2-umb.com/21/muldiv)
     * with further edits by Uniswap Labs also under MIT license.
     */
    function mulDiv(uint256 x, uint256 y, uint256 denominator) internal pure returns (uint256 result) {
        unchecked {
            // 512-bit multiply [prod1 prod0] = x * y. Compute the product mod 2^256 and mod 2^256 - 1, then use
            // use the Chinese Remainder Theorem to reconstruct the 512 bit result. The result is stored in two 256
            // variables such that product = prod1 * 2^256 + prod0.
            uint256 prod0; // Least significant 256 bits of the product
            uint256 prod1; // Most significant 256 bits of the product
            assembly {
                let mm := mulmod(x, y, not(0))
                prod0 := mul(x, y)
                prod1 := sub(sub(mm, prod0), lt(mm, prod0))
            }

            // Handle non-overflow cases, 256 by 256 division.
            if (prod1 == 0) {
                // Solidity will revert if denominator == 0, unlike the div opcode on its own.
                // The surrounding unchecked block does not change this fact.
                // See https://docs.soliditylang.org/en/latest/control-structures.html#checked-or-unchecked-arithmetic.
                return prod0 / denominator;
            }

            // Make sure the result is less than 2^256. Also prevents denominator == 0.
            require(denominator > prod1, "Math: mulDiv overflow");

            ///////////////////////////////////////////////
            // 512 by 256 division.
            ///////////////////////////////////////////////

            // Make division exact by subtracting the remainder from [prod1 prod0].
            uint256 remainder;
            assembly {
                // Compute remainder using mulmod.
                remainder := mulmod(x, y, denominator)

                // Subtract 256 bit number from 512 bit number.
                prod1 := sub(prod1, gt(remainder, prod0))
                prod0 := sub(prod0, remainder)
            }

            // Factor powers of two out of denominator and compute largest power of two divisor of denominator. Always >= 1.
            // See https://cs.stackexchange.com/q/138556/92363.

            // Does not overflow because the denominator cannot be zero at this stage in the function.
            uint256 twos = denominator & (~denominator + 1);
            assembly {
                // Divide denominator by twos.
                denominator := div(denominator, twos)

                // Divide [prod1 prod0] by twos.
                prod0 := div(prod0, twos)

                // Flip twos such that it is 2^256 / twos. If twos is zero, then it becomes one.
                twos := add(div(sub(0, twos), twos), 1)
            }

            // Shift in bits from prod1 into prod0.
            prod0 |= prod1 * twos;

            // Invert denominator mod 2^256. Now that denominator is an odd number, it has an inverse modulo 2^256 such
            // that denominator * inv = 1 mod 2^256. Compute the inverse by starting with a seed that is correct for
            // four bits. That is, denominator * inv = 1 mod 2^4.
            uint256 inverse = (3 * denominator) ^ 2;

            // Use the Newton-Raphson iteration to improve the precision. Thanks to Hensel's lifting lemma, this also works
            // in modular arithmetic, doubling the correct bits in each step.
            inverse *= 2 - denominator * inverse; // inverse mod 2^8
            inverse *= 2 - denominator * inverse; // inverse mod 2^16
            inverse *= 2 - denominator * inverse; // inverse mod 2^32
            inverse *= 2 - denominator * inverse; // inverse mod 2^64
            inverse *= 2 - denominator * inverse; // inverse mod 2^128
            inverse *= 2 - denominator * inverse; // inverse mod 2^256

            // Because the division is now exact we can divide by multiplying with the modular inverse of denominator.
            // This will give us the correct result modulo 2^256. Since the preconditions guarantee that the outcome is
            // less than 2^256, this is the final result. We don't need to compute the high bits of the result and prod1
            // is no longer required.
            result = prod0 * inverse;
            return result;
        }
    }

    /**
     * @notice Calculates x * y / denominator with full precision, following the selected rounding direction.
     */
    function mulDiv(uint256 x, uint256 y, uint256 denominator, Rounding rounding) internal pure returns (uint256) {
        uint256 result = mulDiv(x, y, denominator);
        if (rounding == Rounding.Up && mulmod(x, y, denominator) > 0) {
            result += 1;
        }
        return result;
    }

    /**
     * @dev Returns the square root of a number. If the number is not a perfect square, the value is rounded down.
     *
     * Inspired by Henry S. Warren, Jr.'s "Hacker's Delight" (Chapter 11).
     */
    function sqrt(uint256 a) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }

        // For our first guess, we get the biggest power of 2 which is smaller than the square root of the target.
        //
        // We know that the "msb" (most significant bit) of our target number `a` is a power of 2 such that we have
        // `msb(a) <= a < 2*msb(a)`. This value can be written `msb(a)=2**k` with `k=log2(a)`.
        //
        // This can be rewritten `2**log2(a) <= a < 2**(log2(a) + 1)`
        // → `sqrt(2**k) <= sqrt(a) < sqrt(2**(k+1))`
        // → `2**(k/2) <= sqrt(a) < 2**((k+1)/2) <= 2**(k/2 + 1)`
        //
        // Consequently, `2**(log2(a) / 2)` is a good first approximation of `sqrt(a)` with at least 1 correct bit.
        uint256 result = 1 << (log2(a) >> 1);

        // At this point `result` is an estimation with one bit of precision. We know the true value is a uint128,
        // since it is the square root of a uint256. Newton's method converges quadratically (precision doubles at
        // every iteration). We thus need at most 7 iteration to turn our partial result with one bit of precision
        // into the expected uint128 result.
        unchecked {
            result = (result + a / result) >> 1;
            result = (result + a / result) >> 1;
            result = (result + a / result) >> 1;
            result = (result + a / result) >> 1;
            result = (result + a / result) >> 1;
            result = (result + a / result) >> 1;
            result = (result + a / result) >> 1;
            return min(result, a / result);
        }
    }

    /**
     * @notice Calculates sqrt(a), following the selected rounding direction.
     */
    function sqrt(uint256 a, Rounding rounding) internal pure returns (uint256) {
        unchecked {
            uint256 result = sqrt(a);
            return result + (rounding == Rounding.Up && result * result < a ? 1 : 0);
        }
    }

    /**
     * @dev Return the log in base 2, rounded down, of a positive value.
     * Returns 0 if given 0.
     */
    function log2(uint256 value) internal pure returns (uint256) {
        uint256 result = 0;
        unchecked {
            if (value >> 128 > 0) {
                value >>= 128;
                result += 128;
            }
            if (value >> 64 > 0) {
                value >>= 64;
                result += 64;
            }
            if (value >> 32 > 0) {
                value >>= 32;
                result += 32;
            }
            if (value >> 16 > 0) {
                value >>= 16;
                result += 16;
            }
            if (value >> 8 > 0) {
                value >>= 8;
                result += 8;
            }
            if (value >> 4 > 0) {
                value >>= 4;
                result += 4;
            }
            if (value >> 2 > 0) {
                value >>= 2;
                result += 2;
            }
            if (value >> 1 > 0) {
                result += 1;
            }
        }
        return result;
    }

    /**
     * @dev Return the log in base 2, following the selected rounding direction, of a positive value.
     * Returns 0 if given 0.
     */
    function log2(uint256 value, Rounding rounding) internal pure returns (uint256) {
        unchecked {
            uint256 result = log2(value);
            return result + (rounding == Rounding.Up && 1 << result < value ? 1 : 0);
        }
    }

    /**
     * @dev Return the log in base 10, rounded down, of a positive value.
     * Returns 0 if given 0.
     */
    function log10(uint256 value) internal pure returns (uint256) {
        uint256 result = 0;
        unchecked {
            if (value >= 10 ** 64) {
                value /= 10 ** 64;
                result += 64;
            }
            if (value >= 10 ** 32) {
                value /= 10 ** 32;
                result += 32;
            }
            if (value >= 10 ** 16) {
                value /= 10 ** 16;
                result += 16;
            }
            if (value >= 10 ** 8) {
                value /= 10 ** 8;
                result += 8;
            }
            if (value >= 10 ** 4) {
                value /= 10 ** 4;
                result += 4;
            }
            if (value >= 10 ** 2) {
                value /= 10 ** 2;
                result += 2;
            }
            if (value >= 10 ** 1) {
                result += 1;
            }
        }
        return result;
    }

    /**
     * @dev Return the log in base 10, following the selected rounding direction, of a positive value.
     * Returns 0 if given 0.
     */
    function log10(uint256 value, Rounding rounding) internal pure returns (uint256) {
        unchecked {
            uint256 result = log10(value);
            return result + (rounding == Rounding.Up && 10 ** result < value ? 1 : 0);
        }
    }

    /**
     * @dev Return the log in base 256, rounded down, of a positive value.
     * Returns 0 if given 0.
     *
     * Adding one to the result gives the number of pairs of hex symbols needed to represent `value` as a hex string.
     */
    function log256(uint256 value) internal pure returns (uint256) {
        uint256 result = 0;
        unchecked {
            if (value >> 128 > 0) {
                value >>= 128;
                result += 16;
            }
            if (value >> 64 > 0) {
                value >>= 64;
                result += 8;
            }
            if (value >> 32 > 0) {
                value >>= 32;
                result += 4;
            }
            if (value >> 16 > 0) {
                value >>= 16;
                result += 2;
            }
            if (value >> 8 > 0) {
                result += 1;
            }
        }
        return result;
    }

    /**
     * @dev Return the log in base 256, following the selected rounding direction, of a positive value.
     * Returns 0 if given 0.
     */
    function log256(uint256 value, Rounding rounding) internal pure returns (uint256) {
        unchecked {
            uint256 result = log256(value);
            return result + (rounding == Rounding.Up && 1 << (result << 3) < value ? 1 : 0);
        }
    }
}
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.8.0) (utils/math/SignedMath.sol)

pragma solidity ^0.8.0;

/**
 * @dev Standard signed math utilities missing in the Solidity language.
 */
library SignedMath {
    /**
     * @dev Returns the largest of two signed numbers.
     */
    function max(int256 a, int256 b) internal pure returns (int256) {
        return a > b ? a : b;
    }

    /**
     * @dev Returns the smallest of two signed numbers.
     */
    function min(int256 a, int256 b) internal pure returns (int256) {
        return a < b ? a : b;
    }

    /**
     * @dev Returns the average of two signed numbers without overflow.
     * The result is rounded towards zero.
     */
    function average(int256 a, int256 b) internal pure returns (int256) {
        // Formula from the book "Hacker's Delight"
        int256 x = (a & b) + ((a ^ b) >> 1);
        return x + (int256(uint256(x) >> 255) & (a ^ b));
    }

    /**
     * @dev Returns the absolute unsigned value of a signed value.
     */
    function abs(int256 n) internal pure returns (uint256) {
        unchecked {
            // must be unchecked in order to support `n = type(int256).min`
            return uint256(n >= 0 ? n : -n);
        }
    }
}
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.9.0) (utils/ShortStrings.sol)

pragma solidity ^0.8.8;

import "./StorageSlot.sol";

// | string  | 0xAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA   |
// | length  | 0x                                                              BB |
type ShortString is bytes32;

/**
 * @dev This library provides functions to convert short memory strings
 * into a `ShortString` type that can be used as an immutable variable.
 *
 * Strings of arbitrary length can be optimized using this library if
 * they are short enough (up to 31 bytes) by packing them with their
 * length (1 byte) in a single EVM word (32 bytes). Additionally, a
 * fallback mechanism can be used for every other case.
 *
 * Usage example:
 *
 * ```solidity
 * contract Named {
 *     using ShortStrings for *;
 *
 *     ShortString private immutable _name;
 *     string private _nameFallback;
 *
 *     constructor(string memory contractName) {
 *         _name = contractName.toShortStringWithFallback(_nameFallback);
 *     }
 *
 *     function name() external view returns (string memory) {
 *         return _name.toStringWithFallback(_nameFallback);
 *     }
 * }
 * ```
 */
library ShortStrings {
    // Used as an identifier for strings longer than 31 bytes.
    bytes32 private constant _FALLBACK_SENTINEL = 0x00000000000000000000000000000000000000000000000000000000000000FF;

    error StringTooLong(string str);
    error InvalidShortString();

    /**
     * @dev Encode a string of at most 31 chars into a `ShortString`.
     *
     * This will trigger a `StringTooLong` error is the input string is too long.
     */
    function toShortString(string memory str) internal pure returns (ShortString) {
        bytes memory bstr = bytes(str);
        if (bstr.length > 31) {
            revert StringTooLong(str);
        }
        return ShortString.wrap(bytes32(uint256(bytes32(bstr)) | bstr.length));
    }

    /**
     * @dev Decode a `ShortString` back to a "normal" string.
     */
    function toString(ShortString sstr) internal pure returns (string memory) {
        uint256 len = byteLength(sstr);
        // using `new string(len)` would work locally but is not memory safe.
        string memory str = new string(32);
        /// @solidity memory-safe-assembly
        assembly {
            mstore(str, len)
            mstore(add(str, 0x20), sstr)
        }
        return str;
    }

    /**
     * @dev Return the length of a `ShortString`.
     */
    function byteLength(ShortString sstr) internal pure returns (uint256) {
        uint256 result = uint256(ShortString.unwrap(sstr)) & 0xFF;
        if (result > 31) {
            revert InvalidShortString();
        }
        return result;
    }

    /**
     * @dev Encode a string into a `ShortString`, or write it to storage if it is too long.
     */
    function toShortStringWithFallback(string memory value, string storage store) internal returns (ShortString) {
        if (bytes(value).length < 32) {
            return toShortString(value);
        } else {
            StorageSlot.getStringSlot(store).value = value;
            return ShortString.wrap(_FALLBACK_SENTINEL);
        }
    }

    /**
     * @dev Decode a string that was encoded to `ShortString` or written to storage using {setWithFallback}.
     */
    function toStringWithFallback(ShortString value, string storage store) internal pure returns (string memory) {
        if (ShortString.unwrap(value) != _FALLBACK_SENTINEL) {
            return toString(value);
        } else {
            return store;
        }
    }

    /**
     * @dev Return the length of a string that was encoded to `ShortString` or written to storage using {setWithFallback}.
     *
     * WARNING: This will return the "byte length" of the string. This may not reflect the actual length in terms of
     * actual characters as the UTF-8 encoding of a single character can span over multiple bytes.
     */
    function byteLengthWithFallback(ShortString value, string storage store) internal view returns (uint256) {
        if (ShortString.unwrap(value) != _FALLBACK_SENTINEL) {
            return byteLength(value);
        } else {
            return bytes(store).length;
        }
    }
}
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.9.0) (utils/StorageSlot.sol)
// This file was procedurally generated from scripts/generate/templates/StorageSlot.js.

pragma solidity ^0.8.0;

/**
 * @dev Library for reading and writing primitive types to specific storage slots.
 *
 * Storage slots are often used to avoid storage conflict when dealing with upgradeable contracts.
 * This library helps with reading and writing to such slots without the need for inline assembly.
 *
 * The functions in this library return Slot structs that contain a `value` member that can be used to read or write.
 *
 * Example usage to set ERC1967 implementation slot:
 * ```solidity
 * contract ERC1967 {
 *     bytes32 internal constant _IMPLEMENTATION_SLOT = 0x360894a13ba1a3210667c828492db98dca3e2076cc3735a920a3ca505d382bbc;
 *
 *     function _getImplementation() internal view returns (address) {
 *         return StorageSlot.getAddressSlot(_IMPLEMENTATION_SLOT).value;
 *     }
 *
 *     function _setImplementation(address newImplementation) internal {
 *         require(Address.isContract(newImplementation), "ERC1967: new implementation is not a contract");
 *         StorageSlot.getAddressSlot(_IMPLEMENTATION_SLOT).value = newImplementation;
 *     }
 * }
 * ```
 *
 * _Available since v4.1 for `address`, `bool`, `bytes32`, `uint256`._
 * _Available since v4.9 for `string`, `bytes`._
 */
library StorageSlot {
    struct AddressSlot {
        address value;
    }

    struct BooleanSlot {
        bool value;
    }

    struct Bytes32Slot {
        bytes32 value;
    }

    struct Uint256Slot {
        uint256 value;
    }

    struct StringSlot {
        string value;
    }

    struct BytesSlot {
        bytes value;
    }

    /**
     * @dev Returns an `AddressSlot` with member `value` located at `slot`.
     */
    function getAddressSlot(bytes32 slot) internal pure returns (AddressSlot storage r) {
        /// @solidity memory-safe-assembly
        assembly {
            r.slot := slot
        }
    }

    /**
     * @dev Returns an `BooleanSlot` with member `value` located at `slot`.
     */
    function getBooleanSlot(bytes32 slot) internal pure returns (BooleanSlot storage r) {
        /// @solidity memory-safe-assembly
        assembly {
            r.slot := slot
        }
    }

    /**
     * @dev Returns an `Bytes32Slot` with member `value` located at `slot`.
     */
    function getBytes32Slot(bytes32 slot) internal pure returns (Bytes32Slot storage r) {
        /// @solidity memory-safe-assembly
        assembly {
            r.slot := slot
        }
    }

    /**
     * @dev Returns an `Uint256Slot` with member `value` located at `slot`.
     */
    function getUint256Slot(bytes32 slot) internal pure returns (Uint256Slot storage r) {
        /// @solidity memory-safe-assembly
        assembly {
            r.slot := slot
        }
    }

    /**
     * @dev Returns an `StringSlot` with member `value` located at `slot`.
     */
    function getStringSlot(bytes32 slot) internal pure returns (StringSlot storage r) {
        /// @solidity memory-safe-assembly
        assembly {
            r.slot := slot
        }
    }

    /**
     * @dev Returns an `StringSlot` representation of the string storage pointer `store`.
     */
    function getStringSlot(string storage store) internal pure returns (StringSlot storage r) {
        /// @solidity memory-safe-assembly
        assembly {
            r.slot := store.slot
        }
    }

    /**
     * @dev Returns an `BytesSlot` with member `value` located at `slot`.
     */
    function getBytesSlot(bytes32 slot) internal pure returns (BytesSlot storage r) {
        /// @solidity memory-safe-assembly
        assembly {
            r.slot := slot
        }
    }

    /**
     * @dev Returns an `BytesSlot` representation of the bytes storage pointer `store`.
     */
    function getBytesSlot(bytes storage store) internal pure returns (BytesSlot storage r) {
        /// @solidity memory-safe-assembly
        assembly {
            r.slot := store.slot
        }
    }
}
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.9.0) (utils/Strings.sol)

pragma solidity ^0.8.0;

import "./math/Math.sol";
import "./math/SignedMath.sol";

/**
 * @dev String operations.
 */
library Strings {
    bytes16 private constant _SYMBOLS = "0123456789abcdef";
    uint8 private constant _ADDRESS_LENGTH = 20;

    /**
     * @dev Converts a `uint256` to its ASCII `string` decimal representation.
     */
    function toString(uint256 value) internal pure returns (string memory) {
        unchecked {
            uint256 length = Math.log10(value) + 1;
            string memory buffer = new string(length);
            uint256 ptr;
            /// @solidity memory-safe-assembly
            assembly {
                ptr := add(buffer, add(32, length))
            }
            while (true) {
                ptr--;
                /// @solidity memory-safe-assembly
                assembly {
                    mstore8(ptr, byte(mod(value, 10), _SYMBOLS))
                }
                value /= 10;
                if (value == 0) break;
            }
            return buffer;
        }
    }

    /**
     * @dev Converts a `int256` to its ASCII `string` decimal representation.
     */
    function toString(int256 value) internal pure returns (string memory) {
        return string(abi.encodePacked(value < 0 ? "-" : "", toString(SignedMath.abs(value))));
    }

    /**
     * @dev Converts a `uint256` to its ASCII `string` hexadecimal representation.
     */
    function toHexString(uint256 value) internal pure returns (string memory) {
        unchecked {
            return toHexString(value, Math.log256(value) + 1);
        }
    }

    /**
     * @dev Converts a `uint256` to its ASCII `string` hexadecimal representation with fixed length.
     */
    function toHexString(uint256 value, uint256 length) internal pure returns (string memory) {
        bytes memory buffer = new bytes(2 * length + 2);
        buffer[0] = "0";
        buffer[1] = "x";
        for (uint256 i = 2 * length + 1; i > 1; --i) {
            buffer[i] = _SYMBOLS[value & 0xf];
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

    /**
     * @dev Returns true if the two strings are equal.
     */
    function equal(string memory a, string memory b) internal pure returns (bool) {
        return keccak256(bytes(a)) == keccak256(bytes(b));
    }
}
// SPDX-License-Identifier: Apache-2.0
// Copyright 2023 Enjinstarter
pragma solidity 0.8.19;

import {AccessControl} from "@openzeppelin/contracts/access/AccessControl.sol";
import {IAdminPrivileges} from "./interfaces/IAdminPrivileges.sol";

/**
 * @title AdminPrivileges
 * @author Tim Loh
 * @notice Provides admin privileges role definitions that are inherited by other contracts
 */
contract AdminPrivileges is AccessControl, IAdminPrivileges {
    bytes32 public constant BACKOFFICE_ROLE_ADMIN_ROLE = keccak256("BACKOFFICE_ROLE_ADMIN_ROLE");
    bytes32 public constant BACKOFFICE_GOVERNANCE_ROLE = keccak256("BACKOFFICE_GOVERNANCE_ROLE");
    bytes32 public constant BACKOFFICE_CONTRACT_ADMIN_ROLE = keccak256("BACKOFFICE_CONTRACT_ADMIN_ROLE");

    bytes32 public constant TENANT_ROLE_ADMIN_ROLE = keccak256("TENANT_ROLE_ADMIN_ROLE");
    bytes32 public constant TENANT_GOVERNANCE_ROLE = keccak256("TENANT_GOVERNANCE_ROLE");
    bytes32 public constant TENANT_CONTRACT_ADMIN_ROLE = keccak256("TENANT_CONTRACT_ADMIN_ROLE");
}
// SPDX-License-Identifier: Apache-2.0
// Copyright 2023 Enjinstarter
pragma solidity 0.8.19;

/**
 * @title AdminPrivileges Interface
 * @author Tim Loh
 * @notice Interface for admin privileges role definitions that are inherited by other contracts
 */
interface IAdminPrivileges {
    // solhint-disable func-name-mixedcase

    // https://github.com/crytic/slither/wiki/Detector-Documentation#conformance-to-solidity-naming-conventions
    // slither-disable-next-line naming-convention
    function BACKOFFICE_ROLE_ADMIN_ROLE() external view returns (bytes32);

    // https://github.com/crytic/slither/wiki/Detector-Documentation#conformance-to-solidity-naming-conventions
    // slither-disable-next-line naming-convention
    function BACKOFFICE_GOVERNANCE_ROLE() external view returns (bytes32);

    // https://github.com/crytic/slither/wiki/Detector-Documentation#conformance-to-solidity-naming-conventions
    // slither-disable-next-line naming-convention
    function BACKOFFICE_CONTRACT_ADMIN_ROLE() external view returns (bytes32);

    // https://github.com/crytic/slither/wiki/Detector-Documentation#conformance-to-solidity-naming-conventions
    // slither-disable-next-line naming-convention
    function TENANT_ROLE_ADMIN_ROLE() external view returns (bytes32);

    // https://github.com/crytic/slither/wiki/Detector-Documentation#conformance-to-solidity-naming-conventions
    // slither-disable-next-line naming-convention
    function TENANT_GOVERNANCE_ROLE() external view returns (bytes32);

    // https://github.com/crytic/slither/wiki/Detector-Documentation#conformance-to-solidity-naming-conventions
    // slither-disable-next-line naming-convention
    function TENANT_CONTRACT_ADMIN_ROLE() external view returns (bytes32);

    // solhint-enable func-name-mixedcase
}
// SPDX-License-Identifier: Apache-2.0
// Copyright 2023 Enjinstarter
pragma solidity 0.8.19;

/**
 * @title AdminWallet Interface
 * @author Tim Loh
 * @notice Interface for admin wallet that will receive the funds
 */
interface IAdminWallet {
    /**
     * @notice Emitted when admin wallet has been changed from `oldWallet` to `newWallet`
     * @param oldWallet The wallet before the wallet was changed
     * @param newWallet The wallet after the wallet was changed
     * @param sender The address that changes the admin wallet
     */
    event AdminWalletChanged(address indexed oldWallet, address indexed newWallet, address indexed sender);

    /**
     * @notice Returns the admin wallet address that will receive the funds
     * @return Admin wallet address
     */
    function adminWallet() external view returns (address);
}
// SPDX-License-Identifier: Apache-2.0
// Copyright 2023 Enjinstarter
pragma solidity 0.8.19;

/**
 * @title IFactoryImplementation
 * @author Tim Loh
 * @notice Provides factory implementation type that is inherited by reference implementation contracts for matching
 *         with corresponding factory contracts
 */
interface IFactoryImplementation {
    function factoryImplementationType() external view returns (uint256);
}
// SPDX-License-Identifier: Apache-2.0
// Copyright 2023 Enjinstarter
pragma solidity 0.8.19;

import {IAccessControl} from "@openzeppelin/contracts/access/IAccessControl.sol";
import {IAdminPrivileges} from "./IAdminPrivileges.sol";
import {IAdminWallet} from "./IAdminWallet.sol";

/**
 * @title ISubscriptionService
 * @author Tim Loh
 */
interface ISubscriptionService is IAccessControl, IAdminPrivileges, IAdminWallet {
    /**
     * @notice Emitted when subscription package available for purchase has been setup
     * @param subscriptionId The subscription identifier
     * @param sender The address with backoffice contract admin role that setup the subscription package for purchase
     * @param paymentTokenAddress The address of the token that will be used for payment
     * @param paymentTokenDecimals The number of decimals for the payment token
     * @param priceInPaymentTokenWei The amount in wei of payment tokens to pay for subscription package
     * @param expiryDays The number of days after purchase when subscription package expires
     * @param numberOfContracts The additional number of contracts that can be deployed after purchase
     */
    event AvailableSubscriptionPackageSet(
        bytes32 indexed subscriptionId,
        address indexed sender,
        address indexed paymentTokenAddress,
        uint256 paymentTokenDecimals,
        uint256 priceInPaymentTokenWei,
        uint256 expiryDays,
        uint256 numberOfContracts
    );

    /**
     * @notice Emitted when `purchaserAddress` is added as purchaser of specified subscription
     * @param subscriptionId The subscription identifier
     * @param purchaserAddress The address to be added as purchaser of specified subscription
     * @param sender The address with backoffice contract admin role that added the address as purchaser
     */
    event PurchaserAddressAdded(
        bytes32 indexed subscriptionId,
        address indexed purchaserAddress,
        address indexed sender
    );

    /**
     * @notice Emitted when `purchaserAddress` is removed as purchaser of specified subscription.
     * @param subscriptionId The subscription identifier
     * @param purchaserAddress The address to be removed as purchaser of specified subscription
     * @param sender The address with backoffice contract admin role that removed the address as purchaser
     */
    event PurchaserAddressRemoved(
        bytes32 indexed subscriptionId,
        address indexed purchaserAddress,
        address indexed sender
    );

    /**
     * @notice Emitted when purchased subscription package has been consumed by `account` to deploy a contract
     * @param subscriptionId The subscription identifier
     * @param sender The address with contract usage role that initiated the subscription package consumption by
     *               `account`
     * @param account The address that consumed the subscription package to deploy a contract
     * @param numberOfContractsDeployed The number of contracts deployed after consuming subscription package
     * @param numberOfDeployableContracts The number of deployable contracts after consuming subscription package
     * @param expiryTimestamp The timestamp when purchased subscription package expires
     */
    event SubscriptionPackageConsumed(
        bytes32 indexed subscriptionId,
        address indexed sender,
        address indexed account,
        uint256 numberOfContractsDeployed,
        uint256 numberOfDeployableContracts,
        uint256 expiryTimestamp
    );

    /**
     * @notice Emitted when available subscription package has been purchased by `account`
     * @param subscriptionId The subscription identifier
     * @param sender The address that purchased the available subscription package
     * @param paymentTokenAddress The address of the token that is used for payment
     * @param paymentTokenDecimals The number of decimals for the payment token
     * @param priceInPaymentTokenWei The amount in wei of payment tokens paid for subscription package
     * @param availablePackageNumberOfContracts The additional number of contracts that can be deployed after purchase
     * @param availablePackageExpiryDays The number of days after purchase when subscription package expires
     * @param numberOfDeployableContracts The number of deployable contracts after purchase
     * @param purchaseExpiryTimestamp The timestamp when purchased subscription package expires
     * @param adminWallet The address receiving the payment tokens paid
     */
    event SubscriptionPackagePurchased(
        bytes32 indexed subscriptionId,
        address indexed sender,
        address indexed paymentTokenAddress,
        uint256 paymentTokenDecimals,
        uint256 priceInPaymentTokenWei,
        uint256 availablePackageNumberOfContracts,
        uint256 availablePackageExpiryDays,
        uint256 numberOfDeployableContracts,
        uint256 purchaseExpiryTimestamp,
        address adminWallet
    );

    /**
     * @notice Add `purchaserAddress` as purchaser of subscription package so that can purchase or consume subscription
     * @dev Must be called by backoffice contract admin role
     * @param subscriptionId The subscription identifier
     * @param purchaserAddress The address to be added as purchaser of specified subscription
     */
    function addPurchaserAddress(bytes32 subscriptionId, address purchaserAddress) external;

    /**
     * @notice Consume subscription package to deploy a contract
     * @dev Must be called by contract usage role
     * @dev Can only be consumed if `account` is purchaser of subscription package
     * @param subscriptionId The subscription identifier
     * @param account The address that will consume the subscription package to deploy a contract
     * @return isConsumed `true` if subscription package has been consumed successfully
     */
    function consumeSubscriptionPackage(bytes32 subscriptionId, address account) external returns (bool isConsumed);

    /**
     * @notice Purchase subscription package by sender using ERC20 token for payment
     * @dev Can only be purchased if sender is purchaser of subscription package
     * @param subscriptionId The subscription identifier
     */
    function erc20PurchaseSubscriptionPackage(bytes32 subscriptionId) external;

    /**
     * @notice Purchase subscription package by sender using native token for payment
     * @dev Can only be purchased if sender is purchaser of subscription package
     * @param subscriptionId The subscription identifier
     */
    function nativePurchaseSubscriptionPackage(bytes32 subscriptionId) external payable;

    /**
     * @notice Pause user functions
     * @dev Must be called by backoffice contract admin role
     */
    function pauseContract() external;

    /**
     * @notice Remove `purchaserAddress` as purchaser of subscription package
     * @dev Must be called by backoffice contract admin role
     * @param subscriptionId The subscription identifier
     * @param purchaserAddress The address to be removed as purchaser of specified subscription
     */
    function removePurchaserAddress(bytes32 subscriptionId, address purchaserAddress) external;

    /**
     * @notice Change admin wallet that will receive funds to a new wallet address
     * @dev Must be called by backoffice governance role
     * @param newWallet The new admin wallet
     */
    function setAdminWallet(address newWallet) external;

    /**
     * @notice Setup subscription package that will be available for purchase
     * @dev Must be called by backoffice contract admin role
     * @dev Will auto purchase for zero cost subscription package
     * @param subscriptionId The subscription identifier
     * @param expiryDays The number of days after purchase when subscription package expires
     * @param numberOfContracts The additional number of contracts that can be deployed after purchase
     * @param paymentTokenAddress The address of the token that will be used for payment
     * @param paymentTokenDecimals The number of decimals for the payment token
     * @param priceInPaymentTokenWei The amount in wei of payment tokens to pay for subscription package
     */
    function setAvailableSubscriptionPackage(
        bytes32 subscriptionId,
        uint256 expiryDays,
        uint256 numberOfContracts,
        address paymentTokenAddress,
        uint256 paymentTokenDecimals,
        uint256 priceInPaymentTokenWei
    ) external;

    /**
     * @notice Unpause user functions
     * @dev Must be called by backoffice contract admin role
     */
    function unpauseContract() external;

    /**
     * @notice Get info of subscription package available for purchase
     * @param subscriptionId The subscription identifier
     * @return expiryDays The number of days after purchase when subscription package expires
     * @return numberOfContracts The additional number of contracts that can be deployed after purchase
     * @return paymentTokenAddress The address of the token that will be used for payment
     * @return paymentTokenDecimals The number of decimals for the payment token
     * @return priceInPaymentTokenWei The amount in wei of payment tokens to pay for subscription package
     * @return isInitialized `true` if package is available for purchase
     */
    function getAvailableSubscriptionPackageFor(
        bytes32 subscriptionId
    )
        external
        view
        returns (
            uint256 expiryDays,
            uint256 numberOfContracts,
            address paymentTokenAddress,
            uint256 paymentTokenDecimals,
            uint256 priceInPaymentTokenWei,
            bool isInitialized
        );

    /**
     * @notice Get info of purchased subscription package
     * @param subscriptionId The subscription identifier
     * @return expiryTimestamp The timestamp when purchased subscription package expires
     * @return numberOfContractsDeployed The number of contracts that have been deployed
     * @return numberOfDeployableContracts The number of contracts that can be deployed
     */
    function getPurchasedSubscriptionPackageFor(
        bytes32 subscriptionId
    )
        external
        view
        returns (uint256 expiryTimestamp, uint256 numberOfContractsDeployed, uint256 numberOfDeployableContracts);

    /**
     * @notice Checks whether `purchaserAddress` is allowed to purchase specified subscription package
     * @param subscriptionId The subscription identifier
     * @param purchaserAddress The address to check
     * @return Returns `true` if `purchaserAddress` is allowed to purchase specified subscription package
     */
    function isAllowedToPurchase(bytes32 subscriptionId, address purchaserAddress) external view returns (bool);

    /**
     * @notice Checks whether this contract implements the interface defined by `interfaceId`
     * @dev ERC165
     * @return `true` if this contract implements the interface defined by `interfaceId`
     */
    function supportsInterface(bytes4 interfaceId) external view returns (bool);

    // solhint-disable func-name-mixedcase

    /**
     * @notice Get contract usage role definition
     * @return Returns contract usage role definition
     */
    // https://github.com/crytic/slither/wiki/Detector-Documentation#conformance-to-solidity-naming-conventions
    // slither-disable-next-line naming-convention
    function CONTRACT_USAGE_ROLE() external view returns (bytes32);

    /**
     * @notice Get interface ID for ISubscriptionService interface
     * @return Returns interface ID for ISubscriptionService interface
     */
    // https://github.com/crytic/slither/wiki/Detector-Documentation#conformance-to-solidity-naming-conventions
    // slither-disable-next-line naming-convention
    function INTERFACE_ID() external view returns (bytes4);

    // solhint-enable func-name-mixedcase
}
// SPDX-License-Identifier: Apache-2.0
// Copyright 2023 Enjinstarter
pragma solidity 0.8.19;

import {IAccessControl} from "@openzeppelin/contracts/access/IAccessControl.sol";
import {IAdminPrivileges} from "./IAdminPrivileges.sol";
import {IFactoryImplementation} from "./IFactoryImplementation.sol";

/**
 * @title IVestingCustomFactory
 * @author Tim Loh
 * @notice Custom vesting factory interface for deploying custom vesting contracts based on implementation
 */
interface IVestingCustomFactory is IAccessControl, IAdminPrivileges {
    /**
     * @notice Emitted when backoffice admin address has been changed from `oldBackofficeAdminAddress` to
     *         `newBackofficeAdminAddress`
     * @param oldBackofficeAdminAddress The backoffice admin address before the change
     * @param newBackofficeAdminAddress The backoffice admin address after the change
     * @param sender The address that changes the backoffice admin address
     */
    event BackofficeAdminAddressChanged(
        address indexed oldBackofficeAdminAddress,
        address indexed newBackofficeAdminAddress,
        address indexed sender
    );

    /**
     * @notice Emitted when contract has been successfully deployed
     * @param deployedContract The address of the deployed contract
     * @param deployId The deployment identifier
     * @param subscriptionId The subscription identifier
     * @param deployName The deployment name
     * @param tokenAddress The vesting token address
     * @param tokenDecimals The number of decimals for vesting token
     * @param allowAccumulate `true` if multiple grant amounts is allowed to accumulate for the same user,
     *                        `false` if a user can only have one grant
     * @param backofficeAddress The backoffice admin address that is set for deploy contract
     * @param tenantAdminAddress The tenant admin address that is set for deploy contract
     * @param signer The signer address corresponding to the given signature
     * @param implementation The reference contract implementation address
     */
    event ContractDeployed(
        address indexed deployedContract,
        bytes32 indexed deployId,
        bytes32 indexed subscriptionId,
        string deployName,
        address tokenAddress,
        uint256 tokenDecimals,
        bool allowAccumulate,
        address backofficeAddress,
        address tenantAdminAddress,
        address signer,
        address implementation
    );

    /**
     * @notice Emitted when implementation address has been changed from `oldImplementation` to `newImplementation`
     * @param oldImplementation The implementation address before the change
     * @param newImplementation The implementation address after the change
     * @param sender The address that changes the implementation address
     */
    event ImplementationAddressChanged(
        address indexed oldImplementation,
        address indexed newImplementation,
        address indexed sender
    );

    /**
     * @notice Emitted when subscription service contract address has been changed from `oldAddress` to `newAddress`
     * @param oldAddress The subscription service contract address before the change
     * @param newAddress The subscription service contract address after the change
     * @param sender The address that changes the subscription service contract address
     */
    event SubscriptionServiceChanged(address indexed oldAddress, address indexed newAddress, address indexed sender);

    /**
     * @notice Deploy contract based on given typed signature
     * @param deployId The deploy identifier
     * @param subscriptionId The subscription identifier
     * @param name The deployment name
     * @param tokenAddress The vesting token address
     * @param tokenDecimals The number of decimals for vesting token
     * @param allowAccumulate `true` if multiple grant amounts is allowed to accumulate for the same user,
     *                        `false` if a user can only have one grant
     * @param signature The typed signature must be from an authorized signer before contract is deployed
     */
    function deployWithTypedSignature(
        bytes32 deployId,
        bytes32 subscriptionId,
        string memory name,
        address tokenAddress,
        uint256 tokenDecimals,
        bool allowAccumulate,
        bytes memory signature
    ) external;

    /**
     * @notice Pause user functions (deploy)
     * @dev Must be called by backoffice contract admin role
     */
    function pauseContract() external;

    /**
     * @notice Change backoffice admin address that will be set for deploy contract to a new address
     * @dev Must be called by backoffice contract admin role
     * @param newBackofficeAdminAddress The new backoffice admin address
     */
    function setBackofficeAdminAddress(address newBackofficeAdminAddress) external;

    /**
     * @notice Change implementation to a new address
     * @dev Must be called by backoffice governance role
     * @param newImplementation The new implementation address
     */
    function setImplementationAddress(address newImplementation) external;

    /**
     * @notice Change subscription service contract address
     * @dev Must be called by backoffice governance role
     * @param newAddress The new contract address
     */
    function setSubscriptionService(address newAddress) external;

    /**
     * @notice Unpause user functions (deploy)
     * @dev Must be called by backoffice contract admin role
     */
    function unpauseContract() external;

    /**
     * @notice Get backoffice admin address that will be set for deploy contract
     * @return Returns backoffice admin address
     */
    function backofficeAdminAddress() external view returns (address);

    /**
     * @notice Returns deployment info for given deploy identifier
     * @param deployId The deploy identifier
     * @return implementation The reference contract implementation address
     * @return deployedContract The deployed contract address
     */
    function deployInfoFor(bytes32 deployId) external view returns (address implementation, address deployedContract);

    /**
     * @notice Get factory name
     * @return Returns factory name
     */
    function factoryName() external view returns (string memory);

    /**
     * @notice Get factory version
     * @return Returns factory version
     */
    function factoryVersion() external view returns (string memory);

    /**
     * @notice Get reference implementation contract address
     * @return Returns reference implementation contract address
     */
    function implementationAddress() external view returns (address);

    /**
     * @notice Returns signer of given typed signature
     * @param implementation The reference contract implementation address
     * @param deployId The deploy identifier
     * @param name The deployment name
     * @param tokenAddress The vesting token address
     * @param tokenDecimals The number of decimals for vesting token
     * @param allowAccumulate `true` if multiple grant amounts is allowed to accumulate for the same user,
     *                        `false` if a user can only have one grant
     * @param tenantAdminAddress The tenant admin address that will be set for deploy contract
     * @param signature The typed signature is verified to be from an authorized signer before contract is deployed
     * @return recovered The signer address
     */
    function recoverTypedSignature(
        address implementation,
        bytes32 deployId,
        string memory name,
        address tokenAddress,
        uint256 tokenDecimals,
        bool allowAccumulate,
        address tenantAdminAddress,
        bytes memory signature
    ) external view returns (address recovered);

    /**
     * @notice Get subscription serbice contract address
     * @return Returns subscription service contract address
     */
    function subscriptionService() external view returns (address);
}
// SPDX-License-Identifier: Apache-2.0
// Copyright 2023 Enjinstarter
pragma solidity 0.8.19;

import {Clones} from "@openzeppelin/contracts/proxy/Clones.sol";
import {Pausable} from "@openzeppelin/contracts/security/Pausable.sol";
import {ReentrancyGuard} from "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import {Address} from "@openzeppelin/contracts/utils/Address.sol";
import {ECDSA} from "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";
import {EIP712} from "@openzeppelin/contracts/utils/cryptography/EIP712.sol";
import {AdminPrivileges} from "./AdminPrivileges.sol";
import {ISubscriptionService} from "./interfaces/ISubscriptionService.sol";
import {IFactoryImplementation, IVestingCustomFactory} from "./interfaces/IVestingCustomFactory.sol";

/**
 * @title VestingCustomFactory
 * @author Tim Loh
 * @notice Provides an implementation of custom vesting factory interface for deploying custom vesting contracts based
 *         on reference implementation
 */
contract VestingCustomFactory is AdminPrivileges, EIP712, Pausable, ReentrancyGuard, IVestingCustomFactory {
    using Address for address;
    using Clones for address;
    using ECDSA for bytes32;

    struct DeployInfo {
        address implementation; // address of reference implementation
        address deployedContract; // address of deployed contract
        bool isInitialized; // `true` if initialized
    }

    uint256 public constant SIGNATURE_LENGTH = 65;
    uint256 public constant TOKEN_DECIMALS_MAX = 18;

    uint256 public immutable factoryImplementationType;

    address public backofficeAdminAddress;
    // https://github.com/crytic/slither/wiki/Detector-Documentation#state-variables-that-could-be-declared-immutable
    // slither-disable-next-line immutable-states
    string public factoryName;
    // slither-disable-next-line immutable-states
    string public factoryVersion;
    address public implementationAddress;
    address public subscriptionService;

    mapping(bytes32 => DeployInfo) private _deployments;

    /**
     * @notice The meaning of `name` and `version` is specified in
     *         https://eips.ethereum.org/EIPS/eip-712#definition-of-domainseparator
     */
    constructor(string memory name, string memory version, uint256 implementationType) EIP712(name, version) {
        _setRoleAdmin(BACKOFFICE_ROLE_ADMIN_ROLE, BACKOFFICE_ROLE_ADMIN_ROLE);
        _setRoleAdmin(BACKOFFICE_GOVERNANCE_ROLE, BACKOFFICE_ROLE_ADMIN_ROLE);
        _setRoleAdmin(BACKOFFICE_CONTRACT_ADMIN_ROLE, BACKOFFICE_ROLE_ADMIN_ROLE);

        _grantRole(BACKOFFICE_ROLE_ADMIN_ROLE, msg.sender);
        _grantRole(BACKOFFICE_GOVERNANCE_ROLE, msg.sender);
        _grantRole(BACKOFFICE_CONTRACT_ADMIN_ROLE, msg.sender);

        factoryName = name;
        factoryVersion = version;
        factoryImplementationType = implementationType;
    }

    /**
     * @inheritdoc IVestingCustomFactory
     */
    function deployWithTypedSignature(
        bytes32 deployId,
        bytes32 subscriptionId,
        string memory name,
        address tokenAddress,
        uint256 tokenDecimals,
        bool allowAccumulate,
        bytes memory signature
    ) external virtual override whenNotPaused {
        _deployWithTypedSignature(
            deployId,
            subscriptionId,
            name,
            tokenAddress,
            tokenDecimals,
            allowAccumulate,
            backofficeAdminAddress,
            msg.sender,
            signature
        );
    }

    /**
     * @inheritdoc IVestingCustomFactory
     */
    function pauseContract() external virtual override onlyRole(BACKOFFICE_CONTRACT_ADMIN_ROLE) {
        _pause();
    }

    /**
     * @inheritdoc IVestingCustomFactory
     */
    function setBackofficeAdminAddress(
        address newBackofficeAdminAddress
    ) external virtual override onlyRole(BACKOFFICE_CONTRACT_ADMIN_ROLE) {
        require(newBackofficeAdminAddress != address(0), "VCF: backoffice admin");

        address oldBackofficeAdminAddress = backofficeAdminAddress;
        backofficeAdminAddress = newBackofficeAdminAddress;

        emit BackofficeAdminAddressChanged(oldBackofficeAdminAddress, newBackofficeAdminAddress, msg.sender);
    }

    /**
     * @inheritdoc IVestingCustomFactory
     */
    function setImplementationAddress(
        address newImplementation
    ) external virtual override onlyRole(BACKOFFICE_GOVERNANCE_ROLE) {
        require(newImplementation != address(0), "VCF: new implementation");

        address oldImplementation = implementationAddress;
        implementationAddress = newImplementation;

        emit ImplementationAddressChanged(oldImplementation, newImplementation, msg.sender);

        uint256 implementationType = IFactoryImplementation(newImplementation).factoryImplementationType();
        require(implementationType == factoryImplementationType, "VCF: implementation type");
    }

    /**
     * @inheritdoc IVestingCustomFactory
     */
    function setSubscriptionService(address newAddress) external virtual override onlyRole(BACKOFFICE_GOVERNANCE_ROLE) {
        require(newAddress != address(0), "VCF: address");

        address oldAddress = subscriptionService;
        subscriptionService = newAddress;

        emit SubscriptionServiceChanged(oldAddress, newAddress, msg.sender);

        bool supportsSubscriptionServiceInterface = ISubscriptionService(newAddress).supportsInterface(
            type(ISubscriptionService).interfaceId
        );
        require(supportsSubscriptionServiceInterface, "VCF: interface");
    }

    /**
     * @inheritdoc IVestingCustomFactory
     */
    function unpauseContract() external virtual override onlyRole(BACKOFFICE_CONTRACT_ADMIN_ROLE) {
        _unpause();
    }

    /**
     * @inheritdoc IVestingCustomFactory
     */
    function deployInfoFor(
        bytes32 deployId
    ) external view virtual override returns (address implementation, address deployedContract) {
        require(_deployments[deployId].isInitialized, "VCF: uninitialized");

        implementation = _deployments[deployId].implementation;
        deployedContract = _deployments[deployId].deployedContract;
    }

    /**
     * @inheritdoc IVestingCustomFactory
     */
    function recoverTypedSignature(
        address implementation,
        bytes32 deployId,
        string memory name,
        address tokenAddress,
        uint256 tokenDecimals,
        bool allowAccumulate,
        address tenantAdminAddress,
        bytes memory signature
    ) external view virtual override returns (address recovered) {
        recovered = _recoverTypedSignature(
            implementation,
            deployId,
            name,
            tokenAddress,
            tokenDecimals,
            allowAccumulate,
            tenantAdminAddress,
            signature
        );
    }

    /**
     * @dev Consume purchased subscription package by `account` to deploy a contract
     * @param subscriptionId The subscription identifier
     * @param account The account consuming the subscription package to deploy a contract
     * @return isConsumed Returns whether subscription package has been successfully consumed
     */
    function _consumeSubscriptionPackage(
        bytes32 subscriptionId,
        address account
    ) internal virtual returns (bool isConsumed) {
        require(subscriptionService != address(0), "VCF: subscription");

        isConsumed = ISubscriptionService(subscriptionService).consumeSubscriptionPackage(subscriptionId, account);
    }

    /**
     * @dev Deploy contract based on given typed signature
     * @param deployId The deploy identifier
     * @param subscriptionId The subscription identifier
     * @param name The deployment name
     * @param tokenAddress The vesting token address
     * @param tokenDecimals The number of decimals for vesting token
     * @param allowAccumulate `true` if multiple grant amounts is allowed to accumulate for the same user,
     *                        `false` if a user can only have one grant
     * @param backofficeAddress The backoffice admin address that will be set for deploy contract
     * @param tenantAdminAddress The tenant admin address that will be set for deploy contract
     * @param signature The typed signature must be from an authorized signer before contract is deployed
     */
    function _deployWithTypedSignature(
        bytes32 deployId,
        bytes32 subscriptionId,
        string memory name,
        address tokenAddress,
        uint256 tokenDecimals,
        bool allowAccumulate,
        address backofficeAddress,
        address tenantAdminAddress,
        bytes memory signature
    ) internal virtual nonReentrant {
        require(!_deployments[deployId].isInitialized, "VCF: exists");
        require(backofficeAddress != address(0), "VCF: backoffice address");

        address recovered = _recoverTypedSignature(
            implementationAddress,
            deployId,
            name,
            tokenAddress,
            tokenDecimals,
            allowAccumulate,
            tenantAdminAddress,
            signature
        );
        require(msg.sender == recovered, "VCF: sender");

        bytes memory saltdata = _encodeSaltData(deployId);
        bytes32 salt = keccak256(saltdata);
        address deployedAddress = implementationAddress.cloneDeterministic(salt);
        require(deployedAddress != address(0), "VCF: deployed address");

        _deployments[deployId] = DeployInfo({
            implementation: implementationAddress,
            deployedContract: deployedAddress,
            isInitialized: true
        });

        bytes memory initializeData = _encodeInitializeData(
            tokenAddress,
            tokenDecimals,
            allowAccumulate,
            backofficeAddress,
            tenantAdminAddress
        );

        emit ContractDeployed(
            deployedAddress,
            deployId,
            subscriptionId,
            name,
            tokenAddress,
            tokenDecimals,
            allowAccumulate,
            backofficeAddress,
            tenantAdminAddress,
            recovered,
            implementationAddress
        );

        require(_consumeSubscriptionPackage(subscriptionId, recovered), "VCF: consume");

        // https://github.com/crytic/slither/wiki/Detector-Documentation#unused-return
        // slither-disable-next-line unused-return
        deployedAddress.functionCall(initializeData);
    }

    /**
     * @dev Returns signer of given typed signature
     * @param implementation The reference contract implementation address
     * @param deployId The deploy identifier
     * @param name The deployment name
     * @param tokenAddress The vesting token address
     * @param tokenDecimals The number of decimals for vesting token
     * @param allowAccumulate `true` if multiple grant amounts is allowed to accumulate for the same user,
     *                        `false` if a user can only have one grant
     * @param tenantAdminAddress The tenant admin address that will be set for deploy contract
     * @param signature The typed signature is verified to be from an authorized signer before contract is deployed
     * @return recovered The signer address
     */
    function _recoverTypedSignature(
        address implementation,
        bytes32 deployId,
        string memory name,
        address tokenAddress,
        uint256 tokenDecimals,
        bool allowAccumulate,
        address tenantAdminAddress,
        bytes memory signature
    ) internal view virtual returns (address recovered) {
        require(implementation != address(0), "VCF: implementation");
        require(bytes(name).length > 0, "VCF: name");
        require(tokenAddress != address(0), "VCF: token address");
        require(tokenDecimals <= TOKEN_DECIMALS_MAX, "VCF: token decimals");
        require(tenantAdminAddress != address(0), "VCF: tenant address");
        require(signature.length == SIGNATURE_LENGTH, "VCF: signature");

        bytes32 digest = _hashTypedDataV4(
            keccak256(
                abi.encode(
                    keccak256(
                        "VestingCustom("
                        "address implementation,"
                        "bytes32 deployId,"
                        "string name,"
                        "address tokenAddress,"
                        "uint256 tokenDecimals,"
                        "bool allowAccumulate,"
                        "address tenantAdminAddress"
                        ")"
                    ),
                    implementation,
                    deployId,
                    keccak256(bytes(name)),
                    tokenAddress,
                    tokenDecimals,
                    allowAccumulate,
                    tenantAdminAddress
                )
            )
        );
        recovered = digest.recover(signature);
        require(recovered != address(0), "VCF: recovered");
    }

    /**
     * @dev Returns encoded initialization data for deploy contract
     * @param tokenAddress The vesting token address
     * @param tokenDecimals The number of decimals for vesting token
     * @param allowAccumulate `true` if multiple grant amounts is allowed to accumulate for the same user,
     *                        `false` if a user can only have one grant
     * @param backofficeAddress The backoffice admin address that will be set for deploy contract
     * @param tenantAdminAddress The tenant admin address that will be set for deploy contract
     * @return encodedData The encoded initialization data for deploy contract
     */
    function _encodeInitializeData(
        address tokenAddress,
        uint256 tokenDecimals,
        bool allowAccumulate,
        address backofficeAddress,
        address tenantAdminAddress
    ) internal pure virtual returns (bytes memory encodedData) {
        encodedData = abi.encodeWithSignature(
            "initialize(address,uint256,bool,address,address)",
            tokenAddress,
            tokenDecimals,
            allowAccumulate,
            backofficeAddress,
            tenantAdminAddress
        );
    }

    /**
     * @dev Returns encoded salt data for deploy contract
     * @param deployId The deploy identifier
     * @return encodedData The encoded salt data for deploy contract
     */
    function _encodeSaltData(bytes32 deployId) internal pure virtual returns (bytes memory encodedData) {
        encodedData = abi.encodeWithSignature("salt(bytes32)", deployId);
    }
}
