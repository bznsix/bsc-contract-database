// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "./NewVsageNFT.sol";

contract NewVsage {
    using SafeMath for uint256;
    using SafeERC20 for IERC20;

    // 合约拥有者地址
    address public owner;
    // NFT合约地址
    address public nft;
    address public payToken;

    struct User {
        uint id;
        address referrer;
        uint partnersCount;
        mapping(uint256 => bool) activeLevelsFlag;
        mapping(uint8 => X3) x3Matrix;
        mapping(uint8 => X6) x6Matrix;
    }

    struct X3 {
        //本轮上级
        address currentReferrer;
        //下级
        address[] referrals;
        //复投次数
        uint reinvestCount;
        //是否阻断收益
        bool blocked;
        //流失奖金
        uint256 nobonus;
    }

    struct X6 {
        //本轮上级
        address currentReferrer;
        //第一层下级
        address[] firstLevelReferrals;
        //第二层下级
        address[] secondLevelReferrals;
        //复投数量
        uint reinvestCount;
        address closedPart;
        //是否阻断收益
        bool blocked;
        //流失奖金
        uint256 nobonus;
    }
    mapping(address => User) public users;
    mapping(uint => address) public idToAddress;

    uint public lastUserId = 2;
    address public topAddress;
    //最大等级
    uint public LAST_LEVEL;

    //-----矩阵-----
    struct Matrix {
        //价格
        uint256 price;
        //矩阵类型 1.X3  2.X6
        uint8 matrixType;
        //分红比例70%
        uint dividendRatio;
    }
    //所有矩阵
    Matrix[] public matrixList;

    event Registration(address user, address referrer, uint userId, uint referrerId);
    event Reinvest(address user, address currentReferrer, address caller, uint8 matrix, uint8 level);
    event Upgrade(address user, address referrer, uint8 matrix, uint8 level);
    event NewUserPlace(address user, address referrer, uint8 matrix, uint8 level, uint8 place);
    event MissedEthReceive(address receiver, address from, uint8 matrix, uint8 level);
    event SentExtraEthDividends(address from, address receiver, uint8 matrix, uint8 level);
    event SentETHDividends(address from, address receiver, uint8 matrix, uint8 level, uint256 quantity);

    //获取是否激活
    // function getUserActiveLevelsFlag(address userAddress, uint256 level) public view returns (bool) {
    //     return users[userAddress].activeLevelsFlag[level];
    // }

    // 修饰符：仅合约拥有者可调用
    modifier onlyOwner() {
        require(owner == msg.sender, "Only owner can be called.");
        _;
    }

    // 设置NFT合约地址
    function setNft(address _nft) external onlyOwner {
        nft = _nft;
    }

    constructor() {
        owner = msg.sender;
        topAddress = owner;
        //Mcoin
        payToken = 0x826923122A8521Be36358Bdc53d3B4362B6f46E5;
        //payToken = 0xaB1a4d4f1D656d2450692D237fdD6C7f9146e814;

        uint _dividendRatio = 70;
        // 初始化矩阵
        matrixList.push(Matrix(3 * 1e18, 2, _dividendRatio));
        matrixList.push(Matrix(6 * 1e18, 2, _dividendRatio));
        matrixList.push(Matrix(12 * 1e18, 1, _dividendRatio));
        LAST_LEVEL = 2;

        // 初始化顶级账户
        User storage ownerUser = users[owner];
        ownerUser.id = 1;
        ownerUser.referrer = address(0);
        ownerUser.partnersCount = 0;
        for (uint8 j = 0; j < matrixList.length; j++) {
            ownerUser.activeLevelsFlag[j] = true;
        }
        idToAddress[1] = owner;
    }

    //矩阵是否存在
    function isMatrixEmpty(uint8 level) public view returns (bool) {
        Matrix memory matrixInfo = matrixList[level];
        return matrixInfo.price != 0;
    }

    //本次升级的矩阵
    function getLevel() private view returns (uint8 level) {
        for (uint8 j = 0; j < matrixList.length; j++) {
            if (!users[msg.sender].activeLevelsFlag[j]) {
                return j;
            }
        }
        return 0;
    }

    function buyNewLevel() external {
        require(isUserExists(msg.sender), "user is not exists. Register first.");
        //本次升级的矩阵
        uint8 level = getLevel();
        //矩阵不存在
        require(isMatrixEmpty(level), "matrix does not exist.");
        require(!users[msg.sender].activeLevelsFlag[level], "level already activated");

        Matrix memory matrixInfo = matrixList[level];
        uint8 matrix = matrixInfo.matrixType;
        require(matrix == 1 || matrix == 2, "invalid matrix");
        address freeReferrer = findFreeReferrer(msg.sender, level);

        //从付款人的账户中转移代币
        IERC20(payToken).safeTransferFrom(msg.sender, address(this), matrixInfo.price);
        users[msg.sender].activeLevelsFlag[level] = true;
        //铸造NFT
        NewVsageNFT(nft).mint(level, msg.sender);

        if (matrix == 1) {
            if (level > 0 && users[msg.sender].x3Matrix[level - 1].blocked) {
                users[msg.sender].x3Matrix[level - 1].blocked = false;
            }

            users[msg.sender].x3Matrix[level].currentReferrer = freeReferrer;
            updateX3Referrer(msg.sender, freeReferrer, level);
            emit Upgrade(msg.sender, freeReferrer, 1, level);
        } else {
            if (level > 0 && users[msg.sender].x6Matrix[level - 1].blocked) {
                users[msg.sender].x6Matrix[level - 1].blocked = false;
            }

            updateX6Referrer(msg.sender, freeReferrer, level);
            emit Upgrade(msg.sender, freeReferrer, 2, level);
        }
    }

    //注册
    function registration(address referrerAddress) public {
        address userAddress = msg.sender;
        require(!isUserExists(userAddress), "user exists");
        require(isUserExists(referrerAddress), "referrer not exists");

        uint32 size;
        assembly {
            size := extcodesize(userAddress)
        }
        require(size == 0, "cannot be a contract");

        User storage user = users[userAddress];
        user.id = lastUserId;
        user.referrer = referrerAddress;
        user.partnersCount = 0;
        idToAddress[lastUserId] = userAddress;

        lastUserId++;
        users[referrerAddress].partnersCount++;
        emit Registration(userAddress, referrerAddress, user.id, users[referrerAddress].id);
    }

    function updateX3Referrer(address userAddress, address referrerAddress, uint8 level) private {
        // 将userAddress添加到referrals数组中
        users[referrerAddress].x3Matrix[level].referrals.push(userAddress);

        // 如果referrals数组长度小于3
        if (users[referrerAddress].x3Matrix[level].referrals.length < 3) {
            // 触发NewUserPlace事件，并返回sendETHDividends函数的结果
            emit NewUserPlace(userAddress, referrerAddress, 1, level, uint8(users[referrerAddress].x3Matrix[level].referrals.length));
            return sendETHDividends(referrerAddress, userAddress, 1, level);
        }

        // 触发NewUserPlace事件，表示用户已经占据了位置
        emit NewUserPlace(userAddress, referrerAddress, 1, level, 3);

        // 清空referrals数组
        users[referrerAddress].x3Matrix[level].referrals = new address[](0);
        // 增加上级的复投次数
        users[referrerAddress].x3Matrix[level].reinvestCount++;

        //复投2次
        if (users[referrerAddress].x3Matrix[level].reinvestCount >= 2) {
            //下一等级没开  且   最高等级没开，阻断收益
            if (!users[referrerAddress].activeLevelsFlag[level + 1] && !users[referrerAddress].activeLevelsFlag[LAST_LEVEL]) {
                users[referrerAddress].x3Matrix[level].blocked = true;
            }
        }

        // 给上级进行复投
        if (referrerAddress != topAddress) {
            // 查询上级的空闲推荐人
            address freeReferrerAddress = findFreeReferrer(referrerAddress, level);
            // 如果当前推荐人不等于空闲推荐人，更新当前推荐人为空闲推荐人
            if (users[referrerAddress].x3Matrix[level].currentReferrer != freeReferrerAddress) {
                users[referrerAddress].x3Matrix[level].currentReferrer = freeReferrerAddress;
            }
            // 触发Reinvest事件
            emit Reinvest(referrerAddress, freeReferrerAddress, userAddress, 1, level);
            // 递归调用updateX3Referrer函数，以便上级进行复投
            updateX3Referrer(referrerAddress, freeReferrerAddress, level);
        } else {
            // 给合约的所有者发送以太币分红
            sendETHDividends(topAddress, userAddress, 1, level);
            // 触发Reinvest事件
            emit Reinvest(topAddress, address(0), userAddress, 1, level);
        }
    }

    //X6落位日志
    function x6NewUserPlacelog(address ref, uint8 level, address referrerAddress, address userAddress) private {
        // 获取ref的x6Matrix[level]的一级推荐人数组的长度
        uint len = users[ref].x6Matrix[level].firstLevelReferrals.length;

        // 如果长度为2，并且一级推荐人数组的第一个元素和第二个元素都等于referrerAddress
        if (
            (len == 2) &&
            (users[ref].x6Matrix[level].firstLevelReferrals[0] == referrerAddress) &&
            (users[ref].x6Matrix[level].firstLevelReferrals[1] == referrerAddress)
        ) {
            // 如果referrerAddress的x6Matrix[level]的一级推荐人数组长度为1，触发NewUserPlace事件，位置为5，否则位置为6
            if (users[referrerAddress].x6Matrix[level].firstLevelReferrals.length == 1) {
                emit NewUserPlace(userAddress, ref, 2, level, 5);
            } else {
                emit NewUserPlace(userAddress, ref, 2, level, 6);
            }
        }
        // 如果长度为1或2，并且一级推荐人数组的第一个元素等于referrerAddress
        else if ((len == 1 || len == 2) && users[ref].x6Matrix[level].firstLevelReferrals[0] == referrerAddress) {
            // 如果referrerAddress的x6Matrix[level]的一级推荐人数组长度为1，触发NewUserPlace事件，位置为3，否则位置为4
            if (users[referrerAddress].x6Matrix[level].firstLevelReferrals.length == 1) {
                emit NewUserPlace(userAddress, ref, 2, level, 3);
            } else {
                emit NewUserPlace(userAddress, ref, 2, level, 4);
            }
        }
        // 如果长度为2，并且一级推荐人数组的第二个元素等于referrerAddress
        else if (len == 2 && users[ref].x6Matrix[level].firstLevelReferrals[1] == referrerAddress) {
            // 如果referrerAddress的x6Matrix[level]的一级推荐人数组长度为1，触发NewUserPlace事件，位置为5，否则位置为6
            if (users[referrerAddress].x6Matrix[level].firstLevelReferrals.length == 1) {
                emit NewUserPlace(userAddress, ref, 2, level, 5);
            } else {
                emit NewUserPlace(userAddress, ref, 2, level, 6);
            }
        }
    }

    function updateX6Referrer(address userAddress, address referrerAddress, uint8 level) private {
        // 确保引荐人的级别是激活的
        require(users[referrerAddress].activeLevelsFlag[level], "500. Referrer level is inactive");

        // 如果引荐人的第一级推荐人不满2个，则将用户添加到引荐人的第一级推荐人列表中
        if (users[referrerAddress].x6Matrix[level].firstLevelReferrals.length < 2) {
            users[referrerAddress].x6Matrix[level].firstLevelReferrals.push(userAddress);
            emit NewUserPlace(userAddress, referrerAddress, 2, level, uint8(users[referrerAddress].x6Matrix[level].firstLevelReferrals.length));
            users[userAddress].x6Matrix[level].currentReferrer = referrerAddress;

            // 如果引荐人是合约所有者，则将以太币分红发送给引荐人
            if (referrerAddress == topAddress) {
                return sendETHDividends(referrerAddress, userAddress, 2, level);
            }

            // 获取引荐人的当前推荐人，并将用户添加到第二级推荐人列表中
            address ref = users[referrerAddress].x6Matrix[level].currentReferrer;
            users[ref].x6Matrix[level].secondLevelReferrals.push(userAddress);
            //落位日志
            x6NewUserPlacelog(ref, level, referrerAddress, userAddress);
            // 更新用户的第二级推荐人
            return updateX6ReferrerSecondLevel(userAddress, ref, level);
        }

        // 将用户添加到引荐人的第二级推荐人列表中
        users[referrerAddress].x6Matrix[level].secondLevelReferrals.push(userAddress);

        // 获取引荐人的X6矩阵信息
        X6 memory refX6 = users[referrerAddress].x6Matrix[level];

        // 如果引荐人的封闭部分已经存在
        if (refX6.closedPart != address(0)) {
            // 如果引荐人的第一级推荐人的两个位置都是封闭部分地址
            if ((refX6.firstLevelReferrals[0] == refX6.firstLevelReferrals[1]) && (refX6.firstLevelReferrals[0] == refX6.closedPart)) {
                // 更新用户的X6矩阵
                updateX6(userAddress, referrerAddress, level, true);
            }
            // 如果引荐人的第一级推荐人的第一个位置是封闭部分地址
            else if (refX6.firstLevelReferrals[0] == refX6.closedPart) {
                // 更新用户的X6矩阵
                updateX6(userAddress, referrerAddress, level, true);
            }
            // 引荐人的第一级推荐人位置不全是封闭部分地址
            else {
                // 更新用户的X6矩阵
                updateX6(userAddress, referrerAddress, level, false);
            }

            // 更新用户的第二级推荐人
            return updateX6ReferrerSecondLevel(userAddress, referrerAddress, level);
        }

        // 如果引荐人的第一级推荐人的第二个位置是用户地址
        if (refX6.firstLevelReferrals[1] == userAddress) {
            // 更新用户的X6矩阵
            updateX6(userAddress, referrerAddress, level, false);
            // 更新用户的第二级推荐人
            return updateX6ReferrerSecondLevel(userAddress, referrerAddress, level);
        }
        // 如果引荐人的第一级推荐人的第一个位置是用户地址
        else if (refX6.firstLevelReferrals[0] == userAddress) {
            // 更新用户的X6矩阵
            updateX6(userAddress, referrerAddress, level, true);
            // 更新用户的第二级推荐人
            return updateX6ReferrerSecondLevel(userAddress, referrerAddress, level);
        }

        // 如果引荐人的第一个推荐人的第一级推荐人数量小于等于第二个推荐人的第一级推荐人数量
        if (
            users[refX6.firstLevelReferrals[0]].x6Matrix[level].firstLevelReferrals.length <=
            users[refX6.firstLevelReferrals[1]].x6Matrix[level].firstLevelReferrals.length
        ) {
            // 更新用户的X6矩阵
            updateX6(userAddress, referrerAddress, level, false);
        } else {
            // 更新用户的X6矩阵
            updateX6(userAddress, referrerAddress, level, true);
        }
        // 更新用户的第二级推荐人
        updateX6ReferrerSecondLevel(userAddress, referrerAddress, level);
    }

    function updateX6ReferrerSecondLevel(address userAddress, address referrerAddress, uint8 level) private {
        if (users[referrerAddress].x6Matrix[level].secondLevelReferrals.length < 4) {
            // 如果推荐人的第二级推荐列表长度小于4
            return sendETHDividends(referrerAddress, userAddress, 2, level);
        }

        // 获取上级邀请人的第一级推荐列表
        address[] memory x6FirstLevelReferrals = users[users[referrerAddress].x6Matrix[level].currentReferrer].x6Matrix[level].firstLevelReferrals;
        if (x6FirstLevelReferrals.length == 2) {
            if (x6FirstLevelReferrals[0] == referrerAddress || x6FirstLevelReferrals[1] == referrerAddress) {
                // 如果上级邀请人的第一级推荐列表中包含当前的推荐人地址
                // 将上级邀请人的当前推荐人地址设置为关闭部分
                users[users[referrerAddress].x6Matrix[level].currentReferrer].x6Matrix[level].closedPart = referrerAddress;
            }
        }

        // 清空推荐人的第一级和第二级推荐列表以及关闭部分
        users[referrerAddress].x6Matrix[level].firstLevelReferrals = new address[](0);
        users[referrerAddress].x6Matrix[level].secondLevelReferrals = new address[](0);
        users[referrerAddress].x6Matrix[level].closedPart = address(0);
        // 增加推荐人的再投资计数
        users[referrerAddress].x6Matrix[level].reinvestCount++;

        //复投2次
        if (users[referrerAddress].x6Matrix[level].reinvestCount >= 2) {
            //下一等级没开  且   最高等级没开，阻断收益
            if (!users[referrerAddress].activeLevelsFlag[level + 1] && !users[referrerAddress].activeLevelsFlag[LAST_LEVEL]) {
                users[referrerAddress].x6Matrix[level].blocked = true;
            }
        }

        if (referrerAddress != topAddress) {
            // 如果推荐人不是合约的所有者
            // 查找一个空闲的推荐人地址
            address freeReferrerAddress = findFreeReferrer(referrerAddress, level);

            // 发出再投资事件，显示推荐人地址、空闲推荐人地址、用户地址、2（表示x6矩阵）、级别
            emit Reinvest(referrerAddress, freeReferrerAddress, userAddress, 2, level);
            // 更新推荐人的下一级推荐人
            updateX6Referrer(referrerAddress, freeReferrerAddress, level);
        } else {
            // 如果推荐人是合约的所有者
            // 发出再投资事件，显示所有者地址、0地址、用户地址、2（表示x6矩阵）、级别
            emit Reinvest(topAddress, address(0), userAddress, 2, level);
            // 向合约所有者发送以太币分红
            sendETHDividends(topAddress, userAddress, 2, level);
        }
    }

    function updateX6(address userAddress, address referrerAddress, uint8 level, bool x2) private {
        if (!x2) {
            // 将用户地址添加到推荐人地址的x6Matrix的指定级别的第一个级别推荐列表中
            users[users[referrerAddress].x6Matrix[level].firstLevelReferrals[0]].x6Matrix[level].firstLevelReferrals.push(userAddress);
            // 发出新用户放置事件，显示用户地址、第一个级别推荐列表中的第一个地址、2（表示x6矩阵）、级别以及第一个级别推荐列表的长度
            emit NewUserPlace(
                userAddress,
                users[referrerAddress].x6Matrix[level].firstLevelReferrals[0],
                2,
                level,
                uint8(users[users[referrerAddress].x6Matrix[level].firstLevelReferrals[0]].x6Matrix[level].firstLevelReferrals.length)
            );
            // 发出新用户放置事件，显示用户地址、推荐人地址、2（表示x6矩阵）、级别以及2加上第一个级别推荐列表的长度
            emit NewUserPlace(
                userAddress,
                referrerAddress,
                2,
                level,
                2 + uint8(users[users[referrerAddress].x6Matrix[level].firstLevelReferrals[0]].x6Matrix[level].firstLevelReferrals.length)
            );
            // 设置当前级别的推荐人为第一个级别推荐列表中的第一个地址
            users[userAddress].x6Matrix[level].currentReferrer = users[referrerAddress].x6Matrix[level].firstLevelReferrals[0];
        } else {
            // 将用户地址添加到推荐人地址的x6Matrix的指定级别的第二个级别推荐列表中
            users[users[referrerAddress].x6Matrix[level].firstLevelReferrals[1]].x6Matrix[level].firstLevelReferrals.push(userAddress);
            // 发出新用户放置事件，显示用户地址、第二个级别推荐列表中的第一个地址、2（表示x6矩阵）、级别以及第二个级别推荐列表的长度
            emit NewUserPlace(
                userAddress,
                users[referrerAddress].x6Matrix[level].firstLevelReferrals[1],
                2,
                level,
                uint8(users[users[referrerAddress].x6Matrix[level].firstLevelReferrals[1]].x6Matrix[level].firstLevelReferrals.length)
            );
            // 发出新用户放置事件，显示用户地址、推荐人地址、2（表示x6矩阵）、级别以及4加上第二个级别推荐列表的长度
            emit NewUserPlace(
                userAddress,
                referrerAddress,
                2,
                level,
                4 + uint8(users[users[referrerAddress].x6Matrix[level].firstLevelReferrals[1]].x6Matrix[level].firstLevelReferrals.length)
            );
            // 设置当前级别的推荐人为第二个级别推荐列表中的第一个地址
            users[userAddress].x6Matrix[level].currentReferrer = users[referrerAddress].x6Matrix[level].firstLevelReferrals[1];
        }
    }

    function findFreeReferrer(address userAddress, uint8 level) public view returns (address referrer) {
        while (true) {
            if (users[users[userAddress].referrer].activeLevelsFlag[level]) {
                return users[userAddress].referrer;
            }
            userAddress = users[userAddress].referrer;
        }
    }

    function usersActiveX3Levels(address userAddress, uint8 level) public view returns (bool) {
        return users[userAddress].activeLevelsFlag[level];
    }

    function usersActiveX6Levels(address userAddress, uint8 level) public view returns (bool) {
        return users[userAddress].activeLevelsFlag[level];
    }

    function usersX3Matrix(address userAddress, uint8 level) public view returns (address, address[] memory, bool, uint256, uint256) {
        X3 memory x3 = users[userAddress].x3Matrix[level];
        return (x3.currentReferrer, x3.referrals, x3.blocked, x3.reinvestCount, x3.nobonus);
    }

    function usersX6Matrix(
        address userAddress,
        uint8 level
    ) public view returns (address, address[] memory, address[] memory, bool, address, uint256, uint256) {
        X6 memory x6 = users[userAddress].x6Matrix[level];
        return (x6.currentReferrer, x6.firstLevelReferrals, x6.secondLevelReferrals, x6.blocked, x6.closedPart, x6.reinvestCount, x6.nobonus);
    }

    function isUserExists(address user) public view returns (bool) {
        return (users[user].id != 0);
    }

    //查找收款人
    function findEthReceiver(address userAddress, address _from, uint8 matrix, uint8 level, uint256 dividendAmount) private returns (address, bool) {
        address receiver = userAddress;
        bool isExtraDividends;

        while (true) {
            if (receiver == topAddress) {
                return (receiver, false);
            }

            if (matrix == 1 && users[receiver].x3Matrix[level].blocked) {
                emit MissedEthReceive(receiver, _from, 1, level);
                isExtraDividends = true;
                receiver = users[receiver].x3Matrix[level].currentReferrer;
            } else if (matrix == 2 && users[receiver].x6Matrix[level].blocked) {
                emit MissedEthReceive(receiver, _from, 2, level);
                isExtraDividends = true;
                receiver = users[receiver].x6Matrix[level].currentReferrer;
            } else {
                break;
            }

            // 未获得的奖金
            if (matrix == 1) {
                users[receiver].x3Matrix[level].nobonus += dividendAmount;
            } else {
                users[receiver].x6Matrix[level].nobonus += dividendAmount;
            }
        }

        return (receiver, isExtraDividends);
    }

    function sendETHDividends(address userAddress, address _from, uint8 matrix, uint8 level) private {
        Matrix memory matrixInfo = matrixList[level];
        //分红金额 = 价格 * 分红比例 / 100
        uint256 dividendAmount = matrixInfo.price.mul(matrixInfo.dividendRatio).div(100);
        //沉淀金额，购买NFT卡牌的平分金额
        uint256 precipitationAmount = matrixInfo.price.sub(dividendAmount);

        //查询收款人
        (address receiver, bool isExtraDividends) = findEthReceiver(userAddress, _from, matrix, level, dividendAmount);

        //向上级发送代币
        IERC20(payToken).safeApprove(address(this), dividendAmount);
        IERC20(payToken).safeTransferFrom(address(this), receiver, dividendAmount);

        //向NFT发送代币
        IERC20(payToken).safeApprove(address(this), precipitationAmount);
        IERC20(payToken).safeTransferFrom(address(this), nft, precipitationAmount);
        //增加币池
        NewVsageNFT(nft).addTokenPool(precipitationAmount);

        emit SentETHDividends(_from, receiver, matrix, level, dividendAmount);
        if (isExtraDividends) {
            emit SentExtraEthDividends(_from, receiver, matrix, level);
        }
    }

    // 转移代币的函数
    function transferTokens(address _tokenAddress, address _to, uint256 _amount) external onlyOwner {
        require(_tokenAddress != address(0), "Token address cannot be zero");
        require(_to != address(0), "Recipient address cannot be zero");
        require(_amount > 0, "Amount must be greater than zero");
        // 转移代币
        IERC20(_tokenAddress).transfer(_to, _amount);
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
// OpenZeppelin Contracts (last updated v4.9.0) (utils/math/SafeMath.sol)

pragma solidity ^0.8.0;

// CAUTION
// This version of SafeMath should only be used with Solidity 0.8 or later,
// because it relies on the compiler's built in overflow checks.

/**
 * @dev Wrappers over Solidity's arithmetic operations.
 *
 * NOTE: `SafeMath` is generally not needed starting with Solidity 0.8, since the compiler
 * now has built in overflow checking.
 */
library SafeMath {
    /**
     * @dev Returns the addition of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function tryAdd(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            uint256 c = a + b;
            if (c < a) return (false, 0);
            return (true, c);
        }
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function trySub(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b > a) return (false, 0);
            return (true, a - b);
        }
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function tryMul(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
            // benefit is lost if 'b' is also tested.
            // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
            if (a == 0) return (true, 0);
            uint256 c = a * b;
            if (c / a != b) return (false, 0);
            return (true, c);
        }
    }

    /**
     * @dev Returns the division of two unsigned integers, with a division by zero flag.
     *
     * _Available since v3.4._
     */
    function tryDiv(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a / b);
        }
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers, with a division by zero flag.
     *
     * _Available since v3.4._
     */
    function tryMod(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a % b);
        }
    }

    /**
     * @dev Returns the addition of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `+` operator.
     *
     * Requirements:
     *
     * - Addition cannot overflow.
     */
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        return a + b;
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting on
     * overflow (when the result is negative).
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     *
     * - Subtraction cannot overflow.
     */
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return a - b;
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `*` operator.
     *
     * Requirements:
     *
     * - Multiplication cannot overflow.
     */
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        return a * b;
    }

    /**
     * @dev Returns the integer division of two unsigned integers, reverting on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator.
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return a / b;
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * reverting when dividing by zero.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return a % b;
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting with custom message on
     * overflow (when the result is negative).
     *
     * CAUTION: This function is deprecated because it requires allocating memory for the error
     * message unnecessarily. For custom revert reasons use {trySub}.
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     *
     * - Subtraction cannot overflow.
     */
    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        unchecked {
            require(b <= a, errorMessage);
            return a - b;
        }
    }

    /**
     * @dev Returns the integer division of two unsigned integers, reverting with custom message on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator. Note: this function uses a
     * `revert` opcode (which leaves remaining gas untouched) while Solidity
     * uses an invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        unchecked {
            require(b > 0, errorMessage);
            return a / b;
        }
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * reverting with custom message when dividing by zero.
     *
     * CAUTION: This function is deprecated because it requires allocating memory for the error
     * message unnecessarily. For custom revert reasons use {tryMod}.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        unchecked {
            require(b > 0, errorMessage);
            return a % b;
        }
    }
}
// SPDX-License-Identifier: MIT
// 声明合约的许可证
pragma solidity ^0.8.0;

// 导入ERC20接口
import "@openzeppelin/contracts/interfaces/IERC20.sol";
// 导入ERC1155合约
import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
// 导入计数器库
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "./NewVsage.sol";

contract NewVsageNFT is ERC1155 {
    using SafeERC20 for IERC20;
    using SafeMath for uint256;

    //--------------池子------------------
    //金币池子
    uint256 public coinPool;
    //币池子
    uint256 public tokenPool;
    //币
    address public payToken;
    //--------------NFT信息------------------
    // 记录每个NFT的URI
    mapping(uint256 => string) public _tokenURIs;
    // NFT id 从0开始
    uint256 public _tokenIds;
    //--------------------------------
    // 合约拥有者地址
    address public owner;
    // 魔方合约地址
    address public vsage;

    //用户信息
    struct User {
        //当前金币数量
        uint256 coin;
        //已获利金额
        uint profit;
        //重新激活次数
        uint reactivate;
        //开启权益时间
        uint256 openTime;
        //是否开启权益
        bool openFlag;
        //是否可重新激活
        bool reactivateFlag;
    }

    //NFT信息
    struct NFT {
        //铸造比例
        uint mintRate;
        //售出比例
        uint sellRate;
        //铸造金额
        uint256 amount;
    }

    //--------------记录------------------
    // 记录每个NFT的信息 tokenId -> NFT
    mapping(uint256 => NFT) public tokenList;
    // 记录每个地址的信息, tokenId -> address
    mapping(uint256 => mapping(address => User)) public userList;

    // 是否活跃账户
    mapping(address => bool) public active;
    // 是否90天活跃账户
    mapping(address => bool) public active90;
    //所有开启权益的用户
    address[] public allOpenUser;

    event MintLog(uint256 tokenId, address user);
    event OpenLog(uint256 tokenId, address user);
    event RedeemLog(uint256 tokenId, address user, uint256 reserveCoin, uint256 finallySellAmount, uint256 actualSaleCoin);

    // 构造函数
    constructor() ERC1155("http") {
        owner = msg.sender;
        //Mcoin
        payToken = 0x826923122A8521Be36358Bdc53d3B4362B6f46E5;
        //payToken = 0xaB1a4d4f1D656d2450692D237fdD6C7f9146e814;
        coinPool = 100 * 1e18;
        tokenPool = 100 * 1e18;

        //_mint(msg.sender, 0, 0, "");
        //_mint(msg.sender, 1, 0, "");
        //_mint(msg.sender, 2, 0, "");
        tokenList[0] = NFT({mintRate: 80, sellRate: 80, amount: 3 * 1e18});
        tokenList[1] = NFT({mintRate: 80, sellRate: 80, amount: 6 * 1e18});
        tokenList[2] = NFT({mintRate: 80, sellRate: 80, amount: 12 * 1e18});
        _tokenIds = 2;
    }

    // 增加池子,给Vsage动态使用
    function mint(uint256 tokenId, address user) external vsageOwner {
        require(tokenId <= _tokenIds, "INVALID_DATA");
        //判断是否已经铸造
        require(balanceOf(user, tokenId) == 0, "Already minted");
        _mint(user, tokenId, 1, "");
        //记录用户铸币信息
        userList[tokenId][user] = User({coin: 0, profit: 0, reactivate: 0, openTime: 0, openFlag: false, reactivateFlag: false});
        emit MintLog(tokenId, user);
    }

    // 开启收益
    function open(uint256 tokenId) external {
        require(tokenId <= _tokenIds, "INVALID_DATA");
        //未铸造无法开启
        require(balanceOf(msg.sender, tokenId) != 0, "Uncast cannot be opened");

        //不可重新激活
        if (!userList[tokenId][msg.sender].reactivateFlag) {
            //已经开启，请勿重复操作
            require(!userList[tokenId][msg.sender].openFlag, "Already enabled, please do not repeat the operation");
        }

        uint256 amount = tokenList[tokenId].amount;
        //从付款人的账户中转移代币
        IERC20(payToken).safeTransferFrom(msg.sender, address(this), amount);

        //---------计算获得金币数量----------
        //可铸币金额 = 付款金额 * 80 / 100
        uint256 useAmount = amount.mul(tokenList[tokenId].mintRate).div(100);
        //获得金币数量 = 可铸币金额 / 金币单价
        uint256 coin = useAmount.mul(1e18).div(getTokenPrice());
        //记录开启权益信息
        userList[tokenId][msg.sender].coin = coin;
        userList[tokenId][msg.sender].openFlag = true;
        userList[tokenId][msg.sender].openTime = block.timestamp;
        userList[tokenId][msg.sender].reactivate++;
        userList[tokenId][msg.sender].reactivateFlag = false;

        active[msg.sender] = true;
        active90[msg.sender] = true;

        // 不存在的话添加到数组中
        addAddressToArray(allOpenUser, msg.sender);

        emit OpenLog(tokenId, msg.sender);

        //池子增加
        coinPool += coin;
        tokenPool += amount;
    }

    //列表强平
    function clear() external {
        for (uint i = 0; i < allOpenUser.length; i++) {
            address userAddress = allOpenUser[i];
            //90天不活跃账户
            if (!active90[userAddress]) {
                for (uint256 j = 0; j <= _tokenIds; j++) {
                    //剩余金币大于0
                    if (userList[j][userAddress].coin > 0) {
                        redeem(j, 0, userAddress);
                    }
                }
            }
        }
    }

    /**
     * 赎回
     * @param tokenId_ 赎回的下标
     * @param retentionRatio_ 保留比例
     */
    function redeemExt(uint256 tokenId_, uint retentionRatio_) public {
        redeem(tokenId_, retentionRatio_, msg.sender);
    }

    /**
     * 赎回
     * @param _tokenId 赎回的下标
     * @param _retentionRatio  保留比例
     */
    function redeem(uint256 _tokenId, uint _retentionRatio, address userAddress) private {
        require(balanceOf(userAddress, _tokenId) != 0, "Not minted, redemption failed.");

        User storage user = userList[_tokenId][userAddress];
        require(user.coin > 0, "The number of gold coins is 0");

        //保留比例分母
        uint denominator = 10000;
        require(_retentionRatio < denominator, "Retention ratio must be less than 100");

        NFT memory nft = tokenList[_tokenId];
        require(nft.amount > 0, "Amount not set");

        //活跃账户2倍金额
        uint256 allAmount = getActiveAmount(userAddress, _tokenId);

        //【1】 300NFT，持有238.6金币，价格3.000
        //当前价值238.6*3=715.8。
        //保留70% (600*70%=420MC，420/3=140金币）。
        //实际卖出=238.6-140=98.6金币，实际可获得收益卖出=600/3-140=60金币。60*80%=48金币，48*3=144MC

        //金币单价 1.1
        uint256 tokenPrice = getTokenPrice();
        //账户金币价值
        uint256 userCoinValue = user.coin.mul(tokenPrice).div(1e18);

        //实际扣除金币数量
        uint256 actualSaleCoin = 0;
        //最终获得
        uint256 finallySellAmount = 0;

        //账户金币价值 <= 最多可获得的金币
        if (userCoinValue <= allAmount) {
            //保留金币数量
            uint256 reserveCoin = user.coin.mul(_retentionRatio).div(denominator);
            //实际扣除金币数量
            actualSaleCoin = user.coin.sub(reserveCoin);
            //最终输出金币价值
            finallySellAmount = actualSaleCoin.mul(tokenPrice).div(1e18);
        } else {
            //保留金币价值
            uint256 reserveValue = allAmount.mul(_retentionRatio).div(denominator);
            //保留金币数量
            uint256 reserveCoin = reserveValue.mul(1e18).div(tokenPrice);
            //实际扣除金币数量
            actualSaleCoin = user.coin.sub(reserveCoin);
            //最终输出金币价值 = （最多可获得的金币 - 保留价值 ）* 卖出手续费
            finallySellAmount = allAmount.sub(reserveValue).mul(nft.sellRate).div(100);
        }

        require(user.coin >= actualSaleCoin, "The actual quantity sold is wrong");
        //扣除账户金币
        user.coin -= actualSaleCoin;

        //最大可获利金额
        uint256 maxProfit = allAmount.mul(2);
        //获利金额 + 本次获利 > 总金额
        uint256 allProfit = user.profit.add(finallySellAmount);
        if (allProfit >= maxProfit) {
            finallySellAmount = allAmount.sub(user.profit);
            //设置可重新激活
            user.reactivateFlag = true;
        }
        //超出获利
        if (finallySellAmount == 0) {
            return;
        }

        //增加获利金额
        user.profit += finallySellAmount;
        //发送代币
        IERC20(payToken).safeApprove(address(this), finallySellAmount);
        IERC20(payToken).safeTransferFrom(address(this), userAddress, finallySellAmount);
        //扣除币池子
        tokenPool -= finallySellAmount;

        emit RedeemLog(_tokenId, userAddress, user.coin, finallySellAmount, actualSaleCoin);
    }

    // 修饰符：仅合约拥有者可调用
    modifier onlyOwner() {
        require(owner == msg.sender, "Only owner can be called.");
        _;
    }

    // 修饰符：仅魔方合约可调用
    modifier vsageOwner() {
        require(vsage == msg.sender, "Only vsage can be called.");
        _;
    }

    // 增加池子,给Vsage动态使用
    function addTokenPool(uint256 _tokenPool) external vsageOwner {
        //增加币池
        tokenPool += _tokenPool;
    }

    // 设置币池子
    function setTokenPool(uint256 _tokenPool) external onlyOwner {
        tokenPool = _tokenPool;
    }

    // 设置金币池子
    function setCoinPool(uint256 _coinPool) external onlyOwner {
        coinPool = _coinPool;
    }

    //获取金币单价
    function getTokenPrice() public view returns (uint256) {
        return tokenPool.mul(1e18).div(coinPool);
    }

    // 获取计算金额
    function getActiveAmount(address userAddress, uint256 _tokenId) public view returns (uint256) {
        NFT memory nft = tokenList[_tokenId];
        //活跃账户2倍金额
        if (active[userAddress]) {
            return nft.amount.mul(2);
        } else {
            return nft.amount;
        }
    }

    //地址是否存在于数组中
    function isAddressInArray(address[] storage array, address addr) private view returns (bool) {
        for (uint256 i = 0; i < array.length; i++) {
            if (array[i] == addr) {
                return true;
            }
        }
        return false;
    }

    //加入地址到一个不存在的数组中
    function addAddressToArray(address[] storage array, address addr) private {
        if (!isAddressInArray(array, addr)) {
            array.push(addr);
        }
    }

    // 获取特定NFT的URI
    function uri(uint256 tokenId) public view override returns (string memory) {
        return (_tokenURIs[tokenId]);
    }

    // 设置特定NFT的URI
    function _setTokenUri(uint256 tokenId, string memory tokenURI) private {
        _tokenURIs[tokenId] = tokenURI;
    }

    // 设置是否活跃账户
    function setActive(address user, bool flag) external onlyOwner {
        active[user] = flag;
    }

    // 设置是否90天活跃账户
    function setActive90(address user, bool flag) external onlyOwner {
        active90[user] = flag;
    }

    // 设置魔方合约地址
    function setVsage(address _vsage) external onlyOwner {
        vsage = _vsage;
    }

     // 转移代币的函数
    function transferTokens(address _tokenAddress, address _to, uint256 _amount) external onlyOwner {
        require(_tokenAddress != address(0), "Token address cannot be zero");
        require(_to != address(0), "Recipient address cannot be zero");
        require(_amount > 0, "Amount must be greater than zero");
        // 转移代币
        IERC20(_tokenAddress).transfer(_to, _amount);
    }
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
// OpenZeppelin Contracts v4.4.1 (interfaces/IERC20.sol)

pragma solidity ^0.8.0;

import "../token/ERC20/IERC20.sol";
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.9.0) (token/ERC1155/ERC1155.sol)

pragma solidity ^0.8.0;

import "./IERC1155.sol";
import "./IERC1155Receiver.sol";
import "./extensions/IERC1155MetadataURI.sol";
import "../../utils/Address.sol";
import "../../utils/Context.sol";
import "../../utils/introspection/ERC165.sol";

/**
 * @dev Implementation of the basic standard multi-token.
 * See https://eips.ethereum.org/EIPS/eip-1155
 * Originally based on code by Enjin: https://github.com/enjin/erc-1155
 *
 * _Available since v3.1._
 */
contract ERC1155 is Context, ERC165, IERC1155, IERC1155MetadataURI {
    using Address for address;

    // Mapping from token ID to account balances
    mapping(uint256 => mapping(address => uint256)) private _balances;

    // Mapping from account to operator approvals
    mapping(address => mapping(address => bool)) private _operatorApprovals;

    // Used as the URI for all token types by relying on ID substitution, e.g. https://token-cdn-domain/{id}.json
    string private _uri;

    /**
     * @dev See {_setURI}.
     */
    constructor(string memory uri_) {
        _setURI(uri_);
    }

    /**
     * @dev See {IERC165-supportsInterface}.
     */
    function supportsInterface(bytes4 interfaceId) public view virtual override(ERC165, IERC165) returns (bool) {
        return
            interfaceId == type(IERC1155).interfaceId ||
            interfaceId == type(IERC1155MetadataURI).interfaceId ||
            super.supportsInterface(interfaceId);
    }

    /**
     * @dev See {IERC1155MetadataURI-uri}.
     *
     * This implementation returns the same URI for *all* token types. It relies
     * on the token type ID substitution mechanism
     * https://eips.ethereum.org/EIPS/eip-1155#metadata[defined in the EIP].
     *
     * Clients calling this function must replace the `\{id\}` substring with the
     * actual token type ID.
     */
    function uri(uint256) public view virtual override returns (string memory) {
        return _uri;
    }

    /**
     * @dev See {IERC1155-balanceOf}.
     *
     * Requirements:
     *
     * - `account` cannot be the zero address.
     */
    function balanceOf(address account, uint256 id) public view virtual override returns (uint256) {
        require(account != address(0), "ERC1155: address zero is not a valid owner");
        return _balances[id][account];
    }

    /**
     * @dev See {IERC1155-balanceOfBatch}.
     *
     * Requirements:
     *
     * - `accounts` and `ids` must have the same length.
     */
    function balanceOfBatch(
        address[] memory accounts,
        uint256[] memory ids
    ) public view virtual override returns (uint256[] memory) {
        require(accounts.length == ids.length, "ERC1155: accounts and ids length mismatch");

        uint256[] memory batchBalances = new uint256[](accounts.length);

        for (uint256 i = 0; i < accounts.length; ++i) {
            batchBalances[i] = balanceOf(accounts[i], ids[i]);
        }

        return batchBalances;
    }

    /**
     * @dev See {IERC1155-setApprovalForAll}.
     */
    function setApprovalForAll(address operator, bool approved) public virtual override {
        _setApprovalForAll(_msgSender(), operator, approved);
    }

    /**
     * @dev See {IERC1155-isApprovedForAll}.
     */
    function isApprovedForAll(address account, address operator) public view virtual override returns (bool) {
        return _operatorApprovals[account][operator];
    }

    /**
     * @dev See {IERC1155-safeTransferFrom}.
     */
    function safeTransferFrom(
        address from,
        address to,
        uint256 id,
        uint256 amount,
        bytes memory data
    ) public virtual override {
        require(
            from == _msgSender() || isApprovedForAll(from, _msgSender()),
            "ERC1155: caller is not token owner or approved"
        );
        _safeTransferFrom(from, to, id, amount, data);
    }

    /**
     * @dev See {IERC1155-safeBatchTransferFrom}.
     */
    function safeBatchTransferFrom(
        address from,
        address to,
        uint256[] memory ids,
        uint256[] memory amounts,
        bytes memory data
    ) public virtual override {
        require(
            from == _msgSender() || isApprovedForAll(from, _msgSender()),
            "ERC1155: caller is not token owner or approved"
        );
        _safeBatchTransferFrom(from, to, ids, amounts, data);
    }

    /**
     * @dev Transfers `amount` tokens of token type `id` from `from` to `to`.
     *
     * Emits a {TransferSingle} event.
     *
     * Requirements:
     *
     * - `to` cannot be the zero address.
     * - `from` must have a balance of tokens of type `id` of at least `amount`.
     * - If `to` refers to a smart contract, it must implement {IERC1155Receiver-onERC1155Received} and return the
     * acceptance magic value.
     */
    function _safeTransferFrom(
        address from,
        address to,
        uint256 id,
        uint256 amount,
        bytes memory data
    ) internal virtual {
        require(to != address(0), "ERC1155: transfer to the zero address");

        address operator = _msgSender();
        uint256[] memory ids = _asSingletonArray(id);
        uint256[] memory amounts = _asSingletonArray(amount);

        _beforeTokenTransfer(operator, from, to, ids, amounts, data);

        uint256 fromBalance = _balances[id][from];
        require(fromBalance >= amount, "ERC1155: insufficient balance for transfer");
        unchecked {
            _balances[id][from] = fromBalance - amount;
        }
        _balances[id][to] += amount;

        emit TransferSingle(operator, from, to, id, amount);

        _afterTokenTransfer(operator, from, to, ids, amounts, data);

        _doSafeTransferAcceptanceCheck(operator, from, to, id, amount, data);
    }

    /**
     * @dev xref:ROOT:erc1155.adoc#batch-operations[Batched] version of {_safeTransferFrom}.
     *
     * Emits a {TransferBatch} event.
     *
     * Requirements:
     *
     * - If `to` refers to a smart contract, it must implement {IERC1155Receiver-onERC1155BatchReceived} and return the
     * acceptance magic value.
     */
    function _safeBatchTransferFrom(
        address from,
        address to,
        uint256[] memory ids,
        uint256[] memory amounts,
        bytes memory data
    ) internal virtual {
        require(ids.length == amounts.length, "ERC1155: ids and amounts length mismatch");
        require(to != address(0), "ERC1155: transfer to the zero address");

        address operator = _msgSender();

        _beforeTokenTransfer(operator, from, to, ids, amounts, data);

        for (uint256 i = 0; i < ids.length; ++i) {
            uint256 id = ids[i];
            uint256 amount = amounts[i];

            uint256 fromBalance = _balances[id][from];
            require(fromBalance >= amount, "ERC1155: insufficient balance for transfer");
            unchecked {
                _balances[id][from] = fromBalance - amount;
            }
            _balances[id][to] += amount;
        }

        emit TransferBatch(operator, from, to, ids, amounts);

        _afterTokenTransfer(operator, from, to, ids, amounts, data);

        _doSafeBatchTransferAcceptanceCheck(operator, from, to, ids, amounts, data);
    }

    /**
     * @dev Sets a new URI for all token types, by relying on the token type ID
     * substitution mechanism
     * https://eips.ethereum.org/EIPS/eip-1155#metadata[defined in the EIP].
     *
     * By this mechanism, any occurrence of the `\{id\}` substring in either the
     * URI or any of the amounts in the JSON file at said URI will be replaced by
     * clients with the token type ID.
     *
     * For example, the `https://token-cdn-domain/\{id\}.json` URI would be
     * interpreted by clients as
     * `https://token-cdn-domain/000000000000000000000000000000000000000000000000000000000004cce0.json`
     * for token type ID 0x4cce0.
     *
     * See {uri}.
     *
     * Because these URIs cannot be meaningfully represented by the {URI} event,
     * this function emits no events.
     */
    function _setURI(string memory newuri) internal virtual {
        _uri = newuri;
    }

    /**
     * @dev Creates `amount` tokens of token type `id`, and assigns them to `to`.
     *
     * Emits a {TransferSingle} event.
     *
     * Requirements:
     *
     * - `to` cannot be the zero address.
     * - If `to` refers to a smart contract, it must implement {IERC1155Receiver-onERC1155Received} and return the
     * acceptance magic value.
     */
    function _mint(address to, uint256 id, uint256 amount, bytes memory data) internal virtual {
        require(to != address(0), "ERC1155: mint to the zero address");

        address operator = _msgSender();
        uint256[] memory ids = _asSingletonArray(id);
        uint256[] memory amounts = _asSingletonArray(amount);

        _beforeTokenTransfer(operator, address(0), to, ids, amounts, data);

        _balances[id][to] += amount;
        emit TransferSingle(operator, address(0), to, id, amount);

        _afterTokenTransfer(operator, address(0), to, ids, amounts, data);

        _doSafeTransferAcceptanceCheck(operator, address(0), to, id, amount, data);
    }

    /**
     * @dev xref:ROOT:erc1155.adoc#batch-operations[Batched] version of {_mint}.
     *
     * Emits a {TransferBatch} event.
     *
     * Requirements:
     *
     * - `ids` and `amounts` must have the same length.
     * - If `to` refers to a smart contract, it must implement {IERC1155Receiver-onERC1155BatchReceived} and return the
     * acceptance magic value.
     */
    function _mintBatch(
        address to,
        uint256[] memory ids,
        uint256[] memory amounts,
        bytes memory data
    ) internal virtual {
        require(to != address(0), "ERC1155: mint to the zero address");
        require(ids.length == amounts.length, "ERC1155: ids and amounts length mismatch");

        address operator = _msgSender();

        _beforeTokenTransfer(operator, address(0), to, ids, amounts, data);

        for (uint256 i = 0; i < ids.length; i++) {
            _balances[ids[i]][to] += amounts[i];
        }

        emit TransferBatch(operator, address(0), to, ids, amounts);

        _afterTokenTransfer(operator, address(0), to, ids, amounts, data);

        _doSafeBatchTransferAcceptanceCheck(operator, address(0), to, ids, amounts, data);
    }

    /**
     * @dev Destroys `amount` tokens of token type `id` from `from`
     *
     * Emits a {TransferSingle} event.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `from` must have at least `amount` tokens of token type `id`.
     */
    function _burn(address from, uint256 id, uint256 amount) internal virtual {
        require(from != address(0), "ERC1155: burn from the zero address");

        address operator = _msgSender();
        uint256[] memory ids = _asSingletonArray(id);
        uint256[] memory amounts = _asSingletonArray(amount);

        _beforeTokenTransfer(operator, from, address(0), ids, amounts, "");

        uint256 fromBalance = _balances[id][from];
        require(fromBalance >= amount, "ERC1155: burn amount exceeds balance");
        unchecked {
            _balances[id][from] = fromBalance - amount;
        }

        emit TransferSingle(operator, from, address(0), id, amount);

        _afterTokenTransfer(operator, from, address(0), ids, amounts, "");
    }

    /**
     * @dev xref:ROOT:erc1155.adoc#batch-operations[Batched] version of {_burn}.
     *
     * Emits a {TransferBatch} event.
     *
     * Requirements:
     *
     * - `ids` and `amounts` must have the same length.
     */
    function _burnBatch(address from, uint256[] memory ids, uint256[] memory amounts) internal virtual {
        require(from != address(0), "ERC1155: burn from the zero address");
        require(ids.length == amounts.length, "ERC1155: ids and amounts length mismatch");

        address operator = _msgSender();

        _beforeTokenTransfer(operator, from, address(0), ids, amounts, "");

        for (uint256 i = 0; i < ids.length; i++) {
            uint256 id = ids[i];
            uint256 amount = amounts[i];

            uint256 fromBalance = _balances[id][from];
            require(fromBalance >= amount, "ERC1155: burn amount exceeds balance");
            unchecked {
                _balances[id][from] = fromBalance - amount;
            }
        }

        emit TransferBatch(operator, from, address(0), ids, amounts);

        _afterTokenTransfer(operator, from, address(0), ids, amounts, "");
    }

    /**
     * @dev Approve `operator` to operate on all of `owner` tokens
     *
     * Emits an {ApprovalForAll} event.
     */
    function _setApprovalForAll(address owner, address operator, bool approved) internal virtual {
        require(owner != operator, "ERC1155: setting approval status for self");
        _operatorApprovals[owner][operator] = approved;
        emit ApprovalForAll(owner, operator, approved);
    }

    /**
     * @dev Hook that is called before any token transfer. This includes minting
     * and burning, as well as batched variants.
     *
     * The same hook is called on both single and batched variants. For single
     * transfers, the length of the `ids` and `amounts` arrays will be 1.
     *
     * Calling conditions (for each `id` and `amount` pair):
     *
     * - When `from` and `to` are both non-zero, `amount` of ``from``'s tokens
     * of token type `id` will be  transferred to `to`.
     * - When `from` is zero, `amount` tokens of token type `id` will be minted
     * for `to`.
     * - when `to` is zero, `amount` of ``from``'s tokens of token type `id`
     * will be burned.
     * - `from` and `to` are never both zero.
     * - `ids` and `amounts` have the same, non-zero length.
     *
     * To learn more about hooks, head to xref:ROOT:extending-contracts.adoc#using-hooks[Using Hooks].
     */
    function _beforeTokenTransfer(
        address operator,
        address from,
        address to,
        uint256[] memory ids,
        uint256[] memory amounts,
        bytes memory data
    ) internal virtual {}

    /**
     * @dev Hook that is called after any token transfer. This includes minting
     * and burning, as well as batched variants.
     *
     * The same hook is called on both single and batched variants. For single
     * transfers, the length of the `id` and `amount` arrays will be 1.
     *
     * Calling conditions (for each `id` and `amount` pair):
     *
     * - When `from` and `to` are both non-zero, `amount` of ``from``'s tokens
     * of token type `id` will be  transferred to `to`.
     * - When `from` is zero, `amount` tokens of token type `id` will be minted
     * for `to`.
     * - when `to` is zero, `amount` of ``from``'s tokens of token type `id`
     * will be burned.
     * - `from` and `to` are never both zero.
     * - `ids` and `amounts` have the same, non-zero length.
     *
     * To learn more about hooks, head to xref:ROOT:extending-contracts.adoc#using-hooks[Using Hooks].
     */
    function _afterTokenTransfer(
        address operator,
        address from,
        address to,
        uint256[] memory ids,
        uint256[] memory amounts,
        bytes memory data
    ) internal virtual {}

    function _doSafeTransferAcceptanceCheck(
        address operator,
        address from,
        address to,
        uint256 id,
        uint256 amount,
        bytes memory data
    ) private {
        if (to.isContract()) {
            try IERC1155Receiver(to).onERC1155Received(operator, from, id, amount, data) returns (bytes4 response) {
                if (response != IERC1155Receiver.onERC1155Received.selector) {
                    revert("ERC1155: ERC1155Receiver rejected tokens");
                }
            } catch Error(string memory reason) {
                revert(reason);
            } catch {
                revert("ERC1155: transfer to non-ERC1155Receiver implementer");
            }
        }
    }

    function _doSafeBatchTransferAcceptanceCheck(
        address operator,
        address from,
        address to,
        uint256[] memory ids,
        uint256[] memory amounts,
        bytes memory data
    ) private {
        if (to.isContract()) {
            try IERC1155Receiver(to).onERC1155BatchReceived(operator, from, ids, amounts, data) returns (
                bytes4 response
            ) {
                if (response != IERC1155Receiver.onERC1155BatchReceived.selector) {
                    revert("ERC1155: ERC1155Receiver rejected tokens");
                }
            } catch Error(string memory reason) {
                revert(reason);
            } catch {
                revert("ERC1155: transfer to non-ERC1155Receiver implementer");
            }
        }
    }

    function _asSingletonArray(uint256 element) private pure returns (uint256[] memory) {
        uint256[] memory array = new uint256[](1);
        array[0] = element;

        return array;
    }
}
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/Counters.sol)

pragma solidity ^0.8.0;

/**
 * @title Counters
 * @author Matt Condon (@shrugs)
 * @dev Provides counters that can only be incremented, decremented or reset. This can be used e.g. to track the number
 * of elements in a mapping, issuing ERC721 ids, or counting request ids.
 *
 * Include with `using Counters for Counters.Counter;`
 */
library Counters {
    struct Counter {
        // This variable should never be directly accessed by users of the library: interactions must be restricted to
        // the library's function. As of Solidity v0.5.2, this cannot be enforced, though there is a proposal to add
        // this feature: see https://github.com/ethereum/solidity/issues/4637
        uint256 _value; // default: 0
    }

    function current(Counter storage counter) internal view returns (uint256) {
        return counter._value;
    }

    function increment(Counter storage counter) internal {
        unchecked {
            counter._value += 1;
        }
    }

    function decrement(Counter storage counter) internal {
        uint256 value = counter._value;
        require(value > 0, "Counter: decrement overflow");
        unchecked {
            counter._value = value - 1;
        }
    }

    function reset(Counter storage counter) internal {
        counter._value = 0;
    }
}
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.9.0) (token/ERC1155/IERC1155.sol)

pragma solidity ^0.8.0;

import "../../utils/introspection/IERC165.sol";

/**
 * @dev Required interface of an ERC1155 compliant contract, as defined in the
 * https://eips.ethereum.org/EIPS/eip-1155[EIP].
 *
 * _Available since v3.1._
 */
interface IERC1155 is IERC165 {
    /**
     * @dev Emitted when `value` tokens of token type `id` are transferred from `from` to `to` by `operator`.
     */
    event TransferSingle(address indexed operator, address indexed from, address indexed to, uint256 id, uint256 value);

    /**
     * @dev Equivalent to multiple {TransferSingle} events, where `operator`, `from` and `to` are the same for all
     * transfers.
     */
    event TransferBatch(
        address indexed operator,
        address indexed from,
        address indexed to,
        uint256[] ids,
        uint256[] values
    );

    /**
     * @dev Emitted when `account` grants or revokes permission to `operator` to transfer their tokens, according to
     * `approved`.
     */
    event ApprovalForAll(address indexed account, address indexed operator, bool approved);

    /**
     * @dev Emitted when the URI for token type `id` changes to `value`, if it is a non-programmatic URI.
     *
     * If an {URI} event was emitted for `id`, the standard
     * https://eips.ethereum.org/EIPS/eip-1155#metadata-extensions[guarantees] that `value` will equal the value
     * returned by {IERC1155MetadataURI-uri}.
     */
    event URI(string value, uint256 indexed id);

    /**
     * @dev Returns the amount of tokens of token type `id` owned by `account`.
     *
     * Requirements:
     *
     * - `account` cannot be the zero address.
     */
    function balanceOf(address account, uint256 id) external view returns (uint256);

    /**
     * @dev xref:ROOT:erc1155.adoc#batch-operations[Batched] version of {balanceOf}.
     *
     * Requirements:
     *
     * - `accounts` and `ids` must have the same length.
     */
    function balanceOfBatch(
        address[] calldata accounts,
        uint256[] calldata ids
    ) external view returns (uint256[] memory);

    /**
     * @dev Grants or revokes permission to `operator` to transfer the caller's tokens, according to `approved`,
     *
     * Emits an {ApprovalForAll} event.
     *
     * Requirements:
     *
     * - `operator` cannot be the caller.
     */
    function setApprovalForAll(address operator, bool approved) external;

    /**
     * @dev Returns true if `operator` is approved to transfer ``account``'s tokens.
     *
     * See {setApprovalForAll}.
     */
    function isApprovedForAll(address account, address operator) external view returns (bool);

    /**
     * @dev Transfers `amount` tokens of token type `id` from `from` to `to`.
     *
     * Emits a {TransferSingle} event.
     *
     * Requirements:
     *
     * - `to` cannot be the zero address.
     * - If the caller is not `from`, it must have been approved to spend ``from``'s tokens via {setApprovalForAll}.
     * - `from` must have a balance of tokens of type `id` of at least `amount`.
     * - If `to` refers to a smart contract, it must implement {IERC1155Receiver-onERC1155Received} and return the
     * acceptance magic value.
     */
    function safeTransferFrom(address from, address to, uint256 id, uint256 amount, bytes calldata data) external;

    /**
     * @dev xref:ROOT:erc1155.adoc#batch-operations[Batched] version of {safeTransferFrom}.
     *
     * Emits a {TransferBatch} event.
     *
     * Requirements:
     *
     * - `ids` and `amounts` must have the same length.
     * - If `to` refers to a smart contract, it must implement {IERC1155Receiver-onERC1155BatchReceived} and return the
     * acceptance magic value.
     */
    function safeBatchTransferFrom(
        address from,
        address to,
        uint256[] calldata ids,
        uint256[] calldata amounts,
        bytes calldata data
    ) external;
}
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.5.0) (token/ERC1155/IERC1155Receiver.sol)

pragma solidity ^0.8.0;

import "../../utils/introspection/IERC165.sol";

/**
 * @dev _Available since v3.1._
 */
interface IERC1155Receiver is IERC165 {
    /**
     * @dev Handles the receipt of a single ERC1155 token type. This function is
     * called at the end of a `safeTransferFrom` after the balance has been updated.
     *
     * NOTE: To accept the transfer, this must return
     * `bytes4(keccak256("onERC1155Received(address,address,uint256,uint256,bytes)"))`
     * (i.e. 0xf23a6e61, or its own function selector).
     *
     * @param operator The address which initiated the transfer (i.e. msg.sender)
     * @param from The address which previously owned the token
     * @param id The ID of the token being transferred
     * @param value The amount of tokens being transferred
     * @param data Additional data with no specified format
     * @return `bytes4(keccak256("onERC1155Received(address,address,uint256,uint256,bytes)"))` if transfer is allowed
     */
    function onERC1155Received(
        address operator,
        address from,
        uint256 id,
        uint256 value,
        bytes calldata data
    ) external returns (bytes4);

    /**
     * @dev Handles the receipt of a multiple ERC1155 token types. This function
     * is called at the end of a `safeBatchTransferFrom` after the balances have
     * been updated.
     *
     * NOTE: To accept the transfer(s), this must return
     * `bytes4(keccak256("onERC1155BatchReceived(address,address,uint256[],uint256[],bytes)"))`
     * (i.e. 0xbc197c81, or its own function selector).
     *
     * @param operator The address which initiated the batch transfer (i.e. msg.sender)
     * @param from The address which previously owned the token
     * @param ids An array containing ids of each token being transferred (order and length must match values array)
     * @param values An array containing amounts of each token being transferred (order and length must match ids array)
     * @param data Additional data with no specified format
     * @return `bytes4(keccak256("onERC1155BatchReceived(address,address,uint256[],uint256[],bytes)"))` if transfer is allowed
     */
    function onERC1155BatchReceived(
        address operator,
        address from,
        uint256[] calldata ids,
        uint256[] calldata values,
        bytes calldata data
    ) external returns (bytes4);
}
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (token/ERC1155/extensions/IERC1155MetadataURI.sol)

pragma solidity ^0.8.0;

import "../IERC1155.sol";

/**
 * @dev Interface of the optional ERC1155MetadataExtension interface, as defined
 * in the https://eips.ethereum.org/EIPS/eip-1155#metadata-extensions[EIP].
 *
 * _Available since v3.1._
 */
interface IERC1155MetadataURI is IERC1155 {
    /**
     * @dev Returns the URI for token type `id`.
     *
     * If the `\{id\}` substring is present in the URI, it must be replaced by
     * clients with the actual token type ID.
     */
    function uri(uint256 id) external view returns (string memory);
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
// OpenZeppelin Contracts v4.4.1 (utils/introspection/ERC165.sol)

pragma solidity ^0.8.0;

import "./IERC165.sol";

/**
 * @dev Implementation of the {IERC165} interface.
 *
 * Contracts that want to implement ERC165 should inherit from this contract and override {supportsInterface} to check
 * for the additional interface id that will be supported. For example:
 *
 * ```solidity
 * function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
 *     return interfaceId == type(MyInterface).interfaceId || super.supportsInterface(interfaceId);
 * }
 * ```
 *
 * Alternatively, {ERC165Storage} provides an easier to use but more expensive implementation.
 */
abstract contract ERC165 is IERC165 {
    /**
     * @dev See {IERC165-supportsInterface}.
     */
    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return interfaceId == type(IERC165).interfaceId;
    }
}
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/introspection/IERC165.sol)

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC165 standard, as defined in the
 * https://eips.ethereum.org/EIPS/eip-165[EIP].
 *
 * Implementers can declare support of contract interfaces, which can then be
 * queried by others ({ERC165Checker}).
 *
 * For an implementation, see {ERC165}.
 */
interface IERC165 {
    /**
     * @dev Returns true if this contract implements the interface defined by
     * `interfaceId`. See the corresponding
     * https://eips.ethereum.org/EIPS/eip-165#how-interfaces-are-identified[EIP section]
     * to learn more about how these ids are created.
     *
     * This function call must use less than 30 000 gas.
     */
    function supportsInterface(bytes4 interfaceId) external view returns (bool);
}
