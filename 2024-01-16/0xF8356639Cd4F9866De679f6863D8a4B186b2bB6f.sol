// SPDX-License-Identifier: MIT
pragma solidity ^0.8.15;

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
    uint256 private constant NOT_ENTERED = 1;
    uint256 private constant ENTERED = 2;

    uint256 private _status;

    /**
     * @dev Unauthorized reentrant call.
     */
    error ReentrancyGuardReentrantCall();

    constructor() {
        _status = NOT_ENTERED;
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
        // On the first call to nonReentrant, _status will be NOT_ENTERED
        if (_status == ENTERED) {
            revert ReentrancyGuardReentrantCall();
        }

        // Any calls to nonReentrant after this point will fail
        _status = ENTERED;
    }

    function _nonReentrantAfter() private {
        // By storing the original value once again, a refund is triggered (see
        // https://eips.ethereum.org/EIPS/eip-2200)
        _status = NOT_ENTERED;
    }

    /**
     * @dev Returns true if the reentrancy guard is currently set to "entered", which indicates there is a
     * `nonReentrant` function in the call stack.
     */
    function _reentrancyGuardEntered() internal view returns (bool) {
        return _status == ENTERED;
    }
}

library DateTime {
    /*
     *  Date and Time utilities for ethereum contracts
     *
     */

    function getNowDateTime() public view returns (uint32) {
        uint256 ts = block.timestamp + 8 hours;
        return uint32(ts / 1 days);
    }

    function tsToDateTime(uint256 ts) public pure returns (uint32) {
        return uint32((ts + 8 hours) / 1 days);
    }
}

interface IPancakeFactory {
    function getPair(
        address tokenA,
        address tokenB
    ) external view returns (address pair);
}

interface IERC20 {
    function decimals() external view returns (uint8);

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
    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);

    function mint(uint256 amount) external returns (uint256);

    function destroy(uint256 amount) external returns (uint256);

    function getPrice() external view returns (uint256);
}

interface IUniswapV2Pair {
    function totalSupply() external view returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);

    function balanceOf(address owner) external view returns (uint256);

    function token0() external view returns (address);

    function token1() external view returns (address);

    function getReserves()
        external
        view
        returns (uint112 reserve0, uint112 reserve1, uint32 blockTimestampLast);
}

interface ISwapRouter {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);

    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external;

    function getAmountsOut(
        uint amountIn,
        address[] calldata path
    ) external view returns (uint[] memory amounts);

    function addLiquidity(
        address tokenA,
        address tokenB,
        uint256 amountADesired,
        uint256 amountBDesired,
        uint256 amountAMin,
        uint256 amountBMin,
        address to,
        uint256 deadline
    ) external returns (uint256 amountA, uint256 amountB, uint256 liquidity);

    function removeLiquidity(
        address tokenA,
        address tokenB,
        uint liquidity,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline
    ) external returns (uint amountA, uint amountB);

    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;

    function swapExactETHForTokensSupportingFeeOnTransferTokens(
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external payable;
}

abstract contract Ownable {
    address internal _owner;

    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );

    constructor() {
        address msgSender = msg.sender;
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    function owner() public view returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(_owner == msg.sender, "!o");
        _;
    }

    function renounceOwnership() public virtual onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "n0");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

contract PublicReward {
    constructor(address USDT, address HD) {
        IERC20(USDT).approve(msg.sender, ~uint256(0));
        IERC20(HD).approve(msg.sender, ~uint256(0));
    }
}

contract BlackHole is Ownable, ReentrancyGuard {
    struct User {
        Team team;
        uint8 level; // 等级
        uint64 latestLevelPowerTs; // 最新更新时间
        uint64 latestLPPowerTs; // 最新更新时间
        uint64 latestClaimTs; // 最新领取时间
        uint256 claimedHDReward; // 已领取HD奖励
        uint256 claimedUSDTReward; // 已领取USDT奖励
        uint256 bourtUSDT; // 已购买USDT数
        mapping(uint32 => uint256) teamReward; // 团队BH奖励
        mapping(uint32 => uint256) lpPower; // lp算力
        mapping(uint32 => uint256) levelPower; // 等级算力
        mapping(uint32 => uint256) dailyTransaction; // 每日交易额
    }

    struct Team {
        address add;
        address[] redirects; // 直推
        address left; // 左节点
        address right; //  右节点
        address middle; //  中间节点
        address top; // 父节点
        address leader; // 领导
        uint16 floor; // 所在层
        uint16 reachFloor; // 最下面满层的该层层数
        uint32 nextCount; // 直接子节点数
        uint32 childCount; // 子节点数
        uint32 index; // 所在层的序号
        uint32 latestIndex; // 上次滑落所在父节点序号
        uint64 initTime; // 初始化时间
        mapping(uint32 => mapping(uint16 => uint32)) floorChildInfo; // 下面每层的直接子节信息
    }

    IERC20 USDT;
    IERC20 HD;

    PublicReward public publicReward;

    ISwapRouter router;
    IUniswapV2Pair pair;
    mapping(uint256 => mapping(uint256 => address)) public floorUsers;
    mapping(address => User) users;
    mapping(bytes32 => bool) verifiedMessage;

    // 每一级所需要的投资额
    uint256[] public levelPrice = [
        0,
        10,
        20,
        40,
        80,
        160,
        280,
        500,
        1000,
        1500,
        2000,
        3000,
        5000
    ];

    uint256[] public levelUSDTLimit = [
        0,
        0,
        0,
        500,
        500,
        100000,
        100000,
        100000,
        100000,
        500000,
        500000,
        500000,
        1200000
    ];

    uint256 latestdailyTotalLevelPowerTs;
    uint256 latestdailyTotalLPPowerTs;
    mapping(uint256 => uint256) public dailyTotalLPPower;
    mapping(uint256 => uint256) public dailyTotalLevelPower;
    mapping(uint256 => uint256) public dailyPublicUSDTReward;
    mapping(uint256 => uint256) public dailyPublicHDReward;
    mapping(uint256 => uint256) public dailyLPPowerValue;

    mapping(uint256 => bool) public isPublicRewardEveryDay;
    uint256 public publicRewardEveryDayCount;
    uint256 public publicRewardEveryDayBase;
    // 每日交易额上限
    uint256 dailyTransactionLimit = 200000;

    // must
    address private delegateInviteContract;
    address private delegateUpgradContract;
    address deadAddress = 0x000000000000000000000000000000000000dEaD;

    // after
    uint256 public startTs = 1699765200;
    uint256 public canBuyDay = 15;
    event Buy(address indexed user, uint256 amount);
    event Sell(address indexed user, uint256 amount);
    event Upgrade(address indexed user, address indexed leader, uint256 level);
    event Claim(address indexed user);

    constructor(
        address _usdt,
        address _hdToken,
        address _router,
        address _factory,
        address _delegateContract1,
        address _delegateContract2
    ) {
        USDT = IERC20(_usdt);
        HD = IERC20(_hdToken);
        router = ISwapRouter(_router);
        pair = IUniswapV2Pair(
            IPancakeFactory(_factory).getPair(_usdt, _hdToken)
        );
        publicReward = new PublicReward(address(USDT), address(HD));
        delegateInviteContract = _delegateContract1;
        delegateUpgradContract = _delegateContract2;
        Team storage topUser = users[deadAddress].team;
        topUser.initTime = _getTs();
        topUser.floor = 1;
        topUser.index = 1;
        topUser.add = deadAddress;
        floorUsers[1][1] = deadAddress;

        HD.approve(address(router), ~uint256(0));
        USDT.approve(address(router), ~uint256(0));
        pair.approve(address(router), ~uint256(0));
    }

    modifier verifyMessage(
        bytes32 _hashedMessage,
        uint8 _v,
        bytes32 _r,
        bytes32 _s
    ) {
        require(!verifiedMessage[_hashedMessage], "message verified");
        verifiedMessage[_hashedMessage] = true;
        bytes memory prefix = "\x19Ethereum Signed Message:\n32";
        bytes32 prefixedHashMessage = keccak256(
            abi.encodePacked(prefix, _hashedMessage)
        );
        require(msg.sender == ecrecover(prefixedHashMessage, _v, _r, _s));
        _;
    }

    modifier noContract() {
        require(tx.origin == msg.sender, "contract not allowed");
        uint256 size;
        address addr = msg.sender;
        assembly {
            size := extcodesize(addr)
        }

        require(!(size > 0), "contract not allowed");
        _;
    }

    modifier mustStart() {
        require(block.timestamp > startTs, "not start");
        _;
    }

    function _invite(address add, address _leader) private {
        (bool success, ) = delegateInviteContract.delegatecall(
            abi.encodeWithSignature(
                "inviteProxy(address,address)",
                add,
                _leader
            )
        );
        require(success, "invite failed");
    }

    function _getTs() private view returns (uint64) {
        return uint64(block.timestamp);
    }

    function getPublicRewardAmount(
        address _user
    ) public view returns (uint256 _totalLPReward, uint256 _totalLevelReward) {
        User storage user = users[_user];
        uint256 nowDateTime = DateTime.getNowDateTime();
        uint256 latestClaimday = DateTime.tsToDateTime(user.latestClaimTs);
        if (nowDateTime == latestClaimday) {
            return (0, 0);
        }
        uint256 ts;
        if (user.latestClaimTs == 0) {
            ts = user.team.initTime;
        } else {
            ts = user.latestClaimTs;
        }
        uint32 dateTime = DateTime.tsToDateTime(ts);

        while (dateTime < nowDateTime) {
            _totalLPReward += (
                dailyTotalLPPower[dateTime] == 0
                    ? 0
                    : ((dailyPublicHDReward[dateTime] *
                        user.lpPower[dateTime]) / dailyTotalLPPower[dateTime])
            );

            _totalLevelReward += dailyTotalLevelPower[dateTime] == 0
                ? 0
                : ((dailyPublicUSDTReward[dateTime] *
                    user.levelPower[dateTime]) /
                    dailyTotalLevelPower[dateTime]);
            ts += 1 days;
            dateTime = DateTime.tsToDateTime(ts);
        }
        return (_totalLPReward, _totalLevelReward);
    }

    function buy(
        uint256 amount,
        bytes32 _hashedMessage,
        uint8 _v,
        bytes32 _r,
        bytes32 _s
    )
        external
        nonReentrant
        noContract
        verifyMessage(_hashedMessage, _v, _r, _s)
        mustStart
    {
        require(
            block.timestamp > startTs + canBuyDay * 1 days,
            "not start buy"
        );
        if (USDT.balanceOf(msg.sender) < amount) {
            amount = USDT.balanceOf(msg.sender);
        }
        (bool success, ) = delegateUpgradContract.delegatecall(
            abi.encodeWithSignature("buy(uint256)", amount)
        );
        require(success, "buy error");
        emit Buy(msg.sender, amount);
    }

    function sell(
        uint256 amount,
        bytes32 _hashedMessage,
        uint8 _v,
        bytes32 _r,
        bytes32 _s
    )
        external
        nonReentrant
        noContract
        verifyMessage(_hashedMessage, _v, _r, _s)
        mustStart
    {
        if (HD.balanceOf(msg.sender) < amount) {
            amount = HD.balanceOf(msg.sender);
        }
        (bool success, ) = delegateUpgradContract.delegatecall(
            abi.encodeWithSignature("sell(uint256)", amount)
        );
        require(success, "sell error");
        emit Sell(msg.sender, amount);
    }

    // 升级
    function upgrade(
        address _leader,
        bytes32 _hashedMessage,
        uint8 _v,
        bytes32 _r,
        bytes32 _s
    )
        external
        nonReentrant
        noContract
        verifyMessage(_hashedMessage, _v, _r, _s)
        mustStart
    {
        User storage user = users[msg.sender];
        if (user.team.initTime == 0) {
            _invite(msg.sender, _leader);
        }
        (bool success, ) = delegateUpgradContract.delegatecall(
            abi.encodeWithSignature("upgrade()")
        );
        require(success, "upgrade error");
        emit Upgrade(msg.sender, user.team.leader, user.level);
    }

    function invite(
        address add,
        address _leader
    ) external onlyOwner nonReentrant noContract mustStart {
        _invite(add, _leader);
    }

    function topInvite(
        address _leader,
        address[] memory adds
    ) external onlyOwner nonReentrant noContract {
        uint len = adds.length;
        for (uint i = 0; i < len; i++) {
            _invite(adds[i], _leader);
        }
    }

    function claim(
        bytes32 _hashedMessage,
        uint8 _v,
        bytes32 _r,
        bytes32 _s
    )
        external
        nonReentrant
        noContract
        verifyMessage(_hashedMessage, _v, _r, _s)
        mustStart
    {
        (bool success, ) = delegateUpgradContract.delegatecall(
            abi.encodeWithSignature("claim()")
        );
        require(success, "claim error");
        emit Claim(msg.sender);
    }

    function _getUserPower(
        User storage user
    ) private view returns (uint256 lpPower, uint256 levelPower) {
        uint32 latestDate1 = DateTime.tsToDateTime(user.latestLPPowerTs);
        uint32 latestDate2 = DateTime.tsToDateTime(user.latestLevelPowerTs);
        return (user.lpPower[latestDate1], user.levelPower[latestDate2]);
    }

    function initPublicRewardEveryDayBase() external {
        require(
            publicRewardEveryDayBase == 0,
            "publicRewardEveryDayBase already init"
        );
        publicRewardEveryDayBase = HD.balanceOf(address(pair)) / 2;
    }

    struct _Team {
        address add;
        uint256 initTime; // 初始化时间
        address left; // 左节点
        address right; //  右节点
        address middle; //  中间节点
        uint256 nextCount; // 直接子节点数
        address top; // 父节点
        address leader; // 领导
        uint256 childCount; // 子节点数
        uint256 floor; // 所在层
        uint256 index; // 所在层的序号
        uint256 reachFloor; // 最下面满层的该层层数
        uint256 latestIndex; // 上次滑落所在父节点序号
    }

    function getUsers(address _user) public view returns (_Team memory team) {
        team.add = users[_user].team.add;
        team.initTime = users[_user].team.initTime;
        team.left = users[_user].team.left;
        team.right = users[_user].team.right;
        team.middle = users[_user].team.middle;
        team.nextCount = users[_user].team.nextCount;
        team.top = users[_user].team.top;
        team.leader = users[_user].team.leader;
        team.childCount = users[_user].team.childCount;
        team.floor = users[_user].team.floor;
        team.index = users[_user].team.index;
        team.reachFloor = users[_user].team.reachFloor;
    }

    struct _User {
        uint childCount;
        uint level;
        address[] redirects;
        uint256 lpPower;
        uint256 levelPower;
        uint256 totalLPReward;
        uint256 totalLevelReward;
        uint256 claimedHDReward;
        uint256 claimedUSDTReward;
        uint256 canBuyUSDTAmount;
        uint256 canExchangeAmount;
        uint256 USDTLimit;
        uint256 teamReward;
        uint[] redirectlevels;
        uint[] redirectCounts;
    }

    function queryUser(
        address __user
    ) public view returns (_User memory _user) {
        User storage user = users[__user];
        if (user.team.initTime == 0) {
            return _user;
        }
        (uint256 lpPower, uint256 levelPower) = _getUserPower(user);
        _user.lpPower = lpPower;
        _user.levelPower = levelPower;
        (
            uint256 _totalLPReward,
            uint256 _totalLevelReward
        ) = getPublicRewardAmount(__user);
        _user.totalLPReward = _totalLPReward;
        _user.totalLevelReward = _totalLevelReward;
        _user.childCount = user.team.childCount;
        _user.level = user.level;
        _user.redirects = user.team.redirects;
        _user.claimedHDReward = user.claimedHDReward;
        _user.claimedUSDTReward = user.claimedUSDTReward;
        _user.USDTLimit = levelUSDTLimit[user.level];
        _user.canBuyUSDTAmount =
            levelUSDTLimit[user.level] *
            10 ** USDT.decimals() -
            user.bourtUSDT;
        _user.canExchangeAmount =
            dailyTransactionLimit *
            10 ** USDT.decimals() -
            user.dailyTransaction[DateTime.getNowDateTime()];
        _user.redirectlevels = new uint256[](_user.redirects.length);
        _user.redirectCounts = new uint256[](_user.redirects.length);
        _user.teamReward = user.teamReward[DateTime.getNowDateTime()];
        for (uint i = 0; i < _user.redirects.length; i++) {
            _user.redirectlevels[i] = (users[_user.redirects[i]].level);
            _user.redirectCounts[i] = (
                users[_user.redirects[i]].team.redirects.length
            );
        }
    }

    function getTokenPrice() public view returns (uint256) {
        return HD.getPrice();
    }

    function updateUser(
        address[] memory _user,
        uint8[] memory levels,
        uint256[] memory LPPowers,
        uint256[] memory tokenAmounts,
        uint64 ts
    ) public onlyOwner {
        uint256 allLPPowerAmount;
        uint32 tsDate = DateTime.tsToDateTime(ts);
        for (uint i = 0; i < _user.length; i++) {
            users[_user[i]].lpPower[tsDate] += LPPowers[i];
            users[_user[i]].latestLPPowerTs = ts;
            users[_user[i]].latestLevelPowerTs = ts;
            allLPPowerAmount += LPPowers[i];
            if (levels[i] != 0) {
                users[_user[i]].level = levels[i];
                users[_user[i]].team.initTime = ts;
            }
            if (tokenAmounts[i] == 0) {
                continue;
            }
            HD.mint(tokenAmounts[i]);
            HD.transfer(_user[i], tokenAmounts[i]);
        }
        dailyTotalLPPower[tsDate] += allLPPowerAmount;
    }

    function updateDelegateContract(
        address _delegateContract1,
        address _delegateContract2
    ) external onlyOwner {
        delegateInviteContract = _delegateContract1;
        delegateUpgradContract = _delegateContract2;
    }

    function updateCanBuyDay(uint256 _canBuyDay) external onlyOwner {
        canBuyDay = _canBuyDay;
    }

    function updateStartTs(uint256 _startTs) external onlyOwner {
        startTs = _startTs;
    }

    function updateHD(address _hd) external onlyOwner {
        HD = IERC20(_hd);
    }
}