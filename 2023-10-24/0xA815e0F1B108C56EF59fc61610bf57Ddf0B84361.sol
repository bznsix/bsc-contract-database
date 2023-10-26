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
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";

contract AdminHelper is Ownable, AccessControl {

    bytes32 public constant ADMIN_ROLE = keccak256("ADMIN_ROLE");

    modifier onlySuperAdmin() {
        require(hasRole(DEFAULT_ADMIN_ROLE, msg.sender) || msg.sender == owner(),"super admin only");
        _;
    }

    modifier onlyAdmin() {
        require(hasRole(ADMIN_ROLE, msg.sender) || hasRole(DEFAULT_ADMIN_ROLE, msg.sender) || msg.sender == owner(), "admin only");
        _;
    }

    constructor() {
        _setupRole(DEFAULT_ADMIN_ROLE, msg.sender);
    }

    function isAdmin(address _addr) public view returns(bool) {
        return hasRole(ADMIN_ROLE, _addr) || _addr == owner();
    }
}// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.9;

interface IGoodsStruct {
    /// @notice Used to store the info of NFT spec
    struct NFTSpec {
        uint256 categoryId;
        uint256 typeId;
        uint256 amount;
    }

    /// @notice Used to store the info of goods
    struct Goods {
        uint256 goodsId;
        uint256 quantity;
        bool status;
        bool wlEnabled;
        uint8 paymentMode;
        uint256 price;
        uint256 salesStartTime;
        NFTSpec[] nftSpecs;
    }
}// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "../helpers/AdminHelper.sol";
import "./IGoodsStruct.sol";
import "./StoreData.sol";

interface IMinter {
    /// @notice Mint erc721 or erc1155 token by type id
    function mintByTypeId(address _to, uint256 _typeId, uint256 _amount) external;
}

contract Store is ReentrancyGuard, AdminHelper, IGoodsStruct {
    /// @notice The instance of store data
    StoreData public storeData;

    /// @notice The address of foundation wallet
    address payable public foundationWallet;

    /// @notice Whether enable purchase
    bool public isPurchaseEnabled;

    /// @notice Verify address not zero address
    /// @param _address The address which need to verify
    modifier nonZeroAddress(address _address) {
        require(_address != address(0), "Store: invalid zero address");
        _;
    }

    constructor(address payable _foundationWallet) nonZeroAddress(_foundationWallet) {
        foundationWallet = _foundationWallet;
    }

    /// @notice Verify goods is in unList status
    /// @param _goodsId The goods id which need to verify
    modifier unListStatus(uint256 _goodsId) {
        Goods memory goods = storeData.getGoods(_goodsId);
        require(!goods.status, "Store: goods is not in unList status");
        _;
    }

    /// @notice See {setPurchaseEnabled}
    event PurchaseEnabled(bool _flag);

    /// @notice See {addOrUpdateGoods}
    event AddGoods(uint256 indexed _goodsId, uint256 _quantity, bool _status, bool _wlEnabled, uint256 _paymentMode, uint256 _price, uint256 _salesStartTime, NFTSpec[] _nftSpecs, address[] _addresses);

    /// @notice See {addOrUpdateGoods}
    event UpdateGoods(uint256 indexed _goodsId, uint256 _quantity, bool _status, bool _wlEnabled, uint256 _paymentMode, uint256 _price, uint256 _salesStartTime, NFTSpec[] _nftSpecs, address[] _addresses);
    
    /// @notice See {removeGoods}
    event RemoveGoods(uint256 indexed _goodsId);
    
    /// @notice See {updateQuantity}
    event UpdateQuantity(uint256 indexed _goodsId, uint256 _quantity);

    /// @notice See {updateStatus}
    event UpdateStatus(uint256 indexed _goodsId, bool _status);

    /// @notice See {updatePrice}
    event UpdatePrice(uint256 indexed _goodsId, uint256 _price);
    
    /// @notice See {updateSalesStartTime}
    event UpdateSalesStartTime(uint256 indexed _goodsId, uint256 _timestamp);
    
    /// @notice See {enableWhiteList}
    event EnableWhiteList(uint256 indexed _goodsId, bool _enabled);
    
    /// @notice See {addToWhiteList}
    event AddToWhiteList(uint256 indexed _goodsId, address _address);

    /// @notice See {addToWhiteListBatch}
    event AddToWhiteListBatch(uint256 indexed _goodsId, address[] _addresses);
    
    /// @notice See {removeFromWhiteList}
    event RemoveFromWhiteList(uint256 indexed _goodsId, address _address);

    /// @notice See {removeFromWhiteListBatch}
    event RemoveFromWhiteListBatch(uint256 indexed _goodsId, address[] _addresses);

    /// @notice See {purchase}
    event Purchase(address indexed _purchaser, uint8 indexed _paymentMode, uint256 indexed _goodsId, uint256 _quantity, uint256 _amount);

    /// @notice Set contract address of store data
    /// @param _storeDataAddress The contract address of store data
    function setStoreData(address _storeDataAddress) external onlyAdmin nonZeroAddress(_storeDataAddress) {
        storeData = StoreData(_storeDataAddress);
    }

    /// @notice Set foundation wallet address
    /// @param _foundationWallet The address of foundation wallet
    function setFoundationWallet(address payable _foundationWallet) external onlyOwner nonZeroAddress(_foundationWallet) {
        foundationWallet = _foundationWallet;
    }

    /// @notice Set whether enable purchase
    /// @param _flag Whether enable purchase
    function setPurchaseEnabled(bool _flag) external onlyAdmin {
        require(isPurchaseEnabled != _flag, "Store: flag value already set");

        isPurchaseEnabled = _flag;

        emit PurchaseEnabled(_flag);
    }

    /// @notice Add or update goods
    /// @param _goods The goods which need to add or update
    /// @param _addresses The address array which need add to white list
    function addOrUpdateGoods(Goods calldata _goods, address[] calldata _addresses) external onlyAdmin nonZeroAddress(address(storeData)) {
        if (!storeData.isGoodsExist(_goods.goodsId)) {
            storeData.addGoods(_goods, _addresses);

            emit AddGoods(_goods.goodsId, _goods.quantity, _goods.status, _goods.wlEnabled, _goods.paymentMode, 
                _goods.price, _goods.salesStartTime, _goods.nftSpecs, _addresses);
        } else {
            require(!storeData.getGoods(_goods.goodsId).status, "Store: goods is not in unList status");

            storeData.updateGoods(_goods, _addresses);

            emit UpdateGoods(_goods.goodsId, _goods.quantity, _goods.status, _goods.wlEnabled, _goods.paymentMode, 
                _goods.price, _goods.salesStartTime, _goods.nftSpecs, _addresses);
        }
    }

    /// @notice Remove goods
    /// @param _goodsId The goods id of the goods which need to remove
    function removeGoods(uint256 _goodsId) external onlyAdmin nonZeroAddress(address(storeData)) unListStatus(_goodsId) {
        storeData.removeGoods(_goodsId);

        emit RemoveGoods(_goodsId);
    }

    /// @notice Modify goods quantity
    /// @param _goodsId The goods id of the goods which need to modify quantity
    /// @param _quantity The new quantity of the goods
    function updateQuantity(uint256 _goodsId, uint256 _quantity) external onlyAdmin nonZeroAddress(address(storeData)) {
        storeData.updateQuantity(_goodsId, _quantity);

        emit UpdateQuantity(_goodsId, _quantity);
    }

    /// @notice Modify goods status
    /// @param _goodsId The goods id of the goods which need to modify status
    /// @param _status The new status of the goods
    function updateStatus(uint256 _goodsId, bool _status) external onlyAdmin nonZeroAddress(address(storeData)) {
        storeData.updateStatus(_goodsId, _status);

        emit UpdateStatus(_goodsId, _status);
    }

    /// @notice Modify goods price
    /// @param _goodsId The goods id of the goods which need to modify price
    /// @param _price The new price of the goods
    function updatePrice(uint256 _goodsId, uint256 _price) external onlyAdmin nonZeroAddress(address(storeData)) unListStatus(_goodsId) {
        storeData.updatePrice(_goodsId, _price);

        emit UpdatePrice(_goodsId, _price);
    }

    /// @notice Modify goods sales start time
    /// @param _goodsId The goods id of the goods which need to modify sales start time
    /// @param _timestamp The new sales start time of the goods
    function updateSalesStartTime(uint256 _goodsId, uint256 _timestamp) external onlyAdmin nonZeroAddress(address(storeData)) unListStatus(_goodsId) {
        storeData.updateSaleStartTime(_goodsId, _timestamp);

        emit UpdateSalesStartTime(_goodsId, _timestamp);
    }

    /// @notice Set whether enable white list
    /// @param _goodsId The goods id of the goods which need to set enable white list
    /// @param _enabled Whether enable white list
    function enableWhiteList(uint256 _goodsId, bool _enabled) external onlyAdmin nonZeroAddress(address(storeData)) {
        storeData.enableWhiteList(_goodsId, _enabled);

        emit EnableWhiteList(_goodsId, _enabled);
    }

    /// @notice Add address to white list
    /// @param _goodsId The goods id of the goods which need to add white list
    /// @param _address The address which need add to white list
    function addToWhiteList(uint256 _goodsId, address _address) external onlyAdmin nonZeroAddress(address(storeData)) {
        storeData.addToWhiteList(_goodsId, _address);

        emit AddToWhiteList(_goodsId, _address);
    }

    /// @notice Batch add address to white list
    /// @param _goodsId The goods id of the goods which need to add white list
    /// @param _addresses The address array which need add to white list
    function addToWhiteListBatch(uint256 _goodsId, address[] calldata _addresses) external onlyAdmin nonZeroAddress(address(storeData)) {
        uint256 length = _addresses.length;
        for (uint256 i = 0; i < length; i++) {
            storeData.addToWhiteList(_goodsId, _addresses[i]);
        }

        emit AddToWhiteListBatch(_goodsId, _addresses);
    }

    /// @notice Remove address from white list
    /// @param _goodsId The goods id of the goods which need to remove white list
    /// @param _address The address which need remove from white list
    function removeFromWhiteList(uint256 _goodsId, address _address) external onlyAdmin nonZeroAddress(address(storeData)) {
        storeData.removeFromWhiteList(_goodsId, _address);

        emit RemoveFromWhiteList(_goodsId, _address);
    }

    /// @notice Batch remove address from white list
    /// @param _goodsId The goods id of the goods which need to remove white list
    /// @param _addresses The address array which need remove from white list
    function removeFromWhiteListBatch(uint256 _goodsId, address[] calldata _addresses) external onlyAdmin nonZeroAddress(address(storeData)) {
        uint256 length = _addresses.length;
        for (uint256 i = 0; i < length; i++) {
            storeData.removeFromWhiteList(_goodsId, _addresses[i]);
        }

        emit RemoveFromWhiteListBatch(_goodsId, _addresses);
    }

    /// @notice Purchase goods
    /// @param _goodsId The goods id of the goods which user purchase
    /// @param _quantity The quantity of purchase goods
    function purchase(uint256 _goodsId, uint256 _quantity, uint256 _amount) external payable nonReentrant nonZeroAddress(address(storeData)) {
        require(isPurchaseEnabled, "Store: not enabled purchase");
        Goods memory goods = storeData.getGoods(_goodsId);
        require(goods.status, "Store: goods is not in list status");
        require(_quantity <= goods.quantity, "Store: available quantity not enough");
        require(_amount == goods.price * _quantity, "Store: amount mismatch");
        require(block.timestamp > goods.salesStartTime, "Store: not yet sales");
        if (goods.wlEnabled) {
            require(storeData.isInWhiteList(_goodsId, _msgSender()), "Store: purchaser is not in white list");
        }

        uint8 paymentMode = goods.paymentMode;
        if (paymentMode == 0) {
            require(msg.value == _amount, "Store: value mismatch");
            (bool os, ) = foundationWallet.call{value: _amount}("");
            require(os, "Store: fail to transfer native token");
        } else {
            require(msg.value == 0, "Store: not receive native token");
            address paymentAddress = storeData.paymentModeToAddress(paymentMode);
            require(paymentAddress != address(0), "Store: invalid zero address");
            require(IERC20(paymentAddress).transferFrom(_msgSender(), foundationWallet, _amount), "Store: fail to transfer payment token");
        }

        storeData.updateQuantity(_goodsId, goods.quantity - _quantity);

        uint256 length = goods.nftSpecs.length;
        for (uint256 i = 0; i < length; i++) {
            IMinter minter = IMinter(storeData.nftMinter(goods.nftSpecs[i].categoryId));
            minter.mintByTypeId(_msgSender(), goods.nftSpecs[i].typeId, goods.nftSpecs[i].amount * _quantity);
        }

        emit Purchase(_msgSender(), paymentMode, _goodsId, _quantity, _amount);
    }
}// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.9;

import "./IGoodsStruct.sol";

interface StoreData is IGoodsStruct {

    function nftMinter(uint tokenCategoryId) external view returns (address);
    function paymentModeToAddress(uint paymentMode) external view returns (address);
    function addGoods(Goods calldata goods, address[] calldata whitelistAddrs) external;
    function updateGoods(Goods calldata goods, address[] calldata whitelistAddrs) external;
    function removeGoods(uint goodsId) external;
    function updatePrice(uint goodsId, uint price) external;
    function updateQuantity(uint goodsId, uint quantity) external;
    function updateStatus(uint goodsId, bool status) external;
    function updateSaleStartTime(uint goodsId, uint timestamp) external;
    function enableWhiteList(uint goodsId, bool enabled) external;
    function addToWhiteList(uint goodsId, address addr) external;
    function removeFromWhiteList(uint goodsId, address addr) external;
    function isGoodsExist(uint goodsId) external view returns (bool);
    function getGoods(uint goodsId) external view returns (Goods memory);
    function isInWhiteList(uint goodsId, address addr) external view returns (bool);

}