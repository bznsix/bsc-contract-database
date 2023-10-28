{"Address.sol":{"content":"// SPDX-License-Identifier: MIT\r\n\r\npragma solidity \u003e=0.6.2 \u003c0.8.0;\r\n\r\n/**\r\n * @dev Collection of functions related to the address type\r\n */\r\nlibrary Address {\r\n    /**\r\n     * @dev Returns true if `account` is a contract.\r\n     *\r\n     * [IMPORTANT]\r\n     * ====\r\n     * It is unsafe to assume that an address for which this function returns\r\n     * false is an externally-owned account (EOA) and not a contract.\r\n     *\r\n     * Among others, `isContract` will return false for the following\r\n     * types of addresses:\r\n     *\r\n     *  - an externally-owned account\r\n     *  - a contract in construction\r\n     *  - an address where a contract will be created\r\n     *  - an address where a contract lived, but was destroyed\r\n     * ====\r\n     */\r\n    function isContract(address account) internal view returns (bool) {\r\n        // This method relies on extcodesize, which returns 0 for contracts in\r\n        // construction, since the code is only stored at the end of the\r\n        // constructor execution.\r\n\r\n        uint256 size;\r\n        // solhint-disable-next-line no-inline-assembly\r\n        assembly { size := extcodesize(account) }\r\n        return size \u003e 0;\r\n    }\r\n\r\n    /**\r\n     * @dev Replacement for Solidity\u0027s `transfer`: sends `amount` wei to\r\n     * `recipient`, forwarding all available gas and reverting on errors.\r\n     *\r\n     * https://eips.ethereum.org/EIPS/eip-1884[EIP1884] increases the gas cost\r\n     * of certain opcodes, possibly making contracts go over the 2300 gas limit\r\n     * imposed by `transfer`, making them unable to receive funds via\r\n     * `transfer`. {sendValue} removes this limitation.\r\n     *\r\n     * https://diligence.consensys.net/posts/2019/09/stop-using-soliditys-transfer-now/[Learn more].\r\n     *\r\n     * IMPORTANT: because control is transferred to `recipient`, care must be\r\n     * taken to not create reentrancy vulnerabilities. Consider using\r\n     * {ReentrancyGuard} or the\r\n     * https://solidity.readthedocs.io/en/v0.5.11/security-considerations.html#use-the-checks-effects-interactions-pattern[checks-effects-interactions pattern].\r\n     */\r\n    function sendValue(address payable recipient, uint256 amount) internal {\r\n        require(address(this).balance \u003e= amount, \"Address: insufficient balance\");\r\n\r\n        // solhint-disable-next-line avoid-low-level-calls, avoid-call-value\r\n        (bool success, ) = recipient.call{ value: amount }(\"\");\r\n        require(success, \"Address: unable to send value, recipient may have reverted\");\r\n    }\r\n\r\n    /**\r\n     * @dev Performs a Solidity function call using a low level `call`. A\r\n     * plain`call` is an unsafe replacement for a function call: use this\r\n     * function instead.\r\n     *\r\n     * If `target` reverts with a revert reason, it is bubbled up by this\r\n     * function (like regular Solidity function calls).\r\n     *\r\n     * Returns the raw returned data. To convert to the expected return value,\r\n     * use https://solidity.readthedocs.io/en/latest/units-and-global-variables.html?highlight=abi.decode#abi-encoding-and-decoding-functions[`abi.decode`].\r\n     *\r\n     * Requirements:\r\n     *\r\n     * - `target` must be a contract.\r\n     * - calling `target` with `data` must not revert.\r\n     *\r\n     * _Available since v3.1._\r\n     */\r\n    function functionCall(address target, bytes memory data) internal returns (bytes memory) {\r\n      return functionCall(target, data, \"Address: low-level call failed\");\r\n    }\r\n\r\n    /**\r\n     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`], but with\r\n     * `errorMessage` as a fallback revert reason when `target` reverts.\r\n     *\r\n     * _Available since v3.1._\r\n     */\r\n    function functionCall(address target, bytes memory data, string memory errorMessage) internal returns (bytes memory) {\r\n        return functionCallWithValue(target, data, 0, errorMessage);\r\n    }\r\n\r\n    /**\r\n     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],\r\n     * but also transferring `value` wei to `target`.\r\n     *\r\n     * Requirements:\r\n     *\r\n     * - the calling contract must have an ETH balance of at least `value`.\r\n     * - the called Solidity function must be `payable`.\r\n     *\r\n     * _Available since v3.1._\r\n     */\r\n    function functionCallWithValue(address target, bytes memory data, uint256 value) internal returns (bytes memory) {\r\n        return functionCallWithValue(target, data, value, \"Address: low-level call with value failed\");\r\n    }\r\n\r\n    /**\r\n     * @dev Same as {xref-Address-functionCallWithValue-address-bytes-uint256-}[`functionCallWithValue`], but\r\n     * with `errorMessage` as a fallback revert reason when `target` reverts.\r\n     *\r\n     * _Available since v3.1._\r\n     */\r\n    function functionCallWithValue(address target, bytes memory data, uint256 value, string memory errorMessage) internal returns (bytes memory) {\r\n        require(address(this).balance \u003e= value, \"Address: insufficient balance for call\");\r\n        require(isContract(target), \"Address: call to non-contract\");\r\n\r\n        // solhint-disable-next-line avoid-low-level-calls\r\n        (bool success, bytes memory returndata) = target.call{ value: value }(data);\r\n        return _verifyCallResult(success, returndata, errorMessage);\r\n    }\r\n\r\n    /**\r\n     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],\r\n     * but performing a static call.\r\n     *\r\n     * _Available since v3.3._\r\n     */\r\n    function functionStaticCall(address target, bytes memory data) internal view returns (bytes memory) {\r\n        return functionStaticCall(target, data, \"Address: low-level static call failed\");\r\n    }\r\n\r\n    /**\r\n     * @dev Same as {xref-Address-functionCall-address-bytes-string-}[`functionCall`],\r\n     * but performing a static call.\r\n     *\r\n     * _Available since v3.3._\r\n     */\r\n    function functionStaticCall(address target, bytes memory data, string memory errorMessage) internal view returns (bytes memory) {\r\n        require(isContract(target), \"Address: static call to non-contract\");\r\n\r\n        // solhint-disable-next-line avoid-low-level-calls\r\n        (bool success, bytes memory returndata) = target.staticcall(data);\r\n        return _verifyCallResult(success, returndata, errorMessage);\r\n    }\r\n\r\n    /**\r\n     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],\r\n     * but performing a delegate call.\r\n     *\r\n     * _Available since v3.4._\r\n     */\r\n    function functionDelegateCall(address target, bytes memory data) internal returns (bytes memory) {\r\n        return functionDelegateCall(target, data, \"Address: low-level delegate call failed\");\r\n    }\r\n\r\n    /**\r\n     * @dev Same as {xref-Address-functionCall-address-bytes-string-}[`functionCall`],\r\n     * but performing a delegate call.\r\n     *\r\n     * _Available since v3.4._\r\n     */\r\n    function functionDelegateCall(address target, bytes memory data, string memory errorMessage) internal returns (bytes memory) {\r\n        require(isContract(target), \"Address: delegate call to non-contract\");\r\n\r\n        // solhint-disable-next-line avoid-low-level-calls\r\n        (bool success, bytes memory returndata) = target.delegatecall(data);\r\n        return _verifyCallResult(success, returndata, errorMessage);\r\n    }\r\n\r\n    function _verifyCallResult(bool success, bytes memory returndata, string memory errorMessage) private pure returns(bytes memory) {\r\n        if (success) {\r\n            return returndata;\r\n        } else {\r\n            // Look for revert reason and bubble it up if present\r\n            if (returndata.length \u003e 0) {\r\n                // The easiest way to bubble the revert reason is using memory via assembly\r\n\r\n                // solhint-disable-next-line no-inline-assembly\r\n                assembly {\r\n                    let returndata_size := mload(returndata)\r\n                    revert(add(32, returndata), returndata_size)\r\n                }\r\n            } else {\r\n                revert(errorMessage);\r\n            }\r\n        }\r\n    }\r\n}"},"BeaconProxy.sol":{"content":"// SPDX-License-Identifier: MIT\r\n\r\npragma solidity \u003e=0.6.0 \u003c0.8.0;\r\n\r\nimport \"./Proxy.sol\";\r\nimport \"./Address.sol\";\r\nimport \"./IBeacon.sol\";\r\n\r\n/**\r\n * @dev This contract implements a proxy that gets the implementation address for each call from a {UpgradeableBeacon}.\r\n *\r\n * The beacon address is stored in storage slot `uint256(keccak256(\u0027eip1967.proxy.beacon\u0027)) - 1`, so that it doesn\u0027t\r\n * conflict with the storage layout of the implementation behind the proxy.\r\n *\r\n * _Available since v3.4._\r\n */\r\ncontract BeaconProxy is Proxy {\r\n    /**\r\n     * @dev The storage slot of the UpgradeableBeacon contract which defines the implementation for this proxy.\r\n     * This is bytes32(uint256(keccak256(\u0027eip1967.proxy.beacon\u0027)) - 1)) and is validated in the constructor.\r\n     */\r\n    bytes32 private constant _BEACON_SLOT = 0xa3f0ad74e5423aebfd80d3ef4346578335a9a72aeaee59ff6cb3582b35133d50;\r\n\r\n    /**\r\n     * @dev Initializes the proxy with `beacon`.\r\n     *\r\n     * If `data` is nonempty, it\u0027s used as data in a delegate call to the implementation returned by the beacon. This\r\n     * will typically be an encoded function call, and allows initializating the storage of the proxy like a Solidity\r\n     * constructor.\r\n     *\r\n     * Requirements:\r\n     *\r\n     * - `beacon` must be a contract with the interface {IBeacon}.\r\n     */\r\n    constructor(address beacon, bytes memory data) public payable {\r\n        assert(_BEACON_SLOT == bytes32(uint256(keccak256(\"eip1967.proxy.beacon\")) - 1));\r\n        _setBeacon(beacon, data);\r\n    }\r\n\r\n    /**\r\n     * @dev Returns the current beacon address.\r\n     */\r\n    function _beacon() internal view virtual returns (address beacon) {\r\n        bytes32 slot = _BEACON_SLOT;\r\n        // solhint-disable-next-line no-inline-assembly\r\n        assembly {\r\n            beacon := sload(slot)\r\n        }\r\n    }\r\n\r\n    /**\r\n     * @dev Returns the current implementation address of the associated beacon.\r\n     */\r\n    function _implementation() internal view virtual override returns (address) {\r\n        return IBeacon(_beacon()).implementation();\r\n    }\r\n\r\n    /**\r\n     * @dev Changes the proxy to use a new beacon.\r\n     *\r\n     * If `data` is nonempty, it\u0027s used as data in a delegate call to the implementation returned by the beacon.\r\n     *\r\n     * Requirements:\r\n     *\r\n     * - `beacon` must be a contract.\r\n     * - The implementation returned by `beacon` must be a contract.\r\n     */\r\n    function _setBeacon(address beacon, bytes memory data) internal virtual {\r\n        require(\r\n            Address.isContract(beacon),\r\n            \"BeaconProxy: beacon is not a contract\"\r\n        );\r\n        require(\r\n            Address.isContract(IBeacon(beacon).implementation()),\r\n            \"BeaconProxy: beacon implementation is not a contract\"\r\n        );\r\n        bytes32 slot = _BEACON_SLOT;\r\n\r\n        // solhint-disable-next-line no-inline-assembly\r\n        assembly {\r\n            sstore(slot, beacon)\r\n        }\r\n\r\n        if (data.length \u003e 0) {\r\n            Address.functionDelegateCall(_implementation(), data, \"BeaconProxy: function call failed\");\r\n        }\r\n    }\r\n}"},"IBeacon.sol":{"content":"// SPDX-License-Identifier: MIT\r\n\r\npragma solidity \u003e=0.6.0 \u003c0.8.0;\r\n\r\n/**\r\n * @dev This is the interface that {BeaconProxy} expects of its beacon.\r\n */\r\ninterface IBeacon {\r\n    /**\r\n     * @dev Must return an address that can be used as a delegate call target.\r\n     *\r\n     * {BeaconProxy} will check that this address is a contract.\r\n     */\r\n    function implementation() external view returns (address);\r\n}"},"Proxy.sol":{"content":"// SPDX-License-Identifier: MIT\r\n\r\npragma solidity \u003e=0.6.0 \u003c0.8.0;\r\n\r\n/**\r\n * @dev This abstract contract provides a fallback function that delegates all calls to another contract using the EVM\r\n * instruction `delegatecall`. We refer to the second contract as the _implementation_ behind the proxy, and it has to\r\n * be specified by overriding the virtual {_implementation} function.\r\n *\r\n * Additionally, delegation to the implementation can be triggered manually through the {_fallback} function, or to a\r\n * different contract through the {_delegate} function.\r\n *\r\n * The success and return data of the delegated call will be returned back to the caller of the proxy.\r\n */\r\nabstract contract Proxy {\r\n    /**\r\n     * @dev Delegates the current call to `implementation`.\r\n     *\r\n     * This function does not return to its internall call site, it will return directly to the external caller.\r\n     */\r\n    function _delegate(address implementation) internal virtual {\r\n        // solhint-disable-next-line no-inline-assembly\r\n        assembly {\r\n            // Copy msg.data. We take full control of memory in this inline assembly\r\n            // block because it will not return to Solidity code. We overwrite the\r\n            // Solidity scratch pad at memory position 0.\r\n            calldatacopy(0, 0, calldatasize())\r\n\r\n            // Call the implementation.\r\n            // out and outsize are 0 because we don\u0027t know the size yet.\r\n            let result := delegatecall(gas(), implementation, 0, calldatasize(), 0, 0)\r\n\r\n            // Copy the returned data.\r\n            returndatacopy(0, 0, returndatasize())\r\n\r\n            switch result\r\n            // delegatecall returns 0 on error.\r\n            case 0 { revert(0, returndatasize()) }\r\n            default { return(0, returndatasize()) }\r\n        }\r\n    }\r\n\r\n    /**\r\n     * @dev This is a virtual function that should be overriden so it returns the address to which the fallback function\r\n     * and {_fallback} should delegate.\r\n     */\r\n    function _implementation() internal view virtual returns (address);\r\n\r\n    /**\r\n     * @dev Delegates the current call to the address returned by `_implementation()`.\r\n     *\r\n     * This function does not return to its internall call site, it will return directly to the external caller.\r\n     */\r\n    function _fallback() internal virtual {\r\n        _beforeFallback();\r\n        _delegate(_implementation());\r\n    }\r\n\r\n    /**\r\n     * @dev Fallback function that delegates calls to the address returned by `_implementation()`. Will run if no other\r\n     * function in the contract matches the call data.\r\n     */\r\n    fallback () external payable virtual {\r\n        _fallback();\r\n    }\r\n\r\n    /**\r\n     * @dev Fallback function that delegates calls to the address returned by `_implementation()`. Will run if call data\r\n     * is empty.\r\n     */\r\n    receive () external payable virtual {\r\n        _fallback();\r\n    }\r\n\r\n    /**\r\n     * @dev Hook that is called before falling back to the implementation. Can happen as part of a manual `_fallback`\r\n     * call, or as part of the Solidity `fallback` or `receive` functions.\r\n     *\r\n     * If overriden should call `super._beforeFallback()`.\r\n     */\r\n    function _beforeFallback() internal virtual {\r\n    }\r\n}"}}