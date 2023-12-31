//SPDX-License-Identifier: UNLICENSED

pragma solidity 0.8.17;

import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "./shard_warriors_lib.sol";
interface IERC20 {
  function totalSupply() external view returns (uint256);

  function balanceOf(address account) external view returns (uint256);

  function transfer(address recipient, uint256 amount)
  external
  returns (bool);

  function allowance(address owner, address spender)
  external
  view
  returns (uint256);

  function approve(address spender, uint256 amount) external returns (bool);

  function transferFrom(
    address sender,
    address recipient,
    uint256 amount
  ) external returns (bool);

  event Transfer(address indexed from, address indexed to, uint256 value);
  event Approval(
    address indexed owner,
    address indexed spender,
    uint256 value
  );
}

interface IShardWarriorsGame {
  struct heroStats {
    uint256 hp; // health
    uint256 mana; // mana
    uint256 attack; // attack
    uint256 def; // defense
    uint256 magic; // magic
    uint256 level; // level
    bool isDead; // killed?
  }
  struct HeroBattle {
    uint256 id;
    address player1;
    address player2;
    uint256 battleCost;
    uint256 result;
    heroStats p1;
    heroStats p2;
    uint256 turnP1;
    uint256 turnP2;
    uint256 timestampP1;
    uint256 timestampP2;
    uint256 randomTurnP1;
    uint256 randomTurnP2;
    uint256 p1HeroId;
    uint256 p2HeroId;
    uint256 p1faction;
    uint256 p2faction;
  }

  struct Army {
    heroStats[20] stat; // heroes stats
  }

  function isHeroDead(address user, uint256 heroId) external returns(bool);
  function getHeroLevel(address user, uint256 heroId) external returns(uint256);
  function setHeroLevel(address user, uint256 heroId) external returns(bool);
  function setUpgradeHeroLevel(address user, uint256 heroId, uint256 statIndex) external returns(bool);
  function setHeroDead(address user, uint256 heroId) external returns(bool);
  function fillHeroesStats(address user, uint256 faction) external returns(bool);
  function fightTurn(address user, uint256 turn, uint256 battleId) external;
  function getHeroBattle(uint256 battleId) external view returns (HeroBattle memory);
  function fightCreateOrJoin(address user, uint256 cost, uint256 heroId, uint256 faction) external returns (uint256);
  function calcRewards(uint256 battleId) external returns(uint256[3] memory);
}

contract ShardWarriors {
  using SafeMath for uint256;
  IERC20 public USDTBep20;
  address public USDTBep20address = 0x55d398326f99059fF775485246999027B3197955; //0xD0071e9142638E4d88C9011799ED117536Dcd19c; //0x337610d27c682E347C9cD60BD4b3b107C9d34dDd;//0x55d398326f99059fF775485246999027B3197955; //USDT Bep20
  using ShardWarriorsLibrary for *;
  IShardWarriorsGame gameContract;

  event addShardEvent(address indexed sender, uint256 value);
  event withdrawGoldEvent(address indexed sender, uint256 value);

  struct Building {
    bool active; // flag indicating if the building is active
    uint256 startTs; // start time of construction
    uint256 endTs; // end time of construction
    uint256 collectTs; // time to collect resources
  }

  struct Warrior {
    uint256 faction; // 0) user faction
    uint256 shard; // 1) shards = 100 gold
    uint256 sphere; // 2) spheres = 1000 gold
    uint256 gold; // 3) gold only
    uint256 regTs; // 4) registration timestamp
    //uint256 referals; // number of referrals
    address refL1; // 5) L1 referral 3%
    address refL2; // 6) L2 referral 2%
    address refL3; // 7) L3 referral 1%
    Building[24] myBuildings; // 8) user's buildings
    uint256 myHero; // 9) user's hero
    uint256 battleId; // 10) active battle
  }

  mapping(address => Warrior) private warriors; // list of warriors by address

  uint256 public totalBuildings; // total number of buildings
  uint256 public totalWarriors; // total number of warriors
  uint256 public totalHeroes; // total number of heroes
  uint256 public totalInvestments; // total investments in the contract

  address payable public owner = payable(address(0x3DF0BCfB484BCc7e51ab3FFe04A2ceE2814a48fB)); // owner's address (3%)
  address payable public manager = payable(address(0x1066B070920aeF7BE52d73E1EC0b2a727BFa1ff7)); // manager's address (1%)
  address payable public marketing = payable(address(0xaC90af29a24A5a207F247CbC5212586125d253e1)); // marketing address (1%)

  modifier onlyUser() {
    require(msg.sender == tx.origin, "Function can only be called by a user account.");
    require(msg.sender != address(0), "Null address");
    _;
  }

  constructor(address gameContractAddress) {
    USDTBep20 = IERC20(USDTBep20address);
    gameContract = IShardWarriorsGame(gameContractAddress);
  }

  function getWarrior() external view onlyUser returns (Warrior memory) {
    return warriors[msg.sender];
  }

  function registerMe(address referrer, uint256 faction)
  external onlyUser {
    address user = msg.sender;
    require(warriors[user].regTs == 0, "already registered");
    require(faction >= 0 && faction < 4, "no faction");
    totalWarriors = totalWarriors.add(1);

    // refs
    address refL1 = warriors[referrer].regTs == 0 ? marketing: referrer;
    address refL2 = warriors[refL1].regTs == 0 ? marketing: warriors[refL1].refL1;
    address refL3 = warriors[refL2].regTs == 0 ? marketing: warriors[refL2].refL1;

    //set user refs
    warriors[user].refL1 = refL1;
    warriors[user].refL2 = refL2;
    warriors[user].refL3 = refL3;
    warriors[user].faction = faction;

    warriors[user].regTs = block.timestamp; //регистрация завершена
    // helper fillHeroesStats function random fill heroes stats
    require(gameContract.fillHeroesStats(user, faction), "Error creating heroes!");
  }

  // purchase shards
  function addShard (uint256 amountUSDT)
  external onlyUser {
    address user = msg.sender;
    require(warriors[user].regTs != 0, "not registered");

    uint256 shard = amountUSDT.mul(120); //msg.value.div(2e13);
    require(shard > 0, "Zero shard");
    require(USDTBep20.transferFrom(address(msg.sender), address(this), amountUSDT.mul(1e18)), "Error transfer USDT");

    totalInvestments = totalInvestments.add(amountUSDT);

    // calc refs gold
    address rL1 = warriors[user].refL1;
    address rL2 = warriors[user].refL2;
    address rL3 = warriors[user].refL3;

    warriors[rL1].gold = warriors[rL1].gold.add(shard.mul(3));
    warriors[rL2].gold = warriors[rL2].gold.add(shard.mul(2));
    warriors[rL3].gold = warriors[rL3].gold.add(shard.mul(1));

    // commission calculations
    uint256 goldFee = (amountUSDT.mul(3)).div(100);
    uint256 managerFee = (amountUSDT.mul(2)).div(100);
    uint256 marketingFee = (amountUSDT.mul(1)).div(100);

    payUSDT(goldFee, owner);
    payUSDT(managerFee, manager);
    payUSDT(marketingFee, marketing);
    warriors[user].shard = warriors[user].shard.add(shard);
    emit addShardEvent(user, amountUSDT);
  }

  // The function withdrawGold allows the user to withdraw gold from the smart contract
  function withdrawGold (uint256 amount)
  external onlyUser {
    // Check that the function is called by the user and not by another contract
    // Check that the amount of gold is greater than or equal to 100
    require(amount >= 100, "Invalid amount");

    // Address of the transaction sender
    address user = msg.sender;

    // Amount of USDT to withdraw gold
    uint256 usdt = amount.div(120).div(100); //12000=1usdt
    warriors[user].gold = warriors[user].gold.sub(amount);

    // Transfer the funds if the contract has sufficient balance
    payUSDT(usdt, user);

    emit withdrawGoldEvent(user, usdt);
  }

  // The function swapGoldForShard allows the user to exchange gold for shards
  function swapGoldForShardOrSphere(uint256 amount, bool sphere)
  external onlyUser {
    // Check that the amount of gold is greater than or equal to 100
    require(amount >= 100, "Invalid amount");
    // Address of the transaction sender
    address user = msg.sender;

    // Modify the contract state: subtract the amount of gold from the user and add shards
    warriors[user].gold = warriors[user].gold.sub(amount);
    if (sphere)
      warriors[user].sphere = warriors[user].sphere.add(amount.div(1000));
    else
      warriors[user].shard = warriors[user].shard.add(amount.div(100));

  }

  // The function purchaseBuilding allows the user to purchase a building
  function purchaseBuilding (uint256 buildingId)
  external onlyUser {
    // Check that the building identifier is less than 24
    require(buildingId < 24, "No such building");
    // Address of the transaction sender
    address user = msg.sender;
    // Check that the building has not already been purchased by the user
    require(
      warriors[user].myBuildings[buildingId].active == false,
      "This building already exists!"
    );
    // Synchronize user data
    syncWarrior(user);
    // Modify the contract state: set the building parameters
    warriors[user].myBuildings[buildingId].active = true;

    warriors[user].myBuildings[buildingId].startTs = block.timestamp;
    warriors[user].myBuildings[buildingId].endTs = block.timestamp + 100 days;
    warriors[user].myBuildings[buildingId].collectTs = block.timestamp;
    totalBuildings = totalBuildings.add(1);

    // Deduct the cost of the building from shards or spheres depending on its identifier
    if (buildingId < 12)
      warriors[user].shard = warriors[user].shard.sub(ShardWarriorsLibrary.getPurchaseBuildingPrice(buildingId));
    if (buildingId >= 12 && buildingId < 24)
      warriors[user].sphere = warriors[user].sphere.sub(ShardWarriorsLibrary.getPurchaseBuildingPrice(buildingId));

  }

  function purchaseHero (uint256 heroId)
  external onlyUser {
    // Check if heroId is less than 20
    require(heroId < 20, "No such hero");
    // Transaction sender address
    address user = msg.sender;
    // Check if the user has not already purchased a hero
    require(
      warriors[user].myHero == 0,
      "You got hero already!"
    );
    // Check if the hero is not currently in battle
    require(
      warriors[user].battleId == 0,
      "You are in battle!"
    );

    // Check if the hero is not dead
    require(gameContract.isHeroDead(user, heroId) == false,
      //armies[user].stat[heroId].isDead == false,
      "This hero is Dead!"
    );
    // Deduct the cost of the hero from shards
    warriors[user].shard = warriors[user].shard.sub(2400);
    totalHeroes = totalHeroes.add(1);
    gameContract.setHeroLevel(user, heroId);
    // Save the selected hero
    warriors[user].myHero = heroId.add(1);
  }

  function upgradeHero (uint256 statIndex)
  external onlyUser {
    // Transaction sender address
    address user = msg.sender;
    // Check if the statIndex is valid
    require(statIndex < 5, "No such stat");
    // Check if the hero is not currently in battle
    require(
      warriors[user].battleId == 0,
      "You are in battle!"
    );
    uint256 heroId = warriors[user].myHero;
    // Check if the heroId is valid
    require(heroId > 0 && heroId < 21, "No such hero");

    heroId = heroId.sub(1);

    uint256 heroLevel = gameContract.getHeroLevel(user, heroId);
    //armies[user].stat[heroId].level;

    // Check if the hero level does not exceed the maximum value
    require(heroLevel <= 20, "Max hero level exceeded");

    // Deduct the cost of upgrading the hero from shards or spheres depending on its level
    if (heroLevel <= 10)
      warriors[user].shard = warriors[user].shard.sub(ShardWarriorsLibrary.getUpgradeHeroPrice()); //heroLevel));
    if (heroLevel > 10 && heroLevel <= 20)
      warriors[user].sphere = warriors[user].sphere.sub(ShardWarriorsLibrary.getUpgradeHeroPriceSphere()); //heroLevel));

    require(gameContract.setUpgradeHeroLevel(user, heroId, statIndex), "Error upgrading");

  }

  function killHero()
  external onlyUser {
    // Transaction sender address
    address user = msg.sender;
    // Check if the hero is not currently in battle
    require(
      warriors[user].battleId == 0,
      "You are in battle!"
    );
    uint256 heroId = warriors[user].myHero;
    // Check if the heroId is valid
    require(heroId > 0 && heroId < 21, "No such hero");

    heroId = heroId.sub(1);
    require(gameContract.setHeroDead(user, heroId), "Can't dismiss hero!");
    warriors[user].myHero = 0;

    totalHeroes = totalHeroes.sub(1);
  }

  // The collectGold function allows the user to collect accumulated gold
  function collectGold()
  external onlyUser {
    // Transaction sender address
    address user = msg.sender;
    // Check if the user is registered
    require(warriors[user].regTs > 0, "User is not registered");

    // Synchronize user data
    syncWarrior(user);

  }

  // The auxiliary function syncWarrior synchronizes user data
  function syncWarrior(address user) internal {
    // Check if the user is registered
    uint256 gold = 0;
    for (uint i = 0; i < 24; i++) {
      // Check if the building is active and its end time is greater than the current time
      if (warriors[user].myBuildings[i].active == true &&
        warriors[user].myBuildings[i].endTs > block.timestamp) {

        // Calculate the elapsed time in hours
        uint256 hoursElapsed = block.timestamp.div(3600).sub(warriors[user].myBuildings[i].collectTs.div(3600));
        // Increase the gold collection time by the number of elapsed hours
        warriors[user].myBuildings[i].collectTs = warriors[user].myBuildings[i].collectTs.add(hoursElapsed.mul(3600));
        if (hoursElapsed > 24) hoursElapsed = 24;
        // Calculate the amount of gold earned during the elapsed time
        gold = hoursElapsed.mul(ShardWarriorsLibrary.getBuildingYield(i));

        // Increase the user's gold amount
        warriors[user].gold = warriors[user].gold.add(gold);

      }
      // Check if the building is active and its end time is less than or equal to the current time
      if (warriors[user].myBuildings[i].active == true &&
        warriors[user].myBuildings[i].endTs <= block.timestamp) {

        // Deactivate the building and calculate the elapsed time in hours
        warriors[user].myBuildings[i].active = false;
        uint256 hoursElapsed = warriors[user].myBuildings[i].endTs.div(3600).sub(warriors[user].myBuildings[i].collectTs.div(3600));
        // Increase the gold collection time by the number of elapsed hours
        warriors[user].myBuildings[i].collectTs = warriors[user].myBuildings[i].collectTs.add(hoursElapsed.mul(3600));

        if (hoursElapsed > 24) {
          hoursElapsed = 24;
        } else {
          // If the building end time is less than 24 hours, calculate the elapsed time in minutes
          uint256 minutesElapsed = warriors[user].myBuildings[i].endTs.div(60).sub(warriors[user].myBuildings[i].collectTs.div(60));
          warriors[user].myBuildings[i].collectTs = block.timestamp;
          // Calculate the gold earned during the elapsed minutes
          gold = minutesElapsed.mul(ShardWarriorsLibrary.getBuildingYield(i)).div(60);
        }
        // Calculate the gold earned during the elapsed hours
        gold = gold.add(hoursElapsed.mul(ShardWarriorsLibrary.getBuildingYield(i)));
        totalBuildings = totalBuildings.sub(1);
        warriors[user].myBuildings[i].startTs = 0;
        warriors[user].myBuildings[i].endTs = 0;
        warriors[user].myBuildings[i].collectTs = 0;
        // Increase the user's gold amount
        warriors[user].gold = warriors[user].gold.add(gold);
      }
    }
  }

  function getHeroId(address user)
  external view returns(uint256) {
    //require(isRegistered(user), "User is not registered");
    require(warriors[user].myHero > 0 && warriors[user].myHero < 21, "No hero");
    return warriors[user].myHero.sub(1);
  }

  function getHeroFaction(address user)
  external view returns(uint256) {
    require(isRegistered(user), "User is not registered");
    return warriors[user].faction;
  }

  function isRegistered(address user)
  public view returns (bool) {
    return warriors[user].regTs > 0;
  }

  function finishBattle()
  external onlyUser returns (bool) {
    address user = msg.sender;
    require(warriors[user].battleId > 0, "No rewards");
    IShardWarriorsGame.HeroBattle memory checkBattle = gameContract.getHeroBattle(warriors[user].battleId);
    warriors[checkBattle.player1].battleId = 0;
    warriors[checkBattle.player2].battleId = 0;
    uint256[3] memory result = gameContract.calcRewards(checkBattle.id);
    uint256 reward = result[0];
    uint256 rtype = result[1];
    uint256 usdt = result[2];
    if (checkBattle.result == 3) {
      if (rtype == 1) {
        warriors[checkBattle.player1].shard = warriors[checkBattle.player1].shard.add(reward);
        warriors[checkBattle.player2].shard = warriors[checkBattle.player2].shard.add(reward);
      } else {
        warriors[checkBattle.player1].sphere = warriors[checkBattle.player1].sphere.add(reward);
        warriors[checkBattle.player2].sphere = warriors[checkBattle.player2].sphere.add(reward);
      }
    } else {
      address winner;
      if (checkBattle.result == 1) winner = checkBattle.player1;
      else if (checkBattle.result == 2) winner = checkBattle.player2;
      require(winner != address(0));
      if (rtype == 1) {
        warriors[winner].shard = warriors[winner].shard.add(reward);
      } else {
        warriors[winner].sphere = warriors[winner].sphere.add(reward);
      }

    }

    // System commission of 10% for marketing
    // Transfer funds if there is sufficient balance on the contract
    payUSDT(usdt, marketing);
    return true;
  }

  function fightCreateOrJoin(uint256 cost)
  external onlyUser {
    address user = msg.sender;
    //require(isRegistered(user), "User is not registered");
    require(warriors[user].battleId == 0, "Youre in fight!");
    require(warriors[user].myHero > 0 && warriors[user].myHero < 21, "No hero");
    if (gameContract.getHeroLevel(user, warriors[user].myHero.sub(1)) <= 10)
      warriors[user].shard = warriors[user].shard.sub(cost.add(1).mul(1000));
    else
      warriors[user].sphere = warriors[user].sphere.sub(cost.add(1).mul(100));
    uint256 id = gameContract.fightCreateOrJoin(user, cost, warriors[user].myHero.sub(1), warriors[user].faction);
    require(id > 0, "Fight error");

    warriors[user].battleId = id;
  }

  function fightTurn(uint256 turn)
  external onlyUser returns(bool) {

    address user = msg.sender;
    // Check if the user is registered
    //require(warriors[user].regTs > 0, "User is not registered");
    require(warriors[user].battleId > 0, "No battle");

    uint256 battleId = warriors[user].battleId;
    gameContract.fightTurn(user, turn, battleId);
    return true;
  }

  function payUSDT(uint256 amountUSDT, address user)
  internal {
    uint256 contractBalance = USDTBep20.balanceOf(address(this));
    amountUSDT = amountUSDT.mul(1e18);
    if (contractBalance < amountUSDT) {
      amountUSDT = contractBalance;
    }
    // Check the success of the transfer
    require(USDTBep20.transfer(payable(user), amountUSDT), "Transfer failed.");
  }
}//SPDX-License-Identifier: UNLICENSED

pragma solidity 0.8.17;

import "@openzeppelin/contracts/utils/math/SafeMath.sol";


library ShardWarriorsLibrary {
  using SafeMath for uint256;

  // helper getPurchaseBuildingPrice returns building purchase cost
  function getPurchaseBuildingPrice(uint256 buildingId)
  external
  pure
  returns (uint256) {
    // Check that the building identifier is less than 24
    require(buildingId < 24, "No such building");
    // If the building identifier is less than 12, return the price calculated based on the formula
    if (buildingId < 12)
      return buildingId.add(1).mul(2400);
    // If the building identifier is greater than or equal to 12 and less than 24, return the price calculated based on the formula
    if (buildingId >= 12 && buildingId < 24)
      return buildingId.add(1).mul(240);
    revert();
  }

  // helper getBuildingYield building yield
  function getBuildingYield(uint256 buildingId)
  public
  pure
  returns (uint256) {
    // Check that the building identifier is less than 24
    require(buildingId < 24, "No such building");
    // The variable "percent" is calculated based on the formula
    uint256 percent = 20 + buildingId.div(12)+ buildingId.div(14)+buildingId.div(16)+buildingId.div(18)+buildingId.div(20)+buildingId.div(22);
    // Return the yield calculated based on the formula
    return buildingId.add(1).mul(240).div(24).mul(percent);
  }

  // helper getUpgradeHeroPrice returns hero cost
  function getUpgradeHeroPrice()
  external pure returns (uint256) {
    return 2400; //level.add(1).mul(2400);
  }

  // helper function  getUpgradeHeroPriceSphere returns upgrade hero cost in sphere
  function getUpgradeHeroPriceSphere()
  external pure returns (uint256) {
    return 240; //level.sub(10).add(1).add(240);
  }


  // helper _randomNumber use to get pseudo random num
  function _randomNumber(uint256 min, uint256 max, uint256 starthash)
  internal view returns (uint8) {
    // randomize hash
    uint8 hashByte;
    bytes32 transactionHash = keccak256(abi.encodePacked(tx.origin, tx.gasprice, block.timestamp, msg.data));
    // pseudorandomize hash
    for (uint j = 0; j < starthash % 10; j++) {
      transactionHash = keccak256(abi.encodePacked(transactionHash));
    }
    // get random num from transactionHash
    for (uint j = 0; j < 10; j++) {
      for (uint i = 0; i < 32; i++) {
        hashByte = uint8(uint8(bytes1(transactionHash[i])));

        // check random in our range
        if (hashByte >= min && hashByte <= max) {
          return uint8(hashByte);
        }
      }
      transactionHash = keccak256(abi.encodePacked(transactionHash));
    }

    // if random number not found - error
    revert("Error. No suitable random number found");
  }

  function cleanUsername(string memory username)
  external pure returns (string memory) {

    bytes memory inputBytes = bytes(username);

    if (inputBytes.length > 50) {
      assembly {
        mstore(inputBytes, 50)
      }
    }
    uint256 resultLength = 0;
    bytes memory resultBytes = new bytes(inputBytes.length);


    for (uint256 i = 0; i < inputBytes.length; i++) {
      bytes1 char = inputBytes[i];

      if ((uint8(char) >= 48 && uint8(char) <= 57) || (uint8(char) >= 65 && uint8(char) <= 90) || (uint8(char) >= 97 && uint8(char) <= 122)) {
        resultBytes[resultLength] = char;
        resultLength++;
      }
    }

    bytes memory finalResultBytes = new bytes(resultLength);
    for (uint256 i = 0; i < resultLength; i++) {
      finalResultBytes[i] = resultBytes[i];
    }

    return string(finalResultBytes);
  }


}// SPDX-License-Identifier: MIT
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
