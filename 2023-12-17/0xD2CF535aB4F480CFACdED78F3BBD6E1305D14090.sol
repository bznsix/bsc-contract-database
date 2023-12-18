// SPDX-License-Identifier: UNLICENSED

/**
 *
 *
 *██████╗░██╗██████╗░░█████╗░████████╗███████╗░██████╗██╗░░██╗██╗██████╗░
 *██╔══██╗██║██╔══██╗██╔══██╗╚══██╔══╝██╔════╝██╔════╝██║░░██║██║██╔══██╗
 *██████╔╝██║██████╔╝███████║░░░██║░░░█████╗░░╚█████╗░███████║██║██████╔╝
 *██╔═══╝░██║██╔══██╗██╔══██║░░░██║░░░██╔══╝░░░╚═══██╗██╔══██║██║██╔═══╝░
 *██║░░░░░██║██║░░██║██║░░██║░░░██║░░░███████╗██████╔╝██║░░██║██║██║░░░░░
 *╚═╝░░░░░╚═╝╚═╝░░╚═╝╚═╝░░╚═╝░░░╚═╝░░░╚══════╝╚═════╝░╚═╝░░╚═╝╚═╝╚═╝░░░░░
 *
 *
 * Web: https://pirateship.cc/
 *
 * Telegram: @PirateShip_cc
 *
 */

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IERC20 {

    /**
     * @dev Moves a `value` amount of tokens from the caller's account to `to`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address to, uint256 value) external returns (bool);


    /**
     * @dev Moves a `value` amount of tokens from `from` to `to` using the
     * allowance mechanism. `value` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(address from, address to, uint256 value) external returns (bool);
    /**
     * @dev Returns the value of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

}

pragma solidity ^0.8.16;

contract PirateShip {
    struct Ship {
        uint256 doubloons;
        uint256 gold;
        uint256 gold2;
        uint256 yield;
        uint256 timestamp;
        uint256 hrs;
        address ref;
        uint256 refs;
        uint256 refDeps;
        uint8[7] pirates;
        uint256 totalDoubloonsSpend;
        uint256 totalGoldReceived;
    }
    mapping(address => Ship) public decks;
    uint256 public totalPirates;
    uint256 public totalShips;
    uint256 public totalInvested;
    address public manager = 0x35E4299Eb8574A5d5508Cb497d3261B18C3551B0;

    IERC20 usdt = IERC20(0x55d398326f99059fF775485246999027B3197955);

    function addDoubloons(address ref,uint256 tokenAmount) public {
        usdt.transferFrom(msg.sender, address(this), tokenAmount);
        uint256 doubloons = tokenAmount / 1e16;
        require(doubloons > 0, "Zero doubloons");
        address user = msg.sender;
        totalInvested += tokenAmount;
        if (decks[user].timestamp == 0) {
            totalShips++;
           ref = decks[ref].timestamp == 0 ? manager : ref;
            decks[ref].refs++;
            decks[user].ref = ref;
            decks[user].timestamp = block.timestamp;
        }
        ref = decks[user].ref;
        decks[ref].doubloons += (doubloons * 6) / 100;
        decks[ref].gold += (doubloons * 100 * 4) / 100;
        decks[ref].refDeps += doubloons;
        decks[user].doubloons += doubloons;
        usdt.transfer(manager,(tokenAmount * 10) / 100);
    }

    function withdrawGold() public {
        address user = msg.sender;
        uint256 gold = decks[user].gold;
        decks[user].gold = 0;
        uint256 amount = gold * 1e14;
        usdt.transfer(user,usdt.balanceOf(address(this)) < amount ? usdt.balanceOf(address(this)) : amount);
    }

    function collectGold() public {
        address user = msg.sender;
        syncShip(user);
        decks[user].hrs = 0;
        decks[user].gold += decks[user].gold2;
        decks[user].gold2 = 0;
    }

    function upgradeShip(uint256 pirateId) public {
        require(pirateId < 7, "Maximum 7 Pirates");
        address user = msg.sender;
        if(pirateId>0){
        require(decks[user].pirates[pirateId-1]>=3,"Need to buy previous Pirate");
        }
        syncShip(user);
        decks[user].pirates[pirateId]++;
        totalPirates++;
        uint256 pirates = decks[user].pirates[pirateId];
        decks[user].doubloons -= getUpgradePrice(pirateId, pirates);
        decks[user].totalDoubloonsSpend += getUpgradePrice(pirateId, pirates);
        decks[user].yield += getYield(pirateId, pirates);
    }

    function getPirates(address addr) public view returns (uint8[7] memory) {
        return decks[addr].pirates;
    }

    function syncShip(address user) internal {
        require(decks[user].timestamp > 0, "User is not registered");
        if (decks[user].yield > 0) {
            uint256 hrs = block.timestamp / 3600 - decks[user].timestamp / 3600;
            if (hrs + decks[user].hrs > 24) {
                hrs = 24 - decks[user].hrs;
            }
            uint256 yield = hrs * decks[user].yield;
            if((decks[user].totalGoldReceived+yield) > ((decks[user].totalDoubloonsSpend)*220)){
                 decks[user].gold2 += (decks[user].totalDoubloonsSpend*220)-(decks[user].totalGoldReceived);
                 decks[user].totalGoldReceived += (decks[user].totalDoubloonsSpend*220)-(decks[user].totalGoldReceived);
                 decks[user].yield = 0;
                 for(uint8 i=0;i<7;i++){
                        decks[user].pirates[i]=0;
                 }
            }else{
                decks[user].gold2 += yield;
                decks[user].totalGoldReceived += yield;
            }
            decks[user].hrs += hrs;
        }
        decks[user].timestamp = block.timestamp;
    }

   function getUpgradePrice(uint256 pirateId, uint256 piratesId) internal pure returns (uint256) {
        if (piratesId == 1) return [200, 1400, 3000, 13000, 30000, 120000, 350000][pirateId];
        if (piratesId == 2) return [500, 1900, 5000, 15000, 50000, 150000, 450000][pirateId];
        if (piratesId == 3) return [1000, 2500, 8000, 20000, 90000, 220000, 900000][pirateId];
        revert("Incorrect piratesId");
    }

    function getYield(uint256 pirateId, uint256 piratesId) internal pure returns (uint256) {
        if (piratesId == 1) return [17, 123, 275, 1219, 2880, 11750, 35000][pirateId];
        if (piratesId == 2) return [42, 167, 459, 1407, 4793, 14690, 45000][pirateId];
        if (piratesId == 3) return [85, 219, 735, 1875, 8630, 21542, 90000][pirateId];
        revert("Incorrect piratesId");
    }
}