//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "./interfaces/IERC20Rebl.sol";
import "./interfaces/IREBLNFT.sol";
import "./libs/IterableMapping.sol";

interface IPancakeSwap {
    function WETH() external pure returns (address);

    function getAmountsOut(uint amountIn, address[] calldata path) external view returns (uint[] memory amounts);
}

interface IPancakePair {
    function getReserves() external view returns (uint112 reserve0, uint112 reserve1, uint32 blockTimestampLast);
}

interface IREBLStaking {
    struct UserStakingInfo {
        uint256 rewardUnblockTimestamp;
        uint256 usdtAmountForReward;
        uint256 tokenAmount;
        uint256 rAmount;
        uint256 periodInWeeks;
    }

    function stake(uint256 amount, uint256 periodInWeeks) external;

    function unstakeWithReward() external;

    function unstakeWithoutReward() external;

    function getPotentialNftReward(uint256 tokenAmount, uint256 periodInWeeks, address account) view external returns (uint256[] memory, uint256, uint256);

    function changeMultiplier(uint256 periodInWeeks, uint256 value) external;

    function getMinAmountToStake() external view returns (uint256);

    function usersStaking(address) external view returns (UserStakingInfo memory);

    function getActualNftReward(uint256 calculatedUsdtAmountForReward) view external returns (uint256[] memory);
}

contract REBLStakingV2 is IREBLStaking, Ownable {
    IREBLNFT public nftContract;
    using IterableMapping for IterableMapping.Map;
    IterableMapping.Map internal investors;

    struct Rank {
        address account;
        uint256 multipliedValue;
    }
    IPancakeSwap public router;
    IPancakePair bnbTokenPair = IPancakePair(0x54d79E2c9A7fe6d40623Ee0Cc91BF970Ce6fC150);
    IPancakePair bnbUsdtPair = IPancakePair(0x16b9a82891338f9bA80E2D6970FddA79D1eb0daE);

    address usdtAddress = 0x55d398326f99059fF775485246999027B3197955;
    address reblAddress = 0xbB8b7E9A870FbC22ce4b543fc3A43445Fbf9097f;
    address wbnbAddress = 0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c;
    IREBLStaking stakingV2 = IREBLStaking(0xC1b102872B2A85f09CfdC6723CF7506598112e82);

    mapping(address => bool) public startedMigrating;
    mapping(address => bool) public finalizedMigrating;

    mapping(uint256 => uint256) multiplierByWeekAmount;
    mapping(address => UserStakingInfo) public userStakingOf;
    mapping(address => UserStakingInfo) public tempUserStakingOf;
    uint256 constant MULTIPLIER_DENOMINATOR = 100;
     uint256 constant SECONDS_IN_WEEK = 1 weeks;

    constructor(
        address _nftContractAddress
    ) {
        initDEXRouter(0x10ED43C718714eb63d5aA57B78B54704E256024E);
        nftContract = IREBLNFT(_nftContractAddress);
        multiplierByWeekAmount[2] = 100;
        multiplierByWeekAmount[4] = 120;
        multiplierByWeekAmount[6] = 130;
        multiplierByWeekAmount[8] = 140;
        multiplierByWeekAmount[10] = 150;
        multiplierByWeekAmount[12] = 160;
        multiplierByWeekAmount[14] = 170;
        multiplierByWeekAmount[16] = 180;
        multiplierByWeekAmount[18] = 190;
        multiplierByWeekAmount[20] = 200;
    }

    function getAllInvestors() external view returns(Rank[] memory) {
        Rank[] memory rank = new Rank[](investors.size());
        address user;
        for(uint256 index = 0; index < investors.size(); index++) {
            user = investors.keys[index];
            rank[index] = Rank(user, investors.values[user]);
        }
        return rank;
    }

    function stake(uint256 amount, uint256 periodInWeeks) public override {
        require(periodInWeeks >= 2, "Min period for staking is 2 weeks");
        require(isEvenNumber(periodInWeeks), "Period in weeks should be even number");

        uint256 initialBalance = IERC20Rebl(reblAddress).balanceOf(address(this));
        IERC20Rebl(reblAddress).transferFrom(msg.sender, address(this), amount);
        amount = IERC20Rebl(reblAddress).balanceOf(address(this)) - initialBalance;

        uint256 calculatedUsdtAmountForReward = calculateUsdtAmountForReward(amount, periodInWeeks);
        uint256 calculatedUSDT = userStakingOf[msg.sender].usdtAmountForReward + calculatedUsdtAmountForReward;
        uint256 tokenAmount = userStakingOf[msg.sender].tokenAmount + amount;
        uint256 newRAmount = IERC20Rebl(reblAddress).reflectionFromToken(amount, false);
        uint256 rAmount = userStakingOf[msg.sender].rAmount + newRAmount;
        uint256 unstakeTimestamp = calculateUnstakeTimestamp(periodInWeeks);
        if (unstakeTimestamp < userStakingOf[msg.sender].rewardUnblockTimestamp) {
            unstakeTimestamp = userStakingOf[msg.sender].rewardUnblockTimestamp;
        }
        investors.set(msg.sender, calculatedUSDT);
        userStakingOf[msg.sender] = UserStakingInfo(unstakeTimestamp, calculatedUSDT, tokenAmount, rAmount, periodInWeeks);
    }

    function startMigrating() external {
        require(!startedMigrating[msg.sender], "Migrating already started");
        UserStakingInfo memory infoV1 = stakingV2.usersStaking(msg.sender);
        require(infoV1.rewardUnblockTimestamp > block.timestamp, "You don't have active stake");
        tempUserStakingOf[msg.sender] = infoV1;
        startedMigrating[msg.sender] = true;
    }

    function finalizeMigrating() external {
        require(!finalizedMigrating[msg.sender], "Migrating already finalized");
        IERC20Rebl rebl = IERC20Rebl(reblAddress);
        uint256 amount = tempUserStakingOf[msg.sender].tokenAmount;
        uint256 initialBalance = rebl.balanceOf(address(this));
        rebl.transferFrom(msg.sender, address(this), amount);
        require(rebl.balanceOf(address(this)) - initialBalance >= amount, "Wrong transfer amount");
        userStakingOf[msg.sender] = tempUserStakingOf[msg.sender];
        investors.set(msg.sender, tempUserStakingOf[msg.sender].usdtAmountForReward);
        finalizedMigrating[msg.sender] = true;
    }

    function unstakeWithReward() public override {
        require(block.timestamp >= userStakingOf[msg.sender].rewardUnblockTimestamp, "Reward is not available yet");
        nftContract.mintToByAmount(msg.sender, userStakingOf[msg.sender].usdtAmountForReward);
        uint256 tokenAmount = IERC20Rebl(reblAddress).tokenFromReflection(userStakingOf[msg.sender].rAmount);
        IERC20Rebl(reblAddress).transfer(msg.sender, tokenAmount);
        _clearUserStaking(msg.sender);
    }

    function unstakeWithoutReward() public override {
        uint256 tokenAmount = IERC20Rebl(reblAddress).tokenFromReflection(userStakingOf[msg.sender].rAmount);
        IERC20Rebl(reblAddress).transfer(msg.sender, tokenAmount);
        _clearUserStaking(msg.sender);
    }

    function usersStaking(address account) external override view returns (UserStakingInfo memory) {
        return userStakingOf[account];
    }

    function getPotentialNftReward(uint256 tokenAmount, uint256 periodInWeeks, address account) view public override returns (uint256[] memory, uint256, uint256) {
        uint256 calculatedUsdtAmountForReward = calculateUsdtAmountForReward(tokenAmount, periodInWeeks);
        uint256 unlockTimestamp = block.timestamp + periodInWeeks * SECONDS_IN_WEEK;
        if (userStakingOf[account].usdtAmountForReward > 0) {
            calculatedUsdtAmountForReward += userStakingOf[account].usdtAmountForReward;
            if (userStakingOf[account].rewardUnblockTimestamp > unlockTimestamp) {
                unlockTimestamp = userStakingOf[account].rewardUnblockTimestamp;
            }
        }
        return (getNftReward(calculatedUsdtAmountForReward), calculatedUsdtAmountForReward, unlockTimestamp);
    }

    function getActualNftReward(uint256 calculatedUsdtAmountForReward) view public override returns (uint256[] memory) {
        uint256[] memory nftReward = getNftReward(calculatedUsdtAmountForReward);
        return nftReward;
    }

    function getNftReward(uint256 calculatedUsdtAmountForReward) view internal returns (uint256[] memory) {
        uint256[] memory levelsUsdtValues = nftContract.getLevelsUsdtValues();
        uint256 lowestNftUsdtValue = nftContract.getLowestLevelUsdtValue();
        uint256[] memory levelsCount = new uint256[](levelsUsdtValues.length);
        while (calculatedUsdtAmountForReward >= lowestNftUsdtValue) {
            for (uint256 i = levelsUsdtValues.length; i > 0; i--) {
                if (calculatedUsdtAmountForReward >= levelsUsdtValues[i - 1]) {
                    levelsCount[i - 1]++;
                    calculatedUsdtAmountForReward -= levelsUsdtValues[i - 1];
                    break;
                }
            }
        }
        return levelsCount;
    }

    function changeMultiplier(uint256 periodInWeeks, uint256 value) public override onlyOwner {
        multiplierByWeekAmount[periodInWeeks] = value;
    }

    function updateNFTContract(address _newAddress) public  onlyOwner {
        nftContract = IREBLNFT(_newAddress);
    }

    function _clearUserStaking(address userAddress) internal {
        userStakingOf[userAddress].usdtAmountForReward = 0;
        userStakingOf[userAddress].tokenAmount = 0;
        userStakingOf[userAddress].rAmount = 0;
        userStakingOf[userAddress].rewardUnblockTimestamp = 0;
        investors.remove(userAddress);
    }

    function calculateMultiplier(uint256 periodInWeeks) view internal returns (uint256) {
        if (periodInWeeks > 18) {
            return multiplierByWeekAmount[20];
        }
        return multiplierByWeekAmount[periodInWeeks];
    }

    function isEvenNumber(uint256 number) internal pure returns (bool) {
        uint256 div = number / 2;
        return div * 2 == number;
    }

    function calculateUnstakeTimestamp(uint256 periodInWeeks) internal view returns (uint256) {
        return block.timestamp + periodInWeeks * SECONDS_IN_WEEK;
    }

    function calculateUsdtAmountForReward(uint256 amount, uint256 periodInWeeks) public view returns (uint256) {
        uint256 multiplier = calculateMultiplier(periodInWeeks);
        return calculateTokensPriceInUSDT(amount) * multiplier * (periodInWeeks / 2) / MULTIPLIER_DENOMINATOR;
    }

    function calculateTokensPriceInUSDT(uint256 tokenAmount) public view returns (uint256) {
        (uint256 token1Amount, uint256 token2Amount, ) = bnbTokenPair.getReserves();
        (uint256 tokenReserveForBnbPair, uint256 bnbReserve) = reblAddress < wbnbAddress ? (token1Amount, token2Amount) : (token2Amount, token1Amount);
        (uint256 token3Amount, uint256 token4Amount, ) = bnbUsdtPair.getReserves();
        (uint256 usdtReserve, uint256 bnbReserveForUsdtPair) = usdtAddress < wbnbAddress ? (token3Amount, token4Amount) : (token4Amount, token3Amount);
        return tokenAmount * bnbReserve / bnbReserveForUsdtPair * usdtReserve / tokenReserveForBnbPair;
    }

    function calculateTokensAmountForUsdt(uint256 usdtAmount) public view returns (uint256) {
        (uint256 token1Amount, uint256 token2Amount, ) = bnbUsdtPair.getReserves();
        (uint256 usdtReserve, uint256 bnbReserveForUsdtPair) = usdtAddress < wbnbAddress ? (token1Amount, token2Amount) : (token2Amount, token1Amount);
        (uint256 token3Amount, uint256 token4Amount, ) = bnbTokenPair.getReserves();
        (uint256 tokenReserveForBnbPair, uint256 bnbReserve) = reblAddress < wbnbAddress ? (token3Amount, token4Amount) : (token4Amount, token3Amount);
        return usdtAmount * bnbReserveForUsdtPair / usdtReserve * tokenReserveForBnbPair / bnbReserve;
    }

    function initDEXRouter(address _router) public onlyOwner {
        IPancakeSwap _pancakeV2Router = IPancakeSwap(_router);
        router = _pancakeV2Router;
    }

    function getMinAmountToStake() public view override returns (uint256) {
        return calculateTokensAmountForUsdt(nftContract.getLowestLevelUsdtValue());
    }
}
// SPDX-License-Identifier: MIT

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
        _setOwner(_msgSender());
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

    /**
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions anymore. Can only be called by the current owner.
     *
     * NOTE: Renouncing ownership will leave the contract without an owner,
     * thereby removing any functionality that is only available to the owner.
     */
    function renounceOwnership() public virtual onlyOwner {
        _setOwner(address(0));
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _setOwner(newOwner);
    }

    function _setOwner(address newOwner) private {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}
// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IERC20Rebl {
    /**
     * @dev Returns the amount of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the amount of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Moves `amount` tokens from the caller's account to `recipient`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address recipient, uint256 amount) external returns (bool);

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
     * @dev Moves `amount` tokens from `sender` to `recipient` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);

    /*
     * To get rAmount by tAmount form token contract.
    */
    function reflectionFromToken(
        uint256 tAmount,
        bool deductTransferFee
    ) external view returns(uint256);
    /*
     * To get tAmount by rAmount form token contract.
    */
    function tokenFromReflection(uint256 rAmount) external view returns(uint256);

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
}
// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

interface IREBLNFT {
    function mintToByAmount(address to, uint256 usdtAmount) external;
    function mintToByOwner(address to, uint256 level) external;
    function getLevelsUsdtValues() external view returns (uint256[] memory);
    function getLowestLevelUsdtValue() external view returns (uint256);
}// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

library IterableMapping {
    struct Map {
        address[] keys;
        mapping(address => uint) values;
        mapping(address => uint) indexOf;
        mapping(address => bool) inserted;
    }

    function get(Map storage map, address key) public view returns (uint) {
        return map.values[key];
    }

    function getIndexOfKey(Map storage map, address key) public view returns (int) {
        if(!map.inserted[key]) {
            return -1;
        }
        return int(map.indexOf[key]);
    }

    function getKeyAtIndex(Map storage map, uint index) public view returns (address) {
        return map.keys[index];
    }



    function size(Map storage map) public view returns (uint) {
        return map.keys.length;
    }

    function set(Map storage map, address key, uint val) public {
        if (map.inserted[key]) {
            map.values[key] = val;
        } else {
            map.inserted[key] = true;
            map.values[key] = val;
            map.indexOf[key] = map.keys.length;
            map.keys.push(key);
        }
    }

    function remove(Map storage map, address key) public {
        if (!map.inserted[key]) {
            return;
        }

        delete map.inserted[key];
        delete map.values[key];

        uint index = map.indexOf[key];
        uint lastIndex = map.keys.length - 1;
        address lastKey = map.keys[lastIndex];

        map.indexOf[lastKey] = index;
        delete map.indexOf[key];

        map.keys[index] = lastKey;
        map.keys.pop();
    }
}
// SPDX-License-Identifier: MIT

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
