// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.5.0) (access/AccessControl.sol)

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
        _checkRole(role, _msgSender());
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
// OpenZeppelin Contracts v4.4.1 (access/Ownable.sol)

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
     * @dev Returns the address of the current owner.
     */
    function owner() public view virtual returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
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
}// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "../helpers/AdminHelper.sol";

interface ERC20 {
    function transfer(address to, uint256 amount) external returns (bool);

    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);
}

interface VimOwnershipERC721 {
    function checkExists(uint _tokenId) external view returns(bool);
}

interface VeedValueHelper {
    function checkVimId(uint _vimId) external view returns(bool);
}

interface VimVeed {
    function idToVeed(uint vimId) external view returns (uint);
}

contract VimVeedV2 is AdminHelper {

    struct MigrateVimVeed {
        uint tokenId;
        uint amount;
    }
    
    // Event tracking all deposits
    event Deposit(address indexed _from, uint indexed _vimId, uint _amount);
    // Event tracking all withdraws
    event Withdraw(address indexed _to, uint indexed _vimId, uint _amount);
    // Event tracking migration
    event MigratedVimVeed(uint _vimId, uint _amount);

    event DepositContractAdded(address _depositContract);
    event DepositContractRemoved(address _depositContract);
    event WithdrawContractAdded(address _withdrawContract);
    event WithdrawContractRemoved(address _withdrawContract);

    event EmergencyWithdraw(address _to, uint _amount);

    mapping(address => bool) public isApprovedDeposit;
    mapping(address => bool) public isApprovedWithdraw;

    address[] public depositContracts;
    address[] public withdrawContracts;

    mapping(address => uint) public depositIndex;
    mapping(address => uint) public withdrawIndex;
    
    // Mapping containing VEED balance of all VIMs.
    mapping(uint => uint) public idToVeed;
    // Mapping checking off that VIM had its VimVeed balance migrated over.
    mapping(uint => bool) public idToVeedMigrated;

    ERC20 public veedERC20Contract;
    VimOwnershipERC721 public vim;
    VeedValueHelper public veedValueHelper;
    address public migrationWallet;
    VimVeed public oldVimVeed;


    constructor(address _veedAddress, address _vim, address _mig, address _vimVeedOld) {
        require(_veedAddress != address(0) && _vim != address(0), "Invalid addr");
        require(_mig != address(0), "Invalid addr");
        vim = VimOwnershipERC721(_vim);
        veedERC20Contract = ERC20(_veedAddress);
        migrationWallet = _mig;
        oldVimVeed = VimVeed(_vimVeedOld);
    }

    function updateVimContract(address _vim) external onlyOwner {
        require(_vim != address(0), "Invalid addr");
        vim = VimOwnershipERC721(_vim);
    }

    function setVeedValueHelper(address _addr) external onlyOwner {
        require(_addr != address(0), "Invalid addr");
        veedValueHelper = VeedValueHelper(_addr);
    }

    function setVeed(address _addr) external onlyOwner {
        require(_addr != address(0), "Invalid addr");
        veedERC20Contract = ERC20(_addr);
    }

    function setMigWallet(address _addr) external onlyOwner {
        require(_addr != address(0), "Invalid addr");
        migrationWallet = _addr;
    }

    function addDepositContract(address _addr) external onlyAdmin {
        require(_addr != address(0), "Invalid addr");
        require(isApprovedDeposit[_addr] != true, "Already added");

        isApprovedDeposit[_addr] = true;
        depositContracts.push(_addr);
        depositIndex[_addr] = depositContracts.length - 1;

        emit DepositContractAdded(_addr);
    }

    function removeDepositContract(address _addr) external onlyAdmin {
        require(_addr != address(0), "Invalid addr");
        require(isApprovedDeposit[_addr] == true, "Already removed");

        isApprovedDeposit[_addr] = false;
        uint index = depositIndex[_addr];
        if(index != depositContracts.length - 1) {
            address lastAddr = depositContracts[depositContracts.length - 1];
            depositContracts[index] = lastAddr;
            depositIndex[lastAddr] = index;
        }
        depositContracts.pop();
        delete(depositIndex[_addr]);

        emit DepositContractRemoved(_addr);
    }

    function addWithdrawContract(address _addr) external onlyAdmin {
        require(_addr != address(0), "Invalid addr");
        require(isApprovedWithdraw[_addr] != true, "Already added");

        isApprovedWithdraw[_addr] = true;
        withdrawContracts.push(_addr);
        withdrawIndex[_addr] = withdrawContracts.length - 1;

        emit WithdrawContractAdded(_addr);
    }

    function removeWithdrawContract(address _addr) external onlyAdmin {
        require(_addr != address(0), "Invalid addr");
        require(isApprovedWithdraw[_addr] == true, "Already removed");

        isApprovedWithdraw[_addr] = false;
        uint index = withdrawIndex[_addr];
        if(index != withdrawContracts.length - 1) {
            address lastAddr = withdrawContracts[withdrawContracts.length - 1];
            withdrawContracts[index] = lastAddr;
            withdrawIndex[lastAddr] = index;
        }
        withdrawContracts.pop();
        delete(withdrawIndex[_addr]);

        emit WithdrawContractRemoved(_addr);
    }

    function getDepositContractsAmount() external view returns(uint) {
        return depositContracts.length;
    }

    function getWithdrawContractsAmount() external view returns(uint) {
        return withdrawContracts.length;
    }

    function getDepositContracts(uint _offset, uint _limit) external view returns(address[] memory) {
        uint len = depositContracts.length;

        require(_offset <= len, "_offset cannot be greater than length");
        
        address[] memory list = new address[](_limit);
        
        for (uint i = 0; i < _limit; i++) {
            if (i + _offset < len) {
                address addr = depositContracts[i+ _offset];
                list[i] = addr;
            }
            else {
                break;
            }
        }
        return list;
    }

    function getWithdrawContracts(uint _offset, uint _limit) external view returns(address[] memory) {
        uint len = withdrawContracts.length;

        require(_offset <= len, "_offset cannot be greater than length");
        
        address[] memory list = new address[](_limit);
        
        for (uint i = 0; i < _limit; i++) {
            if (i + _offset < len) {
                address addr = withdrawContracts[i+ _offset];
                list[i] = addr;
            }
            else {
                break;
            }
        }
        return list;
    }
    
    //-------------------------------------------------------------------------
    /// @notice Adds VEED to a VIM's VEED balance.
    /// @dev Throws unless sender is an approved deposit contract.
    /// @param _vimId The UID of the VIM to deposit VEED into.
    /// @param _amount the amount of VEED to deposit into the VIM.
    //-------------------------------------------------------------------------
    function depositVeedReceiver(address _from, uint _vimId, uint _amount) external {
        require(isApprovedDeposit[msg.sender],"approved only");

        /** NEW : Check Token ID */
        require(veedValueHelper.checkVimId(_vimId), "Token DNE");
        
        idToVeed[_vimId] = idToVeed[_vimId] + _amount;
        
        require(veedERC20Contract.transferFrom(_from, address(this), _amount), "Failed transfer");
        
        emit Deposit(_from, _vimId, _amount);
    }
    
    //-------------------------------------------------------------------------
    /// @notice Transfers VEED from a VIM to a destination address.
    /// @dev Throws unless sender is an approved withdraw contract.
    /// @param _to The destination address to transfer VEED to.
    /// @param _vimId The UID of the VIM to withdraw VEED from.
    /// @param _amount the amount of VEED to withdraw and transfer.
    //-------------------------------------------------------------------------
    function withdrawVeedReceiver(address _to, uint _vimId, uint _amount) external {
        require(isApprovedWithdraw[msg.sender], "approved only");

        /** NEW : Check Token ID */
        require(veedValueHelper.checkVimId(_vimId), "Token DNE");
        
        idToVeed[_vimId] = idToVeed[_vimId] - _amount;
        
        require(veedERC20Contract.transfer(_to, _amount), "Failed transfer");
        
        emit Withdraw(_to, _vimId, _amount);
    }

    function migrateVimVeedToNew(uint[] calldata _arr) external {
        require(msg.sender == migrationWallet, "Only mig");
        require(_arr.length > 0, "end index");

        for(uint i = 0; i < _arr.length; i++) {
            
            require(idToVeedMigrated[_arr[i]] == false, "already mig");
            require(vim.checkExists(_arr[i]), "dne");
            // Check off Vim migrated
            idToVeedMigrated[_arr[i]] = true;
            // Set migrated energy amount
            idToVeed[_arr[i]] = oldVimVeed.idToVeed(_arr[i]);

            emit MigratedVimVeed(_arr[i], oldVimVeed.idToVeed(_arr[i]));
        }
    }

    function migrateVimVeedBatch(MigrateVimVeed[] calldata _vimVeedSet) external {
        require(msg.sender == migrationWallet, "only mig");
        require(_vimVeedSet.length > 0, "empty");
        for(uint i = 0; i < _vimVeedSet.length; i++) {
            require(idToVeedMigrated[_vimVeedSet[i].tokenId] == false, "already mig");
            require(vim.checkExists(_vimVeedSet[i].tokenId), "dne");
            // Check off Vim migrated
            idToVeedMigrated[_vimVeedSet[i].tokenId] = true;
            // Set migrated fed amount
            idToVeed[_vimVeedSet[i].tokenId] = _vimVeedSet[i].amount;

            emit MigratedVimVeed(_vimVeedSet[i].tokenId, _vimVeedSet[i].amount);
        }
    }

    function emergencyWithdraw(uint _amount) external onlyOwner {
        bool s = veedERC20Contract.transfer(msg.sender, _amount);
        require(s, "Failed emergency withdraw");
        emit EmergencyWithdraw(msg.sender, _amount);
    }
}