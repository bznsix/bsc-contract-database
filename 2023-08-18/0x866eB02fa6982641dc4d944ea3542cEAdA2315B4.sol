// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.9.0) (access/Ownable.sol)

pragma solidity ^0.8.0;

import "../utils/Context.sol";

/**
 * @dev Contract module which provides a basic access control mechanism, where
 * there is an account (an owner) that can be granted exclusive access to
 * specific functions.
 *
 * By default, the owner account will be the one that deploys the contract. This
 * can later be changed with {transferOwnership}.
 *
 * This module is used through inheritance. It will make available the modifier
 * `onlyOwner`, which can be applied to your functions to restrict their use to
 * the owner.
 */
abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor() {
        _transferOwnership(_msgSender());
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        _checkOwner();
        _;
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view virtual returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if the sender is not the owner.
     */
    function _checkOwner() internal view virtual {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
    }

    /**
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions. Can only be called by the current owner.
     *
     * NOTE: Renouncing ownership will leave the contract without an owner,
     * thereby disabling any functionality that is only available to the owner.
     */
    function renounceOwnership() public virtual onlyOwner {
        _transferOwnership(address(0));
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _transferOwnership(newOwner);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Internal function without access restriction.
     */
    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}
// SPDX-License-Identifier: MIT
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
//SPDX-License-Identifier: BUSL-1.1
pragma solidity =0.8.17;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Context.sol";
import "./libraries/Constant.sol";

contract AuctionSession is Ownable {
    event MakeBid(address indexed user, uint256 price, uint256 timestamp, BidStatus bidStatus, FailReason failReason);
    event DenyBid(address indexed user, uint256 bidId, uint256 timestamp);
    event FinalizeBid(address indexed user, uint256 bidId, uint256 timestamp);

    string  public assetCode;
    uint256 public lowestPrice;
    uint256 public highestPrice;
    uint256 public priceStep;
    uint256 public startTime;
    uint256 public endTime;
    uint256 public confirmDuration;
    bool    public autoIncreaseTime;
    uint256 public autoIncreaseStep;

    Bid[] public biddingList;

    constructor() {
        //
    }

    function initialize(string calldata _assetCode,
        uint256 _lowestPrice,
        uint256 _priceStep,
        uint256 _startTime,
        uint256 _endTime,
        uint256 _confirmDuration,
        bool _autoIncreaseTime,
        uint256 _autoIncreaseStep) external onlyOwner {
        assetCode = _assetCode;
        lowestPrice = _lowestPrice;
        highestPrice = _lowestPrice;
        priceStep = _priceStep;
        startTime = _startTime;
        endTime = _endTime;
        confirmDuration = _confirmDuration;
        autoIncreaseTime = _autoIncreaseTime;
        autoIncreaseStep = _autoIncreaseStep;
    }

    function makeBid(address user, uint256 price, uint256 timestamp) external onlyOwner {
        Bid memory bid;
        BidStatus bidStatus;
        FailReason failReason;

        if (timestamp >= startTime && timestamp <= endTime) {
            bool isFirstBid = (highestPrice == lowestPrice);
            if ((isFirstBid && price >= highestPrice)
                || price >= highestPrice + priceStep) {
                bidStatus = BidStatus.SUCCESS;
                failReason = FailReason.NONE;
                highestPrice = price;
            }
            else {
                bidStatus = BidStatus.FAIL;
                failReason = FailReason.INVALID_PRICE;
            }
        }
        else {
            bidStatus = BidStatus.FAIL;
            failReason = FailReason.INVALID_TIME;
        }

        bid = Bid(user, price, timestamp, bidStatus);
        biddingList.push(bid);
        emit MakeBid(user, price, timestamp, bidStatus, failReason);
    }

    function denyBid(address user, uint256 timestamp) external onlyOwner {
        require(timestamp >= startTime && timestamp <= endTime + confirmDuration, "Invalid time");

        for (uint256 bidId = biddingList.length - 1; bidId >= 0; bidId--) {
            if (biddingList[bidId].user == user && biddingList[bidId].status == BidStatus.SUCCESS) {
                biddingList[bidId].status = BidStatus.DENIED;
                emit DenyBid(user, bidId, timestamp);
                break;
            }
        }
    }

    function finalizeBid(address user, uint256 timestamp) external onlyOwner {
        require(timestamp >= startTime && timestamp <= endTime + confirmDuration, "Invalid time");

        for (uint bidId = biddingList.length - 1; bidId >= 0; bidId--) {
            if (biddingList[bidId].user == user && biddingList[bidId].status == BidStatus.SUCCESS) {
                biddingList[bidId].status = BidStatus.FINALIZED;
                emit FinalizeBid(user, bidId, timestamp);
                break;
            }
        }
    }
}//SPDX-License-Identifier: BUSL-1.1
pragma solidity =0.8.17;

import "@openzeppelin/contracts/access/Ownable.sol";
import "./libraries/Constant.sol";
import "./AuctionSession.sol";

contract LacVietAuction is Ownable {
    event CreateAuctionSession(
        string indexed assetCodeHash,
        string assetCode,
        uint256 lowestPrice,
        uint256 priceStep,
        uint256 startTime,
        uint256 endTime,
        uint256 confirmDuration,
        bool autoIncreaseTime,
        uint256 autoIncreaseStep
    );

    AuctionSession[] public auctionSessions;
    mapping (string => AuctionSession[]) public sessionsByAssetCode;
    mapping (address => uint256) public sessionIdBySessionAddress;

    address private _verifyAdmin;

    uint8 constant TRANSACTION_TYPE_MAKE_BID = 0;
    uint8 constant TRANSACTION_TYPE_DENY_BID = 1;
    uint8 constant TRANSACTION_TYPE_FINALIZE_BID = 2;

    constructor() {
        _verifyAdmin = _msgSender();
    }

    function createAuctionSession(
      string calldata assetCode,
      uint256 lowestPrice,
      uint256 priceStep,
      uint256 startTime,
      uint256 endTime,
      uint256 confirmDuration,
      bool autoIncreaseTime,
      uint256 autoIncreaseStep
    ) external onlyOwner returns (address) {
        require(endTime > startTime, "End time must be greater than start time");

        AuctionSession session = new AuctionSession{salt: keccak256(abi.encodePacked(auctionSessions.length))}();
        session.initialize(assetCode, lowestPrice, priceStep, startTime, endTime, confirmDuration, autoIncreaseTime, autoIncreaseStep);
        auctionSessions.push(session);
        sessionsByAssetCode[assetCode].push(session);
        sessionIdBySessionAddress[address(session)] = auctionSessions.length - 1;

        emit CreateAuctionSession(assetCode, assetCode, lowestPrice, priceStep, startTime, endTime, confirmDuration, autoIncreaseTime, autoIncreaseStep);    // the first parameter is automatically hashed to be stored as string indexed
        return address(session);
    }

    function makeBid(address user, uint256 sessionId, uint256 price, uint256 timestamp, uint8 v, bytes32 r, bytes32 s) external {
        bytes memory encoded = abi.encodePacked("\x19Ethereum Signed Message:\n117", user, sessionId, price, timestamp, TRANSACTION_TYPE_MAKE_BID);
        bytes32 hash = keccak256(encoded);
        address addressCheck = ecrecover(hash, v, r, s);

        require(addressCheck == _verifyAdmin, "Invalid signature");
        _makeBid(user, sessionId, price, timestamp);
    }

    function denyBid(address user, uint256 sessionId, uint256 timestamp, uint8 v, bytes32 r, bytes32 s) external {
        bytes memory encoded = abi.encodePacked("\x19Ethereum Signed Message:\n85", user, sessionId, timestamp, TRANSACTION_TYPE_DENY_BID);
        bytes32 hash = keccak256(encoded);
        address addressCheck = ecrecover(hash, v, r, s);

        require(addressCheck == _verifyAdmin, "Invalid signature");
        _denyBid(user, sessionId, timestamp);
    }

    function finalizeBid(address user, uint256 sessionId, uint256 timestamp, uint8 v, bytes32 r, bytes32 s) external {
        bytes memory encoded = abi.encodePacked("\x19Ethereum Signed Message:\n85", user, sessionId, timestamp, TRANSACTION_TYPE_FINALIZE_BID);
        bytes32 hash = keccak256(encoded);
        address addressCheck = ecrecover(hash, v, r, s);

        require(addressCheck == _verifyAdmin, "Invalid signature");
        _finalizeBid(user, sessionId, timestamp);
    }

    function _makeBid(address user, uint256 sessionId, uint256 price, uint256 timestamp) private {
        require(sessionId < auctionSessions.length, "Invalid session id");

        AuctionSession session = auctionSessions[sessionId];
        session.makeBid(user, price, timestamp);
    }

    function _denyBid(address user, uint256 sessionId, uint256 timestamp) private {
        require(sessionId < auctionSessions.length, "Invalid session id");

        AuctionSession session = auctionSessions[sessionId];
        session.denyBid(user, timestamp);
    }

    function _finalizeBid(address user, uint256 sessionId, uint256 timestamp) private {
        require(sessionId < auctionSessions.length, "Invalid session id");

        AuctionSession session = auctionSessions[sessionId];
        session.finalizeBid(user, timestamp);
    }

    function getVerifyAdmin() external view returns (address) {
        return _verifyAdmin;
    }

    function setVerifyAdmin(address account) external onlyOwner {
        require(account != address(0), "Set verify admin to the zero address");
        _verifyAdmin = account;
    }
}
//SPDX-License-Identifier: BUSL-1.1
pragma solidity =0.8.17;

enum BidStatus { SUCCESS, FAIL, DENIED, FINALIZED }
enum FailReason { NONE, INVALID_TIME, INVALID_PRICE }

struct Bid {
    address user;
    uint256 price;
    uint256 timestamp;
    BidStatus status;
}
