// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import "@chainlink/contracts/src/v0.8/VRFV2WrapperConsumerBase.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/proxy/utils/Initializable.sol";



contract MoneyTree is VRFV2WrapperConsumerBase, ReentrancyGuard, Initializable, Ownable {
    using SafeERC20 for IERC20;
    using EnumerableSet for EnumerableSet.AddressSet;

    uint256 public constant DIVIDER = 10000;

    enum Group { DEV, POOL_A, POOL_B, POOL_C, LOTTERY, TRADING, TOTAL }

    struct UserInfo {
        Group group;
        bool deposited;
        uint256 totalReceived;
        uint256 availableToClaim;
        uint256 numberOfReferrals;
        uint256 lastEpochAddReferrals;
        bool winner;
        uint256 depositTimestamp;
    }

    struct GroupInfo {
        uint256 depositSize;
        uint256 maxPayout;
        uint256 distributionPercent;
    }

    struct RequestStatus {
        uint256 paid;
        bool fulfilled;
        uint256[] randomWords;
    }

    struct Values {
        uint256 distributeAmountDev;     
        uint256 distributeAmountPoolA;     
        uint256 distributeAmountPoolB;     
        uint256 distributeAmountPoolC;     
        uint256 distributeAmountLottery;
        uint256 distributeAmountTrading;     
        uint256 devPaymentAmount;
        address recipient;

        uint256 maxPoolAmountForBonusROI;
        uint256 maxUsersForROIBonus;
        uint256 usersForROIBonus;
        uint256 len;

        uint256 winnerIndex;
        address winnerAddress;
        uint256 winnerPayment;
        bool winnersStayInList;
        uint256 numberOfWinnersStayInList;

        uint256 numberUsersInPool;
        uint256 distributePayment;
        uint256 maxPayout;
        uint256 recieved;
    } 

    address public token;
    address public tradingAccount;

    uint256 public poolStartTime;

    uint256 private distributeAmountPoolAStorage;     
    uint256 private distributeAmountPoolBStorage;     
    uint256 private distributeAmountPoolCStorage;     
    uint256 private distributeAmountLotteryStorage;  

    uint256 private previousBlockNumber;

    uint256 private nonce;

    address public linkToken;
    address public vrfV2Wrapper;

    address public keeper;

    uint256[] public requestIds;
    uint256 public lastRequestId;

    uint32 private callbackGasLimit = 500000;
    uint16 private requestConfirmations = 3;

    uint32 private numWords = 4;

    EnumerableSet.AddressSet private _dev;
    EnumerableSet.AddressSet private _stakersPoolA;
    EnumerableSet.AddressSet private _stakersPoolB;
    EnumerableSet.AddressSet private _stakersPoolC;
    EnumerableSet.AddressSet private _stakersTotal;

    EnumerableSet.AddressSet private _stakersPool_A_B;
    EnumerableSet.AddressSet private _winnerList;

    mapping(address => UserInfo) public userInfo;
    mapping(Group => GroupInfo) public groupInfo;

    mapping(uint256 => mapping(Group => address[])) private epochUsersByGroup;   
    mapping(uint256 => mapping(address => uint256)) private epochUserIndex;
    mapping(uint256 => mapping(address => bool)) private isUserInEpochList;

    mapping(uint256 => uint256) private epochDepositAmount;

    mapping(uint256 => bool) private isEpochDistributed;
    mapping(address => Group) private winnerGroup;

    mapping(uint256 => mapping(uint256 => bool)) private epochStepDone;

    mapping(uint256 => RequestStatus) public s_requests;


    event Deposited(address indexed sender, Group group, uint256 amount, address indexed referrer);
    event ReferrerPaymentPaid(address indexed receiver, uint256 amount);
    event PoolBonusPaid(address indexed receiver, uint256 amount);
    event PoolBonusDistributed(address indexed receiver, uint256 amount);
    event LotteryBonusPaid(address indexed receiver, uint256 amount);
    event DevBonusPaid(address indexed receiver, uint256 amount);
    event TradingAccountFunded(address indexed receiver, uint256 amount);
    event Claimed(address user, uint256 amount);
    event RequestSent(uint256 requestId, uint32 numWords);
    event RequestFulfilled(uint256 requestId, uint256[] randomWords, uint256 payment);

    error MoneyTreeInvalidAddress(address account);
    error MoneyTreeInvalidKeeperAddress(address account);
    error MoneyTreeInvalidDevsLength(uint256 length);
    error MoneyTreeInvalidUserAddress(address user);
    error MoneyTreeUserAlreadyInList(address user);
    error MoneyTreeInvalidAmount(uint256 amount);
    error MoneyTreeInvalidReferrer(address referrer);
    error MoneyTreeInvalidStartTime(uint256 time);
    error MoneyTreeInvalidParameters();
    error MoneyTreeNotInWindow();
    error MoneyTreeInvalidGroup();
    error MoneyTreeInvalidGroupsParameters();
    error MoneyTreeZeroDistributedAmount();
    error MoneyTreeEpochIsDistributed();
    error MoneyTreeWindowIsOpen();
    error MoneyTreeRequestNotFulfilled(uint256 request);
    error MoneyTreeStepNotReadyForExecute(uint256 step);
    error MoneyTreeWrongBlock();


    modifier onlyKeeper(){
        if (msg.sender != keeper) {
            revert MoneyTreeInvalidKeeperAddress(msg.sender);
        }
        _;
    }


    constructor(address _linkToken, address _vrfV2Wrapper, address _keeper, address _token) VRFV2WrapperConsumerBase(_linkToken, _vrfV2Wrapper) {
        if (_keeper == address(0) ||
            _token == address(0)
        ) {
            revert MoneyTreeInvalidAddress(address(0));
        }
        keeper = _keeper;
        token = _token;
    }


    function initialize(address[] memory _devs, address _tradingAccount) external initializer onlyOwner returns (bool) {
        uint256 len = _devs.length;
        if (len != 11) revert MoneyTreeInvalidDevsLength(len);
        if (_tradingAccount == address(0)) revert MoneyTreeInvalidAddress(address(0));

        for (uint256 i = 0; i < len; i++) {
            if (_devs[i] == address(0)) revert MoneyTreeInvalidAddress(address(0));
            _dev.add(_devs[i]);
        }
        if (_dev.length() != 11) revert MoneyTreeInvalidDevsLength(len);

        tradingAccount = _tradingAccount;

        return true;
    }

    function setPoolStartTime(uint256 _poolStartTime) external onlyOwner returns (bool) {
        if (_poolStartTime < block.timestamp) revert MoneyTreeInvalidStartTime(_poolStartTime);
        poolStartTime = _poolStartTime;
        return true;
    }

    function setGroupsInfo(Group[] memory _groups, GroupInfo[] memory _infos) external onlyOwner returns (bool) {
        if (_groups.length != _infos.length) revert MoneyTreeInvalidGroupsParameters();
        uint256 sum;
        for (uint256 i = 0; i < _groups.length; i++) {
            if (groupInfo[_groups[i]].distributionPercent != 0) revert MoneyTreeInvalidGroupsParameters();
            groupInfo[_groups[i]].depositSize = _infos[i].depositSize;
            groupInfo[_groups[i]].maxPayout = _infos[i].maxPayout;
            groupInfo[_groups[i]].distributionPercent = _infos[i].distributionPercent;
            sum += _infos[i].distributionPercent;
        }
        if (sum != DIVIDER) revert MoneyTreeInvalidGroupsParameters();
        return true;
    }

    function setLinkToken(address _linkToken) external onlyKeeper returns (bool) {
        if (_linkToken == address(0)) revert MoneyTreeInvalidAddress(address(0));
        linkToken = _linkToken;
        return true;
    }


    function deposit(Group _group, uint256 _amount, address _referrer) external returns (bool) {
        address _sender = msg.sender;
        if (!isTimeInWindow(block.timestamp)) revert MoneyTreeNotInWindow();
        if (stakersContainsByGroup(Group.TOTAL, _sender)) revert MoneyTreeUserAlreadyInList(_sender);
        if (_referrer != address(0) && 
            (!stakersContainsByGroup(Group.TOTAL, _referrer) || 
            stakersContainsByGroup(Group.DEV, _referrer) ||
            userInfo[_referrer].group != _group)) revert MoneyTreeInvalidReferrer(_referrer);
        if (_group != Group.POOL_A && _group != Group.POOL_B && _group != Group.POOL_C) revert MoneyTreeInvalidGroup();
        if (_amount != groupInfo[_group].depositSize) revert MoneyTreeInvalidAmount(_amount);

        uint256 currentEpoch = getEpoch(block.timestamp);

        IERC20(token).safeTransferFrom(_sender, address(this), _amount);
        epochDepositAmount[currentEpoch] += _amount;

        _stakersTotal.add(_sender);
        if (_group == Group.POOL_A) _stakersPoolA.add(_sender);
        if (_group == Group.POOL_B) _stakersPoolB.add(_sender);
        if (_group == Group.POOL_C) _stakersPoolC.add(_sender);
        if (_group == Group.POOL_A || _group == Group.POOL_B) _stakersPool_A_B.add(_sender);

        userInfo[_sender].group = _group;
        userInfo[_sender].deposited = true;
        userInfo[_sender].depositTimestamp = block.timestamp;

        addUserToGroupCurrentEpochList(_sender);

        if (_referrer != address(0)) {
            if (userInfo[_referrer].lastEpochAddReferrals == currentEpoch) {
                userInfo[_referrer].numberOfReferrals++;
            } else {
                userInfo[_referrer].numberOfReferrals = 1;
            }
            userInfo[_referrer].lastEpochAddReferrals = currentEpoch;

            if (userInfo[_referrer].numberOfReferrals == 3) {

                uint256 receivedAmount = userInfo[_referrer].totalReceived;
                uint256 depositSize = groupInfo[_group].depositSize;
                uint256 referrerMaxPayout = groupInfo[_group].maxPayout;

                if (depositSize * 2 >= referrerMaxPayout - receivedAmount) {

                    _stakersTotal.remove(_referrer);
                    if (_group == Group.POOL_A) _stakersPoolA.remove(_referrer);
                    if (_group == Group.POOL_B) _stakersPoolB.remove(_referrer);
                    if (_group == Group.POOL_C) _stakersPoolC.remove(_referrer);
                    if (_group == Group.POOL_A || _group == Group.POOL_B) _stakersPool_A_B.remove(_referrer);

                    removeUserFromGroupCurrentEpochList(_referrer);

                    userInfo[_referrer].deposited = false;
                    userInfo[_referrer].totalReceived = 0;
                    userInfo[_referrer].numberOfReferrals = 0;
                    userInfo[_referrer].lastEpochAddReferrals = 0;
                    userInfo[_referrer].winner = false;
                    userInfo[_referrer].depositTimestamp = 0;

                    _winnerList.add(_referrer);
                    winnerGroup[_referrer] = _group;
                    

                    IERC20(token).safeTransfer(_referrer, referrerMaxPayout - receivedAmount);

                    epochDepositAmount[currentEpoch] -= (referrerMaxPayout - receivedAmount);

                    emit ReferrerPaymentPaid(_referrer, referrerMaxPayout - receivedAmount);

                } else {
                    userInfo[_referrer].totalReceived += depositSize * 2;
                    userInfo[_referrer].numberOfReferrals = 0;
                    IERC20(token).safeTransfer(_referrer, depositSize * 2);

                    epochDepositAmount[currentEpoch] -= depositSize * 2;

                    emit ReferrerPaymentPaid(_referrer, depositSize * 2);
                }
            }
        }

        emit Deposited(_sender, _group, _amount, _referrer);

        return true;
    }


    function claim() external nonReentrant returns (bool) {
        _claim(msg.sender);
        return true;
    }


    function requestRandomWords() external onlyKeeper returns (uint256 requestId) {
        previousBlockNumber = block.number;
        requestId = requestRandomness(
            callbackGasLimit,
            requestConfirmations,
            numWords
        );
        s_requests[requestId] = RequestStatus({
            paid: VRF_V2_WRAPPER.calculateRequestPrice(callbackGasLimit),
            randomWords: new uint256[](0),
            fulfilled: false
        });
        requestIds.push(requestId);
        lastRequestId = requestId;
        emit RequestSent(requestId, numWords);
        return requestId;
    }


    function distrubuteStep01() external onlyKeeper returns (bool) {
        uint256 _requestId = lastRequestId;
        (, bool fulfilled,) = getRequestStatus(_requestId);
        if (!fulfilled) revert MoneyTreeRequestNotFulfilled(_requestId);

        uint256 currentEpoch = getEpoch(block.timestamp);
        if (block.number == previousBlockNumber) revert MoneyTreeWrongBlock();
        if (epochStepDone[currentEpoch][1]) revert MoneyTreeStepNotReadyForExecute(1);
        if (isTimeInWindow(block.timestamp)) revert MoneyTreeWindowIsOpen();
        if (isEpochDistributed[currentEpoch] == true) revert MoneyTreeEpochIsDistributed();
        if (epochDepositAmount[currentEpoch] == 0) revert MoneyTreeZeroDistributedAmount();
        previousBlockNumber = block.number;

        Values memory v;
        uint256[] memory groupAmounts = calculateGroupDistribution(epochDepositAmount[currentEpoch]);

        v.distributeAmountDev = groupAmounts[0];
        distributeAmountPoolAStorage = groupAmounts[1];
        distributeAmountPoolBStorage = groupAmounts[2];
        distributeAmountPoolCStorage = groupAmounts[3];
        distributeAmountLotteryStorage = groupAmounts[4];
        v.distributeAmountTrading = groupAmounts[5];

        // payDev
        v.devPaymentAmount = v.distributeAmountDev / 11;

        for (uint256 i = 0; i < 11; i++) {
            if (i == 10) {
                v.recipient = _dev.at(i);
                IERC20(token).safeTransfer(v.recipient, v.distributeAmountDev - v.devPaymentAmount * 10);
                emit DevBonusPaid(v.recipient, v.devPaymentAmount);
                break;
            }
            v.recipient = _dev.at(i);
            IERC20(token).safeTransfer(v.recipient, v.devPaymentAmount);

            emit DevBonusPaid(v.recipient, v.devPaymentAmount);
        }

        //  payTradingAccount
        IERC20(token).safeTransfer(tradingAccount, v.distributeAmountTrading);

        epochStepDone[currentEpoch][1] = true;

        emit TradingAccountFunded(tradingAccount, v.distributeAmountTrading);

        return true;
    }


    function distrubuteStep02() external onlyKeeper returns (bool) {
        uint256 _requestId = lastRequestId;
        uint256 currentEpoch = getEpoch(block.timestamp);
        if (block.number == previousBlockNumber) revert MoneyTreeWrongBlock();
        if (!epochStepDone[currentEpoch][1] || epochStepDone[currentEpoch][2]) revert MoneyTreeStepNotReadyForExecute(2);
        previousBlockNumber = block.number;

        Values memory v;

        v.distributeAmountPoolA = distributeAmountPoolAStorage;   

        //   payPoolA
        v.len = epochUsersByGroup[currentEpoch][Group.POOL_A].length;
        if (v.len > 0) {

            v.maxPoolAmountForBonusROI = v.distributeAmountPoolA * 3 / 4;
            v.maxUsersForROIBonus = v.maxPoolAmountForBonusROI / groupInfo[Group.POOL_A].depositSize;

            v.usersForROIBonus = (v.maxUsersForROIBonus > v.len / 4) ? v.len / 4 : v.maxUsersForROIBonus;

            for (uint256 i = 0; i < v.usersForROIBonus; i++) {
                v.len = epochUsersByGroup[currentEpoch][Group.POOL_A].length;

                v.winnerIndex = processRandomness(_requestId, 0, v.len);
                v.winnerAddress = epochUsersByGroup[currentEpoch][Group.POOL_A][v.winnerIndex];

                (v.winnerPayment, v.winnersStayInList) = payWinner(v.winnerAddress);
                if (v.winnersStayInList) {
                    userInfo[v.winnerAddress].winner = true;
                    v.numberOfWinnersStayInList++;
                } 

                v.distributeAmountPoolA -= v.winnerPayment;
                removeUserFromGroupCurrentEpochList(v.winnerAddress);
            }
        }

        v.numberUsersInPool = stakersLengthByGroup(Group.POOL_A) - v.numberOfWinnersStayInList;

        if (v.numberUsersInPool > 0) {

            v.distributePayment = v.distributeAmountPoolA / v.numberUsersInPool;
            v.maxPayout = groupInfo[Group.POOL_A].maxPayout;

            for (uint256 i = stakersLengthByGroup(Group.POOL_A) - 1; i >= 0; i--) {
                v.recipient = stakersByGroup(Group.POOL_A, i);

                if (userInfo[v.recipient].winner == true) {
                    userInfo[v.recipient].winner = false;
                } else {

                    v.recieved = userInfo[v.recipient].totalReceived;

                    if (v.distributePayment >= v.maxPayout - v.recieved) {
                        _stakersTotal.remove(v.recipient);
                        _stakersPoolA.remove(v.recipient);
                        _stakersPool_A_B.remove(v.recipient);

                        userInfo[v.recipient].deposited = false;
                        userInfo[v.recipient].totalReceived = 0;
                        userInfo[v.recipient].numberOfReferrals = 0;
                        userInfo[v.recipient].lastEpochAddReferrals = 0;
                        userInfo[v.recipient].winner = false;
                        userInfo[v.recipient].depositTimestamp = 0;

                        _winnerList.add(v.recipient);
                        winnerGroup[v.recipient] = Group.POOL_A;

                        IERC20(token).safeTransfer(v.recipient, v.maxPayout - v.recieved);
                        v.distributeAmountPoolA -= (v.maxPayout - v.recieved);

                        emit PoolBonusPaid(v.recipient, v.maxPayout - v.recieved);

                    } else {
                        userInfo[v.recipient].totalReceived += v.distributePayment;
                        userInfo[v.recipient].availableToClaim += v.distributePayment;
                        userInfo[v.recipient].numberOfReferrals = 0;
            
                        v.distributeAmountPoolA -= v.distributePayment;

                        emit PoolBonusDistributed(v.recipient, v.distributePayment);
                    }
                }

                if (i == 0) {
                    break;
                }
            }

            distributeAmountPoolBStorage += v.distributeAmountPoolA;
            distributeAmountPoolAStorage = 0;

            v.numberOfWinnersStayInList = 0;

        } else {
            
            distributeAmountPoolBStorage += v.distributeAmountPoolA;
            distributeAmountPoolAStorage = 0;
        }

        epochStepDone[currentEpoch][2] = true;

        return true;
    }


    function distrubuteStep03() external onlyKeeper returns (bool) {
        uint256 _requestId = lastRequestId;
        uint256 currentEpoch = getEpoch(block.timestamp);
        if (block.number == previousBlockNumber) revert MoneyTreeWrongBlock();
        if (!epochStepDone[currentEpoch][2] || epochStepDone[currentEpoch][3]) revert MoneyTreeStepNotReadyForExecute(3);
        previousBlockNumber = block.number;

        Values memory v;

        v.distributeAmountPoolB = distributeAmountPoolBStorage;

        //   payPoolB
        v.len = epochUsersByGroup[currentEpoch][Group.POOL_B].length;
        if (v.len > 0) {

            v.maxPoolAmountForBonusROI = v.distributeAmountPoolB * 3 / 4;
            v.maxUsersForROIBonus = v.maxPoolAmountForBonusROI / groupInfo[Group.POOL_B].depositSize;

            v.usersForROIBonus = (v.maxUsersForROIBonus > v.len / 4) ? v.len / 4 : v.maxUsersForROIBonus;

            for (uint256 i = 0; i < v.usersForROIBonus; i++) {
                v.len = epochUsersByGroup[currentEpoch][Group.POOL_B].length;

                v.winnerIndex = processRandomness(_requestId, 1, v.len);
                v.winnerAddress = epochUsersByGroup[currentEpoch][Group.POOL_B][v.winnerIndex];

                (v.winnerPayment, v.winnersStayInList) = payWinner(v.winnerAddress);
                if (v.winnersStayInList) {
                    userInfo[v.winnerAddress].winner = true;
                    v.numberOfWinnersStayInList++;
                } 

                v.distributeAmountPoolB -= v.winnerPayment;
                removeUserFromGroupCurrentEpochList(v.winnerAddress);
            }
        }

        v.numberUsersInPool = stakersLengthByGroup(Group.POOL_B) - v.numberOfWinnersStayInList;

        if (v.numberUsersInPool > 0) {

            v.distributePayment = v.distributeAmountPoolB / v.numberUsersInPool;
            v.maxPayout = groupInfo[Group.POOL_B].maxPayout;

            for (uint256 i = stakersLengthByGroup(Group.POOL_B) - 1; i >= 0; i--) {
                v.recipient = stakersByGroup(Group.POOL_B, i);

                if (userInfo[v.recipient].winner == true) {
                    userInfo[v.recipient].winner = false;
                } else {

                    v.recieved = userInfo[v.recipient].totalReceived;

                    if (v.distributePayment >= v.maxPayout - v.recieved) {
                        _stakersTotal.remove(v.recipient);
                        _stakersPoolB.remove(v.recipient);
                        _stakersPool_A_B.remove(v.recipient);

                        userInfo[v.recipient].deposited = false;
                        userInfo[v.recipient].totalReceived = 0;
                        userInfo[v.recipient].numberOfReferrals = 0;
                        userInfo[v.recipient].lastEpochAddReferrals = 0;
                        userInfo[v.recipient].winner = false;
                        userInfo[v.recipient].depositTimestamp = 0;

                        _winnerList.add(v.recipient);
                        winnerGroup[v.recipient] = Group.POOL_B;


                        IERC20(token).safeTransfer(v.recipient, v.maxPayout - v.recieved);
                        v.distributeAmountPoolB -= (v.maxPayout - v.recieved);

                        emit PoolBonusPaid(v.recipient, v.maxPayout - v.recieved);

                    } else {
                        userInfo[v.recipient].totalReceived += v.distributePayment;
                        userInfo[v.recipient].availableToClaim += v.distributePayment;
                        userInfo[v.recipient].numberOfReferrals = 0;
            
                        v.distributeAmountPoolB -= v.distributePayment;

                        emit PoolBonusDistributed(v.recipient, v.distributePayment);
                    }
                }

                if (i == 0) {
                    break;
                }
            }

            distributeAmountPoolCStorage += v.distributeAmountPoolB;
            distributeAmountPoolBStorage = 0;

            v.numberOfWinnersStayInList = 0;

        } else {
            
            distributeAmountPoolCStorage += v.distributeAmountPoolB;
            distributeAmountPoolBStorage = 0;
        }

        epochStepDone[currentEpoch][3] = true;

        return true;
    }


    function distrubuteStep04() external onlyKeeper returns (bool) {
        uint256 _requestId = lastRequestId;
        uint256 currentEpoch = getEpoch(block.timestamp);
        if (block.number == previousBlockNumber) revert MoneyTreeWrongBlock();
        if (!epochStepDone[currentEpoch][3] || epochStepDone[currentEpoch][4]) revert MoneyTreeStepNotReadyForExecute(4);
        previousBlockNumber = block.number;

        Values memory v;

        v.distributeAmountPoolC = distributeAmountPoolCStorage;   

        //   payPoolC
        v.len = epochUsersByGroup[currentEpoch][Group.POOL_C].length;
        if (v.len > 0) {

            v.maxPoolAmountForBonusROI = v.distributeAmountPoolC * 3 / 4;
            v.maxUsersForROIBonus = v.maxPoolAmountForBonusROI / groupInfo[Group.POOL_C].depositSize;

            v.usersForROIBonus = (v.maxUsersForROIBonus > v.len / 4) ? v.len / 4 : v.maxUsersForROIBonus;

            for (uint256 i = 0; i < v.usersForROIBonus; i++) {
                v.len = epochUsersByGroup[currentEpoch][Group.POOL_C].length;

                v.winnerIndex = processRandomness(_requestId, 2, v.len);
                v.winnerAddress = epochUsersByGroup[currentEpoch][Group.POOL_C][v.winnerIndex];

                (v.winnerPayment, v.winnersStayInList) = payWinner(v.winnerAddress);
                if (v.winnersStayInList) {
                    userInfo[v.winnerAddress].winner = true;
                    v.numberOfWinnersStayInList++;
                } 

                v.distributeAmountPoolC -= v.winnerPayment;
                removeUserFromGroupCurrentEpochList(v.winnerAddress);
            }
        }

        v.numberUsersInPool = stakersLengthByGroup(Group.POOL_C) - v.numberOfWinnersStayInList;

        if (v.numberUsersInPool > 0) {

            v.distributePayment = v.distributeAmountPoolC / v.numberUsersInPool;
            v.maxPayout = groupInfo[Group.POOL_C].maxPayout;

            for (uint256 i = stakersLengthByGroup(Group.POOL_C) - 1; i >= 0; i--) {
                v.recipient = stakersByGroup(Group.POOL_C, i);

                if (userInfo[v.recipient].winner == true) {
                    userInfo[v.recipient].winner = false;                  
                } else {

                    v.recieved = userInfo[v.recipient].totalReceived;

                    if (v.distributePayment >= v.maxPayout - v.recieved) {
                        _stakersTotal.remove(v.recipient);
                        _stakersPoolC.remove(v.recipient);

                        userInfo[v.recipient].deposited = false;
                        userInfo[v.recipient].totalReceived = 0;
                        userInfo[v.recipient].numberOfReferrals = 0;
                        userInfo[v.recipient].lastEpochAddReferrals = 0;
                        userInfo[v.recipient].winner = false;
                        userInfo[v.recipient].depositTimestamp = 0;

                        _winnerList.add(v.recipient);
                        winnerGroup[v.recipient] = Group.POOL_C;
                        

                        IERC20(token).safeTransfer(v.recipient, v.maxPayout - v.recieved);
                        v.distributeAmountPoolC -= (v.maxPayout - v.recieved);

                        emit PoolBonusPaid(v.recipient, v.maxPayout - v.recieved);

                    } else {
                        userInfo[v.recipient].totalReceived += v.distributePayment;
                        userInfo[v.recipient].availableToClaim += v.distributePayment;
                        userInfo[v.recipient].numberOfReferrals = 0;
            
                        v.distributeAmountPoolC -= v.distributePayment;

                        emit PoolBonusDistributed(v.recipient, v.distributePayment);
                    }
                }

                if (i == 0) {
                    break;
                }
            }

            distributeAmountLotteryStorage += v.distributeAmountPoolC;
            distributeAmountPoolCStorage = 0;

            v.numberOfWinnersStayInList = 0;

        } else {
            
            distributeAmountLotteryStorage += v.distributeAmountPoolC;
            distributeAmountPoolCStorage = 0;
        }

        epochStepDone[currentEpoch][4] = true;

        return true;
    }


    function distrubuteStep05() external onlyKeeper returns (uint256) {
        uint256 _requestId = lastRequestId;
        uint256 currentEpoch = getEpoch(block.timestamp);
        if (block.number == previousBlockNumber) revert MoneyTreeWrongBlock();
        if (!epochStepDone[currentEpoch][4] || epochStepDone[currentEpoch][5]) revert MoneyTreeStepNotReadyForExecute(5);
        previousBlockNumber = block.number;

        Values memory v;

        v.distributeAmountLottery = distributeAmountLotteryStorage;     

        //   payLottery
        while (v.distributeAmountLottery > 0) {

            v.len = _stakersPool_A_B.length();

            v.winnerIndex = processRandomness(_requestId, 3, v.len);

            v.winnerAddress = _stakersPool_A_B.at(v.winnerIndex);


            Group _winnerGroup = userInfo[v.winnerAddress].group;
            v.recieved = userInfo[v.winnerAddress].totalReceived;
            v.maxPayout = groupInfo[_winnerGroup].maxPayout;

            v.winnerPayment = v.maxPayout - v.recieved;

            if (v.distributeAmountLottery >= v.winnerPayment) {

                _stakersTotal.remove(v.winnerAddress);
                if (_winnerGroup == Group.POOL_A) _stakersPoolA.remove(v.winnerAddress);
                if (_winnerGroup == Group.POOL_B) _stakersPoolB.remove(v.winnerAddress);
                if (_winnerGroup == Group.POOL_A || _winnerGroup == Group.POOL_B) _stakersPool_A_B.remove(v.winnerAddress);

                IERC20(token).safeTransfer(v.winnerAddress, v.winnerPayment);

                userInfo[v.winnerAddress].deposited = false;
                userInfo[v.winnerAddress].totalReceived = 0;
                userInfo[v.winnerAddress].numberOfReferrals = 0;
                userInfo[v.winnerAddress].lastEpochAddReferrals = 0;
                userInfo[v.winnerAddress].winner = false;
                userInfo[v.winnerAddress].depositTimestamp = 0;

                _winnerList.add(v.winnerAddress);
                winnerGroup[v.winnerAddress] = _winnerGroup;

                v.distributeAmountLottery -= v.winnerPayment;

                emit LotteryBonusPaid(v.winnerAddress, v.winnerPayment);

            } else {

                userInfo[v.winnerAddress].totalReceived += v.distributeAmountLottery;
                userInfo[v.winnerAddress].numberOfReferrals = 0;
                IERC20(token).safeTransfer(v.winnerAddress, v.distributeAmountLottery);

                emit LotteryBonusPaid(v.winnerAddress, v.distributeAmountLottery);

                v.distributeAmountLottery = 0;
            }

        }

        epochStepDone[currentEpoch][4] = true;

        isEpochDistributed[currentEpoch] = true;

        return v.distributeAmountLottery;
    }


    function winners(uint256 _index) external view returns (address) {
        return _winnerList.at(_index);
    }

    function winnerListContains(address _user) external view returns (bool) {
        return _winnerList.contains(_user);
    }

    function winnerListLength() external view returns (uint256) {
        return _winnerList.length();
    }

    function getWinnerList(uint256 offset, uint256 limit) external view returns (address[] memory output) {
        uint256 _winnerListLength = _winnerList.length();
        if (offset >= _winnerListLength) return new address[](0);
        uint256 to = offset + limit;
        if (_winnerListLength < to) to = _winnerListLength;
        output = new address[](to - offset);
        for (uint256 i = 0; i < output.length; i++) output[i] = _winnerList.at(offset + i);
    }

    function getUserInfo(address _user) 
        external view returns (
            Group group,
            bool deposited,
            uint256 totalReceived,
            uint256 availableToClaim,
            uint256 numberOfReferrals,
            uint256 lastEpochAddReferrals,
            bool winner,
            uint256 depositTimestamp
        ) 
    {
        if (!userInfo[_user].deposited) revert MoneyTreeInvalidUserAddress(_user);

        UserInfo memory info = userInfo[_user];
        return (
            info.group, 
            info.deposited, 
            info.totalReceived, 
            info.availableToClaim, 
            info.numberOfReferrals,
            info.lastEpochAddReferrals,
            info.winner,
            info.depositTimestamp
        );
    }


    function getWinnerGroup(address _user) external view returns (Group group) {
        return winnerGroup[_user];
    }


    function getEpochDepositAmount(uint256 _epoch) external view returns (uint256) {
        return epochDepositAmount[_epoch];
    }


    function withdrawLink() public onlyKeeper returns (bool) {
        LinkTokenInterface link = LinkTokenInterface(linkToken);
        link.transfer(msg.sender, link.balanceOf(address(this)));
        return true;
    }

    function stakersByGroup(Group _group, uint256 _index) public view returns (address) {
        if (_group == Group.DEV) {
            return _dev.at(_index);
        } else if (_group == Group.POOL_A) {
            return _stakersPoolA.at(_index);
        } else if (_group == Group.POOL_B) {
            return _stakersPoolB.at(_index);
        } else if (_group == Group.POOL_C) {
            return _stakersPoolC.at(_index);
        } else if (_group == Group.TOTAL) {
            return _stakersTotal.at(_index);
        } else {
            revert MoneyTreeInvalidGroup();
        }
    }

    function stakersContainsByGroup(Group _group, address _user) public view returns (bool) {
        if (_group == Group.DEV) {
            return _dev.contains(_user);
        } else if (_group == Group.POOL_A) {
            return _stakersPoolA.contains(_user);
        } else if (_group == Group.POOL_B) {
            return _stakersPoolB.contains(_user);
        } else if (_group == Group.POOL_C) {
            return _stakersPoolC.contains(_user);
        } else if (_group == Group.TOTAL) {
            return _stakersTotal.contains(_user);
        } else {
            revert MoneyTreeInvalidGroup();
        }
    }

    function stakersLengthByGroup(Group _group) public view returns (uint256) {
        if (_group == Group.DEV) {
            return _dev.length();
        } else if (_group == Group.POOL_A) {
            return _stakersPoolA.length();
        } else if (_group == Group.POOL_B) {
            return _stakersPoolB.length();
        } else if (_group == Group.POOL_C) {
            return _stakersPoolC.length();
        } else if (_group == Group.TOTAL) {
            return _stakersTotal.length();
        } else {
            revert MoneyTreeInvalidGroup();
        }
    }

    function getStakersList(Group _group, uint256 offset, uint256 limit) public view returns (address[] memory output) {
        uint256 _stakersListLength;
        uint256 to;
        if (_group == Group.POOL_A) {
            _stakersListLength = _stakersPoolA.length();
            if (offset >= _stakersListLength) return new address[](0);
            to = offset + limit;
            if (_stakersListLength < to) to = _stakersListLength;
            output = new address[](to - offset);
            for (uint256 i = 0; i < output.length; i++) output[i] = _stakersPoolA.at(offset + i);
        } else if (_group == Group.POOL_B) {
            _stakersListLength = _stakersPoolB.length();
            if (offset >= _stakersListLength) return new address[](0);
            to = offset + limit;
            if (_stakersListLength < to) to = _stakersListLength;
            output = new address[](to - offset);
            for (uint256 i = 0; i < output.length; i++) output[i] = _stakersPoolB.at(offset + i);
        } else if (_group == Group.POOL_C) {
            _stakersListLength = _stakersPoolC.length();
            if (offset >= _stakersListLength) return new address[](0);
            to = offset + limit;
            if (_stakersListLength < to) to = _stakersListLength;
            output = new address[](to - offset);
            for (uint256 i = 0; i < output.length; i++) output[i] = _stakersPoolC.at(offset + i);
        } else if (_group == Group.TOTAL) {
            _stakersListLength = _stakersTotal.length();
            if (offset >= _stakersListLength) return new address[](0);
            to = offset + limit;
            if (_stakersListLength < to) to = _stakersListLength;
            output = new address[](to - offset);
            for (uint256 i = 0; i < output.length; i++) output[i] = _stakersTotal.at(offset + i);
        } else {
            revert MoneyTreeInvalidGroup();
        }
    }

    function getEpochUsersByGroup(Group _group) public view returns (address[] memory) {
        uint256 _currentEpoch = getEpoch(block.timestamp);
        return epochUsersByGroup[_currentEpoch][_group];
    }


    function getEpochUserIndex(address _user) public view returns (uint256) {
        uint256 _currentEpoch = getEpoch(block.timestamp);
        return epochUserIndex[_currentEpoch][_user];
    }


    function _isUserInEpochList(address _user) public view returns (bool) {
        uint256 _currentEpoch = getEpoch(block.timestamp);
        return isUserInEpochList[_currentEpoch][_user];
    }


    function isTimeInWindow(uint256 _time) public view returns (bool) {
        if (_time < poolStartTime) revert MoneyTreeInvalidParameters();
        uint256 diff = _time - poolStartTime;
        return diff - (diff / 1 weeks) * 1 weeks < 1 days;
    }


    function getEpoch(uint256 _time) public view returns (uint256) {
        if (_time < poolStartTime) revert MoneyTreeInvalidParameters();
        uint256 diff = _time - poolStartTime;
        return diff / 1 weeks + 1;
    }


    function getRequestStatus(uint256 _requestId) public view returns (uint256 paid, bool fulfilled, uint256[] memory randomWords) {
        require(s_requests[_requestId].paid > 0, "request not found");
        RequestStatus memory request = s_requests[_requestId];
        return (request.paid, request.fulfilled, request.randomWords);
    }


    function fulfillRandomWords(uint256 _requestId, uint256[] memory _randomWords) internal override {
        require(s_requests[_requestId].paid > 0, "request not found");
        s_requests[_requestId].fulfilled = true;
        s_requests[_requestId].randomWords = _randomWords;
        emit RequestFulfilled(
            _requestId,
            _randomWords,
            s_requests[_requestId].paid
        );
    }


    function payWinner(address _user) private returns (uint256 payment, bool winnersStayInList) {
        Group userGroup = userInfo[_user].group;
        uint256 receivedAmount = userInfo[_user].totalReceived;
        uint256 depositSize = groupInfo[userGroup].depositSize;
        uint256 userMaxPayout = groupInfo[userGroup].maxPayout;

        if (depositSize >= userMaxPayout - receivedAmount) {

            _stakersTotal.remove(_user);
            if (userGroup == Group.POOL_A) _stakersPoolA.remove(_user);
            if (userGroup == Group.POOL_B) _stakersPoolB.remove(_user);
            if (userGroup == Group.POOL_C) _stakersPoolC.remove(_user);
            if (userGroup == Group.POOL_A || userGroup == Group.POOL_B) _stakersPool_A_B.remove(_user);

            userInfo[_user].deposited = false;
            userInfo[_user].totalReceived = 0;
            userInfo[_user].numberOfReferrals = 0;
            userInfo[_user].lastEpochAddReferrals = 0;
            userInfo[_user].winner = false;
            userInfo[_user].depositTimestamp = 0;

            _winnerList.add(_user);
            winnerGroup[_user] = userGroup;

            IERC20(token).safeTransfer(_user, userMaxPayout - receivedAmount);

            payment = userMaxPayout - receivedAmount;

            emit PoolBonusPaid(_user, userMaxPayout - receivedAmount);

        } else {
            userInfo[_user].totalReceived += depositSize;
            userInfo[_user].numberOfReferrals = 0;
            userInfo[_user].winner = true;
            IERC20(token).safeTransfer(_user, depositSize);

            payment = depositSize;

            winnersStayInList = true;

            emit PoolBonusPaid(_user, depositSize);
        }
    }


    function addUserToGroupCurrentEpochList(address _user) private {
        uint256 _currentEpoch = getEpoch(block.timestamp);
        Group _userGroup = userInfo[_user].group;

        epochUserIndex[_currentEpoch][_user] = epochUsersByGroup[_currentEpoch][_userGroup].length;
        isUserInEpochList[_currentEpoch][_user] = true;
        epochUsersByGroup[_currentEpoch][_userGroup].push(_user);
    }


    function removeUserFromGroupCurrentEpochList(address _user) private {                  
        uint256 _currentEpoch = getEpoch(block.timestamp);
        Group _userGroup = userInfo[_user].group;
        if (isUserInEpochList[_currentEpoch][_user]) {
            uint256 lastUserIndex = epochUsersByGroup[_currentEpoch][_userGroup].length - 1;
            uint256 userIndex = epochUserIndex[_currentEpoch][_user];

            address lastUserAddress = epochUsersByGroup[_currentEpoch][_userGroup][lastUserIndex];
            epochUsersByGroup[_currentEpoch][_userGroup][userIndex] = lastUserAddress;
            epochUserIndex[_currentEpoch][lastUserAddress] = userIndex;

            delete epochUserIndex[_currentEpoch][_user];
            isUserInEpochList[_currentEpoch][_user] = false;

            epochUsersByGroup[_currentEpoch][_userGroup].pop();
        }
    }


    function _claim(address _user) private {
        UserInfo storage user = userInfo[_user];
        uint256 claimAmount = user.availableToClaim;
        if (claimAmount > 0) {
            user.availableToClaim = 0;
            IERC20(token).safeTransfer(_user, claimAmount);
            emit Claimed(_user, claimAmount);
        }
    }


    function processRandomness(uint256 _requestId, uint256 _k, uint256 _size) private returns (uint256 _randomness) {                
        (,,uint256[] memory _randomWords) = getRequestStatus(_requestId);
        nonce++;
        _randomness = uint256(keccak256(abi.encode(_randomWords[_k], blockhash(block.number - 1), _size, nonce)));
        _randomness = _randomness % _size;
    }


    function calculateGroupDistribution(uint256 _totalAmount) private view returns (uint256[] memory) {
        uint256[] memory _amounts = new uint256[](6);
        _amounts[0] = _totalAmount * groupInfo[Group.DEV].distributionPercent / DIVIDER;
        _amounts[1] = _totalAmount * groupInfo[Group.POOL_A].distributionPercent / DIVIDER;
        _amounts[2] = _totalAmount * groupInfo[Group.POOL_B].distributionPercent / DIVIDER;
        _amounts[3] = _totalAmount * groupInfo[Group.POOL_C].distributionPercent / DIVIDER;
        _amounts[4] = _totalAmount * groupInfo[Group.LOTTERY].distributionPercent / DIVIDER;
        _amounts[5] = _totalAmount - _amounts[0] - _amounts[1] - _amounts[2] - _amounts[3] - _amounts[4];
        return _amounts;
    }
}
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.9.0) (proxy/utils/Initializable.sol)

pragma solidity ^0.8.2;

import "../../utils/Address.sol";

/**
 * @dev This is a base contract to aid in writing upgradeable contracts, or any kind of contract that will be deployed
 * behind a proxy. Since proxied contracts do not make use of a constructor, it's common to move constructor logic to an
 * external initializer function, usually called `initialize`. It then becomes necessary to protect this initializer
 * function so it can only be called once. The {initializer} modifier provided by this contract will have this effect.
 *
 * The initialization functions use a version number. Once a version number is used, it is consumed and cannot be
 * reused. This mechanism prevents re-execution of each "step" but allows the creation of new initialization steps in
 * case an upgrade adds a module that needs to be initialized.
 *
 * For example:
 *
 * [.hljs-theme-light.nopadding]
 * ```solidity
 * contract MyToken is ERC20Upgradeable {
 *     function initialize() initializer public {
 *         __ERC20_init("MyToken", "MTK");
 *     }
 * }
 *
 * contract MyTokenV2 is MyToken, ERC20PermitUpgradeable {
 *     function initializeV2() reinitializer(2) public {
 *         __ERC20Permit_init("MyToken");
 *     }
 * }
 * ```
 *
 * TIP: To avoid leaving the proxy in an uninitialized state, the initializer function should be called as early as
 * possible by providing the encoded function call as the `_data` argument to {ERC1967Proxy-constructor}.
 *
 * CAUTION: When used with inheritance, manual care must be taken to not invoke a parent initializer twice, or to ensure
 * that all initializers are idempotent. This is not verified automatically as constructors are by Solidity.
 *
 * [CAUTION]
 * ====
 * Avoid leaving a contract uninitialized.
 *
 * An uninitialized contract can be taken over by an attacker. This applies to both a proxy and its implementation
 * contract, which may impact the proxy. To prevent the implementation contract from being used, you should invoke
 * the {_disableInitializers} function in the constructor to automatically lock it when it is deployed:
 *
 * [.hljs-theme-light.nopadding]
 * ```
 * /// @custom:oz-upgrades-unsafe-allow constructor
 * constructor() {
 *     _disableInitializers();
 * }
 * ```
 * ====
 */
abstract contract Initializable {
    /**
     * @dev Indicates that the contract has been initialized.
     * @custom:oz-retyped-from bool
     */
    uint8 private _initialized;

    /**
     * @dev Indicates that the contract is in the process of being initialized.
     */
    bool private _initializing;

    /**
     * @dev Triggered when the contract has been initialized or reinitialized.
     */
    event Initialized(uint8 version);

    /**
     * @dev A modifier that defines a protected initializer function that can be invoked at most once. In its scope,
     * `onlyInitializing` functions can be used to initialize parent contracts.
     *
     * Similar to `reinitializer(1)`, except that functions marked with `initializer` can be nested in the context of a
     * constructor.
     *
     * Emits an {Initialized} event.
     */
    modifier initializer() {
        bool isTopLevelCall = !_initializing;
        require(
            (isTopLevelCall && _initialized < 1) || (!Address.isContract(address(this)) && _initialized == 1),
            "Initializable: contract is already initialized"
        );
        _initialized = 1;
        if (isTopLevelCall) {
            _initializing = true;
        }
        _;
        if (isTopLevelCall) {
            _initializing = false;
            emit Initialized(1);
        }
    }

    /**
     * @dev A modifier that defines a protected reinitializer function that can be invoked at most once, and only if the
     * contract hasn't been initialized to a greater version before. In its scope, `onlyInitializing` functions can be
     * used to initialize parent contracts.
     *
     * A reinitializer may be used after the original initialization step. This is essential to configure modules that
     * are added through upgrades and that require initialization.
     *
     * When `version` is 1, this modifier is similar to `initializer`, except that functions marked with `reinitializer`
     * cannot be nested. If one is invoked in the context of another, execution will revert.
     *
     * Note that versions can jump in increments greater than 1; this implies that if multiple reinitializers coexist in
     * a contract, executing them in the right order is up to the developer or operator.
     *
     * WARNING: setting the version to 255 will prevent any future reinitialization.
     *
     * Emits an {Initialized} event.
     */
    modifier reinitializer(uint8 version) {
        require(!_initializing && _initialized < version, "Initializable: contract is already initialized");
        _initialized = version;
        _initializing = true;
        _;
        _initializing = false;
        emit Initialized(version);
    }

    /**
     * @dev Modifier to protect an initialization function so that it can only be invoked by functions with the
     * {initializer} and {reinitializer} modifiers, directly or indirectly.
     */
    modifier onlyInitializing() {
        require(_initializing, "Initializable: contract is not initializing");
        _;
    }

    /**
     * @dev Locks the contract, preventing any future reinitialization. This cannot be part of an initializer call.
     * Calling this in the constructor of a contract will prevent that contract from being initialized or reinitialized
     * to any version. It is recommended to use this to lock implementation contracts that are designed to be called
     * through proxies.
     *
     * Emits an {Initialized} event the first time it is successfully executed.
     */
    function _disableInitializers() internal virtual {
        require(!_initializing, "Initializable: contract is initializing");
        if (_initialized != type(uint8).max) {
            _initialized = type(uint8).max;
            emit Initialized(type(uint8).max);
        }
    }

    /**
     * @dev Returns the highest version that has been initialized. See {reinitializer}.
     */
    function _getInitializedVersion() internal view returns (uint8) {
        return _initialized;
    }

    /**
     * @dev Returns `true` if the contract is currently initializing. See {onlyInitializing}.
     */
    function _isInitializing() internal view returns (bool) {
        return _initializing;
    }
}
// SPDX-License-Identifier: MIT
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
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.9.3) (token/ERC20/utils/SafeERC20.sol)

pragma solidity ^0.8.0;

import "../IERC20.sol";
import "../extensions/IERC20Permit.sol";
import "../../../utils/Address.sol";

/**
 * @title SafeERC20
 * @dev Wrappers around ERC20 operations that throw on failure (when the token
 * contract returns false). Tokens that return no value (and instead revert or
 * throw on failure) are also supported, non-reverting calls are assumed to be
 * successful.
 * To use this library you can add a `using SafeERC20 for IERC20;` statement to your contract,
 * which allows you to call the safe operations as `token.safeTransfer(...)`, etc.
 */
library SafeERC20 {
    using Address for address;

    /**
     * @dev Transfer `value` amount of `token` from the calling contract to `to`. If `token` returns no value,
     * non-reverting calls are assumed to be successful.
     */
    function safeTransfer(IERC20 token, address to, uint256 value) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    /**
     * @dev Transfer `value` amount of `token` from `from` to `to`, spending the approval given by `from` to the
     * calling contract. If `token` returns no value, non-reverting calls are assumed to be successful.
     */
    function safeTransferFrom(IERC20 token, address from, address to, uint256 value) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }

    /**
     * @dev Deprecated. This function has issues similar to the ones found in
     * {IERC20-approve}, and its usage is discouraged.
     *
     * Whenever possible, use {safeIncreaseAllowance} and
     * {safeDecreaseAllowance} instead.
     */
    function safeApprove(IERC20 token, address spender, uint256 value) internal {
        // safeApprove should only be called when setting an initial allowance,
        // or when resetting it to zero. To increase and decrease it, use
        // 'safeIncreaseAllowance' and 'safeDecreaseAllowance'
        require(
            (value == 0) || (token.allowance(address(this), spender) == 0),
            "SafeERC20: approve from non-zero to non-zero allowance"
        );
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
    }

    /**
     * @dev Increase the calling contract's allowance toward `spender` by `value`. If `token` returns no value,
     * non-reverting calls are assumed to be successful.
     */
    function safeIncreaseAllowance(IERC20 token, address spender, uint256 value) internal {
        uint256 oldAllowance = token.allowance(address(this), spender);
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, oldAllowance + value));
    }

    /**
     * @dev Decrease the calling contract's allowance toward `spender` by `value`. If `token` returns no value,
     * non-reverting calls are assumed to be successful.
     */
    function safeDecreaseAllowance(IERC20 token, address spender, uint256 value) internal {
        unchecked {
            uint256 oldAllowance = token.allowance(address(this), spender);
            require(oldAllowance >= value, "SafeERC20: decreased allowance below zero");
            _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, oldAllowance - value));
        }
    }

    /**
     * @dev Set the calling contract's allowance toward `spender` to `value`. If `token` returns no value,
     * non-reverting calls are assumed to be successful. Meant to be used with tokens that require the approval
     * to be set to zero before setting it to a non-zero value, such as USDT.
     */
    function forceApprove(IERC20 token, address spender, uint256 value) internal {
        bytes memory approvalCall = abi.encodeWithSelector(token.approve.selector, spender, value);

        if (!_callOptionalReturnBool(token, approvalCall)) {
            _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, 0));
            _callOptionalReturn(token, approvalCall);
        }
    }

    /**
     * @dev Use a ERC-2612 signature to set the `owner` approval toward `spender` on `token`.
     * Revert on invalid signature.
     */
    function safePermit(
        IERC20Permit token,
        address owner,
        address spender,
        uint256 value,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) internal {
        uint256 nonceBefore = token.nonces(owner);
        token.permit(owner, spender, value, deadline, v, r, s);
        uint256 nonceAfter = token.nonces(owner);
        require(nonceAfter == nonceBefore + 1, "SafeERC20: permit did not succeed");
    }

    /**
     * @dev Imitates a Solidity high-level call (i.e. a regular function call to a contract), relaxing the requirement
     * on the return value: the return value is optional (but if data is returned, it must not be false).
     * @param token The token targeted by the call.
     * @param data The call data (encoded using abi.encode or one of its variants).
     */
    function _callOptionalReturn(IERC20 token, bytes memory data) private {
        // We need to perform a low level call here, to bypass Solidity's return data size checking mechanism, since
        // we're implementing it ourselves. We use {Address-functionCall} to perform this call, which verifies that
        // the target address contains contract code and also asserts for success in the low-level call.

        bytes memory returndata = address(token).functionCall(data, "SafeERC20: low-level call failed");
        require(returndata.length == 0 || abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
    }

    /**
     * @dev Imitates a Solidity high-level call (i.e. a regular function call to a contract), relaxing the requirement
     * on the return value: the return value is optional (but if data is returned, it must not be false).
     * @param token The token targeted by the call.
     * @param data The call data (encoded using abi.encode or one of its variants).
     *
     * This is a variant of {_callOptionalReturn} that silents catches all reverts and returns a bool instead.
     */
    function _callOptionalReturnBool(IERC20 token, bytes memory data) private returns (bool) {
        // We need to perform a low level call here, to bypass Solidity's return data size checking mechanism, since
        // we're implementing it ourselves. We cannot use {Address-functionCall} here since this should return false
        // and not revert is the subcall reverts.

        (bool success, bytes memory returndata) = address(token).call(data);
        return
            success && (returndata.length == 0 || abi.decode(returndata, (bool))) && Address.isContract(address(token));
    }
}
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.9.0) (utils/structs/EnumerableSet.sol)
// This file was procedurally generated from scripts/generate/templates/EnumerableSet.js.

pragma solidity ^0.8.0;

/**
 * @dev Library for managing
 * https://en.wikipedia.org/wiki/Set_(abstract_data_type)[sets] of primitive
 * types.
 *
 * Sets have the following properties:
 *
 * - Elements are added, removed, and checked for existence in constant time
 * (O(1)).
 * - Elements are enumerated in O(n). No guarantees are made on the ordering.
 *
 * ```solidity
 * contract Example {
 *     // Add the library methods
 *     using EnumerableSet for EnumerableSet.AddressSet;
 *
 *     // Declare a set state variable
 *     EnumerableSet.AddressSet private mySet;
 * }
 * ```
 *
 * As of v3.3.0, sets of type `bytes32` (`Bytes32Set`), `address` (`AddressSet`)
 * and `uint256` (`UintSet`) are supported.
 *
 * [WARNING]
 * ====
 * Trying to delete such a structure from storage will likely result in data corruption, rendering the structure
 * unusable.
 * See https://github.com/ethereum/solidity/pull/11843[ethereum/solidity#11843] for more info.
 *
 * In order to clean an EnumerableSet, you can either remove all elements one by one or create a fresh instance using an
 * array of EnumerableSet.
 * ====
 */
library EnumerableSet {
    // To implement this library for multiple types with as little code
    // repetition as possible, we write it in terms of a generic Set type with
    // bytes32 values.
    // The Set implementation uses private functions, and user-facing
    // implementations (such as AddressSet) are just wrappers around the
    // underlying Set.
    // This means that we can only create new EnumerableSets for types that fit
    // in bytes32.

    struct Set {
        // Storage of set values
        bytes32[] _values;
        // Position of the value in the `values` array, plus 1 because index 0
        // means a value is not in the set.
        mapping(bytes32 => uint256) _indexes;
    }

    /**
     * @dev Add a value to a set. O(1).
     *
     * Returns true if the value was added to the set, that is if it was not
     * already present.
     */
    function _add(Set storage set, bytes32 value) private returns (bool) {
        if (!_contains(set, value)) {
            set._values.push(value);
            // The value is stored at length-1, but we add 1 to all indexes
            // and use 0 as a sentinel value
            set._indexes[value] = set._values.length;
            return true;
        } else {
            return false;
        }
    }

    /**
     * @dev Removes a value from a set. O(1).
     *
     * Returns true if the value was removed from the set, that is if it was
     * present.
     */
    function _remove(Set storage set, bytes32 value) private returns (bool) {
        // We read and store the value's index to prevent multiple reads from the same storage slot
        uint256 valueIndex = set._indexes[value];

        if (valueIndex != 0) {
            // Equivalent to contains(set, value)
            // To delete an element from the _values array in O(1), we swap the element to delete with the last one in
            // the array, and then remove the last element (sometimes called as 'swap and pop').
            // This modifies the order of the array, as noted in {at}.

            uint256 toDeleteIndex = valueIndex - 1;
            uint256 lastIndex = set._values.length - 1;

            if (lastIndex != toDeleteIndex) {
                bytes32 lastValue = set._values[lastIndex];

                // Move the last value to the index where the value to delete is
                set._values[toDeleteIndex] = lastValue;
                // Update the index for the moved value
                set._indexes[lastValue] = valueIndex; // Replace lastValue's index to valueIndex
            }

            // Delete the slot where the moved value was stored
            set._values.pop();

            // Delete the index for the deleted slot
            delete set._indexes[value];

            return true;
        } else {
            return false;
        }
    }

    /**
     * @dev Returns true if the value is in the set. O(1).
     */
    function _contains(Set storage set, bytes32 value) private view returns (bool) {
        return set._indexes[value] != 0;
    }

    /**
     * @dev Returns the number of values on the set. O(1).
     */
    function _length(Set storage set) private view returns (uint256) {
        return set._values.length;
    }

    /**
     * @dev Returns the value stored at position `index` in the set. O(1).
     *
     * Note that there are no guarantees on the ordering of values inside the
     * array, and it may change when more values are added or removed.
     *
     * Requirements:
     *
     * - `index` must be strictly less than {length}.
     */
    function _at(Set storage set, uint256 index) private view returns (bytes32) {
        return set._values[index];
    }

    /**
     * @dev Return the entire set in an array
     *
     * WARNING: This operation will copy the entire storage to memory, which can be quite expensive. This is designed
     * to mostly be used by view accessors that are queried without any gas fees. Developers should keep in mind that
     * this function has an unbounded cost, and using it as part of a state-changing function may render the function
     * uncallable if the set grows to a point where copying to memory consumes too much gas to fit in a block.
     */
    function _values(Set storage set) private view returns (bytes32[] memory) {
        return set._values;
    }

    // Bytes32Set

    struct Bytes32Set {
        Set _inner;
    }

    /**
     * @dev Add a value to a set. O(1).
     *
     * Returns true if the value was added to the set, that is if it was not
     * already present.
     */
    function add(Bytes32Set storage set, bytes32 value) internal returns (bool) {
        return _add(set._inner, value);
    }

    /**
     * @dev Removes a value from a set. O(1).
     *
     * Returns true if the value was removed from the set, that is if it was
     * present.
     */
    function remove(Bytes32Set storage set, bytes32 value) internal returns (bool) {
        return _remove(set._inner, value);
    }

    /**
     * @dev Returns true if the value is in the set. O(1).
     */
    function contains(Bytes32Set storage set, bytes32 value) internal view returns (bool) {
        return _contains(set._inner, value);
    }

    /**
     * @dev Returns the number of values in the set. O(1).
     */
    function length(Bytes32Set storage set) internal view returns (uint256) {
        return _length(set._inner);
    }

    /**
     * @dev Returns the value stored at position `index` in the set. O(1).
     *
     * Note that there are no guarantees on the ordering of values inside the
     * array, and it may change when more values are added or removed.
     *
     * Requirements:
     *
     * - `index` must be strictly less than {length}.
     */
    function at(Bytes32Set storage set, uint256 index) internal view returns (bytes32) {
        return _at(set._inner, index);
    }

    /**
     * @dev Return the entire set in an array
     *
     * WARNING: This operation will copy the entire storage to memory, which can be quite expensive. This is designed
     * to mostly be used by view accessors that are queried without any gas fees. Developers should keep in mind that
     * this function has an unbounded cost, and using it as part of a state-changing function may render the function
     * uncallable if the set grows to a point where copying to memory consumes too much gas to fit in a block.
     */
    function values(Bytes32Set storage set) internal view returns (bytes32[] memory) {
        bytes32[] memory store = _values(set._inner);
        bytes32[] memory result;

        /// @solidity memory-safe-assembly
        assembly {
            result := store
        }

        return result;
    }

    // AddressSet

    struct AddressSet {
        Set _inner;
    }

    /**
     * @dev Add a value to a set. O(1).
     *
     * Returns true if the value was added to the set, that is if it was not
     * already present.
     */
    function add(AddressSet storage set, address value) internal returns (bool) {
        return _add(set._inner, bytes32(uint256(uint160(value))));
    }

    /**
     * @dev Removes a value from a set. O(1).
     *
     * Returns true if the value was removed from the set, that is if it was
     * present.
     */
    function remove(AddressSet storage set, address value) internal returns (bool) {
        return _remove(set._inner, bytes32(uint256(uint160(value))));
    }

    /**
     * @dev Returns true if the value is in the set. O(1).
     */
    function contains(AddressSet storage set, address value) internal view returns (bool) {
        return _contains(set._inner, bytes32(uint256(uint160(value))));
    }

    /**
     * @dev Returns the number of values in the set. O(1).
     */
    function length(AddressSet storage set) internal view returns (uint256) {
        return _length(set._inner);
    }

    /**
     * @dev Returns the value stored at position `index` in the set. O(1).
     *
     * Note that there are no guarantees on the ordering of values inside the
     * array, and it may change when more values are added or removed.
     *
     * Requirements:
     *
     * - `index` must be strictly less than {length}.
     */
    function at(AddressSet storage set, uint256 index) internal view returns (address) {
        return address(uint160(uint256(_at(set._inner, index))));
    }

    /**
     * @dev Return the entire set in an array
     *
     * WARNING: This operation will copy the entire storage to memory, which can be quite expensive. This is designed
     * to mostly be used by view accessors that are queried without any gas fees. Developers should keep in mind that
     * this function has an unbounded cost, and using it as part of a state-changing function may render the function
     * uncallable if the set grows to a point where copying to memory consumes too much gas to fit in a block.
     */
    function values(AddressSet storage set) internal view returns (address[] memory) {
        bytes32[] memory store = _values(set._inner);
        address[] memory result;

        /// @solidity memory-safe-assembly
        assembly {
            result := store
        }

        return result;
    }

    // UintSet

    struct UintSet {
        Set _inner;
    }

    /**
     * @dev Add a value to a set. O(1).
     *
     * Returns true if the value was added to the set, that is if it was not
     * already present.
     */
    function add(UintSet storage set, uint256 value) internal returns (bool) {
        return _add(set._inner, bytes32(value));
    }

    /**
     * @dev Removes a value from a set. O(1).
     *
     * Returns true if the value was removed from the set, that is if it was
     * present.
     */
    function remove(UintSet storage set, uint256 value) internal returns (bool) {
        return _remove(set._inner, bytes32(value));
    }

    /**
     * @dev Returns true if the value is in the set. O(1).
     */
    function contains(UintSet storage set, uint256 value) internal view returns (bool) {
        return _contains(set._inner, bytes32(value));
    }

    /**
     * @dev Returns the number of values in the set. O(1).
     */
    function length(UintSet storage set) internal view returns (uint256) {
        return _length(set._inner);
    }

    /**
     * @dev Returns the value stored at position `index` in the set. O(1).
     *
     * Note that there are no guarantees on the ordering of values inside the
     * array, and it may change when more values are added or removed.
     *
     * Requirements:
     *
     * - `index` must be strictly less than {length}.
     */
    function at(UintSet storage set, uint256 index) internal view returns (uint256) {
        return uint256(_at(set._inner, index));
    }

    /**
     * @dev Return the entire set in an array
     *
     * WARNING: This operation will copy the entire storage to memory, which can be quite expensive. This is designed
     * to mostly be used by view accessors that are queried without any gas fees. Developers should keep in mind that
     * this function has an unbounded cost, and using it as part of a state-changing function may render the function
     * uncallable if the set grows to a point where copying to memory consumes too much gas to fit in a block.
     */
    function values(UintSet storage set) internal view returns (uint256[] memory) {
        bytes32[] memory store = _values(set._inner);
        uint256[] memory result;

        /// @solidity memory-safe-assembly
        assembly {
            result := store
        }

        return result;
    }
}
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
pragma solidity ^0.8.0;

import "./interfaces/LinkTokenInterface.sol";
import "./interfaces/VRFV2WrapperInterface.sol";

/** *******************************************************************************
 * @notice Interface for contracts using VRF randomness through the VRF V2 wrapper
 * ********************************************************************************
 * @dev PURPOSE
 *
 * @dev Create VRF V2 requests without the need for subscription management. Rather than creating
 * @dev and funding a VRF V2 subscription, a user can use this wrapper to create one off requests,
 * @dev paying up front rather than at fulfillment.
 *
 * @dev Since the price is determined using the gas price of the request transaction rather than
 * @dev the fulfillment transaction, the wrapper charges an additional premium on callback gas
 * @dev usage, in addition to some extra overhead costs associated with the VRFV2Wrapper contract.
 * *****************************************************************************
 * @dev USAGE
 *
 * @dev Calling contracts must inherit from VRFV2WrapperConsumerBase. The consumer must be funded
 * @dev with enough LINK to make the request, otherwise requests will revert. To request randomness,
 * @dev call the 'requestRandomness' function with the desired VRF parameters. This function handles
 * @dev paying for the request based on the current pricing.
 *
 * @dev Consumers must implement the fullfillRandomWords function, which will be called during
 * @dev fulfillment with the randomness result.
 */
abstract contract VRFV2WrapperConsumerBase {
  LinkTokenInterface internal immutable LINK;
  VRFV2WrapperInterface internal immutable VRF_V2_WRAPPER;

  /**
   * @param _link is the address of LinkToken
   * @param _vrfV2Wrapper is the address of the VRFV2Wrapper contract
   */
  constructor(address _link, address _vrfV2Wrapper) {
    LINK = LinkTokenInterface(_link);
    VRF_V2_WRAPPER = VRFV2WrapperInterface(_vrfV2Wrapper);
  }

  /**
   * @dev Requests randomness from the VRF V2 wrapper.
   *
   * @param _callbackGasLimit is the gas limit that should be used when calling the consumer's
   *        fulfillRandomWords function.
   * @param _requestConfirmations is the number of confirmations to wait before fulfilling the
   *        request. A higher number of confirmations increases security by reducing the likelihood
   *        that a chain re-org changes a published randomness outcome.
   * @param _numWords is the number of random words to request.
   *
   * @return requestId is the VRF V2 request ID of the newly created randomness request.
   */
  function requestRandomness(
    uint32 _callbackGasLimit,
    uint16 _requestConfirmations,
    uint32 _numWords
  ) internal returns (uint256 requestId) {
    LINK.transferAndCall(
      address(VRF_V2_WRAPPER),
      VRF_V2_WRAPPER.calculateRequestPrice(_callbackGasLimit),
      abi.encode(_callbackGasLimit, _requestConfirmations, _numWords)
    );
    return VRF_V2_WRAPPER.lastRequestId();
  }

  /**
   * @notice fulfillRandomWords handles the VRF V2 wrapper response. The consuming contract must
   * @notice implement it.
   *
   * @param _requestId is the VRF V2 request ID.
   * @param _randomWords is the randomness result.
   */
  function fulfillRandomWords(uint256 _requestId, uint256[] memory _randomWords) internal virtual;

  function rawFulfillRandomWords(uint256 _requestId, uint256[] memory _randomWords) external {
    require(msg.sender == address(VRF_V2_WRAPPER), "only VRF V2 wrapper can fulfill");
    fulfillRandomWords(_requestId, _randomWords);
  }
}
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.9.0) (utils/Address.sol)

pragma solidity ^0.8.1;

/**
 * @dev Collection of functions related to the address type
 */
library Address {
    /**
     * @dev Returns true if `account` is a contract.
     *
     * [IMPORTANT]
     * ====
     * It is unsafe to assume that an address for which this function returns
     * false is an externally-owned account (EOA) and not a contract.
     *
     * Among others, `isContract` will return false for the following
     * types of addresses:
     *
     *  - an externally-owned account
     *  - a contract in construction
     *  - an address where a contract will be created
     *  - an address where a contract lived, but was destroyed
     *
     * Furthermore, `isContract` will also return true if the target contract within
     * the same transaction is already scheduled for destruction by `SELFDESTRUCT`,
     * which only has an effect at the end of a transaction.
     * ====
     *
     * [IMPORTANT]
     * ====
     * You shouldn't rely on `isContract` to protect against flash loan attacks!
     *
     * Preventing calls from contracts is highly discouraged. It breaks composability, breaks support for smart wallets
     * like Gnosis Safe, and does not provide security since it can be circumvented by calling from a contract
     * constructor.
     * ====
     */
    function isContract(address account) internal view returns (bool) {
        // This method relies on extcodesize/address.code.length, which returns 0
        // for contracts in construction, since the code is only stored at the end
        // of the constructor execution.

        return account.code.length > 0;
    }

    /**
     * @dev Replacement for Solidity's `transfer`: sends `amount` wei to
     * `recipient`, forwarding all available gas and reverting on errors.
     *
     * https://eips.ethereum.org/EIPS/eip-1884[EIP1884] increases the gas cost
     * of certain opcodes, possibly making contracts go over the 2300 gas limit
     * imposed by `transfer`, making them unable to receive funds via
     * `transfer`. {sendValue} removes this limitation.
     *
     * https://consensys.net/diligence/blog/2019/09/stop-using-soliditys-transfer-now/[Learn more].
     *
     * IMPORTANT: because control is transferred to `recipient`, care must be
     * taken to not create reentrancy vulnerabilities. Consider using
     * {ReentrancyGuard} or the
     * https://solidity.readthedocs.io/en/v0.8.0/security-considerations.html#use-the-checks-effects-interactions-pattern[checks-effects-interactions pattern].
     */
    function sendValue(address payable recipient, uint256 amount) internal {
        require(address(this).balance >= amount, "Address: insufficient balance");

        (bool success, ) = recipient.call{value: amount}("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }

    /**
     * @dev Performs a Solidity function call using a low level `call`. A
     * plain `call` is an unsafe replacement for a function call: use this
     * function instead.
     *
     * If `target` reverts with a revert reason, it is bubbled up by this
     * function (like regular Solidity function calls).
     *
     * Returns the raw returned data. To convert to the expected return value,
     * use https://solidity.readthedocs.io/en/latest/units-and-global-variables.html?highlight=abi.decode#abi-encoding-and-decoding-functions[`abi.decode`].
     *
     * Requirements:
     *
     * - `target` must be a contract.
     * - calling `target` with `data` must not revert.
     *
     * _Available since v3.1._
     */
    function functionCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionCallWithValue(target, data, 0, "Address: low-level call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`], but with
     * `errorMessage` as a fallback revert reason when `target` reverts.
     *
     * _Available since v3.1._
     */
    function functionCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        return functionCallWithValue(target, data, 0, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but also transferring `value` wei to `target`.
     *
     * Requirements:
     *
     * - the calling contract must have an ETH balance of at least `value`.
     * - the called Solidity function must be `payable`.
     *
     * _Available since v3.1._
     */
    function functionCallWithValue(address target, bytes memory data, uint256 value) internal returns (bytes memory) {
        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }

    /**
     * @dev Same as {xref-Address-functionCallWithValue-address-bytes-uint256-}[`functionCallWithValue`], but
     * with `errorMessage` as a fallback revert reason when `target` reverts.
     *
     * _Available since v3.1._
     */
    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value,
        string memory errorMessage
    ) internal returns (bytes memory) {
        require(address(this).balance >= value, "Address: insufficient balance for call");
        (bool success, bytes memory returndata) = target.call{value: value}(data);
        return verifyCallResultFromTarget(target, success, returndata, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but performing a static call.
     *
     * _Available since v3.3._
     */
    function functionStaticCall(address target, bytes memory data) internal view returns (bytes memory) {
        return functionStaticCall(target, data, "Address: low-level static call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-string-}[`functionCall`],
     * but performing a static call.
     *
     * _Available since v3.3._
     */
    function functionStaticCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal view returns (bytes memory) {
        (bool success, bytes memory returndata) = target.staticcall(data);
        return verifyCallResultFromTarget(target, success, returndata, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but performing a delegate call.
     *
     * _Available since v3.4._
     */
    function functionDelegateCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionDelegateCall(target, data, "Address: low-level delegate call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-string-}[`functionCall`],
     * but performing a delegate call.
     *
     * _Available since v3.4._
     */
    function functionDelegateCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        (bool success, bytes memory returndata) = target.delegatecall(data);
        return verifyCallResultFromTarget(target, success, returndata, errorMessage);
    }

    /**
     * @dev Tool to verify that a low level call to smart-contract was successful, and revert (either by bubbling
     * the revert reason or using the provided one) in case of unsuccessful call or if target was not a contract.
     *
     * _Available since v4.8._
     */
    function verifyCallResultFromTarget(
        address target,
        bool success,
        bytes memory returndata,
        string memory errorMessage
    ) internal view returns (bytes memory) {
        if (success) {
            if (returndata.length == 0) {
                // only check isContract if the call was successful and the return data is empty
                // otherwise we already know that it was a contract
                require(isContract(target), "Address: call to non-contract");
            }
            return returndata;
        } else {
            _revert(returndata, errorMessage);
        }
    }

    /**
     * @dev Tool to verify that a low level call was successful, and revert if it wasn't, either by bubbling the
     * revert reason or using the provided one.
     *
     * _Available since v4.3._
     */
    function verifyCallResult(
        bool success,
        bytes memory returndata,
        string memory errorMessage
    ) internal pure returns (bytes memory) {
        if (success) {
            return returndata;
        } else {
            _revert(returndata, errorMessage);
        }
    }

    function _revert(bytes memory returndata, string memory errorMessage) private pure {
        // Look for revert reason and bubble it up if present
        if (returndata.length > 0) {
            // The easiest way to bubble the revert reason is using memory via assembly
            /// @solidity memory-safe-assembly
            assembly {
                let returndata_size := mload(returndata)
                revert(add(32, returndata), returndata_size)
            }
        } else {
            revert(errorMessage);
        }
    }
}
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.9.0) (token/ERC20/extensions/IERC20Permit.sol)

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC20 Permit extension allowing approvals to be made via signatures, as defined in
 * https://eips.ethereum.org/EIPS/eip-2612[EIP-2612].
 *
 * Adds the {permit} method, which can be used to change an account's ERC20 allowance (see {IERC20-allowance}) by
 * presenting a message signed by the account. By not relying on {IERC20-approve}, the token holder account doesn't
 * need to send a transaction, and thus is not required to hold Ether at all.
 */
interface IERC20Permit {
    /**
     * @dev Sets `value` as the allowance of `spender` over ``owner``'s tokens,
     * given ``owner``'s signed approval.
     *
     * IMPORTANT: The same issues {IERC20-approve} has related to transaction
     * ordering also apply here.
     *
     * Emits an {Approval} event.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     * - `deadline` must be a timestamp in the future.
     * - `v`, `r` and `s` must be a valid `secp256k1` signature from `owner`
     * over the EIP712-formatted function arguments.
     * - the signature must use ``owner``'s current nonce (see {nonces}).
     *
     * For more information on the signature format, see the
     * https://eips.ethereum.org/EIPS/eip-2612#specification[relevant EIP
     * section].
     */
    function permit(
        address owner,
        address spender,
        uint256 value,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external;

    /**
     * @dev Returns the current nonce for `owner`. This value must be
     * included whenever a signature is generated for {permit}.
     *
     * Every successful call to {permit} increases ``owner``'s nonce by one. This
     * prevents a signature from being used multiple times.
     */
    function nonces(address owner) external view returns (uint256);

    /**
     * @dev Returns the domain separator used in the encoding of the signature for {permit}, as defined by {EIP712}.
     */
    // solhint-disable-next-line func-name-mixedcase
    function DOMAIN_SEPARATOR() external view returns (bytes32);
}
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

interface VRFV2WrapperInterface {
  /**
   * @return the request ID of the most recent VRF V2 request made by this wrapper. This should only
   * be relied option within the same transaction that the request was made.
   */
  function lastRequestId() external view returns (uint256);

  /**
   * @notice Calculates the price of a VRF request with the given callbackGasLimit at the current
   * @notice block.
   *
   * @dev This function relies on the transaction gas price which is not automatically set during
   * @dev simulation. To estimate the price at a specific gas price, use the estimatePrice function.
   *
   * @param _callbackGasLimit is the gas limit used to estimate the price.
   */
  function calculateRequestPrice(uint32 _callbackGasLimit) external view returns (uint256);

  /**
   * @notice Estimates the price of a VRF request with a specific gas limit and gas price.
   *
   * @dev This is a convenience function that can be called in simulation to better understand
   * @dev pricing.
   *
   * @param _callbackGasLimit is the gas limit used to estimate the price.
   * @param _requestGasPriceWei is the gas price in wei used for the estimation.
   */
  function estimateRequestPrice(uint32 _callbackGasLimit, uint256 _requestGasPriceWei) external view returns (uint256);
}
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface LinkTokenInterface {
  function allowance(address owner, address spender) external view returns (uint256 remaining);

  function approve(address spender, uint256 value) external returns (bool success);

  function balanceOf(address owner) external view returns (uint256 balance);

  function decimals() external view returns (uint8 decimalPlaces);

  function decreaseApproval(address spender, uint256 addedValue) external returns (bool success);

  function increaseApproval(address spender, uint256 subtractedValue) external;

  function name() external view returns (string memory tokenName);

  function symbol() external view returns (string memory tokenSymbol);

  function totalSupply() external view returns (uint256 totalTokensIssued);

  function transfer(address to, uint256 value) external returns (bool success);

  function transferAndCall(
    address to,
    uint256 value,
    bytes calldata data
  ) external returns (bool success);

  function transferFrom(
    address from,
    address to,
    uint256 value
  ) external returns (bool success);
}
