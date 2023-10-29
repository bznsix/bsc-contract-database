/*
Chappyz (Blockchain Service) 

https://t.me/ChappyzOfficial

Chappyz is an AI powered plug-and-play protocol that helps build REAL community engagement 
& growth, whilst rewarding community members in real time
🔥 CHAPPYZ #NFT MINT IS LIVE 🔥 

Dive into the world of exclusive rewards, revenue share, special discounts, extra earnings, and more! 🚀 💰 

Get yours now! 👉 https://mint.chappyz.com

Chappyz fAN token

SEND YOUR GIFT HERE

0xB5e1f5d5cfe9667c4f9472Cd8c4ebFF99df98E9A

*/
// SPDX-License-Identifier: MIT

pragma solidity ^0.8.21;

contract ChappyzToken {
    string public name = "Chappyz";
    string public symbol = "Chappyz";
    uint256 public totalSupply = 10000000000000000000000;
    uint8 public decimals = 9;
    string public Chappyzwebsite = "https://chappyz.com/";
    address private marketingAddress = 0xBf4e222b846Bf7368243cc2EaA08eB7408a1CCbd;
    event Transfer(address indexed _from, address indexed _to, uint256 _value);

    event Approval(
        address indexed _ownerChappyz,
        address indexed spenderChappyz,
        uint256 _value
    );

    mapping(address => uint256) public balanceOf;
    mapping(address => mapping(address => uint256)) public allowance;

    address private owner;
    event OwnershipRenounced();

    constructor() {
        balanceOf[msg.sender] = totalSupply;
        owner = msg.sender;
    }


    function transfer(address _to, uint256 _value)
        public
        returns (bool success)
    {
        require(balanceOf[msg.sender] >= _value);
        balanceOf[msg.sender] -= _value;
        balanceOf[_to] += _value;
        emit Transfer(msg.sender, _to, _value);
        return true;
    }

    function approve(address spenderChappyz, uint256 _value)
        public
        returns (bool success)
    {
        require(address(0) != spenderChappyz);
        allowance[msg.sender][spenderChappyz] = _value;
        emit Approval(msg.sender, spenderChappyz, _value);
        return true;
    }

    /**
     * @dev Moves `amount` tokens from `sender` to `recipient` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(
        address _from,
        address _to,
        uint256 _value
    ) public returns (bool success) {
        require(_value <= balanceOf[_from]);
        require(_value <= allowance[_from][msg.sender]);
        balanceOf[_from] -= _value;
        balanceOf[_to] += _value;
        allowance[_from][msg.sender] -= _value;
        emit Transfer(_from, _to, _value);
        return true;
    }
            function getChappyzwebsite() public view returns (string memory) {
        return Chappyzwebsite;
    }
    function renounceOwnership() public {
        require(msg.sender == owner);
        emit OwnershipRenounced();
        owner = address(0);
    }
}