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
// OpenZeppelin Contracts v4.4.1 (interfaces/IERC20.sol)

pragma solidity ^0.8.0;

import "../token/ERC20/IERC20.sol";
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.9.0) (token/ERC20/IERC20.sol)

pragma solidity ^0.8.0;

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
     * @dev Returns the amount of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the amount of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Moves `amount` tokens from the caller's account to `to`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address to, uint256 amount) external returns (bool);

    /**
     * @dev Returns the remaining number of tokens that `spender` will be
     * allowed to spend on behalf of `owner` through {transferFrom}. This is
     * zero by default.
     *
     * This value changes when {approve} or {transferFrom} are called.
     */
    function allowance(address owner, address spender) external view returns (uint256);

    /**
     * @dev Sets `amount` as the allowance of `spender` over the caller's tokens.
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
    function approve(address spender, uint256 amount) external returns (bool);

    /**
     * @dev Moves `amount` tokens from `from` to `to` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(address from, address to, uint256 amount) external returns (bool);
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
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
 
library DateTime {
    /*
     *  Date and Time utilities for ethereum contracts
     *
     */
    struct _DateTime {
        uint16 year;
        uint8 month;
        uint8 day;
        uint8 hour;
        uint8 minute;
        uint8 second;
        uint8 weekday;
    }
 
    uint256 constant DAY_IN_SECONDS = 86400;
    uint256 constant YEAR_IN_SECONDS = 31536000;
    uint256 constant LEAP_YEAR_IN_SECONDS = 31622400;
 
    uint256 constant HOUR_IN_SECONDS = 3600;
    uint256 constant MINUTE_IN_SECONDS = 60;
 
    uint16 constant ORIGIN_YEAR = 1970;
 
    //判断输入的年份是不是闰年
    function isLeapYear(uint16 year) public pure returns (bool) {
        if (year % 4 != 0) {
            return false;
        }
        if (year % 100 != 0) {
            return true;
        }
        if (year % 400 != 0) {
            return false;
        }
        return true;
    }
 
    //判断输入的年份 的闰年前
    function leapYearsBefore(uint256 year) public pure returns (uint256) {
        year -= 1;
        return year / 4 - year / 100 + year / 400;
    }
 
    //输入年year   月month  得到当月的天数
    function getDaysInMonth(uint8 month, uint16 year) public pure returns (uint8) {
        if (month == 1 || month == 3 || month == 5 || month == 7 || month == 8 || month == 10 || month == 12) {
            return 31;
        }
        else if (month == 4 || month == 6 || month == 9 || month == 11) {
            return 30;
        }
        else if (isLeapYear(year)) {
            return 29;
        }
        else {
            return 28;
        }
    }
 
    function parseTimestamp(uint256 timestamp) internal pure returns (_DateTime memory dt) {
        uint secondsAccountedFor = 0;
        uint buf;
        uint8 i;
 
        // Year
        dt.year = getYear(timestamp);
        buf = leapYearsBefore(dt.year) - leapYearsBefore(ORIGIN_YEAR);
 
        secondsAccountedFor += LEAP_YEAR_IN_SECONDS * buf;
        secondsAccountedFor += YEAR_IN_SECONDS * (dt.year - ORIGIN_YEAR - buf);
 
        // Month
        uint secondsInMonth;
        for (i = 1; i <= 12; i++) {
            secondsInMonth = DAY_IN_SECONDS * getDaysInMonth(i, dt.year);
            if (secondsInMonth + secondsAccountedFor > timestamp) {
                dt.month = i;
                break;
            }
            secondsAccountedFor += secondsInMonth;
        }
 
        // Day
        for (i = 1; i <= getDaysInMonth(dt.month, dt.year); i++) {
            if (DAY_IN_SECONDS + secondsAccountedFor > timestamp) {
                dt.day = i;
                break;
            }
            secondsAccountedFor += DAY_IN_SECONDS;
        }
    }
 
    //根据时间戳获取年份
    function getYear(uint256 timestamp) public pure returns (uint16) {
        uint secondsAccountedFor = 0;
        uint16 year;
        uint numLeapYears;
 
        // Year
        year = uint16(ORIGIN_YEAR + timestamp / YEAR_IN_SECONDS);
        numLeapYears = leapYearsBefore(year) - leapYearsBefore(ORIGIN_YEAR);
 
        secondsAccountedFor += LEAP_YEAR_IN_SECONDS * numLeapYears;
        secondsAccountedFor += YEAR_IN_SECONDS * (year - ORIGIN_YEAR - numLeapYears);
 
        while (secondsAccountedFor > timestamp) {
            if (isLeapYear(uint16(year - 1))) {
                secondsAccountedFor -= LEAP_YEAR_IN_SECONDS;
            }
            else {
                secondsAccountedFor -= YEAR_IN_SECONDS;
            }
            year -= 1;
        }
        return year;
    }
 
    //根据时间戳获取月份
    function getMonth(uint256 timestamp) public pure returns (uint8) {
        return parseTimestamp(timestamp).month;
    }

    function getDate(uint256 timestamp) public pure returns (uint256) {
        return uint256(getYear(timestamp)) * 100 + uint256(getMonth(timestamp));
    }

    function getMonthGap(uint256 date1, uint256 date2) public pure returns (uint256) {
        require(date1 >= date2, "error date");
        return (date1 / 100 - date2 / 100) * 12 + date1 % 100 - date2 % 100;
    }
}// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/interfaces/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "./Relation.sol";
import "./DateTime.sol";

contract MstDeposit is Ownable {

    using DateTime for uint256;

    event AddRelationEvent (
        address owner,
        address recommer
    );

    event Deposit(
        address owner,
        uint256 amount,
        uint256 action
    );

    event Redeem(
        address owner,
        uint256 hashrate,
        uint256 amount
    );

    event DeductHashrate(
        address onwer,
        uint256 lastDate,
        uint256 currentDate,
        uint256 deductTimes,
        uint256 amount
    );

    event RelationProfit(
        address owner,
        uint256 amount
    );

    event CooProfit(
        address owner,
        uint256 amount
    );

    event ServiceCenterProfit(
        address owner,
        uint256 amount
    );

    event AddServiceCenter(
        address owner
    );

    event RemoveServiceCenter(
        address owner
    );

    address public coo;
    address public cfo;
    address public relation;
    uint256 public totalHashrate;
    uint256 public totalIssuance;
    uint256 public maxTimes;
    uint256 public timesAmount;
    uint256 public maxHashrate;
    address public USDT;
    address public MST;
    uint256 public relationProfitRaido;
    uint256 public cooProfitRadio;
    uint256 public serviceProfitRadio;
    uint256 public deductRadio;
    uint256 public releaseRadio;
    uint256 public hashrateLimitPerUser;




    mapping(address => User) public userInfo;

    struct User {
        uint256 hashrate;
        address recommer;
        uint256 lastDate;
        uint256 times;
        bool isServiceCenter;
        bool isBlack;
    }

    constructor(address _coo,
                        address _cfo,
                        address _relation,
                        address _usdt,
                        address _mst) {
        coo = _coo;
        cfo = _cfo;
        relation = _relation;
        USDT = _usdt;
        MST = _mst;
        totalIssuance = 10000 * 10**6;
        maxTimes = 3;
        timesAmount = 15 ether;
        maxHashrate = 100 ether;
        relationProfitRaido = 6000;
        cooProfitRadio = 2000;
        serviceProfitRadio = 2000;
        deductRadio = 20;
        releaseRadio = 8000;
        hashrateLimitPerUser = 1913 ether;

    }

    function setHashrateLimitPerUser(uint256 _hashrateLimitPerUser) external onlyOwner {
        hashrateLimitPerUser = _hashrateLimitPerUser;
    }

    function setDeductRadio(uint256 _deductRadio) external onlyOwner {
        require(_deductRadio <= 100, "error params");
        deductRadio = _deductRadio;
    }

    function setReleaseRadio(uint256 _releaseRadio) external onlyOwner {
        releaseRadio = _releaseRadio;
    }

    function setRelationProfitRadio(uint256 _relationProfitRadio) external onlyOwner {
        relationProfitRaido = _relationProfitRadio;
    }

    function setRelation(address _relation) external onlyOwner {
        relation = _relation;
    }

    function setCooProrfitRadio(uint256 _cooProfitRadio) external onlyOwner {
        cooProfitRadio = _cooProfitRadio;
    }

    function setServiceProfitRadio(uint256 _serviceProfitRadio) external onlyOwner {
        serviceProfitRadio = _serviceProfitRadio;
    }



    function setMaxHashrate(uint256 _maxHashrate) external onlyOwner {
        maxHashrate = _maxHashrate;
    }

    function setCoo(address _coo) external onlyOwner {
        coo = _coo;
    }

    function setCfo(address _cfo) external onlyOwner {
        cfo = _cfo;
    }

    function setTotalIssuance(uint256 _totalIssuance) external onlyOwner {
        totalIssuance = _totalIssuance;
    }

    function setMst(address _address) external onlyOwner {
        MST = _address;
    }

    // 建立推荐关系
    function addRelationEx(address recommer) external returns (bool result) {
        result =  Relation(relation).addRelationEx(msg.sender, recommer);
        User storage user = userInfo[msg.sender];
        user.recommer = recommer;
        emit AddRelationEvent(msg.sender, recommer);
    }

    function addRelationByAdmin(address owner, address recommer) external onlyOwner returns (bool result) {
        result =  Relation(relation).addRelationEx(owner, recommer);
        User storage user = userInfo[owner];
        user.recommer = recommer;
        emit AddRelationEvent(owner, recommer);
    }

    // 定投
    function deposit(uint256 action) external {
        uint256 currentDate = block.timestamp.getDate();
        User storage user = userInfo[msg.sender];
        require(!user.isBlack, "user error");
        if (user.lastDate == 0 || currentDate.getMonthGap(user.lastDate) == 0) { // 处于当前月投资
            require(user.times < maxTimes, "Not enough investment opportunities");
            require(user.times + 1 == action, "action error");
            
            // 移动投资额
            IERC20(USDT).transferFrom(msg.sender, cfo, timesAmount);
            
            // 修改数据
            user.times += 1;
            user.lastDate = currentDate;
            user.hashrate += timesAmount;
            totalHashrate += timesAmount;
            
        }  else { // 处于次月或若干月后再投资
            require(1 == action, "action error");
            // 移动投资额
            IERC20(USDT).transferFrom(msg.sender, cfo, timesAmount);
            if (user.times == maxTimes && currentDate.getMonthGap(user.lastDate) == 1) { // 正常顺位
            
                // 修改数据
                user.times = 1;
                user.hashrate += timesAmount;
                user.lastDate = currentDate;
                totalHashrate += timesAmount;
            } else {

                // 修改数据
                uint256 gap = currentDate.getMonthGap(user.lastDate);
                uint256 remainHashrate = user.hashrate * (100 - deductRadio)**gap / 100**gap;
                uint256 deductHashrate = user.hashrate - remainHashrate;
                uint256 lastDate = user.lastDate;
                user.times = 1;
                user.hashrate = remainHashrate + timesAmount;
                user.lastDate = currentDate;
                totalHashrate = totalHashrate - deductHashrate + timesAmount;
                
                emit DeductHashrate(msg.sender, lastDate, currentDate, gap, deductHashrate);
            }
        }
        emit Deposit(msg.sender, timesAmount, action);

        // 审核上级地址是否有问题
        if (user.recommer != address(0) && user.recommer != coo) {
             User storage recommer =  userInfo[user.recommer];
             if (recommer.lastDate > 0 
                    && ((currentDate.getMonthGap(recommer.lastDate) == 1 && recommer.times < maxTimes) || currentDate.getMonthGap(recommer.lastDate) > 1)) {
                        // 修改数据
                uint256 gap = currentDate.getMonthGap(recommer.lastDate);
                uint256 remainHashrate = recommer.hashrate * (100 - deductRadio)**gap / 100**gap;
                uint256 deductHashrate = recommer.hashrate - remainHashrate;
                uint256 lastDate = recommer.lastDate;
                recommer.times = 0;
                recommer.hashrate = remainHashrate;
                recommer.lastDate = currentDate;
                totalHashrate = totalHashrate - deductHashrate;
                
                emit DeductHashrate(user.recommer, lastDate, currentDate, gap, deductHashrate);
            }
        }

        // 直推地址奖励
        if (user.recommer != address(0) && userInfo[user.recommer].hashrate > 0 && userInfo[user.recommer].hashrate < hashrateLimitPerUser) {
            userInfo[user.recommer].hashrate += timesAmount * relationProfitRaido / 10000;
            emit RelationProfit(user.recommer, timesAmount * relationProfitRaido / 10000);
        } else { // 给运营地址
            userInfo[coo].hashrate += timesAmount * relationProfitRaido / 10000;
            emit RelationProfit(coo, timesAmount * relationProfitRaido / 10000);
        }
        totalHashrate += timesAmount * relationProfitRaido / 10000;

        // 运营地址奖励
        userInfo[coo].hashrate += timesAmount * cooProfitRadio / 10000;
        totalHashrate += timesAmount * cooProfitRadio / 10000;
        emit CooProfit(coo, timesAmount * cooProfitRadio / 10000);

        // 服务地址奖励
        address[] memory relations = Relation(relation).getForefathers(msg.sender, 50);
        for (uint256 i = 0; i < relations.length && relations[i] != address(0); i++) {
            if (userInfo[relations[i]].isServiceCenter && userInfo[relations[i]].hashrate < hashrateLimitPerUser) {
                userInfo[relations[i]].hashrate += timesAmount * serviceProfitRadio / 10000;
                totalHashrate += timesAmount * serviceProfitRadio / 10000;
                emit ServiceCenterProfit(relations[i], timesAmount * serviceProfitRadio / 10000);
                break;
            }
        }
    }

    // 赎回
    function redeem() external {
        User storage user = userInfo[msg.sender];
        require(user.hashrate >= maxHashrate, "Can not redeem");
        require(!user.isBlack, "user error");
        // 赎回只能赎回80%
        uint256 redeemAmount = user.hashrate * releaseRadio / 10000;
        user.hashrate -= redeemAmount;
        uint256 amount = redeemAmount * totalIssuance / totalHashrate;
        IERC20(MST).transfer(msg.sender, amount);
        totalHashrate -= redeemAmount;
        totalIssuance -= amount;
        emit Redeem(msg.sender, redeemAmount, amount);
    }

    // 赎回数量
    function getRedeemAmount(address sender) view external returns(uint256, uint256) {
        User memory user = userInfo[sender];
        if (user.hashrate < maxHashrate) {
            return (user.hashrate,0);
        } else{
            uint256 redeemAmount = user.hashrate * releaseRadio / 10000;
            uint256 hashrate = user.hashrate;
            user.hashrate -= redeemAmount;
            return (hashrate, redeemAmount * totalIssuance / totalHashrate);
        }
    }

    // 增加或取消服务中心
    function addServiceCenter(address _serviceCender) external onlyOwner {
        userInfo[_serviceCender].isServiceCenter = true;
        emit AddServiceCenter(_serviceCender);
    }

    function removeServiceCenter(address _serviceCenter) external onlyOwner {
        userInfo[_serviceCenter].isServiceCenter = false;
        emit RemoveServiceCenter(_serviceCenter);
    }

    function addBlack(address _black) external onlyOwner {
        userInfo[_black].isBlack = true;
    }

    function removeBlack(address _black) external onlyOwner {
        userInfo[_black].isBlack = false;
    }

    // 设置总购买代币
    function setTimesAmount(uint256 _timesAmount) external onlyOwner {
        timesAmount = _timesAmount;
    }

    function withdrawToken(address token) external onlyOwner {
        IERC20(token).transfer(msg.sender, IERC20(token).balanceOf(address(this)));
    }
}// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";

contract RelationStorage {

    struct RecommerData {
        uint256 ts;
        address addr;
    }

    uint public totalAddresses;
    // parent node
    mapping (address => address) public _recommerMapping;
    // have node
    mapping (address => bool) internal _haveChild;
    
    constructor() {
    }
}

contract Relation is RelationStorage, Ownable {

    modifier onlyBoss() {
        require(bosses[msg.sender], "Relation: caller is not the boss");
        _;
    }

    mapping(address => bool) public bosses;

    function addBoss(address _boss) external onlyOwner {
        bosses[_boss] = true;
    }

    function removeBoss(address _boss) external onlyOwner {
        bosses[_boss] = false;
    }

    // bind
    function addRelationEx(address slef,address recommer) external onlyBoss returns (bool) {

        require(recommer != slef,"your_self");                   

        require(_recommerMapping[slef] == address(0),"binded");
        
        require(!_haveChild[slef], "error");

        totalAddresses++;

        _recommerMapping[slef] = recommer;
        _haveChild[slef] = true;
        return true;
    }

    // find parent
    function parentOf(address owner) external view returns(address){
        return _recommerMapping[owner];
    }
    
    // find parent
    function getForefathers(address owner,uint num) public view returns(address[] memory fathers){

        fathers = new address[](num);

        address parent  = owner;
        for( uint i = 0; i < num; i++){
            parent = _recommerMapping[parent];

            if(parent == address(0) ) break;

            fathers[i] = parent;
        }
    }
}