/**
 *Submitted for verification at BscScan.com on 2024-01-10
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.23;

// import "@openzeppelin/contracts/interfaces/IERC20.sol";
// import "@openzeppelin/contracts/access/Ownable.sol";


/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IERC20 {
    /**
     * @dev Emitted when `value` tokens are moved from one account (`from`) to
     * another (`to`).
     *
     * Note that `value` may be zero.
     */
    event Transfer(address indexed from, address indexed to, uint256 value);

    /**
     * @dev Emitted when the allowance of a `spender` for an `owner` is set by
     * a call to {approve}. `value` is the new allowance.
     */
    event Approval(address indexed owner, address indexed spender, uint256 value);

    /**
     * @dev Returns the value of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the value of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Moves a `value` amount of tokens from the caller's account to `to`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address to, uint256 value) external returns (bool);

    /**
     * @dev Returns the remaining number of tokens that `spender` will be
     * allowed to spend on behalf of `owner` through {transferFrom}. This is
     * zero by default.
     *
     * This value changes when {approve} or {transferFrom} are called.
     */
    function allowance(address owner, address spender) external view returns (uint256);

    /**
     * @dev Sets a `value` amount of tokens as the allowance of `spender` over the
     * caller's tokens.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * IMPORTANT: Beware that changing an allowance with this method brings the risk
     * that someone may use both the old and the new allowance by unfortunate
     * transaction ordering. One possible solution to mitigate this race
     * condition is to first reduce the spender's allowance to 0 and set the
     * desired value afterwards:
     * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
     *
     * Emits an {Approval} event.
     */
    function approve(address spender, uint256 value) external returns (bool);

    /**
     * @dev Moves a `value` amount of tokens from `from` to `to` using the
     * allowance mechanism. `value` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(address from, address to, uint256 value) external returns (bool);
}


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


/**
 * @dev Contract module which provides a basic access control mechanism, where
 * there is an account (an owner) that can be granted exclusive access to
 * specific functions.
 *
 * The initial owner is set to the address provided by the deployer. This can
 * later be changed with {transferOwnership}.
 *
 * This module is used through inheritance. It will make available the modifier
 * `onlyOwner`, which can be applied to your functions to restrict their use to
 * the owner.
 */
abstract contract Ownable is Context {
    address private _owner;

    /**
     * @dev The caller account is not authorized to perform an operation.
     */
    error OwnableUnauthorizedAccount(address account);

    /**
     * @dev The owner is not a valid owner account. (eg. `address(0)`)
     */
    error OwnableInvalidOwner(address owner);

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the address provided by the deployer as the initial owner.
     */
    constructor(address initialOwner) {
        if (initialOwner == address(0)) {
            revert OwnableInvalidOwner(address(0));
        }
        _transferOwnership(initialOwner);
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
        if (owner() != _msgSender()) {
            revert OwnableUnauthorizedAccount(_msgSender());
        }
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
        if (newOwner == address(0)) {
            revert OwnableInvalidOwner(address(0));
        }
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


contract SltGame {
    
    struct UserInfo {
        address invitor; //用户的直接推荐人
        uint refer_n; // 该用户推荐了多少个有效地址（如⽤户下⼀级有上级滑落的⽤户则不算为⾃⼰的有效⽤户，为上级的有效⽤户）
        uint referSltReward; //待领取的直推slt
        uint referSltClaimed; //累计领取的直推slt
        uint buySltReward; // 待领取的认购slt
        uint buySltClaimed; //累计领取的认购slt
        uint usdtClaimed; //累计领取的奖励USDT
        uint districtID; //属于哪一条普通节点的线（哪个区）,如果该数字不为0，说明是有效用户，已经在团队结构中了
        uint level; // 用户的等级
    }

    mapping(address => UserInfo) public userInfo;
}

contract Stake is Ownable{
    IERC20 public token; //
    address public bAddress;
    struct UserInfo {
        uint stakeAmount;//本金
        uint rewards; //暂存奖励
        uint lastClaimAt; //上次领取时间戳
    }

    mapping(address => UserInfo) public userInfo; //用户表
    mapping(uint => uint) public levelAPR; //年利率
    mapping(address => uint) public userLevel; //用户等级表

    constructor(address initialOwner,address _tokenAddress,address _bAddress) Ownable(initialOwner) {
        token = IERC20(_tokenAddress);
        bAddress = _bAddress;
        levelAPR[1] = 34;
        levelAPR[2] = 38;
        levelAPR[3] = 41;
        levelAPR[4] = 45;
        levelAPR[5] = 49;
        levelAPR[6] = 53;
        levelAPR[7] = 57;
        levelAPR[8] = 60;
        levelAPR[9] = 64;
        levelAPR[10] = 68;
    }

    function getLevel(address _address) public view returns(uint){
        (, , , , , , , , uint level) = SltGame(bAddress).userInfo(_address);
        return level;
    }

    //设置年利率
    function setLevelAPR(uint _level, uint _rate) external onlyOwner {
        levelAPR[_level] = _rate;
    }

    function setLevel(uint _level, address _address) external onlyOwner {
        userLevel[_address] = _level;
    }

    function stake(uint256 _amount) external {
        require(_amount > 0, "Amount must be greater than 0");

        uint level = getLevel(msg.sender);
        if(getLevel(msg.sender) < userLevel[msg.sender])
        {
            level = userLevel[msg.sender];
        }
        else 
        {
            userLevel[msg.sender] = getLevel(msg.sender);
        }
        token.transferFrom(msg.sender, address(this), _amount);
        if(userInfo[msg.sender].stakeAmount == 0) {
            userInfo[msg.sender] = UserInfo(_amount, 0, block.timestamp);
        }
        else {
            userInfo[msg.sender].rewards = userInfo[msg.sender].rewards + getRewards(msg.sender,level);
            userInfo[msg.sender].lastClaimAt = block.timestamp;
            userInfo[msg.sender].stakeAmount = userInfo[msg.sender].stakeAmount + _amount;
        }
    }

    function claim() external {
        require(block.timestamp - userInfo[msg.sender].lastClaimAt >= 24 * 60 * 60, "Claim interval less than 24 hours");
        
        userInfo[msg.sender].rewards = userInfo[msg.sender].rewards + getRewards(msg.sender,userLevel[msg.sender]);
        userInfo[msg.sender].lastClaimAt = block.timestamp;

        token.transfer(msg.sender, userInfo[msg.sender].rewards);
        userInfo[msg.sender].rewards = 0;
    }

    function reStake() external {

        userInfo[msg.sender].rewards = userInfo[msg.sender].rewards + getRewards(msg.sender,userLevel[msg.sender]);
        userInfo[msg.sender].lastClaimAt = block.timestamp;
        userInfo[msg.sender].stakeAmount = userInfo[msg.sender].stakeAmount + userInfo[msg.sender].rewards;
        userInfo[msg.sender].rewards = 0;
    }

    function UnStake(uint256 _amount) external {
        require(_amount > 0, "Amount must be greater than 0");
        require(_amount <= userInfo[msg.sender].stakeAmount, "Amount must be smaller than the stake amount");
        userInfo[msg.sender].rewards = userInfo[msg.sender].rewards + getRewards(msg.sender,userLevel[msg.sender]);
        userInfo[msg.sender].lastClaimAt = block.timestamp;
        userInfo[msg.sender].stakeAmount = userInfo[msg.sender].stakeAmount - _amount;
        token.transfer(msg.sender, _amount);
    }

    function roundDown(uint a, uint b) public pure returns(uint) {
        return a/b;
    }

    function getRewards(address _address, uint _level) public view returns(uint) {
        return userInfo[_address].stakeAmount * levelAPR[_level] / 100000000 * roundDown(block.timestamp - userInfo[_address].lastClaimAt , 60);
    }
}