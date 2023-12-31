// SPDX-License-Identifier: LGPL-3.0-only
pragma solidity >=0.7.0 <0.9.0;
import "../../libraries/GnosisSafeStorage.sol";

/// @title Migration - migrates a Safe contract for BSC fix
/// @author Richard Meissner - <richard@gnosis.io>
contract BscFixMigration is GnosisSafeStorage {

    address public constant SAFE_130_L2_SINGLETON = 0x3E5c63644E683549055b9Be8653de26E0B4CD36E;
    address public constant SAFE_BSC_FIX_SINGLETON = 0x4e6A0E034318Bec795c5E1dD4817A424767265A7;

    /// @dev Allows to migrate the contract. This should be called via a delegatecall.
    function migrate() public {
        singleton = SAFE_BSC_FIX_SINGLETON;
    }

    /// @dev Allows to migrate back the contract. This should be called via a delegatecall.
    function revertMigration() public {
        singleton = SAFE_130_L2_SINGLETON;
    }
}
// SPDX-License-Identifier: LGPL-3.0-only
pragma solidity >=0.7.0 <0.9.0;

/// @title GnosisSafeStorage - Storage layout of the Safe contracts to be used in libraries
/// @author Richard Meissner - <richard@gnosis.io>
contract GnosisSafeStorage {
    // From /common/Singleton.sol
    address internal singleton;
    // From /common/ModuleManager.sol
    mapping(address => address) internal modules;
    // From /common/OwnerManager.sol
    mapping(address => address) internal owners;
    uint256 internal ownerCount;
    uint256 internal threshold;

    // From /GnosisSafe.sol
    bytes32 internal nonce;
    bytes32 internal domainSeparator;
    mapping(bytes32 => uint256) internal signedMessages;
    mapping(address => mapping(bytes32 => uint256)) internal approvedHashes;
}
