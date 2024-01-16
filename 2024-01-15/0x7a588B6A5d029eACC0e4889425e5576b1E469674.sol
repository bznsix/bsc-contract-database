// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

interface IERC20 {
    function transfer(address recipient, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
}

contract TokenLock {
    struct Lock {
        uint256 amount;
        uint256 unlockTime;
        uint256 nonce; 
    }

    
    uint256 private globalNonce = 0;

    mapping(address => mapping(address => Lock[])) public tokenLocks;
    mapping(address => address[]) private userLockedTokens;

    function lockTokens(address _token, uint256 _amount, uint256 _duration) external {
        require(_amount > 0, "Amount must be greater than 0");
        require(IERC20(_token).transferFrom(msg.sender, address(this), _amount), "Transfer failed");

        Lock memory newLock = Lock({
            amount: _amount,
            unlockTime: block.timestamp + _duration,
            nonce: globalNonce // Assign the current global nonce
        });

        tokenLocks[msg.sender][_token].push(newLock);
        globalNonce++; // Increment the global nonce after each lock

        if (!isTokenLockedByUser(msg.sender, _token)) {
            userLockedTokens[msg.sender].push(_token);
        }
    }

    function unlockTokens(address _token, uint256 _index) external {
        Lock storage lock = tokenLocks[msg.sender][_token][_index];
        require(block.timestamp >= lock.unlockTime, "Tokens are still locked");
        require(lock.amount > 0, "No tokens to unlock");

        uint256 amount = lock.amount;
        lock.amount = 0;

        require(IERC20(_token).transfer(msg.sender, amount), "Transfer failed");
    }

    function getLockInfo(address _user, address _token, uint256 _index) public view returns (uint256 amount, uint256 unlockTime, uint256 nonce) {
        Lock memory lock = tokenLocks[_user][_token][_index];
        return (lock.amount, lock.unlockTime, lock.nonce);
    }

    function getLockCount(address _user, address _token) public view returns (uint256) {
        return tokenLocks[_user][_token].length;
    }

    function getLockedTokens(address _user) public view returns (address[] memory) {
        return userLockedTokens[_user];
    }

    function isTokenLockedByUser(address _user, address _token) private view returns (bool) {
        for (uint i = 0; i < userLockedTokens[_user].length; i++) {
            if (userLockedTokens[_user][i] == _token) {
                return true;
            }
        }
        return false;
    }
}