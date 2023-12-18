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
// OpenZeppelin Contracts (last updated v5.0.0) (token/ERC20/IERC20.sol)

pragma solidity ^0.8.20;

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
     * @dev Returns the value of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the value of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Moves a `value` amount of tokens from the caller's account to `to`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address to, uint256 value) external returns (bool);

    /**
     * @dev Returns the remaining number of tokens that `spender` will be
     * allowed to spend on behalf of `owner` through {transferFrom}. This is
     * zero by default.
     *
     * This value changes when {approve} or {transferFrom} are called.
     */
    function allowance(address owner, address spender) external view returns (uint256);

    /**
     * @dev Sets a `value` amount of tokens as the allowance of `spender` over the
     * caller's tokens.
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
    function approve(address spender, uint256 value) external returns (bool);

    /**
     * @dev Moves a `value` amount of tokens from `from` to `to` using the
     * allowance mechanism. `value` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(address from, address to, uint256 value) external returns (bool);
}
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v5.0.0) (utils/Context.sol)

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
pragma solidity >=0.5.0;

interface IUniswapV2Factory {
    event PairCreated(address indexed token0, address indexed token1, address pair, uint);

    function feeTo() external view returns (address);
    function feeToSetter() external view returns (address);

    function getPair(address tokenA, address tokenB) external view returns (address pair);
    function allPairs(uint) external view returns (address pair);
    function allPairsLength() external view returns (uint);

    function createPair(address tokenA, address tokenB) external returns (address pair);

    function setFeeTo(address) external;
    function setFeeToSetter(address) external;
}
pragma solidity >=0.5.0;

interface IUniswapV2Pair {
    event Approval(address indexed owner, address indexed spender, uint value);
    event Transfer(address indexed from, address indexed to, uint value);

    function name() external pure returns (string memory);
    function symbol() external pure returns (string memory);
    function decimals() external pure returns (uint8);
    function totalSupply() external view returns (uint);
    function balanceOf(address owner) external view returns (uint);
    function allowance(address owner, address spender) external view returns (uint);

    function approve(address spender, uint value) external returns (bool);
    function transfer(address to, uint value) external returns (bool);
    function transferFrom(address from, address to, uint value) external returns (bool);

    function DOMAIN_SEPARATOR() external view returns (bytes32);
    function PERMIT_TYPEHASH() external pure returns (bytes32);
    function nonces(address owner) external view returns (uint);

    function permit(address owner, address spender, uint value, uint deadline, uint8 v, bytes32 r, bytes32 s) external;

    event Mint(address indexed sender, uint amount0, uint amount1);
    event Burn(address indexed sender, uint amount0, uint amount1, address indexed to);
    event Swap(
        address indexed sender,
        uint amount0In,
        uint amount1In,
        uint amount0Out,
        uint amount1Out,
        address indexed to
    );
    event Sync(uint112 reserve0, uint112 reserve1);

    function MINIMUM_LIQUIDITY() external pure returns (uint);
    function factory() external view returns (address);
    function token0() external view returns (address);
    function token1() external view returns (address);
    function getReserves() external view returns (uint112 reserve0, uint112 reserve1, uint32 blockTimestampLast);
    function price0CumulativeLast() external view returns (uint);
    function price1CumulativeLast() external view returns (uint);
    function kLast() external view returns (uint);

    function mint(address to) external returns (uint liquidity);
    function burn(address to) external returns (uint amount0, uint amount1);
    function swap(uint amount0Out, uint amount1Out, address to, bytes calldata data) external;
    function skim(address to) external;
    function sync() external;

    function initialize(address, address) external;
}
pragma solidity >=0.6.2;

interface IUniswapV2Router01 {
    function factory() external pure returns (address);
    function WETH() external pure returns (address);

    function addLiquidity(
        address tokenA,
        address tokenB,
        uint amountADesired,
        uint amountBDesired,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline
    ) external returns (uint amountA, uint amountB, uint liquidity);
    function addLiquidityETH(
        address token,
        uint amountTokenDesired,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external payable returns (uint amountToken, uint amountETH, uint liquidity);
    function removeLiquidity(
        address tokenA,
        address tokenB,
        uint liquidity,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline
    ) external returns (uint amountA, uint amountB);
    function removeLiquidityETH(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external returns (uint amountToken, uint amountETH);
    function removeLiquidityWithPermit(
        address tokenA,
        address tokenB,
        uint liquidity,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountA, uint amountB);
    function removeLiquidityETHWithPermit(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountToken, uint amountETH);
    function swapExactTokensForTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory amounts);
    function swapTokensForExactTokens(
        uint amountOut,
        uint amountInMax,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory amounts);
    function swapExactETHForTokens(uint amountOutMin, address[] calldata path, address to, uint deadline)
        external
        payable
        returns (uint[] memory amounts);
    function swapTokensForExactETH(uint amountOut, uint amountInMax, address[] calldata path, address to, uint deadline)
        external
        returns (uint[] memory amounts);
    function swapExactTokensForETH(uint amountIn, uint amountOutMin, address[] calldata path, address to, uint deadline)
        external
        returns (uint[] memory amounts);
    function swapETHForExactTokens(uint amountOut, address[] calldata path, address to, uint deadline)
        external
        payable
        returns (uint[] memory amounts);

    function quote(uint amountA, uint reserveA, uint reserveB) external pure returns (uint amountB);
    function getAmountOut(uint amountIn, uint reserveIn, uint reserveOut) external pure returns (uint amountOut);
    function getAmountIn(uint amountOut, uint reserveIn, uint reserveOut) external pure returns (uint amountIn);
    function getAmountsOut(uint amountIn, address[] calldata path) external view returns (uint[] memory amounts);
    function getAmountsIn(uint amountOut, address[] calldata path) external view returns (uint[] memory amounts);
}
pragma solidity >=0.6.2;

import './IUniswapV2Router01.sol';

interface IUniswapV2Router02 is IUniswapV2Router01 {
    function removeLiquidityETHSupportingFeeOnTransferTokens(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external returns (uint amountETH);
    function removeLiquidityETHWithPermitSupportingFeeOnTransferTokens(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountETH);

    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
    function swapExactETHForTokensSupportingFeeOnTransferTokens(
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external payable;
    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
}
// contracts/MemberManager
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {AccessControl} from "@openzeppelin/contracts/access/AccessControl.sol";

contract DataStorage is AccessControl {
    bytes32 public constant EDITOR = keccak256("EDITOR");
    //TODO edit 1 days
    uint public constant VOTE_PERIOD = 1 days;
    uint public constant VOTE_EPOCH_PERIOD = 30;
    struct Vote {
        uint16 percent;
        bool claimed;
    }
    struct UserInfo {
        uint64 totalVote;
        uint64 totalClaim;
    }
    mapping(address => mapping(uint => Vote)) public votes;
    mapping(address => mapping(uint => uint)) public epochVote;
    mapping(address => mapping(uint => uint8)) public userRank;
    mapping(address => UserInfo) public userInfo;

    event NewVote(address user, uint day, uint epoch, uint percent);
    event ClaimedVote(address user, uint day, uint epoch, uint percent);
    event ActiveVote(uint epoch);

    constructor() {
        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
    }

    function isActiveVote() public view returns (bool) {
        uint day = (block.timestamp - 20 days) / VOTE_PERIOD;
        uint epoch = day / VOTE_EPOCH_PERIOD;
        return epochVote[address(0x0)][epoch] > 0;
    }

    function getVote(address user, uint day) public view returns (uint) {
        return (votes[user][day].percent);
    }

    function setUserRank(address user, uint epoch, uint8 rank) public {
        require(hasRole(EDITOR, msg.sender), "Must be editor");
        userRank[user][epoch] = rank;
    }

    function activeVote() public {
        require(hasRole(EDITOR, msg.sender), "Must be editor");
        uint epoch = ((block.timestamp - 20 days) / VOTE_PERIOD) / VOTE_EPOCH_PERIOD;
        epochVote[address(0x0)][epoch] = 1;
        emit ActiveVote(epoch);
    }

    function userVote(address user, uint16 percent) public {
        require(hasRole(EDITOR, msg.sender), "Must be editor");
        uint day = (block.timestamp - 20 days) / VOTE_PERIOD;
        uint epoch = day / VOTE_EPOCH_PERIOD;
        require(votes[user][day - 1].percent == 0, "Must no freeze day");
        require(votes[user][day].percent == 0, "Must no vote same day");
        votes[user][day] = Vote(percent, false);
        epochVote[user][epoch] += 1;
        userInfo[user].totalVote += 1;
        emit NewVote(user, day, epoch, percent);
    }

    function userClaim(address user, uint day) public returns (uint) {
        require(hasRole(EDITOR, msg.sender), "Must be editor");
        Vote storage vote = votes[user][day];
        require(vote.percent > 0, "Must have vote");
        require(!vote.claimed, "Must not claimed");
        vote.claimed = true;
        userInfo[user].totalClaim += 1;
        uint epoch = day / VOTE_EPOCH_PERIOD;
        emit ClaimedVote(user, day, epoch, vote.percent);
        return vote.percent;
    }
}
// contracts/MemberManager
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IMemberManager {
    function sponsor(address childAddress) external view returns (address);

    function addMember(address _member, address _sponsor) external;

    function getTotalMember() external view returns (uint256);

    function isParent(
        address _parent,
        address _child
    ) external view returns (bool);
}
// contracts/MemberManager
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./IMemberManager.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {IUniswapV2Router02} from "@uniswap/v2-periphery/contracts/interfaces/IUniswapV2Router02.sol";
import {IUniswapV2Factory} from "@uniswap/v2-core/contracts/interfaces/IUniswapV2Factory.sol";
import {IUniswapV2Pair} from "@uniswap/v2-core/contracts/interfaces/IUniswapV2Pair.sol";
import {DataStorage} from "./DataStorage.sol";
import {AccessControl} from "@openzeppelin/contracts/access/AccessControl.sol";

contract VoteContract is AccessControl {
    bytes32 public constant EDITOR = keccak256("EDITOR");
    IUniswapV2Pair public uniswapPair;
    IUniswapV2Router02 public immutable uniswapV2Router =
        IUniswapV2Router02(0x10ED43C718714eb63d5aA57B78B54704E256024E);
    //Mainnet: 0x10ED43C718714eb63d5aA57B78B54704E256024E
    //TODO setup for mainnet
    //TODO edit 1 days
    uint public constant VOTE_PERIOD = 1 days;
    uint public constant VOTE_EPOCH_PERIOD = 30;
    uint public constant VOTE_AMOUNT = 31e18;
    uint[5] public RANK_PERCENT = [4, 8, 12, 16, 20];
    uint public PERCENT_DIF = 6;
    IMemberManager public member;
    IERC20 public usd;
    IERC20 public token;
    DataStorage public data;
    address public feeAddress;
    address public feeMatchAddress;
    address public globalFund;
    address public mtcFund;
    address public sponsorFund;
    uint256 MAX_INT =
        0xffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff;

    constructor(
        address _memberAddress,
        IERC20 _usd,
        IERC20 _token,
        DataStorage _data,
        address _feeAddress,
        address _feeMatchAddress,
        address _globalFund,
        address _mtcFund,
        address _sponsorFund
    ) {
        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
        member = IMemberManager(_memberAddress);
        usd = _usd;
        token = _token;
        feeAddress = _feeAddress;
        data = _data;
        feeMatchAddress = _feeMatchAddress;
        globalFund = _globalFund;
        mtcFund = _mtcFund;
        sponsorFund = _sponsorFund;
        uniswapPair = IUniswapV2Pair(
            IUniswapV2Factory(uniswapV2Router.factory()).getPair(
                address(usd),
                address(token)
            )
        );
        usd.approve(address(uniswapV2Router), MAX_INT);
        token.approve(address(uniswapV2Router), MAX_INT);
    }

    function vote() public {
        address sponsor = member.sponsor(msg.sender);
        require(sponsor != address(0x0), "Must be member");
        require(data.isActiveVote(), "Must be active vote");
        usd.transferFrom(msg.sender, address(this), VOTE_AMOUNT);
        usd.transfer(feeAddress, 1e18);
        usd.transfer(globalFund, 6e16);

        if (sponsorActive(sponsor)) {
            usd.transfer(sponsor, 5e18);
        } else {
            usd.transfer(sponsorFund, 5e18);
        }
        swapTokens(2434e16);
        uint epoch = ((block.timestamp - 20 days) / VOTE_PERIOD) /
            VOTE_EPOCH_PERIOD;
        address[5] memory usersMatch = searchMatchAddress(msg.sender, epoch);
        uint paid = 0;
        for (uint i = 0; i < 5; i++) {
            if (usersMatch[i] != address(0x0)) {
                usd.transfer(
                    usersMatch[i],
                    ((VOTE_AMOUNT - 1e18) * (RANK_PERCENT[i] - paid)) / 1000
                );
                paid = RANK_PERCENT[i];
            }
        }
        if (paid < RANK_PERCENT[4]) {
            usd.transfer(
                feeMatchAddress,
                ((VOTE_AMOUNT - 1e18) * (RANK_PERCENT[4] - paid)) / 1000
            );
        }
        uint16 percent = uint16(
            ((uint256(
                keccak256(
                    abi.encodePacked(
                        msg.sender,
                        block.timestamp,
                        getAmountOut(2434e16)
                    )
                )
            ) % PERCENT_DIF) + (30 - PERCENT_DIF)) * 1000
        );
        data.userVote(msg.sender, percent);
    }

    function editPercentDif(uint percent) public {
        require(hasRole(DEFAULT_ADMIN_ROLE, msg.sender), "Must be editor");
        PERCENT_DIF = percent;
    }

    function sponsorActive(address user) public view returns (bool) {
        uint today = (block.timestamp - 20 days) / VOTE_PERIOD;
        return (data.getVote(user, today) > 0 ||
            data.getVote(user, today - 1) > 0 ||
            data.getVote(user, today - 2) > 0);
    }

    function getAmountOut(uint amountIn) public view returns (uint amountOut) {
        (uint256 reserve0, uint256 reserve1, ) = uniswapPair.getReserves();
        (uint reserveIn, uint reserveOut) = address(usd) < address(token)
            ? (reserve0, reserve1)
            : (reserve1, reserve0);
        uint256 numerator = amountIn * reserveOut;
        uint256 denominator = reserveIn + amountIn;
        amountOut = numerator / denominator;
    }

    function swapTokens(uint256 tokenAmount) private {
        // generate the uniswap pair path of usd -> token
        address[] memory path = new address[](2);
        path[0] = address(usd);
        path[1] = address(token);
        // make the swap
        uniswapV2Router.swapExactTokensForTokensSupportingFeeOnTransferTokens(
            tokenAmount,
            0, // accept any amount
            path,
            mtcFund,
            block.timestamp
        );
    }

    function searchMatchAddress(
        address user,
        uint epoch
    ) public view returns (address[5] memory usersMatch) {
        uint current = 0;
        address sponsor = member.sponsor(user);
        while (current < 5) {
            uint rank = data.userRank(sponsor, epoch);
            if (rank > current) {
                usersMatch[rank - 1] = sponsor;
                current = rank;
            }
            sponsor = member.sponsor(sponsor);
            if (sponsor == address(0x0)) break;
        }
    }

    function claim(uint day) public {
        uint today = (block.timestamp - 20 days) / VOTE_PERIOD;
        require(today >= day + VOTE_EPOCH_PERIOD, "Frozen time vote");
        (uint64 totalVote, uint64 totalClaim) = data.userInfo(msg.sender);
        require(totalVote > totalClaim + 3, "Frozen 3 vote");
        uint percent = data.userClaim(msg.sender, day);
        uint amount = getAmountOut(
            ((VOTE_AMOUNT - 1e18) * percent) / 100000 + (VOTE_AMOUNT - 1e18)
        );
        token.transfer(msg.sender, amount);
    }

    function rankSet(
        address[] calldata users,
        uint8[] calldata rank,
        bool ended
    ) public {
        require(hasRole(EDITOR, msg.sender), "Must be editor");
        require(!data.isActiveVote(), "Not active vote");
        uint epoch = ((block.timestamp - 20 days) / VOTE_PERIOD) /
            VOTE_EPOCH_PERIOD;
        for (uint i = 0; i < users.length; i++) {
            data.setUserRank(users[i], epoch, rank[i]);
        }
        if (ended) {
            data.activeVote();
        }
    }

    function withdrawStuck() external {
        require(hasRole(DEFAULT_ADMIN_ROLE, msg.sender), "Must be owner");
        uint256 balance = token.balanceOf(address(this));
        token.transfer(msg.sender, balance);
        uint256 balanceU = usd.balanceOf(address(this));
        usd.transfer(msg.sender, balanceU);
        payable(msg.sender).transfer(address(this).balance);
    }
}
