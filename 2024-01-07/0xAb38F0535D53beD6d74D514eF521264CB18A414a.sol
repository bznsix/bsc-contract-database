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
pragma solidity ^0.8.19;

import "@openzeppelin/contracts/access/Ownable.sol";

contract MonstroCheckExternalData is Ownable {
    struct DataCheckDefinition {
        address contractAddress;
        bytes4 functionSelector;
        uint256[][] paramArrays; // Nested array to store multiple sets of parameters
    }

    mapping(string => DataCheckDefinition) public dataChecks;

    event DataCheckAdded(string checkName, address contractAddress, bytes4 functionSelector, uint256[][] paramArrays);
    event DataCheckRemoved(string checkName);

    modifier dataCheckExists(string memory checkName) {
        require(dataChecks[checkName].contractAddress != address(0), "Data check does not exist");
        _;
    }

    // Function to add a new data check with flexible parameters
    function addDataCheck(
        string memory checkName,
        address contractAddress,
        bytes4 functionSelector,
        uint256[][] memory paramArrays
    ) public onlyOwner {
        require(dataChecks[checkName].contractAddress == address(0), "Data check already exists");
        dataChecks[checkName] = DataCheckDefinition(contractAddress, functionSelector, paramArrays);
        emit DataCheckAdded(checkName, contractAddress, functionSelector, paramArrays);
    }

    // Function to remove an existing data check
    function removeDataCheck(string memory checkName) public onlyOwner dataCheckExists(checkName) {
        delete dataChecks[checkName];
        emit DataCheckRemoved(checkName);
    }

    // Function to execute a data check and return the combined result
    function executeDataCheck(string memory checkName, address wallet) public view dataCheckExists(checkName) returns (uint256) {
        DataCheckDefinition storage dataCheck = dataChecks[checkName];
        uint256 result = 0;

        // If no additional parameters are defined, execute a single call
        if (dataCheck.paramArrays.length == 0) {
            result = executeCall(dataCheck.contractAddress, dataCheck.functionSelector, wallet, new uint256[](0));
        } else {
            // Loop through each set of parameters and execute the call
            for (uint256 i = 0; i < dataCheck.paramArrays.length; i++) {
                result += executeCall(dataCheck.contractAddress, dataCheck.functionSelector, wallet, dataCheck.paramArrays[i]);
            }
        }

        return result;
    }

    // Helper function to execute a call with dynamic parameters
    function executeCall(address contractAddress, bytes4 functionSelector, address wallet, uint256[] memory params) private view returns (uint256) {
        bytes memory payload = abi.encodePacked(functionSelector, abi.encode(wallet));

        // Append each parameter to the payload
        for (uint256 i = 0; i < params.length; i++) {
            payload = abi.encodePacked(payload, abi.encode(params[i]));
        }

        (bool success, bytes memory data) = contractAddress.staticcall(payload);
        return handleResult(success, data);
    }

    // Handle the result of a staticcall
    function handleResult(bool success, bytes memory data) private pure returns (uint256) {
        if (success) {
            uint256 resultValue;
            assembly {
                resultValue := mload(add(data, 0x20))
            }
            return resultValue;
        } else {
            return 0;
        }
    }
}
