// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v5.0.0) (access/AccessControl.sol)

pragma solidity ^0.8.20;

import {IAccessControl} from "./IAccessControl.sol";
import {Context} from "../utils/Context.sol";
import {ERC165} from "../utils/introspection/ERC165.sol";

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
        mapping(address account => bool) hasRole;
        bytes32 adminRole;
    }

    mapping(bytes32 role => RoleData) private _roles;

    bytes32 public constant DEFAULT_ADMIN_ROLE = 0x00;

    /**
     * @dev Modifier that checks that an account has a specific role. Reverts
     * with an {AccessControlUnauthorizedAccount} error including the required role.
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
    function hasRole(bytes32 role, address account) public view virtual returns (bool) {
        return _roles[role].hasRole[account];
    }

    /**
     * @dev Reverts with an {AccessControlUnauthorizedAccount} error if `_msgSender()`
     * is missing `role`. Overriding this function changes the behavior of the {onlyRole} modifier.
     */
    function _checkRole(bytes32 role) internal view virtual {
        _checkRole(role, _msgSender());
    }

    /**
     * @dev Reverts with an {AccessControlUnauthorizedAccount} error if `account`
     * is missing `role`.
     */
    function _checkRole(bytes32 role, address account) internal view virtual {
        if (!hasRole(role, account)) {
            revert AccessControlUnauthorizedAccount(account, role);
        }
    }

    /**
     * @dev Returns the admin role that controls `role`. See {grantRole} and
     * {revokeRole}.
     *
     * To change a role's admin, use {_setRoleAdmin}.
     */
    function getRoleAdmin(bytes32 role) public view virtual returns (bytes32) {
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
    function grantRole(bytes32 role, address account) public virtual onlyRole(getRoleAdmin(role)) {
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
    function revokeRole(bytes32 role, address account) public virtual onlyRole(getRoleAdmin(role)) {
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
     * - the caller must be `callerConfirmation`.
     *
     * May emit a {RoleRevoked} event.
     */
    function renounceRole(bytes32 role, address callerConfirmation) public virtual {
        if (callerConfirmation != _msgSender()) {
            revert AccessControlBadConfirmation();
        }

        _revokeRole(role, callerConfirmation);
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
     * @dev Attempts to grant `role` to `account` and returns a boolean indicating if `role` was granted.
     *
     * Internal function without access restriction.
     *
     * May emit a {RoleGranted} event.
     */
    function _grantRole(bytes32 role, address account) internal virtual returns (bool) {
        if (!hasRole(role, account)) {
            _roles[role].hasRole[account] = true;
            emit RoleGranted(role, account, _msgSender());
            return true;
        } else {
            return false;
        }
    }

    /**
     * @dev Attempts to revoke `role` to `account` and returns a boolean indicating if `role` was revoked.
     *
     * Internal function without access restriction.
     *
     * May emit a {RoleRevoked} event.
     */
    function _revokeRole(bytes32 role, address account) internal virtual returns (bool) {
        if (hasRole(role, account)) {
            _roles[role].hasRole[account] = false;
            emit RoleRevoked(role, account, _msgSender());
            return true;
        } else {
            return false;
        }
    }
}
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v5.0.0) (access/IAccessControl.sol)

pragma solidity ^0.8.20;

/**
 * @dev External interface of AccessControl declared to support ERC165 detection.
 */
interface IAccessControl {
    /**
     * @dev The `account` is missing a role.
     */
    error AccessControlUnauthorizedAccount(address account, bytes32 neededRole);

    /**
     * @dev The caller of a function is not the expected one.
     *
     * NOTE: Don't confuse with {AccessControlUnauthorizedAccount}.
     */
    error AccessControlBadConfirmation();

    /**
     * @dev Emitted when `newAdminRole` is set as ``role``'s admin role, replacing `previousAdminRole`
     *
     * `DEFAULT_ADMIN_ROLE` is the starting admin for all roles, despite
     * {RoleAdminChanged} not being emitted signaling this.
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
     * - the caller must be `callerConfirmation`.
     */
    function renounceRole(bytes32 role, address callerConfirmation) external;
}
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v5.0.1) (utils/Context.sol)

pragma solidity ^0.8.20;

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

    function _contextSuffixLength() internal view virtual returns (uint256) {
        return 0;
    }
}
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v5.0.0) (utils/introspection/ERC165.sol)

pragma solidity ^0.8.20;

import {IERC165} from "./IERC165.sol";

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
 */
abstract contract ERC165 is IERC165 {
    /**
     * @dev See {IERC165-supportsInterface}.
     */
    function supportsInterface(bytes4 interfaceId) public view virtual returns (bool) {
        return interfaceId == type(IERC165).interfaceId;
    }
}
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v5.0.0) (utils/introspection/IERC165.sol)

pragma solidity ^0.8.20;

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
// OpenZeppelin Contracts (last updated v5.0.0) (utils/Pausable.sol)

pragma solidity ^0.8.20;

import {Context} from "../utils/Context.sol";

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
    bool private _paused;

    /**
     * @dev Emitted when the pause is triggered by `account`.
     */
    event Paused(address account);

    /**
     * @dev Emitted when the pause is lifted by `account`.
     */
    event Unpaused(address account);

    /**
     * @dev The operation failed because the contract is paused.
     */
    error EnforcedPause();

    /**
     * @dev The operation failed because the contract is not paused.
     */
    error ExpectedPause();

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
        if (paused()) {
            revert EnforcedPause();
        }
    }

    /**
     * @dev Throws if the contract is not paused.
     */
    function _requirePaused() internal view virtual {
        if (!paused()) {
            revert ExpectedPause();
        }
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
// OpenZeppelin Contracts (last updated v5.0.0) (utils/ReentrancyGuard.sol)

pragma solidity ^0.8.20;

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
    uint256 private constant NOT_ENTERED = 1;
    uint256 private constant ENTERED = 2;

    uint256 private _status;

    /**
     * @dev Unauthorized reentrant call.
     */
    error ReentrancyGuardReentrantCall();

    constructor() {
        _status = NOT_ENTERED;
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
        // On the first call to nonReentrant, _status will be NOT_ENTERED
        if (_status == ENTERED) {
            revert ReentrancyGuardReentrantCall();
        }

        // Any calls to nonReentrant after this point will fail
        _status = ENTERED;
    }

    function _nonReentrantAfter() private {
        // By storing the original value once again, a refund is triggered (see
        // https://eips.ethereum.org/EIPS/eip-2200)
        _status = NOT_ENTERED;
    }

    /**
     * @dev Returns true if the reentrancy guard is currently set to "entered", which indicates there is a
     * `nonReentrant` function in the call stack.
     */
    function _reentrancyGuardEntered() internal view returns (bool) {
        return _status == ENTERED;
    }
}
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/utils/Pausable.sol";
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";

interface IMetastrikeBoxV3 {
    function balanceOf(
        address account,
        uint256 tokenId
    ) external returns (uint256);

    function mint(
        address account,
        uint256 id,
        uint256 amount,
        bytes memory data
    ) external;

    function mintBatch(
        address to,
        uint256[] memory ids,
        uint256[] memory amounts
    ) external;

    function burn(address account, uint256 id, uint256 amount) external;

    function burnBatch(
        address account,
        uint256[] memory ids,
        uint256[] memory amounts
    ) external;
}

interface IERC20 {
    function totalSupply() external view returns (uint256);

    function balanceOf(address account) external view returns (uint256);

    function transfer(
        address recipient,
        uint256 amount
    ) external returns (bool);

    function allowance(
        address owner,
        address spender
    ) external view returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
}

contract MetastrikeBoxV3Operator is AccessControl, Pausable, ReentrancyGuard {
    bytes32 public constant PAUSER_ROLE = keccak256("PAUSER_ROLE");
    bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");
    bytes32 public constant BURNER_ROLE = keccak256("BURNER_ROLE");

    IMetastrikeBoxV3 public metastrikeBoxV3;

    struct BoxType {
        string name;
        uint256 tokenId;
        uint256 supply;
        uint256 minted;
        uint256 burned;
        uint256 price;
        IERC20 token;
        bool active;
    }

    struct BoxMinted {
        uint256 boxId;
        bool isOpened;
    }

    uint256 public maxAmount = 10;

    mapping(uint256 => bool) public tokenIds;

    mapping(uint256 => BoxType) public boxTypes;

    event GovBoxTypeAdd(uint256 tokendId, BoxType boxType);
    event GovChangeBoxTypeName(uint256 tokendId, string name);
    event GovChangeBoxTypeSupply(uint256 tokendId, uint256 supply);
    event GovChangeBoxTypePrice(uint256 tokendId, uint256 price);
    event GovChangeBoxTypeToken(uint256 tokendId, address token);
    event GovChangeBoxTypeActive(uint256 tokendId, bool active);

    event BoxMint(address user, uint256 tokenId, uint256 amount, bool isGov);
    event BoxMintBatch(
        address user,
        uint256[] tokenIds,
        uint256[] amounts,
        bool isGov
    );
    event BoxBurn(address user, uint256 tokenId, uint256 amount, bool isGov);
    event BoxBurnBatch(
        address user,
        uint256[] tokenIds,
        uint256[] amounts,
        bool isGov
    );

    constructor(address defaultAdmin, address pauser, address minter) {
        _grantRole(DEFAULT_ADMIN_ROLE, defaultAdmin);
        _grantRole(PAUSER_ROLE, pauser);
        _grantRole(MINTER_ROLE, minter);
    }

    function pause() public onlyRole(PAUSER_ROLE) {
        _pause();
    }

    function unpause() public onlyRole(PAUSER_ROLE) {
        _unpause();
    }

    function govSetMetastrikeBoxV3(
        address _metastrikeBoxV3
    ) public onlyRole(DEFAULT_ADMIN_ROLE) {
        metastrikeBoxV3 = IMetastrikeBoxV3(_metastrikeBoxV3);
    }

    function govSetMaxAmount(
        uint256 _maxAmount
    ) public onlyRole(DEFAULT_ADMIN_ROLE) {
        maxAmount = _maxAmount;
    }

    function govAddBoxType(
        string memory _name,
        uint256 _tokenId,
        uint256 _supply,
        uint256 _price,
        address _token,
        bool _active
    ) public onlyRole(DEFAULT_ADMIN_ROLE) {
        require(_token != address(0), "invalid token address");
        require(checkTokenIdExists(_tokenId) == false, "_tokenId exists");

        BoxType memory boxType = BoxType({
            name: _name,
            tokenId: _tokenId,
            supply: _supply,
            minted: 0,
            burned: 0,
            price: _price,
            token: IERC20(_token),
            active: _active
        });

        tokenIds[_tokenId] = true;
        boxTypes[_tokenId] = boxType;
        emit GovBoxTypeAdd(_tokenId, boxType);
    }

    function govChangeBoxTypeName(
        uint256 _tokenId,
        string memory _name
    ) public onlyRole(DEFAULT_ADMIN_ROLE) {
        require(checkTokenIdExists(_tokenId) == true, "_tokenId not exists");

        BoxType storage boxType = boxTypes[_tokenId];
        boxType.name = _name;

        emit GovChangeBoxTypeName(_tokenId, _name);
    }

    function govChangeBoxTypeSupply(
        uint256 _tokenId,
        uint256 _supply
    ) public onlyRole(DEFAULT_ADMIN_ROLE) {
        require(checkTokenIdExists(_tokenId) == true, "_tokenId not exists");

        BoxType storage boxType = boxTypes[_tokenId];

        require(_supply >= boxType.supply, "can not exceeds current supply");

        boxType.supply = _supply;

        emit GovChangeBoxTypeSupply(_tokenId, _supply);
    }

    function govChangeBoxTypePrice(
        uint256 _tokenId,
        uint256 _price
    ) public onlyRole(DEFAULT_ADMIN_ROLE) {
        require(checkTokenIdExists(_tokenId) == true, "_tokenId not exists");

        BoxType storage boxType = boxTypes[_tokenId];

        boxType.price = _price;

        emit GovChangeBoxTypePrice(_tokenId, _price);
    }

    function govChangeBoxTypeToken(
        uint256 _tokenId,
        address _token
    ) public onlyRole(DEFAULT_ADMIN_ROLE) {
        require(_token != address(0), "invalid token address");
        require(checkTokenIdExists(_tokenId) == true, "_tokenId not exists");

        BoxType storage boxType = boxTypes[_tokenId];

        boxType.token = IERC20(_token);

        emit GovChangeBoxTypeToken(_tokenId, _token);
    }

    function govChangeBoxTypeActive(
        uint256 _tokenId,
        bool _active
    ) public onlyRole(DEFAULT_ADMIN_ROLE) {
        require(checkTokenIdExists(_tokenId) == true, "_tokenId not exists");

        BoxType storage boxType = boxTypes[_tokenId];

        boxType.active = _active;

        emit GovChangeBoxTypeActive(_tokenId, _active);
    }

    function mint(uint256 _tokenId, uint256 _amount) public nonReentrant {
        require(checkTokenIdExists(_tokenId) == true, "_tokenId not exists");
        require(_amount > 0, "amount must larger than 0");
        require(_amount <= maxAmount, "can not exceeds max amount");

        BoxType storage boxType = boxTypes[_tokenId];

        require(
            boxType.minted + _amount <= boxType.supply,
            "can not exceeds box type supply"
        );

        boxType.minted += _amount;

        boxType.token.transferFrom(
            msg.sender,
            address(this),
            boxType.price * _amount
        );

        metastrikeBoxV3.mint(msg.sender, _tokenId, _amount, "");

        emit BoxMint(msg.sender, _tokenId, _amount, false);
    }

    function mintBatch(
        uint256[] memory _tokenIds,
        uint256[] memory _amounts
    ) public nonReentrant {
        require(checkTokenIdsExists(_tokenIds) == true, "some of _tokenId not exists");
        require(checkBatchLengths(_tokenIds, _amounts), "lenths do not match");

        for (uint i = 0; i < _tokenIds.length; i++) {
            BoxType storage boxType = boxTypes[_tokenIds[i]];

            require(
                boxType.minted + _amounts[i] <= boxType.supply,
                "can not exceeds box type supply"
            );

            boxType.minted += _amounts[i];

            boxType.token.transferFrom(
                msg.sender,
                address(this),
                boxType.price * _amounts[i]
            );

            metastrikeBoxV3.mint(msg.sender, _tokenIds[i], _amounts[i], "");
        }

        emit BoxMintBatch(msg.sender, _tokenIds, _amounts, true);
    }

    function burn(uint256 _tokenId, uint256 _amount) public nonReentrant {
        require(checkTokenIdExists(_tokenId) == true, "_tokenId not exists");
        require(
            metastrikeBoxV3.balanceOf(msg.sender, _tokenId) >= _amount,
            "insufficient nft tokens"
        );

        metastrikeBoxV3.burn(msg.sender, _tokenId, _amount);

        boxTypes[_tokenId].burned += _amount;

        emit BoxBurn(msg.sender, _tokenId, _amount, false);
    }

    function burnBatch(
        uint256[] memory _tokenIds,
        uint256[] memory _amounts
    ) public nonReentrant {
        require(checkTokenIdsExists(_tokenIds) == true, "some of _tokenId not exists");
        require(checkBatchLengths(_tokenIds, _amounts), "lenths do not match");

        for (uint i = 0; i < _tokenIds.length; i++) {
            require(
                metastrikeBoxV3.balanceOf(msg.sender, _tokenIds[i]) >=
                    _amounts[i],
                "some of tokenId amount exeeds user balance"
            );
            metastrikeBoxV3.burn(msg.sender, _tokenIds[i], _amounts[i]);
            boxTypes[_tokenIds[i]].burned += _amounts[i];
        }
        emit BoxBurnBatch(msg.sender, _tokenIds, _amounts, true);
    }

    function govMint(
        address _user,
        uint256 _tokenId,
        uint256 _amount
    ) public nonReentrant {
        checkTokenIdExists(_tokenId);
        require(_amount > 0, "amount must larger than 0");
        require(_amount <= maxAmount, "can not exceeds max amount");

        BoxType storage boxType = boxTypes[_tokenId];

        require(
            boxType.minted + _amount <= boxType.supply,
            "can not exceeds box type supply"
        );

        boxType.minted += _amount;

        metastrikeBoxV3.mint(_user, _tokenId, _amount, "");

        emit BoxMint(_user, _tokenId, _amount, true);
    }

    function govMintBatch(
        address _user,
        uint256[] memory _tokenIds,
        uint256[] memory _amounts
    ) public nonReentrant {
        checkBatchLengths(_tokenIds, _amounts);
        checkTokenIdsExists(_tokenIds);

        for (uint i = 0; i < _tokenIds.length; i++) {
            BoxType storage boxType = boxTypes[_tokenIds[i]];

            require(
                boxType.minted + _amounts[i] <= boxType.supply,
                "can not exceeds box type supply"
            );

            boxType.minted += _amounts[i];

            metastrikeBoxV3.mint(_user, _tokenIds[i], _amounts[i], "");
        }

        emit BoxMintBatch(_user, _tokenIds, _amounts, true);
    }

    function govWithdraw(
        uint256 _amount,
        address _token
    ) external onlyRole(DEFAULT_ADMIN_ROLE) {
        IERC20(_token).transfer(
            msg.sender,
            _amount == 0 ? IERC20(_token).balanceOf(address(this)) : _amount
        );
    }

    function checkBatchLengths(
        uint256[] memory _items1,
        uint256[] memory _items2
    ) internal pure returns (bool) {
        uint256 length1 = _items1.length;
        uint256 length2 = _items2.length;
        
        return length1 != 0 && length2 != 0 && length1 == length2 ? true : false;
    }

    function checkTokenIdExists(uint256 _tokenId) internal view returns (bool) {
        return tokenIds[_tokenId];
    }

    function checkTokenIdsExists(
        uint256[] memory _tokenIds
    ) internal view returns (bool) {
        for (uint i = 0; i < _tokenIds.length; i++) {
            if (tokenIds[_tokenIds[i]] == false) {
                return false;
            }
        }

        return true;
    }
}
