// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

contract BangerTreasury0073 {
	address private _treasurerAddress;

	event Received(address, uint);
	event Transfered(address indexed to, uint256 amount);

	constructor(address _address) {
		_treasurerAddress = _address;
	}

	modifier onlyTreasurer() {
		require(treasurer() == msg.sender, "Treasury: caller is not the treasurer");
		_;
	}

	function treasurer() public view virtual returns (address) {
		return _treasurerAddress;
	}

	receive() external payable {
		emit Received(msg.sender, msg.value);
	}

	function transfer(uint256 amount, address to) external onlyTreasurer {
		uint256 balance = address(this).balance;
		require(balance > 0, "No funds to transfer");
		require(balance >= amount, "Not enough funds to transfer");

		payable(to).transfer(amount);
		emit Transfered(to, amount);
	}
}
