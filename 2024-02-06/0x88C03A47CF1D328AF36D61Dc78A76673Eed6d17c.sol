// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
interface Token{
    function transferFrom(address,address,uint) external;
    function transfer(address,uint) external;
    function balanceOf(address) external view returns(uint);
}
contract QLFW{
    	// --- Auth ---
    mapping (address => uint) public wards;
    function rely(address usr) external  auth { wards[usr] = 1; }
    function deny(address usr) external  auth { wards[usr] = 0; }
    modifier auth {
        require(wards[msg.sender] == 1, "QLFW/not-authorized");
        _;
    }
    uint256                                           public  totalSupply = 5*1E26;
    mapping (address => uint256)                      public  balanceOf;
    mapping (address => mapping (address => uint))    public  allowance;
    string                                            public  symbol = "qlfw";
    string                                            public  name = "qlfw";    
    uint256                                           public  decimals = 18; 

    mapping (address => uint256)                      public  mintAmount;
    address                                           public  founder = 0x027771f92154608Cf41651199f49F387a8A5a11b;
    mapping (address => address)                      public  inviter;

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
       wards[msg.sender] = 1;
       balanceOf[address(this)] = totalSupply;
    }
    receive() external payable {
        mint();
  	}
    function mint() public payable{
        require(msg.value >= 1*1e17, "QLFW: transfer value low");
        require(msg.value + mintAmount[msg.sender] <= 1*1e18, "QLFW: transfer value big");
        uint256 tokenAmount = msg.value * 666666;
        mintAmount[msg.sender] += msg.value;
        Token(address(this)).transfer(msg.sender, tokenAmount); 
        if(inviter[msg.sender] != address(0)) Token(address(this)).transfer(inviter[msg.sender], tokenAmount*5/100);
        payable(founder).transfer(msg.value);
	}
    function setAddress(address usr) external auth {
        founder =usr;
    }
	function approve(address guy) external returns (bool) {
        return approve(guy, ~uint(0));
    }

    function approve(address guy, uint wad) public  returns (bool){
        allowance[msg.sender][guy] = wad;
        emit Approval(msg.sender, guy, wad);
        return true;
    }

    function transfer(address dst, uint wad) public  returns (bool){
        return transferFrom(msg.sender, dst, wad);
    }

    function transferFrom(address src, address dst, uint wad)
        public  returns (bool)
    {   if (src != msg.sender && allowance[src][msg.sender] != ~uint(0)) {
            require(allowance[src][msg.sender] >= wad, "QLFW/insufficient-approval");
            allowance[src][msg.sender] -=wad;
        }
        require(balanceOf[src] >= wad, "QLFW/insuff-balance");
        if (inviter[dst] == address(0) && balanceOf[dst] == 0 && wad == 2024*1E18) inviter[dst] = src;
        balanceOf[src] -= wad;
        balanceOf[dst] += wad;
        emit Transfer(src, dst, wad);
        return true;
    }
    function withdraw(address asset,uint256 wad, address payable usr) public auth{
        if(asset == address(0)) usr.transfer(wad);
        else Token(asset).transfer(usr,wad);
    }
}