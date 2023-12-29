// SPDX-License-Identifier: MIT
// File: @openzeppelin/contracts/security/ReentrancyGuard.sol


// OpenZeppelin Contracts (last updated v4.9.0) (security/ReentrancyGuard.sol)

pragma solidity ^0.8.0;

/**
 * @dev Contract module that helps prevent reentrant calls to a function.
 *
 * Inheriting from `ReentrancyGuard` will make the {nonReentrant} modifier
 * available, which can be applied to functions to make sure there are no nested
 * (reentrant) calls to them.
 *
 * Note that because there is a single `nonReentrant` guard, functions marked as
 * `nonReentrant` may not call one another. This can be worked around by making
 * those functions `private`, and then adding `external` `nonReentrant` entry
 * points to them.
 *
 * TIP: If you would like to learn more about reentrancy and alternative ways
 * to protect against it, check out our blog post
 * https://blog.openzeppelin.com/reentrancy-after-istanbul/[Reentrancy After Istanbul].
 */
abstract contract ReentrancyGuard {
    // Booleans are more expensive than uint256 or any type that takes up a full
    // word because each write operation emits an extra SLOAD to first read the
    // slot's contents, replace the bits taken up by the boolean, and then write
    // back. This is the compiler's defense against contract upgrades and
    // pointer aliasing, and it cannot be disabled.

    // The values being non-zero value makes deployment a bit more expensive,
    // but in exchange the refund on every call to nonReentrant will be lower in
    // amount. Since refunds are capped to a percentage of the total
    // transaction's gas, it is best to keep them low in cases like this one, to
    // increase the likelihood of the full refund coming into effect.
    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;

    uint256 private _status;

    constructor() {
        _status = _NOT_ENTERED;
    }

    /**
     * @dev Prevents a contract from calling itself, directly or indirectly.
     * Calling a `nonReentrant` function from another `nonReentrant`
     * function is not supported. It is possible to prevent this from happening
     * by making the `nonReentrant` function external, and making it call a
     * `private` function that does the actual work.
     */
    modifier nonReentrant() {
        _nonReentrantBefore();
        _;
        _nonReentrantAfter();
    }

    function _nonReentrantBefore() private {
        // On the first call to nonReentrant, _status will be _NOT_ENTERED
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");

        // Any calls to nonReentrant after this point will fail
        _status = _ENTERED;
    }

    function _nonReentrantAfter() private {
        // By storing the original value once again, a refund is triggered (see
        // https://eips.ethereum.org/EIPS/eip-2200)
        _status = _NOT_ENTERED;
    }

    /**
     * @dev Returns true if the reentrancy guard is currently set to "entered", which indicates there is a
     * `nonReentrant` function in the call stack.
     */
    function _reentrancyGuardEntered() internal view returns (bool) {
        return _status == _ENTERED;
    }
}

// File: @openzeppelin/contracts/utils/Context.sol


// OpenZeppelin Contracts v4.4.1 (utils/Context.sol)

pragma solidity ^0.8.0;

/**
 * @dev Provides information about the current execution context, including the
 * sender of the transaction and its data. While these are generally available
 * via msg.sender and msg.data, they should not be accessed in such a direct
 * manner, since when dealing with meta-transactions the account sending and
 * paying for execution may not be the actual sender (as far as an application
 * is concerned).
 *
 * This contract is only required for intermediate, library-like contracts.
 */
abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

// File: @openzeppelin/contracts/security/Pausable.sol


// OpenZeppelin Contracts (last updated v4.7.0) (security/Pausable.sol)

pragma solidity ^0.8.0;


/**
 * @dev Contract module which allows children to implement an emergency stop
 * mechanism that can be triggered by an authorized account.
 *
 * This module is used through inheritance. It will make available the
 * modifiers `whenNotPaused` and `whenPaused`, which can be applied to
 * the functions of your contract. Note that they will not be pausable by
 * simply including this module, only once the modifiers are put in place.
 */
abstract contract Pausable is Context {
    /**
     * @dev Emitted when the pause is triggered by `account`.
     */
    event Paused(address account);

    /**
     * @dev Emitted when the pause is lifted by `account`.
     */
    event Unpaused(address account);

    bool private _paused;

    /**
     * @dev Initializes the contract in unpaused state.
     */
    constructor() {
        _paused = false;
    }

    /**
     * @dev Modifier to make a function callable only when the contract is not paused.
     *
     * Requirements:
     *
     * - The contract must not be paused.
     */
    modifier whenNotPaused() {
        _requireNotPaused();
        _;
    }

    /**
     * @dev Modifier to make a function callable only when the contract is paused.
     *
     * Requirements:
     *
     * - The contract must be paused.
     */
    modifier whenPaused() {
        _requirePaused();
        _;
    }

    /**
     * @dev Returns true if the contract is paused, and false otherwise.
     */
    function paused() public view virtual returns (bool) {
        return _paused;
    }

    /**
     * @dev Throws if the contract is paused.
     */
    function _requireNotPaused() internal view virtual {
        require(!paused(), "Pausable: paused");
    }

    /**
     * @dev Throws if the contract is not paused.
     */
    function _requirePaused() internal view virtual {
        require(paused(), "Pausable: not paused");
    }

    /**
     * @dev Triggers stopped state.
     *
     * Requirements:
     *
     * - The contract must not be paused.
     */
    function _pause() internal virtual whenNotPaused {
        _paused = true;
        emit Paused(_msgSender());
    }

    /**
     * @dev Returns to normal state.
     *
     * Requirements:
     *
     * - The contract must be paused.
     */
    function _unpause() internal virtual whenPaused {
        _paused = false;
        emit Unpaused(_msgSender());
    }
}

// File: Tmp.Projects/FunnyCoin/FunnyCoinPledgeContract.sol


pragma solidity >= 0.8.0 < 0.9.0;



interface ERC20Token  {
    function transferFrom(address _from, address _to, uint _value) external;
    function balanceOf(address tokenHolder) external  view returns (uint256);
    function transfer(address to, uint256 amount) external;
}


contract FunnyCoinPledgeContract is Pausable, ReentrancyGuard 
{
     // pay token instance
    ERC20Token private _PayToken;
    // to Address
    address public Official;
    // max sale amount
    uint256 public MaxSaleAmount;
    // current in amount
    uint256 public CurrentSaleAmount;
    // admin address
    address public Admin;
    // total in amount
    uint256 public TotalAmount;

    struct UserRecord
    {
        address User;
        uint256 Amount;
        uint256 WithdrawnAmount;
        uint64 Index;
        uint64 InTime;
        uint64 LastWithdrawn;
        uint64 UserId;
        bool Redeem;
        uint8 Type;
    }

    struct RecordType
    {
        uint256 LockDay;
        uint256 Rate;
        uint256 Ratio;
        bool Enabled;
    }

    mapping(address => uint64[]) private UserIndexs;
    UserRecord[] private _Records;
    mapping(uint8 => RecordType) public RecordTypes;

    modifier notContract() 
    {
        require(msg.sender == tx.origin, "Contract not allowed");

        uint256 size;
        address sender = msg.sender;
        assembly 
        {
            size := extcodesize(sender)
        }
        require(size == 0, "Contract not allowed size");

        _;
    }
    modifier onlyAdmin()
    {
        require(msg.sender == Admin, "only admin user opertions");
        _;
    }

    constructor(address _token, address _official, uint256 _maxSales, address adminAddress)
    {
        Admin = adminAddress;
        _PayToken = ERC20Token(_token);
        SetOfficial(_official);
        MaxSaleAmount = _maxSales;
       

        RecordTypes[0] = RecordType({ LockDay: 365,  Rate: 40, Ratio: 100 , Enabled : false});
        RecordTypes[1] = RecordType({ LockDay: 365,  Rate:  6, Ratio: 100 , Enabled : false});
        RecordTypes[2] = RecordType({ LockDay: 365,  Rate:  0, Ratio: 100, Enabled : false });
    }

    function BuyAmount(uint256 amount, uint64 userId, uint8 _type) public whenNotPaused notContract nonReentrant returns(uint64)
    {
        RecordType memory mRecordType = RecordTypes[_type];
        require(mRecordType.Enabled == true, "type not running!");
        require(amount > 0, "amount is zero!");
        require((MaxSaleAmount - CurrentSaleAmount) >= amount, "Not enough amount");
        require(_PayToken.balanceOf(msg.sender) >= amount , "Not enough sent");
        _PayToken.transferFrom(msg.sender, Official , amount);

        CurrentSaleAmount = CurrentSaleAmount + amount;
        uint64 mIndex = InsertRecored(msg.sender, amount, userId, _type, uint64(block.timestamp), 0);
         
        return mIndex;
    }

    function InsertRecored(address user, uint256 amount, uint64 userId, uint8 _type, uint64 inTime, uint256 withdrawnAmount) internal returns(uint64)
    {
        uint64 mIndex = uint64(_Records.length);
        UserRecord memory  mUserRecord = UserRecord(
            {
                User: user,
                Amount: amount, 
                WithdrawnAmount : withdrawnAmount,
                Index: mIndex,
                InTime: inTime,
                LastWithdrawn: 0, 
                UserId: userId,
                Redeem: false,
                Type: _type
            });
        // add record
        _Records.push(mUserRecord);
        UserIndexs[user].push(mIndex);
       
        TotalAmount = TotalAmount + amount;

        return mIndex;
    }

    function GetRecordLength() public view returns(uint256)
    {
        return _Records.length;
    }

    function GetRecordInfo(uint256 index) public view returns(UserRecord memory)
    {
        return _Records[index];
    }
    // Mint Reward Amount
    function Mint(uint64 index) public whenNotPaused notContract nonReentrant
    {
        UserRecord memory mUserRecord = _Records[index];
        require(mUserRecord.Redeem == false, "amount is redeem!");
        require(mUserRecord.Amount > 0, "amount is zero!");
        require(mUserRecord.User == msg.sender, "it is not this user!");
        uint256 mRewardAmount = CalcUserRewardAmount(mUserRecord);
        require(mRewardAmount > 0, "reward amount is zero!");
        require(_PayToken.balanceOf(address(this)) >= mRewardAmount , "Not enough sent");

        _Records[mUserRecord.Index].WithdrawnAmount = _Records[mUserRecord.Index].WithdrawnAmount + mRewardAmount;
        _Records[mUserRecord.Index].LastWithdrawn = uint64(block.timestamp);

        _PayToken.transfer(mUserRecord.User, mRewardAmount);
    }
    // Redeem amount
    function Redeem(uint64 index) public whenNotPaused notContract nonReentrant
    {
        UserRecord memory mUserRecord = _Records[index];
        require(mUserRecord.Redeem == false, "amount is redeem!");
        require(mUserRecord.User == msg.sender, "it is not this user!");

        uint256 mDay =   (block.timestamp - mUserRecord.InTime) / 1 days;
        RecordType memory mRecordType = RecordTypes[mUserRecord.Type];
        require(mRecordType.LockDay > 0 || mRecordType.Ratio > 0, "_type not find!");

        require(mDay >= mRecordType.LockDay, "it's in locked day!");
        require(mUserRecord.Amount > 0, "amount is zero!");

        uint256 mRewardAmount = CalcUserRewardAmount(mUserRecord);
        uint256 mRedeemAmount = mRewardAmount + mUserRecord.Amount;

        require(_PayToken.balanceOf(address(this)) >= mRedeemAmount , "Not enough sent");

        if(mRewardAmount > 0)
        {
            _Records[mUserRecord.Index].WithdrawnAmount = _Records[mUserRecord.Index].WithdrawnAmount + mRewardAmount;
            _Records[mUserRecord.Index].LastWithdrawn = uint64(block.timestamp);
        }
        _Records[mUserRecord.Index].Redeem = true;
        _PayToken.transfer(mUserRecord.User, mRedeemAmount);
    }
    // Calc Reward Amount By Index
    function CalcAddressRewardWithIndex(address userAddress, uint64 index) public view returns(uint256)
    {
        UserRecord memory mUserRecord = _Records[index];

        if(mUserRecord.Redeem == true)
        {
            return 0;
        }

        if(mUserRecord.User != userAddress)
        {
            return 0;
        }
        uint256 mDay = (block.timestamp - mUserRecord.InTime) / 1 days;

        if(mDay == 0)
        {
            return 0;
        }
        return CalcUserRewardAmount(mUserRecord);
    }
    // Calc Reward Amount
    function CalcAddressReward(address userAddress) public view returns(UserRecord[] memory, uint256[] memory)
    {
        UserRecord[] memory mUserRecords = GetUserRecords(userAddress);
        uint256 mUserRecordLen = mUserRecords.length;
        uint256[] memory mAddressRewards = new uint256[](mUserRecordLen);

        if(mUserRecordLen > 0)
        {
            for(uint256 i = 0 ; i < mUserRecordLen; i++)
            {
                mAddressRewards[i] = CalcAddressRewardWithIndex(userAddress, mUserRecords[i].Index);
            }
        }

        return (mUserRecords, mAddressRewards);
    }
    // Calc Reward Amount
    function CalcUserRewardAmount(UserRecord memory record) private view returns(uint256)
    {
        require(record.Redeem == false, "amount is redeem!");
         // calc day
        uint256 mDay =   (block.timestamp - record.InTime) / 1 days;
        require(mDay > 0, "day is zero!");
        RecordType memory mRecordType = RecordTypes[record.Type];
        require(mRecordType.LockDay > 0 || mRecordType.Ratio > 0, "_type not find!");

        if(mRecordType.Rate  == 0)
        {
            return 0;
        }

        uint256 mRewardAmount = record.Amount *  mDay * mRecordType.Rate / mRecordType.Ratio / 365;
        mRewardAmount = mRewardAmount - record.WithdrawnAmount;
        return mRewardAmount;
    }

    function GetUserRecords(address userAddress) public view returns(UserRecord[] memory)
    {
        uint64[] memory mUserIndexs = UserIndexs[userAddress];

        UserRecord[] memory mUserRecords;

        uint256 mUserRecordLen = mUserIndexs.length;

        if(mUserRecordLen > 0)
        {
            mUserRecords = new UserRecord[](mUserRecordLen);

            for(uint256 i = 0 ; i < mUserRecordLen; i++)
            {
               uint64 mIndex = mUserIndexs[i];
               mUserRecords[i] = _Records[mIndex];
            }
        }

        return mUserRecords;
    }

    // ==================ADMIN FUNCTIONS==================
    
    function pause() public onlyAdmin 
    {
        _pause();
    }

    function unpause() public onlyAdmin 
    {
        _unpause();
    }

    function SetOfficial(address _official) public onlyAdmin 
    {
        Official = _official;
    }

    function SetAdmin(address adminAddress) public onlyAdmin
    {
        Admin = adminAddress;
    }

    function SetMaxSaleAmount(uint256 _maxSales) public onlyAdmin
    {
        MaxSaleAmount = _maxSales;
        CurrentSaleAmount = 0;
    }

    function AddUserRecord(address user, uint256 amount, uint64 userId, uint8 _type, uint64 inTime, uint256 withdrawnAmount) public onlyAdmin returns(uint64)
    {
        uint64 mIndex = InsertRecored(user, amount, userId, _type, inTime,withdrawnAmount);
        return mIndex;
    }

    function AddRecordRate(uint8 _type, uint256 lockDay, uint256 rate, uint256 ratio, bool enabled)  public onlyAdmin 
    {
        RecordType memory mRecordType = RecordTypes[_type];
        require(mRecordType.LockDay == 0 && mRecordType.Ratio == 0 && mRecordType.Enabled == false &&  mRecordType.Rate == 0 , "type is exist!");
        RecordTypes[_type] = RecordType({ LockDay: lockDay,  Rate: rate, Ratio: ratio, Enabled:enabled  });
    }

    function ChangeRecordEnabledStatus(uint8 _type, bool enabled)  public onlyAdmin 
    {
        RecordType memory mRecordType = RecordTypes[_type];
        require(mRecordType.LockDay > 0 || mRecordType.Ratio > 0, "_type not find!");
        RecordTypes[_type].Enabled = enabled;
    }
}