// SPDX-License-Identifier: MIT
pragma solidity ^0.8.3;
contract Proxy {
    bytes32 private constant _IMPLEMENTATION_SLOT = 0x360894a13ba1a3210667c828492db98dca3e2076cc3735a920a3ca505d382bbc;
    bytes32 private constant _ADMIN_SLOT = 0xb53127684a568b3173ae13b9f8a6016e243e63b6e8ee1178d6a717850b5d6103;

    modifier ifAdmin() {
        if (msg.sender == admin()) {
            _;
        } else {
            _delegate();
        }
    }

    constructor() public {
        address admin = msg.sender;
        bytes32 slot = _ADMIN_SLOT;
        assembly {
            sstore(slot, admin)
        }
    }
    function implementation() public view returns (address) {
        return _implementation();
    }

    function _implementation() internal view returns (address impl) {
        bytes32 slot = _IMPLEMENTATION_SLOT;
        assembly {
            impl := sload(slot)
        }
    }

    function setImplementation(address newImplementation) external ifAdmin {
        bytes32 slot = _IMPLEMENTATION_SLOT;
        assembly {
            sstore(slot, newImplementation)
        }
    }
    function admin() public view returns (address) {
        return _admin();
    }

    function _admin() internal view returns (address adm) {
        bytes32 slot = _ADMIN_SLOT;
        assembly {
            adm := sload(slot)
        }
    }
    function changeAdmin(address newAdmin) external ifAdmin {
        bytes32 slot = _ADMIN_SLOT;
        assembly {
            sstore(slot, newAdmin)
        }
    }

    function _delegate() internal {
        address _implementation = _implementation();
        assembly {
            calldatacopy(0, 0, calldatasize())
            let result := delegatecall(gas(), _implementation, 0, calldatasize(), 0, 0)
            returndatacopy(0, 0, returndatasize())

            switch result
            case 0 { revert(0, returndatasize()) }
            default { return(0, returndatasize()) }
        }
    }

    fallback () payable external {
        require(msg.sender != _admin(), "admin cannot fallback to proxy target");
        _delegate();
    }

    receive () payable external {
        require(msg.sender != _admin(), "admin cannot fallback to proxy target");
        _delegate();
    }
}