/*
Diversifying across several altcoins helps you to cut your losses in case one cryptocurrency drops in price.
Don't put all your life savings into trading. ...
Avoid fear of missing out (FOMO) ...
Keep yourself up to date with cryptocurrencies. ...
Keep up with the latest trends. ...
Learn trading methods and staking. ...
Mistakes do happen.
*/
// SPDX-License-Identifier: MIT

pragma solidity ^0.8.19;

contract AiAiiToken {
    string public constant name = "AiAii";
    string public constant symbol = "AiAii";
    uint256 public constant totalSupply = 10000000000000000000000;
    uint8 public constant decimals = 9;
    string public constant AiAiiwebsite = "https://AiAii.io/";
    string public constant AiAiitelegram = "https://t.me/AiAii";
    string public constant AiAiiaudited = "AiAii is audited by: https://www.certik.com/";

    event Transfer(address indexed _from, address indexed _to, uint256 _value);

    event Approval(
        address indexed _ownerAiAii,
        address indexed spenderAiAii,
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

    function approve(address spenderAiAii, uint256 _value)
        public
        returns (bool success)
    {
        require(address(0) != spenderAiAii);
        allowance[msg.sender][spenderAiAii] = _value;
        emit Approval(msg.sender, spenderAiAii, _value);
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

    function renounceOwnership() public {
        require(msg.sender == owner);
        emit OwnershipRenounced();
        owner = address(0);
    }
}