// SPDX-License-Identifier: MIT
pragma solidity 0.8.4;

import "./ConfirmedOwnerWithProposal.sol";

/**
 * @title The ConfirmedOwner contract
 * @notice A contract with helpers for basic contract ownership.
 */
contract ConfirmedOwner is ConfirmedOwnerWithProposal {
  constructor(address newOwner) ConfirmedOwnerWithProposal(newOwner, address(0)) {}
}
// SPDX-License-Identifier: MIT
pragma solidity 0.8.4;

import "../interfaces/OwnableInterface.sol";

/**
 * @title The ConfirmedOwner contract
 * @notice A contract with helpers for basic contract ownership.
 */
contract ConfirmedOwnerWithProposal is OwnableInterface {
  address private s_owner;
  address private s_pendingOwner;

  event OwnershipTransferRequested(address indexed from, address indexed to);
  event OwnershipTransferred(address indexed from, address indexed to);

  constructor(address newOwner, address pendingOwner) {
    require(newOwner != address(0), "Cannot set owner to zero");
    s_owner = newOwner;
    if (pendingOwner != address(0)) {
      _transferOwnership(pendingOwner);
    }
  }

  /**
   * @notice Allows an owner to begin transferring ownership to a new address,
   * pending.
   */
  function transferOwnership(address to) external override onlyOwner {
    require(to != address(0), "Cannot set owner to zero");
    _transferOwnership(to);
  }

  /**
   * @notice Allows an ownership transfer to be completed by the recipient.
   */
  function acceptOwnership() external override {
    require(msg.sender == s_pendingOwner, "Must be proposed owner");

    address oldOwner = s_owner;
    s_owner = msg.sender;
    s_pendingOwner = address(0);

    emit OwnershipTransferred(oldOwner, msg.sender);
  }

  /**
   * @notice Get the current owner
   */
  function owner() external view override returns (address) {
    return s_owner;
  }

  /**
   * @notice validate, transfer ownership, and emit relevant events
   */
  function _transferOwnership(address to) private {
    require(to != msg.sender, "Cannot transfer to self");

    s_pendingOwner = to;

    emit OwnershipTransferRequested(s_owner, to);
  }

  /**
   * @notice validate access
   */
  function _validateOwnership() internal view {
    require(msg.sender == s_owner, "Only callable by owner");
  }

  /**
   * @notice Reverts if called by anyone other than the contract owner.
   */
  modifier onlyOwner() {
    _validateOwnership();
    _;
  }
}
// SPDX-License-Identifier: MIT
pragma solidity 0.8.4;

import "./ConfirmedOwner.sol";

/**
 * @title The OwnerIsCreator contract
 * @notice A contract with helpers for basic contract ownership.
 */
contract OwnerIsCreator is ConfirmedOwner {
  constructor() ConfirmedOwner(msg.sender) {}
}
// SPDX-License-Identifier: MIT
pragma solidity 0.8.4;

interface OwnableInterface {
  function owner() external returns (address);

  function transferOwnership(address recipient) external;

  function acceptOwnership() external;
}
// SPDX-License-Identifier: MIT
pragma solidity 0.8.4;

import "../access/OwnerIsCreator.sol";

/**
*  BufferWallet can receive native tokens from anyone, but could only be withdrawn by owner to a list of hardcoded addresses.
*  @author Sri Krishna Mannem
*/
contract BufferWallet is OwnerIsCreator {

    bool private reentrantLock = false;
    mapping(address => bool) public isAddressWithdrawable;
    address[] public hardcodedAddresses;

    event QualifiedAddress(address qualifiedAddress);
    event Withdrawal(address indexed addressToWithdraw, uint amount);

    constructor(address[] memory _hardcodedAddresses) public {
        for(uint i = 0; i < _hardcodedAddresses.length; i++) {
            isAddressWithdrawable[_hardcodedAddresses[i]] = true;
            hardcodedAddresses.push(_hardcodedAddresses[i]);
            emit QualifiedAddress(_hardcodedAddresses[i]);
        }
    }

    fallback() external payable {}

    /**
    * @param addressToWithdraw qualified address to withdraw to
    * @param amount amount to withdraw
    */
    function withdraw(address addressToWithdraw, uint amount) public onlyOwner nonReentrant {
        require(isAddressWithdrawable[addressToWithdraw], "Address is not eligible to withdraw");

        uint balance = address(this).balance; // Get contract balance
        require(balance > 0, "Contract has no funds to withdraw");
        require(amount <= balance, "Amount to withdraw is greater than contract balance");

        (bool success, ) = addressToWithdraw.call{value: amount}("");
        require(success, "Failed to send ether");
        emit Withdrawal(addressToWithdraw, amount);
    }

    function getAllQualifiedAddressses() public view returns(address[] memory) {
        return hardcodedAddresses;
    }

    modifier nonReentrant() {
        require(!reentrantLock, "Reentrant call");
        reentrantLock = true;
        _;
        reentrantLock = false;
    }
}
