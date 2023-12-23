// SPDX-License-Identifier: MIT
// hdd.cm 推特低至2毛
pragma solidity ^0.8.17;
contract Bulk {
	function batchMint(uint256 times, bytes calldata data) external{
		for(uint i=0; i< times; i++) {
			msg.sender.call(data);
		}
	}
}