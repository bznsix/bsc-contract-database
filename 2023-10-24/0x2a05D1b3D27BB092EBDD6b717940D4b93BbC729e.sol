pragma solidity ^0.8.0;

// SPDX-License-Identifier: Unlicensed

contract DummyToken {
	string public name = "DummyToken";
	string public symbol = "DUMMY";

	uint8 public decimals;
	uint256 public totalSupply;
	
	mapping(address => uint256) public balances;
	mapping(address => mapping(address => uint256)) public allowances;
	
	event Transfer(address indexed from, address indexed to, uint256 tokens);
	event Approval(address indexed owner, address indexed spender, uint256 tokens);
	
	constructor(address _dummyRecipient, uint256 _dummySupply, uint8 _dummyDecimals) {
		decimals = _dummyDecimals;
		totalSupply = _dummySupply;
		balances[_dummyRecipient] += _dummySupply;
		
		emit Transfer(address(0), _dummyRecipient, _dummySupply);
	}
	
	function _transfer(address from, address to, uint256 tokens) private {
		// solidity 0.8.x checks for underflows/overflows
		balances[from] -= tokens;
		balances[to] += tokens;
		emit Transfer(from, to, tokens);
	}
	
	// Read public functions
	function balanceOf(address dummyHolder) public view returns (uint256) {
		return balances[dummyHolder];
	}
	
	function allowance(address dummyOwner, address dummySpender) public view returns (uint256) {
		return allowances[dummyOwner][dummySpender];
	}
	
	// Write public functions
	function transfer(address to, uint256 tokens) public returns (bool) {
		_transfer(msg.sender, to, tokens);
		return true;
	}
	
	function transferFrom(address from, address to, uint256 tokens) public returns (bool) {
		allowances[from][msg.sender] -= tokens;	// solidity 0.8 checks for overflows
		_transfer(from, to, tokens);
		return true;
	}
	
	function approve(address spender, uint256 tokens) public returns (bool) {
		allowances[msg.sender][spender] = tokens;
		return true;
	}
}