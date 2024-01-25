// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.23;

import { QuorumManager } from "src/crosschain-data/utils/QuorumManager.sol";
import { ISuperRBAC } from "src/interfaces/ISuperRBAC.sol";
import { ISuperRegistry } from "src/interfaces/ISuperRegistry.sol";
import { Error } from "src/libraries/Error.sol";

/// @title SuperRegistry
/// @dev Keeps information on all addresses used in the Superform ecosystem
/// @author Zeropoint Labs
contract SuperRegistry is ISuperRegistry, QuorumManager {
    //////////////////////////////////////////////////////////////
    //                         CONSTANTS                        //
    //////////////////////////////////////////////////////////////

    uint256 private constant MIN_DELAY = 15 minutes;
    uint256 private constant MAX_DELAY = 24 hours;
    uint64 public immutable CHAIN_ID;

    /// @dev core protocol - identifiers
    /// @notice should not be allowed to be changed
    bytes32 public constant override SUPERFORM_ROUTER = keccak256("SUPERFORM_ROUTER");

    /// @dev can be used to set a new factory that has form ids paused
    /// @notice should not be allowed to be changed
    bytes32 public constant override SUPERFORM_FACTORY = keccak256("SUPERFORM_FACTORY");

    /// @dev can be used to set a new paymaster to forward payments to
    /// @dev could be allowed to be changed
    bytes32 public constant override PAYMASTER = keccak256("PAYMASTER");

    /// @dev accessed in some areas of the protocol to calculate AMB fees. Already has a function to alter the
    /// configuration
    /// @dev could be allowed to be changed
    bytes32 public constant override PAYMENT_HELPER = keccak256("PAYMENT_HELPER");

    /// @dev accessed in many areas of the protocol. has direct access to superforms
    /// @notice should not be allowed to be changed
    bytes32 public constant override CORE_STATE_REGISTRY = keccak256("CORE_STATE_REGISTRY");

    /// @dev accessed in many areas of the protocol. has direct access to timelock form
    /// @notice should not be allowed to be changed
    bytes32 public constant override TIMELOCK_STATE_REGISTRY = keccak256("TIMELOCK_STATE_REGISTRY");

    /// @dev used to sync messages for pausing superforms or deploying transmuters
    /// @notice should not be allowed to be changed
    bytes32 public constant override BROADCAST_REGISTRY = keccak256("BROADCAST_REGISTRY");

    /// @dev not accessed in protocol
    /// @notice should not be allowed to be changed
    bytes32 public constant override SUPER_POSITIONS = keccak256("SUPER_POSITIONS");

    /// @dev accessed in many areas of the protocol
    /// @notice should not be allowed to be changed
    bytes32 public constant override SUPER_RBAC = keccak256("SUPER_RBAC");

    /// @dev not accessed in protocol
    /// @dev could be allowed to be changed
    bytes32 public constant override PAYLOAD_HELPER = keccak256("PAYLOAD_HELPER");

    /// @dev accessed in CSR and validators. can be used to alter behaviour of update deposit payloads
    /// @notice should not be allowed to be changed
    bytes32 public constant override DST_SWAPPER = keccak256("DST_SWAPPER");

    /// @dev accessed in base form to send payloads to emergency queue
    /// @notice should not be allowed to be changed
    bytes32 public constant override EMERGENCY_QUEUE = keccak256("EMERGENCY_QUEUE");

    /// @dev receiver of bridge refunds and airdropped tokens
    /// @notice should not be allowed to be changed
    bytes32 public constant override SUPERFORM_RECEIVER = keccak256("SUPERFORM_RECEIVER");

    /// @dev default keepers - identifiers
    /// @dev could be allowed to be changed
    bytes32 public constant override PAYMENT_ADMIN = keccak256("PAYMENT_ADMIN");
    bytes32 public constant override CORE_REGISTRY_PROCESSOR = keccak256("CORE_REGISTRY_PROCESSOR");
    bytes32 public constant override BROADCAST_REGISTRY_PROCESSOR = keccak256("BROADCAST_REGISTRY_PROCESSOR");
    bytes32 public constant override TIMELOCK_REGISTRY_PROCESSOR = keccak256("TIMELOCK_REGISTRY_PROCESSOR");
    bytes32 public constant override CORE_REGISTRY_UPDATER = keccak256("CORE_REGISTRY_UPDATER");
    bytes32 public constant override CORE_REGISTRY_RESCUER = keccak256("CORE_REGISTRY_RESCUER");
    bytes32 public constant override CORE_REGISTRY_DISPUTER = keccak256("CORE_REGISTRY_DISPUTER");
    bytes32 public constant override DST_SWAPPER_PROCESSOR = keccak256("DST_SWAPPER_PROCESSOR");

    //////////////////////////////////////////////////////////////
    //                     STATE VARIABLES                      //
    //////////////////////////////////////////////////////////////

    /// @dev canonical permit2 contract
    address private permit2Address;

    /// @dev rescue timelock delay config
    uint256 public delay;

    mapping(bytes32 id => mapping(uint64 chainid => address moduleAddress)) private registry;
    /// @dev liquidityBridge id is mapped to a liquidityBridge address (to prevent interaction with unauthorized
    /// bridges)
    mapping(uint8 bridgeId => address bridgeAddress) public bridgeAddresses;
    mapping(uint8 bridgeId => address bridgeValidator) public bridgeValidator;
    mapping(uint8 ambId => address ambAddresses) public ambAddresses;
    mapping(uint8 ambId => bool isBroadcastAMB) public isBroadcastAMB;

    mapping(uint64 chainId => uint256 vaultLimitPerDestination) public vaultLimitPerDestination;

    mapping(uint8 registryId => address registryAddress) public registryAddresses;
    /// @dev is the reverse mapping of registryAddresses
    mapping(address registryAddress => uint8 registryId) public stateRegistryIds;
    /// @dev is the reverse mapping of ambAddresses
    mapping(address ambAddress => uint8 ambId) public ambIds;

    //////////////////////////////////////////////////////////////
    //                       MODIFIERS                          //
    //////////////////////////////////////////////////////////////

    modifier onlyEmergencyAdmin() {
        if (!ISuperRBAC(registry[SUPER_RBAC][CHAIN_ID]).hasEmergencyAdminRole(msg.sender)) {
            revert Error.NOT_EMERGENCY_ADMIN();
        }
        _;
    }

    modifier onlyProtocolAdmin() {
        if (!ISuperRBAC(registry[SUPER_RBAC][CHAIN_ID]).hasProtocolAdminRole(msg.sender)) {
            revert Error.NOT_PROTOCOL_ADMIN();
        }
        _;
    }

    //////////////////////////////////////////////////////////////
    //                      CONSTRUCTOR                         //
    //////////////////////////////////////////////////////////////

    constructor(address superRBAC_) {
        if (superRBAC_ == address(0)) {
            revert Error.ZERO_ADDRESS();
        }

        if (block.chainid > type(uint64).max) {
            revert Error.BLOCK_CHAIN_ID_OUT_OF_BOUNDS();
        }

        CHAIN_ID = uint64(block.chainid);
        registry[SUPER_RBAC][CHAIN_ID] = superRBAC_;

        emit AddressUpdated(SUPER_RBAC, CHAIN_ID, address(0), superRBAC_);
    }

    //////////////////////////////////////////////////////////////
    //              EXTERNAL VIEW FUNCTIONS                     //
    //////////////////////////////////////////////////////////////

    /// @inheritdoc ISuperRegistry
    function getAddress(bytes32 id_) external view override returns (address addr) {
        addr = registry[id_][CHAIN_ID];
        if (addr == address(0)) revert Error.ZERO_ADDRESS();
    }

    /// @inheritdoc ISuperRegistry
    function getAddressByChainId(bytes32 id_, uint64 chainId_) external view override returns (address addr) {
        addr = registry[id_][chainId_];
        if (addr == address(0)) revert Error.ZERO_ADDRESS();
    }

    /// @inheritdoc ISuperRegistry
    function getBridgeAddress(uint8 bridgeId_) external view override returns (address bridgeAddress_) {
        bridgeAddress_ = bridgeAddresses[bridgeId_];
        if (bridgeAddress_ == address(0)) revert Error.ZERO_ADDRESS();
    }

    /// @inheritdoc ISuperRegistry
    function getBridgeValidator(uint8 bridgeId_) external view override returns (address bridgeValidator_) {
        bridgeValidator_ = bridgeValidator[bridgeId_];
        if (bridgeValidator_ == address(0)) revert Error.ZERO_ADDRESS();
    }

    /// @inheritdoc ISuperRegistry
    function getAmbAddress(uint8 ambId_) external view override returns (address ambAddress_) {
        ambAddress_ = ambAddresses[ambId_];
        if (ambAddress_ == address(0)) revert Error.ZERO_ADDRESS();
    }

    /// @inheritdoc ISuperRegistry
    function getAmbId(address ambAddress_) external view override returns (uint8 ambId_) {
        ambId_ = ambIds[ambAddress_];
    }

    /// @inheritdoc ISuperRegistry
    function getStateRegistry(uint8 registryId_) external view override returns (address registryAddress_) {
        registryAddress_ = registryAddresses[registryId_];
        if (registryAddress_ == address(0)) revert Error.ZERO_ADDRESS();
    }

    /// @inheritdoc ISuperRegistry
    function getStateRegistryId(address registryAddress_) external view override returns (uint8 registryId_) {
        registryId_ = stateRegistryIds[registryAddress_];
        if (registryId_ == 0) revert Error.INVALID_REGISTRY_ID();
    }

    /// @inheritdoc ISuperRegistry
    function getVaultLimitPerDestination(uint64 chainId_)
        external
        view
        override
        returns (uint256 vaultLimitPerDestination_)
    {
        vaultLimitPerDestination_ = vaultLimitPerDestination[chainId_];
    }

    /// @inheritdoc ISuperRegistry
    function isValidStateRegistry(address registryAddress_) external view override returns (bool valid_) {
        if (stateRegistryIds[registryAddress_] != 0) return true;

        return false;
    }

    /// @inheritdoc ISuperRegistry
    function isValidAmbImpl(address ambAddress_) external view override returns (bool valid_) {
        uint8 ambId = ambIds[ambAddress_];
        if (ambId != 0 && !isBroadcastAMB[ambId]) return true;

        return false;
    }

    /// @inheritdoc ISuperRegistry
    function isValidBroadcastAmbImpl(address ambAddress_) external view override returns (bool valid_) {
        uint8 ambId = ambIds[ambAddress_];
        if (ambId != 0 && isBroadcastAMB[ambId]) return true;

        return false;
    }

    /// @inheritdoc ISuperRegistry
    function PERMIT2() external view override returns (address) {
        if (permit2Address == address(0)) revert Error.ZERO_ADDRESS();
        return permit2Address;
    }

    //////////////////////////////////////////////////////////////
    //              EXTERNAL WRITE FUNCTIONS                    //
    //////////////////////////////////////////////////////////////

    /// @inheritdoc ISuperRegistry
    function setVaultLimitPerDestination(uint64 chainId_, uint256 vaultLimit_) external override onlyEmergencyAdmin {
        if (vaultLimit_ == 0) {
            revert Error.ZERO_INPUT_VALUE();
        }

        vaultLimitPerDestination[chainId_] = vaultLimit_;
        emit SetVaultLimitPerDestination(chainId_, vaultLimit_);
    }

    /// @inheritdoc ISuperRegistry
    function setDelay(uint256 delay_) external override onlyProtocolAdmin {
        if (delay_ < MIN_DELAY || delay_ > MAX_DELAY) {
            revert Error.INVALID_TIMELOCK_DELAY();
        }

        uint256 oldDelay_ = delay;
        delay = delay_;

        emit SetDelay(oldDelay_, delay_);
    }

    /// @inheritdoc ISuperRegistry
    function setPermit2(address permit2_) external override onlyProtocolAdmin {
        if (permit2Address != address(0)) revert Error.DISABLED();
        if (permit2_ == address(0)) revert Error.ZERO_ADDRESS();

        permit2Address = permit2_;

        emit SetPermit2(permit2_);
    }

    /// @inheritdoc ISuperRegistry
    function batchSetAddress(
        bytes32[] calldata ids_,
        address[] calldata newAddresses_,
        uint64[] calldata chainIds_
    )
        external
        override
        onlyProtocolAdmin
    {
        uint256 len = ids_.length;

        if (len != newAddresses_.length || len != chainIds_.length) revert Error.ARRAY_LENGTH_MISMATCH();

        for (uint256 i; i < len; ++i) {
            setAddress(ids_[i], newAddresses_[i], chainIds_[i]);
        }
    }

    /// @inheritdoc ISuperRegistry
    function setAddress(bytes32 id_, address newAddress_, uint64 chainId_) public override onlyProtocolAdmin {
        address oldAddress = registry[id_][chainId_];
        if (oldAddress != address(0)) {
            /// @notice SUPERFORM_FACTORY, CORE_STATE_REGISTRY, TIMELOCK_STATE_REGISTRY, BROADCAST_REGISTRY, SUPER_RBAC,
            /// DST_SWAPPER, EMERGENCY_QUEUE, SUPER_POSITIONS and SUPERFORM_ROUTER  cannot be changed once set
            if (
                id_ == SUPERFORM_FACTORY || id_ == CORE_STATE_REGISTRY || id_ == TIMELOCK_STATE_REGISTRY
                    || id_ == BROADCAST_REGISTRY || id_ == SUPER_RBAC || id_ == DST_SWAPPER || id_ == EMERGENCY_QUEUE
                    || id_ == SUPER_POSITIONS || id_ == SUPERFORM_ROUTER
            ) {
                revert Error.DISABLED();
            }
        }

        registry[id_][chainId_] = newAddress_;

        emit AddressUpdated(id_, chainId_, oldAddress, newAddress_);
    }

    /// @inheritdoc ISuperRegistry
    function setBridgeAddresses(
        uint8[] memory bridgeId_,
        address[] memory bridgeAddress_,
        address[] memory bridgeValidator_
    )
        external
        override
        onlyProtocolAdmin
    {
        uint256 len = bridgeId_.length;
        if (len != bridgeAddress_.length || len != bridgeValidator_.length) revert Error.ARRAY_LENGTH_MISMATCH();

        for (uint256 i; i < len; ++i) {
            uint8 bridgeId = bridgeId_[i];
            address bridgeAddress = bridgeAddress_[i];
            address bridgeValidatorT = bridgeValidator_[i];
            if (bridgeAddress == address(0)) revert Error.ZERO_ADDRESS();
            if (bridgeId == 0) revert Error.ZERO_INPUT_VALUE();
            if (bridgeValidatorT == address(0)) revert Error.ZERO_ADDRESS();

            if (bridgeAddresses[bridgeId] != address(0)) revert Error.DISABLED();

            bridgeAddresses[bridgeId] = bridgeAddress;
            bridgeValidator[bridgeId] = bridgeValidatorT;
            emit SetBridgeAddress(bridgeId, bridgeAddress);
            emit SetBridgeValidator(bridgeId, bridgeValidatorT);
        }
    }

    /// @inheritdoc ISuperRegistry
    function setAmbAddress(
        uint8[] memory ambId_,
        address[] memory ambAddress_,
        bool[] memory isBroadcastAMB_
    )
        external
        override
        onlyProtocolAdmin
    {
        uint256 len = ambId_.length;
        if (len != ambAddress_.length || len != isBroadcastAMB_.length) revert Error.ARRAY_LENGTH_MISMATCH();

        for (uint256 i; i < len; ++i) {
            address ambAddress = ambAddress_[i];
            uint8 ambId = ambId_[i];
            bool broadcastAMB = isBroadcastAMB_[i];

            if (ambAddress == address(0)) revert Error.ZERO_ADDRESS();
            if (ambId == 0) revert Error.ZERO_INPUT_VALUE();
            if (ambAddresses[ambId] != address(0)) revert Error.DISABLED();

            ambAddresses[ambId] = ambAddress;
            ambIds[ambAddress] = ambId;
            isBroadcastAMB[ambId] = broadcastAMB;
            emit SetAmbAddress(ambId, ambAddress, broadcastAMB);
        }
    }

    /// @inheritdoc ISuperRegistry
    function setStateRegistryAddress(
        uint8[] memory registryId_,
        address[] memory registryAddress_
    )
        external
        override
        onlyProtocolAdmin
    {
        uint256 len = registryId_.length;
        if (len != registryAddress_.length) revert Error.ARRAY_LENGTH_MISMATCH();

        for (uint256 i; i < len; ++i) {
            address registryAddress = registryAddress_[i];
            uint8 registryId = registryId_[i];
            if (registryAddress == address(0)) revert Error.ZERO_ADDRESS();
            if (registryId == 0) revert Error.ZERO_INPUT_VALUE();
            if (registryAddresses[registryId] != address(0)) {
                revert Error.DISABLED();
            }

            registryAddresses[registryId] = registryAddress;
            stateRegistryIds[registryAddress] = registryId;
            emit SetStateRegistryAddress(registryId, registryAddress);
        }
    }

    /// @inheritdoc QuorumManager
    function setRequiredMessagingQuorum(uint64 srcChainId_, uint256 quorum_) external override onlyProtocolAdmin {
        if (srcChainId_ == 0) {
            revert Error.INVALID_CHAIN_ID();
        }

        requiredQuorum[srcChainId_] = quorum_;

        emit QuorumSet(srcChainId_, quorum_);
    }
}
// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.23;

import { IQuorumManager } from "src/interfaces/IQuorumManager.sol";
import { Error } from "src/libraries/Error.sol";

/// @title QuorumManager
/// @dev Quorum thresholds using in sending proofs from chain to chain
/// @author ZeroPoint Labs
abstract contract QuorumManager is IQuorumManager {
    
    //////////////////////////////////////////////////////////////
    //                     STATE VARIABLES                      //
    //////////////////////////////////////////////////////////////

    mapping(uint64 srcChainId => uint256 quorum) internal requiredQuorum;

    //////////////////////////////////////////////////////////////
    //              EXTERNAL VIEW FUNCTIONS                     //
    //////////////////////////////////////////////////////////////

    /// @inheritdoc IQuorumManager
    function getRequiredMessagingQuorum(uint64 srcChainId_) public view returns (uint256 quorum_) {
        /// @dev no chain can have chain id zero. (validates that here)
        if (srcChainId_ == 0) {
            revert Error.ZERO_INPUT_VALUE();
        }
        return requiredQuorum[srcChainId_];
    }

    //////////////////////////////////////////////////////////////
    //              EXTERNAL WRITE FUNCTIONS                    //
    //////////////////////////////////////////////////////////////

    /// @inheritdoc IQuorumManager
    function setRequiredMessagingQuorum(uint64 srcChainId_, uint256 quorum_) external virtual;
}
// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.23;

import { IAccessControl } from "openzeppelin-contracts/contracts/access/IAccessControl.sol";

/// @title ISuperRBAC
/// @dev Interface for SuperRBAC
/// @author Zeropoint Labs
interface ISuperRBAC is IAccessControl {

    //////////////////////////////////////////////////////////////
    //                           STRUCTS                         //
    //////////////////////////////////////////////////////////////

    struct InitialRoleSetup {
        address admin;
        address emergencyAdmin;
        address paymentAdmin;
        address csrProcessor;
        address tlProcessor;
        address brProcessor;
        address csrUpdater;
        address srcVaaRelayer;
        address dstSwapper;
        address csrRescuer;
        address csrDisputer;
    }

    //////////////////////////////////////////////////////////////
    //                          EVENTS                          //
    //////////////////////////////////////////////////////////////

    /// @dev is emitted when superRegistry is set
    event SuperRegistrySet(address indexed superRegistry);

    /// @dev is emitted when an admin is set for a role
    event RoleAdminSet(bytes32 role, bytes32 adminRole);

    //////////////////////////////////////////////////////////////
    //              EXTERNAL VIEW FUNCTIONS                     //
    //////////////////////////////////////////////////////////////

    /// @dev returns the id of the protocol admin role
    function PROTOCOL_ADMIN_ROLE() external view returns (bytes32);

    /// @dev returns the id of the emergency admin role
    function EMERGENCY_ADMIN_ROLE() external view returns (bytes32);

    /// @dev returns the id of the payment admin role
    function PAYMENT_ADMIN_ROLE() external view returns (bytes32);

    /// @dev returns the id of the broadcaster role
    function BROADCASTER_ROLE() external view returns (bytes32);

    /// @dev returns the id of the core state registry processor role
    function CORE_STATE_REGISTRY_PROCESSOR_ROLE() external view returns (bytes32);

    /// @dev returns the id of the timelock state registry processor role
    function TIMELOCK_STATE_REGISTRY_PROCESSOR_ROLE() external view returns (bytes32);

    /// @dev returns the id of the broadcast state registry processor role
    function BROADCAST_STATE_REGISTRY_PROCESSOR_ROLE() external view returns (bytes32);

    /// @dev returns the id of the core state registry updater role
    function CORE_STATE_REGISTRY_UPDATER_ROLE() external view returns (bytes32);

    /// @dev returns the id of the dst swapper role
    function DST_SWAPPER_ROLE() external view returns (bytes32);

    /// @dev returns the id of the core state registry rescuer role
    function CORE_STATE_REGISTRY_RESCUER_ROLE() external view returns (bytes32);

    /// @dev returns the id of the core state registry rescue disputer role
    function CORE_STATE_REGISTRY_DISPUTER_ROLE() external view returns (bytes32);

    /// @dev returns the id of wormhole vaa relayer role
    function WORMHOLE_VAA_RELAYER_ROLE() external view returns (bytes32);

    /// @dev returns whether the given address has the protocol admin role
    /// @param admin_ the address to check
    function hasProtocolAdminRole(address admin_) external view returns (bool);

    /// @dev returns whether the given address has the emergency admin role
    /// @param admin_ the address to check
    function hasEmergencyAdminRole(address admin_) external view returns (bool);

    //////////////////////////////////////////////////////////////
    //              EXTERNAL WRITE FUNCTIONS                    //
    //////////////////////////////////////////////////////////////

    /// @dev updates the super registry address
    function setSuperRegistry(address superRegistry_) external;

    /// @dev configures a new role in superForm
    /// @param role_ the role to set
    /// @param adminRole_ the admin role to set as admin
    function setRoleAdmin(bytes32 role_, bytes32 adminRole_) external;

    /// @dev revokes the role_ from superRegistryAddressId_ on all chains
    /// @param role_ the role to revoke
    /// @param extraData_ amb config if broadcasting is required
    /// @param superRegistryAddressId_ the super registry address id
    function revokeRoleSuperBroadcast(
        bytes32 role_,
        bytes memory extraData_,
        bytes32 superRegistryAddressId_
    )
        external
        payable;

    /// @dev allows sync of global roles from different chains using broadcast registry
    /// @notice may not work for all roles
    function stateSyncBroadcast(bytes memory data_) external;
}
// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.23;

/// @title ISuperRegistry
/// @dev Interface for SuperRegistry
/// @author Zeropoint Labs
interface ISuperRegistry {
    //////////////////////////////////////////////////////////////
    //                          EVENTS                          //
    //////////////////////////////////////////////////////////////

    /// @dev emitted when permit2 is set.
    event SetPermit2(address indexed permit2);

    /// @dev is emitted when an address is set.
    event AddressUpdated(
        bytes32 indexed protocolAddressId, uint64 indexed chainId, address indexed oldAddress, address newAddress
    );

    /// @dev is emitted when a new token bridge is configured.
    event SetBridgeAddress(uint256 indexed bridgeId, address indexed bridgeAddress);

    /// @dev is emitted when a new bridge validator is configured.
    event SetBridgeValidator(uint256 indexed bridgeId, address indexed bridgeValidator);

    /// @dev is emitted when a new amb is configured.
    event SetAmbAddress(uint8 indexed ambId_, address indexed ambAddress_, bool indexed isBroadcastAMB_);

    /// @dev is emitted when a new state registry is configured.
    event SetStateRegistryAddress(uint8 indexed registryId_, address indexed registryAddress_);

    /// @dev is emitted when a new delay is configured.
    event SetDelay(uint256 indexed oldDelay_, uint256 indexed newDelay_);

    /// @dev is emitted when a new vault limit is configured
    event SetVaultLimitPerDestination(uint64 indexed chainId_, uint256 indexed vaultLimit_);

    //////////////////////////////////////////////////////////////
    //              EXTERNAL VIEW FUNCTIONS                     //
    //////////////////////////////////////////////////////////////

    /// @dev gets the deposit rescue delay
    function delay() external view returns (uint256);

    /// @dev returns the permit2 address
    function PERMIT2() external view returns (address);

    /// @dev returns the id of the superform router module
    function SUPERFORM_ROUTER() external view returns (bytes32);

    /// @dev returns the id of the superform factory module
    function SUPERFORM_FACTORY() external view returns (bytes32);

    /// @dev returns the id of the superform paymaster contract
    function PAYMASTER() external view returns (bytes32);

    /// @dev returns the id of the superform payload helper contract
    function PAYMENT_HELPER() external view returns (bytes32);

    /// @dev returns the id of the core state registry module
    function CORE_STATE_REGISTRY() external view returns (bytes32);

    /// @dev returns the id of the timelock form state registry module
    function TIMELOCK_STATE_REGISTRY() external view returns (bytes32);

    /// @dev returns the id of the broadcast state registry module
    function BROADCAST_REGISTRY() external view returns (bytes32);

    /// @dev returns the id of the super positions module
    function SUPER_POSITIONS() external view returns (bytes32);

    /// @dev returns the id of the super rbac module
    function SUPER_RBAC() external view returns (bytes32);

    /// @dev returns the id of the payload helper module
    function PAYLOAD_HELPER() external view returns (bytes32);

    /// @dev returns the id of the dst swapper keeper
    function DST_SWAPPER() external view returns (bytes32);

    /// @dev returns the id of the emergency queue
    function EMERGENCY_QUEUE() external view returns (bytes32);

    /// @dev returns the id of the superform receiver
    function SUPERFORM_RECEIVER() external view returns (bytes32);

    /// @dev returns the id of the payment admin keeper
    function PAYMENT_ADMIN() external view returns (bytes32);

    /// @dev returns the id of the core state registry processor keeper
    function CORE_REGISTRY_PROCESSOR() external view returns (bytes32);

    /// @dev returns the id of the broadcast registry processor keeper
    function BROADCAST_REGISTRY_PROCESSOR() external view returns (bytes32);

    /// @dev returns the id of the timelock form state registry processor keeper
    function TIMELOCK_REGISTRY_PROCESSOR() external view returns (bytes32);

    /// @dev returns the id of the core state registry updater keeper
    function CORE_REGISTRY_UPDATER() external view returns (bytes32);

    /// @dev returns the id of the core state registry updater keeper
    function CORE_REGISTRY_RESCUER() external view returns (bytes32);

    /// @dev returns the id of the core state registry updater keeper
    function CORE_REGISTRY_DISPUTER() external view returns (bytes32);

    /// @dev returns the id of the core state registry updater keeper
    function DST_SWAPPER_PROCESSOR() external view returns (bytes32);

    /// @dev gets the address of a contract on current chain
    /// @param id_ is the id of the contract
    function getAddress(bytes32 id_) external view returns (address);

    /// @dev gets the address of a contract on a target chain
    /// @param id_ is the id of the contract
    /// @param chainId_ is the chain id of that chain
    function getAddressByChainId(bytes32 id_, uint64 chainId_) external view returns (address);

    /// @dev gets the address of a bridge
    /// @param bridgeId_ is the id of a bridge
    /// @return bridgeAddress_ is the address of the form
    function getBridgeAddress(uint8 bridgeId_) external view returns (address bridgeAddress_);

    /// @dev gets the address of a bridge validator
    /// @param bridgeId_ is the id of a bridge
    /// @return bridgeValidator_ is the address of the form
    function getBridgeValidator(uint8 bridgeId_) external view returns (address bridgeValidator_);

    /// @dev gets the address of a amb
    /// @param ambId_ is the id of a bridge
    /// @return ambAddress_ is the address of the form
    function getAmbAddress(uint8 ambId_) external view returns (address ambAddress_);

    /// @dev gets the id of the amb
    /// @param ambAddress_ is the address of an amb
    /// @return ambId_ is the identifier of an amb
    function getAmbId(address ambAddress_) external view returns (uint8 ambId_);

    /// @dev gets the address of the registry
    /// @param registryId_ is the id of the state registry
    /// @return registryAddress_ is the address of the state registry
    function getStateRegistry(uint8 registryId_) external view returns (address registryAddress_);

    /// @dev gets the id of the registry
    /// @notice reverts if the id is not found
    /// @param registryAddress_ is the address of the state registry
    /// @return registryId_ is the id of the state registry
    function getStateRegistryId(address registryAddress_) external view returns (uint8 registryId_);

    /// @dev gets the safe vault limit
    /// @param chainId_ is the id of the remote chain
    /// @return vaultLimitPerDestination_ is the safe number of vaults to deposit
    /// without hitting out of gas error
    function getVaultLimitPerDestination(uint64 chainId_) external view returns (uint256 vaultLimitPerDestination_);

    /// @dev helps validate if an address is a valid state registry
    /// @param registryAddress_ is the address of the state registry
    /// @return valid_ a flag indicating if its valid.
    function isValidStateRegistry(address registryAddress_) external view returns (bool valid_);

    /// @dev helps validate if an address is a valid amb implementation
    /// @param ambAddress_ is the address of the amb implementation
    /// @return valid_ a flag indicating if its valid.
    function isValidAmbImpl(address ambAddress_) external view returns (bool valid_);

    /// @dev helps validate if an address is a valid broadcast amb implementation
    /// @param ambAddress_ is the address of the broadcast amb implementation
    /// @return valid_ a flag indicating if its valid.
    function isValidBroadcastAmbImpl(address ambAddress_) external view returns (bool valid_);

    //////////////////////////////////////////////////////////////
    //              EXTERNAL WRITE FUNCTIONS                    //
    //////////////////////////////////////////////////////////////

    /// @dev sets the deposit rescue delay
    /// @param delay_ the delay in seconds before the deposit rescue can be finalized
    function setDelay(uint256 delay_) external;

    /// @dev sets the permit2 address
    /// @param permit2_ the address of the permit2 contract
    function setPermit2(address permit2_) external;

    /// @dev sets the safe vault limit
    /// @param chainId_ is the remote chain identifier
    /// @param vaultLimit_ is the max limit of vaults per transaction
    function setVaultLimitPerDestination(uint64 chainId_, uint256 vaultLimit_) external;

    /// @dev sets new addresses on specific chains.
    /// @param ids_ are the identifiers of the address on that chain
    /// @param newAddresses_  are the new addresses on that chain
    /// @param chainIds_ are the chain ids of that chain
    function batchSetAddress(
        bytes32[] calldata ids_,
        address[] calldata newAddresses_,
        uint64[] calldata chainIds_
    )
        external;

    /// @dev sets a new address on a specific chain.
    /// @param id_ the identifier of the address on that chain
    /// @param newAddress_ the new address on that chain
    /// @param chainId_ the chain id of that chain
    function setAddress(bytes32 id_, address newAddress_, uint64 chainId_) external;

    /// @dev allows admin to set the bridge address for an bridge id.
    /// @notice this function operates in an APPEND-ONLY fashion.
    /// @param bridgeId_         represents the bridge unique identifier.
    /// @param bridgeAddress_    represents the bridge address.
    /// @param bridgeValidator_  represents the bridge validator address.
    function setBridgeAddresses(
        uint8[] memory bridgeId_,
        address[] memory bridgeAddress_,
        address[] memory bridgeValidator_
    )
        external;

    /// @dev allows admin to set the amb address for an amb id.
    /// @notice this function operates in an APPEND-ONLY fashion.
    /// @param ambId_         represents the bridge unique identifier.
    /// @param ambAddress_    represents the bridge address.
    /// @param isBroadcastAMB_ represents whether the amb implementation supports broadcasting
    function setAmbAddress(
        uint8[] memory ambId_,
        address[] memory ambAddress_,
        bool[] memory isBroadcastAMB_
    )
        external;

    /// @dev allows admin to set the state registry address for an state registry id.
    /// @notice this function operates in an APPEND-ONLY fashion.
    /// @param registryId_    represents the state registry's unique identifier.
    /// @param registryAddress_    represents the state registry's address.
    function setStateRegistryAddress(uint8[] memory registryId_, address[] memory registryAddress_) external;
}
// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.23;

library Error {
    //////////////////////////////////////////////////////////////
    //                  CONFIGURATION ERRORS                    //
    //////////////////////////////////////////////////////////////
    ///@notice errors thrown in protocol setup

    /// @dev thrown if chain id exceeds max(uint64)
    error BLOCK_CHAIN_ID_OUT_OF_BOUNDS();

    /// @dev thrown if not possible to revoke a role in broadcasting
    error CANNOT_REVOKE_NON_BROADCASTABLE_ROLES();

    /// @dev thrown if not possible to revoke last admin
    error CANNOT_REVOKE_LAST_ADMIN();

    /// @dev thrown if trying to set again pseudo immutables in super registry
    error DISABLED();

    /// @dev thrown if rescue delay is not yet set for a chain
    error DELAY_NOT_SET();

    /// @dev thrown if get native token price estimate in paymentHelper is 0
    error INVALID_NATIVE_TOKEN_PRICE();

    /// @dev thrown if wormhole refund chain id is not set
    error REFUND_CHAIN_ID_NOT_SET();

    /// @dev thrown if wormhole relayer is not set
    error RELAYER_NOT_SET();

    /// @dev thrown if a role to be revoked is not assigned
    error ROLE_NOT_ASSIGNED();

    //////////////////////////////////////////////////////////////
    //                  AUTHORIZATION ERRORS                    //
    //////////////////////////////////////////////////////////////
    ///@notice errors thrown if functions cannot be called

    /// COMMON AUTHORIZATION ERRORS
    /// ---------------------------------------------------------

    /// @dev thrown if caller is not address(this), internal call
    error INVALID_INTERNAL_CALL();

    /// @dev thrown if msg.sender is not a valid amb implementation
    error NOT_AMB_IMPLEMENTATION();

    /// @dev thrown if msg.sender is not an allowed broadcaster
    error NOT_ALLOWED_BROADCASTER();

    /// @dev thrown if msg.sender is not broadcast amb implementation
    error NOT_BROADCAST_AMB_IMPLEMENTATION();

    /// @dev thrown if msg.sender is not broadcast state registry
    error NOT_BROADCAST_REGISTRY();

    /// @dev thrown if msg.sender is not core state registry
    error NOT_CORE_STATE_REGISTRY();

    /// @dev thrown if msg.sender is not emergency admin
    error NOT_EMERGENCY_ADMIN();

    /// @dev thrown if msg.sender is not emergency queue
    error NOT_EMERGENCY_QUEUE();

    /// @dev thrown if msg.sender is not minter
    error NOT_MINTER();

    /// @dev thrown if msg.sender is not minter state registry
    error NOT_MINTER_STATE_REGISTRY_ROLE();

    /// @dev thrown if msg.sender is not paymaster
    error NOT_PAYMASTER();

    /// @dev thrown if msg.sender is not payment admin
    error NOT_PAYMENT_ADMIN();

    /// @dev thrown if msg.sender is not protocol admin
    error NOT_PROTOCOL_ADMIN();

    /// @dev thrown if msg.sender is not state registry
    error NOT_STATE_REGISTRY();

    /// @dev thrown if msg.sender is not super registry
    error NOT_SUPER_REGISTRY();

    /// @dev thrown if msg.sender is not superform router
    error NOT_SUPERFORM_ROUTER();

    /// @dev thrown if msg.sender is not a superform
    error NOT_SUPERFORM();

    /// @dev thrown if msg.sender is not superform factory
    error NOT_SUPERFORM_FACTORY();

    /// @dev thrown if msg.sender is not timelock form
    error NOT_TIMELOCK_SUPERFORM();

    /// @dev thrown if msg.sender is not timelock state registry
    error NOT_TIMELOCK_STATE_REGISTRY();

    /// @dev thrown if msg.sender is not user or disputer
    error NOT_VALID_DISPUTER();

    /// @dev thrown if the msg.sender is not privileged caller
    error NOT_PRIVILEGED_CALLER(bytes32 role);

    /// STATE REGISTRY AUTHORIZATION ERRORS
    /// ---------------------------------------------------------

    /// @dev layerzero adapter specific error, thrown if caller not layerzero endpoint
    error CALLER_NOT_ENDPOINT();

    /// @dev hyperlane adapter specific error, thrown if caller not hyperlane mailbox
    error CALLER_NOT_MAILBOX();

    /// @dev wormhole relayer specific error, thrown if caller not wormhole relayer
    error CALLER_NOT_RELAYER();

    /// @dev thrown if src chain sender is not valid
    error INVALID_SRC_SENDER();

    //////////////////////////////////////////////////////////////
    //                  INPUT VALIDATION ERRORS                 //
    //////////////////////////////////////////////////////////////
    ///@notice errors thrown if input variables are not valid

    /// COMMON INPUT VALIDATION ERRORS
    /// ---------------------------------------------------------

    /// @dev thrown if there is an array length mismatch
    error ARRAY_LENGTH_MISMATCH();

    /// @dev thrown if payload id does not exist
    error INVALID_PAYLOAD_ID();

    /// @dev error thrown when msg value should be zero in certain payable functions
    error MSG_VALUE_NOT_ZERO();

    /// @dev thrown if amb ids length is 0
    error ZERO_AMB_ID_LENGTH();

    /// @dev thrown if address input is address 0
    error ZERO_ADDRESS();

    /// @dev thrown if amount input is 0
    error ZERO_AMOUNT();

    /// @dev thrown if final token is address 0
    error ZERO_FINAL_TOKEN();

    /// @dev thrown if value input is 0
    error ZERO_INPUT_VALUE();

    /// SUPERFORM ROUTER INPUT VALIDATION ERRORS
    /// ---------------------------------------------------------

    /// @dev thrown if the vaults data is invalid
    error INVALID_SUPERFORMS_DATA();

    /// @dev thrown if receiver address is not set
    error RECEIVER_ADDRESS_NOT_SET();

    /// SUPERFORM FACTORY INPUT VALIDATION ERRORS
    /// ---------------------------------------------------------

    /// @dev thrown if a form is not ERC165 compatible
    error ERC165_UNSUPPORTED();

    /// @dev thrown if a form is not form interface compatible
    error FORM_INTERFACE_UNSUPPORTED();

    /// @dev error thrown if form implementation address already exists
    error FORM_IMPLEMENTATION_ALREADY_EXISTS();

    /// @dev error thrown if form implementation id already exists
    error FORM_IMPLEMENTATION_ID_ALREADY_EXISTS();

    /// @dev thrown if a form does not exist
    error FORM_DOES_NOT_EXIST();

    /// @dev thrown if form id is larger than max uint16
    error INVALID_FORM_ID();

    /// @dev thrown if superform not on factory
    error SUPERFORM_ID_NONEXISTENT();

    /// @dev thrown if same vault and form implementation is used to create new superform
    error VAULT_FORM_IMPLEMENTATION_COMBINATION_EXISTS();

    /// FORM INPUT VALIDATION ERRORS
    /// ---------------------------------------------------------

    /// @dev thrown if in case of no txData, if liqData.token != vault.asset()
    /// in case of txData, if token output of swap != vault.asset()
    error DIFFERENT_TOKENS();

    /// @dev thrown if the amount in direct withdraw is not correct
    error DIRECT_WITHDRAW_INVALID_LIQ_REQUEST();

    /// @dev thrown if the amount in xchain withdraw is not correct
    error XCHAIN_WITHDRAW_INVALID_LIQ_REQUEST();

    /// LIQUIDITY BRIDGE INPUT VALIDATION ERRORS
    /// ---------------------------------------------------------

    /// @dev thrown if route id is blacklisted in socket
    error BLACKLISTED_ROUTE_ID();

    /// @dev thrown if route id is not blacklisted in socket
    error NOT_BLACKLISTED_ROUTE_ID();

    /// @dev error thrown when txData selector of lifi bridge is a blacklisted selector
    error BLACKLISTED_SELECTOR();

    /// @dev error thrown when txData selector of lifi bridge is not a blacklisted selector
    error NOT_BLACKLISTED_SELECTOR();

    /// @dev thrown if a certain action of the user is not allowed given the txData provided
    error INVALID_ACTION();

    /// @dev thrown if in deposits, the liqDstChainId doesn't match the stateReq dstChainId
    error INVALID_DEPOSIT_LIQ_DST_CHAIN_ID();

    /// @dev thrown if index is invalid
    error INVALID_INDEX();

    /// @dev thrown if the chain id in the txdata is invalid
    error INVALID_TXDATA_CHAIN_ID();

    /// @dev thrown if the validation of bridge txData fails due to a destination call present
    error INVALID_TXDATA_NO_DESTINATIONCALL_ALLOWED();

    /// @dev thrown if the validation of bridge txData fails due to wrong receiver
    error INVALID_TXDATA_RECEIVER();

    /// @dev thrown if the validation of bridge txData fails due to wrong token
    error INVALID_TXDATA_TOKEN();

    /// @dev thrown if txData is not present (in case of xChain actions)
    error NO_TXDATA_PRESENT();

    /// STATE REGISTRY INPUT VALIDATION ERRORS
    /// ---------------------------------------------------------

    /// @dev thrown if payload is being updated with final amounts length different than amounts length
    error DIFFERENT_PAYLOAD_UPDATE_AMOUNTS_LENGTH();

    /// @dev thrown if payload is being updated with tx data length different than liq data length
    error DIFFERENT_PAYLOAD_UPDATE_TX_DATA_LENGTH();

    /// @dev thrown if keeper update final token is different than the vault underlying
    error INVALID_UPDATE_FINAL_TOKEN();

    /// @dev thrown if broadcast finality for wormhole is invalid
    error INVALID_BROADCAST_FINALITY();

    /// @dev thrown if amb id is not valid leading to an address 0 of the implementation
    error INVALID_BRIDGE_ID();

    /// @dev thrown if chain id involved in xchain message is invalid
    error INVALID_CHAIN_ID();

    /// @dev thrown if payload update amount isn't equal to dst swapper amount
    error INVALID_DST_SWAP_AMOUNT();

    /// @dev thrown if message amb and proof amb are the same
    error INVALID_PROOF_BRIDGE_ID();

    /// @dev thrown if order of proof AMBs is incorrect, either duplicated or not incrementing
    error INVALID_PROOF_BRIDGE_IDS();

    /// @dev thrown if rescue data lengths are invalid
    error INVALID_RESCUE_DATA();

    /// @dev thrown if delay is invalid
    error INVALID_TIMELOCK_DELAY();

    /// @dev thrown if amounts being sent in update payload mean a negative slippage
    error NEGATIVE_SLIPPAGE();

    /// @dev thrown if slippage is outside of bounds
    error SLIPPAGE_OUT_OF_BOUNDS();

    /// SUPERPOSITION INPUT VALIDATION ERRORS
    /// ---------------------------------------------------------

    /// @dev thrown if src senders mismatch in state sync
    error SRC_SENDER_MISMATCH();

    /// @dev thrown if src tx types mismatch in state sync
    error SRC_TX_TYPE_MISMATCH();

    //////////////////////////////////////////////////////////////
    //                  EXECUTION ERRORS                        //
    //////////////////////////////////////////////////////////////
    ///@notice errors thrown due to function execution logic

    /// COMMON EXECUTION ERRORS
    /// ---------------------------------------------------------

    /// @dev thrown if the swap in a direct deposit resulted in insufficient tokens
    error DIRECT_DEPOSIT_SWAP_FAILED();

    /// @dev thrown if payload is not unique
    error DUPLICATE_PAYLOAD();

    /// @dev thrown if native tokens fail to be sent to superform contracts
    error FAILED_TO_SEND_NATIVE();

    /// @dev thrown if allowance is not correct to deposit
    error INSUFFICIENT_ALLOWANCE_FOR_DEPOSIT();

    /// @dev thrown if contract has insufficient balance for operations
    error INSUFFICIENT_BALANCE();

    /// @dev thrown if native amount is not at least equal to the amount in the request
    error INSUFFICIENT_NATIVE_AMOUNT();

    /// @dev thrown if payload cannot be decoded
    error INVALID_PAYLOAD();

    /// @dev thrown if payload status is invalid
    error INVALID_PAYLOAD_STATUS();

    /// @dev thrown if payload type is invalid
    error INVALID_PAYLOAD_TYPE();

    /// LIQUIDITY BRIDGE EXECUTION ERRORS
    /// ---------------------------------------------------------

    /// @dev thrown if we try to decode the final swap output token in a xChain liquidity bridging action
    error CANNOT_DECODE_FINAL_SWAP_OUTPUT_TOKEN();

    /// @dev thrown if liquidity bridge fails for erc20 or native tokens
    error FAILED_TO_EXECUTE_TXDATA(address token);

    /// @dev thrown if asset being used for deposit mismatches in multivault deposits
    error INVALID_DEPOSIT_TOKEN();

    /// STATE REGISTRY EXECUTION ERRORS
    /// ---------------------------------------------------------

    /// @dev thrown if bridge tokens haven't arrived to destination
    error BRIDGE_TOKENS_PENDING();

    /// @dev thrown if withdrawal tx data cannot be updated
    error CANNOT_UPDATE_WITHDRAW_TX_DATA();

    /// @dev thrown if rescue passed dispute deadline
    error DISPUTE_TIME_ELAPSED();

    /// @dev thrown if message failed to reach the specified level of quorum needed
    error INSUFFICIENT_QUORUM();

    /// @dev thrown if broadcast payload is invalid
    error INVALID_BROADCAST_PAYLOAD();

    /// @dev thrown if broadcast fee is invalid
    error INVALID_BROADCAST_FEE();

    /// @dev thrown if retry fees is less than required
    error INVALID_RETRY_FEE();

    /// @dev thrown if broadcast message type is wrong
    error INVALID_MESSAGE_TYPE();

    /// @dev thrown if payload hash is invalid during `retryMessage` on Layezero implementation
    error INVALID_PAYLOAD_HASH();

    /// @dev thrown if update payload function was called on a wrong payload
    error INVALID_PAYLOAD_UPDATE_REQUEST();

    /// @dev thrown if a state registry id is 0
    error INVALID_REGISTRY_ID();

    /// @dev thrown if a form state registry id is 0
    error INVALID_FORM_REGISTRY_ID();

    /// @dev thrown if trying to finalize the payload but the withdraw is still locked
    error LOCKED();

    /// @dev thrown if payload is already updated (during xChain deposits)
    error PAYLOAD_ALREADY_UPDATED();

    /// @dev thrown if payload is already processed
    error PAYLOAD_ALREADY_PROCESSED();

    /// @dev thrown if payload is not in UPDATED state
    error PAYLOAD_NOT_UPDATED();

    /// @dev thrown if rescue is still in timelocked state
    error RESCUE_LOCKED();

    /// @dev thrown if rescue is already proposed
    error RESCUE_ALREADY_PROPOSED();

    /// @dev thrown if payload hash is zero during `retryMessage` on Layezero implementation
    error ZERO_PAYLOAD_HASH();

    /// DST SWAPPER EXECUTION ERRORS
    /// ---------------------------------------------------------

    /// @dev thrown if process dst swap is tried for processed payload id
    error DST_SWAP_ALREADY_PROCESSED();

    /// @dev thrown if indices have duplicates
    error DUPLICATE_INDEX();

    /// @dev thrown if failed dst swap is already updated
    error FAILED_DST_SWAP_ALREADY_UPDATED();

    /// @dev thrown if indices are out of bounds
    error INDEX_OUT_OF_BOUNDS();

    /// @dev thrown if failed swap token amount is 0
    error INVALID_DST_SWAPPER_FAILED_SWAP();

    /// @dev thrown if failed swap token amount is not 0 and if token balance is less than amount (non zero)
    error INVALID_DST_SWAPPER_FAILED_SWAP_NO_TOKEN_BALANCE();

    /// @dev thrown if failed swap token amount is not 0 and if native amount is less than amount (non zero)
    error INVALID_DST_SWAPPER_FAILED_SWAP_NO_NATIVE_BALANCE();

    /// @dev forbid xChain deposits with destination swaps without interim token set (for user protection)
    error INVALID_INTERIM_TOKEN();

    /// @dev thrown if dst swap output is less than minimum expected
    error INVALID_SWAP_OUTPUT();

    /// FORM EXECUTION ERRORS
    /// ---------------------------------------------------------

    /// @dev thrown if try to forward 4626 share from the superform
    error CANNOT_FORWARD_4646_TOKEN();

    /// @dev thrown in KYCDAO form if no KYC token is present
    error NO_VALID_KYC_TOKEN();

    /// @dev thrown in forms where a certain functionality is not allowed or implemented
    error NOT_IMPLEMENTED();

    /// @dev thrown if form implementation is PAUSED, users cannot perform any action
    error PAUSED();

    /// @dev thrown if shares != deposit output or assets != redeem output when minting SuperPositions
    error VAULT_IMPLEMENTATION_FAILED();

    /// @dev thrown if withdrawal tx data is not updated
    error WITHDRAW_TOKEN_NOT_UPDATED();

    /// @dev thrown if withdrawal tx data is not updated
    error WITHDRAW_TX_DATA_NOT_UPDATED();

    /// @dev thrown when redeeming from vault yields zero collateral
    error WITHDRAW_ZERO_COLLATERAL();

    /// PAYMENT HELPER EXECUTION ERRORS
    /// ---------------------------------------------------------

    /// @dev thrown if chainlink is reporting an improper price
    error CHAINLINK_MALFUNCTION();

    /// @dev thrown if chainlink is reporting an incomplete round
    error CHAINLINK_INCOMPLETE_ROUND();

    /// @dev thrown if feed decimals is not 8
    error CHAINLINK_UNSUPPORTED_DECIMAL();

    /// EMERGENCY QUEUE EXECUTION ERRORS
    /// ---------------------------------------------------------

    /// @dev thrown if emergency withdraw is not queued
    error EMERGENCY_WITHDRAW_NOT_QUEUED();

    /// @dev thrown if emergency withdraw is already processed
    error EMERGENCY_WITHDRAW_PROCESSED_ALREADY();

    /// SUPERPOSITION EXECUTION ERRORS
    /// ---------------------------------------------------------

    /// @dev thrown if uri cannot be updated
    error DYNAMIC_URI_FROZEN();

    /// @dev thrown if tx history is not found while state sync
    error TX_HISTORY_NOT_FOUND();
}
// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.23;

/// @title IQuorumManager
/// @dev Interface for QuorumManager
/// @author ZeroPoint Labs
interface IQuorumManager {

    //////////////////////////////////////////////////////////////
    //                          EVENTS                           //
    //////////////////////////////////////////////////////////////

    /// @dev emitted when a new quorum is set for a specific chain
    /// @param srcChainId the chain id from which the message (payload) is sent
    /// @param quorum the minimum number of message bridges required for processing
    event QuorumSet(uint64 indexed srcChainId, uint256 indexed quorum);

    //////////////////////////////////////////////////////////////
    //              EXTERNAL VIEW FUNCTIONS                     //
    //////////////////////////////////////////////////////////////

    /// @dev returns the required quorum for the srcChain & dstChain
    /// @param srcChainId_ is the chain id from which the message (payload) is sent
    /// @return quorum_ the minimum number of message bridges required for processing
    function getRequiredMessagingQuorum(uint64 srcChainId_) external view returns (uint256 quorum_);

    //////////////////////////////////////////////////////////////
    //              EXTERNAL WRITE FUNCTIONS                    //
    //////////////////////////////////////////////////////////////

    /// @dev allows inheriting contracts to set the messaging quorum for a specific sender chain
    /// @notice quorum is the number of extra ambs a message proof must go through and be validated
    /// @param srcChainId_ is the chain id from which the message (payload) is sent
    /// @param quorum_ the minimum number of message bridges required for processing
    /// NOTE: overriding child contracts should handle the sender validation & setting of message quorum
    function setRequiredMessagingQuorum(uint64 srcChainId_, uint256 quorum_) external;
}
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v5.0.0) (access/IAccessControl.sol)

pragma solidity ^0.8.20;

/**
 * @dev External interface of AccessControl declared to support ERC-165 detection.
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
