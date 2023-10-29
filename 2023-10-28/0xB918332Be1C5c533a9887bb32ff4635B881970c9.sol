// SPDX-License-Identifier: MIT
pragma solidity >=0.8.18;

import { IPRBProxy } from "./interfaces/IPRBProxy.sol";
import { IPRBProxyPlugin } from "./interfaces/IPRBProxyPlugin.sol";
import { IPRBProxyRegistry } from "./interfaces/IPRBProxyRegistry.sol";

/*

██████╗ ██████╗ ██████╗ ██████╗ ██████╗  ██████╗ ██╗  ██╗██╗   ██╗
██╔══██╗██╔══██╗██╔══██╗██╔══██╗██╔══██╗██╔═══██╗╚██╗██╔╝╚██╗ ██╔╝
██████╔╝██████╔╝██████╔╝██████╔╝██████╔╝██║   ██║ ╚███╔╝  ╚████╔╝
██╔═══╝ ██╔══██╗██╔══██╗██╔═══╝ ██╔══██╗██║   ██║ ██╔██╗   ╚██╔╝
██║     ██║  ██║██████╔╝██║     ██║  ██║╚██████╔╝██╔╝ ██╗   ██║
╚═╝     ╚═╝  ╚═╝╚═════╝ ╚═╝     ╚═╝  ╚═╝ ╚═════╝ ╚═╝  ╚═╝   ╚═╝

*/

/// @title PRBProxy
/// @dev See the documentation in {IPRBProxy}.
contract PRBProxy is IPRBProxy {
    /*//////////////////////////////////////////////////////////////////////////
                                     CONSTANTS
    //////////////////////////////////////////////////////////////////////////*/

    /// @inheritdoc IPRBProxy
    address public immutable override owner;

    /// @inheritdoc IPRBProxy
    IPRBProxyRegistry public immutable override registry;

    /*//////////////////////////////////////////////////////////////////////////
                                     CONSTRUCTOR
    //////////////////////////////////////////////////////////////////////////*/

    /// @notice Creates the proxy by fetching the constructor params from the registry, optionally delegate calling
    /// to a target contract if one is provided.
    /// @dev The rationale of this approach is to have the proxy's CREATE2 address not depend on any constructor params.
    constructor() {
        registry = IPRBProxyRegistry(msg.sender);
        (address owner_, address target, bytes memory data) = registry.constructorParams();
        owner = owner_;
        if (target != address(0)) {
            _execute(target, data);
        }
    }

    /*//////////////////////////////////////////////////////////////////////////
                                  FALLBACK FUNCTIONS
    //////////////////////////////////////////////////////////////////////////*/

    /// @notice Fallback function used to run plugins.
    /// @dev WARNING: anyone can call this function and thus run any installed plugin.
    fallback(bytes calldata data) external payable returns (bytes memory response) {
        // Check if the function selector points to a known installed plugin.
        IPRBProxyPlugin plugin = registry.getPluginByOwner({ owner: owner, method: msg.sig });
        if (address(plugin) == address(0)) {
            revert PRBProxy_PluginNotInstalledForMethod({ caller: msg.sender, owner: owner, method: msg.sig });
        }

        // Delegate call to the plugin.
        bool success;
        (success, response) = address(plugin).delegatecall(data);

        // Log the plugin run.
        emit RunPlugin(plugin, data, response);

        // Check if the call was successful or not.
        if (!success) {
            // If there is return data, the delegate call reverted with a reason or a custom error, which we bubble up.
            if (response.length > 0) {
                assembly {
                    let returndata_size := mload(response)
                    revert(add(32, response), returndata_size)
                }
            } else {
                revert PRBProxy_PluginReverted(plugin);
            }
        }
    }

    /// @dev Called when `msg.value` is not zero and the call data is empty.
    receive() external payable { }

    /*//////////////////////////////////////////////////////////////////////////
                         USER-FACING NON-CONSTANT FUNCTIONS
    //////////////////////////////////////////////////////////////////////////*/

    /// @inheritdoc IPRBProxy
    function execute(address target, bytes calldata data) external payable override returns (bytes memory response) {
        // Check that the caller is either the owner or an envoy with permission.
        if (owner != msg.sender) {
            bool permission = registry.getPermissionByOwner({ owner: owner, envoy: msg.sender, target: target });
            if (!permission) {
                revert PRBProxy_ExecutionUnauthorized({ owner: owner, caller: msg.sender, target: target });
            }
        }

        // Delegate call to the target contract, and handle the response.
        response = _execute(target, data);
    }

    /*//////////////////////////////////////////////////////////////////////////
                          INTERNAL NON-CONSTANT FUNCTIONS
    //////////////////////////////////////////////////////////////////////////*/

    /// @notice Executes a DELEGATECALL to the provided target with the provided data.
    /// @dev Shared logic between the constructor and the `execute` function.
    function _execute(address target, bytes memory data) internal returns (bytes memory response) {
        // Check that the target is a contract.
        if (target.code.length == 0) {
            revert PRBProxy_TargetNotContract(target);
        }

        // Delegate call to the target contract.
        bool success;
        (success, response) = target.delegatecall(data);

        // Log the execution.
        emit Execute(target, data, response);

        // Check if the call was successful or not.
        if (!success) {
            // If there is return data, the delegate call reverted with a reason or a custom error, which we bubble up.
            if (response.length > 0) {
                assembly {
                    // The length of the data is at `response`, while the actual data is at `response + 32`.
                    let returndata_size := mload(response)
                    revert(add(response, 32), returndata_size)
                }
            } else {
                revert PRBProxy_ExecutionReverted();
            }
        }
    }
}
// SPDX-License-Identifier: MIT
pragma solidity >=0.8.4;

import { IPRBProxyPlugin } from "./IPRBProxyPlugin.sol";
import { IPRBProxyRegistry } from "./IPRBProxyRegistry.sol";

/// @title IPRBProxy
/// @notice Proxy contract to compose transactions on behalf of the owner.
interface IPRBProxy {
    /*//////////////////////////////////////////////////////////////////////////
                                       ERRORS
    //////////////////////////////////////////////////////////////////////////*/

    /// @notice Thrown when the transfer ownership function is called directly (not via the registry).
    error PRBProxy_CallerNotRegistry(IPRBProxyRegistry registry, address caller);

    /// @notice Thrown when a target contract reverts without a specified reason.
    error PRBProxy_ExecutionReverted();

    /// @notice Thrown when an unauthorized account tries to execute a delegate call.
    error PRBProxy_ExecutionUnauthorized(address owner, address caller, address target);

    /// @notice Thrown when the fallback function fails to find an installed plugin for the method selector.
    error PRBProxy_PluginNotInstalledForMethod(address caller, address owner, bytes4 method);

    /// @notice Thrown when a plugin execution reverts without a specified reason.
    error PRBProxy_PluginReverted(IPRBProxyPlugin plugin);

    /// @notice Thrown when a non-contract address is passed as the target.
    error PRBProxy_TargetNotContract(address target);

    /// @notice Thrown when the registry is passed as the target.
    error PRBProxy_TargetRegistry();

    /*//////////////////////////////////////////////////////////////////////////
                                       EVENTS
    //////////////////////////////////////////////////////////////////////////*/

    /// @notice Emitted when a target contract is delegate called.
    event Execute(address indexed target, bytes data, bytes response);

    /// @notice Emitted when a plugin is run for a provided method.
    event RunPlugin(IPRBProxyPlugin indexed plugin, bytes data, bytes response);

    /*//////////////////////////////////////////////////////////////////////////
                                 CONSTANT FUNCTIONS
    //////////////////////////////////////////////////////////////////////////*/

    /// @notice The address of the owner account or contract, which controls the proxy.
    function owner() external view returns (address);

    /// @notice The address of the registry that has deployed this proxy.
    function registry() external view returns (IPRBProxyRegistry);

    /*//////////////////////////////////////////////////////////////////////////
                               NON-CONSTANT FUNCTIONS
    //////////////////////////////////////////////////////////////////////////*/

    /// @notice Delegate calls to the provided target contract by forwarding the data. It returns the data it
    /// gets back, and bubbles up any potential revert.
    ///
    /// @dev Emits an {Execute} event.
    ///
    /// Requirements:
    /// - The caller must be either the owner or an envoy with permission.
    /// - `target` must be a contract.
    ///
    /// @param target The address of the target contract.
    /// @param data Function selector plus ABI encoded data.
    /// @return response The response received from the target contract, if any.
    function execute(address target, bytes calldata data) external payable returns (bytes memory response);
}
// SPDX-License-Identifier: MIT
pragma solidity >=0.8.4;

/// @title IPRBProxyPlugin
/// @notice Interface for plugin contracts that can be installed on a proxy.
/// @dev Plugins are contracts that enable the proxy to interact with and respond to calls from other contracts. These
/// plugins are run via the proxy's fallback function.
///
/// This interface is meant to be directly inherited by plugin implementations.
interface IPRBProxyPlugin {
    /// @notice Retrieves the methods implemented by the plugin.
    /// @dev The registry pulls these methods when installing the plugin.
    ///
    /// Requirements:
    /// - The plugin must implement at least one method.
    ///
    /// @return methods The array of the methods implemented by the plugin.
    function getMethods() external returns (bytes4[] memory methods);
}
// SPDX-License-Identifier: MIT
pragma solidity >=0.8.4;

import { IPRBProxy } from "./IPRBProxy.sol";
import { IPRBProxyPlugin } from "./IPRBProxyPlugin.sol";

/// @title IPRBProxyRegistry
/// @notice Deploys new proxies via CREATE2 and keeps a registry of owners to proxies. Proxies can only be deployed
/// once per owner, and they cannot be transferred. The registry also supports installing plugins, which are used
/// for extending the functionality of the proxy.
interface IPRBProxyRegistry {
    /*//////////////////////////////////////////////////////////////////////////
                                       ERRORS
    //////////////////////////////////////////////////////////////////////////*/

    /// @notice Thrown when an action requires the caller to have a proxy.
    error PRBProxyRegistry_CallerDoesNotHaveProxy(address caller);

    /// @notice Thrown when an action requires the owner to not have a proxy.
    error PRBProxyRegistry_OwnerHasProxy(address owner, IPRBProxy proxy);

    /// @notice Thrown when trying to install a plugin that implements a method already implemented by another
    /// installed plugin.
    error PRBProxyRegistry_PluginMethodCollision(
        IPRBProxyPlugin currentPlugin, IPRBProxyPlugin newPlugin, bytes4 method
    );

    /// @notice Thrown when trying to uninstall an unknown plugin.
    error PRBProxyRegistry_PluginUnknown(IPRBProxyPlugin plugin);

    /// @notice Thrown when trying to install a plugin that doesn't implement any method.
    error PRBProxyRegistry_PluginWithZeroMethods(IPRBProxyPlugin plugin);

    /*//////////////////////////////////////////////////////////////////////////
                                       EVENTS
    //////////////////////////////////////////////////////////////////////////*/

    /// @notice Emitted when a new proxy is deployed.
    event DeployProxy(address indexed operator, address indexed owner, IPRBProxy proxy);

    /// @notice Emitted when a plugin is installed.
    event InstallPlugin(
        address indexed owner, IPRBProxy indexed proxy, IPRBProxyPlugin indexed plugin, bytes4[] methods
    );

    /// @notice Emitted when an envoy's permission is updated.
    event SetPermission(
        address indexed owner, IPRBProxy indexed proxy, address indexed envoy, address target, bool newPermission
    );

    /// @notice Emitted when a plugin is uninstalled.
    event UninstallPlugin(
        address indexed owner, IPRBProxy indexed proxy, IPRBProxyPlugin indexed plugin, bytes4[] methods
    );

    /*//////////////////////////////////////////////////////////////////////////
                                      STRUCTS
    //////////////////////////////////////////////////////////////////////////*/

    /// @param owner The address of the user who will own the proxy.
    /// @param target The address of the target to delegate call to. Can be set to zero.
    /// @param data The call data to be passed to the target. Can be set to zero.
    struct ConstructorParams {
        address owner;
        address target;
        bytes data;
    }

    /*//////////////////////////////////////////////////////////////////////////
                                 CONSTANT FUNCTIONS
    //////////////////////////////////////////////////////////////////////////*/

    /// @notice The release version of the proxy system, which applies to both the registry and deployed proxies.
    /// @dev This is stored in the registry rather than the proxy to save gas for end users.
    function VERSION() external view returns (string memory);

    /// @notice The parameters used in constructing the proxy, which the registry sets transiently during proxy
    /// deployment.
    /// @dev The proxy constructor fetches these parameters.
    function constructorParams() external view returns (address owner, address target, bytes memory data);

    /// @notice Retrieves the list of installed methods for the provided plugin.
    /// @dev An empty array is returned if the plugin is unknown.
    /// @param owner The proxy owner for the query.
    /// @param plugin The plugin for the query.
    function getMethodsByOwner(address owner, IPRBProxyPlugin plugin) external view returns (bytes4[] memory methods);

    /// @notice Retrieves the list of installed methods for the provided plugin.
    /// @dev An empty array is returned if the plugin is unknown.
    /// @param proxy The proxy for the query.
    /// @param plugin The plugin for the query.
    function getMethodsByProxy(
        IPRBProxy proxy,
        IPRBProxyPlugin plugin
    )
        external
        view
        returns (bytes4[] memory methods);

    /// @notice Retrieves a boolean flag that indicates whether the provided envoy has permission to call the provided
    /// target.
    /// @param owner The proxy owner for the query.
    /// @param envoy The address checked for permission to call the target.
    /// @param target The address of the target.
    function getPermissionByOwner(
        address owner,
        address envoy,
        address target
    )
        external
        view
        returns (bool permission);

    /// @notice Retrieves a boolean flag that indicates whether the provided envoy has permission to call the provided
    /// target.
    /// @param proxy The proxy for the query.
    /// @param envoy The address checked for permission to call the target.
    /// @param target The address of the target.
    function getPermissionByProxy(
        IPRBProxy proxy,
        address envoy,
        address target
    )
        external
        view
        returns (bool permission);

    /// @notice Retrieves the address of the plugin installed for the provided method selector.
    /// @dev The zero address is returned if no plugin is installed.
    /// @param owner The proxy owner for the query.
    /// @param method The method selector for the query.
    function getPluginByOwner(address owner, bytes4 method) external view returns (IPRBProxyPlugin plugin);

    /// @notice Retrieves the address of the plugin installed for the provided method selector.
    /// @dev The zero address is returned if no plugin is installed.
    /// @param proxy The proxy for the query.
    /// @param method The method selector for the query.
    function getPluginByProxy(IPRBProxy proxy, bytes4 method) external view returns (IPRBProxyPlugin plugin);

    /// @notice Retrieves the proxy for the provided owner.
    /// @param owner The user address for the query.
    function getProxy(address owner) external view returns (IPRBProxy proxy);

    /*//////////////////////////////////////////////////////////////////////////
                               NON-CONSTANT FUNCTIONS
    //////////////////////////////////////////////////////////////////////////*/

    /// @notice Deploys a new proxy for the caller.
    ///
    /// @dev Emits a {DeployProxy} event.
    ///
    /// Requirements:
    /// - The caller must not have a proxy.
    ///
    /// @return proxy The address of the newly deployed proxy.
    function deploy() external returns (IPRBProxy proxy);

    /// @notice This function performs two actions:
    /// 1. Deploys a new proxy for the caller
    /// 2. Delegate calls to the provided target, returning the data it gets back, and bubbling up any potential revert.
    ///
    /// @dev Emits a {DeployProxy} and an {Execute} event.
    ///
    /// Requirements:
    /// - The caller must not have a proxy.
    /// - `target` must be a contract.
    ///
    /// @param target The address of the target.
    /// @param data Function selector plus ABI encoded data.
    /// @return proxy The address of the newly deployed proxy.
    function deployAndExecute(address target, bytes calldata data) external returns (IPRBProxy proxy);

    /// @notice This function performs three actions:
    /// 1. Deploys a new proxy for the caller
    /// 2. Delegate calls to the provided target, returning the data it gets back, and bubbling up any potential revert.
    /// 3. Installs the provided plugin on the newly deployed proxy.
    ///
    /// @dev Emits a {DeployProxy} and an {InstallPlugin} event.
    ///
    /// Requirements:
    /// - The caller must not have a proxy.
    /// - See the requirements in `installPlugin`.
    /// - See the requirements in `execute`.
    ///
    /// @param plugin The address of the plugin to install.
    /// @return proxy The address of the newly deployed proxy.
    function deployAndExecuteAndInstallPlugin(
        address target,
        bytes calldata data,
        IPRBProxyPlugin plugin
    )
        external
        returns (IPRBProxy proxy);

    /// @notice This function performs two actions:
    /// 1. Deploys a new proxy for the caller.
    /// 2. Installs the provided plugin on the newly deployed proxy.
    ///
    /// @dev Emits a {DeployProxy} and an {InstallPlugin} event.
    ///
    /// Requirements:
    /// - The caller must not have a proxy.
    /// - See the requirements in `installPlugin`.
    ///
    /// @param plugin The address of the plugin to install.
    /// @return proxy The address of the newly deployed proxy.
    function deployAndInstallPlugin(IPRBProxyPlugin plugin) external returns (IPRBProxy proxy);

    /// @notice Deploys a new proxy for the provided owner.
    ///
    /// @dev Emits a {DeployProxy} event.
    ///
    /// Requirements:
    /// - The owner must not have a proxy.
    ///
    /// @param owner The owner of the proxy.
    /// @return proxy The address of the newly deployed proxy.
    function deployFor(address owner) external returns (IPRBProxy proxy);

    /// @notice Installs the provided plugin on the caller's proxy, and saves the list of methods implemented by the
    /// plugin so that they can be referenced later.
    ///
    /// @dev Emits an {InstallPlugin} event.
    ///
    /// Notes:
    /// - Installing a plugin is a potentially dangerous operation, because anyone can run the plugin.
    /// - Plugin methods that have the same selectors as {IPRBProxy.execute}, {IPRBProxy.owner}, and
    /// {IPRBProxy.registry} can be installed, but they can never be run.
    ///
    /// Requirements:
    /// - The caller must have a proxy.
    /// - The plugin must have at least one implemented method.
    /// - There must be no method collision with any other plugin installed by the caller.
    ///
    /// @param plugin The address of the plugin to install.
    function installPlugin(IPRBProxyPlugin plugin) external;

    /// @notice Gives or takes a permission from an envoy to call the provided target and function selector
    /// on behalf of the caller's proxy.
    ///
    /// @dev Emits a {SetPermission} event.
    ///
    /// Notes:
    /// - It is not an error to set the same permission.
    ///
    /// Requirements:
    /// - The caller must have a proxy.
    ///
    /// @param envoy The address of the account the caller is giving or taking permission from.
    /// @param target The address of the target.
    /// @param permission The boolean permission to set.
    function setPermission(address envoy, address target, bool permission) external;

    /// @notice Uninstalls the plugin from the caller's proxy, and removes the list of methods originally implemented by
    /// the plugin.
    ///
    /// @dev Emits an {UninstallPlugin} event.
    ///
    /// Requirements:
    /// - The caller must have a proxy.
    /// - The plugin must be a known, previously installed plugin.
    ///
    /// @param plugin The address of the plugin to uninstall.
    function uninstallPlugin(IPRBProxyPlugin plugin) external;
}
