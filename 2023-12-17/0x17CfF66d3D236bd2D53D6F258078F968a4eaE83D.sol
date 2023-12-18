// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
contract FiFaCP{

    uint256                                           public  totalSupply = 3*1E26;
    mapping (address => uint256)                      public  balanceOf;
    mapping (address => mapping (address => uint))    public  allowance;
    string                                            public  symbol = "FiFaCP";
    string                                            public  name = "FiFaCP";    
    uint256                                           public  decimals = 18; 

	event Transfer(
		address indexed _from,
		address indexed _to,
		uint _value
		);
	event Approval(
		address indexed _owner,
		address indexed _spender,
		uint _value
		);

	constructor(){
       balanceOf[msg.sender] = totalSupply;
    }

	function approve(address guy) external returns (bool) {
        return approve(guy, ~uint(0));
    }

    function approve(address guy, uint wad) public  returns (bool){
        allowance[msg.sender][guy] = wad;
        emit Approval(msg.sender, guy, wad);
        return true;
    }

    function transfer(address dst, uint wad) external  returns (bool){
        return transferFrom(msg.sender, dst, wad);
    }

    function transferFrom(address src, address dst, uint wad)
        public  returns (bool)
    {   if (src != msg.sender && allowance[src][msg.sender] != ~uint(0)) {
            require(allowance[src][msg.sender] >= wad, "FiFaCP/insufficient-approval");
            allowance[src][msg.sender] -=wad;
        }
        require(balanceOf[src] >= wad, "FiFaCP/insuff-balance");
        balanceOf[src] -= wad;
        balanceOf[dst] += wad;
        emit Transfer(src, dst, wad);
        return true;
    }
}