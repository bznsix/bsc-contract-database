// SPDX-License-Identifier: MIT

pragma solidity ^0.8.19;

interface IERC20 {
    function decimals() external view returns (uint8);

    function symbol() external view returns (string memory);

    function name() external view returns (string memory);

    function totalSupply() external view returns (uint256);

    function balanceOf(address account) external view returns (uint256);

    function transfer(address recipient, uint256 amount) external returns (bool);

    function allowance(address owner, address spender) external view returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);

    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

abstract contract Ownable {
    address internal _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor () {
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

interface IToken {
    function bindInvitor(address account, address invitor) external;

    function getTeamInvitor(address account, uint256 len) external view returns (address[] memory);

    function _teamNum(address account) external view returns (uint256);

    function getBinderLength(address account) external view returns (uint256);

    function _binders(address account, uint256 i) external view returns (address);

    function getUserTokenInfo(address account) external view returns (
        uint256 tokenBalance, uint256 lastTransferTime
    );
}

abstract contract AbsPool is Ownable {
    struct PoolInfo {
        uint256 gameId;
        uint256 perAmount;
        uint256 maxLen;
        bool pause;
        bool oneWin;
        uint256 feeRate;
        uint256 lastGameBlockNum;
        uint256 lastSeedIndex;
        uint256 burnRate;
    }

    struct UserInfo {
        bool active;
        uint256 pendingAmount;
        uint256 lastReleaseTime;
        uint256 releaseAmountPerDay;
        uint256 calAmount;
        uint256 claimedAmount;
        uint256 teamAmount;
        uint256 pendingTeamReward;
        uint256 claimedTeamReward;
        uint256 accPendingAmount;
    }

    PoolInfo[] private _poolInfo;
    mapping(uint256 => mapping(uint256 => address[])) public _poolAccounts;
    mapping(uint256 => mapping(uint256 => uint256)) public _poolWinSeed;

    mapping(address => UserInfo) private _userInfo;

    address private _tokenAddress;

    mapping(uint256 => uint256) public _teamRewardRate;
    mapping(uint256 => uint256) public _teamRewardCondition;

    mapping(uint256 => uint256) public _inviteFee;
    uint256 private constant _inviteLen = 2;
    uint256 private constant _teamLen = 20;
    uint256 private constant _maxLevel = 5;
    uint256 public _sameLevelRate = 1000;

    uint256 private constant _dailyDuration = 1 days;
    uint256 public _releaseDays = 90;
    address public _feeAddress;
    address public _burnAddress = address(0x000000000000000000000000000000000000dEaD);

    uint256 public _claimTeamFee = 1000;
    uint256 public _lossReleaseRate = 9000;

    constructor(
        address TokenAddress, address FeeAddress
    ){
        _tokenAddress = TokenAddress;
        uint256 tokenUnit = 10 ** IERC20(_tokenAddress).decimals();
        _createPool(100 * tokenUnit, 10, false, true, 1000, 1000);
        _createPool(1000 * tokenUnit, 10, false, true, 1000, 1000);
        _createPool(10000 * tokenUnit, 10, false, true, 1000, 1000);
        _createPool(100 * tokenUnit, 10, false, false, 1000, 1000);
        _createPool(1000 * tokenUnit, 10, false, false, 1000, 1000);
        _createPool(10000 * tokenUnit, 10, false, false, 1000, 1000);
        _createPool(100 * tokenUnit, 20, true, true, 1000, 1000);
        _createPool(1000 * tokenUnit, 20, true, true, 1000, 1000);
        _createPool(10000 * tokenUnit, 20, false, true, 1000, 1000);

        _inviteFee[0] = 100;
        _inviteFee[1] = 50;

        _teamRewardRate[1] = 20;
        _teamRewardRate[2] = 40;
        _teamRewardRate[3] = 60;
        _teamRewardRate[4] = 80;
        _teamRewardRate[5] = 100;
        _teamRewardCondition[1] = 100000 * tokenUnit;
        _teamRewardCondition[2] = 300000 * tokenUnit;
        _teamRewardCondition[3] = 900000 * tokenUnit;
        _teamRewardCondition[4] = 3000000 * tokenUnit;
        _teamRewardCondition[5] = 10000000 * tokenUnit;

        _rewardCondition = 20000 * tokenUnit;
        _feeAddress = FeeAddress;
    }

    function _createPool(uint256 perAmount, uint256 maxLen, bool pause, bool oneWin, uint256 feeRate, uint256 burnRate) private {
        _poolInfo.push(PoolInfo({
        gameId : 0,
        perAmount : perAmount,
        maxLen : maxLen,
        pause : pause,
        oneWin : oneWin,
        feeRate : feeRate,
        lastGameBlockNum : 0,
        lastSeedIndex : 0,
        burnRate : burnRate
        }));
    }

    function join(uint256 index, address invitor) external {
        address account = msg.sender;
        require(tx.origin == account, "Ori");
        PoolInfo storage poolInfo = _poolInfo[index];
        require(!poolInfo.pause, "pause");
        uint256 gameId = poolInfo.gameId;

        UserInfo storage userInfo = _userInfo[account];
        address tokenAddress = _tokenAddress;
        if (!userInfo.active) {
            if (_userInfo[invitor].active) {
                IToken(tokenAddress).bindInvitor(account, invitor);
            }
            userInfo.active = true;
        }

        _poolAccounts[index][gameId].push(account);

        uint256 perAmount = poolInfo.perAmount;
        _takeToken(tokenAddress, account, address(this), perAmount);

        _calTeamAmount(tokenAddress, account, perAmount);

        uint256 blockNum = block.number;
        if (_poolAccounts[index][gameId].length >= poolInfo.maxLen) {
            require(blockNum != poolInfo.lastGameBlockNum, "NextBlock");
            _calGame(index, gameId);
            poolInfo.gameId = gameId + 1;
        } else {
            poolInfo.lastGameBlockNum = blockNum;
        }
    }

    function claimGameReward() public {
        address account = msg.sender;
        UserInfo storage userInfo = _userInfo[account];
        uint256 pending = userInfo.calAmount;

        uint256 pendingAmount = userInfo.pendingAmount;
        uint256 nowTime = block.timestamp;
        uint256 releaseAmount = getReleaseAmount(userInfo, pendingAmount, nowTime);
        if (releaseAmount > 0) {
            pending += releaseAmount;
            userInfo.pendingAmount = pendingAmount - releaseAmount;
            userInfo.lastReleaseTime = nowTime;
        }
        if (pending > 0) {
            userInfo.calAmount = 0;
            userInfo.claimedAmount += pending;
            _giveToken(_tokenAddress, account, pending);
        }
    }

    function getReleaseAmount(UserInfo storage userInfo, uint256 pendingAmount, uint256 nowTime) private view returns (uint256 releaseAmount){
        releaseAmount = 0;
        if (pendingAmount > 0) {
            releaseAmount = userInfo.releaseAmountPerDay * (nowTime - userInfo.lastReleaseTime) / _dailyDuration;
            if (releaseAmount > pendingAmount) {
                releaseAmount = pendingAmount;
            }
        }
    }

    function claimTeamReward() public {
        address account = msg.sender;
        UserInfo storage userInfo = _userInfo[account];
        uint256 pending = userInfo.pendingTeamReward;
        if (pending > 0) {
            userInfo.pendingTeamReward = 0;
            uint256 feeAmount = pending * _claimTeamFee / 10000;
            address tokenAddress = _tokenAddress;
            if (feeAmount > 0) {
                _giveToken(tokenAddress, _feeAddress, feeAmount);
                pending -= feeAmount;
            }
            userInfo.claimedTeamReward += pending;
            _giveToken(tokenAddress, account, pending);
        }
    }

    function _calTeamAmount(address tokenAddress, address account, uint256 perAmount) private {
        address [] memory invitors = IToken(tokenAddress).getTeamInvitor(account, _teamLen);
        uint256 lastRewardLevel;
        uint256 lastSameLevel;
        uint256 teamReward;
        address invitor;
        for (uint256 i = 0; i < _teamLen;) {
            invitor = invitors[i];
            if (address(0) == invitor) {
                break;
            }
            _userInfo[invitor].teamAmount += perAmount;
            if (i < _inviteLen) {
                uint256 inviteAmount = perAmount * _inviteFee[i] / 10000;
                _userInfo[invitor].pendingTeamReward += inviteAmount;
            }
            uint256 invitorLevel = _getInvitorLevel(invitor, lastRewardLevel);
            if (invitorLevel > lastRewardLevel) {
                uint256 rewardRate = _teamRewardRate[invitorLevel] - _teamRewardRate[lastRewardLevel];
                teamReward = rewardRate * perAmount / 10000;
                lastRewardLevel = invitorLevel;
                _userInfo[invitor].pendingTeamReward += teamReward;
            } else if (invitorLevel > lastSameLevel && invitorLevel == lastRewardLevel) {
                lastSameLevel = invitorLevel;
                _userInfo[invitor].pendingTeamReward += teamReward * _sameLevelRate / 10000;
                if (lastSameLevel >= _maxLevel) {
                    break;
                }
            }
        unchecked{
            ++i;
        }
        }
    }

    function _calGame(uint256 poolId, uint256 gameId) private {
        PoolInfo storage poolInfo = _poolInfo[poolId];
        address[] storage accounts = _poolAccounts[poolId][gameId];
        uint256 seed = uint256(blockhash(poolInfo.lastGameBlockNum));
        if (0 == seed) {
            seed = poolInfo.lastSeedIndex + 1;
            poolInfo.lastSeedIndex = seed;
        }
        _poolWinSeed[poolId][gameId] = seed;
        uint256 len = accounts.length;
        uint256 randomIndex = seed % len;
        uint256 perAmount = poolInfo.perAmount;
        uint256 winAmount = perAmount * len;
        bool oneWin = poolInfo.oneWin;
        uint256 feeAmount;
        uint256 burnAmount;
        if (oneWin) {
            feeAmount = winAmount * poolInfo.feeRate / 10000;
            burnAmount = winAmount * poolInfo.burnRate / 10000;
        } else {
            feeAmount = perAmount * poolInfo.feeRate / 10000;
            burnAmount = perAmount * poolInfo.burnRate / 10000;
        }
        address tokenAddress = _tokenAddress;
        if (feeAmount > 0) {
            _giveToken(tokenAddress, _feeAddress, feeAmount);
        }
        if (burnAmount > 0) {
            _giveToken(tokenAddress, _burnAddress, burnAmount);
        }
        winAmount = winAmount - feeAmount - burnAmount;
        uint256 lossReleaseAmount = perAmount * _lossReleaseRate / 10000;
        if (oneWin) {
            for (uint256 i = 0; i < len;) {
                if (randomIndex == i) {
                    _userInfo[accounts[i]].calAmount += winAmount;
                } else {
                    _addReleaseAmount(accounts[i], lossReleaseAmount);
                }
            unchecked{
                ++i;
            }
            }
        } else {
            winAmount = winAmount / (len - 1);
            for (uint256 i = 0; i < len;) {
                if (randomIndex == i) {
                    _addReleaseAmount(accounts[i], lossReleaseAmount);
                } else {
                    _userInfo[accounts[i]].calAmount += winAmount;
                }
            unchecked{
                ++i;
            }
            }
        }
    }

    function _addReleaseAmount(address account, uint256 amount) private {
        UserInfo storage userInfo = _userInfo[account];
        uint256 pendingAmount = userInfo.pendingAmount;
        uint256 nowTime = block.timestamp;
        uint256 releaseAmount = getReleaseAmount(userInfo, pendingAmount, nowTime);
        if (releaseAmount > 0) {
            userInfo.calAmount += releaseAmount;
            pendingAmount -= releaseAmount;
        }

        pendingAmount += amount;
        userInfo.pendingAmount = pendingAmount;
        userInfo.releaseAmountPerDay = pendingAmount / _releaseDays;
        userInfo.lastReleaseTime = nowTime;
        userInfo.accPendingAmount += amount;
    }

    function _getInvitorLevel(
        address invitor, uint256 lowLevel
    ) private view returns (uint256){
        if (0 == lowLevel) {
            lowLevel = 1;
        }
        uint256 teamAmount = _userInfo[invitor].teamAmount;
        for (uint256 i = lowLevel; i <= _maxLevel;) {
            if (teamAmount < _teamRewardCondition[i]) {
                return i - 1;
            }
        unchecked{
            ++i;
        }
        }
        return _maxLevel;
    }

    function _takeToken(address tokenAddress, address account, address to, uint256 amount) private {
        if (0 == amount) {
            return;
        }
        IERC20 token = IERC20(tokenAddress);
        uint256 tokenBalance = token.balanceOf(to);
        token.transferFrom(account, to, amount);
        require(token.balanceOf(to) - tokenBalance >= amount, "TFF");
    }

    function _giveToken(address tokenAddress, address account, uint256 amount) private {
        if (0 == amount) {
            return;
        }
        IERC20(tokenAddress).transfer(account, amount);
    }

    function getBaseInfo() external view returns (
        address tokenAddress, uint256 tokenDecimals, string memory tokenSymbol
    ){
        tokenAddress = _tokenAddress;
        tokenDecimals = IERC20(tokenAddress).decimals();
        tokenSymbol = IERC20(tokenAddress).symbol();
    }

    function getOriPoolInfo(uint256 poolId) public view returns (
        uint256 gameId,
        uint256 perAmount,
        uint256 maxLen,
        bool pause,
        bool oneWin,
        uint256 feeRate,
        uint256 lastGameBlockNum,
        uint256 lastSeedIndex,
        uint256 burnRate
    ){
        PoolInfo storage poolInfo = _poolInfo[poolId];
        gameId = poolInfo.gameId;
        perAmount = poolInfo.perAmount;
        maxLen = poolInfo.maxLen;
        pause = poolInfo.pause;
        oneWin = poolInfo.oneWin;
        feeRate = poolInfo.feeRate;
        lastGameBlockNum = poolInfo.lastGameBlockNum;
        lastSeedIndex = poolInfo.lastSeedIndex;
        burnRate = poolInfo.burnRate;
    }

    function getGameInfo(uint256 poolId) public view returns (
        uint256 gameId,
        uint256 perAmount,
        uint256 maxLen,
        bool pause,
        uint256 joinLen
    ){
        PoolInfo storage poolInfo = _poolInfo[poolId];
        gameId = poolInfo.gameId;
        perAmount = poolInfo.perAmount;
        maxLen = poolInfo.maxLen;
        pause = poolInfo.pause;
        joinLen = _poolAccounts[poolId][gameId].length;
    }

    function getGameInfos(uint256[] memory poolIds) public view returns (
        uint256[] memory gameIds,
        uint256[] memory perAmounts,
        uint256[] memory maxLens,
        bool[] memory pauses,
        uint256[] memory joinLens
    ){
        uint256 len = poolIds.length;
        gameIds = new uint256[](len);
        perAmounts = new uint256[](len);
        maxLens = new uint256[](len);
        pauses = new bool[](len);
        joinLens = new uint256[](len);
        for (uint256 i = 0; i < len; ++i) {
            (gameIds[i], perAmounts[i], maxLens[i], pauses[i], joinLens[i]) = getGameInfo(poolIds[i]);
        }
    }

    function getPoolLen() public view returns (uint256){
        return _poolInfo.length;
    }

    function getPoolAccountsLen(uint256 poolId, uint256 gameId) public view returns (uint256){
        return _poolAccounts[poolId][gameId].length;
    }

    function getPoolAccounts(uint256 poolId, uint256 gameId) public view returns (address[] memory){
        return _poolAccounts[poolId][gameId];
    }

    function getOriUserInfo(address account) public view returns (
        uint256 pendingAmount,
        uint256 lastReleaseTime,
        uint256 releaseAmountPerDay,
        uint256 calAmount
    ){
        UserInfo storage userInfo = _userInfo[account];
        pendingAmount = userInfo.pendingAmount;
        lastReleaseTime = userInfo.lastReleaseTime;
        releaseAmountPerDay = userInfo.releaseAmountPerDay;
        calAmount = userInfo.calAmount;
    }

    function getUserInfo(address account) public view returns (
        bool active,
        uint256 accPendingAmount,
        uint256 pendingReleaseAmount,
        uint256 pendingClaimAmount,
        uint256 claimedAmount,
        uint256 tokenBalance,
        uint256 tokenAllowance
    ){
        UserInfo storage userInfo = _userInfo[account];
        active = userInfo.active;
        accPendingAmount = userInfo.accPendingAmount;
        pendingReleaseAmount = userInfo.pendingAmount;
        uint256 releaseAmount = getReleaseAmount(userInfo, pendingReleaseAmount, block.timestamp);
        pendingClaimAmount = userInfo.calAmount + releaseAmount;
        pendingReleaseAmount -= releaseAmount;
        claimedAmount = userInfo.claimedAmount;
        tokenBalance = IERC20(_tokenAddress).balanceOf(account);
        tokenAllowance = IERC20(_tokenAddress).allowance(account, address(this));
    }

    function getUserTeamInfo(address account) public view returns (
        uint256 teamAmount,
        uint256 pendingTeamReward,
        uint256 claimedTeamReward,
        address invitor,
        uint256 teamNum,
        uint256 binderLen,
        uint256 level
    ){
        UserInfo storage userInfo = _userInfo[account];
        teamAmount = userInfo.teamAmount;
        pendingTeamReward = userInfo.pendingTeamReward;
        claimedTeamReward = userInfo.claimedTeamReward;
        invitor = IToken(_tokenAddress).getTeamInvitor(account, 1)[0];
        teamNum = IToken(_tokenAddress)._teamNum(account);
        binderLen = IToken(_tokenAddress).getBinderLength(account);
        level = _getInvitorLevel(account, 0);
    }

    function getBinderList(
        address account,
        uint256 start,
        uint256 len
    ) external view returns (
        address[] memory binderList,
        bool[] memory activeList
    ){
        IToken token = IToken(_tokenAddress);
        uint256 binderLen = token.getBinderLength(account);
        if (start > binderLen) {
            start = binderLen;
        }
        if (0 == len || len > binderLen - start) {
            len = binderLen - start;
        }
        binderList = new address[](len);
        activeList = new bool[](len);
        uint256 index = 0;
        for (uint256 i = start; i < start + len; i++) {
            address binder = token._binders(account, i);
            binderList[index] = binder;
            activeList[index] = _userInfo[binder].active;
            index++;
        }
    }

    function claimBalance(address to, uint256 amount) external onlyOwner {
        address payable addr = payable(to);
        addr.transfer(amount);
    }

    function claimToken(address erc20Address, address to, uint256 amount) external onlyOwner {
        IERC20 erc20 = IERC20(erc20Address);
        erc20.transfer(to, amount);
    }

    function setTokenAddress(address adr) external onlyOwner {
        _tokenAddress = adr;
    }

    function setFeeAddress(address adr) external onlyOwner {
        _feeAddress = adr;
    }

    function setBurnAddress(address adr) external onlyOwner {
        _burnAddress = adr;
    }

    function setPoolPause(uint256 i, bool pause) public onlyOwner {
        _poolInfo[i].pause = pause;
    }

    function setPoolAmount(uint256 i, uint256 amount) public onlyOwner {
        uint256 gameId = _poolInfo[i].gameId;
        require(0 == _poolAccounts[i][gameId].length, "start");
        _poolInfo[i].perAmount = amount;
    }

    function setPoolFeeRate(uint256 i, uint256 fee) public onlyOwner {
        _poolInfo[i].feeRate = fee;
    }

    function setPoolBurnRate(uint256 i, uint256 burn) public onlyOwner {
        _poolInfo[i].burnRate = burn;
    }

    function setPoolMaxLen(uint256 i, uint256 max) public onlyOwner {
        require(max > 1, "min=2");
        _poolInfo[i].maxLen = max;
    }

    function addPool(uint256 perAmount, uint256 maxLen, bool pause, bool oneWin, uint256 feeRate, uint256 burnRate) public onlyOwner {
        require(maxLen > 1, "min=2");
        _createPool(perAmount, maxLen, pause, oneWin, feeRate, burnRate);
    }

    function setTeamRewardRate(uint256 i, uint256 r) external onlyOwner {
        _teamRewardRate[i] = r;
    }

    function setTeamRewardCondition(uint256 i, uint256 c) external onlyOwner {
        _teamRewardCondition[i] = c;
    }

    function setInviteFee(uint256 i, uint256 f) external onlyOwner {
        _inviteFee[i] = f;
    }

    function setSameLevelRate(uint256 r) external onlyOwner {
        _sameLevelRate = r;
    }

    function setReleaseDays(uint256 ds) external onlyOwner {
        _releaseDays = ds;
    }

    uint256 public _startRewardTime = 0;
    uint256 public _rewardRate = 49938;
    uint256 private constant _rewardFactor = 100000000;
    uint256 public _rewardDuration = 4 hours;
    uint256 public _rewardCondition;
    mapping(address => uint256) private _claimedAprReward;

    function claimAprReward() public {
        address account = msg.sender;
        require(tx.origin == account, "Ori");
        uint256 pendingAprReward = calPendingAprReward(account);
        if (pendingAprReward > 0) {
            _giveToken(_tokenAddress, account, pendingAprReward);
            _claimedAprReward[account] += pendingAprReward;
        }
    }

    function calPendingAprReward(address account) public view returns (uint256) {
        (uint256 buyAmount, uint256 lastRewardTime) = IToken(_tokenAddress).getUserTokenInfo(account);
        uint256 startTime = _startRewardTime;
        if (0 == startTime) {
            return 0;
        }

        uint256 rewardRate = _rewardRate;
        if (0 == rewardRate) {
            return 0;
        }

        if (buyAmount < _rewardCondition) {
            return 0;
        }
        if (lastRewardTime == 0) {
            lastRewardTime = startTime;
        }

        if (lastRewardTime < startTime) {
            lastRewardTime = startTime;
        }

        uint256 blockTime = block.timestamp;
        if (blockTime <= lastRewardTime) {
            return 0;
        }

        uint256 rewardDuration = _rewardDuration;
        uint256 times = (blockTime - lastRewardTime) / rewardDuration;
        uint256 reward;
        uint256 totalReward;
        for (uint256 i; i < times;) {
            reward = buyAmount * rewardRate / _rewardFactor;
            totalReward += reward;
            buyAmount += reward;
        unchecked{
            ++i;
        }
        }
        return totalReward;
    }

    function getUserAprReward(address account) public view returns (uint256 claimed, uint256 pending){
        claimed = _claimedAprReward[account];
        pending = calPendingAprReward(account);
    }

    function setStartRewardTime(uint256 time) external onlyOwner {
        _startRewardTime = time;
    }

    function startRewardTime() external onlyOwner {
        _startRewardTime = block.timestamp;
    }

    function setRewardRate(uint256 rate) external onlyOwner {
        _rewardRate = rate;
    }

    function setRewardCondition(uint256 c) external onlyOwner {
        _rewardCondition = c;
    }

    function setRewardDuration(uint256 d) external onlyOwner {
        _rewardDuration = d;
    }

    function setClaimTeamFee(uint256 f) external onlyOwner {
        _claimTeamFee = f;
    }

    function setLossReleaseRate(uint256 r) external onlyOwner {
        _lossReleaseRate = r;
    }
}

contract Game is AbsPool {
    constructor() AbsPool(
        address(0xF0B3F3a8e3C7aB7f8723225f65136aefA20Ec1F8),
        address(0xb8f12fB5B3F73998D2C6715790981f1Cb3A62AF4)
    ){

    }
}