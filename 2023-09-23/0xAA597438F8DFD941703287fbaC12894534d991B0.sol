// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

interface IPermissionManager {
    function addAdmin(address _admin) external;

    function removeAdmin(address _admin) external;

    function addManager(address _manager) external;

    function removeManager(address _manager) external;

    function isAdmin(address _admin) external view returns (bool);

    function isManager(address _manager) external view returns (bool);

    function isManagerOrAdmin(
        address _managerOrAdmin
    ) external view returns (bool);
}
// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import {IPermissionManager} from "./interfaces/IPermissionManager.sol";

/// @title PermissionManager
/// @author DeepchainLabs
/// @notice This contract provides a permission manager for admins and managers
/// @dev This contract is intended to be inherited by any contract that needs to restrict access to certain functions
contract PermissionManager is IPermissionManager {
    /// @notice valid admins
    mapping(address => bool) private admins;
    /// @notice valid managers
    mapping(address => bool) private managers;

    event AdminAdded(address indexed admin);
    event AdminRemoved(address indexed admin);
    event ManagerAdded(address indexed manager);
    event ManagerRemoved(address indexed manager);

    /// @notice Initializes the permission manager contract
    constructor() {
        admins[msg.sender] = true;
    }

    /// @dev Modifier to be used in permissioned functions that only admins can call
    modifier onlyAdmin() {
        require(admins[msg.sender], "Only admin");
        _;
    }

    /// @notice Adds an admin
    /// @dev This function can only be called by an admin
    /// @param _admin (address) The address of the admin
    function addAdmin(address _admin) external onlyAdmin {
        require(!admins[_admin], "Already admin");
        admins[_admin] = true;
        emit AdminAdded(_admin);
    }

    /// @notice Removes an admin
    /// @dev This function can only be called by an admin
    /// @param _admin (address) The address of the admin
    function removeAdmin(address _admin) external onlyAdmin {
        require(admins[_admin], "Not admin");
        admins[_admin] = false;
        emit AdminRemoved(_admin);
    }

    /// @notice Adds a manager
    /// @dev This function can only be called by an admin
    /// @param _manager (address) The address of the manager
    function addManager(address _manager) external onlyAdmin {
        require(!managers[_manager], "Already manager");
        managers[_manager] = true;
        emit ManagerAdded(_manager);
    }

    /// @notice Removes a manager
    /// @dev This function can only be called by an admin
    /// @param _manager (address) The address of the manager
    function removeManager(address _manager) external onlyAdmin {
        require(managers[_manager], "Not manager");
        managers[_manager] = false;
        emit ManagerRemoved(_manager);
    }

    function isAdmin(address _admin) external view override returns (bool) {
        return admins[_admin];
    }

    /// @notice Checks if an address is a manager
    /// @param _manager (address) The address of the manager
    /// @return  (bool) Whether the address is a manager or not
    function isManager(address _manager) external view override returns (bool) {
        return managers[_manager];
    }

    /// @notice Checks if an address is a manager or admin
    /// @param _managerOrAdmin (address) The address of the manager or admin
    /// @return  (bool) Whether the address is a manager or admin or not
    function isManagerOrAdmin(
        address _managerOrAdmin
    ) external view override returns (bool) {
        return managers[_managerOrAdmin] || admins[_managerOrAdmin];
    }
}
