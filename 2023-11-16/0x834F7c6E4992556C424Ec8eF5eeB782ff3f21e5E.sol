contract Rel {
    event Bind(address indexed user, address indexed parent);
    event Upgrade(address indexed user, uint256 indexed level);

    address public pool;

    mapping(address => address) public parents;

    mapping(address => uint256) public levelPerUser;

    mapping(address => mapping(uint256 => uint256)) public countPerLevelPerUser;

    constructor(address genesis) {
        parents[genesis] = address(1);
        emit Bind(genesis, address(1));
    }

    function bind(address parent) external {
        require(parents[msg.sender] == address(0), "already bind");
        require(parents[parent] != address(0), "parent invalid");
        parents[msg.sender] = parent;
        countPerLevelPerUser[parent][0]++;
        emit Bind(msg.sender, parent);
    }

    function setPool(address adr) external {
        require(pool == address(0) && adr != address(0));
        pool = adr;
    }

    function setUserLevel(address user, uint256 newLevel) external {
        require(msg.sender == pool, "not allowed");
        levelPerUser[user] = newLevel;
        countPerLevelPerUser[user][newLevel - 1] = 5;
        emit Upgrade(user, newLevel);
    }

    function upgrade(address user) external {
        require(msg.sender == pool, "not allowed");
        uint256 oldLevel = levelPerUser[user];
        if (oldLevel == 0) {
            uint256 newLevel = 1;
            levelPerUser[user] = newLevel;
            emit Upgrade(user, newLevel);
            address p = parents[user];
            while (p != address(0) && p != address(1)) {
                countPerLevelPerUser[p][oldLevel]--;
                countPerLevelPerUser[p][newLevel]++;
                (oldLevel, newLevel) = getUserNewLevel(p);
                if (newLevel > oldLevel) {
                    levelPerUser[p] = newLevel;
                    emit Upgrade(p, newLevel);
                    p = parents[p];
                } else {
                    break;
                }
            }
        }
    }

    function getUserNewLevel(
        address adr
    ) private view returns (uint256 oldLevel, uint256 newLevel) {
        oldLevel = levelPerUser[adr];
        newLevel = oldLevel;
        if (oldLevel >= 1 && oldLevel <= 4) {
            uint256 s = countPerLevelPerUser[adr][5];
            for (uint256 i = 4; i >= oldLevel; --i) {
                s += countPerLevelPerUser[adr][i];
                if (i == 4 && s >= 3) { //5
                    newLevel = 5;
                } else if (i == 3 && s >= 3) {
                    newLevel = 4;
                } else if (i == 2 && s >= 5) {
                    newLevel = 3;
                } else if (i == 1 && s >= 5) {
                    newLevel = 2;
                }
            }
        }
    }
}