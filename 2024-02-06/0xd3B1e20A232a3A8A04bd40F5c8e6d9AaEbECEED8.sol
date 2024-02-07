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

import "@openzeppelin/contracts/interfaces/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

interface RelationInterface {
    function getForefathers(address owner,uint num) external view returns(address[] memory fathers);
    function parentOf(address owner) external view returns(address);
}

interface DividendInterfact {
    function addMember(address _member, uint256 _level) external;
}

contract MstLand is Ownable {

    event BuyLand(
        address owner,
        uint256 landPrice
    );
    event DirectProfit(
        address owner,
        address sender,
        uint256 landPrice,
        uint256 amount,
        uint256 count
    );
    event RolloverProfit(
        address owner,
        address sender,
        uint256 landPrice,
        uint256 amount,
        uint256 myLevel
    );
    event PresidentProfit(
        address owner,
        address sender,
        uint256 landPrice,
        uint256 amount
    );
    event BossProfit(
        address owner,
        address sender,
        uint256 landPrice,
        uint256 amount
    );
    event WholeProfit(
        address owner,
        address sender,
        uint256 landPrice,
        uint256 amount
    );
    event DirectorProfit(
        address owner,
        address sender,
        uint256 landPrice,
        uint256 amount
    );
    event BoleProfit(
        address woner,
        address sender,
        uint256 landPrice,
        uint256 amount
    );
    event LevelUp(
        address owner,
        uint256 level
    );
    event Withdraw (
        address owner,
        uint256 amount
    );

    struct User {
        uint256 level;
        bool ownLand;
    }

    address public USDT = 0x55d398326f99059fF775485246999027B3197955;
    address public rewardToken = 0x55d398326f99059fF775485246999027B3197955; 
    uint256 public landPrice = 155 ether;
    address public president = 0x9e63d3e9504e1B8EB4fc5D67b5A024E29f531885;
    address public director = 0x1DC082F77330d1DdC695EfEaEE48396446e44B9a;
    address public boss = 0x2cDf295674b5f1647717a807fa799d0256562CdA;
    address public whole = 0x7D35Ac95E523aA3d6B5fB9A67126AC1f245E98B4;
    address public cfo = 0x1150Dcc751c6C73FB78744Cab59638E1C9fc5a1c;
    address public dividendContract;
    address public relation;
    uint256 public presidentRadio = 200;
    uint256 public directorRadio = 300;
    uint256 public bossRadio = 500;
    uint256 public wholeRadio = 400;
    uint256 public boleRadio = 10000;
    uint256[] public directRadio = [4000, 5000, 6000];

    mapping(uint256 => mapping(address => uint256)) public recommerLevelMap;
    mapping(address => uint256) public cloudWithdrawMap;
    mapping(address => mapping(address => mapping(uint256 => bool))) public marketStatisMap;
    mapping(address => User) public userInfo;

    constructor(address _relation, address _dividend) {
        relation = _relation;
        dividendContract = _dividend;
    }

    function setUSDT(address _usdt) external onlyOwner {
        USDT = _usdt;
    }

    function setLandPrice(uint256 _landPrice) external onlyOwner {
        landPrice = _landPrice;
    }

    function setRewardToken(address _rewardToken) external onlyOwner {
        rewardToken = _rewardToken;
    }

    function setPresident(address _president) external onlyOwner {
        president = _president;
    }

    function setDirector(address _director) external onlyOwner {
        director = _director;
    }

    function setBoss(address _boss) external onlyOwner {
        boss = _boss;
    }

    function setWhole(address _whole) external onlyOwner {
        whole = _whole;
    }

    function setCfo(address _cfo) external onlyOwner {
        cfo = _cfo;
    }

    function setDividendContract(address _dividendContract) external onlyOwner {
        dividendContract = _dividendContract;
    }

    function setRelation(address _relation) external onlyOwner {
        relation = _relation;
    }

    function setPresidentRadio(uint256 _presidentRadio) external onlyOwner {
        presidentRadio = _presidentRadio;
    }

    function setDirectorRadio(uint256 _directorRadio) external onlyOwner {
        directorRadio = _directorRadio;
    }

    function setBossRadio(uint256 _bossRadio) external onlyOwner {
        bossRadio = _bossRadio;
    }

    function setWholeRadio(uint256 _wholeRadio) external onlyOwner {
        wholeRadio = _wholeRadio;
    }

    function setBoleRadio(uint256 _boleRadio) external onlyOwner {
        boleRadio = _boleRadio;
    }

    function setDirectRadio(uint256 _radio1, uint256 _radio2, uint256 _radio3) external onlyOwner {
        directRadio[0] = _radio1;
        directRadio[1] = _radio2;
        directRadio[2] = _radio3;
    }

    // 购买土地
    function buyLand() external {
        address[] memory fathers = RelationInterface(relation).getForefathers(msg.sender, 50);
        address recommer = fathers[0];
        require(recommer != address(0), "please bind recommer");
        require(!userInfo[msg.sender].ownLand, "cannot buy land repeat");
        
        recommerLevelMap[0][recommer] += 1;
        
        // 直推奖
        if (recommerLevelMap[0][recommer] >= 3 && userInfo[recommer].ownLand) { // 60%直推奖
            cloudWithdrawMap[recommer] += (landPrice * directRadio[2] / 10000);
            emit DirectProfit(recommer, msg.sender, landPrice, landPrice * directRadio[2] / 10000, recommerLevelMap[0][recommer]);
        } else if (recommerLevelMap[0][recommer] == 2 && userInfo[recommer].ownLand) { // 50%直推奖
            cloudWithdrawMap[recommer] += (landPrice * directRadio[1] / 10000);
            emit DirectProfit(recommer, msg.sender, landPrice, landPrice * directRadio[1] / 10000, recommerLevelMap[0][recommer]);
        } else if (recommerLevelMap[0][recommer] == 1 && userInfo[recommer].ownLand) { // 40%直推奖
            cloudWithdrawMap[recommer] += (landPrice * directRadio[0] / 10000);
            emit DirectProfit(recommer, msg.sender, landPrice, landPrice * directRadio[0] / 10000, recommerLevelMap[0][recommer]);
        }

        // 流水奖
        uint256 rewardLevel = 0;
        for (uint256 i=0; i<fathers.length; i++) {
            if (fathers[i] == address(0)) {
                break;
            }
            User storage father = userInfo[fathers[i]];
            uint fatherLevel = father.level;
            if (fatherLevel > 6) {
                fatherLevel = 6;
            }
            if (fatherLevel > rewardLevel && fatherLevel <= 6 && userInfo[fathers[i]].ownLand) { // 可领取流水奖 3% + 星数加成2%
                uint level = fatherLevel - rewardLevel;
                uint256 myRadio = level * 2;
                if (rewardLevel == 0) {
                    myRadio = myRadio + 1;
                }
                uint256 rolloverBonus = landPrice * myRadio / 100;
                cloudWithdrawMap[fathers[i]] += rolloverBonus;
                emit RolloverProfit(fathers[i], msg.sender, landPrice, rolloverBonus, father.level);
                // 上级获得伯乐奖
                if (userInfo[RelationInterface(relation).parentOf(fathers[i])].level >= 3  && userInfo[RelationInterface(relation).parentOf(fathers[i])].ownLand) {
                    cloudWithdrawMap[RelationInterface(relation).parentOf(fathers[i])] += (rolloverBonus * boleRadio / 10000);
                    emit BoleProfit(RelationInterface(relation).parentOf(fathers[i]), fathers[i], landPrice, (rolloverBonus * boleRadio / 10000));
                }
                rewardLevel = fatherLevel;
                if (rewardLevel >= 6) {
                    break;
                }
            }
        }

        // 分红奖
        // 总裁分红2%
        cloudWithdrawMap[president] += (landPrice * presidentRadio / 10000);
        emit PresidentProfit(president, msg.sender, landPrice, landPrice * presidentRadio / 10000);
        // 董事分红3%
        cloudWithdrawMap[director] += (landPrice * directorRadio / 10000);
        emit DirectorProfit(director, msg.sender, landPrice, landPrice * directorRadio / 10000);
        // 老板分红5%
        cloudWithdrawMap[boss] += (landPrice * bossRadio / 10000);
        emit BossProfit(boss, msg.sender, landPrice, landPrice * bossRadio / 10000);
        // 全网分红
        cloudWithdrawMap[whole] += (landPrice * wholeRadio / 10000);
        emit WholeProfit(whole, msg.sender, landPrice, landPrice * wholeRadio / 10000); 

        // 升级
        levelUp(msg.sender);

        // 入账
        IERC20(USDT).transferFrom(msg.sender, cfo, landPrice);

        userInfo[msg.sender].ownLand = true;

        emit BuyLand(msg.sender, landPrice);
    }

    // 升级
    function levelUp(address sender) internal {
        DividendInterfact(dividendContract).addMember(sender, userInfo[sender].level);
        address[] memory fathers = RelationInterface(relation).getForefathers(sender, 50);
        uint256 level = userInfo[sender].level;
        for (uint256 i=0; i<fathers.length; i++) {
            User storage father = userInfo[fathers[i]];
            // 判断是否升级
            if ((father.level == 0 && recommerLevelMap[father.level][fathers[i]] >= 3)
                || (father.level >= 1 && father.level < 6 && recommerLevelMap[father.level][fathers[i]] >= 2)
                || (father.level >= 6 && father.level < 8 && recommerLevelMap[father.level][fathers[i]] >= 3)) {
                father.level += 1;
                level = father.level;
                // 直推人加数量
                if (!marketStatisMap[RelationInterface(relation).parentOf(fathers[i])][fathers[i]][level] && level > 0) {
                    recommerLevelMap[father.level][RelationInterface(relation).parentOf(fathers[i])] += 1;
                    marketStatisMap[RelationInterface(relation).parentOf(fathers[i])][fathers[i]][level] = true;

                }
                emit LevelUp(fathers[i], father.level);
            } else {
                if (!marketStatisMap[RelationInterface(relation).parentOf(fathers[i])][fathers[i]][level] && level > 0) {
                    recommerLevelMap[level][RelationInterface(relation).parentOf(fathers[i])] += 1;
                    marketStatisMap[RelationInterface(relation).parentOf(fathers[i])][fathers[i]][level] = true;
                }
            }
            if (father.ownLand) {
                DividendInterfact(dividendContract).addMember(fathers[i], father.level);
            }
        }
    }

    // 提取奖励
    function withdrawUSDT() external {
        if (cloudWithdrawMap[msg.sender] > 0) {
            uint withdrawAmount = cloudWithdrawMap[msg.sender];
            cloudWithdrawMap[msg.sender] = 0;
            IERC20(rewardToken).transfer(msg.sender, withdrawAmount);
            emit Withdraw(msg.sender, withdrawAmount);
        }
    }

    function sendLandByAdmin(address receiver) external onlyOwner {
        address recommer = RelationInterface(relation).parentOf(receiver);
        require(recommer != address(0), "please bind recommer");
        require(!userInfo[receiver].ownLand, "cannot buy land repeat");

        recommerLevelMap[0][recommer] += 1;
        levelUp(receiver);

        userInfo[receiver].ownLand = true;
        emit BuyLand(receiver, 0);
    }

    function ownLand(address owner) external view returns (bool) {
        return userInfo[owner].ownLand;
    }

    function withdrawToken(address token) external onlyOwner {
        IERC20(token).transfer(msg.sender, IERC20(token).balanceOf(address(this)));
    }
}