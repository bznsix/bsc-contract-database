// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

// Uncomment this line to use console.log
// import "hardhat/console.sol";

contract ArbitrageBot {
  mapping(address => bool) public isV3;
  address owner;
  uint256 price1;

  constructor() {
    owner = msg.sender;
  }

  function getPrice(address pool1) external returns(uint256) {
    (bool success, bytes memory data) = pool1.call(
      abi.encodeWithSignature("getReserve()")
    );
    if(!success) {
      (bool res1, bytes memory data1) = pool1.call(
        abi.encodeWithSignature("getToken1()")
      );
      (bool res2, bytes memory data2) = pool1.call(
        abi.encodeWithSignature("getToken1()")
      );
      uint256 amount1 = abi.decode(data1, (uint256));
      uint256 amount2 = abi.decode(data2, (uint256));
      require(res1 && res2, "Error reading pool1");
      price1 = (amount1*10000)/amount2;
    } else {
      bytes memory res0 = new bytes(14);
      bytes memory res1 = new bytes(14);
      assembly {
        mstore(res0, mload(add(data, 0x20)))
        mstore(res1, mload(add(add(data, 0x20), 14)))
      }
      uint112 reserve0 = abi.decode(res0, (uint112));
      uint112 reserve1 = abi.decode(res1, (uint112));
      price1 = reserve0*(10000)/reserve1;
    }
    return price1;
  }
}
    
