// SPDX-License-Identifier: BUSL-1.1

pragma solidity >=0.5.0;

interface ILayerZeroReceiver {
    // @notice LayerZero endpoint will invoke this function to deliver the message on the destination
    // @param _srcChainId - the source endpoint identifier
    // @param _srcAddress - the source sending contract address from the source chain
    // @param _nonce - the ordered message nonce
    // @param _payload - the signed payload is the UA bytes has encoded to be sent
    function lzReceive(uint16 _srcChainId, bytes calldata _srcAddress, uint64 _nonce, bytes calldata _payload) external;
}
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (interfaces/IERC20.sol)

pragma solidity ^0.8.0;

import "../token/ERC20/IERC20.sol";
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.8.0) (proxy/utils/Initializable.sol)

pragma solidity ^0.8.2;

import "../../utils/Address.sol";

/**
 * @dev This is a base contract to aid in writing upgradeable contracts, or any kind of contract that will be deployed
 * behind a proxy. Since proxied contracts do not make use of a constructor, it's common to move constructor logic to an
 * external initializer function, usually called `initialize`. It then becomes necessary to protect this initializer
 * function so it can only be called once. The {initializer} modifier provided by this contract will have this effect.
 *
 * The initialization functions use a version number. Once a version number is used, it is consumed and cannot be
 * reused. This mechanism prevents re-execution of each "step" but allows the creation of new initialization steps in
 * case an upgrade adds a module that needs to be initialized.
 *
 * For example:
 *
 * [.hljs-theme-light.nopadding]
 * ```solidity
 * contract MyToken is ERC20Upgradeable {
 *     function initialize() initializer public {
 *         __ERC20_init("MyToken", "MTK");
 *     }
 * }
 *
 * contract MyTokenV2 is MyToken, ERC20PermitUpgradeable {
 *     function initializeV2() reinitializer(2) public {
 *         __ERC20Permit_init("MyToken");
 *     }
 * }
 * ```
 *
 * TIP: To avoid leaving the proxy in an uninitialized state, the initializer function should be called as early as
 * possible by providing the encoded function call as the `_data` argument to {ERC1967Proxy-constructor}.
 *
 * CAUTION: When used with inheritance, manual care must be taken to not invoke a parent initializer twice, or to ensure
 * that all initializers are idempotent. This is not verified automatically as constructors are by Solidity.
 *
 * [CAUTION]
 * ====
 * Avoid leaving a contract uninitialized.
 *
 * An uninitialized contract can be taken over by an attacker. This applies to both a proxy and its implementation
 * contract, which may impact the proxy. To prevent the implementation contract from being used, you should invoke
 * the {_disableInitializers} function in the constructor to automatically lock it when it is deployed:
 *
 * [.hljs-theme-light.nopadding]
 * ```
 * /// @custom:oz-upgrades-unsafe-allow constructor
 * constructor() {
 *     _disableInitializers();
 * }
 * ```
 * ====
 */
abstract contract Initializable {
    /**
     * @dev Indicates that the contract has been initialized.
     * @custom:oz-retyped-from bool
     */
    uint8 private _initialized;

    /**
     * @dev Indicates that the contract is in the process of being initialized.
     */
    bool private _initializing;

    /**
     * @dev Triggered when the contract has been initialized or reinitialized.
     */
    event Initialized(uint8 version);

    /**
     * @dev A modifier that defines a protected initializer function that can be invoked at most once. In its scope,
     * `onlyInitializing` functions can be used to initialize parent contracts.
     *
     * Similar to `reinitializer(1)`, except that functions marked with `initializer` can be nested in the context of a
     * constructor.
     *
     * Emits an {Initialized} event.
     */
    modifier initializer() {
        bool isTopLevelCall = !_initializing;
        require(
            (isTopLevelCall && _initialized < 1) || (!Address.isContract(address(this)) && _initialized == 1),
            "Initializable: contract is already initialized"
        );
        _initialized = 1;
        if (isTopLevelCall) {
            _initializing = true;
        }
        _;
        if (isTopLevelCall) {
            _initializing = false;
            emit Initialized(1);
        }
    }

    /**
     * @dev A modifier that defines a protected reinitializer function that can be invoked at most once, and only if the
     * contract hasn't been initialized to a greater version before. In its scope, `onlyInitializing` functions can be
     * used to initialize parent contracts.
     *
     * A reinitializer may be used after the original initialization step. This is essential to configure modules that
     * are added through upgrades and that require initialization.
     *
     * When `version` is 1, this modifier is similar to `initializer`, except that functions marked with `reinitializer`
     * cannot be nested. If one is invoked in the context of another, execution will revert.
     *
     * Note that versions can jump in increments greater than 1; this implies that if multiple reinitializers coexist in
     * a contract, executing them in the right order is up to the developer or operator.
     *
     * WARNING: setting the version to 255 will prevent any future reinitialization.
     *
     * Emits an {Initialized} event.
     */
    modifier reinitializer(uint8 version) {
        require(!_initializing && _initialized < version, "Initializable: contract is already initialized");
        _initialized = version;
        _initializing = true;
        _;
        _initializing = false;
        emit Initialized(version);
    }

    /**
     * @dev Modifier to protect an initialization function so that it can only be invoked by functions with the
     * {initializer} and {reinitializer} modifiers, directly or indirectly.
     */
    modifier onlyInitializing() {
        require(_initializing, "Initializable: contract is not initializing");
        _;
    }

    /**
     * @dev Locks the contract, preventing any future reinitialization. This cannot be part of an initializer call.
     * Calling this in the constructor of a contract will prevent that contract from being initialized or reinitialized
     * to any version. It is recommended to use this to lock implementation contracts that are designed to be called
     * through proxies.
     *
     * Emits an {Initialized} event the first time it is successfully executed.
     */
    function _disableInitializers() internal virtual {
        require(!_initializing, "Initializable: contract is initializing");
        if (_initialized != type(uint8).max) {
            _initialized = type(uint8).max;
            emit Initialized(type(uint8).max);
        }
    }

    /**
     * @dev Returns the highest version that has been initialized. See {reinitializer}.
     */
    function _getInitializedVersion() internal view returns (uint8) {
        return _initialized;
    }

    /**
     * @dev Returns `true` if the contract is currently initializing. See {onlyInitializing}.
     */
    function _isInitializing() internal view returns (bool) {
        return _initializing;
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
    function transferFrom(address from, address to, uint256 amount) external returns (bool);
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

//** DCB Token claim Contract */
//** Author: Aceson 2022.3 */

pragma solidity 0.8.19;

import "openzeppelin-contracts/contracts/interfaces/IERC20.sol";
import "openzeppelin-contracts/contracts/proxy/utils/Initializable.sol";

import "./interfaces/IDCBInvestments.sol";
import "./interfaces/IDCBPlatformVesting.sol";
import "./interfaces/IDCBTokenClaim.sol";
import "layerzero/interfaces/ILayerZeroReceiver.sol";

contract DCBTokenClaim is Initializable, ILayerZeroReceiver, IDCBTokenClaim {
    IDCBInvestments public _investment; //Investments contract
    IERC20 public _rewardToken; //Token to be used for tier calc
    IDCBPlatformVesting public _vesting; //Vesting contract
    address public layerZero; //Layerzero contract address

    //Keccack(<hidden answer>)
    /* solhint-disable var-name-mixedcase */
    bytes32 public ANSWER_HASH;
    uint256 public totalShares; //Total shares for the event

    mapping(address => UserAllocation) public userAllocation; //Allocation per user

    ClaimInfo public claimInfo;
    Tiers[] public tierInfo;

    address[] private participants;
    address[] private registeredUsers;
    address public tierMigratorAddr;
    uint16 internal nativeChainId;

    event Initialized(Params p);
    event UserRegistered(address user);
    event UserClaimed(address user, uint256 amount);

    modifier onlyManager() {
        require(_investment.hasRole(keccak256("MANAGER_ROLE"), msg.sender), "Only manager");
        _;
    }

    function initialize(Params calldata p) external initializer {
        _investment = IDCBInvestments(msg.sender);
        _rewardToken = IERC20(p.rewardTokenAddr);
        _vesting = IDCBPlatformVesting(p.vestingAddr);
        layerZero = p.layerZeroAddr;
        tierMigratorAddr = p.tierMigratorAddr;
        nativeChainId = p.nativeChainId;

        /**
         * Generate the new Claim Event
         */
        claimInfo.minTier = p.minTier;
        claimInfo.distAmount = p.distAmount;
        claimInfo.createDate = uint32(block.timestamp);
        claimInfo.startDate = p.startDate;
        claimInfo.endDate = p.endDate;

        ANSWER_HASH = p.answerHash;

        for (uint256 i = 0; i < p.tiers.length; i++) {
            tierInfo.push(Tiers({ minLimit: p.tiers[i].minLimit, multi: p.tiers[i].multi }));
        }

        emit Initialized(p);
    }

    function setParams(Params calldata p) external {
        require(msg.sender == address(_investment), "Only factory");

        claimInfo.minTier = p.minTier;
        claimInfo.distAmount = p.distAmount;
        claimInfo.startDate = p.startDate;
        claimInfo.endDate = p.endDate;

        _investment = IDCBInvestments(msg.sender);
        _rewardToken = IERC20(p.rewardTokenAddr);
        _vesting = IDCBPlatformVesting(p.vestingAddr);

        ANSWER_HASH = p.answerHash;

        for (uint256 i = 0; i < p.tiers.length; i++) {
            tierInfo.push(Tiers({ minLimit: p.tiers[i].minLimit, multi: p.tiers[i].multi }));
        }
    }

    function registerForAllocation(address _user, uint8 _tier, uint8 _multi) public returns (bool) {
        require(msg.sender == (layerZero) || msg.sender == tierMigratorAddr, "Invalid sender");

        uint256 shares = (2 ** _tier) * _multi;
        (, uint16 _holdMulti) = getTier(_user);
        shares = shares * _holdMulti / 1000;

        userAllocation[_user].active = 1;
        userAllocation[_user].shares = shares;
        userAllocation[_user].registeredTier = uint8(_tier);
        userAllocation[_user].multi = uint8(_multi);

        registeredUsers.push(_user);

        totalShares = totalShares + shares;
        emit UserRegistered(_user);

        return true;
    }

    function registerByManager(
        address[] calldata _users,
        uint256[] calldata _tierOfUser,
        uint256[] calldata _multiOfUser
    )
        external
        onlyManager
    {
        require((_users.length == _tierOfUser.length) && (_tierOfUser.length == _multiOfUser.length), "Invalid input");
        uint256 len = _users.length;
        uint256 total;
        require(block.timestamp <= claimInfo.endDate && block.timestamp >= claimInfo.startDate, "Registration closed");

        for (uint256 i = 0; i < len; i++) {
            require(_tierOfUser[i] >= claimInfo.minTier, "Minimum tier required");
            require(userAllocation[_users[i]].active == 0, "Already registered");

            uint256 shares = (2 ** _tierOfUser[i]) * _multiOfUser[i];
            (, uint16 _holdMulti) = getTier(_users[i]);
            shares = shares * _holdMulti / 1000;

            userAllocation[_users[i]].active = 1;
            userAllocation[_users[i]].shares = shares;
            userAllocation[_users[i]].registeredTier = uint8(_tierOfUser[i]);
            userAllocation[_users[i]].multi = uint8(_multiOfUser[i]);

            registeredUsers.push(_users[i]);

            total = total + shares;
            emit UserRegistered(_users[i]);
        }

        totalShares = totalShares + total;
    }

    function lzReceive(uint16 _id, bytes calldata _srcAddress, uint64, bytes memory data) public override {
        require(
            _id == nativeChainId
                && keccak256(_srcAddress) == keccak256(abi.encodePacked(tierMigratorAddr, address(this))),
            "Invalid source"
        );

        address user;
        uint8 tier;
        uint8 multi;

        // solhint-disable-next-line no-inline-assembly
        assembly {
            // Extract the address from data (first 20 bytes)
            user := mload(add(data, 0x14))

            // Extract the first uint8 (21st byte)
            tier := byte(0, mload(add(data, 0x34)))

            // Extract the second uint8 (22nd byte)
            multi := byte(0, mload(add(data, 0x35)))
        }

        registerForAllocation(user, tier, multi);
    }

    function setMinTierForClaim(uint8 _minTier) external onlyManager {
        claimInfo.minTier = _minTier;
    }

    function setToken(address _token) external {
        require(msg.sender == address(_investment), "Only factory");
        _rewardToken = IERC20(_token);
    }

    function claimTokens() external returns (bool) {
        UserAllocation storage user = userAllocation[msg.sender];

        require(user.active == 1, "Not registered / Already claimed");
        require(block.timestamp >= claimInfo.endDate, "Claim not open yet");

        uint256 amount = getClaimableAmount(msg.sender);

        if (amount > 0) {
            participants.push(msg.sender);
            _investment.setUserInvestment(msg.sender, address(this), amount);
            _vesting.setTokenClaimWhitelist(msg.sender, amount);
        }

        user.shares = 0;
        user.claimedAmount = amount;
        user.active = 0;

        emit UserClaimed(msg.sender, amount);

        return true;
    }

    function getParticipants() external view returns (address[] memory) {
        return participants;
    }

    function getRegisteredUsers() external view returns (address[] memory) {
        return registeredUsers;
    }

    function getClaimForTier(uint8 _tier, uint8 _multi) public view returns (uint256) {
        if (totalShares == 0) return 0;
        return ((2 ** _tier) * _multi * claimInfo.distAmount / totalShares);
    }

    function getClaimableAmount(address _address) public view returns (uint256) {
        if (totalShares == 0) return 0;
        return (userAllocation[_address].shares * claimInfo.distAmount / totalShares);
    }

    function getTier(address _user) public view returns (uint256 _tier, uint16 _holdMulti) {
        uint256 len = tierInfo.length;
        uint256 amount = _rewardToken.balanceOf(_user);

        for (uint256 i = len - 1; i >= 0; i--) {
            if (amount >= tierInfo[i].minLimit) {
                return (i, tierInfo[i].multi);
            }
        }
    }
}
// SPDX-License-Identifier: UNLICENSED

//** DCB Investments Interface */
//** Author Aaron & Aceson : DCB 2023.2 */

pragma solidity 0.8.19;

interface IDCBInvestments {
    event DistributionClaimed(address _user, address _event);
    event ImplementationsChanged(address _newVesting, address _newTokenClaim, address _newCrowdfunding);
    event Initialized(uint8 version);
    event ManagerRoleSet(address _user, bool _status);
    event RoleAdminChanged(bytes32 indexed role, bytes32 indexed previousAdminRole, bytes32 indexed newAdminRole);
    event RoleGranted(bytes32 indexed role, address indexed account, address indexed sender);
    event RoleRevoked(bytes32 indexed role, address indexed account, address indexed sender);
    event UserInvestmentSet(address _address, address _event, uint256 _amount);

    function changeImplementations(address _newVesting, address _newTokenClaim, address _newCrowdfunding) external;

    function changeVestingStartTime(address _event, uint256 _newTime) external;

    function claimDistribution(address _event) external returns (bool);

    function crowdfundingImpl() external view returns (address);

    function events(address)
        external
        view
        returns (
            string memory name,
            address paymentToken,
            address tokenAddress,
            address vestingAddress,
            uint8 eventType
        );

    function eventsList(uint256) external view returns (address);

    function getRoleAdmin(bytes32 role) external view returns (bytes32);

    function getUserInvestments(address _address) external view returns (address[] memory);

    function grantRole(bytes32 role, address account) external;

    function hasRole(bytes32 role, address account) external view returns (bool);

    function initialize() external;

    function numUserInvestments(address) external view returns (uint256);

    function renounceRole(bytes32 role, address account) external;

    function revokeRole(bytes32 role, address account) external;

    function setManagerRole(address _user, bool _status) external;

    function setUserInvestment(address _address, address _event, uint256 _amount) external returns (bool);

    function supportsInterface(bytes4 interfaceId) external view returns (bool);

    function tokenClaimImpl() external view returns (address);

    function userAmount(address, address) external view returns (uint256);

    function vestingImpl() external view returns (address);
}
// SPDX-License-Identifier: MIT

//** DCB Vesting Interface */

pragma solidity 0.8.19;

interface IDCBPlatformVesting {
    struct VestingInfo {
        uint256 cliff;
        uint256 start;
        uint256 duration;
        uint256 initialUnlockPercent;
    }

    struct VestingPool {
        uint256 cliff;
        uint256 start;
        uint256 duration;
        uint256 initialUnlockPercent;
        WhitelistInfo[] whitelistPool;
        mapping(address => HasWhitelist) hasWhitelist;
    }

    /**
     *
     * @dev WhiteInfo is the struct type which store whitelist information
     *
     */
    struct WhitelistInfo {
        address wallet;
        uint256 amount;
        uint256 distributedAmount;
        uint256 value; // price * amount in decimals of payment token
        uint256 joinDate;
        uint256 refundDate;
        bool refunded;
    }

    struct HasWhitelist {
        uint256 arrIdx;
        bool active;
    }

    struct ContractSetup {
        address _innovator;
        address _paymentReceiver;
        address _vestedToken;
        address _paymentToken;
        uint32 _nativeChainId;
        uint256 _totalTokenOnSale;
        uint256 _gracePeriod;
        uint256[] _refundFees;
    }

    struct VestingSetup {
        uint256 _startTime;
        uint256 _cliff;
        uint256 _duration;
        uint256 _initialUnlockPercent;
    }

    struct BuybackSetup {
        address router;
        address[] path;
    }

    event Claim(address indexed token, uint256 amount, uint256 time);

    event SetWhitelist(address indexed wallet, uint256 amount, uint256 value);

    event Refund(address indexed wallet, uint256 amount);

    function initializeCrowdfunding(ContractSetup memory c, VestingSetup memory p, BuybackSetup memory b) external;

    function initializeTokenClaim(address _token, VestingSetup memory p, uint32 _nativeChainId) external;

    function setCrowdfundingWhitelist(address _wallet, uint256 _amount, uint256 _value) external;

    function setTokenClaimWhitelist(address _wallet, uint256 _amount) external;

    function claimDistribution(address _wallet) external returns (bool);

    function getWhitelist(address _wallet) external view returns (WhitelistInfo memory);

    function getWhitelistPool() external view returns (WhitelistInfo[] memory);

    function transferOwnership(address _newOwner) external;

    function setVestingParams(
        uint256 _cliff,
        uint256 _start,
        uint256 _duration,
        uint256 _initialUnlockPercent
    )
        external;

    function setCrowdFundingParams(ContractSetup calldata c, uint256 _platformFee) external;

    function setToken(address _newToken) external;

    function rescueTokens(address _receiver, uint256 _amount) external;

    /**
     *
     * inherit functions will be used in contract
     *
     */

    function getVestAmount(address _wallet) external view returns (uint256);

    function getReleasableAmount(address _wallet) external view returns (uint256);

    function getVestingInfo() external view returns (VestingInfo memory);
}
// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.19;

/* solhint-disable */

interface IDCBTokenClaim {
    struct Params {
        uint8 minTier;
        uint16 nativeChainId;
        uint32 startDate;
        uint32 endDate;
        address rewardTokenAddr;
        address vestingAddr;
        address tierMigratorAddr;
        address layerZeroAddr;
        bytes32 answerHash;
        uint256 distAmount;
        Tiers[] tiers;
    }

    struct Tiers {
        uint256 minLimit;
        uint16 multi;
    }

    struct UserAllocation {
        uint8 active; //Is active or not
        uint8 registeredTier; //Tier of user while registering
        uint8 multi; //Multiplier of user while registering
        uint256 shares; //Shares owned by user
        uint256 claimedAmount; //Claimed amount from event
    }

    struct ClaimInfo {
        uint8 minTier; //Minimum tier required for users while registering
        uint32 createDate; //Created date
        uint32 startDate; //Event start date
        uint32 endDate; //Event end date
        uint256 distAmount; //Total distributed amount
    }

    function ANSWER_HASH() external view returns (bytes32);

    function claimInfo()
        external
        view
        returns (uint8 minTier, uint32 createDate, uint32 startDate, uint32 endDate, uint256 distAmount);

    function claimTokens() external returns (bool);

    function getClaimForTier(uint8 _tier, uint8 _multi) external view returns (uint256);

    function getClaimableAmount(address _address) external view returns (uint256);

    function getParticipants() external view returns (address[] memory);

    function getRegisteredUsers() external view returns (address[] memory);

    function getTier(address _user) external view returns (uint256 _tier, uint16 _holdMulti);

    function initialize(Params memory p) external;

    function setMinTierForClaim(uint8 _minTier) external;

    function setParams(Params calldata p) external;

    function setToken(address _token) external;

    function registerForAllocation(address _user, uint8 _tier, uint8 _multi) external returns (bool);

    function registerByManager(
        address[] calldata _users,
        uint256[] calldata _tierOfUser,
        uint256[] calldata _multiOfUser
    )
        external;

    function tierInfo(uint256) external view returns (uint256 minLimit, uint16 multi);

    function totalShares() external view returns (uint256);

    function userAllocation(address)
        external
        view
        returns (uint8 active, uint8 registeredTier, uint8 multi, uint256 shares, uint256 claimedAmount);
}
