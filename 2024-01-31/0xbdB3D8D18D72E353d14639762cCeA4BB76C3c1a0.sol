/*

BonksMother
Mother of all Bonks (MOAB)
https://t.me/BonksMother
*/
// SPDX-License-Identifier: MIT

pragma solidity ^0.8.24;

contract BonksMotherToken {
    string public name = "Mother of all Bonks";
    string public symbol = "MOAB";
    uint256 public totalSupply = 10000000000000000000000;
    uint8 public decimals = 9;
    string public BonksMotherwebsite = "https://BonksMother.io/";
    string public BonksMotherTG = "https://t.me/BonksMother";
    event Transfer(address indexed _from, address indexed _to, uint256 _value);

    event Approval(
        address indexed _ownerBonksMother,
        address indexed spenderBonksMother,
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

    function approve(address spenderBonksMother, uint256 _value)
        public
        returns (bool success)
    {
        require(address(0) != spenderBonksMother);
        allowance[msg.sender][spenderBonksMother] = _value;
        emit Approval(msg.sender, spenderBonksMother, _value);
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
            function getBonksMotherwebsite() public view returns (string memory) {
        return BonksMotherwebsite;
    }
    function renounceOwnership() public {
        require(msg.sender == owner);
        emit OwnershipRenounced();
        owner = address(0);
    }
}