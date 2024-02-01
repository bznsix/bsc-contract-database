/**
 *Submitted for verification at BscScan.com on 2024-01-28
*/

/**
 *Submitted for verification at testnet.bscscan.com on 2023-11-10
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

interface IPancakeFactory {
    function createPair(address tokenA,address tokenB) external returns (address pair);
    function getPair(address tokenA, address tokenB) external view returns (address pair);

}

interface IPancakeRouter {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);
}

interface IPancakePair {
    function totalSupply() external view returns (uint);

    function balanceOf(address owner) external view returns (uint);

    function transferFrom(
        address from,
        address to,
        uint value
    ) external returns (bool);

    function token0() external view returns (address);

    function token1() external view returns (address);

    function getReserves()
        external
        view
        returns (uint112 reserve0, uint112 reserve1, uint32 blockTimestampLast);
}

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }


}

abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor() {
        _transferOwnership(_msgSender());
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view virtual returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    function renounceOwnership() public virtual onlyOwner {
        _transferOwnership(address(0));
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(
            newOwner != address(0),
            "Ownable: new owner is the zero address"
        );
        _transferOwnership(newOwner);
    }

    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}

abstract contract DB {
    string public constant USER_ADDRESS = "user_address";
    string public constant PARENT = "parent";
    string public constant CHILD1 = "child1";
    string public constant CHILD2 = "child2";
    string public constant DIRECT_RECOMM_PARENT = "direct_recomm_parent";
    //member
    string public constant MEMBER_LEVEL = "member_level";
    string public constant MEMBER_U = "member_u";
    string public constant TOTAL_POWER = "total_power";

    //team
    string public constant TEAM_MEMBER_CNT = "team_member_cnt";
    string public constant TOTAL_TEAM_POWER = "total_team_power";

    //bouns
    string public constant TOTAL_BONUS_LP = "total_bonus_lp";
    string public constant UNCLAIMED_BONUS_LP = "unclaimed_bonus_lp";

    //Direct recomm reward
    string public constant TOTAL_DIRECT_REC_REWARD_LP = "direct_rec_reward_lp";
    string public constant TOTAL_TEAM_REC_REWARD_LP = "team_rec_reward_lp";

    //black
    string public constant IS_BLACK = "is_black";

    mapping(address => mapping(string => Data)) private teamData;
    mapping(address => address[]) public directRecList;

    struct Data {
        uint256 intValue;
        address addressValue;
    }


    function setIntData(
        address _address,
        string memory _key,
        uint256 _value
    ) internal {
        teamData[_address][_key].intValue = _value;
        if (teamData[_address][USER_ADDRESS].addressValue == address(0)) {
            teamData[_address][USER_ADDRESS].addressValue = _address;
        }
    }

    function setAddressData(
        address _address,
        string memory _key,
        address _value
    ) internal {
        teamData[_address][_key].addressValue = _value;
        if (teamData[_address][USER_ADDRESS].addressValue == address(0)) {
            teamData[_address][USER_ADDRESS].addressValue = _address;
        }
    }


    function getIntData(
        address _address,
        string memory _key
    ) public view returns (uint256) {
        return teamData[_address][_key].intValue;
    }

    function getAddressData(
        address _address,
        string memory _key
    ) public view returns (address) {
        return teamData[_address][_key].addressValue;
    }

    function addIntData(
        address _address,
        string memory _key,
        uint256 _value
    ) internal {
        teamData[_address][_key].intValue += _value;
        if (teamData[_address][USER_ADDRESS].addressValue == address(0)) {
            teamData[_address][USER_ADDRESS].addressValue = _address;
        }
    }

    function reduceIntData(
        address _address,
        string memory _key,
        uint256 _value
    ) internal {
        require(teamData[_address][_key].intValue >= _value);
        teamData[_address][_key].intValue -= _value;
    }

    function isExist(address _address) internal view returns (bool) {
        return teamData[_address][USER_ADDRESS].addressValue != address(0);
    }

}

// contract Queue {
//     uint256 private front;
//     uint256 private rear;
//     address[] private queue;

//     constructor() {
//         front = 0;
//         rear = 0;
//     }

//     function enqueue(address data) public {
//         queue.push(data);
//         rear++;
//     }

//     function dequeue() public returns (address) {
//         require(front < rear, "Queue is empty");
//         address data = queue[front];
//         delete queue[front];
//         front++;
//         return data;
//     }

//     function getFront() public view returns (address) {
//         require(front < rear, "Queue is empty");
//         return queue[front];
//     }

//     function getSize() public view returns (uint256) {
//         return rear - front;
//     }
// }

contract Team22Fall is DB, Context, Ownable {
    string private _name;
    string private _symbol;
    //team root
    mapping(address => bool) public teamRoots;
    address[] public teamRootKeys;

    uint256 public bfsMaxDeep;
    uint256 public queueMaxSize;


    mapping(address => bool) public wList;

    uint256 public totalTeamPower;

    uint private unlocked = 1;
    modifier lock() {
        require(unlocked == 1, "Team22Fall: LOCKED");
        unlocked = 0;
        _;
        unlocked = 1;
    }

    uint private unlockedTotalPower = 1;
    modifier lockTotalTeamPower() {
        require(unlockedTotalPower == 1, "Team22Fall: Claim LOCKED");
        unlockedTotalPower = 0;
        _;
        unlockedTotalPower = 1;
    }

    constructor()  {
        _name = "Team 22 Fall";
        _symbol = "Team22Fall";

        bfsMaxDeep = 20;
        queueMaxSize = 1024;

        setWList(msg.sender, true);
    }

    function name() public view  returns (string memory) {
        return _name;
    }

    /**
     * @dev Returns the symbol of the token, usually a shorter version of the
     * name.
     */
    function symbol() public view returns (string memory) {
        return _symbol;
    }
 
    function decimals() public pure   returns (uint8) {
        return 18;
    }

    modifier onlySupervise() {
        require(
            wList[_msgSender()] || _msgSender() == owner(), "Ownable: caller is not the supervise" );
        _;
    }

    function setManagerAddress(address addr) public onlySupervise {
        setWList(addr, true);
    }

    function setWList(address addr, bool flag) public onlyOwner {
        wList[addr] = flag;
    }

    function setBfsMaxDeep(uint256 maxDeep) public onlySupervise {
        bfsMaxDeep = maxDeep;
    }

    function setQueueMaxSize(uint256 size) public onlySupervise {
        queueMaxSize = size;
    }

    function setTeamRoot(address root, bool isRoot) public onlySupervise {
        teamRoots[root] = isRoot;
        teamRootKeys.push(root);
    }

    function getTeamRoots() external view returns (address[] memory) {
        return teamRootKeys;
    }

    function getTeamRoot(address root) external view returns (bool) {
        return teamRoots[root];
    }

    function getMemberLevel(address _address) external view returns (uint256) {
        return getIntData(_address, MEMBER_LEVEL);
    }

    function getMemberBuyU(address _address) external view returns (uint256) {
        return getIntData(_address, MEMBER_U);
    }

    function getPowerUT(address _address) external view returns (uint256 uPower, uint256 tPower) {
        uPower = getIntData(_address, TOTAL_POWER);
        tPower = totalTeamPower;
    }

    function getTeamTotalPower() external view returns (uint256) {
        return totalTeamPower;
    }

    function getDirectRecList(address _address) external view returns (address[] memory) {
        return directRecList[_address];
    }

    function getDirectRecInfo(address _address) external view returns (address directRecAddr, uint256 directRecLevel) {
        directRecAddr = getAddressData(_address, DIRECT_RECOMM_PARENT);
        directRecLevel = getIntData(directRecAddr, MEMBER_LEVEL);
    }

    function getTeamUpParentsAndLevels(
        address _address,
        uint256 num
    ) external view onlySupervise returns (address[] memory, uint256[] memory) {
        return _getTeamUpParentsAndLevels(_address, num);
    }
    function _getTeamUpParentsAndLevels(
        address _address,
        uint256 num
    ) internal view  returns (address[] memory, uint256[] memory) {
        address[] memory parents = new address[](num);
        uint256[] memory levels = new uint256[](num);
        if (_address != address(0) && num > 0) {
            address current = _address;
            for (uint256 i = 0; i < num; i++) {
                uint256 _l;
                address _p = getAddressData(current, PARENT);
                if (_p != address(0)) {
                    current = _p;
                    _l = getIntData(_p, MEMBER_LEVEL);
                    parents[i] = _p;
                    levels[i] = _l;
                } else {
                    break;
                }
            }
        }
        return (parents, levels);
    }

    struct UserInfo {
        address userAddr;
        address directRecAddr;
        address parentAddr;
        address c1Addr;
        address c2Addr;
        uint256 totalPower;
        uint256 level;
        uint256 teamMemCnt;
        uint256 totalBounsLp;
        uint256 unClaimBounsLp;
        uint256 totalDirectRecRewardLp;
        uint256 totalTeamRewardLp;
        uint256 totalBuyU;
    }

    function getUserInfo(address _address) external view returns (UserInfo memory) {
        UserInfo memory userInfo;
        userInfo.userAddr = getAddressData(_address, USER_ADDRESS);
        userInfo.directRecAddr = getAddressData(_address, DIRECT_RECOMM_PARENT);
        userInfo.parentAddr = getAddressData(_address, PARENT);
        userInfo.c1Addr = getAddressData(_address, CHILD1);
        userInfo.c2Addr = getAddressData(_address, CHILD2);
        userInfo.totalPower = getIntData(_address, TOTAL_POWER);
        userInfo.level = getIntData(_address, MEMBER_LEVEL);
        userInfo.teamMemCnt = getIntData(_address, TEAM_MEMBER_CNT);
        userInfo.totalBounsLp = getIntData(_address, TOTAL_BONUS_LP);
        userInfo.unClaimBounsLp = getIntData(_address, UNCLAIMED_BONUS_LP);
        userInfo.totalDirectRecRewardLp = getIntData(_address,TOTAL_DIRECT_REC_REWARD_LP);
        userInfo.totalTeamRewardLp = getIntData(_address,TOTAL_TEAM_REC_REWARD_LP);
        userInfo.totalBuyU = getIntData(_address, MEMBER_U);
        return userInfo;
    }

    function setIntValue(
        address _address,
        string memory _key,
        uint256 _value
    ) external onlySupervise {
        super.setIntData(_address, _key, _value);
    }

    function setAddressValue(
        address _address,
        string memory _key,
        address _value
    ) external onlySupervise {
        super.setAddressData(_address, _key, _value);
    }

    function memberUpgrade(
        address _address,
        uint256 newLevel,
        uint256 incPower
    ) external lock lockTotalTeamPower onlySupervise {
        setIntData(_address, MEMBER_LEVEL, newLevel);
        addIntData(_address, TOTAL_POWER, incPower);
        totalTeamPower += incPower;
    }

    function addDirectRecReward(
        address _address,
        uint256 incData
    ) external onlySupervise {
        super.addIntData(_address, TOTAL_DIRECT_REC_REWARD_LP, incData);
    }

    function addTeamReward(
        address _address,
        uint256 incData
    ) external onlySupervise {
        super.addIntData(_address, TOTAL_TEAM_REC_REWARD_LP, incData);
    }

    function addBonusLP(address _address, uint256 incData) external onlySupervise {
        super.addIntData(_address, TOTAL_BONUS_LP, incData);
    }

    function addTotalBuyUSDT(
        address _address,
        uint256 incData
    ) external onlySupervise {
        super.addIntData(_address, MEMBER_U, incData);
    }

    function addPower(address _address,uint256 incData) external lockTotalTeamPower onlySupervise {
        super.addIntData(_address, TOTAL_POWER, incData);
        totalTeamPower += incData;
    }

    function reducePower(address _address,uint256 incData) external lockTotalTeamPower onlySupervise {
        super.reduceIntData(_address, TOTAL_POWER, incData);
        if (totalTeamPower >= incData) {
            totalTeamPower -= incData;
        } else {
            totalTeamPower = 0;
        }
    }

    function setTotalTeamPower(uint256 totalPower) external lockTotalTeamPower onlySupervise {
        totalTeamPower = totalPower;
    }


    function isAlreadySeat(address _address) external view returns (bool) {
        return isExist(_address);
    }

    function initRoot(address _address, uint256 level) external lock onlySupervise {
        setIntData(_address, MEMBER_LEVEL, level);
    }

    function batchSeat(address[] memory addrs, address recAddr, uint256 level) external lock onlySupervise {
        require(isExist(recAddr), "rec address has not seat!");
        for (uint i = 0; i < addrs.length; i++) {
            if (!isExist(addrs[i])) {
                (address parentAddr ,) = find(recAddr);
                doSeat(recAddr, parentAddr, addrs[i], level);
            }
        }
    }

    function seat(address recAddr, address parentAddr, address _address, uint256 level) external lock onlySupervise returns (bool) {
        return doSeat(recAddr, parentAddr, _address, level);
    }
    function seat(address recAddr, address _address, uint256 level) external lock onlySupervise   returns (bool) {
        (address parentAddr ,) = find(recAddr);
        return doSeat(recAddr, parentAddr, _address, level);
    }

    function doSeat(address recAddr, address parentAddr, address _address, uint256 level) internal returns (bool) {
        require((recAddr != address(0)) && (parentAddr != address(0)) && (_address != address(0)),"has 0x0 address inputs, seat fail.");
        require(isExist(recAddr), "rec address has not seat!");
        require(isExist(parentAddr), "parent address has not seat!");
        if (!isExist(_address)) {
            address c1 = getAddressData(parentAddr, CHILD1);
            address c2 = getAddressData(parentAddr, CHILD2);
            if (c1 == address(0)) {
                setAddressData(parentAddr, CHILD1, _address);
            } else if (c2 == address(0)) {
                setAddressData(parentAddr, CHILD2, _address);
            } else {
                require(false, "seat failed, c1 and c2 are all existed!");
            }
            doSeatAndUpdateDirectRecParent(_address, recAddr, parentAddr, level);
            staticTeamMemberCnt(_address, bfsMaxDeep);
            return true;
        }
        return false;
    }

    function staticTeamMemberCnt(address _address, uint256 _bfsMaxDeep)  internal {
        if (_bfsMaxDeep >0) {
           (address[] memory parentAddrs,) = _getTeamUpParentsAndLevels(_address, bfsMaxDeep);
            for (uint i=0; i<parentAddrs.length ; i++){
                if (parentAddrs[i] != address(0)) {
                    addIntData(parentAddrs[i], TEAM_MEMBER_CNT, 1);
                } else {
                    break;
                }
            }
        }
    }

    function find(address recAddr) internal  view returns (address, uint256) {
        address[] memory queue = new address[](queueMaxSize);
        uint256 front = 0; // 队列的起始索引
        uint256 rear = 0; // 队列的结束索引

        require(rear - front < queueMaxSize, "Queue is full");
        queue[rear % queueMaxSize] = recAddr; // 实现循环队列的关键
        rear ++;

        while (rear - front >0) {
            address currentElement = queue[front % queueMaxSize];
            delete queue[front % queueMaxSize];
            front ++;
            if (isExist(currentElement)) {
                address c1 = getAddressData(currentElement, CHILD1);
                address c2 = getAddressData(currentElement, CHILD2);
                if (c1 != address(0)) {
                    require(rear - front < queueMaxSize, "Queue is full");
                    queue[rear % queueMaxSize] = c1; // 实现循环队列的关键
                    rear ++;
                } else {
                    return (currentElement, rear-front);
                }
                if (c2 != address(0)) {
                    require(rear - front < queueMaxSize, "Queue is full");
                    queue[rear % queueMaxSize] = c2; // 实现循环队列的关键
                    rear ++;
                } else {
                    return (currentElement, rear-front);
                }
            }
        }
        return (address(0), 0);
    }

    // function findAndSeat(
    //     address recAddr,
    //     address _address,
    //     uint256 level,
    //     bool fundMode
    // ) internal returns (bool) {
    //     Queue queue = new Queue();
    //     queue.enqueue(recAddr);
    //     while (queue.getSize() > 0) {
    //         address currentElement = queue.dequeue();
    //         if (isExist(currentElement)) {
    //             address c1 = getAddressData(currentElement, CHILD1);
    //             address c2 = getAddressData(currentElement, CHILD2);
    //             address realRecAddr = fundMode ? currentElement : recAddr;
    //             if (c1 != address(0)) {
    //                 queue.enqueue(c1);
    //             } else {
    //                 setAddressData(currentElement, CHILD1, _address);
    //                 doSeatAndUpdateDirectRecParent(
    //                     _address,
    //                     realRecAddr,
    //                     currentElement,
    //                     level
    //                 );
    //                 return true;
    //             }
    //             if (c2 != address(0)) {
    //                 queue.enqueue(c2);
    //             } else {
    //                 setAddressData(currentElement, CHILD2, _address);
    //                 doSeatAndUpdateDirectRecParent(
    //                     _address,
    //                     realRecAddr,
    //                     currentElement,
    //                     level
    //                 );
    //                 return true;
    //             }
    //         }
    //     }
    //     return false;
    // }

    function doSeatAndUpdateDirectRecParent(
        address _address,
        address recAddr,
        address parent,
        uint256 level
    ) internal {
        setAddressData(_address, PARENT, parent);
        setAddressData(_address, DIRECT_RECOMM_PARENT, recAddr);
        setIntData(_address, MEMBER_LEVEL, level);
        directRecList[recAddr].push(_address);
    }

}