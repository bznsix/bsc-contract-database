// SPDX-License-Identifier: MIT

// Deployed with the Atlas IDE
// https://app.atlaszk.com

pragma solidity ^0.8.0;

contract Ledger {

    struct User {
        string oldWalletId;
        uint oldUserId;
        string newWalletId;
        uint newUserId;
        address oldAddress;
    }

    event UserReplaced(address oldAddress,uint oldUserId, string oldWalletId, uint newUserId, string newWalletId);

    // userId -> User
    mapping(uint => User) public users;
    mapping(uint => bool) public userReplaced;
    address public owner;
    
    constructor() {
        owner = msg.sender;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner can call");
        _;
    }

    function record(string memory _oldWalletId, uint _oldUserId, string memory _newWalletId, uint _newUserId) public  returns(bool) {

        require(!userReplaced[_oldUserId], "User has already been replaced");
        
        // 每个旧用户 只能替换一次
        User storage user = users[_oldUserId];
 
        // 记录用户信息
        user.oldAddress = msg.sender;
        user.oldWalletId = _oldWalletId;
        user.oldUserId = _oldUserId;
        user.newWalletId = _newWalletId;
        user.newUserId = _newUserId;

        userReplaced[_oldUserId] = true;
        emit UserReplaced(msg.sender, _oldUserId, _oldWalletId, _newUserId, _newWalletId);

        return true;

    }

    function set(uint userId, bool value) public onlyOwner {
        userReplaced[userId] = value;
    }

}

 