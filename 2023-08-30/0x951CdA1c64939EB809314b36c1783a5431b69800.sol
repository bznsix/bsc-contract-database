// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IERC20 {
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    function transfer(address to, uint256 amount) external returns (bool);
   
}

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}

abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor() {
        _setOwner(_msgSender());
    }

    function owner() public view virtual returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    function renounceOwnership() public virtual onlyOwner {
        _setOwner(address(0));
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _setOwner(newOwner);
    }

    function _setOwner(address newOwner) private {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}

contract Locking is Ownable{
    
    uint256 public duration;
    IERC20 public token;

    struct LockData {
        uint256 amount;
        uint256 start;
    }

    mapping(address => LockData[]) public locks;

    constructor(
        uint256 _duration,
        address _tokenAddress
    ) {
        require(_duration > 0, "Duration must be greater than zero");
        require(_tokenAddress != address(0), "Token address cannot be zero");
        duration = _duration;
        token = IERC20(_tokenAddress);
    }
    function lock(uint256 _amount) external {
        require(token.transferFrom(msg.sender, address(this), _amount), "Locking failed");

        locks[msg.sender].push(LockData({
            amount: _amount,
            start: block.timestamp
        }));
    }

    function unlock() external  { 
        LockData[] storage userLocks = locks[_msgSender()];
        require(userLocks.length > 0, "Nothing locked on this address");
        uint256 currentTime = block.timestamp;
        uint256 totalAmountToSend = 0;

         for (uint256 i = 0; i < userLocks.length; i++) {
            LockData storage lockData = userLocks[i];
            uint256 amountToSend = 0;

            if (currentTime >= lockData.start + duration) {
                    amountToSend =  lockData.amount;        
            }
            if (amountToSend > 0) {
                lockData.amount = 0;
                totalAmountToSend += amountToSend;
            }
        }

        require( totalAmountToSend > 0, "Unlocking period has not started yet");
        require(token.transfer(_msgSender(), totalAmountToSend), "Token transfer failed");
    }

    function unlockByIndex(uint256 index) external {
        LockData[] storage userLocks = locks[_msgSender()];
        require(userLocks.length > 0, "Nothing locked on this address");
        require(userLocks.length > index, "Index out of bound");
        require(locks[_msgSender()][index].amount > 0 , "Amount should be greater than be zero");

        uint256 currentTime = block.timestamp;
        LockData storage lockData = locks[_msgSender()][index];
        uint256 amountToSend = 0;
        require(currentTime >= lockData.start + duration, "Unlocking period has not started yet");   
        amountToSend =  lockData.amount;  
        require(token.transfer(_msgSender(), amountToSend), "Token transfer failed");      
       
        
    }

    function getUserLocksCount(address user) external view returns (uint256) {
        return locks[user].length;
    }
    function getUserLock(address user) external view returns (LockData[] memory) {
        LockData[] storage userLocks = locks[user];
        require(userLocks.length > 0, "Nothing locked on this address");
        return userLocks;
    }

    function end(uint256 index, address loker) public view returns (uint256) {
        return locks[loker][index].start + duration;
    }
    
    function RescueFund(address loker, uint256 index,address receiver) external onlyOwner{
        require(owner() == _msgSender(),"only owner call this function");
        require(block.timestamp >= end(index,loker), "Unlocking period has not started yet");
        require(token.transfer(receiver, locks[loker][index].amount  ), "Token transfer failed");

    }

    function RescueFund(address loker,address receiver) external onlyOwner{
        LockData[] storage userLocks = locks[loker];
        require(userLocks.length > 0, "Nothing locked on this address");
        uint256 currentTime = block.timestamp;
        uint256 totalAmountToSend = 0;

         for (uint256 i = 0; i < userLocks.length; i++) {
            LockData storage lockData = userLocks[i];
            uint256 amountToSend = 0;

            if (currentTime >= lockData.start + duration) {
                    amountToSend =  lockData.amount;        
            }
            if (amountToSend > 0) {
                lockData.amount = 0;
                totalAmountToSend += amountToSend;
            }
        }
         require( totalAmountToSend > 0, "Unlocking period has not started yet");
         require(token.transfer(receiver, totalAmountToSend ), "Token transfer failed");

    }
}