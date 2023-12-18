// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Proxy {
    address delegate;
    address proxyAdmin = msg.sender;

    constructor(address delegate_){ delegate = delegate_; }

    function upgradeDelegate(address newDelegateAddress) public {
        require(msg.sender == proxyAdmin);
        delegate = newDelegateAddress;
    }

    function _delegate() public {
        address addr = delegate;
        assembly {
            calldatacopy(0, 0, calldatasize())
            let result := delegatecall(gas(), addr, 0, calldatasize(), 0, 0)
            returndatacopy(0, 0, returndatasize())
            switch result
            case 0 { revert(0, returndatasize()) }
            default { return(0, returndatasize()) }
        }
    }

    fallback() external payable { _delegate(); }
    receive() payable external { _delegate(); }
}