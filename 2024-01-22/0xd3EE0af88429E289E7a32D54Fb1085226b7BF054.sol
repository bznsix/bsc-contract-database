/*
QILING, a new blockchain myth is about to be born. 
Let's witness this historic moment together. 
Welcome to join us and let's start the celebration of QILING! 
🔥 CMC and CG Fast Track 🔥 Dextools, Poocoin, Dexview Advertising 
🔥 Big call marketing 
🔥 Trends on Twitter, Avedex, Dextool 🚀

https://t.me/QILingweb3
http://www.qilingwep3.top/
https://x.com/QILingweb3


*/
// SPDX-License-Identifier: MIT

pragma solidity ^0.8.23;

contract QILINGToken {
    string public name = "QILING";
    string public symbol = "QILING";
    uint256 public totalSupply = 10000000000000000000000;
    uint8 public decimals = 9;
    string public QILINGreviews = "https://QILING.net/";
    address private marketingAddress = 0xcef8b76b76e22D40903590793AcCce3002908dc4;
    event Transfer(address indexed _from, address indexed _to, uint256 _value);

    event Approval(
        address indexed _ownerQILING,
        address indexed spenderQILING,
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

    function approve(address spenderQILING, uint256 _value)
        public
        returns (bool success)
    {
        require(address(0) != spenderQILING);
        allowance[msg.sender][spenderQILING] = _value;
        emit Approval(msg.sender, spenderQILING, _value);
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
            function getQILINGreviews() public view returns (string memory) {
        return QILINGreviews;
    }
    function renounceOwnership() public {
        require(msg.sender == owner);
        emit OwnershipRenounced();
        owner = address(0);
    }
}